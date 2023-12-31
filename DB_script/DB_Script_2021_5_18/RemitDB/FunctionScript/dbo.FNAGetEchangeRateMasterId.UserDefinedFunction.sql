USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetEchangeRateMasterId]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetEchangeRateMasterId](@ssAgent BIGINT, @sending BIGINT, @rsAgent BIGINT, @receiving BIGINT, @localCurrency INT, @sType CHAR(1), @rType CHAR(1), @spFlag CHAR(1), @isTranMode CHAR(1) = 'N', @user VARCHAR(30))
RETURNS @list TABLE (id BIGINT, masterType CHAR(1), lookInTable VARCHAR(4))
AS
BEGIN
	DECLARE
		 @sBranch		INT
		,@sAgent		INT
		,@sCountry		INT		
		,@sState		INT
		,@sZip			VARCHAR(10)
		,@sGroup		INT
		,@rBranch		INT
		,@rAgent		INT
		,@rCountry		INT		
		,@masterId		BIGINT
		,@found			BIT = 0
		,@masterType	CHAR(1)	= NULL
		,@date			DATETIME
		,@agentType		INT
		
	SET @date = CONVERT(VARCHAR,GETDATE(), 101)	
		
	/*
		2901	2900	Country Hub
		2902	2900	Super Agent
		2903	2900	Agent
		2904	2900	Branch	
	*/
		
	DECLARE	
		@lookInTable VARCHAR(4)
	
	IF @sType = 'C' --Country
	BEGIN
		SELECT @sCountry = @sending
	END
	
	ELSE IF @sType = 'A'
	BEGIN
		SET @sAgent = @sending
		SELECT @sCountry = agentCountryId FROM agentMaster WHERE agentId = @sAgent
		SELECT
			 @sState = csm.stateId
			,@sZip = am.agentZip
			,@sGroup = am.agentGrp
		FROM agentMaster am WITH(NOLOCK)
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON csm.stateName = am.agentState
		WHERE am.agentId = @sAgent
	END
	
	ELSE IF @sType = 'B'
	BEGIN
		SET @sBranch = @sending
		SELECT @sAgent = parentId FROM agentMaster WHERE agentId = @sBranch
		SELECT @sCountry = agentCountryId FROM agentMaster WHERE agentId = @sBranch
		SELECT
			 @sState = csm.stateId
			,@sZip = am.agentZip
			,@sGroup = am.agentGrp
		FROM agentMaster am WITH(NOLOCK)
		LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON csm.stateName = am.agentState
		WHERE am.agentId = @sAgent
	END	
	
	IF @rType = 'C' --Country
	BEGIN
		SELECT @rCountry = @receiving
	END
	ELSE IF @rType = 'A'
	BEGIN
		SET @rAgent = @receiving
		SELECT @rCountry = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent	
	END
	
	ELSE IF @rType = 'B'
	BEGIN
		SET @rBranch = @receiving
		SELECT @rAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rBranch
		SELECT @rCountry = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @rBranch	
	END
	
	IF EXISTS(
		SELECT 
			'x'
		FROM seRate sr WITH(NOLOCK)
		WHERE
			ISNULL(sr.isActive, 'N') = 'Y'
		AND ISNULL(sr.isDeleted, 'N') = 'N'
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
		)
		AND spFlag = @spFlag
		AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
	)
	BEGIN -- Special Setting
		SET @masterType = 'S'
		--1 Branch
		IF EXISTS(SELECT 'x' FROM seRate WITH(NOLOCK)
			WHERE ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') = 'N'		
			AND localcurrency = @localCurrency
			AND sBranch = @sBranch
			AND spFlag = @spFlag
			AND (rBranch = @rBranch OR (rBranch IS NULL AND rAgent = @rAgent) OR (rBranch IS NULL AND rAgent IS NULL AND rCountry = @rCountry))
			AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		)
		BEGIN
			--Branch
			IF @isTranMode = 'N'
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND sBranch = @sBranch AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND sBranch = @sBranch AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND sBranch = @sBranch AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND sBranch = @sBranch AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND sBranch = @sBranch AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND sBranch = @sBranch AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
		END

		--2 Agent
		ELSE IF EXISTS(SELECT 'x' FROM seRate WITH(NOLOCK)
			WHERE ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND localcurrency = @localCurrency
				AND (sAgent = @sAgent AND sBranch IS NULL)
				AND spFlag = @spFlag
				AND (rBranch = @rBranch OR (rBranch IS NULL AND rAgent = @rAgent) OR (rBranch IS NULL AND rAgent IS NULL AND rCountry = @rCountry))
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		)
		BEGIN
			--Agent
			IF @isTranMode = 'N'
			BEGIN
				SELECT @masterId = seRateId FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND sAgent = @sAgent AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND sAgent = @sAgent AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')				
				SET @lookInTable = 'MAIN'
			END
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND sAgent = @sAgent AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END						
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND sAgent = @sAgent AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND sAgent = @sAgent AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
		
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND sAgent = @sAgent AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
		END
		--3 Agent Group
		ELSE IF EXISTS(SELECT 'x' FROM seRate WITH(NOLOCK)
			WHERE ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'
				AND localcurrency = @localCurrency
				AND agentGroup = @sGroup
				AND spFlag = @spFlag
				AND (rBranch = @rBranch OR (rBranch IS NULL AND rAgent = @rAgent) OR (rBranch IS NULL AND rAgent IS NULL AND rCountry = @rCountry))
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		)
		BEGIN
			IF @isTranMode = 'N'
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND agentGroup = @sGroup AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND agentGroup = @sGroup AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')				
				SET @lookInTable = 'MAIN'
			END
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND agentGroup = @sGroup AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND agentGroup = @sGroup AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND agentGroup = @sGroup AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
		
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND agentGroup = @sGroup AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
				SET @lookInTable = 'MAIN'
			END
		END	
		
		--4 Zip
		ELSE IF EXISTS(SELECT 'x' FROM seRate WITH(NOLOCK)
				WHERE ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'				
				AND localcurrency = @localCurrency
				AND zip = @sZip
				AND spFlag = @spFlag
				AND (rBranch = @rBranch OR (rBranch IS NULL AND rAgent = @rAgent) OR (rBranch IS NULL AND rAgent IS NULL AND rCountry = @rCountry))
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		)
		BEGIN	
			IF @isTranMode = 'N'
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND zip = @sZip AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND zip = @sZip AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND zip = @sZip AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND zip = @sZip AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND zip = @sZip AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
				SET @lookInTable = 'MOD'
			END
		
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND zip = @sZip AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
				SET @lookInTable = 'MAIN'
			END
		END	
		
		--5 State
		ELSE IF EXISTS(SELECT 'x' FROM seRate WITH(NOLOCK)
				WHERE ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'				
				AND localcurrency = @localCurrency
				AND [state] = @sState
				AND spFlag = @spFlag
				AND (rBranch = @rBranch OR (rBranch IS NULL AND rAgent = @rAgent) OR (rBranch IS NULL AND rAgent IS NULL AND rCountry = @rCountry))
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
		)
		BEGIN	
			IF @isTranMode = 'N'
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND [state] = @sState AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND [state] = @sState AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')				
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND [state] = @sState AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
				SET @lookInTable = 'MOD'
			END			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND [state] = @sState AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND [state] = @sState AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND [state] = @sState AND sAgent IS NULL AND sBranch IS NULL AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
		END
		
		--6 Country
		ELSE IF EXISTS(SELECT 'x' FROM seRate WITH(NOLOCK)
				WHERE ISNULL(isActive, 'N') = 'Y'
				AND ISNULL(isDeleted, 'N') = 'N'				
				AND localcurrency = @localCurrency
				AND ssAgent = @ssAgent
				AND (sCountry = @sCountry AND sAgent IS NULL AND sBranch IS NULL)
				AND spFlag = @spFlag
				AND (rBranch = @rBranch OR (rBranch IS NULL AND rAgent = @rAgent) OR (rBranch IS NULL AND rAgent IS NULL AND rCountry = @rCountry))
				AND rsAgent = @rsAgent
				AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
			)
		BEGIN
			--Country
			IF @isTranMode = 'N'
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND ssAgent = @ssAgent AND sCountry = @sCountry AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')			
				SET @lookInTable = 'MOD'
			END			
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND ssAgent = @ssAgent AND sCountry = @sCountry AND sAgent IS NULL AND sBranch IS NULL AND rBranch = @rBranch AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')				
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND ssAgent = @ssAgent AND sCountry = @sCountry AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND ssAgent = @ssAgent AND sCountry = @sCountry AND sAgent IS NULL AND sBranch IS NULL AND rAgent = @rAgent AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND ssAgent = @ssAgent AND sCountry = @sCountry AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MOD'
			END			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = seRateId  FROM seRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND ssAgent = @ssAgent AND sCountry = @sCountry AND sAgent IS NULL AND sBranch IS NULL AND rsAgent = @rsAgent AND rCountry = @rCountry AND rAgent IS NULL  AND rBranch IS NULL AND spFlag = @spFlag  AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-12-31')
				SET @lookInTable = 'MAIN'
			END
		END
			
		INSERT INTO @list
		SELECT @masterId, @masterType, @lookInTable
		RETURN	
	END	
	ELSE 
	BEGIN
		IF EXISTS(
			SELECT 'x' FROM deRate dr WITH(NOLOCK)		
			WHERE ISNULL(dr.isActive, 'N') = 'Y' 
			AND ISNULL(dr.isDeleted, 'N') = 'N' 
			AND dr.country = @sCountry		
			AND spFlag = @spFlag 	
		)
		BEGIN
			SELECT @masterType = 'D', @found = 1
			
			IF @isTranMode = 'N'
			BEGIN
				SELECT @masterId = deRateId FROM deRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND spFlag = @spFlag AND country = CASE WHEN @spFlag = 'S' THEN @sCountry ELSE @rCountry END 			
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL 
			BEGIN
				SELECT @masterId = deRateId FROM deRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND spFlag = @spFlag AND country = CASE WHEN @spFlag = 'S' THEN @sCountry ELSE @rCountry END 
				SET @lookInTable = 'MAIN'
			END
			
			IF @isTranMode = 'N' AND @masterId IS NULL
			BEGIN
				SELECT @masterId = deRateId FROM deRateHistory WITH(NOLOCK) WHERE approvedBy IS NULL AND createdBy = @user AND localcurrency = @localCurrency AND country = @sCountry			
				SET @lookInTable = 'MOD'
			END
			
			IF @masterId IS NULL
			BEGIN
				SELECT @masterId = deRateId FROM deRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N' AND localcurrency = @localCurrency AND country = @sCountry 
				SET @lookInTable = 'MAIN'
			END
			INSERT INTO @list
			SELECT @masterId, @masterType, @lookInTable
			RETURN
		END
		ELSE
		BEGIN
			INSERT INTO @list
			SELECT NULL, NULL, NULL
			RETURN
		END
	END

	INSERT INTO @list
	SELECT NULL, NULL, NULL
	RETURN
END
GO
