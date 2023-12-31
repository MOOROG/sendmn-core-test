USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_CreateTXN]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	ws_int_proc_CreateTXN  @ACCESSCODE='BRNNP1087',@USERNAME='dhan321',@PASSWORD='dhan123',@FOREX_SESSION_ID='',
	@AGENT_TXN_REF_ID='3453453',@REMITTER_ID='1234556',@SENDER_NAME='Dhan Saud',@SENDER_ADDRESS='QTR Test Add',@SENDER_MOBILE='9848700321',
	@SENDER_CITY='test',@SENDER_COUNTRY='Qatar',@SENDERS_IDENTITY_TYPE='1302',@SENDER_IDENTITY_NUMBER='124457',@RECEIVER_NAME='Arjun',
	@RECEIVER_ADDRESS='KTM',@RECEIVER_CONTACT_NUMBER='9848700324',@RECEIVER_CITY='KTM',@RECEIVER_COUNTRY='Nepal',@OCCUPATION='Student',
	@SOURCE_OF_FUND='Salary',@RELATIONSHIP='Brother',@PURPOSE_OF_REMITTANCE='Studying',@COLLECT_AMT='100',@PAYOUTAMT='2900',
	@PAYMENTTYPE='C',@BANK_NAME='',@BANK_BRANCH_NAME='',@BANK_ACCOUNT_NUMBER='',@TRNDATE='2016-12-26',@CALC_BY='C'
