USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_MaxMoneyPayHistory]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_MaxMoneyPayHistory](
	 @flag						VARCHAR(50)
	,@user						VARCHAR(50) 			
	,@rowId						BIGINT			= NULL
	,@payTokenId				VARCHAR(100)	= NULL
	,@refNo						VARCHAR(100)	= NULL
	,@benefName					VARCHAR(100)	= NULL
	,@benefCity					VARCHAR(100)	= NULL
	,@benefMobile				VARCHAR(100)	= NULL
	,@benefAddress				VARCHAR(100)	= NULL
	,@benefAccIdNo				VARCHAR(100)	= NULL
	,@benefIdType				VARCHAR(100)	= NULL
	,@benefCountry				VARCHAR(100)	= NULL
	,@benefIdNo					VARCHAR(100)	= NULL
	,@senderName				VARCHAR(100)	= NULL
	,@senderAddress				VARCHAR(100)	= NULL
	,@senderCity				VARCHAR(100)	= NULL
	,@senderMobile				VARCHAR(100)	= NULL
	,@senderIdType				VARCHAR(100)	= NULL
	,@senderIdNo				VARCHAR(100)	= NULL
	,@senderCountry				VARCHAR(100)	= NULL
	,@pCCY						VARCHAR(100)	= NULL
	,@pCommission				VARCHAR(100)	= NULL
	,@pCurrency					VARCHAR(100)	= NULL
	,@pAgent					VARCHAR(100)	= NULL
	,@pBranch					INT				= NULL
	,@pUser						VARCHAR(100)	= NULL
	,@payemntType				VARCHAR(100)	= NULL
	,@createdDate				DATETIME		= NULL
	,@createdBy					VARCHAR(30)		= NULL
	,@paidDate					DATETIME		= NULL
	,@paidBy					VARCHAR(30)		= NULL
	,@payResponseCode			VARCHAR(20)		= NULL
	,@payResponseMsg			VARCHAR(100)	= NULL
	,@recordStatus				VARCHAR(50)		= NULL
	,@message					VARCHAR(500)	= NULL
	,@txnDate					VARCHAR(100)	= NULL
	,@status					VARCHAR(100)	= NULL
	,@remittanceEntryDt			VARCHAR(100)	= NULL
	,@remittanceAuthorizedDt	VARCHAR(100)	= NULL
	,@remitType					VARCHAR(100)	= NULL
	,@rCurrency					VARCHAR(100)	= NULL
	,@Pamount					VARCHAR(100)	= NULL
	,@localAmount				VARCHAR(100)	= NULL
	,@exchangeRate				VARCHAR(100)	= NULL
	,@dollarRate				VARCHAR(100)	= NULL
	,@TPAgentID					VARCHAR(100)	= NULL
	,@TPAgentName				VARCHAR(100)	= NULL
	,@payConfirmationNo			VARCHAR(100)	= NULL	
	,@apiStatus					VARCHAR(100)	= NULL
	,@tranPayProcess			VARCHAR(20)		= NULL
	,@pBranchName				VARCHAR(100)	= NULL
	,@pAgentName				VARCHAR(100)	= NULL
	,@rIdType					VARCHAR(30)		= NULL
	,@rIdNumber					VARCHAR(30)		= NULL
	,@rIdPlaceOfIssue			VARCHAR(50)		= NULL
	,@rIssuedDate				DATETIME		= NULL
	,@rValidDate				DATETIME		= NULL
	,@rDob						DATETIME		= NULL
	,@rAddress					VARCHAR(100)	= NULL
	,@rOccupation				VARCHAR(100)	= NULL
	,@rContactNo				VARCHAR(50)		= NULL
	,@rCity						VARCHAR(100)	= NULL
	,@rNativeCountry			VARCHAR(100)	= NULL
	,@relationType				VARCHAR(50)		= NULL
	,@relativeName				VARCHAR(100)	= NULL
	,@remarks					VARCHAR(500)	= NULL
	,@approveBy					VARCHAR(30)		= NULL
	,@approvePwd				VARCHAR(100)	= NULL
	,@sCountry					VARCHAR(100)    = NULL
	,@agentName					VARCHAR(100)	= NULL
	,@provider					VARCHAR(100)	= NULL
	,@sortBy					VARCHAR(50)		= NULL
	,@sortOrder					VARCHAR(5)		= NULL
	,@pageSize					INT				= NULL
	,@pageNumber				INT				= NULL
	,@customerId				VARCHAR(50)		= NULL
	,@membershipId				VARCHAR(50)		= NULL
	,@rbankName					VARCHAR(50)		= NULL
	,@rbankBranch				VARCHAR(100)	= NULL
	,@rcheque					VARCHAR(50)		= NULL
	,@rAccountNo				VARCHAR(50)		= NULL
	,@topupMobileNo				varchar(50)		= null
	,@relationship				VARCHAR(100)	= NULL
	,@purpose					VARCHAR(100)	= NULL
	,@sBranchMapCOdeInt			INT				= NULL
	,@paymentType				VARCHAR(50)		= NULL
	,@tranMode					VARCHAR(50)		= NULL
	,@tranNo 					VARCHAR(50)		= NULL
	,@bankName					VARCHAR(150)	= NULL
	,@bankBranch 				VARCHAR(150)	= NULL
	,@bankAccNo 				VARCHAR(50)		= NULL
	,@partnerId					VARCHAR(25)		= NULL
	,@pBranchId					VARCHAR(25)		= NULL
)
AS
SET XACT_ABORT ON
BEGIN TRY
	DECLARE @refNoEnc VARCHAR(100) = dbo.FNAEncryptString(@refNo)
	IF @flag = 's'
	BEGIN
		DECLARE @agentGrp INT,@cotrolNo VARCHAR(50), @branchName VARCHAR(200)
		IF @pBranchId IS NOT NULL
			SELECT @branchName = agentName, @agentGrp = agentGrp FROM agentMaster am WITH(NOLOCK) WHERE agentId = @pBranchId

		
	END

	IF @flag = 'i' 
	BEGIN
		if EXISTS (SELECT 'X' FROM dbo.maxMoneyPayHistory WITH(NOLOCK) WHERE  refNo = @refNoEnc)
		BEGIN
		    UPDATE dbo.maxMoneyPayHistory SET 
						recordStatus = 'EXPIRED'
			WHERE refNo = @refNoEnc AND recordStatus <> 'READYTOPAY'
		END

		IF @pBranch IS NULL
			SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user

		INSERT INTO dbo.maxMoneyPayHistory
		        ( refNo ,
		          tokenId ,
		          benefName ,
		          benefAddress ,
		          benefMobile ,
		          benefCity ,
		          benefCountry ,
		          benefIdType ,
		          benefIdNo ,
		          benefAccIdNo ,
		          senderName ,
		          senderAddress ,
		          senderCity ,
		          senderMobile ,
		          senderCountry ,
		          senderIdType ,
		          senderIdNo ,
		          pCurrency ,
		          payemntType ,
		          createdDate ,
		          createdBy ,
		          txnDate ,
		          [status] ,
				  tranMode ,
				  tranNo ,
				  bankName ,
				  bankBranch ,
				  bankAccNo ,
				  remittanceEntryDt ,
				  amount
		        )
		VALUES  ( @refNoEnc , -- refNo - varchar(100)
		          @payTokenId , -- payTokenId - varchar(100)
		          @benefName , -- benefName - varchar(100)
		          @benefAddress , -- benefAddress - varchar(100)
		          @benefMobile , -- benefMobile - varchar(100)
		          @benefCity , -- benefCity - varchar(100)
		          @benefCountry , -- benefCountry - varchar(100)
		          @benefIdType , -- benefIdType - varchar(100)
		          @benefIdNo , -- benefIdNo - varchar(100)
		          @benefAccIdNo , -- benefAccIdNo - varchar(100)
		          @senderName , -- senderName - varchar(100)
		          @senderAddress , -- senderAddress - varchar(100)
		          @senderCity , -- senderCity - varchar(100)
		          @senderMobile , -- senderMobile - varchar(100)
		          @senderCountry , -- senderCountry - varchar(100)
		          @senderIdType , -- senderIdType - varchar(100)
		          @senderIdNo , -- senderIdNo - varchar(100)
		          @pCurrency , -- pCurrency - varchar(100)
		          @paymentType , -- pUser - varchar(100)
		          GETDATE() , -- payemntType - varchar(100)
		          @user , -- createdDate - datetime
		          @txnDate , -- createdBy - varchar(30)
		          @status , -- paidDate - datetime
		          @tranMode , -- paidBy - varchar(30)
		          @tranNo , -- message - varchar(500)
		          @bankName , -- txnDate - varchar(100)
		          @bankBranch , -- status - varchar(100)
		          @bankAccNo ,  -- payResponseCode - varchar(20)
				  @remittanceEntryDt ,
				  @Pamount
		        )
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
	END

	IF @flag = 'readyToPay'
	BEGIN
		UPDATE dbo.maxMoneyPayHistory SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = isnull(@pBranch,pBranch)
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber 
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = @rValidDate
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks 	  	 = @remarks 
			,rBank			 = @rbankName
			,rBankBranch	 = @rbankBranch
			,rAccountNo		 = @rAccountNo
			,rChequeNo		 = @rcheque
			,customerId		 = @customerId
			,membershipId	 = @membershipId
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose
			,rIssueDate		 = @rIssuedDate				
		WHERE rowId = @rowId
		SELECT @Pamount = amount FROM dbo.maxMoneyPayHistory WITH(NOLOCK) WHERE rowId = @rowId
		SELECT '0' errorCode, 'Ready to pay has been recorded successfully.' msg, 'Nepal' id, @Pamount extra
		RETURN
	END

	IF @flag = 'payError'
	BEGIN
		UPDATE dbo.maxMoneyPayHistory SET 
				recordStatus	 = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg  = @payResponseMsg 		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END

	IF @flag IN ('pay', 'restore')
	BEGIN
		IF NOT EXISTS(
			SELECT 'x' FROM dbo.maxMoneyPayHistory WITH(NOLOCK) 
			WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') 
				AND rowid = @rowid )
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
			RETURN
		END
		 
		DECLARE
			 @tranId					BIGINT
			,@tranIdTemp				BIGINT 
			,@pSuperAgent				INT 
			,@pSuperAgentName			VARCHAR(100)
			,@pCountry					VARCHAR(100)
			,@pState					VARCHAR(100)
			,@pDistrict					VARCHAR(100)
			,@pLocation					INT
			,@pAgentComm				MONEY
			,@pAgentCommCurrency		VARCHAR(3)
			,@pSuperAgentComm			MONEY
			,@pSuperAgentCommCurrency	VARCHAR(3)						
			,@sAgent					INT	 
			,@sAgentName				VARCHAR(100)
			,@sBranch					INT 
			,@sBranchName				VARCHAR(100)
			,@sSuperAgent				INT
			,@sSuperAgentName			VARCHAR(100) 
			,@sAgentMapCode				INT = 1075
	 		,@sBranchMapCode			INT = @sBranchMapCOdeInt
			--,@purposeOfRemit			VARCHAR(100) = NULL
			,@pBankBranch				VARCHAR(100) = NULL
			,@sAgentSettRate			VARCHAR(100) = NULL
			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			,@cAmt						MONEY
			,@tAmt						MONEY
			,@ServiceCharge				MONEY
			,@beneIdNo					INT
			,@customerRate				MONEY
			,@payoutCurr				VARCHAR(50)
			,@collCurr					VARCHAR(50)			 		
			,@MapCodeIntBranch			VARCHAR(50) 
			,@companyId					INT = 16
			,@ControlNoModified			VARCHAR(50)
			,@controlNo					VARCHAR(50)
			,@sCountryId				INT

		SELECT
			 @refNo						= km.refNo
			,@benefName					= km.benefName
			,@benefMobile				= km.benefMobile 
			,@benefAddress				= km.benefAddress
			,@benefAccIdNo				= km.benefAccIdNo
			,@benefIdType				= km.benefIdType
			,@senderName				= km.senderName
			,@senderAddress 			= km.senderAddress
			,@senderMobile				= km.senderMobile 
			,@senderIdType				= km.senderIdType 
			,@senderIdNo				= km.senderIdNo 
			,@remittanceEntryDt			= km.remittanceEntryDt
			,@remittanceAuthorizedDt	= km.remittanceAuthorizedDt
			,@remitType					= km.remitType
			,@rCurrency					= km.rCurrency 
			,@pCurrency					= km.pCurrency
			,@pCommission				= km.pCommission
			,@Pamount					= km.amount
			,@localAmount				= km.localAmount
			,@exchangeRate				= km.exchangeRate
			,@dollarRate				= km.dollarRate
			,@apiStatus					= km.apiStatus
			,@recordStatus				= km.recordStatus
			,@rIdType					= km.rIdType
			,@rIdNumber					= km.rIdNumber
			,@rValidDate				= km.rValidDate
			,@rIssuedDate				= km.rIssueDate
			,@rDob						= km.rDob
			,@rOccupation				= km.rOccupation
			,@rNativeCountry			= km.nativeCountry
			,@pBranch					= isnull(@pBranch,km.pBranch)
			,@rIdPlaceOfIssue			= km.rIdPlaceOfIssue
			,@relationType				= km.relationType
			,@relativeName				= km.relativeName
			,@tpAgentId					= km.tpAgentId
			,@rbankName					= rBank
			,@rbankBranch				= rBankBranch
			,@rcheque					= rAccountNo
			,@rAccountNo				= rChequeNo
			,@membershipId				= membershipId
			,@customerId				= customerId
			,@purpose					= purposeOfRemit
			,@relationship				= relWithSender
		FROM dbo.maxMoneyPayHistory km WITH(NOLOCK)
		WHERE rowId = @rowId
		
		SET @ControlNoModified = @refNo

		SELECT TOP 1
			@sCountry = cm.countryName,
			@sCountryId = cm.countryId
		FROM countryMaster cm WITH(NOLOCK) INNER JOIN countryCurrency cc WITH(NOLOCK) ON cm.countryId = cc.countryId
		INNER JOIN currencyMaster currM WITH(NOLOCK) ON currM.currencyId = cc.currencyId
		WHERE currM.currencyCode = @rCurrency
			AND isOperativeCountry  ='Y'
		AND ISNULL(cc.isDeleted,'N') = 'N'

		SELECT 
				@pAgent = parentId, 
				@pBranchName = agentName, 
				@agentType = agentType,
				@pCountry = agentCountry,
				@pState = agentState,
				@pDistrict = agentDistrict,
				@pLocation = agentLocation,
				@MapCodeIntBranch  = mapCodeInt  
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
		
		--## Check if controlno exist in remittran. 		
		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified)
		BEGIN
			DECLARE @msg VARCHAR(100)
			SELECT  
					@agentName = sAgentName
				,@status = payStatus	
			FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified
			SET @msg = 'This transaction belongs to ' + @agentName + ' and is in status: ' + @status
			EXEC proc_errorHandler 1,@msg,NULL
			RETURN
		END

		--## Set paying agent details.
		SELECT 
			@pAgent = parentId, 
			@pBranchName = agentName, 
			@agentType = agentType,
			@pCountry = agentCountry,
			@pState = agentState,
			@pDistrict = agentDistrict,
			@pLocation = agentLocation,
			@MapCodeIntBranch=mapCodeInt  
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
		
		IF @agentType = 2903
			SET @pAgent = @pBranch
		
		--## Check if txn exist in remitTran but not in Inficare system.
		DECLARE	
				@remitTrandate DATETIME
			,@remitTrandateNepal DATETIME
		
		SELECT 
				@tranId = id
			,@remitTrandate = paidDate
			,@remitTrandateNepal = paidDateLocal
			,@pAgentComm = pAgentComm 
			,@remitTrandate = GETDATE()
			,@remitTrandateNepal = dbo.FNAGetDateInNepalTZ()
		FROM remitTran  WITH(NOLOCK) WHERE controlNo = @ControlNoModified


		--## 1. Find Sending Agent Details
		SELECT  @sBranch = agentId, 
				@sAgent = parentId, 
				@sBranchName = agentName, 
				@agentType = agentType 
		FROM agentMaster WITH(NOLOCK) 
		WHERE mapCodeInt = @sBranchMapCode AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @agentType = 2903
		BEGIN
			SET @sAgent = @sBranch
		END
		
		SELECT  @sSuperAgent = parentId, 
				@sAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent

		SELECT @sSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
	
		--## 2. Find Payout Agent Details
		SELECT  @pSuperAgent = parentId, 
				@pAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		
		DECLARE @deliveryMethodId INT, @pCommCheck MONEY
		
		SELECT @payoutMethod = 'Cash Payment',@collCurr='MYR'
		DECLARE @pCountryId INT = NULL
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'				

		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'

		----## 3. Find Commission 
		--DECLARE @deliveryMethodId INT, @pCommCheck MONEY
		
		--SET @payoutMethod = 'Cash Payment'
		--DECLARE @pCountryId INT = NULL
		--SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		--SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		--WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'				

		--SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'

		--SELECT 
		--	@pAgentComm = ISNULL(pAgentComm, 0) 
		--FROM dbo.FNAGetGIBLCommission(@sBranch, @sCountryId,@deliveryMethodId,@Pamount)

		--SET @pAgentComm = @pCommission

		SELECT 
			@pAgentComm = ISNULL(pAgentComm, 0) 
		FROM dbo.FNAGetGIBLCommission(@sBranch, @ControlNoModified,@deliveryMethodId,'MAX')

		DECLARE @sCurrCostRate MONEY,@sCurrHoMargin MONEY,@sCurrAgentMargin MONEY,@pCurrCostRate MONEY
		,@pCurrHoMargin MONEY,@pCurrAgentMargin MONEY,@agentCrossSettRate MONEY
		--## EXCHANGE RATE 
		SELECT 
			 @customerRate			= customerRate
			,@sCurrCostRate			= sCurrCostRate
			,@sCurrHoMargin			= sCurrHoMargin
			,@sCurrAgentMargin		= sCurrAgentMargin
			,@pCurrCostRate			= pCurrCostRate
			,@pCurrHoMargin			= pCurrHoMargin
			,@pCurrAgentMargin		= pCurrAgentMargin
			,@agentCrossSettRate	= agentCrossSettRate
		FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurrency,@deliveryMethodId)

		--## GET SERVICE CHARGE 
		SET @tAmt= @Pamount/@customerRate

		SELECT @ServiceCharge = AMOUNT FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch
				,@pCountryId,null,@pAgent,@PBranch,@deliveryMethodId,@tAmt,@collCurr)

		SET @cAmt = @tAmt + isnull(@ServiceCharge,0)

		BEGIN TRANSACTION
		BEGIN
		--## Inserting Data in remittran table 
			INSERT INTO remitTran (	 
			[controlNo],[senderName],[sCountry],[sSuperAgent],[sSuperAgentName],[paymentMethod]	,[cAmt],[pAmt]				
			,[tAmt],[customerRate],[pAgentComm]	,[payoutCurr],[pAgent],[pAgentName]	,[pSuperAgent],[pSuperAgentName]
			,[receiverName]	,[pCountry],[pBranch],[pBranchName]	,[pState],[pDistrict],[pLocation],[pbankName],[purposeofRemit]
			,[pMessage]	,[pBankBranch],[sAgentSettRate]	,[createdDate],[createdDateLocal],[createdBy],[approvedDate]				
			,[approvedDateLocal],[approvedBy],[paidBy],[paidDate]	,[paidDateLocal],[serviceCharge]			
			,sCurrCostRate,pCurrCostRate,agentCrossSettRate,sCurrHoMargin,sCurrAgentMargin							
			--## hardcoded parameters			
			,[tranStatus],[payStatus],[collCurr],[controlNo2],[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName]					
					)
		SELECT
			@ControlNoModified,@senderName,isnull(@sCountry,'Qatar'),@sSuperAgent,@sSuperAgentName,'Cash Payment',@cAmt,@Pamount
			,@tAmt,@customerRate,@pAgentComm,@pCurrency,@pAgent,@pAgentName,@pSuperAgent,@pSuperAgentName 
			,@benefName	,@pCountry,@pBranch,@pBranchName,@pState,@pDistrict,@pLocation,@bankName,@purpose
			,@remarks,@pBankBranch,@SagentsettRate,dbo.FNAGetDateInNepalTZ() ,GETDATE(),'SWIFT:API',dbo.FNAGetDateInNepalTZ()
			,GETDATE(),'SWIFT:API',@user,dbo.FNAGetDateInNepalTZ(),GETDATE(),@ServiceCharge
			,@sCurrCostRate,@pCurrCostRate,@agentCrossSettRate,@sCurrHoMargin,@sCurrAgentMargin
			--## HardCoded Parameters
			,'Paid','Paid',@collCurr,@refNo,'I',@sAgent,@sAgentName,@sBranch,@sBranchName
					
				SET @tranId = SCOPE_IDENTITY()

				--## Inserting Data in tranSenders table
				INSERT INTO tranSenders	(
						tranId
					,firstName
					,country
					,[address]
					,idType
					,idNumber
					,mobile
					)
				SELECT
						@tranId			
					,@senderName
					,@sCountry	
					,@senderAddress
					,@senderIdType	
					,@senderIdNo
					,@senderMobile
				
				--## Inserting Data in tranReceivers table
				INSERT INTO tranReceivers (
						tranId
					,firstName
					,country
					,city
					,[address]
					,mobile
					,idType2
					,idNumber2
					,dob
					,occupation
					,validDate
					,idPlaceOfIssue
					,relationType
					,relativeName
					,bankName
					,branchName
					,chequeNo
					,accountNo
					,membershipId
					,customerId
					,relWithSender
					,purposeOfRemit
					,issuedDate2
					,validDate2
					)		
				SELECT 
						@tranId			
					,@benefName
					,@pCountry
					,@benefAddress
					,@benefAddress	
					,@benefMobile
					,@rIdType	
					,@rIdNumber
					,@rDob
					,@rOccupation
					,@rValidDate
					,@rIdPlaceOfIssue
					,@relationType
					,@relativeName
					,@rbankName
					,@rbankBranch
					,@rcheque
					,@raccountNo
					,@membershipId
					,@customerId
					,@relationship
					,@purpose
					,@rIssuedDate
					,@rValidDate
			
			/*
			UPDATE remitTranCompliancePay SET
					tranId	= @tranId							
			WHERE tranId = @tranIdTemp
			*/
			--UPDATE tranPayCompliance SET
			--tranId	= @tranId
			--WHERE tranId = @tranIdTemp
			/*
			IF @membershipId IS NOT NULL
			BEGIN
				UPDATE dbo.customerMaster SET 
					paidTxn = ISNULL(paidTxn,0)+1,
					firstTxnDate = ISNULL(firstTxnDate,GETDATE()) 
				WHERE membershipId = @membershipId 
			END
			*/
			--## Updating Data in globalBankPayHistory table by paid status
			UPDATE dbo.maxMoneyPayHistory SET 
					recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg
				,confirmationNo	 = @payConfirmationNo
				,paidDate		 = GETDATE()
				,totalComm		 = @pCommission
				,paidBy			 = @user			
			WHERE rowId = @rowId
			-- ## Limit Update
			EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @Pamount ,@settlingAgent = @pBranch
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SET @msg = 
				CASE 
					WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
					ELSE 'Transaction paid successfully'
				END

		EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @ControlNoModified
		SET @controlNo = dbo.fnadecryptstring(@ControlNoModified)
		EXEC [proc_errorHandler] 0, @msg, @controlNo
		RETURN
	END	

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
END CATCH

GO
