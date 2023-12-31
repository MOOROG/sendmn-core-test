USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_approveTran]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM remitTran
EXEC proc_cancelTran @flag = 'details', @user = 'shree_b1', @tranId = '1', @controlNo = '91885218404'

*/

CREATE proc [dbo].[proc_approveTran] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(20)		= NULL
	,@tranId			INT				= NULL	
	,@sCountry			INT				= NULL
	,@sFirstName		VARCHAR(30)		= NULL
	,@sMiddleName		VARCHAR(30)		= NULL
	,@sLastName1		VARCHAR(30)		= NULL
	,@sLastName2		VARCHAR(30)		= NULL
	,@sMemId			VARCHAR(30)		= NULL
	,@sId				BIGINT			= NULL	
	,@sTranId			VARCHAR(50)		= NULL	
	,@rCountry			INT				= NULL
	,@rFirstName		VARCHAR(30)		= NULL
	,@rMiddleName		VARCHAR(30)		= NULL
	,@rLastName1		VARCHAR(30)		= NULL
	,@rLastName2		VARCHAR(30)		= NULL
	,@rMemId			VARCHAR(30)		= NULL
	,@rId				BIGINT			= NULL
	,@pCountry			INT				= NULL
	
	,@customerId		INT				= NULL
	,@agentId			INT				= NULL
	,@senderId			INT				= NULL
	,@benId				INT				= NULL
	,@cancelReason		VARCHAR(200)	= NULL
	,@cAmt				MONEY			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

SET NOCOUNT ON
SET XACT_ABORT ON

SELECT @pageSize = 1000, @pageNumber = 1
	
	DECLARE @sBranch INT
	
	DECLARE @controlNoEncrypted		VARCHAR(100)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

IF @flag = 'approve'
BEGIN
	--Check if the approver is the same user who sent transaction
	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND createdBy = @user)
	BEGIN
		EXEC proc_errorHandler 1, 'Process denied for same user', @controlNoEncrypted
		RETURN	
	END
	DECLARE @tranStatus VARCHAR(20) = NULL
	SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	SELECT @tranStatus = tranStatus, @cAmt = cAmt FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF @sBranch <> dbo.FNAGetHOAgentId() --Head Office
	BEGIN
		IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch <> @sBranch)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
			RETURN
		END
	END
	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Payment')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been approved and ready for payment', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Paid')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is already been paid', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is cancelled', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Lock')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is locked. Please Contact HO', @controlNoEncrypted
		RETURN
	END
	DECLARE @userId INT, @sendPerTxn MONEY, @sendPerDay MONEY, @sendTodays MONEY
	SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
	SELECT @sendPerDay = sendPerDay, @sendPerTxn = sendPerTxn, @sendTodays = ISNULL(sendTodays, 0) FROM userWiseTxnLimit WITH(NOLOCK) WHERE userId = @userId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
	IF(@cAmt > @sendPerTxn)
	BEGIN
		EXEC proc_errorHandler 1, 'Transfer Amount exceeds user per transaction limit.', @controlNoEncrypted
		RETURN
	END
	IF(@sendTodays > @sendPerDay)
	BEGIN
		EXEC proc_errorHandler 1, 'User Per Day Transaction Limit exceeded.', @controlNoEncrypted
		RETURN
	END
	BEGIN TRANSACTION
		UPDATE remitTran SET
			  tranStatus				= 'Payment'					--Payment
			 ,approvedBy				= @user
			 ,approvedDate				= GETDATE()
			 ,approvedDateLocal			= DBO.FNADateFormatTZ(GETDATE(), @user)
		WHERE controlNo = @controlNoEncrypted
		
		UPDATE userWiseTxnLimit SET
			 sendTodays = ISNULL(sendTodays, 0) + @cAmt
		WHERE userId = @userId AND ISNULL(isActive, 'N') = 'Y'
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC proc_errorHandler 0, 'Transaction Approved Successfully', @tranId
END

ELSE IF @flag = 'reject'
	BEGIN
		BEGIN TRANSACTION
			UPDATE remitTran SET
				  tranStatus				= 'Cancel'			--Cancel
				 ,approvedBy				= @user
				 ,approvedDate				= GETDATE()
				 ,approvedDateLocal			= DBO.FNADateFormatTZ(GETDATE(), @user)
			WHERE id = @tranId
		
			--A/C Master
			SELECT @cAmt = cAmt FROM remitTran WHERE id = @tranId
			UPDATE creditLimit SET 
				todaysSent = todaysSent - @cAmt 
			
			WHERE agentId = (
				SELECT parentId FROM agentMaster WHERE agentId = (
					SELECT agentId FROM applicationUsers WHERE userName = @user
					)
				)
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		EXEC [proc_errorHandler] 0, 'Transaction cancelled successfully', @tranId	
	END	
	
