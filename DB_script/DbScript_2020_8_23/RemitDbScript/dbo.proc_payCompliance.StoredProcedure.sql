USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payCompliance]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_payCompliance](
		 @flag				VARCHAR(20)			
		,@user			    VARCHAR(50)		= NULL			
	    ,@id				INT				= NULL
		,@remarks			VARCHAR(MAX)	= NULL
		,@controlNo			VARCHAR(50)		= NULL
		,@csDetailRecId		BIGINT			= NULL
		,@sortBy            VARCHAR(50)		= NULL
		,@sortOrder         VARCHAR(5)		= NULL
		,@pageSize          INT				= NULL
		,@pageNumber        INT				= NULL
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY

DECLARE @tranId BIGINT	

IF @flag='txn_list'
BEGIN
		DECLARE
			 @sql				VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)	

		SET @table = '
			(
			SELECT 	TOP 10
					 provider		= CASE  WHEN rtc.provider =''4734'' THEN ''Global Remit''
											WHEN  rtc.provider =''4670'' THEN ''Cash Express''
											WHEN  rtc.provider =''4726'' THEN ''EZ Remit''
											WHEN  rtc.provider =''4869'' THEN ''RIA Remit''
											WHEN  rtc.provider =''4854'' THEN ''MoneyGram''
											
											WHEN  rtc.provider =''4909'' THEN ''Xpress Mone''
											WHEN  rtc.provider =''4816'' THEN ''Instant Cash''
											WHEN  rtc.provider =''4812'' THEN ''IME-I''
											WHEN  rtc.provider =''1002'' THEN ''IME-D''
											ELSE ''-'' END 
											
					 ,tranId		= rtc.TranId			
					,controlNo		= ''<a href="'+dbo.FNAGetURL()+'Remit/Transaction/ApproveOFAC/PayTranCompliance/Manage.aspx?rowId='' + cast(rtc.rowId as varchar) + ''">'' +dbo.fnadecryptstring(rtc.controlNo)+ ''</a>''
					,pBranchName	= am.agentName
					,receiverName	= receiverName
					,type			= ''Compliance''
					,createdBy		= rtc.createdBy
					,createdDate	= rtc.createdDate					
					,hasChanged = ''''
			FROM tranPayCompliance rtc WITH(NOLOCK)
			LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON rtc.pBranch = am.agentId
			WHERE rtc.approvedDate IS NULL  '

		IF @controlNo IS NOT NULL
			SET @table = @table + ' AND rtc.controlNo LIKE ''%' + dbo.fnaencryptstring(@controlNo) + '%'''

		SET @table = @table + ' )x'
		SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
						
		SET @sql_filter = ''
					
		SET @select_field_list ='			 
			 controlNo
			,pBranchName
			,type
			,receiverName			
			,hasChanged
			,createdBy
			,createdDate			
			,tranId
			,provider
			'
			
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
	END
IF @Flag='s'
BEGIN
	DECLARE 
	    @agentGrp INT,
		@partnerId BIGINT, 
		@branchName VARCHAR(200),
		@rowId BIGINT

	SELECT  @partnerId = provider,
			@rowId = tranId
	FROM tranPayCompliance WITH(NOLOCK) 
		WHERE rowId = @id

	IF @partnerId IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid Transaction.', @rowId
		RETURN;
	END
	IF(@partnerId='4734')  /***** Global Remit *****/
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
			,pAmount		    = gbl.amount
			,rCurrency			= gbl.rCurrency
			,pCurrency			= gbl.pCurrency
			,remarks			= gbl.remarks	
			,paymentMethod		= 'Cash Payment'
			,tokenId			= gbl.tokenId	
			,amt				= gbl.amount
			,pBranch			= gbl.pBranch	
			,sendingCountry		= ''
			,sendingAgent		= ''	
			,branchName			= am.agentName
			,providerName       = 'Global Remit'
			,orderNo			= ''		  
		FROM globalBankPayHistory gbl WITH(NOLOCK)	
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON gbl.pBranch = am.agentId
		WHERE  rowId = @rowId ORDER BY rowId DESC

		--## Transaction Log Details
		SELECT TOP 1
			 rowId 
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK) WHERE 1=2

		RETURN
	 END			  
	IF (@partnerId='4670') /***** CASH EXPRESS *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
			 ,branchName				    = am.agentName
			 ,providerName					= 'Cash Express'
			 ,orderNo						= ''	
	    FROM cePayHistory ce WITH(NOLOCK)
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON ce.pBranch = am.agentId
		WHERE rowId = @rowId ORDER BY rowId DESC
		--## Transaction Log Details
		SELECT TOP 1
			 rowId 
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK) WHERE 1=2
		RETURN	
	END
	IF (@partnerId='4726')  /***** EZ Remit *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId		
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
				 ,recTelePhone			  	= ISNULL(ez.tbContactTelephoneNo,'')
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
				 ,branchName				= am.agentName
				 ,providerName				= 'EZ Remit'
				 ,orderNo					= ''
	    FROM ezPayHistory ez WITH(NOLOCK)
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON ez.pBranch = am.agentId
		WHERE ez.id = @rowId
		ORDER BY id DESC
		--## Transaction Log Details
		SELECT TOP 1
			 rowId 
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK) WHERE 1=2
		RETURN
	END
	IF (@partnerId='4869')   /***** RIA *****/
	BEGIN 		
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
			 ,branchName				= am.agentName
			 ,providerName				= 'RIA Financial'
			 ,orderNo					= ria.orderNo
	    FROM riaRemitPayHistory ria WITH(NOLOCK)
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON ria.pBranch = am.agentId
		WHERE rowId = @rowId ORDER BY rowId DESC
		--## Transaction Log Details
		SELECT TOP 1
			 rowId 
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK) WHERE 1=2
		RETURN
	END
	IF (@partnerId='4909')   /***** X-PRESS Money *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
			 ,branchName				= am.agentName
			 ,providerName				= 'XPRESS Money'
			 ,orderNo					= ''		
	    FROM xPressTranHistory xp WITH(NOLOCK)
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON xp.branchId = am.agentId
		WHERE rowId = @rowId ORDER BY rowId DESC
		--## Transaction Log Details
		SELECT TOP 1
			 rowId 
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK) WHERE 1=2
		RETURN
	END
	IF @partnerId = '4854'   /***** MONEY GRAM *****/
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
			 ,branchName				= am.agentName
			 ,providerName				= 'Money Gram'
			 ,orderNo					= ''	
	    FROM mgPayHistory xp WITH(NOLOCK)
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON xp.branch = am.agentId
		WHERE id = @rowId ORDER BY id DESC
		--## Transaction Log Details
		SELECT TOP 1
			 rowId 
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK) WHERE 1=2
		RETURN 
	END
	IF (@partnerId='4816')   /***** Instant Cash *****/
	BEGIN 	
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
			 ,branchName				= am.agentName
			 ,providerName				= 'Instant Cash'
			 ,orderNo					= ic.Agent_OrderNumber	
	    FROM icPayHistory ic WITH(NOLOCK)
		LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON ic.pBranch = am.agentId
		WHERE rowId = @rowId ORDER BY rowId DESC		
		--## Transaction Log Details
		SELECT TOP 1
			 rowId 
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK) WHERE 1=2
		RETURN
	END	

	DECLARE 
		@mapCodeDom VARCHAR(50)
	   ,@tranStatus VARCHAR(50)	  
	   ,@payStatus VARCHAR(50)
	   ,@controlNoEncrypted VARCHAR(50)
	   ,@agentType VARCHAR(50)
	   ,@pTxnLocation VARCHAR(50)
	   ,@pAgentLocation VARCHAR(50)
	   ,@pAgent VARCHAR(50)
	   ,@paymentMethod VARCHAR(50)
	   ,@sBranchId VARCHAR(50)	  
	   ,@mapCodeInt VARCHAR(50)
	   ,@lockStatus VARCHAR(50)	 
	   ,@payTokenId VARCHAR(50)  
	IF (@partnerId='4812')    /***** IME INTERNATIONAL *****/
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
				,branchName					=am.agentName
				,providerName				='IME International'
				,orderNo					= ''
				,agentGrp					= @agentGrp		
				,rIdType					= tpc.rIdType
                ,rIdNumber					= tpc.rIdNumber
                ,rPlaceOfIssue				= tpc.rPlaceOfIssue
                ,rRelativeName				= tpc.rRelativeName
                ,rRelationType				= tpc.rRelationType
                ,rContactNo					= tpc.rContactNo
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		INNER JOIN dbo.tranPayCompliance tpc WITH(NOLOCK) ON tpc.tranId = trn.id
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = tpc.pBranch
		WHERE trn.id = @rowId	

		-- ## Transaction Log Details
		SELECT @controlNoEncrypted = controlNo 
			FROM remitTran rt WITH(NOLOCK) WHERE id = @rowId
		SELECT 
			 rowId
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
		WHERE trn.tranId = @tranId OR trn.controlNo = @controlNoEncrypted
		ORDER BY trn.rowId DESC	
	END

	IF (@partnerId='1002')    /***** IME Nepal *****/
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId
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
				,branchName					=am.agentName
				,providerName				='IME Nepal'
				,orderNo					= ''
				,agentGrp					= @agentGrp		
				,rIdType					= tpc.rIdType
                ,rIdNumber					= tpc.rIdNumber
                ,rPlaceOfIssue				= tpc.rPlaceOfIssue
                ,rRelativeName				= tpc.rRelativeName
                ,rRelationType				= tpc.rRelationType
                ,rContactNo					= tpc.rContactNo
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		INNER JOIN dbo.tranPayCompliance tpc WITH(NOLOCK) ON tpc.tranId = trn.id
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = tpc.pBranch
		WHERE trn.id = @rowId	

		-- ## Transaction Log Details
		SELECT @controlNoEncrypted = controlNo 
			FROM remitTran rt WITH(NOLOCK) WHERE id = @rowId
		SELECT 
			 rowId
			,message
			,trn.createdBy
			,trn.createdDate
		FROM tranModifyLog trn WITH(NOLOCK)
		LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
		WHERE trn.tranId = @tranId OR trn.controlNo = @controlNoEncrypted
		ORDER BY trn.rowId DESC	
	END
