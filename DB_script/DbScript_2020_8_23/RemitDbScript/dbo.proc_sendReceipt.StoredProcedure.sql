USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendReceipt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_sendReceipt] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@tranId			VARCHAR(30)		= NULL
	,@msgType			CHAR(1)			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS
	DECLARE @controlNoEncrypted	VARCHAR(20),@tranStatus VARCHAR(20),@agentId INT
	
	DECLARE  @headMsg				NVARCHAR(MAX)
			,@commonMsg				NVARCHAR(MAX)
			,@countrySpecificMsg	NVARCHAR(MAX)			
			,@sAgent				INT
			,@sCountry				INT
			,@sUser					VARCHAR(50)
			,@sUserFullName			VARCHAR(75)	
			,@customerId			INT	
			,@bonusPointPending		MONEY
			,@bonusPoint			MONEY
			,@bonusSchemeId			INT

	IF @controlNo IS NOT NULL
	BEGIN
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(@controlNo))
		SELECT @tranId = holdTranId FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	END

	IF @tranId IS NOT NULL
	BEGIN
		IF ISNUMERIC(@tranId) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Transaction ID', NULL
			RETURN
		END
		SELECT @controlNoEncrypted = controlNo FROM vwRemitTran WITH(NOLOCK) WHERE holdTranId = @tranId OR id = @tranId
		SET @controlNo = dbo.FNADecryptString(@controlNoEncrypted)
	END

	

--## Check Transaction Control No
IF @flag = 'c'			
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND ISNULL(tranType, 'D') = 'D')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found', @controlNoEncrypted
		RETURN
	END
	
	SELECT @tranStatus = tranStatus FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF @tranStatus = 'Cancel'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found', @controlNoEncrypted
		RETURN
	END
	IF @tranStatus = 'Block'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is blocked. Please Contact Head Office.', @controlNoEncrypted
		RETURN
	END

	SELECT @agentId = agentId FROM applicationUsers WHERE userName = @user
	IF @agentId = dbo.FNAGetHOAgentId()
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNoEncrypted
		RETURN
	END
	
	IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND (sBranch = (SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user)))
	BEGIN
		EXEC proc_errorHandler 1, 'You are not authorized to view this transaction', @controlNoEncrypted
		RETURN
	END
	EXEC proc_errorHandler 0, 'Transaction Found', @controlNoEncrypted
END

--## transaction information for receipt
IF @flag = 'receipt' 
BEGIN	
	SELECT 
		 @sAgent = sBranch
		,@sUser = createdBy 
		,@customerId = sen.customerId
	FROM remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId 
	WHERE controlNo = @controlNoEncrypted

	SELECT @bonusSchemeId = bonusSchemeId 
	FROM bonusOperationSetup 
	WHERE GETDATE() BETWEEN schemeStartDate AND schemeEndDate
	AND isnull(isActive,'N') = 'Y'

	IF @bonusSchemeId is not null and @customerId is not null
	SELECT 
			@bonusPointPending= bonusPointPending,
			@bonusPoint=isnull(bonusPoint,0) 
	FROM customerMaster WITH (NOLOCK)
	where isnull(isDeleted,'N') <> 'Y' 
		and customerId = @customerId

	SELECT 
		 tranId = trn.id
		,controlNo = dbo.FNADecryptString(trn.controlNo)	

		,sMemId = sen.membershipId
		,senderName = UPPER(sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, ''))
		,sCountryName = sen.country
		,sAddress = sen.address
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		,sIdType = ISNULL(sdv.detailTitle,sen.idType)
		,sIdNo = sen.idNumber
		,sEmail = sen.email
		
		--Receiver Information
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,receiverName = UPPER(rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, ''))
		,rCountryName = rec.country
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = rec.idType
		,rIdNo = rec.idNumber
		,relWithSender = trn.relWithSender
		

		,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN trn.sSuperAgentName ELSE trn.sAgentName END
		,sBranchName = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		,sAgentLocation = sLoc.districtName
	
		,sAgentAddress = sa.agentAddress
		,agentPhone1 = sa.agentPhone1	

		,pAgentCountry = trn.pCountry
		,pAgentDistrict = trn.pDistrict
		,pAgentLocation = pLoc.districtName
		
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,trn.cAmt
		,trn.pAmt
		,trn.paymentMethod
		
		,relationship = ISNULL(trn.relWithSender, '-')
		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,collMode = trn.collMode
		,trn.collCurr
		,trn.accountNo
		,branchName = trn.pBankBranchName
		,bankName = trn.pBankName
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,trn.tranStatus
		,trn.payStatus
		,payoutMsg = isnull(trn.pMessage,'')
		,trn.createdBy
		,trn.createdDate
		,trn.approvedBy
		,trn.approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.payTokenId
		,pendingBonus = isnull(cast(@bonusPointPending as varchar),'')
		,earnedBonus = isnull(cast(@bonusPoint as varchar),'')
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)
	WHERE trn.controlNo = @controlNoEncrypted 
	
	-->> 6.Message
	
	SELECT
		@sUserFullName = firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '')
	FROM applicationUsers WHERE userName = @sUser
	
	SELECT @sCountry = countryId FROM countryMaster WITH(NOLOCK) 
		WHERE countryName = (SELECT agentCountry FROM agentMaster WHERE agentId = @sAgent)
	
	--Head Message
	SELECT @headMsg = headMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@headMsg IS NULL)
		SELECT @headMsg = headMsg FROM message WHERE countryId IS NULL AND headMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
		
	--Common Message
	SELECT @commonMsg = commonMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') <> 'Y'
	IF(@commonMsg IS NULL)
		SELECT @commonMsg = commonMsg FROM message WHERE countryId IS NULL AND commonMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	--Country Specific Message
	SELECT @countrySpecificMsg = countrySpecificMsg FROM message WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@countrySpecificMsg IS NULL)
		SELECT @countrySpecificMsg = countrySpecificMsg FROM message WHERE countryId IS NULL AND countrySpecificMsg IS NOT NULL AND msgType = @msgType AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	SELECT @headMsg AS headMsg,@commonMsg AS commonMsg, @countrySpecificMsg AS countrySpecificMsg, @sUserFullName AS sUserFullName