ELSE IF @flag = 'details'
BEGIN
	SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	SELECT @tranStatus = tranStatus FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF (@tranStatus IS NOT NULL)
	BEGIN
		INSERT INTO tranViewHistory(
			 controlNumber
			,tranViewType
			,agentId
			,createdBy
			,createdDate
		)
		SELECT
			 @controlNoEncrypted
			,'A'
			,@sBranch
			,@user
			,GETDATE()
	END
	ELSE
	BEGIN
		EXEC proc_errorHandler 1000, 'No Transaction Found', @controlNoEncrypted
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch <> @sBranch)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Payment')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction already been approved and ready for payment', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Paid')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is already been paid', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is cancelled', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Lock')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is locked. Please Contact HO', @controlNoEncrypted
		RETURN
	END
	EXEC proc_errorHandler 0, 'Transaction Found', @controlNoEncrypted
	
	SELECT 
		 trn.id
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		,sMemId = sen.membershipId
		,sCustomerId = sen.customerId
		,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = sen.country
		,sStateName = sen.state
		,sDistrict = sen.district
		,sCity = sen.city
		,sAddress = sen.address
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		
		,sIdType = sen.idType
		,sIdNo = sen.idNumber
		,sValidDate = sen.validDate
		,sEmail = sen.email
		
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,rCountryName = rec.country
		,rStateName = rec.state
		,rDistrict = rec.district
		,rCity = rec.city
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = rec.idType
		,rIdNo = rec.idNumber
		
		,sBranchName = trn.sBranchName
		,sAgentName = CASE WHEN trn.sAgent = trn.sBranch THEN trn.sSuperAgentName ELSE trn.sAgentName END
		,sAgentLocation = sLoc.districtName
		,sAgentDistrict = sa.agentDistrict
		,sAgentCity = sa.agentCity
		,sAgentCountry = sa.agentCountry
		
		,pAgentName = CASE WHEN trn.pAgentName = trn.pBranchName THEN trn.pSuperAgentName ELSE trn.pAgentName END
		,pBranchName = trn.pBranchName
		,pAgentCountry = trn.pCountry
		,pAgentState = trn.pState
		,pAgentDistrict = trn.pDistrict
		,pAgentLocation = pLoc.districtName
		,pAgentCity = pa.agentCity
		,pAgentAddress = pa.agentAddress
		
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,trn.cAmt
		,trn.pAmt
		
		,relationship = ISNULL(trn.relWithSender, '-')
		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,collMode = trn.collMode
		,trn.collCurr
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,BranchName = trn.pBankBranchName
		,trn.accountNo
		,BankName = trn.pBankName
		,trn.tranStatus
		,trn.payStatus
		,payoutMsg = ISNULL(trn.pMessage, '-')
		,trn.createdBy
		,trn.createdDate
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	WHERE 
			trn.controlNo = @controlNoEncrypted
			
END

--Load Data For Approve For Agent-----------------------------------------------------------------------------------------
ELSE IF @flag = 's'	
BEGIN
	SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	
	SET @table = '(
				SELECT 
					 trn.id
					,controlNo = dbo.FNADecryptString(trn.controlNo)
					,sCustomerId = sen.customerId
					,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
					,sCountryName = sen.country
					,sStateName = sen.state
					,sCity = sen.city
					,sAddress = sen.address
					,rCustomerId = rec.customerId
					,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,rCountryName = rec.country
					,rStateName = rec.state
					,rCity = rec.city
					,rAddress = rec.address
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				WHERE
					trn.tranStatus = ''Hold'' AND 
					trn.payStatus = ''Unpaid'' AND
					trn.approvedBy IS NULL AND
					(trn.sBranch = ''' + CAST(@sBranch AS VARCHAR) + ''' OR trn.sAgent = ''' + CAST(@sBranch AS VARCHAR) + ''')
	'
	SET @sql_filter = ''
	
	IF @controlNo IS NOT NULL
		SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 
		
	IF @sFirstName IS NOT NULL
		SET @table = @table + ' AND sen.firstName LIKE ''' + @sFirstName + '%'''
		
	IF @sMiddleName IS NOT NULL
		SET @table = @table + ' AND sen.middleName LIKE ''' + @sMiddleName + '%'''
		
	IF @sLastName1 IS NOT NULL
		SET @table = @table + ' AND sen.lastName1 LIKE ''' + @sLastName1 + '%'''
		
	IF @sLastName2 IS NOT NULL
		SET @table = @table + ' AND sen.lastName2 LIKE ''' + @sLastName2 + '%'''
		
	IF @sMemId IS NOT NULL
		SET @table = @table + ' AND sen.membershipId = ' + CAST(@sMemId AS VARCHAR)
			
	IF @rFirstName IS NOT NULL
		SET @table = @table + ' AND rec.firstName LIKE ''' + @rFirstName + '%'''
		
	IF @rMiddleName IS NOT NULL
		SET @table = @table + ' AND rec.middleName LIKE ''' + @rMiddleName + '%'''
		
	IF @rLastName1 IS NOT NULL
		SET @table = @table + ' AND rec.lastName1 LIKE ''' + @rLastName1 + '%'''
		
	IF @rLastName2 IS NOT NULL
		SET @table = @table + ' AND rec.lastName2 LIKE ''' + @rLastName2 + '%'''		
		
	IF @rMemId IS NOT NULL
		SET @table = @table + ' AND c.membershipId = ' + CAST(@rMemId AS VARCHAR)
		
	SET @select_field_list ='
				 id
				,controlNo
				,sCustomerId
				,senderName
				,sCountryName
				,sStateName
				,sCity
				,sAddress
				,rCustomerId
				,receiverName
				,rCountryName
				,rStateName
				,rCity
				,rAddress				
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
----------------------------------------------------------------------------------------------------------------

