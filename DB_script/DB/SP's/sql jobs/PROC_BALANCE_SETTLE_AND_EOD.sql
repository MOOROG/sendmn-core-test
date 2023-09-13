
--EXEC PROC_BALANCE_SETTLE_AND_EOD @FLAG = 'EOD'

ALTER PROC PROC_BALANCE_SETTLE_AND_EOD
(
	@FLAG VARCHAR(20)
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @DATE VARCHAR(10), @AMOUNT MONEY
	SELECT @DATE = CAST(GETDATE() AS DATE)

	IF @FLAG = 'EOD'
	BEGIN
		SELECT SUM(INAMOUNT)-SUM(OUTAMOUNT) BALANCE, USERID INTO #CHECKING FROM BRANCH_CASH_IN_OUT WHERE 1=1
		AND BRANCHID NOT IN (394394, 394393)
		AND USERID <> 0
		GROUP BY USERID

		INSERT INTO #CHECKING
		SELECT SUM(INAMOUNT)-SUM(OUTAMOUNT) BALANCE, 0 USERID FROM BRANCH_CASH_IN_OUT WHERE 1=1
		and branchid = 394396

		IF EXISTS(SELECT BALANCE FROM #CHECKING WHERE BALANCE <> 0)
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'TRANSFER TO VAULT PENDING FROM TELLERS!', NULL
			RETURN
		END
		--IF EXISTS (SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT(NOLOCK) WHERE APPROVEDDATE IS NULL)
		--BEGIN
		--	EXEC PROC_ERRORHANDLER 1, 'Please approve all pending vault transfer''s before performing this operation!', null
		--	RETURN
		--END
		--IF EXISTS (SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT(NOLOCK) WHERE createdDate < @DATE)
		--BEGIN
		--	EXEC PROC_ERRORHANDLER 1, 'EOD pending for previous date!', null
		--	RETURN
		--END
		--IF EXISTS (SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT_HISTORY(NOLOCK) WHERE createdDate BETWEEN @DATE AND @DATE + ' 23:59:59')
		--BEGIN
		--	EXEC PROC_ERRORHANDLER 1, 'EOD already performed!', null
		--	RETURN
		--END
		
		SELECT rowId, inAmount, outAmount, branchId, userId, referenceId, tranDate, head, 
						remarks, createdBy, createdDate, approvedBy, approvedDate, mode, fromAcc, toAcc
		INTO #TEMP
		FROM BRANCH_CASH_IN_OUT (NOLOCK)
		--WHERE createdDate BETWEEN '2020-05-08' AND '2020-05-21 23:59:59'

		INSERT INTO BRANCH_CASH_IN_OUT_HISTORY (inAmount, outAmount, branchId, userId, referenceId, tranDate, head, 
						remarks, createdBy, createdDate, approvedBy, approvedDate, mode, fromAcc, toAcc, MAIN_TABLE_ROW_ID)
		SELECT inAmount, outAmount, branchId, userId, referenceId, tranDate, head, 
						remarks, createdBy, createdDate, approvedBy, approvedDate, mode, fromAcc, toAcc, rowId
		FROM #TEMP (NOLOCK)
		
		DELETE B
		FROM #TEMP T
		INNER JOIN BRANCH_CASH_IN_OUT B(NOLOCK) ON B.ROWID = T.ROWID

		EXEC PROC_ERRORHANDLER 0, 'EOD done successfully!', null
	END
	ELSE IF @FLAG = 'CUSTOMER-BALANCE'
	BEGIN
		SELECT TRANID, TRANDATE, DEPOSITAMOUNT, PAYMENTAMOUNT, CLOSINGBALANCE, BANKNAME
		INTO #TEMP_SETTLE
		FROM CUSTOMER_DEPOSIT_LOGS
		WHERE 1 = 1
		AND TRANDATE BETWEEN @DATE AND @DATE + ' 23:59:59'
		AND isSettled = 0
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM #TEMP_SETTLE)
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'No data to save!', null
			RETURN
		END
		IF EXISTS (SELECT 1 FROM #TEMP_SETTLE WHERE PAYMENTAMOUNT <> 0)
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'Amounts other then customer deposits are not skipped, please skip all first!', null
			RETURN
		END
		
		DECLARE @CUSTOMER_CASH_COLL_ACC VARCHAR(30) = '139276572', @BANK_ACC VARCHAR(30), @BANK_ID INT, @SESSION_ID VARCHAR(100) = NEWID()
		WHILE EXISTS(SELECT TOP 1 1 FROM #TEMP_SETTLE)
		BEGIN
			SELECT @BANK_ID = BANKNAME 
			FROM #TEMP_SETTLE

			SELECT @AMOUNT = SUM(ISNULL(DEPOSITAMOUNT, 0))
			FROM #TEMP_SETTLE 
			WHERE BANKNAME = @BANK_ID

			SELECT @BANK_ACC = ACCT_NUM 
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER 
			WHERE AGENT_ID = @BANK_ID
			AND ACCT_RPT_CODE = 'TB'

			--voucher entry for JME service charge income
			INSERT INTO FASTMONEYPRO_ACCOUNT.DBO.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
				,rpt_code,trn_currency,emp_name,field1,field2)
			SELECT @SESSION_ID,'system',@CUSTOMER_CASH_COLL_ACC,'j','cr',@AMOUNT,1,@AMOUNT,@DATE
				,'USDVOUCHER','JPY','system',@BANK_ID,'Customer Deposit EOD'

			--voucher entry for forex gain/loss
			INSERT INTO FASTMONEYPRO_ACCOUNT.DBO.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
				,rpt_code,trn_currency,emp_name,field1,field2)	
			SELECT @SESSION_ID,'system',@BANK_ACC,'j','dr',@AMOUNT,1,@AMOUNT,@DATE
				,'USDVOUCHER','JPY','system',@BANK_ID,'Customer Deposit EOD'

			UPDATE L SET L.ISSETTLED = 1 
			FROM #TEMP_SETTLE T
			INNER JOIN CUSTOMER_DEPOSIT_LOGS L(NOLOCK) ON L.TRANID = T.TRANID 
			WHERE T.BANKNAME = @BANK_ID

			DELETE FROM #TEMP_SETTLE 
			WHERE BANKNAME = @BANK_ID
		END

		EXEC PROC_ERRORHANDLER 0, 'Customer deposit settled successfully!', null
		DECLARE @narration VARCHAR(150) = 'Customer deposit settlement: system'
		EXEC FASTMONEYPRO_ACCOUNT.DBO.[spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@DATE,@narration=@narration,@company_id=1,@v_type='j',@user='system'
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION
	
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	
	INSERT INTO LOGS(ERRORPAGE, errorMsg, errorDetails, CREATEDBY, CREATEDDATE)
	SELECT 'SQL JOB', 'PROC_BALANCE_SETTLE_AND_EOD : '+@FLAG, @errorMessage, 'auto', GETDATE()
END CATCH

