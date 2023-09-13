
ALTER FUNCTION [dbo].[FNAGetSendComm](
		 @sCountry INT, @ssAgent INT, @sAgent INT, @sBranch INT
		,@rCountry INT, @rsAgent INT, @rAgent INT, @rBranch INT
		,@collCurr VARCHAR(3),@serviceType INT
		,@collAmt MONEY
		,@payAmt MONEY
		,@serviceCharge MONEY
		,@hubComm MONEY
		,@agentComm MONEY
		,@sSettlementRate FLOAT
		,@pSettlementRate FLOAT
		)
RETURNS @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY, commissionCurrency VARCHAR(3))
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
		,@commissionBase	INT
		,@amt				MONEY
		,@commGroup			INT
	
	DECLARE @commissionRule TABLE(ruleId INT)
	DECLARE @commissionPackage TABLE(packageId INT)
	
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	
	--1. Find Sending Agent Details-------------------------------------------------------------------------------------------------------
	SELECT 
		 @agentType = agentType
		,@sState = csm.stateId
		,@sZip = agentZip 
	FROM agentMaster am WITH(NOLOCK)
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName 
	WHERE agentId = @sBranch
	
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
		SET @sBranch = NULL
	END	
	
	--*****Check For Payout Super Agent*****
	IF @rAgent IS NOT NULL AND @rsAgent IS NULL
		SELECT @rsAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent
		
	SELECT @sGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = ISNULL(@sBranch, @sAgent)		
	
	--Location Group
	--Your location Group logic goes here
	IF EXISTS(SELECT 'X' FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = ISNULL(@sBranch, @sAgent) AND ruleType = 'cs')
	BEGIN
		INSERT @commissionRule
		SELECT DISTINCT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = ISNULL(@sBranch, @sAgent) AND ruleType = 'cs'
	END
	ELSE IF EXISTS(SELECT 'X' FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = @sAgent AND ruleType = 'cs')
	BEGIN
		INSERT @commissionRule
		SELECT DISTINCT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = @sAgent AND ruleType = 'cs'
	END
	ELSE
	BEGIN
		--Commission Group
		SELECT @commGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE groupCat = 6600 AND agentId = ISNULL(@sBranch, @sAgent) AND ISNULL(isDeleted, 'N') = 'N'
		--Commission Package
		INSERT @commissionPackage
		SELECT packageId FROM commissionGroup WITH(NOLOCK) WHERE groupId = @commGroup AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		--Commission Rule
		INSERT @commissionRule
		SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId IN (SELECT packageId FROM @commissionPackage) AND ruleType = '6450' AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
	END
	--2. Find Receiving Agent and Location Details	
	IF @rBranch IS NOT NULL
	BEGIN
		SELECT 
			 @agentType = agentType 
			,@rState = csm.stateId
			,@rZip = agentZip
		FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName 
		WHERE agentId = @rBranch
		
		IF @agentType = 2903
		BEGIN
			SET @rAgent = @rBranch
			SET @rBranch = NULL
		END
		SELECT @rGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = ISNULL(@rBranch, @rAgent)
	END
	
	IF EXISTS(
			SELECT 'x' FROM scSendMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId
			INNER JOIN scSendDetail sd WITH(NOLOCK) ON sm.scSendMasterId = sd.scSendMasterId
			WHERE 
				ISNULL(sm.isActive, 'N') = 'Y'
			AND ISNULL(sm.isEnable, 'N') = 'Y'
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
			--AND @collAmt BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	
	BEGIN -- Special Setting
		SET @masterType = 'S'
		--1 Branch
		IF EXISTS(SELECT 'x' FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rBranch 
= @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch			
			SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group	
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--8. All Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			SELECT @commissionBase = commissionBase FROM scSendMaster WHERE scSendMasterId = @masterId
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 's', @sSettlementRate, @pSettlementRate, @collCurr, NULL), baseCurrency FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @masterId
			RETURN
		END

		--2 Agent and Agent Group	
		IF EXISTS(SELECT 'x' FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND sBranch IS 
NULL AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL)  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch						
			SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent
 AND sBranch IS NULL AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'
)
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'
)
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')


			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'
)
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State	
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--8. All Receiving Country
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo,
 '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
					
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 's', @sSettlementRate, @pSettlementRate, @collCurr, NULL), baseCurrency FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @masterId
			RETURN
		END
		
		--3 Super Agent		
		IF EXISTS(SELECT 'x' FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rCountry IS NULL) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch
			SET @found = 1
			SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')


			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')


			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group			
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo,
 '2100-12-31')
			
			--8. All Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL) AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 's', @sSettlementRate, @pSettlementRate, @collCurr, NULL), baseCurrency FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @masterId
			RETURN			
		END
		
		--4 Zip		
		IF EXISTS(SELECT 'x' FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group			
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
(rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
(rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
(rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
(rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group				
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--8. All Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND 
rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 's', @sSettlementRate, @pSettlementRate, @collCurr, NULL), baseCurrency FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @masterId
			RETURN
		END
		
		--5 State
		IF EXISTS(SELECT 'x' FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rBranch =
@rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState
 AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and AGent Group		
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent	
			IF @masterId IS NULL		
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receving Agent Group		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL		
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--8. All Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry IS NULL AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 's', @sSettlementRate, @pSettlementRate, @collCurr, NULL), baseCurrency FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @masterId
			RETURN
		END
		--INSERT INTO @list
		--SELECT TOP 1 ruleId,@masterId,1,1 FROM @commissionRule
		--RETURN
		--6 Country
		IF EXISTS(SELECT 'x' FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent
 IS NULL AND sAgent IS NULL AND sBranch IS NULL AND (rBranch = @rBranch OR rAgent = @rAgent OR (rCountry = @rCountry OR rCountry IS NULL)) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1	
			--1. Receiving Branch		
			SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND
 ISNULL(effectiveTo, '2100-12-31')
			
			--8. All Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rCountry IS NULL AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterId  FROM scSendMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scSendMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rCountry IS NULL AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 's', @sSettlementRate, @pSettlementRate, @collCurr, NULL), baseCurrency FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @masterId
			RETURN
		END
	END
	INSERT INTO @list
	SELECT NULL, NULL, NULL, NULL
	RETURN
END

