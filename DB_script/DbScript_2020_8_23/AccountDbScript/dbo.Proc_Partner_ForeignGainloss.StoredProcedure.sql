ALTER  PROC [dbo].[Proc_Partner_ForeignGainloss]
@Date DATE,
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

IF EXISTS(SELECT 'A' FROM tran_master(nolock) where field2 = 'FOREIGN GAIN' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SELECT 'FOREX GAIN LOSS VOUCHER ALREADY GENERATED ON THIS DATE'+CAST(@Date AS VARCHAR) SMG
	RETURN
END

DECLARE @OPENINGRATE MONEY,@CLOSINGRATE MONEY,@OKRW MONEY,@OUSD MONEY,@ForeignExGain MONEY,@TradingGain MONEY,@RevalGain MONEY
DECLARE @TXNKRW MONEY,@TXNUSD MONEY
DECLARE @CLOSINGKRW MONEY,@CLOSINGUSD MONEY
DECLARE @Narration varchar(100)

----## OPENING KRW AND USD OF THAT ACCOUNT
SELECT @OKRW = SUM(case when part_tran_type='DR' then tran_amt*-1 else tran_amt end)
	,@OUSD = ISNULL(SUM(case when part_tran_type='DR' then usd_amt*-1 else usd_amt end),0)
FROM tran_master(NOLOCK) 
WHERE tran_date < @Date AND ACC_NUM = @PartnerAccount

DECLARE @OpeningDate DATE = DATEADD(DAY,1,@Date)

----## get CLOSING RATE FROM LAST RATE DEFINED IN SYSTEM
SELECT TOP 1  @CLOSINGRATE = cRate FROM SendMnPro_Remit.dbo.defExRateHistory(NOLOCK) 
WHERE Country = 118 AND createdDate < @OpeningDate ORDER BY ROWID DESC
--select @OKRW,@OUSD
--return
----## GET CLOSING DEAL RATE
--SELECT TOP 1 @CLOSINGRATE = usd_rate
--FROM tran_master(NOLOCK) 
--WHERE tran_date  <= @Date AND field2 = 'DEAL BOOKING'
--AND fcy_curr = 'USD' and part_tran_type='DR'
--ORDER BY tran_date DESC,tran_id DESC

----## GET ALL THE TRANSACTION DETAIL FROM ACCOUNT
SELECT tran_amt,ISNULL(usd_amt,0) usd_amt,USD_RATE,ISNULL(SendMargin,0) AS SendMargin,part_tran_type,field2 INTO #TempTran
FROM tran_master(NOLOCK) 
WHERE tran_date  BETWEEN @Date AND CAST(@Date AS VARCHAR)+' 23:59:59' AND ACC_NUM = @PartnerAccount
--and ISNULL(field2,'') not IN ('FOREIGN GAIN','TRADING GAINLOSS','REVALUATION GAINLOSS')


SELECT @CLOSINGKRW = ISNULL(@OKRW,0) ,@CLOSINGUSD = ISNULL(@OUSD,0)

----## GET CLOSING BALANCE BEFORE TRADING / FOREIGN GAINLOSS
SELECT @CLOSINGKRW = @CLOSINGKRW + ISNULL(SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end),0)
	  ,@CLOSINGUSD = @CLOSINGUSD + ISNULL(SUM(case when part_tran_type='dr' then ISNULL(usd_amt,0)*-1 else ISNULL(usd_amt,0) end),0)
FROM #TempTran(NOLOCK)

--select @OKRW,@OUSD
----## FOR GETTING OPENING BALANCE AND $ RATE
SELECT @OKRW = ISNULL(@OKRW,0) - ISNULL(SUM(tran_amt),0),@OUSD = ISNULL(@OUSD,0) - ISNULL(SUM(ISNULL(usd_amt,0)),0)
FROM #TempTran(NOLOCK) WHERE part_tran_type = 'DR' 


--select @OKRW,@OUSD,* FROM #TempTran(NOLOCK) WHERE part_tran_type = 'DR' 

--## GET OPENING EXCHANGE RATE WHERE ALL DR ENTRY ALSO INCLUDED
IF ISNULL(@OKRW,0) = 0
	SET @OpeningRate = @CLOSINGRATE
ELSE
	SET @OpeningRate = @OKRW / @OUSD

----SELECT @OKRW KRW, @OUSD OUSD,@OpeningRate RATE
--select *,@OpeningRate OpeningRate,(ISNULL(usd_amt,0)*(USD_RATE-ISNULL(SendMargin,0))) -(ISNULL(usd_amt,0)* @OpeningRate) FROM #TempTran(NOLOCK) WHERE part_tran_type = 'CR' 

----## CALCULATING FOREIGN AND TRADING GAINLOSS
SELECT	@TXNKRW			= SUM(tran_amt)
		,@TXNUSD		= SUM(ISNULL(usd_amt,0))
		,@ForeignExGain = SUM(ISNULL(SendMargin,0)*usd_amt)
		--,@TradingGain	= SUM((ISNULL(usd_amt,0)*(USD_RATE-ISNULL(SendMargin,0))) -(ISNULL(usd_amt,0)* @OpeningRate))
FROM #TempTran(NOLOCK) WHERE part_tran_type = 'CR'  

--IF ISNULL(@TXNKRW,0) = 0
--BEGIN
--	SELECT 'TRANSACTION NOT FOUND'
--	RETURN
--END
--SELECT @CLOSINGKRW TXNKRW,@CLOSINGUSD TXNUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@OpeningRate OpeningRate


