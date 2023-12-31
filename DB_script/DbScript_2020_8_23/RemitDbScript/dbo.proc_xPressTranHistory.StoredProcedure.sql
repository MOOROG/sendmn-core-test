USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_xPressTranHistory]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_xPressTranHistory] (
	 @flag VARCHAR(50)
	,@provider VARCHAR(50) = NULL
	,@agentName VARCHAR(50) = NULL
	,@rowId BIGINT = NULL
	,@user VARCHAR(30) = NULL
	,@branchId VARCHAR(30) = NULL	
	,@txnByHo CHAR(1) = NULL		
	,@xmwsSessionID VARCHAR(100) = NULL
	,@xpin VARCHAR(100) = NULL
	,@customerFirstName VARCHAR(100) = NULL
	,@customerMiddleName VARCHAR(100) = NULL
	,@customerLastName VARCHAR(100) = NULL
	,@customerPOBox VARCHAR(100) = NULL
	,@customerAddress1 VARCHAR(100) = NULL
	,@customerAddress2 VARCHAR(100) = NULL
	,@customerAddressCity VARCHAR(100) = NULL
	,@customerAddressState VARCHAR(100) = NULL
	,@customerAddressCountry VARCHAR(100) = NULL
	,@customerAddressZip VARCHAR(100) = NULL
	,@customerPhone VARCHAR(100) = NULL
	,@customerMobile VARCHAR(100) = NULL
	,@customerFax VARCHAR(100) = NULL
	,@customerEmail VARCHAR(100) = NULL
	,@customerDescription VARCHAR(100) = NULL
	,@customerOtherInfo VARCHAR(100) = NULL
	,@beneficiaryFirstName VARCHAR(100) = NULL
	,@beneficiaryMiddleName VARCHAR(100) = NULL
	,@beneficiaryLastName VARCHAR(100) = NULL
	,@beneficiaryIDOtherType VARCHAR(100) = NULL
	,@beneficiaryID VARCHAR(100) = NULL
	,@beneficiaryPOBox VARCHAR(100) = NULL
	,@beneficiaryAddress1 VARCHAR(100) = NULL
	,@beneficiaryAddress2 VARCHAR(100) = NULL
	,@beneficiaryAddressCity VARCHAR(100) = NULL
	,@beneficiaryAddressState VARCHAR(100) = NULL
	,@beneficiaryAddressCountry VARCHAR(100) = NULL
	,@beneficiaryAddressZip VARCHAR(100) = NULL
	,@beneficiaryPhone VARCHAR(100) = NULL
	,@beneficiaryMobile VARCHAR(100) = NULL
	,@beneficiaryFax VARCHAR(100) = NULL
	,@beneficiaryEmail VARCHAR(100) = NULL
	,@beneficiaryTestQuestion VARCHAR(100) = NULL
	,@beneficiaryTestAnswer VARCHAR(100) = NULL
	,@messageToBeneficiary VARCHAR(100) = NULL
	,@beneficiaryDescription VARCHAR(100) = NULL
	,@beneficiaryOtherInfo VARCHAR(100) = NULL
	,@purposeOfTxn VARCHAR(100) = NULL
	,@sourceOfIncome VARCHAR(100) = NULL
	,@payoutAmount MONEY = NULL
	,@payInAmount MONEY = NULL
	,@commission MONEY = NULL
	,@tax MONEY = NULL
	,@agentXchgRate MONEY = NULL
	,@payoutCcyCode VARCHAR(100) = NULL
	,@payInCcyCode VARCHAR(100) = NULL
	,@payoutDate DATETIME = NULL
	,@payinDate DATETIME = NULL
	,@sendingAgentCode VARCHAR(100) = NULL
	,@sendingAgentName VARCHAR(100) = NULL
	,@receivingAgentCode VARCHAR(100) = NULL
	,@receivingAgentName VARCHAR(100) = NULL
	,@sendingCountry VARCHAR(100) = NULL
	,@receiveCountry VARCHAR(100) = NULL
	,@transactionMode VARCHAR(100) = NULL
	,@accountName VARCHAR(100) = NULL
	,@accountNo VARCHAR(100) = NULL
	,@bankName VARCHAR(100) = NULL
	,@bankBranchName VARCHAR(100) = NULL
	,@returnCode VARCHAR(100) = NULL
	,@returnMsg VARCHAR(100) = NULL	
	,@pBranch	VARCHAR(100)	=NULL
	,@rIdType VARCHAR(100) = NULL
	,@rIdNumber VARCHAR(100) = NULL
	,@rPlaceOfIssue VARCHAR(100) = NULL
	,@rRelationType VARCHAR(100) = NULL
	,@rRelativeName VARCHAR(100) = NULL
	,@rContactNo VARCHAR(100) = NULL
	,@rIssuedDate VARCHAR(100) = NULL
	,@rValidDate VARCHAR(100) = NULL
	,@customerId INT = NULL
	,@membershipId VARCHAR(100) = NULL
	,@txnStatus VARCHAR(100) = NULL
	,@sortBy VARCHAR(50)= NULL
	,@sortOrder VARCHAR(5)= NULL
	,@pageSize INT= NULL
	,@pageNumber INT= NULL
	,@rbankName         VARCHAR(50)		= NULL
	,@rbankBranch		VARCHAR(100)	= NULL
	,@rcheque			VARCHAR(50)		= NULL
	,@rAccountNo		VARCHAR(50)		= NULL
	,@topupMobileNo		varchar(50)		= null
	,@rDob				DATETIME		= NULL
	,@relationship		VARCHAR(100)	= NULL
	,@purpose			VARCHAR(100)	= NULL
)

