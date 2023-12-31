USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_DailyGainLossCalculation_FCY]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_DailyGainLossCalculation_FCY]
(
	@controlNo	varchar(30) 
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

	declare @controlNoEnc varchar(50) = dbo.fnaencryptstring(@controlNo)
	
	IF EXISTS (select 'A' from tran_master(nolock) where field1 = @controlNo and tran_type='j' and field2='Remittance FX' )
	BEGIN
		RETURN
	END

	declare @pAgent int,@tAmt money,@sCurrCostRate money,@pAgentComm money,@ID INT,@TxnDate date
	declare @pAgentPrincipleAcc varchar(50),@agentSettCurr VARCHAR(10),@TxnFx varchar(15),@TradingFX varchar(15)
	
	declare @pAgentCommKRW money ,@PLAmount money
	DECLARE @PositionUsd MONEY,@PositionKrw MONEY,@DealRowId BIGINT,@BuyRate money

	DECLARE @pCurr VARCHAR(5),@CutomerRate DECIMAL(10,8),@pCurrCostRate money,@totalUsd money,@GainlossAmount money
			,@pAmt MONEY,@sCurrHoMargin MONEY,@TradingGL MONEY,@sessionID varchar(30)
	
	set @sessionID = @controlNo+'ex'

	delete from temp_tran WHERE sessionID = @sessionID

	select 
		@tAmt = round(tAmt,0),@pAgent = pAgent 
		,@sCurrCostRate = (sCurrCostRate+ISNULL(sCurrHoMargin,0)), @pAgentComm = pAgentComm
		,@ID = id,@TxnDate = approvedDate,@pCurr = payoutCurr,@CutomerRate = customerRate
		,@pCurrCostRate = pCurrCostRate,@pAmt = pAmt,@sCurrHoMargin = sCurrHoMargin
	from SendMnPro_Remit.dbo.remitTran (nolock) 
	where controlno = @controlNoEnc

	--## EXCLUDE DONGA DNV TXN FROM GAINLOSS ,CURRENCY IS DEALING DIRECTLY
	IF @pAgent not in(2090,221271,1056)
		return

	if exists(select 'a' from CorrenpondentLibilities_other(nolock) where TranId = @ID)
	begin
		return
	end
	if not exists(select 'a' from UsdStockSummary_other(nolock))
		return

BEGIN transaction
	select @agentSettCurr = agentSettCurr from SendMnPro_Remit.dbo.agentmaster(nolock) where agentid = @pAgent

	declare @pAmtUsd money

	SELECT @totalUsd = (@pAmt/@pCurrCostRate)+ case when @agentSettCurr ='USD' THEN @pAgentComm ELSE (@pAgentComm/@sCurrCostRate) END
	SET @GainlossAmount = @totalUsd * @sCurrHoMargin

	IF @pAgent in(221271) AND @pCurr = 'LKR' ----## COMMERCIAL BANK SRI LANKA
	begin
		set @pAmtUsd = ((@pAmt+@pAgentComm)/@pCurrCostRate) 
	end
	else
	begin
		set @pAmtUsd = (@pAmt/@pCurrCostRate)
	end
	
	set @TxnFx		= '900241088186'
	set @TradingFX	= '900141055635'

	SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TP'

	IF @pAgent in(2090,221271) AND @pCurr = 'USD'
	BEGIN
		SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TPU'
	END

DECLARE @TradingGL_TP money,@BuyRate_TP money,@BuyRate_usd money,@posId bigint

select TOP 1 @BuyRate = Rate from UsdStockSummary(NOLOCK) where TxnDate<=@TxnDate ORDER BY Id DESC

select TOP 1 @BuyRate_TP = Rate,@posId = Id,@PositionUsd=UsdAmt,@PositionKrw = KRWAmt from UsdStockSummary_Other(nolock) where Curr = @pCurr ORDER BY Id DESC

set @TradingGL_TP = (@pAmtUsd*@BuyRate_TP - @pAmtUsd*@pCurrCostRate)/@BuyRate_TP*@BuyRate
set @BuyRate_usd = @TradingGL_TP/@BuyRate

-- storing transaction gain loss
insert into [CorrenpondentLibilities_Other](TranId,ControlNo,UsdAmt,KRWAmt,Rate,TxnDate,TxnGain
	,PositionUsd,PositionKrw,BuyRate,DealRowId,TradingGL,UsdRate,Curr,TradingKrw)
select @ID,@controlNo,@pAmtUsd,@pAmt,@pAmt/@pAmtUsd,@TxnDate,@GainlossAmount
	,(@PositionUsd-@BuyRate_usd),@PositionKrw,@BuyRate_TP,@posId,@BuyRate_usd,@BuyRate,@pCurr,@TradingGL_TP

select @PositionUsd = isnull(@PositionUsd,0) - @pAmtUsd + isnull(@BuyRate_usd,0),@PositionKrw = isnull(@PositionKrw,0) - @pAmt 

insert into UsdStockSummary_Other(UsdAmt,Rate,KRWAmt,TxnDate,TxnType,tranId,Curr)
select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@TxnDate,'S',@ID,@pCurr

/*
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2)	
	SELECT @sessionID,'system',@pAgentPrincipleAcc,'j'
	,CASE WHEN @PLAmount>0 THEN 'DR' ELSE 'CR' END,abs(@PLAmount),1,abs(@PLAmount),@TxnDate
		,'USDVOUCHER','USD','',@controlNo,'Remittance FX'

-- entry for trading FX
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2)	
	SELECT @sessionID,'system',@TradingFX,'j'
		,CASE WHEN @TradingGL>0 THEN 'DR' ELSE 'CR' END,abs(@TradingGL),1,abs(@TradingGL),@TxnDate
		,'USDVOUCHER','KRW','',@controlNo,'Remittance FX'

-- entry for transaction FX
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2)	
	SELECT @sessionID,'system',@TxnFx,'j','CR',@GainlossAmount,1,@GainlossAmount,@TxnDate
		,'USDVOUCHER','KRW','',@controlNo,'Remittance FX'

SELECT a.acct_name,t.tran_amt,t.usd_amt,t.usd_rate,t.* FROM temp_tran t(nolock)
inner join ac_master a(nolock) on a.acct_num = t.acct_num
WHERE sessionID = @sessionID

*/
commit transaction
return	
--declare @narration varchar(500) = 'Gainloss of control no : '+@controlNo+' on dtd: '+cast(@TxnDate as varchar)
--exec [spa_saveTempTrnUSD] @flag='i',@sessionID = @sessionID,@date = @TxnDate,@narration = @narration,@company_id = 1,@v_type = 'j',@user = 'system'

GO
