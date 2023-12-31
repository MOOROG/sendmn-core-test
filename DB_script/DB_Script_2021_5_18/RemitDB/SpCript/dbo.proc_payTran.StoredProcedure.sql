USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payTran]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_payTran] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(20)		= NULL
	,@payTokenId		VARCHAR(20)		= NULL
	,@tranId			INT				= NULL	
	
	,@sAgentName		VARCHAR(200)	= NULL
	,@txnDate			DATETIME		= NULL
	,@sFirstName		VARCHAR(30)		= NULL
	,@sMiddleName		VARCHAR(30)		= NULL
	,@sLastName1		VARCHAR(30)		= NULL
	,@sLastName2		VARCHAR(30)		= NULL
	,@sMemId			VARCHAR(30)		= NULL
	,@sId				BIGINT			= NULL
	,@sCountry			VARCHAR(50)		= NULL
	,@sAddress			VARCHAR(100)	= NULL
	,@sCity				VARCHAR(50)		= NULL
	,@sMobile			VARCHAR(20)		= NULL
	,@sTranId			VARCHAR(50)		= NULL	
	
	,@rFirstName		VARCHAR(30)		= NULL
	,@rMiddleName		VARCHAR(30)		= NULL
	,@rLastName1		VARCHAR(30)		= NULL
	,@rLastName2		VARCHAR(30)		= NULL
	,@rMemId			VARCHAR(30)		= NULL
	,@rId				BIGINT			= NULL
	,@rCountry			VARCHAR(50)		= NULL
	,@rAddress			VARCHAR(100)	= NULL
	,@rCity				VARCHAR(50)		= NULL		
	,@rMobile			VARCHAR(20)		= NULL
	
	,@rIdType			VARCHAR(30)		= NULL
	,@rIdNumber			VARCHAR(30)		= NULL
	,@rPlaceOfIssue		VARCHAR(50)		= NULL
	,@rIssuedDate		DATETIME		= NULL
	,@rValidDate		DATETIME		= NULL
	,@rRelationType		VARCHAR(50)		= NULL
	,@rRelativeName		VARCHAR(100)	= NULL
	,@payoutAmt			MONEY			= NULL
	,@payoutCurr		VARCHAR(3)		= NULL
	,@paymentType		VARCHAR(30)		= NULL
	,@sLocation			INT				= NULL
	,@pLocation			INT				= NULL
	
	,@msgType			CHAR(1)			= NULL
	
	,@pBranch			INT				= NULL
	,@pBranchName		VARCHAR(100)	= NULL
	,@pAgent			INT				= NULL
	,@pAgentName		VARCHAR(100)	= NULL
	,@pSuperAgent		INT				= NULL
	,@pSuperAgentName	VARCHAR(100)	= NULL
	,@settlingAgent		INT				= NULL
	,@mapCode			VARCHAR(8)		= NULL
	,@mapCodeDom		VARCHAR(8)		= NULL
	,@customerId		INT				= NULL
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

DECLARE 
	 @sBranch					INT
	,@pCountry					VARCHAR(100)
	,@pState					VARCHAR(100)
	,@pDistrict					VARCHAR(100)
	,@deliveryMethod			VARCHAR(100)
	,@tAmt						MONEY
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

DECLARE 
	 @pCountryId		INT
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

IF @flag = 'details'
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

