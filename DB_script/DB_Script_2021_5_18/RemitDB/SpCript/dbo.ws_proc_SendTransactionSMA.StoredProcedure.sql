USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_SendTransactionSMA]    Script Date: 5/18/2021 5:17:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_SendTransaction_italy]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_SendTransaction_italy

GO


*/
/*
	EXEC ws_proc_SendTransaction @AGENT_CODE='IMEADE01',@USER_ID='apioo1',@PASSWORD='pralhad123',@AGENT_SESSION_ID='1231',@AGENT_TXNID='12',@LOCATION_ID=10200700
	,@SENDER_NAME='Pralhad Sedhai',@SENDER_ADDRESS='Menara jaya,KL',@SENDER_MOBILE='060123345671',@SENDER_CITY='kuala lampur',@SENDER_COUNTRY='Malaysia'
	,@SENDER_ID_TYPE='Passport',@SENDER_ID_NUMBER='05708477',@SENDER_ID_ISSUE_DATE='2012-12-12',@SENDER_ID_EXPIRE_DATE='2014-12-11',@SENDER_DATE_OF_BIRTH='1989-05-03'
	,@RECEIVER_NAME='Riwaj Rimal',@RECEIVER_ADDRESS='Kathmandu',@RECEIVER_CONTACT_NUMBER='9841234567',@RECEIVER_CITY='kathmandu',@RECEIVER_COUNTRY='Philipines'
	,@TRANSFERAMOUNT='12000',@PAYMENTMODE='C',@CALC_BY='P'
*/

