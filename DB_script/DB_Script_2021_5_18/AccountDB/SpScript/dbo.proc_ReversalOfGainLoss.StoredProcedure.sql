USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_ReversalOfGainLoss]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_ReversalOfGainLoss]
(
	@controlNo	varchar(30) 
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

	declare @controlNoEnc varchar(50) = dbo.fnaencryptstring(@controlNo)

	IF EXISTS (select 'A' from tran_master(nolock) where field1 = @controlNo and tran_type='j' 
		and field2='Remittance FX' and isnull(acct_type_code,'') = 'Reverse')
	BEGIN
		return
	END

	declare @refNum varchar(50),@tranType varchar(10),@remarks varchar(100),@txnDate date,@tranId bigint
	declare @PositionUsd money,@PositionKrw money

	select @txnDate = cancelApprovedDate,@tranId = id from SendMnPro_Remit.dbo.remitTran(nolock) 
	where controlNo = @controlNoEnc

	IF EXISTS(select 'a' from UsdStockSummary(nolock) where tranId = @tranId and TxnType = 'C')
		return

	set @remarks = 'Cancelation of Gainloss Transaction :'+@controlNo

begin transaction
	--select @refNum = ref_num,@tranType = tran_type
	--from tran_master(nolock) where field1 = @controlNo and field2='Remittance FX'

	--declare @tempTbl table (errorcode varchar(5), msg varchar(max), id varchar(50))
	--insert into @tempTbl(errorcode, msg, id)
	--EXEC proc_EditVoucher @flag='REVERSE',@refNum = @refNum,@vType = @tranType,@User = 'system',@remarks = @remarks
		
	select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt
	from UsdStockSummary(NOLOCK) ORDER BY Id DESC

	SELECT @PositionUsd = ISNULL(@PositionUsd,0)+UsdAmt,@PositionKrw = ISNULL(@PositionKrw,0) + KRWAmt - isnull(TradingGL,0)
			,@tranId = TranId
	FROM CorrenpondentLibilities(NOLOCK) WHERE ControlNo = @controlNo
	
	insert into UsdStockSummary(UsdAmt,Rate,KRWAmt,TxnDate,TxnType,tranId)
	select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@txnDate,'C',@tranId

	INSERT INTO CorrenpondentLibilities(TranId,UsdAmt,Rate,KRWAmt,TxnDate,TxnGain,TradingGL,TxnType
		,PositionUsd,PositionKrw,BuyRate,ControlNo)
	SELECT TranId,UsdAmt*-1,Rate,KRWAmt*-1,@txnDate,TxnGain*-1,TradingGL*-1,'C'
		,@PositionUsd,@PositionKrw,@PositionKrw/@PositionUsd,ControlNo 
	FROM CorrenpondentLibilities(nolock) WHERE ControlNo = @controlNo 

commit transaction


GO
