USE FASTMONEYPRO_REMIT
GO

ALTER PROC proc_sendIRHNew
	 @flag					VARCHAR(50)
	,@user					VARCHAR(30)
	,@txnPWD				VARCHAR(100)		=	NULL
	,@agentRefId			VARCHAR(20)			=	NULL
	,@senderId				VARCHAR(50)			=	NULL
	,@sfName				VARCHAR(100)		=	NULL
	,@smName				VARCHAR(100)		=	NULL
	,@slName				VARCHAR(100)		=	NULL
	,@slName2				VARCHAR(100)		=	NULL
	,@sIdType				VARCHAR(100)		=	NULL
	,@sIdNo					VARCHAR(50)			=	NULL
	,@sIdValid				DATETIME			=	NULL
	,@sdob					DATETIME			=	NULL
	,@sTel					VARCHar(20)			=	NULL
	,@sMobile				varchar(20)			=	NULL
	,@sNaCountry			VARCHAR(50)			=	NULL
	,@scity					VARCHAR(100)		=	NULL
	,@sPostCode				VARCHAR(50)			=	NULL
	,@sAdd1					VARCHAR(150)		=	NULL
	,@sAdd2					VARCHAR(150)		=	NULL
	,@sEmail				VARCHAR(100)		=	NULL
	,@sgender				VARCHAR(100)		=	NULL
	,@smsSend				CHAR(1)				=	NULL
	,@sCompany				VARCHAR(100)		=	NULL
	,@sDcInfo				VARCHAR(50)			=	NULL
	,@sIpAddress			VARCHAR(50)			=	NULL
	
	,@benId					VARCHAR(50)			=	NULL
	,@rfName				VARCHAR(100)		=	NULL
	,@rmName				VARCHAR(100)		=	NULL
	,@rlName				VARCHAR(100)		=	NULL
	,@rlName2				VARCHAR(100)		=	NULL
	,@rIdType				VARCHAR(100)		=	NULL
	,@rIdNo					VARCHAR(50)			=	NULL
	,@rIdValid				DATETIME			=	NULL
	,@rdob					DATETIME			=	NULL
	,@rTel					VARCHar(20)			=	NULL
	,@rMobile				varchar(20)			=	NULL
	,@rNaCountry			VARCHAR(50)			=	NULL
	,@rcity					VARCHAR(100)		=	NULL
	,@rPostCode				VARCHAR(50)			=	NULL
	,@rAdd1					VARCHAR(150)		=	NULL
	,@rAdd2					VARCHAR(150)		=	NULL
	,@rEmail				VARCHAR(100)		=	NULL
	,@raccountNo			VARCHAR(50)			=	NULL
	,@rgender				VARCHAR(100)		=	NULL
    ,@salaryRange			VARCHAR(150)		=	NULL
	
	,@pCountry				VARCHAR(50)			=	NULL -- pay country
	,@pCountryId			INT					=	NULL -- PAY COUNTRY ID
	,@pSuperAgent			INT					=	NULL  --payout Super Agent
	,@deliveryMethod		VARCHAR(50)			=	NULL -- payment mode
	,@deliveryMethodId		INT					=	NULL -- payment mode ID
	,@pBank					INT					=	NULL
	,@pBankName				VARCHAR(100)		=	NULL
	,@pBankBranch			INT					=	NULL
	,@pBankBranchName		VARCHAR(100)		=	NULL
	
	,@pAgent				INT					=	NULL
	,@pAgentName			VARCHAR(100)		=	NULL
	,@pBranch				INT					=	NULL
	,@pBranchName			VARCHAR(100)		=	NULL
	,@pBankType				CHAR(1)				=	NULL
	
	,@pCurr					VARCHAR(3)			=	NULL
	,@collCurr				VARCHAR(3)			=	NULL
	,@cAmt					MONEY				=	NULL
	,@pAmt					MONEY				=	NULL
	,@tAmt					MONEY				=	NULL
	,@serviceCharge			MONEY				=	NULL
	,@discount				MONEY				=	NULL	
	,@exRate				FLOAT				=	NULL
	,@schemeType			VARCHAR(50)			=	NULL
	,@couponTranNo			VARCHAR(20)			=	NULL
	,@purpose				VARCHAR(150)		=	NULL
	,@sourceOfFund			VARCHAR(150)		=	NULL
	,@relationship			VARCHAR(100)		=	NULL
	,@occupation			VARCHAR(100)		=	NULL
	,@payMsg				VARCHAR(1000)		=	NULL
	,@company				VARCHAR(200)		=	NULL
	,@nCust					CHAR(1)				=	NULL
	,@enrollCust			CHAR(1)				=	NULL
	
	,@controlNo				VARCHAR(20)			=	NULL
	,@agentId				INT					=	NULL  --payout
	,@sCountryId			INT					=	NULL 
	,@sCountry				VARCHAR(100)		=	NULL 
	,@sBranch				INT					=	NULL
	,@sBranchName			VARCHAR(100)		=	NULL
	,@sAgent				INT					=	NULL
	,@sAgentName			VARCHAR(100)		=	NULL
	,@sSuperAgent			INT					=	NULL
	,@sSuperAgentName		VARCHAR(100)		=	NULL
	,@settlingAgent			INT					=	NULL
	,@branchMapCode			VARCHAR(10)			=	NULL
	,@agentMapCode			VARCHAR(10)			=	NULL
	,@collMode				VARCHAR(50)			=	NULL
	,@id					BIGINT				=	NULL	
	,@sessionId				VARCHAR(50)			=	NULL	
	,@cancelrequestId		INT					=	NULL
	,@salary				VARCHAR(10)			=	NULL		
	,@memberCode			VARCHAR(20)			=	NULL	
	,@schemeCode			VARCHAR(20)			=	NULL
	,@cwPwd					VARCHAR(10)			=	NULL
	,@ttName				VARCHAR(200)		=	NULL
	,@ofacRes				VARCHAR(MAX)		=	NULL
	,@ofacReason			VARCHAR(200)		=	NULL
	,@voucherDetails		XML					=	NULL

	,@RBATxnRisk			VARCHAR(15)			=	NULL
	,@RBACustomerRisk		VARCHAR(15)			=	NULL
	,@RBACustomerRiskValue	MONEY				=	NULL

	,@pLocation				BIGINT				=	NULL
	,@pLocationText			VARCHAR(100)		=	NULL
	,@pSubLocation			BIGINT				=	NULL
	,@pSubLocationText		VARCHAR(100)		=	NULL
	,@pTownId				VARCHAR(100)		=	NULL

	,@isManualSc			CHAR(1)				=	NULL
	,@manualSc				MONEY				=	NULL
	,@sCustStreet			VARCHAR(50)			=	NULL
	,@sCustLocation			INT					=	NULL
	,@sCustomerType			INT					=	NULL
	,@sCustBusinessType		INT					=	NULL
	,@sCustIdIssuedCountry	INT					=	NULL
	,@sCustIdIssuedDate		VARCHAR(25)			=	NULL
	,@receiverId			INT					=	NULL
	,@payoutPartner			INT					=	NULL
	,@customerDepositedBank INT					=	NULL
	,@introducer			VARCHAR(100)		=	NULL
	,@isOnbehalf			VARCHAR(1)			=	NULL
	,@payerId				BIGINT				=	NULL
	,@payerBranchId			BIGINT				=	NULL
	,@IsFromTabPage			CHAR(1)				=	NULL
	,@customerPassword		VARCHAR(20)			=	NULL
	,@referralCode			varchar(20)			=   NULL
	,@controlNumber			varchar(30)			=   NULL
	,@complienceMessage			VARCHAR(500)	=	NULL
	,@complienceErrorCode		TINYINT			=	NULL
	,@shortMsg					VARCHAR(100)	=	NULL
	,@isAdditionalCDDI		CHAR(1)				=   NULL
	,@additionalCDDIXml		NVARCHAR(MAX)		=   NULL

