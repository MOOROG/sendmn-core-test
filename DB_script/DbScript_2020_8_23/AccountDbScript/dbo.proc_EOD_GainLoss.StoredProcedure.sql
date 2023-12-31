ALTER  proc [dbo].[proc_EOD_GainLoss]
@TxnDate varchar(20)

as
set nocount on;

DECLARE @PositionUsd MONEY,@PositionKrw MONEY,@DealRowId BIGINT,@BuyRate money,@DealId bigint
if not exists(select 'a' from UsdStockSummary(nolock) where TxnDate = @TxnDate)
begin
	select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt,@DealRowId = ID,@BuyRate = Rate 
	from UsdStockSummary(NOLOCK) ORDER BY Id DESC

	IF EXISTS(SELECT 'A' FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and isnull(Dealer,'') <>'Inter Bank Transfer'
		 and lcyCurr is null )
	BEGIN
		SELECT @PositionUsd = ISNULL(@PositionUsd,0)+UsdAmt,@PositionKrw = ISNULL(@PositionKrw,0)+LcyAmt
			,@DealId = RowId 
		FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and lcyCurr is null
		AND isnull(Dealer,'') <> 'Inter Bank Transfer'
	END
	insert into UsdStockSummary(UsdAmt,Rate,KRWAmt,TxnDate,tranId)
	select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@TxnDate,@DealId
end

select controlNo = dbo.FNADecryptString(controlNo),tranStatus='S',approvedDate into #temp
from SendMnPro_Remit.dbo.remitTran(nolock) 
where approvedDate between @TxnDate and dateadd(d,1,CAST(@TxnDate as date))
--AND payoutCurr NOT IN ('VND') 
AND pAgent <> '221227'
order by approvedDate

insert into #temp
select controlNo = dbo.FNADecryptString(controlNo),tranStatus = 'C',cancelApprovedDate
from SendMnPro_Remit.dbo.remitTran(nolock) 
where cancelApprovedDate between @TxnDate and dateadd(d,1,CAST(@TxnDate as date))
--AND payoutCurr NOT IN ('VND') 
AND pAgent <> '221227'
order by cancelApprovedDate

declare @str int = 1,@cnt int,@controlNo varchar(20)

select * into #tempSendTxn from #temp where tranStatus = 'S' 

alter table #tempSendTxn add rowId int identity(1,1)

select @cnt = count(1) from #tempSendTxn

----## GainLoss from send transaction
while @cnt >= @str
begin
	select @controlNo = controlNo from #tempSendTxn where rowId = @str
	exec proc_DailyGainLossCalculation @controlNo
	set @str = @str +1 
end	

select * into #tempCancelTxn from #temp where tranStatus = 'C' 

alter table #tempCancelTxn add rowId int identity(1,1)

select @cnt = count(1),@str = 1 from #tempCancelTxn

----## GainLoss from send transaction
while @cnt >= @str
begin
	select @controlNo = controlNo from #tempCancelTxn where rowId = @str
	exec proc_ReversalOfGainLoss @controlNo
	set @str = @str +1 
end	
GO
