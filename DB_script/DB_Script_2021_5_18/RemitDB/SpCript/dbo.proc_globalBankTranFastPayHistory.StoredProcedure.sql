USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_globalBankTranFastPayHistory]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_globalBankTranFastPayHistory](
	     @flag						VARCHAR(50)
	    ,@user						VARCHAR(50) 			
	    ,@rowId						VARCHAR(20)		= NULL
		,@pBranch					VARCHAR(100)	= NULL
	    ,@tokenId				    VARCHAR(100)	= NULL
		,@radNo                     VARCHAR(100)	= NULL
		,@agentBranchId             VARCHAR(100)	= NULL
		,@status                    VARCHAR(100)	= NULL
		,@statusName                VARCHAR(100)	= NULL
		,@transactionDate           VARCHAR(100)	= NULL
		,@receiveCurrencyIsoCode    VARCHAR(100)	= NULL
		,@rAmount                   VARCHAR(100)	= NULL
		,@sAmount                   VARCHAR(100)	= NULL
		,@paymentModeId             VARCHAR(100)	= NULL
		,@exRate                    VARCHAR(100)	= NULL
		,@cAmountLocal              VARCHAR(100)	= NULL
		,@cAmountForeign            VARCHAR(100)	= NULL
		,@payoutBranchId            VARCHAR(100)	= NULL
		,@paymentModeName           VARCHAR(100)	= NULL
		,@senderFullName            VARCHAR(100)	= NULL
		,@senderAddress             VARCHAR(100)	= NULL
		,@senderAddressUnicode      VARCHAR(100)	= NULL
		,@senCityId                 VARCHAR(100)	= NULL
		,@senderCityName            VARCHAR(100)	= NULL
		,@senderStateId             VARCHAR(100)	= NULL
		,@senderStateName           VARCHAR(100)	= NULL
		,@senderCountryIsoCode      VARCHAR(100)	= NULL
		,@senderCountryName         VARCHAR(100)	= NULL
		,@senderPhoneHome           VARCHAR(100)	= NULL
		,@senderPhoneMobile         VARCHAR(100)	= NULL
		,@receiverFullName          VARCHAR(100)	= NULL
		,@receiverCountryIsoCode    VARCHAR(100)	= NULL
		,@receiverCountryName       VARCHAR(100)	= NULL
		,@receiverStateId           VARCHAR(100)	= NULL
		,@receiverStateName         VARCHAR(100)	= NULL
		,@recCityId                 VARCHAR(100)	= NULL
		,@receiverCityName          VARCHAR(100)	= NULL
		,@receiverAddress           VARCHAR(100)	= NULL
		,@receiverPhoneMobile       VARCHAR(100)	= NULL
		,@recNo                     VARCHAR(100)	= NULL
		,@senId                     VARCHAR(100)	= NULL
		,@partnerId				    VARCHAR(30)		= NULL
		,@pBranchId					VARCHAR(50)		= NULL
		,@branchName				VARCHAR(200)	= NULL
		,@amount					VARCHAR(100)	= NULL
		,@rIdType					VARCHAR(30)		= NULL
		,@rIdNumber					VARCHAR(30)		= NULL
		,@rIdPlaceOfIssue			VARCHAR(50)		= NULL
		,@rValidDate				VARCHAR(30)		= NULL
		,@rDob						VARCHAR(30)		= NULL
		,@rAddress					VARCHAR(100)	= NULL
		,@rCity						VARCHAR(100)	= NULL
		,@rOccupation				VARCHAR(100)	= NULL
		,@rContactNo				VARCHAR(50)		= NULL
		,@rNativeCountry			VARCHAR(100)	= NULL
		,@relationType				VARCHAR(50)		= NULL
		,@relativeName				VARCHAR(100)	= NULL
		,@remarks					VARCHAR(500)	= NULL
		,@customerId				VARCHAR(50)		= NULL
		,@relationship				VARCHAR(100)	= NULL
		,@purpose					VARCHAR(100)	= NULL
		,@rIssuedDate				DATETIME		= NULL
		,@membershipId				VARCHAR(50)		= NULL
		,@rbankName					VARCHAR(50)		= NULL
		,@rbankBranch				VARCHAR(100)	= NULL
		,@rcheque					VARCHAR(50)		= NULL
		,@rAccountNo				VARCHAR(50)		= NULL
		,@payResponseCode			VARCHAR(20)		= NULL
		,@payResponseMsg			VARCHAR(100)	= NULL
		,@sBranchMapCOdeInt			INT				= NULL
		,@remittanceEntryDt			VARCHAR(100)	= NULL
		,@remittanceAuthorizedDt	VARCHAR(100)	= NULL
		,@remitType					VARCHAR(100)	= NULL 
		,@pCommission				VARCHAR(100)	= NULL
		,@apiStatus					VARCHAR(100)	= NULL
		,@payConfirmationNo			VARCHAR(100)	= NULL
		,@benefAccIdNo				VARCHAR(100)	= NULL
		,@senderIdType				VARCHAR(100)	= NULL
		,@senderIdNo				VARCHAR(100)	= NULL
		,@agentName					VARCHAR(100)	= NULL
		,@pAgent					INT				= NULL
		,@pCurrency					VARCHAR(100)	= NULL
		,@dollarRate				VARCHAR(100)	= NULL
		,@recordStatus				VARCHAR(50)		= NULL
		,@TPAgentID					VARCHAR(100)	= NULL
		,@rCurrency					VARCHAR(100)	= NULL
		,@pBranchName				VARCHAR(100)	= NULL
		,@pAgentName				VARCHAR(100)	= NULL
		)
 AS
 SET XACT_ABORT ON
 SET NOCOUNT    ON
  BEGIN TRY
	DECLARE  @agentGrp				INT
			,@cotrolNo				VARCHAR(50)
			,@subPartnerId			INT 
			,@radNoEnc				VARCHAR(100) = dbo.FNAEncryptString(@radNo)
	IF @pBranchId IS NOT NULL
	SELECT @branchName = agentName, @agentGrp = agentGrp FROM agentMaster am WITH(NOLOCK) WHERE agentId = @pBranchId

	IF @rowId like '%|%'
		SELECT @rowId = value FROM DBO.SPLIT('|',@rowId) WHERE id = 1 

IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 'x' FROM globalBankTranFastPayHistory WITH(NOLOCK) WHERE radNo= @radNoEnc)
	BEGIN
		UPDATE globalBankTranFastPayHistory SET 
			recordStatus = 'EXPIRED'
		WHERE radNo = @radNoEnc AND recordStatus <> 'READYTOPAY'
	END

	IF @pBranch IS NULL
		SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
				
	IF @pBranch = '1001'
	BEGIN
		EXEC [proc_errorHandler] 1, 'Payout branch is missing.', @rowId
		RETURN;
	END		
				
	INSERT INTO globalBankTranFastPayHistory (
			radNo,agentBranchId,status,statusName,transactionDate,receiveCurrencyIsoCode,rAmount,sAmount,paymentModeId           
			,exRate,cAmountLocal,cAmountForeign,payoutBranchId,paymentModeName,senderFullName,senderAddress           
			,senderAddressUnicode,senCityId,senderCityName,senderStateId,senderStateName,senderCountryIsoCode,senderCountryName       
			,senderPhoneHome,senderPhoneMobile,receiverFullName,receiverCountryIsoCode,receiverCountryName,receiverStateId         
			,receiverStateName,recCityId,receiverCityName,receiverAddress,receiverPhoneMobile,recNo,senId,createdDate
			,createdBy,pBranch,recordStatus
			)
	SELECT								
			@radNoEnc,@agentBranchId,@status,@statusName,@transactionDate,@receiveCurrencyIsoCode,@rAmount,@sAmount,@paymentModeId        
			,@exRate,@cAmountLocal,@cAmountForeign,@payoutBranchId,@paymentModeName,@senderFullName,@senderAddress        
			,@senderAddressUnicode,@senCityId,@senderCityName,@senderStateId,@senderStateName,@senderCountryIsoCode,@senderCountryName
			,@senderPhoneHome,@senderPhoneMobile,@receiverFullName ,@receiverCountryIsoCode,@receiverCountryName,@receiverStateId      
			,@receiverStateName,@recCityId,@receiverCityName,@receiverAddress,@receiverPhoneMobile,@recNo,@senId,GETDATE()                
			,@user,@pBranch,'DRAFT'

	SET @rowId = SCOPE_IDENTITY()
	EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
	RETURN 
