USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetSC]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetSC](@sBranch BIGINT, @rsAgent BIGINT, @rCountry BIGINT, @pLocation BIGINT, @rBranch BIGINT, @serviceType INT, @transferAmount MONEY, @collCurr VARCHAR(3))
RETURNS @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY)
AS
BEGIN
	DECLARE
		 @sAgent			INT
		,@ssAgent			INT	
		,@sCountry			INT
		,@sState			INT
		,@sZip				VARCHAR(10)
		,@sGroup			INT
		,@rAgent			INT
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
	SELECT @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	
	--1. Find Sending Agent Details------------------------------------------------------------------------------------------------------
	SELECT @sGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = @sBranch
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
		SET @sBranch = NULL
	END	
	ELSE
	BEGIN
		SELECT @sAgent = parentId FROM agentMaster WHERE agentId = @sBranch
	END	
	SELECT @sCountry = countryId FROM countryMaster WITH(NOLOCK) 
		WHERE countryName = (SELECT agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent)
	
	SELECT
		 @sState = csm.stateId
		,@sZip = am.agentZip
	FROM agentMaster am WITH(NOLOCK) 
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
	WHERE agentId = @sAgent
	
	SELECT @ssAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
	
	--Location Group
	--Your location Group logic goes here
	--Commission Group
	SELECT @commGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE groupCat = 6600 AND agentId = ISNULL(@sBranch, @sAgent) AND ISNULL(isDeleted, 'N') = 'N'
	--Commission Package
	INSERT @commissionPackage
	SELECT packageId FROM commissionGroup WITH(NOLOCK) WHERE groupId = @commGroup AND ISNULL(isDeleted, 'N') = 'N'
	--Commission Rule
	INSERT @commissionRule
	SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId IN (SELECT packageId FROM @commissionPackage) AND ruleType = 'sc' AND ISNULL(isDeleted, 'N') = 'N'
	
	--2. Find Receiving Agent/Location Details-------------------------------------------------------------------------------------------	
	IF @rBranch IS NOT NULL
	BEGIN
		SELECT @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @rBranch
		IF @agentType = 2903
		BEGIN
			SET @rAgent = @rBranch
			SET @rBranch = NULL	
		END
		ELSE
		BEGIN
			SELECT @rAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rBranch
		END
		SELECT @rGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = ISNULL(@rBranch, @rAgent)
		SELECT @rsAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent
		SELECT
			 @rState = csm.stateId
			,@rZip = am.agentZip
			,@rGroup = am.agentGrp
		FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE agentId = @rAgent
	END
	ELSE IF @pLocation IS NOT NULL
	BEGIN
		SELECT @rGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND districtCode = @pLocation		
		--Your Logic Goes Here To Find Receinving Agent Group From District/Group Mapping
	END

	IF EXISTS(
			SELECT 'x' FROM sscMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId
			INNER JOIN sscDetail sd WITH(NOLOCK) ON sm.sscMasterId = sd.sscMasterId
			WHERE 
				ISNULL(sm.isActive, 'N') = 'Y'
			AND ISNULL(sm.isDeleted, 'N') = 'N'
			
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
				AND (rCountry = @rCountry OR rCountry IS NULL)
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
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN
		END
		
		--2 Agent and Agent Group		
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL)  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch				
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group		
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
					
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group			
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State	
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			--7. Receiving Country
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN
		END
		
		--3 Super Agent
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN
		END
		
		--3 Agent Group		
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group				
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND agentGroup = @sGroup AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN			
		END
		
		--4 Zip		
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group			
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group			
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country				
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN
		END
		
		--5 State		
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group			
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL		
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')		
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN
		END
		
		
		--6 Country
		IF EXISTS(SELECT 'x' FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1	
			--1. Receiving Branch		
			SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group		
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group		
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = sscMasterId  FROM sscMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.sscMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN
		END
	END
	/*	
	ELSE 
	BEGIN
		IF EXISTS(
			SELECT 'x' FROM dscMaster dm WITH(NOLOCK)
			INNER JOIN dscDetail dd WITH(NOLOCK) ON dm.dscMasterId = dd.dscMasterId
			WHERE ISNULL(dm.isActive, 'N') = 'Y' 
			AND ISNULL(dm.isDeleted, 'N') = 'N' 
			AND sCountry = @sCountry 
			AND rCountry = @rCountry 
			AND baseCurrency = @collCurr
			AND (tranType = @serviceType OR tranType IS NULL)
			AND ISNULL(dd.isActive, 'N') = 'Y'
			AND ISNULL(dd.isDeleted, 'N') = 'N'		
			AND @transferAmount BETWEEN fromAmt and toAmt
		)
		BEGIN
			SELECT @masterType = 'D', @found = 1
			SELECT @masterId = dscMasterId FROM dscMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType
			IF @masterId IS NULL
				SELECT @masterId = dscMasterId FROM dscMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetSCAmt(@masterId, @masterType, @transferAmount)
			RETURN
		END
	END
	*/
	INSERT INTO @list
	SELECT NULL, NULL, NULL
	RETURN
END
GO
