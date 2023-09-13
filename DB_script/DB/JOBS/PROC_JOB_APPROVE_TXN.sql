use fastmoneypro_remit
go

ALTER PROC PROC_JOB_APPROVE_TXN
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @TRANID BIGINT = NULL, @COUNTROLNO VARCHAR(30), @tranDate VARCHAR(20), @ISCANCEL INT, @cancelReason VARCHAR(100),
	@ref_num VARCHAR(20), @CANCELAPPROVEDDATE VARCHAR(20), @NEWTRANID BIGINT, @TRANSTATUS VARCHAR(20), @paiddate varchar(20);
	
	--CREATE TABLE TEMP_ERROR_CODE (ERROR_CODE VARCHAR(20), MSG VARCHAR(250), ID VARCHAR(20))
	
	WHILE EXISTS(SELECT TOP 1 1 FROM send_voucher (NOLOCK) WHERE voucher_gen = 0)
	BEGIN
		SELECT TOP 1 @TRANID = s.ID, @COUNTROLNO = s.CONTROLNO, @CANCELAPPROVEDDATE = s.cancelApproveddate, @paiddate = paidDate
		FROM send_voucher s (NOLOCK)
		WHERE voucher_gen = 0

		INSERT INTO TEMP_ERROR_CODE
		EXEC FastMoneyPro_Account.dbo.proc_transactionVoucherEntry @controlNo = @COUNTROLNO
		
		IF @CANCELAPPROVEDDATE IS NOT NULL
		BEGIN
			select top 1  @ref_num = t.ref_num from FastMoneyPro_Account.dbo.tran_master t(nolock)
			WHERE field1 = @COUNTROLNO AND t.tran_type = 'j' AND field2 = 'Remittance Voucher'
			AND ACCT_TYPE_CODE IS NULL

			IF @ref_num is NOT null
			BEGIN
				set @cancelReason ='Cancellation and refund of '+@COUNTROLNO

				EXEC FastMoneyPro_Account.dbo.proc_CancelTranVoucher @flag = 'REVERSE', @tranDate = @CANCELAPPROVEDDATE,@refNum=@ref_num,@vType='J',@refund='N',@user='system',@remarks=@cancelReason
			END
		END
		ELSE
		BEGIN
			EXEC FastMoneyPro_Account.DBO.PROC_TRANSACTION_PAID_VOUCHER_ENTRY @controlNo=@COUNTROLNO,@tranDate=@paiddate
		END
		--EXEC proc_ApproveHoldedTXN_ForJob @flag='approve',@id=@TRANID,@user='admin'

		UPDATE send_voucher SET voucher_gen = 1 WHERE CONTROLNO = @COUNTROLNO
	END
	--EXEC PROC_JOB_VAULT_TRANSFER_AND_EOD
		--IF @ISCANCEL = 0 
		--BEGIN
		--	IF @TRANSTATUS = 'PAID'
		--		EXEC FastMoneyPro_Account.DBO.PROC_TRANSACTION_PAID_VOUCHER_ENTRY @controlNo=@COUNTROLNO,@tranDate=@tranDate
		--END
		--ELSE 
		--BEGIN
		--	SELECT @NEWTRANID = ID 
		--	FROM REMITTRAN (NOLOCK) 
		--	WHERE CONTROLNO = DBO.FNAENCRYPTSTRING(@COUNTROLNO)

		--	EXEC PROC_CANCEL_TXN_CASH @TRAN_ID=@NEWTRANID

			--select top 1  @ref_num = t.ref_num from FastMoneyPro_Account.dbo.tran_master t(nolock)
			--WHERE field1 = @COUNTROLNO AND t.tran_type = 'j' AND field2 = 'Remittance Voucher'
			--AND ACCT_TYPE_CODE IS NULL

			--IF @ref_num is NOT null
			--BEGIN
			--	set @cancelReason ='Cancellation and refund of '+@COUNTROLNO

			--	EXEC FastMoneyPro_Account.dbo.proc_CancelTranVoucher @flag = 'REVERSE', @tranDate = @CANCELAPPROVEDDATE,@refNum=@ref_num,@vType='J',@refund='N',@user='system',@remarks=@cancelReason
			--END
		--END
		--EXEC FastMoneyPro_Account.dbo.proc_transactionVoucherEntry @controlNo = @COUNTROLNO
END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()

	INSERT INTO JOB_ERROR_LOGS
	SELECT @errorMessage, 'PROC_JOB_APPROVE_TXN', GETDATE()
END CATCH

--CREATE TABLE JOB_ERROR_LOGS (ROW_ID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY, ERROR_MSG VARCHAR(MAX), JOB_NAME VARCHAR(50), LOG_DATE DATETIME)
