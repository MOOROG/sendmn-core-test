USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_SendTransaction_JP]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_int_proc_SendTransaction_JP] (	 
		@AGENT_CODE					VARCHAR(50),
		@USER_ID					VARCHAR(50),
		@PASSWORD					VARCHAR(50),
		@AGENT_SESSION_ID			VARCHAR(50),
		@AGENT_TXNID				VARCHAR(50) = NULL,
		@LOCATION_ID				VARCHAR(50),
		@SENDER_NAME				VARCHAR(50),
		@SENDER_GENDER				VARCHAR(50) = NULL,
		@SENDER_ADDRESS				VARCHAR(50),
		@SENDER_MOBILE				VARCHAR(50),
		@SENDER_CITY				VARCHAR(100),
		@SENDER_COUNTRY				VARCHAR(50),
		@SENDER_ID_TYPE				VARCHAR(50),
		@SENDER_ID_NUMBER			VARCHAR(50),
		@SENDER_ID_ISSUE_DATE		VARCHAR(50) = NULL,
		@SENDER_ID_EXPIRE_DATE		VARCHAR(50) = NULL,
		@SENDER_DATE_OF_BIRTH		VARCHAR(50) = NULL,
		@RECEIVER_NAME				VARCHAR(50),
		@RECEIVER_ADDRESS			VARCHAR(50),
		@RECEIVER_CONTACT_NUMBER	VARCHAR(50) = NULL,
		@RECEIVER_CITY				VARCHAR(50) = NULL,
		@RECEIVER_COUNTRY			VARCHAR(50),
		@TRANSFERAMOUNT				MONEY,
		@PAYMENTMODE				VARCHAR(50) ,
		@BANKID						VARCHAR(50) = NULL,
		@BANK_ACCOUNT_NUMBER		VARCHAR(50) = NULL,
		@CALC_BY					VARCHAR(50) ,		
		@OUR_SERVICE_CHARGE			MONEY		= NULL,
		@EXT_BANK_BRANCH_ID			VARCHAR(50)	= NULL,
		@RECEIVER_IDENTITY_TYPE		VARCHAR(50)	= NULL,
		@RECEIVER_IDENTITY_NUMBER	VARCHAR(50) = NULL,
		@BANK_NAME					VARCHAR(150) = NULL,
		@BANK_BRANCH_NAME			VARCHAR(150) = NULL,
		@PAYOUT_AGENT_ID			VARCHAR(50) = NULL
)

AS

/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_SendTransaction]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_SendTransaction
GO
	 EXEC ws_proc_SendTransaction @AGENT_CODE='IMEADE01',@USER_ID='apioo1',@PASSWORD='pralhad123',@AGENT_SESSION_ID='1231',@AGENT_TXNID='12',@LOCATION_ID=10200700
	,@SENDER_NAME='Pralhad Sedhai',@SENDER_ADDRESS='Menara jaya,KL',@SENDER_MOBILE='060123345671',@SENDER_CITY='kuala lampur',@SENDER_COUNTRY='Malaysia'
	,@SENDER_ID_TYPE='Passport',@SENDER_ID_NUMBER='05708477',@SENDER_ID_ISSUE_DATE='2012-12-12',@SENDER_ID_EXPIRE_DATE='2014-12-11',@SENDER_DATE_OF_BIRTH='1989-05-03'
	,@RECEIVER_NAME='Riwaj Rimal',@RECEIVER_ADDRESS='Kathmandu',@RECEIVER_CONTACT_NUMBER='9841234567',@RECEIVER_CITY='kathmandu',@RECEIVER_COUNTRY='Philipines'
	,@TRANSFERAMOUNT='12000',@PAYMENTMODE='C',@CALC_BY='P'	

*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

--select top 10 * from apiRequestLog

