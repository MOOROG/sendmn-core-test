USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_mobile_withdrawFromWallet]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_mobile_withdrawFromWallet]
(
@FLAG				VARCHAR(30)
,@USER				VARCHAR(150)	= NULL
,@AMOUNT			MONEY			= NULL
,@TXN_ID			BIGINT			= NULL
,@CURRENCY			VARCHAR(10)		= NULL
,@controlNo			VARCHAR(30)		= NULL
,@RequestFrom		VARCHAR(30)		= NULL
,@tranId			VARCHAR(20)		= NULL
,@password			VARCHAR(50)		= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN
	DECLARE @CUSTOMER_ID		BIGINT = NULL, 
			@BANK_NAME			VARCHAR(100), 
			@ACC_NUM			VARCHAR(50), 
			@BANK_ID			INT, 
			@AVAILABLE_BALANCE	MONEY, 
			@BANK_CODE			VARCHAR(30),
			@FIRST_NAME			VARCHAR(100), 
			@LAST_NAME			VARCHAR(100), 
			@CUSTOMER_WALLET	VARCHAR(30), 
			@FULL_NAME			VARCHAR(100)
	
IF @FLAG = 'request-core'
BEGIN
	SET @CUSTOMER_ID = 0

	SELECT  @controlNo = RT.controlNo,
			@BANK_ID = KB.rowId,
			@BANK_NAME = KB.BankName,
			@BANK_CODE = KB.bankCode,
			@ACC_NUM = RT.accountNo,
			@FULL_NAME = RT.receiverName,
			@AMOUNT =ISNULL(RT.pAmt,30),
			@CURRENCY = ISNULL(RT.payoutCurr,'MNT')
	FROM REMITTRAN RT(NOLOCK)
	LEFT JOIN KoreanBankList KB(NOLOCK) ON RT.PBANK = KB.AGENTID
	LEFT JOIN TBL_WALLET_WITHDRAW TW(NOLOCK) ON RT.Id = TW.tranId  --dhan : To avoid  duplicate transaction deposit
	WHERE RT.id = @tranId AND TW.TranId IS NULL

		
	IF @BANK_ID IS NULL
	BEGIN
		SELECT 1 Code, 'Invalid or unmaped bank!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@ACC_NUM, '') = ''
	BEGIN
		SELECT 1 Code, 'Invalid or empty account number!' Msg, NULL Id
		RETURN
	END

	IF @AMOUNT <= 0
	BEGIN
		SELECT 1 Code, 'Amount can not be 0 or negative!' Msg, NULL Id
		RETURN
	END

	INSERT INTO TBL_WALLET_WITHDRAW(USERID, CUSTOMER_ID, CUSTOMER_BANK_ID, CUSTOMER_ACCOUNT_NO, CUSTOMER_BANK_NAME, WITHDRAW_AMOUNT, CHARGE_AMOUNT,
								REQUESTED_DATE, CURRENCY, CONTROL_NO,tranId)
	SELECT @USER, @CUSTOMER_ID, @BANK_ID, @ACC_NUM, @BANK_NAME, @AMOUNT, 0, GETDATE(), ISNULL(@CURRENCY, 'MNT'), @controlNo,@tranId

	SET @TXN_ID = @@IDENTITY
		
	SELECT @FIRST_NAME = firstName,
				@LAST_NAME = lastName1
	--FROM dbo.FNASplitName('ARJUN SINGH DHAMI')
	FROM dbo.FNASplitName(@FULL_NAME)

	SELECT Code = 0, 
			Msg = 'Success', 
			txnId = @TXN_ID, 
			bankCode = @BANK_CODE,
			bankName = @BANK_NAME, 
			accountNo = @ACC_NUM, 
			amount = @AMOUNT, 
			pCurrency=@CURRENCY, 
			serviceCharge = 0, 
			firstName = @FIRST_NAME,
			lastName = @LAST_NAME,
			fullName = @FULL_NAME,
			noticeMessage = 'SendMN Bank Deposit (R) #'+ISNULL(DBO.DECRYPTDB(@controlNo), '')
END
ELSE IF @FLAG = 'DETAILS'
BEGIN
	DECLARE @CUSTOMER_PASSWORD VARCHAR(50)
	IF NOT EXISTS (SELECT * FROM TBL_WALLET_WITHDRAW (NOLOCK) WHERE ROW_ID = @TXN_ID AND RESPONSE_CODE IS NULL)
	BEGIN
		SELECT 1 Code, 'Request already confirmed!' Msg, NULL Id
		RETURN
	END

	SELECT @CUSTOMER_ID = CUSTOMER_ID
	FROM TBL_WALLET_WITHDRAW (NOLOCK) 
	WHERE ROW_ID = @TXN_ID

	SELECT @AVAILABLE_BALANCE = DBO.FNAGetCustomerAvailableBalance(CM.CUSTOMERID),
			@CUSTOMER_WALLET = walletAccountNo,
			@FULL_NAME = FULLNAME,
			@CUSTOMER_PASSWORD = customerPassword
	FROM customerMaster CM(NOLOCK)
	WHERE customerId = @CUSTOMER_ID

	IF @CUSTOMER_ID IS NULL
	BEGIN
		SELECT 1 Code, 'Invalid customer!' Msg, NULL Id
		RETURN
	END

	IF @CUSTOMER_PASSWORD <> DBO.FNAEncryptString(@password)
	BEGIN
		SELECT 1 Code, 'Password does not match!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@AVAILABLE_BALANCE, 0) < ISNULL(@AMOUNT, -1)
	BEGIN
		SELECT 1 Code, 'Insufficient balance for withdraw!' Msg, NULL Id
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM TBL_WALLET_WITHDRAW (NOLOCK) WHERE ROW_ID = @TXN_ID AND CUSTOMER_ID = @CUSTOMER_ID)
	BEGIN
		SELECT 1 Code, 'Invalid request!' Msg, NULL Id
		RETURN
	END

	SELECT @CUSTOMER_ID = CM.CUSTOMERID,
			@BANK_ID = CM.bankName,
			@FIRST_NAME = CM.firstName,
			@LAST_NAME = CM.lastName1,
			@BANK_NAME = KB.BankName,
			@BANK_CODE = KB.bankCode,
			@ACC_NUM = CM.bankAccountNo,
			@AVAILABLE_BALANCE = DBO.FNAGetCustomerAvailableBalance(CM.CUSTOMERID),
			@CUSTOMER_WALLET = CM.walletAccountNo
	FROM customerMaster CM(NOLOCK)
	INNER JOIN KoreanBankList KB(NOLOCK) ON KB.rowId = CM.bankName
	WHERE CM.CUSTOMERID = @CUSTOMER_ID

	IF @CUSTOMER_ID IS NULL
	BEGIN
		SELECT 1 Code, 'Invalid customer!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@ACC_NUM, 0) = ''
	BEGIN
		SELECT 1 Code, 'Invalid or empty customer bank acount number!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@BANK_ID, 0) = 0
	BEGIN
		SELECT 1 Code, 'Invalid or empty customer bank!' Msg, NULL Id
		RETURN
	END

	IF @AMOUNT <= 0
	BEGIN
		SELECT 1 Code, 'Amount can not be 0 or negative!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@AVAILABLE_BALANCE, 0) < @AMOUNT
	BEGIN
		SELECT 1 Code, 'Insufficient balance for withdraw!' Msg, NULL Id
		RETURN
	END

	SELECT Code = 0, 
			Msg = 'Success', 
			txnId = @TXN_ID, 
			bankName = @BANK_NAME, 
			accountNo = @ACC_NUM, 
			amount = @AMOUNT, 
			bankCode = @BANK_CODE, 
			serviceCharge = 0, 
			pCurrency=ISNULL(@CURRENCY, 'MNT'), 
			firstName = @FIRST_NAME,
			lastName = @LAST_NAME,
			noticeMessage = 'SendMN Bank Deposit (W) #'+ISNULL(@CUSTOMER_WALLET, '')