AS
SET NOCOUNT ON 
SET XACT_ABORT ON
BEGIN TRY
	DECLARE
		 @sCurrCostRate				FLOAT
		,@sCurrHoMargin				FLOAT
		,@pCurrCostRate				FLOAT
		,@pCurrHoMargin				FLOAT
		,@sCurrAgentMargin			FLOAT
		,@pCurrAgentMargin			FLOAT
		,@sCurrSuperAgentMargin		FLOAT
		,@pCurrSuperAgentMargin		FLOAT
		,@customerRate				FLOAT
		,@receivingCustType		INT
		,@senderName				VARCHAR(100)
		,@controlNoEncrypted VARCHAR(30)
		,@user1 VARCHAR(50)	=	NULL
		,@limitBal				MONEY
		,@holdType VARCHAR(10) =NULL
		,@agentCrossSettRate		FLOAT
		,@treasuryTolerance			FLOAT
		,@customerPremium			FLOAT
		,@schemePremium				FLOAT
		,@sharingValue				MONEY
		,@sharingType				CHAR(1)
		,@customerTotalAmt2			MONEY = 0
		,@iServiceCharge			MONEY
		,@iTAmt						MONEY
		,@iPAmt						MONEY
		,@iScDiscount				MONEY
		,@iCustomerRate				FLOAT
		,@iCollDetailAmt			MONEY
		,@sAgentComm				MONEY
		,@sAgentCommCurrency		VARCHAR(3)
		,@sSuperAgentComm			MONEY
		,@sSuperAgentCommCurrency	VARCHAR(3)
		,@pAgentComm				MONEY
		,@pAgentCommCurrency		VARCHAR(3)
		,@pSuperAgentComm			MONEY
		,@pSuperAgentCommCurrency	VARCHAR(3)
		,@promotionCode				INT
		,@promotionType				INT		
		,@sAgentSettRate			FLOAT
		,@pDateCostRate				FLOAT
		,@userId INT
		,@compFinalRes VARCHAR(20)
		,@complianceRes VARCHAR(20)

IF @flag = 'exRate'
BEGIN
	DECLARE @exRateCalByPartner			BIT
			,@pSuperAgentName			VARCHAR(100)
			,@scValue					MONEY
			,@scAction					CHAR(2)
			,@scOffer					MONEY
			,@exRateOffer				FLOAT
			,@scDiscount				MONEY
			,@place						INT
			,@currDecimal				INT
			,@sendingCustType			INT
			,@msg						VARCHAR(200)
			,@errorCode					CHAR(1) = 0

			--GET PAYOUT PARTNER
			SELECT @payoutPartner = AGENTID, @exRateCalByPartner = ISNULL(exRateCalByPartner, 0)
			FROM TblPartnerwiseCountry(NOLOCK) 
			WHERE CountryId = @pCountryId AND IsActive = 1 
			AND ISNULL(PaymentMethod, @deliveryMethod) = @deliveryMethod
			
			IF @payoutPartner IS NOT NULL
			BEGIN
				--GET PAYOUT AGENT DETAILS
				SELECT @PAGENT = AGENTID FROM AGENTMASTER (NOLOCK) WHERE PARENTID = @payoutPartner AND ISNULL(ISSETTLINGAGENT, 'N') = 'Y';

				SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
						   @pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
				FROM dbo.FNAGetBranchFullDetails(@PAGENT)
			END
			ELSE
			BEGIN
				 SELECT '1' ErrCode, 'Partner not yet mapped for the selected country!' Msg,NULL id
				 RETURN
			END

			DECLARE @rowId INT
			SELECT @scValue = 0, @scOffer = 0, @exRateOffer = 0, @scDiscount = 0
			
			IF @senderId IS NOT NULL
				SELECT @senderId = customerId, @sIdNo = idNumber FROM customerMaster WITH(NOLOCK) WHERE idNumber = @senderId
		
			--2. Find Decimal Mask for payout amount rounding
			SELECT @pCurr = pCurrency FROM dbo.exRateTreasury WITH(NOLOCK) WHERE pCountry = @pCountryId AND pAgent = @pAgent 
			IF @pCurr IS NULL
				SELECT @pCurr = pCurrency FROM dbo.exRateTreasury WITH(NOLOCK) WHERE pCountry = @pCountryId AND pAgent IS NULL
            
			SELECT @place = place, @currDecimal = currDecimal
			FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' 
			AND currency = @pCurr AND ISNULL(tranType,@deliveryMethod) = @deliveryMethod
			
			SET @currDecimal = ISNULL(@currDecimal, 0)
					    
			IF @pCurr IS NULL
			BEGIN
				 SELECT '1' ErrCode, 'Currency not been defined yet for receiving country' Msg,NULL id
				 RETURN
			END
			
			SELECT @exRate = dbo.FNAGetCustomerRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)

			IF ISNULL(@exRate, 0) = 0
			BEGIN
				SELECT '1' ErrCode, 'Exchange rate not defined yet for receiving currency (' + @pCurr + ')' Msg,NULL id
				RETURN
			END

			IF ISNULL(@cAmt, 0.00) <> 0.00
			BEGIN
				IF ISNULL(@isManualSc, 'N') = 'N'
				BEGIN
					SELECT @serviceCharge = amount FROM [dbo].FNAGetServiceCharge(
							@sCountryId, @sSuperAgent, @sAgent, @sBranch 
						   ,@pCountryId, @pSuperAgent, @pAgent, @pBranch 
						   ,@deliveryMethod, @cAmt, @collCurr
						   )
				END
				ELSE
				BEGIN
						SET @serviceCharge = ISNULL(@manualSc, 0)
				END
				IF @serviceCharge IS NULL AND ISNULL(@isManualSc, 'N') = 'N'
				BEGIN
					SELECT '1' ErrCode, 'Service charge not defined yet for receiving country' Msg,NULL id
					RETURN;
				END

				SET @tAmt = @cAmt - @serviceCharge + @scDiscount

				SET @exRate = ROUND(@pAmt / @tAmt, 4)

			END 


		--4. Validate Country Sending Limit 
        EXEC PROC_CHECKCOUNTRYLIMIT @flag = 's-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
			,@deliveryMethod = @deliveryMethod,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT

		IF @errorCode <> '0'
		BEGIN
			SELECT @errorCode ErrCode, @msg Msg
			RETURN;
		END
		--Validate Country Sending Limit END

		--5. Validate Country Receiving Limit
        EXEC PROC_CHECKCOUNTRYLIMIT @flag = 'r-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
			,@deliveryMethod = @deliveryMethod,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT
			
		IF @errorCode <> '0'
		BEGIN
			SELECT @errorCode ErrCode, @msg Msg
			RETURN;
		END
		--Validate Country Receiving Limit

			
		SET @msg = 'Success'
		SELECT 
			@errorCode ErrCode,
			@msg Msg, 
			scCharge = @serviceCharge,
			exRate = @exRate, 
			place = @place,
			pCurr = @pCurr, 
			currDecimal = @currDecimal,
			pAmt =@pAmt, 
			sAmt = @tAmt,
			place=@place,
			disc = 0.00, 
			collAmt = @cAmt,
			exRateOffer = @exRateOffer, 
			scOffer = @scDiscount, 
			scAction = @scAction, 
			scValue = @scValue, 
			scDiscount = @scDiscount
	END

