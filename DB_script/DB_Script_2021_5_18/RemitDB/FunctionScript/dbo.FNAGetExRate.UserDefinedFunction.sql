USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetExRate]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetExRate]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].FNAGetExRate
GO
*/
/*
	SELECT * FROM dbo.FNAGetExRate(133,13345,NULL,'MYR',16,NULL,'BDT',NULL)
*/
CREATE FUNCTION [dbo].[FNAGetExRate](@cCountry INT, @cAgent INT, @cBranch INT, @cCurrency VARCHAR(3), @pCountry INT, @pAgent INT, @pCurrency VARCHAR(3), @tranType INT)
RETURNS @list TABLE (
		 exRateTreasuryId		BIGINT
		,customerRate			FLOAT
		,sCurrCostRate			FLOAT
		,sCurrHoMargin			FLOAT
		,sCurrAgentMargin		FLOAT
		,pCurrCostRate			FLOAT
		,pCurrHoMargin			FLOAT
		,pCurrAgentMargin		FLOAT
		,sAgentSettRate			FLOAT
		,pAgentSettRate			FLOAT
		,agentCrossSettRate		FLOAT
		,treasuryTolerance		FLOAT
		,customerPremium		FLOAT
		,sharingValue			MONEY
		,sharingType			CHAR(1)
		)
