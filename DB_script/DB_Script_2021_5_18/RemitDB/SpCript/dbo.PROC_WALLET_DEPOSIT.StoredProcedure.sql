USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_WALLET_DEPOSIT]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PROC_WALLET_DEPOSIT]
(
	@FLAG			VARCHAR(30)
	,@USER			VARCHAR(80) = NULL
	,@AMOUNT		MONEY = NULL
	,@BILL_NO		VARCHAR(50) = NULL
	,@DATE			DATETIME = NULL
	,@DESCRIPTION	NVARCHAR(150) = NULL
	,@VAT_FLAG		BIT = NULL
	,@ROW_ID		BIGINT = NULL
	,@RESPONSE_CODE	NVARCHAR(100) = NULL
	,@RESPONSE_MESSAGE	NVARCHAR(250) = NULL
	,@XML			NVARCHAR(MAX) = NULL
	,@TP_CODE		VARCHAR(50) = NULL
	,@TP_CODE_EXTRA	VARCHAR(50) = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @CUSTOMER_ID BIGINT = NULL, @CUSTOMER_WALLET VARCHAR(30)
	IF @FLAG = 'REQUEST'
	BEGIN
		SELECT @CUSTOMER_ID = CUSTOMERID, @CUSTOMER_WALLET = walletaccountno
		FROM CUSTOMERMASTER (NOLOCK) 
		WHERE username = @USER 
		AND APPROVEDBY IS NOT NULL 
		AND APPROVEDDATE IS NOT NULL

		IF @CUSTOMER_ID IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid customer!', NULL
			RETURN
		END
		IF ISNULL(@AMOUNT, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Amount can not be empty or negative!', NULL
			RETURN
		END

		INSERT INTO TBL_WALLET_DEPOSIT_REQUEST([USER], CUSTOMER_ID, AMOUNT, BILL_NO, [DATE], [DESCRIPTION], VAT_FLAG
				, CREATED_BY, CREATED_DATE, IS_EXPIRED, IS_SUCCESS, RESPONSE_CODE, RESPONSE_MESSAGE)
		SELECT @USER, @CUSTOMER_ID, @AMOUNT, @BILL_NO, @DATE, @DESCRIPTION + ISNULL(' - '+@CUSTOMER_WALLET, ''), @VAT_FLAG
						, @USER, GETDATE(), 0, 0, NULL, NULL

		SET @ROW_ID = @@IDENTITY
		SELECT @BILL_NO = RIGHT(REPLACE(NEWID(), '-', '')+RIGHT('0000000' + CAST(@ROW_ID AS VARCHAR), 6), 20)

		UPDATE TBL_WALLET_DEPOSIT_REQUEST SET BILL_NO = @BILL_NO WHERE ROW_ID = @ROW_ID

		INSERT INTO TBL_WALLET_DEPOSIT_LOG(DEPOSIT_ID, REQUEST_RESPONSE, [TYPE], LOG_DATE)
		SELECT @ROW_ID, @XML, 'REQUEST', GETDATE()

		--EXEC proc_errorHandler 0, 'Success', @BILL_NO
		SELECT 0 ERRORCODE, 'Success' MSG, @BILL_NO ID, @ROW_ID EXTRA
		RETURN
	END
	IF @FLAG = 'ERROR'
	BEGIN
		UPDATE TBL_WALLET_DEPOSIT_REQUEST SET RESPONSE_CODE = @RESPONSE_CODE, RESPONSE_MESSAGE = @RESPONSE_MESSAGE,
								IS_EXPIRED = 1, STATUS_UPDATED_DATE = GETDATE()
		WHERE ROW_ID = @ROW_ID

		INSERT INTO TBL_WALLET_DEPOSIT_LOG(DEPOSIT_ID, REQUEST_RESPONSE, [TYPE], LOG_DATE)
		SELECT @ROW_ID, @XML, 'RESPONSE', GETDATE()

		EXEC proc_errorHandler 0, 'Success', NULL
		RETURN
	END
	IF @FLAG = 'SUCCESS'
	BEGIN
		UPDATE TBL_WALLET_DEPOSIT_REQUEST SET RESPONSE_CODE = @RESPONSE_CODE, RESPONSE_MESSAGE = @RESPONSE_MESSAGE,
								IS_EXPIRED = 0, TP_CODE = @TP_CODE, TP_CODE_EXTRA = @TP_CODE_EXTRA
		WHERE ROW_ID = @ROW_ID

		INSERT INTO TBL_WALLET_DEPOSIT_LOG(DEPOSIT_ID, REQUEST_RESPONSE, [TYPE], LOG_DATE)
		SELECT @ROW_ID, @XML, 'RESPONSE', GETDATE()

		EXEC proc_errorHandler 0, 'Success', NULL
		RETURN
	END
	IF @FLAG = 'CHECK'
	BEGIN
		DECLARE @IS_EXPIRED BIT, @IS_SUCCESS BIT

		SELECT @ROW_ID = ROW_ID
				,@IS_EXPIRED = IS_EXPIRED
				,@IS_SUCCESS = IS_SUCCESS
		FROM TBL_WALLET_DEPOSIT_REQUEST(NOLOCK) 
		WHERE BILL_NO = @BILL_NO

		IF @ROW_ID IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid bill number!', NULL
			RETURN
		END
		IF @IS_EXPIRED = 1
		BEGIN
			EXEC proc_errorHandler 1, 'Requested bill number is already expired!', NULL
			RETURN
		END
		IF @IS_SUCCESS = 1
		BEGIN
			EXEC proc_errorHandler 1, 'Requested bill number is already marked as paid!', NULL
			RETURN
		END

		EXEC proc_errorHandler 0, 'Success', NULL
		RETURN
	END
	IF @FLAG = 'PAID'
	BEGIN
		SELECT 
			  @USER				=  [USER]				
			 ,@AMOUNT			=  AMOUNT		
			 ,@BILL_NO			=  BILL_NO		
			 ,@DATE				=  [DATE]			
			 ,@DESCRIPTION		=  [DESCRIPTION]
			 ,@CUSTOMER_ID		=  CUSTOMER_ID
			 ,@IS_EXPIRED		=  IS_EXPIRED
			 ,@IS_SUCCESS		=  IS_SUCCESS
			 ,@ROW_ID			=  ROW_ID
		FROM TBL_WALLET_DEPOSIT_REQUEST (NOLOCK) 
		WHERE BILL_NO = @BILL_NO

		IF @ROW_ID IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid bill number!', NULL
			RETURN
		END
		IF @IS_EXPIRED = 1
		BEGIN
			EXEC proc_errorHandler 1, 'Requested bill number is already expired!', NULL
			RETURN
		END
		IF @IS_SUCCESS = 1
		BEGIN
			EXEC proc_errorHandler 1, 'Requested bill number is already marked as paid!', NULL
			RETURN
		END

		BEGIN TRAN
			INSERT INTO TBL_WALLET_DEPOSIT_LOG(DEPOSIT_ID, REQUEST_RESPONSE, [TYPE], LOG_DATE)
			SELECT @ROW_ID, @XML, 'CHECK-RESP', GETDATE()

			UPDATE TBL_WALLET_DEPOSIT_REQUEST SET IS_SUCCESS = 1
			WHERE ROW_ID = @ROW_ID

			UPDATE customerMaster SET AVAILABLEBALANCE = ISNULL(AVAILABLEBALANCE, 0) + @AMOUNT WHERE CUSTOMERID = @CUSTOMER_ID

			--VOUCHER ENTRY
			DECLARE @KHAN_BANK_ACC VARCHAR(30), @TxnDate VARCHAR(30) = GETDATE(), @FULL_NAME VARCHAR(100)
					, @sessionID VARCHAR(50), @narration VARCHAR(100)

			SELECT @CUSTOMER_WALLET = walletAccountNo,
					@FULL_NAME = FULLNAME
			FROM customerMaster CM(NOLOCK)
			WHERE CUSTOMERID = @CUSTOMER_ID

			SELECT @KHAN_BANK_ACC = AC.acct_num FROM Vw_GetAgentID VA
			INNER JOIN SendMnPro_Account.DBO.ac_master AC(NOLOCK) ON AC.AGENT_ID  = VA.agentId
			WHERE SearchText = 'khankBank'
			AND AC.acct_rpt_code = 'VAC'
		
			SELECT @sessionID = RIGHT(NEWID(), 20), @TxnDate = GETDATE()
			--SendMN Khan Bank Acc :DR
			INSERT INTO SendMnPro_Account.dbo.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
				,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
			SELECT @sessionID,'system',@KHAN_BANK_ACC,'s','DR',@AMOUNT,@AMOUNT,1,@TxnDate
				,'Deposit Voucher','MNT',NULL,CAST(@ROW_ID AS VARCHAR),'Wallet Deposit', NULL, NULL

			--Customer wallet :CR
			INSERT INTO SendMnPro_Account.dbo.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
			SELECT @sessionID,'system',@CUSTOMER_WALLET,'s','CR',@AMOUNT,@AMOUNT,1,@TxnDate
				,'Deposit Voucher','MNT',NULL,CAST(@ROW_ID AS VARCHAR),'Wallet Deposit', NULL, NULL

			SET @narration = 'Wallet Deposit - ' + ISNULL(@FULL_NAME, '')
		
		COMMIT TRAN        
		IF @@TRANCOUNT=0      
		BEGIN      
			EXEC proc_errorHandler 0, 'Success', NULL

			EXEC SendMnPro_Account.dbo.[spa_saveTempTrnUSD] @flag='i',@sessionID=@sessionID,@date=@TxnDate,@narration=@narration
				,@company_id=1,@v_type='s',@user='system'
			--PUT THE LOGIC TO GENERATE VOUCHER HERE
			RETURN   
		END      
	END
END


GO
