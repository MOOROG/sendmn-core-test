USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_crossExchangeRate]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC proc_crossExchangeRate
	 @ssAgent		 = 53
	,@sCountry		 = 3
	,@sAgent		 = 59
	,@sBranch		 = 78
	,@rsAgent		 = 3
	,@rCountry		 = 1
	,@rAgent		 = 9
	,@rBranch		 = 19
	,@listType		 = 'd'

SELECT * FROM seRate

*/

CREATE proc [dbo].[proc_crossExchangeRate]
	 @user			VARCHAR(30)
	,@ssAgent		INT = NULL
	,@sCountry		INT = NULL
	,@sAgent		INT = NULL
	,@sBranch		INT = NULL
	,@rsAgent		INT = NULL
	,@rCountry		INT = NULL
	,@rAgent		INT = NULL
	,@rBranch		INT = NULL
	
	,@listType		CHAR(1) = NULL
	
	
	/*	'd':	no level
		'a':	agentLevel
		'c':	countryLevel
		'b':	branchLevel	
	*/
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @agentList TABLE (
		 Id				INT IDENTITY(1, 1)	
		,sCountry		INT
		,sAgent			INT
		,sBranch		INT
		,rCountry		INT
		,rAgent			INT
		,rBranch		INT	
	)


	DECLARE @agentList2 TABLE (
		 Id				INT IDENTITY(1, 1)
		,sCountry		INT
		,sAgent			INT
		,sBranch		INT
		,rCountry		INT
		,rAgent			INT
		,rBranch		INT
		,sending		INT
		,receiving		INT
		,sType			CHAR(1)
		,rType			CHAR(1)
		,collCurr		INT
		,pCurr			INT
	)

	IF @listType = 'd'
	BEGIN
		INSERT @agentList(sCountry, sAgent, sBranch, rCountry, rAgent, rBranch)
		SELECT @sCountry, @sAgent, @sBranch, @rCountry, @rAgent, @rBranch
	END
	ELSE IF @listType = 'c'
	BEGIN
		IF @sCountry IS NULL 
		BEGIN
			EXEC proc_errorHandler 1, 'You must define sending country.', NULL
			RETURN	
		END
		
		IF @rsAgent IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'You must define receiving super agent.', NULL
			RETURN	
		END
			
		INSERT @agentList(sCountry, sAgent, sBranch, rCountry, rAgent, rBranch)
		SELECT
			DISTINCT 
			@sCountry, @sAgent, @sBranch, am.agentCountryId, NULL, NULL
		FROM agentMaster am WITH(NOLOCK) WHERE parentId = @rsAgent		
	END 

	ELSE IF @listType = 'a'
	BEGIN
		IF @sCountry IS NULL 
		BEGIN
			EXEC proc_errorHandler 1, 'You must define sending country.', NULL
			RETURN	
		END
		
		IF @rsAgent IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'You must define receiving super agent.', NULL
			RETURN	
		END
		
		IF @rCountry IS NOT NULL AND @rsAgent IS NOT NULL
		BEGIN	
			INSERT @agentList(sCountry, sAgent, sBranch, rCountry, rAgent, rBranch)
			SELECT
				DISTINCT 
				@sCountry, @sAgent, @sBranch, am.agentCountryId, am.agentId, NULL
			FROM agentMaster am WITH(NOLOCK) WHERE agentCountryId = @rCountry AND parentId = @rsAgent
		END
				
		ELSE IF @rsAgent IS NOT NULL
		BEGIN	
			INSERT @agentList(sCountry, sAgent, sBranch, rCountry, rAgent, rBranch)
			SELECT
				DISTINCT 
				@sCountry, @sAgent, @sBranch, am.agentCountryId, am.agentId, NULL
			FROM agentMaster am WITH(NOLOCK) WHERE parentId = @rsAgent
		END
	END 

	ELSE IF @listType = 'b'
	BEGIN
		IF @sCountry IS NULL 
		BEGIN
			EXEC proc_errorHandler 1, 'You must define sending country.', NULL
			RETURN	
		END
		
		IF @rAgent IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'You must define receiving agent.', NULL
			RETURN	
		END
			
		INSERT @agentList(sCountry, sAgent, sBranch, rCountry, rAgent, rBranch)
		SELECT
			DISTINCT 
			@sCountry, @sAgent, @sBranch, am.agentCountryId, am.parentId, am.agentId
		FROM agentMaster am WITH(NOLOCK) WHERE parentId = @rAgent
		
	END 
	
	
	DECLARE @Id INT, @max INT

	SELECT 
		 @max = MAX(Id) 
	FROM @agentList

	SET @Id = 1

	WHILE @Id <= @max
	BEGIN
		SELECT
			 @sCountry = sCountry
			,@sAgent = sAgent
			,@sBranch = sBranch
			,@rCountry = rCountry
			,@rAgent = rAgent
			,@rBranch = rBranch
		FROM @agentList WHERE Id = @Id
		
		IF @sAgent IS NOT NULL AND @rAgent IS NOT NULL
		BEGIN
			INSERT @agentList2 (
				 sCountry
				,sAgent
				,sBranch
				,rCountry
				,rAgent
				,rBranch
				,sending
				,receiving
				,sType
				,rType
				,collCurr
				,pCurr
			)
			SELECT 
				DISTINCT
				 @sCountry
				,@sAgent
				,@sBranch
				,@rCountry
				,@rAgent
				,@rBranch
				,COALESCE(@sBranch, @sAgent, @sCountry)
				,COALESCE(@rBranch, @rAgent, @rCountry)
				,CASE WHEN @sBranch IS NOT NULL THEN 'B' WHEN @sAgent IS NOT NULL THEN 'A' WHEN @sCountry IS NOT NULL THEN 'C' END
				,CASE WHEN @rBranch IS NOT NULL THEN 'B' WHEN @rAgent IS NOT NULL THEN 'A' WHEN @rCountry IS NOT NULL THEN 'C' END
				,curr.collCurr
				,curr.pCurr
			FROM @agentList am
			INNER JOIN (
				SELECT
					--DISTINCT
					 sAgent = @sAgent
					,rAgent = @rAgent
					,collCurr = x.currencyId
					,pCurr = y.currencyId
					
				FROM (
					SELECT 
						currencyId
					FROM agentCurrency WHERE agentId = @sAgent AND (spFlag = 5200 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N' 
				) x
				CROSS JOIN (
				SELECT 
					currencyId
				FROM agentCurrency WHERE agentId = @rAgent AND (spFlag = 5201 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N'
				) y	
			) curr ON am.sAgent = curr.sAgent	
		END
		
		ELSE IF @sAgent IS NOT NULL AND @rCountry IS NOT NULL
		BEGIN
			INSERT @agentList2 (
				 sCountry
				,sAgent
				,sBranch
				,rCountry
				,rAgent
				,rBranch
				,sending
				,receiving
				,sType
				,rType
				,collCurr
				,pCurr
			)
			SELECT 
				DISTINCT
				 @sCountry
				,@sAgent
				,@sBranch
				,@rCountry
				,@rAgent
				,@rBranch
				,COALESCE(@sBranch, @sAgent, @sCountry)
				,COALESCE(@rBranch, @rAgent, @rCountry)
				,CASE WHEN @sBranch IS NOT NULL THEN 'B' WHEN @sAgent IS NOT NULL THEN 'A' WHEN @sCountry IS NOT NULL THEN 'C' END
				,CASE WHEN @rBranch IS NOT NULL THEN 'B' WHEN @rAgent IS NOT NULL THEN 'A' WHEN @rCountry IS NOT NULL THEN 'C' END
				,curr.collCurr
				,curr.pCurr
			FROM @agentList am
			INNER JOIN (
				SELECT
					--DISTINCT
					 sAgent = @sAgent
					,rCountry = @rCountry
					,collCurr = x.currencyId
					,pCurr = y.currencyId
					
				FROM (
					SELECT 
						currencyId
					FROM agentCurrency WHERE agentId = @sAgent AND (spFlag = 5200 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N' 
				) x
				CROSS JOIN (
				SELECT 
					currencyId
				FROM countryCurrency WHERE countryId = @rCountry AND (spFlag = 5201 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N'
				) y	
			) curr ON am.sAgent = curr.sAgent	
		END
		
		ELSE IF @sCountry IS NOT NULL AND @rAgent IS NOT NULL
		BEGIN
			INSERT @agentList2 (
				 sCountry
				,sAgent
				,sBranch
				,rCountry
				,rAgent
				,rBranch
				,sending
				,receiving
				,sType
				,rType
				,collCurr
				,pCurr
			)
			SELECT 
				DISTINCT
				 @sCountry
				,@sAgent
				,@sBranch
				,@rCountry
				,@rAgent
				,@rBranch
				,COALESCE(@sBranch, @sAgent, @sCountry)
				,COALESCE(@rBranch, @rAgent, @rCountry)
				,CASE WHEN @sBranch IS NOT NULL THEN 'B' WHEN @sAgent IS NOT NULL THEN 'A' WHEN @sCountry IS NOT NULL THEN 'C' END
				,CASE WHEN @rBranch IS NOT NULL THEN 'B' WHEN @rAgent IS NOT NULL THEN 'A' WHEN @rCountry IS NOT NULL THEN 'C' END
				,curr.collCurr
				,curr.pCurr
			FROM @agentList am
			INNER JOIN (
				SELECT
					--DISTINCT
					 sCountry = @sCountry
					,rAgent = @rAgent
					,collCurr = x.currencyId
					,pCurr = y.currencyId
					
				FROM (
					SELECT 
						currencyId
					FROM countryCurrency WHERE countryId = @sCountry AND (spFlag = 5201 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N'
				
				) x
				CROSS JOIN (			
					SELECT 
						currencyId
					FROM agentCurrency WHERE agentId = @rAgent AND (spFlag = 5200 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N' 
				
				) y	
			) curr ON am.sCountry = curr.sCountry	
		END
		
		ELSE IF @sCountry IS NOT NULL AND @rCountry IS NOT NULL
		BEGIN
			INSERT @agentList2 (
				 sCountry
				,sAgent
				,sBranch
				,rCountry
				,rAgent
				,rBranch
				,sending
				,receiving
				,sType
				,rType
				,collCurr
				,pCurr
			)
			SELECT 
				DISTINCT
				 @sCountry
				,@sAgent
				,@sBranch
				,@rCountry
				,@rAgent
				,@rBranch
				,COALESCE(@sBranch, @sAgent, @sCountry)
				,COALESCE(@rBranch, @rAgent, @rCountry)
				,CASE WHEN @sBranch IS NOT NULL THEN 'B' WHEN @sAgent IS NOT NULL THEN 'A' WHEN @sCountry IS NOT NULL THEN 'C' END
				,CASE WHEN @rBranch IS NOT NULL THEN 'B' WHEN @rAgent IS NOT NULL THEN 'A' WHEN @rCountry IS NOT NULL THEN 'C' END
				,curr.collCurr
				,curr.pCurr
			FROM @agentList am
			INNER JOIN (
				SELECT
					--DISTINCT
					 sCountry = @sCountry
					,rCountry = @rCountry
					,collCurr = x.currencyId
					,pCurr = y.currencyId
					
				FROM (
					SELECT 
						currencyId
					FROM countryCurrency WHERE countryId = @sCountry AND (spFlag = 5201 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N'
				
				) x
				CROSS JOIN (			
					SELECT 
						currencyId
					FROM countryCurrency WHERE countryId = @rCountry AND (spFlag = 5201 OR spFlag IS NULL) AND ISNULL(isDeleted, 'N') = 'N'
				
				) y	
			) curr ON am.sCountry = curr.sCountry	
		END		
		
		SET @Id = @Id + 1	
	END

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
		,collCurr		INT
		,payCurr		INT
	)

	DECLARE
		 @sending		INT
		,@receiving		INT
		,@sType			CHAR(1)
		,@rType			CHAR(1)
		,@collCurr		INT
		,@pCurr			INT
		,@pCost			MONEY
		,@pMargin		MONEY
		,@pAgentMargin	MONEY
		,@pVe			MONEY
		,@pNe			MONEY
		,@sCost			MONEY
		,@sMargin		MONEY
		,@sAgentMargin	MONEY
		,@sVe			MONEY
		,@sNe			MONEY
		,@crossRate		MONEY
		
		
	SELECT 
		 @max = MAX(Id) 
	FROM @agentList2
	
	SET @Id = 1
	
	WHILE @Id <= @max
	BEGIN
		SELECT
			 @sCountry = sCountry
			,@sAgent = sAgent
			,@sBranch = sBranch
			,@rCountry = rCountry
			,@rAgent = rAgent
			,@rBranch = rBranch
			,@sending = sending
			,@receiving = receiving
			,@collCurr = collCurr
			,@pCurr = pCurr
			,@sType = sType
			,@rType = rType			
			
		FROM @agentList2 WHERE Id = @Id
		
		
		SELECT
			 @pCost			= pCost
			,@pMargin		= pMargin
			,@pAgentMargin	= pAgentMargin
			,@pVe			= pVe
			,@pNe			= pNe
			
			,@sCost			= sCost
			,@sMargin		= sMargin
			,@sAgentMargin	= sAgentMargin
			,@sVe			= sVe
			,@sNe			= sNe
			
			,@crossRate		= crossRate
		FROM [dbo].FNAGetEchangeRate(@ssAgent, @sending, @rsAgent, @receiving, @collCurr, @pCurr, @sType, @rType, 'N', @user)
		
		INSERT INTO @eList(sCountry, sAgent, sBranch, rCountry, rAgent, rBranch
						   ,sCost, sMargin, sAgentMargin, sNet, rCost, rMargin
						   ,rAgentMargin, rNet, crossRate, collCurr, payCurr
		)
		SELECT @sCountry, @sAgent, @sBranch, @rCountry, @rAgent, @rBranch
				,@sCost, @sMargin, @sAgentMargin, (@sCost + @sMargin + @sAgentMargin), @pCost, @pMargin
				,@pAgentMargin, (@pCost - @pMargin - @pAgentMargin), @crossRate, @collCurr, @pCurr
				
		SET @Id = @Id + 1
		
	END
	
	SELECT
		 el.sCountry
		,sCountryName = sc.countryName + ISNULL(' » ' + sa.agentName, '') + ISNULL(' » ' + sb.agentName, '') --+ '(' + coll.currencyCode + ')'
		,el.sAgent
		,sAgentName = sa.agentName
		,el.sBranch
		,sBranchName = sb.agentName	
		,el.rCountry
		,rCountryName = rc.countryName + ISNULL(' » ' + ra.agentName, '') + ISNULL(' » ' + rb.agentName, '') --+ '(' + pay.currencyCode + ')'
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
		,el.crossRate
		,el.collCurr
		,el.payCurr		
		,collCurrName = coll.currencyCode 
		,payCurrName = pay.currencyCode 
	FROM @eList el
	LEFT JOIN countryMaster sc WITH(NOLOCK) ON sc.countryId = el.sCountry 
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON el.sAgent = sa.agentId
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON el.sBranch = sb.agentId
	LEFT JOIN countryMaster rc WITH(NOLOCK) ON rc.countryId = el.rCountry 
	LEFT JOIN agentMaster ra WITH(NOLOCK) ON el.rAgent = ra.agentId
	LEFT JOIN agentMaster rb WITH(NOLOCK) ON el.rBranch = rb.agentId
	LEFT JOIN currencyMaster coll WITH(NOLOCK) ON el.collCurr = coll.currencyId
	LEFT JOIN currencyMaster pay WITH(NOLOCK) ON el.payCurr = pay.currencyId
END TRY
BEGIN CATCH
	DECLARE @errMsg VARCHAR(500)
	SET @errMsg = ERROR_MESSAGE() + ' : ' + CAST(ERROR_LINE() AS VARCHAR(50))
	EXEC proc_errorHandler 1, @errMsg, NULL		
END CATCH


GO
