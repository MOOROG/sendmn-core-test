ALTER  PROC [dbo].[proc_payTransaction] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(20)		= NULL
	,@payTokenId		VARCHAR(20)		= NULL
	,@tranId			INT				= NULL	
	
	,@sBranchCode		VARCHAR(10)		= NULL
	,@sAgentCode		VARCHAR(10)		= NULL
	,@sAgentName		VARCHAR(200)	= NULL
	,@sBranchName		VARCHAR(200)	= NULL
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
	,@sIdType			VARCHAR(30)		= NULL
	,@sIdNo				VARCHAR(30)		= NULL
	,@sIdValidDate		VARCHAR(50)		= NULL
	,@sAddress1			VARCHAR(100)	= NULL
	,@sAddress2			VARCHAR(100)	= NULL
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
	,@rMobile			VARCHAR(30)		= NULL
	,@rContactNo		VARCHAR(50)		= NULL	
	,@tAmt				MONEY			= NULL
	,@cAmt				MONEY			= NULL
	,@collCurr			VARCHAR(3)		= NULL
	,@serviceCharge		MONEY			= NULL
	,@custRate			MONEY			= NULL
	,@sAgentComm		MONEY			= NULL
	,@payoutAmt			MONEY			= NULL
	,@payoutCurr		VARCHAR(3)		= NULL
	,@paymentType		VARCHAR(30)		= NULL
	,@sLocation			INT				= NULL
	,@pLocation			INT				= NULL
	,@sendUser			VARCHAR(50)		= NULL
	,@rIdType			VARCHAR(30)		= NULL
	,@rIdNumber			VARCHAR(30)		= NULL
	,@rPlaceOfIssue		VARCHAR(50)		= NULL
	,@rIssuedDate		DATETIME		= NULL
	,@rValidDate		DATETIME		= NULL
	,@rRelationType		VARCHAR(50)		= NULL
	,@rRelativeName		VARCHAR(100)	= NULL
	,@msgType			CHAR(1)			= NULL
	,@sql				VARCHAR(MAX)	= NULL
	,@pBranch			INT				= NULL
	,@pBranchName		VARCHAR(100)	= NULL
	,@pAgent			INT				= NULL
	,@pAgentName		VARCHAR(100)	= NULL
	,@pSuperAgent		INT				= NULL
	,@pSuperAgentName	VARCHAR(100)	= NULL
	,@settlingAgent		INT				= NULL
	,@mapCode			VARCHAR(8)		= NULL
	,@mapCodeDom		VARCHAR(8)		= NULL
	,@fromPayTrnTime	VARCHAR(20)		= NULL
	,@toPayTrnTime		VARCHAR(20)		= NULL
	,@extCustomerId		VARCHAR(50)		= NULL
    ,@membershipId		VARCHAR(50)		= NULL
    ,@customerId		VARCHAR(50)		= NULL
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON
DECLARE @tempTicket TABLE(postedBy VARCHAR(50), postedDate DATETIME, comment VARCHAR(200))
DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	
	EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT

DECLARE 
	 @sBranch					INT
	,@sAgent					INT
	,@sSuperAgent				INT
	,@sSuperAgentName			VARCHAR(100)
	,@pCountry					VARCHAR(100)
	,@pState					VARCHAR(100)
	,@pDistrict					VARCHAR(100)
	,@pLocationBranch			INT
	,@deliveryMethod			VARCHAR(100)
	,@pAmt						MONEY
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
	,@agentType					INT
	,@actAsBranchFlag			CHAR(1)
	,@tokenId					BIGINT
	,@controlNoEncrypted		VARCHAR(20)
	,@commCheck					MONEY
	,@tranType					CHAR(1)
	
	DECLARE @pDistrictApi INT, @pDistrictBranch INT
	DECLARE 
		 @pCountryId INT = NULL
		,@deliveryMethodId	INT = NULL
		,@sCountryId INT = NULL
	DECLARE @pAgentCommI MONEY
	DECLARE @tranStatus VARCHAR(20) = NULL
	
	SELECT @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