ELSE IF @flag = 'paySearch'			--Pay Search Local
BEGIN
/*
	EXEC proc_payTran @flag = 'paySearch', @user = 'bharat', @controlNo = '91598256530', @agentRefId = 'buruysvr5v5k1pfxxjgfq00f'
*/
	--Necessary Parameter: @pBranch, @pAgent, @user, @controlNo
	DECLARE @tranStatus VARCHAR(20) = NULL
	SELECT @tranStatus = tranStatus, @tranId = id FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	SELECT @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	
	--Validation Starts----------------------------------------------------------------------------------------------
	IF (@tranStatus IS NOT NULL)
	BEGIN
		INSERT INTO tranViewHistory(
			 controlNumber
			,tranViewType
			,agentId
			,createdBy
			,createdDate
			,tranId
		)
		SELECT
			 @controlNoEncrypted
			,'PAY'
			,@pBranch
			,@user
			,GETDATE()
			,@tranId
		
		SET @payTokenId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		EXEC proc_errorHandler 1000, 'No Transaction Found', @controlNoEncrypted
		RETURN
	END
	
	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND paymentMethod = 'Bank Deposit')
	BEGIN
		EXEC proc_errorHandler 1, 'Cannot process payment for Payment Type "Bank Deposit"', NULL
		RETURN	
	END
	IF (EXISTS(SELECT 'X' FROM remitTran WHERE controlNo = @controlNoEncrypted AND sBranch = @pBranch) 
		OR EXISTS(SELECT 'X' FROM remitTran WHERE controlNo = @controlNoEncrypted AND sAgent = @pAgent))
	BEGIN
		EXEC proc_errorHandler 1, 'Cannot process payment for same POS', @tranId
		RETURN
	END
	
	IF (@tranStatus = 'Paid')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Hold')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is hold', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is cancelled', @controlNoEncrypted
		RETURN
	END
	
	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Lock' )
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is locked. Please Contact HO', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Block')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is blocked. Please Contact HO', @controlNoEncrypted
		RETURN
	END
	
	
	DECLARE @tranDistrictId INT, @payAgentDistrictId INT
	SELECT @payAgentDistrictId = districtId FROM apiLocationMapping WHERE apiDistrictCode = @pLocation
	SELECT @tranDistrictId = districtId FROM apiLocationMapping WHERE apiDistrictCode = (SELECT pLocation FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted)
	IF @payAgentDistrictId IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Location not found. Please Contact HO', @controlNo
		RETURN
	END
	IF @tranDistrictId IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Location not found. Please Contact HO', @controlNo
		RETURN
	END
	IF(@tranDistrictId <> @payAgentDistrictId)
	BEGIN
		EXEC proc_errorHandler 1, 'You are not allowed to pay this TXN. It is not within your district.', @controlNoEncrypted
		RETURN
	END
	
	EXEC proc_errorHandler 0, 'Transaction Verification Successful', @tranId
	
	--End of Validation--------------------------------------------------------------------------------------------------
	
	--Select payout details----------------------------------------------------------------------------------------------
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
		
		,sAgent = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		
		,pBranchName = ISNULL(trn.pBranchName, 'Any')
		,pCountryName = trn.pCountry
		,pStateName = trn.pState
		,pDistrictName = trn.pDistrict
		,pLocationName = pLoc.districtName
		,pAddress = pa.agentAddress
		
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,trn.cAmt
		,trn.pAmt
		
		,relationship = ISNULL(trn.relWithSender, '-')
		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,trn.pAmt
		,collMode = trn.collMode
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,trn.tranStatus
		,trn.payStatus
		,payoutMsg = ISNULL(trn.pMessage, '-')
		,send_agent = COALESCE(trn.sBranchName, trn.sAgentName)
		,txn_date = trn.createdDateLocal
		,payTokenId = @payTokenId
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	WHERE trn.controlNo = @controlNoEncrypted
	--End of Select payout details--------------------------------------------------------------------------------------
	
	--Lock Transaction--------------------------------------------------------------------------------------------------
	UPDATE remitTran SET 
		 payTokenId			= @payTokenId
		,tranStatus			= 'Lock'
		,lockedBy			= @user
		,lockedDate			= GETDATE()
		,lockedDateLocal	= dbo.FNADateFormatTZ(GETDATE(), @user)
	WHERE controlNo = @controlNoEncrypted
	--End of Lock Transaction--------------------------------------------------------------------------------------------
	
	--Log Details-------------------------------------------------------------------------------------------------------
	SELECT 
		 message
		--,createdBy = au.firstName + ISNULL( ' ' + au.middleName, '') + ISNULL( ' ' + au.lastName, '')
		,trn.createdBy
		,trn.createdDate
	FROM tranModifyLog trn WITH(NOLOCK)
	LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
	WHERE trn.tranId = @tranId OR trn.controlNo = @controlNoEncrypted
	ORDER BY trn.createdDate DESC
	--End of Log Details------------------------------------------------------------------------------------------------
END

