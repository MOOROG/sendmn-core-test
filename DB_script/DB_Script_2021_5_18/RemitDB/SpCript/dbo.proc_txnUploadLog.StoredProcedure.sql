USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnUploadLog]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_txnUploadLog]
	 @flag					VARCHAR(50)	= NULL
	,@user					VARCHAR(50)	= NULL
	,@logId					BIGINT		= NULL
	,@uploadedDateFrom		DATETIME	= NULL
	,@uploadedDateTo		DATETIME	= NULL
	,@uploadedBy			VARCHAR(50)	= NULL
	,@agentId				INT			= NULL
	,@agentName				VARCHAR(100)= NULL
	,@branchName			VARCHAR(100)= NULL
	,@sortBy                VARCHAR(50)	= NULL
	,@sortOrder             VARCHAR(5)	= NULL
	,@pageSize              INT			= NULL
	,@pageNumber            INT			= NULL
AS
SET NOCOUNT ON
DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)

DECLARE @receivingMode VARCHAR(100)
		
IF @flag = 's'
BEGIN
	IF @sortBy IS NULL
		SET @sortBy = 'logId'
	IF @sortOrder IS NULL
		SET @sortOrder = 'DESC'

	SET @table = '(
			SELECT  
				 main.logId
				,agentName = main.pAgentName
				,branchName = main.pBranchName
				,main.logType
				,main.receivingMode
				,main.uploadedBy
				,main.uploadedDate
			FROM txnUploadLog main WITH(NOLOCK)
			WHERE 1=1
				) x'

	SET @sql_filter = ''
	
	IF @logId IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND logId = ''' + CAST(@logId AS VARCHAR) + ''''
	
	IF @agentName IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND agentName LIKE ''' + @agentName + '%'''
	
	IF @branchName IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND branchName LIKE ''' + @branchName + '%'''
	
	IF @uploadedBy IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND uploadedBy = ''' + @uploadedBy + ''''
	
	IF @uploadedDateFrom IS NOT NULL AND @uploadedDateTo IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND uploadedDate BETWEEN ''' + CONVERT(VARCHAR,@uploadedDateFrom,101) + ''' AND ''' + CONVERT(VARCHAR,@uploadedDateFrom,101) + ' 23:59:59'''
	
	SET @select_field_list ='
		 logId
		,agentName
		,branchName
		,logType
		,receivingMode
		,uploadedBy
		,uploadedDate
		'

	EXEC dbo.proc_paging
		@table
		,@sql_filter
		,@select_field_list
		,@extra_field_list
		,@sortBy
		,@sortOrder
		,@pageSize
		,@pageNumber
END

