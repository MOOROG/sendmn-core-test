USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_instantCashPay]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC proc_instantCashPay @flag='restore', @user='dipesh', @pBranch='5517', @rowId='33', 
@pBranchName='RAHAT MULTIPURPOSE CO-OPERATIVE SOCIETY LTD - BAGLUNG'
*/
CREATE procEDURE [dbo].[proc_instantCashPay]
	 @flag			VARCHAR(50)
	,@sortBy		VARCHAR(50)		= NULL
	,@sortOrder		VARCHAR(5)		= NULL
	,@pageSize		INT				= NULL
	,@pageNumber	INT				= NULL
	,@user			VARCHAR(50)		= NULL
	,@rowId			INT				= NULL
	,@xpin			VARCHAR(50)		= NULL
	,@agentName		VARCHAR(200)	= NULL
	,@pBranch		INT				= NULL
	,@pBranchName	VARCHAR(200)	= NULL
AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY 
	DECLARE
		 @xpinEnc			VARCHAR(50) 
		,@sql				VARCHAR(MAX)	
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@controlNoEncrypted VARCHAR(50)
		,@tranId			BIGINT

IF @flag = 's'
BEGIN
	--SELECT * FROM [ThirdPaymentRemitTran]
	IF @sortBy IS NULL 
		SET @sortBy = 'provider'
	SET @table = '
		(
			SELECT
				 rowId					= rowId
				,provider				= ''INSTANT CASH''
				,agentName				= am.agentName
				,xpin					= dbo.fnadecryptstring(ic.ictc_number)
				,customer 				= ic.remitter_Name
				,beneficiary			= ic.Beneficiary_Name
				,customerAddress		= ic.remitter_Address
				,beneficiaryAddress		= ic.Beneficiary_Address
				,payoutAmount			= floor(ic.Paying_Amount)
				,payoutDate				= ic.createdDate
			FROM icPayHistory  ic WITH(NOLOCK)
			LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = ic.pBranch
			WHERE 1 = 1	
	
		'
		IF @xpin IS NOT NULL
		BEGIN
			SET @xpinEnc = dbo.fnaencryptstring(@xpin)
			SET @table = @table + ' AND ic.ictc_number = ''' + @xpinEnc + ''''	
			select @pBranch = pBranch,@user = createdBy from icPayHistory with(nolock)
			where ictc_number = @xpinEnc
			if @pBranch is null and @user is not null
			begin
				select @pBranch = agentId  from applicationUsers with(nolock)  
				where userName = @user
				update icPayHistory set pBranch = @pBranch 
				where ictc_number = @xpinEnc 
			end		
		END
			
		IF @agentName IS NOT NULL
			SET @table = @table + ' AND am.agentName LIKE ''' + @agentName + '%'''
		SET @table = @table + ' 
		) x '
			print(@table)
		SET @sql_filter = ''				

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
			 rowId					= rowId
			,[controlNo]			= dbo.fnadecryptstring(ic.ictc_number)
			,[sCountry]				= ic.Originating_Country
			,[sName]				= Remitter_Name
			,[sAddress]				= Remitter_Address
			,[sCity]        		= ''
			,[sIdType]				= Remitter_IDType
			,[sIdNumber]			= Remitter_IDDtl
			,[sMobile]      		= ''
			,[sAgentName]   		= 'Instant Cash'
			,[rCountry]				= 'Nepal'
			,[rName]				= Beneficiary_Name
			,[rAddress]				= Beneficiary_Address
			,[rCity]				= Beneficiary_City
			,[rPhone]				= Beneficiary_TelNo		
			,[rIdType]				= Expected_BenefID
			,[rIdNumber]			= Expected_BenefID
			,[pAmt]					= floor(ic.Paying_Amount)
			,[pCurr]				= 'NPR'
			,[pBranch]				= am.agentName
			,[branchId]     		= am.agentId
			,[pUser]				= ic.createdBy
			,[transactionMode]      = 'Cash Payment'
			,[PlaceOfIssue]			= rIdPlaceOfIssue
			,[rRelativeName]		= relativeName
			,[RelationType]			= relationType
			,[rContactNo]			= rContactNo
		FROM icPayHistory ic WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON ic.pBranch = am.agentId
		WHERE ic.rowid = @rowId ORDER BY rowid DESC
		RETURN
END

