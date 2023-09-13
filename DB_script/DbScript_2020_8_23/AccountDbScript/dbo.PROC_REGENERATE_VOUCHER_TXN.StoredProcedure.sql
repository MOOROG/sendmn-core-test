USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_REGENERATE_VOUCHER_TXN]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PROC_REGENERATE_VOUCHER_TXN]
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @VOUCHER_NUM VARCHAR(20), @CONTROLNO VARCHAR(30), @TRANSTATUS VARCHAR(60), @CANCELDATE VARCHAR(30)
		,@cancelReason VARCHAR(200)
	--UPDATE COMM_MISSING SET VOUCHER_GEN = 0 WHERE CONTROLNO IN ('21714447', '33JP212342230')
	--SELECT * FROM COMM_MISSING WHERE VOUCHER_GEN = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM COMM_MISSING WHERE VOUCHER_GEN = 0)
	BEGIN
		SELECT @CONTROLNO = CONTROLNO, @TRANSTATUS = TRANSTATUS, @CANCELDATE = CANCELAPPROVEDDATE
		FROM COMM_MISSING (NOLOCK)
		WHERE VOUCHER_GEN = 0

		SELECT @VOUCHER_NUM = REF_NUM
		FROM TRAN_MASTER TM(NOLOCK)
		WHERE FIELD1 = @CONTROLNO
		AND FIELD2 = 'REMITTANCE VOUCHER'
		AND ACCT_TYPE_CODE IS NULL

		DELETE FROM tran_master WHERE REF_NUM = @VOUCHER_NUM
		DELETE FROM tran_masterDETAIL WHERE REF_NUM = @VOUCHER_NUM

		EXEC proc_transactionVoucherEntry @controlNo = @CONTROLNO, @refNum = @VOUCHER_NUM
		IF @TRANSTATUS = 'CANCEL' AND @CANCELDATE IS NOT NULL
		BEGIN
			DELETE FROM tran_master WHERE REF_NUM = @VOUCHER_NUM + '.01'
			DELETE FROM tran_masterDETAIL WHERE REF_NUM = @VOUCHER_NUM + '.01'

			set @cancelReason ='Cancellation and refund of '+@CONTROLNO

			EXEC proc_CancelTranVoucher @flag = 'REVERSE', @tranDate = @CANCELDATE,@refNum=@VOUCHER_NUM
				,@vType='J',@refund='N',@user='SYSTEM',@remarks=@cancelReason
		END

		UPDATE COMM_MISSING SET VOUCHER_GEN = 1 WHERE CONTROLNO = @CONTROLNO
	END
END




GO
