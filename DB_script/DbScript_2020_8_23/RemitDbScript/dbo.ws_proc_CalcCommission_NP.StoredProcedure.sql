USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_CalcCommission_NP]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC  @spName @AGENT_SESSION_ID,@TRANSFER_AMOUNT,@PAYMENT_MODE,@CALC_BY,@SENDING_COUNTRY,@PAYOUT_COUNTRY


CREATE proc [dbo].[ws_proc_CalcCommission_NP](
	 @AGENT_CODE		VARCHAR(50)
	,@USER_ID			VARCHAR(50)
	,@PASSWORD			VARCHAR(50)
	,@AGENT_SESSION_ID	VARCHAR(50)
	,@TRANSFER_AMOUNT	VARCHAR(50)
	,@PAYMENT_MODE		VARCHAR(50)
	,@CALC_BY			VARCHAR(50)
	,@SENDING_COUNTRY	VARCHAR(100) 
	,@PAYOUT_COUNTRY	VARCHAR(100)
)
AS

		SET NOCOUNT ON;
		SET XACT_ABORT ON;

		DECLARE @EXRATEID VARCHAR(40) = NEWID()
		DECLARE @errorTable TABLE
		(
			 AGENT_REFID VARCHAR(150)
			,COLLECT_AMT MONEY
			,COLLECT_CURRENCY VARCHAR(3)
			,SERVICE_CHARGE MONEY
			,EXCHANGE_RATE MONEY
			,PAYOUT_AMT MONEY
			,PAYOUT_CURRENCY VARCHAR(3)
			,SESSION_ID VARCHAR(36)
		)
	
	INSERT INTO @errorTable	( AGENT_REFID ) 
	SELECT @AGENT_SESSION_ID

	IF @USER_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'USER_ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @AGENT_CODE IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT_CODE Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @PASSWORD IS NULL
	BEGIN
		SELECT '1001' CODE, 'PASSWORD Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @USER_ID <> 'n3p@lU$er' OR @AGENT_CODE <> '1001' OR @PASSWORD <> '36928c11f93d6b0cbf573d0e1ac350f7'
	BEGIN
		SELECT '1002' CODE,'Authentication Failed' MESSAGE, * FROM @errorTable
		RETURN
	END
		
	IF @PAYOUT_COUNTRY IS NULL
	BEGIN
		SELECT '1001' CODE,'PAYOUT COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	IF @SENDING_COUNTRY IS NULL 
	BEGIN
		SELECT '1001' CODE,'SENDING COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	IF @TRANSFER_AMOUNT IS NULL
	BEGIN
		SELECT '1001' CODE,'TRANSFER AMOUNT Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	IF @TRANSFER_AMOUNT IS NOT NULL AND ISNUMERIC(@TRANSFER_AMOUNT)=0
	BEGIN
		SELECT '9001' CODE,'TRANSFER AMOUNT must be numeric' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	IF @PAYMENT_MODE IS NULL
	BEGIN
		SELECT '1001' CODE,'PAYMETHOD Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	IF @CALC_BY IS NULL
	BEGIN
		SELECT '1001' CODE,'CALC BY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE,'AGENT SESSION ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	IF @PAYMENT_MODE NOT IN('C','B','D')
	BEGIN
		SELECT '3001' CODE, 'Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank D - Account Deposit To Other Bank' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @CALC_BY NOT IN('S','P','C')
	BEGIN
		SELECT '1004' CODE, 'Invalid Parameter CALC BY' MESSAGE, * FROM @errorTable
		RETURN
	END	

		DECLARE
		 @pCountryId		INT
		,@pAgent			INT
		,@pCurr				VARCHAR(3)
		,@deliveryMethod	INT
		,@exRate			FLOAT
		,@cAmt				MONEY
		,@tAmt				MONEY
		,@pAmt				MONEY
		,@sCountryId		INT 
		,@sSuperAgent		INT
		,@sAgent			INT
		,@sBranch			INT = NULL
		,@collCurr			VARCHAR(3)
		,@serviceCharge		MONEY
	
	SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryCode = @PAYOUT_COUNTRY AND ISNULL(isDeleted,'N')='N'
	SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryCode = @SENDING_COUNTRY AND ISNULL(isDeleted,'N')='N'	
	
	SELECT 
		@deliveryMethod  = serviceTypeId
		FROM serviceTypeMaster 
		WHERE ISNULL(isDeleted,'N')='N'
		AND typeTitle = CASE WHEN @PAYMENT_MODE = 'C' THEN 'Cash Payment'
							 WHEN @PAYMENT_MODE = 'B' THEN 'Bank Deposit'
							 WHEN @PAYMENT_MODE = 'D' THEN 'Bank Deposit'
						END
	
	DECLARE
		 @rowId INT
		,@place INT
		,@currDecimal INT
	
