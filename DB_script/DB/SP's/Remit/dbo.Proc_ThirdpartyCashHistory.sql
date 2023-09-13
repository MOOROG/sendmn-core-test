SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO


ALTER PROC [dbo].[Proc_ThirdpartyCashHistory](
	 @flag						VARCHAR(50)
	,@user						VARCHAR(50) 			
	,@rowId						BIGINT			= NULL
	,@payTokenId				VARCHAR(100)	= NULL
	,@refNo						VARCHAR(100)	= NULL
	,@RequestFrom				VARCHAR(20)		= NULL
	,@sendingCurrency			VARCHAR(10)		= NULL
	,@exRate					VARCHAR(20)		= NULL

	,@benefName					VARCHAR(100)	= NULL
	,@benefCity					VARCHAR(100)	= NULL
	,@benefMobile				VARCHAR(100)	= NULL
	,@benefAddress				VARCHAR(100)	= NULL
	,@benefCountry				VARCHAR(100)	= NULL

	,@senderName				VARCHAR(100)	= NULL
	,@senderAddress				VARCHAR(100)	= NULL
	,@senderCity				VARCHAR(100)	= NULL
	,@senderMobile				VARCHAR(100)	= NULL
	,@senderCountry				VARCHAR(100)	= NULL

	,@pCurrency					VARCHAR(100)	= NULL
	,@paymentType				VARCHAR(100)	= NULL
	,@payResponseCode			VARCHAR(20)		= NULL
	,@payResponseMsg			VARCHAR(100)	= NULL
	,@message					VARCHAR(500)	= NULL
	,@txnDate					DATETIME		= NULL
	,@pAmount					VARCHAR(100)	= NULL
	,@pCommission				VARCHAR(10)		= NULL
	,@pConfirmId				VARCHAR(100)	= NULL
		
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
	,@relationship				VARCHAR(100)	= NULL
	,@purpose					VARCHAR(100)	= NULL
	,@tranNo 					VARCHAR(50)		= NULL
	,@partnerId					VARCHAR(25)		= NULL
	,@sessionId					VARCHAR(100)	= NULL
	,@senderAgent				VARCHAR(50)		= NULL
	,@pBranch					VARCHAR(20)				= NULL
	,@rbankBranch				VARCHAR(100)	= NULL
	,@rbankName					VARCHAR(100)	= NULL
	,@rAccountNo				VARCHAR(50)		= NULL
	,@rcheque					VARCHAR(50)		= NULL
	,@sBranchMapCOdeInt			INT				= NULL
	,@sendAgent					VARCHAR(100)	= NULL
	,@benefIdNumber				VARCHAR(30)		= NULL
	,@benefIdType				VARCHAR(50)		= NULL
	,@remittanceEntryDt			VARCHAR(30)		= NULL
	,@tranMode					VARCHAR(30)		= NULL
	,@customerId				VARCHAR(30)		= NULL
	,@membershipId				VARCHAR(30)		= NULL
	,@sCountry					VARCHAR(30)		= NULL
	,@payConfirmationNo			VARCHAR(30)		= NULL
	--new addition
    ,@sAmount					VARCHAR(100)	= NULL
    ,@incomeSource				VARCHAR(100)	= NULL
    ,@calculateBy				VARCHAR(100)	= NULL
	,@pCurrCostRate				MONEY			= NULL
	,@sCurrCostRate				MONEY			= NULL
	,@pBranchName				VARCHAR(100)    = NULL
	,@password					VARCHAR(100)	= NULL
	,@complianceQuestion		NVARCHAR(MAX)	= NULL
)
AS
SET XACT_ABORT ON
SET NOCOUNT ON
BEGIN TRY
	DECLARE @refNoEnc VARCHAR(100) = dbo.FNAEncryptString(@refNo),@riaSuperAget VARCHAR(20)

	SELECT @riaSuperAget = agentId FROM dbo.Vw_GetAgentID WHERE SearchText ='riaAgent'

	IF @flag = ''
	BEGIN
		SELECT TOP 1 PIN=dbo.decryptdb(refNo),OrderNo=sessionId
		,TransRefID=tokenId,BeneCurrency = pCurrency,BeneAmount=pAmount
		,CorrespLocCountry=benefCountry
		, CorrespLocID = ISNULL(pBranch,'394414')
		FROM dbo.GMEPayHistory WITH(NOLOCK)
		WHERE refNo = @refNoEnc ORDER BY rowId DESC
		select * from GMEPayHistory
		RETURN
	END
	IF @flag = 's'
	BEGIN
		DECLARE @agentGrp INT,@cotrolNo VARCHAR(50), @branchName VARCHAR(200)
		IF @pBranch IS NOT NULL
			SELECT @branchName = agentName, @agentGrp = agentGrp FROM agentMaster am WITH(NOLOCK) WHERE agentId = @pBranch
	END
