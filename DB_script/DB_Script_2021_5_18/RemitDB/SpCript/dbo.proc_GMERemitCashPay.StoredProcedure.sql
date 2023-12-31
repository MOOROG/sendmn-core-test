USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GMERemitCashPay]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_GMERemitCashPay](
	 @flag						VARCHAR(50)
	,@user						VARCHAR(50) 			
	,@rowId						BIGINT			= NULL
	,@payTokenId				VARCHAR(100)	= NULL
	,@refNo						VARCHAR(100)	= NULL

	,@benefName					VARCHAR(100)	= NULL
	,@benefCity					VARCHAR(100)	= NULL
	,@benefMobile				VARCHAR(100)	= NULL
	,@benefAddress				VARCHAR(100)	= NULL
	,@benefCountry				VARCHAR(100)	= NULL

	,@senderName				VARCHAR(100)	= NULL
	,@senderAddress				VARCHAR(100)	= NULL
	,@senderCity				VARCHAR(100)	= NULL
	,@senderMobile				VARCHAR(100)	= NULL
	,@senderCountry				VARCHAR(100)	= NULL

	,@pCurrency					VARCHAR(100)	= NULL
	,@paymentType				VARCHAR(100)	= NULL
	,@payResponseCode			VARCHAR(20)		= NULL
	,@payResponseMsg			VARCHAR(100)	= NULL
	,@message					VARCHAR(500)	= NULL
	,@txnDate					VARCHAR(100)	= NULL
	,@pAmount					VARCHAR(100)	= NULL
	,@pCommission				VARCHAR(10)		= NULL
	,@pConfirmId				VARCHAR(100)	= NULL
		
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
	,@relationship				VARCHAR(100)	= NULL
	,@purpose					VARCHAR(100)	= NULL
	,@tranNo 					VARCHAR(50)		= NULL
	,@partnerId					VARCHAR(25)		= NULL
	,@sessionId					VARCHAR(50)		= NULL
	,@senderAgent				VARCHAR(50)		= NULL
	,@pBranch					INT				= NULL
	,@rbankBranch				VARCHAR(100)	= NULL
	,@rbankName					VARCHAR(100)	= NULL
	,@rAccountNo				VARCHAR(50)		= NULL
	,@rcheque					VARCHAR(50)		= NULL
	,@sBranchMapCOdeInt			INT				= NULL
	,@sendAgent					VARCHAR(100)	= NULL
	,@benefIdNumber				VARCHAR(30)		= NULL
	,@benefIdType				VARCHAR(50)		= NULL
	,@remittanceEntryDt			VARCHAR(30)		= NULL
	,@tranMode					VARCHAR(30)		= NULL
	,@customerId				VARCHAR(30)		= NULL
	,@membershipId				VARCHAR(30)		= NULL
	,@sCountry					VARCHAR(30)		= NULL
	,@payConfirmationNo			VARCHAR(30)		= NULL
	--new addition
    ,@sAmount					VARCHAR(100)	= NULL
    ,@incomeSource				VARCHAR(100)	= NULL
    ,@calculateBy				VARCHAR(100)	= NULL
	,@pCurrCostRate				MONEY			= NULL
	,@sCurrCostRate				MONEY			= NULL
	,@pBranchName				VARCHAR(100)    = NULL

)
AS
SET XACT_ABORT ON
SET NOCOUNT ON
BEGIN TRY
	DECLARE @refNoEnc VARCHAR(100) = dbo.FNAEncryptString(@refNo)
	IF @flag = 's'
	BEGIN
		DECLARE @agentGrp INT,@cotrolNo VARCHAR(50), @branchName VARCHAR(200)
		IF @pBranch IS NOT NULL
			SELECT @branchName = agentName, @agentGrp = agentGrp FROM agentMaster am WITH(NOLOCK) WHERE agentId = @pBranch
	END

	IF @flag = 'i' 
	BEGIN
		if EXISTS (SELECT 'X' FROM dbo.GMEPayHistory WITH(NOLOCK) WHERE refNo = @refNoEnc)
		BEGIN
		    UPDATE dbo.GMEPayHistory SET 
						recordStatus = 'EXPIRED'
			WHERE refNo = @refNoEnc AND recordStatus <> 'READYTOPAY'
		END

		IF @pBranch IS NULL
			SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user

		INSERT INTO dbo.GMEPayHistory
				( 
				refNo,
				--senderAgent, 
				senderName, 
				senderAddress, 
				senderMobile, 
				senderCity, 
				senderCountry,

				benefName, 
				benefAddress, 
				benefMobile, 
				benefCity, 
				benefCountry,
				
				pAmount, 
				sAmount,
				pCurrency, 
				paymentType, 
				txnDate, 
				tokenId,
				sessionId,
				rOccupation,
				incomeSource,
				relationType,
				purposeOfRemit,
				rCurrCostRate,
				sCurrCostRate,

				message, 
				createdBy, 
				createdDate, 
				recordStatus
				
				)
		select   @refNoEnc, 
				--@senderName,
				@senderName, 
				@senderAddress, 
				@senderMobile, 
				@senderCity, 
				@senderCountry,
				 
				@benefName, 
				@benefAddress, 
				@benefMobile, 
				@benefCity, 
				@benefCountry,
				
				@pAmount,
				@sAmount,
				@pCurrency, 
				@paymentType, 
				@remittanceEntryDt, 
				@payTokenId,
				@sessionId,
				@rOccupation,
				@incomeSource,
				@relationship,
				@purpose,
				@pCurrCostRate,
				@sCurrCostRate,

				@message, 
				@user ,
				GETDATE() , 
				'DRAFT'
				
				
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
	END

	IF @flag = 'readyToPay'
	BEGIN
		UPDATE dbo.GMEPayHistory SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = isnull(@pBranch, pBranch)
			,pBankBranch	 = ISNULL(@pBranch, pBankBranch)
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber 
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = @rValidDate
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,benefMobile	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks 	  	 = @remarks 
			,rBank			 = @rbankName
			,rBankBranch	 = @rbankBranch
			,rAccountNo		 = @rAccountNo
			,rChequeNo		 = @rcheque
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose
			,rIssueDate		 = @rIssuedDate				
		WHERE rowId = @rowId
		SELECT @pAmount = pAmount FROM dbo.GMEPayHistory WITH(NOLOCK) WHERE rowId = @rowId
		SELECT '0' errorCode, 'Ready to pay has been recorded successfully.' msg, 'Nepal' id, @pAmount extra
		RETURN
	END

	IF @flag = 'payError'
	BEGIN
		UPDATE dbo.GMEPayHistory SET 
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
			SELECT 'x' FROM dbo.GMEPayHistory WITH(NOLOCK) 
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
			,@pAgentName				VARCHAR(80)
			,@pCountryId				INT
			,@recordStatus				VARCHAR(30)
			,@agentName					VARCHAR(100)
			,@status					VARCHAR(30)
			,@pAgent					VARCHAR(100)
			--,@pBranchName				VARCHAR(100)
			,@senderIdType				VARCHAR(30)
			,@bankName					VARCHAR(100)
			,@senderIdNo				VARCHAR(15)
			,@rCurrency					VARCHAR(30)

		SELECT
			 @refNo						= rm.refNo
			,@benefName					= rm.benefName
			,@benefMobile				= rm.benefMobile 
			,@benefAddress				= rm.benefAddress
			,@senderName				= rm.senderName
			,@senderAddress 			= rm.senderAddress
			,@senderMobile				= rm.senderMobile 
			,@pCurrency					= rm.pCurrency
			,@pAmount					= rm.pAmount
			,@tAmt						= rm.sAmount
			,@recordStatus				= rm.recordStatus
			,@rIdType					= rm.rIdType
			,@rIdNumber					= rm.rIdNumber
			,@rValidDate				= rm.rValidDate
			,@rIssuedDate				= rm.rIssueDate
			,@rDob						= rm.rDob
			,@rOccupation				= rm.rOccupation
			,@rNativeCountry			= rm.nativeCountry
			,@pBranch					= isnull(@pBranch,rm.pBranch)
			,@rIdPlaceOfIssue			= rm.rIdPlaceOfIssue
			,@relationType				= rm.relationType
			,@relativeName				= rm.relativeName
			,@rbankName					= rm.rBank
			,@rbankBranch				= rm.rBankBranch
			,@rcheque					= rm.rChequeNo
			,@rAccountNo				= rm.rAccountNo
			,@purpose					= rm.purposeOfRemit
			,@relationship				= rm.relWithSender
			,@pCurrCostRate				= rm.rCurrCostRate
			,@sCurrCostRate				= rm.sCurrCostRate
		FROM dbo.GMEPayHistory rm WITH(NOLOCK)
		WHERE rowId = @rowId
		
		SET @ControlNoModified = @refNo
		
		SET  @sCountryId = '118'
		SET  @sCountry = 'South Korea'

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
		
		SELECT  @pSuperAgent = parentId, 
				@pAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent

	
		--## 1. Find Sending Agent Details
		SELECT @sAgent = sAgent,@sAgentName = sAgentName,@sBranch = sBranch,@sBranchName = sBranchName
				,@sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName
				,@pCountry = pCountry,@pCountryId = pCountryId
		FROM dbo.FNAGetBranchFullDetails(394409)  --NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
		
		DECLARE @deliveryMethodId INT, @pCommCheck MONEY
		
		--Get collection currency
		SELECT @collCurr = cm.currencyCode FROM dbo.countryCurrency cc (NOLOCK)
		INNER JOIN dbo.CurrencyMaster cm (NOLOCK) ON cm.currencyId = cc.currencyId
		WHERE cc.countryId = @sCountryId

		SET @payoutMethod = 'Cash Payment'
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'				

		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'MNT'

		--DECLARE @sCurrCostRate MONEY,@sCurrHoMargin MONEY,@sCurrAgentMargin MONEY,@pCurrCostRate MONEY
		DECLARE @sCurrHoMargin MONEY,@sCurrAgentMargin MONEY,@pCurrHoMargin MONEY,@pCurrAgentMargin MONEY,
				@agentCrossSettRate MONEY, @commCheck MONEY

		--## GET SERVICE CHARGE
		--SET @tAmt= @pAmount

		SELECT @ServiceCharge = AMOUNT FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch
				,@pCountryId,null,@pAgent,@PBranch,@deliveryMethodId,@tAmt,@collCurr)
		
		
		--	SET @customerRate=(@pCurrCostRate/@sCurrCostRate)
	
		SET @customerRate = dbo.FNAGetCustomerRate(@sCountryId, @sAgent, @sBranch, @collCurr, '142',@pAgent, 'MNT', '1')

		--IF @customerRate IS NULL OR @customerRate = '' OR @customerRate = 0
		--BEGIN
		--	SET @msg = 'Ex-Rate not defined for sending country'  + @sCountry + ' and receving country  Mongolia'

		--	EXEC proc_errorHandler 1,@msg,NULL
		--	RETURN
		--END 

		--SET @sCurrCostRate = 1
		SET @cAmt = @tAmt + (ISNULL(@ServiceCharge,0))
		

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
			,[tranStatus],[payStatus],[collCurr],[controlNo2],[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName], sRouteId				
					)
			SELECT
			@ControlNoModified,@senderName,@sCountry,@sSuperAgent,@sSuperAgentName,'Cash Payment',@cAmt,@Pamount
			,@tAmt,@customerRate,@pAgentComm,@pCurrency,@pAgent,@pAgentName,@pSuperAgent,@pSuperAgentName 
			,@benefName	,@pCountry,@pBranch,@pBranchName,@pState,@pDistrict,@pLocation,@bankName,@purpose
			,@remarks,@pBankBranch,@SagentsettRate,dbo.FNAGetDateInNepalTZ() ,GETDATE(),@user,dbo.FNAGetDateInNepalTZ()
			,GETDATE(),@user,@user,dbo.FNAGetDateInNepalTZ(),GETDATE(),@ServiceCharge
			,@sCurrCostRate,@pCurrCostRate,@agentCrossSettRate,@sCurrHoMargin,@sCurrAgentMargin
			--## HardCoded Parameters
			,'Paid','Paid',@collCurr,@refNo,'I',@sAgent,@sAgentName,@sBranch,@sBranchName, 'GME'
					
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
					,@relationship
					,@purpose
					,@rIssuedDate
					,@rValidDate
			
			--## Updating Data in globalBankPayHistory table by paid status
			UPDATE dbo.GMEPayHistory SET 
					recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg
				,confirmationNo	 = @payConfirmationNo
				,paidDate		 = GETDATE()
				,paidBy			 = @user			
			WHERE rowId = @rowId
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SET @msg = CASE WHEN @flag = 'restore' THEN 'Transaction has been restored successfully' ELSE 'Transaction paid successfully' END

		 SET @refNo = dbo.decryptdb(@ControlNoModified)

		EXEC  SendMnPro_Account.dbo.Proc_CashDepositVoucher @controlNo = @refNo ,@refNum= NULL 

		SELECT 0 errorCode, @msg msg, @refNo id,extra= @pAgentComm
		RETURN
	END	

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
END CATCH


















GO
