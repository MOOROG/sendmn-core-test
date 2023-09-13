--394122  JME Tokyo Main Branch
-- SELECT * FROM AGENTMASTER WHERE PARENTID=393877
--EXEC PROC_REFERRAL_AGENT_WISE @FLAG = 'I', @AGENT_ID = NULL, @REFERRAL_CODE = 'XYZ_MART', @REFERRAL_NAME = 'XYZ MART TOKYO', @REFERRAL_ADDRESS = 'TOKYO', 
--										@REFERRAL_MOBILE = '9849001291', @REFERRAL_EMAIL = 'SANJOG@GMAIL.COM', @REFERRAL_ID = 0
--										, @USER = 'admin', @IS_ACTIVE = 1
USE FASTMONEYPRO_REMIT
GO

ALTER PROC PROC_REFERRAL_AGENT_WISE
(
	@FLAG VARCHAR(20)
	,@USER VARCHAR(60)
	,@AGENT_ID INT = NULL
	,@REFERRAL_NAME VARCHAR(150) = NULL
	,@REFERRAL_ADDRESS VARCHAR(250) = NULL
	,@REFERRAL_MOBILE VARCHAR(50) = NULL
	,@REFERRAL_EMAIL VARCHAR(80)  = NULL
	,@REFERRAL_ID INT = NULL
	,@IS_ACTIVE BIT = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @FLAG = 'I'
	BEGIN
		DECLARE @REFERRAL_CODE	VARCHAR(50) = NULL
		
		IF @AGENT_ID IS NOT NULL AND NOT EXISTS(SELECT 1 FROM AGENTMASTER (NOLOCK) WHERE AGENTID = @AGENT_ID AND ISNULL(ISACTIVE, 'Y') = 'Y' AND ISNULL(ISDELETED, 'N') = 'N' AND ISNULL(ISINTL, 0) = 1)
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'Agent not found or inactive!', null
			RETURN
		END
		IF EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @REFERRAL_CODE)
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'Referral with same referral code already exists!', null
			RETURN
		END
		IF ISNULL(@REFERRAL_ID, 0) <> 0 AND NOT EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE ROW_ID = @REFERRAL_ID)
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'Referral mapping not possible, mapping referral not found!', null
			RETURN
		END


		INSERT INTO REFERRAL_AGENT_WISE(AGENT_ID, REFERRAL_CODE, REFERRAL_NAME, REFERRAL_ADDRESS, 
											REFERRAL_MOBILE, REFERRAL_EMAIL, REFERRAL_ID, CREATED_BY, CREATED_DATE, IS_ACTIVE)
		SELECT ISNULL(@AGENT_ID, 0), '0', @REFERRAL_NAME, @REFERRAL_ADDRESS, 
											@REFERRAL_MOBILE, @REFERRAL_EMAIL, @REFERRAL_ID, @USER, GETDATE(), @IS_ACTIVE
		
		DECLARE @ROW_ID INT = @@IDENTITY
		
		SET @REFERRAL_CODE = 'JME' + RIGHT('0000' + CAST(@ROW_ID AS VARCHAR), 4)

		UPDATE REFERRAL_AGENT_WISE SET REFERRAL_CODE = @REFERRAL_CODE WHERE ROW_ID = @ROW_ID

		IF ISNULL(@AGENT_ID, 0) <> 0
		BEGIN
			DECLARE @ACCT_NUM VARCHAR(20)

			SELECT @ACCT_NUM = MAX(cast(ACCT_NUM AS BIGINT)+1) FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE gl_code='0'
			SET @ACCT_NUM = ISNULL(@ACCT_NUM, 8080000001)

			----## AUTO CREATE LEDGER FOR REFERRAL
			INSERT INTO FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
			acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
			lien_amt, utilised_amt, available_amt,created_date,created_by,company_id, ac_currency)

			VALUES(@ACCT_NUM, @REFERRAL_CODE, '0', @ROW_ID, 'o', 0, 'RA', GETDATE(), 0, 0, 0, 0, 0, GETDATE(), @USER, 1, 'JPY')
		END
		
		EXEC PROC_ERRORHANDLER 0, 'Data saved successfully!', null
		RETURN
	END
END