----## ADDING FOREIGN GAINLOSS IN CLOSING KRW
SET @CLOSINGKRW = @CLOSINGKRW - ISNULL(@ForeignExGain,0)
--SELECT @CLOSINGKRW TXNKRW,@CLOSINGUSD TXNUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@OpeningRate OpeningRate

----SET @CLOSINGKRW = @CLOSINGKRW - ISNULL(@TradingGain,0)
SET @TradingGain =  @CLOSINGKRW - (@CLOSINGUSD*@OpeningRate)
SET @CLOSINGKRW = @CLOSINGKRW - ISNULL(@TradingGain,0)

--SELECT @CLOSINGKRW CLOSINGKRW,@CLOSINGUSD CLOSINGUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@CLOSINGRATE CLOSINGRATE

----## GETTING REVALUTATION GAINLOSS
SET @RevalGain = @CLOSINGUSD * @CLOSINGRATE
--SELECT @RevalGain,@CLOSINGUSD,@CLOSINGRATE
SET @RevalGain = @CLOSINGKRW - ISNULL(@RevalGain,0)

--SELECT @CLOSINGKRW TXNKRW,@CLOSINGUSD TXNUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@CLOSINGRATE CLOSINGRATE,@RevalGain RevalGain

--SELECT @CLOSINGKRW TXNKRW,@CLOSINGUSD TXNUSD, @ForeignExGain ForeignExGain,@TradingGain TradingGain,@RevalGain RevalGain
BEGIN TRANSACTION
DECLARE @vouchertable TABLE (AccNum VARCHAR(20),tranType VARCHAR(2),tranAmt MONEY,sessionId VARCHAR(30),VoucherType VARCHAR(20),Curr VARCHAR(5))
DECLARE @FOREIGNSESSION VARCHAR(30),@TRADINGSESSION VARCHAR(30),@REVALUATIONSESSION VARCHAR(30)
SELECT @FOREIGNSESSION = FORMAT(GETDATE(),'FOREIGNyyyyMMdd'),@TRADINGSESSION = FORMAT(GETDATE(),'TRADINGyyyyMMdd'),@REVALUATIONSESSION = FORMAT(GETDATE(),'REVALyyyyMMdd')

----## FOREIGN EXCHANGE GAINLOSS
IF @ForeignExGain <>0 
BEGIN
	INSERT INTO @vouchertable(AccNum,tranType,tranAmt,sessionId,VoucherType,Curr)
	SELECT @PartnerAccount,CASE WHEN @ForeignExGain > 0 THEN 'DR' ELSE 'CR' END,ABS(@ForeignExGain),@FOREIGNSESSION,'FOREIGN GAIN','USD' UNION ALL
	SELECT '900141084569',CASE WHEN @ForeignExGain > 0 THEN 'CR' ELSE 'DR' END,ABS(@ForeignExGain),@FOREIGNSESSION,'FOREIGN GAIN','KRW'
END
----## TRADING GAINLOSS
IF @TradingGain <>0
BEGIN
	INSERT INTO @vouchertable(AccNum,tranType,tranAmt,sessionId,VoucherType,Curr)
	SELECT @PartnerAccount,CASE WHEN @TradingGain > 0 THEN 'DR' ELSE 'CR' END,ABS(@TradingGain),@TRADINGSESSION,'TRADING GAINLOSS','USD' UNION ALL
	SELECT '900141055635',CASE WHEN @TradingGain > 0 THEN 'CR' ELSE 'DR' END,ABS(@TradingGain),@TRADINGSESSION,'TRADING GAINLOSS','KRW'
END
----## REVALUATION GAINLOSS
IF @RevalGain <>0
BEGIN
	INSERT INTO @vouchertable(AccNum,tranType,tranAmt,sessionId,VoucherType,Curr)
	SELECT @PartnerAccount,CASE WHEN @RevalGain > 0 THEN 'DR' ELSE 'CR' END,ABS(@RevalGain),@REVALUATIONSESSION,'REVALUATION GAINLOSS','USD' UNION ALL
	SELECT '900141091390',CASE WHEN @RevalGain > 0 THEN 'CR' ELSE 'DR' END,ABS(@RevalGain),@REVALUATIONSESSION,'REVALUATION GAINLOSS','KRW'
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


IF NOT EXISTS(SELECT 'A' FROM tran_master T(nolock) where field2 = 'FOREIGN GAIN' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SET @Narration = 'FOREIGN EXCHANGE GAIN DT : '+FORMAT(@Date,'yyyy-MM-dd')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @FOREIGNSESSION,@date = @Date,@narration = @Narration,@company_id=1,@v_type='j',@user='system'
END

IF NOT EXISTS(SELECT 'A' FROM tran_master T(nolock) where field2 = 'TRADING GAINLOSS' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SET @Narration = 'TRADING GAIN/LOSS DT : '+FORMAT(@Date,'yyyy-MM-dd')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @TRADINGSESSION,@date = @Date,@narration = @Narration,@company_id=1,@v_type='j',@user='system'
END

IF NOT EXISTS(SELECT 'A' FROM tran_master T(nolock) where field2 = 'REVALUATION GAINLOSS' and tran_date = @Date and acc_num = @PartnerAccount)
BEGIN
	SET @Narration = 'REVALUATION GAIN/LOSS DT : '+FORMAT(@Date,'yyyy-MM-dd')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @REVALUATIONSESSION,@date = @Date,@narration = @Narration,@company_id=1,@v_type='j',@user='system'
END

GO
