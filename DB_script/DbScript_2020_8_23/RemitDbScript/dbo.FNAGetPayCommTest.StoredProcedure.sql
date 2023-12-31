USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[FNAGetPayCommTest]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[FNAGetPayCommTest](
		 @sBranch			BIGINT = 1016
		,@sCountry			INT	=	118
		,@sLocation			INT	= NULL
		,@rsAgent			BIGINT	= 1009	
		,@rCountry			BIGINT	=151
		,@rLocation			BIGINT	=NULL	
		,@rBranch			BIGINT	=1010	
		,@payoutCurr		VARCHAR(3)	=	'NPR'
		,@serviceType		INT	=	1
		,@collAmt			MONEY	=	50000.00	
		,@payAmt			MONEY	=	3740.00
		,@serviceCharge		MONEY	=	10000.00
		,@hubComm			MONEY	=	NULL
		,@sAgentComm		MONEY	=	NULL
		)
--RETURNS @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY, commissionCurrency VARCHAR(3))
AS
BEGIN
	DECLARE
		 @sAgent			INT
		,@ssAgent			INT
		,@sHub				INT	
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
		,@commGroup			INT
	
	DECLARE @commissionRule TABLE(ruleId INT)
	DECLARE @commissionPackage TABLE(packageId INT)
	
	SET @date = CONVERT(VARCHAR, GETDATE(), 101)
	
	DECLARE @agentType INT
	
	IF @sBranch IS NOT NULL
	BEGIN
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
		--SELECT @sGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = ISNULL(@sBranch, @sAgent)
		--SELECT @sCountry = countryId FROM countryMaster WITH(NOLOCK) 
		--	WHERE countryName = (SELECT agentCountry FROM agentMaster WHERE agentId = @sAgent)
		SELECT @ssAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		/*
		SELECT
			 @sState = csm.stateId
			,@sZip = agentZip
		FROM agentMaster am WITH(NOLOCK)
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE am.agentId = @sAgent
		*/
	END
	
	IF @sLocation IS NOT NULL
	BEGIN
		SELECT @sGroup = groupDetail FROM locationGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND districtCode = @sLocation
	END
	
	--2. Find Receiving Agent/Location Details-------------------------------------------------------------------------------------------		
	IF @rBranch IS NOT NULL
	BEGIN
		SELECT @agentType = agentType, @rAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rBranch
		IF @agentType = 2903
		BEGIN
			SET @rAgent = @rBranch
			SET @rBranch = NULL
		END

		--SELECT @rGroup = groupDetail FROM agentGroupMaping WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND agentId = ISNULL(@rBranch, @rAgent)
		SELECT @rsAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent
		SELECT
			 @rState = csm.stateId
			,@rZip = agentZip
		FROM agentMaster am WITH(NOLOCK) 
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON am.agentState = csm.stateName
		WHERE am.agentId = @rAgent
		
		--Paying Location Group
		--Commission Group
		SELECT @commGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE groupCat = 6600 AND agentId = @rAgent AND ISNULL(isDeleted, 'N') = 'N'
		--Commission Package
		
		INSERT @commissionPackage
		SELECT packageId FROM commissionGroup WITH(NOLOCK) WHERE groupId = @commGroup AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		--Commission Rule
		
		INSERT @commissionRule
		SELECT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId IN (SELECT packageId FROM @commissionPackage) AND ruleType = 'cp' AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'

	END
	IF @rLocation IS NOT NULL
	BEGIN
		SELECT @rGroup = groupDetail FROM locationGroupMaping WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND groupCat = 6300 AND districtCode = @rLocation				
	END
	SELECT * FROM @commissionRule
	SELECT @rBranch
	SELECT @sBranch,@sAgent, @sCountry, @ssAgent, @sState, @sGroup, @sZip, @rBranch, @rAgent, @rCountry, @rsAgent, @rState, @rGroup, 
	@rZip, @payoutCurr, @serviceType,@payAmt,@date
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
			AND baseCurrency = @payoutCurr
			AND (tranType = @serviceType OR tranType IS NULL)
			AND ISNULL(sd.isActive, 'N') = 'Y'
			AND ISNULL(sd.isDeleted, 'N') = 'N'		
			AND @payAmt BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	
	BEGIN -- Special Setting
		

		SET @masterType = 'S'
		--1 Branch
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND (rBranch = 

@rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' 
				AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rAgent = @rAgent AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rAgent = @rAgent AND rAgentGroup IS NULL AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rAgent = @rAgent AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rAgent = @rAgent AND rAgentGroup IS NULL AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent						
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
					
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rState = @rState AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rState = @rState AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
							
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sBranch = @sBranch 

AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
		
		--2 Agent and Agent Group		
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sAgent = @sAgent 
		AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) 
		AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL)  
		AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			--1. Receiving Branch				
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @payoutCurr 
			AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rBranch = @rBranch AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent or Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND agentGroup = @rGroup) 
				AND baseCurrency = @payoutCurr AND tranType = @serviceType  
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND agentGroup IS NULL) 
				AND baseCurrency = @payoutCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND agentGroup = @rGroup) 
				AND baseCurrency = @payoutCurr AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND agentGroup IS NULL) AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND agentGroup = @rGroup) AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND (rAgent = @rAgent AND agentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND agentGroup = @rGroup) AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND (rAgent = @rAgent AND agentGroup IS NULL) AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rZip = @rZip AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rState = @rState AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rState = @rState AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup = @sGroup) AND rCountry = @rCountry AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (sAgent = @sAgent AND agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			--INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
		
		--3 Super Agent
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 
		AND sAgent = @sAgent AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) 
		AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) 
		AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo,'2100-12-31'))
		BEGIN	
			--1. Receiving Branch		
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND ssAgent = @ssAgent AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType = @serviceType 
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent
 
AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rAgent = @rAgent AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rAgent = @rAgent AND rAgentGroup IS NULL AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rAgent = @rAgent AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rAgent = @rAgent AND rAgentGroup IS NULL AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent						
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
					
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rState = @rState AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rState = @rState AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
							
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND ssAgent = @ssAgent 

AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				
			--INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
		
		--3 Agent Group		
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (agentGroup = @sGroup) 
		AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND baseCurrency = @payoutCurr 
		AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId
			 WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			 AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @payoutCurr 
			 AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rBranch = @rBranch AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) 
				AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) 
				AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) 
				AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND (rAgent = @rAgent AND rAgentGroup IS NULL) 
				AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rZip = @rZip AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rState = @rState AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rState = @rState AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @payoutCurr 
				AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
				AND (agentGroup = @sGroup OR agentGroup IS NULL) AND rCountry = @rCountry AND baseCurrency = @payoutCurr 
				AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			--INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN			
		END
		
		--4 Zip		
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
		AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND baseCurrency = @payoutCurr 
		AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = scPayMasterId FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
			AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group			
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND tranType = @serviceType 
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType = @serviceType 
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND tranType IS NULL 
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent			
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rState = @rState AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rState = @rState AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--7. Receiving Country
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND zip = @sZip 
				AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

			--INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
		
		--5 State
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
		AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2
100-12-31'))
		BEGIN
			SET @found = 1
			--1. Receiving Branch
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
			AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--2. Receiving Agent and Agent Group			
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--3. Receiving Super Agent
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--4. Receiving Agent Group
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--5. Receiving Zip
			IF @masterId IS NULL		
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			IF @masterId IS NULL			
				SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
				INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
				WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
				AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
			--6. Receiving State		
	IF @masterId IS NULL			
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
		AND rState = @rState AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	IF @masterId IS NULL			
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
		AND rState = @rState AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			
	--7. Receiving Country			
	IF @masterId IS NULL
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
		AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')	
	IF @masterId IS NULL
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND [state] = @sState 
		AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')

	--INSERT INTO @list
	SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
	RETURN
END
		