END
ELSE IF @flag='compliance'
BEGIN
	IF @controlNo IS NULL 
		SELECT @controlNo = dbo.FNADecryptString(controlNo) FROM tranPayCompliance WITH(NOLOCK) WHERE rowId = @id

	DECLARE @holdTranId BIGINT
	SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo)
	
	SELECT
		 rowId
		,csDetailRecId 
		,[S.N.]		= ROW_NUMBER()OVER(ORDER BY ROWID)	
		,[Remarks]	= ISNULL( RTRIM(LTRIM(ISNULL(dbo.FNAGetDataValue(condition),''))) + ' ' + 
						CASE WHEN checkType = 'Sum' THEN 'Transaction Amount' 
							 WHEN checkType = 'Count' THEN 'Transaction Count' END
						+ ' exceeds ' + CAST(PARAMETER AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)   
						,reason)
		,[Matched TRAN ID] = ISNULL(rtc.matchTranId,rtc.TranId)
	FROM remitTranCompliancePay rtc WITH(NOLOCK)
	LEFT JOIN csDetailRec cdr WITH(NOLOCK) ON rtc.csDetailTranId = cdr.csDetailRecId 
	WHERE rtc.TranId = ISNULL(@holdTranId, @tranId)
END
IF @flag = 'release'
BEGIN 
	IF EXISTS(SELECT 'X' FROM tranPayCompliance WITH(NOLOCK) WHERE rowId = @id)
	BEGIN		
		IF @remarks IS NULL
		BEGIN		
			EXEC proc_errorHandler 1, 'Compliance remarks can not be blank.', @id
			RETURN;		
		END	
		
		BEGIN TRANSACTION

			UPDATE tranPayCompliance SET 
				 approvedRemarks	= @remarks
				,approvedBy			= @user
				,approvedDate		= GETDATE()
				,@tranId			= tranId 
			WHERE rowId = @id AND approvedDate IS NULL

			UPDATE remitTranCompliancePay SET 
				 approvedRemarks	= @remarks
				,approvedBy			= @user
				,approvedDate		= GETDATE() 
			WHERE tranId = @tranId AND approvedDate IS NULL

			UPDATE remitTran SET 
				tranStatus			= 'Payment'
			WHERE id = @tranId

		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Release remarks has been saved successfully.', @id
	END
	EXEC proc_errorHandler 1, 'Transaction not found.', @id
