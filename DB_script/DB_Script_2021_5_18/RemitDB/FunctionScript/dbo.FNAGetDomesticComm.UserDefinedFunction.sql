USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDomesticComm]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	SELECT * FROM [dbo].FNAGetDomesticComm(9, NULL, 137, 1, 10000)
*/
CREATE FUNCTION [dbo].[FNAGetDomesticComm](@sBranch INT, @rBranch INT, @pLocation INT, @tranType INT, @transferAmount MONEY)
RETURNS @list TABLE (masterId BIGINT, serviceCharge MONEY, sAgentComm MONEY, ssAgentComm MONEY, pAgentComm MONEY, psAgentComm MONEY, bankComm MONEY)
AS
BEGIN
	DECLARE
		 @sAgent			INT
		,@sState			INT
		,@sGroup			INT
		,@masterId			BIGINT	
		,@found				BIT = 0
		,@rAgent			INT
		,@rState			INT
		,@rGroup			INT
		,@date				DATETIME
		
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	
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
	
	--Sending Group
	SELECT @sGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE groupCat = 6500 AND agentId = ISNULL(@sBranch, @sAgent)
	
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

		SELECT @rState = csm.stateId FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE agentId = @rAgent
	END
	IF @pLocation IS NOT NULL
	BEGIN
		--Receiving Group
		SELECT @rGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6600 AND districtCode = @pLocation	
	END

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
				 OR sGroup = @sGroup
			)
			
			AND
			
			(
				(rBranch = @rBranch OR rBranch IS NULL)
				AND (rAgent = @rAgent OR rAgent IS NULL)
				OR [rState] = @rState
				OR rGroup = @rGroup
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
		--SELECT @sGroup, @rGroup, 1,1,1,1,1
		--RETURN
		IF EXISTS(SELECT 'x' FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rGroup) AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN			
			SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgent = @rAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rGroup = @rGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, serviceCharge, sAgentComm, ssAgentComm, pAgentComm, psAgentComm, bankComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN
		END
		
		--2 Agent		
		IF EXISTS(SELECT 'x' FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rGroup) AND (tranType = @tranType OR tranType IS NULL)  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN				
			SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rBranch = @rBranch AND tranType = @tranType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rAgent = @rAgent AND tranType = @tranType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rAgent = @rAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rGroup = @rGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rState = @rState AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			INSERT INTO @list
			SELECT @masterId, serviceCharge, sAgentComm, ssAgentComm, pAgentComm, psAgentComm, bankComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN
		END
		
		--3 Agent Group		
		IF EXISTS(SELECT 'x' FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sGroup = @sGroup OR sGroup IS NULL) AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rGroup) AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rBranch = @rBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rAgent = @rAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rAgent = @rAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rGroup = @rGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rState = @rState AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup = @sGroup AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rBranch = @rBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rAgent = @rAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rAgent = @rAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rGroup = @rGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rState = @rState AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sGroup IS NULL AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			INSERT INTO @list
			SELECT @masterId, serviceCharge, sAgentComm, ssAgentComm, pAgentComm, psAgentComm, bankComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN			
		END
		
		--4 State		
		IF EXISTS(SELECT 'x' FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND (rBranch = @rBranch OR rAgent = @rAgent OR rState = @rState OR rGroup = @rGroup) AND (tranType = @tranType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			
			SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rBranch = @rBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rBranch = @rBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rAgent = @rAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rAgent = @rAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rGroup = @rGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rGroup = @rGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rState = @rState AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scMasterId  FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [sState] = @sState AND rState = @rState AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			INSERT INTO @list
			SELECT @masterId, serviceCharge, sAgentComm, ssAgentComm, pAgentComm, psAgentComm, bankComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
			RETURN
		END
		SELECT @masterId = scMasterId FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch IS NULL AND sAgent IS NULL AND sGroup IS NULL AND sState IS NULL AND rBranch IS NULL AND rAgent IS NULL AND rGroup IS NULL AND rState IS NULL AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scMasterId FROM scMaster WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch IS NULL AND sAgent IS NULL AND sGroup IS NULL AND sState IS NULL AND rBranch IS NULL AND rAgent IS NULL AND rGroup IS NULL AND rState IS NULL AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')	
		
		INSERT INTO @list
		SELECT @masterId, serviceCharge, sAgentComm, ssAgentComm, pAgentComm, psAgentComm, bankComm FROM [dbo].FNAGetDomesticCommDetail(@masterId, @transferAmount)
		RETURN
	END
	
	INSERT INTO @list
	SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL
	RETURN
END
GO
