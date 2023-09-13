SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[proc_sendIRH] (
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
	,@pBankBranch			VARCHAR(30)			=	NULL
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
	,@isYourMoney			CHAR(1)				=	NULL
	,@isPep					CHAR(1)				=	NULL
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
	,@isAdditionalCDDI		CHAR(1)				=   NULL
	,@additionalCDDIXml		NVARCHAR(MAX)		=   NULL
	,@calcBy				VARCHAR(10)			=	NULL
	,@promotionCode			INT					=	NULL
	,@promotionAmount		VARCHAR(150)		=	NULL
	,@complianceQuestion		NVARCHAR(MAX)	= NULL
)

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
BEGIN
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
		,@sAgentSettRate			FLOAT
		,@pDateCostRate				FLOAT
		,@agentCrossSettRate		FLOAT
		,@treasuryTolerance			FLOAT
		,@customerPremium			FLOAT
		,@schemePremium				FLOAT
		,@sharingValue				MONEY
		,@sharingType				CHAR(1)
		,@sAgentComm				MONEY
		,@sAgentCommCurrency		VARCHAR(3)
		,@sSuperAgentComm			MONEY
		,@sSuperAgentCommCurrency	VARCHAR(3)
		,@pAgentComm				MONEY
		,@pAgentCommCurrency		VARCHAR(3)
		,@pSuperAgentComm			MONEY
		,@pSuperAgentCommCurrency	VARCHAR(3)
		,@promotionType				INT		
		
		,@pSuperAgentName			VARCHAR(100)
		,@pStateId					INT
		,@agentType					INT
		,@senderName				VARCHAR(100)
		,@pAgentMapCode				VARCHAR(10)
		,@pBranchMapCode			VARCHAR(10)
		,@F_ANYWHERE				CHAR(1)
		,@TRN_TYPE					VARCHAR(100)
		,@complienceMessage			VARCHAR(500)
		,@complienceErrorCode		TINYINT
		,@shortMsg					VARCHAR(100)
	 	,@XMLDATA					XML
		,@orginalCollCurr			VARCHAR(3)--Dyanamic Sc Charge
		,@baseCurrScCharge			MONEY

	DECLARE
		 @xAmt					MONEY
		,@baseCurrency			VARCHAR(3)

		,@limitBal				MONEY
		,@sendingCustType		INT
		,@receivingCustType		INT
		,@msg					VARCHAR(200)
		,@exRateCalByPartner	BIT

	IF @pBankBranch = 'NA'
		SET @pBankBranch = NULL

	DECLARE @iServiceCharge		MONEY, @iTAmt MONEY, @iPAmt MONEY, @iScDiscount MONEY, @iCustomerRate FLOAT, @iCollDetailAmt MONEY
	DECLARE @place INT, @currDecimal INT
	DECLARE @cisMasterId		INT, @compIdResult VARCHAR(300),@perDayCustomerLimit money
	
	DECLARE @controlNoEncrypted VARCHAR(20)
	DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @totalRows INT, @count INT, @compFinalRes VARCHAR(20)
	DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
	
	IF ISNULL(@sBranch, 0) = 0
		SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	
	DECLARE @customerTotalAmt2 MONEY = 0
	DECLARE @errorCode CHAR(1) = 0

	DECLARE 
		 @tellerBalance MONEY
		,@tellerLimit MONEY
		,@sendPerTransaction MONEY
		,@vaultBalance MONEY
		,@vaultLimit MONEY
	
	SELECT @sfName	= LTRIM(RTRIM(@sfName))
	,@smName = 	LTRIM(RTRIM(@smName))
	,@slName = LTRIM(RTRIM(@slName))
	,@slName2	= LTRIM(RTRIM(@slName2))
	,@rfName		= LTRIM(RTRIM(@rfName))
	,@rmName		= LTRIM(RTRIM(@rmName))
	,@rlName		= LTRIM(RTRIM(@rlName))
	,@rlName2		= LTRIM(RTRIM(@rlName2))

	IF @salary = 'undefined'
		set @salary = null

	IF @salaryRange = 'undefined'
		set @salaryRange = null
	
	if @pBankBranchName in ('Select','undefined')
		set @pBankBranchName = 'Any Branch'
	
	--CHECK IF SC IS ALLOWED TO EDIT BY USER OR  NOT
	DECLARE @HAS_RIGHT_EDIT_SC CHAR(1) = 'N'
	SELECT @HAS_RIGHT_EDIT_SC = dbo.FNAHasRight(@user, '40101440')
	
	IF ISNULL(@isManualSc, 'N') = 'Y' AND @HAS_RIGHT_EDIT_SC = 'N'
	BEGIN
		SELECT '1' ErrCode, 'Invalid attempt to calculate SC manually!' Msg,NULL id
		RETURN
	END

	IF @flag = 'v-referral'
	BEGIN
		DECLARE @IS_ACTIVE BIT
		SELECT @IS_ACTIVE = IS_ACTIVE FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer
		
		IF @IS_ACTIVE IS NULL
		BEGIN
			SELECT '1' ErrCode, 'Invalid referral code!' Msg,NULL id
			RETURN
		END
		IF @IS_ACTIVE = 0
		BEGIN
			SELECT '1' ErrCode, 'Disabled referral passed!' Msg,NULL id
			RETURN
		END
		SELECT '0' ErrCode, 'Success!' Msg,NULL id
		RETURN
	END

	IF @flag IN ('V', 'I')
	BEGIN
		IF ISNULL(@senderId, 0) = 0 OR (ISNULL(@senderId, '') = '')
		BEGIN
			SELECT '1' ErrCode, 'Invalid sender selected, please refresh page and try sending again!' Msg,NULL id
			RETURN
		END

		--CHECKING OF BRANCH/USER CASH HOLD LIMIT
		IF EXISTS(SELECT * FROM AGENTMASTER WHERE AGENTID = @SAGENT AND ISINTL = 1) AND ISNULL(@INTRODUCER, '') <> ''
		BEGIN
			SELECT '1' ErrCode, 'Agent''s and introducer can not be selected at same time!' Msg,NULL id
			RETURN
		END

		DECLARE @RULETYPE CHAR(1), @LIMITERRORCODE INT, @BRANCH_ID_FOR_LIMIT VARCHAR(20), @INTRODUCER_LIMIT VARCHAR(20)
		
		IF NOT EXISTS(SELECT * FROM APPLICATIONUSERS (NOLOCK) WHERE USERNAME = @USER AND AGENTID = @SAGENT) AND ISNULL(@INTRODUCER, '') = ''
			SET @INTRODUCER_LIMIT = @SAGENT

		ELSE IF ISNULL(@INTRODUCER, '') <> ''
			SET @INTRODUCER_LIMIT = @INTRODUCER

		EXEC PROC_CHECK_BRANCH_USER_CASH_HOLD_LIMIT @USER = @USER, @INTRODUCER = @INTRODUCER_LIMIT, @CAMT = @CAMT
														, @ERRORCODE = @LIMITERRORCODE OUT
														, @ERRORMSG = @msg OUT, @RULETYPE = @RULETYPE OUT
		--select @RULETYPE,@ERRORCODE
		IF @LIMITERRORCODE <> 0 AND @RULETYPE = 'B' AND @COLLMODE = 'CASH COLLECT'
		BEGIN
			SELECT '1' ErrCode, 'Branch/User cash hold limit is exceeded, please contact head office!' Msg,NULL id
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
		
		SELECT @kycStatus = kycStatus
		FROM TBL_CUSTOMER_KYC (NOLOCK) 
		WHERE CUSTOMERID = @senderId
		AND ISDELETED = 0
		--AND kycStatus=11044
		ORDER BY KYC_DATE 

		
		IF ISNULL(@kycStatus, 0) <> 11044
		BEGIN
			IF @kycStatus IS NOT NULL
				SELECT @MSG = 'KYC for selected customer is not completed, it is in status:' + detailTitle FROM staticDataValue (NOLOCK) WHERE valueId = @kycStatus
			ELSE 
				SELECT @MSG = 'Please complete KYC status first'

			SELECT '1' ErrCode, @MSG Msg,NULL id
			RETURN
		END
		
		--GET PAYOUT AGENT DETAILS
		SELECT @PAGENT = AGENTID FROM AGENTMASTER (NOLOCK) WHERE PARENTID = @payoutPartner AND ISNULL(ISSETTLINGAGENT, 'N') = 'Y';

		SELECT @pSuperAgent = sSuperAgent,@pSuperAgentName = sSuperAgentName,
				   @pAgent = sAgent,@pAgentName = sAgentName ,@pBranch = sBranch,@pBranchName = sBranchName
		FROM dbo.FNAGetBranchFullDetails(@PAGENT)

		SELECT @sSuperAgent = sSuperAgent,@sSuperAgentName = sSuperAgentName,
				@sAgent = sAgent,@sAgentName = sAgentName ,@sBranch = sBranch,@sBranchName = sBranchName
		FROM dbo.FNAGetBranchFullDetails(@sBranch)
	END

	SET @sAgentCommCurrency = 'MNT'	
	IF @flag = 'acBal'					--Get Available Account Balance
	BEGIN
		SELECT 
			 @pCountryId = am.agentCountryId
		FROM applicationUsers au WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
		WHERE userName = @user

		SELECT TOP 1 @collCurr = CM.currencyCode
		FROM currencyMaster CM WITH(NOLOCK)
		INNER JOIN countryCurrency CC WITH(NOLOCK) ON CM.currencyId = CC.currencyId
		WHERE CC.countryId = @pCountryId AND ISNULL(cc.isDeleted,'N') = 'N'
		AND ISNULL(CC.isDefault, 'N') = 'Y'

		-->> checking per day country send limit 
		SELECT 
			@limitBal = D.amount 
		FROM csMaster M WITH (NOLOCK)
		INNER JOIN csDetail D WITH(NOLOCK) ON M.csMasterId = D.csMasterId--csDetailId CHANGED BY ARJUN
		WHERE sCountry = @pCountryId
		AND ISNULL(M.isActive,'Y') = 'Y' AND ISNULL(D.isActive,'Y')='Y' 
						

		IF @agentId IS NULL
			SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		ELSE
			SELECT @sBranch = @agentId
		
		SELECT @sAgent = parentId, @agentType = agentType FROM agentMaster WITH(NOLOCK) 
		   WHERE agentId = @sBranch

		IF @agentType = 2903
			SET @sAgent = @sBranch
		
		SELECT @sSuperAgent = parentId FROM agentMaster WITH(NOLOCK) 
			  WHERE agentId = @sAgent
		
		SELECT @settlingAgent = agentId FROM agentMaster 
			  WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		
		 IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		
		DECLARE @limit MONEY, @limitCurr VARCHAR(3), @cRateAgent FLOAT
		
		SELECT @limit = ISNULL(dbo.FNAGetLimitBalIRH(@settlingAgent), 0)
		SELECT @limitCurr = currency FROM creditLimitInt WITH(NOLOCK) 
		WHERE agentId = @settlingAgent AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		
		SELECT 
			 availableBal				= @limit
			,balCurrency				= @collCurr
			,limExpiry					= ISNULL(CONVERT(VARCHAR, expiryDate, 101), 'N/A')
			,sCountryLimit				= ISNULL(@limitBal,0)
			,sCurr						= @collCurr			
			,tellerBanalce				= 0
			,txnPerDayCustomerLimit		= dbo.FNAGetPerDayCustomerLimit(@settlingAgent)
		FROM creditLimitInt cl
		WHERE agentId = @settlingAgent		

	END
	
	IF @flag = 'acBalByAgentId'					--Get Available Account Balance
	BEGIN
		SET @pCountryId=142;
		--SELECT 
		--	 @pCountryId = am.agentCountryId
		--FROM applicationUsers au WITH(NOLOCK)
		--INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
		--WHERE userName = @user

		SELECT TOP 1 @collCurr = CM.currencyCode
		FROM currencyMaster CM WITH(NOLOCK)
		INNER JOIN countryCurrency CC WITH(NOLOCK) ON CM.currencyId = CC.currencyId
		WHERE CC.countryId = @pCountryId AND ISNULL(cc.isDeleted,'N') = 'N'
		AND ISNULL(CC.isDefault, 'N') = 'Y'

		-->> checking per day country send limit 
		SELECT 
			@limitBal = D.amount 
		FROM csMaster M WITH (NOLOCK)
		INNER JOIN csDetail D WITH(NOLOCK) ON M.csMasterId = D.csMasterId--csDetailId CHANGED BY ARJUN
		WHERE sCountry = @pCountryId
		AND ISNULL(M.isActive,'Y') = 'Y' AND ISNULL(D.isActive,'Y')='Y' 
						

		--IF @agentId IS NULL
		--	SELECT @sBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		--ELSE
		--	SELECT @sBranch = @agentId

		SELECT @sAgent = parentId, @agentType = agentType FROM agentMaster WITH(NOLOCK) 
		   WHERE agentId = @sBranch
	
		IF @agentType = 2903
			SET @sAgent = @sBranch
		
		SELECT @sSuperAgent = parentId FROM agentMaster WITH(NOLOCK) 
			  WHERE agentId = @sAgent
		
		SELECT @settlingAgent = agentId FROM agentMaster 
			  WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		
		 IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent AND isSettlingAgent = 'Y'

		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		
		DECLARE @limitAmt MONEY, @limitCurrency VARCHAR(3), @cRateAgentAmt FLOAT,@userId INT,
				@user1 VARCHAR(50)=NULL,  @holdType VARCHAR(10) =NULL
		IF EXISTS (SELECT 1 FROM dbo.applicationUsers WHERE agentId=@sBranch AND userName=@user)
		BEGIN
		  SELECT  @user1 = @user, @sBranch = null
		END 
		--EXEC proc_sendIRH @flag = 'acBalByAgentId', @user = 'anupam', @sBranch = '394393'
		--EXEC proc_sendIRH @flag = 'acBalByAgentId', @user = 'anupam', @sBranch = '394392'
		SELECT @limitAmt = availableLimit, 
			  @holdType = CASE WHEN ruleType = 'H' THEN 'Hold' Else 'Block' END 
		FROM DBO.FNAGetUserCashLimitDetails(@user1, @sBranch)

		--SELECT @limitAmt = ISNULL(dbo.proc_checkUserAvailableBalance(@settlingAgent), 0)
		SELECT @limitCurrency = 'MNT'-- FROM creditLimitInt WITH(NOLOCK) 
		--WHERE agentId = @settlingAgent AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		SELECT 
			 availableBal				= @limitAmt
			,balCurrency				= @collCurr
			,limExpiry					= 'N/A'
			,sCountryLimit				= ISNULL(@limitBal,0)
			,sCurr						= @collCurr			
			,tellerBanalce				= 0
			,txnPerDayCustomerLimit		= dbo.FNAGetPerDayCustomerLimit(@settlingAgent)
			,holdType					= @holdType
		

	END
	IF @flag = 'getReferralBal'
	BEGIN
		SELECT  totalLimit, 
				 availableLimit
		FROM DBO.FNAGetBranchCashLimitDetails(@referralCode, 'R')
	END
	
	ELSE IF @flag = 'v'						--Validation
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

		--IF @occupation IS NULL
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Occupation is missing', NULL
		--	RETURN	
		--END 

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

