USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payTxnV2]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_payTxnV2](
		 @flag				VARCHAR(1)			
		,@user			    VARCHAR(50) 			
	    ,@rowId				BIGINT			    = NULL
		,@securityNo		VARCHAR(50)		    = NULL
		,@transactionDate   DATETIME            = NULL
		,@sendingCountry    VARCHAR(50)		    = NULL
		,@senderName        VARCHAR(50)		    = NULL
		,@senderAddress		VARCHAR(50)		    = NULL
		,@senderContactNo	VARCHAR(50)		    = NULL
		,@senderCountry     VARCHAR(50)		    = NULL
		,@senderIdNo		VARCHAR(50)			= NULl
		,@senderIdType		VARCHAR(50)			= NULl
		,@recName			VARCHAR(50)			= NULl
		,@recAddress		VARCHAR(50)			= NULl
		,@recContactNo		VARCHAR(50)			= NULl
		,@recIdType			VARCHAR(50)			= NULl
		,@recIdNo			VARCHAR(50)			= NULl
		,@pAmount			VARCHAR(50)			= NULl
		,@relationType		VARCHAR(50)			= NULl
		,@relativeName		VARCHAR(50)			= NULl
		,@rIdPlaceOfIssue	VARCHAR(50)			= NULl
		,@partnerId         VARCHAR(30)			= NULL
		,@pBranchId			VARCHAR(50)			= NULL
		,@branchName		VARCHAR(200)		= NULL
)
AS

