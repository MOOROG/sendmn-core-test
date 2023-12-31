USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendAutoEmail]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_sendAutoEmail] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(50)		= NULL
	,@complain			VARCHAR(MAX)	= NULL
	,@user				VARCHAR(50)		= NULL
	,@branchId			INT				= NULL
) 
AS
SET NOCOUNT ON
SET XACT_ABORT ON

	DECLARE @controlNoEncrypted VARCHAR(20)
			,@id INT
			,@replyTo VARCHAR(5)
			,@adminEmail VARCHAR(MAX)
			,@agentEmail VARCHAR(100)
			,@subject VARCHAR(MAX)
			,@body VARCHAR(MAX)
			,@agentName VARCHAR(200)
			,@branch INT
			,@agent INT
	SET @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)


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
		,#STUDENT_NAME#			VARCHAR(MAX)
		,#STUDENT_CLASS#		VARCHAR(MAX)
	)


	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted)
	BEGIN
		INSERT INTO #TEMP1
		SELECT 
			 #CURRENT_DATE#			= CAST(GETDATE() AS VARCHAR)
			,#SEND_AGENT_NAME#		= ISNULL(sAgentName + ' - ' + sBranchName, '')
			,#SEND_COUNTRY#			= sCountry
			,#TRAN_ID#				= CAST(rt.id AS VARCHAR)
			,#SEND_USER#			= rt.createdBy
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
			,#STUDENT_NAME#			= rec.stdName
			,#STUDENT_CLASS#		= ISNULL(' ' + sl.name, '') + ' /' +ISNULL(' ' + rec.stdRollRegNo, '') + ISNULL(' ' + rec.stdSemYr,' ')
		FROM remitTran rt WITH(NOLOCK) INNER JOIN dbo.tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		LEFT JOIN dbo.schoolLevel sl WITH(NOLOCK) ON sl.rowId = rec.stdLevel 
		WHERE controlNo = @controlNoEncrypted
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
			,t.#STUDENT_NAME#
			,t.#STUDENT_CLASS#
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
			,#STUDENT_NAME#
			,#STUDENT_CLASS#
		)
	) AS unpvt


	IF @flag = 'EduPay'
	BEGIN
		IF EXISTS(
		SELECT 'x'
			FROM emailTemplate WITH(NOLOCK) 
			WHERE templateFor = @flag 
			AND ISNULL(replyTo, 'Both') IN ('Both', 'Admin') 
			AND ISNULL(isEnabled, 'N') = 'Y' 
			AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT @adminEmail = email +';'+ ISNULL(@adminEmail, '')
			FROM SystemEmailSetup WITH(NOLOCK) 
			WHERE ISNULL(isSummary, 'No') = 'Yes' 
				AND (agent = dbo.FNAGetHOAgentId()) 
				AND ISNULL(isDeleted, 'N') = 'N'

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

			if @adminEmail is not NULL and @subject IS not NULL and @body is not NULL and @controlNo is not NULL
			BEGIN
				INSERT INTO dbo.SMSQueue
						( 
						  email ,
						  subject ,
						  msg ,
						  createdDate ,
						  createdBy ,
						  controlNo 
						)
				VALUES  ( 
						  @adminEmail , 
						  @subject , 
						  @body , 
						  GETDATE(),
						  @user,
						  @controlNo
						)
			END
		END
		

		-- ## Email subject and body - Agent	
		IF EXISTS(SELECT 'X' FROM emailTemplate WITH(NOLOCK) 
			WHERE templateFor = @flag 
				AND ISNULL(replyTo, 'Both') IN ('Both', 'Agent') 
				AND ISNULL(isEnabled, 'N') = 'Y' 
				AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT 
				@subject = emailSubject, 
				@body = emailFormat 
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
		
			SELECT @agentEmail = agentEmail1 
			FROM remitTran rt WITH(NOLOCK) 
			INNER JOIN dbo.tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
			INNER JOIN dbo.schoolMaster sm WITH(NOLOCK) ON rec.stdCollegeId = sm.rowId 
			INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON sm.agentId = am.agentId
			WHERE rt.controlNo = @controlNoEncrypted
			IF @agentEmail is not NULL
			BEGIN            
				INSERT INTO dbo.SMSQueue
						( 
						  email ,
						  subject ,
						  msg ,
						  createdDate ,
						  createdBy ,
						  controlNo 
						)
				VALUES  ( 
						  @agentEmail , 
						  @subject , 
						  @body , 
						  GETDATE(),
						  @user,
						  @controlNo
						)
			END
		END
	END

GO
