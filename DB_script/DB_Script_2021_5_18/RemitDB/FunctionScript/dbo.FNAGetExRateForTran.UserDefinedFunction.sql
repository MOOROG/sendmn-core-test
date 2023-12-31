USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetExRateForTran]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetExRateForTran](@cBranch INT, @pBranch INT, @pCountry INT, @collCurr VARCHAR(3), @payCurr VARCHAR(3), @tranType INT, @user VARCHAR(30))
RETURNS @list TABLE (id BIGINT, agentCrossRate FLOAT, customerCrossRate FLOAT)
AS
BEGIN
	DECLARE
		 @cCountry		INT
		,@cAgent		INT
		,@cAgentGroup	INT
		,@cBranchGroup	INT	
		,@sState		INT
		,@sZip			VARCHAR(10)
		,@sGroup		INT
		,@pAgent		INT	
		,@pAgentGroup	INT
		,@pBranchGroup	INT
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
	
	SELECT @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch
	IF(@agentType = 2903)
	BEGIN
		SELECT @cAgent = @cBranch
		SELECT @cBranch = NULL
	END
	ELSE
		SELECT @cAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch
		
	SELECT @cCountry = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @cAgent
	
	SELECT @cBranchGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE agentId = @cBranch AND groupCat = 6700
	
	IF @pBranch IS NOT NULL
	BEGIN
		IF @pBranch = 2903
		BEGIN
			SELECT @pAgent = @pBranch
			SELECT @pBranch = NULL
		END
		ELSE
			SELECT @pAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
			
		SELECT @pBranchGroup = groupDetail FROM agentGroupMaping WITH(NOLOCK) WHERE agentId = @pBranch AND groupCat = 6800
	END
	
	--1. Search by Sending Branch
	IF EXISTS(SELECT 'X' FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND (pBranch = @pBranch OR pBranchGroup = @pBranchGroup OR pAgent = @pAgent OR pAgentGroup = @pAgentGroup OR pCountry = @pCountry OR (tranType = @tranType OR tranType IS NULL)))
	BEGIN
		SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pBranch = @pBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pBranch = @pBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pBranchGroup = @pBranchGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pBranchGroup = @pBranchGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pAgent = @pAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pAgent = @pAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pAgentGroup = @pAgentGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pAgentGroup = @pAgentGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pCountry = @pCountry AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranch = @cBranch AND pCountry = @pCountry AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		
		INSERT @list
		SELECT @masterId, agentCrossRate, customerCrossRate FROM dbo.FNAGetCrossRate(@masterId)
		RETURN
	END
	
	--2. Search by Sending Branch Group
	IF EXISTS(SELECT 'X' FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND (pBranch = @pBranch OR pBranchGroup = @pBranchGroup OR pAgent = @pAgent OR pAgentGroup = @pAgentGroup OR pCountry = @pCountry OR (tranType = @tranType OR tranType IS NULL)))
	BEGIN
		SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pBranch = @pBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pBranch = @pBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pBranchGroup = @pBranchGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pBranchGroup = @pBranchGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pAgent = @pAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pAgent = @pAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pAgentGroup = @pAgentGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pAgentGroup = @pAgentGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pCountry = @pCountry AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cBranchGroup = @cBranchGroup AND pCountry = @pCountry AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
	
		INSERT @list
		SELECT @masterId, agentCrossRate, customerCrossRate FROM dbo.FNAGetCrossRate(@masterId)
		RETURN
	END
	
	--3. Search by Sending Agent
	IF EXISTS(SELECT 'X' FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND (pBranch = @pBranch OR pBranchGroup = @pBranchGroup OR pAgent = @pAgent OR pAgentGroup = @pAgentGroup OR pCountry = @pCountry OR (tranType = @tranType OR tranType IS NULL)))
	BEGIN
		SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pBranch = @pBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pBranch = @pBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pBranchGroup = @pBranchGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pBranchGroup = @pBranchGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pAgent = @pAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pAgent = @pAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pAgentGroup = @pAgentGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pAgentGroup = @pAgentGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pCountry = @pCountry AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgent = @cAgent AND pCountry = @pCountry AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		
		INSERT @list
		SELECT @masterId, agentCrossRate, customerCrossRate FROM dbo.FNAGetCrossRate(@masterId)
		RETURN
	END
	
	--4. Search by Sending Agent Group
	IF EXISTS(SELECT 'X' FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND (pBranch = @pBranch OR pBranchGroup = @pBranchGroup OR pAgent = @pAgent OR pAgentGroup = @pAgentGroup OR pCountry = @pCountry OR (tranType = @tranType OR tranType IS NULL)))
	BEGIN
		SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pBranch = @pBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pBranch = @pBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pBranchGroup = @pBranchGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pBranchGroup = @pBranchGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pAgent = @pAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pAgent = @pAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pAgentGroup = @pAgentGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pAgentGroup = @pAgentGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pCountry = @pCountry AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cAgentGroup = @cAgentGroup AND pCountry = @pCountry AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
	
		INSERT @list
		SELECT @masterId, agentCrossRate, customerCrossRate FROM dbo.FNAGetCrossRate(@masterId)
		RETURN
	END
	
	--5. Search by Sending Country
	IF EXISTS(SELECT 'X' FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND (pBranch = @pBranch OR pBranchGroup = @pBranchGroup OR pAgent = @pAgent OR pAgentGroup = @pAgentGroup OR pCountry = @pCountry OR (tranType = @tranType OR tranType IS NULL)))
	BEGIN
		SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pBranch = @pBranch AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pBranch = @pBranch AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pBranchGroup = @pBranchGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pBranchGroup = @pBranchGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pAgent = @pAgent AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pAgent = @pAgent AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pAgentGroup = @pAgentGroup AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pAgentGroup = @pAgentGroup AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pCountry = @pCountry AND tranType = @tranType AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
		IF @masterId IS NULL
			SELECT @masterId = spExRateId FROM spExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND cCurrency = @collCurr AND pCurrency = @payCurr AND cCountry = @cCountry AND pCountry = @pCountry AND tranType IS NULL AND @date BETWEEN ISNULL(effectiveFrom, '1900-01-01') AND ISNULL(effectiveTo, '2100-01-01')
	
		INSERT @list
		SELECT @masterId, agentCrossRate, customerCrossRate FROM dbo.FNAGetCrossRate(@masterId)
		RETURN
	END

	INSERT INTO @list
	SELECT NULL, NULL, NULL
	RETURN
END
GO
