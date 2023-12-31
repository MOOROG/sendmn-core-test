USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDomesticPayCommForCancel]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetDomesticPayCommForCancel](@sBranch INT, @pLocation INT, @tranType INT, @transferAmount MONEY)
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
	DECLARE @totalRows INT, @count INT, @pAgentComm1 MONEY, @pAgentComm2 MONEY = 99999, @psAgentComm1 MONEY, @psAgentComm2 MONEY = 99999
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	
	--1. Get Sending Side Details
		SELECT @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		IF @agentType = 2903
		BEGIN
			SET @sAgent = @sBranch
			SET @sBranch = NULL
		END	
		ELSE
		BEGIN
			SELECT @sAgent = parentId FROM agentMaster WHERE agentId = @sBranch
		END	
		
		--Sending State
		SELECT @sState = csm.stateId FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE agentId = @sAgent
		
		--Sending Location Group
		SELECT @sDistrict = agentDistrict FROM agentMaster WITH(NOLOCK) WHERE agentId = ISNULL(@sBranch, @sAgent)
		SELECT @sDistrictId = districtId FROM zoneDistrictMap WITH(NOLOCK) WHERE districtName = @sDistrict AND ISNULL(isDeleted, 'N') = 'N'
		SELECT @sLocationGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) WHERE groupCat = 6300 AND districtCode = @sDistrictId AND ISNULL(isDeleted, 'N') = 'N'
		
	--End of Sending Agent Details---------------------------------------------------------------------------------------------------------------
	
	--2. Get Paying Side Details-----------------------------------------------------------------------------------------------------------------------
		--Paying Location Group
		SELECT @rDistrictId = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @pLocation
		SELECT @rLocationGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) WHERE groupCat = 6300 AND districtCode = @rDistrictId AND ISNULL(isDeleted, 'N') = 'N'
	--End of Paying Agent Details----------------------------------------------------------------------------------------------------------------
	
	IF EXISTS(
			SELECT 'x' FROM scMaster sm WITH(NOLOCK) 
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
				rGroup = @rLocationGroup
			)
			
			AND (tranType = @tranType OR tranType IS NULL)
			AND ISNULL(sd.isActive, 'N') = 'Y'
			AND ISNULL(sd.isDeleted, 'N') = 'N'		
			AND @transferAmount BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	
	BEGIN
		--1 Branch
		IF EXISTS(SELECT 'x' FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rGroup = @rLocationGroup) AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT DISTINCT scMasterId  FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rGroup = @rLocationGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END		
			
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT DISTINCT scMasterId FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rGroup = @rLocationGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END				
			
			INSERT INTO @list
			SELECT @masterId, @pAgentComm2, @psAgentComm2
			RETURN
		END
		
		--2 Agent		
		IF EXISTS(SELECT 'x' FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND (rGroup = @rLocationGroup) AND (tranType = @tranType OR tranType IS NULL)  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT DISTINCT scMasterId  FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rGroup = @rLocationGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END	
			
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT DISTINCT scMasterId  FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rGroup = @rLocationGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END				

			INSERT INTO @list
			SELECT @masterId, @pAgentComm2, @psAgentComm2
			RETURN
		END
		
		--3 Agent Group		
		IF EXISTS(SELECT 'x' FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sGroup = @sLocationGroup OR sGroup IS NULL) AND (rGroup = @rLocationGroup) AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT scMasterId FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rGroup = @rLocationGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END		
			
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT scMasterId FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sLocationGroup AND rGroup = @rLocationGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END					
			
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT scMasterId  FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rGroup = @rLocationGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END							
			
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT scMasterId  FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rGroup = @rLocationGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END					

			INSERT INTO @list
			SELECT @masterId, @pAgentComm2, @psAgentComm2
			RETURN			
		END
		
		--4 State		
		IF EXISTS(SELECT 'x' FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND (rGroup = @rLocationGroup) AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT DISTINCT scMasterId  FROM scMaster sm WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rGroup = @rLocationGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END	
			
			IF @found = 0
			BEGIN
				INSERT @commissionRule
				SELECT DISTINCT scMasterId  FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rGroup = @rLocationGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				WHILE EXISTS(SELECT 'X' FROM @commissionRule)
				BEGIN
					SET @found = 1
					SELECT TOP 1 @masterId = ruleId FROM @commissionRule
					SELECT @pAgentComm1 = pAgentComm, @psAgentComm1 = psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
					IF(@pAgentComm2 > @pAgentComm1)
						SET @pAgentComm2 = @pAgentComm1
					IF(@psAgentComm2 > @psAgentComm1)
						SET @psAgentComm2 = @psAgentComm1
					DELETE FROM @commissionRule WHERE ruleId = @masterId
				END
			END				
			INSERT INTO @list
			SELECT @masterId, @pAgentComm2, @psAgentComm2
			RETURN
		END
		SELECT @masterId = scMasterId FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch IS NULL AND sAgent IS NULL AND sGroup IS NULL AND sState IS NULL AND rBranch IS NULL AND rAgent IS NULL AND rGroup IS NULL AND rState IS NULL AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scMasterId FROM scMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scMasterId = cr.ruleId WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch IS NULL AND sAgent IS NULL AND sGroup IS NULL AND sState IS NULL AND rBranch IS NULL AND rAgent IS NULL AND rGroup IS NULL AND rState IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')	
		
		INSERT INTO @list
		SELECT @masterId, pAgentComm, psAgentComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
		RETURN
	END
	
	INSERT INTO @list
	SELECT NULL, NULL, NULL
	RETURN
END
GO