END

ELSE IF @flag = 's' 
BEGIN 
	IF(@partnerId='6873') 
	BEGIN 
		  
			EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId

			SELECT TOP 1 
			rowId				= gbl.rowId
			,securityNo		    = dbo.FNADecryptString(gbl.radNo)
			,transactionDate	=SUBSTRING(gbl.transactionDate,1,10)		
			,senderName		    = gbl.senderFullName		
			,senderAddress	    = gbl.senderAddress
			,senderMobile		= gbl.senderPhoneMobile	
			,senderTel			= gbl.senderPhoneHome
			,senderIdNo		    = ''--gbl.senderIdNo	
			,senderIdType		= ''--gbl.senderIdType
			,senderCity			= gbl.senderCityName
			,recName		    = gbl.receiverFullName
			,recAddress		    = gbl.receiverAddress
			,recMobile			= gbl.receiverPhoneMobile
			,recTelePhone		= ''--gbl.benefTel
			,recIdType		    ='' -- gbl.benefIdType
			,recIdNo		    = '' --gbl.benefAccIdNo
			,recCity			= receiverCityName
			,recCountry			= receiverCountryName
			,pAmount		    = isnull(gbl.rAmount,0)
			,rCurrency			= gbl.receiveCurrencyIsoCode
			,pCurrency			='NPR' -- gbl.pCurrency
			,remarks			= ''  --gbl.remarks	
			,paymentMethod		= 'Cash Payment'
			,tokenId			= ''  --gbl.tokenId	
			--,amt				= isnull(gbl.rAmount,0)--isnull(cast(cAmountLocal as decimal(10,2)),0)
			,amt				= cast(isnull(gbl.rAmount,0) as decimal(10,2))
			,pBranch			= gbl.pBranch	
			,sendingCountry		= gbl.senderCountryName
			,sendingAgent		= ''	
			,branchName			= @branchName
			,providerName       = 'Global Tranfast Remit'
			,orderNo			= ''		  
			,agentGrp			= @agentGrp
			,subPartnerId		= 0
			,benefStateId		= receiverStateId
			,benefCityId 		= recCityId
		FROM globalBankTranFastPayHistory gbl WITH(NOLOCK)	
		WHERE  rowId = @rowId ORDER BY rowId DESC

			--- ## Log Details
		SELECT TOP 1 [message],trn.createdBy,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2
			
		RETURN
	END
END

ELSE IF @flag = 'readyToPay'
BEGIN
		SELECT @rowId = value FROM DBO.SPLIT('|',@rowId) WHERE id = 1 
		UPDATE globalBankTranFastPayHistory SET 
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
			,rContactNom   	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks 	  	 = @remarks 
			,customerId		 = @customerId
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose
			,rIssueDate		 = @rIssuedDate				
		WHERE rowId = @rowId
	--	SELECT @amount = cAmountLocal FROM globalBankTranFastPayHistory WITH(NOLOCK) WHERE rowId = @rowId
	SELECT '0' errorCode, 'Ready to pay has been recorded successfully.' msg, 'Nepal' id, @amount extra
	RETURN
END

ELSE IF @flag = 'payError'
BEGIN
		UPDATE globalBankTranFastPayHistory SET 
				recordStatus	 = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg  = @payResponseMsg 		
			WHERE rowId = @rowId
	EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
	RETURN
END