IF @flag = 's-customer'
BEGIN
	IF EXISTS(SELECT * FROM dbo.RiaCashHistory WHERE rowId = @rowId AND Pin= dbo.encryptDb(@refNo))
	BEGIN
		SET @partnerId = 	@riaSuperAget
		SET @payTokenId = NEWID()
	END
	ELSE
	BEGIN
	
		SELECT @payTokenId = tokenId,@partnerId=senderAgent
		FROM GMEPayHistory (NOLOCK)
		WHERE rowId = @rowId
	END

	SELECT ReceivingTokenId = @payTokenId,
			rIdType = ID.detailTitle,
			rIdNumber = CM.idNumber,
			rIdPlaceOfIssue = ISNULL(CM.placeOfIssue, CO.COUNTRYNAME),
			rIdPlaceOfIssueCode = CO.countryCode,
			rIdIssueDate = CONVERT(VARCHAR(10), CM.idIssueDate, 111),
			rDob = CONVERT(VARCHAR(10), CM.dob, 111),
			occupation = OCCU.detailTitle,
			rContactNo = mobile,
			firstName,
			lastName1,
			fullName='viernoles marrtes',--CM.FULLNAME,
			customerId,
			membershipId = ISNULL(membershipId, customerId),
			mobile,
			email = customerEmail,
			note = WALLETACCOUNTNO,
			partnerId = @partnerId,
			[address] = CM.address,
			city = City.CITY_NAME
	FROM customerMaster CM(NOLOCK) 
	LEFT JOIN countryMaster CO(NOLOCK) ON CO.countryId = CM.country
	INNER JOIN STATICDATAVALUE ID(NOLOCK) ON ID.VALUEID = CM.IDTYPE
	INNER JOIN STATICDATAVALUE OCCU(NOLOCK) ON OCCU.VALUEID = CM.occupation
	LEFT JOIN TBL_CITY_LIST City(NOLOCK) ON (City.ROW_ID = CM.city OR City.CITY_NAME = cm.city)
	WHERE USERNAME = @user