END
ELSE IF @FLAG = 'request'
BEGIN
	SELECT @CUSTOMER_ID = CM.customerId,
			@BANK_ID = CM.bankName,
			@FIRST_NAME = CM.firstName,
			@LAST_NAME = CM.lastName1,
			@BANK_NAME = KB.BankName,
			@BANK_CODE = KB.bankCode,
			@ACC_NUM = CM.bankAccountNo,
			@AVAILABLE_BALANCE = DBO.FNAGetCustomerAvailableBalance(CM.CUSTOMERID),
			@CUSTOMER_WALLET = CM.walletAccountNo
	FROM customerMaster CM(NOLOCK)
	INNER JOIN KoreanBankList KB(NOLOCK) ON KB.rowId = CM.bankName
	WHERE username = @USER

	IF @CUSTOMER_ID IS NULL
	BEGIN
		SELECT 1 Code, 'Invalid customer!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@ACC_NUM, 0) = ''
	BEGIN
		SELECT 1 Code, 'Invalid or empty customer bank acount number!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@BANK_ID, 0) = 0
	BEGIN
		SELECT 1 Code, 'Invalid or empty customer bank!' Msg, NULL Id
		RETURN
	END

	IF @AMOUNT <= 0
	BEGIN
		SELECT 1 Code, 'Amount can not be 0 or negative!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@AVAILABLE_BALANCE, 0) < @AMOUNT
	BEGIN
		SELECT 1 Code, 'Insufficient balance for withdraw!' Msg, NULL Id
		RETURN
	END

	--IF @AMOUNT < 1000
	--BEGIN
	--	SELECT 1 Code, 'You can not transfer below 1000!' Msg, NULL Id
	--	RETURN
	--END

	--IF @AMOUNT > 100000
	--BEGIN
	--	SELECT 1 Code, 'You can not transfer more than 100000!' Msg, NULL Id
	--	RETURN
	--END

	INSERT INTO TBL_WALLET_WITHDRAW(USERID, CUSTOMER_ID, CUSTOMER_BANK_ID, CUSTOMER_ACCOUNT_NO, CUSTOMER_BANK_NAME, WITHDRAW_AMOUNT, CHARGE_AMOUNT,
								REQUESTED_DATE, CURRENCY)
	SELECT @USER, @CUSTOMER_ID, @BANK_ID, @ACC_NUM, @BANK_NAME, @AMOUNT, 0, GETDATE(), ISNULL(@CURRENCY, 'MNT')

	SET @TXN_ID = @@IDENTITY

	SELECT Code = 0, 
			Msg = 'Success', 
			txnId = @TXN_ID, 
			bankName = @BANK_NAME, 
			accountNo = @ACC_NUM, 
			amount = @AMOUNT, 
			bankCode = @BANK_CODE, 
			serviceCharge = 0, 
			pCurrency=ISNULL(@CURRENCY, 'MNT'), 
			firstName = @FIRST_NAME,
			lastName = @LAST_NAME,
			noticeMessage = 'SendMN Bank Deposit (W) #'+ISNULL(@CUSTOMER_WALLET, '')
