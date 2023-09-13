---- EXEC Proc_FCY_ForeignGainloss @Date = '2019-01-04',@PartnerAccount = '111004015'
--EXEC Proc_FCY_ForeignGainloss @Date = '2019-01-02',@PartnerAccount = '111004015'
ALTER PROC Proc_FCY_ForeignGainloss
 @Date DATE ,
@PartnerAccount VARCHAR(20) 

AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS(SELECT 'A' FROM VW_PostedAccountDetail(nolock) where field2 = 'TRADING GAINLOSS FCY' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SELECT 'TRADING GAIN LOSS VOUCHER ALREADY GENERATED ON THIS DATE'+CAST(@Date AS VARCHAR) MSG
	RETURN
END

DECLARE @OPENING_RATE DECIMAL(10,4),@CLOSING_RATE FLOAT,@OPENING_JPY MONEY,@OPENING_USD MONEY,@ForeignExGain MONEY,@TradingGain MONEY,@RevalGain MONEY
DECLARE @TXN_JPY MONEY,@TXN_USD MONEY
DECLARE @CLOSING_JPY MONEY,@CLOSING_USD MONEY,@FCY_CLOSING_RATE MONEY
DECLARE @Narration varchar(100),@CURR VARCHAR(5)

SELECT @CURR = ac_currency FROM ac_master(NOLOCK) WHERE ACCT_NUM = @PartnerAccount AND acct_rpt_code IN('TPA','TPU')

----## OPENING KRW AND USD OF THAT ACCOUNT
SELECT @OPENING_JPY = SUM(case when part_tran_type='DR' then tran_amt*-1 else tran_amt end)
	,@OPENING_USD = ISNULL(SUM(case when part_tran_type='DR' then usd_amt*-1 else usd_amt end),0)
FROM VW_PostedAccountDetail(NOLOCK) 
WHERE tran_date < @Date AND ACC_NUM = @PartnerAccount

DECLARE @OpeningDate DATE = DATEADD(DAY,1,@Date)

SET @OPENING_RATE = @OPENING_USD/@OPENING_JPY

--UPDATE ALL THE TRANSACTIONS 
--SELECT DBO.DECRYPTDB(CONTROLNO) CONTROLNO, PAMT, TAMT INTO #TEMP_TRANSACTION
--FROM FASTMONEYPRO_REMIT.DBO.REMITTRAN (NOLOCK)
--WHERE PCOUNTRY = 'VIETNAM'
--AND CREATEDDATE BETWEEN @Date AND CAST(@Date AS VARCHAR) + ' 23:59:59'

--UPDATE M SET M.TRAN_AMT = M.USD_AMT/(PAMT/TAMT), M.USD_RATE = (PAMT/TAMT) 
--FROM #TEMP_TRANSACTION T
--INNER JOIN TRAN_MASTER M (NOLOCK) ON M.FIELD1 = T.CONTROLNO AND M.USD_AMT <> T.PAMT
--AND M.ACC_NUM IN ('111004015', '101003884')
--SELECT @CLOSING_RATE = SUM(ISNULL(USD_AMT, 0))/SUM(ISNULL(TRAN_AMT, 0))-- 211.60
--FROM VW_PostedAccountDetail(NOLOCK) 
--WHERE tran_date < @Date --AND field2 = 'DEAL BOOKING'
--AND fcy_curr = @CURR --and part_tran_type='DR'
--AND ACC_NUM = @PartnerAccount

----## GET ALL THE TRANSACTION DETAIL FROM ACCOUNT
SELECT tran_amt,ISNULL(usd_amt,0) usd_amt,USD_RATE,ISNULL(SendMargin,0) AS SendMargin,part_tran_type,field2,field1 INTO #TempTran
FROM VW_PostedAccountDetail(NOLOCK) 
WHERE tran_date  BETWEEN @Date AND CAST(@Date AS VARCHAR)+' 23:59:59' AND ACC_NUM = @PartnerAccount

ALTER TABLE #TempTran ADD sCurrCostRate MONEY,pCurrCostRate MONEY,VNDCOST DECIMAL(10, 4), controlNoEnc VARCHAR(30)

UPDATE #TempTran SET controlNoEnc = DBO.FNAEncryptString(field1)

UPDATE T SET T.sCurrCostRate = ISNULL(R.sCurrCostRate, 0),T.pCurrCostRate=ISNULL(R.pCurrCostRate, 0), 
T.SendMargin = CASE WHEN ISNULL(T.SendMargin, 0) = 0 THEN R.pCurrHoMargin ELSE ISNULL(T.SendMargin, 0) END
FROM #TempTran T
INNER JOIN [FastMoneyPro_Remit].DBO.remitTran R(NOLOCK) ON R.controlNo = controlNoEnc

--UPDATE #TempTran SET VNDCOST = pCurrCostRate / sCurrCostRate

SELECT @CLOSING_JPY = ISNULL(@OPENING_JPY,0) ,@CLOSING_USD = ISNULL(@OPENING_USD,0)


----## GET CLOSING BALANCE BEFORE TRADING / FOREIGN GAINLOSS
SELECT @CLOSING_JPY = @CLOSING_JPY + ISNULL(SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end),0)
	  ,@CLOSING_USD = @CLOSING_USD + ISNULL(SUM(case when part_tran_type='dr' then ISNULL(usd_amt,0)*-1 else ISNULL(usd_amt,0) end),0)
