USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_EOD_GainLoss_FCY]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_EOD_GainLoss_FCY]
@TxnDate varchar(20)

as
set nocount on;
DECLARE @dealUsd money,@dealLcy money

DECLARE @PositionUsd MONEY,@PositionKrw MONEY,@DealRowId BIGINT,@BuyRate money,@DealId bigint

if not exists(select 'a' from UsdStockSummary_Other(nolock) where TxnDate = @TxnDate and Curr = 'VND')
begin
	select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt,@DealRowId = ID,@BuyRate = Rate 
	from UsdStockSummary_Other(NOLOCK) where Curr = 'VND' ORDER BY Id DESC

	IF EXISTS(SELECT 'A' FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and isnull(Dealer,'') <>'Inter Bank Transfer'
		 and lcyCurr = 'VND')
	BEGIN
		SELECT @PositionUsd = isnull(@PositionUsd,0) +ISNULL(UsdAmt,0)
			,@PositionKrw = isnull(@PositionKrw,0)+isnull(LcyAmt,0)
			,@DealId = RowId 
		FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and lcyCurr = 'VND'
		AND isnull(Dealer,'') <> 'Inter Bank Transfer'
	END
	insert into UsdStockSummary_Other(UsdAmt,Rate,KRWAmt,TxnDate,tranId,Curr)
	select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@TxnDate,@DealId,'VND'
end
if not exists(select 'a' from UsdStockSummary_Other(nolock) where TxnDate = @TxnDate and Curr = 'LKR')
begin
	SELECT @PositionUsd=0,@PositionKrw=0,@DealRowId=NULL,@BuyRate=0
	select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt,@DealRowId = ID,@BuyRate = Rate 
	from UsdStockSummary_Other(NOLOCK) where Curr = 'LKR' ORDER BY Id DESC

	IF EXISTS(SELECT 'A' FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and isnull(Dealer,'') <>'Inter Bank Transfer'
		 and lcyCurr = 'LKR')
	BEGIN
		SELECT @PositionUsd = isnull(@PositionUsd,0) +ISNULL(UsdAmt,0)
			,@PositionKrw = isnull(@PositionKrw,0)+isnull(LcyAmt,0)
			,@DealId = RowId 
		FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and lcyCurr = 'LKR'
		AND isnull(Dealer,'') <> 'Inter Bank Transfer'
	END
	insert into UsdStockSummary_Other(UsdAmt,Rate,KRWAmt,TxnDate,tranId,Curr)
	select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@TxnDate,@DealId,'LKR'
end
if not exists(select 'a' from UsdStockSummary_Other(nolock) where TxnDate = @TxnDate and Curr = 'NPR')
begin
	SELECT @PositionUsd=0,@PositionKrw=0,@DealRowId=NULL,@BuyRate=0
	select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt,@DealRowId = ID,@BuyRate = Rate 
	from UsdStockSummary_Other(NOLOCK) where Curr = 'NPR' ORDER BY Id DESC

	IF EXISTS(SELECT 'A' FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and isnull(Dealer,'') <>'Inter Bank Transfer'
		 and lcyCurr = 'NPR')
	BEGIN
		SELECT @PositionUsd = isnull(@PositionUsd,0) +ISNULL(UsdAmt,0)
			,@PositionKrw = isnull(@PositionKrw,0)+isnull(LcyAmt,0)
			,@DealId = RowId 
		FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and lcyCurr = 'NPR'
		AND isnull(Dealer,'') <> 'Inter Bank Transfer'
	END
	insert into UsdStockSummary_Other(UsdAmt,Rate,KRWAmt,TxnDate,tranId,Curr)
	select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@TxnDate,@DealId,'NPR'
end

if not exists(select 'a' from UsdStockSummary_Other(nolock))
	return

select controlNo = dbo.FNADecryptString(controlNo),tranStatus='S',approvedDate,pAgent,payoutCurr into #temp
from SendMnPro_Remit.dbo.remitTran(nolock) 
where approvedDate between @TxnDate and dateadd(d,1,CAST(@TxnDate as date))
AND pAgent IN(2090,221271,1056)
order by approvedDate

DELETE FROM #temp WHERE pAgent = 2090 AND payoutCurr <> 'VND'
DELETE FROM #temp WHERE pAgent = 221271 AND payoutCurr <> 'LKR'

insert into #temp
select controlNo = dbo.FNADecryptString(controlNo),tranStatus = 'C',cancelApprovedDate,pAgent,payoutCurr
from SendMnPro_Remit.dbo.remitTran(nolock) 
where cancelApprovedDate between @TxnDate and dateadd(d,1,CAST(@TxnDate as date))
AND pAgent IN(2090,221271,1056)
order by cancelApprovedDate

DELETE FROM #temp WHERE pAgent = 2090 AND payoutCurr <> 'VND'
DELETE FROM #temp WHERE pAgent = 221271 AND payoutCurr <> 'LKR'

declare @str int = 1,@cnt int,@controlNo varchar(20)

select * into #tempSendTxn from #temp where tranStatus = 'S' 

alter table #tempSendTxn add rowId int identity(1,1)

select @cnt = count(1) from #tempSendTxn

----## GainLoss from send transaction
while @cnt >= @str
begin
	select @controlNo = controlNo from #tempSendTxn where rowId = @str
	exec proc_DailyGainLossCalculation_FCY @controlNo
	set @str = @str +1 
end	

select * into #tempCancelTxn from #temp where tranStatus = 'C' 

alter table #tempCancelTxn add rowId int identity(1,1)

select @cnt = count(1),@str = 1 from #tempCancelTxn

----## GainLoss from send transaction
while @cnt >= @str
begin
	select @controlNo = controlNo from #tempCancelTxn where rowId = @str
	exec proc_ReversalOfGainLoss_FCY @controlNo
	set @str = @str +1 
end	

GO