-----Dyanamic Sc Charge Start
		  SET @orginalCollCurr = @collCurr

		  SELECT @baseCurrency = baseCurrency FROM sscmaster 
		  WHERE scountry = @sCountryId AND sSAgent = @sSuperAgent AND rCountry = @pCountryId AND ISNULL(rsAgent ,@pSuperAgent) = @pSuperAgent

		  IF @baseCurrency != 'MNT'
		  BEGIN
			 SET @collCurr = @baseCurrency
		  END
----Dyanamic Sc Charge End

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
			IF @cAmt <> @tAmt + @serviceCharge
			BEGIN
				EXEC proc_errorHandler 1, 'Please click on Calculate or Click out side the Service Charge input Box, after editing Service Charge!', NULL
				RETURN
			END 
		END
	
--Dyanamic Sc Charge Start
			SET @baseCurrScCharge = @serviceCharge

			IF @baseCurrency != 'MNT'
			BEGIN
			  SELECT  @iServiceCharge = dbo.FNA_GetMNTAmount(@baseCurrency,@iServiceCharge,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			  SELECT  @serviceCharge = dbo.FNA_GetMNTAmount(@baseCurrency,@serviceCharge,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			END
--Dyanamic Sc Charge End

		IF @baseCurrency != 'MNT'  --Dyanamic Sc Charge End
		BEGIN
			SET @collCurr = @orginalCollCurr
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
		IF @schemeCode IS NOT NULL
		BEGIN
			DECLARE @scValue MONEY, @scAction CHAR(2), @scOffer MONEY, @exRateOffer FLOAT, @scDiscount MONEY
			
		END
		SET @iCustomerRate = @exRate + ISNULL(@schemePremium, 0)

		SET @iTAmt = @cAmt - @iServiceCharge
		

		SELECT @place = place, @currDecimal = currDecimal
		FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' 
		AND currency = @pCurr AND ISNULL(tranType,@deliveryMethodId) =@deliveryMethodId
		
		SET @currDecimal = ISNULL(@currDecimal, 0)
		SET @place = ISNULL(@place, 0)
		
		SET @iPAmt = @iTAmt * @iCustomerRate

		IF @pAmt - @iPAmt <= 1
			SET @iPAmt = @pAmt
		

		IF @iPAmt <> @pAmt
		BEGIN
			EXEC proc_errorHandler 1, 'Amount detail not match. Please re-calculate the amount again.', NULL
			RETURN
		END
		--End of service charge Checking
		
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

		
		--------#Register Receiver if not registered#---------------
		DECLARE @rBankId INT = ISNULL(@pBank, @pAgent)
		DECLARE @rBankBranchId INT = ISNULL(@pBankBranch, '')

	
		EXEC PROC_CHECK_RECEIVER_REGISTRATION @flag = 'i', @user=@user, @rfName=@rfName, @rmName=@rmName, @rlName=@rlName, @receiverIdNo=@rIdNo,
				@receiverIdType=@rIdType, @receiverCountry=@pCountry, @receiverAdd=@rAdd1, @receiverCity=@rcity, @receiverMobile=@rMobile,
				@receiverPhone = @rTel, @receiverEmail = @rEmail, @receiverId = @receiverId OUT, @customerId = @senderId, @paymentMethodId=@deliveryMethodId,
				@rBankId= @rBankId,@rBankBranchId = @rBankBranchId, @rAccountNo=@raccountNo,@purpose=@purpose,@relationship = @relationship,@loginBranchId = @sBranch

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

		SET @sCountry = 'Mongolia'

		IF ISNULL(@isAdditionalCDDI, 'N') = 'N'
		BEGIN
			CREATE TABLE #TBL_COMPLIANCE_RESULT (ERROR_CODE INT, MSG VARCHAR(500), RULE_ID INT, SHORT_MSG VARCHAR(100), [TYPE] VARCHAR(10), IS_D0C_REQUIRED BIT)

			INSERT INTO #TBL_COMPLIANCE_RESULT (ERROR_CODE, MSG, RULE_ID, SHORT_MSG, [TYPE], IS_D0C_REQUIRED)
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
					ORDER BY ISNULL(IS_D0C_REQUIRED, 0) DESC 
					--SELECT 102 errorCode,@shortMsg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
				END
				--IF(@complienceErrorCode = 3)
				--BEGIN
				--	SELECT 103 errorCode,@shortMsg msg, @complienceErrorCode id, @complienceMessage compApproveRemark,'compliance' vtype
				--END
				DELETE FROM ComplianceLog where agentRefId = @agentRefId
				
				INSERT INTO ComplianceLog(senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName, receiverCountry, payOutAmt,
				complianceId, complianceReason, complainceDetailMessage, createdBy, createdDate, agentRefId, isDocumentRequired)

				SELECT @senderName, @sCountry, @sIdType, @sIdNo, @sMobile, @receiverName, @pCountry, @cAmt, RULE_ID, SHORT_MSG, MSG, @user, GETDATE()
								, @agentRefId, IS_D0C_REQUIRED
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
		FROM ComplianceLog CL(NOLOCK)
		WHERE agentRefId = @agentRefId 
		AND CAST(CREATEDDATE AS DATE) = CAST(GETDATE() AS DATE)

		DECLARE @IS_TXN_IN_COMPLIANCE BIT = 0, @isDocumentRequired CHAR(1) = 'N'
		IF EXISTS(SELECT * FROM #TEMP_COMPLIANCE WHERE isDocumentRequired = 1)
		BEGIN
			SET @isDocumentRequired = 'Y'
		END

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
					vtype	= 'compliance',
					isDocumentRequired = 'N'

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
					vtype	= 'compliance',
					isDocumentRequired = @isDocumentRequired

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
					vtype	= 'compliance',
					isDocumentRequired = @isDocumentRequired

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

		IF @customerPassword IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM dbo.customerMaster WHERE customerId=@senderId AND dbo.decryptDb(customerPassword) =@customerPassword)
			BEGIN
			    EXEC proc_errorHandler 1, 'Customer Password is invalid !', NULL
				RETURN
			END
		END

		--******************BEGINING OF NEW CUSTOMER CREATION AND ENROLLMENT********************************
		SELECT @sIdTypeId = valueId from staticDataValue WITH(NOLOCK) WHERE detailTitle = @sIdType AND typeID = 1300
		
		SELECT @sfName = UPPER(@sfName), @smName = UPPER(@smName), @slName = UPPER(@slName), @slName2 = UPPER(@slName2)
		SELECT @rfName = UPPER(@rfName), @rmName = UPPER(@rmName), @rlName = UPPER(@rlName), @rlName2 = UPPER(@rlName2)
		--2. Begining of New customer Creation and enrollment or updating existing customer data---
		SET @senderName = @sfName + ISNULL(' ' + @smName, '') + ISNULL(' ' + @slName, '') + ISNULL(' ' + @slName2, '')
		SET @receiverName = @rfName + ISNULL(' ' + @rmName, '') + ISNULL(' ' + @rlName, '') + ISNULL(' ' + @rlName2, '')

		
		SET @sNaCountryId = (SELECT countryId FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYNAME = @sNaCountry)


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
		
		SET @controlNo = 'SMN' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 8)
		
		IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
		BEGIN
			SET @controlNo = 'SMN' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 8)
			IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
			BEGIN
				EXEC proc_errorHandler 1, 'Technical error occurred. Please try again', NULL
				RETURN
			END
		END
		
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		
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
		--Credit Limit Section
		IF @collMode = 'Cash Collect'
		BEGIN
			DECLARE @sBranch1 INT
			IF EXISTS (SELECT 1 FROM dbo.applicationUsers WHERE agentId=@sBranch AND userName=@user)
			BEGIN
				SELECT @user1 = @user, @sBranch1 = null
			END
			ELSE
			BEGIN
				SET @sBranch1 = @sBranch
			END
			
			SELECT @limitBal = availableLimit, 
					@holdType = CASE WHEN ruleType = 'H' THEN 'Hold' Else 'Block' END 
			FROM DBO.FNAGetUserCashLimitDetails(@user1, @sBranch1)

			IF @tAmt > @limitBal AND @holdType = 'B'
			BEGIN
				EXEC [proc_errorHandler] 1, 'Transfer amount exceeds Limit. Please, Check your available limit.', @controlNo
				RETURN		
			END
		END
		

		--End of Credit Limit Section-------------------------------------------------------------------------------------------------------------

		SELECT 
			 @customerRate			= customerRate
			,@sCurrCostRate			= sCurrCostRate
			,@sCurrHoMargin			= sCurrHoMargin
			,@sCurrAgentMargin		= sCurrAgentMargin
			,@pCurrCostRate			= pCurrCostRate
			,@pCurrHoMargin			= pCurrHoMargin
			,@pCurrAgentMargin		= pCurrAgentMargin
			,@agentCrossSettRate	= agentCrossSettRate
			,@treasuryTolerance		= treasuryTolerance
			,@customerPremium		= customerPremium
			,@sharingValue			= sharingValue
			,@sharingType			= sharingType
		FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)
		 
		IF @customerRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction cannot be proceed. Exchange Rate not defined', NULL
			RETURN
		END
		


