USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payIntTransaction]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_payIntTransaction](
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(20)		= NULL	
	,@agentRefId		VARCHAR(20)		= NULL
	,@rIdType			VARCHAR(30)		= NULL
	,@rIdNumber			VARCHAR(30)		= NULL
	,@rPlaceOfIssue		VARCHAR(50)		= NULL
	,@rMobile			VARCHAR(100)	= NULL
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
	,@topupMobileNo		varchar(50)		= null
	,@relationship		VARCHAR(100)	= NULL
	,@purpose			VARCHAR(100)	= NULL
	,@dob				DATETIME		= NULL
	,@rIssuedDate		DATETIME		= NULL
	,@rValidDate		DATETIME		= NULL
	,@complianceQuestion		NVARCHAR(MAX)	= NULL
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON

	DECLARE 
	     @sCountry					VARCHAR(200)
		,@sCountryId				INT 
		,@sBranch					INT
		,@sAgent					INT
		,@sSuperAgent				INT
		,@sSuperAgentName			VARCHAR(100)
		,@sLocation					INT
		,@pCountry					VARCHAR(100)
		,@pCountryId				INT
		,@pState					VARCHAR(100)
		,@pDistrict					VARCHAR(100)
		,@pLocation					INT
		,@deliveryMethod			VARCHAR(100)
		,@deliveryMethodId			INT 
		,@pAmt						MONEY
		,@cAmt						MONEY
		,@pAgentComm				MONEY
		,@pAgentCommCurrency		VARCHAR(3)
		,@pSuperAgentComm			MONEY
		,@pSuperAgentCommCurrency	VARCHAR(3)
		,@pHubComm					MONEY
		,@pHubCommCurrency			VARCHAR(3)
		,@collMode					INT
		,@receivingCurrency			INT
		,@senderId					INT
		,@agentType					INT
		,@actAsBranchFlag			CHAR(1)
		,@tokenId					BIGINT
		,@controlNoEncrypted		VARCHAR(20)
		,@commCheck					MONEY
		,@userId					int
		,@tranId					BIGINT
		,@serviceCharge				MONEY
		,@sRouteId					VARCHAR(5)
		,@lockStatus				VARCHAR(10)
		,@txnDate					DATETIME
		,@days						INT
		,@msg						VARCHAR(MAX)		
		,@complianceAction			CHAR(1)
		,@compApproveRemark			VARCHAR(200)	
		,@XMLDATA					XML	
	DECLARE 
		 @tranStatus VARCHAR(50)
		,@payTokenId VARCHAR(50)
		,@payStatus VARCHAR(50)
		,@sFullName VARCHAR(200)
		,@rFullName VARCHAR(200)
				
	SELECT @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)


	IF @flag = 'payTran' 
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Please relogin to the system.', @controlNo
			RETURN
		END	

		IF @pBranch IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid payout agent. Please select payout agent.', @controlNo
			RETURN
		END	

		-- ## Find Payout Agent Details
		SELECT
			 @pState			= agentState
			,@pDistrict			= agentDistrict
			,@pLocation			= agentLocation
			,@agentType			= agentType
			,@mapCodeInt		= mapCodeInt 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch 
	
		SELECT 
		     @tranId			= id
			,@pAmt				= pAmt
			,@cAmt				= cAmt
			,@deliveryMethod	= paymentMethod
			,@sCountry			= sCountry
			,@pCountry			= pCountry
			,@serviceCharge		= serviceCharge
			,@sAgent			= sAgent
			,@sBranch			= sBranch
			,@sRouteId			= sRouteId
			,@lockStatus		= lockStatus
			,@txnDate			= createdDateLocal
			,@tranStatus		= tranStatus
			,@payStatus			= payStatus
			,@sFullName			= senderName
			,@rFullName			= receiverName
			,@sSuperAgent		= sSuperAgent
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted

		IF EXISTS (SELECT 1 FROM tranModifyLog (NOLOCK) WHERE tranId = @tranId AND resolvedDate IS NULL AND [status] = 'Request')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction modification pending, Please contact HO!', NULL
			RETURN
		END
		
		IF ISNULL(@lockStatus, '') <> 'locked'
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, You need to Re-try for payment(Please submit within 5 Min after searching the transaction)', @controlNo
			RETURN
		END
		
		IF @deliveryMethod <> 'Cash Payment'
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot process for Payment, Invalid Payment Type', NULL
			RETURN
		END
		
		IF (@tranStatus <> 'Payment' OR @payStatus != 'Unpaid')
		BEGIN
			SET @msg = 'Transaction is not in authorized mode, Transtatus : ' + @tranStatus + ', PayStatus : ' + @paystatus
			EXEC proc_errorHandler 1, @msg, @controlNoEncrypted
			RETURN
		END

		--IF (@sSuperAgent = dbo.FNAGetIntlAgentId())
		--BEGIN
		--	EXEC proc_errorHandler 1, 'You can not pay transaction of same country!!', NULL
		--	RETURN
		--END

		IF @rValidDate IS NOT NULL AND @rIdType <> 'Citizenship'
		BEGIN
			IF @rValidDate < CAST(CONVERT(VARCHAR,GETDATE(),101) AS DATETIME)
			BEGIN
				EXEC proc_errorHandler 1, 'Cannot process transaction, as Id is going to expire soon.', @customerId
				RETURN
			END  
		END

		--## Start OFAC / Compliance 
		DECLARE 
			@receiverOfacRes VARCHAR(MAX),
			@ofacRes VARCHAR(MAX),
			@ofacReason VARCHAR(MAX),
			@senderOfacRes VARCHAR(MAX)

			--## checking for OFAC is already checked or not
		IF NOT EXISTS(SELECT 'x' FROM tranPayOfac WITH(NOLOCK) WHERE tranId = @tranId  AND provider = 4812 AND 1=2)
		BEGIN
			EXEC proc_ofacTracker @flag = 't', @name = @sFullName, @Result = @senderOfacRes OUTPUT
			EXEC proc_ofacTracker @flag = 't', @name = @rFullName, @Result = @receiverOfacRes OUTPUT		

			IF ISNULL(@senderOfacRes, '') <> ''
			BEGIN
				SET @ofacReason = 'Matched by sender name'
			END
			IF ISNULL(@receiverOfacRes, '') <> ''
			BEGIN
				SET @ofacRes = ISNULL(@senderOfacRes + ',' + @receiverOfacRes, '' + @receiverOfacRes)
				SET @ofacReason = 'Matched by receiver name'
			END
			IF ISNULL(@senderOfacRes, '') <> '' AND ISNULL(@receiverOfacRes, '') <> ''
			BEGIN
				SET @ofacReason = 'Matched by both sender name and receiver name'
			END

			IF ISNULL(@ofacRes, '') <> ''
			BEGIN
				INSERT tranPayOfac(tranId,provider, blackListId, reason, flag, pAmt,controlNo,pBranch,senderName,receiverName,txnDate,createdBy,createdDate,
				rMemId,rIdType,rIdNumber,rPlaceOfIssue,rContactNo,rRelationType,rRelativeName)
				SELECT @tranId, '4812' ,@ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes),@pAmt,@controlNoEncrypted,@pBranch,@sFullName,@rFullName,@txnDate,@user,GETDATE(),
				@membershipId,@rIdType,@rIdNumber,@rPlaceOfIssue,@rMobile,@rRelationType,@rRelativeName

				EXEC proc_errorHandler 1, 'Transaction is not in authorized mode, Please contact Head Office.', @controlNoEncrypted
				RETURN
			END
		END			
		--## checking for OFAC is approved or not
		IF EXISTS(SELECT 'x' FROM tranPayOfac WITH(NOLOCK) 
				WHERE tranId = @tranId		
					AND provider = 4812 
					AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode, Please contact Head Office.', @controlNoEncrypted
			RETURN
		END	
		
		-- ## Check Threshold Limit above or equal 300000
		IF NOT EXISTS(SELECT 'X' FROM txnThresholdLimit 
			WHERE controlNo = @controlNoEncrypted AND pAgent = @pBranch AND ISNULL(isActive, 'N') = 'Y'
			AND approvedDate IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE
						(sendingCountry = @sCountry OR sendingCountry IS NULL)
						AND agMaxLimitAmt >= @pAmt
						AND currency = 'NPR'
						AND (tranType = '1' OR tranType IS NULL)
						AND ISNULL(isActive, 'N') = 'Y'
						AND ISNULL(isDeleted, 'N') = 'N')
			BEGIN
				EXEC proc_errorHandler 1, 'You are not authorized to pay this much amount. Please contact HO for authorization.', @controlNo
				RETURN
			END
		END

		-- ## Check 30 days expiry date
		/*
		SELECT * FROM txnThresholdLimit
		ALTER TABLE txnThresholdLimit ADD remarks varchar(max)
		*/
		SET @days  =  DATEDIFF(DAY,@txnDate,GETDATE())
		IF @days > 30
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM txnThresholdLimit WITH(NOLOCK)
				WHERE controlNo = @controlNoEncrypted AND pAgent = @pBranch AND ISNULL(isActive, 'N') = 'Y'  
					AND approvedDate IS NOT NULL)
			BEGIN	
				SET @msg = 'You are not authorized to pay this transaction ('+CAST(@days AS VARCHAR)+' days old txn). Please contact head office for authorization.'
				EXEC proc_errorHandler 1, @msg, @controlNo
				RETURN				
			END
		END

		DECLARE @payPerTxn MONEY, @payPerDay MONEY, @payTodays MONEY
		SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
		SELECT @payPerDay = payPerDay, @payPerTxn = payPerTxn, @payTodays = ISNULL(payTodays, 0) 
			FROM userWiseTxnLimit WITH(NOLOCK) WHERE userId = @userId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
	
		IF(@pAmt > @payPerTxn)
		BEGIN
			EXEC proc_errorHandler 1, 'Transfer Amount exceeds user per Pay Transaction Limit.', @controlNoEncrypted
			RETURN
		END
		IF(@payTodays > @payPerDay)
		BEGIN
			EXEC proc_errorHandler 1, 'User Per Day Pay Transaction Limit exceeded.', @controlNoEncrypted
			RETURN
		END
	
		-- ## Commission Calculation Start
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry

		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'
		
		IF @sBranch IN (10069, 10070) ---GPL
		BEGIN
			SELECT 
				@pAgentComm = ISNULL(pAgentComm, 0) 
				,@pAgentCommCurrency = 'NPR'
				,@commCheck = ISNULL(pAgentComm, 0) 
			FROM dbo.FNAGetGIBLCommission(@pBranch, 0,1,'GPL')
		END
		IF @sBranch IN (9809, 9810) ---Gme-Korea 
		BEGIN
			SELECT 
				@pAgentComm = ISNULL(pAgentComm, 0) 
				,@pAgentCommCurrency = 'NPR'
				,@commCheck = ISNULL(pAgentComm, 0) 
			FROM dbo.FNAGetGIBLCommission(@pBranch, 0,1,'GPL')
		END
		ELSE
		BEGIN
			SELECT 
				 @pAgentComm			= ISNULL(amount, 0)
				,@pAgentCommCurrency	= commissionCurrency
				,@commCheck				= amount 
			FROM dbo.FNAGetPayComm(@sBranch, @sCountryId, @sLocation, @pSuperAgent, @pCountryId, @pLocation, @pBranch, 'NPR', 
									@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @pHubComm, @pSuperAgentComm)
		END

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
		IF EXISTS(SELECT 'X' FROM @csMasterRec WHERE 1=2)
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
				,@receiverName		= @rFullName 
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
					rIdType,rIdNumber,rPlaceOfIssue,rContactNo,rRelationType,rRelativeName,relWithSender,purposeOfRemit,createdBy,createdDate,IdIssuedDate,IdExpiryDate)					
					SELECT @tranId, '4812' , @controlNoEncrypted,@pBranch,@rFullName,@membershipId,@dob,
					@rIdType,@rIdNumber,@rPlaceOfIssue,@rMobile,@rRelationType,@rRelativeName,@relationship,@purpose,@user,GETDATE(),@rIssuedDate,@rValidDate

				

					DELETE FROM dbo.remitTranCompliancePayTemp WHERE tranId = @tranId			
				END

				IF ISNULL(@complianceAction, '') <> ''
					BEGIN
												
						--UPDATE remitTran SET
						--	 tranStatus	= 'Hold'
						--WHERE id = @tranId
					
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
			END			
		END 

		END		
		
		-------Compliance Check End----------


		BEGIN TRANSACTION
		UPDATE remitTran SET
			 pAgentComm					= @pAgentComm
			,pAgentCommCurrency			= @pAgentCommCurrency
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
			,paidDateLocal				= GETDATE()
			,paidBy						= @user
			,lockStatus					= 'unlocked'			
		WHERE controlNo = @controlNoEncrypted

		UPDATE tranReceivers SET
			 idType2			= @rIdType
			,idNumber2			= @rIdNumber
			,idPlaceOfIssue2	= @rPlaceOfIssue
			,mobile				= @rMobile
			,homePhone			= @rMobile
			,customerId			= @customerId
			,membershipId		= @membershipId
			,relationType		= @rRelationType
			,relativeName		= @rRelativeName
			,bankName			= @rbankName
			,branchName			= @rbankBranch
			,chequeNo			= @rcheque
			,accountNo			= @raccountNo
			,workPhone			= @topupMobileNo
			,relWithSender		= @relationship
			,purposeOfRemit		= @purpose
			,dob				= @dob
			,issuedDate2		= @rIssuedDate
			,validDate2			= @rValidDate
		WHERE tranId = @tranId

		IF ISNULL(@complianceQuestion, '') <> ''
		BEGIN
			SET @XMLDATA = CONVERT(XML, REPLACE(@complianceQuestion,'&','&amp;'), 2) 

			SELECT  answer = p.value('@answer', 'varchar(150)') ,
					qType = p.value('@qType', 'varchar(500)'),
					qId = p.value('@qId', 'varchar(500)')
			INTO #TRANSACTION_COMPLIANCE_QUESTION
			FROM @XMLDATA.nodes('/root/row') AS tmp ( p );
		
			INSERT INTO TBL_TXN_COMPLIANCE_CDDI
			SELECT @tranId, qId, answer
			FROM #TRANSACTION_COMPLIANCE_QUESTION
		END
		IF @membershipId IS NOT NULL 
		BEGIN
			UPDATE dbo.customerMaster SET 
				paidTxn = ISNULL(paidTxn,0)+1,
				firstTxnDate = ISNULL(firstTxnDate,GETDATE()) 
			WHERE membershipId = @membershipId 
		END
		SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
		UPDATE userWiseTxnLimit	SET
				payTodays = ISNULL(payTodays, 0) + @pAmt
		WHERE userId = @userId AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'	

		-- ## Start Send SMS To Sender
		DECLARE @parentMapCode	VARCHAR(8)
			   ,@smsToSender	CHAR(1)
			   ,@sMobile		VARCHAR(100)
	
		SELECT @sMobile = mobile FROM tranSenders WHERE tranId = @tranId
		SELECT @smsToSender = ISNULL(SendSMSToSender,'N')
				FROM agentBusinessfunction WITH(NOLOCK) WHERE agentId = @sAgent

		
		
		-- ## Limit Update
		EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @pAmt ,@settlingAgent = @pBranch
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SELECT 0 errorCode,  msg='Transaction has been paid successfully', @controlNo id,payoutCommission= @pAgentComm	


	END		
	
	IF @flag = 'paySearch'				
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Please relogin to the system.', @controlNo
			RETURN
		END

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

		IF @pBranch IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please Choose Agent', NULL
			RETURN
		END

		SELECT 
			 @mapCodeInt = mapCodeInt
			,@agentType = agentType
			,@pLocation = agentLocation 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch

		IF (@mapCodeInt IS NULL OR @mapCodeInt = '' OR @mapCodeInt = 0)
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Map Code', NULL
			RETURN
		END
	
		SELECT 
				@tranStatus		= tranStatus, 
				@tranId			= id, 
				@lockStatus		= lockStatus,
				@payStatus		= payStatus,
				@sSuperAgent		= sSuperAgent
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
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
			IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND paymentMethod = 'Cash Payment')
			BEGIN
				EXEC proc_errorHandler 1, 'Cannot process for Payment, Invalid Payment Type', NULL
				RETURN	
			END
			--IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND sBranch = @pBranch) 
			--BEGIN
			--	EXEC proc_errorHandler 1, 'Cannot process payment for same POS', @tranId
			--	RETURN
			--END
		IF (@tranStatus <> 'Payment' OR @payStatus != 'Unpaid')
		BEGIN
			SET @msg = 'Transaction is not in authorized mode, Transtatus : ' + @tranStatus + ', PayStatus : ' + @paystatus
			EXEC proc_errorHandler 1, @msg, @controlNoEncrypted
			RETURN
		END
		--IF (@sSuperAgent = dbo.FNAGetIntlAgentId())
		--BEGIN
		--	EXEC proc_errorHandler 1, 'You can not pay transaction of same country!!', NULL
		--	RETURN
		--END
			DECLARE @tranDistrictId INT, @payAgentDistrictId INT

			EXEC proc_errorHandler 0, 'Transaction Verification Successful', @tranId
		
			-- ## Checking 30 days expiry days & more than 3,00,000 pAmt
			DECLARE @checkPayTran TABLE (tSetFlag VARCHAR(10), eSetFlag VARCHAR(10))
			DECLARE @tSetFlag VARCHAR(10),@eSetFlag VARCHAR(10)
		
			SELECT @tSetFlag = tSetFlag, @eSetFlag = eSetFlag FROM @checkPayTran

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
		
			-- ## Lock Transaction
			UPDATE remitTran SET 
				 payTokenId			= @payTokenId
				,lockStatus			= 'locked'
				,lockedBy			= @user
				,lockedDate			= GETDATE()
				,lockedDateLocal	= GETDATE()
			WHERE controlNo = @controlNoEncrypted
					
			-- ## Log Details
			SELECT 
				 [message]
				,trn.createdBy
				,trn.createdDate
			FROM tranModifyLog trn WITH(NOLOCK)
			WHERE trn.tranId = @tranId OR ISNULL(trn.controlNo,'') = ISNULL(@controlNoEncrypted, '')
			ORDER BY trn.createdDate DESC
		END
	END












GO
