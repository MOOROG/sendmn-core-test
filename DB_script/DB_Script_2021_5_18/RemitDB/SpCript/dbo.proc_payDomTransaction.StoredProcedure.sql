USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payDomTransaction]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_payDomTransaction](	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(20)		= NULL	
	,@agentRefId		VARCHAR(20)		= NULL	
	,@rIdType			VARCHAR(30)		= NULL
	,@rIdNumber			VARCHAR(30)		= NULL
	,@rPlaceOfIssue		VARCHAR(50)		= NULL
	,@rMobile			VARCHAR(50)		= NULL
	,@rRelationType		VARCHAR(50)		= NULL
	,@rRelativeName		VARCHAR(100)	= NULL	
	,@pBranch			INT				= NULL
	,@pBranchName		VARCHAR(100)	= NULL
	,@pAgent			INT				= NULL
	,@pAgentName		VARCHAR(100)	= NULL
	,@pSuperAgent		INT				= NULL
	,@pSuperAgentName	VARCHAR(100)	= NULL
	,@settlingAgent		INT				= NULL
	,@mapCodeInt		VARCHAR(8)		= NULL
	,@mapCodeDom		VARCHAR(8)		= NULL
	,@customerId		VARCHAR(50)		= NULL
    ,@membershipId		VARCHAR(50)		= NULL
	,@fromPayTrnTime	VARCHAR(20)		= NULL
	,@toPayTrnTime		VARCHAR(20)		= NULL    
	,@rbankName         VARCHAR(50)		= NULL
	,@rbankBranch		VARCHAR(100)	= NULL
	,@rcheque			VARCHAR(50)		= NULL
	,@rAccountNo		VARCHAR(50)		= NULL
	,@TopupMobileNo		VARCHAR(50)		= NULL
	,@relationship		VARCHAR(100)	= NULL
	,@purpose			VARCHAR(100)	= NULL
	,@dob				DATETIME		= NULL
	,@rIssuedDate		DATETIME		= NULL
	,@rValidDate		DATETIME		= NULL
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON

	DECLARE 
		 @sBranch					INT
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
		,@sendingCustType			INT
		,@receivingCurrency			INT
		,@agentType					INT
		,@tokenId					BIGINT
		,@controlNoEncrypted		VARCHAR(20)
		,@commCheck					MONEY
		,@tranType					CHAR(1)
		,@pCountryId				INT = NULL
		,@deliveryMethodId			INT = NULL
		,@sCountryId				INT = NULL
		,@tranStatus				VARCHAR(20) = NULL
		,@pDistrictApi				INT
		,@pDistrictBranch			INT
		,@lockedBy					VARCHAR(50)
		,@tranId					INT
		,@sCountry					VARCHAR(200)
		,@pLocation					INT
		,@payTokenId				VARCHAR(50)
		,@payStatus					VARCHAR(50)
		,@receiverName				VARCHAR(100)
		,@complianceAction			CHAR(1)
		,@compApproveRemark			VARCHAR(200)
		,@msg						VARCHAR(200)
		,@IsSettlingAgent			CHAR(1)
	SELECT @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

	IF @flag = 'payTran'				
	BEGIN	
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
			,@pAmt				= pAmt
			,@pLocation			= pLocation
			,@tranStatus		= tranStatus
			,@lockedBy			= lockedBy
			,@payStatus			= payStatus
			,@receiverName		= receiverName
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
		SELECT 
			 @pLocationBranch = agentLocation
			,@pState = agentState
			,@pDistrict	= agentDistrict 
			,@IsSettlingAgent = isSettlingAgent
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
		
		SET @mapCodeDom = @pAgent
		IF @IsSettlingAgent = 'Y'
			SET @mapCodeDom = @pBranch

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
		IF (@payStatus = 'Paid')
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
		IF @rValidDate IS NOT NULL AND @rIdType <> 'Citizenship'
		BEGIN
			IF @rValidDate < CAST(CONVERT(VARCHAR,GETDATE(),101) AS DATETIME)
			BEGIN
				EXEC proc_errorHandler 1, 'Cannot process transaction, as Id is going to expire soon.', @customerId
				RETURN
			END  
		END
		--Location Verfication
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
	
		--Commission Calculation Start
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		SELECT @pCountryId = 151 
		SELECT @sCountryId = 151
	
		SELECT
			 @pAgentComm		= ISNULL(pAgentComm, 0)
			,@pSuperAgentComm	= ISNULL(psAgentComm, 0)
			,@commCheck			= pAgentComm
		FROM dbo.FNAGetDomesticPayComm(@sBranch, @pBranch, @deliveryMethodId, @pAmt)
	
		SELECT @pAgentCommCurrency = 'NPR', @pSuperAgentCommCurrency = 'NPR'
	
		IF @commCheck IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Commission not defined. Please contact HO', @controlNo
			RETURN
		END
				
		-------Compliance Check Begin----------
		IF NOT EXISTS(SELECT 'X' FROM remitTranCompliancePay WITH(NOLOCK) WHERE tranId = @tranId AND approvedDate IS NOT NULL)
		BEGIN

		DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @totalRows INT, @count INT, @compFinalRes VARCHAR(20), @result VARCHAR(MAX)
		DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
		
		INSERT @csMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetComplianceRuleMaster_Pay(@pBranch, @pCountryId, NULL, @pBranch, NULL, NULL, @customerId)
		SELECT @totalRows = COUNT(*) FROM @csMasterRec
		
		DECLARE @denyTxn CHAR(1) = 'N'
		IF EXISTS(SELECT 'X' FROM @csMasterRec)
		BEGIN
			DELETE FROM remitTranCompliancePayTemp WHERE tranId = @tranId
			SET @count = 1
			WHILE(@count <= @totalRows)
			BEGIN
				SELECT @csMasterId = masterId FROM @csMasterRec WHERE rowId = @count
				
				EXEC proc_complianceRuleDetail_Pay 
				 @user				= @user
				,@tranId			= @tranId
				,@tAmt				= @pAmt
				,@customerId		= @customerId			
				,@receiverId		= @rIdNumber 
				,@receiverMemId		= @membershipId			
				,@receiverName		= @receiverName 
				,@receiverMobile	= @rMobile
				,@receiverAcNo		= @rAccountNo
				,@masterId			= @csMasterId
				,@paymentMethod		= @deliveryMethodId
				,@checkingFor		= 'v'				
				,@result			= @complianceRes OUTPUT
								
				
				SET @compFinalRes = ISNULL(@compFinalRes, '') + ISNULL(@complianceRes, '')
				
				IF @complianceRes = 'M' AND ISNULL(@complianceAction, '') <> 'C'
					SET @complianceAction = 'M'
				IF @complianceRes = 'C' 
					SET @complianceAction = 'C'
				
				SET @count = @count + 1
			END
		END
		
		IF(ISNULL(@compFinalRes, '') <> '')
		BEGIN			
			IF(@compFinalRes <> '')
			BEGIN				
				IF EXISTS(SELECT 'X' FROM remitTranCompliancePayTemp WITH(NOLOCK) WHERE tranId = @tranId)
				BEGIN
					INSERT INTO remitTranCompliancePay(tranId, csDetailTranId, matchTranId)
					SELECT @tranId, csDetailTranId, matchTranId FROM remitTranCompliancePayTemp WITH(NOLOCK) WHERE tranId = @tranId
					
					
					INSERT tranPayCompliance(tranId,provider,controlNo,pBranch,receiverName,rMemId,dob,
					rIdType,rIdNumber,rPlaceOfIssue,rContactNo,rRelationType,rRelativeName,relWithSender,purposeOfRemit,createdBy,createdDate,bankName,branchName,chequeNo,accountNo,alternateMobileNo,IdIssuedDate,IdExpiryDate)					
					SELECT @tranId, '1002' , @controlNoEncrypted,@pBranch,@receiverName,@membershipId,@dob,
					@rIdType,@rIdNumber,@rPlaceOfIssue,@rMobile,@rRelationType,@rRelativeName,@relationship,@purpose,@user,GETDATE(),@rbankName,@rbankBranch,@rcheque,@raccountNo,@TopupMobileNo,@rIssuedDate,@rValidDate

					DELETE FROM dbo.remitTranCompliancePayTemp WHERE tranId = @tranId			
				END

				IF ISNULL(@complianceAction, '') = 'M'
					BEGIN
												
						UPDATE remitTran SET
							 tranStatus	= 'Hold'
						WHERE id = @tranId
					
						UPDATE remitTranCompliancePay SET
							 approvedRemarks	= 'Marked for Compliance'
							,approvedBy			= 'system'
							,approvedDate		= GETDATE()
						WHERE tranId = @tranId

						UPDATE tranPayCompliance SET
							 approvedRemarks	= 'Marked for Compliance'
							,approvedBy			= 'system'
							,approvedDate		= GETDATE()
						WHERE tranId = @tranId
					END
				ELSE
					BEGIN
						UPDATE remitTran SET
							 tranStatus	= 'Compliance Hold Pay'
						WHERE id = @tranId
					END

			END

			IF ISNULL(@complianceAction, '') = 'C'
				BEGIN					
					SET @msg = 'Sorry, This transaction is in compliance hold and cannot processed further. Please contact HO.'
				END
				
			SELECT 101 errorCode,@msg msg, NULL id
			RETURN
		END 

		END		
		
		-------Compliance Check End----------
		
		BEGIN TRANSACTION	
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
			,pState						= @pState
			,pLocation					= @pLocation
			,pDistrict					= @pDistrict
			,tranStatus					= 'Paid'
			,payStatus					= 'Paid'
			,paidDate					= dbo.FNAGetDateInNepalTZ()
			,paidDateLocal				= GETDATE()
			,paidBy						= @user			
		WHERE controlNo = @controlNoEncrypted

		UPDATE tranReceivers SET
			 idType2			= @rIdType
			,idNumber2			= @rIdNumber
			,idPlaceOfIssue2	= @rPlaceOfIssue
			,mobile				= @rMobile
			,homePhone			= @rMobile
			,relationType		= @rRelationType
			,relativeName		= @rRelativeName
			,customerId			= @customerId
			,membershipId		= @membershipId
			,bankName			= @rbankName
			,branchName			= @rbankBranch
			,chequeNo			= @rcheque
			,accountNo			= @raccountNo
			,relWithSender		= @relationship
			,purposeOfRemit		= @purpose
			,dob				= @dob
			,issuedDate2		= @rIssuedDate
			,validDate2			= @rValidDate
		WHERE tranId = @tranId

		IF @membershipId IS NOT NULL 
		BEGIN
			UPDATE dbo.customerMaster SET 
				paidTxn = ISNULL(paidTxn,0)+1,
				firstTxnDate = ISNULL(firstTxnDate,GETDATE()) 
			WHERE membershipId = @membershipId 
		END


		EXEC SendMnPro_Account.dbo.PROC_REMIT_DATA_UPDATE
			 @flag			= 'p'
			,@mapCode		= @mapCodeDom
			,@user			= @user
			,@pAgentComm	= @pAgentComm
			,@controlNo		= @controlNo
			
		-- ## Limit Update
		EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @pAmt ,@settlingAgent = @pBranch	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		EXEC [proc_errorHandler] 0, 'Transaction has been paid successfully', @controlNo	
	
	END
	
	IF @flag = 'paySearch'				
	BEGIN
		IF(DATEDIFF(MI,CAST(dbo.FNAGetDateInNepalTZ() AS TIME), CAST(@fromPayTrnTime AS TIME))) > 0
		BEGIN
			EXEC proc_errorHandler 1, 'You are not authorized to pay at this time', NULL
			RETURN
		END
		IF(DATEDIFF(MI,CAST(dbo.FNAGetDateInNepalTZ() AS TIME), CAST(@toPayTrnTime AS TIME))) < 0
		BEGIN
			EXEC proc_errorHandler 1, 'You are not authorized to pay at this time', NULL
			RETURN
		END
	
		DECLARE @hasRight CHAR(1), @payDomesticFunctionId VARCHAR(50)
		SET @payDomesticFunctionId = '40101311,40101520'
		SELECT @hasRight = dbo.FNAHasRight(@user, @payDomesticFunctionId)
		IF(@hasRight = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'You are not authorized to pay domestic transaction.', NULL
			RETURN
		END

		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Please relogin to the system.', @controlNo
			RETURN
		END

		SELECT @mapCodeDom = mapCodeDom
			,@agentType = agentType
			,@pLocation = agentLocation 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch

		IF (@mapCodeDom IS NULL OR @mapCodeDom = '' OR @mapCodeDom = 0)
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Map Code', NULL
			RETURN
		END
	
		SELECT 
			@tranStatus = tranStatus, 
			@tranId = id,
			@payStatus = payStatus
		FROM remitTran WITH(NOLOCK) 
		WHERE controlNo = @controlNoEncrypted
	
		IF @tranStatus IS NULL
		BEGIN
			EXEC proc_errorHandler 1000, 'Transaction not found', NULL
			RETURN
		END

		IF @agentType = 2903		
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
			IF (@payStatus = 'Paid')
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
			IF (@tranStatus <> 'Payment')
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction is not in authorized mode', @controlNoEncrypted
				RETURN
			END
			DECLARE @tranDistrictId INT, @payAgentDistrictId INT

			--Checking payout location for domestic txn
				
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
		
			-->>Start:Checking pay tran for 30 days expiry days & more than 3,00,000 transaction
			DECLARE @checkPayTran TABLE(tSetFlag VARCHAR(10), eSetFlag VARCHAR(10))
			DECLARE @tSetFlag VARCHAR(10), @eSetFlag VARCHAR(10)
			
			--INSERT INTO @checkPayTran(tSetFlag, eSetFlag)
			--EXEC proc_checkPayLock @user ='admin', @controlNo = @controlNoEncrypted, @agentId = @pBranch
			
			SELECT @tSetFlag = tSetFlag, @eSetFlag = eSetFlag FROM @checkPayTran
			--<<End:Checking pay tran for 30 days expiry days & more than 3,00,000 transaction
			
			--End of Validation
			SELECT 
				 trn.id
				,controlNo		= dbo.FNADecryptString(trn.controlNo)
				,sMemId			= sen.membershipId
				,sCustomerId	= sen.customerId
				,senderName		= sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
				,sCountryName	= sen.country
				,sStateName		= sen.state
				,sDistrict		= sen.district
				,sCity			= sen.city
				,sAddress		= sen.address
				,sContactNo		= COALESCE(sen.mobile, sen.homephone, sen.workphone)			
				,sIdType		= sen.idType
				,sIdNo			= sen.idNumber
				,sValidDate		= sen.validDate
				,sEmail			= sen.email			
				,rMemId			= rec.membershipId
				,rCustomerId	= rec.customerId
				,receiverName	= rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
				,rCountryName	= rec.country
				,rStateName		= rec.state
				,rDistrict		= rec.district
				,rCity			= rec.city
				,rAddress		= rec.address
				,rContactNo		= COALESCE(rec.mobile, rec.homephone, rec.workphone)
				,rIdType		= rec.idType
				,rIdNo			= rec.idNumber			
				,sAgent			= trn.sBranchName
				,sAgentCountry	= sa.agentCountry			
				,pBranchName	= ISNULL(trn.pBranchName, 'Any')
				,pCountryName	= trn.pCountry
				,pStateName		= trn.pState
				,pDistrictName	= trn.pDistrict
				,pLocationName	= pLoc.districtName
				,pAddress		= pa.agentAddress			
				,trn.tAmt
				,trn.serviceCharge
				,handlingFee	= ISNULL(trn.handlingFee, 0)
				,trn.cAmt
				,trn.pAmt			
				,relationship	= ISNULL(trn.relWithSender, '-')
				,purpose		= ISNULL(trn.purposeOfRemit, '-')
				,sourceOfFund	= ISNULL(trn.sourceOfFund, '-')
				,trn.pAmt
				,collMode		= trn.collMode
				,paymentMethod	= trn.paymentMethod
				,trn.payoutCurr
				,trn.tranStatus
				,trn.payStatus
				,payoutMsg		= ISNULL(trn.pMessage, '-')
				,send_agent		= COALESCE(trn.sBranchName, trn.sAgentName)
				,txn_date		= trn.createdDateLocal
				,payTokenId		= @payTokenId
				,tSetFlag		= @tSetFlag
				,eSetFlag		= @eSetFlag
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