END
--EXEC proc_transactionView @FLAG='COMPL_DETAIL',@controlNo='1',@tranId='1'
IF @flag='COMPL_DETAIL'
BEGIN
/*
5000	By Sender ID
5001	By Sender Name
5002	By Sender Mobile
5003	By Beneficiary ID
5004	By Beneficiary ID(System)
5005	By Beneficiary Name
5006	By Beneficiary Mobile
5007	By Beneficiary A/C Number
*/
	DECLARE @tranIds AS VARCHAR(MAX), @criteria AS INT, @totalTran AS INT, @criteriaValue AS VARCHAR(500), @reason VARCHAR(500)
	SELECT 
		@tranIds = matchTranId, 
		@tranId = TranId 
	FROM remitTranCompliancePay with(nolock) 
	WHERE rowId = @id --(ROWID) --id of remitTranCompliancePay

	SELECT @criteria = criteria FROM csDetailRec with(nolock) WHERE csDetailRecId = @csDetailRecId--id of csDetailRec
	SELECT @totalTran = COUNT(*) FROM dbo.Split(',', @tranIds)
		
	IF @criteria='5000'
		SELECT @criteriaValue = B.membershipId
			 FROM tranSenders B with(nolock) WHERE B.tranId = @tranId			 
			 
	IF @criteria='5001'
		SELECT @criteriaValue = senderName FROM remitTran with(nolock) WHERE Id = @tranId	
			 
	IF @criteria='5002'
		SELECT @criteriaValue = B.mobile
			 FROM tranSenders B with(nolock) WHERE B.tranId = @tranId	
			 
	IF @criteria='5003'
		SELECT @criteriaValue = B.rMemId
			 FROM tranPayCompliance B with(nolock) WHERE B.tranId = @tranId	
			 
	IF @criteria='5004'
		SELECT @criteriaValue = B.rMemId
			 FROM tranPayCompliance B with(nolock) WHERE B.tranId = @tranId
			 
	IF @criteria='5005'
		SELECT @criteriaValue = receiverName FROM tranPayCompliance with(nolock) WHERE tranId = @tranId	
		
	IF @criteria='5006'
		SELECT @criteriaValue = B.rContactNo
			 FROM tranPayCompliance B with(nolock) WHERE B.tranId = @tranId		
	
	IF @criteria='5007'
		SELECT @criteriaValue = A.accountNo
			 FROM remitTran A with(nolock) WHERE A.id = @tranId	
				 
	SELECT
		 REMARKS	= CASE WHEN @csDetailRecId = 0 THEN @reason ELSE
						RTRIM(LTRIM(ISNULL(dbo.FNAGetDataValue(condition),''))) + ' ' + 
						CASE WHEN checkType = 'Sum' THEN 'Transaction Amount' 
							 WHEN checkType = 'Count' THEN 'Transaction Count' END
						+ ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)+': <font size=''2px''>'+ISNULL(@criteriaValue,'')+'</font>'
						END
		,totTran	= 'Total Count: <b>'+ CASE WHEN @csDetailRecId = 0 THEN '1' ELSE  CAST(@totalTran AS VARCHAR) END +'</b>'
	FROM csDetailRec with(nolock)
	WHERE csDetailRecId= CASE WHEN @csDetailRecId=0 THEN 1 ELSE @csDetailRecId END

	SELECT 
		 [S.N.]			= ROW_NUMBER() OVER(ORDER BY @id)
		,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)
		,[TRAN AMOUNT]	= dbo.ShowDecimal(trn.cAmt) 
		,[CURRENCY]		= trn.collCurr 
		,[TRAN DATE]	= CONVERT(VARCHAR,trn.createdDate,101)  		
	FROM VWremitTran trn with(nolock) INNER JOIN 
	(
		SELECT * FROM dbo.Split(',', @tranIds)
	)B ON trn.id = B.value
	
	UNION ALL
	---- RECORD DISPLAY FROM CANCEL TRANSACTION TABLE
	SELECT 
		 [S.N.]			= ROW_NUMBER() OVER(ORDER BY @controlNo)
		,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)
		,[TRAN AMOUNT]	= dbo.ShowDecimal(trn.cAmt) 
		,[CURRENCY]		= trn.collCurr 
		,[TRAN DATE]	= CONVERT(VARCHAR,trn.createdDate,101)  		
	FROM cancelTranHistory trn with(nolock) INNER JOIN 
	(
		SELECT * FROM dbo.Split(',', @tranIds)
	)B ON trn.tranId = B.value
END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN
END CATCH



GO