BEGIN TRY
	DECLARE @apiRequestId INT
	INSERT INTO apiRequestLog(
		USER_ID,
		PASSWORD,
		AGENT_SESSION_ID,
		AGENT_CODE,
		LOCATION_ID,
		SENDER_NAME,
		--SENDER_GENDER,
		SENDER_ADDRESS,
		SENDER_MOBILE,
		SENDER_CITY,
		SENDER_COUNTRY,
		SENDER_ID_TYPE,
		SENDER_ID_NUMBER,
		SENDER_ID_ISSUE_DATE,
		SENDER_ID_EXPIRE_DATE,
		SENDER_DATE_OF_BIRTH,
		RECEIVER_NAME,
		RECEIVER_ADDRESS,
		RECEIVER_CONTACT_NUMBER,
		RECEIVER_CITY,
		RECEIVER_COUNTRY,
		TRANSFER_AMOUNT,
		PAYMENT_MODE,
		BANK_ID,
		BANK_ACCOUNT_NUMBER,
		CALC_BY,
		AUTHORIZED_REQUIRED,
		OUR_SERVICE_CHARGE,
		EXT_BANK_BRANCH_ID,
		RECEIVER_IDENTITY_TYPE,
		RECEIVER_IDENTITY_NUMBER,
		BANK_NAME,
		BANK_BRANCH_NAME,
		PAYOUT_AGENT_ID,
		REQUESTED_DATE
	)
	SELECT
		@USER_ID,
		@PASSWORD,
		@AGENT_SESSION_ID,
		@AGENT_TXNID,
		@LOCATION_ID,
		@SENDER_NAME,
		----@SENDER_GENDER,
		@SENDER_ADDRESS,
		@SENDER_MOBILE,
		@SENDER_CITY,
		@SENDER_COUNTRY,
		@SENDER_ID_TYPE,
		@SENDER_ID_NUMBER,
		@SENDER_ID_ISSUE_DATE,
		@SENDER_ID_EXPIRE_DATE,
		@SENDER_DATE_OF_BIRTH,
		@RECEIVER_NAME,
		@RECEIVER_ADDRESS,
		@RECEIVER_CONTACT_NUMBER,
		@RECEIVER_CITY,
		@RECEIVER_COUNTRY,
		@TRANSFERAMOUNT,
		@PAYMENTMODE,
		@BANKID,
		@BANK_ACCOUNT_NUMBER,
		@CALC_BY,
		NULL,--@AUTHORIZED_REQUIRED,
		@OUR_SERVICE_CHARGE,
		@EXT_BANK_BRANCH_ID,
		@RECEIVER_IDENTITY_TYPE,
		@RECEIVER_IDENTITY_NUMBER,
		@BANK_NAME,
		@BANK_BRANCH_NAME,
		@PAYOUT_AGENT_ID,
		GETDATE()
	
	SET @apiRequestId = SCOPE_IDENTITY()
	
	IF @CALC_BY = 'C' SET @CALC_BY = 'S'
	
	SET @SENDER_NAME = UPPER(@SENDER_NAME)
	SET @RECEIVER_NAME = UPPER(@RECEIVER_NAME)
	DECLARE @controlNo VARCHAR(50),@tranId INT
	
	DECLARE 
			 @sCountryId INT,@sCountry VARCHAR(50),@collCurr  VARCHAR(3), @sSuperAgent INT,@sSuperAgentName VARCHAR(200),@pBankName VARCHAR(200)
			,@sAgent INT ,@sAgentName	VARCHAR(200), @sBranch INT,@sBranchName VARCHAR(200),@deliveryMethod VARCHAR(100), @deliveryMethodId INT
			,@pCountryId INT,@pCurr VARCHAR(3)
			,@pSuperAgent INT,@pSuperAgentName VARCHAR(200), @pAgent INT,@pAgentName VARCHAR(200), @pBranch INT,@pBranchName VARCHAR(200)
			,@pBankBranchName VARCHAR(200)
			,@EXTERNALCODE VARCHAR(200)
			,@agentApiType INT, @isItalianAgent BIT = 0, @isUAEAgent BIT = 0	
	DECLARE @errorTable TABLE(
		 AGENT_REFID VARCHAR(150), REFID VARCHAR(50), AGENT_TXNID INT, COLLECT_AMT MONEY, COLLECT_CURRENCY VARCHAR(3), EXRATE MONEY
		,SERVICE_CHARGE MONEY, PAYOUTAMT MONEY, PAYOUTCURRENCY VARCHAR(3), TXN_DATE	VARCHAR(10)
	)
	--SELECT @agentApiType = agentApiType	FROM agentMaster WITH(NOLOCK) WHERE agentCode = @AGENT_CODE
	INSERT INTO @errorTable(AGENT_REFID) 
	SELECT @AGENT_SESSION_ID
	
	DECLARE @errCode INT, @pBankBranch INT,  @autMsg VARCHAR(500), @errorCode VARCHAR(10), @errorMsg VARCHAR(MAX)
	EXEC ws_int_proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT, @autMsg OUT
	
		
	IF (@errCode = 1 )
	BEGIN
		SELECT @errorCode = '1002', @errorMsg = ISNULL(@autMsg, 'Authentication Fail')
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @USER_ID AND forceChangePwd = 'Y')
	BEGIN
		SELECT @errorCode = '1002', @errorMsg = 'You logged on first time,must first change your password and try again!'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	-->>------------------VALIDATION-------------------------------
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'AGENT SESSION ID Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @SENDER_NAME IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'SENDER NAME Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @SENDER_ADDRESS IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'SENDER ADDRESS Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @SENDER_CITY IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'SENDER CITY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @SENDER_COUNTRY IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'SENDER COUNTRY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @SENDER_ID_TYPE IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'SENDER ID TYPE Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @SENDER_ID_NUMBER IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'SENDER ID NUMBER Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @RECEIVER_NAME IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'RECEIVER NAME Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @RECEIVER_ADDRESS IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'RECEIVER ADDRESS Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @RECEIVER_COUNTRY IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'RECEIVER COUNTRY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @TRANSFERAMOUNT IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'TRANSFER AMOUNT Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF ISNUMERIC(@TRANSFERAMOUNT) = 0 AND @TRANSFERAMOUNT IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: TRANSFER AMOUNT must be numeric'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF ISNUMERIC(@LOCATION_ID) = 0 AND @LOCATION_ID IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: LOCATION ID must be numeric'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	--IF ISNUMERIC(@BANKID) = 0 AND @BANKID IS NOT NULL
	--BEGIN
	--	SELECT 9001 CODE, 'Technical Error: BANK ID must be numeric' MESSAGE, * FROM @errorTable
	--	RETURN
	--END

	IF ISDATE(@SENDER_DATE_OF_BIRTH) = 0 AND @SENDER_DATE_OF_BIRTH IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: DOB must be date'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF ISDATE(@SENDER_ID_EXPIRE_DATE) = 0 AND @SENDER_ID_EXPIRE_DATE IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: ID expiry date must be date'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF ISDATE(@SENDER_ID_ISSUE_DATE) = 0 AND @SENDER_ID_ISSUE_DATE IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: ID issue date must be date'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF DATEDIFF(D,@SENDER_ID_ISSUE_DATE,@SENDER_ID_EXPIRE_DATE)<0
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: ID expiry date must be more than issue date'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @PAYMENTMODE IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'PAYMETHOD Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @CALC_BY IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'CALC BY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @PAYMENTMODE NOT IN('C','B','CP', 'BP')
	BEGIN
		SELECT @errorCode = '3001', @errorMsg = 'Invalid Payment Type, Must be C - Cash Pickup  B - Bank Deposit.'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	DECLARE @promotionFlag CHAR(1)
	SET @promotionFlag = RIGHT(@PAYMENTMODE, 1)
	IF LEN(@PAYMENTMODE) > 1
		SET @PAYMENTMODE = LEFT(@PAYMENTMODE, LEN(@PAYMENTMODE) - 1)
		
	IF @CALC_BY NOT IN('S','P')
	BEGIN
		SELECT @errorCode = '1004', @errorMsg = 'Invalid Parameter CALC BY'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
		
	-->>Get Sending Agent Details
	SELECT @sCountryId = countryId, @sBranch = agentId FROM applicationUsers WITH (NOLOCK) WHERE userName = @USER_ID

	SELECT TOP 1 @collCurr = CM.currencyCode,@sCountry = C.countryName FROM countryCurrency CC WITH (NOLOCK)
	INNER JOIN countryMaster C WITH(NOLOCK ) ON C.countryId = CC.countryId
	INNER JOIN  currencyMaster CM WITH(NOLOCK) ON CC.currencyId = CM.currencyId
	 WHERE CC.countryId = @sCountryId AND ISNULL(Cc.isDeleted,'N') = 'N'

	-- DECLARE 
	--	  @pBank INT,@pBankBranch INT
	--	 ,@pBankType CHAR(1)
	--	 ,@pBankCountry VARCHAR(100) = 'Nepal'
	--	 ,@EXTERNALCODE VARCHAR(50)		 

	--SELECT
	--	 --@pAgent = 1251
	--	--,@pAgentName = 'International Money Express( IME) - HO'
	--	 @pSuperAgent = 1002
	--	,@pSuperAgentName = 'International Money Express (IME) Pvt. Ltd'
	--	,@pCountryId = 151
	--	--,@pCurr = 'NPR'

	--IF @PAYMENTTYPE = 'B'
	--BEGIN
	--	SELECT TOP 1 
	--		@pBank = extBankId, @pBankName = bankName, @EXTERNALCODE = externalCode
	--	FROM externalBank WITH(NOLOCK) 
	--	WHERE routingCode = @BANKID AND ISNULL(isDeleted, 'N') = 'N'
						
	--	SELECT			 
	--		 @pBankName = ISNULL(@pBankName, @BANK_NAME)
	--		,@pBankBranchName =  @BANK_BRANCH_NAME	
	--		,@pBankType = 'E'	


	--	-->>Validate BANK_ID only for Bank Transfer and Account Deposit
	--	IF @pBank IS NULL
	--	BEGIN
	--		SELECT '102' CODE, 'Invalid BANK ID' MESSAGE, * FROM @errorTable				
	--		RETURN 
	--	END
	--END	


	 
	SELECT @sAgent = parentId,@sBranchName = agentName FROM agentMaster WITH (NOLOCK) WHERE agentId = @sBranch  AND ISNULL(isActive,'N')='Y'
	SELECT @sSuperAgent = parentId,@sAgentName  = agentName FROM agentMaster WITH (NOLOCK) WHERE agentId = @sAgent   AND ISNULL(isActive,'N')='Y'
	SELECT @sSuperAgentName = agentName FROM agentMaster WITH (NOLOCK) WHERE agentId = @sSuperAgent   AND ISNULL(isActive,'N') = 'Y' 
	--<<End of Get Sending Agent Details
	
	-->>Get Payout Agent Details--
	DECLARE @pBank INT, @pBankType CHAR(1), @pBankCountry VARCHAR(100)
	
	-->>Validate LOCATION_ID. IF LOCATION_ID is bankId then find head office Id
	DECLARE @agentType INT, @locationCountry VARCHAR(100), @isHeadOffice CHAR(1)


	IF @PAYMENTMODE = 'B'
	BEGIN
		DECLARE @parentMapCode VARCHAR(10)
		SELECT TOP 1 @parentMapCode = pam.mapCodeInt, @pBankBranchName = am.agentName FROM agentMaster am WITH(NOLOCK)
		INNER JOIN agentMaster pam WITH(NOLOCK) ON am.parentId = pam.agentId 
		WHERE am.mapCodeInt = @BANKID
		
		SELECT TOP 1 
			@pBank = extBankId, @pBankName = bankName, @EXTERNALCODE = externalCode
		FROM externalBank WITH(NOLOCK) 
		WHERE mapCodeInt = @parentMapCode AND ISNULL(isDeleted, 'N') = 'N'
		
		--SET @pBankBranchName = @BANK_BRANCH_NAME
		--SELECT @pAgent = 1004, @pAgentName = 'IME Nepal', 
		SET @pBankType = 'E'
		
		IF @pBank IS NULL
		BEGIN
			SELECT @pBank = extBankId, @pBankBranch = extBranchId, @pBankBranchName = branchName FROM externalBankBranch WITH(NOLOCK) WHERE extBranchId = @BANKID
			SELECT @pBankName = bankName, @EXTERNALCODE = externalCode FROM externalBank WITH(NOLOCK) WHERE extBankId = @pBank
		END
		
		IF @pBank IS NULL
		BEGIN
			SELECT @errorCode = '1001', @errorMsg = 'Invalid BANK ID'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN 
		END
	END
	
	DECLARE @currDecimal INT
	SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @RECEIVER_COUNTRY 
	SELECT TOP 1 @pCurr = CM.currencyCode, @currDecimal = CM.countAfterDecimal FROM countryCurrency CC WITH(NOLOCK)
	INNER JOIN currencyMaster CM WITH(NOLOCK) ON CC.currencyId = CM.currencyId
	WHERE CC.countryId = @pCountryId AND ISNULL(cc.isDeleted, 'N') = 'N'
	
	IF @pCurr IS NULL
	BEGIN
		SELECT @errorCode = '3008', @errorMsg = 'You are not allowed to send to country ' + @RECEIVER_COUNTRY
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END

	--<<End of Get Payout Agent Details
	-------------------END ----------------------------------
	
	-->>Manage Payment Type
	SELECT 
		@deliveryMethodId  = serviceTypeId, @deliveryMethod = typeTitle  
	FROM serviceTypeMaster WITH(NOLOCK) 
	WHERE ISNULL(isDeleted,'N') = 'N'
	AND typeTitle = CASE	WHEN @PAYMENTMODE = 'C' THEN 'CASH PAYMENT'
							WHEN @PAYMENTMODE = 'B' THEN 'BANK DEPOSIT'

					END
		
	-->>Start:Field Validation according to setup
	DECLARE @errTable TABLE(errorCode VARCHAR(10), msg VARCHAR(200), id VARCHAR(10))
	INSERT INTO @errTable(errorCode, msg, id)
	EXEC proc_sendValidation
		 @agentId				= @sAgent
		,@senIdType				= @SENDER_ID_TYPE
		,@senIdNo				= @SENDER_ID_NUMBER
		,@senIdValidDate		= @SENDER_ID_EXPIRE_DATE
		,@senDob				= @SENDER_DATE_OF_BIRTH
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
		,@pAgent				= @pAgent
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
	FROM currencyPayoutRound WHERE ISNULL(isDeleted, 'N') = 'N'
	AND currency = @pCurr AND tranType IS NULL
	
	-->>Start:Get Exchange Rate Details
	DECLARE @customerRate MONEY,@sCurrCostRate MONEY,@sCurrHoMargin MONEY,@sCurrAgentMargin MONEY,@pCurrCostRate MONEY,@pCurrHoMargin MONEY
	,@pCurrAgentMargin MONEY,@agentCrossSettRate MONEY,@treasuryTolerance MONEY,@sharingValue MONEY,@sharingType CHAR(1),@customerPremium MONEY
	,@sAgentComm MONEY,@sAgentCommCurrency VARCHAR(3)
	
		
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
		SELECT @errorCode = '1001', @errorMsg = 'Transaction cannot be proceed. Exchange Rate not defined'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	--<<End:Get Exchange Rate Details

	-->>Start:Get tAmt, cAmt, pAmt on the basis of CALCBY
	SELECT 
		 @cAmt = CASE WHEN @CALC_BY = 'S' THEN CAST(@TRANSFERAMOUNT AS MONEY) ELSE '0' END
		,@pAmt = CASE WHEN @CALC_BY = 'P' THEN CAST(@TRANSFERAMOUNT AS MONEY) ELSE '0' END
	
	DECLARE @scDiscount MONEY
	IF ISNULL(@cAmt, 0.00) <> 0.00  AND @CALC_BY = 'S'
	BEGIN
	   SELECT @iServiceCharge = amount FROM [dbo].FNAGetServiceCharge(
					@sCountryId, @sSuperAgent, @sAgent, @sBranch 
				   ,@pCountryId, NULL, @pAgent, NULL 
				   ,@deliveryMethodId, @cAmt, @collCurr
				   )

		IF @iServiceCharge IS NULL 
		BEGIN
			SELECT @errorCode = '1001', @errorMsg = 'Service Charge Not Defined for Receiving Country'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN;
		END
		
		IF @promotionFlag = 'P'
			SET @iServiceCharge = 0
		
		--IF @pCountryId = 151
		--BEGIN
		--	SET @scDiscount = @iServiceCharge
		--	SET @iServiceCharge = 0
		--END
		
		SET @tAmt = @cAmt - @iServiceCharge 
		SET @pAmt = (@tAmt) * (@customerRate)
		
		SET @currDecimal = ISNULL(@currDecimal, 0)
		IF @currDecimal IS NOT NULL
		BEGIN
			SET @pAmt = ROUND(@pAmt, @currDecimal, 1)
		END
		ELSE IF @place IS NOT NULL
		BEGIN
			SET @pAmt = ROUND(@pAmt, -@place, 1)
		END
	END
	ELSE
	BEGIN
		SET @tAmt = @pAmt/(@customerRate)
		SELECT  @iServiceCharge = amount FROM [dbo].FNAGetServiceCharge(
				 @sCountryId, NULL, @sAgent, NULL 
				,@pCountryId, NULL, @pAgent, NULL 
				,@deliveryMethodId, @tAmt, @collCurr
		)

		IF @iServiceCharge IS NULL 
		BEGIN
			SELECT @errorCode = '1001', @errorMsg = 'Service Charge Not Defined for Receiving Country'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN;
		END
		
		IF @promotionFlag = 'P'
			SET @iServiceCharge = 0
		
		--IF @pCountryId = 151
		--BEGIN
		--	SET @scDiscount = @iServiceCharge
		--	SET @iServiceCharge = 0
		--END
			
		SET @cAmt = (@tAmt + @iServiceCharge)
	END
	
	IF @iServiceCharge > @cAmt
	BEGIN
		SELECT @errorCode = '3009', @errorMsg = 'Sent Amount must be more than Service Charge'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN;
	END
	--<<End:Get tAmt, cAmt, pAmt on the basis of CALCBY	
		
	-->>Start:Commission Calculation
	DECLARE @sSettlementRate FLOAT, @pSettlementRate FLOAT,@tellerBalance MONEY
	SET @sSettlementRate = @sCurrCostRate + @sCurrHoMargin
	SET @pSettlementRate = @pCurrCostRate - @pCurrHoMargin
	
	SELECT @sAgentComm = amount, @sAgentCommCurrency = commissionCurrency FROM dbo.FNAGetSendComm(
											@sCountryId, @sSuperAgent, @sAgent, @sBranch,
											@pCountryId, @pSuperAgent, @pAgent, @pBranch,
											@collCurr, @deliveryMethodId, @cAmt, @pAmt, @iServiceCharge, NULL, NULL,
											@sSettlementRate, @pSettlementRate)
	--<<End:Commission Calculation
	
	-->>Start:Verify Agent Send Per Txn
	IF EXISTS(SELECT 'X' FROM sendTranLimit
				WHERE agentId = @sAgent
				AND ISNULL(receivingCountry, ISNULL(@pCountryId, 0)) = ISNULL(@pCountryId, 0)
				AND ISNULL(tranType, ISNULL(@deliveryMethodId, 0)) = ISNULL(@deliveryMethodId, 0)
				AND currency = @collCurr AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
			)
	BEGIN
		IF EXISTS(SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE agentId = @sAgent AND receivingCountry = @pCountryId 
					AND tranType = @deliveryMethodId AND currency = @collCurr 
					AND @cAmt < minLimitAmt
					AND @cAmt > maxLimitAmt
					AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT @errorCode = '3012', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
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
			SELECT @errorCode = '3012', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND receivingCountry = @pCountryId 
					AND tranType = @deliveryMethodId AND currency = @collCurr 
					AND @cAmt < minLimitAmt
					AND @cAmt > maxLimitAmt
					AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT @errorCode = '3012', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
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
			SELECT @errorCode = '3012', @errorMsg = 'Partner Balance Exceed, Cannot Make a TXN'
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
			SELECT @errorCode = '3011', @errorMsg = 'Payout Amount Limit Exceed'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE sendingCountry = @sCountryId AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr 
					AND tranType IS NULL AND @pAmt > maxLimitAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
		BEGIN
			SELECT @errorCode = '3011', @errorMsg = 'Payout Amount Limit Exceed'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr 
					AND tranType = @deliveryMethodId AND @pAmt > maxLimitAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
		BEGIN
			SELECT @errorCode = '3011', @errorMsg = 'Payout Amount Limit Exceed'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK)
					WHERE sendingCountry IS NULL AND countryId = @pCountryId AND agentId = @pAgent AND currency = @pCurr
					AND tranType IS NULL AND @pAmt > maxLimitAmt AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
		BEGIN
			SELECT @errorCode = '3011', @errorMsg = 'Payout Amount Limit Exceed'
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
		SELECT @errorCode = '3011', @errorMsg = 'Payout Amount Limit Exceed'
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	-->>End:Verify Payout Per Txn Limit	
	
	IF EXISTS(SELECT TOP 1 'X' FROM thirdPartyAgentTxnIdV2 WITH(NOLOCK) WHERE agentTxnId = @AGENT_SESSION_ID AND agentId = @sAgent)
	BEGIN
		SELECT TOP 1 @controlNo = controlNo FROM remitTran (NOLOCK) WHERE controlNo2 = @AGENT_SESSION_ID AND createdBy = 'kodhead123'
		SELECT @errorCode = '1001', @errorMsg = 'Duplicate Ref ID : ' + @AGENT_SESSION_ID + '; ICN : ' + dbo.FNADecryptString(@controlNo)
		EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg

		SELECT TOP 1 @errorCode CODE
			,MESSAGE				= @errorMsg
			,AGENT_REFID			= @AGENT_SESSION_ID 
			,REFID					= dbo.FNADecryptString(@controlNo)
			,AGENT_TXNID			= 1
			,COLLECT_AMT			= cAmt
			,COLLECT_CURRENCY		= collCurr
			,EXRATE					= customerRate
			,SERVICE_CHARGE			= serviceCharge
			,PAYOUTAMT				= pAmt
			,PAYOUTCURRENCY			= payoutCurr 
			,TXN_DATE				= createdDate
		FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNo
		RETURN
	END
	
	-->>Start:Get Data Compliance for Compliance Checking and suspicious duplicate txn
	DECLARE @today VARCHAR(10) = CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USER_ID), 101)
	DECLARE @remitTranTemp TABLE(tranId BIGINT, controlNo VARCHAR(20), controlNo2 VARCHAR(50), cAmt MONEY, receiverName VARCHAR(200), receiverIdType VARCHAR(100), receiverIdNumber VARCHAR(50), dot DATETIME)
	
	INSERT INTO @remitTranTemp(tranId, controlNo, controlNo2, cAmt, receiverName, receiverIdType, receiverIdNumber, dot)
	SELECT rt.id, rt.controlNo, rt.controlNo2, rt.cAmt, rt.receiverName, rec.idType, rec.idNumber, rt.createdDate
	FROM vwRemitTran rt WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	WHERE sen.idNumber = @SENDER_ID_NUMBER 
	AND tranStatus <> 'CancelRequest' AND tranStatus <> 'Cancel'
	AND (rt.approvedDate BETWEEN @today AND @today + ' 23:59:59'
	OR (approvedBy IS NULL AND cancelApprovedBy IS NULL))
	
	IF EXISTS(SELECT 'X' FROM @remitTranTemp WHERE cAmt = @cAmt 
				AND (receiverName = @RECEIVER_NAME)
				AND DATEDIFF(MI, dot, dbo.FNADateFormatTZ(GETDATE(), @USER_ID)) <= 2
			)
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'Similar transaction found'
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
	--		EXEC proc_complianceRuleDetail 
	--			 @user				= @USER_ID
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
	--			,@agentRefId		= @AGENT_TXNID
	--			,@result			= @complianceRes OUTPUT
	--			,@senderId			= @SENDER_ID_NUMBER
	--			,@senderName		= @SENDER_NAME
	--			,@senderMobile		= @SENDER_MOBILE
	--		SET @compFinalRes = ISNULL(@compFinalRes, '') + ISNULL(@complianceRes, '')			

	--		SET @count = @count + 1
	--	END
	--END
	



	-->>Start:Control Number Generation
	
	SET @controlNo = '9080' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
	IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
	BEGIN
		SET @controlNo = '9496' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
		IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
		BEGIN
			SELECT @errorCode = '9001', @errorMsg = 'Technical error occurred. Please try again'
			EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			RETURN
		END
	END		
	SET @pAmt = ROUND(@pAmt, 0, 1)
	DECLARE @controlNoEncrypted VARCHAR(50)
	SET @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)	
	--<<End:Control Number Generation
	
	IF @PAYMENTMODE = 'B'
	BEGIN
		SELECT TOP 1 @pAgent = internalCode, @pAgentName = bankName FROM externalBank WITH(NOLOCK) WHERE extBankId = @pBank
		--SELECT TOP 1 @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
		SELECT @pBranchName = ISNULL(@pBankBranchName, @BANK_BRANCH_NAME)
	END
	
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
				,tranStatus,payStatus
				,createdDate,createdDateLocal,createdBy
				,approvedDate,approvedDateLocal,approvedBy
				,tranType
				,senderName,receiverName,controlNo2
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
				,'Payment', 'Unpaid'
				,dbo.FNADateFormatTZ(GETDATE(),@USER_ID),GETDATE(),@USER_ID
				,dbo.FNADateFormatTZ(GETDATE(),@USER_ID),GETDATE(),@USER_ID
				,'I'
				,@SENDER_NAME,@RECEIVER_NAME,@AGENT_SESSION_ID
						
			SET @tranId = @@IDENTITY
			
			DECLARE @sFirstName VARCHAR(100),@sMiddleName VARCHAR(100),@sLastName VARCHAR(100),@sLastName2 VARCHAR(100)
			DECLARE @rFirstName VARCHAR(100),@rMiddleName VARCHAR(100),@rLastName VARCHAR(100),@rLastName2 VARCHAR(100)
			
			SELECT @sFirstName = firstName, @sMiddleName = middleName, @sLastName = lastName1, @sLastName2 = lastName2 FROM dbo.FNASplitName(@SENDER_NAME)
			SELECT @rFirstName = firstName, @rMiddleName = middleName, @rLastName = lastName1, @rLastName2 = lastName2 FROM dbo.FNASplitName(@RECEIVER_NAME)
			DECLARE @memberCode VARCHAR(50),@senderId INT,@sIdTypeId INT
			
			SELECT @senderId = C.customerId FROM customers C WITH (NOLOCK) INNER JOIN customerIdentity CI WITH (NOLOCK) ON C.customerId = CI.customerId
				INNER JOIN staticDataValue SV WITH (NOLOCK) ON CI.idType = SV.valueId WHERE SV.detailTitle = @SENDER_ID_TYPE AND CI.idNumber = @SENDER_ID_NUMBER
			
			
			INSERT INTO tranSenders
			(
				 customerId
				,gender
				,tranId
				,firstName,middleName,lastName1,lastName2,fullName
				,country,city,address,homePhone,mobile
				,idType,idNumber
				,issuedDate,validDate,dob
				
			)
			SELECT
				 @senderId
				,@SENDER_GENDER
				,@tranId
				,@sFirstName,@sMiddleName,@sLastName,@sLastName2,@SENDER_NAME	
				,@sCountry,@SENDER_CITY,@SENDER_ADDRESS,@SENDER_MOBILE,@SENDER_MOBILE
				,@SENDER_ID_TYPE,@SENDER_ID_NUMBER
				,@SENDER_ID_ISSUE_DATE,@SENDER_ID_EXPIRE_DATE,@SENDER_DATE_OF_BIRTH
				
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
		SELECT @AGENT_SESSION_ID, @sAgent
		
		-->>Start:Verify Compliance
		IF EXISTS(SELECT 'X' FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @AGENT_TXNID)
		BEGIN
			INSERT INTO remitTranCompliance(TranId, csDetailTranId, matchTranId)
			SELECT @tranId, csDetailTranId, matchTranId FROM remitTranComplianceTemp WITH(NOLOCK) WHERE agentRefId = @AGENT_TXNID
			SET @compFinalRes = 'C'
		END
		
		IF EXISTS(SELECT 'X' FROM @remitTranTemp WHERE dot BETWEEN CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USER_ID), 101) AND CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USER_ID), 101) + ' 23:59:59' AND cAmt = @cAmt AND (receiverName = @RECEIVER_NAME))
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
				WHERE controlNo = @controlNoEncrypted
			END
			ELSE IF(@compFinalRes <> '' AND ISNULL(@ofacRes, '') = '')
			BEGIN
				UPDATE remitTran SET
					 tranStatus			= 'Compliance'
				WHERE controlNo = @controlNoEncrypted
			END
			ELSE IF(ISNULL(@compFinalRes, '') <> '' AND ISNULL(@ofacRes, '') <> '')
			BEGIN
				INSERT remitTranOfac(TranId, blackListId, reason, flag)
				SELECT @tranId, @ofacRes, @ofacReason, dbo.FNAGetOFAC_Flag(@ofacRes)
				
				UPDATE remitTran SET
					 tranStatus			= 'OFAC/Compliance'
				WHERE controlNo = @controlNoEncrypted
			END
		END
		
		UPDATE apiRequestLog SET 
			  errorCode = '0'
			 ,errorMsg = 'Transaction saved successfully'
			 ,controlNo = @controlNoEncrypted 
		WHERE rowId = @apiRequestId
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		SELECT	
			 CODE					=  '0'
			,AGENT_REFID			= @AGENT_SESSION_ID 
			,MESSAGE				= 'Transaction saved successfully' 
			,REFID					= @controlNo
			,AGENT_TXNID			= '1'
			,COLLECT_AMT			= cAmt
			,COLLECT_CURRENCY		= collCurr
			,EXRATE					= customerRate
			,SERVICE_CHARGE			= serviceCharge
			,PAYOUTAMT				= pAmt
			,PAYOUTCURRENCY			= payoutCurr 
			,TXN_DATE				= createdDate
		FROM remitTran WITH(NOLOCK)
		WHERE id = @tranId
		
		INSERT INTO PinQueueList(ICN)
		SELECT @controlNoEncrypted
		
		--IF @PAYMENTMODE = 'D'
		--BEGIN
		--	EXEC proc_transactionRouting @flag = 'update', @user = @USER_ID, @tranIds = @tranId, @pAgent = @pAgent
		--END
	END 
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRAN

SELECT @errorCode = '9001', @errorMsg = 'Technical Error : ' + ERROR_MESSAGE()
EXEC ws_int_proc_responseLog @flag = 's', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg

SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
			
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error',@errorMsg MESSAGE,'ws_int_proc_SendTransaction_JP','admin', GETDATE()
END CATCH


GO