IF @flag IN ('V', 'I')
BEGIN
		SELECT @controlNoEncrypted = DBO.FNAENCRYPTSTRING(@controlNumber)
		IF EXISTS(SELECT * FROM REMITTRAN (NOLOCK) WHERE controlno = @controlNoEncrypted) OR EXISTS(SELECT * FROM REMITTRANTEMP (NOLOCK) WHERE controlno = @controlNoEncrypted)
		BEGIN
			EXEC proc_errorHandler 1, 'Duplicate Transaction! transaction with same Pin No already exists!', NULL
			RETURN
		END

		--CHECKING OF BRANCH/USER CASH HOLD LIMIT
		IF EXISTS(SELECT * FROM AGENTMASTER WHERE AGENTID = @SAGENT AND ISINTL = 1) AND ISNULL(@INTRODUCER, '') <> ''
		BEGIN
			SELECT '1' ErrCode, 'Agent''s and introducer can not be selected at same time!' Msg,NULL id
			RETURN
		END

		--CHECK IF PAYOUT PARTNER IS ACTIVE OR NOT AND CHECK STATUS
		IF @payoutPartner IS NULL
		BEGIN
			SELECT '1' ErrCode, 'Payout partner not defined yet for receiving country!' Msg,NULL id
			RETURN
		END
		IF NOT EXISTS(SELECT 1 FROM TblPartnerwiseCountry (NOLOCK) WHERE AgentId = @payoutPartner AND IsActive = 1)
		BEGIN
			SELECT '1' ErrCode, 'Payout partner is not active please retry by choosing country again!' Msg,NULL id
			RETURN
		END

		SELECT @exRateCalByPartner = ISNULL(exRateCalByPartner, 0)
		FROM TblPartnerwiseCountry(NOLOCK) 
		WHERE CountryId = @pCountryId AND IsActive = 1 
		AND ISNULL(PaymentMethod, @deliveryMethodId) = @deliveryMethodId

		--CHECKING CUSTOMER KYC STATUS
		DECLARE @kycStatus INT
		
		--GET PAYOUT AGENT DETAILS
		SELECT @PAGENT = AGENTID FROM AGENTMASTER (NOLOCK) WHERE PARENTID = @payoutPartner AND ISNULL(ISSETTLINGAGENT, 'N') = 'Y';

		SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
				   @pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
		FROM dbo.FNAGetBranchFullDetails(@PAGENT)
		SELECT @sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName,
				@sAgent = sAgent,@sAgentName = sAgentName ,@sBranch = sBranch,@sBranchName = sBranchName
		FROM dbo.FNAGetBranchFullDetails(@sBranch)
	END
