USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCrossRate]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetCrossRate](@masterId BIGINT)
RETURNS @list TABLE(
	 cCurrCostRate FLOAT
	,cCurrHOMargin FLOAT
	,cCurrAgentMargin FLOAT
	,pCurrCostRate FLOAT
	,pCurrHOMargin FLOAT
	,pCurrAgentMargin FLOAT
	,agentCrossRate FLOAT
	,customerCrossRate FLOAT
	)
AS
BEGIN
	DECLARE @cCurrCostRate FLOAT, @cCurrHOMargin FLOAT, @cCurrAgentMargin FLOAT, @pCurrCostRate FLOAT, @pCurrHOMargin FLOAT, @pCurrAgentMargin FLOAT, @agentCrossRate FLOAT, @customerCrossRate FLOAT, @crossRateFactor CHAR(1)
	SELECT
		 @cCurrCostRate = cRate
		,@cCurrHOMargin = cCurrHOMargin
		,@cCurrAgentMargin = cCurrAgentMargin
		,@pCurrCostRate = pRate
		,@pCurrHOMargin = pCurrHOMargin
		,@pCurrAgentMargin = pCurrAgentMargin
		,@agentCrossRate = CASE WHEN (main.cRateFactor = 'M' AND main.pRateFactor = 'M') THEN ((main.pRate - ISNULL(pCurrHOMargin, 0))/(main.cRate + ISNULL(cCurrHOMargin, 0))) 
								   WHEN (main.cRateFactor = 'M' AND main.pRateFactor = 'D') THEN ((1/(main.pRate + ISNULL(pCurrHOMargin, 0)))/(main.cRate + ISNULL(cCurrHOMargin, 0)))
								   WHEN (main.cRateFactor = 'D' AND main.pRateFactor = 'M') THEN ((main.pRate - ISNULL(pCurrHOMargin, 0))/(1/(main.cRate - ISNULL(cCurrHOMargin, 0)))) 
								   WHEN (main.cRateFactor = 'D' AND main.pRateFactor = 'D') THEN ((1/(main.pRate + ISNULL(pCurrHOMargin, 0)))/(1/(main.cRate - ISNULL(cCurrHOMargin, 0))))
							  END
		,@customerCrossRate = CASE WHEN (main.cRateFactor = 'M' AND main.pRateFactor = 'M') THEN ((main.pRate - ISNULL(pCurrHOMargin, 0) - ISNULL(pCurrAgentMargin, 0))/(main.cRate + ISNULL(cCurrHOMargin, 0) + ISNULL(cCurrAgentMargin, 0))) 
								   WHEN (main.cRateFactor = 'M' AND main.pRateFactor = 'D') THEN ((1/(main.pRate + ISNULL(pCurrHOMargin, 0) + ISNULL(pCurrAgentMargin, 0)))/(main.cRate + ISNULL(cCurrHOMargin, 0) + ISNULL(cCurrAgentMargin, 0)))
								   WHEN (main.cRateFactor = 'D' AND main.pRateFactor = 'M') THEN ((main.pRate - ISNULL(pCurrHOMargin, 0) - ISNULL(pCurrAgentMargin, 0))/(1/(main.cRate - ISNULL(cCurrHOMargin, 0) - ISNULL(cCurrAgentMargin, 0)))) 
								   WHEN (main.cRateFactor = 'D' AND main.pRateFactor = 'D') THEN ((1/(main.pRate + ISNULL(pCurrHOMargin, 0) + ISNULL(pCurrAgentMargin, 0)))/(1/(main.cRate - ISNULL(cCurrHOMargin, 0) - ISNULL(cCurrAgentMargin, 0))))
							  END
		,@crossRateFactor = crossRateFactor
	FROM spExRate main WITH(NOLOCK) WHERE spExRateId = @masterId
	
	IF(@crossRateFactor = 'D')
		SELECT @customerCrossRate = 1/@customerCrossRate
			
	INSERT @list	
	SELECT @cCurrCostRate, @cCurrHOMargin, @cCurrAgentMargin, @pCurrCostRate, @pCurrHOMargin, @pCurrAgentMargin, @agentCrossRate, @customerCrossRate
		
	RETURN	
END
GO
