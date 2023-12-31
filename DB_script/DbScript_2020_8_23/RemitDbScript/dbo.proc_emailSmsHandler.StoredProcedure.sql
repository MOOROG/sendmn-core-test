USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_emailSmsHandler]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_emailSmsHandler]
	 @flag			VARCHAR(50)		= NULL
	,@user			VARCHAR(50)		= NULL
	,@msg			VARCHAR(MAX)	= NULL
	,@country		VARCHAR(100)	= NULL
	,@agentId		INT				= NULL
	,@exRateId		INT				= NULL

AS
SET NOCOUNT ON

IF @flag = 'sms'
BEGIN
	INSERT INTO SMSQueue(
		 mobileNo
		,msg
		,country
		,createdBy
		,createdDate
	)
	SELECT 
		 mobile
		,@msg
		,@country
		,@user 
		,GETDATE()
	FROM SystemEmailSetup WITH(NOLOCK) WHERE country = @country AND isXRate = 'Yes' AND ISNULL(isDeleted, 'N') = 'N'
END
IF @flag = 'ExRate'
BEGIN
	DECLARE  @emails VARCHAR(MAX)
			,@subject VARCHAR(MAX)
			,@body VARCHAR(MAX)
			,@replyTo VARCHAR(MAX)

	CREATE TABLE #letterKeyword(id INT IDENTITY(1,1), keyword VARCHAR(MAX), VALUE VARCHAR(MAX))
	CREATE TABLE #TEMP1(
		 #CURRENT_DATE#			VARCHAR(MAX)
		,#CURRENT_TIME#			VARCHAR(MAX)
		,#R_CURR#				VARCHAR(MAX)
		,#USD_VS_R_CURR#		VARCHAR(MAX)
		,#S_CURR#				VARCHAR(MAX)
		,#USD_VS_S_CURR#		VARCHAR(MAX)		
	)
	
	select @agentId = cAgent 
		from exRateTreasury with(nolock) where exRateTreasuryId = @exRateId
	
	INSERT INTO #TEMP1
	SELECT 
		 #CURRENT_DATE#			= CONVERT(VARCHAR,GETDATE(),107)
		,#CURRENT_TIME#			= LTRIM(RIGHT(CONVERT(VARCHAR(20), dbo.FNAGetDateInNepalTZ(), 100), 7))
		,#R_CURR#				= pCurrency
		,#USD_VS_R_CURR#		= ROUND((pRate - ISNULL(pMargin, 0) - ISNULL(pHoMargin, 0)), 10)
		,#S_CURR#				= cCurrency
		,#USD_VS_S_CURR#		= ROUND((cRate + ISNULL(cMargin, 0) + ISNULL(cHoMargin, 0)), 10)
	FROM exRateTreasury et WITH(NOLOCK) 
	INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = et.cAgent
	WHERE ISNULL(et.isActive, 'N') = 'Y' 
		AND ISNULL(et.isDeleted, 'N') = 'N' 
		AND et.exRateTreasuryId = @exRateId
	
	INSERT INTO #letterKeyWord
	SELECT col, VALUE
	FROM
	(
		SELECT
			 t.#CURRENT_DATE#
			,t.#CURRENT_TIME#
			,t.#R_CURR#
			,t.#USD_VS_R_CURR#	
			,t.#S_CURR#
			,t.#USD_VS_S_CURR#
		FROM #TEMP1 AS t
	) AS SourceTable
	UNPIVOT
	(
		VALUE FOR Col IN
		(
			 #CURRENT_DATE#
			,#CURRENT_TIME#
			,#R_CURR#
			,#USD_VS_R_CURR#	
			,#S_CURR#
			,#USD_VS_S_CURR#
		)
	) AS unpvt

	-- ## Email subject and body - admin
	SELECT
		@subject = emailSubject, 
		@body = emailFormat,
		@replyTo = replyTo
	FROM emailTemplate WITH(NOLOCK) 
	WHERE templateFor = @flag 
	AND ISNULL(replyTo, 'Both') IN ('Both', 'Admin') 
	AND ISNULL(isEnabled, 'N') = 'Y' 
	AND ISNULL(isDeleted, 'N') = 'N'
	
	
	IF @replyTo IN ('Both')
	BEGIN
		SELECT @emails = agentEmail1 FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
	END

	DECLARE @totalRows INT, @count INT = 1
	SELECT @totalRows = COUNT(*) FROM #letterKeyword
	WHILE(@count <= @totalRows)
	BEGIN
		SELECT 
			 @subject = REPLACE(@subject, keyword, ISNULL(VALUE, ''))
			,@body = REPLACE(@body, keyword, ISNULL(VALUE, ''))
		FROM #letterKeyword WHERE id = @count
		
		SET @count = @count + 1
	END

	--SELECT @subject [subject], @body [body], @emails [agentEmail]

	INSERT INTO SMSQueue(
		 email
		,subject
		,msg
		,country
		,createdBy
		,createdDate
	)
	SELECT 
		 --'dipesh@swifttech.com.np'--
		 'ramesh.subedi@imeremit.com;subash@imeremit.com'--@emails
		,'Exchange Rate'
		,@body
		,@country
		,@user 
		,GETDATE()
	
END




GO
