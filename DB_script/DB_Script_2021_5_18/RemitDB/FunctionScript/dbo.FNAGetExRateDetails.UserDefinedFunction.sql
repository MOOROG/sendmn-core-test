USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetExRateDetails]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetExRateDetails](@masterId BIGINT)
RETURNS @list TABLE(
	 customerRate FLOAT
	,sCurrCostRate FLOAT
	,sCurrHoMargin FLOAT
	,sCurrAgentMargin FLOAT
	,pCurrCostRate FLOAT
	,pCurrHoMargin FLOAT
	,pCurrAgentMargin FLOAT
	,sAgentSettRate FLOAT
	,pAgentSettRate FLOAT
	,agentCrossSettRate FLOAT
	,treasuryTolerance FLOAT
	,customerPremium FLOAT
	,sharingValue MONEY
	,sharingType CHAR(1)
	)
AS
BEGIN
	INSERT @list
	SELECT 
		 ISNULL(crossRateOperation,customerRate) + ISNULL(premium, 0)
		,cRate
		,ROUND(cMargin + cHoMargin, 6)
		,cAgentMargin
		,pRate
		,ROUND(pMargin + pHoMargin, 6)
		,pAgentMargin
		,ROUND(cRate + cMargin + cHoMargin, 6)
		,ROUND(pRate - pMargin - pHoMargin, 6)
		,crossRate
		,tolerance
		,ISNULL(premium, 0)
		,sharingValue
		,sharingType
	FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @masterId
	RETURN
END


GO
