USE FASTMONEYPRO_ACCOUNT
GO

CREATE PROC PROC_FUNDTRANSFER
	@flag			VARCHAR(30) 
	,@user			VARCHAR(20)	=	NULL
	,@date			VARCHAR(10)	=	NULL
	,@description	NVARCHAR(250)=	NULL
	,@currency		VARCHAR(10) =	NULL
	,@amount		BIGINT		=	NULL
	,@debitAc		VARCHAR(30) =	NULL
	,@creditAc		VARCHAR(30)	=	NULL
	,@SETTINGS_ID   INT			=	NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY

IF @flag = 'save'
BEGIN
	INSERT INTO TBL_FUND_TRANSFER_SETTINGS
	values (@currency,@debitAc,@creditAc,@description)

	select 0 ErrorCode,'Data inserted successfully' Msg, null Id
END
ELSE IF @FLAG = 'descriptionDdl'
BEGIN
	select null valueField,'Select Description' textField
	union all
	select row_Id valueField,description textField from tbl_fund_transfer_settings	
END
ELSE IF @flag = 'saveFundTransfer'
BEGIN
		DECLARE @FROM_ACC VARCHAR(30), @TO_ACC VARCHAR(30), @SESSION_ID VARCHAR(50) = NEWID(), @ID BIGINT
		CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))

		SELECT @FROM_ACC = FROM_ACC, @TO_ACC = TO_ACC, @DESCRIPTION = [DESCRIPTION]
		FROM TBL_FUND_TRANSFER_SETTINGS (NOLOCK)
		WHERE ROW_ID = @SETTINGS_ID
		IF NOT EXISTS (SELECT 1 FROM ac_master (NOLOCK) WHERE ACCT_NUM = @FROM_ACC) OR NOT EXISTS (SELECT 1 FROM ac_master (NOLOCK) WHERE ACCT_NUM = @TO_ACC)
		BEGIN
			EXEC PROC_ERRORHANDLER 1, 'Invalid accounts defined for the transfer!', NULL
			RETURN;
		END
		
		INSERT INTO TBL_FUND_TRANSFER(SETTINGS_ID, AMOUNT, TRAN_DATE, CREATED_BY, CREATED_DATE, CURRENCY)
		SELECT @SETTINGS_ID, @AMOUNT, @date, @USER, GETDATE(), @CURRENCY

		SET @ID = @@IDENTITY

		--voucher entry for TRANSIT ACC
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,field1,field2)	
		SELECT @SESSION_ID,@USER,@FROM_ACC,'j','cr',@AMOUNT,@AMOUNT,1,@date
			,'USDVOUCHER',@CURRENCY,@ID,'Transit Cash Settle'

		--voucher entry for VAULT OR BANK ACC
		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
			,rpt_code,trn_currency,field1,field2)	
		SELECT @SESSION_ID,@USER,@TO_ACC,'j','dr',@AMOUNT,@AMOUNT,1,@date
			,'USDVOUCHER',@CURRENCY,@ID,'Transit Cash Settle'

		INSERT INTO #TEMP_ERROR_CODE
		EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@date,@narration=@DESCRIPTION,@company_id=1,@v_type='j',@user=@USER

		UPDATE T SET T.IS_SUCCESS = CASE WHEN ERROR_CODE = '0' THEN 0 ELSE 1 END, T.VOUCHER_NUM = ID, T.ERROR_MSG = MSG
		FROM TBL_FUND_TRANSFER T
		INNER JOIN #TEMP_ERROR_CODE C ON 1 = 1
		WHERE ROW_ID = @ID

		SELECT * FROM #TEMP_ERROR_CODE
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT 1 errorCode,'Error in Fund Transfer' msg ,NULL id
		END
END CATCH