USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ezPayHistory]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_ezPayHistory](
	 @flag									VARCHAR(50)		= NULL
	,@user									VARCHAR(50)		= NULL
	,@rowId									BIGINT		  	= NULL	
	,@TransactionNumber						VARCHAR(50)		= NULL
	,@SecurityNumber						VARCHAR(50)		= NULL
	,@TransactionDate						VARCHAR(50)		= NULL
	,@TypeOfTransaction						VARCHAR(50)		= NULL
	,@TransactionStatus						VARCHAR(50)		= NULL
	,@scCustomerName						VARCHAR(50)		= NULL
	,@scCustomerArabicName					VARCHAR(50)		= NULL
	,@scCustomerAddress						VARCHAR(50)		= NULL
	,@scCustomerCardNumber					VARCHAR(50)		= NULL
	,@scCustID								VARCHAR(50)		= NULL
	,@scCustIDType							VARCHAR(50)		= NULL
	,@scCustTelephoneNumber					VARCHAR(50)		= NULL
	,@scCustMobileNumber					VARCHAR(50)		= NULL
	,@scCustNationality						VARCHAR(50)		= NULL
	,@scCustEmail							VARCHAR(50)		= NULL
	,@sccustDOB								VARCHAR(50)		= NULL
	,@scCustMessage							VARCHAR(50)		= NULL
	,@scCustOccupation						VARCHAR(50)		= NULL
	,@scRelationship						VARCHAR(50)		= NULL
	,@scCustBankcode						VARCHAR(50)		= NULL
	,@scCustBankShortname					VARCHAR(50)		= NULL
	,@scCustBankName						VARCHAR(50)		= NULL
	,@scCustBankBranchcode					VARCHAR(50)		= NULL
	,@scCustBankBranchshortname				VARCHAR(50)		= NULL
	,@scCustBankBranchName					VARCHAR(50)		= NULL
	,@scBranchAddress						VARCHAR(50)		= NULL
	,@scContactPerson						VARCHAR(50)		= NULL 
	,@scContactTelephoneNo					VARCHAR(50)		= NULL
	,@scCustCountryCode						VARCHAR(50)		= NULL
	,@scCustCountry							VARCHAR(50)		= NULL
	,@tbName								VARCHAR(50)		= NULL
	,@tbArabicName							VARCHAR(50)		= NULL
	,@tbAddress								VARCHAR(50)		= NULL
	,@tbAccountNumber						VARCHAR(50)		= NULL
	,@tbIdNumber							VARCHAR(50)		= NULL
	,@tbIdtype								VARCHAR(50)		= NULL
	,@tbBenBankName							VARCHAR(50)		= NULL
	,@tbBenBankBranchName					VARCHAR(50)		= NULL
	,@tbBankShortName						VARCHAR(50)		= NULL
	,@tbBankName							VARCHAR(50)		= NULL
	,@tbBranchShortName						VARCHAR(50)		= NULL
	,@tbBranchName							VARCHAR(50)		= NULL
	,@tbBranchAddress						VARCHAR(50)		= NULL
	,@tbContactPerson						VARCHAR(50)		= NULL
	,@tbContactTelephoneNo					VARCHAR(50)		= NULL
	,@tbIBBank								VARCHAR(50)		= NULL
	,@tbIBBranch							VARCHAR(50)		= NULL
	,@tbIBAddress							VARCHAR(50)		= NULL
	,@tbIBBankAccountno						VARCHAR(50)		= NULL
	,@tbIBBankDiffernt						VARCHAR(50)		= NULL
	,@tbIBClearingNumber					VARCHAR(50)		= NULL
	,@tbIBClearingType						VARCHAR(50)		= NULL
	,@tbIBSwiftCode							VARCHAR(50)		= NULL
	,@tbTelephoneNumber						VARCHAR(50)		= NULL
	,@tbMobileNumber						VARCHAR(50)		= NULL
	,@tbNationality							VARCHAR(50)		= NULL
	,@tbBenCountry							VARCHAR(50)		= NULL
	,@tbFundSource							VARCHAR(50)		= NULL
	,@tbPin									VARCHAR(50)		= NULL
	,@tbPurpose								VARCHAR(50)		= NULL
	,@tbSwiftCode							VARCHAR(50)		= NULL
	,@tbPaymentAgentCode					VARCHAR(50)		= NULL
	,@tbPaymentAgentCountryCode				VARCHAR(50)		= NULL
	,@tbPaymentAgentLocationCode			VARCHAR(50)		= NULL
	,@tbRecipientName						VARCHAR(50)		= NULL
	,@tbRecipientAddress					VARCHAR(50)		= NULL
	,@tbRecipientTelephone					VARCHAR(50)		= NULL
	,@tbRecipientMessage					VARCHAR(50)		= NULL
	,@tbReceiverComm						VARCHAR(50)		= NULL
	,@tbTypeOfTransaction					VARCHAR(50)		= NULL
													   		
	,@tdFxAmount							VARCHAR(50)		= NULL
	,@tdRate								VARCHAR(50)		= NULL
	,@tdMktRate								VARCHAR(50)		= NULL
	,@tdLocalAmount							VARCHAR(50)		= NULL
	,@tdTotalLocalAmount					VARCHAR(50)		= NULL
	,@tdCommissionAmount					VARCHAR(50)		= NULL
	,@tdLocalCurrencyCode					VARCHAR(50)		= NULL
	,@tdFxCurrencyCode						VARCHAR(50)		= NULL
	 												  
	,@apiStatus								VARCHAR(50)		= NULL
	,@payResponseCode						VARCHAR(20)		= NULL
	,@payResponseMsg						VARCHAR(100)	= NULL
	,@recordStatus							VARCHAR(50)		= NULL
	,@tranPayProcess						VARCHAR(20)		= NULL
	,@createdDate							DATETIME   		= NULL	
	,@paidDate								DATETIME   		= NULL
	,@paidBy								VARCHAR(30)		= NULL
	,@rContactNo							VARCHAR(50)		= NULL
	,@nativeCountry							VARCHAR(100)	= NULL
	,@pBranch								INT		   		= NULL
	,@rIdType								VARCHAR(30)		= NULL
	,@rIdNumber								VARCHAR(30)		= NULL
	,@rIdPlaceOfIssue						VARCHAR(50)		= NULL
	,@rIssuedDate							DATETIME		= NULL
	,@rValidDate							DATETIME		= NULL
	,@rDob									DATETIME		= NULL
	,@rAddress								VARCHAR(100)	= NULL 
	,@rCity									VARCHAR(100)	= NULL 
	,@rOccupation							VARCHAR(100)	= NULL
	,@relationType							VARCHAR(50)		= NULL
	,@relativeName							VARCHAR(100)	= NULL
	,@remarks								VARCHAR(500)	= NULL
	,@cAmt									VARCHAR(100)	= NULL
	,@pAmt									VARCHAR(100)	= NULL
	,@tAmt									VARCHAR(100)	= NULL
	
	,@sCountry								VARCHAR(100)	= NULL
	,@pCountry								VARCHAR(100)	= NULL	
	
	
	,@pBranchName							VARCHAR(100)	=NULL
	
	,@agentName								VARCHAR(100)    = NULL
	,@provider								VARCHAR(100)    = NULL
	
	,@sortBy								VARCHAR(50)		= NULL
	,@sortOrder								VARCHAR(5)		= NULL
	,@pageSize								INT				= NULL
	,@pageNumber						    INT				= NULL
	,@controlNo							    VARCHAR(50)		= NULL
	,@customerId							VARCHAR(50)		= NULL
	,@membershipId							VARCHAR(50)		= NULL
	
	,@rbankName								VARCHAR(50)		= NULL
	,@rbankBranch							VARCHAR(100)	= NULL
	,@rcheque								VARCHAR(50)		= NULL
	,@rAccountNo							VARCHAR(50)		= NULL
	,@topupMobileNo							varchar(50)		= null
	,@relationship							VARCHAR(100)	= NULL
	,@purpose								VARCHAR(100)	= NULL
	
)AS	
SET NOCOUNT ON
SET XACT_ABORT ON													
BEGIN TRY
	DECLARE
		 @SecurityNoEnc				VARCHAR(50) = dbo.FNAencryptString(@SecurityNumber)
		 		 
	IF @flag = 's'
	BEGIN	
		DECLARE @table				VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
		SET @table = '
			(
				SELECT
					rowId=id
					,''EZREMIT Remit'' AS provider
					,am.agentName
					,dbo.FNADecryptString(SecurityNumber) AS xpin
					,customer				= ISNULL(scCustomerName, '''')
					,beneficiary			= ISNULL(tbName, '''')
					,customerAddress		= ISNULL(scCustomerAddress, '''')
					,beneficiaryAddress		= ISNULL(tbAddress, '''')
					,payoutAmount			= ez.tdFxAmount
					,payoutDate				=ez.paidDate
				FROM ezPayHistory  ez WITH(NOLOCK)
				LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = ez.pBranch
				WHERE recordStatus NOT IN(''DRAFT'', ''EXPIRED'')			
			'
			IF @SecurityNumber IS NOT NULL
			BEGIN				
				SET @table = @table + ' AND SecurityNumber = ''' + @SecurityNoEnc + ''''	
				select @pBranch = pBranch,@user = createdBy from ezPayHistory with(nolock)
				where SecurityNumber = @SecurityNoEnc
				if @pBranch is null and @user is not null
				begin
					select @pBranch = agentId  from applicationUsers with(nolock)  
					where userName = @user
					update ezPayHistory set pBranch = @pBranch 
					where SecurityNumber = @SecurityNoEnc 
				end				
			END
			ELSE
			BEGIN
				SET @table = @table + ' AND tranPayProcess IS NULL'
			END
			
			IF @agentName IS NOT NULL
				SET @table = @table + ' AND am.agentName LIKE ''' + @agentName + '%'''
			SET @table = @table + ' 
			) x '
			
			SET @sql_filter = ''	
		
			IF @provider IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND provider LIKE ''' + @provider + '%'''
			

			SET @select_field_list ='
				 rowId
				,provider		
				,agentName 
				,xpin
				,customer
				,beneficiary
				,customerAddress
				,beneficiaryAddress
				,payoutAmount
				,payoutDate			
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

		RETURN
	END

	IF @flag='a'
	BEGIN	
		SELECT TOP 100
			rowId			= ez.id
		   ,[controlNo] 	= dbo.FNADecryptString(ez.SecurityNumber)		 
		   ,[sCountry]  	= ez.scCustCountry
		   ,[sName]			= ez.scCustomerName
		   ,[sAddress]  	= ISNULL(ez.scCustomerAddress,'')
		   ,sCity			= null
		   ,sMobile			= isnull(ez.scCustTelephoneNumber,'')+isnull(','+ez.scCustMobileNumber,'')
		   ,sAgentName  	= 'EZREMIT LTD'
		   ,sAgent			= 4726		  
		   ,[rCountry]  	= 'Nepal'
		   ,[rName]			= ez.tbName
		   ,[rAddress]  	= ez.tbAddress
		   ,[rCity]			= isnull(ez.rCity,'')
		   ,[rPhone]		= ISNULL(ez.tbContactTelephoneNo,'')
		   ,branchId		= ez.pBranch 
		   ,[rIdType]		= ez.rIdType
		   ,[rIdNumber] 	= ez.rIdNumber
		   ,[pAmt]			= ez.tdFxAmount
		   ,[pCurr]			= ez.tdFxCurrencyCode
		   ,[pBranch]		= am.agentName
		   ,[pUser]			= ez.createdBy
		   ,transactionMode = 'Cash Payment'
		   ,PlaceOfIssue	= rIdPlaceOfIssue
		   ,rRelativeName	= relativeName
		   ,RelationType	= relationType
		   ,rContactNo		= rContactNo									
		FROM ezPayHistory ez WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON ez.pBranch = am.agentId
		WHERE recordStatus <> ('DRAFT') AND ez.id = @rowId
		ORDER BY id DESC
		RETURN
	END

	IF @flag='i'			
	BEGIN
		IF EXISTS(
				SELECT 'x'
				FROM ezPayHistory
				WHERE SecurityNumber=@SecurityNoEnc
		    )
		BEGIN
			UPDATE ezPayHistory SET 
				recordStatus = 'EXPIRED'
			WHERE  SecurityNumber= @SecurityNoEnc AND recordStatus <> 'READYTOPAY'
		END
		IF @pBranch IS NULL
			SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		IF @pBranch = '1001'
		BEGIN
			EXEC [proc_errorHandler] 1, 'Payout branch is missing.', @rowId
			RETURN;
		END	
		INSERT INTO ezPayHistory(
				 TransactionNumber				
				,SecurityNumber					
				,TransactionDate				
				,TypeOfTransaction				
				,TransactionStatus				
				,scCustomerName					
				,scCustomerArabicName			
				,scCustomerAddress				
				,scCustomerCardNumber			
				,scCustID						
				,scCustIDType					
				,scCustTelephoneNumber			
				,scCustMobileNumber				
				,scCustNationality				
				,scCustEmail					
				,sccustDOB						
				,scCustMessage					
				,scCustOccupation				
				,scRelationship					
				,scCustBankcode					
				,scCustBankShortname			
				,scCustBankName					
				,scCustBankBranchcode			
				,scCustBankBranchshortname		
				,scCustBankBranchName			
				,scBranchAddress				
				,scContactPerson				
				,scContactTelephoneNo			
				,scCustCountryCode				
				,scCustCountry					
				,tbName							
				,tbArabicName					
				,tbAddress						
				,tbAccountNumber				
				,tbIdNumber						
				,tbIdtype						
				,tbBenBankName					
				,tbBenBankBranchName			
				,tbBankShortName				
				,tbBankName						
				,tbBranchShortName				
				,tbBranchName					
				,tbBranchAddress				
				,tbContactPerson				
				,tbContactTelephoneNo			
				,tbIBBank						
				,tbIBBranch						
				,tbIBAddress					
				,tbIBBankAccountno				
				,tbIBBankDiffernt				
				,tbIBClearingNumber				
				,tbIBClearingType				
				,tbIBSwiftCode					
				,tbTelephoneNumber				
				,tbMobileNumber					
				,tbNationality					
				,tbBenCountry					
				,tbFundSource					
				,tbPin							
				,tbPurpose						
				,tbSwiftCode					
				,tbPaymentAgentCode				
				,tbPaymentAgentCountryCode		
				,tbPaymentAgentLocationCode		
				,tbRecipientName				
				,tbRecipientAddress				
				,tbRecipientTelephone			
				,tbRecipientMessage				
				,tbReceiverComm					
				,tbTypeOfTransaction			

				,tdFxAmount						
				,tdRate							
				,tdMktRate						
				,tdLocalAmount					
				,tdTotalLocalAmount				
				,tdCommissionAmount				
				,tdLocalCurrencyCode			
				,tdFxCurrencyCode				
				 	
				,apiStatus						
				,payResponseCode				
				,payResponseMsg					
				,recordStatus					
				,tranPayProcess					
				,createdDate					
				,createdBy						
				,paidDate						
				,paidBy							
				,rContactNo						
				,nativeCountry					
				,pBranch						
				,rIdType						
				,rIdNumber						
				,rIdPlaceOfIssue				
				,rValidDate						
				,rDob							
				,rAddress						
				,rCity							
				,rOccupation					
				,relationType					
				,relativeName					
				,remarks						
			
		)SELECT
				 @TransactionNumber					
				,@SecurityNoEnc					
				,@TransactionDate					
				,@TypeOfTransaction					
				,@TransactionStatus					
				,@scCustomerName					
				,@scCustomerArabicName				
				,@scCustomerAddress					
				,@scCustomerCardNumber				
				,@scCustID							
				,@scCustIDType						
				,@scCustTelephoneNumber				
				,@scCustMobileNumber				
				,@scCustNationality					
				,@scCustEmail						
				,@sccustDOB							
				,@scCustMessage						
				,@scCustOccupation					
				,@scRelationship					
				,@scCustBankcode					
				,@scCustBankShortname				
				,@scCustBankName					
				,@scCustBankBranchcode				
				,@scCustBankBranchshortname			
				,@scCustBankBranchName				
				,@scBranchAddress					
				,@scContactPerson					
				,@scContactTelephoneNo				
				,@scCustCountryCode					
				,@scCustCountry						
				,@tbName							
				,@tbArabicName						
				,@tbAddress							
				,@tbAccountNumber					
				,@tbIdNumber						
				,@tbIdtype							
				,@tbBenBankName						
				,@tbBenBankBranchName				
				,@tbBankShortName					
				,@tbBankName						
				,@tbBranchShortName					
				,@tbBranchName						
				,@tbBranchAddress					
				,@tbContactPerson					
				,@tbContactTelephoneNo				
				,@tbIBBank							
				,@tbIBBranch						
				,@tbIBAddress						
				,@tbIBBankAccountno					
				,@tbIBBankDiffernt					
				,@tbIBClearingNumber				
				,@tbIBClearingType					
				,@tbIBSwiftCode						
				,@tbTelephoneNumber					
				,@tbMobileNumber					
				,@tbNationality						
				,@tbBenCountry						
				,@tbFundSource						
				,@tbPin								
				,@tbPurpose							
				,@tbSwiftCode						
				,@tbPaymentAgentCode				
				,@tbPaymentAgentCountryCode			
				,@tbPaymentAgentLocationCode		
				,@tbRecipientName					
				,@tbRecipientAddress				
				,@tbRecipientTelephone				
				,@tbRecipientMessage				
				,@tbReceiverComm					
				,@tbTypeOfTransaction				
													
				,@tdFxAmount						
				,@tdRate							
				,@tdMktRate							
				,@tdLocalAmount						
				,@tdTotalLocalAmount				
				,@tdCommissionAmount				
				,@tdLocalCurrencyCode				
				,@tdFxCurrencyCode					
				 									
				,@apiStatus							
				,@payResponseCode					
				,@payResponseMsg					
				,@recordStatus						
				,@tranPayProcess					
				,GETDATE()						
				,@user							
				,@paidDate							
				,@paidBy							
				,@rContactNo						
				,@nativeCountry						
				,@pBranch							
				,@rIdType							
				,@rIdNumber							
				,@rIdPlaceOfIssue					
				,@rValidDate						
				,@rDob								
				,@rAddress							
				,@rCity								
				,@rOccupation						
				,@relationType						
				,@relativeName						
				,@remarks							
				
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
			
	END	
	
	IF @flag='readyToPay'				
	BEGIN
		--alter table ezPayHistory add topupMobileNo varchar(20)
		--alter table ezPayHistory add customerId bigint,membershipId varchar(50)
		UPDATE ezPayHistory SET			
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = ISNULL(@pBranch,pBranch)
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = @rValidDate
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,nativeCountry	 = @nativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks	 	 = @remarks 
			,rBank			 = @rbankName
			,rBankBranch	 = @rbankBranch
			,rAccountNo		 = @rAccountNo
			,rChequeNo		 = @rcheque
			,topupMobileNo	 = @topupMobileNo
			,customerId		 = @customerId
			,membershipId	 = @membershipId
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose		
			,rIssueDate		 = @rIssuedDate
		WHERE id = @rowId
		EXEC [proc_errorHandler] 0, 'Ready to pay has been recorded successfully.', @rowId
		RETURN		
	END	
	
	IF @flag = 'payError'
	BEGIN
		UPDATE ezPayHistory SET 
			 recordStatus = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg = @payResponseMsg 		
		WHERE id = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END
	
	IF @flag IN('pay','restore')
	BEGIN
		IF NOT EXISTS(
			SELECT 'x' FROM ezPayHistory WITH(NOLOCK)
			WHERE recordStatus IN('READYTOPAY','PAYERROR','PAID')
			AND id=@rowId
		)
		
		BEGIN
			declare @ms varchar(100)='Transaction Not Found! '+Convert(varchar(10),@rowId)
			EXEC proc_errorHandler 1,@ms,@rowId
		END	
		
		
		DECLARE 
		 @pAgent					VARCHAR(100)= NULL					
		,@agentType					VARCHAR(100)= NULL			
		,@pState					VARCHAR(100)= NULL	
		,@pDistrict					VARCHAR(100)= NULL	
		,@pLocation					VARCHAR(100)= NULL
		,@sAgentMapCode				INT = '28100000'
		,@sBranchMapCode			INT = '28100100'	
		
		,@sBranch					VARCHAR(100)= NULL
		,@sAgent					VARCHAR(100)= NULL
		,@sBranchName				VARCHAR(100)= NULL
		,@pSuperAgent				VARCHAR(100)= NULL
		,@pAgentName				VARCHAR(100)= NULL
		,@pSuperAgentName			VARCHAR(100)= NULL
		,@sSuperAgent				VARCHAR(100)= NULL
		,@sAgentName				VARCHAR(100)= NULL
		
		,@sSuperAgentName			VARCHAR(100)= NULL
		,@payoutMethod				VARCHAR(100)= NULL
		,@pSuperAgentComm			VARCHAR(100)= NULL		
		,@pSuperAgentCommCurrency	VARCHAR(100)= NULL
		,@pAgentComm				VARCHAR(100)= NULL
		,@pAgentCommCurrency		VARCHAR(100)= NULL		
		,@tranId					BIGINT		= NULL		
		,@MapCodeIntBranch			VARCHAR(100)= NULL	
		,@tranIdTemp				BIGINT			

		SELECT 
		   @TransactionNumber			=ez.TypeOfTransaction		   
		  ,@SecurityNumber				=ez.SecurityNumber    
		  ,@scCustomerName				=ez.scCustomerName
		  ,@scCustomerAddress			=ez.scCustomerAddress
		  ,@scCustID					=ez.scCustID
		  ,@scCustIDType				=ez.scCustIDType
		  ,@scCustTelephoneNumber		=ez.scCustTelephoneNumber
		  ,@scCustCountry				=ez.scCustCountry
		  ,@scCustNationality			=ez.scCustNationality
	     
		  ,@tbName						=ez.tbName      
		  ,@tbAddress					=ez.tbAddress
		  ,@tbPurpose					=ez.tbPurpose      
		  ,@tbIdNumber					=tbIdNumber
		  ,@tbTelephoneNumber			=ez.tbTelephoneNumber  
		  ,@pCountry					=ez.tbBenCountry
		  ,@tbNationality				=ez.tbNationality	                    
		  ,@cAmt						= floor(ez.tdFxAmount)
		  ,@pAmt						= floor(ez.tdFxAmount)
		  ,@tAmt						= floor(ez.tdFxAmount)
	      ,@tdFxAmount      	      	= floor(ez.tdFxAmount)          
		  ,@tdTotalLocalAmount			= floor(ez.tdFxAmount)                             
		  ,@tdFxCurrencyCode			=ez.tdFxCurrencyCode 
		  ,@apiStatus					=ez.apiStatus
		  ,@recordStatus				=ez.recordStatus
		  ,@nativeCountry				=ez.nativeCountry
		  ,@pBranch						=isnull(@pBranch,ez.pBranch)
		  ,@rIdType						=ez.rIdType
		  ,@rIdNumber					=ez.rIdNumber
		  ,@rIdPlaceOfIssue				=ez.rIdPlaceOfIssue
		  ,@rValidDate					=ez.rValidDate
		  ,@rDob						=ez.rDob    
		  ,@rOccupation					=ez.rOccupation
		  ,@relationType				=ez.relationType
		  ,@relativeName				=ez.relativeName
		  ,@remarks						=ez.remarks	  
		  ,@rbankName					= rBank
		  ,@rbankBranch					= rBankBranch
		  ,@rcheque						= rAccountNo
		  ,@rAccountNo					= rChequeNo  
		  ,@topupMobileNo				= topupMobileNo
		  ,@customerId					= customerId
		  ,@membershipId				= membershipId
		  ,@rContactNo					= rContactNo
		  ,@purpose						= purposeOfRemit
		  ,@relationship				= relWithSender
		  ,@rIssuedDate					= rIssueDate
      FROM ezPayHistory ez WITH(NOLOCK)
     WHERE id=@rowId
     
     
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
		
	-- ## check for control number if exist in remittran
	IF EXISTS(SELECT 'x' from remitTran WITH(NOLOCK) WHERE controlNo=@SecurityNumber)
	BEGIN
		DECLARE 			
			 @status	VARCHAR(50)
			,@msg		VARCHAR(100)
			
		SELECT 
			 @agentName =sAgentName
			,@status=payStatus			
		 FROM remitTran WITH(NOLOCK) 
		 WHERE controlNo=@SecurityNumber
		 
		 SET @msg='This transaction belong to '+@agentName+'and is in status:'+@status
		 EXEC proc_errorHandler 1,@msg,NULL
		 RETURN
	END
		
		
	-- ## Set Paying agent detail
	SELECT 
		 @pAgent			= parentId
		,@pBranchName		=agentName
		,@agentType			=agentType
		,@pCountry			=agentCountry
		,@pState			=agentState
		,@pDistrict			=agentDistrict
		,@pLocation			=agentLocation
		,@MapCodeIntBranch	=mapCodeInt
    FROM agentMaster WITH(NOLOCK) WHERE agentId=@pBranch
    IF @agentType = 2903
	BEGIN
		SET @pAgent = @pBranch
	END
    
    
    
    -- ## Find sending agent detail
    SELECT 
		 @sBranch		=agentId
		,@sAgent		=parentId
		,@sBranchName	=agentName
		,@agentType		=agentType 
	FROM agentMaster WITH(NOLOCK) 
	WHERE mapCodeInt = @sBranchMapCode AND ISNULL(isDeleted, 'N') = 'N'
	
	
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
	END
	
	SELECT 
		 @sSuperAgent	=parentId
		,@sAgentName	=agentName
	FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent
	
	SELECT @sSuperAgentName=agentName
	FROM agentMaster WITH(NOLOCK) WHERE agentId=@sSuperAgent
	
	-- ## Find Payout agent Detail
	SELECT 
		 @pSuperAgent	=parentId
		,@pAgentName	=agentName		
	FROM agentMaster WITH(NOLOCK)WHERE agentId=@pAgent
	
	SELECT @pSuperAgentName=agentName 
	FROM agentMaster WITH(NOLOCK)WHERE agentId=@pSuperAgent
	
	
	-- ## Find Commisssion
	DECLARE 
		 @sCountryId		INT
		,@deliveryMethodId	INT
		,@pCommCheck		MONEY

		select @sCountry =agentCountry,@sCountryId=agentCountryId
		from agentMaster where agentCode='4726'
			
		SET @payoutMethod='Cash Payment'
		
		DECLARE @pCountryId INT=NULL
		
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK)WHERE countryName = @pCountry 
		
		SELECT @deliveryMethodId=serviceTypeId
		FROM serviceTypeMaster WITH(NOLOCK)
		WHERE typeTitle=@payoutMethod AND ISNULL(isDeleted,'N')='N'
		
		SELECT 
			 @pSuperAgentComm			=0
			,@pSuperAgentCommCurrency	='NPR'
			
		SELECT 
			 @pAgentComm		=ISNULL(amount,0)
			,@pCommCheck		=amount
			,@pAgentCommCurrency=commissionCurrency			
		FROM dbo.FNAGetPayComm(@sBranch,@sCountryId,NULL,@pSuperAgent,151,
			@pLocation,@pBranch,'NPR',@deliveryMethodId,NULL,@tdFxAmount,NULL,NULL,NULL)---tdFxAmount is destination amount		

		IF @pCommCheck IS NULL
		BEGIN
			EXEC proc_errorHandler 1,'Payout Commission not defined.',NULL
			RETURN
		END	

	-------Compliance Check Begin----------

		-- Thirdparty txn doesn't have tranid. Hence, temp tranid is created for compliance checking process. Later on this will replace by actual tranId.
		SELECT @tranIdTemp = ABS(CAST(CRYPT_GEN_RANDOM(8) AS BIGINT)) 

		IF NOT EXISTS(SELECT 'X' FROM remitTranCompliancePay WITH(NOLOCK) WHERE tranId = @tranIdTemp AND approvedDate IS NOT NULL)
		BEGIN

		DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @totalRows INT, @count INT, @compFinalRes VARCHAR(20), @result VARCHAR(MAX),@complianceAction CHAR(1),
		@compApproveRemark	VARCHAR(200)

		DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
		
		INSERT @csMasterRec(masterId)
		SELECT masterId FROM dbo.FNAGetComplianceRuleMaster_Pay(@pBranch, @pCountryId, NULL, @pBranch, NULL, NULL, @customerId)
		SELECT @totalRows = COUNT(*) FROM @csMasterRec
		
		DECLARE @denyTxn CHAR(1) = 'N'
		IF EXISTS(SELECT 'X' FROM @csMasterRec)
		BEGIN
			DELETE FROM remitTranCompliancePayTemp WHERE tranId = @tranIdTemp
			SET @count = 1
			WHILE(@count <= @totalRows)
			BEGIN
				SELECT @csMasterId = masterId FROM @csMasterRec WHERE rowId = @count
				
				EXEC proc_complianceRuleDetail_Pay 
				 @user				= @user
				,@tranId			= @tranIdTemp
				,@tAmt				= @pAmt
				,@customerId		= @customerId			
				,@receiverId		= @rIdNumber 
				,@receiverMemId		= @membershipId			
				,@receiverName		= @tbName 
				,@receiverMobile	= @rContactNo
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
				IF EXISTS(SELECT 'X' FROM remitTranCompliancePayTemp WITH(NOLOCK) WHERE tranId = @tranIdTemp)
				BEGIN
					INSERT INTO remitTranCompliancePay(tranId, csDetailTranId, matchTranId)
					SELECT @tranIdTemp, csDetailTranId, matchTranId FROM remitTranCompliancePayTemp WITH(NOLOCK) WHERE tranId = @tranIdTemp
					
					
					--INSERT tranPayCompliance(tranId,provider,controlNo,pBranch,receiverName,rMemId,dob,
					--rIdType,rIdNumber,rPlaceOfIssue,rContactNo,rRelationType,rRelativeName,relWithSender,purposeOfRemit,createdBy,createdDate)					
					--SELECT @tranIdTemp, '4726' , @SecurityNumber,@pBranch,@tbName,@membershipId,@rDob,
					--@rIdType,@rIdNumber,@rIdPlaceOfIssue,@rContactNo,@relationType,@relativeName,@relationship,@purpose,@user,GETDATE()
					
					DELETE FROM dbo.remitTranCompliancePayTemp WHERE tranId = @tranIdTemp			
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
						WHERE tranId = @tranIdTemp

						--UPDATE tranPayCompliance SET
						--	 approvedRemarks	= 'Marked for Compliance'
						--	,approvedBy			= 'system'
						--	,approvedDate		= GETDATE()
						--WHERE tranId = @tranIdTemp
					END				

			END

		END 

		END		
		
		-------Compliance Check End----------
		BEGIN TRANSACTION					
			INSERT INTO remitTran (	 
					  [controlNo]						
					 ,[senderName]					
					 ,[sCountry]					
					 ,[sSuperAgent]					
					 ,[sSuperAgentName]				
					 ,[paymentMethod]				
					 ,[cAmt]						
					 ,[pAmt]						
					 ,[tAmt]						
					 ,[pAgentComm]					
					 ,[payoutCurr]					
					 ,[pAgent]						
					 ,[pAgentName]					
					 ,[pSuperAgent]					
					 ,[pSuperAgentName]				
					 ,[receiverName]				
					 ,[pCountry]					
					 ,[pBranch]						
					 ,[pBranchName]					
					 ,[pState]						
					 ,[pDistrict]					
					 ,[pLocation]					
					 ,[purposeofRemit]				
					 ,[pMessage]													
					 ,[createdDate]					
					 ,[createdDateLocal]			
					 ,[createdBy]					
					 ,[approvedDate]				
					 ,[approvedDateLocal]			
					 ,[approvedBy]					
					 ,[paidBy]						
					 ,[paidDate]					
					 ,[paidDateLocal]
													
					 --## hardcoded parameters			
					 ,[tranStatus]					
					 ,[payStatus]
					 					
					 ,[collCurr]					
					 ,[controlNo2]					
					 ,[tranType]					
					 ,[sAgent]						
					 ,[sAgentName]					
					 ,[sBranch]						
					 ,[sBranchName]	
					 ,[sCurrCostRate]				
				 )SELECT
					  @SecurityNumber
					 ,@scCustomerName
					 ,@sCountry
					 ,@sSuperAgent
					 ,@sSuperAgentName
					 ,'Cash Payment'--hard core
					 ,@cAmt	--destination amount
					 ,@pAmt
					 ,@tAmt
					 ,@pAgentComm
					 ,@tdFxCurrencyCode--payout currency
					 ,@pAgent
					 ,@pAgentName
					 ,@pSuperAgent
					 ,@pSuperAgentName					 
					 ,@tbName----benefic name 
					 ,@pCountry
					 ,@pBranch
					 ,@pBranchName
					 ,@pState
					 ,@pDistrict
					 ,@pLocation
					 ,@tbPurpose---remit purpose
					 ,@remarks
					 ,GETDATE() 
					 ,dbo.FNAGetDateInNepalTZ()
					 ,'SWIFT:API'
					 ,GETDATE()	 
					 ,dbo.FNAGetDateInNepalTZ()
					 ,'SWIFT:API'
					 ,@user
					 ,GETDATE()
					 ,dbo.FNAGetDateInNepalTZ()
					 
					 ,'Paid'
					 ,'Paid'
					 ,@tdFxCurrencyCode--destination currency
					 ,@SecurityNoEnc--controlNo2
					 ,'I'
					 ,@sAgent
					 ,@sAgentName
					 ,@sBranch
					 ,@sBranchName	
					 ,'1'				
			SET @tranId=SCOPE_IDENTITY();	
			INSERT INTO tranSenders(
				 tranId
				,firstName
				,country
				,nativeCountry
				,[address]
				,idType
				,idNumber
				,homePhone
								)
			SELECT
				 @tranId
				,@scCustomerName
				,@scCustCountry
				,@scCustNationality
				,@scCustomerAddress				
				,@scCustIDType
				,@scCustID				
				,@scCustTelephoneNumber

			INSERT INTO tranReceivers (
					 tranId
					,firstName
					,country
					,nativeCountry
					,city
					,[address]
					,homePhone
					,idType
					,idNumber
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
					,workPhone
					,customerId
					,membershipId
					,mobile
					,relWithSender
					,purposeOfRemit
					,issuedDate2
					,validDate2

				)SELECT
				 @tranId		
				,@tbName
				,@pCountry
				,@tbNationality
				,@tbAddress
				,@tbAddress	
				,@tbTelephoneNumber
				,@rIdType	
				,@rIdNumber
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
				,@topupMobileNo	
				,@customerId
				,@membershipId
				,@rContactNo
				,@relationship
				,@purpose
				,@rIssuedDate
				,@rValidDate
			
			UPDATE remitTranCompliancePay SET
					tranId	= @tranId							
			WHERE tranId = @tranIdTemp

			UPDATE tranPayCompliance SET
			tranId	= @tranId
			WHERE tranId = @tranIdTemp

			IF @membershipId IS NOT NULL
			BEGIN
				UPDATE dbo.customerMaster SET 
					paidTxn = ISNULL(paidTxn,0)+1,
					firstTxnDate = ISNULL(firstTxnDate,GETDATE()) 
				WHERE membershipId = @membershipId 
			END		
													
			UPDATE ezPayHistory SET 
				 recordStatus		= 'PAID'
				,tranPayProcess		= CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode	= @payResponseCode
				,payResponseMsg		= @payResponseMsg
				,paidDate			= GETDATE()
				,paidBy				= @user				
			WHERE id = @rowId
			EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @SecurityNumber	
			
			SET @controlNo = dbo.fnadecryptstring(@SecurityNumber)
			/*Topup Information Send SMS*/
			IF @membershipId IS NOT NULL
			BEGIN
				EXEC proc_topupQueue 
					 @flag			= 'a'
					,@user			= @user
					,@tranId		= @tranId
					,@tranType		= 'I'
			END
			-- ## Limit Update	
			EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @pAmt ,@settlingAgent = @pBranch
		IF @@TRANCOUNT>0
		COMMIT TRANSACTION
		SET @msg=
				CASE 
					WHEN @flag='restore' THEN 'Transaction has been restored successfully' ELSE 'Transaction paid Successfully'
					END
		EXEC proc_errorHandler 0,@msg, @controlNo
		RETURN
			
	END	
	IF @flag ='byPass'
    BEGIN
		SELECT @rowId = id FROM ezPayHistory WITH(NOLOCK) WHERE SecurityNumber = DBO.FNAEncryptString(@SecurityNumber) AND recordStatus='PAID'
		
		SELECT CASE WHEN (@rowId IS NOT NULL OR @rowId > 0)THEN '0' ELSE '1' END errorCode
		, CASE WHEN (@rowId IS NOT NULL OR @rowId > 0)THEN 'Success' ELSE 'Transaction not found' END msg
		, @rowId id, @pAmt extra
    END																	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
	SELECT ERROR_LINE()
END CATCH													
 


GO
