SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO


ALTER PROC proc_get_exRate_master
(
	@flag				VARCHAR(20)
	,@user				VARCHAR(100) = NULL
	,@sCountryId		INT = NULL
	,@sAgent			INT = NULL
	,@sSuperAgent		INT = NULL
	,@sBranch			INT = NULL
	,@senderId			BIGINT = NULL
	,@collCurr			VARCHAR(5) = NULL
	,@pCountryId		INT = NULL
	,@pCountry			VARCHAR(50) = NULL
	,@pAgent			INT = NULL
	,@pCurr				VARCHAR(5) = NULL
	,@deliveryMethodId	INT = NULL
	,@cAmt				MONEY = NULL
	,@pAmt				MONEY = NULL
	,@calBy				CHAR(1) = NULL
	,@couponCode		VARCHAR(30) = NULL
	,@schemeId			INT = NULL
	,@payOutPartner		INT = NULL
	,@paymentType		VARCHAR(50) = NULL
	,@cardOnline		VARCHAR(10) = NULL
	,@tpExRate			FLOAT = NULL
	,@isManualSc		CHAR(1) = NULL
	,@manualSc			MONEY = NULL
	,@ProcessFor		VARCHAR(20) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @scValue MONEY, @scAction CHAR(2), @scOffer MONEY, @exRateOffer FLOAT, @scDiscount MONEY
	DECLARE @place INT, @currDecimal INT, @collMode VARCHAR(30), @sendingCustType VARCHAR(30), @msg VARCHAR(150), @errorCode INT
	DECLARE @exRateCalByPartner BIT, @pSuperAgent INT, @serviceCharge MONEY, @tAmt MONEY, @pSuperAgentName VARCHAR(100), @pBranch INT
	DECLARE @pAgentName VARCHAR(100), @pBranchName VARCHAR(100), @exRate FLOAT, @pCurrHoMargin FLOAT,@FOREX_SESSION_ID VARCHAR(40)
	

	SELECT @sAgent = V.AGENTID, @sAgent = V.AGENTID, @sCountryId = CM.countryId, @sSuperAgent = AM.parentId
	FROM VW_GETAGENTID V
	INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = V.AGENTID
	LEFT JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AM.AGENTCOUNTRY
	WHERE SEARCHTEXT='PayTxnFromMobile'
	
	IF ISNULL(@pCountryId, 0) = 0
		SELECT @pCountryId = countryId FROM countryMaster (NOLOCK) WHERE COUNTRYNAME = @pCountry

	SELECT @payoutPartner = AGENTID, @exRateCalByPartner = ISNULL(exRateCalByPartner, 0)
	FROM TblPartnerwiseCountry(NOLOCK) 
	WHERE CountryId = @pCountryId AND IsActive = 1 
	AND ISNULL(PaymentMethod, @deliveryMethodId) = @deliveryMethodId
		
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
		SELECT '1' ErrorCode, 'Partner not yet mapped for the selected country!' Msg,NULL id
		RETURN
	END

	DECLARE @rowId INT
	SELECT @scValue = 0, @scOffer = 0, @exRateOffer = 0, @scDiscount = 0
			
	SELECT @place = place, @currDecimal = currDecimal
	FROM currencyPayoutRound WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' 
	AND currency = @pCurr AND ISNULL(tranType,@deliveryMethodId) = @deliveryMethodId
			
	SET @currDecimal = ISNULL(@currDecimal, 0)
					    
	IF @pCurr IS NULL
	BEGIN
		SELECT '1' ErrorCode, 'Currency not been defined yet for receiving country' Msg,NULL id
		RETURN
	END

	IF @flag = 'false'
	BEGIN	
		SELECT @exRate = dbo.FNAGetCustomerRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethodId)
		
		SELECT 
			@pCurrHoMargin	= pCurrHoMargin
		FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)
		IF ISNULL(@exRate, 0) = 0
		BEGIN
			SELECT '1' ErrorCode, 'Exchange rate not defined yet for receiving currency (' + @pCurr + ')' Msg,NULL id
			RETURN
		END

		IF @calBy = 'C'
		BEGIN
			IF ISNULL(@isManualSc, 'N') = 'N'
			BEGIN
				SELECT @serviceCharge = amount FROM [dbo].FNAGetServiceCharge(
						@sCountryId, @sSuperAgent, @sAgent, @sBranch 
						,@pCountryId, @pSuperAgent, @pAgent, @pBranch 
						,@deliveryMethodId, @cAmt, @collCurr
						)
			END
			ELSE
			BEGIN
				SET @serviceCharge = ISNULL(@manualSc, 0)
			END

			IF @serviceCharge IS NULL AND ISNULL(@isManualSc, 'N') = 'N'
			BEGIN
				SELECT '1' ErrorCode, 'Service charge not defined yet for receiving country' Msg,NULL id
				RETURN;
			END
			IF @scAction = 'PD' -- Percent Discount
			BEGIN
				SET @scOffer = (@scValue/100) * @serviceCharge
				SET @scDiscount = (@scValue/100) * @serviceCharge
			END
			ELSE IF @scAction = 'FD' -- Flat Discount
			BEGIN
				SET @scDiscount = @scValue
			END
			ELSE IF @scAction = 'FV' -- Fixed Value
			BEGIN
				SET @scOffer = @scValue
				SET @scDiscount = @serviceCharge - @scValue
			END
				
			SET @tAmt = @cAmt - @serviceCharge + @scDiscount
				
			SET @pAmt = @tAmt * (@exRate + @exRateOffer)	
						
			SET @pAmt = FLOOR(@pAmt)
		END
		ELSE
		BEGIN
			--SET @tAmt = CEILING(@pAmt/(@exRate + @exRateOffer), 0)
			SET @tAmt = CEILING(@pAmt/(@exRate + @exRateOffer))
			--SELECT @sCountryId sCountryId, @sSuperAgent sSuperAgent, @sAgent sAgent, @sBranch sBranch 
			--				,@pCountryId pCountryId, @pSuperAgent pSuperAgent, @pAgent pAgent, @pBranch pBranch 
			--				,@deliveryMethodId deliveryMethodId, @tAmt tAmt, @collCurr collCurr
			--				RETURN
			IF ISNULL(@isManualSc, 'N') = 'N'
			BEGIN
				SELECT  @serviceCharge = amount FROM [dbo].FNAGetServiceCharge
						(
							@sCountryId, @sSuperAgent, @sAgent, @sBranch 
							,@pCountryId, @pSuperAgent, @pAgent, @pBranch 
							,@deliveryMethodId, @tAmt, @collCurr
						)
			END
			ELSE
			BEGIN
				SET @serviceCharge = ISNULL(@manualSc, 0)
			END

			IF @serviceCharge IS NULL 
			BEGIN
				SELECT '1' ErrorCode, 'Service charge not defined yet for receiving country' Msg,NULL id
				RETURN;
			END
				
			IF @scAction = 'PD'
			BEGIN
				SET @scOffer = (@scValue/100) * @serviceCharge
				SET @scDiscount = (@scValue/100) * @serviceCharge
			END
			ELSE IF @scAction = 'FD'
			BEGIN
				SET @scDiscount = @scValue
			END
			ELSE IF @scAction = 'FV'
			BEGIN
				SET @scOffer = @scValue
				SET @scDiscount = @serviceCharge - @scValue
			END
				
			SET @cAmt = (@tAmt + @serviceCharge - @scDiscount)

			SET @cAmt = CEILING(@cAmt)
		END	
		
		--4. Validate Country Sending Limit 
        EXEC PROC_CHECKCOUNTRYLIMIT @flag = 's-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
			,@deliveryMethod = @deliveryMethodId,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT

		IF @errorCode <> '0'
		BEGIN
			SELECT @errorCode ErrorCode, @msg Msg
			RETURN;
		END
		
		--Validate Country Sending Limit END

		--5. Validate Country Receiving Limit
        EXEC PROC_CHECKCOUNTRYLIMIT @flag = 'r-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
			,@deliveryMethod = @deliveryMethodId,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT
			
		IF @errorCode <> '0'
		BEGIN
			SELECT @errorCode ErrorCode, @msg Msg
			RETURN;
		END


		IF ISNULL(@ProcessFor ,'')='send'
		BEGIN
			SET @FOREX_SESSION_ID = NEWID()
			
		----## lock ex rate for individual txn
			UPDATE exRateCalcHistory SET isExpired = 1 WHERE CUSTOMER_ID = @senderId AND isExpired = 0
			
			INSERT INTO exRateCalcHistory (
				CUSTOMER_ID,[USER_ID],FOREX_SESSION_ID,serviceCharge,pAmt,customerRate,sCurrCostRate,sCurrHoMargin		
				,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin,agentCrossSettRate,createdDate,isExpired,tAmt,schemeId
			)
			SELECT	@senderId,@user,@FOREX_SESSION_ID,@serviceCharge,@pAmt,@exRate,1,0		
				,0,@pCurrHoMargin+@exRate,@pCurrHoMargin,0,@exRate,GETDATE(),0,@tAmt,@schemeId
		END
			
		SET @msg = 'Success'
		SELECT 
			@errorCode ErrorCode,
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
			scDiscount = @scDiscount,
			tpExRate = 0,
			amountLimitPerDay = 0,
			amountLimitPerTran = 0,
			customerTotalSentAmt = 0,
			exRateDisplay = @exRate,
			EXRATEID = 0,
			maxAmountLimitPerTran = 0,
			minAmountLimitPerTran = 0,
			PerTxnMinimumAmt = 0,
			schemeAppliedMsg = '',
			schemeId = 0,
			tpPCurr = @pCurr,
			collCurr = @collCurr,
			ForexSessionId=@FOREX_SESSION_ID
	END
	ELSE IF @FLAG = 'true'
	BEGIN
		IF ISNULL(@tpExRate, 0) = 0
		BEGIN
			SELECT '1' ErrorCode, 'Third Party Exchange rate fetching error for currency (' + @pCurr + ')' Msg
			RETURN
		END
		
		SELECT 
			@pCurrHoMargin	= pCurrHoMargin
		FROM dbo.FNAGetExRate(@sCountryId,@sAgent,@sBranch,@collCurr,@pCountryId,@pAgent,@pCurr,@deliveryMethodId)
		
		SELECT @exRate =  @tpExRate - ISNULL(@pCurrHoMargin, 0)

		IF ISNULL(@exRate, 0) = 0
		BEGIN
			SELECT '1' ErrorCode, 'Exchange rate not defined yet for receiving currency (' + @pCurr + ')' Msg,NULL id
			RETURN
		END

		IF @calBy = 'C'
		BEGIN
			IF ISNULL(@isManualSc, 'N') = 'N'
			BEGIN
				SELECT @serviceCharge = amount FROM [dbo].FNAGetServiceCharge(
						@sCountryId, @sSuperAgent, @sAgent, @sBranch 
						,@pCountryId, @pSuperAgent, @pAgent, @pBranch 
						,@deliveryMethodId, @cAmt, @collCurr
						)
			END
			ELSE
			BEGIN
				SET @serviceCharge = ISNULL(@manualSc, 0)
			END

				
			IF @serviceCharge IS NULL AND ISNULL(@isManualSc, 'N') = 'N'
			BEGIN
				SELECT '1' ErrorCode, 'Service charge not defined yet for receiving country' Msg,NULL id
				RETURN;
			END
			IF @scAction = 'PD' -- Percent Discount
			BEGIN
				SET @scOffer = (@scValue/100) * @serviceCharge
				SET @scDiscount = (@scValue/100) * @serviceCharge
			END
			ELSE IF @scAction = 'FD' -- Flat Discount
			BEGIN
				SET @scDiscount = @scValue
			END
			ELSE IF @scAction = 'FV' -- Fixed Value
			BEGIN
				SET @scOffer = @scValue
				SET @scDiscount = @serviceCharge - @scValue
			END
				
			SET @tAmt = @cAmt - @serviceCharge + @scDiscount
				
			SET @pAmt = @tAmt * (@exRate + @exRateOffer)	
						
			SET @pAmt = FLOOR(@pAmt)
		END
		ELSE
		BEGIN
			SET @tAmt = CEILING(@pAmt/(@exRate + @exRateOffer))
			IF ISNULL(@isManualSc, 'N') = 'N'
			BEGIN
				SELECT  @serviceCharge = amount FROM [dbo].FNAGetServiceCharge(
						@sCountryId, @sSuperAgent, @sAgent, @sBranch 
						,@pCountryId, @pSuperAgent, @pAgent, @pBranch 
						,@deliveryMethodId, @tAmt, @collCurr
				)
			END
			ELSE
			BEGIN
				SET @serviceCharge = ISNULL(@manualSc, 0)
			END
				
			IF @serviceCharge IS NULL 
			BEGIN
				SELECT '1' ErrorCode, 'Service charge not defined yet for receiving country' Msg,NULL id
				RETURN;
			END
				
			IF @scAction = 'PD'
			BEGIN
				SET @scOffer = (@scValue/100) * @serviceCharge
				SET @scDiscount = (@scValue/100) * @serviceCharge
			END
			ELSE IF @scAction = 'FD'
			BEGIN
				SET @scDiscount = @scValue
			END
			ELSE IF @scAction = 'FV'
			BEGIN
				SET @scOffer = @scValue
				SET @scDiscount = @serviceCharge - @scValue
			END
				
			SET @cAmt = (@tAmt + @serviceCharge - @scDiscount)
			SET @cAmt = ROUND(@cAmt, @currDecimal)
		END	

		--4. Validate Country Sending Limit 
		EXEC PROC_CHECKCOUNTRYLIMIT @flag = 's-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
			,@deliveryMethod = @deliveryMethodId,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT

		IF @errorCode <> '0'
		BEGIN
			SELECT @errorCode ErrorCode, @msg Msg
			RETURN;
		END
		--Validate Country Sending Limit END

		--5. Validate Country Receiving Limit
		EXEC PROC_CHECKCOUNTRYLIMIT @flag = 'r-limit', @cAmt = @cAmt, @pAmt = @pAmt, @sCountryId = @sCountryId, @collMode = @collMode
			,@deliveryMethod = @deliveryMethodId,@sendingCustType = @sendingCustType,@pCountryId = @pCountryId,@pCurr = @pCurr, @collCurr = @collCurr
			,@pAgent = @pAgent, @sAgent = @sAgent, @sBranch = @sBranch
			,@msg = @msg OUT, @errorCode = @errorCode OUT
			
		IF @errorCode <> '0'
		BEGIN
			SELECT @errorCode ErrorCode, @msg Msg
			RETURN;
		END
		--Validate Country Receiving Limit

		IF ISNULL(@ProcessFor ,'')='send'
		BEGIN
			SET @FOREX_SESSION_ID = NEWID()

		----## lock ex rate for individual txn
			UPDATE exRateCalcHistory SET isExpired = 1 WHERE CUSTOMER_ID = @senderId AND isExpired = 0

			INSERT INTO exRateCalcHistory (
				CUSTOMER_ID,[USER_ID],FOREX_SESSION_ID,serviceCharge,pAmt,customerRate,sCurrCostRate,sCurrHoMargin		
				,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin,agentCrossSettRate,createdDate,isExpired,tAmt,schemeId
			)
			SELECT	@senderId,@user,@FOREX_SESSION_ID,@serviceCharge,@pAmt,@exRate,1,0		
				,0,@pCurrHoMargin+@exRate,@pCurrHoMargin,0,@exRate,GETDATE(),0,@tAmt,@schemeId
		END
			
		SET @msg = 'Success'
		SELECT 
			@errorCode ErrorCode,
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
			scDiscount = @scDiscount,
			tpExRate = @tpExRate,
			amountLimitPerDay = 0,
			amountLimitPerTran = 0,
			customerTotalSentAmt = 0,
			exRateDisplay = @exRate,
			EXRATEID = 0,
			maxAmountLimitPerTran = 0,
			minAmountLimitPerTran = 0,
			PerTxnMinimumAmt = 0,
			schemeAppliedMsg = '',
			schemeId = 0,
			tpPCurr = @pCurr,
			collCurr = @collCurr,
			ForexSessionId=@FOREX_SESSION_ID

	END
END
GO