--6 Country
IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) 
INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCountry = @sCountry OR sCountry IS NULL) 
AND (rBranch = @rBranch OR rAgent = @rAgent OR rCountry = @rCountry OR rsAgent = @rsAgent) AND baseCurrency = @payoutCurr 
AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
BEGIN
	--1. Receiving Branch		
	IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCountry = @sCountry OR sCountry
IS NULL) AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
	BEGIN 
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
		AND sCountry = @sCountry AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rBranch = @rBranch 
			AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rBranch = @rBranch AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	END
	--2. Receiving Agent and Agent Group
	IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCountry = @sCountry OR sCountry
IS NULL) AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')) 
	BEGIN
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry 
			AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry 
			AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND (rAgent = @rAgent AND rAgentGroup = @rGroup) 
			AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND (rAgent = @rAgent AND rAgentGroup = @rGroup) AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry 
			AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND (rAgent = @rAgent AND rAgentGroup IS NULL) AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	END
	--3. Receiving Super Agent
	IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) 
	INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
	WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCountry = @sCountry OR sCountry IS NULL) 
	AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
	BEGIN
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry 
			AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry 
			AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rsAgent = @rsAgent AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	END
	--4. Receiving Agent Group
	IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCountry = @sCountry OR sCountry
IS NULL) AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
	BEGIN
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgentGroup = @rGroup 
			AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rAgentGroup = @rGroup 
			AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rAgentGroup = @rGroup AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	END
	--5. Receiving Zip
	IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) 
	INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
	WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCountry = @sCountry OR sCountry IS NULL) 
	AND rZip = @rZip AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')) 
	BEGIN
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rZip = @rZip 
			AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rZip = @rZip 
			AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rZip = @rZip AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	END
	--6. Receiving State
	IF EXISTS(SELECT 'X' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND (sCountry = @sCountry OR sCountry
IS NULL) AND rState = @rState AND baseCurrency = @payoutCurr AND (tranType = @serviceType OR tranType IS NULL) AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31'))
	BEGIN
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rState = @rState AND baseCurrency = @payoutCurr 
			AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rState = @rState AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rState = @rState 
			AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		IF @masterId IS NULL			
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
			AND rState = @rState AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	END
	--7. Receiving Country
	IF @masterId IS NULL
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND sAgent IS NULL 
		AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	IF @masterId IS NULL
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND sAgent IS NULL AND rCountry = @rCountry 
		AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	IF @masterId IS NULL
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
		AND sAgent IS NULL AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType = @serviceType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	IF @masterId IS NULL
		SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
		INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
		WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry IS NULL 
		AND sAgent IS NULL AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	
			--INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
	END
	/*	
	ELSE 
	BEGIN
		IF EXISTS(
			SELECT 'x' FROM dcPayMaster dm WITH(NOLOCK)
			INNER JOIN dcPayDetail dd WITH(NOLOCK) ON dm.dcPayMasterId = dd.dcPayMasterId
			WHERE ISNULL(dm.isActive, 'N') = 'Y'
			AND ISNULL(dm.isEnable, 'N') = 'Y' 
			AND ISNULL(dm.isDeleted, 'N') = 'N' 
			AND sCountry = @sCountry 
			AND rCountry = @rCountry 
			AND baseCurrency = @payoutCurr
			AND (tranType = @serviceType OR tranType IS NULL)
			AND ISNULL(dd.isActive, 'N') = 'Y'
			AND ISNULL(dd.isDeleted, 'N') = 'N'		
			AND @payAmt BETWEEN fromAmt and toAmt
		)
		BEGIN
			SELECT @masterType = 'D', @found = 1
			SELECT @masterId = dcPayMasterId FROM dcPayMaster WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tranT

ype = @serviceType
			IF @masterId IS NULL
				SELECT @masterId = dcPayMasterId FROM dcPayMaster WITH(NOLOCK) WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND sCountry = @sCountry AND rCountry = @rCountry AND baseCurrency = @payoutCurr AND tran

Type IS NULL
				
			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM dcPayMaster WHERE dcPayMasterId = @masterId
			RETURN
		END
	END
	*/
	--INSERT INTO @list
	SELECT NULL, NULL, NULL, NULL
	RETURN
END



GO
