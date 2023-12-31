USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDomesticPayComm]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetDomesticPayComm](@sBranch INT, @rBranch INT, @tranType INT, @transferAmount MONEY)
RETURNS @list TABLE (masterId BIGINT, pAgentComm MONEY, psAgentComm MONEY)
AS
BEGIN
	DECLARE
		 @sAgent			INT
		,@sState			INT
		,@sLocationGroup	INT
		,@masterId			BIGINT	
		,@found				BIT = 0
		,@rAgent			INT
		,@rState			INT
		,@rLocationGroup	INT
		,@date				DATETIME
		,@sDistrict			VARCHAR(100)
		,@sDistrictId		INT
		,@commGroup			INT
		,@rDistrict			VARCHAR(100)
		,@rDistrictId		INT
	
	DECLARE @commissionRule TABLE(ruleId INT)
	DECLARE @commissionPackage TABLE(packageId INT)
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	
	--1. Get Sending Side Details
		SELECT @agentType = agentType, @sAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		IF @agentType = 2903
		BEGIN
			SET @sAgent = @sBranch
			SET @sBranch = NULL
		END
		
		--Sending State
		SELECT @sState = csm.stateId, @sDistrict = am.agentDistrict FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE agentId = ISNULL(@sBranch, @sAgent)
		
		--Sending Location Group
		SELECT @sDistrictId = districtId FROM zoneDistrictMap WITH(NOLOCK) 
			WHERE districtName = @sDistrict AND ISNULL(isDeleted, 'N') = 'N'
		SELECT @sLocationGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) 
			WHERE groupCat = 6300 AND districtCode = @sDistrictId AND ISNULL(isDeleted, 'N') = 'N'
		
	--End of Sending Agent Details---------------------------------------------------------------------------------------------------------------
	
	--2. Get Paying Side Details-----------------------------------------------------------------------------------------------------------------------
		SELECT @agentType = agentType, @rAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rBranch
		IF @agentType = 2903
		BEGIN
			SET @rAgent = @rBranch
			SET @rBranch = NULL	
		END
		
		--Paying State
		SELECT @rState = csm.stateId, @rDistrict = am.agentDistrict FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE agentId = ISNULL(@rBranch, @rAgent)
		
		--Paying Location Group
		SELECT @rDistrictId = districtId FROM zoneDistrictMap WITH(NOLOCK) 
			WHERE districtName = @rDistrict AND ISNULL(isDeleted, 'N') = 'N'
		SELECT @rLocationGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) 
			WHERE groupCat = 6300 AND districtCode = @rDistrictId AND ISNULL(isDeleted, 'N') = 'N'
		--Commission Group
		SELECT @commGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) 
			WHERE groupCat = 6600 AND agentId = @rAgent AND ISNULL(isDeleted, 'N') = 'N'
		--Commission Package
		INSERT @commissionPackage
		SELECT packageId FROM commissionGroup WITH(NOLOCK) 
			WHERE groupId = @commGroup AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		--Commission Rule
		INSERT @commissionRule
		SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) 
			WHERE packageId IN (SELECT packageId FROM @commissionPackage) AND ruleType = 'ds' 
			AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
	--End of Paying Agent Details----------------------------------------------------------------------------------------------------------------
	
	IF EXISTS(
			SELECT 'x' FROM scMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId
			INNER JOIN scDetail sd WITH(NOLOCK) ON sm.scMasterId = sd.scMasterId
			WHERE 
				ISNULL(sm.isActive, 'N') = 'Y'
			AND ISNULL(sm.isDeleted, 'N') = 'N'
			
			AND
			
			(
				 (sBranch = @sBranch OR sBranch IS NULL)
				 AND (sAgent = @sAgent OR sAgent IS NULL)
				 OR [sState] = @sState
				 OR sGroup = @sLocationGroup
			)
			
			AND
			
			(
				(rBranch = @rBranch OR rBranch IS NULL)
				AND (rAgent = @rAgent OR rAgent IS NULL)
				OR [rState] = @rState
				OR rGroup = @rLocationGroup
			)
			
			AND (tranType = @tranType OR tranType IS NULL)
			AND ISNULL(sd.isActive, 'N') = 'Y'
			AND ISNULL(sd.isDeleted, 'N') = 'N'		
			AND @transferAmount BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	
	BEGIN
		--1 Branch
		--INSERT @list
		--SELECT @sLocationGroup, @rLocationGroup, 1,1,1,1,1
		--RETURN
		IF EXISTS(SELECT 'x' FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 
			AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rLocationGroup) 
			AND (tranType = @tranType OR tranType IS NULL) 
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN			
			SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch 
				AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rGroup = @rLocationGroup 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rGroup = @rLocationGroup 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, pAgentComm, psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN
		END
		
		--2 Agent		
		IF EXISTS(SELECT 'x' FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent 
			AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rLocationGroup) 
			AND (tranType = @tranType OR tranType IS NULL)  
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN				
			SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rBranch = @rBranch 
				AND tranType = @tranType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rBranch = @rBranch 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rAgent = @rAgent 
					AND tranType = @tranType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rAgent = @rAgent 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rGroup = @rLocationGroup 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rGroup = @rLocationGroup 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rState = @rState 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rState = @rState 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			INSERT INTO @list
			SELECT @masterId, pAgentComm, psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN
		END
		
		--3 Agent Group		
		IF EXISTS(SELECT 'x' FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sGroup = @sLocationGroup OR sGroup IS NULL) 
			AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rLocationGroup) 
			AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rBranch = @rBranch AND tranType 
= @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rBranch = @rBranch AND tranType
 IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rAgent = @rAgent AND tranType =
 @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rAgent = @rAgent 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup 
					AND rGroup = @rLocationGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup 
					AND rGroup = @rLocationGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rState = @rState 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rState = @rState 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rBranch = @rBranch 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rBranch = @rBranch 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rAgent = @rAgent 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL 
					AND rAgent = @rAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rGroup = @rLocationGroup 
				AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rGroup = @rLocationGroup 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rState = @rState 
				AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rState = @rState 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			INSERT INTO @list
			SELECT @masterId, pAgentComm, psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN			
		END
		
		--4 State		
		IF EXISTS(SELECT 'x' FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState 
			AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rLocationGroup) 
			AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			
			SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rBranch = @rBranch 
				AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rBranch = @rBranch 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId
					 WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rAgent = @rAgent 
					 AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rAgent = @rAgent 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState 
					AND rGroup = @rLocationGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState 
					AND rGroup = @rLocationGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rState = @rState 
					AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
					WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rState = @rState 
					AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			INSERT INTO @list
			SELECT @masterId, pAgentComm, psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN
		END
		SELECT @masterId = scMasterId FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
			WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch IS NULL AND sAgent IS NULL AND sGroup IS NULL 
			AND sState IS NULL AND rBranch IS NULL AND rAgent IS NULL AND rGroup IS NULL AND rState IS NULL AND tranType = @tranType 
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scMasterId FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId 
				WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch IS NULL AND sAgent IS NULL 
				AND sGroup IS NULL AND sState IS NULL AND rBranch IS NULL AND rAgent IS NULL AND rGroup IS NULL AND rState IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')	
		
		INSERT INTO @list
		SELECT @masterId, pAgentComm, psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
		RETURN
	END
	
	INSERT INTO @list
	SELECT NULL, NULL, NULL
	RETURN
END

GO
