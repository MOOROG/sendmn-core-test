USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetServiceCharge]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetServiceCharge](
	 @sCountry INT, @ssAgent INT, @sAgent INT, @sBranch INT
	,@rCountry INT, @rsAgent INT, @rAgent INT, @rBranch INT
	,@serviceType INT, @transferAmount MONEY, @collCurr VARCHAR(3)
)
RETURNS @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY)
AS
BEGIN
	DECLARE
		 @sState			INT
		,@sZip				VARCHAR(10)
		,@sGroup			INT
		,@masterId			BIGINT	
		,@found				BIT = 0
		,@masterType		CHAR(1)
		,@rState			INT
		,@rGroup			INT
		,@rZip				INT
		,@date				DATETIME
		,@commGroup			INT
	
	DECLARE @commissionRule TABLE(ruleId INT)
	DECLARE @commissionPackage TABLE(packageId INT)
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	SELECT 
		 @agentType = agentType
		,@sState = csm.stateId
		,@sZip = am.agentZip 
	FROM agentMaster am WITH(NOLOCK)
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName WHERE am.agentId = @sBranch
	
	--1. Find Sending Agent Details
	SELECT @sGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 
		AND agentId = @sBranch
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
		SET @sBranch = NULL
	END	
	
	--*****Check For Payout Super Agent*****
	IF @rAgent IS NOT NULL AND @rsAgent IS NULL
		SELECT @rsAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent
	
	--Location Group
	--Your location Group logic goes here

	--IF EXISTS(SELECT 'X' FROM agentCommissionRule WITH(NOLOCK) WHERE (agentId = ISNULL(@sBranch, @sAgent) OR agentId = @sAgent) AND ruleType = 'sc' AND ISNULL(isActive, 'N') = 'Y')
	--BEGIN
	--	INSERT @commissionRule
	--	SELECT DISTINCT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = ISNULL(@sBranch, @sAgent) AND ruleType = 'sc' AND ISNULL(isActive, 'N') = 'Y'
	--	UNION ALL
	--	SELECT DISTINCT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = @sAgent AND ruleType = 'sc' AND ISNULL(isActive, 'N') = 'Y'
	--END
	--ELSE IF EXISTS(SELECT 'X' FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = @sAgent AND ruleType = 'sc' AND ISNULL(isActive, 'N') = 'Y')
	--BEGIN
	--	INSERT @commissionRule
	--	SELECT DISTINCT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = @sAgent AND ruleType = 'sc' AND ISNULL(isActive, 'N') = 'Y'
	--END
	--ELSE
	--BEGIN
	--	--Commission Group
	--	SELECT @commGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE groupCat = 6600 AND agentId = ISNULL(@sBranch, @sAgent) AND ISNULL(isDeleted, 'N') = 'N'
	--	--Commission Package
	--	INSERT @commissionPackage
	--	SELECT packageId FROM commissionGroup WITH(NOLOCK) WHERE groupId = @commGroup AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
	--	--Commission Rule
	--	INSERT @commissionRule
	--	SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId IN (SELECT packageId FROM @commissionPackage) 
	--	AND ruleType = 'sc'
	--	--ruleType = '6400'
	--	 AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
	--END

	SELECT @commGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE groupCat = 6600 AND agentId = ISNULL(@sBranch, @sAgent) AND ISNULL(isDeleted, 'N') = 'N'
		--Commission Package
		INSERT @commissionPackage
		SELECT packageId FROM commissionGroup WITH(NOLOCK) WHERE groupId = @commGroup AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		--Commission Rule
		INSERT @commissionRule
		SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId IN (SELECT packageId FROM @commissionPackage) 
		AND ruleType = 'sc'
		--ruleType = '6400'
		 AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'


	--2. Find Receiving Agent/Location Details
	IF @rBranch IS NOT NULL
	BEGIN
		SELECT 
			 @agentType = agentType 
			,@rState = csm.stateId
			,@rZip = am.agentZip
		FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE am.agentId = @rBranch
		
		IF @agentType = 2903
		BEGIN
			SET @rAgent = @rBranch
			SET @rBranch = NULL	
		END
		SELECT @rGroup = groupDetail FROM agentGroupMaping(nolock) WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 
		AND agentId = ISNULL(@rBranch, @rAgent)
	END
	
	IF EXISTS(
			SELECT 'x' FROM sscMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId
			INNER JOIN sscDetail sd WITH(NOLOCK) ON sm.sscMasterId = sd.sscMasterId
			WHERE 
				ISNULL(sm.isActive, 'N') = 'Y'
			AND ISNULL(sm.isDeleted, 'N') = 'N'
			and sm.sCountry = @sCountry
			and sm.rCountry = @rCountry
			AND
			
			(
				 (sBranch = @sBranch OR sBranch IS NULL)
				 AND (ssAgent = @ssAgent OR ssAgent IS NULL)
				 AND (sAgent = @sAgent OR sAgent IS NULL)
				 OR [state] = @sState
				 OR agentGroup = @sGroup
				 OR zip = @sZip
			)
			
			AND
			
			(
				(rBranch = @rBranch OR rBranch IS NULL)
				AND (rAgent = @rAgent OR rAgent IS NULL)
				AND (rsAgent = @rsAgent OR rsAgent IS NULL)
				OR [rState] = @rState
				OR rAgentGroup = @rGroup
				OR rZip = @rZip
			)
			AND baseCurrency = @collCurr
			AND (tranType = @serviceType OR tranType IS NULL)
			AND ISNULL(sd.isActive, 'N') = 'Y'
			AND ISNULL(sd.isDeleted, 'N') = 'N'		
			AND @transferAmount BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	
	BEGIN -- Special Setting

		SET @masterType = 'S'
		
		--1 Branch
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
		WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) 
		AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency= @collCurr 
			AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch 
				AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry

			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE
				 ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rBranch IS NULL 
				 AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') 
				 AND ISNULL(effectiveTo, '2100-12-31')and sm.sCountry = @sCountry and sm.rCountry = @rCountry

			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr 
				ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND sBranch = @sBranch AND (rAgent = @rAgent AND rBranch IS NULL 
				AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND 
				@date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry

			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent 
				AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND 
				@date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31') and sm.sCountry = @sCountry and sm.rCountry = @rCountry

			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND 
				sBranch = @sBranch AND (rAgent = @rAgent AND rBranch IS NULL 
				AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr 
				ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND 
				rsAgent = @rsAgent AND rAgent IS NULL  AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType 
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31') and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE 
				ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND rAgent IS NULL 
				AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			
						
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' 
				AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND rsAgent IS 
				NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN 
				ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry

			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND 
				sBranch = @sBranch AND rCountry = @rCountry AND rsAgent IS 
				NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			
			IF @masterId IS NOT NULL
			BEGIN
				INSERT INTO @list
				SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
				RETURN
			END
		END
		
		--2 Agent and Agent Group		
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL) AND (rBranch = @rBranch 
		OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL)  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch				
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE
			 ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
			AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE 
				ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND 
				(sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
				AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE 
				ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date 
				BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			
			--2. Receiving Agent and Agent Group		
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' 
				AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' 
				AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND
				 @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType 
				 AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId
				 WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND 
				(sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND 
				(sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN 
				ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31') and sm.sCountry = @sCountry and sm.rCountry = @rCountry
					
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
				AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date 
				BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId
				 WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) 
				AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN 
				ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) 
				AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			
			--7. Receiving Country
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry 
				AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE 
				ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry 
				AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry 
				AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry 
				AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			
			IF @masterId IS NOT NULL
			BEGIN	
				INSERT INTO @list
				SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
				RETURN
			END
		END
		
		--3 Super Agent
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND (rBranch= @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) 
			AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))

		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL 
			AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') 
			AND ISNULL(effectiveTo, '2100-12-31')
			and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE 
				ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL

				AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
			begin
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) 
				AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND 
				sAgent IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr
				 AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date 
				BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL
				AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL 
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			--3. Receiving Super Agent
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL



				AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL



				AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			
			--7. Receiving Country
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL



				 AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				 and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL



				AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NOT NULL
			BEGIN
				INSERT INTO @list
				SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
				RETURN
			END
		END
		
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL 
		AND sBranch IS NULL AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-1


2-31'))
		BEGIN
			SET @found = 1	
			--1. Receiving Branch		
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
			IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			
			--2. Receiving Agent and Agent Group		
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			
						
			--7. Receiving Country
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '210


0-12-31')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent 
				IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31


')
				and sm.sCountry = @sCountry and sm.rCountry = @rCountry
			END
			
			IF @masterId IS NOT NULL
			BEGIN

				INSERT INTO @list
				SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
				RETURN
			END
		END
	END
	INSERT INTO @list
	SELECT NULL, NULL, NULL
	RETURN
END




GO
