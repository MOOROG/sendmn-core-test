--EXEC proc_tranCalculator @flag = 'exRate', @user = 'anupam', @sCountryId = '113', @sAgent = '394392', @sBranch = '394392', @collCurr = 'JPY', @pCountryId = '151', 
--@pAgent = '103', @pCurr = null, @deliveryMethod = '2', @transferAmt = '20000', @payAmt = null, @sSuperAgent = '393877', @calculateBy = 'cAmt'

ALTER PROCEDURE [dbo].[PROC_TranCalculator]
	 @user				VARCHAR(30)		= NULL
	,@flag				VARCHAR(10)		= NULL
	,@sCountryId		INT				= NULL
	,@sAgent			INT				= NULL
	,@sBranch			INT				= NULL
	,@collCurr			VARCHAR(3)		= NULL
	,@pCountryId		INT				= NULL
	,@pAgent			INT				= NULL
	,@pCurr				VARCHAR(3)		= NULL
	,@deliveryMethod	INT				= NULL
	,@transferAmt		MONEY			= NULL
	,@payAmt			MONEY			= NULL
	,@calculateBy		VARCHAR(10)		= NULL
	,@sSuperAgent		INT				= NULL
AS
SET NOCOUNT ON;

IF @flag = 'exRate'
BEGIN
	    DECLARE @rowId INT, @place INT, @currDecimal INT, @exRateOffer MONEY = 0, @scOffer MONEY = 0 , @cDecimal INT	 
	    DECLARE @scharge MONEY,@exRate FLOAT, @payoutPartner int
		
		SELECT @payoutPartner = AGENTID
		FROM TblPartnerwiseCountry(NOLOCK) 
		WHERE CountryId = @pCountryId AND IsActive = 1 
		AND ISNULL(PaymentMethod, @deliveryMethod) = @deliveryMethod
			
		IF @payoutPartner IS NOT NULL
		BEGIN
			--GET PAYOUT AGENT DETAILS
			SELECT @PAGENT = AGENTID FROM AGENTMASTER (NOLOCK) WHERE PARENTID = @payoutPartner AND ISNULL(ISSETTLINGAGENT, 'N') = 'Y';

			SELECT @pAgent = sAgent
			FROM dbo.FNAGetBranchFullDetails(@PAGENT)
		END

	    SELECT TOP 1 @pCurr = CM.currencyCode
	    FROM currencyMaster CM WITH (NOLOCK)
	    INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId=CC.currencyId
	    WHERE CC.countryId=@pCountryId
		AND CC.isDefault = 'Y'
	    
	    SELECT TOP 1 @collCurr = CM.currencyCode
	    FROM currencyMaster CM WITH (NOLOCK)
	    INNER JOIN countryCurrency CC WITH (NOLOCK) ON CM.currencyId=CC.currencyId
	    WHERE CC.countryId = @sCountryId and CM.isDeleted = NULL AND CC.isDeleted IS NULL

		-- ## Calculating collection amt decimal value 
		SELECT @cDecimal = ISNULL(currDecimal,2)
	    FROM currencyPayoutRound WHERE ISNULL(isDeleted, 'N') = 'N' 
	    AND currency = @collCurr AND tranType = @deliveryMethod

		IF @cDecimal IS NULL
			SELECT @cDecimal = ISNULL(currDecimal,2)
			FROM currencyPayoutRound WHERE ISNULL(isDeleted, 'N') = 'N' 
			AND currency = @collCurr AND tranType IS NULL

		IF @cDecimal IS NULL 
			SET @cDecimal = 2

		SELECT @place = place, @currDecimal = currDecimal
	    FROM currencyPayoutRound WHERE ISNULL(isDeleted, 'N') = 'N' 
	    AND currency = @pCurr AND tranType = @deliveryMethod
		
		SET @currDecimal = ISNULL(@currDecimal, 0)

	    IF @pCurr IS NULL
	    BEGIN
			 SELECT '1' ErrCode, 'Currency Not Defined for Receiving Country' Msg
			 RETURN
	    END

		--SELECT @sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod
		--return;
	    SELECT @exRate = dbo.FNAGetCustomerRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)
		IF @exRate IS NULL 
		BEGIN
			SELECT '1' ErrCode, 'Ex-Rate Not Defined for Receiving Currency ('+@pCurr+')' Msg
			RETURN
		END

		IF @calculateBy IS NULL
		BEGIN
			IF ISNULL(@transferAmt, 0.00) <> 0.00
				SET @calculateBy = 'cAmt'
			ELSE
				SET @calculateBy = 'pAmt'
		END
		
		IF @calculateBy = 'cAmt'
		BEGIN
		   SELECT @scharge = amount FROM [dbo].FNAGetServiceCharge(
						@sCountryId, @sSuperAgent, @sAgent, @sBranch 
					   ,@pCountryId, NULL, @pAgent, NULL 
					   ,@deliveryMethod, @transferAmt, @collCurr
					   )

			IF @scharge IS NULL 
			BEGIN
				SELECT '1' ErrCode, 'Service Charge Not Defined for Receiving Currency' Msg
				RETURN
			END
			SET @payAmt = (@transferAmt - @scharge) * (@exRate)
			SET @payAmt = ROUND(@payAmt, @currDecimal)
			IF @place IS NOT NULL
				SET @payAmt = ROUND(@payAmt, - @place)
		END
		ELSE
		BEGIN
			SET @transferAmt = @payAmt/@exRate
			--select @transferAmt
			SELECT  @scharge = amount FROM [dbo].FNAGetServiceCharge(
					 @sCountryId, @sSuperAgent, @sAgent, @sBranch 
					,@pCountryId, NULL, @pAgent, NULL 
					,@deliveryMethod, @transferAmt, @collCurr
			)
			IF @sCharge IS NULL 
			BEGIN
				SELECT '1' ErrCode, 'Service Charge Not Defined for Receiving Currency' Msg
				RETURN;
			END		
			
			SET @transferAmt = @transferAmt + @scharge			
			DECLARE @ad FLOAT
			SELECT @ad = 1.0/POWER(10, 3)
			SET @transferAmt = @transferAmt + @ad
			SET @transferAmt = ROUND(@transferAmt, @cDecimal)
		END
		
		SELECT 
			 '0' ErrCode, 'Success' Msg, scCharge = @scharge
			,exRate = @exRate, place = @place
			,pCurr = @pCurr, currDecimal = @currDecimal
			,pAmt = ROUND(@payAmt, 2), sAmt = cast((@transferAmt - @scharge) as float)
			,disc = 0.00, collAmt = cast(@transferAmt as float)
			,exRateOffer = @exRateOffer, scOffer = @scOffer
END

if @flag='collCurr'
BEGIN
		SELECT TOP 1 CM.currencyCode
		FROM currencyMaster CM WITH(NOLOCK)
		INNER JOIN countryCurrency CC WITH(NOLOCK) ON CM.currencyId = CC.currencyId
		WHERE CC.countryId = @sCountryId
		AND ISNULL(CM.isDeleted,'N') = 'N' 
		AND ISNULL(CM.isActive,'Y') = 'Y'
		AND ISNULL(CC.isActive,'Y') = 'Y'
		AND ISNULL(CC.isDeleted,'N') = 'N'
END


