ALTER proc [dbo].[proc_DailyGainLossCalculation]
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

	declare @pAgent int,@tAmt money,@sCurrCostRate money,@pAgentComm money,@ID INT,@TxnDate date,@pAgentCommCurrency varchar(5)
	declare @pAgentPrincipleAcc varchar(50),@agentSettCurr VARCHAR(10),@TxnFx varchar(15),@TradingFX varchar(15)
	
	declare @pAgentCommKRW money ,@PLAmount money
	DECLARE @PositionUsd MONEY,@PositionKrw MONEY,@DealRowId BIGINT,@BuyRate money

	DECLARE @pCurr VARCHAR(5),@CutomerRate DECIMAL(10,8),@pCurrCostRate money,@totalUsd money,@GainlossAmount money
			,@pAmt MONEY,@sCurrHoMargin MONEY,@TradingGL MONEY,@sessionID varchar(30)
	
	set @sessionID = @controlNo+'ex'

	delete from temp_tran WHERE sessionID = @sessionID

	select 
		@tAmt = round(tAmt,0),@pAgent = pAgent 
		,@sCurrCostRate = (sCurrCostRate+ISNULL(sCurrHoMargin,0)), @pAgentComm = pAgentComm,@pAgentCommCurrency = pAgentCommCurrency
		,@ID = id,@TxnDate = approvedDate,@pCurr = payoutCurr,@CutomerRate = customerRate
		,@pCurrCostRate = pCurrCostRate,@pAmt = pAmt,@sCurrHoMargin = sCurrHoMargin
	from SendMnPro_Remit.dbo.remitTran (nolock) 
	where controlno = @controlNoEnc

	DECLARE @DealId bigint
--excluding ria transaction
	IF @pAgent IN(221227)
		RETURN

	--if not exists(select 'a' from UsdStockSummary(nolock) where TxnDate = @TxnDate)
	--begin
	--	select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt,@DealRowId = ID,@BuyRate = Rate 
	--	from UsdStockSummary(NOLOCK) ORDER BY Id DESC

	--	IF EXISTS(SELECT 'A' FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate and isnull(Dealer,'') <>'Inter Bank Transfer')
	--	BEGIN
	--		SELECT @PositionUsd = ISNULL(@PositionUsd,0)+UsdAmt,@PositionKrw = ISNULL(@PositionKrw,0)+LcyAmt
	--			,@DealId = RowId 
	--		FROM DealBookingHistory(NOLOCK) WHERE DealDate = @TxnDate
	--	END
		
	--	insert into UsdStockSummary(UsdAmt,Rate,KRWAmt,TxnDate,tranId)
	--	select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@TxnDate,@DealId
	--end
	if exists(select 'a' from CorrenpondentLibilities(nolock) where TranId = @ID)
	begin
		return
	end
	if not exists(select 'a' from UsdStockSummary(nolock))
		return

BEGIN transaction
	select @agentSettCurr = agentSettCurr from SendMnPro_Remit.dbo.agentmaster(nolock) where agentid = @pAgent

	declare @partnerKrw money,@pAmtUsd money

	if @pAgent in (221271)
	begin
		SELECT @totalUsd = CASE WHEN @pCurr = 'LKR' THEN (@pAmt/@pCurrCostRate) WHEN  @pCurr = 'USD' THEN (@pAmt+@pAgentComm) ELSE 0 END
	end
	else
	begin
		SELECT @totalUsd = (@pAmt/@pCurrCostRate)+ case when @pAgentCommCurrency ='USD' THEN @pAgentComm ELSE (@pAgentComm/@sCurrCostRate) END
	end
	SET @GainlossAmount = @totalUsd * @sCurrHoMargin

	set @pAmtUsd = (@pAmt/@pCurrCostRate)
	set @partnerKrw = @tAmt - @GainlossAmount
	
	set @TxnFx		= '900241088186'
	set @TradingFX	= '900141055635'

	SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TP'

	IF @pAgent in( 2090,221271) AND @pCurr = 'USD'
	BEGIN
		SELECT @pAgentPrincipleAcc = acct_num FROM ac_master(NOLOCK) WHERE agent_id = @pAgent AND acct_rpt_code='TPU'
	END

	if @pAgent in (221271) AND @pCurr = 'USD'
	begin
		set @partnerKrw = @partnerKrw + @pAgentComm*@sCurrCostRate
	end
	else
	begin
		set @partnerKrw = @partnerKrw + 
			CASE	WHEN @pAgentCommCurrency = 'USD' THEN(@pAgentComm*@sCurrCostRate) 
					WHEN @pAgentCommCurrency = 'LKR' THEN(@pAgentComm/ @CutomerRate) ELSE @pAgentComm END
	end

select TOP 1 @PositionUsd = UsdAmt,@PositionKrw = KRWAmt,@DealRowId = ID,@BuyRate = Rate 
from UsdStockSummary(NOLOCK) ORDER BY Id DESC

set @TradingGL = @partnerKrw - (@totalUsd * @BuyRate)
SET @PLAmount = @GainlossAmount - @TradingGL

----storing transaction gain loss
insert into CorrenpondentLibilities(TranId,ControlNo,UsdAmt,KRWAmt,Rate,TxnDate,TxnGain
	,PositionUsd,PositionKrw,BuyRate,DealRowId,TradingGL)
select @ID,@controlNo,@totalUsd,@partnerKrw,@partnerKrw/@totalUsd,@TxnDate,@GainlossAmount
	,(@PositionUsd-@totalUsd),(@PositionKrw-isnull(@partnerKrw,0)+isnull(@TradingGL,0)),@BuyRate,@DealRowId,@TradingGL

select @PositionUsd = isnull(@PositionUsd,0) - @totalUsd,@PositionKrw = isnull(@PositionKrw,0) - @partnerKrw + isnull(@TradingGL,0)

insert into UsdStockSummary(UsdAmt,Rate,KRWAmt,TxnDate,TxnType,tranId)
select @PositionUsd,@PositionKrw/@PositionUsd,@PositionKrw,@TxnDate,'S',@ID

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
declare @narration varchar(500) = 'Gainloss of control no : '+@controlNo+' on dtd: '+cast(@TxnDate as varchar)
exec [spa_saveTempTrnUSD] @flag='i',@sessionID = @sessionID,@date = @TxnDate,@narration = @narration,@company_id = 1,@v_type = 'j',@user = 'system'

GO