*/
CREATE PROC [dbo].[ws_int_proc_CreateTXN] (	 
		@ACCESSCODE					VARCHAR(50),
		@USERNAME					VARCHAR(50),
		@PASSWORD					VARCHAR(50),		
		@FOREX_SESSION_ID			VARCHAR(50),
		@AGENT_TXN_REF_ID			VARCHAR(50) = NULL,
		@REMITTER_ID				VARCHAR(50),
		@SENDER_NAME				VARCHAR(50),
		@SENDER_ADDRESS				VARCHAR(50),
		@SENDER_MOBILE				VARCHAR(50),
		@SENDER_CITY				VARCHAR(100),
		@SENDER_COUNTRY				VARCHAR(50),
		@SENDERS_IDENTITY_TYPE		VARCHAR(50),
		@SENDER_IDENTITY_NUMBER		VARCHAR(50),
		@RECEIVER_NAME				VARCHAR(50),
		@RECEIVER_ADDRESS			VARCHAR(50),
		@RECEIVER_CONTACT_NUMBER	VARCHAR(50) = NULL,
		@RECEIVER_CITY				VARCHAR(50) = NULL,
		@RECEIVER_COUNTRY			VARCHAR(50),

		@OCCUPATION					VARCHAR(50) = NULL,
        @SOURCE_OF_FUND				VARCHAR(50) = NULL,
        @RELATIONSHIP				VARCHAR(50) = NULL,
        @PURPOSE_OF_REMITTANCE		VARCHAR(50) = NULL,

		@COLLECT_AMT				MONEY,
		@PAYOUTAMT					MONEY,		
		@PAYMENTTYPE				VARCHAR(50),
		@BANKID						VARCHAR(50) = NULL,
		@BANK_NAME					VARCHAR(50),
		@BANK_BRANCH_NAME			VARCHAR(50),
		@BANK_ACCOUNT_NUMBER		VARCHAR(50) = NULL,
		@TRNDATE					DATETIME,
		@CALC_BY					VARCHAR(50)
)

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

     --IF @ACCESSCODE ='IMEQAAJ007'
     --SET @CALC_BY = 'C'	
	DECLARE @apiRequestId INT					
	INSERT INTO apiRequestLog(					
		AGENT_CODE,
		USER_ID,
		PASSWORD,
		AGENT_SESSION_ID,
		AGENT_TXN_ID,		
		SENDER_NAME,		
		SENDER_ADDRESS,
		SENDER_MOBILE,
		SENDER_CITY,
		SENDER_COUNTRY,
		SENDER_ID_TYPE,
		SENDER_ID_NUMBER,		
		RECEIVER_NAME,
		RECEIVER_ADDRESS,
		RECEIVER_CONTACT_NUMBER,
		RECEIVER_CITY,
		RECEIVER_COUNTRY,
		TRANSFER_AMOUNT,
		COLLECT_AMT,
		PAYOUTAMT,
		PAYMENT_MODE,
		BANK_ID,
		BANK_ACCOUNT_NUMBER,
		CALC_BY,
		BANK_NAME,
		BANK_BRANCH_NAME,		
		REQUESTED_DATE,
		OCCUPATION,
        SOURCE_OF_FUND,
        RELATIONSHIP,
        PURPOSE_OF_REMITTANCE	
	)
	SELECT
		@ACCESSCODE,
		@USERNAME,
		@PASSWORD,
		@FOREX_SESSION_ID,
		@AGENT_TXN_REF_ID,		
		@SENDER_NAME,		
		@SENDER_ADDRESS,
		@SENDER_MOBILE,
		@SENDER_CITY,
		@SENDER_COUNTRY,
		@SENDERS_IDENTITY_TYPE,
		@SENDER_IDENTITY_NUMBER,		
		@RECEIVER_NAME,
		@RECEIVER_ADDRESS,
		@RECEIVER_CONTACT_NUMBER,
		@RECEIVER_CITY,
		@RECEIVER_COUNTRY,
		@COLLECT_AMT,
		@COLLECT_AMT,
		@PAYOUTAMT,
		@PAYMENTTYPE,
		@BANKID,
		@BANK_ACCOUNT_NUMBER,
		@CALC_BY,		
		@BANK_NAME,
		@BANK_BRANCH_NAME,		
		GETDATE(),
		@OCCUPATION,
        @SOURCE_OF_FUND,
        @RELATIONSHIP,
        @PURPOSE_OF_REMITTANCE	
	
	
	SET @apiRequestId = SCOPE_IDENTITY()	
	
	SET @SENDER_NAME = UPPER(@SENDER_NAME)
	SET @RECEIVER_NAME = UPPER(@RECEIVER_NAME)
		
	DECLARE 
		 @sCountryId INT,@sCountry VARCHAR(50),@collCurr  VARCHAR(3), @sSuperAgent INT
		,@sSuperAgentName VARCHAR(200),@pBankName VARCHAR(200),@sAgent INT 
		,@sAgentName	VARCHAR(200), @sBranch INT,@sBranchName VARCHAR(200)
		,@deliveryMethod VARCHAR(100), @deliveryMethodId INT,@pCountryId INT, @pCurr VARCHAR(3)
		,@pSuperAgent INT,@pSuperAgentName VARCHAR(200), @pAgent INT,@pAgentName VARCHAR(200)
		,@pBranch INT,@pBranchName VARCHAR(200),@pBankBranchName VARCHAR(200)		
		,@controlNo VARCHAR(50),@tranId INT
		
	----# EXTRA THIRDPARTY AGENTS
	DECLARE @MTradeMalaysia INT = 9560

	SELECT @pSuperAgent = 000,@pSuperAgentName = 'Intl Payout Super Agent',@pCountryId= 151
	
	DECLARE @errorTable TABLE(
		 AGENT_TXN_REF_ID VARCHAR(150), REFNO VARCHAR(50), AGENT_TXNID INT, COLLECT_AMT MONEY, COLLECT_CURRENCY VARCHAR(3), EXCHANGE_RATE MONEY
		,SERVICE_CHARGE MONEY, PAYOUTAMT MONEY, PAYOUTCURRENCY VARCHAR(3), TXN_DATE	VARCHAR(10)
	)
	--SELECT @agentApiType = agentApiType	FROM agentMaster WITH(NOLOCK) WHERE agentCode = @ACCESSCODE
	INSERT INTO @errorTable(AGENT_TXN_REF_ID) 
	SELECT @AGENT_TXN_REF_ID
	
	DECLARE @errCode INT, @autMsg	VARCHAR(500), @errorCode VARCHAR(10), @errorMsg VARCHAR(MAX)
	EXEC ws_int_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT, @autMsg OUT
	
	IF (@errCode = 1 )
	BEGIN     --1002
		SELECT @errorCode = '102', @errorMsg = ISNULL(@autMsg, 'Authentication Fail')
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @USERNAME AND forceChangePwd = 'Y')
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'You logged on first time,must first change your password and try again!'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	-->>------------------VALIDATION-------------------------------
	IF @FOREX_SESSION_ID IS NULL
	BEGIN		--1001
		SELECT @errorCode = '102', @errorMsg = 'FOREX SESSION ID Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @AGENT_TXN_REF_ID IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'AGENT TXN REF ID Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN;
	END	

	IF @SENDER_NAME IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'SENDER NAME Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @SENDER_COUNTRY IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'SENDER COUNTRY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @RECEIVER_NAME IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'RECEIVER NAME Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @RECEIVER_ADDRESS IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'RECEIVER ADDRESS Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @RECEIVER_COUNTRY IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'RECEIVER COUNTRY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END

	IF @COLLECT_AMT IS NULL AND @PAYOUTAMT IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'Both COLLECT AMT and PAYOUTAMT Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @CALC_BY = 'P'
	BEGIN
		IF @PAYOUTAMT IS NULL
		BEGIN
			SET @CALC_BY = 'C' 			
		END
	END

	IF @CALC_BY = 'C' 
	BEGIN
		IF @COLLECT_AMT IS NULL
		BEGIN
			SELECT @errorCode = '102', @errorMsg = 'COLLECT AMT Field is Empty'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
	END
	 	
	IF ISNUMERIC(@COLLECT_AMT) = 0 AND @COLLECT_AMT IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: TRANSFER AMOUNT must be numeric'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF ISNUMERIC(@REMITTER_ID) = 0 AND @REMITTER_ID IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: REMITTER ID must be numeric'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF ISNUMERIC(@BANKID) = 0 AND @BANKID IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: BANK ID must be numeric'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
		
	IF @PAYMENTTYPE IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'PAYMENT TYPE Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @CALC_BY IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'CALC BY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @PAYMENTTYPE NOT IN('C','B')
	BEGIN
		SELECT @errorCode = '205', @errorMsg = 'Invalid Payment Type, Must be C - Cash Pickup OR B - Account Deposit to Bank'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @PAYMENTTYPE = 'B'
	BEGIN	
		IF ISNUMERIC(@BANKID) = 0
		BEGIN
			SELECT @errorCode = '9001', @errorMsg = 'Provided Bank ID can not perform Account Deposit'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		
		IF @BANK_ACCOUNT_NUMBER IS NULL
		BEGIN
			SELECT @errorCode = '9001', @errorMsg = 'BANK ACCOUNT NUMBER field is empty'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
	
		IF ISNUMERIC(@BANK_ACCOUNT_NUMBER)=0 
		BEGIN
			SELECT @errorCode = '9001', @errorMsg = 'Technical Error: BANK ACCOUNT NUMBER must be numeric'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
	END
	
	IF @CALC_BY NOT IN('C','P')
	BEGIN
		SELECT @errorCode = '104', @errorMsg = 'Invalid Parameter CALC BY'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	-->>Agent who supplies their own ICN
	DECLARE @WORLDCOMFINANCE INT = 4907
	--<<End of Agent who supplies their own ICN

	-->>Get Sending Agent Details

	SELECT 
		@sCountryId = countryId, 
		@sBranch = sb.agentId,
		@sBranchName = sb.agentName,
		@sAgent = sa.agentId,
		@sAgentName = sa.agentName,		
		@sSuperAgent = ssa.agentId,
		@sSuperAgentName = ssa.agentName
	FROM applicationUsers au WITH (NOLOCK) 
	LEFT JOIN agentMaster sb WITH (NOLOCK) ON au.agentId = sb.agentId 
	LEFT JOIN agentMaster sa WITH (NOLOCK) ON sa.agentId = sb.parentId 
	LEFT JOIN agentMaster ssa WITH (NOLOCK) ON ssa.agentId = sa.parentId	
	WHERE userName = @USERNAME
		AND ISNULL(au.isActive,'N')='Y'
		AND ISNULL(sb.isActive,'N')='Y'
		AND ISNULL(sa.isActive,'N')='Y'
		AND ISNULL(ssa.isActive,'N')='Y'
		

	--SELECT @sCountryId,@sBranch,@sBranchName,@sAgent,@sAgentName,@sSuperAgent,@sSuperAgentName
	--RETURN

	SELECT TOP 1 
		@collCurr = CM.currencyCode,
		@sCountry = C.countryName 
	FROM countryCurrency CC WITH (NOLOCK)
	INNER JOIN countryMaster C WITH(NOLOCK ) ON C.countryId = CC.countryId
	INNER JOIN  currencyMaster CM WITH(NOLOCK) ON CC.currencyId = CM.currencyId
	WHERE CC.countryId = @sCountryId AND ISNULL(Cc.isDeleted,'N') = 'N'
	
	--<<End of Get Sending Agent Details
	
	DECLARE @Excurr varchar(5)
	SELECT @Excurr = cCurrency FROM exRateTreasury(NOLOCK) WHERE CAGENT = @sAgent

	IF @Excurr <> @collCurr
		SET @collCurr = @Excurr

	-->>Get Payout Agent Details--
	DECLARE 
		  @pBank INT,@pBankBranch INT
		 ,@pBankType CHAR(1)
		 ,@pBankCountry VARCHAR(100) = 'Nepal'
		 ,@EXTERNALCODE VARCHAR(50)		 

	IF @PAYMENTTYPE = 'B'
	BEGIN
		DECLARE @parentMapCode VARCHAR(50)

		SELECT @pAgent = parentId, @pBankBranchName = agentName FROM dbo.agentMaster WITH(NOLOCK) WHERE agentId = @BANKID
		
		IF NOT EXISTS (SELECT 'X' FROM dbo.agentMaster WITH(NOLOCK) WHERE agentId = @BANKID AND agentType = '2904')
		BEGIN
		    SELECT @errorCode = '102', @errorMsg = 'Invalid BANK ID'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN 
		END

		IF EXISTS (SELECT 'X' FROM dbo.agentMaster WITH(NOLOCK) WHERE agentId = @pAgent AND ISNULL(IsIntl, 0) = 0)
		BEGIN
		    SELECT @errorCode = '102', @errorMsg = 'Invalid BANK ID'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN 
		END

		SELECT @pBank = @pAgent, @pBankName = agentName FROM dbo.agentMaster WITH(NOLOCK) WHERE agentId = @pAgent

		SET @pBranch = @BANKID
		SET @pBankBranch = @BANKID
		SET @pAgentName = @pBankName
		SET @pBranchName = @pBankBranchName

		

		--SELECT TOP 1 @parentMapCode = pam.mapCodeInt, @pBankBranchName = am.agentName FROM agentMaster am WITH(NOLOCK)
		--INNER JOIN agentMaster pam WITH(NOLOCK) ON am.parentId = pam.agentId 
		--WHERE am.mapCodeInt = @BANKID
		
		--SELECT TOP 1 
		--	@pBank = extBankId, @pBankName = bankName, @EXTERNALCODE = externalCode
		--FROM externalBank WITH(NOLOCK) 
		--WHERE mapCodeInt = @parentMapCode AND ISNULL(isDeleted, 'N') = 'N'
						
		--SELECT			 
		--	 @pBankName = ISNULL(@pBankName, @BANK_NAME)	
		--	,@pBankType = 'E'	
		
		--IF @pBank IS NULL AND ISNUMERIC(@BANKID) = 1
		--BEGIN
		--	SELECT @pBank = extBankId, @pBankBranch = extBranchId, @pBankBranchName = branchName FROM externalBankBranch WITH(NOLOCK) WHERE extBranchId = @BANKID
		--	SELECT @pBankName = bankName, @EXTERNALCODE = externalCode FROM externalBank WITH(NOLOCK) WHERE extBankId = @pBank
		--END
		

		--IF @PAYMENTTYPE = 'B'
		--BEGIN
		--	SELECT TOP 1 @pAgent = internalCode, @pAgentName = bankName FROM externalBank WITH(NOLOCK) WHERE extBankId = @pBank
		--	SELECT @pBranchName = ISNULL(@pBankBranchName, @BANK_BRANCH_NAME)
		--END
		-->>Validate BANK_ID only for Bank Transfer and Account Deposit
		IF @pBank IS NULL
		BEGIN
			SELECT @errorCode = '102', @errorMsg = 'Invalid BANK ID'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN 
		END
	END	

	DECLARE @currDecimal INT
	SELECT TOP 1 
		 @currDecimal = CM.countAfterDecimal 
		,@pCurr = 'NPR'
	FROM countryCurrency CC WITH(NOLOCK)
	INNER JOIN currencyMaster CM WITH(NOLOCK) ON CC.currencyId = CM.currencyId
	WHERE CC.countryId = @pCountryId AND ISNULL(cc.isDeleted, 'N') = 'N'
	
	IF @pCurr IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'You are not allowed to send to country ' + @RECEIVER_COUNTRY
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	--<<End of Get Payout Agent Details
	
	--IF EXISTS (
	--	SELECT 
	--		'x' 
	--	FROM exRateCalcHistory WITH(NOLOCK) 
	--	WHERE FOREX_SESSION_ID = @FOREX_SESSION_ID 
	--	AND isExpired = 'U'
	--)
	--BEGIN
	--	SELECT 
	--		302 CODE
	--		,'Your FOREX SESSION ID is Already used' MESSAGE
	--		,* 
	--	FROM @errorTable
	--	RETURN
	--END


	--IF EXISTS (
	--	SELECT 
	--		'x' 
	--	FROM exRateCalcHistory WITH(NOLOCK) 
	--	WHERE FOREX_SESSION_ID = @FOREX_SESSION_ID 
	--		AND (isExpired = 'N' OR isExpired IS NULL) 
	--		AND createdDate < DATEADD(MINUTE,-5,GETDATE())
	--)
	--BEGIN
	--	SELECT 
	--		302 CODE
	--		,'FOREX SESSION ID Expired' MESSAGE
	--		,* 
	--	FROM @errorTable
	--	RETURN		
	--END
	
	-------------------END ----------------------------------	
	-->>Manage Payment Type
	SELECT 
		@deliveryMethodId  = serviceTypeId, 
		@deliveryMethod = typeTitle  
	FROM serviceTypeMaster WITH(NOLOCK) 
	WHERE ISNULL(isDeleted,'N') = 'N'
	AND typeTitle = CASE	
						WHEN @PAYMENTTYPE = 'C' THEN 'CASH PAYMENT'
						WHEN @PAYMENTTYPE = 'B' THEN 'BANK DEPOSIT'
							
					END 
	
	-->>Start:Field Validation according to setup
	DECLARE @errTable TABLE(errorCode VARCHAR(10), msg VARCHAR(200), id VARCHAR(10))
	
	
	INSERT INTO @errTable(errorCode, msg, id)
	EXEC proc_sendValidation
		 @agentId				= @sAgent
		,@senIdType				= @SENDERS_IDENTITY_TYPE
		,@senIdNo				= @SENDER_IDENTITY_NUMBER
		--,@senIdValidDate		= @SENDER_ID_EXPIRE_DATE
		--,@senDob				= @SENDER_DATE_OF_BIRTH
		,@senAddress			= @SENDER_ADDRESS
		,@senCity				= @SENDER_CITY
		,@senContact			= @SENDER_MOBILE
		,@recAddress			= @RECEIVER_ADDRESS
		,@recCity				= @RECEIVER_CITY
		,@recContact			= @RECEIVER_CONTACT_NUMBER
		,@paymentMethod			= @deliveryMethod
		,@deliveryMethodId		= @deliveryMethodId
		,@pBank					= @pBank
		,@pBankBranchName		= @pBankBranchName
		,@accountNo				= @BANK_ACCOUNT_NUMBER
		,@pAgent				= 99999
		,@pBankType				= @pBankType
		,@pCountryId			= @pCountryId
		,@sCountryId			= @sCountryId
	
	
	IF NOT EXISTS(SELECT 'X' FROM @errTable WHERE errorCode = '0')
	BEGIN
		DECLARE @msg VARCHAR(200)
		SELECT @msg = msg FROM @errTable
		SELECT @errorCode = '1001', @errorMsg = @msg
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	--<<End:Field Validation according to Setup
		
	DECLARE @collMode VARCHAR(20),@iCollDetailAmt MONEY
	SET @collMode = 'Cash'
			
	DECLARE @iServiceCharge MONEY,@tAmt MONEY,@pAmt MONEY,@cAmt MONEY
	DECLARE @rowId INT, @place INT
				
	-->>Find Decimal Mask for payout amount rounding
	SELECT @place = place, @currDecimal = currDecimal
	FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N'
	AND currency = @pCurr AND tranType IS NULL
	
	-->>Start:Get Exchange Rate Details
	DECLARE @customerRate MONEY,@sCurrCostRate MONEY,@sCurrHoMargin MONEY,@sCurrAgentMargin MONEY,@pCurrCostRate MONEY,@pCurrHoMargin MONEY
	,@pCurrAgentMargin MONEY,@agentCrossSettRate MONEY,@treasuryTolerance MONEY,@sharingValue MONEY,@sharingType CHAR(1),@customerPremium MONEY
	,@sAgentComm MONEY,@sAgentCommCurrency VARCHAR(3)
	,@date varchar(20) = cast(getdate() as date)
	
	
	IF @sAgent = @MTradeMalaysia  ----## FOR MTRADE ASIA
	BEGIN
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
		--SET @customerRate = 107
		IF @customerRate IS NULL 
		BEGIN
			SELECT '102' CODE, 'Ex-Rate Not Defined for Receiving Currency (' + @pCurr + ')' MESSAGE, * FROM @errorTable
			RETURN
		END

		SET @CALC_BY = 'P'	
	END

	ELSE
	BEGIN
		IF NOT EXISTS ( SELECT 'x' FROM exRateCalcHistory WITH(NOLOCK) WHERE FOREX_SESSION_ID = @FOREX_SESSION_ID AND USER_ID = @USERNAME)
		BEGIN
			SELECT @errorCode = '302', @errorMsg = 'Invalid FOREX SESSION ID OR Parameter miss matched'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		ELSE
		BEGIN		 
			SELECT top 1
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
			FROM exRateCalcHistory WITH(NOLOCK) 
			WHERE FOREX_SESSION_ID = @FOREX_SESSION_ID 
				AND USER_ID = @USERNAME
				--AND CreatedDate BETWEEN @date AND  @date +' 23:59'
				ORDER BY rowId DESC

		END		
	END		
	
				
	IF @customerRate IS NULL
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'Transaction cannot be proceed. Exchange Rate not defined'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	--<<End:Get Exchange Rate Details
	
	-->>Start:Get tAmt, cAmt, pAmt on the basis of CALCBY
	SELECT 
		 @cAmt = CASE WHEN @CALC_BY = 'C' THEN CAST(@COLLECT_AMT AS MONEY) ELSE '0' END
		,@pAmt = CASE WHEN @CALC_BY = 'P' THEN CAST(@PAYOUTAMT AS MONEY) ELSE '0' END
	
	SET @pAmt = dbo.FNARemitRoundForNPR(@pAmt)
	DECLARE @scDiscount MONEY
	
	IF ISNULL(@cAmt, 0.00) <> 0.00  AND @CALC_BY = 'C'
	BEGIN
		SELECT 
			@iServiceCharge = amount 
		FROM [dbo].FNAGetServiceCharge(
			@sCountryId, @sSuperAgent, @sAgent, @sBranch 
			,@pCountryId, NULL, @pAgent, NULL 
			,@deliveryMethodId, @cAmt, @collCurr
		)


		IF @iServiceCharge IS NULL 
		BEGIN
			SELECT @errorCode = '102', @errorMsg = 'Service Charge Not Defined for Receiving Country'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN;
		END
		
		--Nepal Relief Fund
		--IF @pCountryId = 151 AND @sAgent IN (4880)
		--BEGIN
		--	SET @scDiscount = @iServiceCharge
		--	SET @iServiceCharge = 0
		--END
		
		SET @tAmt = @cAmt - @iServiceCharge		
		SET @pAmt = @tAmt * @customerRate
		SET @pAmt = dbo.FNARemitRoundForNPR(@pAmt)
		/*
		SET @currDecimal = ISNULL(@currDecimal, 0)
		IF @currDecimal IS NOT NULL
		BEGIN
			SET @pAmt = ROUND(@pAmt, @currDecimal, 1)
		END
		ELSE IF @place IS NOT NULL
		BEGIN
			SET @pAmt = ROUND(@pAmt, -@place, 1)
		END
		*/
	END
	ELSE
	BEGIN
		SET @tAmt = @pAmt/(@customerRate)

		SELECT
			@iServiceCharge = amount 
		FROM [dbo].FNAGetServiceCharge(
				 @sCountryId, @sSuperAgent, @sAgent, NULL 
				,@pCountryId, NULL, @pAgent, NULL 
				,@deliveryMethodId, @tAmt, @collCurr
		)

		IF @sAgent = @MTradeMalaysia 
		BEGIN
			SELECT 
				@iServiceCharge = amount 
			FROM [dbo].FNAGetServiceCharge(
				@sCountryId, @sSuperAgent, @sAgent, @sBranch 
				,@pCountryId, NULL, @pAgent, NULL 
				,@deliveryMethodId, @tAmt, @collCurr
			)
		END

		IF @iServiceCharge IS NULL 
		BEGIN
			SELECT @errorCode = '102', @errorMsg = 'Service Charge Not Defined for Receiving Country'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		
		--IF @pCountryId = 151 AND @sAgent IN (4880)
		--BEGIN
		--	SET @scDiscount = @iServiceCharge
		--	SET @iServiceCharge = 0
		--END
		
		SET @cAmt = (@tAmt + @iServiceCharge)
	END
	
	--SELECT @errorCode CODE, @iServiceCharge MESSAGE, * FROM @errorTable
	--RETURN;

	IF ISNULL(@iServiceCharge,0) >= ISNULL(@cAmt,0)
	BEGIN
		SELECT @errorCode = '102', @errorMsg = 'Sent Amount must be more than Service Charge'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN;
	END

	--<<End:Get tAmt, cAmt, pAmt on the basis of CALCBY	
	--SET @pAmt = ROUND(@pAmt, 0, 1)	
	-->>Start:Commission Calculation
	DECLARE @sSettlementRate FLOAT, @pSettlementRate FLOAT,@tellerBalance MONEY
	SET @sSettlementRate = @sCurrCostRate + @sCurrHoMargin
	SET @pSettlementRate = @pCurrCostRate - @pCurrHoMargin
	
	SELECT 
		@sAgentComm = amount, 
		@sAgentCommCurrency = commissionCurrency 
	FROM dbo.FNAGetSendComm(
		@sCountryId, @sSuperAgent, @sAgent, @sBranch,
		@pCountryId, @pSuperAgent, @pAgent, @pBranch,
		@collCurr, @deliveryMethodId, @cAmt, @pAmt, @iServiceCharge, NULL, NULL,
		@sSettlementRate, @pSettlementRate
	)
	--Nepal Relief Fund
	--IF @pCountryId = 151 AND @sAgent IN (4880)
	--BEGIN
	--	SET @sAgentComm = 0
	--END
	--<<End:Commission Calculation
	
	-->>Start:Verify Agent Send Per Txn
	IF EXISTS(
		SELECT 
			'x' 
		FROM sendTranLimit
			WHERE agentId = @sAgent
				AND ISNULL(receivingCountry, ISNULL(@pCountryId, 0)) = ISNULL(@pCountryId, 0)
				AND ISNULL(tranType, ISNULL(@deliveryMethodId, 0)) = ISNULL(@deliveryMethodId, 0)
				AND currency = @collCurr AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
	)
	BEGIN
		IF EXISTS(
			SELECT 
				'x' FROM sendTranLimit WITH(NOLOCK) WHERE agentId = @sAgent AND receivingCountry = @pCountryId 
					AND tranType = @deliveryMethodId AND currency = @collCurr 
					AND @cAmt < minLimitAmt
					AND @cAmt > maxLimitAmt
					AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(
			SELECT 
				'x' 
			FROM sendTranLimit WITH(NOLOCK) 
			WHERE agentId = @sAgent AND receivingCountry = @pCountryId 
					AND tranType IS NULL AND currency = @collCurr 
					AND @cAmt < minLimitAmt
					AND @cAmt > maxLimitAmt
					AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		)
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(
			SELECT 
				'x' 
			FROM sendTranLimit WITH(NOLOCK) 
			WHERE agentId IS NULL AND receivingCountry = @pCountryId 
					AND tranType = @deliveryMethodId AND currency = @collCurr 
					AND @cAmt < minLimitAmt
					AND @cAmt > maxLimitAmt
					AND ISNULL(isActive, 'N') = 'Y' 
					AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE agentId = @sAgent AND receivingCountry = @pCountryId 
					AND tranType IS NULL AND currency = @collCurr 
					AND @cAmt < minLimitAmt
					AND @cAmt > maxLimitAmt
					AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
	END
	--<<End:Verify Agent Send Per Txn
		
	-->>Start:Verify Payout Per Txn Limit
	IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE ISNULL(sendingCountry, ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId, 0)
				AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr 
				AND ISNULL(tranType, ISNULL(@deliveryMethodId, 0)) = ISNULL(@deliveryMethodId, 0)
				AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
	BEGIN
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE sendingCountry = @sCountryId AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr 
					AND tranType = @deliveryMethodId AND @pAmt > maxLimitAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Payout Amount Limit Exceed'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE sendingCountry = @sCountryId AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr 
					AND tranType IS NULL AND @pAmt > maxLimitAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Payout Amount Limit Exceed'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr 
					AND tranType = @deliveryMethodId AND @pAmt > maxLimitAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Payout Amount Limit Exceed'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr
					AND tranType IS NULL AND @pAmt > maxLimitAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
		BEGIN
			SELECT @errorCode = '104', @errorMsg = 'Payout Amount Limit Exceed'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
	END
	
	IF NOT EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE ISNULL(sendingCountry, ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId, 0)
					AND agentId IS NULL AND countryId = @pCountryId AND currency = @pCurr
					AND ISNULL(tranType, ISNULL(@deliveryMethodId, 0)) = ISNULL(@deliveryMethodId, 0)
					AND maxLimitAmt >= @pAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
	BEGIN
		SELECT @errorCode = '104', @errorMsg = 'Payout Amount Limit Exceed'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	-->>End:Verify Payout Per Txn Limit	
	DECLARE @remarks VARCHAR(500)
	IF EXISTS(SELECT TOP 1 'X' FROM thirdPartyAgentTxnIdV2 WITH(NOLOCK) WHERE agentTxnId = @AGENT_TXN_REF_ID AND agentId = @sAgent)
	BEGIN
		SELECT TOP 1 @controlNo = controlNo FROM remitTran (NOLOCK) WHERE controlNo2 =  dbo.FNAEncryptString(@AGENT_TXN_REF_ID) AND sAgent = @sAgent -- AND createdBy = @USERNAME
		SELECT @errorCode = '1001', @errorMsg = 'Duplicate Ref ID : ' + @AGENT_TXN_REF_ID + '; ICN : ' + dbo.FNADecryptString(@controlNo)
		EXEC ws_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks

		SELECT TOP 1 
			 CODE					= @errorCode 			
			,AGENT_TXN_REF_ID		= @AGENT_TXN_REF_ID 
			,MESSAGE				= @errorMsg
			,REFNO					= dbo.FNADecryptString(@controlNo)
			--,AGENT_TXNID			= 1
			,COLLECT_AMT			= cAmt
			--,COLLECT_CURRENCY		= collCurr
			,EXCHANGE_RATE					= customerRate
			,SERVICE_CHARGE			= serviceCharge
			,PAYOUTAMT				= pAmt
			,PAYOUTCURRENCY			= payoutCurr 
			--,TXN_DATE				= createdDate
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNo

		--SELECT	
		--	 CODE					=  '0'
		--	,AGENT_TXN_REF_ID		= @AGENT_TXN_REF_ID 
		--	,MESSAGE				= 'Transaction created Successfully'--CASE WHEN @AUTHORIZED_REQUIRED='Y' THEN 'Transaction need Authorization' ELSE 'Transaction saved successfully' END 
		--	,REFNO					= @controlNo
		--	--,AGENT_TXNID			= 1
		--	,COLLECT_AMT			= cAmt
		--	--,COLLECT_CURRENCY		= collCurr
		--	,EXCHANGE_RATE			= customerRate
		--	,SERVICE_CHARGE			= serviceCharge
		--	,PAYOUTAMT				= pAmt
		--	,PAYOUTCURRENCY			= payoutCurr 
		--	--,TXN_DATE				= createdDate
		--FROM remitTran WITH(NOLOCK)
		--WHERE id = @tranId		



		RETURN
	END


	-->>Start:Get Data Compliance for Compliance Checking and suspicious duplicate txn
	DECLARE @today VARCHAR(10) = CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USERNAME), 101)
	DECLARE @remitTranTemp TABLE(tranId BIGINT, controlNo VARCHAR(20), cAmt MONEY, receiverName VARCHAR(200), receiverIdType VARCHAR(100), receiverIdNumber VARCHAR(50), dot DATETIME)
	
	INSERT INTO @remitTranTemp(tranId, controlNo, cAmt, receiverName, receiverIdType, receiverIdNumber, dot)
	SELECT rt.id, rt.controlNo, rt.cAmt, rt.receiverName, rec.idType, rec.idNumber, rt.createdDateLocal
	FROM vwRemitTran rt WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	WHERE sen.idNumber = @SENDER_IDENTITY_NUMBER 
	AND tranStatus <> 'CancelRequest' AND tranStatus <> 'Cancel'
	AND (rt.approvedDate BETWEEN @today AND @today + ' 23:59:59'
	OR (approvedBy IS NULL AND cancelApprovedBy IS NULL))
	
	IF EXISTS(SELECT 'X' FROM @remitTranTemp WHERE cAmt = @cAmt 
				AND (receiverName = @RECEIVER_NAME)
				AND DATEDIFF(MI, dot, GETDATE()) <= 5
			)
	BEGIN
		SELECT @errorCode = '206', @errorMsg = 'Similar transaction found'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	--<<End:Get Data Compliance for Compliance Checking and suspicious duplicate txn
		
	DECLARE @agentFxGain FLOAT
	SET @agentFxGain = (@tAmt * (@agentCrossSettRate - @customerRate))/@agentCrossSettRate
			
	-->>Start:OFAC/Compliance Checking
	DECLARE @receiverOfacRes VARCHAR(MAX),@ofacRes VARCHAR(MAX),@ofacReason VARCHAR(MAX)
	EXEC proc_ofacTracker @flag = 't', @name = @SENDER_NAME, @Result = @ofacRes OUTPUT
	EXEC proc_ofacTracker @flag = 't', @name = @RECEIVER_NAME, @Result = @receiverOfacRes OUTPUT
	
	DECLARE @result VARCHAR(MAX)
	DECLARE @csMasterId INT, @complianceRes VARCHAR(20), @totalRows INT, @count INT, @compFinalRes VARCHAR(20)
	DECLARE @csMasterRec TABLE (rowId INT IDENTITY(1,1), masterId INT)
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
	
	--INSERT @csMasterRec(masterId)
	--SELECT masterId FROM dbo.FNAGetComplianceRuleMaster(@sBranch, @pCountryId, NULL, @pBranch, NULL, NULL, NULL)
	--SELECT @totalRows = COUNT(*) FROM @csMasterRec
	
	--IF EXISTS(SELECT 'X' FROM @csMasterRec)
	--BEGIN
	--	SET @count = 1
	--	WHILE(@count <= @totalRows)
	--	BEGIN
	--		SELECT @csMasterId = masterId FROM @csMasterRec WHERE rowId = @count
	--		EXEC ws_int_proc_complianceRuleDetail 
	--			 @user				= @USERNAME
	--			,@tranId			= @tranId
	--			,@tAmt				= @tAmt
	--			,@senId				= NULL
	--			,@benId				= NULL
	--			,@beneficiaryName	= @RECEIVER_NAME
	--			,@beneficiaryMobile = @RECEIVER_CONTACT_NUMBER
	--			,@benAccountNo		= @BANK_ACCOUNT_NUMBER
	--			,@masterId			= @csMasterId
	--			,@paymentMethod		= @deliveryMethodId
	--			,@checkingFor		= 'v'
	--			,@agentRefId		= @AGENT_TXN_REF_ID
	--			,@result			= @complianceRes OUTPUT
	--			,@senderId			= @SENDER_IDENTITY_NUMBER
	--			,@senderName		= @SENDER_NAME
	--			,@senderMobile		= @SENDER_MOBILE
	--		SET @compFinalRes = ISNULL(@compFinalRes, '') + ISNULL(@complianceRes, '')
	--		SET @count = @count + 1
	--	END
	--END

	
	--<<End:OFAC/Compliance Checking
	
	-->>Start:Control Number Generation		
	IF @sAgent = @MTradeMalaysia
	BEGIN
		IF LEFT(@AGENT_TXN_REF_ID, 4) <> '7001' OR LEN(@AGENT_TXN_REF_ID)<> 11
		BEGIN
			SELECT @errorCode = '102', @errorMsg = 'Invalid AGENT TXN REF ID. Must start with "7001" and must have 11 digits'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN;
		END

		SET @controlNo = @AGENT_TXN_REF_ID
		IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
		BEGIN
			SELECT @errorCode = '9001', @errorMsg = 'Technical error occurred. Duplicate AGENT TXN REF ID. Please try again'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
	END
	ELSE
	BEGIN
		SET @controlNo = '788' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '00000000', 8) 	
		--SET @controlNo = '9080' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
		IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
		BEGIN
			SET @controlNo = '788' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '00000000', 8) 
			IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
			BEGIN
				SELECT @errorCode = '9001', @errorMsg = 'Technical error occurred. Please try again'
				EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
				SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
				RETURN
			END
		END
	END
	
	DECLARE @controlNoEncrypted VARCHAR(50)
	SET @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)	
	--<<End:Control Number Generation
		
	BEGIN	
		BEGIN TRANSACTION	
		-->>Start:Data Insert into remitTran, tranSenders, tranReceivers
			INSERT INTO remitTran
			(
				 controlNo
				,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin,sAgentSettRate
				,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
				,agentCrossSettRate,customerRate,treasuryTolerance,customerPremium
				,sharingValue,serviceCharge, agentFxGain, handlingFee
				,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency
				,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName
				,pCountry,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName
				,paymentMethod
				,pBank,pBankName,pBankBranch,pBankBranchName,pBankType
				,accountNo,externalBankCode
				,collMode,collCurr,tAmt,cAmt,pAmt,payoutCurr
				,tranStatus
				,payStatus
				,createdDate,createdDateLocal,createdBy
				,approvedDate,approvedDateLocal,approvedBy
				,tranType
				,senderName,receiverName,controlNo2
				,sourceOfFund, relWithSender, purposeOfRemit
			)


			SELECT 
				 @controlNoEncrypted
				,@sCurrCostRate,@sCurrHoMargin,@sCurrAgentMargin,@sSettlementRate
				,@pCurrCostRate,@pCurrHoMargin,@pCurrAgentMargin
				,@agentCrossSettRate,@customerRate,@treasuryTolerance,@customerPremium
				,@sharingValue,@iServiceCharge,@agentFxGain, ISNULL(@scDiscount, 0)
				,@sAgentComm,@sAgentCommCurrency,0,@sAgentCommCurrency
				,@sCountry,@sSuperAgent,@sSuperAgentName,@sAgent,@sAgentName,@sBranch,@sBranchName
				,@RECEIVER_COUNTRY,@pSuperAgent,@pSuperAgentName,@pAgent,@pAgentName,@pBranch,@pBranchName
				,@deliveryMethod
				,@pBank,@pBankName,@pBankBranch,ISNULL(@pBankBranchName, @BANK_BRANCH_NAME),@pBankType
				,@BANK_ACCOUNT_NUMBER,@EXTERNALCODE
				,@collMode,@collCurr,@tAmt,@cAmt,@pAmt,@pCurr
				,'Payment'
				,'Unpaid'
				,dbo.FNADateFormatTZ(GETDATE(),@USERNAME),GETDATE(),@USERNAME
				,dbo.FNADateFormatTZ(GETDATE(),@USERNAME),GETDATE(),@USERNAME
				,'I'
				,@SENDER_NAME,@RECEIVER_NAME, dbo.FNAEncryptString(@AGENT_TXN_REF_ID)
				, @SOURCE_OF_FUND, @RELATIONSHIP, @PURPOSE_OF_REMITTANCE
						
			SET @tranId = SCOPE_IDENTITY()
			
			DECLARE @sFirstName VARCHAR(100),@sMiddleName VARCHAR(100),@sLastName VARCHAR(100),@sLastName2 VARCHAR(100)
			DECLARE @rFirstName VARCHAR(100),@rMiddleName VARCHAR(100),@rLastName VARCHAR(100),@rLastName2 VARCHAR(100)
			
			SELECT @sFirstName = firstName, @sMiddleName = middleName, @sLastName = lastName1, @sLastName2 = lastName2 FROM dbo.FNASplitName(@SENDER_NAME)
			SELECT @rFirstName = firstName, @rMiddleName = middleName, @rLastName = lastName1, @rLastName2 = lastName2 FROM dbo.FNASplitName(@RECEIVER_NAME)
			DECLARE @memberCode VARCHAR(50),@senderId INT,@sIdTypeId INT
			
			SELECT @senderId = C.customerId FROM customers C WITH (NOLOCK) INNER JOIN customerIdentity CI WITH (NOLOCK) ON C.customerId = CI.customerId
				INNER JOIN staticDataValue SV WITH (NOLOCK) ON CI.idType = SV.valueId WHERE SV.detailTitle = @SENDERS_IDENTITY_TYPE AND CI.idNumber = @SENDER_IDENTITY_NUMBER
			
			
			INSERT INTO tranSenders
			(
				 customerId
				,membershipId
				,tranId
				,firstName,middleName,lastName1,lastName2,fullName
				,country,city,address,homePhone,mobile
				,idType,idNumber
				--,issuedDate,validDate,dob
				,occupation
				
			)
			SELECT
				 @senderId
				,@REMITTER_ID
				,@tranId
				,@sFirstName,@sMiddleName,@sLastName,@sLastName2,@SENDER_NAME	
				,@sCountry,@SENDER_CITY,@SENDER_ADDRESS,@SENDER_MOBILE,@SENDER_MOBILE
				,@SENDERS_IDENTITY_TYPE,@SENDER_IDENTITY_NUMBER
				--,@SENDER_ID_ISSUE_DATE,@SENDER_ID_EXPIRE_DATE,@SENDER_DATE_OF_BIRTH
				,@OCCUPATION

				
			INSERT INTO tranReceivers
			(
				 tranId
				,firstName,middleName,lastName1,lastName2,fullName
				,city,address,homePhone,workPhone,country
			)		
			SELECT 
				 @tranId
				,@rFirstName,@rMiddleName,@rLastName,@rLastName2,@RECEIVER_NAME		
				,@RECEIVER_CITY,@RECEIVER_ADDRESS,@RECEIVER_CONTACT_NUMBER,@RECEIVER_CONTACT_NUMBER,@RECEIVER_COUNTRY
		-->>End:Data Insert into remitTran, tranSenders, tranReceivers
		
		INSERT INTO controlNoList(controlNo)
		SELECT @controlNo
			
		INSERT INTO thirdPartyAgentTxnIdV2(agentTxnId, agentId)
		SELECT @AGENT_TXN_REF_ID, @sAgent

		-->>Start:Verify Compliance
		IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @AGENT_TXN_REF_ID)
		BEGIN
			INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
			SELECT @tranId, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @AGENT_TXN_REF_ID
			SET @compFinalRes = 'C'
		END
		
		IF EXISTS(
			SELECT 'X' 
			FROM @remitTranTemp 
			WHERE dot BETWEEN CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USERNAME), 101) 
				AND CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USERNAME), 101) + ' 23:59:59' AND cAmt = @cAmt 
				AND (receiverName = @RECEIVER_NAME)
		)
		BEGIN
			INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId, reason)
			SELECT @tranId, 0, tranid, 'Suspected duplicate transaction' FROM @remitTranTemp WHERE cAmt = @cAmt AND (receiverName = @RECEIVER_NAME)
			SET @compFinalRes = 'C'
		END	

		IF(ISNULL(@compFinalRes, '') <> '' OR ISNULL(@ofacRes, '') <> '')
		BEGIN
			IF(@ofacRes <> '' AND ISNULL(@compFinalRes, '') = '')
			BEGIN
				INSERT remitTranOfac(TranId, blackListId, reason, flag)
				SELECT @tranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
				
				UPDATE remitTran SET
					 tranStatus			= 'OFAC'
					,approvedBy			= @USERNAME
					,approvedDate		= dbo.FNADateFormatTZ(GETDATE(), @USERNAME)
					,approvedDateLocal	= GETDATE()
				WHERE controlNo = @controlNoEncrypted
				
			END
			
			ELSE IF(@compFinalRes <> '' AND ISNULL(@ofacRes, '') = '')
			BEGIN
				UPDATE remitTran SET
					 tranStatus			= 'Compliance'
					,approvedBy			= @USERNAME
					,approvedDate		= dbo.FNADateFormatTZ(GETDATE(), @USERNAME)
					,approvedDateLocal	= GETDATE()
				WHERE controlNo = @controlNoEncrypted
			END
			
			
			ELSE IF(ISNULL(@compFinalRes, '') <> '' AND ISNULL(@ofacRes, '') <> '')
			BEGIN
				INSERT remitTranOfac(TranId, blackListId, reason, flag)
				SELECT @tranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
	
				BEGIN
					UPDATE remitTran SET
						 tranStatus			= 'OFAC/Compliance'
						,approvedBy			= @USERNAME
						,approvedDate		= dbo.FNADateFormatTZ(GETDATE(), @USERNAME)
						,approvedDateLocal	= GETDATE()
					WHERE controlNo = @controlNoEncrypted
				END
			END
		END
		
		--<<End:Verify Compliance
		UPDATE apiRequestLog SET 
			  errorCode = '0'
			 ,errorMsg = 'Transaction created successfully'
			 ,controlNo = @controlNo 
		WHERE rowId = @apiRequestId
		UPDATE exRateCalcHistory SET 
			isExpired = 'U'
		WHERE @FOREX_SESSION_ID = @FOREX_SESSION_ID


		INSERT INTO PinQueueList(ICN)
	     SELECT @controlNoEncrypted


		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		SELECT	
			 CODE					=  '0'
			,AGENT_TXN_REF_ID		= @AGENT_TXN_REF_ID 
			,MESSAGE				= 'Transaction created Successfully'--CASE WHEN @AUTHORIZED_REQUIRED='Y' THEN 'Transaction need Authorization' ELSE 'Transaction saved successfully' END 
			,REFNO					= @controlNo
			--,AGENT_TXNID			= 1
			,COLLECT_AMT			= cAmt
			--,COLLECT_CURRENCY		= collCurr
			,EXCHANGE_RATE			= customerRate
			,SERVICE_CHARGE			= serviceCharge
			,PAYOUTAMT				= pAmt
			,PAYOUTCURRENCY			= payoutCurr 
			--,TXN_DATE				= createdDate
		FROM remitTran WITH(NOLOCK)
		WHERE id = @tranId		

	END 
	
END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
ROLLBACK TRAN

SELECT @errorCode = '9001', @errorMsg = 'Technical Error : ' + ERROR_MESSAGE()
EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg

DECLARE @errorLogId BIGINT		
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_int_proc_CreateTXN', @USERNAME, GETDATE()
SET @errorLogId = SCOPE_IDENTITY()

SELECT '9001' CODE, 'Technical Error occurred, Error Log ID : ' + CAST(@errorLogId AS VARCHAR) MESSAGE, * FROM @errorTable

END CATCH
GO
