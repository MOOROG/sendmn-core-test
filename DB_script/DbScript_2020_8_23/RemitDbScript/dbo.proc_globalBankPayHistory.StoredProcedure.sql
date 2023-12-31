USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_globalBankPayHistory]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_globalBankPayHistory] (
	 @flag						VARCHAR(50)
	,@user						VARCHAR(50) 			
	,@rowId						BIGINT			= NULL
	,@tokenId					VARCHAR(100)	= NULL
	,@radNo						VARCHAR(100)	= NULL
	,@benefName					VARCHAR(100)	= NULL
	,@benefTel					VARCHAR(100)	= NULL
	,@benefMobile				VARCHAR(100)	= NULL
	,@benefAddress				VARCHAR(100)	= NULL
	,@benefAccIdNo				VARCHAR(100)	= NULL
	,@benefIdType				VARCHAR(100)	= NULL
	,@senderName				VARCHAR(100)	= NULL
	,@senderAddress				VARCHAR(100)	= NULL
	,@senderTel					VARCHAR(100)	= NULL
	,@senderMobile				VARCHAR(100)	= NULL
	,@senderIdType				VARCHAR(100)	= NULL
	,@senderIdNo				VARCHAR(100)	= NULL
	,@remittanceEntryDt			VARCHAR(100)	= NULL
	,@remittanceAuthorizedDt	VARCHAR(100)	= NULL
	,@remitType					VARCHAR(100)	= NULL
	,@pCurrency					VARCHAR(100)	= NULL
	,@rCurrency					VARCHAR(100)	= NULL
	,@pCommission				VARCHAR(100)	= NULL
	,@amount					VARCHAR(100)	= NULL
	,@localAmount				VARCHAR(100)	= NULL
	,@exchangeRate				VARCHAR(100)	= NULL
	,@dollarRate				VARCHAR(100)	= NULL

	,@TPAgentID					VARCHAR(100)	= NULL
	,@TPAgentName				VARCHAR(100)	= NULL

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
	
	
)
AS
SET XACT_ABORT ON

BEGIN TRY
	DECLARE		 
	@radNoEnc	VARCHAR(100) = dbo.FNAEncryptString(@radNo)

	IF @flag = 's'
	BEGIN	
		DECLARE @table				VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
		SET @table = '
			(
				SELECT
					gbl.rowId
					,''Global IME REMIT'' AS provider
					,am.agentName
					,dbo.FNADecryptString(gbl.radNo) AS xpin
					,customer				= ISNULL(gbl.senderName, '''')
					,beneficiary			= ISNULL(gbl.benefName, '''')
					,customerAddress		= ISNULL(gbl.senderAddress, '''')
					,beneficiaryAddress		= ISNULL(gbl.rAddress, '''')
					,payoutAmount			= gbl.amount
					,payoutDate				=gbl.paidDate
				FROM globalBankPayHistory  gbl WITH(NOLOCK)
				LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = gbl.pBranch
				WHERE recordStatus IN(''payError'')	 and gbl.createdDate > ''2014-05-16'''
			IF @radNo IS NOT NULL
			BEGIN
				SET @table = @table + ' AND radNo = ''' + @radNoEnc + ''''	
				select @pBranch = pBranch,@user = createdBy from globalBankPayHistory with(nolock)
				where radNo = @radNoEnc
				if @pBranch is null and @user is not null
				begin
					select @pBranch = agentId  from applicationUsers with(nolock)  
					where userName = @user
					update globalBankPayHistory set pBranch = @pBranch 
					where radNo = @radNoEnc 
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
			 rowId			= gbl.rowId
			,[controlNo]	= dbo.FNADecryptString(gbl.radNo)
			,[sCountry]		= isnull(cm.countryName,'Malaysia')
			,[sName]		= gbl.senderName
			,[sAddress]		= ISNULL(gbl.senderAddress,'')
			,[sIdType]		= gbl.senderIdType
			,[sIdNumber]	= gbl.senderIdNo
			,sCity			= null
			,sMobile		= gbl.senderMobile
			,sAgentName  	= 'Global IME Remit'
		    ,sAgent			= 4734		
			,[rCountry]		= 'Nepal'
			,[rName]		= gbl.benefName
			,[rAddress]		= gbl.rAddress
			,[rCity]		= gbl.rCity
			,[rPhone]		= ISNULL(gbl.rContactNo,'')
			,[rIdType]		= gbl.rIdType
			,[rIdNumber]	= gbl.rIdNumber
			,[pAmt]			= gbl.amount
			,[pCurr]		= gbl.pCurrency
			,[pBranchName]	= am.agentName
			,pBranch		= gbl.pBranch
			,branchId		= gbl.pBranch
			,[pUser]		= gbl.createdBy			
			,transactionMode ='Cash Payment'
			,PlaceOfIssue	=null
			,rRelativeName	=null
			,RelationType	=null
			,rContactNo		=rContactNo			
		FROM globalBankPayHistory gbl WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON gbl.pBranch = am.agentId
		left join currencyMaster currM with(nolock) on gbl.rCurrency = currM.currencyCode
		left join countryCurrency cc with(nolock) on cc.currencyId = currM.currencyId
		left join countryMaster cm with(nolock) on cm.countryId = cc.countryId
		WHERE recordStatus <> ('DRAFT') AND rowId = @rowId
		ORDER BY rowId DESC

		RETURN
	END 
			
	IF @flag = 'i'
	BEGIN
		IF EXISTS (SELECT 'x' FROM globalBankPayHistory WITH(NOLOCK) WHERE radNo= @radNoEnc)
		BEGIN
			UPDATE globalBankPayHistory SET 
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
		IF (LEFT(dbo.FNADecryptString(@radNoEnc),8) = '10122160')
		BEGIN
			EXEC [proc_errorHandler] 1, 'Please Go to Global IME Bank Branch to Receive the transaction!', @rowId
			RETURN;
		END
		INSERT INTO globalBankPayHistory (
			 radNo						
			,tokenId	
			,benefName
			,benefTel
			,benefMobile 
			,benefAddress
			,benefAccIdNo
			,benefIdType 
			,senderName 
			,senderAddress 
			,senderTel 
			,senderMobile 
			,senderIdType 
			,senderIdNo 
			,remittanceEntryDt
			,remittanceAuthorizedDt
			,remarks
			,remitType 
			,rCurrency 
			,pCurrency 
			,pCommission 
			,amount 
			,localAmount 
			,exchangeRate 
			,dollarRate 
			,apiStatus
			,recordStatus
			,pBranch
			,createdDate
			,createdBy 
			,tpAgentId
			,tpAgentName
			)
		SELECT
			 @radNoEnc
			,@tokenId
			,@benefName
			,@benefTel
			,@benefMobile
			,@benefAddress
			,@benefAccIdNo
			,@benefIdType 
			,@senderName 
			,@senderAddress 
			,@senderTel 
			,@senderMobile 
			,@senderIdType 
			,@senderIdNo 
			,@remittanceEntryDt
			,@remittanceAuthorizedDt
			,@remarks
			,@remitType 
			,@rCurrency 
			,@pCurrency 
			,@pCommission 
			,FLOOR(@amount)
			,@localAmount 
			,@exchangeRate 
			,@dollarRate 
			,@apiStatus
			,'DRAFT'
			,@pBranch
			,GETDATE()
			,@user	
			,@tpAgentId
			,@tpAgentName
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
	END
	
	IF @flag = 'readyToPay'
	BEGIN
		UPDATE globalBankPayHistory SET 
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
		SELECT @amount = amount FROM globalBankPayHistory WITH(NOLOCK) WHERE rowId = @rowId
		SELECT '0' errorCode, 'Ready to pay has been recorded successfully.' msg, 'Nepal' id, @amount extra
		RETURN
	END
	
	IF @flag = 'payError'
	BEGIN
		UPDATE globalBankPayHistory SET 
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
			SELECT 'x' FROM globalBankPayHistory WITH(NOLOCK) 
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
			,@benefName					= gbl.benefName
			,@benefTel					= gbl.benefTel
			,@benefMobile				= gbl.benefMobile 
			,@benefAddress				= gbl.benefAddress
			,@benefAccIdNo				= gbl.benefAccIdNo
			,@benefIdType				= gbl.benefIdType
			,@senderName				= gbl.senderName
			,@senderAddress 			= gbl.senderAddress
			,@senderTel					= gbl.senderTel 
			,@senderMobile				= gbl.senderMobile 
			,@senderIdType				= gbl.senderIdType 
			,@senderIdNo				= gbl.senderIdNo 
			,@remittanceEntryDt			= gbl.remittanceEntryDt
			,@remittanceAuthorizedDt	= gbl.remittanceAuthorizedDt
			,@remitType					= gbl.remitType
			,@rCurrency					= gbl.rCurrency 
			,@pCurrency					= gbl.pCurrency
			,@pCommission				= gbl.pCommission
			,@amount					= gbl.amount
			,@localAmount				= gbl.localAmount
			,@exchangeRate				= gbl.exchangeRate
			,@dollarRate				= gbl.dollarRate
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
			,@tpAgentId					= gbl.tpAgentId
			,@rbankName					= rBank
			,@rbankBranch				= rBankBranch
			,@rcheque					= rAccountNo
			,@rAccountNo				= rChequeNo
			,@membershipId				= membershipId
			,@customerId				= customerId
			,@purpose					= purposeOfRemit
			,@relationship				= relWithSender
		FROM globalBankPayHistory gbl WITH(NOLOCK)
		WHERE rowId = @rowId
		
		SELECT TOP 1
			@sCountry = cm.countryName,
			@sCountryId = cm.countryId
		FROM countryMaster cm WITH(NOLOCK) INNER JOIN countryCurrency cc WITH(NOLOCK) ON cm.countryId = cc.countryId
		INNER JOIN currencyMaster currM WITH(NOLOCK) ON currM.currencyId = cc.currencyId
		WHERE currM.currencyCode = @rCurrency
		 AND isOperativeCountry  ='Y'
		AND ISNULL(cc.isDeleted,'N') = 'N'

		-->> Modify controlNo if the transaction is from cash express (Al Ansari Exchange)
		IF LEN(dbo.FNADecryptstring(@radNo)) = 8 
			SET @ControlNoModified = dbo.FNAEncryptstring(dbo.FNADecryptstring(@radNo)+'G')
		ELSE
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
			DECLARE @status VARCHAR(100),@msg VARCHAR(100)
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
		
		--## 3. Find Commission 
		DECLARE @deliveryMethodId INT, @pCommCheck MONEY
		
		SET @payoutMethod = 'Cash Payment'
		DECLARE @pCountryId INT = NULL
		SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'				

		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'NPR'

		--## 4. Getting pAgentCommision for India to Nepal - Global API
		--if @sCountryId in (104) or @tpAgentId in (53) --,223
		--BEGIN
		--	SELECT  @pAgentComm = ISNULL(amount, 0), 
		--			@pCommCheck = amount, 
		--			@pAgentCommCurrency = commissionCurrency, 
		--			@pCommCheck = amount 
		--	FROM dbo.FNAGetPayCommGlobalApiIndiaToNepal(@sBranch, @sCountryId, NULL, @pSuperAgent, 151, 
		--	@pLocation, @pBranch, 'NPR', @deliveryMethodId, NULL, @amount, NULL, NULL, NULL)

		--	--if @pAgentComm is null or @pAgentComm =''
		--	-- set @pAgentComm = 50
		--END
		--ELSE
		--BEGIN
		--	SELECT  @pAgentComm = ISNULL(amount, 0), 
		--			@pCommCheck = amount, 
		--			@pAgentCommCurrency = commissionCurrency, 
		--			@pCommCheck = amount 
		--	FROM dbo.FNAGetPayComm(@sBranch, @sCountryId, NULL, @pSuperAgent, 151, 
		--	@pLocation, @pBranch, 'NPR', @deliveryMethodId, NULL, @amount, NULL, NULL, NULL)
		--END

		SELECT 
			@pAgentComm = ISNULL(pAgentComm, 0) 
		FROM dbo.FNAGetGIBLCommission(@sBranch, @ControlNoModified,@deliveryMethodId,'GIBL')

		--IF @pCommCheck IS NULL
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Payout Commission not defined', NULL
		--	RETURN
		--END
		
		-------Compliance Check Begin----------
		/*
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
				,@tAmt				= @amount
				,@customerId		= @customerId			
				,@receiverId		= @rIdNumber 
				,@receiverMemId		= @membershipId			
				,@receiverName		= @benefName 
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
					--SELECT @tranIdTemp, '4734' , @ControlNoModified,@pBranch,@benefName,@membershipId,@rDob,
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
		*/
		-------Compliance Check End----------

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
					 ,[customerRate]				
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
					 ,[serviceCharge]			
													
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
					,@senderName
					,isnull(@sCountry,'Qatar')
					,@sSuperAgent
					,@sSuperAgentName
					,'Cash Payment'
					,@amount
					,@amount
					,@amount
					,'1'
					,@pAgentComm
					,@pCurrency
					,@pAgent
					,@pAgentName
					,@pSuperAgent
					,@pSuperAgentName 
					,@benefName	 
					,@pCountry
					,@pBranch
					,@pBranchName
					,@pState
					,@pDistrict
					,@pLocation
					,@bankName
					,@purpose
					,@remarks	
					,@pBankBranch
					,@SagentsettRate
					
					,dbo.FNAGetDateInNepalTZ() 
					,GETDATE()
					,'SWIFT:API'
					,dbo.FNAGetDateInNepalTZ()
					,GETDATE()
					,'SWIFT:API'
					,@user
					,dbo.FNAGetDateInNepalTZ()
					,GETDATE()
					,'0'

					--## HardCoded Parameters
					,'Paid'
					,'Paid'
					,@pCurrency
					,@radNo
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
					,homePhone
					,mobile
					)
				SELECT
					 @tranId			
					,@senderName
					,@sCountry	
					,@senderAddress
					,@senderIdType	
					,@senderIdNo
					,@senderTel
					,@senderMobile
				
				--## Inserting Data in tranReceivers table
				INSERT INTO tranReceivers (
					 tranId
					,firstName
					,country
					,city
					,[address]
					,homePhone
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
					,@benefTel	
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
			UPDATE globalBankPayHistory SET 
				 recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg
				,confirmationNo	 = @payConfirmationNo
				,paidDate		 = GETDATE()
				,paidBy			 = @user			
			WHERE rowId = @rowId
			-- ## Limit Update
			EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @amount ,@settlingAgent = @pBranch
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
