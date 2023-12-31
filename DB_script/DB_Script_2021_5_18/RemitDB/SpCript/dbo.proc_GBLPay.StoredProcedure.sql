USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GBLPay]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_GBLPay @flag = 'details', @user = 'bajrashali_b1', @tranId = '1', @controlNo = '91191505349'

*/

CREATE PROC [dbo].[proc_GBLPay] (	 
	 @flag						VARCHAR(50)
	,@controlNo					VARCHAR(20)		= NULL
	,@user						VARCHAR(30)		= NULL
	,@agentRefId				VARCHAR(20)		= NULL
	,@payTokenId				VARCHAR(20)		= NULL
	,@tranId					INT				= NULL	
	
	,@remittanceEntryDate		VARCHAR(30)		= NULL
	,@remittanceAuthorizedDate	VARCHAR(30)		= NULL
	,@sFirstName				VARCHAR(30)		= NULL
	,@sMiddleName				VARCHAR(30)		= NULL
	,@sLastName1				VARCHAR(30)		= NULL
	,@sLastName2				VARCHAR(30)		= NULL
	,@sAddress					VARCHAR(100)	= NULL
	,@sTelephone				VARCHAR(20)		= NULL
	,@sMobile					VARCHAR(20)		= NULL
	
	,@rFirstName				VARCHAR(30)		= NULL
	,@rMiddleName				VARCHAR(30)		= NULL
	,@rLastName1				VARCHAR(30)		= NULL
	,@rLastName2				VARCHAR(30)		= NULL
	,@rAddress					VARCHAR(100)	= NULL
	,@rTelephone				VARCHAR(20)		= NULL		
	,@rMobile					VARCHAR(20)		= NULL
	
	,@rIdType					VARCHAR(30)		= NULL
	,@rIdNumber					VARCHAR(30)		= NULL
	,@rPlaceOfIssue				VARCHAR(50)		= NULL
	,@rIssuedDate				DATETIME		= NULL
	,@rValidDate				DATETIME		= NULL
	
	,@tAmt						MONEY			= NULL
	,@collCurr					VARCHAR(3)		= NULL
	,@exRate					DECIMAL(15,9)	= NULL
	,@payoutAmt					MONEY			= NULL
	,@payoutCurr				VARCHAR(3)		= NULL
	,@paymentType				VARCHAR(30)		= NULL
	,@payingCommission			MONEY			= NULL
	
	,@remarks					VARCHAR(MAX)	= NULL
	,@msgType					CHAR(1)			= NULL
	
	,@pBranch					INT				= NULL
	,@customerId				INT				= NULL
	,@sortBy					VARCHAR(50)		= NULL
	,@sortOrder					VARCHAR(5)		= NULL
	,@pageSize					INT				= NULL
	,@pageNumber				INT				= NULL
	
	,@refNo						VARCHAR(20)		= NULL
	,@senderName				VARCHAR(100)	= NULL
	,@beneficiaryName			VARCHAR(100)	= NULL
	,@remitType					VARCHAR(50)		= NULL
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

DECLARE 
	 @sBranch					INT
	,@sBranchName				VARCHAR(100)
	,@sAgent					INT
	,@sAgentName				VARCHAR(100)
	,@sSuperAgent				INT
	,@sSuperAgentName			VARCHAR(100)
	,@sHub						INT
	,@sHubName					VARCHAR(100)
	,@sCountry					INT
	,@pHub						INT
	,@pHubName					VARCHAR(50)
	,@pSuperAgent				INT
	,@pSuperAgentName			VARCHAR(100)
	,@pAgent					INT
	,@pAgentName				VARCHAR(100)
	,@pBranchName				VARCHAR(100)
	,@pCountry					VARCHAR(100)
	,@pState					VARCHAR(100)
	,@pDistrict					VARCHAR(100)
	,@pLocation					INT
	,@deliveryMethod			VARCHAR(100)
	,@cAmt						MONEY
	,@pAmt						MONEY
	,@serviceCharge				MONEY
	,@pAgentComm				MONEY
	,@pAgentCommCurrency		VARCHAR(3)
	,@pSuperAgentComm			MONEY
	,@pSuperAgentCommCurrency	VARCHAR(3)
	,@pHubComm					MONEY
	,@pHubCommCurrency			VARCHAR(3)
	,@collMode					INT
	,@sendingCustType			INT
	,@receivingCurrency			INT
	,@senderId					INT
	,@payoutMethod				INT
	,@agentType					INT
	,@actAsBranchFlag			CHAR(1)
	,@tokenId					BIGINT
	,@controlNoEncrypted		VARCHAR(20)

	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

IF @flag = 'pay'				--Domestic Pay	For API
BEGIN	
	SELECT @payoutMethod = CASE WHEN @paymentType = 'Cash Pay' THEN 1 END
	
	--1. Find Sending Agent Details-------------------------------------------------------------------------
	SELECT @sBranch = agentId, @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentCode = 'GBL-API' AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y'
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
	END
	ELSE
	BEGIN
		SELECT @sAgent = parentId, @sBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	END
	SELECT @sSuperAgent = parentId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
	SELECT @sHub = parentId, @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
	SELECT @sHubName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sHub
	--End of Find Sending Agent Details----------------------------------------------------------------------
	
	--2. Find Payout Agent Details---------------------------------------------------------------------------
	IF @pBranch IS NULL
		SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user 
	SELECT 
		 @pCountry = agentCountry
		,@pState = agentState
		,@pDistrict = agentDistrict
		,@pLocation = agentLocation 
	FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch 
	
	--Payout
	SELECT @agentType = agentType, @pbranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	--Check for branch or agent acting as branch
	IF @agentType = 2903	--Agent
	BEGIN
		SET @pAgent = @pBranch
	END
	ELSE
	BEGIN
		SELECT @pAgent = parentId, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	END
	SELECT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
	SELECT @pHub = parentId, @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
	SELECT @pHubName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pHub
	--End of Find Payout Agent Details--------------------------------------------------------------------------------
	
	--3. Find Settling Agent-------------------------------------------------------------------------------------------
	DECLARE @settlingAgent INT = NULL
	SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pBranch AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pAgent AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pSuperAgent AND isSettlingAgent = 'Y'
	--End of Find Settling Agent--------------------------------------------------------------------------------------
	
	--4. Commission Calculation Start
	SET @payoutMethod = 'Cash Payment'
	SELECT @sCountry = countryId 
	FROM countryCurrency cc WITH(NOLOCK) 
	INNER JOIN currencyMaster cm WITH(NOLOCK) ON cc.currencyId = cm.currencyId AND ISNULL(cc.isActive, 'N') = 'Y' AND ISNULL(cc.isDeleted, 'N') <> 'Y'
	WHERE cm.currencyCode = @collCurr
	DECLARE @pCountryId INT = NULL, @deliveryMethodId INT = NULL
	SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
	SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @payoutMethod
	
	SELECT @pHubComm = ISNULL(amount, 0) FROM dbo.FNAGetPayCommHub(@sBranch, @sCountry, NULL, @pSuperAgent, @pCountryId, @pLocation, @pBranch, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, 0, 0)
	SELECT @pHubCommCurrency = 'NPR'
	
	SELECT @pSuperAgentComm = ISNULL(amount, 0) FROM dbo.FNAGetPayCommSA(@sBranch, @sCountry, NULL, @pSuperAgent, @pCountryId, @pLocation, @pBranch, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @pHubComm, 0)
	SELECT @pSuperAgentCommCurrency = 'NPR'
	
	SELECT @pAgentComm = ISNULL(amount, 0) FROM dbo.FNAGetPayComm(@sBranch, @sCountry, NULL, @pSuperAgent, @pCountryId, @pLocation, @pBranch, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @pHubComm, @pSuperAgentComm)
	SELECT @pAgentCommCurrency = 'NPR'
	
	--Commission Calculation End
		
	BEGIN TRANSACTION
		BEGIN
		--Transaction Insert
		INSERT INTO remitTran(
			 controlNo
			,pAgentComm
			,pAgentCommCurrency
			,pSuperAgentComm
			,pSuperAgentCommCurrency
			,pHubComm
			,pHubCommCurrency
			,sBranch
			,sBranchName
			,sAgent
			,sAgentName
			,sSuperAgent
			,sSuperAgentName
			,sHub
			,sHubName
			,pBranch
			,pBranchName
			,pAgent
			,pAgentName
			,pSuperAgent
			,pSuperAgentName
			,pHub
			,pHubName
			,pCountry
			,pState
			,pDistrict
			,pLocation
			,tAmt
			,collCurr
			,pAmt
			,payoutCurr
			,paymentMethod
			,tranStatus
			,payStatus
			,createdBy
			,createdDate
			,approvedBy
			,approvedDate
			,paidDate
			,paidDateLocal
			,paidBy
		)
		SELECT
			 @controlNoEncrypted
			,@pAgentComm
			,@pAgentCommCurrency
			,@pSuperAgentComm
			,@pSuperAgentCommCurrency
			,@pHubComm
			,@pHubCommCurrency
			,@sBranch
			,@sBranchName
			,@sAgent
			,@sAgentName
			,@sSuperAgent
			,@sSuperAgentName
			,@sHub
			,@sHubName
			,@pBranch
			,@pBranchName
			,@pAgent
			,@pAgentName
			,@pSuperAgent
			,@pSuperAgentName
			,@pHub
			,@pHubName
			,@pCountry
			,@pState
			,@pDistrict
			,@pLocation
			,@tAmt
			,@collCurr
			,@payoutAmt
			,@payoutCurr
			,@payoutMethod
			,'Paid'
			,'Paid'
			,'system'
			,LEFT(@remittanceEntryDate, 19)
			,'system'
			,LEFT(@remittanceAuthorizedDate, 19)
			,GETDATE()
			,dbo.FNADateFormatTZ(GETDATE(), @user)
			,@user
		
		SET @tranId = SCOPE_IDENTITY()
		--Sender Insert
		INSERT INTO tranSenders(
			tranId, firstName, middleName, lastName1, lastName2, address, mobile, homePhone
		)
		SELECT
			@tranId,@sFirstName,@sMiddleName,@sLastName1,@sLastName2,@sAddress,@sMobile, @sTelephone
		
		--Receiver Insert
		INSERT INTO tranReceivers(
			tranId, firstName, middleName, lastName1, lastName2, address, mobile, homePhone
			, idType, idNumber, idPlaceOfIssue, issuedDate, validDate
		)
		SELECT
			@tranId,@rFirstName,@rMiddleName,@rLastName1,@rLastName2,@rAddress,@rMobile, @rTelephone
			,@rIdType,@rIdNumber,@rPlaceOfIssue,@rIssuedDate,@rValidDate
		END
	--A/C Master
		EXEC proc_updateTopUpLimit @settlingAgent, @payoutAmt
			
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC [proc_errorHandler] 0, 'Transaction has been paid successfully', @tranId		
	
END

ELSE IF @flag = 'details'
BEGIN
	SELECT 
		 trn.id
		,dbo.FNADecryptString(trn.controlNo)
		
		,sMemId = sen.membershipId
		,sCustomerId = sen.customerId
		,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = sen.country 
		,sStateName = sen.state
		,sCity = sen.city
		,sAddress = sen.address
		
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,rCountryName = rec.country
		,rStateName = rec.state
		,rCity = rec.city
		,rAddress = rec.address
		
		,rIdType = rci.idType
		,rIdNumber = rci.idNumber
		,rPlaceOfIssue = rci.placeOfIssue
		,rIssuedDate = rci.issuedDate
		,rValidDate = rci.validDate
		
		,sAgentCountry = trn.sCountry
		
		,relationship = trn.relWithSender
		,purpose = trn.purposeOfRemit
		,trn.pAmt
		,collMode = trn.collMode
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,sAgent = trn.sAgentName
		,trn.tranStatus
		,trn.payStatus
		,pMessage = ISNULL(trn.pMessage, '-')
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN customerIdentity rci WITH(NOLOCK) ON rec.customerId = rci.customerId
	WHERE trn.controlNo = @controlNoEncrypted
		
END

ELSE IF @flag = 'i'
BEGIN
	INSERT INTO ApiGBLTXN (
		 controlNo
		,refNo
		,tokenId
		,senderName
		,senderAddress
		,senderTelephone
		,senderMobile
		,beneficiaryName
		,beneficiaryAddress
		,beneficiaryTelephone
		,beneficiaryMobile
		,beneficiaryIdType
		,beneficiaryIdNo
		,collAmt
		,collCurr
		,exRate
		,payoutAmt
		,payoutCurr
		,payingComm
		,remarks
		,remitType
		,remittanceEntryDate
		,remittanceAuthorizedDate
		,fetchUser
		,fetchDate
	)
	SELECT
		 @controlNoEncrypted
		,@refNo
		,@payTokenId
		,@senderName
		,@sAddress
		,@sTelephone
		,@sMobile
		,@beneficiaryName
		,@rAddress
		,@rTelephone
		,@rMobile
		,@rIdType
		,@rIdNumber
		,@tAmt
		,@collCurr
		,@exRate
		,@payoutAmt
		,@payoutCurr
		,@payingCommission
		,@remarks
		,@remitType
		,LEFT(@remittanceEntryDate, 19)
		,LEFT(@remittanceAuthorizedDate, 19)
		,@user
		,GETDATE()
END

	


GO