AS
BEGIN TRY
SET XACT_ABORT ON

DECLARE
	 @xpinEnc			VARCHAR(50) 
	,@sql				VARCHAR(MAX)	
	,@table				VARCHAR(MAX)
	,@select_field_list	VARCHAR(MAX)
	,@extra_field_list	VARCHAR(MAX)
	,@sql_filter		VARCHAR(MAX)
	,@modType			VARCHAR(6)
	,@oldAgent			INT
	,@ApprovedFunctionId	VARCHAR(8)
	,@xPressMoneyMapID INT = 25100000
	,@xPressMoneyMapID_Branch INT = 25100100 --Branch - Head office
	,@receiverName		VARCHAR(250)

IF @flag = 'canpay'
BEGIN
	IF LTRIM(RTRIM(@txnStatus)) IN ('Sent - Ready for pickup at destination','Released for payment','Released-Ready for pick up')	
		SELECT 'Y' res
	ELSE 
		SELECT 'N'
	RETURN
END

IF @flag = 'check-status'
BEGIN
	DECLARE @code VARCHAR(10)
	IF LTRIM(RTRIM(@txnStatus)) IN ('Sent - Ready for pickup at destination','Released for payment','Released-Ready for pick up')	
		SELECT @code = '0'
	ELSE 
		SELECT @code = '1'

		SELECT @code errorCode, @txnStatus msg, NULL id

	RETURN
END

SET @xpinEnc = dbo.FNAencryptString(@xpin)

