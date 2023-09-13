USE FASTMONEYPRO_ACCOUNT
GO

--EXEC PROC_AGENT_COMM_ENTRY @FLAG ='I',@USER ='admin',@REFERRAL_CODE ='JME0001',@RECEIVER_ACC_NUM ='100139258568',@AMOUNT ='10000',@TRAN_DATE ='2020-03-09',@NARRATION ='test'

ALTER PROC PROC_AGENT_COMM_ENTRY
(  
 @FLAG VARCHAR(20)  
 ,@USER VARCHAR(50)  
 ,@REFERRAL_CODE VARCHAR(50) = NULL  
 ,@RECEIVER_ACC_NUM VARCHAR(30) = NULL  
 ,@AMOUNT MONEY = NULL  
 ,@TRAN_DATE VARCHAR(30) = NULL  
 ,@NARRATION VARCHAR(250) = NULL  
)  
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
BEGIN  
	IF @FLAG = 'ACC-LIST'
	BEGIN
		SELECT ACCT_NUM, ACCT_NAME
		FROM AC_MASTER 
		WHERE ACCT_NUM IN ('100139258568')
	END
	ELSE IF @FLAG = 'I'  
	BEGIN  
		DECLARE @TRANSIT_CASH_ACC VARCHAR(30) = '9539277135', @REFERAL_AC VARCHAR(30)  
		, @REFERRAL_ID INT, @SESSION_ID VARCHAR(50) = NEWID(), @AGENT_ID INT, @AGENT_NAME VARCHAR(150)
		, @TAX_ACC VARCHAR(30) = '100739218987', @MARKETINGPROMOTION_ACC VARCHAR(30) = '910639248385', @TAX_AMT MONEY
		
  
		SELECT @REFERRAL_ID = ROW_ID, @AGENT_ID = AGENT_ID, @AGENT_NAME = REFERRAL_NAME
		FROM FastMoneyPro_Remit.DBO.REFERRAL_AGENT_WISE (NOLOCK)   
		WHERE REFERRAL_CODE = @REFERRAL_CODE  
  
		IF @REFERRAL_ID IS NULL  
		BEGIN  
			EXEC PROC_ERRORHANDLER 1, 'Invalid Referral Selected!', NULL  
			RETURN;  
		END
		
		IF @AGENT_ID = 0
		BEGIN
			SELECT @REFERAL_AC = ACCT_NUM  
			FROM AC_MASTER (NOLOCK)  
			WHERE AGENT_ID = @REFERRAL_ID  
			AND ACCT_RPT_CODE = 'RAC'  
		END
		ELSE
		BEGIN
			SELECT @REFERAL_AC = ACCT_NUM  
			FROM AC_MASTER (NOLOCK)  
			WHERE AGENT_ID = @AGENT_ID  
			AND ACCT_RPT_CODE = 'ACP'  
		END
		
		IF @REFERAL_AC IS NULL OR @RECEIVER_ACC_NUM IS NULL  
		BEGIN  
			EXEC PROC_ERRORHANDLER 1, 'No account found for either Referal or bank/branch!', NULL  
			RETURN;  
		END  
		CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))  
  
		IF @AGENT_ID = 0
		BEGIN
			--voucher entry for TRANSIT ACC  
			INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
			,rpt_code,trn_currency,field1,field2)   
			SELECT @SESSION_ID,@user,@TRANSIT_CASH_ACC,'j','dr',@AMOUNT,@AMOUNT,1,@TRAN_DATE  
			,'USDVOUCHER','JPY',NULL,'Agent Comm Paid'  

			SET @TAX_AMT = FLOOR(@AMOUNT / 11)

			--voucher entry for VAULT OR BANK ACC  
			INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
			,rpt_code,trn_currency,field1,field2)   
			SELECT @SESSION_ID,@user,@TAX_ACC,'j','dr',@TAX_AMT,@TAX_AMT,1,@TRAN_DATE  
			,'USDVOUCHER','JPY',NULL,'Agent Comm Paid'  
			
			--voucher entry for REFERRAL ACC (ONLY FOR BACKEND PURPOSE)  
			INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
			,rpt_code,trn_currency,field1,field2)   
			SELECT @SESSION_ID,@user,@MARKETINGPROMOTION_ACC,'j','cr',@TAX_AMT,@TAX_AMT,1,@TRAN_DATE  
			,'USDVOUCHER','JPY',NULL,'Agent Comm Paid'  
		END

		--voucher entry for VAULT OR BANK ACC  
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
		,rpt_code,trn_currency,field1,field2)   
		SELECT @SESSION_ID,@user,@RECEIVER_ACC_NUM,'j','cr',@AMOUNT,@AMOUNT,1,@TRAN_DATE  
		,'USDVOUCHER','JPY',NULL,'Agent Comm Paid'  
  
		--voucher entry for REFERRAL ACC (ONLY FOR BACKEND PURPOSE)  
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date  
		,rpt_code,trn_currency,field1,field2)   
		SELECT @SESSION_ID,@user,@REFERAL_AC,'j','dr',@AMOUNT,@AMOUNT,1,@TRAN_DATE  
		,'USDVOUCHER','JPY',NULL,'Agent Comm Paid'  
		
		SET @NARRATION = LTRIM(RTRIM(@NARRATION))  
  
		IF ISNULL(@NARRATION, '') = ''  
			SET @NARRATION = 'Comm Paid - ' + @AGENT_NAME  
		ELSE   
			SET @NARRATION = 'Comm Paid - ' + @AGENT_NAME + ' - ' + @NARRATION  
		
		EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@TRAN_DATE,@narration=@NARRATION,@company_id=1,@v_type='j',@user=@user  
	END  
	ELSE IF @FLAG = 'B'
	BEGIN
		SELECT @REFERAL_AC = ACCT_NUM
		FROM AC_MASTER A(NOLOCK)
		INNER JOIN FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE R(NOLOCK) ON R.ROW_ID = A.AGENT_ID AND A.ACCT_RPT_CODE = 'RAC'
		WHERE R.REFERRAL_CODE = @REFERRAL_CODE
		
		SELECT 0, BALANCE = ISNULL(SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0), null
		FROM TRAN_MASTER (NOLOCK)
		WHERE ACC_NUM = @REFERAL_AC
	END
END  
  --EXEC PROC_AGENT_COMM_ENTRY @FLAG ='B',@USER ='admin',@REFERRAL_CODE ='JME0003'

