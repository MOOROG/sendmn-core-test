use fastmoneypro_remit
go
--EXEC PROC_MANUAL_CANCEL @CONTROLNO = '33TF025897271', @CANCELdATE = '2020-05-18', @USER = 'atit', @cancelReason='ACCOUNT # INCORRECT'

ALTER PROC PROC_MANUAL_CANCEL 
(
	@CONTROLNO VARCHAR(30)
	,@CANCELdATE VARCHAR(30) = NULL
	,@USER VARCHAR(50) = NULL
	,@cancelReason VARCHAR(150) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @ID BIGINT, @ref_num varchar(30), @ref_num_new VARCHAR(30), @collMode VARCHAR(30), @sAgent INT, @userId INT, @referralCode VARCHAR(30)
				,@isOnbehalf CHAR(1), @cAmt MONEY, @controlNoEncrypted VARCHAR(30) = DBO.FNAENCRYPTSTRING(@CONTROLNO)

	CREATE TABLE #TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))

	IF ISNULL(@USER, '') = ''
		SET @USER = 'SYSTEM'

	SELECT @ID = RT.ID,
			@collMode = COLLMODE,
			@sAgent = SAGENT,
			@userId = A.USERID,
			@referralCode = PROMOTIONCODE,
			@isOnbehalf = (CASE WHEN ISONBEHALF = '1' THEN 'Y' ELSE 'N' END),
			@cAmt = CAMT
	FROM remitTran RT WITH(NOLOCK) 
	INNER JOIN tranSenders S WITH(NOLOCK) ON S.tranId = RT.id
	LEFT JOIN applicationUsers A(NOLOCK) ON A.USERNAME = RT.CREATEDBY
	WHERE CONTROLNO = @controlNoEncrypted

	BEGIN TRANSACTION
		UPDATE remitTran SET
				tranStatus				= 'Cancel'
				, PAYSTATUS				= 'CANCEL'
				,cancelApprovedBy		= @user
				,cancelApprovedDate		= @CANCELdATE
				,cancelApprovedDateLocal	= @CANCELdATE
				,cancelReason				= @cancelReason
		WHERE ID = @ID

		select @cancelDate = CANCELAPPROVEDDATE
		from REMITTRAN WHERE ID = @ID

		EXEC proc_transactionLogs 'i', @user, @ID, @cancelReason, 'Cancel Approved'

		IF @collMode = 'Cash collect'
		BEGIN
			EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG='CANCEL',@S_AGENT = @sAgent,@S_USER = @userId,@REFERRAL_CODE = @referralCode,@C_AMT = @cAmt,@ONBEHALF = @isOnbehalf
		END
		IF @collMode = 'Bank Deposit'
		BEGIN
			EXEC proc_UpdateCustomerBalance @controlNo=@controlNoEncrypted
		END


		EXEC PROC_CANCEL_TXN_CASH @TRAN_ID = @ID

		select top 1 @ref_num = t.ref_num from FastMoneyPro_Account.dbo.tran_master t(nolock)
		WHERE field1 = @CONTROLNO AND t.tran_type = 'j' AND field2 = 'Remittance Voucher'
		AND ACCT_TYPE_CODE IS NULL

		SET @ref_num_new = @ref_num+'.01'

		IF @ref_num is NOT null
		BEGIN
			SELECT top 1 @ref_num_new = t.ref_num from FastMoneyPro_Account.dbo.tran_master t(nolock)
			WHERE field1 = @CONTROLNO AND t.tran_type = 'j' AND field2 = 'Remittance Voucher'
			AND ACCT_TYPE_CODE = 'Paid'

			IF @ref_num_new IS NOT NULL
			BEGIN
				DELETE FROM FastMoneyPro_Account.dbo.tran_master WHERE REF_NUM = @ref_num_new AND ACCT_TYPE_CODE = 'Paid'
				DELETE FROM FastMoneyPro_Account.dbo.tran_masterDETAIL WHERE REF_NUM = @ref_num_new
			END

			set @cancelReason ='Cancellation and refund of '+@CONTROLNO

			--select @cancelDate, @ref_num, @USER, @cancelReason
			INSERT INTO #TEMP_ERROR_CODE
			EXEC FastMoneyPro_Account.dbo.proc_CancelTranVoucher @flag = 'REVERSE', @tranDate = @cancelDate,@refNum=@ref_num,@vType='J',@refund='N',@user=@USER,@remarks=@cancelReason
		END
		ELSE
		BEGIN
			SELECT 1 ERROR_CODE, 'No send voucher found for this txn' msg, null ID
			RETURN
		END

		SELECT ERROR_CODE, msg = CASE WHEN ERROR_CODE = '0' THEN 'Cancel done successfully with voucher no: '+ID ELSE 'Error performing cancel txn' END , ID
		FROM #TEMP_ERROR_CODE

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() msg, NULL id
END CATCH