CREATE proc [dbo].[ws_proc_SendTransactionSMA] (	 
		@AGENT_CODE				VARCHAR(50) ,
		@USER_ID				VARCHAR(50) ,
		@PASSWORD				VARCHAR(50) ,
		@AGENT_SESSION_ID		VARCHAR(50) ,
		@AGENT_TXNID			VARCHAR(50) ,
		@LOCATION_ID			VARCHAR(50) ,
		@SENDER_NAME			VARCHAR(50) ,
		@SENDER_GENDER			VARCHAR(50) = NULL,
		@SENDER_ADDRESS			VARCHAR(50) ,
		@SENDER_MOBILE			VARCHAR(50) ,
		@SENDER_CITY			VARCHAR(100),
		@SENDER_COUNTRY			VARCHAR(50) ,
		@SENDER_ID_TYPE			VARCHAR(50) ,
		@SENDER_ID_NUMBER		VARCHAR(50) ,
		@SENDER_ID_ISSUE_DATE	VARCHAR(50) ,
		@SENDER_ID_EXPIRE_DATE   VARCHAR(50) ,
		@SENDER_DATE_OF_BIRTH	VARCHAR(50) ,
		@RECEIVER_NAME			VARCHAR(50) ,
		@RECEIVER_ADDRESS		VARCHAR(50) ,
		@RECEIVER_CONTACT_NUMBER VARCHAR(50) = NULL,
		@RECEIVER_CITY			VARCHAR(50)  = NULL,
		@RECEIVER_COUNTRY		VARCHAR(50) ,
		@PAYOUT_AMOUNT			VARCHAR(50) ,
		@PAYMENTMODE			VARCHAR(50) ,
		@BANKID					VARCHAR(50) = NULL,--xxx
		@BANK_ACCOUNT_NUMBER	VARCHAR(50) = NULL,		
		@OUR_SERVICE_CHARGE		MONEY		= NULL,
		@EXT_BANK_BRANCH_ID		VARCHAR(50)	= NULL,--xxxxx
		@SETTLE_USD_AMT			VARCHAR(50)	= NULL,
		@SETTLE_RATE			VARCHAR(50)	= NULL,
		@CUSTOMER_ID			VARCHAR(50)	= NULL,
		@RECEIVER_RELATION		VARCHAR(50)	= NULL,
		@SOURCE_OF_INCOME		VARCHAR(50)	= NULL,
		@REASON_FOR_REMITTANCE	VARCHAR(50)	= NULL,
		@SENDER_OCCUPATION		VARCHAR(50)	= NULL
)

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	--DECLARE @TRANSFERAMOUNT VARCHAR(50)  = @PAYOUT_AMOUNT

	DECLARE @apiRequestId INT
		INSERT INTO apiRequestLogSMA (
		 AGENT_CODE				
		,USER_ID				
		,PASSWORD				
		,AGENT_SESSION_ID		
		,AGENT_TXNID			
		,LOCATION_ID			
		,SENDER_NAME			
		,SENDER_GENDER			
		,SENDER_ADDRESS			
		,SENDER_MOBILE			
		,SENDER_CITY			
		,SENDER_COUNTRY			
		,SENDER_ID_TYPE			
		,SENDER_ID_NUMBER		
		,SENDER_ID_ISSUE_DATE	
		,SENDER_ID_EXPIRE_DATE  
		,SENDER_DATE_OF_BIRTH	
		,RECEIVER_NAME			
		,RECEIVER_ADDRESS		
		,RECEIVER_CONTACT_NUMBER
		,RECEIVER_CITY			
		,RECEIVER_COUNTRY		
		,PAYOUT_AMOUNT			
		,PAYMENTMODE			
		,BANKID					
		,BANK_ACCOUNT_NUMBER	
		,OUR_SERVICE_CHARGE		
		,EXT_BANK_BRANCH_ID		
		,SETTLE_USD_AMT			
		,SETTLE_RATE			
		,CUSTOMER_ID			
		,RECEIVER_RELATION		
		,SOURCE_OF_INCOME		
		,REASON_FOR_REMITTANCE	
		,SENDER_OCCUPATION	
		,REQUEST_DATE
	)
	SELECT 
		 @AGENT_CODE				
		,@USER_ID				
		,@PASSWORD				
		,@AGENT_SESSION_ID		
		,@AGENT_TXNID			
		,@LOCATION_ID			
		,@SENDER_NAME			
		,@SENDER_GENDER			
		,@SENDER_ADDRESS			
		,@SENDER_MOBILE			
		,@SENDER_CITY			
		,@SENDER_COUNTRY			
		,@SENDER_ID_TYPE			
		,@SENDER_ID_NUMBER		
		,@SENDER_ID_ISSUE_DATE	
		,@SENDER_ID_EXPIRE_DATE  
		,@SENDER_DATE_OF_BIRTH	
		,@RECEIVER_NAME			
		,@RECEIVER_ADDRESS		
		,@RECEIVER_CONTACT_NUMBER
		,@RECEIVER_CITY			
		,@RECEIVER_COUNTRY		
		,@PAYOUT_AMOUNT			
		,@PAYMENTMODE			
		,@BANKID					
		,@BANK_ACCOUNT_NUMBER	
		,@OUR_SERVICE_CHARGE		
		,@EXT_BANK_BRANCH_ID		
		,@SETTLE_USD_AMT			
		,@SETTLE_RATE			
		,@CUSTOMER_ID			
		,@RECEIVER_RELATION		
		,@SOURCE_OF_INCOME		
		,@REASON_FOR_REMITTANCE	
		,@SENDER_OCCUPATION	
		,GETDATE()
		
	SET @apiRequestId = SCOPE_IDENTITY()	
		
	DECLARE @autMsg	VARCHAR(500)

	SET @SENDER_NAME = UPPER(@SENDER_NAME)
	SET @RECEIVER_NAME = UPPER(@RECEIVER_NAME)
	DECLARE @controlNo VARCHAR(50),@tranId INT
	DECLARE @sCountryId INT, @sCountry VARCHAR(50),@collCurr VARCHAR(3), @sSuperAgent INT, @sSuperAgentName VARCHAR(200), @pBankName VARCHAR(200)
	,@sAgent INT ,@sAgentName VARCHAR(200), @sBranch INT, @sBranchName VARCHAR(200), @deliveryMethod VARCHAR(100), @deliveryMethodId INT
	,@pCountryId INT, @pCurr VARCHAR(3)
	,@pSuperAgent INT, @pSuperAgentName VARCHAR(200), @pAgent INT, @pAgentName VARCHAR(200), @pBranch INT, @pBranchName VARCHAR(200)
	,@pBankBranchName VARCHAR(200), @EXTERNALCODE VARCHAR(200)

	DECLARE @errCode INT, @pBankBranch INT
	EXEC ws_int_proc_checkAuthntication @USER_ID, @PASSWORD, @AGENT_CODE, @errCode OUT,@autMsg OUT

	--SELECT  @agentCode = agentId  FROM agentMaster where mapcodeInt = @agentCode
	
	DECLARE @errorTable TABLE (
		 AGENT_SESSION_ID VARCHAR(150), REFID VARCHAR(50), AGENT_TXNID INT
		 , COLLECT_AMT MONEY, COLLECT_CURRENCY VARCHAR(3)
		,EXCHANGE_RATE MONEY,SERVICE_CHARGE MONEY
		,PAYOUTAMT MONEY,PAYOUTCURRENCY	VARCHAR(3),TXN_DATE	VARCHAR(10)
	)
	
	INSERT INTO @errorTable(AGENT_SESSION_ID) 
	SELECT @AGENT_SESSION_ID
	DECLARE @errorCode VARCHAR(10), @errorMsg VARCHAR(500)
	IF (@errCode = 1)
	BEGIN		
		SELECT @errorCode = '1002', @errorMsg = ISNULL(@autMsg,'Authentication Fail')
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable

		RETURN
	END
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USER_ID AND forceChangePwd = 'Y')
	BEGIN
		SELECT @errorCode = '1002', @errorMsg = 'You are required to change your password!'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
				
		RETURN
	END
	
	-->>Validation------------------
	IF @AGENT_SESSION_ID IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'AGENT SESSION ID Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN
	END
	
	IF ISNUMERIC(@AGENT_TXNID) = 0 OR @AGENT_TXNID IS NULL OR @AGENT_TXNID NOT LIKE '921________'
	BEGIN				
		SELECT @errorCode = '1001', @errorMsg = 'AGENT TXNID Field is Empty Or not valid'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END

	
	IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @AGENT_TXNID)
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'Duplicate AGENT TXNID'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END	
		
	IF @SENDER_NAME IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'SENDER NAME Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF @SENDER_ADDRESS IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'SENDER ADDRESS Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF @SENDER_CITY IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'SENDER CITY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF @SENDER_COUNTRY IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'SENDER COUNTRY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	
	IF @SENDER_ID_TYPE IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'SENDER ID TYPE Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;		
	END
	IF @SENDER_ID_NUMBER IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'SENDER ID NUMBER Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF @RECEIVER_NAME IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'RECEIVER NAME Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF @RECEIVER_ADDRESS IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'RECEIVER ADDRESS Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF @RECEIVER_COUNTRY IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'RECEIVER COUNTRY Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END

	IF @PAYOUT_AMOUNT IS NULL
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'PAYOUT AMOUNT Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF ISNUMERIC(@PAYOUT_AMOUNT) = 0 AND @PAYOUT_AMOUNT IS NOT NULL OR  CAST(@PAYOUT_AMOUNT AS MONEY) <=0
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: PAYOUT AMOUNT must be numeric and more than 0'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable		
		RETURN;
	END
	IF ISNUMERIC(@SETTLE_USD_AMT) = 0 OR @SETTLE_USD_AMT IS NULL OR CAST(@SETTLE_USD_AMT AS MONEY) <=0
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: SETTLE USD AMT must be numeric and more than 0' 
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF @OUR_SERVICE_CHARGE IS NULL OR @OUR_SERVICE_CHARGE <= 0.0
	BEGIN
		SELECT @errorCode = '3003', @errorMsg = 'Technical Error: Invalid OUR SERVICE CHARGE'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable		
		RETURN 
	END
	
	IF ISDATE(@SENDER_DATE_OF_BIRTH) = 0 AND @SENDER_DATE_OF_BIRTH IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: DOB must be date'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable		
		RETURN;
	END
	IF ISDATE(@SENDER_ID_EXPIRE_DATE) = 0 AND @SENDER_ID_EXPIRE_DATE IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: ID expiry date must be date'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable		
		RETURN;
	END
	IF ISDATE(@SENDER_ID_ISSUE_DATE) = 0 AND @SENDER_ID_ISSUE_DATE IS NOT NULL
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: ID issue date must be date'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END
	IF DATEDIFF(D,@SENDER_ID_ISSUE_DATE,@SENDER_ID_EXPIRE_DATE)<0
	BEGIN
		SELECT @errorCode = '9001', @errorMsg = 'Technical Error: ID expiry date must be more than issue date'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable		
		RETURN;
	END
	IF @PAYMENTMODE IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'PAYMETHOD Field is Empty'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN;
	END

	IF @SENDER_ID_TYPE NOT IN(
		 'CITIZENSHIP'
		,'DRIVER LICENSE'
		,'EMPLOYMENT AUTHORIZATION'
		,'LEARNER PERMIT'
		,'NATIONAL ID' 
		,'OTHER'
		,'PASSPORT'
		,'RESIDENT CARD'
		,'STATE ID'
		,'SOCIAL SECURITY'	
	)	
	BEGIN
		SELECT @errorCode = '3001', @errorMsg = 'Invalid Sender ID Type, Must be CITIZENSHIP, DRIVER LICENSE, EMPLOYMENT AUTHORIZATION, LEARNER PERMIT, NATIONAL ID, OTHER, PASSPORT, RESIDENT CARD, STATE ID, SOCIAL SECURITY'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable		
		RETURN
	END

	IF @PAYMENTMODE NOT IN('C','B')
	BEGIN
		SELECT @errorCode = '3001', @errorMsg = 'Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable		
		RETURN
	END
	IF @PAYMENTMODE = 'B'
	BEGIN	
		IF ISNUMERIC(@LOCATION_ID) = 0
		BEGIN
			SELECT @errorCode = '9001', @errorMsg = 'Provided Location ID can not perform Account Deposit'
			EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable			
			RETURN
		END
		
		IF @BANK_ACCOUNT_NUMBER IS NULL
		BEGIN
			SELECT @errorCode = '9001', @errorMsg = 'BANK ACCOUNT NUMBER field is empty'
			EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable			
			RETURN
		END
	
		--IF ISNUMERIC(@BANK_ACCOUNT_NUMBER)=0 
		--BEGIN
		--	SELECT '9001' CODE, 'Technical Error: BANK ACCOUNT NUMBER must be numeric' MESSAGE, * FROM @errorTable
		--	RETURN
		--END
	END

	--SELECT TOP 1 
	--	--@collCurr = CM.currencyCode
	--	 @collCurr = 'USD'	
	--	,@sCountry = C.countryName FROM countryCurrency CC WITH (NOLOCK)
	--INNER JOIN countryMaster C WITH (NOLOCK ) ON C.countryId = CC.countryId
	--INNER JOIN  currencyMaster CM WITH (NOLOCK) ON CC.currencyId = CM.currencyId
	--WHERE CC.countryId = @sCountryId   AND ISNULL(Cc.isDeleted,'N') = 'N'
	 
	
	-->>Get Sending Agent Details	
	SELECT TOP 1
		@sCountryId = au.countryId,
		@sBranch = au.agentId,
		@sBranchName = sb.agentName,
		@sAgent = sb.parentId,
		@sAgentName  = sa.agentName, 
		@sSuperAgent = sa.parentId,
		@sSuperAgentName  = ssa.agentName 
	FROM applicationUsers au WITH (NOLOCK)
	LEFT JOIN agentMaster sb WITH (NOLOCK) ON au.agentId = sb.agentId
	LEFT JOIN agentMaster sa WITH (NOLOCK) ON sb.parentId = sa.agentId
	LEFT JOIN agentMaster ssa WITH (NOLOCK) ON sa.parentId = ssa.agentId
	WHERE au.userName = @USER_ID 
		AND ISNULL(au.isActive,'N')='Y'
		AND ISNULL(sb.isActive,'N')='Y'
		AND ISNULL(sa.isActive,'N')='Y'
		AND ISNULL(ssa.isActive,'N')='Y'
	--<<End of Get Sending Agent Details

	SELECT TOP 1 
		@collCurr = 'USD',-- CM.currencyCode,
		@sCountry = 'United States'-- C.countryName 
	FROM countryCurrency CC WITH (NOLOCK)
	INNER JOIN countryMaster C WITH(NOLOCK ) ON C.countryId = CC.countryId
	INNER JOIN  currencyMaster CM WITH(NOLOCK) ON CC.currencyId = CM.currencyId
	WHERE CC.countryId = @sCountryId AND ISNULL(Cc.isDeleted,'N') = 'N'

	DECLARE 
		  @pBank INT--,@pBankBranch INT
		 ,@pBankType CHAR(1)
		 ,@pBankCountry VARCHAR(100) = 'Nepal'
		 --,@EXTERNALCODE VARCHAR(50)		
		 

	SELECT
		 --@pAgent = 1251
		--,@pAgentName = 'International Money Express( IME) - HO'
		 @pSuperAgent = 1002
		,@pSuperAgentName = 'International Money Express (IME) Pvt. Ltd'
		,@pCountryId = 151
		--,@pCurr = 'NPR'

	IF @PAYMENTMODE = 'B'
	BEGIN

		DECLARE @parentMapCode VARCHAR(10)
		SELECT TOP 1 
			@parentMapCode = pam.mapCodeInt, @pBankBranchName = am.agentName 
		FROM agentMaster am WITH(NOLOCK)
		INNER JOIN agentMaster pam WITH(NOLOCK) ON am.parentId = pam.agentId 
		WHERE am.mapCodeInt = @LOCATION_ID AND ISNULL(am.isDeleted, 'N') = 'N'
		
		SELECT TOP 1 
			@pBank = extBankId, @pBankName = bankName, @EXTERNALCODE = externalCode
		FROM externalBank WITH(NOLOCK) 
		WHERE mapCodeInt = @parentMapCode AND ISNULL(isDeleted, 'N') = 'N'
						
		SELECT			 
			 @pBankBranchName = @EXT_BANK_BRANCH_ID
			,@pBankType = 'E'

		IF @pBank IS NULL AND ISNUMERIC(@LOCATION_ID) = 1
		BEGIN
			SELECT @pBank = extBankId, @pBankBranch = extBranchId, @pBankBranchName = branchName FROM externalBankBranch WITH(NOLOCK) WHERE extBranchId = @LOCATION_ID
			SELECT @pBankName = bankName, @EXTERNALCODE = externalCode FROM externalBank WITH(NOLOCK) WHERE extBankId = @pBank
		END
		
		-->>Validate LOCATION_ID(BANK_ID) only for Bank Transfer and Account Deposit
		IF @pBank IS NULL
		BEGIN
			SELECT @errorCode = '3003', @errorMsg = 'Invalid LOCATION ID'
			EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
			SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
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
		SELECT @errorCode = '3008', @errorMsg = 'You are not allowed to send to country ' + @RECEIVER_COUNTRY
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN
	END
	--<<End of Get Payout Agent Details
	
	-->>Manage Payment Type
	SELECT 
		@deliveryMethodId  = serviceTypeId, 
		@deliveryMethod = typeTitle  
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
		,@pAgent				= 1251
		,@pBankType				= @pBankType
		,@pCountryId			= @pCountryId
		,@sCountryId			= @sCountryId
		
	IF NOT EXISTS(SELECT 'X' FROM @errTable WHERE errorCode = '0')
	BEGIN
		DECLARE @msg VARCHAR(200)
		SELECT @msg = msg FROM @errTable
		
		SELECT @errorCode = '1001', @errorMsg = @msg
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
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
	
	-->>Start:Get tAmt, cAmt, pAmt	
	SELECT 
		 @cAmt = CAST((@SETTLE_USD_AMT+ isnull(@OUR_SERVICE_CHARGE,0)) AS MONEY)
		,@pAmt = CAST(@PAYOUT_AMOUNT AS MONEY)
		,@iServiceCharge =  @OUR_SERVICE_CHARGE 

	SET @tAmt = @cAmt - @iServiceCharge
	SELECT 
		 @customerRate			= @pAmt /@tAmt
		,@agentCrossSettRate	= @pAmt /@tAmt
		,@sCurrCostRate			= 1
		,@sCurrHoMargin			= 0
		,@sCurrAgentMargin		= 0
		,@pCurrCostRate			= @pAmt /@tAmt
		,@pCurrHoMargin			= 0
		,@pCurrAgentMargin		= 0
		,@treasuryTolerance		= 0
		,@customerPremium		= 0
		,@sharingValue			= 0
	
	
	IF @iServiceCharge > @tAmt
	BEGIN		
		SELECT @errorCode = '3009', @errorMsg = 'Sent Amount must be more than Service Charge'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN
	END
	
	SET @pAmt = ROUND(@pAmt, 0, 1)
	--<<End:Get tAmt, cAmt, pAmt on the basis of CALCBY	
			
	-->>Start:Commission Calculation
	DECLARE @sSettlementRate FLOAT, @pSettlementRate FLOAT
	
	SET @sSettlementRate = CAST(@SETTLE_RATE AS MONEY)	
	
	-->>Start:Get Data Compliance for Compliance Checking and suspicious duplicate txn	
	DECLARE @today VARCHAR(10) = CONVERT(VARCHAR, GETDATE(), 101)
	DECLARE @remitTranTemp TABLE(tranId BIGINT, controlNo VARCHAR(20), cAmt MONEY, receiverName VARCHAR(200), receiverIdType VARCHAR(100), receiverIdNumber VARCHAR(50), dot DATETIME)
	
	INSERT INTO @remitTranTemp(tranId, controlNo, cAmt, receiverName, receiverIdType, receiverIdNumber, dot)
	SELECT TOP 3 rt.id, rt.controlNo, rt.cAmt, rt.receiverName, rec.idType, rec.idNumber, rt.createdDate
	FROM vwRemitTran rt WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	WHERE sen.idNumber = @SENDER_ID_NUMBER 
	AND tranStatus NOT IN ('CancelRequest', 'Cancel')
	AND (rt.approvedDateLocal BETWEEN @today
	AND @today + ' 23:59:59'
	OR (approvedBy IS NULL AND cancelApprovedBy IS NULL))
	ORDER BY rt.id DESC


	--INSERT INTO @remitTranTemp(tranId, controlNo, cAmt, receiverName, receiverIdType, receiverIdNumber, dot)
	--SELECT rt.id, rt.controlNo, rt.cAmt, rt.receiverName, rec.idType, rec.idNumber, rt.createdDate
	--FROM vwRemitTran rt WITH(NOLOCK)
	--INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	--INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	--WHERE sen.idNumber = @SENDER_ID_NUMBER 
	--AND tranStatus NOT IN ('CancelRequest', 'Cancel')
	--AND (rt.approvedDate BETWEEN CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USER_ID), 101) AND CONVERT(VARCHAR, dbo.FNADateFormatTZ(GETDATE(), @USER_ID), 101) + ' 23:59:59'
	--OR (approvedBy IS NULL AND cancelApprovedBy IS NULL))
	
	IF EXISTS(SELECT 'X' FROM @remitTranTemp WHERE cAmt = @cAmt 
				AND (receiverName = @RECEIVER_NAME)
				AND DATEDIFF(MI, dot, dbo.FNADateFormatTZ(GETDATE(), @USER_ID)) <= 2
			)
	BEGIN		
		SELECT @errorCode = '1001', @errorMsg = 'Similar transaction found'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN
	END


	--<<End:Get Data Compliance for Compliance Checking and suspicious duplicate txn
	
	DECLARE @agentFxGain FLOAT
	--SET @agentFxGain = (@tAmt * (@agentCrossSettRate - @customerRate))/@agentCrossSettRate
			
	-->>Start:OFAC/Compliance Checking
	

	-->>Start:Control Number Generation
	SET @controlNo = @AGENT_TXNID 
	--'9999' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000', 7)
	DECLARE @controlNoEncrypted VARCHAR(50) = dbo.FNAEncryptString(@controlNo)	
	
	IF EXISTS(SELECT 'X' FROM controlNoList WITH(NOLOCK) WHERE controlNo = @controlNo)
	BEGIN
		SELECT @errorCode = '3012', @errorMsg = 'Duplicate Agent TXN ID'
		EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
		SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable
		RETURN
	END

	IF @pAgent IS NULL 
	BEGIN
		SELECT 
			@pAgent = internalCode
			,@pAgentName = bankName
		FROM externalBank WITH(NOLOCK) WHERE extBankId = @pBank
	END
	
	BEGIN TRANSACTION
	-->>Start:Data Insert into remitTran, tranSenders, tranReceivers	
		INSERT INTO remitTran
		(
			 controlNo
			,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin,sAgentSettRate
			,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
			,agentCrossSettRate,customerRate,treasuryTolerance,customerPremium
			,sharingValue,serviceCharge, agentFxGain
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
			,senderName,receiverName
			,relWithSender, sourceOfFund, purposeOfRemit
		)

		SELECT 
			 @controlNoEncrypted
			,@sCurrCostRate,@sCurrHoMargin,@sCurrAgentMargin,@sSettlementRate
			,@pCurrCostRate,@pCurrHoMargin,@pCurrAgentMargin
			,@agentCrossSettRate,@customerRate,@treasuryTolerance,@customerPremium
			,@sharingValue,@iServiceCharge,@agentFxGain
			,@sAgentComm,@sAgentCommCurrency,0,@sAgentCommCurrency
			,@sCountry,@sSuperAgent,@sSuperAgentName,@sAgent,@sAgentName,@sBranch,@sBranchName
			,@RECEIVER_COUNTRY,@pSuperAgent,@pSuperAgentName,@pAgent,@pAgentName,@pBranch,@pBranchName
			,@deliveryMethod
			,@pBank,@pBankName,@pBankBranch,@pBankBranchName,@pBankType
			,@BANK_ACCOUNT_NUMBER,@EXTERNALCODE
			,@collMode,@collCurr,@tAmt,@cAmt,@pAmt,@pCurr
			,'Payment', 'Unpaid'
			,dbo.FNADateFormatTZ(GETDATE(),@USER_ID),GETDATE(),@USER_ID
			,dbo.FNADateFormatTZ(GETDATE(),@USER_ID),GETDATE(),@USER_ID
			,'I'
			,@SENDER_NAME,@RECEIVER_NAME	
			,@RECEIVER_RELATION, @SOURCE_OF_INCOME, @REASON_FOR_REMITTANCE
		
		SET @tranId = @@IDENTITY
		
		DECLARE @sFirstName VARCHAR(100),@sMiddleName VARCHAR(100),@sLastName VARCHAR(100),@sLastName2 VARCHAR(100)
		DECLARE @rFirstName VARCHAR(100),@rMiddleName VARCHAR(100),@rLastName VARCHAR(100),@rLastName2 VARCHAR(100)
		
		SELECT @sFirstName = firstName,@sMiddleName = middleName,@sLastName = lastName1,@sLastName2 = lastName2 FROM dbo.FNASplitName(@SENDER_NAME)
		SELECT @rFirstName = firstName,@rMiddleName = middleName,@rLastName = lastName1,@rLastName2 = lastName2 FROM dbo.FNASplitName(@RECEIVER_NAME)
		DECLARE @memberCode VARCHAR(50),@senderId INT,@sIdTypeId INT
		
		SELECT @senderId = C.customerId FROM customers C WITH (NOLOCK) INNER JOIN customerIdentity CI WITH (NOLOCK) ON C.customerId=CI.customerId
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
			,occupation
			,membershipId
			
		)
		SELECT
			 @senderId
			,@SENDER_GENDER
			,@tranId
			,@sFirstName,@sMiddleName,@sLastName,@sLastName2,@SENDER_NAME	
			,@sCountry,@SENDER_CITY,@SENDER_ADDRESS,@SENDER_MOBILE,@SENDER_MOBILE
			,@SENDER_ID_TYPE,@SENDER_ID_NUMBER
			,@SENDER_ID_ISSUE_DATE,@SENDER_ID_EXPIRE_DATE,@SENDER_DATE_OF_BIRTH
			,@SENDER_OCCUPATION
			,@CUSTOMER_ID
			
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

		INSERT INTO PinQueueList(ICN)
		SELECT @controlNoEncrypted
		
		UPDATE apiRequestLogSMA SET 
			  errorCode = '0'
			 ,errorMsg = 'Transaction created successfully'
			 ,controlNo = @controlNoEncrypted 
		WHERE rowId = @apiRequestId

	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
			
	SELECT	
		 CODE					=  '0'
		,AGENT_SESSION_ID			= @AGENT_SESSION_ID 
		,MESSAGE				= 'Transaction saved successfully'
		,REFID					= @controlNo
		,AGENT_TXNID			= 1
		,COLLECT_AMT			= tAmt
		,COLLECT_CURRENCY		= collCurr
		,EXCHANGE_RATE			= customerRate
		,SERVICE_CHARGE			= serviceCharge
		,PAYOUTAMT				= pAmt
		,PAYOUTCURRENCY			= payoutCurr 
		,TXN_DATE				= createdDate
	FROM remitTran WITH(NOLOCK)
	WHERE id = @tranId
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRAN

SELECT @errorCode = '9001', @errorMsg = 'Technical Error : ' + ERROR_MESSAGE()
EXEC ws_int_proc_responseLog @flag = 'u', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg
SELECT @errorCode CODE, MESSAGE = @errorMsg, * FROM @errorTable

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_SendTransactionSMA<br/></br>' + 'Technical Error : ' + ERROR_MESSAGE() ,@USER_ID, GETDATE()

END CATCH

GO
