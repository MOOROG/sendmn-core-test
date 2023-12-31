USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_SaveFundDealingVoucher]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_SaveFundDealingVoucher]
	@User		VARCHAR(50),
	@date		varchar(20),
	@srtNarration varchar(300),
	@SessionId	VARCHAR(50)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @company_id VARCHAR(10) = '1'

BEGIN TRY
begin
	IF NOT EXISTS(select 'A' from temp_tran (NOLOCK) WHERE sessionID = @SessionId)
	BEGIN
		EXEC Proc_errorHandler 1 ,'TRANSACTION NOT FOUND FOR VOUCHER GENERATION!',null
		RETURN
	END
	IF (ISDATE(@date)) = 0 OR CAST(@date AS DATE) > CAST(GETDATE() AS DATE)
	BEGIN
		EXEC Proc_errorHandler 1 ,'INVALID DATE',null
		RETURN
	END

	DECLARE @totalRows int
	DECLARE @Part_Id int
	DECLARE @ac_num  varchar(20)
	DECLARE @TotalAmt numeric(20,2)
	DECLARE @trntype varchar(2)
	DECLARE @totalDR numeric(20,2)
	DECLARE @totalCR numeric(20,2)
	DECLARE @ref_num varchar(20)
	DECLARE @USD_AMT numeric(20,2)
	DECLARE @strSAgent as varchar(20) 
	DECLARE @msg as varchar(max) ='' 

	-- AC Masters values
	-- Temp Voucher values
create table #tempsumTrn (Part_Id int identity(1,1),acct_num varchar(20), 
	TotalAmt numeric(20,2), part_tran_type varchar(2), USD_AMT numeric(20,2),exRate MONEY )

DECLARE @tempFundAmount TABLE(AGENTID VARCHAR(20),RATE MONEY,REMAINAMT MONEY,TRAN_ID INT)

INSERT INTO @tempFundAmount
SELECT S.R_BANK,RATE = ISNULL(S.WeightedRate,S.USD_RATE),REMAIN_AMT = (S.REMAIN_AMT_EXCHANGE),S.TRAN_ID
FROM FundTransactionSummary S(NOLOCK)
INNER JOIN(
	SELECT R_BANK,TRAN_ID = MAX(TRAN_ID) FROM FundTransactionSummary(NOLOCK)
	GROUP BY R_BANK
)X ON S.R_BANK = X.R_BANK AND S.TRAN_ID = X.TRAN_ID
--GROUP BY S.R_BANK,S.WeightedRate,S.USD_RATE

 IF NOT EXISTS(SELECT * from @tempFundAmount)
 BEGIN
	EXEC Proc_errorHandler 1 ,'SORRY,THERE IS NO REMAINING FUND FOR DEALING',null
	RETURN
 END

IF EXISTS(select 'A' from temp_tran T(NOLOCK)
	LEFT JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	WHERE W.AGENTID IS NULL AND T.sessionID = @SessionId)
BEGIN
	SELECT @msg = @msg+T.acct_num+',' FROM temp_tran T(NOLOCK)
	LEFT JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	WHERE W.AGENTID IS NULL AND T.sessionID = @SessionId

	SET @msg = 'INVALID BANK AC ENTERED FOR DEALING :'+ISNULL(@msg,'')
	EXEC Proc_errorHandler 1 ,@msg,null
	RETURN
END

IF EXISTS(select 'A' from temp_tran T(NOLOCK)
	INNER JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	WHERE T.sessionID = @SessionId AND T.tran_amt > W.REMAINAMT)
BEGIN
	SELECT @msg = @msg+w.AGENTID+',' FROM temp_tran T(NOLOCK)
	INNER JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	WHERE T.sessionID = @SessionId AND T.tran_amt > W.REMAINAMT

	SET @msg = 'INSUFFICIENT FUND FOUND FOR BANK :'+ISNULL(@msg,'')
	EXEC Proc_errorHandler 1 ,@msg,null
	RETURN
END

IF EXISTS(select 'A' from temp_tran T(NOLOCK)
	INNER JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	WHERE T.sessionID = @SessionId AND T.tran_amt > W.REMAINAMT)
BEGIN
	SELECT @msg = @msg+w.AGENTID+',' FROM temp_tran T(NOLOCK)
	INNER JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	WHERE T.sessionID = @SessionId AND T.tran_amt > W.REMAINAMT

	SET @msg = 'INSUFFICIENT FUND FOUND FOR BANK :'+ISNULL(@msg,'')
	EXEC Proc_errorHandler 1 ,@msg,null
	RETURN
END

IF EXISTS(select 'A' from temp_tran T(NOLOCK)
	LEFT JOIN ac_master W ON T.acct_num = w.acct_rpt_code
	WHERE T.sessionID = @SessionId AND W.acct_num IS NULL)
BEGIN
	SELECT @msg = @msg+T.acct_num+',' FROM temp_tran T(NOLOCK)
	LEFT JOIN ac_master W ON T.acct_num = w.acct_rpt_code
	WHERE T.sessionID = @SessionId AND W.acct_num IS NULL

	SET @msg = 'USD AC FOUND FOR BANK :'+ISNULL(@msg,'')
	EXEC Proc_errorHandler 1 ,@msg,null
	RETURN
