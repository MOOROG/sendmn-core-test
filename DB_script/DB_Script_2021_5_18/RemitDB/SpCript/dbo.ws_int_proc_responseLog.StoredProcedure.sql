USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_responseLog]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_int_proc_responseLog]
	 @flag			VARCHAR(10)		= NULL
	,@requestId		BIGINT			= NULL
	,@errorCode		VARCHAR(10)		= NULL
	,@errorMsg		VARCHAR(MAX)	= NULL

AS

SET NOCOUNT ON

/*
	s - Standard Send
	u - SMA USA Send
	o - Other Methods
	sp_helptext ws_int_proc_responseLog
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

IF @flag = 'o'
BEGIN
	UPDATE requestApiLogOther SET
		 errorCode			= @errorCode
		,errorMsg			= @errorMsg
	WHERE rowId = @requestId
	
	RETURN
END

GO