RETURN
END
	IF @flag = 'i' 
	BEGIN
		IF @RequestFrom = 'mobile'
			SET @pBranch =(SELECT agentId FROM Vw_GetAgentID WHERE SearchText = 'PayTxnFromMobile')-- '394420'  --clearly this is pay from wallet user which is recorded under this payoutBranch..


		if EXISTS (SELECT 'X' FROM dbo.GMEPayHistory WITH(NOLOCK) WHERE refNo = @refNoEnc)
		BEGIN
		    UPDATE dbo.GMEPayHistory SET recordStatus = 'EXPIRED' WHERE refNo = @refNoEnc AND recordStatus <> 'READYTOPAY'
		END

		IF @pBranch IS NULL
			SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user

			
		INSERT INTO dbo.GMEPayHistory
				( 
				RequestFrom,
				refNo,
				sendingAgent, 
				senderName, 
				senderAddress, 
				senderMobile, 
				senderCity, 
				senderCountry,

				benefName, 
				benefAddress, 
				benefMobile, 
				benefCity, 
				benefCountry,
				
				pAmount, 
				sAmount,
				pCurrency, 
				paymentType, 
				txnDate, 
				tokenId,
				sessionId,
				rOccupation,
				incomeSource,
				relationType,
				purposeOfRemit,
				rCurrCostRate,
				sCurrCostRate,
				sendingCurrency,
				exRate,

				message, 
				createdBy, 
				createdDate, 
				recordStatus
				
				)
		select  @RequestFrom,
				@refNoEnc, 
				@sendAgent,
				@senderName, 
				@senderAddress, 
				@senderMobile, 
				@senderCity, 
				@senderCountry,
				 
				@benefName, 
				@benefAddress, 
				@benefMobile, 
				@benefCity, 
				@benefCountry,
				
				@pAmount,
				@sAmount,
				@pCurrency, 
				@paymentType, 
				@remittanceEntryDt, 
				@payTokenId,
				@sessionId,
				@rOccupation,
				@incomeSource,
				@relationship,
				@purpose,
				@pCurrCostRate,
				@sCurrCostRate,
				@sendingCurrency,
				@exRate,
		
				@message, 
				@user ,
				GETDATE() , 
				'DRAFT'
		
		DECLARE @senderCountryCode VARCHAR(10), @receivingCountryInfo VARCHAR(30)

		SELECT @senderCountryCode = countryCode
		FROM countryMaster (NOLOCK)
		WHERE countryName = @senderCountry

		SELECT @receivingCountryInfo = countryCode + '|' + countryName
		FROM countryMaster (NOLOCK)
		WHERE countryName = @benefCountry
				
		SET @rowId = SCOPE_IDENTITY()
		SELECT 0 errorCode, 'Transaction Has Been Saved Successfully' msg, @rowId id, @senderCountryCode senderCountryCode, @receivingCountryInfo receivingCountryInfo 
		RETURN 
	END

	IF @flag = 'readyToPay'
	BEGIN

		IF @RequestFrom = 'mobile'
			SET @pBranch = (SELECT agentId FROM Vw_GetAgentID WHERE SearchText = 'PayTxnFromMobile')--'394420'  --clearly this is pay from wallet user which is recorded under this payoutBranch..
		
		IF @RequestFrom = 'mobile'
		BEGIN
			IF NOT EXISTS(SELECT * FROM CUSTOMERMASTER (NOLOCK) WHERE USERNAME = @user AND CUSTOMERPASSWORD = DBO.FNAENCRYPTSTRING(@password))
			BEGIN 
				SELECT '1' errorCode, 'Provided Credentials Wrong' msg, @sendAgent id
				RETURN;
		   END 
		END
		ELSE
		BEGIN
		   IF NOT EXISTS( SELECT 'x' From applicationusers where userName = @user)
		   BEGIN 
				SELECT '1' errorCode, 'Provided Credentials Wrong' msg, @sendAgent id
				RETURN;
		   END 
		END
		IF (@sessionId IS NULL OR @sessionId = '')
		BEGIN
			SELECT '1' Code,'SessionId Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF (@refNo IS NULL OR @refNo = '')
		BEGIN
			SELECT '1' Code,'ControlNo Number Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF @rIdType = '' OR @rIdType IS NULL 
		BEGIN
			SELECT '1' Code,'rIdType Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF @rIdNumber = '' OR @rIdNumber IS NULL 
		BEGIN
			SELECT '1' Code,'rIdNumber Is Mandatory' Message , NULL Id
			RETURN;
		END

		--IF ISDATE(@rDob) = 0
		--BEGIN
		--	SELECT '1' Code,'RDob Date Formate Is Wrong!' Message , NULL Id
		--	RETURN;
		--END

		--IF ISDATE(@rDob) = 0
		--BEGIN
		--	SELECT '1' Code,'RDob Date Formate Is Wrong!' Message , NULL Id
		--	RETURN;
		--END

		IF @rContactNo = '' OR @rContactNo IS NULL
		BEGIN
			SELECT '1' Code,'rContactNo Is Mandatory' Message , NULL Id
			RETURN;
		END

		IF ISDATE(@rIssuedDate) = 0 AND @rIssuedDate IS NOT NULL
		BEGIN
			SELECT '1' Code,'rIssued Date   Formate Is Wrong!' Message , NULL Id
			RETURN;
		END

		IF @rIdPlaceOfIssue = '' AND @rIdPlaceOfIssue IS NOT NULL
		BEGIN
			SELECT '1' Code,'rIdPlaceOfIssue Is Mandatory!' Message , NULL Id
			RETURN;
		END

		IF @rOccupation = '' AND @rOccupation IS NOT NULL
		BEGIN
			SELECT '1' Code,'occupation Is Mandatory!' Message , NULL Id
			RETURN;
		END

		IF @payTokenId  = '' AND @payTokenId  IS NOT NULL
		BEGIN
			SELECT '1' Code,'ReceivingTokenId Is Mandatory!' Message , NULL Id
			RETURN;
		END

		

	   SELECT TOP 1 @rowId = rowId,@sendAgent = sendingAgent from GMEPayHistory WHERE refNo = @refNoEnc ORDER by rowId desc

		UPDATE dbo.GMEPayHistory SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = isnull(@pBranch, pBranch)
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber 
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = @rValidDate
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,benefMobile	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks 	  	 = @remarks 
			,rBank			 = @rbankName
			,rBankBranch	 = @rbankBranch
			,rAccountNo		 = @rAccountNo
			,rChequeNo		 = @rcheque
			,relWithSender	 = @relationship
			,purposeOfRemit  = @purpose
			,rIssueDate		 = @rIssuedDate				
		WHERE rowId = @rowId
	
		SELECT '0' errorCode, 'Ready to pay has been recorded successfully.' msg, @sendAgent id
		RETURN
	END

	IF @flag = 'payError'
	BEGIN
		UPDATE dbo.GMEPayHistory SET 
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
			SELECT 'x' FROM dbo.GMEPayHistory WITH(NOLOCK) 
			WHERE recordStatus IN('READYTOPAY', 'PAYERROR', 'PAID') 
				AND rowid = @rowid )
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found!', @rowid
			RETURN
		END
		
		IF @RequestFrom = 'mobile'
			SET @pBranch = (SELECT agentId FROM Vw_GetAgentID WHERE SearchText = 'PayTxnFromMobile')--'394420'  --clearly this is pay from wallet user which is recorded under this payoutBranch..


		IF @RequestFrom = 'mobile' and @customerId IS NULL
		SELECT @customerId = customerId 
		FROM customerMaster (NOLOCK) 
		WHERE username = @user

		IF @customerId IS NULL AND @RequestFrom = 'mobile'
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid customer!', @rowid
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
			,@pBankBranch				VARCHAR(100) = NULL
			,@sAgentSettRate			VARCHAR(100) = NULL
			,@agentType					INT
			,@payoutMethod				VARCHAR(50)
			,@cAmt						MONEY
			,@tAmt						MONEY
			,@ServiceCharge				MONEY
			,@beneIdNo					INT
			,@customerRate				MONEY
			,@payoutCurr				VARCHAR(50)
			,@collCurr					VARCHAR(50)			 		
			,@MapCodeIntBranch			VARCHAR(50) 
			,@companyId					INT = 16
			,@ControlNoModified			VARCHAR(50)
			,@controlNo					VARCHAR(50)
			,@sCountryId				INT
			,@pAgentName				VARCHAR(80)
			,@pCountryId				INT
			,@recordStatus				VARCHAR(30)
			,@agentName					VARCHAR(100)
			,@status					VARCHAR(30)
			,@pAgent					VARCHAR(100)
			--,@pBranchName				VARCHAR(100)
			,@senderIdType				VARCHAR(30)
			,@bankName					VARCHAR(100)
			,@senderIdNo				VARCHAR(15)
			,@rCurrency					VARCHAR(30)

		SELECT
			 @refNo						= rm.refNo
			,@benefName					= rm.benefName
			,@benefMobile				= rm.benefMobile 
			,@benefAddress				= rm.benefAddress
			,@senderName				= rm.senderName
			,@senderAddress 			= rm.senderAddress
			,@senderMobile				= rm.senderMobile 
			,@pCurrency					= rm.pCurrency
			,@pAmount					= rm.pAmount
			,@tAmt						= rm.sAmount
			,@recordStatus				= rm.recordStatus
			,@rIdType					= rm.rIdType
			,@rIdNumber					= rm.rIdNumber
			,@rValidDate				= rm.rValidDate
			,@rIssuedDate				= rm.rIssueDate
			,@rDob						= rm.rDob
			,@rOccupation				= rm.rOccupation
			,@rNativeCountry			= rm.nativeCountry
			,@pBranch					= isnull(@pBranch,rm.pBranch)
			,@rIdPlaceOfIssue			= rm.rIdPlaceOfIssue
			,@relationType				= rm.relationType
			,@relativeName				= rm.relativeName
			,@rbankName					= rm.rBank
			,@rbankBranch				= rm.rBankBranch
			,@rcheque					= rm.rChequeNo
			,@rAccountNo				= rm.rAccountNo
			,@purpose					= rm.purposeOfRemit
			,@relationship				= rm.relWithSender
			,@pCurrCostRate				= rm.rCurrCostRate
			,@sCurrCostRate				= rm.sCurrCostRate
		FROM dbo.GMEPayHistory rm WITH(NOLOCK)
		WHERE rowId = @rowId
		
		SET @ControlNoModified = @refNo
		
		SET  @sCountryId = '118'
		SET  @sCountry = 'South Korea'

		--## Check if controlno exist in remittran. 		
		IF EXISTS( SELECT 'x' FROM remitTran WITH(NOLOCK) WHERE controlNo = @ControlNoModified)
		BEGIN
			DECLARE @msg VARCHAR(100)
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
		
		SELECT  @pSuperAgent = parentId, 
				@pAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		
		SELECT @pSuperAgentName = agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent

	
		--## 1. Find Sending Agent Details
		SELECT @sAgent = sAgent,@sAgentName = sAgentName,@sBranch = sBranch,@sBranchName = sBranchName
				,@sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName
				,@pCountry = pCountry,@pCountryId = pCountryId
		FROM dbo.FNAGetBranchFullDetails(@sendAgent)  --NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
		
		DECLARE @deliveryMethodId INT, @pCommCheck MONEY
		
		--Get collection currency
		SELECT @collCurr = cm.currencyCode FROM dbo.countryCurrency cc (NOLOCK)
		INNER JOIN dbo.CurrencyMaster cm (NOLOCK) ON cm.currencyId = cc.currencyId
		WHERE cc.countryId = @sCountryId

		SET @payoutMethod = 'Cash Payment'
		
		SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) 
		WHERE typeTitle = @payoutMethod AND ISNULL(isDeleted, 'N') = 'N'				

		SELECT @pSuperAgentComm = 0, @pSuperAgentCommCurrency = 'MNT'

		--DECLARE @sCurrCostRate MONEY,@sCurrHoMargin MONEY,@sCurrAgentMargin MONEY,@pCurrCostRate MONEY
		DECLARE @sCurrHoMargin MONEY,@sCurrAgentMargin MONEY,@pCurrHoMargin MONEY,@pCurrAgentMargin MONEY,
				@agentCrossSettRate MONEY, @commCheck MONEY,@koreaAgent VARCHAR(20),@OldCollCurr VARCHAR(20)

		SET @customerRate = dbo.FNAGetCustomerRate(@sCountryId, @sAgent, @sBranch, @collCurr, '142',@pAgent, 'MNT', '1')

		

		SELECT  @koreaAgent=agentId  from vw_GetAgentID WHERE SearchText = 'koreaAgent'

		IF @sAgent= @koreaAgent
		BEGIN
			SET @OldCollCurr = @collCurr
			SET @collCurr = 'MNT'
		END

		SELECT @ServiceCharge = AMOUNT FROM [dbo].FNAGetServiceCharge(@sCountryId,@sSuperAgent,@sAgent,@sBranch
				,@pCountryId,null,@pAgent,@PBranch,@deliveryMethodId,@tAmt,@collCurr)
		
		IF @sAgent= @koreaAgent
		BEGIN
			SET @collCurr = @OldCollCurr 
		END

		SET @cAmt = @tAmt + (ISNULL(@ServiceCharge,0))
		
		DECLARE @tranType CHAR(1) = 'I'
		IF @RequestFrom = 'mobile'
			SET @tranType = 'M'

		BEGIN TRANSACTION
		BEGIN
		
		--## Inserting Data in remittran table 
			INSERT INTO remitTran (	 
			[controlNo],[senderName],[sCountry],[sSuperAgent],[sSuperAgentName],[paymentMethod]	,[cAmt],[pAmt]				
			,[tAmt],[customerRate],[pAgentComm]	,[payoutCurr],[pAgent],[pAgentName]	,[pSuperAgent],[pSuperAgentName]
			,[receiverName]	,[pCountry],[pBranch],[pBranchName]	,[pState],[pDistrict],[pLocation],[pbankName],[purposeofRemit]
			,[pMessage]	,[pBankBranch],[sAgentSettRate]	,[createdDate],[createdDateLocal],[createdBy],[approvedDate]				
			,[approvedDateLocal],[approvedBy],[paidBy],[paidDate]	,[paidDateLocal],[serviceCharge]			
			,sCurrCostRate,pCurrCostRate,agentCrossSettRate,sCurrHoMargin,sCurrAgentMargin							
			--## hardcoded parameters			
			,[tranStatus],[payStatus],[collCurr],[controlNo2],[tranType],[sAgent],[sAgentName],[sBranch],[sBranchName], sRouteId				
					)
			SELECT
			@ControlNoModified,@senderName,@sCountry,@sSuperAgent,@sSuperAgentName,'Cash Payment',@Pamount,@Pamount
			,@Pamount,@customerRate,@pAgentComm,@pCurrency,@pAgent,@pAgentName,@pSuperAgent,@pSuperAgentName 
			,@benefName	,@pCountry,@pBranch,@pBranchName,@pState,@pDistrict,@pLocation,@bankName,@purpose
			,@remarks,@pBankBranch,@SagentsettRate,dbo.FNAGetDateInNepalTZ() ,GETDATE(),@user,dbo.FNAGetDateInNepalTZ()
			,GETDATE(),@user,@user,dbo.FNAGetDateInNepalTZ(),GETDATE(),@ServiceCharge
			,@sCurrCostRate,@pCurrCostRate,@agentCrossSettRate,@sCurrHoMargin,@sCurrAgentMargin
			--## HardCoded Parameters
			,'Paid','Paid',@collCurr,@refNo,@tranType,@sAgent,@sAgentName,@sBranch,@sBranchName, 'GME'
					
				SET @tranId = SCOPE_IDENTITY()

				--## Inserting Data in tranSenders table
				INSERT INTO tranSenders	(
					 tranId
					,firstName
					,country
					,[address]
					,idType
					,idNumber
					,mobile
					,customerId
					)
				SELECT
					 @tranId		
					,@senderName
					,@sCountry	
					,@senderAddress
					,@senderIdType	
					,@senderIdNo
					,@senderMobile
					,@customerId
				
				--## Inserting Data in tranReceivers table
				INSERT INTO tranReceivers (
						tranId
						,customerId
					,firstName
					,country
					,city
					,[address]
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
					,relWithSender
					,purposeOfRemit
					,issuedDate2
					,validDate2
					)		
				SELECT 
						@tranId	
						,@customerId		
					,@benefName
					,@pCountry
					,@benefAddress
					,@benefAddress	
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
					,@relationship
					,@purpose
					,@rIssuedDate
					,@rValidDate

			IF ISNULL(@complianceQuestion, '') <> ''
			BEGIN
				DECLARE @XMLDATA XML;

				SET @XMLDATA = CONVERT(XML, REPLACE(@complianceQuestion,'&','&amp;'), 2) 

				SELECT  answer = p.value('@answer', 'varchar(150)') ,
						qType = p.value('@qType', 'varchar(500)'),
						qId = p.value('@qId', 'varchar(500)')
				INTO #TRANSACTION_COMPLIANCE_QUESTION
				FROM @XMLDATA.nodes('/root/row') AS tmp ( p );
		
				INSERT INTO TBL_TXN_COMPLIANCE_CDDI
				SELECT @tranId, qId, answer
				FROM #TRANSACTION_COMPLIANCE_QUESTION
			END
			
			--## Updating Data in globalBankPayHistory table by paid status
			UPDATE dbo.GMEPayHistory SET 
					recordStatus	 = 'PAID'
				,tranPayProcess  = CASE WHEN @flag = 'Pay' THEN 'REGULAR' ELSE 'RESTORED' END
				,payResponseCode = @payResponseCode
				,payResponseMsg  = @payResponseMsg
				,confirmationNo	 = @payConfirmationNo
				,paidDate		 = GETDATE()
				,paidBy			 = @user			
			WHERE rowId = @rowId

		 	IF @RequestFrom = 'mobile'	
				UPDATE customerMaster set availableBalance =ISNULL(availableBalance,0) + @pAmount WHERE customerId =  @customerId
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SET @msg = CASE WHEN @flag = 'restore' THEN 'Transaction has been restored successfully' ELSE 'Transaction paid successfully' END

		 SET @refNo = dbo.decryptdb(@ControlNoModified)
		 EXEC  FastMoneyPro_Account.dbo.Proc_CashDepositVoucher @controlNo = @refNo ,@refNum= NULL 

		SELECT 0 errorCode, @msg msg, @refNo id,extra= @pAgentComm
		RETURN
	END	

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
END CATCH
GO