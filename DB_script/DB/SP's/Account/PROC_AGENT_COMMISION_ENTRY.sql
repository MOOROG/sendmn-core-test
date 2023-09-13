--EXEC PROC_AGENT_COMMISION_ENTRY @FLAG ='I',@USER ='admin',@REFERRAL_CODE ='JME0001',@RECEIVER_ACC_NUM ='100139258568',@AMOUNT ='15000',@TRAN_DATE ='2020-01-23',@NARRATION ='TEST'

--SELECT * FROM TEMP_TRAN WHERE ACCT_NUM = '100139258568'

use fastmoneyPro_account
GO
ALTER PROC PROC_AGENT_COMMISION_ENTRY
	@FLAG					VARCHAR(20)
	,@USER					VARCHAR(20)		= NULL
	,@REFERRAL_CODE			VARCHAR(20)		= NULL
	,@RECEIVER_ACC_NUM		BIGINT			= NULL
	,@AMOUNT				BIGINT			= NULL
	,@TRAN_DATE				VARCHAR(10)		= NULL
	,@NARRATION				VARCHAR(MAX)	= NULL
AS
BEGIN TRY
IF @FLAG = 'I'
BEGIN 
		DECLARE @agentAccNo BIGINT,@SESSION_ID VARCHAR(50) = NEWID()

		--voucher entry fro Agent Account
		SELECT @agentAccNo = ACCT_NUM FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AM (NOLOCK)
		INNER JOIN FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE RA (NOLOCK) ON RA.ROW_ID = AM.AGENT_ID
		WHERE RA.REFERRAL_CODE = @REFERRAL_CODE AND AM.ACCT_RPT_CODE = 'RA' 
		
		DECLARE @ROW_ID INT = @@IDENTITY
		
		--voucher entry for PETTY CASH
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,field1,field2)	
		SELECT @SESSION_ID,@user,@RECEIVER_ACC_NUM,'j','cr',@AMOUNT,@AMOUNT,1,@TRAN_DATE
			,'USDVOUCHER','JPY',@ROW_ID,'Agent Commission'

		--voucher entry for AGENT ACC NO
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,field1,field2)	
		SELECT @SESSION_ID,@user,@agentAccNo,'j','dr',@AMOUNT,@AMOUNT,1,@TRAN_DATE
			,'USDVOUCHER','JPY',@ROW_ID,'Agent Commission '

		--voucher entry for Marketting Incentive Payable
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,field1,field2)	
		SELECT @SESSION_ID,@user,'9539277135','j','dr',@AMOUNT,@AMOUNT,1,@TRAN_DATE
			,'USDVOUCHER','JPY',@ROW_ID,'Agent Commission '


		SET @NARRATION = LTRIM(RTRIM(@NARRATION))

		IF ISNULL(@NARRATION, '') = ''
		SET @NARRATION = 'Agent Commission Entry'
		ELSE 
			SET @NARRATION = 'Agent Commission Entry - ' + @NARRATION

		CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))

		INSERT INTO #TEMP_ERROR_CODE
		EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@TRAN_DATE,@narration=@NARRATION,@company_id=1,@v_type='j',@user=@user

		SELECT * FROM #TEMP_ERROR_CODE

END
ELSE IF @FLAG = 'BankBranchName'
BEGIN
	SELECT ACCT_NUM, ACCT_NAME
	FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AM(NOLOCK) 
	WHERE AM.ACCT_NUM = 100139258568 --Petty Cash 
END
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 1
BEGIN
	ROLLBACK TRANSACTION
	SELECT 1 ErrorCode,ERROR_MESSAGE() Msg
END
END CATCH