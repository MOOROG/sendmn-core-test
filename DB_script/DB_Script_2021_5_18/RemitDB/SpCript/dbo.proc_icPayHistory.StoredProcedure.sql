USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_icPayHistory]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_icPayHistory] (
	 @flag					VARCHAR(50)
	,@user					VARCHAR(50) 			
	,@rowId					BIGINT			= NULL
	------------ IC Pay parameters -----------
	,@ICTC_Number			VARCHAR(100)	= NULL
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
	---------------------END--------------------------
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
	,@pBranch				INT				= NULL
	,@pBranchName			VARCHAR(100)	= NULL
	,@pAgent				INT				= NULL
	,@pAgentName			VARCHAR(100)	= NULL	
	,@rIdType				VARCHAR(30)		= NULL
	,@rIdNumber				VARCHAR(30)		= NULL
	,@rIdPlaceOfIssue		VARCHAR(50)		= NULL
	,@rIssuedDate			DATETIME		= NULL
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
	
	,@sCountry				VARCHAR(100)    = NULL
	
	,@agentName				VARCHAR(100)	= NULL
	,@provider				VARCHAR(100)	= NULL
	
	,@sortBy				VARCHAR(50)		= NULL
	,@sortOrder				VARCHAR(5)		= NULL
	,@pageSize				INT				= NULL
	,@pageNumber			INT				= NULL
	,@customerId			INT				= NULL
	,@membershipId			INT				= NULL

	,@rbankName         VARCHAR(50)		= NULL
	,@rbankBranch		VARCHAR(100)	= NULL
	,@rcheque			VARCHAR(50)		= NULL
	,@rAccountNo		VARCHAR(50)		= NULL
	,@topupMobileNo		varchar(50)		= null
	,@relationship				VARCHAR(100)	= NULL
	,@purpose					VARCHAR(100)	= NULL
)
AS
SET XACT_ABORT ON