ELSE IF @flag IN ('pay', 'restore')
BEGIN
		
	IF NOT EXISTS(SELECT 'x' FROM globalBankTranFastPayHistory WITH(NOLOCK) WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID')	AND rowid = @rowid)
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
			,@bankName					VARCHAR(100) = NULL
			--,@purposeOfRemit			VARCHAR(100) = NULL
			,@pBankBranch				VARCHAR(100) = NULL
			,@sAgentSettRate			VARCHAR(100) = NULL
			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			,@cAmt						MONEY
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
			 @radNo						= gbl.radNo
			,@receiverFullName			= gbl.receiverFullName
			,@senderPhoneHome			= gbl.receiverPhoneMobile
			,@receiverPhoneMobile		= gbl.receiverPhoneMobile 
			,@receiverAddress			= gbl.receiverAddress
			,@benefAccIdNo				= ''           --gbl.benefAccIdNo
			,@rIdType					= gbl.rIdType
			,@senderFullName				= gbl.senderFullName
			,@senderAddress 			= gbl.senderAddress
			,@senderPhoneHome			= gbl.senderPhoneHome
			,@senderPhoneMobile			= gbl.senderPhoneMobile 
			,@senderIdType				= ''          --gbl.senderIdType 
			,@senderIdNo				=''           --gbl.senderIdNo 
			,@remittanceEntryDt			= gbl.remittanceEntryDt
			,@remittanceAuthorizedDt	= gbl.remittanceAuthorizedDt
			,@remitType					= gbl.remitType
			,@receiveCurrencyIsoCode	= gbl.receiveCurrencyIsoCode   --rCurrency 
			,@pCurrency					= gbl.pCurrency
			,@pCommission				= gbl.pCommission
			,@amount					= gbl.rAmount      --amount
			,@cAmountLocal				= gbl.cAmountLocal      --localAmount
			,@exRate			    	= gbl.exRate
			,@dollarRate				= ''              --gbl.dollarRate
			,@apiStatus					= gbl.apiStatus
			,@recordStatus				= gbl.recordStatus
			,@rIdType					= gbl.rIdType
			,@rIdNumber					= gbl.rIdNumber
			,@rValidDate				= gbl.rValidDate
			,@rIssuedDate				= gbl.rIssueDate
			,@rDob						= gbl.rDob
			,@rOccupation				= gbl.rOccupation
			,@rNativeCountry			= gbl.nativeCountry
			,@pBranch					= isnull(@pBranch,gbl.pBranch)
			,@rIdPlaceOfIssue			= gbl.rIdPlaceOfIssue
			,@relationType				= gbl.relationType
			,@relativeName				= gbl.relativeName
			,@tpAgentId					=''         -- gbl.tpAgentId
			,@rbankName					=''        --  rBank
			,@rbankBranch				= ''        --rBankBranch
			,@rcheque					= ''         --rAccountNo
			,@rAccountNo				= ''         ---rChequeNo
			,@membershipId				= ''         --membershipId
			,@customerId				= customerId
			,@purpose					= purposeOfRemit
			,@relationship				= relWithSender
		FROM globalBankTranFastPayHistory gbl WITH(NOLOCK)
		WHERE rowId = @rowId
		
		SELECT TOP 1
			@senderCountryName = cm.countryName,
			@sCountryId = cm.countryId
		FROM countryMaster cm WITH(NOLOCK) INNER JOIN countryCurrency cc WITH(NOLOCK) ON cm.countryId = cc.countryId
		INNER JOIN currencyMaster currM WITH(NOLOCK) ON currM.currencyId = cc.currencyId
		WHERE currM.currencyCode = @rCurrency                        --@receiveCurrencyIsoCode
		 AND isOperativeCountry  ='Y'
		AND ISNULL(cc.isDeleted,'N') = 'N'

		SET @ControlNoModified = @radNo

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
			SELECT @agentName = sAgentName,@status = payStatus	
			FROM remitTran WITH(NOLOCK) 
			WHERE controlNo = @ControlNoModified

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
		DECLARE	@remitTrandate DATETIME,@remitTrandateNepal DATETIME
		
		SELECT 
			 @tranId = id
			,@remitTrandate = paidDate
			,@remitTrandateNepal = paidDateLocal
			,@pAgentComm = pAgentComm 
			,@remitTrandate = GETDATE()
			,@remitTrandateNepal = dbo.FNAGetDateInNepalTZ()
		FROM remitTran  WITH(NOLOCK) 
		WHERE controlNo = @ControlNoModified

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
		
		SELECT  @sSuperAgent = parentId,@sAgentName = agentName FROM agentMaster WITH(NOLOCK) 
		WHERE agentId = @sAgent

		SELECT @sSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
	
		--## 2. Find Payout Agent Details
		SELECT  @pSuperAgent = parentId,@pAgentName = agentName FROM agentMaster WITH(NOLOCK) 
		WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		
		--## 3. Find Commission 
		DECLARE @deliveryMethodId INT, @pCommCheck MONEY
		
		SET @payoutMethod = 'Cash Payment'
		DECLARE @pCountryId INT = NULL
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'				

		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'

		SELECT @pAgentComm = ISNULL(pAgentComm, 0) 
		FROM dbo.FNAGetGIBLCommission(@sBranch, @radNo,@deliveryMethodId,'GIBLTFS')

		
		BEGIN TRANSACTION
		BEGIN
		--## Inserting Data in remittran table 
			INSERT INTO remitTran (	 
				[controlNo],[senderName],[sCountry],[sSuperAgent],[sSuperAgentName],[paymentMethod]
				,[cAmt],[pAmt],[tAmt],[customerRate],[pAgentComm],[payoutCurr]
				,[pAgent],[pAgentName],[pSuperAgent],[pSuperAgentName],[receiverName],[pCountry]
				,[pBranch],[pBranchName],[pState],[pDistrict],[pLocation],[pbankName],[purposeofRemit],[pMessage]
				,[pBankBranch],[sAgentSettRate],[createdDate],[createdDateLocal],[createdBy],[approvedDate],[approvedDateLocal]			
				,[approvedBy],[paidBy],[paidDate],[paidDateLocal],[serviceCharge],[tranStatus],[payStatus],[collCurr],[controlNo2]					
				,[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName]					
				)
			SELECT
				@ControlNoModified,@senderFullName,isnull(@senderCountryName,''),@sSuperAgent,@sSuperAgentName,'Cash Payment'
				,@amount,@amount,@amount,'1',@pAgentComm,@pCurrency
				,@pAgent,@pAgentName,@pSuperAgent,@pSuperAgentName ,@receiverFullName,@pCountry
				,@pBranch,@pBranchName,@pState,@pDistrict,@pLocation,@bankName,@purpose,@remarks
				,@pBankBranch,@SagentsettRate,dbo.FNAGetDateInNepalTZ(),GETDATE(),@user,dbo.FNAGetDateInNepalTZ(),GETDATE()
				,@user,@user,dbo.FNAGetDateInNepalTZ(),GETDATE(),'0','Paid','Paid',@pCurrency,@radNo
				,'I',@sAgent,@sAgentName,@sBranch,@sBranchName
					
				SET @tranId = SCOPE_IDENTITY()
	 	
		BEGIN
				--## Inserting Data in tranSenders table
			INSERT INTO tranSenders	(tranId,firstName,country,[address],idType,idNumber,homePhone,mobile)
			SELECT @tranId,@senderFullName,@senderCountryName,@senderAddress,@senderIdType,@senderIdNo,@senderPhoneHome,@senderPhoneMobile 
					--,@senderTel
					--,@senderMobile
				
				--## Inserting Data in tranReceivers table
			INSERT INTO tranReceivers (
				tranId,firstName,country,city,[address],homePhone,mobile
				,idType2,idNumber2,dob,occupation,validDate,idPlaceOfIssue,relationType,relativeName,bankName
				,branchName,chequeNo,accountNo,membershipId,customerId,relWithSender,purposeOfRemit,issuedDate2,validDate2
			)		
			SELECT 
				@tranId,@receiverFullName,@pCountry,@receiverAddress,@receiverAddress,@senderPhoneHome,@receiverPhoneMobile
				,@rIdType,@rIdNumber,@rDob,@rOccupation,@rValidDate,@rIdPlaceOfIssue,@relationType,@relativeName,@rbankName
				,@rbankBranch,@rcheque,@raccountNo,@membershipId,@customerId,@relationship,@purpose,@rIssuedDate,@rValidDate
			
			--## Updating Data in globalBankPayHistory table by paid status
			UPDATE globalBankTranFastPayHistory SET 
				 recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg
				,confirmationNo	 = @payConfirmationNo
				,paidDate		 = GETDATE()
				,paidBy			 = @user			
			WHERE rowId = @rowId

			EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @amount ,@settlingAgent = @pBranch
		END
		END
	
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
