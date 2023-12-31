USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ForeignGainloss_KRWVSOTHER]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---- EXEC Proc_ForeignGainloss_KRWVSOTHER @Date = '2018-09-21',@PartnerAccount = '771474249'

CREATE PROC [dbo].[Proc_ForeignGainloss_KRWVSOTHER]
 @Date DATE ,
@PartnerAccount VARCHAR(20) 

AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;

--DECLARE @Date date = '2017-10-31',@PartnerAccount varchar(20) = '771000937'
 
--IF NOT EXISTS(SELECT 'A' FROM tran_master(nolock) where field2 = 'FOREIGN GAIN' AND tran_date = DATEADD(day,-1,@Date)  and acc_num = @PartnerAccount)
--BEGIN
--	SELECT 'PREVIOUS DAY FOREX GAIN LOSS VOUCHER ALREADY GENERATED PENDING'+CAST(@Date AS VARCHAR) SMG
--	RETURN
--END

IF EXISTS(SELECT 'A' FROM tran_master(nolock) where field2 = 'FOREIGN GAIN FCY' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SELECT 'FOREX GAIN LOSS VOUCHER ALREADY GENERATED ON THIS DATE'+CAST(@Date AS VARCHAR) SMG
	RETURN
END

DECLARE @OPENINGRATE DECIMAL(10,8),@CLOSINGRATE FLOAT,@OKRW MONEY,@OUSD MONEY,@ForeignExGain MONEY,@TradingGain MONEY,@RevalGain MONEY
DECLARE @TXNKRW MONEY,@TXNUSD MONEY
DECLARE @CLOSINGKRW MONEY,@CLOSINGUSD MONEY,@FCYCLOSINGRATE MONEY
DECLARE @Narration varchar(100),@CURR VARCHAR(5)

SELECT @CURR = ac_currency FROM ac_master(NOLOCK) WHERE ACCT_NUM = @PartnerAccount

----## OPENING KRW AND USD OF THAT ACCOUNT
SELECT @OKRW = SUM(case when part_tran_type='DR' then tran_amt*-1 else tran_amt end)
	,@OUSD = ISNULL(SUM(case when part_tran_type='DR' then usd_amt*-1 else usd_amt end),0)
FROM tran_master(NOLOCK) 
WHERE tran_date < @Date AND ACC_NUM = @PartnerAccount

DECLARE @OpeningDate DATE = DATEADD(DAY,1,@Date)

----## get CLOSING RATE FROM LAST RATE DEFINED IN SYSTEM
SELECT TOP 1  @CLOSINGRATE = pRate FROM [FastMoneyPro_Remit].DBO.defExRateHistory(NOLOCK) 
WHERE country = 105 and currency='IDR' AND baseCurrency ='KRW' AND createdDate < @OpeningDate 
ORDER BY createdDate DESC
--select @OKRW,@OUSD,@CLOSINGRATE
--return
------## GET CLOSING DEAL RATE
IF ISNULL(@CLOSINGRATE,0)=0
BEGIN
	SELECT TOP 1 @CLOSINGRATE = usd_rate
	FROM tran_master(NOLOCK) 
	WHERE tran_date  <= @Date AND field2 = 'DEAL BOOKING'
	AND fcy_curr = 'IDR' and part_tran_type='DR'
	AND ACC_NUM = @PartnerAccount
	ORDER BY tran_date DESC,tran_id DESC
END

--select @OKRW,@OUSD,@CLOSINGRATE
--return

----## GET ALL THE TRANSACTION DETAIL FROM ACCOUNT
SELECT tran_amt,ISNULL(usd_amt,0) usd_amt,USD_RATE,ISNULL(SendMargin,0) AS SendMargin,part_tran_type,field2,field1 INTO #TempTran
FROM tran_master(NOLOCK) 
WHERE tran_date  BETWEEN @Date AND CAST(@Date AS VARCHAR)+' 23:59:59' AND ACC_NUM = @PartnerAccount
----and field2 not IN ('FOREIGN GAIN FCY','TRADING GAINLOSS FCY','REVALUATION GAINLOSS FCY')

ALTER TABLE #TempTran ADD sCurrCostRate MONEY,pCurrCostRate MONEY,VNDCOST DECIMAL(10,8)

UPDATE T SET T.pCurrCostRate=R.pCurrCostRate FROM #TempTran T
INNER JOIN [FastMoneyPro_Remit].DBO.remitTran R(NOLOCK) ON R.controlNo = DBO.FNAEncryptString(T.field1)

--UPDATE #TempTran SET VNDCOST = CAST(pCurrCostRate AS FLOAT)/sCurrCostRate

SELECT @CLOSINGKRW = ISNULL(@OKRW,0) ,@CLOSINGUSD = ISNULL(@OUSD,0)

----## GET CLOSING BALANCE BEFORE TRADING / FOREIGN GAINLOSS
SELECT @CLOSINGKRW = @CLOSINGKRW + ISNULL(SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end),0)
	  ,@CLOSINGUSD = @CLOSINGUSD + ISNULL(SUM(case when part_tran_type='dr' then ISNULL(usd_amt,0)*-1 else ISNULL(usd_amt,0) end),0)
