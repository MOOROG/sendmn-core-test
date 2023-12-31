USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_GetCalculation]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exRateTreasury

SELECT * FROM exRateTreasury(NOLOCK) WHERE CAGENT = 9561

exec ws_int_proc_GetCalculation @ACCESSCODE='BRNNP9561',@USERNAME='mtradeasia',@PASSWORD='mtradeasia',
@AGENT_TXN_REF_ID='345342100153',@PAYOUT_AGENT_ID=NULL,@REMIT_AMOUNT='50000',
@PAYMENTTYPE='C',@PAYOUT_COUNTRY='Nepal',@CALC_BY='C'

SELECT dbo.decryptDb(pwd),agentId,* FROM dbo.applicationUsers WHERE userName like 'el%'
SELECT dbo.decryptDb(pwd),agentId,* FROM dbo.applicationUsers WHERE userName = 'dhan321'

exchange Rate
SELECT * FROM dbo.FNAGetExRate(153,1086,1087,'QAR','151',null,'NPR',1)

*/

CREATE PROC [dbo].[ws_int_proc_GetCalculation] (	 
	@ACCESSCODE		VARCHAR(50),
	@USERNAME			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_TXN_REF_ID   VARCHAR(50),
	@PAYOUT_AGENT_ID    VARCHAR(50)=null,
	@REMIT_AMOUNT		VARCHAR(50),
	@PAYMENTTYPE		VARCHAR(50)=null,
	@PAYOUT_COUNTRY	VARCHAR(50),
	@CALC_BY			VARCHAR(50)

)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

     SET @PAYOUT_COUNTRY = 'Nepal'
     SET @PAYOUT_AGENT_ID = ISNULL(NULLIF(@PAYOUT_AGENT_ID, 0),'-1')

	--SET @CALC_BY = 'C'

	DECLARE @apiRequestId BIGINT
	INSERT INTO requestApiLogOther(
		 AGENT_CODE			
		,USER_ID 			
		,PASSWORD 			
		,AGENT_TXN_REF_ID
		,PAYOUT_AGENT_ID
		,REMIT_AMOUNT	
		,PAYMENTTYPE	
		,PAYOUT_COUNTRY	
		,CALC_BY
		,METHOD_NAME
		,REQUEST_DATE

	)
	SELECT
		 @ACCESSCODE				
		,@USERNAME 			
		,@PASSWORD 			
		,@AGENT_TXN_REF_ID
		,@PAYOUT_AGENT_ID
		,@REMIT_AMOUNT	
		,@PAYMENTTYPE	
		,@PAYOUT_COUNTRY	
		,@CALC_BY
		,'ws_int_proc_GetCalculation'
		,GETDATE()
	SET @apiRequestId = SCOPE_IDENTITY()	
	
     --select LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7) 

	DECLARE @errCode INT
	DECLARE @EXRATEID VARCHAR(40) = LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7) 
	
	DECLARE @autMsg	VARCHAR(500)	
	DECLARE @errorTable TABLE(
		 AGENT_REFID VARCHAR(150),COLLECT_AMT MONEY,COLLECT_CURRENCY VARCHAR(3)
		,SERVICE_CHARGE MONEY,EXCHANGE_RATE MONEY
		,PAYOUTAMT MONEY,PAYOUTCURRENCY VARCHAR(3),SESSION_ID VARCHAR(36)
	)

	DECLARE 
		 @PAYOUT_COUNTRY_ID INT = 151
		,@IME_AGENT_ID INT = 1002
		,@IME_AGENT_NAME VARCHAR(50) = 'BRN Nepal'
	
	INSERT INTO @errorTable(AGENT_REFID) 
	SELECT @AGENT_TXN_REF_ID

	EXEC ws_int_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT,@autMsg OUT

	IF(@errCode = 1)
	BEGIN
		SELECT '102' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USERNAME AND forceChangePwd = 'Y')
	BEGIN
		SELECT '102' CODE, 'You logged on first time,must first change your password and try again!' MESSAGE, * FROM @errorTable
		RETURN
	END
	------------------VALIDATION-------------------------------
	IF @PAYOUT_COUNTRY IS NULL
	BEGIN
		SELECT '102' CODE,'PAYOUT COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @REMIT_AMOUNT IS NULL
	BEGIN
		SELECT '102' CODE,'REMIT AMOUNT Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @REMIT_AMOUNT IS NOT NULL AND ISNUMERIC(@REMIT_AMOUNT)=0
	BEGIN
		SELECT '9001' CODE,'REMIT AMOUNT must be numeric' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @PAYOUT_AGENT_ID IS NOT NULL AND ISNUMERIC(@PAYOUT_AGENT_ID)=0
	BEGIN
		SELECT '9001' CODE,'PAYOUT AGENT ID must be numeric' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @PAYMENTTYPE IS NULL
	BEGIN
		SELECT '102' CODE,'PAYMENT TYPE Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @CALC_BY IS NULL
	BEGIN
		SELECT '102' CODE,'CALC BY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @AGENT_TXN_REF_ID IS NULL
	BEGIN
		SELECT '102' CODE,'AGENT TXN REF ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END

	IF @PAYMENTTYPE NOT IN('C','B','CP', 'BP')
	BEGIN
		SELECT '205' CODE, 'Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank' MESSAGE, * FROM @errorTable
		RETURN
	END

	DECLARE @promotionFlag CHAR(1)
	SET @promotionFlag = RIGHT(@PAYMENTTYPE, 1)
	IF LEN(@PAYMENTTYPE) > 1
		SET @PAYMENTTYPE = LEFT(@PAYMENTTYPE, LEN(@PAYMENTTYPE) - 1)
		
	IF @CALC_BY NOT IN('C','P')
	BEGIN

		SELECT '104' CODE, 'Invalid Parameter CALC BY' MESSAGE, * FROM @errorTable
		RETURN
	END
		
	IF ISNULL(@PAYOUT_AGENT_ID, '') <> '-1' AND @PAYMENTTYPE = 'C'
	BEGIN
		SELECT '104' CODE, 'Invalid PAYOUT AGENT ID' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF ISNUMERIC(@PAYOUT_AGENT_ID) = 0
	BEGIN
		SELECT '104' CODE, 'Invalid PAYOUT AGENT ID' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @PAYOUT_COUNTRY <> 'NEPAL'
	BEGIN
		SELECT '104' CODE, 'Invalid PAYOUT COUNTRY' MESSAGE, * FROM @errorTable
		RETURN
	END

	DECLARE @pCountryId		INT,
			@pAgent			INT,
			@pAgentName		VARCHAR(100),
			@pSuperAgent	INT,
			@pCurr			VARCHAR(3),
			@deliveryMethod INT,
			@exRate			MONEY,
			@cAmt			MONEY,
			@tAmt			MONEY,
			@pAmt			MONEY,
			
			@sCountryId		INT,
			@sAgent			INT,
			@collCurr		VARCHAR(3),
			@serviceCharge	MONEY,
			@sSuperAgent	INT,
			@sBranch		INT
	

	IF @PAYOUT_AGENT_ID <> '-1' AND @PAYMENTTYPE = 'B'
	BEGIN
		
		DECLARE @pBank INT, @pBankBranch INT = @PAYOUT_AGENT_ID, @isBankFound INT
		SELECT @pBank = parentid, @pAgent = parentId FROM dbo.agentMaster WITH(NOLOCK) WHERE agentId = @pBankBranch

		IF @pBank IS NULL
		BEGIN
			SELECT '3003' CODE, 'Invalid Payout Agent ID' MESSAGE, * FROM @errorTable			
			RETURN
		END
				
		SELECT @pAgentName = am.agentName, @pSuperAgent = sm.agentId 
		FROM dbo.agentMaster am WITH(NOLOCK) 
		INNER JOIN dbo.agentMaster sm WITH(NOLOCK) ON am.parentId = sm.agentId
		WHERE am.agentId = @pAgent

	END

	--IF @LOCATION_ID IS NOT NULL
	--BEGIN
	--	DECLARE @pBankBranch INT
	--	IF @PAYOUT_COUNTRY = 'Nepal' AND @PAYMENTTYPE = 'B'
	--	BEGIN
	--		SELECT 
	--			@pBankBranch = extBranchId 
	--		FROM externalBankBranch WITH(NOLOCK) WHERE externalCode = @LOCATION_ID AND ISNULL(isDeleted, 'N') = 'N'
			
	--		IF @pBankBranch IS NULL
	--		BEGIN
	--			SELECT '3003' CODE, 'Invalid Location ID' MESSAGE, * FROM @errorTable			
	--			RETURN
	--		END
	--	END
	--	ELSE
	--	BEGIN
	--		DECLARE @agentType INT, @locationCountry VARCHAR(100), @pBranch INT, @locationIsActive CHAR(1)
	--		SELECT 
	--			@agentType = agentType, @pAgent = agentId, 
	--			@locationCountry = agentCountry, @locationIsActive = ISNULL(isActive, 'N') 
	--		FROM agentMaster WITH(NOLOCK) 
	--			WHERE mapCodeInt = @LOCATION_ID 
	--				AND ISNULL(isDeleted, 'N') = 'N'
			
	--		IF @agentType = 2903
	--			SELECT TOP 1 
	--				@pBranch = agentId, @pAgent = parentId 
	--			FROM agentMaster WITH(NOLOCK) 
	--				WHERE parentId = @pAgent 
	--					AND ISNULL(isHeadOffice, 'N') = 'Y' 
	--					AND ISNULL(isDeleted, 'N') = 'N'
	--		ELSE
	--			SELECT 
	--				@pBranch = agentId, @pAgent = parentId 
	--			FROM agentMaster WITH(NOLOCK) 
	--				WHERE mapCodeInt = @LOCATION_ID 
	--					AND agentType = 2904 
	--					AND ISNULL(isDeleted, 'N') = 'N'
			
	--		IF @locationIsActive IS NULL
	--		BEGIN
	--			SELECT '3003' CODE, 'Invalid Location ID1' MESSAGE, * FROM @errorTable
	--			RETURN
	--		END
	--		IF @locationIsActive = 'N'
	--		BEGIN
	--			SELECT '3004' CODE, 'Location ID is inactive' MESSAGE, * FROM @errorTable
	--			RETURN
	--		END
	--		IF @locationCountry <> @PAYOUT_COUNTRY
	--		BEGIN
	--			SELECT '3003' CODE, 'Invalid Location ID2' MESSAGE, * FROM @errorTable
	--			RETURN
	--		END
	--	END
	--END	
	--IF ISNULL(@PAYOUT_AGENT_ID, '') <> '-1' AND @PAYMENTTYPE = 'B'
	--BEGIN
	--	SELECT @pAgent = ISNULL(internalCode,'-1')
	--		FROM externalBank eb WITH(NOLOCK) WHERE extBankId = @PAYOUT_AGENT_ID
	--END
	
	SELECT 
		 @sBranch = sb.agentId 
		,@sAgent	  =  sa.agentId
		,@sSuperAgent =  sa.parentId 		
		,@sCountryId = au.countryId	
		,@pSuperAgent = @IME_AGENT_ID
		,@pCountryId = @PAYOUT_COUNTRY_ID
		,@pAgentName = @IME_AGENT_NAME
	FROM applicationUsers au WITH(NOLOCK) 
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON au.agentId = sb.agentId
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON sb.parentId = sa.agentId	
	WHERE userName = @USERNAME
		AND ISNULL(sb.isActive,'N')='Y'
		AND ISNULL(sa.isActive,'N')='Y'
	
	
	SELECT 
		@deliveryMethod  = serviceTypeId 
	FROM serviceTypeMaster 
	WHERE ISNULL(isDeleted,'N')='N'
		AND typeTitle = CASE @PAYMENTTYPE 
							WHEN 'C' THEN 'Cash Payment'
							WHEN 'B' THEN 'Bank Deposit'
						END
			
	DECLARE @rowId INT, @place INT, @currDecimal INT
	
	--2. Find Decimal Mask for payout amount rounding----------------------------------------------------------------------------------
	SELECT TOP 1 
		@pCurr = CM.currencyCode, @currDecimal = CM.countAfterDecimal 
	FROM currencyMaster CM WITH (NOLOCK)
	INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId = CC.currencyId
	WHERE CC.countryId = @pCountryId 
		AND ISNULL(cc.isDeleted, 'N') <> 'Y'
	
	DECLARE @Excurr varchar(5)
	SELECT @Excurr = cCurrency FROM exRateTreasury(NOLOCK) WHERE CAGENT = @sAgent

	SELECT TOP 1 
		@collCurr = CM.currencyCode
	FROM currencyMaster CM WITH (NOLOCK)
	INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId = CC.currencyId
	WHERE CC.countryId = @sCountryId 
		AND ISNULL(cc.isDeleted, 'N') <> 'Y'
	
	--select @Excurr , @collCurr

	IF @Excurr <> @collCurr
		SET @collCurr = @Excurr

	SELECT @place = place, @currDecimal = currDecimal
	FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') <> 'Y' 
	AND currency = @pCurr AND tranType IS NULL
	
	--End of 2-------------------------------------------------------------------------------------------------------------------------
		    
	IF @pCurr IS NULL
	BEGIN
		 SELECT '102' CODE, 'Sending Country is not allowed' MESSAGE, * FROM @errorTable
		 RETURN
	END
	DECLARE 
		 @customerRate MONEY, @sCurrCostRate MONEY,@sCurrHoMargin MONEY
		,@sCurrAgentMargin MONEY,@pCurrCostRate MONEY,@pCurrHoMargin MONEY
		,@pCurrAgentMargin MONEY,@agentCrossSettRate MONEY,@treasuryTolerance MONEY
		,@sharingValue MONEY,@sharingType CHAR(1),@customerPremium MONEY
		,@sAgentComm MONEY,@sAgentCommCurrency VARCHAR(3)

	
	SELECT 
		 @exRate				= customerRate
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
	FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethod)
	--SELECT 
	--	sCountryId = @sCountryId,
	--	sAgent = @sAgent,
	--	sBranch	= @sBranch,
	--	collCurr = @collCurr,
	--	pCountryId = @pCountryId,
	--	pAgent = @pAgent,
	--	pCurr = @pCurr,
	--	deliveryMethod = @deliveryMethod

	IF @exRate IS NULL 
	BEGIN
		SELECT '102' CODE, 'Ex-Rate Not Defined for Receiving Currency (' + @pCurr + ')' MESSAGE, * FROM @errorTable
		RETURN
	END
		
	SELECT 
		 @cAmt = CASE @CALC_BY WHEN 'C' THEN @REMIT_AMOUNT ELSE '0' END
		,@pAmt = CASE @CALC_BY WHEN 'P' THEN @REMIT_AMOUNT ELSE '0' END

	--SET @pAmt = dbo.FNARemitRoundForNPR(@pAmt)
	

	--SELECT @sCountryId, @sSuperAgent, @sAgent, @sBranch 
	--			   ,@pCountryId, NULL, @pAgent, NULL 
	--			   ,@deliveryMethod, @cAmt, @collCurr

	IF ISNULL(@cAmt, 0.00) <> 0.00  AND @CALC_BY = 'C'
	BEGIN
	   SELECT @serviceCharge = amount FROM [dbo].FNAGetServiceCharge(
					@sCountryId, @sSuperAgent, @sAgent, @sBranch 
				   ,@pCountryId, NULL, @pAgent, NULL 
				   ,@deliveryMethod, @cAmt, @collCurr
				   )

		IF @serviceCharge IS NULL
		BEGIN
			SELECT '102' CODE, 'Service Charge Not Defined for Receiving Country' MESSAGE, * FROM @errorTable
			RETURN;
		END
		
		IF @promotionFlag = 'P'
			SET @serviceCharge = 0
		
		--Nepal Relief Fund
		--IF @pCountryId = 151 AND @sAgent IN (4880)
		--	SET @serviceCharge = 0
				
		SET @tAmt = @cAmt - @serviceCharge 
		
		--SET @pAmt = @tAmt * @exRate
		--SET @pAmt = dbo.FNARemitRoundForNPR(@pAmt)

		
		IF @currDecimal IS NOT NULL
		BEGIN
			SET @pAmt = (@cAmt - @serviceCharge ) * (@exRate)
			SET @pAmt = ROUND(@pAmt, @currDecimal, 1)
		END
		ELSE IF @place IS NOT NULL
		BEGIN
			SET @pAmt = (@cAmt - @serviceCharge ) * (@exRate)
			SET @pAmt = ROUND(@pAmt, -@place, 1)
		END
		
	END
	ELSE
	BEGIN
		SET @tAmt = ROUND(@pAmt/@exRate, 0)		
		SELECT 
			@serviceCharge = amount 
		FROM [dbo].FNAGetServiceCharge(
			@sCountryId, @sSuperAgent, @sAgent, @sBranch 
			,@pCountryId, NULL, @pAgent, NULL 
			,@deliveryMethod, @tAmt, @collCurr
		)

		IF @serviceCharge IS NULL 
		BEGIN
			SELECT '102' CODE, 'Service Charge Not Defined for Receiving Country' MESSAGE
					,* FROM @errorTable
			RETURN;
		END
		
		IF @promotionFlag = 'P'
			SET @serviceCharge = 0
		
		--Nepal Relief Fund
		--IF @pCountryId = 151 AND @sAgent IN (4880)
		--	SET @serviceCharge = 0
				
		IF @currDecimal IS NOT NULL
		BEGIN
			SET @cAmt = (@tAmt + @serviceCharge)
			SET @cAmt = ROUND(@cAmt, @currDecimal)
		END
		ELSE IF @place IS NOT NULL
		BEGIN
			SET @cAmt = (@tAmt + @serviceCharge)
			SET @cAmt = ROUND(@cAmt, -@place)
		END
	END
	IF @serviceCharge > @cAmt
	BEGIN
		SELECT '102' CODE, 'Sent Amount must be more than Service Charge' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @sAgent = 4858 -- UAE Exchange
	BEGIN
		SELECT 
			@cAmt = dbo.FNACustomRound(@cAmt, 1)
			,@serviceCharge = dbo.FNACustomRound(@serviceCharge, 1)
	END


	--UPDATE exRateCalcHistory SET 
	--	isExpired = 'Y'
	--WHERE AGENT_TXN_REF_ID = @AGENT_TXN_REF_ID
			
	INSERT INTO exRateCalcHistory (
		 AGENT_CODE	
		,[USER_ID]
		,AGENT_TXN_REF_ID
		,FOREX_SESSION_ID
		,serviceCharge
		,pAmt
		,customerRate
		,sCurrCostRate		
		,sCurrHoMargin		
		,sCurrAgentMargin	
		,pCurrCostRate		
		,pCurrHoMargin		
		,pCurrAgentMargin	
		,agentCrossSettRate
		,treasuryTolerance	
		,customerPremium	
		,sharingValue		
		,sharingType
		,createdDate				
		,isExpired
	)
	SELECT
		 @ACCESSCODE	
		,@USERNAME	
		,@AGENT_TXN_REF_ID
		,@EXRATEID
		,@serviceCharge
		,@pAmt
		,@exRate			
		,@sCurrCostRate		
		,@sCurrHoMargin		
		,@sCurrAgentMargin	
		,@pCurrCostRate		
		,@pCurrHoMargin		
		,@pCurrAgentMargin	
		,@agentCrossSettRate
		,@treasuryTolerance	
		,@customerPremium	
		,@sharingValue		
		,@sharingType				
		,GETDATE()				
		,'N'	
			

	SELECT 
		 '0'									Code
		,@AGENT_TXN_REF_ID						AGENT_REFID 
		,ISNULL(@pAgentName, @PAYOUT_COUNTRY)	Message		
		,@cAmt									COLLECT_AMT
		,@collCurr								COLLECT_CURRENCY
		,@serviceCharge							SERVICE_CHARGE
		,@exRate								EXCHANGE_RATE
		,@pAmt									PAYOUTAMT
		,@pCurr									PAYOUTCURRENCY
		,@EXRATEID								SESSION_ID


		UPDATE requestApiLogOther SET 
			errorCode = '0'
			,errorMsg = 'Success'			
		WHERE rowId = @apiRequestId

	--SELECT 
	--	 '0'									CODE
	--	,ISNULL(@pAgentName, @PAYOUT_COUNTRY)	MESSAGE
	--	,@AGENT_TXN_REF_ID						AGENT_TXN_REF_ID 
	--	,@cAmt									COLLECT_AMT
	--	,@collCurr								COLLECT_CURRENCY
	--	,@serviceCharge							SERVICE_CHARGE
	--	,@exRate								EXCHANGE_RATE
	--	,@pAmt									PAYOUTAMT
	--	,@pCurr									PAYOUTCURRENCY
	--	,@EXRATEID								FOREX_SESSION_ID
END TRY
	
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRAN
DECLARE @errorLogId BIGINT
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_int_proc_GetCalculation',@USERNAME, GETDATE()
SET @errorLogId = SCOPE_IDENTITY()

SELECT '9001' CODE, 'Technical Error occurred, Error Log ID : ' + CAST(@errorLogId AS VARCHAR) MESSAGE, * FROM @errorTable
END CATCH



GO
