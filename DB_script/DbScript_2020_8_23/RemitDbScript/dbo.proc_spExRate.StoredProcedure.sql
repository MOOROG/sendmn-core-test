USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_spExRate]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	proc_spExRate @flag = 's', @user = 'admin', @sortBy = 'spExRateId', @sortOrder = 'ASC', @pageSize = '10', @pageNumber = '1'
*/
CREATE proc [dbo].[proc_spExRate]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@spExRateId						VARCHAR(30)		= NULL
	,@spExRateIds						VARCHAR(MAX)	= NULL
	,@tranType							INT				= NULL
	,@cCountry                          INT				= NULL
	,@cAgent							INT				= NULL
	,@cAgentGroup						INT				= NULL
	,@cBranch							INT				= NULL
	,@cBranchGroup						INT				= NULL
	,@pCountry							INT				= NULL
	,@pAgent							INT				= NULL
	,@pAgentGroup						INT				= NULL
	,@pBranch							INT				= NULL
	,@pBranchGroup						INT				= NULL
	,@cCurrency							VARCHAR(3)		= NULL
	,@pCurrency							VARCHAR(3)		= NULL
	,@cRateFactor						CHAR(1)			= NULL
	,@pRateFactor						CHAR(1)			= NULL
	,@cRate								FLOAT			= NULL
	,@pRate								FLOAT			= NULL
	,@cCurrHOMargin						FLOAT			= NULL
	,@pCurrHOMargin						FLOAT			= NULL
	,@cCurrAgentMargin					FLOAT			= NULL
	,@pCurrAgentMargin					FLOAT			= NULL
	,@cHOTolMax							FLOAT			= NULL
	,@cHOTolMin							FLOAT			= NULL
	,@pHOTolMax							FLOAT			= NULL
	,@pHOTolMin							FLOAT			= NULL
	,@cAgentTolMax						FLOAT			= NULL
	,@cAgentTolMin						FLOAT			= NULL
	,@pAgentTolMax						FLOAT			= NULL
	,@pAgentTolMin						FLOAT			= NULL
	,@crossRate							FLOAT			= NULL
	,@crossRateFactor					CHAR(1)			= NULL
	,@effectiveFrom						DATETIME		= NULL
	,@effectiveTo						DATETIME		= NULL
	,@hasChanged                        CHAR(1)			= NULL
	,@currency							VARCHAR(3)		= NULL
	,@country							INT				= NULL
	,@agent								INT				= NULL
	,@rateType							CHAR(1)			= NULL
	,@cCountryName						VARCHAR(100)	= NULL
	,@cAgentName						VARCHAR(100)	= NULL
	,@pCountryName						VARCHAR(100)	= NULL
	,@pAgentName						VARCHAR(100)	= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	
	DECLARE @rateIdList TABLE(rowId INT IDENTITY(1,1), spExRateId INT)	
	SELECT
		 @logIdentifier = 'spExRateId'
		,@logParamMain = 'spExRate'
		,@logParamMod = 'spExRateHistory'
		,@module = '20'
		,@tableAlias = 'Special Ex-Rate'
		,@ApprovedFunctionId = 20111830
	
	IF @flag = 'cr'			--Load Cost Rate according to Currency
	BEGIN
		DECLARE @defExRateId INT
		SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @agent AND country = @country AND currency = @currency AND tranType = @tranType
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @agent AND country = @country AND currency = @currency AND tranType IS NULL
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CO' AND country = @country AND currency = @currency AND tranType = @tranType
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CO' AND country = @country AND currency = @currency AND tranType IS NULL
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @currency AND tranType = @tranType
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @currency AND tranType IS NULL
		
		IF @rateType = 'C'
		BEGIN
			SELECT 
				 costRate = CASE WHEN factor = 'M' THEN (ISNULL(cRate, 0) + ISNULL(cMargin, 0))
								 WHEN factor = 'D' THEN (ISNULL(cRate, 0) - ISNULL(cMargin, 0))
							END 
				,factor
				,factorName = CASE WHEN factor = 'M' THEN 'Multiplication' WHEN factor = 'D' THEN 'Division' END
			FROM defExRate WITH(NOLOCK) 
			WHERE defExRateId = @defExRateId	
		END
		ELSE IF @rateType = 'P'
		BEGIN
			SELECT 
				 costRate = CASE WHEN factor = 'M' THEN (ISNULL(pRate, 0) - ISNULL(pMargin, 0))
								 WHEN factor = 'D' THEN (ISNULL(pRate, 0) + ISNULL(pMargin, 0))
							END 
				,factor
				,factorName = CASE WHEN factor = 'M' THEN 'Multiplication' WHEN factor = 'D' THEN 'Division' END
			FROM defExRate WITH(NOLOCK) 
			WHERE defExRateId = @defExRateId	
		END
	END
	
	IF @flag IN ('s')		
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'spExRateId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'	
		
		DECLARE @m VARCHAR(MAX)
		SET @m = '(
					SELECT
						 spExRateId = ISNULL(mode.spExRateId, main.spExRateId)
						,tranType = ISNULL(mode.tranType, main.tranType)
						,cCountry = ISNULL(mode.cCountry, main.cCountry)
						,cAgent = ISNULL(mode.cAgent, main.cAgent)
						,cAgentGroup = ISNULL(mode.cAgentGroup, mode.cAgentGroup)
						,cBranch = ISNULL(mode.cBranch, main.cBranch)
						,cBranchGroup = ISNULL(mode.cBranchGroup, main.cBranchGroup)
						,pCountry = ISNULL(mode.pCountry, main.pCountry)
						,pAgent = ISNULL(mode.pAgent, main.pAgent)
						,pAgentGroup = ISNULL(mode.pAgentGroup, mode.pAgentGroup)
						,pBranch = ISNULL(mode.pBranch, main.pBranch)
						,pBranchGroup = ISNULL(mode.pBranchGroup, main.pBranchGroup)
						,cCurrency = ISNULL(mode.cCurrency, main.cCurrency)
						,pCurrency = ISNULL(mode.pCurrency, main.pCurrency)
						,cRateFactor = ISNULL(mode.cRateFactor, main.cRateFactor)
						,pRateFactor = ISNULL(mode.pRateFactor, main.pRateFactor)
						,cRate = ISNULL(mode.cRate, main.cRate)
						,pRate = ISNULL(mode.pRate, main.pRate)
						,cCurrHOMargin = ISNULL(mode.cCurrHOMargin, main.cCurrHOMargin)
						,pCurrHOMargin = ISNULL(mode.pCurrHOMargin, main.pCurrHOMargin)
						,cCurrAgentMargin = ISNULL(mode.cCurrAgentMargin, main.cCurrAgentMargin)
						,pCurrAgentMargin = ISNULL(mode.pCurrAgentMargin, main.pCurrAgentMargin)
						,cHOTolMax = ISNULL(mode.cHOTolMax, main.cHOTolMax)
						,cHOTolMin = ISNULL(mode.cHOTolMin, main.cHOTolMin)
						,pHOTolMax = ISNULL(mode.pHOTolMax, main.pHOTolMax)
						,pHOTolMin = ISNULL(mode.pHOTolMin, main.pHOTolMin)
						,cAgentTolMax = ISNULL(mode.cAgentTolMax, main.cAgentTolMax)
						,cAgentTolMin = ISNULL(mode.cAgentTolMin, main.cAgentTolMin)
						,pAgentTolMax = ISNULL(mode.pAgentTolMax, main.pAgentTolMax)
						,pAgentTolMin = ISNULL(mode.pAgentTolMin, main.pAgentTolMin)
						,crossRate = ISNULL(mode.crossRate, main.crossRate)
						,crossRateFactor = ISNULL(mode.crossRateFactor, main.crossRateFactor)
						,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
						,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)				
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.spExRateId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM spExRate main WITH(NOLOCK)
					LEFT JOIN spExRateHistory mode ON main.spExRateId = mode.spExRateId AND mode.approvedBy IS NULL				
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					
					WHERE  (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
				) '
				
					
		SET @table = '(
						SELECT
							 main.spExRateId	
							,main.tranType
							,tranTypeName = ISNULL(stm.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''All'')
							,main.cAgentGroup
							,cAgentGroupName = ISNULL(cag.detailTitle, ''All'')
							,main.cBranch
							,cBranchName = ISNULL(cbm.agentName, ''All'')
							,main.cBranchGroup
							,cBranchGroupName = ISNULL(cbg.detailTitle, ''All'')
							,main.pCountry
							,pCountryName = pc.countryName
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''All'')
							,main.pAgentGroup
							,pAgentGroupName = ISNULL(pag.detailTitle, ''All'')
							,main.pBranch
							,pBranchName = ISNULL(pbm.agentName, ''All'')
							,main.pBranchGroup
							,pBranchGroupName = ISNULL(pbg.detailTitle, ''All'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,main.pRate
							,cCurrHOMargin = ISNULL(main.cCurrHOMargin, 0.0)
							,pCurrHOMargin = ISNULL(main.pCurrHOMargin, 0.0)
							,cCurrAgentMargin = ISNULL(main.cCurrAgentMargin, 0.0)
							,pCurrAgentMargin = ISNULL(main.pCurrAgentMargin, 0.0)
							,cCurrAgentOffer = CASE WHEN main.cRateFactor = ''M'' THEN ISNULL(main.cRate, 0.0) + ISNULL(main.cCurrHOMargin, 0.0)
													WHEN main.cRateFactor = ''D'' THEN ISNULL(main.cRate, 0.0) - ISNULL(main.cCurrHOMargin, 0.0) END
							,pCurrAgentOffer = CASE WHEN main.pRateFactor = ''M'' THEN ISNULL(main.pRate, 0.0) - ISNULL(main.pCurrHOMargin, 0.0)
													WHEN main.pRateFactor = ''D'' THEN ISNULL(main.pRate, 0.0) + ISNULL(main.pCurrHOMargin, 0.0) END
							,cCurrCustomerOffer = CASE WHEN main.cRateFactor = ''M'' THEN ISNULL(main.cRate, 0.0) + ISNULL(main.cCurrHOMargin, 0.0) + ISNULL(main.cCurrAgentMargin, 0.0)
													   WHEN main.cRateFactor = ''D'' THEN ISNULL(main.cRate, 0.0) - ISNULL(main.cCurrHOMargin, 0.0) - ISNULL(main.cCurrAgentMargin, 0.0) END
							,pCurrCustomerOffer = CASE WHEN main.pRateFactor = ''M'' THEN ISNULL(main.pRate, 0.0) - ISNULL(main.pCurrHOMargin, 0.0) - ISNULL(main.pCurrAgentMargin, 0.0)
													   WHEN main.pRateFactor = ''D'' THEN ISNULL(main.pRate, 0.0) + ISNULL(main.pCurrHOMargin, 0.0) + ISNULL(main.pCurrAgentMargin, 0.0) END				
							,cHOTolMax = ISNULL(main.cHOTolMax, 0.0)
							,cHOTolMin = ISNULL(main.cHOTolMin, 0.0)
							,pHOTolMax = ISNULL(main.pHOTolMax, 0.0)
							,pHOTolMin = ISNULL(main.pHOTolMin, 0.0)
							,cAgentTolMax = ISNULL(main.cAgentTolMax, 0.0)
							,cAgentTolMin = ISNULL(main.cAgentTolMin, 0.0)
							,pAgentTolMax = ISNULL(main.pAgentTolMax, 0.0)
							,pAgentTolMin = ISNULL(main.pAgentTolMin, 0.0)
							,hoCrossRate = CAST((
											CASE WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''M'') THEN (main.pRate/main.cRate) 
												WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''D'') THEN ((1/main.pRate)/main.cRate)
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''M'') THEN (main.pRate/(1/main.cRate)) 
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''D'') THEN ((1/main.pRate)/(1/main.cRate))
											END
											) AS DECIMAL(11, 6))
							,agentCrossRate = CAST(( 
											CASE WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''M'') THEN ((main.pRate - ISNULL(main.pCurrHOMargin, 0.0))/(main.cRate + ISNULL(main.cCurrHOMargin, 0.0))) 
												WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''D'') THEN ((1/(main.pRate + ISNULL(main.pCurrHOMargin, 0.0)))/(main.cRate + ISNULL(main.cCurrHOMargin, 0.0)))
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''M'') THEN ((main.pRate - ISNULL(main.pCurrHOMargin, 0.0))/(1/(main.cRate - ISNULL(main.cCurrHOMargin, 0.0))))
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''D'') THEN ((1/(main.pRate + ISNULL(main.pCurrHOMargin, 0.0)))/(1/(main.cRate - ISNULL(main.cCurrHOMargin, 0.0))))
											END
											) AS DECIMAL(11, 6))
							,crossRate = CAST(ISNULL(main.crossRate, 0) AS DECIMAL(11, 6))
							,main.crossRateFactor
							,effectiveFromDate = CONVERT(VARCHAR, main.effectiveFrom, 101)
							,effectiveFromTime = CONVERT(VARCHAR, main.effectiveFrom, 8)
							,effectiveToDate = CONVERT(VARCHAR, main.effectiveTo, 101)
							,effectiveToTime = CONVERT(VARCHAR, main.effectiveTo, 8)
							,cRateMaskMulBd = CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulBd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivBd END
							,cRateMaskMulAd = CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulAd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivAd END
							,pRateMaskMulBd = CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulBd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivBd END
							,pRateMaskMulAd = CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulAd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivAd END
							,main.modifiedBy
							,main.hasChanged	
						FROM ' + @m + ' main
						LEFT JOIN countryMaster cc ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN staticDataValue cag WITH(NOLOCK) ON main.cAgentGroup = cag.valueId
						LEFT JOIN agentMaster cbm WITH(NOLOCK) ON main.cBranch = cbm.agentId
						LEFT JOIN staticDataValue cbg WITH(NOLOCK) ON main.cBranchGroup = cbg.valueId
						LEFT JOIN countryMaster pc ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN staticDataValue pag WITH(NOLOCK) ON main.pAgentGroup = pag.valueId
						LEFT JOIN agentMaster pbm WITH(NOLOCK) ON main.pBranch = pbm.agentId
						LEFT JOIN staticDataValue pbg WITH(NOLOCK) ON main.pBranchGroup = pbg.valueId
						LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						LEFT JOIN rateMask prm WITH(NOLOCK) ON main.pCurrency = prm.currency AND ISNULL(prm.isActive, ''N'') = ''Y''
						WHERE 1=1
						
						'
							
		SET @table =  @table + ') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
			
		IF @cAgentGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentGroup = ' + CAST(@cAgentGroup AS VARCHAR(50))
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR(50))
		
		IF @cBranchGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranchGroup = ' + CAST(@cBranchGroup AS VARCHAR(50))
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
		
		IF @pAgentGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentGroup = ' + CAST(@pAgentGroup AS VARCHAR(50))
		
		IF @pBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pBranch = ' + CAST(@pBranch AS VARCHAR(50))
		
		IF @pBranchGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pBranchGroup = ' + CAST(@pBranchGroup AS VARCHAR(50))
				
		SET @select_field_list = '
			 spExRateId	
			,tranType
			,tranTypeName		
			,cCountry
			,cCountryName
			,cAgent
			,cAgentName
			,cAgentGroup
			,cAgentGroupName
			,cBranch
			,cBranchName
			,cBranchGroup
			,cBranchGroupName
			,pCountry
			,pCountryName
			,pAgent
			,pAgentName
			,pAgentGroup
			,pAgentGroupName
			,pBranch
			,pBranchName
			,pBranchGroup
			,pBranchGroupName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,pRate
			,cCurrHOMargin
			,pCurrHOMargin
			,cCurrAgentMargin
			,pCurrAgentMargin
			,cCurrAgentOffer
			,pCurrAgentOffer
			,cCurrCustomerOffer
			,pCurrCustomerOffer
			,cHOTolMax
			,cHOTolMin
			,pHOTolMax
			,pHOTolMin
			,cAgentTolMax
			,cAgentTolMin
			,pAgentTolMax
			,pAgentTolMin
			,hoCrossRate
			,agentCrossRate
			,crossRate
			,crossRateFactor
			,effectiveFromDate
			,effectiveFromTime
			,effectiveToDate
			,effectiveToTime
			,cRateMaskMulBd
			,cRateMaskMulAd
			,pRateMaskMulBd
			,pRateMaskMulAd
			,modifiedBy
			,hasChanged
			'
		PRINT @table	
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
				
	END
	
	IF @flag IN ('m')				--Approve List
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'spExRateId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'	
		   
		SET @m = '(
					SELECT
						 spExRateId = ISNULL(mode.spExRateId, main.spExRateId)
						,tranType = ISNULL(mode.tranType, main.tranType)
						,cCountry = ISNULL(mode.cCountry, main.cCountry)
						,cAgent = ISNULL(mode.cAgent, main.cAgent)
						,cAgentGroup = ISNULL(mode.cAgentGroup, mode.cAgentGroup)
						,cBranch = ISNULL(mode.cBranch, main.cBranch)
						,cBranchGroup = ISNULL(mode.cBranchGroup, main.cBranchGroup)
						,pCountry = ISNULL(mode.pCountry, main.pCountry)
						,pAgent = ISNULL(mode.pAgent, main.pAgent)
						,pAgentGroup = ISNULL(mode.pAgentGroup, mode.pAgentGroup)
						,pBranch = ISNULL(mode.pBranch, main.pBranch)
						,pBranchGroup = ISNULL(mode.pBranchGroup, main.pBranchGroup)
						,cCurrency = ISNULL(mode.cCurrency, main.cCurrency)
						,pCurrency = ISNULL(mode.pCurrency, main.pCurrency)
						,cRateFactor = ISNULL(mode.cRateFactor, main.cRateFactor)
						,pRateFactor = ISNULL(mode.pRateFactor, main.pRateFactor)
						,cRate = ISNULL(mode.cRate, main.cRate)
						,pRate = ISNULL(mode.pRate, main.pRate)
						,cCurrHOMarginOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cCurrHOMargin END
						,pCurrHOMarginOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pCurrHOMargin END
						,cCurrAgentMarginOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cCurrAgentMargin END
						,pCurrAgentMarginOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pCurrAgentMargin END
						,cHOTolMaxOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cHOTolMax END
						,cHOTolMinOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cHOTolMin END
						,pHOTolMaxOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pHOTolMax END
						,pHOTolMinOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pHOTolMin END
						,cAgentTolMaxOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cAgentTolMax END
						,cAgentTolMinOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cAgentTolMin END
						,pAgentTolMaxOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pAgentTolMax END
						,pAgentTolMinOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pAgentTolMin END
						,crossRateOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.crossRate END
						,crossRateFactorOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.crossRateFactor END
						,effectiveFromOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.effectiveFrom END
						,effectiveToOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.effectiveTo END
						,cCurrHOMarginNew = CASE WHEN main.approvedBy IS NULL THEN main.cCurrHOMargin ELSE mode.cCurrHOMargin END
						,pCurrHOMarginNew = CASE WHEN main.approvedBy IS NULL THEN main.pCurrHOMargin ELSE mode.pCurrHOMargin END
						,cCurrAgentMarginNew = CASE WHEN main.approvedBy IS NULL THEN main.cCurrAgentMargin ELSE mode.cCurrAgentMargin END
						,pCurrAgentMarginNew = CASE WHEN main.approvedBy IS NULL THEN main.pCurrAgentMargin ELSE mode.pCurrAgentMargin END
						,cHOTolMaxNew = CASE WHEN main.approvedBy IS NULL THEN main.cHOTolMax ELSE mode.cHOTolMax END
						,cHOTolMinNew = CASE WHEN main.approvedBy IS NULL THEN main.cHOTolMin ELSE mode.cHOTolMin END
						,pHOTolMaxNew = CASE WHEN main.approvedBy IS NULL THEN main.pHOTolMax ELSE mode.pHOTolMax END
						,pHOTolMinNew = CASE WHEN main.approvedBy IS NULL THEN main.pHOTolMin ELSE mode.pHOTolMax END
						,cAgentTolMaxNew = CASE WHEN main.approvedBy IS NULL THEN main.cAgentTolMax ELSE mode.cAgentTolMax END
						,cAgentTolMinNew = CASE WHEN main.approvedBy IS NULL THEN main.cAgentTolMin ELSE mode.cAgentTolMin END
						,pAgentTolMaxNew = CASE WHEN main.approvedBy IS NULL THEN main.pAgentTolMax ELSE mode.pAgentTolMax END
						,pAgentTolMinNew = CASE WHEN main.approvedBy IS NULL THEN main.pAgentTolMin ELSE mode.pAgentTolMin END
						,effectiveFromNew = CASE WHEN main.approvedBy IS NULL THEN main.effectiveFrom ELSE mode.effectiveFrom END
						,effectiveToNew = CASE WHEN main.approvedBy IS NULL THEN main.effectiveTo ELSE mode.effectiveTo END
						,crossRateNew = CASE WHEN main.approvedBy IS NULL THEN main.crossRate ELSE mode.crossRate END
						,crossRateFactorNew = CASE WHEN main.approvedBy IS NULL THEN main.crossRateFactor ELSE mode.crossRateFactor END		
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.approvedBy END		
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.spExRateId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM spExRate main WITH(NOLOCK)
					LEFT JOIN spExRateHistory mode ON main.spExRateId = mode.spExRateId AND mode.approvedBy IS NULL				
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					
					WHERE  (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
				) '
				
					
		SET @table = '(
						SELECT
							 main.spExRateId	
							,main.tranType
							,tranTypeName = ISNULL(stm.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''All'')
							,main.cAgentGroup
							,cAgentGroupName = ISNULL(cag.detailTitle, ''All'')
							,main.cBranch
							,cBranchName = ISNULL(cbm.agentName, ''All'')
							,main.cBranchGroup
							,cBranchGroupName = ISNULL(cbg.detailTitle, ''All'')
							,main.pCountry
							,pCountryName = pc.countryName
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''All'')
							,main.pAgentGroup
							,pAgentGroupName = ISNULL(pag.detailTitle, ''All'')
							,main.pBranch
							,pBranchName = ISNULL(pbm.agentName, ''All'')
							,main.pBranchGroup
							,pBranchGroupName = ISNULL(pbg.detailTitle, ''All'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,main.pRate
							,cCurrHOMarginOld = ISNULL(main.cCurrHOMarginOld, 0.0)
							,pCurrHOMarginOld = ISNULL(main.pCurrHOMarginOld, 0.0)
							,cCurrAgentMarginOld = ISNULL(main.cCurrAgentMarginOld, 0.0)
							,pCurrAgentMarginOld = ISNULL(main.pCurrAgentMarginOld, 0.0)
							,cCurrAgentOfferOld = CASE WHEN main.cRateFactor = ''M'' THEN ISNULL(main.cRate, 0.0) + ISNULL(main.cCurrHOMarginOld, 0.0)
													WHEN main.cRateFactor = ''D'' THEN ISNULL(main.cRate, 0.0) - ISNULL(main.cCurrHOMarginOld, 0.0) END
							,pCurrAgentOfferOld = CASE WHEN main.pRateFactor = ''M'' THEN ISNULL(main.pRate, 0.0) - ISNULL(main.pCurrHOMarginOld, 0.0)
													WHEN main.pRateFactor = ''D'' THEN ISNULL(main.pRate, 0.0) + ISNULL(main.pCurrHOMarginOld, 0.0) END
							,cCurrCustomerOfferOld = CASE WHEN main.cRateFactor = ''M'' THEN ISNULL(main.cRate, 0.0) + ISNULL(main.cCurrHOMarginOld, 0.0) + ISNULL(main.cCurrAgentMarginOld, 0.0)
													   WHEN main.cRateFactor = ''D'' THEN ISNULL(main.cRate, 0.0) - ISNULL(main.cCurrHOMarginOld, 0.0) - ISNULL(main.cCurrAgentMarginOld, 0.0) END
							,pCurrCustomerOfferOld = CASE WHEN main.pRateFactor = ''M'' THEN ISNULL(main.pRate, 0.0) - ISNULL(main.pCurrHOMarginOld, 0.0) - ISNULL(main.pCurrAgentMarginOld, 0.0)
													   WHEN main.pRateFactor = ''D'' THEN ISNULL(main.pRate, 0.0) + ISNULL(main.pCurrHOMarginOld, 0.0) + ISNULL(main.pCurrAgentMarginOld, 0.0) END				
							,cHOTolMaxOld = ISNULL(main.cHOTolMaxOld, 0.0)
							,cHOTolMinOld = ISNULL(main.cHOTolMinOld, 0.0)
							,pHOTolMaxOld = ISNULL(main.pHOTolMaxOld, 0.0)
							,pHOTolMinOld = ISNULL(main.pHOTolMinOld, 0.0)
							,cAgentTolMaxOld = ISNULL(main.cAgentTolMaxOld, 0.0)
							,cAgentTolMinOld = ISNULL(main.cAgentTolMinOld, 0.0)
							,pAgentTolMaxOld = ISNULL(main.pAgentTolMaxOld, 0.0)
							,pAgentTolMinOld = ISNULL(main.pAgentTolMinOld, 0.0)
							,hoCrossRateOld = CAST(( 
											CASE WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''M'') THEN (main.pRate/main.cRate) 
												WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''D'') THEN ((1/main.pRate)/main.cRate)
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''M'') THEN (main.pRate/(1/main.cRate)) 
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''D'') THEN ((1/main.pRate)/(1/main.cRate))
											END
											) AS DECIMAL(11, 6))
							,agentCrossRateOld = CAST(( 
											CASE WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''M'') THEN ((main.pRate - ISNULL(main.pCurrHOMarginOld, 0.0))/(main.cRate + ISNULL(main.cCurrHOMarginOld, 0.0))) 
												WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''D'') THEN ((1/(main.pRate + ISNULL(main.pCurrHOMarginOld, 0.0)))/(main.cRate + ISNULL(main.cCurrHOMarginOld, 0.0)))
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''M'') THEN ((main.pRate - ISNULL(main.pCurrHOMarginOld, 0.0))/(1/(main.cRate - ISNULL(main.cCurrHOMarginOld, 0.0))))
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''D'') THEN ((1/(main.pRate + ISNULL(main.pCurrHOMarginOld, 0.0)))/(1/(main.cRate - ISNULL(main.cCurrHOMarginOld, 0.0))))
											END
											) AS DECIMAL(11, 6))
							,crossRateOld = CAST(main.crossRateOld AS DECIMAL(11, 6))
							,crossRateFactorOld = CASE WHEN main.crossRateFactorOld = ''M'' THEN ''MUL''
														WHEN main.crossRateFactorOld = ''D'' THEN ''DIV'' ELSE ''-'' END
							,effectiveFromDateOld = CONVERT(VARCHAR, main.effectiveFromOld, 101)
							,effectiveFromTimeOld = CONVERT(VARCHAR, main.effectiveFromOld, 8)
							,effectiveToDateOld = CONVERT(VARCHAR, main.effectiveToOld, 101)
							,effectiveToTimeOld = CONVERT(VARCHAR, main.effectiveToOld, 8)	
							
							,cCurrHOMarginNew = ISNULL(main.cCurrHOMarginNew, 0.0)
							,pCurrHOMarginNew = ISNULL(main.pCurrHOMarginNew, 0.0)
							,cCurrAgentMarginNew = ISNULL(main.cCurrAgentMarginNew, 0.0)
							,pCurrAgentMarginNew = ISNULL(main.pCurrAgentMarginNew, 0.0)
							,cCurrAgentOfferNew = CASE WHEN main.cRateFactor = ''M'' THEN ISNULL(main.cRate, 0.0) + ISNULL(main.cCurrHOMarginNew, 0.0)
													WHEN main.cRateFactor = ''D'' THEN ISNULL(main.cRate, 0.0) - ISNULL(main.cCurrHOMarginNew, 0.0) END
							,pCurrAgentOfferNew = CASE WHEN main.pRateFactor = ''M'' THEN ISNULL(main.pRate, 0.0) - ISNULL(main.pCurrHOMarginNew, 0.0)
													WHEN main.pRateFactor = ''M'' THEN ISNULL(main.pRate, 0.0) + ISNULL(main.pCurrHOMarginNew, 0.0) END
							,cCurrCustomerOfferNew = CASE WHEN main.cRateFactor = ''M'' THEN ISNULL(main.cRate, 0.0) + ISNULL(main.cCurrHOMarginNew, 0.0) + ISNULL(main.cCurrAgentMarginNew, 0.0)
													   WHEN main.cRateFactor = ''D'' THEN ISNULL(main.cRate, 0.0) - ISNULL(main.cCurrHOMarginNew, 0.0) - ISNULL(main.cCurrAgentMarginNew, 0.0) END
							,pCurrCustomerOfferNew = CASE WHEN main.pRateFactor = ''M'' THEN ISNULL(main.pRate, 0.0) - ISNULL(main.pCurrHOMarginNew, 0.0) - ISNULL(main.pCurrAgentMarginNew, 0.0)
													   WHEN main.pRateFactor = ''D'' THEN ISNULL(main.pRate, 0.0) + ISNULL(main.pCurrHOMarginNew, 0.0) + ISNULL(main.pCurrAgentMarginNew, 0.0) END				
							,cHOTolMaxNew = ISNULL(main.cHOTolMaxNew, 0.0)
							,cHOTolMinNew = ISNULL(main.cHOTolMinNew, 0.0)
							,pHOTolMaxNew = ISNULL(main.pHOTolMaxNew, 0.0)
							,pHOTolMinNew = ISNULL(main.pHOTolMinNew, 0.0)
							,cAgentTolMaxNew = ISNULL(main.cAgentTolMaxNew, 0.0)
							,cAgentTolMinNew = ISNULL(main.cAgentTolMinNew, 0.0)
							,pAgentTolMaxNew = ISNULL(main.pAgentTolMaxNew, 0.0)
							,pAgentTolMinNew = ISNULL(main.pAgentTolMinNew, 0.0)
							,hoCrossRateNew = CAST((
											CASE WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''M'') THEN (main.pRate/main.cRate) 
												WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''D'') THEN ((1/main.pRate)/main.cRate)
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''M'') THEN (main.pRate/(1/main.cRate)) 
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''D'') THEN ((1/main.pRate)/(1/main.cRate))
											END
											) AS DECIMAL(11, 6))
							,agentCrossRateNew = CAST(( 
											CASE WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''M'') THEN ((main.pRate - ISNULL(main.pCurrHOMarginNew, 0.0))/(main.cRate + ISNULL(main.cCurrHOMarginNew, 0.0))) 
												WHEN (main.cRateFactor = ''M'' AND main.pRateFactor = ''D'') THEN ((1/(main.pRate + ISNULL(main.pCurrHOMarginNew, 0.0)))/(main.cRate + ISNULL(main.cCurrHOMarginNew, 0.0)))
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''M'') THEN ((main.pRate - ISNULL(main.pCurrHOMarginNew, 0.0))/(1/(main.cRate - ISNULL(main.cCurrHOMarginNew, 0.0))))
												WHEN (main.cRateFactor = ''D'' AND main.pRateFactor = ''D'') THEN ((1/(main.pRate + ISNULL(main.pCurrHOMarginNew, 0.0)))/(1/(main.cRate - ISNULL(main.cCurrHOMarginNew, 0.0))))
											END
											) AS DECIMAL(11, 6))
							,crossRateNew = CAST(main.crossRateNew AS DECIMAL(11, 6))
							,crossRateFactorNew = CASE WHEN main.crossRateFactorNew = ''M'' THEN ''MUL''
														WHEN main.crossRateFactorNew = ''D'' THEN ''DIV'' ELSE ''MUL'' END
							,effectiveFromDateNew = CONVERT(VARCHAR, main.effectiveFromNew, 101)
							,effectiveFromTimeNew = CONVERT(VARCHAR, main.effectiveFromNew, 8)
							,effectiveToDateNew = CONVERT(VARCHAR, main.effectiveToNew, 101)
							,effectiveToTimeNew = CONVERT(VARCHAR, main.effectiveToNew, 8)	
							,modType = CASE WHEN main.modType = ''I'' THEN ''Insert'' WHEN main.modType = ''U'' THEN ''Update'' END
							,main.modifiedBy
							,main.hasChanged	
						FROM ' + @m + ' main
						LEFT JOIN countryMaster cc ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN staticDataValue cag WITH(NOLOCK) ON main.cAgentGroup = cag.valueId
						LEFT JOIN agentMaster cbm WITH(NOLOCK) ON main.cBranch = cbm.agentId
						LEFT JOIN staticDataValue cbg WITH(NOLOCK) ON main.cBranchGroup = cbg.valueId
						LEFT JOIN countryMaster pc ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN staticDataValue pag WITH(NOLOCK) ON main.pAgentGroup = pag.valueId
						LEFT JOIN agentMaster pbm WITH(NOLOCK) ON main.pBranch = pbm.agentId
						LEFT JOIN staticDataValue pbg WITH(NOLOCK) ON main.pBranchGroup = pbg.valueId
						LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId
						WHERE 1=1 AND hasChanged = ''Y''
						
						'
							
		SET @table =  @table + ') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
			
		IF @cAgentGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentGroup = ' + CAST(@cAgentGroup AS VARCHAR(50))
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR(50))
		
		IF @cBranchGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranchGroup = ' + CAST(@cBranchGroup AS VARCHAR(50))
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
		
		IF @pAgentGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentGroup = ' + CAST(@pAgentGroup AS VARCHAR(50))
		
		IF @pBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pBranch = ' + CAST(@pBranch AS VARCHAR(50))
		
		IF @pBranchGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pBranchGroup = ' + CAST(@pBranchGroup AS VARCHAR(50))
				
		SET @select_field_list = '
			 spExRateId	
			,tranType
			,tranTypeName		
			,cCountry
			,cCountryName
			,cAgent
			,cAgentName
			,cAgentGroup
			,cAgentGroupName
			,cBranch
			,cBranchName
			,cBranchGroup
			,cBranchGroupName
			,pCountry
			,pCountryName
			,pAgent
			,pAgentName
			,pAgentGroup
			,pAgentGroupName
			,pBranch
			,pBranchName
			,pBranchGroup
			,pBranchGroupName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,pRate
			,cCurrHOMarginOld
			,pCurrHOMarginOld
			,cCurrAgentMarginOld
			,pCurrAgentMarginOld
			,cCurrAgentOfferOld
			,pCurrAgentOfferOld
			,cCurrCustomerOfferOld
			,pCurrCustomerOfferOld
			,cHOTolMaxOld
			,cHOTolMinOld
			,pHOTolMaxOld
			,pHOTolMinOld
			,cAgentTolMaxOld
			,cAgentTolMinOld
			,pAgentTolMaxOld
			,pAgentTolMinOld
			,hoCrossRateOld
			,agentCrossRateOld
			,crossRateOld
			,crossRateFactorOld
			,effectiveFromDateOld
			,effectiveFromTimeOld
			,effectiveToDateOld
			,effectiveToTimeOld
			,cCurrHOMarginNew
			,pCurrHOMarginNew
			,cCurrAgentMarginNew
			,pCurrAgentMarginNew
			,cCurrAgentOfferNew
			,pCurrAgentOfferNew
			,cCurrCustomerOfferNew
			,pCurrCustomerOfferNew
			,cHOTolMaxNew
			,cHOTolMinNew
			,pHOTolMaxNew
			,pHOTolMinNew
			,cAgentTolMaxNew
			,cAgentTolMinNew
			,pAgentTolMaxNew
			,pAgentTolMinNew
			,hoCrossRateNew
			,agentCrossRateNew
			,crossRateNew
			,crossRateFactorNew
			,effectiveFromDateNew
			,effectiveFromTimeNew
			,effectiveToDateNew
			,effectiveToTimeNew
			,modType
			,modifiedBy
			,hasChanged
			'
		--PRINT @table	
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
				
	END
	
	IF @flag IN ('i', 'u')
	BEGIN
		DECLARE 
				@cDefExRateId INT, @pDefExRateId INT,
				@HoTolCMax FLOAT, @HoTolCMin FLOAT, @HoTolPMax FLOAT, @HoTolPMin FLOAT, 
				@AgentTolCMax FLOAT, @AgentTolCMin FLOAT, @AgentTolPMax FLOAT, @AgentTolPMin FLOAT, @errorMsg VARCHAR(200)
		
		IF @flag = 'u'
		BEGIN
			SELECT 
				 @cCurrency		= cCurrency
				,@cRate			= cRate
				,@cRateFactor	= cRateFactor
				,@pCurrency		= pCurrency
				,@pRate			= pRate
				,@pRateFactor	= pRateFactor
				,@tranType = tranType 
			FROM spExRate WITH(NOLOCK) WHERE spExRateId = @spExRateId
		END
		SELECT @cDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @cCurrency AND tranType = @tranType
		IF @cDefExRateId IS NULL
			SELECT @cDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @cCurrency AND tranType IS NULL
		
		SELECT @pDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @pCurrency AND tranType = @tranType
		IF @pDefExRateId IS NULL
			SELECT @pDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @pCurrency AND tranType IS NULL
		
		SELECT 
			 @HoTolCMax = ISNULL(cMax, 0)
			,@HoTolCMin = ISNULL(cMin, 0)
		FROM defExRate WHERE defExRateId = @cDefExRateId
		
		SELECT
			 @HoTolPMax = ISNULL(pMax, 0)
			,@HoTolPMin = ISNULL(pMin, 0)
		FROM defExRate WHERE defExRateId = @pDefExRateId
		
		IF(@cAgentTolMax > @cHOTolMax)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Max Tolerance in Collection Rate exceeds HO Max Tolerance', NULL
			RETURN
		END
		IF(@cAgentTolMin < @cHOTolMin)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Min Tolerance in Collection Rate exceeds HO Min Tolerance', NULL
			RETURN
		END
		IF(@cCurrAgentMargin > @cHOTolMax)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Margin in Collection Rate exceeds HO Max Tolerance', NULL
			RETURN
		END
		IF(@cCurrAgentMargin < @cHOTolMin)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Margin in Collection Rate exceeds HO Min Tolerance', NULL
			RETURN
		END
		IF(ISNULL(@cRateFactor, '') = 'M')
		BEGIN
			IF((@cRate + @cCurrHOMargin) > @HoTolCMax)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Collection Rate Offer exceeds Max Rate', NULL
				RETURN
			END
			IF((@cRate + @cCurrHoMargin) < @HoTolCMin)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Collection Rate Offer exceeds Min Rate', NULL
				RETURN
			END
			IF((@cRate + @cHOTolMax) > @HoTolCMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Collection Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@cRate + @cHOTolMax) < @HoTolCMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Collection Rate) exceeds Min Rate', NULL
				RETURN
			END
			IF((@cRate + @cHOTolMin) > @HoTolCMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Collection Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@cRate + @cHOTolMin) < @HoTolCMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Collection Rate) exceeds Min Rate', NULL
				RETURN
			END
		END
		ELSE IF(ISNULL(@cRateFactor, '') = 'D')
		BEGIN
			IF((@cRate - @cCurrHOMargin) > @HoTolCMax)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Collection Rate Offer exceeds Max Rate', NULL
				RETURN
			END
			IF((@cRate - @cCurrHoMargin) < @HoTolCMin)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Collection Rate Offer exceeds Min Rate', NULL
				RETURN
			END	
			IF((@cRate - @cHOTolMax) > @HoTolCMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Collection Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@cRate - @cHOTolMax) < @HoTolCMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Collection Rate) exceeds Min Rate', NULL
				RETURN
			END
			IF((@cRate - @cHOTolMin) > @HoTolCMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Collection Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@cRate - @cHOTolMin) < @HoTolCMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Collection Rate) exceeds Min Rate', NULL
				RETURN
			END
		END
		IF(@pAgentTolMax > @pHOTolMax)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Max Tolerance in Payment Rate exceeds HO Max Tolerance', NULL
			RETURN
		END
		IF(@pAgentTolMin < @pHOTolMin)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Min Tolerance in Payment Rate exceeds HO Min Tolerance', NULL
			RETURN
		END
		IF(@pCurrAgentMargin > @pHOTolMax)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Margin in Payment Rate exceeds HO Max Tolerance', NULL
			RETURN
		END
		IF(@pCurrAgentMargin < @pHOTolMin)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Margin in Payment Rate exceeds HO Min Tolerance', NULL
			RETURN
		END
		IF(ISNULL(@pRateFactor, '') = 'M')
		BEGIN
			IF((@pRate - @pCurrHOMargin) > @HoTolPMax)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Payment Rate Offer exceeds Max Rate', NULL
				RETURN
			END
			IF((@pRate - @pCurrHOMargin) < @HoTolPMin)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Payment Rate Offer exceeds Min Rate', NULL
				RETURN
			END
			IF((@pRate - @pHOTolMax) > @HoTolPMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Payment Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@pRate - @pHOTolMax) < @HoTolPMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Payment Rate) exceeds Min Rate', NULL
				RETURN
			END
			IF((@pRate - @pHOTolMin) > @HoTolPMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Payment Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@pRate - @pHOTolMin) < @HoTolPMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Payment Rate) exceeds Min Rate', NULL
				RETURN
			END
		END
		ELSE IF(ISNULL(@pRateFactor, '') = 'D')
		BEGIN
			IF((@pRate + @pCurrHOMargin) > @HoTolPMax)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Payment Rate Offer exceeds Max Rate', NULL
				RETURN
			END
			IF((@pRate + @pCurrHOMargin) < @HoTolPMin)
			BEGIN
				EXEC proc_errorHandler 1, 'Agent Payment Rate Offer exceeds Min Rate', NULL
				RETURN
			END	
			IF((@pRate + @pHOTolMax) > @HoTolPMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Payment Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@pRate + @pHOTolMax) < @HoTolPMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Max Tolerance(Payment Rate) exceeds Min Rate', NULL
				RETURN
			END
			IF((@pRate + @pHOTolMin) > @HoTolPMax)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Payment Rate) exceeds Max Rate', NULL
				RETURN
			END
			IF((@pRate + @pHOTolMin) < @HoTolPMin)
			BEGIN
				EXEC proc_errorHandler 1, 'HO Min Tolerance(Payment Rate) exceeds Min Rate', NULL
				RETURN
			END
		END
	END
		
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM spExRate WHERE 
						ISNULL(tranType, 0) = ISNULL(@tranType, 0) 
					AND cCountry = @cCountry 
					AND pCountry = @pCountry
					AND ISNULL(cAgent, 0) = ISNULL(@cAgent, 0)
					AND ISNULL(cAgentGroup, 0) = ISNULL(@cAgentGroup, 0)
					AND ISNULL(cBranch, 0) = ISNULL(@cBranch, 0)
					AND ISNULL(cBranchGroup, 0) = ISNULL(@cBranchGroup, 0)
					AND ISNULL(pAgent, 0) = ISNULL(@pAgent, 0)
					AND ISNULL(pAgentGroup, 0) = ISNULL(@pAgentGroup, 0)
					AND ISNULL(pBranch, 0) = ISNULL(@pBranch, 0)
					AND ISNULL(pBranchGroup, 0) = ISNULL(@pBranchGroup, 0)
				)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO spExRate (
				 tranType
				,cCountry
				,cAgent
				,cAgentGroup
				,cBranch
				,cBranchGroup
				,pCountry
				,pAgent
				,pAgentGroup
				,pBranch
				,pBranchGroup
				,cCurrency
				,pCurrency
				,cRateFactor
				,pRateFactor
				,cRate
				,pRate
				,cCurrHOMargin
				,pCurrHOMargin
				,cCurrAgentMargin
				,pCurrAgentMargin
				,cHOTolMax
				,cHOTolMin
				,pHOTolMax
				,pHOTolMin
				,cAgentTolMax
				,cAgentTolMin
				,pAgentTolMax
				,pAgentTolMin
				,crossRate
				,crossRateFactor
				,effectiveFrom
				,effectiveTo
				,createdBy
				,createdDate
			)
			SELECT
				 @tranType
				,@cCountry
				,@cAgent
				,@cAgentGroup
				,@cBranch
				,@cBranchGroup
				,@pCountry
				,@pAgent
				,@pAgentGroup
				,@pBranch
				,@pBranchGroup
				,@cCurrency
				,@pCurrency
				,@cRateFactor
				,@pRateFactor
				,@cRate
				,@pRate
				,ISNULL(@cCurrHOMargin, 0)
				,ISNULL(@pCurrHOMargin, 0)
				,ISNULL(@cCurrAgentMargin, 0)
				,ISNULL(@pCurrAgentMargin, 0)
				,ISNULL(@cHOTolMax, 0)
				,ISNULL(@cHOTolMin, 0)
				,ISNULL(@pHOTolMax, 0)
				,ISNULL(@pHOTolMin, 0)
				,ISNULL(@cAgentTolMax, 0)
				,ISNULL(@cAgentTolMin, 0)
				,ISNULL(@pAgentTolMax, 0)
				,ISNULL(@pAgentTolMin, 0)
				,@crossRate
				,@crossRateFactor
				,@effectiveFrom
				,@effectiveTo
				,@user
				,GETDATE()
				
				
			SET @spExRateId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @spExRateId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM spExRateHistory WITH(NOLOCK)
				WHERE spExRateId = @spExRateId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM spExRateHistory mode WITH(NOLOCK)
			INNER JOIN spExRate main WITH(NOLOCK) ON mode.spExRateId = main.spExRateId
			WHERE mode.spExRateId= @spExRateId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM spExRate WITH(NOLOCK) WHERE spExRateId = @spExRateId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM spExRate WITH(NOLOCK)
			WHERE spExRateId = @spExRateId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @spExRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM spExRateHistory WITH(NOLOCK)
			WHERE spExRateId  = @spExRateId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @spExRateId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM spExRate WHERE approvedBy IS NULL AND spExRateId  = @spExRateId)			
			BEGIN				
				UPDATE spExRate SET
					 cCurrHOMargin		= ISNULL(@cCurrHOMargin, 0)
					,pCurrHOMargin		= ISNULL(@pCurrHOMargin, 0)
					,cCurrAgentMargin	= ISNULL(@cCurrAgentMargin, 0)
					,pCurrAgentMargin	= ISNULL(@pCurrAgentMargin, 0)
					,cHOTolMax			= ISNULL(@cHOTolMax, 0)
					,cHOTolMin			= ISNULL(@cHOTolMin, 0)
					,pHOTolMax			= ISNULL(@pHOTolMax, 0)
					,pHOTolMin			= ISNULL(@pHOTolMin, 0)
					,cAgentTolMax		= ISNULL(@cAgentTolMax, 0)
					,cAgentTolMin		= ISNULL(@cAgentTolMin, 0)
					,pAgentTolMax		= ISNULL(@pAgentTolMax, 0)
					,pAgentTolMin		= ISNULL(@pAgentTolMin, 0)
					,effectiveFrom		= @effectiveFrom
					,effectiveTo		= @effectiveTo
					,crossRate			= @crossRate
					,crossRateFactor	= @crossRateFactor
					,modifiedBy			= @user
					,modifiedDate		= GETDATE()					
				WHERE spExRateId = @spExRateId			
			END
			ELSE
			BEGIN
				DELETE FROM spExRateHistory WHERE spExRateId = @spExRateId AND approvedBy IS NULL
				INSERT INTO spExRateHistory(						
					 spExRateId 
					,tranType
					,cCountry
					,cAgent
					,cAgentGroup
					,cBranch
					,cBranchGroup
					,pCountry
					,pAgent
					,pAgentGroup
					,pBranch
					,pBranchGroup
					,cCurrency
					,pCurrency
					,cRateFactor
					,pRateFactor
					,cRate
					,pRate
					,cCurrHOMargin
					,pCurrHOMargin
					,cCurrAgentMargin
					,pCurrAgentMargin
					,cHOTolMax
					,cHOTolMin
					,pHOTolMax
					,pHOTolMin
					,cAgentTolMax
					,cAgentTolMin
					,pAgentTolMax
					,pAgentTolMin
					,crossRate
					,crossRateFactor
					,effectiveFrom
					,effectiveTo
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @spExRateId
					,main.tranType
					,main.cCountry
					,main.cAgent
					,main.cAgentGroup
					,main.cBranch
					,main.cBranchGroup
					,main.pCountry
					,main.pAgent
					,main.pAgentGroup
					,main.pBranch
					,main.pBranchGroup
					,main.cCurrency
					,main.pCurrency
					,main.cRateFactor
					,main.pRateFactor
					,main.cRate
					,main.pRate
					,@cCurrHOMargin
					,@pCurrHOMargin
					,@cCurrAgentMargin
					,@pCurrAgentMargin
					,@cHOTolMax
					,@cHOTolMin
					,@pHOTolMax
					,@pHOTolMin
					,@cAgentTolMax
					,@cAgentTolMin
					,@pAgentTolMax
					,@pAgentTolMin
					,@crossRate
					,@crossRateFactor
					,@effectiveFrom
					,@effectiveTo
					,@user
					,GETDATE()
					,'U'
				FROM spExRate main WITH(NOLOCK) WHERE spExRateId = @spExRateId

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @spExRateId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM spExRate WITH(NOLOCK)
			WHERE spExRateId = @spExRateId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @spExRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM spExRateHistory  WITH(NOLOCK)
			WHERE spExRateId = @spExRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @spExRateId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM spExRate WITH(NOLOCK) WHERE spExRateId = @spExRateId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM spExRate WHERE spExRateId = @spExRateId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @spExRateId
			RETURN
		END
			INSERT INTO spExRateHistory(
				 spExRateId 
				,tranType
				,cCountry
				,cAgent
				,cAgentGroup
				,cBranch
				,cBranchGroup
				,pCountry
				,pAgent
				,pAgentGroup
				,pBranch
				,pBranchGroup
				,cCurrency
				,pCurrency
				,cRateFactor
				,pRateFactor
				,cRate
				,pRate
				,cCurrHOMargin
				,pCurrHOMargin
				,cCurrAgentMargin
				,pCurrAgentMargin
				,cHOTolMax
				,cHOTolMin
				,pHOTolMax
				,pHOTolMin
				,cAgentTolMax
				,cAgentTolMin
				,pAgentTolMax
				,pAgentTolMin
				,crossRate
				,crossRateFactor
				,effectiveFrom
				,effectiveTo
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 spExRateId 
				,tranType
				,cCountry
				,cAgent
				,cAgentGroup
				,cBranch
				,cBranchGroup
				,pCountry
				,pAgent
				,pAgentGroup
				,pBranch
				,pBranchGroup
				,cCurrency
				,pCurrency
				,cRateFactor
				,pRateFactor
				,cRate
				,pRate
				,cCurrHOMargin
				,pCurrHOMargin
				,cCurrAgentMargin
				,pCurrAgentMargin
				,cHOTolMax
				,cHOTolMin
				,pHOTolMax
				,pHOTolMin
				,cAgentTolMax
				,cAgentTolMin
				,pAgentTolMax
				,pAgentTolMin
				,crossRate
				,crossRateFactor
				,effectiveFrom
				,effectiveTo			
				,@user
				,GETDATE()
				,'D'
			FROM spExRate WHERE spExRateId = @spExRateId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @spExRateId
	END

	ELSE IF @flag IN('reject')
	BEGIN
		IF(ISNULL(@spExRateIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to reject', NULL
			RETURN
		END
		BEGIN TRANSACTION
			SET @sql = 'SELECT spExRateId FROM spExRate WITH(NOLOCK) WHERE spExRateId IN (' + @spExRateIds + ')'
			INSERT @rateIdList
			EXEC (@sql)
			WHILE EXISTS(SELECT 'X' FROM @rateIdList)
			BEGIN
				SELECT TOP 1 @spExRateId = spExRateId FROM @rateIdList
				IF EXISTS (SELECT 'X' FROM spExRate WHERE approvedBy IS NULL AND spExRateId = @spExRateId)
				BEGIN --New record			
						SET @modType = 'Reject'
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @spExRateId, @oldValue OUTPUT
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @spExRateId, @user, @oldValue, @newValue
										
						IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
						BEGIN
							IF @@TRANCOUNT > 0
							ROLLBACK TRANSACTION
							EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @spExRateId
							RETURN
						END
					DELETE FROM spExRate WHERE spExRateId =  @spExRateId
				END
				ELSE
				BEGIN
						SET @modType = 'Reject'
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @spExRateId, @oldValue OUTPUT
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @spExRateId, @user, @oldValue, @newValue
						IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
						BEGIN
							IF @@TRANCOUNT > 0
							ROLLBACK TRANSACTION
							EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @spExRateId
							RETURN
						END
						DELETE FROM spExRateHistory WHERE spExRateId = @spExRateId AND approvedBy IS NULL
					
				END	
				
				DELETE FROM @rateIdList WHERE spExRateId = @spExRateId
			END	
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @spExRateId
	END

	ELSE IF @flag  IN ('approve')
	BEGIN
		IF(ISNULL(@spExRateIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to approve', NULL
			RETURN
		END
		BEGIN TRANSACTION
			SET @sql = 'SELECT spExRateId FROM spExRate WITH(NOLOCK) WHERE spExRateId IN (' + @spExRateIds + ')'
			INSERT @rateIdList
			EXEC (@sql)
			WHILE EXISTS(SELECT 'X' FROM @rateIdList)
			BEGIN
				SELECT TOP 1 @spExRateId = spExRateId FROM @rateIdList
				IF EXISTS (SELECT 'X' FROM spExRate WHERE approvedBy IS NULL AND spExRateId = @spExRateId)
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM spExRateHistory WHERE spExRateId = @spExRateId AND approvedBy IS NULL
				IF @modType = 'I'
				BEGIN --New record
					UPDATE spExRate SET
						isActive = 'Y'
						,approvedBy = @user
						,approvedDate= GETDATE()
					WHERE spExRateId = @spExRateId
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @spExRateId, @newValue OUTPUT
				END
				ELSE IF @modType = 'U'
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @spExRateId, @oldValue OUTPUT
					UPDATE main SET
						 main.cCurrHOMargin		= mode.cCurrHOMargin
						,main.pCurrHOMargin		= mode.pCurrHOMargin
						,main.cCurrAgentMargin	= mode.cCurrAgentMargin
						,main.pCurrAgentMargin	= mode.pCurrAgentMargin
						,main.cHOTolMax			= mode.cHOTolMax
						,main.cHOTolMin			= mode.cHOTolMin
						,main.pHOTolMax			= mode.pHOTolMax
						,main.pHOTolMin			= mode.pHOTolMin
						,main.cAgentTolMax		= mode.cAgentTolMax
						,main.cAgentTolMin		= mode.cAgentTolMin
						,main.pAgentTolMax		= mode.pAgentTolMax
						,main.pAgentTolMin		= mode.pAgentTolMin
						,main.effectiveFrom		= mode.effectiveFrom
						,main.effectiveTo		= mode.effectiveTo
						,main.crossRate			= mode.crossRate
						,main.crossRateFactor	= mode.crossRateFactor
						,main.modifiedBy		= @user
						,main.modifiedDate		= GETDATE()
					FROM spExRate main
					INNER JOIN spExRateHistory mode ON mode.spExRateId = main.spExRateId
					WHERE mode.spExRateId = @spExRateId AND mode.approvedBy IS NULL

					EXEC [dbo].proc_GetColumnToRow  'spExRate', 'spExRateId', @spExRateId, @newValue OUTPUT
				END
				ELSE IF @modType = 'D'
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @spExRateId, @oldValue OUTPUT
					UPDATE spExRate SET
						 isActive		= 'N'
						,modifiedDate	= GETDATE()
						,modifiedBy		= @user					
					WHERE spExRateId = @spExRateId
				END
				
				UPDATE spExRateHistory SET
					 approvedBy = @user
					,approvedDate = GETDATE()
				WHERE spExRateId = @spExRateId AND approvedBy IS NULL
				
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @spExRateId, @user, @oldValue, @newValue
				
				DELETE FROM @rateIdList WHERE spExRateId = @spExRateId
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @spExRateId
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @spExRateId
END CATCH


GO