-------------------- Find Decimal Mask for payout amount rounding  ----------------------------------
	SELECT TOP 1 
		  @pCurr = CM.currencyCode
		, @currDecimal = CM.countAfterDecimal 
		FROM currencyMaster CM WITH (NOLOCK)
		INNER JOIN countryCurrency CC WITH (NOLOCK)	ON CM.currencyId = CC.currencyId
		WHERE CC.countryId = @pCountryId
	
	SELECT TOP 1
		@collCurr = CM.currencyCode
		FROM currencyMaster CM WITH (NOLOCK)
		INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId = CC.currencyId
		WHERE CC.countryId = @sCountryId
	
	SELECT 
		  @place = place
		, @currDecimal = currDecimal
		FROM currencyPayoutRound 
		WHERE ISNULL(isDeleted, 'N') = 'N' 
		AND currency = @pCurr AND tranType IS NULL
------------- End -----------------------------------------------------
	
	IF @pCurr IS NULL
	BEGIN
		 SELECT '3008' CODE, 'Select Country is not allowed' MESSAGE, * FROM @errorTable
		 RETURN
	END
	
	DECLARE 
		@customerRate MONEY
		,@sCurrCostRate MONEY
		,@sCurrHoMargin MONEY
		,@sCurrAgentMargin MONEY
		,@pCurrCostRate MONEY
		,@pCurrHoMargin MONEY
		,@pCurrAgentMargin MONEY
		,@agentCrossSettRate MONEY
		,@treasuryTolerance MONEY
		,@sharingValue MONEY
		,@sharingType CHAR(1)
		,@customerPremium MONEY
		,@sAgentComm MONEY
		,@sAgentCommCurrency VARCHAR(3)

------------------ Setting Default AgentId for Sending Country -------------------------------
	
	SELECT @sAgent = CASE 
						WHEN @SENDING_COUNTRY = 'JP' THEN	4846
						WHEN @SENDING_COUNTRY = 'US' THEN	4814
					 END
		
	SELECT @sBranch = CASE 
						WHEN @SENDING_COUNTRY = 'JP' THEN	4847
						WHEN @SENDING_COUNTRY = 'US' THEN	4815
					 END
	
------------------ End -------------------------------------	
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

	IF @exRate IS NULL 
	BEGIN
		SELECT '1001' CODE, 'Ex-Rate Not Defined for Receiving Currency (' + @pCurr + ')' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	SELECT 
		 @cAmt = CASE WHEN @CALC_BY IN ('S','C') THEN @TRANSFER_AMOUNT ELSE '0' END
		,@pAmt = CASE WHEN @CALC_BY = 'P' THEN @TRANSFER_AMOUNT ELSE '0' END
		
	IF ISNULL(@cAmt,0.00) <> 0.00  AND (@CALC_BY = 'S' OR @CALC_BY = 'C')
	BEGIN
		SELECT  
			@serviceCharge = amount
			FROM [dbo].FNAGetServiceCharge(@sCountryId, @sSuperAgent, @sAgent,@sBranch ,@pCountryId, NULL, @pAgent, NULL ,@deliveryMethod, @cAmt, @collCurr)
		IF @serviceCharge IS NULL
		BEGIN
			SELECT '1001' CODE, 'Service Charge Not Defined for Receiving Country' MESSAGE, * FROM @errorTable
			RETURN;
		END
		
		SET @tAmt = @cAmt - @serviceCharge 
		
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
		SET @tAmt = @pAmt/@exRate
		SET @tAmt = ROUND(@tAmt, 0)
		SELECT 
			@serviceCharge = amount 
			FROM [dbo].FNAGetServiceCharge(@sCountryId, @sSuperAgent, @sAgent, @sBranch, @pCountryId, NULL, @pAgent, NULL, @deliveryMethod, @tAmt, @collCurr )

	SELECT @sCountryId, @sSuperAgent, @sAgent, @sBranch, @pCountryId, NULL, @pAgent, NULL, @deliveryMethod, @tAmt, @collCurr 

		IF @serviceCharge IS NULL 
		BEGIN
			SELECT '1001' CODE, 'Service Charge Not Defined for Receiving Country' MESSAGE
					,* FROM @errorTable
			RETURN;
		END
		
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
	
	IF @serviceCharge > @tAmt
	BEGIN
		SELECT '3009' CODE, 'Sent Amount must be more than Service Charge' MESSAGE, * FROM @errorTable
		RETURN;
	END
	
	SELECT 
		 '0'									CODE
		,@PAYOUT_COUNTRY						MESSAGE
		,@AGENT_SESSION_ID						AGENT_REFID
		,@cAmt									COLLECT_AMT
		,@collCurr								COLLECT_CURRENCY
		,@serviceCharge							SERVICE_CHARGE
		,@exRate								EXCHANGE_RATE
		,@pAmt									PAYOUT_AMT
		,@pCurr									PAYOUT_CURRENCY
		,@EXRATEID								SESSION_ID


GO