IF @Flag='s'
BEGIN
	DECLARE @agentGrp INT,@cotrolNo VARCHAR(50)
	IF @pBranchId IS NOT NULL
		SELECT @branchName = agentName, @agentGrp = agentGrp FROM agentMaster am WITH(NOLOCK) WHERE agentId = @pBranchId
	

	IF(@partnerId='4734')  /***** Global Remit *****/
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId
		SELECT TOP 1 
			 rowId				= gbl.rowId
			,securityNo		    = dbo.FNADecryptString(gbl.radNo)
			,transactionDate	= gbl.createdDate		
			,senderName		    = gbl.senderName	
			,senderAddress	    = gbl.senderAddress
			,senderMobile		= gbl.senderMobile	
			,senderTel			= gbl.senderTel
			,senderIdNo		    = gbl.senderIdNo	
			,senderIdType		= gbl.senderIdType
			,senderCity			= ''
			,recName		    = gbl.benefName
			,recAddress		    = gbl.benefAddress
			,recMobile			= gbl.benefMobile
			,recTelePhone		= gbl.benefTel
			,recIdType		    = gbl.benefIdType
			,recIdNo		    = gbl.benefAccIdNo
			,recCity			= ''
			,recCountry			= ''
			,pAmount		    = isnull(gbl.amount,0)
			,rCurrency			= gbl.rCurrency
			,pCurrency			= gbl.pCurrency
			,remarks			= gbl.remarks	
			,paymentMethod		= 'Cash Payment'
			,tokenId			= gbl.tokenId	
			,amt				= isnull(gbl.amount,0)
			,pBranch			= gbl.pBranch	
			,sendingCountry		= ''
			,sendingAgent		= ''	
			,branchName			= @branchName
			,providerName       = 'Global Remit'
			,orderNo			= ''	
			,agentGrp			= ''	  
		FROM globalBankPayHistory gbl WITH(NOLOCK)	
		WHERE  rowId = @rowId ORDER BY rowId DESC

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2

		RETURN
	 END			  
	IF (@partnerId='4670') /***** CASH EXPRESS *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId	
		SELECT TOP 1
			  rowId						
			 ,securityNo					= dbo.FNADecryptString(ce.gitNo)
			 ,transactionDate				= ce.createdDate
			 ,senderName					= ce.custName
			 ,senderAddress					= ISNULL(ce.custAddress,'')
			 ,senderMobile					= ISNULL(ce.custPhone,'')
			 ,senderTel						= ''
			 ,senderIdNo					= ce.custIdNo
			 ,senderIdType					= ce.custIdType
			 ,senderCity					= ''
			 ,recName						= ce.beneName
			 ,recAddress					= ce.beneAddress
			 ,recMobile						= isnull(ce.rContactNo,ce.benePhone)
			 ,recTelePhone					= ISNULL(ce.benePhone,'')
			 ,recIdType						= ce.rIdType
			 ,recIdNo						= ce.rIdNumber
			 ,recCity						= ''
			 ,recCountry					= ''
			 ,pAmount						= ce.destinationAmount
			 ,rCurrency						= 'NPR'
			 ,pCurrency						= ce.destinationCurrency
			 ,remarks						= ce.remarks
			 ,paymentMethod					= 'Cash Payment'
			 ,tokenId						= ''
			 ,amt							= ce.destinationAmount
			 ,pBranch						= ce.pBranch
			 ,sendingCountry				= ''
			 ,sendingAgent					= ''
			 ,branchName				    = @branchName
			 ,providerName					= 'Cash Express'
			 ,orderNo						= ''	
			 ,agentGrp						= @agentGrp	
	    FROM cePayHistory ce WITH(NOLOCK)
		WHERE rowId = @rowId ORDER BY rowId DESC

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2

		RETURN	
	END

	IF (@partnerId='4726')  /***** EZ Remit *****/
	BEGIN 			
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId
		SELECT TOP 1
				  rowId				  	= ez.id
				 ,securityNo			  	= dbo.FNADecryptString(ez.SecurityNumber)		
				 ,transactionDate		  	= ez.createdDate
				 ,senderName			  	= ez.scCustomerName
				 ,senderAddress			  	= ISNULL(ez.scCustomerAddress,'')
				 ,senderMobile			  	= ISNULL(ez.scCustMobileNumber,'')
				 ,senderTel				  	= ISNULL(ez.scCustTelephoneNumber,'')
				 ,senderIdNo			  	= ez.scCustId
				 ,senderIdType			  	= ez.scCustIdType
				 ,senderCity				= ''
				 ,recName				  	= ez.tbName
				 ,recAddress			  	= ez.tbAddress
				 ,recMobile				  	= isnull(rContactNo,ez.tbContactTelephoneNo)
				 ,recTelePhone			  	= ISNULL(ez.tbTelephoneNumber,ez.tbContactTelephoneNo)
				 ,recIdType				  	= ez.rIdType
				 ,recIdNo				  	= ez.rIdNumber
				 ,recCity					= ''
				 ,recCountry				= ez.tbBenCountry
				 ,pAmount				  	= ez.tdFxAmount
				 ,rCurrency				  	= 'NPR'
				 ,pCurrency				  	= ez.tdFxCurrencyCode
				 ,remarks				  	= ez.remarks
				 ,paymentMethod				= 'Cash Payment'
				 ,tokenId				  	= ''
				 ,amt					    = ez.tdFxAmount
				 ,pBranch					= ez.pBranch
				 ,sendingCountry			= ez.scCustCountry
				 ,sendingAgent				= ez.scCustBankName
				 ,branchName				= @branchName
				 ,providerName				= 'EZ Remit'
				 ,orderNo					= ''	
				 ,agentGrp						= @agentGrp	
	    FROM ezPayHistory ez WITH(NOLOCK)
		WHERE ez.id = @rowId
		ORDER BY id DESC

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2

		RETURN
	END
	IF (@partnerId='4869')   /***** RIA *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId	
		SELECT TOP 1
			  rowId			
			 ,securityNo				= dbo.FNADecryptString(ria.pin)			   
			 ,transactionDate		    = ria.createdDate
			 ,senderName				= ria.CustNameFirst + ISNULL( ' ' + ria.custNameLast1, '') + ISNULL( ' ' + ria.custNameLast2, '')  
			 ,senderAddress				= ISNULL(ria.CustAddress,'')
			 ,senderMobile				= ISNULL(ria.custTelNo,'')
			 ,senderTel					= ISNULL(ria.custTelNo,'')
			 ,senderIdNo				= ''
			 ,senderIdType				= ''
			 ,senderCity				= ''
			 ,recName					= ria.beneNameFirst + ISNULL( ' ' + ria.beneNameLast1, '') + ISNULL( ' ' + ria.beneNameLast2, '')  
			 ,recAddress				=  ria.rAddress	
			 ,recMobile					= ISNULL(ria.rContactNo,'')
			 ,recTelePhone				= ISNULL(ria.rContactNo,'')
			 ,recIdType					= ria.rIdType
			 ,recIdNo					= ria.rIdNumber
			 ,recCity					= ''
			 ,recCountry				= ''
			 ,pAmount					= ria.BeneAmount
			 ,rCurrency					= 'NPR'
			 ,pCurrency					= 'NPR'
			 ,remarks					= ria.remarks
			 ,paymentMethod				= 'Cash Payment'
			 ,tokenId					= ria.transRefID
			 ,amt						= ria.beneAmount
			 ,pBranch				    = ria.pBranch
			 ,sendingCountry			= ''
			 ,sendingAgent				= ''
			 ,branchName				= @branchName
			 ,providerName				= 'RIA Financial'
			 ,orderNo					= ria.orderNo	
			 ,agentGrp						= @agentGrp	
	    FROM riaRemitPayHistory ria WITH(NOLOCK)
		WHERE rowId = @rowId ORDER BY rowId DESC

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2

		RETURN
	END
	IF (@partnerId='4909')   /***** X-PRESS Money *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId	
		SELECT TOP 1
			  rowId			
			 ,securityNo				= dbo.FNADecryptString(xp.xpin)			   
			 ,transactionDate		    = xp.payinDate
			 ,senderName				= xp.customerFirstName + ISNULL( ' ' + xp.customerMiddleName, '') + ISNULL( ' ' + xp.customerLastName, '') 
			 ,senderAddress				= ISNULL(xp.customerAddress1,'')
			 ,senderMobile				= ISNULL(xp.customerMobile,'')
			 ,senderTel					= ISNULL(xp.customerPhone,'')
			 ,senderIdNo				= ''
			 ,senderIdType				= ''
			 ,senderCity				= customerAddressCity
			 ,recName					= xp.beneficiaryFirstName + ISNULL( ' ' + xp.beneficiaryMiddleName, '') + ISNULL( ' ' + xp.beneficiaryLastName, '') 
			 ,recAddress				= xp.beneficiaryAddress1	
			 ,recMobile					= ISNULL(xp.beneficiaryMobile,'')
			 ,recTelePhone				= ISNULL(xp.beneficiaryPhone,'')
			 ,recIdType					= xp.beneficiaryIDOtherType
			 ,recIdNo					= xp.beneficiaryID
			 ,recCity					= xp.beneficiaryAddressCity
			 ,recCountry				= xp.beneficiaryAddressCountry
			 ,pAmount					= xp.payoutAmount
			 ,rCurrency					= xp.payoutCcyCode
			 ,pCurrency					= xp.payoutCcyCode
			 ,remarks					= xp.messageToBeneficiary
			 ,paymentMethod				= 'Cash Payment'
			 ,tokenId					= xp.xmwsSessionID
			 ,amt						= xp.payoutAmount
			 ,pBranch				    = xp.branchId
			 ,sendingCountry			= xp.sendingCountry
			 ,sendingAgent				= xp.sendingAgentName
			 ,branchName				= @branchName
			 ,providerName				= 'XPRESS Money'
			 ,orderNo					= ''	
			 ,agentGrp						= @agentGrp	
	    FROM xPressTranHistory xp WITH(NOLOCK)
		WHERE rowId = @rowId ORDER BY rowId DESC
		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2

		RETURN
	END
	IF @partnerId = '4854'   /***** MONEY GRAM *****/
	BEGIN
		--SELECT top 10 * FROM mgPayHistory WITH(NOLOCK) order by id desc WHERE id = @id
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId	
		SELECT TOP 1
			  rowId						= xp.id			
			 ,securityNo				= dbo.FNADecryptString(xp.referenceNumber)			   
			 ,transactionDate		    = xp.dateTimeSent
			 ,senderName				= xp.senderFirstName + ISNULL( ' ' + xp.senderMiddleName, '') + ISNULL( ' ' + xp.senderLastName, '')+ISNULL( ' ' + xp.senderLastName2, '')  
			 ,senderAddress				= ISNULL(xp.senderAddress,'')
			 ,senderMobile				= ISNULL(xp.senderHomePhone,'')
			 ,senderTel					= ISNULL(xp.senderHomePhone,'')
			 ,senderIdType				= ''
			 ,senderIdNo				= ''
			 ,senderCity				= xp.senderCity
			 ,senderCountry				= xp.senderCountry
			 ,recName					= xp.receiverFirstName + ISNULL( ' ' + xp.receiverMiddleName, '') + ISNULL( ' ' + xp.receiverLastName, '') + ISNULL( ' ' + xp.receiverLastName2, '')
			 ,recAddress				= xp.receiverAddress
			 ,recMobile					= ''
			 ,recTelePhone				= ISNULL(xp.receiverContactNo,'')
			 ,recIdType					= xp.receiverIdType
			 ,recIdNo					= xp.receiverIdnumber
			 ,recCity					= xp.receiverCity
			 ,recCountry				= xp.receiverNativeCountry
			 ,pAmount					= floor(xp.receiveAmount)
			 ,rCurrency					= ''
			 ,pCurrency					= xp.receiveCurrency
			 ,remarks					= xp.remarks
			 ,paymentMethod				= 'Cash Payment'
			 ,tokenId					= xp.mgiTransactionSessionID
			 ,amt						= xp.receiveAmount
			 ,pBranch				    = xp.branch
			 ,sendingCountry			= xp.originatingCountry
			 ,sendingAgent				= xp.agentName
			 ,branchName				= @branchName
			 ,providerName				= 'Money Gram'
			 ,orderNo					= ''	
			 ,agentGrp						= @agentGrp	
	    FROM mgPayHistory xp WITH(NOLOCK)
		WHERE id = @rowId ORDER BY id DESC

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2

		RETURN 
	END

	IF (@partnerId='4816')   /***** Instant Cash *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @rowId	
		SELECT TOP 1
			  rowId			
			 ,securityNo				= dbo.FNADecryptString(ic.ICTC_Number)			   
			 ,transactionDate		    = CASE WHEN ISNULL(ic.Transaction_SentDate,'')<>'' AND LEN(ic.Transaction_SentDate)=8
											THEN SUBSTRING(ic.Transaction_SentDate,5,2)+'/'+SUBSTRING(ic.Transaction_SentDate,7,2)+'/'+SUBSTRING(ic.Transaction_SentDate,1,4)
											ELSE ic.Transaction_SentDate
										  END -- 11/13/2014
										  
			 ,senderName				= ic.Remitter_Name
			 ,senderAddress				= ISNULL(ic.Remitter_Address,'')
			 ,senderMobile				= ''
			 ,senderTel					= ''
			 ,senderIdNo				= ic.Remitter_IDDtl
			 ,senderIdType				= ic.Remitter_IDType
			 ,senderCity				= ''
			 ,recName					= ic.Beneficiary_Name
			 ,recAddress				= ic.Beneficiary_Address	
			 ,recMobile					= ISNULL(ic.Beneficiary_MobileNo,'')
			 ,recTelePhone				= ISNULL(ic.Beneficiary_TelNo,'')
			 ,recIdType					= ic.rIdType
			 ,recIdNo					= ic.rIdNumber
			 ,recCity					= ic.Beneficiary_City
			 ,recCountry				= ic.Destination_Country
			 ,pAmount					= ic.Paying_Amount
			 ,rCurrency					= ic.Paying_Currency
			 ,pCurrency					= 'NPR'
			 ,remarks					= ic.remarks
			 ,paymentMethod				= 'Cash Payment'
			 ,tokenId					= ''
			 ,amt						= ic.Paying_Amount
			 ,pBranch				    = ic.pBranch
			 ,sendingCountry			= ic.Originating_Country
			 ,sendingAgent				= ''
			 ,branchName				= @branchName
			 ,providerName				= 'Instant Cash'
			 ,orderNo					= ic.Agent_OrderNumber	
			 ,agentGrp						= @agentGrp	
	    FROM icPayHistory ic WITH(NOLOCK)
		WHERE rowId = @rowId ORDER BY rowId DESC

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE 1=2

		RETURN
	END	

	DECLARE 
		@mapCodeDom VARCHAR(50)
	   ,@tranStatus VARCHAR(50)
	   ,@tranId INT
	   ,@payStatus VARCHAR(50)
	   ,@controlNoEncrypted VARCHAR(50)
	   ,@agentType VARCHAR(50)
	   ,@pTxnLocation VARCHAR(50)
	   ,@pAgentLocation VARCHAR(50)
	   ,@pAgent VARCHAR(50)
	   ,@controlNo VARCHAR(50)
	   ,@paymentMethod VARCHAR(50)
	   ,@sBranchId VARCHAR(50)	  
	   ,@mapCodeInt VARCHAR(50)
	   ,@lockStatus VARCHAR(50)	 
	   ,@payTokenId VARCHAR(50)  
	IF (@partnerId='IME-D')    /***** IME DOMESTIC*****/
	BEGIN 				
		IF @pBranchId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please Choose Paying Agent', NULL
			RETURN
		END
		SELECT 
			@mapCodeDom = mapCodeDom,
			@agentType = agentType, 
			@pAgentLocation = agentLocation,
			@branchName = agentName			 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranchId
		IF (@mapCodeDom IS NULL OR @mapCodeDom = '' OR @mapCodeDom = 0)
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Map Code', NULL
			RETURN
		END
	
		SELECT 
			@tranStatus = tranStatus, 
			@tranId = id,
			@payStatus = payStatus ,
			@controlNoEncrypted = controlNo,
			@paymentMethod = paymentMethod,
			@sBranchId = sBranch,
			@pTxnLocation = pLocation
		FROM remitTran WITH(NOLOCK) 
		WHERE id = @rowId
	
		IF @tranStatus IS NULL
		BEGIN
			EXEC proc_errorHandler 1000, 'Transaction not found', NULL
			RETURN
		END

		IF @agentType = 2903		
		BEGIN
			SET @pAgent = @pBranchId
		END
	
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
			,@pBranchId
			,@user
			,GETDATE()
			,@tranId
				
		IF @paymentMethod = 'Bank Deposit'
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot process payment for Payment Type Bank Deposit', NULL
			RETURN	
		END
		IF @sBranchId = @pBranchId
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

		DECLARE @tranDistrictId INT, @payAgentDistrictId INT			
		SELECT @payAgentDistrictId = districtId FROM apiLocationMapping WHERE apiDistrictCode = @pAgentLocation
		SELECT @tranDistrictId = districtId FROM apiLocationMapping WHERE apiDistrictCode = @pTxnLocation
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
		SET @payTokenId = SCOPE_IDENTITY()
		SELECT TOP 1
				 rowId						=trn.id
				,securityNo					=dbo.FNADecryptString(trn.controlNo)	
				,transactionDate		    =trn.createdDateLocal
				,senderName					=sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
				,senderAddress				=sen.address
				,senderCity					=sen.city
				,senderMobile				=sen.mobile
				,senderTel					=sen.homephone
				,senderIdType				=sen.idType
				,senderIdNo					=sen.idNumber
				,recName					=rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
				,recAddress					=rec.address
				,recMobile					=rec.mobile
				,recTelePhone				=rec.homephone
				,recIdType					=rec.idType
				,recIdNo					=rec.idNumber
				,recCity					=rec.city
				,recCountry					=rec.country
				,pAmount					=trn.pAmt
				,rCurrency					=trn.collCurr
				,pCurrency					=trn.payoutCurr
				,remarks					=pMessage
				,paymentMethod				=trn.paymentMethod
				,tokenId					=trn.payTokenId
				,amt						=tAmt
				,pBranch				    =trn.pBranch
				,sendingCountry				=trn.sCountry
				,sendingAgent				=trn.sAgentName				
				,branchName					=@branchName
				,providerName				='IME Domestic'
				,orderNo					= ''	
				,agentGrp						= @agentGrp	
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		WHERE trn.id = @rowId

		-- ## Lock Transaction
		UPDATE remitTran SET 
				 payTokenId			= @payTokenId
				,tranStatus			= 'Lock'
				,lockedBy			= @user
				,lockedDate			= GETDATE()
				,lockedDateLocal	= GETDATE()
		WHERE id = @rowId

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE trn.tranId = @tranId OR ISNULL(trn.controlNo,'') = ISNULL(@controlNoEncrypted, '')
		ORDER BY trn.createdDate DESC

		-- ## Compliance pay details Details
		SELECT tranId
				,controlNo
				,pBranch
				,receiverName
				,rMemId
				,dob = CONVERT(VARCHAR(10),dob,101)
				,rIdType
				,rIdNumber
				,rPlaceOfIssue
				,rContactNo
				,rRelationType
				,rRelativeName
				,relWithSender
				,purposeOfRemit = ISNULL(sd.detailTitle,purposeOfRemit)
				,purposeOfRemitId = purposeOfRemit	
				,reason
				,bankName
				,branchName
				,chequeNo
				,accountNo
				,alternateMobileNo FROM tranPayCompliance tc WITH(NOLOCK)
				LEFT JOIN staticDataValue sd WITH(NOLOCK) ON tc.purposeOfRemit=sd.valueId
				WHERE tc.tranId = @tranId OR ISNULL(tc.controlNo,'') = ISNULL(@controlNoEncrypted, '')

	END
	IF (@partnerId='IME-I')    /***** IME INTERNATIONAL *****/
	BEGIN 
		
		IF @pBranchId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please Choose Agent', NULL
			RETURN
		END

		SELECT 
		     @mapCodeInt = mapCodeInt
			,@agentType = agentType
			,@pAgentLocation = agentLocation 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranchId

		IF (@mapCodeInt IS NULL OR @mapCodeInt = '' OR @mapCodeInt = 0)
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Map Code', NULL
			RETURN
		END
	
		SELECT 
			  @tranStatus = tranStatus
			, @tranId = id 
			, @lockStatus = lockStatus
			, @payStatus = payStatus
			, @sBranchId = sBranch
			, @paymentMethod = paymentMethod
			, @controlNoEncrypted = controlNo
		FROM remitTran WITH(NOLOCK) WHERE id = @rowId
	
		IF @tranStatus IS NULL
		BEGIN
			EXEC proc_errorHandler 1000, 'Transaction not found', NULL
			RETURN
		END

		IF @agentType = 2903	
		BEGIN
			SET @pAgent = @pBranchId
		END

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
			,@pBranchId
			,@user
			,GETDATE()
			,@tranId
		
		IF @paymentMethod = 'Bank Deposit'
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot process payment for Payment Type Bank Deposit', NULL
			RETURN	
		END
		IF @sBranchId = @pBranchId
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot process payment for same POS', @tranId
			RETURN
		END
		
		IF (@tranStatus = 'CancelRequest')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction has been requested for cancel', @controlNoEncrypted
			RETURN
		END
		IF (@lockStatus = 'Lock' )
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is locked', @controlNoEncrypted
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
		EXEC proc_errorHandler 0, 'Transaction Verification Successful', @tranId	
		SET @payTokenId = SCOPE_IDENTITY()	
		SELECT TOP 1
				 rowId						=trn.id
				,securityNo					=dbo.FNADecryptString(trn.controlNo)	
				,transactionDate		    =trn.createdDateLocal
				,senderName					=sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
				,senderAddress				=sen.address
				,senderCity					=sen.city
				,senderMobile				=sen.mobile
				,senderTel					=sen.homephone
				,senderIdType				=sen.idType
				,senderIdNo					=sen.idNumber
				,recName					=rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
				,recAddress					=rec.address
				,recMobile					=rec.mobile
				,recTelePhone				=rec.homephone
				,recIdType					=rec.idType
				,recIdNo					=rec.idNumber
				,recCity					=rec.city
				,recCountry					=rec.country
				,pAmount					=trn.pAmt
				,rCurrency					=trn.collCurr
				,pCurrency					=trn.payoutCurr
				,remarks					=pMessage
				,paymentMethod				=trn.paymentMethod
				,tokenId					=trn.payTokenId
				,amt						=trn.pAmt
				,pBranch				    =trn.pBranch
				,sendingCountry				=trn.sCountry
				,sendingAgent				=trn.sAgentName
				,branchName					=dbo.GetAgentNameFromId(@pBranchId)
				,providerName				='IME International'
				,orderNo					= ''
				,agentGrp					= @agentGrp		
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		WHERE trn.id = @rowId
		
		-- ## Lock Transaction
		UPDATE remitTran SET
			 payTokenId			= @payTokenId
			,lockStatus			= 'locked'
			,lockedBy			= @user
			,lockedDate			= GETDATE()
			,lockedDateLocal	= GETDATE()
		WHERE id = @rowId

		-- ## Log Details
		SELECT 
			 [message]
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		WHERE trn.tranId = @tranId OR ISNULL(trn.controlNo,'') = ISNULL(@controlNoEncrypted, '')
		ORDER BY trn.createdDate DESC

		-- ## Compliance pay details Details
		SELECT tranId
				,controlNo
				,pBranch
				,receiverName
				,rMemId
				,dob = CONVERT(VARCHAR(10),dob,101)
				,rIdType
				,rIdNumber
				,rPlaceOfIssue
				,rContactNo
				,rRelationType
				,rRelativeName
				,relWithSender
				,purposeOfRemit = ISNULL(sd.detailTitle,purposeOfRemit)
				,purposeOfRemitId = purposeOfRemit	
				,reason
				,bankName
				,branchName
				,chequeNo
				,accountNo
				,alternateMobileNo FROM tranPayCompliance tc WITH(NOLOCK)
				LEFT JOIN staticDataValue sd WITH(NOLOCK) ON tc.purposeOfRemit=sd.valueId
				WHERE tc.tranId = @tranId OR ISNULL(tc.controlNo,'') = ISNULL(@controlNoEncrypted, '')

	END
END

GO
