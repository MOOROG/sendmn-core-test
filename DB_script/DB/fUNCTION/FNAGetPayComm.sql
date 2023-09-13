
ALTER FUNCTION [dbo].[FNAGetPayComm](
		 @sBranch			BIGINT
		,@sCountry			INT
		,@sLocation			INT
		,@rsAgent			BIGINT
		,@rCountry			BIGINT
		,@rLocation			BIGINT
		,@rBranch			BIGINT
		,@payoutCurr		VARCHAR(3)
		,@serviceType		INT
		,@collAmt			MONEY
		,@payAmt			MONEY
		,@serviceCharge		MONEY
		,@hubComm			MONEY
		,@sAgentComm		MONEY
)
returns @list TABLE (masterId BIGINT, masterType CHAR(1), amount MONEY, commissionCurrency VARCHAR(3))
as
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
		SELECT @ssAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
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
				 AND (ssAgent = @ssAgent OR ssAgent IS NULL)
				 OR agentGroup = @sGroup
			)
			AND
			(
				(rBranch = @rBranch OR rBranch IS NULL)
				AND (rAgent = @rAgent OR rAgent IS NULL)
				AND (rsAgent = @rsAgent OR rsAgent IS NULL)
				OR rAgentGroup = @rGroup
			)
			AND commissionCurrency = @payoutCurr
			AND (tranType = @serviceType OR tranType IS NULL)
			AND ISNULL(sd.isActive, 'N') = 'Y'
			AND ISNULL(sd.isDeleted, 'N') = 'N'		
			AND CASE commissionBase 
					WHEN 4200 THEN @collAmt  
					WHEN 4201 THEN @payAmt
					WHEN 4202 THEN @serviceCharge
					ELSE @payAmt END BETWEEN fromAmt and toAmt
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			and sCountry = @sCountry and rCountry = @rCountry
	)
	
	BEGIN -- Special Setting
		SET @masterType = 'S'
		
		--1 ALL POSIBLE PARAMETERS	
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND SsAgent = @SsAgent AND rsAgent = @rsAgent
			AND commissionCurrency = @payoutCurr AND tranType = @serviceType
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			and sCountry = @sCountry and rCountry = @rCountry )
		BEGIN
						
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND SsAgent = @SsAgent AND rsAgent = @rsAgent
			AND commissionCurrency = @payoutCurr AND tranType = @serviceType
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			and sCountry = @sCountry and rCountry = @rCountry		

			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END

		--2 service type optional 
		IF EXISTS(SELECT 'x' FROM scPayMaster sm WITH(NOLOCK) INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND SsAgent = @SsAgent AND rsAgent = @rsAgent
			AND commissionCurrency = @payoutCurr AND tranType is null
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			and sCountry = @sCountry and rCountry = @rCountry )
		BEGIN
						
			SELECT @masterId = scPayMasterId  FROM scPayMaster sm WITH(NOLOCK) 
			INNER JOIN @commissionRule cr ON sm.scPayMasterId = cr.ruleId 
			WHERE ISNULL(isEnable, 'N') = 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' 
			AND SsAgent = @SsAgent AND rsAgent = @rsAgent
			AND commissionCurrency = @payoutCurr AND tranType is null
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			and sCountry = @sCountry and rCountry = @rCountry		

			INSERT INTO @list
			SELECT @masterId, @masterType, [dbo].FNAGetCommission(@masterId, @masterType, @collAmt, @payAmt, @serviceCharge, @hubComm, @sAgentComm, 'p', NULL, NULL, NULL, NULL), commissionCurrency FROM scPayMaster WHERE scPayMasterId = @masterId
			RETURN
		END
	END
	INSERT INTO @list
	SELECT NULL, NULL, NULL, NULL
	RETURN
END


