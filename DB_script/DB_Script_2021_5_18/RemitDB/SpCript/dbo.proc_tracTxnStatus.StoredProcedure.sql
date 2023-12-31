USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tracTxnStatus]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_tracTxnStatus](
	@flag VARCHAR(10)
	,@controlNo VARCHAR(50)	
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
    IF @flag = 'track'
	BEGIN
	    DECLARE @controlNoEnc VARCHAR(50) = dbo.FNAEncryptString(@controlNo), @status INT, @tranStatus VARCHAR(20), @paystatus VARCHAR(20), @paymentMethod VARCHAR(15)
		
		IF EXISTS(SELECT 1 FROM dbo.remitTranTemp (NOLOCK) WHERE controlNo = @controlNoEnc)
		BEGIN
		    EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 1
		END
		
		ELSE IF NOT EXISTS(SELECT 1 FROM dbo.remitTran (NOLOCK) WHERE controlNo = @controlNoEnc AND cancelApprovedDate IS NULL)
		BEGIN
			EXEC dbo.proc_errorHandler @errorCode = '1', @msg = 'Invalid transaction!', @id = NULL 
			RETURN
		END
		ELSE
		BEGIN
			SELECT 
				@tranStatus = tranStatus,
				@paystatus = payStatus,
				@paymentMethod = paymentMethod
			FROM dbo.remitTran (NOLOCK)
			WHERE controlNo = @controlNoEnc

			IF @tranStatus IS NULL
			BEGIN
				EXEC dbo.proc_errorHandler @errorCode = '1', @msg = 'Invalid transaction!', @id = NULL 
			END
			--SELECT @paymentMethod, @tranStatus, @paystatus

			IF @paymentMethod = 'BANK DEPOSIT'
			BEGIN
			    IF @tranStatus = 'Payment' AND @paystatus = 'Unpaid'
				BEGIN
					EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 2
				END
				ELSE IF @tranStatus = 'Payment' AND @paystatus = 'Post'
				BEGIN
					EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 3
				END
				ELSE IF @tranStatus = 'Paid' AND @paystatus = 'Paid'
				BEGIN
					EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 4
				END
				ELSE
				BEGIN
				    EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 2
				END
			END
			ELSE
			BEGIN
			    IF @tranStatus = 'Payment' AND @paystatus = 'Unpaid'
				BEGIN
					EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 2
				END
				ELSE IF @tranStatus = 'Paid' AND @paystatus = 'Paid'
				BEGIN
					EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 4
				END
				ELSE
				BEGIN
				    EXEC dbo.proc_errorHandler @errorCode = '0', @msg = 'Success!', @id = 3
				END
			END
		END
	END
END
GO
