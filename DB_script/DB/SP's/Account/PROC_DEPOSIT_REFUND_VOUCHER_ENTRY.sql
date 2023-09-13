

--EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_DEPOSIT_REFUND_VOUCHER_ENTRY @flag = 'W', @user = 'admin', @rowId = 1
ALTER PROC PROC_DEPOSIT_REFUND_VOUCHER_ENTRY
(
	@flag VARCHAR(5)	= NULL
	,@user VARCHAR(40)	= NULL
	,@rowId INT = NULL
	,@isSettled BIT = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @customerId VARCHAR(15)				
			,@refundOrDepositAmount MONEY				
			,@refundCharge MONEY			
			,@refundRemarks VARCHAR(300)			
			,@redfundChargeRemarks VARCHAR(300)	
			,@collMode	VARCHAR(30)
			,@bankId	VARCHAR(50)	
			,@sessionId	VARCHAR(50)	= NEWID()
			,@TxnDate	DATETIME

	IF @flag = 'W'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM FASTMONEYPRO_REMIT.DBO.CUSTOMER_REFUND (NOLOCK) WHERE ROWID = @rowId AND APPROVEDDATE IS NOT NULL)
		BEGIN
			SELECT 1 errorCode, 'No record found/unapproved' msg, @rowid Id;
			RETURN;
		END

		SELECT @customerId = customerId
				,@refundOrDepositAmount = refundAmount
				,@refundCharge = ISNULL(refundCharge, 0)
				,@refundRemarks = refundRemarks
				,@redfundChargeRemarks = refundChargeRemarks
				,@bankId = BANKID
				,@collMode = COLLMODE
				,@TxnDate = approvedDate
		FROM FASTMONEYPRO_REMIT.DBO.CUSTOMER_REFUND (NOLOCK) 
		WHERE ROWID = @rowId
	END
	ELSE IF @flag = 'D'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM FASTMONEYPRO_REMIT.DBO.CUSTOMER_TRANSACTIONS (NOLOCK) WHERE ROWID = @rowId)
		BEGIN
			SELECT 1 errorCode, 'No record found' msg, @rowid Id;
			RETURN;
		END
		
		SELECT @customerId = customerId
				,@refundOrDepositAmount = deposit
				,@bankId = BANKID
				,@TxnDate = tranDate
		FROM FASTMONEYPRO_REMIT.DBO.CUSTOMER_TRANSACTIONS (NOLOCK) 
		WHERE ROWID = @rowId

		SELECT @collMode = 'Bank Deposit', @refundCharge = 0
	END
	BEGIN TRANSACTION

	DECLARE @cashOrBankAccNum VARCHAR(30), @refundChargeAcc VARCHAR(30) = '101000848', @customerAcc VARCHAR(30), @customerName VARCHAR(100)

	SELECT @customerAcc = walletaccountNo, @customerName = ISNULL(FULLNAME, FIRSTNAME) 
	FROM FASTMONEYPRO_REMIT.DBO.CUSTOMERMASTER (NOLOCK) 
	WHERE CUSTOMERID = @customerId

	--IF @collMode = 'Cash Collect'
	--BEGIN
	--	SET @cashOrBankAccNum = '100139231259'		--Customer Cash Account (JPY)
	--END
	--ELSE IF @collMode = 'Bank Deposit'
	--BEGIN
	--	IF @isSettled = 1
	--	BEGIN
	--		SELECT @cashOrBankAccNum = '139276572' --CUSTOMER CASH ACCOUNT
	--	END
	--	ELSE 
	--	BEGIN
	--		SELECT @cashOrBankAccNum = ACCT_NUM 
	--		FROM AC_MASTER (NOLOCK)
	--		WHERE AGENT_ID = @bankId
	--		AND ACCT_RPT_CODE = 'TB'
	--	END
	--END
	--SET @cashOrBankAccNum = @bankId

	----voucher entry for customer
	--INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	--	,rpt_code,trn_currency,field1,field2)	
	--SELECT @sessionId,'system',@customerAcc,'j',CASE WHEN @flag = 'W' THEN 'dr' ELSE 'cr' END,(@refundOrDepositAmount-@refundCharge),(@refundOrDepositAmount-@refundCharge),1,@TxnDate
	--	,'USDVOUCHER','JPY',@customerId,CASE WHEN @flag = 'W' THEN 'Refund Voucher' ELSE 'Deposit Voucher' END

	----voucher entry for Bank acc or Cash Acc
	--INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	--	,rpt_code,trn_currency,field1,field2)	
	--SELECT @sessionId,'system',@cashOrBankAccNum,'j',CASE WHEN @flag = 'D' THEN 'dr' ELSE 'cr' END,@refundOrDepositAmount,@refundOrDepositAmount,1,@TxnDate
	--	,'USDVOUCHER','JPY',@customerId,CASE WHEN @flag = 'W' THEN 'Refund Voucher' ELSE 'Deposit Voucher' END

	SET @cashOrBankAccNum = @bankId

	--voucher entry for customer
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,field1,field2)	
	SELECT @sessionId,'system',@customerAcc,'j','dr',(@refundOrDepositAmount+@refundCharge),(@refundOrDepositAmount+@refundCharge),1,@TxnDate
		,'USDVOUCHER','JPY',@rowId,'Refund Voucher'

	--voucher entry for Bank acc or Cash Acc
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,field1,field2)	
	SELECT @sessionId,'system',@cashOrBankAccNum,'j','cr',@refundOrDepositAmount+@refundCharge,@refundOrDepositAmount+@refundCharge,1,@TxnDate
		,'USDVOUCHER','JPY',@rowId,'Refund Voucher'


	--voucher entry for refund charge (if exists)
	--IF ISNULL(@refundCharge, 0) > 0
	--BEGIN
	--	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
	--		,rpt_code,trn_currency,field1,field2)	
	--	SELECT @sessionId,'system',@refundChargeAcc,'j','dr',@refundCharge,@refundCharge,1,@TxnDate
	--		,'USDVOUCHER','JPY',@customerId,'Refund Voucher'
	--END


	COMMIT TRANSACTION
	DECLARE @cashOrBank VARCHAR(100), @narration VARCHAR(500) 
	

	IF @flag = 'W'
	BEGIN
		SET @cashOrBank = CASE WHEN @collMode = 'Cash Collect' THEN 'From Cash Account: '+@cashOrBankAccNum 
											ELSE 'From Bank Account: '+@cashOrBankAccNum
										END
		SET @narration = 'Refund ' + @customerName
	END
	ELSE IF @flag = 'D'
	BEGIN
		SET @narration = 'Deposit : ' + @customerName + ' ' + @customerAcc + ' ' +cast(@TxnDate as VARCHAR)
	END

	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@sessionID,@date=@TxnDate,@narration=@narration,@company_id=1,@v_type='j',@user='system'
END


