USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tpApiLogs]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_tpApiLogs]
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
	,@processId	VARCHAR(40)		= NULL
AS
SET @user = ISNULL(@user, 'SYSTEM')

IF @flag = 'i'
BEGIN
	SET @processId = NEWID()

	INSERT vwTpApiLogs(providerName, methodName, controlNo, requestXml, requestedBy,requestedDate,errorCode,errorMessage,processId)
	SELECT @providerName, @methodName, @controlNo, @requestXml, @user, GETDATE(), @errorCode, @errorMessage,@processId
	
	SET @rowId = SCOPE_IDENTITY()
	SELECT '0' ErrorCode, 'Request Logged Successfully' Msg, @rowId Id,@processId Extra
	RETURN
END

ELSE IF @flag = 'i-api'
BEGIN
	if isnull(@processId, '') = ''
		SET @processId = NEWID()

	INSERT vwTpApiLogs(providerName, methodName, controlNo, requestXml, requestedBy,requestedDate,errorCode,errorMessage,processId)
	SELECT @providerName, @methodName, @controlNo, @requestXml, @user, GETDATE(), @errorCode, @errorMessage,@processId
	
	SET @rowId = SCOPE_IDENTITY()
	SELECT '0' ErrorCode, 'Request Logged Successfully' Msg, @rowId Id,@processId Extra
	RETURN
END

ELSE IF @flag = 'u'
BEGIN
	--SELECT @methodName = methodName, @providerName = providerName FROM vwTpApiLogs WITH(NOLOCK) WHERE rowId = @rowId

	UPDATE vwTpApiLogs SET
		 responseXml = @responseXml
		,responseDate = GETDATE()
		,errorCode	= @errorCode
		,errorMessage = @errorMessage
	WHERE rowId = @rowId

	SELECT '0' ErrorCode, 'Response Logged Successfully' Msg, @rowId Id

	RETURN
END

ELSE IF @flag = 'vr'
BEGIN
	/*
		Validate For Duplicate Request within 180000 millisecons = 180 seconds = 3 minutes
		check from the internal log recorded
		if there is an execution either from the schedule or manual run by user, it will verify if there is duplicate request done by itself or any other user.
	*/

	CREATE TABLE #temp(rowId BIGINT, requestedBy VARCHAR(50), requestedDate DATETIME)

	INSERT INTO #temp(rowId, requestedBy, requestedDate)
	SELECT rowId, requestedBy, requestedDate 
	FROM vwTpApiLogs WITH(NOLOCK) 
	WHERE controlNo = @controlNo AND requestedDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59:998'
	
	IF EXISTS(SELECT TOP 1 'X' FROM #temp)
	BEGIN
		DECLARE @count INT

		IF @user = 'sch_admin'
		BEGIN
			SELECT @count = COUNT('X') FROM #temp WHERE DATEDIFF(MILLISECOND, requestedDate, GETDATE()) <= 180000
			IF ISNULL(@count, 0) > 1
			BEGIN
				EXEC dbo.proc_errorHandler 1, 'From IME: Duplicate request within 3 minutes is restricted', NULL
				RETURN
			END
		END
		ELSE
		BEGIN
			SELECT @count = COUNT('X') FROM #temp WHERE DATEDIFF(MILLISECOND, requestedDate, GETDATE()) <= 5000
			IF ISNULL(@count, 0) > 1
			BEGIN
				EXEC dbo.proc_errorHandler 1, 'From IME: Duplicate request within 5 seconds is restricted', NULL
				RETURN
			END
		END
	END

	EXEC dbo.proc_errorHandler 0, 'Valid Request', NULL

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp
END



GO