IF @flag = 'payDom'				
BEGIN	
	DECLARE @lockedBy VARCHAR(50)
	IF @user IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Your session has expired. Please relogin to the system.', @controlNo
		RETURN
	END
	SELECT
		 @tranId			= id 
		,@deliveryMethod	= paymentMethod
		,@sCountry			= sCountry
		,@sBranch			= sBranch
		,@payoutAmt			= pAmt
		,@pLocation			= pLocation
		,@tranStatus		= tranStatus
		,@lockedBy			= lockedBy
	FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	SELECT @pLocationBranch = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	
	IF @tranStatus IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Cannot post transaction for invalid transaction number', NULL
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch = @pBranch)
	BEGIN
		EXEC proc_errorHandler 1, 'Cannot process for same POS', @controlNoEncrypted
		RETURN
	END
	IF (@tranStatus = 'CancelRequest')
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
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
	IF @tranStatus <> 'Lock'
	BEGIN
		EXEC proc_errorHandler 1, 'Your time for paying this transaction has expired. Please try again after a while.', @controlNoEncrypted
		RETURN
	END
	IF @lockedBy <> @user
	BEGIN
		EXEC proc_errorHandler 1, 'You are not authorised to pay this transaction at this time. Please try again after a while', @controlNoEncrypted
		RETURN 
	END
	-->>Location Verfication
	SELECT @pDistrictApi = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @pLocation
	SELECT @pDistrictBranch = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @pLocationBranch
	IF @pDistrictApi IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Location not found. Please Contact HO', @controlNo
		RETURN
	END
	IF @pDistrictBranch IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Location not found. Please Contact HO', @controlNo
		RETURN
	END
	IF @pDistrictApi <> @pDistrictBranch
	BEGIN
		EXEC proc_errorHandler 1, 'You are not allowed to pay this TXN. It is not within your district.', @controlNo
		RETURN
	END
	--End of Location Verification
	
	DECLARE @userId INT, @payPerTxn MONEY, @payPerDay MONEY, @payTodays MONEY
	SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
	SELECT @payPerDay = payPerDay, @payPerTxn = payPerTxn, @payTodays = ISNULL(payTodays, 0) FROM userWiseTxnLimit WITH(NOLOCK) WHERE userId = @userId AND ISNULL(isDeleted, 'N') = 'N'
	
	IF(@payoutAmt > @payPerTxn)
	BEGIN
		EXEC proc_errorHandler 1, 'Transfer Amount exceeds user per Pay Transaction Limit.', @controlNoEncrypted
		RETURN
	END
	IF(@payTodays > @payPerDay)
	BEGIN
		EXEC proc_errorHandler 1, 'User Per Day Pay Transaction Limit exceeded.', @controlNoEncrypted
		RETURN
	END
	
	SELECT 
		 @agentType = agentType, @pAgent = parentId, @pBranchName = agentName
		,@pState = agentState, @pDistrict = agentDistrict
		,@mapCode = mapCodeInt, @mapCodeDom = mapCodeDom
	FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch

	--Check for branch or agent acting as branch
	IF @agentType = 2903	
	BEGIN
		SET @pAgent = @pBranch
	END
	SELECT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
	SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
	
	--Commission Calculation Start
	SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
	SELECT @pCountryId = 151 
	SELECT @sCountryId = 151
	
	SELECT
		 @pAgentComm		= ISNULL(pAgentComm, 0)
		,@pAgentCommI		= ISNULL(pAgentComm, 0)
		,@pSuperAgentComm	= ISNULL(psAgentComm, 0)
		,@commCheck			= pAgentComm
	FROM dbo.FNAGetDomesticPayComm(@sBranch, @pBranch, @deliveryMethodId, @payoutAmt)
	
	SELECT @pAgentCommCurrency = 'NPR', @pSuperAgentCommCurrency = 'NPR'
	
	IF @commCheck IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Commission not defined. Please contact HO', @controlNo
		RETURN
	END
	
	BEGIN TRANSACTION
		--Update Transaction Record
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
			,pLocation					= @pLocation
			,pDistrict					= @pDistrict
			,tranStatus					= 'Paid'
			,payStatus					= 'Paid'
			,paidDate					= dbo.FNAGetDateInNepalTZ()
			,paidDateLocal				= dbo.FNAGetDateInNepalTZ()
			,paidBy						= @user
		WHERE controlNo = @controlNoEncrypted
		
		--6.Update receiver identification details
		SELECT @tranId = id FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
		UPDATE tranReceivers SET
			 idType2			= @rIdType
			,idNumber2			= @rIdNumber
			,issuedDate2		= @rIssuedDate
			,validDate2			= @rValidDate
			,idPlaceOfIssue2	= @rPlaceOfIssue
			,mobile				= @rMobile
			,homePhone			= @rContactNo
			,relationType		= @rRelationType
			,relativeName		= @rRelativeName
			,customerId			= @customerId
			,membershipId		= @membershipId
		WHERE tranId = @tranId
		
		EXEC SendMnPro_Account.dbo.PROC_REMIT_DATA_UPDATE
		 @flag = 'p'
		,@mapCode		= @mapCodeDom
		,@user			= @user
		,@pAgentComm	= @pAgentComm
		,@controlNo		= @controlNo
		
		INSERT INTO domesticPayQueueList(controlNo, controlNoSwiftEnc, controlNoInficareEnc)
		SELECT @controlNo, @controlNoEncrypted, dbo.encryptDbLocal(@controlNo)
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC [proc_errorHandler] 0, 'Transaction has been paid successfully', @controlNo	
END