IF @flag = 'v'						--Validation
BEGIN
		DECLARE @AVAILABLEBALANCE MONEY
		

		IF @nCust='N'
		BEGIN
			IF ISNULL(@senderId, 0) = 0
			BEGIN
				EXEC proc_errorHandler 1, 'Please choose Sender', NULL
				RETURN
			END
			
			SELECT @AVAILABLEBALANCE = DBO.FNAGetCustomerAvailableBalance(@senderId)
			
			IF (ISNULL(@AVAILABLEBALANCE, 0) < @CAMT) AND (@collMode = 'Bank Deposit')
			BEGIN
				EXEC proc_errorHandler 1, 'Collect Amount can not be greater then Available Balance!', NULL
				RETURN
			END
		END
		IF @sfName IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Sender First Name missing', NULL
			RETURN
		END
		IF @sNaCountry IS NULL
		BEGIN
			EXEC proc_errorHandler 1, ' Sender Native Country missing', NULL
			RETURN
		END	
		IF @rfName IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'New Receiver First Name missing', NULL
			RETURN
		END
		
		IF ISNULL(@deliveryMethod, '') = ''
		BEGIN
			EXEC proc_errorHandler 1, 'Please choose payment mode', NULL
			RETURN
		END
		IF @serviceCharge IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Service Charge missing', NULL
			RETURN
		END
		IF ISNULL(@tAmt, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Transfer Amount missing', NULL
			RETURN
		END
		IF ISNULL(@exRate, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Exchange Rate missing', NULL
			RETURN
		END
		
		IF ISNULL(@cAmt, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Collection Amount is missing. Cannot send transaction', NULL
			RETURN	
		END 
		IF @serviceCharge > @cAmt
		BEGIN
			EXEC proc_errorHandler 1, 'Collection Amount is less than service charge.', NULL
			RETURN	
		END 


		--*****Payout Agent*****
		IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			IF @pBank IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Please select bank', NULL
				RETURN
			END
			
			IF @raccountNo IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Account number cannot be blank', NULL
				RETURN
			END
		END
		
		IF (@pBankBranch IS NOT NULL)
		BEGIN
			SELECT @pBank = parentId, @pBankBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch
			SELECT @pBankName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBank
		END
		
		SELECT @sendingCustType = customerType FROM dbo.customerMaster WITH(NOLOCK) WHERE customerId = @senderId
		SELECT @receivingCustType = customerType FROM dbo.customerMaster WITH(NOLOCK) WHERE customerId = @benId
		
		--4. Exchange Rate Checking
		--SET @pAgent=1006
		--SET @pSuperAgent=1005
		--SET @pBranch=1007

		SELECT @exRate=customerRate
			,@sCurrCostRate = sCurrCostRate
			,@sCurrHoMargin = sCurrHoMargin
			,@sCurrAgentMargin = sCurrAgentMargin
			,@pCurrCostRate = pCurrCostRate
			,@pCurrHoMargin = pCurrHoMargin
			,@pCurrAgentMargin = pCurrAgentMargin
		FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)
		
		IF @exRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined', NULL
			RETURN
		END
		--End of Exchange Rate Checking
		
		--5. Service Charge Checking
		
		IF ISNULL(@isManualSc, 'N') = 'N'
		BEGIN
			SELECT @iServiceCharge = ISNULL(amount, -1) FROM [dbo].FNAGetServiceCharge(
							@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
							@pCountryId, @pSuperAgent, @pAgent, @pBranch, 
							@deliveryMethodId, @cAmt, @collCurr
						) 
		END
		ELSE
		BEGIN
			SET @serviceCharge = ISNULL(@manualSc, 0)
		END
		
		IF @iServiceCharge = -1 AND ISNULL(@isManualSc, 'N') = 'N'
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Service Charge is not defined', NULL
			RETURN
		END
		
		SET @iServiceCharge = ROUND(@iServiceCharge, 2)
		IF (@iServiceCharge <> @serviceCharge) AND (ISNULL(@isManualSc, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Amount detail not match. Please check service charge', NULL
			RETURN
		END
		
		--send agent commission if it is external agent
		DECLARE @sSettlementRate FLOAT, @pSettlementRate FLOAT
		SET @sSettlementRate = @sCurrCostRate + @sCurrHoMargin
		SET @pSettlementRate = @pCurrCostRate - @pCurrHoMargin

		--START OFAC Checking 
		DECLARE @receiverName VARCHAR(200)
		
		IF(ISNULL(@senderId, '') = '')
			SELECT @senderName = @sfName + ISNULL(' ' + @smName, '') + ISNULL(' ' + @slName, '') + ISNULL(' ' + @slName2, '')
		ELSE
			SELECT @senderName = firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName1, '') + ISNULL(' ' + lastName2, '') 
			FROM dbo.customerMaster WITH(NOLOCK) WHERE customerId = @senderId
		
		SELECT @receiverName = @rfName + ISNULL(' ' + @rmName, '') + ISNULL(' ' + @rlName, '') + ISNULL(' ' + @rlName2, '')

		DECLARE @receiverOfacRes VARCHAR(MAX)
		EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @ofacRes OUTPUT
		EXEC proc_ofacTracker @flag = 't', @name = @receiverName, @Result = @receiverOfacRes OUTPUT
		
		DECLARE @result VARCHAR(MAX)
		IF ISNULL(@ofacRes, '') <> ''
		BEGIN
			SET @ofacReason = 'Matched by sender name'
		END
		IF ISNULL(@receiverOfacRes, '') <> ''
		BEGIN
			SET @ofacRes = ISNULL(@ofacRes + ',' + @receiverOfacRes, '' + @receiverOfacRes)
			SET @ofacReason = 'Matched by receiver name'
		END
		IF ISNULL(@ofacRes, '') <> '' AND ISNULL(@receiverOfacRes, '') <> ''
		BEGIN
			SET @ofacReason = 'Matched by both sender name and receiver name'
		END
		
		--******************BEGINING OF NEW CUSTOMER CREATION AND ENROLLMENT********************************
		DECLARE @sIdTypeId INT
		SELECT @sIdTypeId = valueId from staticDataValue WITH(NOLOCK) WHERE detailTitle = @sIdType AND typeID = 1300
		
		SELECT @sfName = UPPER(@sfName), @smName = UPPER(@smName), @slName = UPPER(@slName), @slName2 = UPPER(@slName2)
		SELECT @rfName = UPPER(@rfName), @rmName = UPPER(@rmName), @rlName = UPPER(@rlName), @rlName2 = UPPER(@rlName2)
		--2. Begining of New customer Creation and enrollment or updating existing customer data---
		SET @senderName = @sfName + ISNULL(' ' + @smName, '') + ISNULL(' ' + @slName, '') + ISNULL(' ' + @slName2, '')
		SET @receiverName = @rfName + ISNULL(' ' + @rmName, '') + ISNULL(' ' + @rlName, '') + ISNULL(' ' + @rlName2, '')
	
		DECLARE @sNaCountryId INT = (SELECT countryId FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYNAME = @sNaCountry)

		--------#Register Customer if not registered#---------------
		IF ISNULL(@senderId, 0) = 0
		BEGIN
			EXEC PROC_CHECK_CUSTOMER_REGISTRATION @flag = 'i', @customerName = @senderName, @customerIdNo = @sIdNo, @customerIdType = @sIdTypeId, 
				@nativeCountryId = @sNaCountryId, @customerId = @senderId OUT, @user = @user, @custAdd = @sAdd1, @custCity = @scity, @custEmail = @sEmail,
				@custMobile = @sMobile, @custDOB = @sdob, @custIdValidDate = @sIdValid, @occupation = @occupation, @ipAddress = @sIpAddress,
				@sCustStreet = @sCustStreet, @sCustLocation = @sCustLocation, @sCustomerType = @sCustomerType, @sCustBusinessType = @sCustBusinessType,
				@sCustIdIssuedCountry = @sCustIdIssuedCountry, @sCustIdIssuedDate = @sCustIdIssuedDate, @sfName = @sfName, @smName = @smName, @slName = @slName,
				@zipCode = @sPostCode
		END
		
		IF @senderId = '0000'
		BEGIN
			EXEC proc_errorHandler 1, 'Sender Email can not be blank.', NULL
			RETURN
		END

		--------#Register Receiver if not registered#---------------
		DECLARE @rBankId INT = ISNULL(@pBank, @pAgent)
		DECLARE @rBankBranchId INT = ISNULL(@pBankBranch, '')
		EXEC PROC_CHECK_RECEIVER_REGISTRATION @flag = 'i', @user=@user, @rfName=@rfName, @rmName=@rmName, @rlName=@rlName, @receiverIdNo=@rIdNo,
			@receiverIdType=@rIdType, @receiverCountry=@pCountry, @receiverAdd=@rAdd1, @receiverCity=@rcity, @receiverMobile=@rMobile,
			@receiverPhone = @rTel, @receiverEmail = @rEmail, @receiverId = @receiverId OUT, @customerId = @senderId, @paymentMethodId=@deliveryMethodId,
			@rBankId= @rBankId,@rBankBranchId = @rBankBranchId, @rAccountNo=@raccountNo,@purpose=@purpose,@relationship = @relationship

		--START Compliance Checking
		DECLARE @complianceRuleId INT, @cAmtUSD MONEY
  
		SELECT 
			@sCurrCostRate			= sCurrCostRate
			,@sCurrHoMargin			= sCurrHoMargin
		FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethodId)
		
		IF @sCurrCostRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined!', NULL
			RETURN
		END

		SET @sCountry = 'Japan'

		IF ISNULL(@isAdditionalCDDI, 'N') = 'N'
		BEGIN
			CREATE TABLE #TBL_COMPLIANCE_RESULT (ERROR_CODE INT, MSG VARCHAR(500), RULE_ID INT, SHORT_MSG VARCHAR(100), [TYPE] VARCHAR(10))

			INSERT INTO #TBL_COMPLIANCE_RESULT (ERROR_CODE, MSG, RULE_ID, SHORT_MSG, [TYPE])
			EXEC [PROC_COMPLIANCE_CHECKING_NEW]
				@flag = 'core'
				,@user			 = @user
				,@sIdType		 = @sIdType
				,@sIdNo			 = @sIdNo
				,@receiverName   = @receiverName
				,@amount		 = @tAmt
				,@customerId	 = @senderId
				,@pCountryId	 = @pCountryId
				,@deliveryMethod = @deliveryMethodId
				,@professionId   = @occupation
				,@receiverMobile = @rMobile
				,@accountNo		 = @raccountNo
				,@receiverId	 = @receiverId


			IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RESULT WHERE ERROR_CODE <> 0)
			BEGIN		
				--IF(@complienceErrorCode = 1)
				--BEGIN
				--	SELECT 101 errorCode,@shortMsg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
				--END 
				IF EXISTS(SELECT * FROM #TBL_COMPLIANCE_RESULT WHERE ERROR_CODE IN (2, 3))
				BEGIN
					DELETE FROM remitTranComplianceTemp where agentRefId = @agentRefId

					INSERT remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId)
					SELECT TOP 1 RULE_ID, NULL, @agentRefId
					FROM #TBL_COMPLIANCE_RESULT 
					WHERE ERROR_CODE IN (2, 3)

					--SELECT 102 errorCode,@shortMsg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
				END
				--IF(@complienceErrorCode = 3)
				--BEGIN
				--	SELECT 103 errorCode,@shortMsg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
				--END
				DELETE FROM ComplianceLog where agentRefId = @agentRefId

				INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName, receiverCountry, payOutAmt,
				complianceId, complianceReason, complainceDetailMessage, createdBy, createdDate, agentRefId)

				SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName, @pCountry, @cAmt, RULE_ID, SHORT_MSG, MSG, @user, GETDATE(), @agentRefId
				FROM #TBL_COMPLIANCE_RESULT
			END 
			--END OFAC/Compliance data
		END

		IF(@ofacRes <> '')
		BEGIN
			SET @result = @ofacRes + '|' + ISNULL(@ofacReason, '')
			SELECT errorCode = 100, msg = 'WARNING!!! This customer is listed on OFAC List', id = @result
			EXEC proc_sendPageLoadData @flag = 'ofac', @user = @user, @blackListIds = @ofacRes
		END

		SELECT * INTO #TEMP_COMPLIANCE 
		FROM ComplianceLog (NOLOCK) 
		WHERE agentRefId = @agentRefId 
		AND CAST(CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)

			DECLARE @IS_TXN_IN_COMPLIANCE BIT = 0
		IF EXISTS(SELECT 1 FROM #TEMP_COMPLIANCE)
		BEGIN
			IF EXISTS(SELECT 1 FROM #TEMP_COMPLIANCE CL
						INNER JOIN csDetail CD(NOLOCK) ON CD.csDetailId = CL.complianceId
						WHERE agentRefId = @agentRefId AND CAST(cl.CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)
						AND nextAction = 'B')
			BEGIN
				SET @IS_TXN_IN_COMPLIANCE = 1

				SELECT
					errorCode = 101,
					MSG = 'COMPLIANCE BLOCK',
					id		= 1,
					compApproveRemark	= 'COMPLIANCE BLOCK',
					vtype	= 'compliance'

				SELECT TOP 1
						id
					,csDetailRecId = ''
					,[S.N.]		= ROW_NUMBER() OVER(ORDER BY id)	
					,[Remarks]	= complianceReason
					,[Action]	= CASE WHEN nextAction = 'H' THEN 'HOLD' WHEN nextAction = 'B' THEN 'Blocked' ELSE 'Questionnaire' END
					--,[Matched Tran ID] = ''
				FROM #TEMP_COMPLIANCE CL
				INNER JOIN csDetail CD(NOLOCK) ON CD.csDetailId = CL.complianceId
				WHERE agentRefId = @agentRefId AND CAST(cl.CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)
				AND nextAction = 'B'
				ORDER BY CD.period
			END
			IF @IS_TXN_IN_COMPLIANCE = 0 AND EXISTS(SELECT 1 FROM #TEMP_COMPLIANCE CL
						INNER JOIN csDetail CD(NOLOCK) ON CD.csDetailId = CL.complianceId
						WHERE agentRefId = @agentRefId AND CAST(cl.CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)
						AND nextAction = 'Q') 
			BEGIN
				SET @IS_TXN_IN_COMPLIANCE = 1

				SELECT
					errorCode = 103,
					MSG = 'COMPLIANCE HOLD',
					id		= 1,
					compApproveRemark	= 'COMPLIANCE HOLD',
					vtype	= 'compliance'

				SELECT TOP 1
						id
					,csDetailRecId = ''
					,[S.N.]		= ROW_NUMBER() OVER(ORDER BY id)	
					,[Remarks]	= complianceReason
					,[Action]	= CASE WHEN nextAction = 'H' THEN 'HOLD' WHEN nextAction = 'B' THEN 'Blocked' ELSE 'Questionnaire' END
					--,[Matched Tran ID] = ''
				FROM #TEMP_COMPLIANCE CL
				INNER JOIN csDetail CD(NOLOCK) ON CD.csDetailId = CL.complianceId
				WHERE agentRefId = @agentRefId AND CAST(cl.CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)
				AND nextAction = 'Q'
				ORDER BY CD.period
			END
			IF @IS_TXN_IN_COMPLIANCE = 0 AND EXISTS(SELECT 1 FROM #TEMP_COMPLIANCE CL
						INNER JOIN csDetail CD(NOLOCK) ON CD.csDetailId = CL.complianceId
						WHERE agentRefId = @agentRefId AND CAST(cl.CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)
						AND nextAction = 'H')
			BEGIN
				SELECT
					errorCode = 102,
					MSG = 'COMPLIANCE QUESTIONNAIRE',
					id		= 1,
					compApproveRemark	= 'COMPLIANCE QUESTIONAIRE',
					vtype	= 'compliance'

				SELECT TOP 1
						id
					,csDetailRecId = ''
					,[S.N.]		= ROW_NUMBER() OVER(ORDER BY id)	
					,[Remarks]	= complianceReason
					,[Action]	= CASE WHEN nextAction = 'H' THEN 'HOLD' WHEN nextAction = 'B' THEN 'Blocked' ELSE 'Questionnaire' END
					--,[Matched Tran ID] = ''
				FROM #TEMP_COMPLIANCE CL
				INNER JOIN csDetail CD(NOLOCK) ON CD.csDetailId = CL.complianceId
				WHERE agentRefId = @agentRefId AND CAST(cl.CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)
				AND nextAction = 'H'
				ORDER BY CD.period
			END
		END
		

		SELECT 0 errorCode, 'Validation successful' msg, @senderId id, @receiverId Extra
		
		--*****Check For Same Name*****
		SELECT tranId = rt.id, senderName, sIdType = sen.idType, sIdNo = sen.idNumber, cAmt, pCountry 
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId 
		WHERE senderName = @senderName AND createdDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'
		
		--*****Check For Same Id*****
		SELECT tranId = rt.id, senderName, sIdType = sen.idType, sIdNo = sen.idNumber, cAmt, pCountry 
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId 
		WHERE idType = @sIdType AND idNumber = @sIdNo AND createdDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'
		
END
ELSE IF @flag = 'i'					--Send Transaction
	BEGIN
		--1. Field Validation-----------------------------------------------------------
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Cannot send transaction', NULL
			RETURN
		END

		IF ISNULL(@IsFromTabPage,'0')!='1'
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE PWD = DBO.FNAEncryptString(@txnPWD) AND userName = @user)
			BEGIN
				EXEC proc_errorHandler 1, 'TXN password is invalid !', @user
				RETURN
			END
		END
		
		IF (ISNULL(@deliveryMethod, '') = ''
			OR @serviceCharge IS NULL
			OR ISNULL(@cAmt, 0) = 0
			OR ISNULL(@tAmt,0) = 0
			OR ISNULL(@exRate, 0) = 0)
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field(s) missing', NULL
			RETURN
		END

		--******************BEGINING OF NEW CUSTOMER CREATION AND ENROLLMENT********************************
		SELECT @sIdTypeId = valueId from staticDataValue WITH(NOLOCK) WHERE detailTitle = @sIdType AND typeID = 1300
		
		SELECT @sfName = UPPER(@sfName), @smName = UPPER(@smName), @slName = UPPER(@slName), @slName2 = UPPER(@slName2)
		SELECT @rfName = UPPER(@rfName), @rmName = UPPER(@rmName), @rlName = UPPER(@rlName), @rlName2 = UPPER(@rlName2)
		--2. Begining of New customer Creation and enrollment or updating existing customer data---
		SET @senderName = @sfName + ISNULL(' ' + @smName, '') + ISNULL(' ' + @slName, '') + ISNULL(' ' + @slName2, '')
		SET @receiverName = @rfName + ISNULL(' ' + @rmName, '') + ISNULL(' ' + @rlName, '') + ISNULL(' ' + @rlName2, '')

		
		SET @sNaCountryId = (SELECT countryId FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYNAME = @sNaCountry)

		--------#Register Customer if not registered#---------------
		EXEC PROC_CHECK_CUSTOMER_REGISTRATION @flag = 'i', @customerName = @senderName, @customerIdNo = @sIdNo, @customerIdType = @sIdTypeId, 
			@nativeCountryId = @sNaCountryId, @customerId = @senderId OUT, @user = @user, @custAdd = @sAdd1, @custCity = @scity, @custEmail = @sEmail,
			@custMobile = @sMobile, @custDOB = @sdob, @custIdValidDate = @sIdValid, @occupation = @occupation, @ipAddress = @sIpAddress

		IF @senderId = '0000'
		BEGIN
			EXEC proc_errorHandler 1, 'Sender Email can not be blank.', NULL
			RETURN
		END

		SET @nCust = 'Y'

		IF @nCust = 'N' AND @senderId IS NULL 
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field(s) missing', NULL
			RETURN
		END	
	
		IF @nCust = 'N' AND @collMode = 'Bank Deposit'
		BEGIN
			SELECT @AVAILABLEBALANCE = DBO.FNAGetCustomerAvailableBalance(@senderId)

			IF (ISNULL(@AVAILABLEBALANCE, 0) < @CAMT) 
			BEGIN
				EXEC proc_errorHandler 1, 'Collect Amount can not be greater then Available Balance!', NULL
				RETURN
			END
		END

		IF ISNULL(@cAmt, 0) = 0
		BEGIN
			EXEC proc_errorHandler 1, 'Collection Amount is missing', NULL
			RETURN	
		END 
		
		IF @serviceCharge > @cAmt
		BEGIN
			EXEC proc_errorHandler 1, 'Collection Amount is less than service charge.', NULL
			RETURN	
		END 
		
		IF ISNULL(@controlNumber, '') = ''
		BEGIN
			EXEC proc_errorHandler 1, 'Control number can not be blank!', NULL
			RETURN
		END
		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNumber)
		
		IF @deliveryMethod IN ('Cash Payment', 'Door to Door')
		BEGIN
			IF @deliveryMethod = 'Door to Door'
			BEGIN
				SET @payMsg = ' [Door To Door Location:' + @pBankBranchName + ', ' + @pBankBranchName + ' ]'
			END
		END
		ELSE IF @deliveryMethod = 'Bank Deposit'
		BEGIN
			IF @pBank IS NULL 
			BEGIN
				EXEC proc_errorHandler 1, 'Bank is required for Bank Deposit ', NULL
				RETURN
			END
		END
		
		--3. Check Limit starts
		SELECT @settlingAgent = agentId FROM dbo.agentMaster (NOLOCK) WHERE agentId = @sBranch AND ISNULL(isSettlingAgent, 'N') = 'Y'

		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM dbo.agentMaster (NOLOCK) WHERE agentId = @sAgent AND ISNULL(isSettlingAgent, 'N') = 'Y'


		SET @sCountryId = 113

		--Get Service Charge----------------------------------------------------------------------------------------------------------------------
		DECLARE @originalSC MONEY = 0
		IF ISNULL(@isManualSc, 'N') = 'N'
		BEGIN
			SELECT @iServiceCharge = ISNULL(amount, -1) FROM [dbo].FNAGetServiceCharge(
							@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
							@pCountryId, @pSuperAgent, @pAgent, @pBranch, 
							@deliveryMethodId, @cAmt, @collCurr
						) 
			SET @originalSC = @iServiceCharge
		END
		ELSE
		BEGIN
			SET @serviceCharge = ISNULL(@manualSc, 0)
			SELECT @originalSC = ISNULL(amount, -1) FROM [dbo].FNAGetServiceCharge(
							@sCountryId, @sSuperAgent, @sAgent, @sBranch, 
							@pCountryId, @pSuperAgent, @pAgent, @pBranch, 
							@deliveryMethodId, @cAmt, @collCurr
						) 
		END
		
		IF @iServiceCharge = -1 AND ISNULL(@isManualSc, 'N') = 'N'
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Service Charge is not defined', NULL
			RETURN
		END
		
		--Earthquake relief fund
		DECLARE @scDisc MONEY
		
		IF @iServiceCharge <> @serviceCharge AND ISNULL(@isManualSc, 'N') = 'N'
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Amount detail not match. Service Charge is different.', NULL
			RETURN
		END
		--End-------------------------------------------------------------------------------------------------------------------------------------
		
		SELECT 
			@customerRate			= @exRate
			,@sCurrCostRate			= NULL
			,@sCurrHoMargin			= NULL
			,@sCurrAgentMargin		= NULL
			,@pCurrCostRate			= NULL
			,@pCurrHoMargin			= NULL
			,@pCurrAgentMargin		= NULL
			,@agentCrossSettRate	= NULL
			,@treasuryTolerance		= NULL
			,@customerPremium		= NULL
			,@sharingValue			= NULL
			,@sharingType			= NULL
		FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)

		IF @customerRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined', NULL
			RETURN
		END
		
		
		--6. Commission Calculation Start
		
		--**********Customer Per Day Limit Checking**********
		DECLARE @remitTranTemp TABLE(tranId BIGINT, controlNo VARCHAR(20), cAmt MONEY, receiverName VARCHAR(200), receiverIdType VARCHAR(100), receiverIdNumber VARCHAR(50), dot DATETIME)
		DECLARE @moneySendTemp TABLE(tranNo BIGINT, refno VARCHAR(20), paidAmt MONEY, receiverName VARCHAR(200), receiverIdDescription VARCHAR(100), receiverIdDetail VARCHAR(50), dot DATETIME)
		
		INSERT INTO @remitTranTemp(tranId, controlNo, cAmt, receiverName, receiverIdType, receiverIdNumber, dot)
		SELECT rt.id, rt.controlNo, rt.cAmt, rt.receiverName, rec.idType, rec.idNumber, rt.createdDateLocal
		FROM vwRemitTran rt WITH(NOLOCK)
		INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		WHERE sen.idNumber = @sIdNo 
		AND (tranStatus <> 'CancelRequest' AND tranStatus <> 'Cancel')
		AND (rt.approvedDate BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59'
		OR (approvedBy IS NULL AND cancelApprovedBy IS NULL))
		
		IF EXISTS(SELECT 'X' FROM @remitTranTemp WHERE cAmt = @cAmt 
					AND (receiverName = @receiverName OR (ISNULL(receiverIdType, '0') = @rIdType AND ISNULL(receiverIdNumber, '0') = @rIdNo))
					AND DATEDIFF(MI, dot, GETDATE()) <= 5
				)
		BEGIN
			EXEC proc_errorHandler 1, 'Similar transaction found. You can process similar transaction after 5 minutes.', NULL
			RETURN
		END
	
		DECLARE @customerTotalSentAmt MONEY = 0, @txnSumTobeDeducted MONEY = 0
		
		SELECT @customerTotalSentAmt = SUM(cAmt) FROM @remitTranTemp
		SELECT @customerTotalAmt2 = SUM(paidAmt) FROM @moneySendTemp
		SELECT @txnSumTobeDeducted = ISNULL(SUM(paidAmt), 0)
		FROM @moneySendTemp mst
		INNER JOIN @remitTranTemp rtt ON mst.refno = rtt.controlNo
		
		IF (ISNULL(@customerTotalAmt2, 0) + ISNULL(@customerTotalSentAmt, 0) + @cAmt - @txnSumTobeDeducted) > dbo.FNAGetPerDayCustomerLimit(@settlingAgent)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Customer Limit exceeded.', NULL
			RETURN
		END
			
		-- #########country and occupation  risk point
		DECLARE @countryRisk INT,@OccupationRisk INT,@isFirstTran CHAR(1)
		
		SET @isFirstTran = CASE WHEN @nCust='Y' THEN 'Y' END
		
		SELECT @sNaCountry = CASE WHEN @nCust='Y' THEN @sNaCountry ELSE nativeCountry END
		FROM tranSenders WITH(NOLOCK) WHERE customerId = @senderId
		
		IF NOT EXISTS(SELECT 'Z' FROM tranSenders WITH(NOLOCK) WHERE customerId = @senderId)
			SET @isFirstTran ='Y'
			
	    SELECT @countryRisk = ISNULL(fatfRating, 0) FROM countryMaster C WITH(NOLOCK) WHERE countryName = @sNaCountry AND ISNULL(C.isActive,'Y') = 'Y' AND ISNULL(C.isDeleted,'N') = 'Y'
	    SELECT @OccupationRisk = ISNULL(riskFactor,0) FROM occupationMaster WITH(NOLOCK) WHERE occupationId = @occupation AND ISNULL(isActive,'Y')='Y' AND ISNULL(isDeleted,'N')='Y'
		
		--RBA 
		DECLARE @RBAScoreTxn MONEY, @RBAScoreCustomer MONEY
		SELECT
			 @RBAScoreCustomer	= @RBACustomerRiskValue
			,@RBAScoreTxn		= CASE WHEN @RBATxnRisk = 'LOW RISK' THEN 40
									WHEN @RBATxnRisk  = 'MEDIUM RISK' THEN 50 
									WHEN @RBATxnRisk  = 'HIGH RISK' THEN 51 
									ELSE 100 END
		
		IF @deliveryMethod = 'BANK DEPOSIT'  
		BEGIN 
			IF NOT EXISTS(SELECT 'A' FROM API_BANK_LIST(nolock) where BANK_ID = @pBank AND IS_ACTIVE = 1)
			begin
				EXEC proc_errorHandler 1, 'Invalid bank selected', NULL
				return
			end
		END 
		--##Get Voucher Details into temp table END##--	

		SELECT @pAgentCommCurrency = DBO.FNAGetPayCommCurrency(@sSuperAgent,@sAgent,@sBranch,@SCOUNTRYID,@pSuperAgent,@pBranch,@pCountryId)

		SELECT @pAgentComm = amount FROM dbo.FNAGetPayComm(@sAgent,@sCountryId, 
								NULL, null, @pCountryId, null, @pAgent, @pAgentCommCurrency
								,@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, NULL, NULL)
		
		SET @sSettlementRate = @sCurrCostRate + @sCurrHoMargin
		SET @pSettlementRate = @pCurrCostRate - @pCurrHoMargin

		SELECT @sAgentComm = 0, @sSuperAgentComm = 0, @sSuperAgentCommCurrency = @sAgentCommCurrency
		
		DECLARE @agentFxGain MONEY = 0
		IF @pCountry NOT IN ('VIETNAM') --CORRIDOR FX GAIN/LOSS IS NOT CALCULATED TXN WISE FOR VIETNAM
		BEGIN
			SET @agentFxGain = @tAmt - ROUND((@pAmt / @pCurrCostRate), 4)
		END


		BEGIN TRANSACTION
			INSERT INTO remitTranTemp(
				 controlNo
				,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin
				,pCurrCostRate,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin
				,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate
				,treasuryTolerance,customerPremium,schemePremium,sharingValue
				--,sharingType
				,serviceCharge,handlingFee, agentFxGain
				,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency
				,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency
				,promotionCode,promotionType
				,pMessage
				,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,sCountry
				,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName,pCountry
				,paymentMethod
				,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,pBankType
				,expectedPayoutAgent
				,collMode,collCurr,tAmt,cAmt,pAmt,payoutCurr
				,relWithSender,purposeOfRemit,sourceOfFund
				,tranStatus,payStatus
				,createdDate,createdDateLocal,createdBy	
				,tranType,voucherNo	
				,senderName
				,receiverName	
				,pState
				,pDistrict
				,pLocation
				--NEW
				,isScMaunal
				,originalSC
				,externalBankCode
				,isOnBehalf
				,PayerId
				,PayerBranchId
				,sRouteId
			)				
					
			SELECT
				 @controlNoEncrypted
				,@sCurrCostRate,@sCurrHoMargin,@sCurrSuperAgentMargin,@sCurrAgentMargin
				,@pCurrCostRate,@pCurrHoMargin,@pCurrSuperAgentMargin,@pCurrAgentMargin
				,@agentCrossSettRate,@customerRate,@sAgentSettRate,@pDateCostRate
				,@treasuryTolerance,@customerPremium,ISNULL(@schemePremium,0),@sharingValue
				--,@sharingType
				,@serviceCharge,ISNULL(@scDiscount,0), @agentFxGain
				,@sAgentComm,@sAgentCommCurrency,@sSuperAgentComm,@sSuperAgentCommCurrency
				,@pAgentComm,@pAgentCommCurrency,@pSuperAgentComm,@pSuperAgentCommCurrency
				,@introducer,@promotionType													--@promotionCode REPLACED BY ARJUN
				,@payMsg
				,@sSuperAgent,@sSuperAgentName,@sAgent,@sAgentName,@sBranch,@sBranchName,@sCountry
				,@pSuperAgent,@pSuperAgentName,@pAgent,@pAgentName,@pBranch,@pBranchName,@pCountry
				,@deliveryMethod
				,@pBank,@pBankName,@pBankBranch,@pBankBranchName,@raccountNo,@pBankType
				,@pAgentName
				,@collMode,@collCurr,@tAmt,@cAmt,@pAmt,@pCurr
				,@relationship,@purpose,@sourceOfFund
				,'Hold','Unpaid'
				,DBO.FNADateFormatTZ(GETDATE(), @user),GETDATE(),@user
				,'I',''
				,@senderName
				,@receiverName
				,@pLocation, @pSubLocation,@pTownId
				,CASE WHEN ISNULL(@isManualSc, 'N') = 'Y' THEN 1 ELSE 0 END 
				,@originalSC
				,@customerDepositedBank
				,CASE @isOnbehalf WHEN 'Y' THEN 1 ELSE 0 END
				,@payerId
				,@payerBranchId
				,CASE @IsFromTabPage WHEN '1' THEN '1' ELSE '0' END
				
			SET @id = SCOPE_IDENTITY()	
			
			INSERT INTO controlNoList(controlNo)
			SELECT @controlNumber
			
			INSERT INTO tranSendersTemp(
				 tranId,customerId,membershipId
				,firstName,middleName,lastName1,lastName2
				,fullName
				,country,[address],address2,zipCode,city,email
				,homePhone,mobile,nativeCountry
				,dob,placeOfIssue,idType,idNumber,validDate
				,occupation
				,countryRiskPoint,customerRiskPoint
				,isFirstTran
				,salary,companyName
				,cwPwd,ttName
				,dcInfo,ipAddress,RBA
				--NEW
				,STATE
				,district--USE FOR STREET
				,customerType
				--,ttName--USE FOR BUSINESS TYPE
				,idPlaceOfIssue
			)
			SELECT 
					 @id,@senderId,@memberCode,@sfName,@smName,@slName,@slName2
					,@senderName,@sCountry
					,@sAdd1,@sAdd2,@sPostCode,@scity,@sEmail,@sTel,@sMobile,@sNaCountry,@sdob
					,@sIdTypeId,@sIdType,@sIdNo,@sIdValid,@occupation,@countryRisk,@RBAScoreCustomer
					,@isFirstTran,@salaryRange
					,@company,@cwPwd,@ttName,@sDcInfo,@sIpAddress, @RBAScoreTxn
					,@sCustLocation
					,@sCustStreet
					,@sCustomerType
					--,@sCustBusinessType
					,@sCustIdIssuedCountry

			
			INSERT INTO tranReceiversTemp(
				 tranId,customerId,membershipId
				,firstName,middleName,lastName1,lastName2
				,fullName
				,country,[address],zipCode,city,email
				,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue
				,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,gender
				,STATE,district,accountNo
			)
			SELECT
				 @id,@receiverId,''
				,@rfName,@rmName,@rlName,@rlName2
				,@receiverName
				,@pCountry,@rAdd1,@rPostCode,@rcity,@rEmail
				,@rTel,@rTel,@rMobile,@rNaCountry,@rdob,NULL
				,@rIdType,@rIdNo,NULL,NULL,@rIdValid,@rgender
				,@pLocationText, @pSubLocationText,@raccountNo		
			
			EXEC PROC_CUSTOMERMODIFYLOG 
					@flag						=	'i-fromSendPage',
					@user						=	@user,
                    @customerId					=	@senderId,
					@mobileNumber				=	@sMobile,
					@monthlyIncome				=	@salaryRange,
					@email						=	@sEmail,
					@placeofissue				=   @sCustIdIssuedCountry,
					@occupation					=	@occupation

			UPDATE CUSTOMERMASTER set	mobile = ISNULL(@sMobile,mobile)
							,monthlyincome=ISNULL(@salaryRange,monthlyincome)
							,email =ISNULL(@sEmail,email)
							,placeofissue=ISNULL(@sCustIdIssuedCountry,placeofissue)
							,occupation=ISNULL(@occupation,occupation)
			WHERE CUSTOMERID = @senderId

			UPDATE RECEIVERINFORMATION SET address = ISNULL(@rAdd1, address), mobile = ISNULL(@rMobile, mobile)
			WHERE receiverId = @receiverId

			DECLARE @PARTICULARS VARCHAR(200) = 'Send TXN: '+@controlNumber
			
			EXEC proc_customerTxnHistory @controlNo = @controlNoEncrypted

			DECLARE @XMLDATA XML;
			IF ISNULL(@isAdditionalCDDI, 'N') = 'Y'
			BEGIN
				SET @XMLDATA = CONVERT(XML, REPLACE(@additionalCDDIXml,'&','&amp;'), 2) 

				SELECT  ID = p.value('@id', 'varchar(150)') ,
						ANSWER = p.value('@answer', 'varchar(30)') 
				INTO #TRANSACTION_COMPLIANCE_CDDI
				FROM @XMLDATA.nodes('/root/row') AS tmp ( p );

				INSERT INTO TBL_TXN_COMPLIANCE_CDDI
				SELECT @id, ID, ANSWER
				FROM #TRANSACTION_COMPLIANCE_CDDI
			END
			----UPDATE BRANCH/AGENT CREDIT LIMIT
			--EXEC Proc_AgentBalanceUpdate_INT @flag = 's',@tAmt = @cAmt ,@settlingAgent = @settlingAgent				

		--10. Compliance----------------------------------------------------------------------------------------------------
		IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId)
		BEGIN
			INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
			SELECT @id, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @agentRefId
			SET @compFinalRes = 'C'

			UPDATE ComplianceLog SET tranId = @id WHERE agentRefId = @agentRefId
		END
		
		IF EXISTS(SELECT 'X' FROM @remitTranTemp 
		WHERE dot BETWEEN CONVERT(VARCHAR, GETDATE(), 101) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59' 
		AND cAmt = @cAmt AND (receiverName = @receiverName OR (ISNULL(receiverIdType, '0') = @rIdType 
		AND ISNULL(receiverIdNumber, '0') = @rIdNo)))
		BEGIN
			INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId, reason)
			SELECT @id, 0, tranid, 'Suspected duplicate transaction' FROM @remitTranTemp WHERE cAmt = @cAmt AND (receiverName = @receiverName OR (ISNULL(receiverIdType, '0') = @rIdType AND ISNULL(receiverIdNumber, '0') = @rIdNo))
			SET @compFinalRes = 'C'
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 'X' FROM @moneySendTemp WHERE paidAmt = @cAmt AND (receiverName = @receiverName OR (ISNULL(receiverIdDescription, '0') = @rIdType AND ISNULL(receiverIdDetail, '0') = @rIdNo)))
			BEGIN
				INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId, reason)
				SELECT @id, 0, tranNo, 'Suspected duplicate transaction from Inficare system' FROM @moneySendTemp WHERE paidAmt = @cAmt AND (receiverName = @receiverName OR (ISNULL(receiverIdDescription, '0') = @rIdType AND ISNULL(receiverIdDetail, '0') = @rIdNo))
				SET @compFinalRes = 'C'
			END
		END
		
		IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '')
		BEGIN
			IF(@ofacRes <> '' AND ISNULL(@compFinalRes, '') = '')
			BEGIN
				INSERT remitTranOfac(TranId, blackListId, reason, flag)
				SELECT @id, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
				
				UPDATE remitTranTemp SET
					 tranStatus	= 'OFAC Hold'
				WHERE controlNo = @controlNoEncrypted
			END
			
			ELSE IF(@compFinalRes <> '' AND ISNULL(@ofacRes, '') = '')
			BEGIN
				UPDATE remitTranTemp SET
					 tranStatus	= 'Compliance Hold'
				WHERE controlNo = @controlNoEncrypted
			END
			
			ELSE IF(ISNULL(@compFinalRes, '') <> '' AND ISNULL(@ofacRes, '') <> '')
			BEGIN
				INSERT remitTranOfac(TranId, blackListId, reason, flag)
				SELECT @id, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
				
				UPDATE remitTranTemp SET
					 tranStatus	= 'OFAC/Compliance Hold'
				WHERE controlNo = @controlNoEncrypted
			END
		END

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		IF(@complianceRes = 'C' OR @ofacRes <> '')
		BEGIN
			SELECT 101 errorCode, 'Transaction under compliance' msg, @controlNumber id, @id extra
			RETURN
		END
		SELECT 100 errorCode, 'Transaction has been sent successfully and is waiting for approval' msg, @controlNumber id, @id extra
		
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH

