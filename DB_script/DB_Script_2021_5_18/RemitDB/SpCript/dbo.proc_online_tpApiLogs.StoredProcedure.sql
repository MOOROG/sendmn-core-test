USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_tpApiLogs]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_online_tpApiLogs]
	 @flag VARCHAR(50)
	,@providerName VARCHAR(200) = NULL
	,@methodName VARCHAR(200)	= NULL
	,@controlNo VARCHAR(50)		= NULL
	,@rowId BIGINT				= NULL
	,@requestXml VARCHAR(MAX)	= NULL
	,@responseXml VARCHAR(MAX)	= NULL
	,@user VARCHAR(30)			= NULL
	,@errorCode VARCHAR(10)		= NULL
	,@errorMessage VARCHAR(200)	= NULL
AS
SET @user = ISNULL(@user, 'SYSTEM')

IF @flag = 'i'
BEGIN
	INSERT tpApiLogs(providerName, methodName, controlNo, requestXml, requestedBy,requestedDate)
	SELECT @providerName, @methodName, @controlNo, @requestXml, @user, GETDATE()
	
	SET @rowId = SCOPE_IDENTITY()
	SELECT '0' ErrorCode, 'Request Logged Successfully' Msg, @rowId Id, '', ''
	RETURN
END

IF @flag = 'u'
BEGIN
	UPDATE tpApiLogs SET
		 responseXml = @responseXml
		,responseDate = GETDATE()
		
	WHERE rowId = @rowId

	SELECT '0' ErrorCode, 'Response Logged Successfully' Msg, @rowId Id, '', ''
	RETURN
END

GO