END
ELSE IF @FLAG = 'CONFIRM' AND @RequestFrom = 'core'
BEGIN
	IF NOT EXISTS (SELECT * FROM TBL_WALLET_WITHDRAW (NOLOCK) WHERE ROW_ID = @TXN_ID AND RESPONSE_CODE IS NULL)
	BEGIN
		SELECT 1 Code, 'Request already confirmed!' Msg, NULL Id
		RETURN
	END
	
	IF NOT EXISTS(SELECT * FROM TBL_WALLET_WITHDRAW (NOLOCK) WHERE ROW_ID = @TXN_ID AND tranId = @tranId AND WITHDRAW_AMOUNT = @AMOUNT)
	BEGIN
		SELECT 1 Code, 'Invalid request!' Msg, NULL Id
		RETURN
	END


	UPDATE TBL_WALLET_WITHDRAW 
	SET RESPONSE_CODE = 0, 
		RESPONSE_MSG = 'Success', 
		CONFIRMED_DATE = GETDATE() 
	WHERE ROW_ID = @TXN_ID AND  tranId = @tranId

	SELECT 0 Code, 'Success!' Msg, NULL Id


	--remit start 
		EXEC proc_PayAcDepositV3 @flag = 'payIntl',@user ='system', @tranIds = @tranId,@requestFrom ='api'
	--remit end 
