USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetPayCommOnline]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetPayCommOnline](
		 @sCountry INT, @ssAgent INT, @sAgent INT, @sBranch INT
		,@rCountry INT, @rsAgent INT, @rAgent INT, @rBranch INT
		,@collCurr				VARCHAR(3)
		,@payoutCurr			VARCHAR(3)
		,@serviceType			INT
		,@collAmt				MONEY
		,@payAmt				MONEY
		,@serviceCharge			MONEY
		,@hubComm				MONEY
		,@agentComm				MONEY
		,@sSettlementRate		FLOAT
		,@pSettlementRate		FLOAT	
		)
RETURNS @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY, commissionCurrency VARCHAR(3), commissionType CHAR(1), pcnt MONEY)
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
	DECLARE @amount MONEY, @commissionType CHAR(1), @pcnt MONEY
	
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	
	IF @sBranch IS NOT NULL
	BEGIN
		SELECT
			 @agentType = am.agentType
			,@sState = csm.stateId
			,@sZip = agentZip
		FROM agentMaster am WITH(NOLOCK)
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE am.agentId = @sBranch
			
		IF @agentType = 2903
		BEGIN
			SET @sAgent = @sBranch
			SET @sBranch = NULL
		END
		SELECT @sGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = ISNULL(@sBranch, @sAgent)
	END
	
	--2. Find Receiving Agent/Location Details-------------------------------------------------------------------------------------------		
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

	--SELECT @rGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = ISNULL(@rBranch, @rAgent)

	--Paying Location Group
	IF EXISTS(SELECT 'X' FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = ISNULL(@rBranch, @rAgent) AND ruleType = 'cp' AND ISNULL(isActive, 'N') = 'Y')
	BEGIN
		INSERT @commissionRule
		SELECT DISTINCT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = ISNULL(@rBranch, @rAgent) AND ruleType = 'cp' AND ISNULL(isActive, 'N') = 'Y'
	END
	ELSE IF EXISTS(SELECT 'X' FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = @rAgent AND ruleType = 'cp' AND ISNULL(isActive, 'N') = 'Y')
	BEGIN
		INSERT @commissionRule
		SELECT DISTINCT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE agentId = @rAgent AND ruleType = 'cp' AND ISNULL(isActive, 'N') = 'Y'
	END
	ELSE
	BEGIN
		--Commission Group
		SELECT @commGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE groupCat = 6600 AND agentId = @rAgent AND ISNULL(isDeleted, 'N') = 'N'
		--Commission Package
		INSERT @commissionPackage
		SELECT packageId FROM commissionGroup WITH(NOLOCK) WHERE groupId = @commGroup AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		--Commission Rule
		INSERT @commissionRule
		SELECT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId IN (SELECT packageId FROM @commissionPackage) AND ruleType = '6500' AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
	END
	IF EXISTS(
			SELECT 'x' FROM scPayMaster sm WITH(NOLOCK)
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			INNER JOIN scPayDetail sd WITH(NOLOCK) ON sm.scPayMasterId = sd.scPayMasterId
			WHERE 
				ISNULL(sm.isActive, 'N') = 'Y'
			AND ISNULL(sm.isEnable, 'N') = 'Y'
			AND ISNULL(sm.isDeleted, 'N') = 'N'
			AND
			(
				 (sBranch = @sBranch OR sBranch IS NULL)
				 AND (sAgent = @sAgent OR sAgent IS NULL)
				 AND (sCountry = @sCountry OR sCountry IS NULL)
				 AND (ssAgent = @ssAgent OR ssAgent IS NULL)
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
			--AND baseCurrency = @payoutCurr
			AND (tranType = @serviceType OR tranType IS NULL)
			AND ISNULL(sd.isActive, 'N') = 'Y'
			AND ISNULL(sd.isDeleted, 'N') = 'N'		
			--AND @payAmt BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	
	BEGIN -- Special Setting
		SET @masterType = 'S'
		--1 Branch
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent						
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
					
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
							
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			SELECT @amount = amount, @commissionType = commissionType, @pcnt = pcnt FROM [dbo].FNAGetPayCommDetailOnline(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 'p', @sSettlementRate, @pSettlementRate, @collCurr, @payoutCurr)
			INSERT INTO @list
			SELECT @masterId, @masterType, @amount, commissionCurrency, @commissionType, @pcnt FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
		
		--2 Agent and Agent Group		
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND sBranch IS NULL AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND (tranType = @serviceType OR tranType IS NULL)  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch				
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rBranch = @rBranch AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rBranch = @rBranch AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent or Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup = @rGroup) AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup IS NULL) AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup = @rGroup) AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup IS NULL) AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup = @rGroup) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup IS NULL) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup = @rGroup) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND (rAgent = @rAgent AND rBranch IS NULL AND agentGroup IS NULL) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rZip = @rZip AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rZip = @rZip AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rZip = @rZip AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rZip = @rZip AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rState = @rState AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rState = @rState AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup = @sGroup) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND sBranch IS NULL AND agentGroup IS NULL) AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			SELECT @amount = amount, @commissionType = commissionType, @pcnt = pcnt FROM [dbo].FNAGetPayCommDetail(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 'p', @sSettlementRate, @pSettlementRate, @collCurr, @payoutCurr)
			INSERT INTO @list
			SELECT @masterId, @masterType, @amount, commissionCurrency, @commissionType, @pcnt FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
		
		--3 Super Agent
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND rAgentGroup IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent						
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rAgentGroup = @rGroup AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rAgentGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rZip = @rZip AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rZip = @rZip AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
					
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rState = @rState AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
							
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			SELECT @amount = amount, @commissionType = commissionType, @pcnt = pcnt FROM [dbo].FNAGetPayCommDetail(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 'p', @sSettlementRate, @pSettlementRate, @collCurr, @payoutCurr)
			INSERT INTO @list
			SELECT @masterId, @masterType, @amount, commissionCurrency, @commissionType, @pcnt FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
		
	
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ((sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL) OR sCountry IS NULL) AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch		
			IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ((sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL) OR sCountry IS NULL) AND rBranch = @rBranch AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
			BEGIN 
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND rBranch = @rBranch AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			END
			--2. Receiving Agent and Agent Group
			IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ((sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL) OR sCountry IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')) 
			BEGIN
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			END
			--3. Receiving Super Agent
			IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ((sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL) OR sCountry IS NULL) AND rsAgent = @rsAgent AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
			BEGIN
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND rsAgent = @rsAgent AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				IF @masterId IS NULL
					SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND rsAgent = @rsAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			END
		
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND ssAgent IS NULL AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND sAgent IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL AND sAgent IS NULL AND rCountry = @rCountry AND rsAgent IS NULL AND rAgent IS NULL AND rBranch IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			
			SELECT @amount = amount, @commissionType = commissionType, @pcnt = pcnt FROM [dbo].FNAGetPayCommDetail(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @agentComm, 'p', @sSettlementRate, @pSettlementRate, @collCurr, @payoutCurr)
			INSERT INTO @list
			SELECT @masterId, @masterType, @amount, commissionCurrency, @commissionType, @pcnt FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
	END
	INSERT INTO @list
	SELECT NULL, NULL, NULL, NULL, NULL, NULL
	RETURN
END
GO