FROM #TempTran(NOLOCK)

--select @OKRW,@OUSD
----## FOR GETTING OPENING BALANCE AND $ RATE
SELECT @OKRW = ISNULL(@OKRW,0) - ISNULL(SUM(tran_amt),0),@OUSD = ISNULL(@OUSD,0) - ISNULL(SUM(ISNULL(usd_amt,0)),0)
FROM #TempTran(NOLOCK) WHERE part_tran_type = 'DR' 

--select @OKRW,@OUSD
--select @OKRW,@OUSD,* FROM #TempTran(NOLOCK) WHERE part_tran_type = 'DR' 

--## GET OPENING EXCHANGE RATE WHERE ALL DR ENTRY ALSO INCLUDED
IF ISNULL(@OKRW,0) = 0
	SET @OpeningRate = @CLOSINGRATE
ELSE
	SET @OpeningRate =  CAST(@OUSD AS FLOAT)/@OKRW 

--SELECT @OKRW KRW, @OUSD OUSD,@OpeningRate RATE,@CLOSINGRATE
--RETURN
--select *,@OpeningRate OpeningRate,(ISNULL(usd_amt,0)*(USD_RATE-ISNULL(SendMargin,0))) -(ISNULL(usd_amt,0)* @OpeningRate) FROM #TempTran(NOLOCK) WHERE part_tran_type = 'CR' 

--SELECT *,@OpeningRate OpeningRate FROM #TempTran(NOLOCK) WHERE part_tran_type = 'CR'  

----## CALCULATING FOREIGN AND TRADING GAINLOSS
SELECT	@TXNKRW			= SUM(tran_amt)
		,@TXNUSD		= SUM(ISNULL(usd_amt,0))
		,@ForeignExGain = SUM((tran_amt * SendMargin)/pCurrCostRate)
		,@TradingGain	= SUM((tran_amt * @OpeningRate-tran_amt * pCurrCostRate) / pCurrCostRate)
FROM #TempTran(NOLOCK) WHERE part_tran_type = 'CR'  

--IF ISNULL(@TXNKRW,0) = 0
--BEGIN
--	SELECT 'TRANSACTION NOT FOUND'
--	RETURN
--END

--SELECT @CLOSINGKRW TXNKRW,@CLOSINGUSD TXNUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@OpeningRate OpeningRate

----## ADDING FOREIGN GAINLOSS IN CLOSING KRW
SET @CLOSINGKRW = @CLOSINGKRW - ISNULL(@ForeignExGain,0)
--SELECT @CLOSINGKRW CLOSINGKRW,@CLOSINGUSD CLOSINGUSD

SET @TradingGain = @CLOSINGKRW - @CLOSINGUSD / @OpeningRate

----SET @CLOSINGKRW = @CLOSINGKRW + ISNULL(@TradingGain,0)
SET @CLOSINGKRW = @CLOSINGKRW - ISNULL(@TradingGain,0)

--SELECT @CLOSINGKRW CLOSINGKRW,@CLOSINGUSD CLOSINGUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@CLOSINGRATE CLOSINGRATE

----## GETTING REVALUTATION GAINLOSS
SET @RevalGain = @CLOSINGUSD / @CLOSINGRATE
--SELECT @RevalGain RevalGain,@CLOSINGUSD CLOSINGUSD,@CLOSINGRATE
SET @RevalGain = @CLOSINGKRW - ISNULL(@RevalGain,0)

--SELECT @OKRW OKRW,@OUSD OFCY ,@CLOSINGKRW CLOSINGKRW,@CLOSINGUSD CLOSINGUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@OpeningRate OpeningRate,@CLOSINGRATE CLOSINGRATE
--,@RevalGain RevalGain, CLOSINGKRW = @CLOSINGKRW - @RevalGain

