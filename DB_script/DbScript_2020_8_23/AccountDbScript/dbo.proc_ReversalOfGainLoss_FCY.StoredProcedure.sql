ALTER PROC [dbo].[proc_ReversalOfGainLoss_FCY]
(
	@controlNo	varchar(30) 
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

	declare @controlNoEnc varchar(50) = dbo.fnaencryptstring(@controlNo)

	declare @refNum varchar(50),@tranType varchar(10),@remarks varchar(100),@txnDate date,@tranId bigint
	declare @PositionUsd money,@PositionKrw money,@pAgent int,@curr varchar(5)

	select @txnDate = cancelApprovedDate,@tranId = id,@pAgent = pagent ,@curr = payoutCurr
	from SendMnPro_Remit.dbo.remitTran(nolock) 
	where controlNo = @controlNoEnc

	IF EXISTS(select 'a' from UsdStockSummary_Other(nolock) where tranId = @tranId and TxnType = 'C')
		return

	set @remarks = 'Cancelation of Gainloss Transaction :'+@controlNo

begin transaction
	--select @refNum = ref_num,@tranType = tran_type
	--from tran_master(nolock) where field1 = @controlNo and field2='Remittance FX'

	--declare @tempTbl table (errorcode varchar(5), msg varchar(max), id varchar(50))
	--insert into @tempTbl(errorcode, msg, id)
	--EXEC proc_EditVoucher @flag='REVERSE',@refNum = @refNum,@vType = @tranType,@User = 'system',@remarks = @remarks
		
	select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt from UsdStockSummary_Other(NOLOCK) 
	WHERE CURR = @curr
	ORDER BY Id DESC

	SELECT @PositionUsd = ISNULL(@PositionUsd,0)+UsdAmt- isnull(TradingGL,0),@PositionKrw = ISNULL(@PositionKrw,0) + KRWAmt ,@tranId = TranId
	FROM CorrenpondentLibilities_Other(NOLOCK) WHERE ControlNo = @controlNo
	
	insert into UsdStockSummary_Other(UsdAmt,Rate,KRWAmt,TxnDate,TxnType,tranId,Curr)
	select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@txnDate,'C',@tranId,@curr

	INSERT INTO CorrenpondentLibilities_Other(TranId,UsdAmt,Rate,KRWAmt,TxnDate,TxnGain,TradingGL,TxnType
		,PositionUsd,PositionKrw,BuyRate,ControlNo,Curr,UsdRate,TradingKrw,DealRowId)
	SELECT TranId,UsdAmt*-1,Rate,KRWAmt*-1,@txnDate,TxnGain*-1,TradingGL*-1,'C'
		,@PositionUsd,@PositionKrw,@PositionKrw/@PositionUsd,ControlNo,Curr,UsdRate,TradingKrw*-1,DealRowId
	FROM CorrenpondentLibilities_Other(nolock) WHERE ControlNo = @controlNo 

commit transaction



GO