AS
BEGIN
	DECLARE @exRateTreasuryId BIGINT, @premium FLOAT
	DECLARE @customerRate FLOAT
	
	----FETCH EXRATE FROM COST RATE SETUP FOR DIRECT DEALING WITH KRW (BNI:KRW VS IDR)
	IF EXISTS(SELECT 'A' FROM defExRate(NOLOCK) WHERE country = @pCountry AND currency = @pCurrency AND baseCurrency = 'KRW' AND IsActive='Y') --FOR INDONESIA
	BEGIN
		DECLARE @sCurrCostRate MONEY
		SELECT @sCurrCostRate = cRate
		FROM defExRate(NOLOCK) 
		WHERE country = 118 AND currency = 'KRW' AND baseCurrency = 'USD' AND IsActive='Y'

		INSERT INTO @list
		SELECT defExRateId,pRate - ISNULL(pMargin,0) AS customerRate,@sCurrCostRate sCurrCostRate,0 sCurrHoMargin ,0 sCurrAgentMargin,pRate AS pCurrCostRate,pMargin AS pCurrHoMargin,0 pCurrAgentMargin
			, 0 sAgentSettRate, 0 pAgentSettRate ,pRate - ISNULL(pMargin,0) AS agentCrossSettRate,0 treasuryTolerance,0 customerPremium,0 sharingValue,'' sharingType
		FROM defExRate(NOLOCK) 
		WHERE country = @pCountry AND currency = @pCurrency 
		AND baseCurrency = 'KRW' AND IsActive='Y'
		AND ISNULL(tranType,@tranType) = @tranType
		RETURN
	END

	--1. Search By Sending Branch and Receiving Agent
	IF EXISTS(SELECT 'X' FROM exRateTreasury ert WITH(NOLOCK) INNER JOIN exRateBranchWise erbw WITH(NOLOCK)
				ON ert.exRateTreasuryId = erbw.exRateTreasuryId
				WHERE
				cBranch = @cBranch AND ISNULL(ert.isActive, 'N') = 'Y' AND ISNULL(erbw.isActive, 'N') = 'Y'
				AND pCurrency = @pCurrency
				AND pCountry = @pCountry
				AND (pAgent = @pAgent)
				)
	BEGIN
		SELECT @exRateTreasuryId = ert.exRateTreasuryId, @premium = erbw.premium FROM exRateTreasury ert WITH(NOLOCK) INNER JOIN exRateBranchWise erbw WITH(NOLOCK)
				ON ert.exRateTreasuryId = erbw.exRateTreasuryId
				WHERE
				cBranch = @cBranch AND ISNULL(ert.isActive, 'N') = 'Y' AND ISNULL(erbw.isActive, 'N') = 'Y'
				AND pCurrency = @pCurrency
				AND pCountry = @pCountry
				AND (pAgent = @pAgent)
		
		SELECT @customerRate = ISNULL(crossRateOperation,customerRate) + ISNULL(@premium, 0) FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
		
		INSERT INTO @list
		SELECT @exRateTreasuryId, @customerRate, sCurrCostRate, sCurrHoMargin, sCurrAgentMargin, pCurrCostRate, pCurrHoMargin, pCurrAgentMargin, sAgentSettRate, pAgentSettRate
		, agentCrossSettRate, treasuryTolerance, ISNULL(@premium, customerPremium), sharingValue, sharingType FROM dbo.FNAGetExRateDetails(@exRateTreasuryId)
		RETURN
	END
	
	--2. Search By Sending Agent and Receiving Agent
	IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cAgent = @cAgent AND (pAgent = @pAgent) AND (pCountry = @pCountry) AND (tranType = @tranType OR tranType IS 
NULL))
	BEGIN
		SELECT @exRateTreasuryId = exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cAgent = @cAgent AND pAgent = @pAgent AND tranType = @tranType
		IF @exRateTreasuryId IS NULL
			SELECT @exRateTreasuryId = exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cAgent = @cAgent AND pAgent = @pAgent AND tranType IS NULL
		
		INSERT INTO @list
		SELECT @exRateTreasuryId, customerRate, sCurrCostRate, sCurrHoMargin, sCurrAgentMargin, pCurrCostRate, pCurrHoMargin, pCurrAgentMargin, sAgentSettRate, pAgentSettRate, agentCrossSettRate
		, treasuryTolerance, customerPremium, sharingValue, sharingType FROM dbo.FNAGetExRateDetails(@exRateTreasuryId)
		RETURN
		
		--INSERT INTO @list
		--SELECT 1,1,1,1,1,1,1,1,1,1,1,1,1,1
		--RETURN
	END
	
	--3. Search By Sending Branch and Receiving Country
	IF EXISTS(SELECT 'X' FROM exRateTreasury ert WITH(NOLOCK) INNER JOIN exRateBranchWise erbw WITH(NOLOCK)
				ON ert.exRateTreasuryId = erbw.exRateTreasuryId
				WHERE
				cBranch = @cBranch AND ISNULL(ert.isActive, 'N') = 'Y' AND ISNULL(erbw.isActive, 'N') = 'Y'
				AND pCurrency = @pCurrency
				AND pCountry = @pCountry
				AND (pAgent IS NULL)
				)
	BEGIN
		SELECT @exRateTreasuryId = ert.exRateTreasuryId, @premium = erbw.premium FROM exRateTreasury ert WITH(NOLOCK) INNER JOIN exRateBranchWise erbw WITH(NOLOCK)
				ON ert.exRateTreasuryId = erbw.exRateTreasuryId
				WHERE
				cBranch = @cBranch AND ISNULL(ert.isActive, 'N') = 'Y' AND ISNULL(erbw.isActive, 'N') = 'Y'
				AND pCurrency = @pCurrency
				AND pCountry = @pCountry
				AND (pAgent IS NULL)
				
		SELECT @customerRate = ISNULL(crossRateOperation,customerRate) + ISNULL(@premium, 0) FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
		
		INSERT INTO @list
		SELECT @exRateTreasuryId, @customerRate, sCurrCostRate, sCurrHoMargin, sCurrAgentMargin, pCurrCostRate, pCurrHoMargin, pCurrAgentMargin, sAgentSettRate, pAgentSettRate, agentCrossSettRate
		, treasuryTolerance, customerPremium, sharingValue, sharingType FROM dbo.FNAGetExRateDetails(@exRateTreasuryId)
		RETURN
	END
	
	--4. Search By Sending Agent and Receiving Country
	IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cAgent = @cAgent AND (pAgent IS NULL) 
	AND (pCountry = @pCountry) AND (tranType = @tranType OR tranType IS NULL))
	BEGIN
		SELECT @exRateTreasuryId = exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cAgent = @cAgent 
		AND pCountry = @pCountry AND pAgent IS NULL AND tranType = @tranType
		IF @exRateTreasuryId IS NULL
			SELECT @exRateTreasuryId = exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cAgent = @cAgent AND pCountry = @pCountry AND pAgent IS NULL AND tranType IS NULL
		
		INSERT INTO @list
		SELECT @exRateTreasuryId, customerRate, sCurrCostRate, sCurrHoMargin, sCurrAgentMargin, pCurrCostRate, pCurrHoMargin, pCurrAgentMargin, sAgentSettRate, pAgentSettRate, agentCrossSettRate,
		 treasuryTolerance, customerPremium, sharingValue, sharingType FROM dbo.FNAGetExRateDetails(@exRateTreasuryId)
		RETURN
		
		--INSERT INTO @list
		--SELECT 1,1,1,1,1,1,1,1,1,1,1,1,1,1
		--RETURN
	END
	
	--3. Search By Sending Country and Receiving Agent/Country
	IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cCountry = @cCountry AND cAgent IS NULL 
	AND (pAgent = @pAgent OR pAgent IS NULL) AND (pCountry = @pCountry) AND (tranType = @tranType OR tranType IS NULL))
	BEGIN
		SELECT @exRateTreasuryId = exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) 
		WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cCountry = @cCountry 
		AND cAgent IS NULL AND pAgent = @pAgent AND tranType = @tranType
		IF @exRateTreasuryId IS NULL
		BEGIN
			SELECT @exRateTreasuryId = exRateTreasuryId 
			FROM exRateTreasury WITH(NOLOCK) 
			WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cCountry = @cCountry AND cAgent IS NULL AND pAgent = @pAgent AND tranType IS NULL
		END
		IF @exRateTreasuryId IS NULL
		BEGIN
			SELECT @exRateTreasuryId = exRateTreasuryId 
			FROM exRateTreasury WITH(NOLOCK) 
			WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cCountry = @cCountry AND cAgent IS NULL 
			AND pCountry = @pCountry AND pAgent IS NULL AND tranType = @tranType
		END
		IF @exRateTreasuryId IS NULL
		BEGIN
			SELECT @exRateTreasuryId = exRateTreasuryId 
			FROM exRateTreasury WITH(NOLOCK) 
			WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @cCurrency AND pCurrency = @pCurrency AND cCountry = @cCountry 
			AND cAgent IS NULL AND pCountry = @pCountry AND pAgent IS NULL AND tranType IS NULL
		END
		INSERT INTO @list
		SELECT @exRateTreasuryId, customerRate, sCurrCostRate, sCurrHoMargin, sCurrAgentMargin, pCurrCostRate, pCurrHoMargin, pCurrAgentMargin, sAgentSettRate, pAgentSettRate, agentCrossSettRate,
		 treasuryTolerance, customerPremium, sharingValue, sharingType 
		 FROM dbo.FNAGetExRateDetails(@exRateTreasuryId)
		RETURN
	END

	
	INSERT INTO @list
	SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	RETURN
END

GO
