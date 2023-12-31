USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetEchangeRate]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetEchangeRate](@ssAgent BIGINT, @sending BIGINT, @rsAgent BIGINT, @receiving BIGINT, @collCurr INT, @payCurr INT, @sType CHAR(1), @rType CHAR(1), @isTranMode CHAR(1), @user VARCHAR(30))
RETURNS @list TABLE(pCost MONEY, pMargin MONEY, pAgentMargin MONEY, pVe MONEY, pNe MONEY, sCost MONEY, sMargin MONEY, sAgentMargin MONEY, sVe MONEY, sNe MONEY, crossRate MONEY)
AS
BEGIN
	DECLARE 
		 @ccMasterId		INT
		,@ccMaster			CHAR(1)
		,@lookInTable		VARCHAR(4)
		,@pcMasterId		INT
		,@pcMaster			CHAR(1)
		
	SELECT
		 @pcMasterId = id
		,@pcMaster = masterType
		,@lookInTable = lookInTable
	FROM [dbo].FNAGetEchangeRateMasterId(@ssAgent, @sending, @rsAgent, @receiving, @payCurr, @sType, @rType,  'P', @isTranMode, @user)
	
	SELECT
		 @ccMasterId = id
		,@ccMaster	= masterType
		,@lookInTable = lookInTable	
	FROM [dbo].FNAGetEchangeRateMasterId(@ssAgent, @sending, @rsAgent, @receiving, @collCurr, @sType, @sType, 'S', @isTranMode, @user)	
	
	DECLARE	
		 @ccCost		MONEY
		,@ccMargin		MONEY
		,@ccAgentMargin MONEY
		,@ccVe			MONEY
		,@ccNe			MONEY	
		,@pcCost		MONEY
		,@pcMargin		MONEY
		,@pcAgentMargin MONEY
		,@pcVe			MONEY
		,@pcNe			MONEY

	SELECT
		 @ccCost = ISNULL(cost, 0)
		,@ccMargin = ISNULL(margin, 0)
		,@ccAgentMargin = ISNULL(agentMargin, 0)
		,@ccVe = ISNULL(ve, 0)
		,@ccNe = ISNULL(ne, 0)
	FROM [dbo].FNAGetEchangeRateDetails(@ccMasterId, @ccMaster, @lookInTable) x
		
	SELECT
		 @pcCost = ISNULL(cost, 0)
		,@pcMargin = ISNULL(margin, 0)
		,@pcAgentMargin = ISNULL(agentMargin, 0)
		,@pcVe = ISNULL(ve, 0)
		,@pcNe = ISNULL(ne, 0)
	FROM [dbo].FNAGetEchangeRateDetails(@pcMasterId, @pcMaster, @lookInTable) x
		
	DECLARE
		 @s MONEY
		,@p MONEY
		,@cr MONEY
		
	SELECT
		 @s = @ccCost + @ccMargin + @ccAgentMargin
		,@p = @pcCost - @pcMargin - @pcAgentMargin
	
	SET @cr = CASE WHEN @ccCost > 1 THEN @p / NULLIF(@s, 0) ELSE @p * @s END
	
	INSERT @list (
		 pCost
		,pMargin
		,pAgentMargin
		,pVe
		,pNe		
		,sCost
		,sMargin
		,sAgentMargin
		,sVe
		,sNe
		,crossRate
	)	
	SELECT		
		 @pcCost
		,@pcMargin
		,@pcAgentMargin
		,@pcVe
		,@pcNe
		,@ccCost
		,@ccMargin
		,@ccAgentMargin
		,@ccVe
		,@ccNe
		,@cr
		
	RETURN	
END
GO
