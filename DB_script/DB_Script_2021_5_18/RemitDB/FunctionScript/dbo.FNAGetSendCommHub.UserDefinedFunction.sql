USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetSendCommHub]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetSendCommHub](
		 @sBranch BIGINT
		,@rsAgent BIGINT
		,@rCountry BIGINT
		,@district BIGINT
		,@rBranch BIGINT
		,@collCurr VARCHAR(3)
		,@serviceType INT
		,@collAmt MONEY
		,@payAmt MONEY
		,@serviceCharge MONEY
		,@hubComm MONEY
		,@sAgentComm MONEY
		)
RETURNS @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY, commissionCurrency VARCHAR(3))
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
		,@rHub				INT
		,@masterId			BIGINT	
		,@found				BIT = 0
		,@masterType		CHAR(1)
		,@rState			INT
		,@rGroup			INT
		,@rZip				INT
		,@date				DATETIME		
		,@commissionBase	INT
		,@amt				MONEY
		
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	
	--1. Find Sending Agent Details-------------------------------------------------------------------------------------------------------
	SELECT @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	SELECT @sGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = @sBranch
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
		SET @sBranch = NULL
	END	
	ELSE
	BEGIN
		SELECT @sAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	END
	IF @sGroup IS NULL 
		SELECT @sGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = @sAgent		
	SELECT @sCountry = countryId FROM countryMaster WITH(NOLOCK) 
		WHERE countryName = (SELECT agentCountry FROM agentMaster WHERE agentId = @sAgent)
	SELECT @ssAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
	
	SELECT
		 @sState = csm.stateId
		,@sZip = agentZip
	FROM agentMaster am WITH(NOLOCK)
	LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
	WHERE am.agentId = @sAgent
	
	--2. Find Receiving Agent and Location Details	
	IF @rBranch IS NOT NULL
	BEGIN
		SELECT @rGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6400 AND agentId = @rBranch
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
		IF @rGroup IS NULL
			SELECT @rGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6400 AND agentId = @rAgent
		SELECT @rsAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent
		SELECT
			 @rState = csm.stateId
			,@rZip = agentZip
		FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE agentId = @rAgent
	END
	IF @district IS NOT NULL
	BEGIN
		SELECT @rGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6400 AND districtCode = @district		
	END
	
	IF EXISTS(
			SELECT 'x' FROM scSendMasterHub sm WITH(NOLOCK) 
			INNER JOIN scSendDetailHub sd WITH(NOLOCK) ON sm.scSendMasterHubId = sd.scSendMasterHubId
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
			AND @collAmt BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	
	BEGIN -- Special Setting
		SET @masterType = 'S'
		--1 Branch
		IF EXISTS(SELECT 'x' FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch			
			SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group	
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')


			SELECT @commissionBase = commissionBase FROM scSendMasterHub WHERE scSendMasterHubId = @masterId
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommissionHub(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 's'), baseCurrency FROM scSendMasterHub WITH(NOLOCK) WHERE scSendMasterHubId = @masterId
			RETURN
		END

		--2 Agent and Agent Group	
		IF EXISTS(SELECT 'x' FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL)  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch						
			SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State	
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommissionHub(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 's'), baseCurrency FROM scSendMasterHub WITH(NOLOCK) WHERE scSendMasterHubId = @masterId
			RETURN
		END
		
		--3 Agent Group		
		IF EXISTS(SELECT 'x' FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch
			SET @found = 1
			SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group			
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommissionHub(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 's'), baseCurrency FROM scSendMasterHub WITH(NOLOCK) WHERE scSendMasterHubId = @masterId
			RETURN			
		END
		
		--4 Zip		
		IF EXISTS(SELECT 'x' FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group			
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receiving Agent Group				
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommissionHub(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 's'), baseCurrency FROM scSendMasterHub WITH(NOLOCK) WHERE scSendMasterHubId = @masterId
			RETURN
		END
		
		--5 State
		IF EXISTS(SELECT 'x' FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and AGent Group		
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent	
			IF @masterId IS NULL		
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--4. Receving Agent Group		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL		
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
						
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommissionHub(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 's'), baseCurrency FROM scSendMasterHub WITH(NOLOCK) WHERE scSendMasterHubId = @masterId
			RETURN
		END
		
		--6 Country
		IF EXISTS(SELECT 'x' FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry) AND baseCurrency = @collCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1	
			--1. Receiving Branch		
			SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rBranch = @rBranch AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgent = @rAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgent = @rAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rsAgent = @rsAgent AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgentGroup = @rGroup AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rZip = @rZip AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rZip = @rZip AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rState = @rState AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rState = @rState AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scSendMasterHubId  FROM scSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommissionHub(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 's'), baseCurrency FROM scSendMasterHub WITH(NOLOCK) WHERE scSendMasterHubId = @masterId
			RETURN
		END
	END	
	ELSE 
	BEGIN
		IF EXISTS(
			SELECT 'x' FROM dcSendMasterHub dm WITH(NOLOCK)
			INNER JOIN dcSendDetailHub dd WITH(NOLOCK) ON dm.dcSendMasterHubId = dd.dcSendMasterHubId
			WHERE ISNULL(dm.isActive, 'N') = 'Y' 
			AND ISNULL(dm.isEnable, 'N') = 'Y'
			AND ISNULL(dm.isDeleted, 'N') = 'N' 
			AND sCountry = @sCountry 
			AND rCountry = @rCountry
			AND baseCurrency = @collCurr 
			AND (tranType = @serviceType OR tranType IS NULL)
			AND ISNULL(dd.isActive, 'N') = 'Y'
			AND ISNULL(dd.isDeleted, 'N') = 'N'		
			AND @collAmt BETWEEN fromAmt and toAmt
		)
		BEGIN
			SELECT @masterType = 'D', @found = 1
			SELECT @masterId = dcSendMasterHubId FROM dcSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType = @serviceType
			IF @masterId IS NULL
				SELECT @masterId = dcSendMasterHubId FROM dcSendMasterHub WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @collCurr AND tranType IS NULL
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommissionHub(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 's'), baseCurrency FROM dcSendMasterHub WITH(NOLOCK) WHERE dcSendMasterHubId = @masterId
			RETURN
		END
	END
	
	INSERT INTO @list
	SELECT NULL, NULL, NULL, NULL
	RETURN
END
GO
