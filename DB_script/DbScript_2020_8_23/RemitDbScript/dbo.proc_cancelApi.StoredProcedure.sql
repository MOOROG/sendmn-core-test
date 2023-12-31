USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cancelApi]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_cancelApi]
(
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(100)	= NULL	
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE 
	 @controlNoEncrypted VARCHAR(50)
	,@tranStatus VARCHAR(50)
	,@message	VARCHAR(MAX)
	,@pCountry VARCHAR(100)

SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(LTRIM(RTRIM(@controlNo))))

IF @flag = 'chkStatus'
BEGIN
	IF @user IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Your session has expired. Cannot cancel transaction', NULL
		RETURN
	END

	SELECT 
		 @tranStatus		= tranStatus
		,@pCountry			= pCountry
	FROM dbo.remitTran WITH(NOLOCK) WHERE  controlNo = @controlNoEncrypted
	
	IF (@tranStatus IS NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction not found', @controlNoEncrypted
		RETURN
	END

	IF @tranStatus = 'Paid' AND @pCountry = 'Nepal'
	BEGIN
		set @message = 'Transaction is in PAID status, so can not approve the cancel request.'
		EXEC proc_errorHandler 1, @message, @controlNoEncrypted
		RETURN
	END
	
	EXEC [proc_errorHandler] 0, 'Healthy', @controlNoEncrypted

END

IF @flag = 'update'
BEGIN
	EXEC [proc_errorHandler] 0, 'Successfully updated', @controlNoEncrypted
END




GO