END
-- ## GET Sending agent Id
DECLARE @foreignGain_AC varchar(30) = '141001604'
	
	INSERT INTO #tempsumTrn(acct_num,TotalAmt,part_tran_type,USD_AMT,exRate)
	SELECT acct_num,lc_amt_cr,'dr',tran_amt,usd_rate 
	FROM temp_tran(NOLOCK) WHERE sessionID = @SessionId

	--## BANK AC VS $ AC OF SAME BANK
	INSERT INTO #tempsumTrn(acct_num,part_tran_type,USD_AMT,exRate,TotalAmt)
	SELECT A.acct_num,'cr',T.tran_amt,W.RATE,T.tran_amt*W.RATE
	FROM temp_tran T(NOLOCK)
	INNER JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	INNER JOIN ac_master A (NOLOCK) ON T.acct_num = A.acct_rpt_code
	WHERE T.sessionID = @SessionId
	UNION ALL
	-- GAIN LOSS
	select acct_num = @foreignGain_AC,'cr',T.tran_amt,(T.usd_rate - W.RATE),T.tran_amt*(T.usd_rate - W.RATE)
	from temp_tran T(NOLOCK)
	INNER JOIN @tempFundAmount W ON T.acct_num = w.AGENTID
	WHERE T.sessionID = @SessionId

	DELETE FROM #tempsumTrn WHERE exRate = 0

	UPDATE #tempsumTrn SET 
		part_tran_type = CASE WHEN exRate < 0 THEN 'dr' else 'cr' end
		,exRate = ABS(exRate)
		,TotalAmt = ABS(TotalAmt)
	WHERE acct_num = @foreignGain_AC

	SELECT @ref_num = journal_voucher from billSetting(NOLOCK) where company_id = @company_id
	
	SELECT @Part_Id = max(Part_Id) from #tempsumTrn

	SELECT @totalDR = sum(TotalAmt) from #tempsumTrn where part_tran_type = 'dr' 
	SELECT @totalCR = sum(TotalAmt) from #tempsumTrn where part_tran_type = 'cr'

--SELECT * FROM #tempsumTrn 
--RETURN

	-- conditions 1 for Total DR CR equal 
IF ISNULL(@totalDR,0) <> ISNULL(@totalCR,1)
BEGIN	
	EXEC Proc_errorHandler 1 ,'DR and CR amount not Equal',null
	RETURN
END

SET @strSAgent = NULL
BEGIN TRANSACTION		

--Start loop count
set @totalRows = 1
while @Part_Id >=  @totalRows
begin
			-- row wise trn values
		select @ac_num = acct_num,@TotalAmt = round(TotalAmt,2),@trntype = part_tran_type,@USD_AMT = USD_AMT
		from #tempsumTrn where Part_Id = @totalRows
			
		Exec ProcDrCrUpdateFinal @trntype ,@ac_num,@USD_AMT,@TotalAmt

set @totalRows = @totalRows+1
end

	-- ######### Insert into Transaction Table
		INSERT INTO tran_master (
			entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,rpt_code,tran_amt,tran_date,
			tran_type,company_id,part_tran_srl_num,
			created_date, usd_amt,usd_rate,RunningBalance)
		SELECT @User,c.acct_num,a.gl_code,lower(part_tran_type),@ref_num,A.acct_rpt_code,c.TotalAmt,@date
			,'j',@company_id,ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo
			,GETDATE(),c.USD_AMT,c.exRate, dbo.[FNAGetRunningBalance](c.acct_num,c.TotalAmt,part_tran_type)
		FROM #tempsumTrn c
		INNER JOIN ac_master a (NOLOCK) ON c.acct_num = a.acct_num 


		INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
		SELECT TOP 1 @ref_num,@srtNarration,@company_id,@date,'j'
		
		UPDATE S SET 
			S.REMAIN_AMT_EXCHANGE = REMAIN_AMT_EXCHANGE - T.tran_amt
			,s.CUMM_NPR = s.CUMM_NPR - (F.RATE*T.tran_amt)
		FROM FundTransactionSummary S 
		INNER JOIN @tempFundAmount F ON S.TRAN_ID = F.TRAN_ID
		INNER JOIN temp_tran T(NOLOCK) ON F.AGENTID = T.acct_num
		WHERE T.sessionID = @SessionId AND T.part_tran_type = 'DR'
	
	INSERT INTO ExchangeTransactionSummary(R_BANK,USD_AMT,FUND_RATE,EX_RATE,EX_BANK,TRAN_DATE,REMAIN_AMT,REF_NUM,FUND_ID)
	SELECT T.acct_num,T.tran_amt,F.RATE,T.usd_rate,A.acct_num,@date,T.tran_amt,@ref_num,F.TRAN_ID 
	FROM @tempFundAmount F 
	INNER JOIN temp_tran T(NOLOCK) ON F.AGENTID = T.acct_num
	INNER JOIN ac_master A(NOLOCK) ON T.acct_num = A.acct_rpt_code 
	WHERE T.sessionID = @SessionId AND T.part_tran_type = 'DR'
	
-- ######### update voucher number
	UPDATE billSetting set journal_voucher = cast(journal_voucher as float)+1 

COMMIT TRANSACTION

-- ######### Delete temp TRansaction
	DROP TABLE #tempsumTrn
	TRUNCATE TABLE temp_tran
--####### Final message select 'Saved, Process Complete: '+ @ref_num as Success
	
	SELECT @srtNarration = 'Save Success voucher No: 
		<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+ cast(@date as varchar) +'&type=trannumber&tran_num='+ cast(@ref_num as varchar) +'&vouchertype=j'' > '+ cast(@ref_num as varchar) +' </a>' 
	
	EXEC proc_errorHandler 0 ,@srtNarration,@ref_num

END

END TRY

BEGIN CATCH

IF @@TRANCOUNT <> 0 
ROLLBACK TRANSACTION

SET @srtNarration = ERROR_MESSAGE()
EXEC proc_errorHandler 1 ,@srtNarration,NULL

END CATCH
GO