ELSE IF @flag = 'sho'	
BEGIN
	SET @table = '(
				SELECT 
					 trn.id
					,controlNo = dbo.FNADecryptString(trn.controlNo)
					,sCustomerId = sen.customerId
					,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
					,sCountryName = sen.country
					,sStateName = sen.state
					,sCity = sen.city
					,sAddress = sen.address
					,rCustomerId = rec.customerId
					,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,rCountryName = rec.country
					,rStateName = rec.state
					,rCity = rec.city
					,rAddress = rec.address
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				INNER JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName
				WHERE
					trn.tranStatus = ''Hold'' AND 
					trn.payStatus = ''Unpaid'' AND
					trn.approvedBy IS NULL AND
					au.agentId = dbo.FNAGetHOAgentId()
	'
	SET @sql_filter = ''
	
	IF @controlNo IS NOT NULL
		SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 
		
	if @cAmt=0
	 set @cAmt=null
	IF @cAmt IS NOT NULL 
		SET @table = @table + ' AND trn.cAmt = ''' + CAST(@cAmt AS VARCHAR)+ '''' 
		
	IF @sFirstName IS NOT NULL
		SET @table = @table + ' AND sen.firstName LIKE ''' + @sFirstName + '%'''
		
	IF @sMiddleName IS NOT NULL
		SET @table = @table + ' AND sen.middleName LIKE ''' + @sMiddleName + '%'''
		
	IF @sLastName1 IS NOT NULL
		SET @table = @table + ' AND sen.lastName1 LIKE ''' + @sLastName1 + '%'''
		
	IF @sLastName2 IS NOT NULL
		SET @table = @table + ' AND sen.lastName2 LIKE ''' + @sLastName2 + '%'''
		
	IF @sMemId IS NOT NULL
		SET @table = @table + ' AND sen.membershipId = ' + CAST(@sMemId AS VARCHAR)
			
	IF @rFirstName IS NOT NULL
		SET @table = @table + ' AND rec.firstName LIKE ''' + @rFirstName + '%'''
		
	IF @rMiddleName IS NOT NULL
		SET @table = @table + ' AND rec.middleName LIKE ''' + @rMiddleName + '%'''
		
	IF @rLastName1 IS NOT NULL
		SET @table = @table + ' AND rec.lastName1 LIKE ''' + @rLastName1 + '%'''
		
	IF @rLastName2 IS NOT NULL
		SET @table = @table + ' AND rec.lastName2 LIKE ''' + @rLastName2 + '%'''		
		
	IF @rMemId IS NOT NULL
		SET @table = @table + ' AND c.membershipId = ' + CAST(@rMemId AS VARCHAR)
		
	SET @select_field_list ='
				 id
				,controlNo
				,sCustomerId
				,senderName
				,sCountryName
				,sStateName
				,sCity
				,sAddress
				,rCustomerId
				,receiverName
				,rCountryName
				,rStateName
				,rCity
				,rAddress				
			   '
	SET @table = @table + ') x'
	--select @table
	--return;	
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
----------------------------------------------------------------------------------------------------------------

ELSE IF @flag = 'va'		--Verify Amount
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction not found', NULL
	END
	IF NOT EXISTS(SELECT 'X' FROM remitTran WITh(NOLOCK) WHERE controlNo = @controlNoEncrypted AND cAmt = @cAmt)
	BEGIN
		EXEC proc_errorHandler 1, 'Collection amount doesnot match. Please enter the correct amount', NULL
		RETURN
	END
	EXEC proc_errorHandler 0, 'Success', NULL
END

GO
