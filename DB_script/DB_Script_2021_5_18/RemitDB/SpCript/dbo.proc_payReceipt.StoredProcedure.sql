USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payReceipt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*

EXEC proc_payReceipt @flag = 'receiptLocal', @user = 'admin', 
@controlNo = '91722496166', @msgType = 'P'

*/

CREATE PROC [dbo].[proc_payReceipt] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@msgType			CHAR(1)			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

SET NOCOUNT ON;


DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(@controlNo))

IF @flag = 'receipt' --All transaction information (sender, receiver, payout)
BEGIN

	SELECT * FROM payTranDetail with (nolock)  WHERE controlNo = @controlNoEncrypted
	
	--Message
	DECLARE  @headMsg				NVARCHAR(MAX)
			,@commonMsg				NVARCHAR(MAX)
			,@countrySpecificMsg	NVARCHAR(MAX)
			
			,@pAgent		INT
			,@pCountry		INT
			,@pUser			VARCHAR(50)
			,@pUserFullName	VARCHAR(75)
		
	SELECT 
		 @pAgent = sBranch
		,@pUser = paidBy 
	FROM remitTran with (nolock) WHERE controlNo = @controlNoEncrypted
	
	SELECT
		@pUserFullName = firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '')
	FROM applicationUsers with (nolock) WHERE userName = @pUser
	
	SELECT @pCountry = agentCountry FROM agentMaster with (nolock) WHERE agentId = @pAgent
	
	--Head Message
	SELECT @headMsg = headMsg FROM message with (nolock) WHERE countryId = @pCountry AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@headMsg IS NULL)
		SELECT @headMsg = headMsg FROM message with (nolock) WHERE countryId IS NULL AND headMsg IS NOT NULL AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
		
	--Common Message
	SELECT @commonMsg = commonMsg FROM message with (nolock) WHERE countryId = @pCountry AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@commonMsg IS NULL)
		SELECT @commonMsg = commonMsg FROM message with (nolock) WHERE countryId IS NULL AND commonMsg IS NOT NULL AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	--Country Specific Message
	SELECT @countrySpecificMsg = countrySpecificMsg FROM message with (nolock) WHERE countryId = @pCountry AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@countrySpecificMsg IS NULL)
		SELECT @countrySpecificMsg = countrySpecificMsg FROM message with (nolock) WHERE countryId IS NULL AND countrySpecificMsg IS NOT NULL AND msgType = @msgType AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	SELECT @headMsg AS headMsg,@commonMsg AS commonMsg, @countrySpecificMsg AS countrySpecificMsg, @pUserFullName AS pUserFullName


END

ELSE IF @flag = 'receiptLocal'
BEGIN


	
	   SELECT 
		 tranId = trn.id
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		
		--Sender Information
		,sMemId = sen.membershipId
		,sCustomerId = sen.customerId
		,senderName = UPPER(ISNULL(sen.firstName, '') + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, ''))
		,sCountryName = sen.country
		,sStateName = sen.state
		,sDistrict = sen.district
		,sCity = sen.city
		,sAddress = left(sen.address,50)
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		,sIdType = sen.idType
		,sIdNo = sen.idNumber
		,sValidDate = sen.validDate
		,sEmail = sen.email
		
		--Receiver Information
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,receiverName = UPPER(ISNULL(rec.firstName, '') + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, ''))
		,rCountryName = rec.country
		,rStateName = rec.state
		,rDistrict = rec.district
		,rCity = rec.city
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = rec.idType2
		,rIdNo = rec.idNumber2
		
		--Sending Agent Information
		,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN trn.sSuperAgentName ELSE trn.sAgentName END
		,sBranchName = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		,sAgentState = sa.agentState
		,sAgentDistrict = sa.agentDistrict
		,sAgentLocation = sLoc.districtName
		,sAgentCity = sa.agentCity
		,sAgentAddress = sa.agentAddress
		
		--Payout Agent Information
		,pAgentName = CASE WHEN trn.pAgentName = trn.pBranchName THEN trn.pSuperAgentName ELSE trn.pAgentName END
		,pBranchName = trn.pBranchName
		,pAgentCountry = trn.pCountry
		--,pAgentState = trn.pState
		,pAgentDistrict = trn.pDistrict
		,pAgentLocation = pLoc.districtName
		,pAgentPhone = pa.companyPhone1
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
		,trn.tranStatus
		,trn.payStatus
		,payoutMsg = ISNULL(trn.pMessage, '-')
		,trn.createdBy
		,trn.createdDate
		,trn.approvedBy
		,trn.approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.payTokenId
		,rec.chequeNo
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	WHERE trn.controlNo = @controlNoEncrypted


----------------------------- MESSAGE ----------------------------------------------------------
	SELECT @pUser = paidBy FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	SELECT
		@pUserFullName = firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '')
	FROM applicationUsers WITH(NOLOCK) WHERE userName = @pUser
	
	SELECT @pCountry = countryId FROM countryMaster WITH(NOLOCK)
		WHERE countryName = (SELECT agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent)
	
	--Head Message
	SELECT @headMsg = headMsg FROM [message] WITH(NOLOCK) WHERE countryId = @pCountry AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@headMsg IS NULL)
		SELECT @headMsg = headMsg FROM [message] WITH(NOLOCK) WHERE countryId IS NULL AND headMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
		
	--Common Message
	SELECT @commonMsg = commonMsg FROM [message] WITH(NOLOCK) WHERE countryId = @pCountry AND ISNULL(isDeleted, 'N') <> 'Y'
	IF(@commonMsg IS NULL)
		SELECT @commonMsg = commonMsg FROM [message] WITH(NOLOCK) WHERE countryId IS NULL AND commonMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	--Country Specific Message
	SELECT @countrySpecificMsg = countrySpecificMsg FROM [message] WITH(NOLOCK) WHERE countryId = @pCountry AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@countrySpecificMsg IS NULL)
		SELECT @countrySpecificMsg = countrySpecificMsg FROM [message] WITH(NOLOCK) WHERE countryId IS NULL AND countrySpecificMsg IS NOT NULL AND msgType = @msgType AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	SELECT @headMsg AS headMsg,@commonMsg AS commonMsg, @countrySpecificMsg AS countrySpecificMsg, @pUserFullName AS pUserFullName
END

ELSE IF @flag = 'c'			--Check Transaction Control No
BEGIN

	IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) 
		WHERE controlNo = @controlNoEncrypted 
			AND payStatus = 'Paid' 
			AND ISNULL(tranType, 'D') = 'D')
	BEGIN
		EXEC proc_errorHandler 1, 'Paid Transaction Not Found', @controlNoEncrypted
		RETURN
	END
	
	DECLARE @agentId INT
	SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	IF @agentId = dbo.FNAGetHOAgentId()
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNoEncrypted
		RETURN
	END
	
	SELECT @pAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
	
	IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND (pAgent = @pAgent OR pBranch = @agentId))
	BEGIN
		EXEC proc_errorHandler 1, 'You are not authorized to view this transaction', @controlNoEncrypted
		RETURN
	END
	EXEC proc_errorHandler 0, 'Transaction Found', @controlNo
END


GO