RETURN
END
ELSE IF @FLAG = 'CONFIRM'
BEGIN
	IF NOT EXISTS (SELECT * FROM TBL_WALLET_WITHDRAW (NOLOCK) WHERE ROW_ID = @TXN_ID AND RESPONSE_CODE IS NULL)
	BEGIN
		SELECT 1 Code, 'Request already confirmed!' Msg, NULL Id
		RETURN
	END

	SELECT @CUSTOMER_ID = CUSTOMERID,
			@AVAILABLE_BALANCE = DBO.FNAGetCustomerAvailableBalance(CM.CUSTOMERID),
			@CUSTOMER_WALLET = walletAccountNo,
			@FULL_NAME = FULLNAME
	FROM customerMaster CM(NOLOCK)
	WHERE username = @USER

	IF @CUSTOMER_ID IS NULL
	BEGIN
		SELECT 1 Code, 'Invalid customer!' Msg, NULL Id
		RETURN
	END

	IF ISNULL(@AVAILABLE_BALANCE, 0) < ISNULL(@AMOUNT, -1)
	BEGIN
		SELECT 1 Code, 'Insufficient balance for withdraw!' Msg, NULL Id
		RETURN
	END

	IF NOT EXISTS(SELECT * FROM TBL_WALLET_WITHDRAW (NOLOCK) WHERE ROW_ID = @TXN_ID AND CUSTOMER_ID = @CUSTOMER_ID)
	BEGIN
		SELECT 1 Code, 'Invalid request!' Msg, NULL Id
		RETURN
	END

	UPDATE CUSTOMERMASTER SET AVAILABLEBALANCE = ISNULL(AVAILABLEBALANCE, 0) - @AMOUNT
	WHERE CUSTOMERID = @CUSTOMER_ID

	UPDATE TBL_WALLET_WITHDRAW SET RESPONSE_CODE = 0, RESPONSE_MSG = 'Success', CONFIRMED_DATE = GETDATE() WHERE ROW_ID = @TXN_ID


	SELECT 0 Code, 'Success!' Msg, NULL Id

	DECLARE @KHAN_BANK_ACC VARCHAR(30), @sessionID VARCHAR(50)
			,@TxnDate VARCHAR(25), @narration VARCHAR(100)

	SELECT @KHAN_BANK_ACC = AC.acct_num FROM Vw_GetAgentID VA
	INNER JOIN SendMnPro_Account.DBO.ac_master AC(NOLOCK) ON AC.AGENT_ID  = VA.agentId
	WHERE SearchText = 'khankBank'
	AND AC.acct_rpt_code = 'VAC'

	--VOUCHER ENTRY
	SELECT @sessionID = RIGHT(NEWID(), 20), @TxnDate = GETDATE()
	--SendMN Khan Bank Acc :DR
	INSERT INTO SendMnPro_account.dbo.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
	SELECT @sessionID,'system',@KHAN_BANK_ACC,'s','CR',@AMOUNT,@AMOUNT,1,@TxnDate
		,'Withdraw Voucher',ISNULL(@CURRENCY, 'MNT'),NULL,@TXN_ID,'Bank Deposit', NULL, NULL

	--Customer wallet :CR
	INSERT INTO SendMnPro_account.dbo.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
	SELECT @sessionID,'system',@CUSTOMER_WALLET,'s','DR',@AMOUNT,@AMOUNT,1,@TxnDate
		,'Withdraw Voucher',ISNULL(@CURRENCY, 'MNT'),NULL,@TXN_ID,'Bank Deposit', NULL, NULL

	SET @narration = 'Bank Deposit - ' + ISNULL(@FULL_NAME, '')
	
	EXEC SendMnPro_account.dbo.[spa_saveTempTrnUSD] @flag='i',@sessionID=@sessionID,@date=@TxnDate,@narration=@narration
			,@company_id=1,@v_type='s',@user='system'

	RETURN
END
END
 
GO