FROM #TempTran(NOLOCK)

--select @OPENING_JPY,@OPENING_USD
----## FOR GETTING OPENING BALANCE AND $ RATE
SELECT @OPENING_JPY = ISNULL(@OPENING_JPY,0) - ISNULL(SUM(tran_amt),0),@OPENING_USD = ISNULL(@OPENING_USD,0) - ISNULL(SUM(ISNULL(usd_amt,0)),0)
FROM #TempTran(NOLOCK) WHERE part_tran_type = 'DR' 


--## GET OPENING EXCHANGE RATE WHERE ALL DR ENTRY ALSO INCLUDED
IF ISNULL(@OPENING_JPY,0) = 0
	SET @OPENING_RATE = @CLOSING_RATE
ELSE
	SET @OPENING_RATE =  CAST(@OPENING_USD AS FLOAT)/@OPENING_JPY 


----## CALCULATING FOREIGN AND TRADING GAINLOSS
SELECT	@TXN_JPY			= SUM(tran_amt)
		,@TXN_USD		= SUM(ISNULL(usd_amt,0))
		--,@ForeignExGain = SUM((SendMargin) * (tran_amt / pCurrCostRate))							--SUM((tran_amt/(sCurrCostRate+SendMargin))*SendMargin)
		,@TradingGain	= (SUM(ISNULL(USD_AMT, 0)) - (SUM(ISNULL(TRAN_AMT, 0)) * @OPENING_RATE)) / @OPENING_RATE --SUM((ISNULL(tran_amt,0)*(VNDCOST - @OPENING_RATE))/VNDCOST)
FROM #TempTran(NOLOCK) WHERE part_tran_type = 'CR'  


--SELECT @CLOSING_JPY TXNKRW,@CLOSING_USD TXNUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@RevalGain RevalGain
BEGIN TRANSACTION
DECLARE @vouchertable TABLE (AccNum VARCHAR(20),tranType VARCHAR(2),tranAmt MONEY,sessionId VARCHAR(30),VoucherType VARCHAR(30),Curr VARCHAR(5))
DECLARE @TRADINGSESSION VARCHAR(30) = FORMAT(GETDATE(),'TRADINGyyyyMMdd')


----## TRADING GAINLOSS
IF @TradingGain <>0
BEGIN
	INSERT INTO @vouchertable(AccNum,tranType,tranAmt,sessionId,VoucherType,Curr)
	SELECT @PartnerAccount,CASE WHEN @TradingGain < 0 THEN 'DR' ELSE 'CR' END,ABS(@TradingGain),@TRADINGSESSION,'TRADING GAINLOSS FCY','JPY' UNION ALL
	SELECT '900139259454',CASE WHEN @TradingGain < 0 THEN 'CR' ELSE 'DR' END,ABS(@TradingGain),@TRADINGSESSION,'TRADING GAINLOSS FCY','JPY'
END

--SELECT * FROM AC_MASTER(NOLOCK) WHERE ACCT_NUM='771000937'
DROP TABLE #TempTran
--SELECT * FROM @vouchertable

DELETE FROM temp_tran WHERE sessionID IN (@TRADINGSESSION)

INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2)	
SELECT sessionId,'system',AccNum,'j',tranType,0,0,tranAmt,@Date,'USDVOUCHER',Curr,'','',VoucherType FROM @vouchertable

COMMIT TRANSACTION

IF NOT EXISTS(SELECT 'A' FROM VW_PostedAccountDetail T(nolock) where field2 = 'TRADING GAINLOSS FCY' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SET @Narration = 'FCY TRADING GAIN/LOSS DT : '+FORMAT(@Date,'yyyy-MM-dd')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @TRADINGSESSION,@date = @Date,@narration = @Narration,@company_id=1,@v_type='j',@user='system'
END
