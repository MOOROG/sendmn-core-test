USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cePayHistory]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_cePayHistory] (
	 @flag					VARCHAR(50)
	,@user					VARCHAR(50)
	,@rowId					BIGINT		  	= NULL	
	,@agentId				VARCHAR(20)	  	= NULL
	,@agentRequestId		VARCHAR(100)  	= NULL
	,@beneAddress			VARCHAR(200)  	= NULL
	,@beneBankAccountNumber	VARCHAR(100)  	= NULL
	,@beneBankBranchCode	VARCHAR(100)  	= NULL
	,@beneBankBranchName	VARCHAR(100)  	= NULL
	,@beneBankCode			VARCHAR(200)  	= NULL
	,@beneBankName			VARCHAR(200)  	= NULL
	,@beneIdNo				VARCHAR(50)	  	= NULL
	,@beneName				VARCHAR(100)  	= NULL
	,@benePhone				VARCHAR(50)	  	= NULL
	,@custAddress			VARCHAR(200)  	= NULL
	,@custIdDate			VARCHAR(20)	  	= NULL
	,@custIdNo				VARCHAR(20)	  	= NULL
	,@custIdType			VARCHAR(20)	  	= NULL
	,@custName				VARCHAR(100)  	= NULL
	,@custNationality		VARCHAR(100)  	= NULL
	,@custPhone				VARCHAR(100)  	= NULL
	,@description			VARCHAR(300)  	= NULL
	,@destinationAmount		MONEY		  	= NULL
	,@destinationCurrency	VARCHAR(20)	  	= NULL
	,@gitNo					VARCHAR(20)	  	= NULL
	,@paymentMode			VARCHAR(20)	  	= NULL
	,@purpose				VARCHAR(50)	  	= NULL
	,@responseCode			VARCHAR(100)  	= NULL
	,@settlementCurrency	VARCHAR(20)		= NULL	
	,@apiStatus				VARCHAR(100)	= NULL
	,@payResponseCode		VARCHAR(20)		= NULL
	,@payResponseMsg		VARCHAR(100)	= NULL
	,@recordStatus			VARCHAR(50)		= NULL
	,@tranPayProcess		VARCHAR(20)		= NULL
	,@createdDate			DATETIME		= NULL
	,@createdBy				VARCHAR(30)		= NULL
	,@paidDate				DATETIME		= NULL
	,@paidBy				VARCHAR(30)		= NULL
	,@pBranch				INT				= NULL
	,@pBranchName			VARCHAR(50)		= NULL
	,@pAgent				INT				= NULL
	,@pAgentName			VARCHAR(100)	= NULL
	,@rIdType				VARCHAR(30)		= NULL
	,@rIdNumber				VARCHAR(30)		= NULL
	,@rIdPlaceOfIssue		VARCHAR(50)		= NULL
	,@rValidDate			DATETIME		= NULL
	,@rDob					DATETIME		= NULL
	,@rAddress				VARCHAR(100)	= NULL
	,@rOccupation			VARCHAR(100)	= NULL
	,@rContactNo			VARCHAR(50)		= NULL
	,@rCity					VARCHAR(100)	= NULL
	,@rNativeCountry		VARCHAR(100)	= NULL
	,@relationType			VARCHAR(50)		= NULL
	,@relativeName			VARCHAR(100)	= NULL
	,@remarks				VARCHAR(500)	= NULL
	,@approveBy				VARCHAR(30)		= NULL
	,@approvePwd			VARCHAR(100)	= NULL

	,@sortBy				VARCHAR(50)	  	= NULL
	,@sortOrder				VARCHAR(5)	  	= NULL
	,@pageSize				INT			  	= NULL
	,@pageNumber			INT			  	= NULL	
	,@agentNamee			VARCHAR(50)		= NULL
	,@provider				VARCHAR(50)		= NULL
	,@customerId			VARCHAR(50)		= NULL
	,@membershipId			VARCHAR(50)		= NULL
)
AS
SET XACT_ABORT ON


