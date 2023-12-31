USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_emailData]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_emailData] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(50)		= NULL
	,@complain			VARCHAR(MAX)	= NULL
	,@user				VARCHAR(50)		= NULL
	,@branchId			INT				= NULL
) 
AS
SET NOCOUNT ON
SET XACT_ABORT ON
	
	insert into emailHistory(flag,controlno,complain,createdBy,branchId)
	select @flag,@controlNo,@complain,@user,@branchId
	DECLARE @controlNoEncrypted VARCHAR(20)
			,@id INT
			,@replyTo VARCHAR(5)
			,@agentEmail VARCHAR(100)
			,@subject VARCHAR(MAX)
			,@body VARCHAR(MAX)
			,@agentName VARCHAR(200)
			,@branch INT
			,@agent INT
	SET @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

	IF @branchId IS NULL
		SELECT @branchId = agentId FROM applicationUsers WITH(NOLOCK) WHERE username=@user

	CREATE TABLE #letterKeyword(id INT IDENTITY(1,1), keyword VARCHAR(MAX), VALUE VARCHAR(MAX))
	CREATE TABLE #TEMP1(
		 #CURRENT_DATE#			VARCHAR(MAX)
		,#SEND_AGENT_NAME#		VARCHAR(MAX)
		,#SEND_COUNTRY#			VARCHAR(MAX)
		,#TRAN_ID#				VARCHAR(MAX)
		,#SEND_USER#			VARCHAR(MAX)
		,#PAID_USER#			VARCHAR(MAX)
		,#CANCEL_USER#			VARCHAR(MAX)
		,#CONTROL_NO#			VARCHAR(MAX)
		,#COMPLAIN#				VARCHAR(MAX)
		,#USER_NAME#			VARCHAR(MAX)
		,#PAID_AGENT_NAME#		VARCHAR(MAX)
		,#PAID_COUNTRY#			VARCHAR(MAX)
		,#SEND_DATE#			VARCHAR(MAX)
		,#PAID_DATE#			VARCHAR(MAX)
		,#CANCEL_DATE#			VARCHAR(MAX)
		,#SEND_AMT#				VARCHAR(MAX)
		,#PAID_AMT#				VARCHAR(MAX)
		,#USER_FULL_NAME#		VARCHAR(MAX)
		,#AGENT_NAME#			VARCHAR(MAX)
		,#BRANCH_NAME#			VARCHAR(MAX)
		,#RETURN_AMT#			VARCHAR(MAX)
	)


	IF EXISTS(SELECT 'X' FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted)
	BEGIN
		INSERT INTO #TEMP1
		SELECT 
			 #CURRENT_DATE#			= CAST(GETDATE() AS VARCHAR)
			,#SEND_AGENT_NAME#		= ISNULL(sAgentName + ' - ' + sBranchName, '')
			,#SEND_COUNTRY#			= sCountry
			,#TRAN_ID#				= CAST(id AS VARCHAR)
			,#SEND_USER#			= createdBy
			,#PAID_USER#			= ISNULL(paidBy, '')
			,#CANCEL_USER#			= ISNULL(cancelApprovedBy, '')
			,#CONTROL_NO#			= @controlNo
			,#COMPLAIN#				= ISNULL(@complain, '')
			,#USER_NAME#			= @user
			,#PAID_AGENT_NAME#		= ISNULL(pAgentName + ' - ' + pBranchName, '')
			,#PAID_COUNTRY#			= pCountry
			,#SEND_DATE#			= CAST(approvedDate AS VARCHAR)
			,#PAID_DATE#			= CAST(paidDate AS VARCHAR)
			,#CANCEL_DATE#			= CAST(cancelApprovedDate AS VARCHAR)
			,#SEND_AMT#				= dbo.ShowDecimal(cAmt)
			,#PAID_AMT#				= dbo.ShowDecimal(pAmt)
			,#USER_FULL_NAME#		= (SELECT firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '') FROM applicationUsers WITH(NOLOCK) WHERE userName = @user)
			,#AGENT_NAME#			= (
										SELECT CASE WHEN @branchId = dbo.FNAGetHOAgentId() THEN 'IME Head Office' ELSE sAgentName END
									   )
			,#BRANCH_NAME#			= (
										SELECT CASE WHEN @branchId = dbo.FNAGetHOAgentId() THEN 'IME Head Office' ELSE sBranchName END
									   )
			,#RETURN_AMT#			= cAmt - ISNULL(cancelCharge, 0)
		FROM vwRemitTran WITH(NOLOCK)
		WHERE controlNo = @controlNoEncrypted
	END
	ELSE
	BEGIN
		INSERT INTO #TEMP1
		SELECT 
			 #CURRENT_DATE#			= CAST(GETDATE() AS VARCHAR)
			,#SEND_AGENT_NAME#		= ISNULL(sAgentName + ' - ' + sBranchName, '')
			,#SEND_COUNTRY#			= sCountry
			,#TRAN_ID#				= CAST(id AS VARCHAR)
			,#SEND_USER#			= createdBy
			,#PAID_USER#			= ISNULL(paidBy, '')
			,#CANCEL_USER#			= ISNULL(cancelApprovedBy, '')
			,#CONTROL_NO#			= @controlNo
			,#COMPLAIN#				= ISNULL(@complain, '')
			,#USER_NAME#			= @user
			,#PAID_AGENT_NAME#		= ISNULL(pAgentName + ' - ' + pBranchName, '')
			,#PAID_COUNTRY#			= pCountry
			,#SEND_DATE#			= CAST(approvedDate AS VARCHAR)
			,#PAID_DATE#			= CAST(paidDate AS VARCHAR)
			,#CANCEL_DATE#			= CAST(cancelApprovedDate AS VARCHAR)
			,#SEND_AMT#				= dbo.ShowDecimal(cAmt)
			,#PAID_AMT#				= dbo.ShowDecimal(pAmt)
			,#USER_FULL_NAME#		= (SELECT firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '') FROM applicationUsers WITH(NOLOCK) WHERE userName = @user)
			,#AGENT_NAME#			= (
										SELECT CASE WHEN @branchId = dbo.FNAGetHOAgentId() THEN 'IME Head Office' ELSE sAgentName END
									   )
			,#BRANCH_NAME#			= (
										SELECT CASE WHEN @branchId = dbo.FNAGetHOAgentId() THEN 'IME Head Office' ELSE sBranchName END
									   )
			,#RETURN_AMT#			= cAmt - ISNULL(cancelCharge, 0)
		FROM cancelTranHistory WITH(NOLOCK)
		WHERE controlNo = @controlNoEncrypted
	END

	IF @controlNoEncrypted=''
	BEGIN
		INSERT INTO #TEMP1(#BRANCH_NAME#,#CURRENT_DATE#)
		SELECT agentName,GETDATE() FROM applicationUsers U WITH(NOLOCK) 
		INNER JOIN agentMaster A WITH(NOLOCK) ON U.agentId=A.agentId
		WHERE U.USERNAME=@USER
	END

	INSERT INTO #letterKeyWord
	SELECT col, VALUE
	FROM
	(
		SELECT
			 t.#CURRENT_DATE#
			,t.#SEND_AGENT_NAME#
			,t.#SEND_COUNTRY#	
			,t.#TRAN_ID#
			,t.#SEND_USER#
			,t.#PAID_USER#
			,t.#CANCEL_USER#
			,t.#CONTROL_NO#
			,t.#COMPLAIN#
			,t.#USER_NAME#
			,t.#PAID_AGENT_NAME#
			,t.#PAID_COUNTRY#
			,t.#SEND_DATE#
			,t.#PAID_DATE#
			,t.#CANCEL_DATE#
			,t.#SEND_AMT#
			,t.#PAID_AMT#	
			,t.#USER_FULL_NAME#
			,t.#AGENT_NAME#
			,t.#BRANCH_NAME#
			,t.#RETURN_AMT#
		FROM #TEMP1 AS t
	) AS SourceTable
	UNPIVOT
	(
		VALUE FOR Col IN
		(
			 #CURRENT_DATE#
			,#SEND_AGENT_NAME#
			,#SEND_COUNTRY#	
			,#TRAN_ID#
			,#SEND_USER#
			,#PAID_USER#
			,#CANCEL_USER#
			,#CONTROL_NO#
			,#COMPLAIN#
			,#USER_NAME#
			,#PAID_AGENT_NAME#
			,#PAID_COUNTRY#
			,#SEND_DATE#
			,#PAID_DATE#
			,#CANCEL_DATE#
			,#SEND_AMT#
			,#PAID_AMT#	
			,#USER_FULL_NAME#
			,#AGENT_NAME#
			,#BRANCH_NAME#
			,#RETURN_AMT#
		)
	) AS unpvt

	IF @flag = 'Trouble'
	BEGIN
		/*
		EXEC proc_emailData @flag = 'Trouble', @user = 'admin', 
			@controlNo = '7644176864D', @complain = 'Test Message'
		*/
		SELECT 
			 smtpServer
			,smtpPort
			,sendID
			,sendPSW 
			,enableSsl
		FROM emailServerSetup WITH(NOLOCK) 
		
		IF NOT EXISTS(SELECT 'X' FROM #letterKeyword)
		BEGIN
			SELECT name = NULL, email = NULL
		END
		ELSE
		BEGIN
			SELECT  
				 name
				,email
			FROM SystemEmailSetup WITH(NOLOCK) 
			WHERE ISNULL(isTrouble, 'No') = 'Yes' AND (agent = dbo.FNAGetHOAgentId()) AND ISNULL(isDeleted, 'N') = 'N'
		END
	END

	ELSE IF @flag = 'Modification Approve'
	BEGIN
		if not exists(
		SELECT 'x'
			FROM emailTemplate WITH(NOLOCK) 
			WHERE templateFor = @flag 
			AND ISNULL(replyTo, 'Both') IN ('Both', 'Admin') 
			AND ISNULL(isEnabled, 'N') = 'Y' 
			AND ISNULL(isDeleted, 'N') = 'N')
		begin
			return;
		end
		SELECT 
			 smtpServer
			,smtpPort
			,sendID
			,sendPSW 
			,enableSsl
		FROM emailServerSetup WITH(NOLOCK)
		
		SELECT  
			 name
			,email
		FROM SystemEmailSetup WITH(NOLOCK) 
		WHERE ISNULL(isTrouble, 'No') = 'Yes' AND (agent = dbo.FNAGetHOAgentId()) AND ISNULL(isDeleted, 'N') = 'N'
	END 

	ELSE IF @flag = 'Modification Request'
	BEGIN
		if not exists(
		SELECT 'x'
			FROM emailTemplate WITH(NOLOCK) 
			WHERE templateFor = @flag 
			AND ISNULL(replyTo, 'Both') IN ('Both', 'Admin') 
			AND ISNULL(isEnabled, 'N') = 'Y' 
			AND ISNULL(isDeleted, 'N') = 'N')
		begin
			return;
		end
		SELECT 
			 smtpServer
			,smtpPort
			,sendID
			,sendPSW 
			,enableSsl
		FROM emailServerSetup WITH(NOLOCK) 

		SELECT  
			 name
			,email
		FROM SystemEmailSetup WITH(NOLOCK) 
		WHERE ISNULL(isTrouble, 'No') = 'Yes' AND (agent = dbo.FNAGetHOAgentId()) AND ISNULL(isDeleted, 'N') = 'N'
	END 

	ELSE IF @flag = 'Cancel'
	BEGIN
		SELECT 
			 smtpServer
			,smtpPort
			,sendID
			,sendPSW 
			,enableSsl
		FROM emailServerSetup WITH(NOLOCK) 

		SELECT  
			 name
			,email
		FROM SystemEmailSetup WITH(NOLOCK) 
		WHERE ISNULL(isCancel, 'No') = 'Yes' AND (agent = dbo.FNAGetHOAgentId()) AND ISNULL(isDeleted, 'N') = 'N'
	END

	ELSE IF @flag = 'Cancel Request'
	BEGIN
		SELECT 
			 smtpServer
			,smtpPort
			,sendID
			,sendPSW 
			,enableSsl
		FROM emailServerSetup WITH(NOLOCK)

		SELECT
			 name
			,email
		FROM SystemEmailSetup WITH(NOLOCK) 
		WHERE ISNULL(isCancel, 'No') = 'Yes' AND (agent = dbo.FNAGetHOAgentId()) AND ISNULL(isDeleted, 'N') = 'N'
	END

	ELSE IF @flag = 'Bonus'
	BEGIN
		SELECT 
			 smtpServer
			,smtpPort
			,sendID
			,sendPSW 
			,enableSsl
		FROM emailServerSetup WITH(NOLOCK) 

		SELECT 
			 name
			,email
		FROM SystemEmailSetup WITH(NOLOCK)
		WHERE ISNULL(isBonus, 'No') = 'Yes' 
		AND (agent = dbo.FNAGetHOAgentId()) AND ISNULL(isDeleted, 'N') = 'N'	
	END
	ELSE
	BEGIN
		SELECT 
			 smtpServer
			,smtpPort
			,sendID
			,sendPSW 
			,enableSsl
		FROM emailServerSetup WITH(NOLOCK) 

		SELECT
			 name
			,email
		FROM SystemEmailSetup WITH(NOLOCK)
		WHERE (agent = dbo.FNAGetHOAgentId()) AND ISNULL(isDeleted, 'N') = 'N'
	END

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
		SELECT @branch = sBranch FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		SELECT @agentEmail = agentEmail1 FROM agentMaster WITH(NOLOCK) WHERE agentId = @branch
		--select @branch
	END
	DECLARE @totalRows INT, @count INT = 1
	SELECT @totalRows = COUNT(*) FROM #letterKeyword
	WHILE(@count <= @totalRows)
	BEGIN
		SELECT 
			 @subject = REPLACE(@subject, keyword, ISNULL(VALUE, ''))
			,@body = REPLACE(@body, keyword, ISNULL(VALUE, ''))
			,@id = id 
		FROM #letterKeyword WHERE id = @count
		
		SET @count = @count + 1
	END

	SELECT @subject [subject], @body [body], @agentEmail [agentEmail]

	-- ## Email subject and body - Agent	
	IF EXISTS(SELECT 'X' FROM emailTemplate WITH(NOLOCK) 
		WHERE templateFor = @flag 
			AND ISNULL(replyTo, 'Both') IN ('Both', 'Agent') 
			AND ISNULL(isEnabled, 'N') = 'Y' 
			AND ISNULL(isDeleted, 'N') = 'N')
	BEGIN
		SELECT @subject = emailSubject, @body = emailFormat 
		FROM emailTemplate WITH(NOLOCK) WHERE templateFor = @flag 
		AND ISNULL(replyTo, 'Both') IN ('Both', 'Agent') 
		AND ISNULL(isEnabled, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		SET @count = 1
		WHILE(@count <= @totalRows)
		BEGIN
			SELECT 
				 @subject = REPLACE(@subject, keyword, ISNULL(VALUE, ''))
				,@body = REPLACE(@body, keyword, ISNULL(VALUE, ''))
				,@id = id 
			FROM #letterKeyword WHERE id = @count
			
			SET @count = @count + 1
		END
		SELECT @agentEmail = agentEmail1 FROM agentMaster WITH(NOLOCK) WHERE agentId = @branch
		/*SELECT @agentEmail = agentEmail1 FROM 
		agentMaster am WITH(NOLOCK) 
		INNER JOIN applicationUsers au WITH(NOLOCK) ON am.agentId = au.agentId WHERE au.userName = @user
		*/
		
		SELECT @subject [subject], @body [body], @agentEmail [agentEmail]
	END


GO