ELSE IF @flag = 'paySearch'				
BEGIN
	IF @pBranch IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Please Choose Agent', NULL
		RETURN
	END
	SELECT @mapCodeDom = mapCodeDom FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	IF (@mapCodeDom IS NULL OR @mapCodeDom = '' OR @mapCodeDom = 0)
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid Map Code', NULL
		RETURN
	END
	
	SELECT @tranStatus = tranStatus, @tranId = id FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	IF @tranStatus IS NULL
	BEGIN
		EXEC proc_errorHandler 1000, 'Transaction not found', NULL
		RETURN
	END
	
	SELECT @agentType = agentType, @pLocation = agentLocation FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	IF @agentType = 2903		--Agent
	BEGIN
		SET @pAgent = @pBranch
	END
	
	IF @tranStatus IS NOT NULL
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
		
		IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND paymentMethod = 'Bank Deposit')
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot process payment for Payment Type Bank Deposit', NULL
			RETURN	
		END
		IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch = @pBranch) 
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot process payment for same POS', @tranId
			RETURN
		END
		
		IF (@tranStatus = 'CancelRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
			RETURN
		END
		IF (@tranStatus = 'Lock' )
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is locked', @controlNoEncrypted
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
		DECLARE @tranDistrictId INT, @payAgentDistrictId INT

		--Checking payout location for domestic txn
		IF LEFT(@controlNo,1) = 'D' 
		BEGIN		
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
		END
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @tranId
		
		--Checking pay tran for 30 days expiry days & more than 3,00,000 transaction
		declare @checkPayTran TABLE (tSetFlag varchar(10), eSetFlag varchar(10))
		declare @tSetFlag as varchar(10),@eSetFlag varchar(10)
		insert into @checkPayTran(tSetFlag,eSetFlag)
		exec proc_checkPayLock @user ='admin', @controlNo = @controlNoEncrypted, @agentId = @pBranch
		select @tSetFlag = tSetFlag, @eSetFlag = eSetFlag from @checkPayTran

		--End of Validation
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
			,tSetFlag = @tSetFlag
			,eSetFlag = @eSetFlag
		FROM remitTran trn WITH(NOLOCK)
		LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		
		LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
		LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
		LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
		WHERE trn.controlNo = @controlNoEncrypted
		--End of Select payout details
		
		--Lock Transaction
		UPDATE remitTran SET 
			 payTokenId			= @payTokenId
			,tranStatus			= 'Lock'
			,lockedBy			= @user
			,lockedDate			= GETDATE()
			,lockedDateLocal	= GETDATE()
		WHERE controlNo = @controlNoEncrypted
		--End of Lock Transaction
		
		--Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE trn.tranId = @tranId OR ISNULL(trn.controlNo,'') = ISNULL(@controlNoEncrypted, '')
		ORDER BY trn.createdDate DESC
		--End of Log Details
	END
END


	





GO