---Dyanamic Sc Charge Start
		  SET @orginalCollCurr = @collCurr

		  SELECT @baseCurrency = baseCurrency FROM sscmaster 
		  WHERE scountry = @sCountryId AND sSAgent = @sSuperAgent AND rCountry = @pCountryId AND ISNULL(rsAgent ,@pSuperAgent) = @pSuperAgent

		  IF @baseCurrency != 'MNT'
		  BEGIN
			 SET @collCurr = @baseCurrency
		  END
----Dyanamic Sc Charge End


		SET @sCountryId = 142

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
			--IF @cAmt <> @tAmt + @serviceCharge
			--BEGIN
			--	EXEC proc_errorHandler 1, 'Please click on Calculate or Click out side the Service Charge input Box, after editing Service Charge!', NULL
			--	RETURN
			--END 
		END
		
		
			   
--Dyanamic Sc Charge Start
			SET @baseCurrScCharge = @serviceCharge
			IF @baseCurrency != 'MNT'
			BEGIN
			  SELECT  @originalSC = dbo.FNA_GetMNTAmount(@baseCurrency,@originalSC,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			  SELECT  @iServiceCharge = dbo.FNA_GetMNTAmount(@baseCurrency,@iServiceCharge,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			  SELECT  @serviceCharge = dbo.FNA_GetMNTAmount(@baseCurrency,@serviceCharge,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			END
--Dyanamic Sc Charge End
		SET @collCurr = @orginalCollCurr --Dyanamic Sc Charge End
		
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
		
		--4. Get Exchange Rate Details------------------------------------------------------------------------------------------------------------------
		
		
		SET @serviceCharge = @serviceCharge - ISNULL(@scDiscount, 0)
		SET @iServiceCharge = @iServiceCharge - ISNULL(@iScDiscount, 0)
		
		SET @tAmt = @cAmt - @serviceCharge

		SET @iCustomerRate = @customerRate + ISNULL(@schemePremium, 0)
		
		SET @iTAmt = @cAmt - @iServiceCharge

		SELECT @place = place, @currDecimal = currDecimal
		FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' 
		AND currency = @pCurr AND ISNULL(tranType,@deliveryMethodId) =@deliveryMethodId
		
		SET @currDecimal = ISNULL(@currDecimal, 0)
		SET @place = ISNULL(@place, 0)
		
		SET @iPAmt = @iTAmt * @iCustomerRate

		SET @iPAmt = @iTAmt * @iCustomerRate

		SET @iPAmt = ROUND(@iPAmt, @currDecimal, 1)
		--IF @place IS NOT NULL
		--	SET @iPAmt = ROUND(@iPAmt, -@place, 1)
		
		
		IF @pAmt - @iPAmt <= 1
			SET @iPAmt = @pAmt
		
		IF @iPAmt <> @pAmt
		BEGIN
			EXEC proc_errorHandler 1, 'Amount detail not match. Please re-calculate the amount again.', NULL
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
		
		SELECT @sNaCountry = CASE WHEN @nCust='Y' THEN @sNaCountry ELSE nativeCountry END
		FROM tranSenders WITH(NOLOCK) WHERE customerId = @senderId
		
		IF NOT EXISTS(SELECT 'Z' FROM tranSenders WITH(NOLOCK) WHERE customerId = @senderId)
		BEGIN
			IF NOT EXISTS(SELECT 'Z' FROM tranSendersTEMP WITH(NOLOCK) WHERE customerId = @senderId)
				SET @isFirstTran ='Y'
			ELSE 
				SET @isFirstTran ='N'
		END

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
								,@deliveryMethodId, @cAmt, @pAmt, @serviceCharge, @tAmt, NULL)
		
				
---Part 2 : New Logic for Service charge in multiple currencies start
			IF @pAgentCommCurrency != 'MNT'
			BEGIN
			  SELECT  @pAgentComm = dbo.FNA_GetMNTAmount(@pAgentCommCurrency,@pAgentComm,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			END
--Part 2 : New Logic for Service charge in multiple currencies end
		SET @pAgentComm = CEILING(@pAgentComm)
		SET @sSettlementRate = @sCurrCostRate + @sCurrHoMargin
		SET @pSettlementRate = @pCurrCostRate - @pCurrHoMargin

		IF ISNULL(@pAgentComm,'0') = '0' OR @pAgentComm = ''
		BEGIN
			EXEC proc_errorHandler 1, 'PAgent commission Missing', NULL
			RETURN
		END 
	
		SELECT @sAgentComm = 0, @sSuperAgentComm = 0, @sSuperAgentCommCurrency = @sAgentCommCurrency
		
		IF EXISTS(SELECT * FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer AND AGENT_ID <> 0)
		BEGIN
			SELECT @sAgent = AM.AGENTID, 
					@sAgentName = AM.AGENTNAME,
					@sBranch = AM.AGENTID, 
					@sBranchName = AM.AGENTNAME
			FROM REFERRAL_AGENT_WISE R(NOLOCK) 
			INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = R.AGENT_ID
			WHERE REFERRAL_CODE = @introducer
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
				,relWithSender,purposeOfRemit,sourceOfFund,isYourMoney,isPep
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
				,@serviceCharge,ISNULL(@scDiscount,0), 0
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
				,@relationship,@purpose,@sourceOfFund,@isYourMoney,@isPep
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
			SELECT @controlNo

			
				IF ISNULL(@complianceQuestion, '') <> ''
				BEGIN
					SET @XMLDATA = CONVERT(XML, REPLACE(@complianceQuestion,'&','&amp;'), 2) 

					SELECT  answer = p.value('@answer', 'varchar(150)') ,
							qType = p.value('@qType', 'varchar(500)'),
							qId = p.value('@qId', 'varchar(500)')
					INTO #TRANSACTION_COMPLIANCE_QUESTION
					FROM @XMLDATA.nodes('/root/row') AS tmp ( p );
		
					INSERT INTO TBL_TXN_COMPLIANCE_CDDI
					SELECT @id, qId, answer
					FROM #TRANSACTION_COMPLIANCE_QUESTION
				END

			--UPDATE PROMOTIONAL CAMPAIGN
			IF ISNULL(@promotionCode, 0) <> 0
			BEGIN
				EXEC PROC_PROMOTIONAL_CAMPAIGN_COUNTRY_WISE @ID = @id, @promotionCode = @promotionCode, @promotionAmount = @promotionAmount
			END

			SELECT @sAdd1=ISNULL(Address,ADDITIONALADDRESS) FROM dbo.customerMaster(NOLOCK) WHERE customerId=@senderId

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
			
			--SELECT @sourceOfFund = valueId FROM dbo.staticDataValue WHERE detailTitle = @sourceOfFund and typeID = '3900'

			DECLARE @SOURCE INT, @PURPOSEID INT, @RELATION INT, @OCCUPATIONID INT

			SELECT @SOURCE = valueId
			FROM STATICDATAVALUE (NOLOCK)
			WHERE detailTitle = @sourceOfFund
			AND typeID = '3900'

			SELECT @PURPOSEID = valueId
			FROM STATICDATAVALUE (NOLOCK)
			WHERE detailTitle = @purpose
			AND typeID = '3800'

			SELECT @RELATION = valueId
			FROM STATICDATAVALUE (NOLOCK)
			WHERE detailTitle = @relationship
			AND typeID = '2100'

			SELECT @OCCUPATIONID = valueId
			FROM STATICDATAVALUE (NOLOCK)
			WHERE detailTitle = @occupation
			AND typeID = '2000'

			--EXEC PROC_CUSTOMERMODIFYLOG 
			--		@flag						=	'i-fromSendPage'
			--		,@user						=	@user
   --                 ,@customerId				=	@senderId
			--		,@mobileNumber				=	@sMobile
			--		,@monthlyIncome				=	@salaryRange
			--		,@email						=	@sEmail
			--		,@placeofissue				=   @sCustIdIssuedCountry
			--		,@occupation				=	@OCCUPATIONID
			--		,@sourceOfFund				=	@SOURCE

			UPDATE CUSTOMERMASTER set	mobile = ISNULL(@sMobile,mobile)
							,monthlyincome=ISNULL(@salaryRange,monthlyincome)
							,email =ISNULL(@sEmail,email)
							,placeofissue=ISNULL(@sCustIdIssuedCountry,placeofissue)
							,occupation=ISNULL(@OCCUPATIONID,occupation)
							,sourceOfFund = ISNULL(@SOURCE,sourceOfFund)
			WHERE CUSTOMERID = @senderId

			EXEC PROC_RECEIVERMODIFYLOGS @flag = 'i-fromSendPage'
										 ,@address		= @rAdd1
										 ,@email		= @rEmail
										 ,@mobile		= @rMobile
										 ,@receiverId	= @receiverId
										 ,@customerId   = @senderId
											
			UPDATE RECEIVERINFORMATION SET address = ISNULL(@rAdd1, address), mobile = ISNULL(@rMobile, mobile),email = ISNULL(@rEmail,email),
											purposeOfRemit = ISNULL(@PURPOSEID, purposeOfRemit), relationship = ISNULL(@RELATION, relationship),
											bankBranchName = ISNULL(@pBankBranchName, bankBranchName)
			WHERE receiverId = @receiverId

			IF @collMode = 'Cash Collect'
			BEGIN
				SELECT @userId = userId	FROM APPLICATIONUSERS WHERE USERNAME = @USER
				EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG='SEND',@S_AGENT = @sAgent,@S_USER = @userId,@C_AMT = @cAmt,@REFERRAL_CODE = @introducer,@ONBEHALF = @isOnbehalf
			END
			ELSE
			BEGIN
				EXEC PROC_INSERT_JP_DEPOSIT_TXN_LOG @FLAG = 'I', @TRANID = @id, @CUSTOMERID = @senderId, @CAMT = @cAmt
			END

			DECLARE @PARTICULARS VARCHAR(200) = 'Send TXN: '+@controlNo
			
			EXEC proc_customerTxnHistory @controlNo = @controlNoEncrypted

		
			IF ISNULL(@isAdditionalCDDI, 'N') = 'Y'
			BEGIN
				SET @XMLDATA = CONVERT(XML, REPLACE(@additionalCDDIXml,'&','&amp;'), 2) 

				SELECT  ID = p.value('@id', 'varchar(150)') ,
						ANSWER = p.value('@answer', 'varchar(500)') 
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

		IF @LIMITERRORCODE <> 0 AND @RULETYPE = 'H' AND @COLLMODE = 'CASH COLLECT'
		BEGIN
			UPDATE remitTranTemp SET
					tranStatus	= CASE WHEN tranStatus = 'Compliance Hold' THEN 'Cash Limit/Compliance Hold'
										WHEN tranStatus = 'OFAC Hold' THEN 'Cash Limit/OFAC Hold'
										WHEN tranStatus = 'OFAC/Compliance Hold' THEN 'Cash Limit/OFAC/Compliance Hold'
										ELSE 'Cash Limit Hold'
									END
			WHERE controlNo = @controlNoEncrypted
			INSERT INTO dbo.remitTranCashLimitHold
			    ( tranId ,
			          approvedRemarks ,
			          approvedBy ,
			          approvedDate ,
			 reason
			        )
			VALUES  ( @id , -- tranId - bigint
			          null , -- approvedRemarks - varchar(150)
			          null , -- approvedBy - varchar(80)
					  null , -- approvedDate - datetime
			          null  -- reason - varchar(500)
			        )
					
		END

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		IF(@complianceRes = 'C' OR @ofacRes <> '')
		BEGIN
			SELECT 101 errorCode, 'Transaction under compliance' msg, @controlNo id, @id extra
			RETURN
		END
		SELECT 100 errorCode, 'Transaction has been sent successfully and is waiting for approval' msg, @controlNo id, @id extra
		
	END

	ELSE IF @flag = 'exRate'			--Get Exchange Rate, Service Charge, Scheme/Offer and amount details
	BEGIN
		--IF @manualSc = 'NAN' 
		--	SET @manualSc = '0'

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
			
		--	SELECT @exRate = dbo.FNAGetCustomerRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)
		SELECT 
			@sCurrCostRate			= sCurrCostRate
			,@sCurrHoMargin			= sCurrHoMargin
			,@pCurrCostRate			= pCurrCostRate
			,@pCurrHoMargin			= pCurrHoMargin
			,@exRate				= customerRate
		FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)

		IF ISNULL(@exRate, 0) = 0
		BEGIN
			SELECT '1' ErrCode, 'Exchange rate not defined yet for receiving currency (' + @pCurr + ')' Msg,NULL id
			RETURN
		END

			
-----Dyanamic Sc Charge Start
		  SET @orginalCollCurr = @collCurr

		  SELECT @baseCurrency = baseCurrency FROM sscmaster 
		  WHERE scountry = @sCountryId AND sSAgent = @sSuperAgent AND rCountry = @pCountryId AND ISNULL(rsAgent ,@pSuperAgent) = @pSuperAgent

		  IF @baseCurrency != 'MNT'
		  BEGIN
			 SET @collCurr = @baseCurrency
		  END
----Dyanamic Sc Charge End


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

			   
--Dyanamic Sc Charge Start
			SET @baseCurrScCharge = @serviceCharge

			IF @baseCurrency != 'MNT'
			BEGIN
			  SELECT  @serviceCharge = dbo.FNA_GetMNTAmount(@baseCurrency,@serviceCharge,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			END
--Dyanamic Sc Charge End
				
				IF @serviceCharge IS NULL AND ISNULL(@isManualSc, 'N') = 'N'
				BEGIN
					SELECT '1' ErrCode, 'Service charge not defined yet for receiving country' Msg,NULL id
					RETURN;
				END
				
				SET @tAmt = @cAmt - @serviceCharge + @scDiscount
				
				SET @pAmt = @tAmt * (@exRate + @exRateOffer)	
						
				SET @pAmt = FLOOR(@pAmt)
			END
			ELSE
			BEGIN
				--SET @tAmt = ROUND(@pAmt/(@exRate + @exRateOffer),0)
				SET @tAmt = CEILING(@pAmt/(@exRate + @exRateOffer))
				IF ISNULL(@isManualSc, 'N') = 'N'
				BEGIN
					SELECT  @serviceCharge = amount FROM [dbo].FNAGetServiceCharge(
						 @sCountryId, @sSuperAgent, @sAgent, @sBranch 
						,@pCountryId, @pSuperAgent, @pAgent, @pBranch 
						,@deliveryMethod, @tAmt, @collCurr
				)
				END
			   ELSE
			   BEGIN
					SET @serviceCharge = ISNULL(@manualSc, 0)
			   END

--Dyanamic Sc Charge Start
			SET @baseCurrScCharge = @serviceCharge

			IF @baseCurrency != 'MNT'
			BEGIN
			  SELECT  @serviceCharge = dbo.FNA_GetMNTAmount(@baseCurrency,@serviceCharge,@sCurrCostRate,ISNULL(@sCurrHoMargin, 0),(@pCurrCostRate - ISNULL(@pCurrHoMargin,0)))
			END
--Dyanamic Sc Charge End

				IF @serviceCharge IS NULL 
				BEGIN
					SELECT '1' ErrCode, 'Service charge not defined yet for receiving country' Msg,NULL id
					RETURN;
				END
				
				SET @cAmt = (@tAmt + @serviceCharge - @scDiscount)
				
				SET @cAmt = CEILING(@cAmt)		
			END	


		SET @collCurr = @orginalCollCurr --Dyanamic Sc Charge End


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
			scCharge = @baseCurrScCharge, --@serviceCharge,  Dyanamic Sc Charge End
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
			scDiscount = @scDiscount,
			tpExRate = 0,
			ScChargeCurr = @baseCurrency
	END
	
	ELSE IF @flag = 'customerRate'		--Get Customer Rate
	BEGIN
		SELECT TOP 1 @pCurr = CM.currencyCode 
		FROM currencyMaster CM WITH (NOLOCK)
		INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId = CC.currencyId
		WHERE CC.countryId = @pCountryId 
		AND ISNULL(CC.isDeleted, 'N') = 'N'
	    
		IF @pCurr IS NULL
		BEGIN
			 SELECT '1' ErrCode, 'Not defined' Msg,NULL id
			 RETURN
		END
		
		SELECT @exRate = dbo.FNAGetCustomerRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)
		IF @exRate IS NULL
		BEGIN
			SELECT '1' ErrCode, 'Not defined' Msg,NULL id
			RETURN
		END

		declare @maxLimit as money,@lCurr as varchar(10)

		SELECT @maxLimit = maxLimitAmt,@lCurr = currency FROM sendTranLimit with(nolock)
		WHERE agentId =@sAgent
		AND ISNULL(receivingCountry, ISNULL(@pCountryId, 0)) = ISNULL(@pCountryId, 0)
		AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
		AND currency = @collCurr AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'

		SELECT @maxLimit = maxLimitAmt,@lCurr = currency FROM sendTranLimit with(nolock)
		WHERE agentId is null
		AND ISNULL(receivingCountry, ISNULL(@pCountryId, 0)) = ISNULL(@pCountryId, 0)
		AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
		AND currency = @collCurr AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'

		SELECT '0' ErrCode, @exRate exRate, @pCurr pCurr,@maxLimit limit,@lCurr limitCurr
	END
	
	ELSE IF @flag = 'CustdayLimit'		-- CUSTOMER PER DAY LIMIT
	BEGIN
		DECLARE @txnSum MONEY,@txnCount INT, @tranId INT, @date VARCHAR(20) = CONVERT(varchar(20), GETDATE(),111)
	
		SELECT 
			@limitBal= D.amount FROM csMaster M WITH (NOLOCK)
		INNER JOIN csDetail D WITH(NOLOCK) ON M.csMasterId=D.csDetailId
		WHERE sCountry=@sCountryId
		AND ISNULL(M.isActive,'Y')='Y' AND ISNULL(D.isActive,'Y')='Y' 
		
		
		SELECT 
			 @txnSum= ISNULL(SUM(R.cAmt),0),@txnCount=COUNT('x')  
		FROM remitTran R WITH (NOLOCK), tranSenders  S WITH (NOLOCK)
		WHERE R.id = S.tranId and S.customerId = @senderId
		  AND R.approvedDate between @date and @date +' 23:59:59'
			
			
		SELECT ISNULL(@limitBal,0) countryBalLimit,ISNULL(@txnSum,0) custDayLimit,
			 ISNULL(@txnCount,0) custDayTxn,CAST(GETDATE() as DATE) [txnDate]
			
	END
	
	ELSE IF @flag = 'cti'				--All transaction information (sender, receiver, payout)
	BEGIN
		SELECT DISTINCT
			 c.customerId
			,c.membershipId
			,Name = c.firstName + ISNULL(' ' + c.middleName, '') + ISNULL(' ' + c.lastName1, '') + ISNULL(' ' + c.lastName2, '')
			,c.Country 
			,Address
			,[State]
			,Phone = COALESCE(mobile, homePhone, workPhone)
			,city
		FROM tranSenders c WITH(NOLOCK)	
		WHERE c.id = @senderId
		
		SELECT DISTINCT
			 c.customerId
			,c.membershipId
			,Name = c.firstName + ISNULL( ' ' + c.middleName, '') + ISNULL( ' ' + c.lastName1, '') + ISNULL( ' ' + c.lastName2, '')
			,Country 
			,Address
			,[State]
			,Phone = COALESCE(mobile, homePhone, workPhone)
			,city
		FROM tranreceivers c WITH(NOLOCK)	
		WHERE c.id = @benId
		
		IF @agentId > 0
		BEGIN
			SELECT
				DISTINCT
				 am.agentId
				,am.agentCode
				,name = am.agentName
				,address = am.agentAddress
				,city = agentCity
				,[State] = agentState
				,Phone = COALESCE(agentMobile1, agentMobile2, agentPhone1, agentPhone2)
				,Country = @pCountry
			FROM agentMaster am WITH(NOLOCK)
			LEFT JOIN agentCurrency ac WITH(NOLOCK) ON am.agentId = ac.agentId
			WHERE am.agentId = @agentId
		END
		ELSE
		BEGIN
			SELECT
				 agentId = NULL
				,agentCode = NULL
				,name = 'Any'
				,address = NULL
				,city = NULL
				,state = NULL
				,Phone = NULL
				,country = @pCountry
		END
	END
	
	ELSE IF @flag = 'controlNo'
	BEGIN
		SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
		SELECT
			  senderId = sen.customerId
			 ,benId = ben.customerId
			 ,pCountry = cm.countryId
			 ,deliveryMethod = stm.serviceTypeId
			 ,tAmt = trn.tAmt
			 ,cAmt = trn.cAmt
			 ,pAmt = trn.pAmt
			 ,customerRate = trn.customerRate
			 ,serviceCharge = trn.serviceCharge
			 ,trn.collCurr
			 ,trn.payoutCurr
			 ,agentId = pBranch
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers ben WITH(NOLOCK) ON trn.id = ben.tranId
		INNER JOIN countryMaster cm WITH(NOLOCK) ON trn.pCountry = cm.countryName
		INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
		WHERE controlNo = @controlNoEncrypted
	END
	
	ELSE IF @flag = 'senderId'
	BEGIN
		SELECT TOP 1
			 senderId = sen.customerId
			,benId = ben.customerId
			,pCountry = cm.countryId
			,deliveryMethod = stm.serviceTypeId
			,tAmt = trn.tAmt
			,cAmt = trn.cAmt
			,pAmt = trn.pAmt
			,customerRate = trn.customerRate
			,serviceCharge = trn.serviceCharge
			,trn.collCurr
			,trn.payoutCurr
			,agentId = pBranch
		FROM remitTran trn WITH(NOLOCK)
		INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		INNER JOIN tranReceivers ben WITH(NOLOCK) ON trn.id = ben.tranId
		INNER JOIN countryMaster cm WITH(NOLOCK) ON trn.pCountry = cm.countryName
		INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
		WHERE sen.customerId = @senderId ORDER BY trn.id DESC
	END	
	ELSE IF @flag = 'chkSenderIdNo'
	BEGIN
		--IF EXISTS(SELECT 'X' FROM dbo.customerMaster WITH(NOLOCK) WHERE idNumber = @sIdNo AND ISNULL(isDeleted, 'N') = 'N')
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Customer is already registered with this Id Number', NULL
		--	RETURN
		--END
		EXEC proc_errorHandler 0, 'Success', NULL
	END
END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH
GO