IF @flag = 'd'
BEGIN
	IF NOT EXISTS(SELECT 'x' FROM xPressTranHistory WITH(NOLOCK) WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') and rowid = @rowid)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
		RETURN
	END
		
	DELETE FROM xPressTranHistory WHERE rowId = @rowId	
	EXEC [proc_errorHandler] 0, 'Record has been deleted successfully.', @rowId
	RETURN
END

IF @flag = 's'
BEGIN
	IF @sortBy IS NULL SET @sortBy = 'provider'
	SET @table = '
		(
			SELECT
				rowId
				,''xPress Money'' AS provider
				,am.agentName
				,dbo.FNADecryptString(xpin) AS xpin
				,customer = ISNULL(customerFirstName, '''') + ISNULL('' '' + customerMiddleName, '''') + ISNULL('' '' + customerLastName, '''')
				,beneficiary = ISNULL(beneficiaryFirstName, '''') + ISNULL('' '' + beneficiaryMiddleName, '''') + ISNULL('' '' + beneficiaryLastName, '''')
				,customerAddress		= ISNULL(customerAddress1, '''') + ISNULL('' ,'' + customerAddress2, '''') + ISNULL('' ,'' + customerAddressCity, '''') + ISNULL('' ,'' + customerAddressState, '''')
				,beneficiaryAddress		= ISNULL(beneficiaryAddress1, '''') + ISNULL('' ,'' + beneficiaryAddress2, '''') + ISNULL('' ,'' + beneficiaryAddressCity, '''') + ISNULL('' ,'' + beneficiaryAddressState, '''')
				,payoutAmount
				,payoutDate
			FROM xPressTranHistory  xp WITH(NOLOCK)
			LEFT JOIN agentMaster am WITH(NOLOCK) ON am.agentId = xp.branchId
			WHERE recordStatus NOT IN(''DRAFT'', ''EXPIRED'')			
		'
		IF @xpin IS NOT NULL
		BEGIN
			
			SET @table = @table + ' AND xp.xpin = ''' + @xpinEnc + ''''		
			select @pBranch = branchId,@user = createdBy from xPressTranHistory with(nolock)
			where xpin = @xpinEnc
			if @pBranch is null and @user is not null
			begin
				select @pBranch = agentId  from applicationUsers with(nolock)  
				where userName = @user
				update xPressTranHistory set branchId = @pBranch 
				where xpin = @xpinEnc 
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
	SELECT 
		dbo.FNADecryptString(xpin) xpin1, 
		* 
		,xp.rRelationType RelationType
		,xp.rPlaceOfIssue PlaceOfIssue
	FROM xPressTranHistory xp WITH(NOLOCK) 
	--LEFT JOIN staticDataValue rt WITH(NOLOCK) ON xp.rRelationType = rt.valueId 
	--LEFT JOIN zoneDistrictMap poi WITH(NOLOCK) ON xp.rPlaceOfIssue = poi.districtId 
	
	WHERE rowId = @rowId	
	RETURN
END

IF @flag = 'i'
BEGIN	
	IF EXISTS (
		SELECT 
			'x' 
		FROM xPressTranHistory 
		WHERE xpin = @xpinEnc
	)
	BEGIN
		UPDATE xPressTranHistory SET 
			recordStatus = 'EXPIRED'
		WHERE xpin = @xpinEnc AND recordStatus <> 'READYTOPAY'
	END
	IF @branchId IS NULL
		SELECT @branchId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		
	IF @branchId = '1001'
	BEGIN
		EXEC [proc_errorHandler] 1, 'Payout branch is missing.', @rowId
		RETURN;
	END	

	INSERT INTO xPressTranHistory (
		 xmwsSessionID
		,xpin
		,customerFirstName
		,customerMiddleName
		,customerLastName
		,customerPOBox
		,customerAddress1
		,customerAddress2
		,customerAddressCity
		,customerAddressState
		,customerAddressCountry
		,customerAddressZip
		,customerPhone
		,customerMobile
		,customerFax
		,customerEmail
		,customerDescription
		,customerOtherInfo
		,beneficiaryFirstName
		,beneficiaryMiddleName
		,beneficiaryLastName
		,beneficiaryIDOtherType
		,beneficiaryID
		,beneficiaryPOBox
		,beneficiaryAddress1
		,beneficiaryAddress2
		,beneficiaryAddressCity
		,beneficiaryAddressState
		,beneficiaryAddressCountry
		,beneficiaryAddressZip
		,beneficiaryPhone
		,beneficiaryMobile
		,beneficiaryFax
		,beneficiaryEmail
		,beneficiaryTestQuestion
		,beneficiaryTestAnswer
		,messageToBeneficiary
		,beneficiaryDescription
		,beneficiaryOtherInfo
		,purposeOfTxn
		,sourceOfIncome
		,payoutAmount
		,payInAmount
		,commission
		,tax
		,agentXchgRate
		,payoutCcyCode
		,payInCcyCode
		,payoutDate
		,payinDate
		,sendingAgentCode
		,sendingAgentName
		,receivingAgentCode
		,receivingAgentName
		,sendingCountry
		,receiveCountry
		,transactionMode
		,accountName
		,accountNo
		,bankName
		,bankBranchName
		,returnCode
		,returnMsg	
		,createdBy
		,createdDate
		,txnByHo
		,branchId
		,recordStatus
	)
	SELECT
		 @xmwsSessionID
		,@xpinEnc
		,@customerFirstName
		,@customerMiddleName
		,@customerLastName
		,@customerPOBox
		,@customerAddress1
		,@customerAddress2
		,@customerAddressCity
		,@customerAddressState
		,@customerAddressCountry
		,@customerAddressZip
		,@customerPhone
		,@customerMobile
		,@customerFax
		,@customerEmail
		,@customerDescription
		,@customerOtherInfo
		,@beneficiaryFirstName
		,@beneficiaryMiddleName
		,@beneficiaryLastName
		,@beneficiaryIDOtherType
		,@beneficiaryID
		,@beneficiaryPOBox
		,@beneficiaryAddress1
		,@beneficiaryAddress2
		,@beneficiaryAddressCity
		,@beneficiaryAddressState
		,@beneficiaryAddressCountry
		,@beneficiaryAddressZip
		,@beneficiaryPhone
		,@beneficiaryMobile
		,@beneficiaryFax
		,@beneficiaryEmail
		,@beneficiaryTestQuestion
		,@beneficiaryTestAnswer
		,@messageToBeneficiary
		,@beneficiaryDescription
		,@beneficiaryOtherInfo
		,@purposeOfTxn
		,@sourceOfIncome
		,@payoutAmount
		,@payInAmount
		,@commission
		,@tax
		,@agentXchgRate
		,@payoutCcyCode
		,@payInCcyCode
		,CONVERT(VARCHAR, @payoutDate, 101)
		,CONVERT(VARCHAR, @payinDate, 101)		
		,@sendingAgentCode
		,@sendingAgentName
		,@receivingAgentCode
		,@receivingAgentName
		,@sendingCountry
		,@receiveCountry
		,@transactionMode
		,@accountName
		,@accountNo
		,@bankName
		,@bankBranchName
		,@returnCode
		,@returnMsg
		,@user
		,GETDATE()
		,@txnByHo
		,@branchId
		,'DRAFT'
	SET @rowId = SCOPE_IDENTITY()
	EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
	RETURN 
END
IF @flag = 'readyToPay'
BEGIN
	--alter table xPressTranHistory add topupMobileNo varchar(20)
	UPDATE xPressTranHistory SET 
		 recordStatus = 'READYTOPAY'
		,payResponseCode = @returnCode
		,payResponseMsg = @returnMsg 
		,rIdType = @rIdType
		,rIdNumber = @rIdNumber
		,rPlaceOfIssue = @rPlaceOfIssue
		,rRelationType = @rRelationType
		,rRelativeName = @rRelativeName
		,rContactNo  = @rContactNo
		,rIssuedDate = @rIssuedDate
		,rValidDate = @rValidDate
		,membershipId = @membershipId
		,customerId = @customerId
		,rBank			 = @rbankName
		,rBankBranch	= @rbankBranch
		,rAccountNo		= @rAccountNo
		,rChequeNo		= @rcheque
		,topupMobileNo = @topupMobileNo
		,rDob			 = @rDob
		,relWithSender	 = @relationship
		,purposeOfRemit  = @purpose		
		,rIssueDate	=	@rIssuedDate 
	WHERE rowId = @rowId
	EXEC [proc_errorHandler] 0, 'Ready to pay has been recorded successfully.', @rowId
	RETURN
END
IF @flag = 'payError'
BEGIN
	UPDATE xPressTranHistory SET 
		 recordStatus = 'PAYERROR'
		,payResponseCode = @returnCode
		,payResponseMsg = @returnMsg		
	WHERE rowId = @rowId
	EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
	RETURN
END

--payError

IF @flag IN ('pay', 'restore')
BEGIN
	IF NOT EXISTS(
		SELECT 'x' FROM xPressTranHistory WITH(NOLOCK) 
		WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') 
			AND rowid = @rowid
	)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
		RETURN
	END

	DECLARE
		 @tranId					BIGINT 
		,@tranIdTemp				BIGINT 
		,@sBranch					INT
		,@sBranchName				VARCHAR(100)
		,@sAgent					INT
		,@sAgentName				VARCHAR(100)
		,@sSuperAgent				INT
		,@sSuperAgentName			VARCHAR(100)
		,@pCountry					VARCHAR(100)
		,@pState					VARCHAR(100)
		,@pDistrict					VARCHAR(100)
		,@pLocation					INT
		,@deliveryMethod			VARCHAR(100)
		,@pAgent					VARCHAR(200)
		,@pAgentComm				MONEY
		,@pAgentCommCurrency		VARCHAR(3)
		,@pSuperAgentComm			MONEY
		,@pSuperAgentCommCurrency	VARCHAR(3)
		,@agentType					INT
		,@payoutMethod				VARCHAR(50)
		,@cAmt						MONEY
		,@controlNo					VARCHAR(50)
		,@beneIdNo					INT
		,@customerRate				MONEY
		,@payoutCurr				VARCHAR(50)
		,@collCurr					VARCHAR(50)		
		,@sendAgentName				VARCHAR(200)			
		,@sendCountry				VARCHAR(200)
		,@pSuperAgent				VARCHAR(100)
		,@pBranchName				VARCHAR(100)
		,@pAgentName				VARCHAR(100)
		,@pSuperAgentName			VARCHAR(200)
		,@MapCodeIntBranch			VARCHAR(50) 
		,@companyId					INT = 16
		
			
		SELECT
			 @controlNo				= xpin
			,@xpin					= dbo.FNADecryptString(xpin)			
			,@beneficiaryID			= beneficiaryID
			,@beneficiaryFirstName	= beneficiaryFirstName
			,@beneficiaryMiddleName	= beneficiaryMiddleName
			,@beneficiaryLastName	= beneficiaryLastName
			,@receiverName			= ISNULL(@beneficiaryFirstName,'') + ISNULL( ' ' + @beneficiaryMiddleName, '') + ISNULL( ' ' + @beneficiaryLastName, '')  
			,@beneficiaryPhone		= beneficiaryPhone
			,@beneficiaryMobile		= beneficiaryMobile
			,@beneficiaryPOBox		= beneficiaryPOBox 
			,@beneficiaryAddressZip	= beneficiaryAddressZip
			,@beneficiaryFax		= beneficiaryFax
			,@beneficiaryEmail		= beneficiaryEmail
			,@beneficiaryAddress1	= beneficiaryAddress1+' ,'+beneficiaryAddress2+' ,'+ beneficiaryAddressCity+' ,'+beneficiaryAddressState
			
			,@customerFirstName		= customerFirstName
			,@customerMiddleName	= customerMiddleName
			,@customerLastName		= customerLastName			
			,@customerPhone			= customerPhone
			,@customerMobile		= customerMobile
			,@customerPOBox			= customerPOBox 
			,@customerAddressZip	= customerAddressZip
			,@customerFax			= customerFax
			,@customerEmail			= customerEmail
			,@customerAddress1		= customerAddress1+' ,'+customerAddress2+' ,'+ customerAddressCity+' ,'+customerAddressState
			
			,@purposeOfTxn			= purposeOfTxn
			,@sourceOfIncome		= sourceOfIncome			
			,@payoutAmount			= payoutAmount	
			,@cAmt					= payInAmount
			,@commission			= commission
			,@tax					= tax
			,@customerRate			= agentXchgRate
			,@payoutCurr			= payoutCcyCode
			,@collCurr				= payInCcyCode			
			
			,@sendAgentName			= sendingAgentName
			,@sendCountry			= sendingCountry
			,@payoutMethod			= 'Cash Payment'
		
			,@pBranch = ISNULL(@branchId, branchId)
			,@rIdType = rIdType
			,@rIdNumber = rIdNumber
			,@rPlaceOfIssue = rPlaceOfIssue
			,@rRelationType = rRelationType
			,@rRelativeName = rRelativeName
			,@rContactNo = rContactNo
			,@rIssuedDate = rIssueDate
			,@rValidDate = rValidDate
			,@returnCode = payResponseCode
			,@returnMsg = payResponseMsg 
			,@rbankName = rBank
			,@rbankBranch = rBankBranch
			,@rcheque = rAccountNo
			,@rAccountNo = rChequeNo
			,@customerId = customerId
			,@membershipId = membershipId
			,@topupMobileNo = topupMobileNo
			,@rDob = rDob
			,@purpose = purposeOfRemit
			,@relationship = relWithSender
		FROM xPressTranHistory WITH(NOLOCK) WHERE rowId = @rowId
		
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
		FROM remitTran  WITH(NOLOCK) WHERE controlNo = @controlNo
	
		--1. Find Sending Agent Details
		SELECT  @sBranch = agentId, 
				@sAgent = parentId, 
				@sBranchName = agentName, 
				@agentType = agentType 
		FROM agentMaster WITH(NOLOCK) 
		WHERE mapCodeInt = '25100000' AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @agentType = 2903
		BEGIN
			SET @sAgent = @sBranch
		END
		
		SELECT  @sSuperAgent = parentId, 
				@sAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent

		SELECT @sSuperAgentName = agentName 
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
			
		SELECT  @pSuperAgent = parentId, 
				@pAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
		
			--3. Find Commission 
		DECLARE @sCountryId INT, @deliveryMethodId INT, @pCommCheck MONEY
		SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sendingCountry
		
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
		@pLocation, @pBranch, 'NPR', @deliveryMethodId, NULL, @payoutAmount, NULL, NULL, NULL)

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
				,@tAmt				= @payoutAmount
				,@customerId		= @customerId			
				,@receiverId		= @rIdNumber 
				,@receiverMemId		= @membershipId			
				,@receiverName		= @receiverName
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
					--SELECT @tranIdTemp, '4909' , @controlNo,@pBranch,@receiverName,@membershipId,@rDob,
					--@rIdType,@rIdNumber,@rPlaceOfIssue,@rContactNo,@rRelationType,@rRelativeName,@relationship,@purpose,@user,GETDATE()
					
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
			INSERT INTO remitTran(
				 controlNo
				,pAgentComm
				,pAgentCommCurrency
				,pSuperAgentComm
				,pSuperAgentCommCurrency
				,sBranch
				,sBranchName
				,sAgent
				,sAgentName
				,sSuperAgent
				,sSuperAgentName
				,sCountry
				,pBranch
				,pBranchName
				,pAgent
				,pAgentName
				,pSuperAgent
				,pSuperAgentName
				,pCountry
				,pState
				,pDistrict
				,pLocation
				,tAmt
				,collCurr
				,serviceCharge
				,cAmt
				,sAgentComm
				,sAgentCommCurrency
				,pAmt
				,payoutCurr
				,paymentMethod
				,customerRate
				,tranStatus
				,payStatus
				,createdBy
				,createdDate
				,createdDateLocal
				,approvedBy
				,approvedDate
				,approvedDateLocal
				,paidDate
				,paidDateLocal
				,paidBy
				,tranType
				,senderName
				,receiverName
			)
	
			SELECT
				 @controlNo
				,@pAgentComm 
				,@pAgentCommCurrency  
				,@pSuperAgentComm 
				,@pSuperAgentCommCurrency 
				,@sBranch 
				,@sBranchName 
				,@sAgent 
				,@sAgentName 
				,@sSuperAgent 
				,@sSuperAgentName 
				,@sendCountry 
				,@pBranch 
				,@pBranchName 
				,@pAgent 
				,@pAgentName 
				,@pSuperAgent 
				,@pSuperAgentName 
				,@pCountry 
				,@pState 
				,@pDistrict 
				,@pLocation 
				,@payoutAmount 				
				,@payoutCurr 
				,0 
				,@payoutAmount 
				,0 
				,@payoutCurr 
				,@payoutAmount 
				,@payoutCurr 
				,'Cash Payment' 
				,@customerRate 
				,'Paid' 
				,'Paid' 
				,'xPressMoney' 
				,GETDATE() 
				,GETDATE() 
				,'xPressMoney' 
				,GETDATE() 
				,GETDATE() 
				,dbo.FNAGetDateInNepalTZ() 
				,dbo.FNAGetDateInNepalTZ() 
				,@user 
				,'I' 
				,ISNULL(' '+ @customerFirstName,'') + ISNULL( ' ' + @customerMiddleName, '') + ISNULL( ' ' + @customerLastName, '') 
				,ISNULL(' '+ @beneficiaryFirstName,'') + ISNULL( ' ' + @beneficiaryMiddleName, '') + ISNULL( ' ' + @beneficiaryLastName, '') 

			SET @tranId = SCOPE_IDENTITY()
			--## Inserting Data in tranSenders table
			INSERT INTO tranSenders(
				tranId, firstName, middleName, lastName1, address, mobile, workPhone, city, country
				, idType, idNumber, validDate
			)
			SELECT
				@tranId,@customerFirstName,@customerMiddleName,@customerLastName,
				@customerAddress1,@customerMobile,@customerPhone,@customerAddressCity,@customerAddressCountry
				,null, NULL, NULL
			
			--## Inserting Data in tranReceivers table
			INSERT INTO tranReceivers(
				tranId, firstName, middleName, lastName1, lastName2, address, mobile, homePhone, city, country
				, idType, idNumber, relationType, relativeName,bankName
					,branchName
					,chequeNo
					,accountNo
					,workPhone
					,customerId
					,membershipId,relWithSender,purposeOfRemit,dob,issuedDate2,validDate2
			)
			SELECT
				@tranId,@beneficiaryFirstName,@beneficiaryMiddleName,@beneficiaryLastName,NULL,@beneficiaryAddress1,
				@rContactNo,@beneficiaryPhone,NULL,'Nepal'
				,@rIdType,@rIdNumber,@rRelationType, @rRelativeName,@rbankName
					,@rbankBranch
					,@rcheque
					,@raccountNo
					,@topupMobileNo
					,@customerId
					,@membershipId,@relationship,@purpose,@rDob,@rIssuedDate,@rValidDate
			
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
							
			--## >> Updating Data in xPressTranHistory table by paid status
			UPDATE xPressTranHistory SET 
				 recordStatus = 'PAID'
				,tranPayProcess = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @returnCode
				,payResponseMsg = @returnMsg				
			WHERE rowId = @rowId

		END
		/*Topup Information Send SMS*/
		IF @membershipId IS NOT NULL
		BEGIN
			EXEC proc_topupQueue 
				 @flag			= 'a'
				,@user			= @user
				,@tranId		= @tranId
				,@tranType		= 'I'
		END
		EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @controlNo	
		-- ## Limit Update
		EXEC Proc_AgentBalanceUpdate @flag = 'p',@tAmt = @payoutAmount ,@settlingAgent = @pBranch
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		DECLARE @msg VARCHAR(200)
		SET @msg = 
			CASE 
				WHEN @flag = 'restore' THEN 'Transaction has been restored successfully'
				ELSE 'Transaction paid successfully'
			END
			
		EXEC [proc_errorHandler] 0, @msg, @xpin	

	RETURN	
END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, null id
END CATCH



GO