ELSE IF @flag = 'uploadedTxnList'
BEGIN
	--Successful Transaction----------------------------------------------------------------------------------------------------
	SELECT @receivingMode = receivingMode FROM txnUploadLog WITH(NOLOCK) WHERE logId = @logId
	IF @receivingMode = 'Bank Deposit'
	BEGIN
		SELECT 
			 [ICN]					= dbo.FNADecryptString(controlNo)
			,[Branch]				= ISNULL(rt.pBankBranchName, rt.pBranchName)
			,[Sender Name]			= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]		= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Bank A/C No.]			= rt.accountNo
			,[Total Amount]			= rt.pAmt
			,[Paid Date]			= rt.paidDate
			,[Paid By]				= rt.paidBy
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE uploadLogId = @logId
		
		RETURN
	END
	
	ELSE IF @receivingMode = 'Account Deposit to other bank'
	BEGIN
		SELECT 
			 [ICN]					= dbo.FNADecryptString(controlNo)
			,[Ext. Bank]			= ISNULL(rt.pBankName, rt.pAgentName)
			,[Ext. Branch]			= ISNULL(rt.pBankBranchName, rt.pBranchName)
			,[Sender Name]			= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]		= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Bank A/C No.]			= rt.accountNo
			,[Total Amount]			= rt.pAmt
			,[Paid Date]			= rt.paidDate
			,[Paid By]				= rt.paidBy
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE uploadLogId = @logId
		
		RETURN
	END
	
	ELSE IF @receivingMode = 'Agri Bank Cash Pay'
	BEGIN
		SELECT 
			 [ICN]					= dbo.FNADecryptString(controlNo)
			,[Branch]				= ISNULL(rt.pBankBranchName, rt.pBranchName)
			,[Sender Name]			= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]		= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Receiver Contact No.]	= ISNULL(rec.mobile, '') + ISNULL('/' + rec.homePhone, '')
			,[Total Amount]			= rt.pAmt
			,[Paid Date]			= rt.paidDate
			,[Paid By]				= rt.paidBy
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE uploadLogId = @logId
		
		RETURN
	END
	
	ELSE IF @receivingMode = 'Door to Door'
	BEGIN
		SELECT 
			 [ICN]					= dbo.FNADecryptString(controlNo)
			,[Branch]				= ISNULL(rt.pBankBranchName, rt.pBranchName)
			,[Sender Name]			= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]		= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Receiver Contact No.]	= ISNULL(rec.mobile, '') + ISNULL('/' + rec.homePhone, '')
			,[Receiver Address]		= rec.[address]
			,[Total Amount]			= rt.pAmt
			,[Paid Date]			= rt.paidDate
			,[Paid By]				= rt.paidBy
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE uploadLogId = @logId
		
		RETURN
	END
	
	ELSE IF @receivingMode = 'Cash Payment to Other Bank'
	BEGIN
		SELECT 
			 [ICN]					= dbo.FNADecryptString(controlNo)
			,[Ext. Bank]			= isnull(rt.pBankName, rt.pAgentName)
			,[Ext. Branch]			= isnull(rt.pBankBranchName, rt.pBranchName)
			,[Sender Name]			= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]		= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			--,[Receiver Name]		= '<b>' + rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '') + '</b>'
			--							+ '<br/>[Contact No.: ' + ISNULL(rec.mobile, '') + ISNULL('/' + rec.homePhone, '') + ISNULL('<br/>' + rec.idType, '') + ISNULL(' : ' + rec.idNumber, '') + ']'
			,[Receiver Contact No.]	= ISNULL(rec.homePhone, '') + ISNULL('/' + rec.mobile, '')
			,[Receiver ID]			= ISNULL(rec.idType, '') + ISNULL(' : ' + rec.idNumber, '')
			,[Total Amount]			= rt.pAmt
			,[Paid Date]			= rt.paidDate
			,[Paid By]				= rt.paidBy
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE uploadLogId = @logId
		
		RETURN
		--''<b>'' + actrn.ReceiverName + ''</b>'' + ''<br/>[Contact No.: '' + ISNULL(actrn.receiverPhone, '''') + ISNULL(''/'' + actrn.receiver_mobile, '''') + ISNULL(''<br/>'' + receiverIDDescription, '''') + ISNULL('' : '' + receiverID, '''') + '']''
	END
	
	ELSE IF @receivingMode = 'Cash Payment'
	BEGIN
		SELECT 
			 [ICN]					= dbo.FNADecryptString(controlNo)
			,[Branch]				= ISNULL(rt.pBankBranchName, rt.pBranchName)
			,[Sender Name]			= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, '')
			,[Receiver Name]		= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
			,[Receiver Contact No.]	= ISNULL(rec.mobile, '') + ISNULL('/' + rec.homePhone, '')
			,[Total Amount]			= rt.pAmt
			,[Paid Date]			= rt.paidDate
			,[Paid By]				= rt.paidBy
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE uploadLogId = @logId
		
		RETURN
	END
	
	SELECT
		 rt.controlNo
		,sFirstName = sen.firstName, sMiddleName = sen.middleName, sLastName1 = sen.lastName1, sLastName2 = sen.lastName2
		,rFirstName = rec.firstName, rMiddleName = rec.middleName, rLastName1 = rec.lastName1, rLastName2 = rec.lastName2
		,pAmt
		,tranStatus
	INTO #tempTrn
	FROM remitTran rt WITH(NOLOCK)
	INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	WHERE uploadLogId = @logId
	
	SELECT 
			 [ICN]				= dbo.FNADecryptString(controlNo)
			,[Sender Name]		= sFirstName + ISNULL(' ' + sMiddleName, '') + ISNULL(' ' + sLastName1, '') + ISNULL(' ' + sLastName2, '')
			,[Receiver Name]	= rFirstName + ISNULL(' ' + rMiddleName, '') + ISNULL(' ' + rLastName1, '') + ISNULL(' ' + rLastName2, '')
			,[Payout Amount]	= pAmt
			,[Status]			= tranStatus
	FROM #tempTrn
	
	--Unsuccessful Transaction--------------------------------------------------------------------------------------------------
	DECLARE @dataList TABLE(
		 id					INT IDENTITY(1,1)
		,controlNoEncrypted VARCHAR(20)
		,controlNo			VARCHAR(20)
		,Amount				VARCHAR(20)
		,[Status]			VARCHAR(300)
		,errorCode			INT
	)
	DECLARE @xml XML
	SELECT @xml = xmlErrorData FROM txnUploadLog WITH(NOLOCK) WHERE logId = @logId
	IF @xml IS NULL
		RETURN
	INSERT @dataList
	SELECT	
		 dbo.FNAEncryptString(p.value('@controlno','VARCHAR(20)') )as ControlnoEnc	
		,p.value('@controlno','VARCHAR(20)') as ControlNo		
		,p.value('@amount','VARCHAR(20)')as Amount 
		,p.value('@status','VARCHAR(300)') as [status]
		,NULL
	FROM @xml.nodes('/root/row') as tmp(p)
	
	SELECT  
		 [ICN]				= controlNo
		,[Amount]			= CASE WHEN Amount = '' THEN '0' ELSE Amount END
		,[Status]			= [status]
	FROM @dataList
END

GO
