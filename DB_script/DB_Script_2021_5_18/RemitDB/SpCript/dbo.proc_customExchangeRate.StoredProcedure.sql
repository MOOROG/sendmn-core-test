USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customExchangeRate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

proc_customExchangeRate 'cl', 'admin', 5

*/

CREATE proc [dbo].[proc_customExchangeRate]
	 @flag									VARCHAR(10)
	,@user									VARCHAR(30)
	,@agentId								INT				= NULL
	,@agentCountryWiseCustomMarginId		VARCHAR(30)		= NULL
	,@sAgentId								INT				= NULL
	,@sRate									FLOAT			= NULL
	,@SMargin								FLOAT			= NULL
	,@sMin									FLOAT			= NULL
	,@sMax									FLOAT			= NULL
	,@pCountryId							INT				= NULL
	,@pRate									FLOAT			= NULL
	,@pMargin								FLOAT			= NULL
	,@pMin									FLOAT			= NULL
	,@pMax									FLOAT			= NULL
	,@SCRCRate								FLOAT			= NULL
	,@SCRCMargin							FLOAT			= NULL
	,@rndSExRate							INT				= NULL
	,@rndPAmount							INT				= NULL
AS
/*
@flag,
	s	=> Country wise, agent wise list	
	cl	=> Agent Vs Country List
	al	=> Agent Vs Agent List
	ci	=> Agent country insert
	ai  => Agent agent insert
	cu	=> Agent country update
	au	=> Agent agent update
*/

SET NOCOUNT ON
SET XACT_ABORT ON

IF @flag = 'ci'
BEGIN
	PRINT 1
	
	
	
END
ELSE IF @flag = 'cu'
BEGIN
	PRINT 2
	
END
ELSE IF @flag = 's'
BEGIN
	SELECT
		 countryId
		,ccm.countryName
		,agentId	
		,am.agentName	
	FROM agentMaster am WITH(NOLOCK)
	INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON am.agentCountry = ccm.countryId
	ORDER BY ccm.countryName, am.agentName
END
ELSE IF @flag = 'cl'
BEGIN
	SELECT
		 x.agentCountryWiseCustomMarginId 
		,s.agentId
		,sAgent = s.agentName
		,sCurr = s1.currCode
		,sCountry = s1.countryName		
		,x.sRate
		,sMargin = ISNULL(x.sMargin, 0)
		,sBid = ISNULL(x.sRate, 0) + ISNULL(x.sMargin, 0)
		,x.sMax
		,x.sMin
		
		,p.countryId
		,pCountry = p.countryName
		,pCurr = p.currCode
		,x.pRate
		,pMargin = ISNULL(x.pMargin, 0)
		,pBid = ISNULL(x.pRate, 0) + ISNULL(x.pMargin, 0)
		,x.pMax 
		,x.pMin		
				
		,x.SCRCRate
		,SCRCMargin = ISNULL(x.SCRCMargin, 0)
		,SCRCBid = ISNULL(x.SCRCRate, 0) - ISNULL(x.SCRCMargin, 0)
		,x.modifiedBy
		,x.modifiedDate
	FROM (
		SELECT 
			*
		FROM agentCountryWiseCustomMargin WHERE sAgentId = @agentId
	) x
	INNER JOIN countryCurrencyMaster p WITH(NOLOCK) ON x.pCountryId = p.countryId
	INNER JOIN agentMaster s WITH(NOLOCK) ON x.sAgentId = s.agentId
	INNER JOIN countryCurrencyMaster s1 WITH(NOLOCK) ON s.agentCountry = s1.countryId
END




GO
