USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_responseLog]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ws_proc_responseLog]
	 @flag			VARCHAR(10)		= NULL
	,@requestId		BIGINT			= NULL
	,@errorCode		VARCHAR(10)		= NULL
	,@errorMsg		VARCHAR(MAX)	= NULL
	,@remarks		VARCHAR(30)		= NULL

AS

SET NOCOUNT ON

/*
	s - Standard Send
	u - SMA USA Send
	o - Other Methods
	p - Pay
*/

IF @flag = 's'
BEGIN
	UPDATE apiRequestLog SET
		 errorCode			= @errorCode
		,errorMsg			= @errorMsg
	WHERE rowId = @requestId
	
	RETURN
END

IF @flag = 'u'
BEGIN
	UPDATE apiRequestLogSMA SET
		 errorCode			= @errorCode
		,errorMsg			= @errorMsg
	WHERE rowId = @requestId
	
	RETURN
END

IF @flag = 'p'
BEGIN
	UPDATE apiRequestLogPay SET
		 errorCode			= @errorCode
		,errorMsg			= @errorMsg
		,remarks			= @remarks
	WHERE rowId = @requestId
	
	RETURN
END

IF @flag = 'sma'
BEGIN
	UPDATE dbo.apiRequestLogSMA SET
		 errorCode			= @errorCode
		,errorMsg			= @errorMsg
	WHERE rowId = @requestId
	
	RETURN
END

IF @flag = 'exrate'
BEGIN
	UPDATE apiRequestLog_GetExRate SET
		 errorCode			= @errorCode
		,errorMsg			= @errorMsg
	WHERE rowId = @requestId
	
	RETURN
END
GO
