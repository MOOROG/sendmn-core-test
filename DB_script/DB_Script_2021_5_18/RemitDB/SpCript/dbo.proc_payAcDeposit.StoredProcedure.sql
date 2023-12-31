USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payAcDeposit]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_payAcDeposit] 	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@accountNo			VARCHAR(30)		= NULL
	,@senderName		VARCHAR(50)		= NULL
	,@receiverName		VARCHAR(50)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@tranIds			VARCHAR(MAX)	= NULL
	,@pBranch			INT				= NULL
	,@settlingAgent		INT				= NULL
	,@bankId			INT				= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
	,@tranNos			VARCHAR(MAX)	= NULL
AS

/*

EXEC proc_payAcDeposit @flag = 's'  ,@pageNumber='1', @pageSize='10', @sortBy='controlNo', @sortOrder='ASC', @user = 'admin'
*/
	DECLARE 
		 @select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)

	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE 
		 @controlNoEncrypted	VARCHAR(100)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	
	SELECT @pageSize = 1000, @pageNumber = 1


IF @flag = 's'				--Select Transaction with payment type AC Deposit
BEGIN
	SET @table = '(
				SELECT 
					 trn.id
					,controlNo = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.FNADecryptString(trn.controlNo) + '''''')">'' + dbo.FNADecryptString(trn.controlNo) + ''</a>''
					--,controlNo = dbo.FNADecryptString(trn.controlNo)
					,trn.accountNo
					,bankName = ISNULL(trn.pBankName,trn.pAgentName)
					,pBranchName = ISNULL(trn.pBankBranchName,trn.pBranchName)
					,trn.pAmt
					,trn.payoutCurr
					,rCustomerId = rec.customerId
					,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,rCountryName = rec.country
					,rStateName = rec.state
					,rCity = rec.city
					,rAddress = rec.address
					,tranDate = trn.approvedDate
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				WHERE trn.tranStatus = ''Payment'' 
					AND trn.payStatus = ''Unpaid'' 
					AND trn.paymentMethod = ''Bank Deposit''					
			'
			--AND pBranch = ' + CAST(@pBranch AS VARCHAR) + '
	SET @sql_filter = ''
	
	IF @bankId IS NOT NULL
		SET @table = @table + ' AND pAgent = ' + CAST(@bankId AS VARCHAR) + ''
		
	IF @pBranch IS NOT NULL
		SET @table = @table + ' AND pBranch = ' + CAST(@pBranch AS VARCHAR) + ''
	
	IF @controlNo IS NOT NULL
		SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 
	
	IF @accountNo IS NOT NULL
		SET @table = @table + ' AND trn.accountNo = ''' + @accountNo + '''' 
	
	IF @receiverName IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND receiverName LIKE ''%' + @receiverName + '%''' 
		
	SET @select_field_list ='
				 id
				,controlNo
				,accountNo
				,bankName
				,pBranchName
				,pAmt
				,payoutCurr
				,rCustomerId
				,receiverName
				,rCountryName
				,rStateName
				,rCity
				,rAddress	
				,tranDate			
			   '
	SET @table = @table + ') x'
			
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

ELSE IF @flag = 'payIntl'
BEGIN
	DECLARE @txn TABLE(id INT IDENTITY(1,1),tranNo VARCHAR(50))
	DECLARE @script VARCHAR(MAX)
	
	IF NOT EXISTS(SELECT 'X' FROM @txn)
	BEGIN
		EXEC proc_errorHandler 0, 'No Transaction to post', NULL
		RETURN
	END
	
	EXEC proc_errorHandler 0, 'Transaction(s) paid successfully', NULL
END