IF @flag = 'restore'
BEGIN
	IF NOT EXISTS(
			SELECT 'x' FROM icPayHistory WITH(NOLOCK) 
			WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') 
				AND rowid = @rowid )
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
			RETURN
		END
	DECLARE 
		 @ICTC_Number			VARCHAR(100)	= NULL
		,@Agent_OrderNumber		VARCHAR(100)	= NULL
		,@Remitter_Name			VARCHAR(100)	= NULL
		,@Remitter_Address		VARCHAR(100)	= NULL
		,@Remitter_IDType		VARCHAR(100)	= NULL
		,@Remitter_IDDtl		VARCHAR(100)	= NULL
		,@Originating_Country	VARCHAR(100)	= NULL
		,@Delivery_Mode			VARCHAR(100)	= NULL
		,@Paying_Amount			VARCHAR(100)	= NULL
		,@PayingAgent_CommShare VARCHAR(100)	= NULL
		,@Paying_Currency		VARCHAR(100)	= NULL
		,@Paying_Agent			VARCHAR(100)	= NULL
		,@Paying_AgentName		VARCHAR(100)	= NULL
		,@Beneficiary_Name		VARCHAR(100)	= NULL
		,@Beneficiary_Address	VARCHAR(100)	= NULL
		,@Beneficiary_City		VARCHAR(100)	= NULL
		,@Destination_Country	VARCHAR(100)	= NULL
		,@Beneficiary_TelNo		VARCHAR(100)	= NULL
		,@Beneficiary_MobileNo	VARCHAR(100)	= NULL
		,@Expected_BenefID		VARCHAR(100)	= NULL
		,@Bank_Address			VARCHAR(100)	= NULL
		,@Bank_Account_Number	VARCHAR(100)	= NULL
		,@Bank_Name				VARCHAR(100)	= NULL
		,@Purpose_Remit			VARCHAR(100)	= NULL
		,@Message_PayeeBranch	VARCHAR(100)	= NULL
		,@Bank_BranchCode		VARCHAR(100)	= NULL
		,@Settlement_Rate		VARCHAR(100)	= NULL
		,@PrinSettlement_Amount VARCHAR(100)	= NULL
		,@Transaction_SentDate	VARCHAR(100)	= NULL
		
		,@payConfirmationNo		VARCHAR(100)	= NULL
		,@apiStatus				VARCHAR(100)	= NULL
		,@payResponseCode		VARCHAR(20)		= NULL
		,@payResponseMsg		VARCHAR(100)	= NULL
		,@recordStatus			VARCHAR(50)		= NULL
		,@tranPayProcess		VARCHAR(20)		= NULL
		,@createdDate			DATETIME		= NULL
		,@createdBy				VARCHAR(30)		= NULL
		,@paidDate				DATETIME		= NULL
		,@paidBy				VARCHAR(30)		= NULL	
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
		,@pAgent				INT				= NULL
		,@pAgentName			VARCHAR(100)	= NULL
		,@sCountry				VARCHAR(100)    = NULL	
		,@provider				VARCHAR(100)	= NULL
		,@remarks				VARCHAR(500)	= NULL
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
		,@sAgentMapCode				INT = 33200000  
	 	,@sBranchMapCode			INT = 33200100 
		,@bankName					VARCHAR(100) = NULL
		,@purposeOfRemit			VARCHAR(100) = NULL
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
		,@MapCodeIntAgent			VARCHAR(50) 
		,@MapAgentName				VARCHAR(50) 
		,@companyId					INT = 16
		,@controlNo					VARCHAR(50)
			
		SELECT
			 @ICTC_Number			= 	ic.ICTC_Number			
			,@Agent_OrderNumber		= 	ic.Agent_OrderNumber
			,@Remitter_Name			= 	ic.Remitter_Name
			,@Remitter_Address		= 	ic.Remitter_Address
			,@Remitter_IDType		= 	ic.Remitter_IDType
			,@Remitter_IDDtl		= 	ic.Remitter_IDDtl
			,@Originating_Country   = 	ic.Originating_Country
			,@Delivery_Mode 		= 	ic.Delivery_Mode
			,@Paying_Amount 		= 	ic.Paying_Amount
			,@PayingAgent_CommShare = 	ic.PayingAgent_CommShare
			,@Paying_Currency 		= 	ic.Paying_Currency
			,@Paying_Agent 			= 	ic.Paying_Agent
			,@Paying_AgentName		= 	ic.Paying_AgentName
			,@Beneficiary_Name		= 	ic.Beneficiary_Name
			,@Beneficiary_Address	= 	ic.rAddress
			,@Beneficiary_City		= 	ic.rCity
			,@Destination_Country	= 	ic.Destination_Country
			,@Beneficiary_TelNo		= 	ic.rContactNo
			,@Beneficiary_MobileNo  = 	ic.Beneficiary_MobileNo
			,@Expected_BenefID		= 	ic.Expected_BenefID
			,@Bank_Address			= 	ic.Bank_Address
			,@Bank_Account_Number	= 	ic.Bank_Account_Number
			,@Bank_Name				= 	ic.Bank_Name
			,@Purpose_Remit			= 	ic.Purpose_Remit
			,@Message_PayeeBranch	= 	ic.Message_PayeeBranch
			,@Bank_BranchCode		= 	ic.Bank_BranchCode
			,@Settlement_Rate		= 	ic.Settlement_Rate
			,@PrinSettlement_Amount = 	ic.PrinSettlement_Amount
			,@Transaction_SentDate  = 	ic.Transaction_SentDate
			,@rIdType				=   ic.rIdType
			,@rIdNumber				=   ic.rIdNumber
			,@rValidDate			=   ic.rValidDate
			,@rDob					=	ic.rDob
			,@rOccupation			=   ic.rOccupation
			,@rNativeCountry		=   ic.nativeCountry
			,@pBranch				=	pBranch
			,@pBranchName			=   pb.agentName
		FROM icPayHistory ic WITH(NOLOCK)
		LEFT JOIN agentMaster pb WITH(NOLOCK) ON ic.pBranch = pb.agentId
		WHERE rowId = @rowId
		
		--## Check if controlno exist in remittran. 	
		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @ICTC_Number)
		BEGIN
			DECLARE @status VARCHAR(100),@msg VARCHAR(100)
			SELECT  
				 @agentName = sAgentName
				,@status = payStatus	
			FROM remitTran WITH(NOLOCK) WHERE controlNo = @ICTC_Number
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

		SELECT  @sBranch = bm.agentId, 
				@sAgent = am.agentId, 
				@sBranchName = bm.agentName, 
				@sAgentName = am.agentName
		FROM agentMaster bm WITH(NOLOCK) inner join agentMaster am with(nolock) on bm.parentId = am.agentId
		WHERE bm.agentId = 4817 
		
		SELECT  @sSuperAgent = '4641', 
				@sSuperAgentName = 'INTERNATIONAL AGENTS' 
	
		--## 2. Find Payout Agent Details
		SELECT  @pSuperAgent = parentId
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		SELECT  @pSuperAgentname = agentNAME 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		--## 3. Find Commission 
		DECLARE @sCountryId INT, @deliveryMethodId INT, @pCommCheck MONEY
		SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry
		
		if @sCountryId is null
			select @sCountryId = agentCountryId from agentMaster with(nolock) where agentId = @sBranch

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
		@pLocation, @pBranch, 'NPR', @deliveryMethodId, NULL, @Paying_Amount, NULL, NULL, NULL)

		IF @pCommCheck IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Payout Commission not defined', @pBranch
			RETURN
		END
		
		BEGIN TRANSACTION
		BEGIN	
				
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
					 				
					 ,[tranType]					
					 ,[sAgent]						
					 ,[sAgentName]					
					 ,[sBranch]						
					 ,[sBranchName]	
					 ,sCurrCostRate				
				 )
			
				SELECT
					 @ICTC_Number
					,@Remitter_Name	 
					,@Originating_Country
					,@sSuperAgent
					,@sSuperAgentName
					,'Cash Payment'
					,ROUND(@Paying_Amount,0)
					,ROUND(@Paying_Amount,0)
					,ROUND(@Paying_Amount,0)
					,@pAgentComm
					,'NPR'
					,@pAgent
					,@pAgentName
					,@pSuperAgent
					,@pSuperAgentName 
					,@Beneficiary_Name  

					,@pCountry
					,@pBranch
					,@pBranchName

					,@pState
					,@pDistrict
					,@pLocation

					,@purposeOfRemit
					,@remarks	
					,GETDATE() 
					,GETDATE()
					,'SWIFT:API'
					,GETDATE()	 
					,GETDATE()
					,'SWIFT:API'
					,@user
					,dbo.FNAGetDateInNepalTZ()
					,dbo.FNAGetDateInNepalTZ()

					--## HardCoded Parameters
					,'Paid'
					,'Paid'
					,'NPR'

					,'I'
					,@sAgent
					,@sAgentName
					,@sBranch
					,@sBranchName
					,'1'
					
				SET @tranId = SCOPE_IDENTITY()


			
			-- ## insert to TranSenders
			INSERT INTO tranSenders	(
					 tranId
					,firstName					
					,country
					,[address]
					,homePhone
					)
				SELECT
					 @tranId			
					,@Remitter_Name
					,@Originating_Country	
					,@Remitter_Address	
					,''
			
			-- ## insert to TranReceivers
			INSERT INTO tranReceivers (
				 tranId
				,firstName
				,country
				,city
				,[address]
				,homePhone
				,mobile
				,idType
				,idNumber
				,dob
				,occupation
				,validDate
				)		
			SELECT 
				 @tranId			
				,@Beneficiary_Name
				,left(@Destination_Country,100)
				,left(@Beneficiary_City,150)
				,left(@Beneficiary_Address,500)
				,left(@Beneficiary_TelNo,100)
				,left(@Beneficiary_MobileNo,100)
				,left(@rIdType,50)
				,left(@rIdNumber,50)
				,@rDob
				,@rOccupation
				,@rValidDate

		-- ## Updating Data in icPayHistory table by paid status
			UPDATE icPayHistory SET 
				 recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg								
			WHERE rowId = @rowId	
			
			
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

		SET @msg = 'Transaction has been restored successfully'

		EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @ICTC_Number
		
		SET @controlNo = dbo.fnadecryptstring(@ICTC_Number)	
		EXEC [proc_errorHandler] 0, @msg, @controlNo
		RETURN
END
	
END TRY 
BEGIN CATCH
 IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, NULL
END CATCH







GO
