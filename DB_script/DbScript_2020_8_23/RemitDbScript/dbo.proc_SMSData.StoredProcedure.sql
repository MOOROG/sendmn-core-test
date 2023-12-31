USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_SMSData]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC proc_SMSData @flag = 'SMSToSender',@controlNo= '99266917270',@branchId = '4681', @user = 'admin',@sAgent ='4672'

*/

CREATE proc [dbo].[proc_SMSData] 
(	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(50)		= NULL
	,@user				VARCHAR(50)		= NULL
	,@branchId			INT				= NULL
	,@sAgent			INT				= NULL
	,@senderMobile		VARCHAR(50)		= NULL
	,@sCountry			VARCHAR(100)	= NULL
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON
	DECLARE @controlNoEncrypted VARCHAR(20), @msg VARCHAR(MAX),@code varchar(10),@length int
	
	select @code = countryMobCode,@length = countryMobLength
	from countryMaster with(nolock) where countryName = @sCountry

	if @code is null or @length is null
		return;

	if len(@senderMobile) <> @length
	begin
		if left(@senderMobile,len(@code)) <> @code
			set @senderMobile = @code+@senderMobile		
	end

	if len(@senderMobile)<> @length
		return;
	
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

	IF OBJECT_ID('tempdb..#TEMP1') IS NOT NULL
	DROP TABLE #TEMP1

	IF OBJECT_ID('tempdb..#letterKeyword') IS NOT NULL
	DROP TABLE #letterKeyword

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
		,#RECEIVER_NAME#		VARCHAR(MAX)
		,#SENDER_NAME#			VARCHAR(MAX)
		,#ACCOUNT_NO#			VARCHAR(MAX)	
	)


	INSERT INTO #TEMP1
	SELECT 
		 #CURRENT_DATE#			= CAST(GETDATE() AS VARCHAR)
		,#SEND_AGENT_NAME#		= ISNULL(sAgentName + ' - ' + sBranchName, '')
		,#SEND_COUNTRY#			= sCountry
		,#TRAN_ID#				= CAST(rt.id AS VARCHAR)
		,#SEND_USER#			= createdBy
		,#PAID_USER#			= ISNULL(paidBy, '')
		,#CANCEL_USER#			= ISNULL(cancelApprovedBy, '')
		,#CONTROL_NO#			= @controlNo
		,#COMPLAIN#				= ''
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
									SELECT CASE WHEN am.agentId = dbo.FNAGetHOAgentId() THEN 'IME Head Office' ELSE pam.agentName END FROM applicationUsers au WITH(NOLOCK) 
									INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId 
									INNER JOIN agentMaster pam WITH(NOLOCK) ON am.parentId = pam.agentId
									WHERE userName = @user
								  )
		,#BRANCH_NAME#			= (
									SELECT am.agentName FROM applicationUsers au WITH(NOLOCK)
									INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
									WHERE userName = @user
									)
		,#RETURN_AMT#			= cAmt - ISNULL(cancelCharge, 0)
		,#RECEIVER_NAME#		= ISNULL(rec.firstName, '') + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
		,#SENDER_NAME#			= ISNULL(sen.firstName, '') + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
		,#ACCOUNT_NO#			= rt.accountNo
	FROM vwRemitTran rt WITH(NOLOCK) inner join vwTranSenders sen with(nolock) on rt.id = sen.tranId
	inner join vwTranReceivers rec with(nolock) on rt.id = rec.tranId
	WHERE controlNo = @controlNoEncrypted


	INSERT INTO #letterKeyWord
	SELECT
		col, VALUE
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
				,t.#RECEIVER_NAME#
				,t.#SENDER_NAME#
				,t.#ACCOUNT_NO#
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
				,#RECEIVER_NAME#
				,#SENDER_NAME#
				,#ACCOUNT_NO#
			)
		) AS unpvt


	SELECT
		@msg = emailFormat
	FROM emailTemplate WITH(NOLOCK) 
	WHERE templateFor = @flag 
	AND ISNULL(isEnabled, 'N') = 'Y' 
	AND ISNULL(isDeleted, 'N') = 'N'
		
	
	DECLARE @totalRows INT, @count INT = 1
	SELECT @totalRows = COUNT(*) FROM #letterKeyword
	WHILE(@count <= @totalRows)
	BEGIN
		SELECT 
			 @msg = REPLACE(@msg, keyword, ISNULL(VALUE, ''))
		FROM #letterKeyword WHERE id = @count	
		SET @count = @count + 1
	END

	insert into SMSQueue(mobileNo,msg,createdDate,createdBy,country,agentId,branchId,controlNo)
	select @senderMobile,@msg,getdate(),@user,@sCountry,@sAgent,@branchId,@controlNoEncrypted

	


	


GO