BEGIN TRY
	DECLARE
		 @gitNoEnc	VARCHAR(50) = dbo.FNAencryptString(@gitNo)



	IF @flag = 's'
	BEGIN	
		DECLARE @table				VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
		SET @table = '
			(
				SELECT
					rowId=rowId
					,''Cash Express'' AS provider
					,am.agentName
					,dbo.FNADecryptString(gitNo) AS xpin
					,customer				= ISNULL(ce.custName, '''')
					,beneficiary			= ISNULL(ce.beneName, '''')
					,customerAddress		= ISNULL(ce.custAddress, '''')
					,beneficiaryAddress		= ISNULL(ce.beneAddress, '''')
					,payoutAmount			= ce.destinationAmount
					,payoutDate				=ce.paidDate
				FROM cePayHistory  ce WITH(NOLOCK)
				LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = ce.pBranch
				WHERE recordStatus NOT IN(''DRAFT'', ''EXPIRED'')			
			'
			IF @gitNo IS NOT NULL
			BEGIN
				SET @table = @table + ' AND gitNo = ''' + @gitNoEnc + ''''			
			END
			ELSE
			BEGIN
				SET @table = @table + ' AND tranPayProcess IS NULL'
			END
			
			IF @agentNamee IS NOT NULL
				SET @table = @table + ' AND am.agentName LIKE ''' + @agentNamee + '%'''
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

	IF @flag = 'a'
	BEGIN
		SELECT TOP 1
			 rowId
			,[controlNo]	= dbo.FNADecryptString(ce.gitNo)
			,[sCountry]		= ce.custNationality
			,[sName]		= ce.custName
			,[sAddress]		= ISNULL(ce.custAddress,'')
			,sCity			=null
			,sMobile		=isnull(ce.custPhone,'')
			,sAgentName		='Cash Express'
			,sAgent			=4670
			,[sIdType]		= ce.custIdType
			,[sIdNumber]	= ce.custIdNo
			,[rCountry]		= 'Nepal'--ce.Destination_Country
			,[rName]		= ce.beneName
			,[rAddress]		= ce.beneAddress
			,[rCity]		= ''--ce.rCity
			,[rPhone]		= ISNULL(ce.benePhone,'')
			,[rIdType]		= ce.rIdType
			,[rIdNumber]	= ce.rIdNumber
			,[pAmt]			= ce.destinationAmount
			,[pCurr]		= ce.destinationCurrency
			,[pBranch]		= am.agentName
			,branchId		= ce.pBranch 
			,[pUser]		= ce.createdBy
			,transactionMode= case paymentMode 
									when 1 then 'Cash Payment' ELSE 'Bank Deposit' END
			,PlaceOfIssue	= rIdPlaceOfIssue
		    ,rRelativeName	= relativeName
		    ,RelationType	= relationType
		    ,rContactNo		= rContactNo
		FROM cePayHistory ce WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON ce.pBranch = am.agentId
		WHERE recordStatus <> ('DRAFT') AND rowId = @rowId
		ORDER BY rowId DESC
		RETURN
	END

	IF @flag = 'i'
	BEGIN	
		IF EXISTS (
			SELECT 
				'x' 
			FROM cePayHistory 
			WHERE gitNo = @gitNoEnc
		)
		
		BEGIN
			UPDATE cePayHistory SET 
				recordStatus = 'EXPIRED'
			WHERE gitNo = @gitNoEnc AND recordStatus <> 'READYTOPAY'
		END

		INSERT INTO cePayHistory (
			 agentId
			,agentRequestId		
			,beneAddress		
			,beneBankAccountNumber
			,beneBankBranchCode	
			,beneBankBranchName	
			,beneBankCode		
			,beneBankName		
			,beneIdNo
			,beneName
			,benePhone
			,custAddress		
			,custIdDate
			,custIdNo
			,custIdType
			,custName
			,custNationality	
			,custPhone
			,[description]
			,destinationAmount	
			,destinationCurrency
			,gitNo	
			,paymentMode		
			,purpose
			,responseCode		
			,settlementCurrency	
			,apiStatus
			,recordStatus		
			,createdDate		
			,createdBy
			,pBranch
		)
		SELECT
			@agentId
			,@agentRequestId		
			,@beneAddress		
			,@beneBankAccountNumber
			,@beneBankBranchCode	
			,@beneBankBranchName	
			,@beneBankCode		
			,@beneBankName		
			,@beneIdNo
			,@beneName
			,@benePhone
			,@custAddress		
			,@custIdDate
			,@custIdNo
			,@custIdType
			,@custName
			,@custNationality	
			,@custPhone
			,@description		
			,@destinationAmount
			,@destinationCurrency
			,@gitNoEnc	
			,@paymentMode		
			,@purpose
			,@responseCode		
			,@settlementCurrency	
			,@apiStatus
			,'DRAFT'
			,GETDATE()		
			,@user				
			,@pBranch
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
	END
	
	IF @flag = 'readyToPay'
	BEGIN
		UPDATE cePayHistory SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = @pBranch 
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
			,remarks	 	 = @remarks 
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Ready to pay has been recorded successfully.','Nepal'
		RETURN
	END	

	IF @flag = 'payError'
	BEGIN
		UPDATE cePayHistory SET 
			 recordStatus = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg = @payResponseMsg 		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END
	
	IF @flag IN ('pay', 'restore')
	BEGIN
		IF NOT EXISTS(
			SELECT 'x' FROM cePayHistory WITH(NOLOCK) 
			WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') 
				AND rowid = @rowid
		)
		
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
			RETURN
		END
		
		DECLARE
			 @tranId					BIGINT 
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
			,@sAgentMapCode				INT = 33300350
	 		,@sBranchMapCode			INT = 33422529
	 		,@sCountry					VARCHAR(100)


			,@bankName					VARCHAR(100) = NULL
			,@pBankBranch				VARCHAR(100) = NULL
			,@sAgentSettRate			VARCHAR(100) = NULL

			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			,@cAmt						MONEY
			,@customerRate				MONEY
			,@payoutCurr				VARCHAR(50)
			,@collCurr					VARCHAR(50)	
			,@companyId					INT = 16
			,@ControlNoModified			VARCHAR(50)	
			,@controlNo					VARCHAR(50)	
	
		SELECT 
			 @gitNo					= ce.gitNo
			,@beneName				= ce.beneName
			,@benePhone				= ce.rContactNo
			,@beneAddress			= ce.rAddress
			,@beneIdNo				= ce.rIdNumber
			,@custName				= ce.custName
			,@custAddress			= ce.custAddress
			,@custNationality		= ce.custNationality
			,@custPhone				= ce.custPhone
			,@custIdType			= ce.custIdType
			,@custIdNo				= ce.custIdNo
			,@custIdDate			= ce.custIdDate
			,@destinationAmount		= ce.destinationAmount
			,@destinationCurrency   = ce.destinationCurrency
			,@purpose				= ce.purpose
			,@paymentMode			= ce.paymentMode
			,@settlementCurrency	= ce.settlementCurrency
			,@description			= ce.description
						
			,@rNativeCountry		= ce.nativeCountry
			,@rIdType				= ce.rIdType
			,@rValidDate			= ce.rValidDate
			,@rDob					= ce.rDob
			,@rOccupation			= ce.rOccupation
			,@remarks				= ce.remarks
			,@apiStatus				= ce.apiStatus
			,@recordStatus			= ce.recordStatus
			,@rIdType				= ce.rIdType
			,@rIdNumber				= ce.rIdNumber
			,@rValidDate			= ce.rValidDate
			,@rDob					= ce.rDob
			,@rOccupation			= ce.rOccupation
			,@rNativeCountry		= ce.nativeCountry
			,@pBranch				= isnull(@pBranch,ce.pBranch)
			,@rIdPlaceOfIssue		= ce.rIdPlaceOfIssue
			,@relationType			= ce.relationType
			,@relativeName			= ce.relativeName			
		FROM cePayHistory ce WITH(NOLOCK)
		WHERE rowId = @rowId		
		
		SET @ControlNoModified = dbo.FNAEncryptstring(dbo.FNADecryptstring(@gitNo)+'A')
		SELECT 
			 @pAgent = parentId, 
			 @pBranchName = agentName, 
			 @agentType = agentType,
			 @pCountry = agentCountry,
			 @pState = agentState,
			 @pDistrict = agentDistrict,
			 @pLocation = agentLocation
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch	

		--## Check if controlno exist in remittran. 		
		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified)
		BEGIN
			DECLARE @agentName VARCHAR(100),@status VARCHAR(100),@msg VARCHAR(100)
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
			@pLocation = agentLocation
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
		
		IF @agentType = 2903
			SET @pAgent = @pBranch
					
		--##1. Find Sending Agent Details
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
				@sAgentName = agentName,
				@sCountry = agentCountry
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent

		SELECT @sSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent

--##2. Find Payout Agent Details
		SELECT  @pSuperAgent = parentId, 
				@pAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent

--##3. Find Commission 
		DECLARE @sCountryId INT, @deliveryMethodId INT, @pCommCheck MONEY
		SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry
		
		SET @payoutMethod = 'Cash Payment'
		DECLARE @pCountryId INT = NULL
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'
				
		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'
		SELECT  @pAgentComm = ISNULL(amount, 0), 
				@pCommCheck = amount, 
				@pAgentCommCurrency = commissionCurrency, 
				@pCommCheck = amount 
		FROM dbo.FNAGetPayComm(@sBranch, @sCountryId, NULL, @pSuperAgent, 151, 
		@pLocation, @pBranch, 'NPR', @deliveryMethodId, NULL, @destinationAmount, NULL, NULL, NULL)

		IF @pCommCheck IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Payout Commission not defined', NULL
				RETURN
			END		
			
		BEGIN TRANSACTION
		BEGIN
		
		--## Inserting Data in remittran table 				
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
					 ,[pBankBranch]					
					 ,[sAgentSettRate]				
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
				 )
		SELECT 
					 @ControlNoModified
					,@custName
					,@sCountry
					,@sSuperAgent
					,@sSuperAgentName
					,'Cash Payment'
					,@destinationAmount
					,@destinationAmount
					,@destinationAmount
					,@pAgentComm
					,@destinationCurrency
					,@pAgent
					,@pAgentName
					,@pSuperAgent
					,@pSuperAgentName 
					,@beneName	 
					,@pCountry
					,@pBranch
					,@pBranchName
					,@pState
					,@pDistrict
					,@pLocation
					,@purpose
					,@remarks	
					,@pBankBranch
					,@SagentsettRate
					,GETDATE() 
					,GETDATE()
					,'SWIFT:API'
					,GETDATE()	 
					,GETDATE()
					,'SWIFT:API'
					,@user
					,dbo.FNAGetDateInNepalTZ()
					,dbo.FNAGetDateInNepalTZ()

					--## hardCoded Parameters
					,'Paid'
					,'Paid'
					,@destinationCurrency
					,@gitNo
					,'I'
					,@sAgent
					,@sAgentName
					,@sBranch
					,@sBranchName
										
			SET @tranId = SCOPE_IDENTITY()

			--## Inserting Data in tranSenders table
			INSERT INTO tranSenders	(
					 tranId
					,firstName
					,country
					,[address]
					,idType
					,idNumber
					,validDate
					,homePhone
				)
				SELECT
					 @tranId			
					,@custName
					,@sCountry	
					,@custAddress
					,@custIdType	
					,@custIdNo
					,CONVERT(DATETIME,@custIdDate,103)
					,@custPhone
					
			--## Inserting Data in tranReceivers table
			INSERT INTO tranReceivers (
					 tranId
					,firstName
					,country
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
					)		
				SELECT 
					 @tranId			
					,@beneName
					,@pCountry
					,@beneAddress
					,@beneAddress	
					,@benePhone
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

			--## Updating Data in cePayHistory table by paid status
			UPDATE cePayHistory SET 
				 recordStatus = 'PAID'
				,tranPayProcess = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg = @payResponseMsg
				,paidDate    = GETDATE()
				,paidBy		 = @user				
			WHERE rowId = @rowId

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
	SELECT ERROR_LINE()
END CATCH




GO