BEGIN TRY
	DECLARE		 
		 @sql					VARCHAR(MAX)	
		,@table					VARCHAR(MAX)
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@modType				VARCHAR(6)
		,@oldAgent				INT
		,@ApprovedFunctionId	VARCHAR(8)

		
	IF @flag = 'a'
	BEGIN 
		SELECT TOP 1
			 rowId
			,[controlNo]	= dbo.FNADecryptString(ic.ICTC_Number)
			,[sCountry]		= ic.Originating_Country
			,[sName]		= ic.Remitter_Name
			,[sAddress]		= ISNULL(ic.Remitter_Address,'')
			,[sIdType]		= ic.Remitter_IDType
			,[sIdNumber]	= ic.Remitter_IDDtl
			,[rCountry]		= ic.Destination_Country
			,[rName]		= ic.Beneficiary_Name
			,[rAddress]		= ic.rAddress
			,[rCity]		= ic.rCity
			,[rPhone]		= ISNULL(ic.Beneficiary_TelNo,'')
			,[rIdType]		= ic.rIdType
			,[rIdNumber]	= ic.rIdNumber
			,[pAmt]			= ic.Paying_Amount
			,[pCurr]		= ic.Paying_Currency
			,[pBranch]		= am.agentName
			,[pUser]		= ic.createdBy
		FROM icPayHistory ic WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON ic.pBranch = am.agentId
		WHERE recordStatus <> ('DRAFT') AND ICTC_Number = dbo.FNAEncryptString(@ICTC_Number)
		ORDER BY rowId DESC
		RETURN
	END 
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (SELECT 'x' FROM icPayHistory WITH(NOLOCK) WHERE ICTC_Number = dbo.FNAEncryptString(@ICTC_Number))
		BEGIN
			UPDATE icPayHistory SET 
				recordStatus = 'EXPIRED'
			WHERE ICTC_Number = dbo.FNAEncryptString(@ICTC_Number) AND recordStatus <> 'READYTOPAY'
		END
		IF @pBranch IS NULL
			SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
		IF @pBranch = '1001'
		BEGIN
			EXEC [proc_errorHandler] 1, 'Payout branch is missing.', @rowId
			RETURN;
		END	
		INSERT INTO icPayHistory (
			 ICTC_Number
			,Agent_OrderNumber
			,Remitter_Name
			,Remitter_Address
			,Remitter_IDType
			,Remitter_IDDtl
			,Originating_Country
			,Delivery_Mode
			,Paying_Amount
			,PayingAgent_CommShare
			,Paying_Currency
			,Paying_Agent
			,Paying_AgentName
			,Beneficiary_Name
			,Beneficiary_Address
			,Beneficiary_City
			,Destination_Country
			,Beneficiary_TelNo
			,Beneficiary_MobileNo
			,Expected_BenefID
			,Bank_Address
			,Bank_Account_Number
			,Bank_Name
			,Purpose_Remit
			,Message_PayeeBranch
			,Bank_BranchCode
			,Settlement_Rate
			,PrinSettlement_Amount
			,Transaction_SentDate
			,apiStatus
			,recordStatus
			,pBranch
			,createdDate
			,createdBy )
		SELECT
			 dbo.FNAencryptString(@ICTC_Number)
			,@Agent_OrderNumber
			,@Remitter_Name
			,@Remitter_Address
			,CASE 
				WHEN @Remitter_IDType = '11' THEN 'Passport'
				WHEN @Remitter_IDType IN('6', '06') THEN 'Driving License'
				WHEN @Remitter_IDType IN('9','09') THEN 'Labour Card'
				WHEN @Remitter_IDType = '15' THEN 'State Id'
				WHEN @Remitter_IDType = '18' THEN 'Alien Registration'
				WHEN @Remitter_IDType = '99' THEN 'Other'
				ELSE @Remitter_IDType
			 END  	--@Remitter_IDType
			,@Remitter_IDDtl
			,@Originating_Country
			,@Delivery_Mode
			,@Paying_Amount
			,@PayingAgent_CommShare
			,@Paying_Currency
			,@Paying_Agent
			,@Paying_AgentName
			,@Beneficiary_Name
			,@Beneficiary_Address
			,@Beneficiary_City
			,@Destination_Country
			,@Beneficiary_TelNo
			,@Beneficiary_MobileNo
			,@Expected_BenefID
			,@Bank_Address
			,@Bank_Account_Number
			,@Bank_Name
			, CASE  
				WHEN @Purpose_Remit IN ('1', '01') THEN 'Family Maintenance'
				WHEN @Purpose_Remit IN ('2', '02')  THEN 'Tourism'
				WHEN @Purpose_Remit IN ('3', '03')  THEN 'Education'
				WHEN @Purpose_Remit IN ('4', '04')  THEN 'Medical'
				ELSE @Purpose_Remit
			 END --@Purpose_Remit
			,@Message_PayeeBranch
			,@Bank_BranchCode
			,@Settlement_Rate
			,@PrinSettlement_Amount
			,@Transaction_SentDate
			,@apiStatus
			,'DRAFT'
			,@pBranch
			,GETDATE()
			,@user	
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
	END
	
	IF @flag = 'readyToPay'
	BEGIN
		--IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE pwd = DBO.FNAEncryptString(@approvePwd) AND userName = @user)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'TXN password is invalid !', @user
		--	RETURN
		--END 
		--alter table icPayHistory add topupMobileNo varchar(20)
		--alter table icPayHistory add customerId bigint,membershipId varchar(50)
		UPDATE icPayHistory SET 
			 recordStatus 	= 'READYTOPAY'
			,pBranch 	  	= ISNULL(@pBranch ,pBranch)
			,rIdType 	  	= @rIdType 
			,rIdNumber 	  	= @rIdNumber
			,rIdPlaceOfIssue = @rIdPlaceOfIssue 
			,rValidDate	  	= @rValidDate
			,rDob 		  	= @rDob 
			,rAddress 	  	= @rAddress 
			,rCity 		  	= @rCity 
			,rOccupation  	= @rOccupation 
			,rContactNo   	= @rContactNo 
			,nativeCountry	= @rNativeCountry 
			,remarks 	  	= @remarks 
			,rBank			 = @rbankName
			,rBankBranch	= @rbankBranch
			,rAccountNo		= @rAccountNo
			,rChequeNo		= @rcheque
			,topupMobileNo	= @topupMobileNo
			,customerId		= @customerId
			,membershipId	= @membershipId
			,relWithSender	= @relationship
			,purposeOfRemit = @purpose
			,rIssueDate		 = @rIssuedDate		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Ready to pay has been recorded successfully.', @rowId
		RETURN
	END
	
	IF @flag = 'payError'
	BEGIN
		UPDATE icPayHistory SET 
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
			SELECT 'x' FROM icPayHistory WITH(NOLOCK) 
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
			,@rbankName				=   rBank
			,@rbankBranch			=   rBankBranch
			,@rcheque				=   rAccountNo
			,@rAccountNo			=   rChequeNo
			,@topupMobileNo			=   topupMobileNo
			,@customerId			=   customerId
			,@membershipId			=   membershipId
			,@purpose				=   purposeOfRemit
			,@relationship			=   relWithSender
			,@rIssuedDate			=	rIssueDate 
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
			EXEC proc_errorHandler 1, 'Payout Commission not defined', NULL
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
				,@tAmt				= @Paying_Amount
				,@customerId		= @customerId			
				,@receiverId		= @rIdNumber 
				,@receiverMemId		= @membershipId			
				,@receiverName		= @Beneficiary_Name 
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
					--SELECT @tranIdTemp, '4816' , @ICTC_Number,@pBranch,@Beneficiary_Name,@membershipId,@rDob,
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
					 ,[controlNo2]					
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
					,@Agent_OrderNumber
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
				,bankName
				,branchName
				,chequeNo
				,accountNo
				,workPhone
				,customerId
				,membershipId
				,relWithSender
				,purposeOfRemit
				,issuedDate2
				,validDate2
				)		
			SELECT 
				 @tranId			
				,@Beneficiary_Name
				,@Destination_Country	
				,@Beneficiary_City
				,@Beneficiary_Address
				,@Beneficiary_MobileNo
				,@Beneficiary_TelNo	
				,@rIdType	
				,@rIdNumber
				,@rDob
				,@rOccupation
				,@rValidDate
				,@rbankName
				,@rbankBranch
				,@rcheque
				,@raccountNo
				,@topupMobileNo
				,@customerId
				,@membershipId
				,@relationship
				,@purpose
				,@rIssuedDate
				,@rValidDate

			UPDATE remitTranCompliancePay SET
					tranId	= @tranId
			WHERE tranId = @tranIdTemp

			--UPDATE tranPayCompliance SET
			--tranId	= @tranId
			--WHERE tranId = @tranIdTemp
	

			IF @membershipId IS NOT NULL
			BEGIN
				UPDATE dbo.customerMaster SET 
					paidTxn = ISNULL(paidTxn,0)+1,
					firstTxnDate = ISNULL(firstTxnDate,GETDATE()) 
				WHERE membershipId = @membershipId 
			END		
		-- ## Updating Data in icPayHistory table by paid status
			UPDATE icPayHistory SET 
				 recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg								
			WHERE rowId = @rowId	
			
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
			EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @Paying_Amount ,@settlingAgent = @pBranch
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SET @msg = 
				CASE 
					WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
					ELSE 'Transaction paid successfully'
				END

		EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @ICTC_Number
		
		SET @controlNo = dbo.fnadecryptstring(@ICTC_Number)	
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
