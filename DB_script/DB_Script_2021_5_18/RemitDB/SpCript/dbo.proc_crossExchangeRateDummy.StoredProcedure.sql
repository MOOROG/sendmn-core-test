USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_crossExchangeRateDummy]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[proc_crossExchangeRateDummy]
AS
DECLARE @eList TABLE (
	 sCountry		INT
	,sAgent			INT
	,sBranch		INT
	,rCountry		INT
	,rAgent			INT
	,rBranch		INT
	,sCost			MONEY
	,sMargin		MONEY
	,sAgentMargin	MONEY
	,sNet			MONEY
	,rCost			MONEY
	,rMargin		MONEY
	,rAgentMargin	MONEY
	,rNet			MONEY
	,crossRate		MONEY
)

INSERT INTO @eList(sCountry, sAgent, sBranch, rCountry, rAgent, rBranch, sCost, sMargin, sAgentMargin, sNet, rCost, rMargin, rAgentMargin, rNet, crossRate)
SELECT 3, 59, 78, 1, 9, 19, 50, 0.1, 0.1, 50.2, 80, 0.5, 0.6, 78.9, 1.78 UNION ALL
SELECT 3, 55, 64, 1, 9, 19, 50, 0.08, 0.08, 50.16, 80, 0.3, 0.5, 79.2, 1.58
--SELECT * FROM @eList

SELECT
	 el.sCountry
	,sCountryName = sc.countryName 
	,el.sAgent
	,sAgentName = sa.agentName
	,el.sBranch
	,sBranchName = sb.agentName
	
	,el.rCountry
	,rCountryName = rc.countryName 
	,el.rAgent
	,sAgentName = ra.agentName
	,el.rBranch
	,rBranchName = rb.agentName
	
	,el.sCost
	,el.sMargin
	,el.sAgentMargin
	,el.sNet
	
	,el.rCost
	,el.rMargin
	,el.rAgentMargin
	,el.rNet
	

FROM @eList el
LEFT JOIN countryMaster sc WITH(NOLOCK) ON sc.countryId = el.sCountry 
LEFT JOIN agentMaster sa WITH(NOLOCK) ON el.sAgent = sa.agentId
LEFT JOIN agentMaster sb WITH(NOLOCK) ON el.sBranch = sb.agentId

LEFT JOIN countryMaster rc WITH(NOLOCK) ON rc.countryId = el.rCountry 
LEFT JOIN agentMaster ra WITH(NOLOCK) ON el.rAgent = ra.agentId
LEFT JOIN agentMaster rb WITH(NOLOCK) ON el.rBranch = rb.agentId

GO
