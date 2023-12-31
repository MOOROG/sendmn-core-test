USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_riaRemitPayHistory]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_riaRemitPayHistory] (
     @flag					VARCHAR(50)
	,@user					VARCHAR(50) 			
	,@rowId					BIGINT			= NULL
	----------------------------------------------------
--> from ria API
	,@transRefID			VARCHAR(100)	= NULL 
	,@orderFound			VARCHAR(100)	= NULL
	,@pIN					VARCHAR(100)	= NULL
	,@orderNo				VARCHAR(100)	= NULL
	,@seqIDRA				VARCHAR(100)	= NULL	
	,@orderDate				DATETIME		= NULL	
	,@custNameFirst			VARCHAR(100)	= NULL
	,@custNameLast1			VARCHAR(100)	= NULL
	,@custNameLast2			VARCHAR(100)	= NULL
	,@custAddress			VARCHAR(100)	= NULL
	,@custCity				VARCHAR(100)	= NULL
	,@custState				VARCHAR(100)	= NULL
	,@custCountry			VARCHAR(100)	= NULL
	,@custZip				VARCHAR(100)	= NULL
	,@custTelNo				VARCHAR(100)	= NULL
	,@beneNameFirst			VARCHAR(100)	= NULL
	,@beneNameLast1			VARCHAR(100)	= NULL
	,@beneNameLast2			VARCHAR(100)	= NULL
	,@beneAddress			VARCHAR(100)	= NULL
	,@beneCity				VARCHAR(100)	= NULL
	,@beneState				VARCHAR(100)	= NULL
	,@beneCountry			VARCHAR(100)	= NULL
	,@beneZip				VARCHAR(100)	= NULL
	,@beneTelNo				VARCHAR(100)	= NULL
	,@beneCurrency			VARCHAR(50)      = NULL
	,@beneAmount			MONEY			= NULL
	,@responseDateTimeUTC	VARCHAR(50)	= NULL	
	----------------------------------------------------
			
	,@payConfirmationNo			VARCHAR(100)	= NULL
	
	,@apiStatus					VARCHAR(100)	= NULL
	,@payResponseCode			VARCHAR(20)		= NULL
	,@payResponseMsg			VARCHAR(100)	= NULL
	,@recordStatus				VARCHAR(50)		= NULL
	,@tranPayProcess			VARCHAR(20)		= NULL
	,@createdDate				DATETIME		= NULL
	,@createdBy					VARCHAR(30)		= NULL
	,@paidDate					DATETIME		= NULL
	,@paidBy					VARCHAR(30)		= NULL
	,@pBranch					INT				= NULL
	,@pBranchName				VARCHAR(100)	= NULL
	,@pAgent					INT				= NULL
	,@pAgentName				VARCHAR(100)	= NULL
	,@rIdType					VARCHAR(30)		= NULL
	,@rIdNumber					VARCHAR(30)		= NULL
	,@rIdPlaceOfIssue			VARCHAR(50)		= NULL
	,@rValidDate				VARCHAR(20)		= NULL
	,@rIssuedDate				DATETIME		= NULL
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
	
)
AS
SET XACT_ABORT ON
BEGIN TRY

	DECLARE	@pinEnc	VARCHAR(100) = dbo.FNAEncryptString(@pIN)	
	
	,@sFullName			VARCHAR(200)
	,@rFullName			VARCHAR(200)
	,@tranId			BIGINT
	,@tranIdTemp		BIGINT
	,@pAmt				MONEY
	,@cAmt				MONEY
	,@txnDate			DATETIME
/*

EXEC [dbo].[proc_riaRemitPayHistory] @flag = 'aInfo', @user = 'adbapiuser'

*/
IF @flag = 'aInfo'
BEGIN
	SELECT TOP 1
		0 ErrorCode, am.agentName, am.agentId
	FROM applicationUsers au (NOLOCK)
	INNER JOIN agentMaster am (NOLOCK) ON au.agentId = am.agentId
	WHERE au.userName = @user
	RETURN
END	
	
IF @flag = 'loc'
	BEGIN
		IF @pBranch IS NULL
		BEGIN
			SELECT TOP 1 @pBranch = agentId FROM applicationUsers (NOLOCK) WHERE userName = @user
		END

		SELECT BranchCode = 'IME' + RIGHT('00000' + CAST(ISNULL(@pBranch, '0') AS VARCHAR), 6)
		--SELECT BranchCode = 'IME' + RIGHT('00000' + CAST(agentId AS VARCHAR), 6) FROM agentMaster am WITH(NOLOCK) WHERE agentId = @pBranch
		RETURN;
	END
	IF @flag = 's'
	BEGIN	
		DECLARE @table				VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
		SET @table = '
			(
				SELECT
					ria.rowId
					,''RIA FINANCIAL SERVICES'' AS provider
					,am.agentName
					,dbo.FNADecryptString(ria.pin) AS xpin
					,customer				= ISNULL(ria.CustNameFirst, '''')
					,beneficiary			= ISNULL(ria.beneNameFirst, '''')
					,customerAddress		= ISNULL(ria.CustAddress, '''')
					,beneficiaryAddress		= ISNULL(ria.rAddress, '''')
					,payoutAmount			= ria.BeneAmount
					,payoutDate				=ria.paidDate
				FROM riaRemitPayHistory  ria WITH(NOLOCK)
				LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = ria.pBranch
				WHERE recordStatus NOT IN(''DRAFT'', ''EXPIRED'')			
			'
			IF @pIN IS NOT NULL
			BEGIN
				SET @table = @table + ' AND pin = ''' + @pinEnc + ''''	
				select @pBranch = pBranch,@user = createdBy from riaRemitPayHistory with(nolock)
				where pin = @pinEnc
				if @pBranch is null and @user is not null
				begin
					select @pBranch = agentId  from applicationUsers with(nolock)  
					where userName = @user
					update riaRemitPayHistory set pBranch = @pBranch 
					where pin = @pinEnc 
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

	IF @flag = 'a'
	BEGIN 		
		SELECT TOP 1
			   	rowId
			   ,[controlNo]				= dbo.FNADecryptString(ria.pin)			   
			   ,[sCountry]				= ria.sCountry
			   ,[sName]					= ria.CustNameFirst
			   ,[sAddress]				= ISNULL(ria.CustAddress,'')
			   ,sCity					= ISNULL(ria.custCity,'')
			   ,sMobile					= ISNULL(ria.custTelNo,'')
			   ,sAgentName				= 'RIA FINANCIAL SERVICES'
			   ,sAgent					= 4869			  
			   ,[rCountry]				= 'Nepal'
			   ,[rName]					= ria.beneNameFirst
			   ,[rAddress]				= ria.rAddress
			   ,[rCity]					= ria.rCity
			   ,[rPhone]				= ISNULL(ria.rContactNo,'')
			   ,[rIdType]				= ria.rIdType
			   ,[rIdNumber]				= ria.rIdNumber
			   ,[pAmt]					= ria.BeneAmount
			   ,[pCurr]					= ria.BeneCurrency
			   ,[pBranch]				= am.agentName
				,branchId				= ria.pBranch 
			   ,[pUser]					= ria.createdBy
			   ,transactionMode			= 'Cash Payment'
			   ,PlaceOfIssue			= rIdPlaceOfIssue
			   ,rRelativeName			= relativeName
			   ,RelationType			= relationType
			   ,rContactNo				= rContactNo
		FROM riaRemitPayHistory ria WITH(NOLOCK)
		left JOIN agentMaster am WITH(NOLOCK) ON ria.pBranch = am.agentId
		WHERE recordStatus <> ('DRAFT') AND rowId = @rowId
		ORDER BY rowId DESC
		RETURN
	END 
			
	IF @flag = 'i'
	BEGIN
			IF EXISTS (SELECT 'x' FROM riaRemitPayHistory WITH(NOLOCK) WHERE pin= @pinEnc)
			BEGIN
				UPDATE riaRemitPayHistory SET 
					recordStatus = 'EXPIRED'
				WHERE pin = @pinEnc AND recordStatus <> 'READYTOPAY'
			END
			IF @pBranch IS NULL
				SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
			IF @pBranch = '1001'
			BEGIN
				EXEC [proc_errorHandler] 1, 'Payout branch is missing.', @rowId
				RETURN;
			END	
			INSERT INTO riaRemitPayHistory (
			transRefID
			,orderFound  
			,pin
			,orderNo  
			,seqIDRA  
			,orderDate  
			,custNameFirst  
			,custNameLast1  
			,custNameLast2  
			,custAddress  
			,custCity  
			,custState  
			,custCountry  
			,custZip  
			,custTelNo  
			,beneNameFirst  
			,beneNameLast1  
			,beneNameLast2  
			,beneAddress  
			,beneCity  
			,beneState  
			,beneCountry  
			,beneZip  
			,beneTelNo  
			,beneAmount  
			,responseDateTimeUTC 
			,remarks
			,apiStatus
			,recordStatus
			,pBranch
			,createdDate
			,createdBy 
			)
		SELECT
			 @transRefID
			,@orderFound  
			,@pinEnc
			,@orderNo  
			,@seqIDRA  
			,CONVERT(datetime, @orderDate, 102)  
			,@custNameFirst  
			,@custNameLast1  
			,@custNameLast2  
			,@custAddress  
			,@custCity  
			,@custState  
			,@custCountry  
			,@custZip  
			,@custTelNo  
			,@beneNameFirst  
			,@beneNameLast1  
			,@beneNameLast2  
			,@beneAddress  
			,@beneCity  
			,@beneState  
			,@beneCountry  
			,@beneZip  
			,@beneTelNo  
			,@beneAmount  
			,@responseDateTimeUTC  		
			,@remarks
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
	
	SELECT 
		     @tranId			= id
			,@pAmt				= pAmt
			,@cAmt				= cAmt
			,@sCountry			= sCountry
			,@txnDate			= createdDateLocal
			,@sFullName			= senderName
			,@rFullName			= receiverName
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @pinEnc
	
	
	
		--## Start OFAC / Compliance 
		DECLARE 
			@receiverOfacRes VARCHAR(MAX),
			@ofacRes VARCHAR(MAX),
			@ofacReason VARCHAR(MAX),
			@senderOfacRes VARCHAR(MAX)

			--## checking for OFAC is already checked or not
		IF NOT EXISTS(SELECT 'x' FROM tranPayOfac WITH(NOLOCK) WHERE tranId = @tranId  AND provider = 4869)
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
				SELECT @tranId, '4869' ,@ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes),@pAmt,@pinEnc,@pBranch,@sFullName,@rFullName,@txnDate,@user,GETDATE(),
				@membershipId,@rIdType,@rIdNumber,@rIdPlaceOfIssue,@beneTelNo,@relationType,@relativeName

				EXEC proc_errorHandler 1, 'Transaction is not in authorized mode, Please contact Head Office.', @pinEnc
				RETURN
			END
		END			
		--## checking for OFAC is approved or not
		IF EXISTS(SELECT 'x' FROM tranPayOfac WITH(NOLOCK) 
				WHERE tranId = @tranId		
					AND provider = 4869 
					AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction is not in authorized mode, Please contact Head Office.', @pinEnc
			RETURN
		END
		
		
		UPDATE riaRemitPayHistory SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = isnull(@pBranch ,pBranch)
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber 
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = CONVERT(DATETIME,@rValidDate, 102)
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks 	  	 = @remarks 
			,sCountry		 = @sCountry
			,rBank			 = @rbankName
			,rBankBranch	 = @rbankBranch
			,rAccountNo		 = @rAccountNo
			,rChequeNo		 = @rcheque
			,membershipId	 = @membershipId
			,customerId		 = @customerId
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose	
			,rIssueDate		 = @rIssuedDate
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Ready to pay has been recorded successfully.', @rowId
		RETURN
	END
	
	IF @flag = 'payError'
	BEGIN
		UPDATE riaRemitPayHistory SET 
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
			SELECT 'x' FROM riaRemitPayHistory WITH(NOLOCK) 
			WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') 
				AND rowid = @rowid )
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
			RETURN
		END

		DECLARE
			-- @tranId					BIGINT 
			@pSuperAgent				INT 
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
			,@sAgentMapCode				INT = 33200000  /*Need to change the value as per ria */
	 		,@sBranchMapCode			INT = 33200100 /*Need to change the value as per ria */

			,@bankName					VARCHAR(100) = NULL
			,@purposeOfRemit			VARCHAR(100) = NULL
			,@pBankBranch				VARCHAR(100) = NULL
			,@sAgentSettRate			VARCHAR(100) = NULL

			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			--,@cAmt						MONEY
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
		/* Start Ria Date  */
			 @transRefID				= ria.transRefID 
			,@orderFound				= ria.orderFound
			,@pin						= ria.pin
			,@orderNo					= ria.orderNo
			,@seqIDRA					= ria.seqIDRA
			,@orderDate					= ria.orderDate
			,@custNameFirst				= ria.custNameFirst
			,@custNameLast1				= ria.custNameLast1
			,@custNameLast2				= ria.custNameLast2
			,@custAddress				= ria.custAddress
			,@custCity					= ria.custCity
			,@custState					= ria.custState
			,@custCountry				= ria.custCountry
			,@custZip					= ria.custZip
			,@custTelNo					= ria.custTelNo
			,@beneNameFirst				= ria.beneNameFirst
			,@beneNameLast1				= ria.beneNameLast1
			,@beneNameLast2				= ria.beneNameLast2
			,@rFullName					= ISNULL(ria.beneNameFirst,'') +ISNULL(' '+ria.beneNameLast1,'') + ISNULL(' '+ria.beneNameLast2,'')
			,@beneAddress				= ria.beneAddress
			,@beneCity					= ria.beneCity
			,@beneState					= ria.beneState
			,@beneCountry				= ria.beneCountry
			,@beneZip					= ria.beneZip
			,@beneTelNo					= ria.beneTelNo
			,@rContactNo				= ria.rContactNo
			,@beneAmount				= ria.beneAmount
			,@responseDateTimeUTC		= ria.responseDateTimeUTC
			
			------------------------------------------------------
			,@apiStatus					= ria.apiStatus
			,@recordStatus				= ria.recordStatus
			,@rIdType					= ria.rIdType
			,@rIdNumber					= ria.rIdNumber
			,@rValidDate				= ria.rValidDate
			,@rDob						= ria.rDob
			,@rOccupation				= ria.rOccupation
			,@rNativeCountry			= ria.nativeCountry
			,@pBranch					= isnull(@pBranch,ria.pBranch)
			,@rIdPlaceOfIssue			= ria.rIdPlaceOfIssue
			,@relationType				= ria.relationType
			,@relativeName				= ria.relativeName
			,@sCountry					= case when ria.custCountry ='Nepal' then 'Australia' else ria.custCountry end
			,@rbankName					= rBank
			,@rbankBranch				= rBankBranch
			,@rcheque					= rAccountNo
			,@rAccountNo				= rChequeNo
			,@membershipId				= membershipId
			,@customerId				= customerId
			,@purpose					= purposeOfRemit
			,@relationship				= relWithSender
			,@rIssuedDate				= rIssueDate
		FROM riaRemitPayHistory ria WITH(NOLOCK)
		WHERE rowId = @rowId
		
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
		
		
/*Additional End */--End		
		
--## Check if controlno exist in remittran. 	

		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @pin )
		BEGIN
			DECLARE @status VARCHAR(100),@msg VARCHAR(100)
			SELECT  
				 @agentName = sAgentName
				,@status = payStatus	
			FROM remitTran WITH(NOLOCK) WHERE controlNo = @pin
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
		@pLocation, @pBranch, 'NPR', @deliveryMethodId, NULL, @beneamount, NULL, NULL, NULL)

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
				,@tAmt				= @beneamount
				,@customerId		= @customerId			
				,@receiverId		= @rIdNumber 
				,@receiverMemId		= @membershipId			
				,@receiverName		= @rFullName
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
					--SELECT @tranIdTemp, '4869' , @pin,@pBranch,@rFullName,@membershipId,@rDob,
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
					 ,[pbankName]					
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
					 --,[serviceCharge]			
													
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
					 @pin
					,@custNameFirst+' '+ISNULL(@custNameLast1,'')+' '+ISNULL(@custNameLast2,'')
					,@sCountry
					,@sSuperAgent
					,@sSuperAgentName
					,'Cash Payment'
					,dbo.FNARemitRoundForNPR(@beneamount)
					,dbo.FNARemitRoundForNPR(@beneamount)
					,dbo.FNARemitRoundForNPR(@beneamount)
					--,@exchangeRate
					,@pAgentComm
					,'NPR'--@beneCurrency
					,@pAgent
					,@pAgentName
					,@pSuperAgent
					,@pSuperAgentName 
					,@beneNameFirst+' '+ISNULL(@beneNameLast1,'')+' '+ISNULL(@beneNameLast2,'')
					,@pCountry
					,@pBranch
					,@pBranchName
					,@pState
					,@pDistrict
					,@pLocation
					,@bankName
					,@purposeOfRemit
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
					--,@pCommission

					--## HardCoded Parameters
					,'Paid'
					,'Paid'
					,'NPR'
					,dbo.FNAEncryptString(@transRefID) 
					,'I'
					,@sAgent
					,@sAgentName
					,@sBranch
					,@sBranchName
					,'1'
					
				SET @tranId = SCOPE_IDENTITY()

				INSERT INTO tranSenders	(
					 tranId
					,firstName
					,lastName1
					,lastName2					
					,country
					,[address]
					,homePhone
					)
				SELECT
					 @tranId			
					,@custNameFirst
					,@custNameLast1
					,@custNameLast2
					,@sCountry	
					,@CustAddress
					,@CustTelNo
					
				INSERT INTO tranReceivers (
					 tranId
					,firstName
					,lastName1
					,lastName2
					,country
					,city
					,[address]					
					,mobile
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
					,membershipId
					,customerId
					,relWithSender
					,purposeOfRemit
					,issuedDate2
					,validDate2
					)		
				SELECT 
					 @tranId			
					,@beneNameFirst  
					,@beneNameLast1
					,@beneNameLast2
					,@pCountry
					,@beneAddress
					,@beneCity  
					,@beneTelNo  
					,@rContactNo
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
					,@membershipId
					,@customerId
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
		----## >> Updating Data in riaRemitPayHistory table by paid status
			UPDATE riaRemitPayHistory SET 
				 recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg
				,confirmationNo	 = @payConfirmationNo
				,paidDate		 = GETDATE()
				,paidBy			 = @user			
			WHERE rowId = @rowId		
			
			-- ## Limit Update	
			EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @beneamount ,@settlingAgent = @pBranch
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SET @msg = 
				CASE 
					WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
					ELSE 'Transaction paid successfully'
				END

		EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @pin
		--EXEC proc_INFICARE_sendTxn @flag = 'SI',@controlNoEncrypted = @pin
		--EXEC proc_INFICARE_payTxn @flag = 'p',@tranIds = @tranId
		SET @controlNo = dbo.fnadecryptstring(@pin)	
		EXEC [proc_errorHandler] 0, @msg, @controlNo
		RETURN
	END	
	
	IF @flag ='byPass'
    BEGIN
		SELECT @rowId = rowId,@beneAmount=beneAmount FROM riaRemitPayHistory WITH(NOLOCK) WHERE pin = DBO.FNAEncryptString(@pIN) AND recordStatus='PAID'
		
		SELECT CASE WHEN (@rowId IS NOT NULL OR @rowId > 0)THEN '0' ELSE '1' END errorCode
		, CASE WHEN (@rowId IS NOT NULL OR @rowId > 0)THEN 'Success' ELSE 'Transaction not found' END msg
		, @rowId id, @beneAmount extra
    END
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
END CATCH

GO