ELSE IF @flag = 'payUpdate'			--Pay Update Local
BEGIN
	IF @user IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Your session has expired. Cannot pay transaction', NULL
		RETURN
	END
	--1.Start of Validation--------------------------------------------------------------------------------------------------
	SELECT @tranStatus = tranStatus FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
		RETURN
	END
	IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND lockedBy = @user AND (payTokenId = @payTokenId OR payTokenId IS NULL))
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is locked. Please Contact HO', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Block')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is blocked. Please Contact HO', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Paid')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has already been paid', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Hold')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is hold', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'Cancel')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is cancelled', @controlNoEncrypted
		RETURN
	END
	
	/*
	IF @pBranch IS NULL
		SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
	*/
	SELECT @pCountry = 'Nepal'
	SELECT @pLocation = agentLocation, @pState = agentState,@pDistrict = agentDistrict FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	
	SELECT @payAgentDistrictId = districtId FROM apiLocationMapping WHERE apiDistrictCode = @pLocation
	SELECT @tranDistrictId = districtId FROM apiLocationMapping WHERE apiDistrictCode = (SELECT pLocation FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted)
	IF @payAgentDistrictId IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Location not found. Please Contact HO', @controlNo
		RETURN
	END
	IF @tranDistrictId IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Location not found. Please Contact HO', @controlNo
		RETURN
	END
	IF(@tranDistrictId <> @payAgentDistrictId)
	BEGIN
		EXEC proc_errorHandler 1, 'You are not allowed to pay this TXN. It is not within your district.', @controlNoEncrypted
		RETURN
	END
	
	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch = @pBranch)
	BEGIN
		EXEC proc_errorHandler 1, 'Cannot process for same POS', @controlNoEncrypted
		RETURN
	END
	--End Of Validation-----------------------------------------------------------------------------------------------
	
	--2.Find Sending Agent Details-------------------------------------------------------------------
	--Sending Agent
	SELECT @sBranch = sBranch FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF @sBranch IS NULL
		SELECT @sBranch = sAgent FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	SELECT @sLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	
	--End of Find Sending Agent and Payout Agent Details------------------------------------------------------------
	
	--Check Sending List From Table dbo.rsList----------------------------------------------------------------------
	--IF EXISTS(SELECT 'X' FROM rsList WITH(NOLOCK) 
	--			WHERE agentId = @pBranch 
	--			AND rsAgentId = @sBranch 
	--			AND agentRole = 's' 
	--			AND listType = 'ex' 
	--			AND ISNULL(isDeleted, 'N') <> 'Y' 
	--			AND ISNULL(isActive, 'Y') = 'Y')
	--BEGIN
	--	EXEC proc_errorHandler 1, 'You are not allowed to pay this transaction', NULL
	--	RETURN
	--END
	--IF NOT EXISTS(SELECT 'X' FROM rsList WITH(NOLOCK) 
	--			WHERE agentId = @pBranch 
	--			AND rsAgentId = @sBranch 
	--			AND agentRole = 's' 
	--			AND listType = 'in' 
	--			AND ISNULL(isDeleted, 'N') <> 'Y' 
	--			AND ISNULL(isActive, 'Y') = 'Y')
	--BEGIN
	--	EXEC proc_errorHandler 1, 'You are not allowed to pay this transaction', NULL
	--	RETURN
	--END
	--End of Checking Sending List------------------------------------------------------------------------------------
	
	/*
	--3.Find Settlement Agent-----------------------------------------------------------------------------------------
	SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pBranch AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pAgent AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pSuperAgent AND isSettlingAgent = 'Y'
	--End of Find Settlement Agent-------------------------------------------------------------------------------
	*/
	
	--4.Commission Calculation Start-------------------------------------------------------------------------------
	SELECT 
		 @deliveryMethod	= paymentMethod
		,@sCountry			= sCountry
		,@pLocation			= pLocation
		,@tAmt				= tAmt
		,@cAmt				= cAmt
		,@pAmt				= pAmt
		,@serviceCharge		= serviceCharge 
		,@payoutCurr		= payoutCurr 
	FROM remitTran WHERE controlNo = @controlNoEncrypted
	
	DECLARE @deliveryMethodId INT
	SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND typeTitle = @deliveryMethod
	
	IF @sCountry = 'Nepal'
	BEGIN
		DECLARE @commissionCheck MONEY
		SELECT
			 @pAgentComm		= ISNULL(pAgentComm, 0)
			,@pSuperAgentComm	= ISNULL(psAgentComm, 0)
			,@commissionCheck	= pAgentComm
		FROM dbo.FNAGetDomesticPayComm(@sBranch, @pBranch, @deliveryMethodId, @tAmt)
		
		SELECT @pAgentCommCurrency = 'NPR', @pSuperAgentCommCurrency = 'NPR'
	END
	ELSE
	BEGIN
		DECLARE @sCountryId INT
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry
		
		SELECT @pSuperAgentComm = ISNULL(amount, 0), @pSuperAgentCommCurrency = commissionCurrency 
		FROM dbo.FNAGetPayCommSA(@sBranch, @sCountryId, @sLocation, @pSuperAgent, @pCountryId, @pLocation, @pBranch, @payoutCurr, @deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @pHubComm, 0)
		SELECT @pAgentComm = ISNULL(amount, 0), @commissionCheck = amount, @pAgentCommCurrency = commissionCurrency 
		FROM dbo.FNAGetPayComm(@sBranch, @sCountryId, @sLocation, @pSuperAgent, @pCountryId, @pLocation, @pBranch, @payoutCurr, @deliveryMethodId, @cAmt,

 @pAmt, @serviceCharge, @pHubComm, @pSuperAgentComm)
	END
	
	IF @commissionCheck IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Pay Commission has not been defined', NULL
		RETURN
	END
	--Commission Calculation End---------------------------------------------------------------------------------
		
	BEGIN TRANSACTION
		--5.Update Transaction Record----------------------------------------------------------------------------
		UPDATE remitTran SET
			 pAgentComm					= @pAgentComm
			,pAgentCommCurrency			= @pAgentCommCurrency
			,pSuperAgentComm			= @pSuperAgentComm
			,pSuperAgentCommCurrency	= @pSuperAgentCommCurrency
			,pHubComm					= @pHubComm
			,pHubCommCurrency			= @pHubCommCurrency
			,pBranch					= @pBranch
			,pBranchName				= @pBranchName
			,pAgent						= @pAgent
			,pAgentName					= @pAgentName
			,pSuperAgent				= @pSuperAgent
			,pSuperAgentName			= @pSuperAgentName
			,pCountry					= @pCountry
			,pState						= @pState
			,pDistrict					= @pDistrict
			,tranStatus					= 'Paid'
			,payStatus					= 'Paid'
			,paidDate					= GETDATE()
			,paidDateLocal				= DBO.FNADateFormatTZ(GETDATE(), @user)
			,paidBy						= @user
		WHERE controlNo = @controlNoEncrypted
		------End of Update Transaction Record------------------------------------------------------------------
		
		--6.Update receiver identification details--------------------------------------------------------------
		SELECT @tranId = id FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		UPDATE tranReceivers SET
			 idType			= @rIdType
			,idNumber		= @rIdNumber
			,issuedDate		= @rIssuedDate
			,validDate		= @rValidDate
			,placeOfIssue	= @rPlaceOfIssue
			,mobile			= @rMobile
			,relationType	= @rRelationType
			,relativeName	= @rRelativeName
		WHERE tranId = @tranId
		
		--SELECT 
		--	@customerId = customerId 
		--FROM remitTran trn WITH(NOLOCK)
		--LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		--WHERE trn.controlNo = @controlNoEncrypted
		
		--UPDATE customerIdentity SET
		--	 idType						= ISNULL(@rIdType, idType)
		--	,idNumber					= ISNULL(@rIdNumber, idNumber)
		--	,issuedDate					= ISNULL(@rIssuedDate, issuedDate)
		--	,validDate					= ISNULL(@rValidDate, validDate)
		--	,placeOfIssue				= ISNULL(@rPlaceOfIssue, placeOfIssue)
		--WHERE customerId = @customerId AND ISNULL(isDeleted, 'N') <> 'Y' AND isPrimary = 'Y'
		
		---End of Update receiver identification details-------------------------------------------------------
		
		--7.A/C Master----------------------------------------------------------------------------------------------
		EXEC proc_updatePayTopUpLimit @settlingAgent, @pAmt
		
		--UPDATE ac_master SET 
		--	system_reserved_amt = ISNULL(system_reserved_amt, 0) - ISNULL(@payoutAmt, 0) 
		--WHERE agent_id = @settlingAgent AND gl_code = 1
		
		--End Of A/C Master-----------------------------------------------------------------------------------------
		
		---##### PROCEDURE FOR PAID TANSACTIO  EOD
		--EXEC proc_paidEODRemit @USER, @tranId
			
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	--8.Accounting Server---------------------------------------------------------------------------------------
	--SELECT * FROM [192.168.1.234].IME_TEST.dbo.[REMIT_TRN_LOCAL]
	DECLARE @parentMapCode VARCHAR(8)
	SELECT @mapCodeDom = mapCodeDom FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	SELECT @parentMapCode = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @settlingAgent	
	EXEC SendMnPro_Account.dbo.PROC_REMIT_DATA_UPDATE
		 @flag = 'p'
		,@mapCode		= @mapCodeDom
		,@pMapCode		= @parentMapCode
		,@user			= @user
		,@pAgentComm	= @pAgentComm
		,@controlNo		= @controlNo
	
	/*
	UPDATE [192.168.1.234].IME_TEST.dbo.[REMIT_TRN_LOCAL] SET
		 R_BRANCH		= @mapCodeDom
		,R_AGENT		= @mapCodeDom
		,paidBy			= @user
		,P_DATE			= GETDATE()
		,PAY_STATUS		= 'Paid'
		,TRN_STATUS		= 'Paid'
		,R_SC			= @pAgentComm 
	WHERE TRN_REF_NO = dbo.encryptDbLocal(@controlNo)
	*/
		
	EXEC [proc_errorHandler] 0, 'Transaction has been paid successfully', @controlNoEncrypted
END



	





GO