ELSE IF @flag = 'u'
BEGIN
	DECLARE @sql VARCHAR(MAX)
	DECLARE 
			 @tranId					INT
			,@rowId						INT
			,@totalRow					INT
			,@sBranch					INT
			,@pSuperAgent				INT
			,@sCountry					VARCHAR(100)
			,@sLocation					INT
			,@pHubComm MONEY, @pHubCommCurrency	VARCHAR(3), @pSuperAgentComm MONEY, @pSuperAgentCommCurrency VARCHAR(3), @pAgentComm MONEY, @pAgentCommCurrency	VARCHAR(3)
			,@pCountry VARCHAR(100), @pCountryId INT, @pLocation INT
			,@deliveryMethod VARCHAR(50), @deliveryMethodId	INT
			,@collCurr VARCHAR(3), @tAmt MONEY, @cAmt MONEY, @pAmt MONEY, @payoutCurr VARCHAR(3), @serviceCharge MONEY 
	IF(@tranIds IS NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction(s) not found', NULL
		RETURN
	END
	CREATE TABLE #tempTran(rowId INT IDENTITY(1,1), tranId INT)
	SET @sql = '
					INSERT INTO #tempTran(tranId)
					SELECT id FROM remitTran WHERE id IN (' + @tranIds + ')
				'
	EXEC(@sql)
		
	SET @rowId = 1
	SELECT @totalRow = COUNT(rowId) FROM #tempTran
	WHILE (@rowId <= @totalRow)
	BEGIN
		SELECT @tranId = tranId FROM #tempTran WHERE rowId = @rowId
		SELECT 
			 @sBranch			= trn.sBranch
			,@sCountry			= trn.sCountry
			,@sLocation			= sb.agentLocation
			,@pSuperAgent		= trn.pSuperAgent
			,@pCountryId		= cm.countryId
			,@pLocation			= trn.pLocation
			,@pBranch			= trn.pBranch
			,@deliveryMethodId	= dm.serviceTypeId
			,@tAmt				= trn.tAmt
			,@cAmt				= trn.cAmt
			,@pAmt				= trn.pAmt
			,@serviceCharge		= trn.serviceCharge
			,@payoutCurr		= trn.payoutCurr
		FROM remitTran trn WITH(NOLOCK)
		LEFT JOIN agentMaster sb WITH(NOLOCK) ON trn.sBranch = sb.agentId
		LEFT JOIN countryMaster cm WITH(NOLOCK) ON trn.pCountry = cm.countryName
		LEFT JOIN serviceTypeMaster dm WITH(NOLOCK) ON trn.paymentMethod = dm.typeTitle
		WHERE id = @tranId
		
		--Commission Calculation Starts---------------------------------
		IF @sCountry = 'Nepal'
		BEGIN
			SELECT
				 @pAgentComm		= ISNULL(pAgentComm, 0)
				,@pSuperAgentComm	= ISNULL(psAgentComm, 0)
			FROM dbo.FNAGetDomesticPayComm(@sBranch, @pBranch, @deliveryMethodId, @tAmt)
		
			SELECT @pAgentCommCurrency = 'NPR', @pSuperAgentCommCurrency = 'NPR'
		END
		ELSE
		BEGIN
			SELECT @pSuperAgentComm = amount, @pSuperAgentCommCurrency = commissionCurrency FROM dbo.FNAGetPayCommSA(@sBranch, NULL, @sLocation, @pSuperAgent, @pCountryId, @pLocation, @pBranch, @payoutCurr, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @pHubComm, 0)
			
			SELECT @pAgentComm = amount, @pAgentCommCurrency = commissionCurrency FROM dbo.FNAGetPayComm(@sBranch, NULL, @sLocation, @pSuperAgent, @pCountryId, @pLocation, @pBranch, @payoutCurr, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @pHubComm, @pSuperAgentComm)
		END
		--Commission Calculation Ends-----------------------------------
		UPDATE remitTran SET
			 pHubComm					= @pHubComm
			,pHubCommCurrency			= @pHubCommCurrency
			,pSuperAgentComm			= @pSuperAgentComm
			,pSuperAgentCommCurrency	= @pSuperAgentCommCurrency
			,pAgentComm					= @pAgentComm
			,pAgentCommCurrency			= @pAgentCommCurrency
			,tranStatus					= 'Paid'
			,payStatus					= 'Paid'
			,paidBy						= @user
			,paidDate					= GETDATE()
			,paidDateLocal				= dbo.FNADateFormatTZ(GETDATE(), @user)
		WHERE id = @tranId
		
		SELECT @settlingAgent = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		--EXEC proc_updateTopUpLimit @settlingAgent, @pAmt
		
		SET @rowId = @rowId + 1
	END
	
	/*
	-- ### inserting txn view history
	INSERT INTO tranViewHistory (		 
		 tranViewType
		,createdBy
		,createdDate
		,tranId
		,remarks
	)
	SELECT		 
		'PAY'
		,@user
		,GETDATE()
		,value
		,'ADM: PAY A/C DEPOSIT TXN' from  dbo.Split(',',@tranIds)
		
	*/
	EXEC proc_errorHandler 0, 'Transaction(s) paid successfully', NULL
END

GO