--SELECT @CLOSINGKRW TXNKRW,@CLOSINGUSD TXNUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@RevalGain RevalGain
BEGIN TRANSACTION
DECLARE @vouchertable TABLE (AccNum VARCHAR(20),tranType VARCHAR(2),tranAmt MONEY,sessionId VARCHAR(30),VoucherType VARCHAR(30),Curr VARCHAR(5))
DECLARE @FOREIGNSESSION VARCHAR(30),@TRADINGSESSION VARCHAR(30),@REVALUATIONSESSION VARCHAR(30)
SELECT @FOREIGNSESSION = FORMAT(GETDATE(),'FOREIGNyyyyMMdd'),@TRADINGSESSION = FORMAT(GETDATE(),'TRADINGyyyyMMdd'),@REVALUATIONSESSION = FORMAT(GETDATE(),'REVALyyyyMMdd')

----## FOREIGN EXCHANGE GAINLOSS
IF @ForeignExGain <>0 
BEGIN
	INSERT INTO @vouchertable(AccNum,tranType,tranAmt,sessionId,VoucherType,Curr)
	SELECT @PartnerAccount,CASE WHEN @ForeignExGain > 0 THEN 'DR' ELSE 'CR' END,ABS(@ForeignExGain),@FOREIGNSESSION,'FOREIGN GAIN FCY',@CURR UNION ALL
	SELECT '900141084569',CASE WHEN @ForeignExGain > 0 THEN 'CR' ELSE 'DR' END,ABS(@ForeignExGain),@FOREIGNSESSION,'FOREIGN GAIN FCY','KRW'
END
----## TRADING GAINLOSS
IF @TradingGain <>0
BEGIN
	INSERT INTO @vouchertable(AccNum,tranType,tranAmt,sessionId,VoucherType,Curr)
	SELECT @PartnerAccount,CASE WHEN @TradingGain > 0 THEN 'DR' ELSE 'CR' END,ABS(@TradingGain),@TRADINGSESSION,'TRADING GAINLOSS FCY',@CURR UNION ALL
	SELECT '900141055635',CASE WHEN @TradingGain > 0 THEN 'CR' ELSE 'DR' END,ABS(@TradingGain),@TRADINGSESSION,'TRADING GAINLOSS FCY','KRW'
END
----## REVALUATION GAINLOSS
IF @RevalGain <>0
BEGIN
	INSERT INTO @vouchertable(AccNum,tranType,tranAmt,sessionId,VoucherType,Curr)
	SELECT @PartnerAccount,CASE WHEN @RevalGain > 0 THEN 'DR' ELSE 'CR' END,ABS(@RevalGain),@REVALUATIONSESSION,'REVALUATION GAINLOSS FCY',@CURR UNION ALL
	SELECT '900141091390',CASE WHEN @RevalGain > 0 THEN 'CR' ELSE 'DR' END,ABS(@RevalGain),@REVALUATIONSESSION,'REVALUATION GAINLOSS FCY','KRW'
END

--SELECT * FROM AC_MASTER(NOLOCK) WHERE ACCT_NUM='771000937'
DROP TABLE #TempTran
--SELECT * FROM @vouchertable

DELETE FROM temp_tran WHERE sessionID IN (@FOREIGNSESSION,@TRADINGSESSION,@REVALUATIONSESSION)

INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2)	
SELECT sessionId,'system',AccNum,'j',tranType,0,0,tranAmt,@Date,'USDVOUCHER',Curr,'','',VoucherType FROM @vouchertable

COMMIT TRANSACTION
--select * from @vouchertable
--RETURN

IF NOT EXISTS(SELECT 'A' FROM tran_master T(nolock) where field2 = 'FOREIGN GAIN FCY' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SET @Narration = 'FCY FOREIGN EXCHANGE GAIN DT : '+FORMAT(@Date,'yyyy-MM-dd')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @FOREIGNSESSION,@date = @Date,@narration = @Narration,@company_id=1,@v_type='j',@user='system'
END

IF NOT EXISTS(SELECT 'A' FROM tran_master T(nolock) where field2 = 'TRADING GAINLOSS FCY' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SET @Narration = 'FCY TRADING GAIN/LOSS DT : '+FORMAT(@Date,'yyyy-MM-dd')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @TRADINGSESSION,@date = @Date,@narration = @Narration,@company_id=1,@v_type='j',@user='system'
END

IF NOT EXISTS(SELECT 'A' FROM tran_master T(nolock) where field2 = 'REVALUATION GAINLOSS FCY' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SET @Narration = 'FCY REVALUATION GAIN/LOSS DT : '+FORMAT(@Date,'yyyy-MM-dd')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @REVALUATIONSESSION,@date = @Date,@narration = @Narration,@company_id=1,@v_type='j',@user='system'
END
GO