END

--## transaction information for fee receipt
IF @flag = 'receiptFeeCollection' 
BEGIN	
	SELECT 
		 @sAgent = sBranch
		,@sUser = createdBy 
		,@customerId = sen.customerId
	FROM remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId 
	WHERE controlNo = @controlNoEncrypted

	SELECT @bonusSchemeId = bonusSchemeId 
	FROM bonusOperationSetup 
	WHERE GETDATE() BETWEEN schemeStartDate AND schemeEndDate
	AND isnull(isActive,'N') = 'Y'

	IF @bonusSchemeId is not null and @customerId is not null
	SELECT 
			@bonusPointPending= bonusPointPending,
			@bonusPoint=isnull(bonusPoint,0) 
	FROM customerMaster WITH (NOLOCK)
	where isnull(isDeleted,'N') <> 'Y' 
		and customerId = @customerId
	SELECT 
		 tranId = trn.id
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		
		--## Sender Information
		,sMemId = sen.membershipId
		,senderName = UPPER(sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, ''))
		,sCountryName = sen.country
		,sAddress = sen.address
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		,sIdType = ISNULL(sdv.detailTitle,sen.idType)
		,sIdNo = sen.idNumber
		,sEmail = sen.email
		--## Receiver Information
		,receiverName = sMas.name
		,rCountryName = sMas.country
		,rAddress = sMas.address
		,rContactNo = sMas.contactNo	
		
		--## student Information	
		,stdName = rec.stdName
		,stdLevel = lvl.name
		,stdRollRegNo = rec.stdRollRegNo
		,stdSemYr = rec.stdSemYr
		,stdFeeType = fee.feeType
		,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN trn.sSuperAgentName ELSE trn.sAgentName END
		,sBranchName = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		,sAgentLocation = sLoc.districtName
	
		,sAgentAddress = sa.agentAddress
		,agentPhone1 = sa.agentPhone1	

		,pAgentCountry = trn.pCountry
		,pAgentDistrict = trn.pDistrict
		,pAgentLocation = pLoc.districtName
		
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,trn.cAmt
		,trn.pAmt
		,trn.paymentMethod
		
		,relationship = ISNULL(trn.relWithSender, '-')
		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,collMode = trn.collMode
		,trn.collCurr
		
		,accountNo=sMas.accountNo
		,branchName = BRANCH.agentAddress
		,bankName = BANK.agentName
		,paymentMethod = trn.paymentMethod
		
		,trn.payoutCurr
		,trn.tranStatus
		,trn.payStatus
		,payoutMsg = isnull(trn.pMessage,'')
		,trn.createdBy
		,trn.createdDate
		,trn.approvedBy
		,trn.approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.payTokenId
		,pendingBonus = isnull(cast(@bonusPointPending as varchar),'')
		,earnedBonus = isnull(cast(@bonusPoint as varchar),'')
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN schoolMaster sMas	WITH(NOLOCK) ON sMas.rowId = rec.stdCollegeId
	LEFT JOIN schoolLevel lvl with(nolock) on lvl.rowId=rec.stdLevel
	LEFT JOIN agentMaster BANK WITH(NOLOCK) ON BANK.agentId=sMas.bankId
	LEFT JOIN agentMaster BRANCH WITH(NOLOCK) ON BRANCH.agentId=sMas.bankBranchId
	LEFT JOIN schoolFee fee with(nolock) on fee.rowId=rec.feeTypeId
	LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)
	WHERE trn.controlNo = @controlNoEncrypted 	

END

--## Check Internation send Transaction Control No
IF @flag = 'checkInt'			
BEGIN	
	declare @sBranch int,@userType varchar(20),@parentId int
	SELECT @tranStatus = tranStatus,@sAgent = sAgent,@sBranch = sBranch FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF @tranStatus IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found', @controlNo
		RETURN
	END
	IF @tranStatus = 'Cancel'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is cancelled', @controlNo
		RETURN
	END
	IF @tranStatus = 'Block'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is blocked. Please Contact Head Office.', @controlNo
		RETURN
	END

	SELECT @agentId = au.agentId,
		@userType = userType,
		@parentId = am.parentId 
	FROM applicationUsers au WITH(NOLOCK) inner join agentMaster am with(nolock) ON au.agentId = am.agentId WHERE userName = @user

	IF @agentId = dbo.FNAGetHOAgentId()
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNo
		RETURN
	END

	if @sBranch = @agentId
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNo
		RETURN
	END

	if @sAgent = @parentId and @userType = 'AH'
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNo
		RETURN
	END
	EXEC proc_errorHandler 1, 'Transaction not found', @controlNo
END




GO
