USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_exRateOperation]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_exRateOperation]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_exRateOperation
GO
*/
/*
	proc_spExRate @flag = 's', @user = 'admin', @sortBy = 'exRateOpId', @sortOrder = 'ASC', @pageSize = '10', @pageNumber = '1'
*/
CREATE proc [dbo].[proc_exRateOperation]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@exRateTreasuryId					VARCHAR(30)		= NULL
	,@exRateTreasuryIds					VARCHAR(MAX)	= NULL
	,@exRateBranchWiseId				VARCHAR(30)		= NULL
	,@exRateBranchWiseIds				VARCHAR(MAX)	= NULL
	,@tranType							INT				= NULL
	,@cCurrency							VARCHAR(3)		= NULL
	,@cCountry                          INT				= NULL
	,@cAgent							INT				= NULL
	,@cBranch							INT				= NULL
	,@cRateFactor						CHAR(1)			= NULL
	,@cRate								FLOAT			= NULL
	,@cMargin							FLOAT			= NULL
	,@pCurrency							VARCHAR(3)		= NULL
	,@pCountry							INT				= NULL
	,@pAgent							INT				= NULL
	,@pRateFactor						CHAR(1)			= NULL
	,@pRate								FLOAT			= NULL
	,@pMargin							FLOAT			= NULL
	,@crossRate							FLOAT			= NULL
	,@tolerance							FLOAT			= NULL
	,@premium							FLOAT			= NULL
	,@customerRate						FLOAT			= NULL
	,@margin							FLOAT			= NULL
	,@crossRateFactor					CHAR(1)			= NULL
	,@hasChanged                        CHAR(1)			= NULL
	,@currency							VARCHAR(3)		= NULL
	,@country							INT				= NULL
	,@agent								INT				= NULL
	,@rateType							CHAR(1)			= NULL
	,@cCountryName						VARCHAR(100)	= NULL
	,@cAgentName						VARCHAR(100)	= NULL
	,@pCountryName						VARCHAR(100)	= NULL
	,@pAgentName						VARCHAR(100)	= NULL
	,@isUpdated							CHAR(1)			= NULL
	,@isActive							CHAR(1)			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@xml								XML				= NULL

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE @msg VARCHAR(100)
	CREATE TABLE #exRateBranchWiseIdTemp(exRateBranchWiseId INT)
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
	
	DECLARE @rateIdList TABLE(rowId INT IDENTITY(1,1), exRateOpId INT)	
	SELECT
		 @logIdentifier = 'exRateOpId'
		,@logParamMain = 'exRateOperation'
		,@logParamMod = 'exRateOperationHistory'
		,@module = '20'
		,@tableAlias = 'Exchange Rate Operation'
		,@ApprovedFunctionId = 20111830
	
	CREATE TABLE #exRateIdTemp(exRateTreasuryId INT)
	DECLARE @cDefExRateId INT, @pDefExRateId INT, @errorMsg VARCHAR(200)
	DECLARE @cOffer FLOAT, @pOffer FLOAT
	DECLARE @hasRight CHAR(1) 
	
	IF @flag = 'cr'			--Load Cost Rate according to Currency
	BEGIN
		DECLARE @defExRateId INT
		SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @agent AND country = @country AND currency = @currency
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent IS NULL AND country = @country AND currency = @currency
		
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
	
	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cCountryName,cAgentName,pCountryName,pAgentName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'pCountryName,pAgentName,cCountryName,cAgentName'
		
		SET @sortOrder = ''	
		
		--SELECT * FROM exRateTreasury WITH(NOLOCK)
		DECLARE @m VARCHAR(MAX)
		--SELECT * FROM exRateOperation
		SET @m = '(
					SELECT
						 exRateOpId = main.exRateTreasuryId
						,tranType = main.tranType
						,cCurrency = main.cCurrency
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,cRateFactor = main.cRateFactor
						,pCurrency = main.pCurrency
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,pRateFactor = main.pRateFactor
						,cRate = main.cRate
						,pRate = main.pRate
						,cMargin = main.cMargin
						,cHoMargin = main.cHoMargin
						,pMargin = main.pMargin
						,pHoMargin = main.pHoMargin
						,crossRate = main.crossRateOperation
						,crossRateNew = main.customerRate
						,tolerance = main.toleranceOperation
						,toleranceNew = main.tolerance
						,premium = main.premium
						,premiumNew = main.premium
						,customerRate = main.crossRateOperation + main.premium
						,customerRateNew = main.customerRate + main.premium
						,margin = main.toleranceOperation - main.premium
						,marginNew = main.tolerance - main.premium
						,isUpdated = main.isUpdatedOperation
						,isActive = main.isActive	
						,lastModifiedBy = ISNULL(modifiedByOperation, createdBy)
						,lastModifiedDate = ISNULL(modifiedDateOperation, createdDate)	
						,main.createdBy
						,main.createdDate
						,modifiedBy = ISNULL(main.modifiedBy, main.createdBy)
						,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
						,hasChanged = main.isUpdatedOperation
						,modType = CASE WHEN main.crossRateOperation IS NULL THEN ''I'' ELSE ''U'' END
						,hasBranchWiseRate = CASE WHEN (
												SELECT TOP 1 exRateBranchWiseId FROM exRateBranchWise WITH(NOLOCK) WHERE exRateTreasuryId = main.exRateTreasuryId AND ISNULL(isActive, ''N'') = ''Y''
												) IS NULL THEN ''N'' ELSE ''Y'' END
					FROM exRateTreasury main WITH(NOLOCK)
					WHERE cCountry = 133 AND cAgent = ' + dbo.FNAGetIMEAgentId() + ' AND approvedBy IS NOT NULL
					AND ISNULL(main.isActive, ''N'') = ''Y''
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateOpId
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCurrency	
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.cRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0.0)
							,cHoMargin = ISNULL(main.cHoMargin, 0.0)
							,main.pCurrency
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.pRateFactor
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0.0)
							,pHoMargin = ISNULL(main.pHoMargin, 0.0)
							,main.crossRate
							,main.crossRateNew
							,main.tolerance
							,main.toleranceNew
							,main.premium
							,main.premiumNew
							,main.customerRate
							,main.customerRateNew
							,main.margin
							,main.marginNew
							,main.isUpdated	
							,cMin = crm.cMin
							,cMax = crm.cMax
							,pMin = prm.pMin
							,pMax = prm.pMax		
							,cRateMaskMulBd = CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulBd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivBd END
							,cRateMaskMulAd = CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulAd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivAd END
							,pRateMaskMulBd = CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulBd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivBd END
							,pRateMaskMulAd = CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulAd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivAd END
							,crossRateMaskAd = dbo.FNAGetCrossRateDecimalMask(main.cCurrency, main.pCurrency)
							,lastModifiedBy
							,lastModifiedDate
							,main.modifiedBy
							,main.hasChanged
							,main.modType
							,main.hasBranchWiseRate	
						FROM ' + @m + ' main
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						LEFT JOIN rateMask prm WITH(NOLOCK) ON main.pCurrency = prm.currency AND ISNULL(prm.isActive, ''N'') = ''Y''
						WHERE 1 = 1
						
						'
							
		SET @table =  @table + ') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isUpdated = ''' + @isUpdated + ''''
				
		SET @select_field_list = '
			 exRateOpId
			,tranType
			,cCurrency		
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cRateFactor
			,cRate
			,cMargin
			,cHoMargin
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,pCurrency
			,pRateFactor
			,pRate
			,pMargin
			,pHoMargin
			,crossRate
			,crossRateNew
			,tolerance
			,toleranceNew
			,premium
			,premiumNew
			,customerRate
			,customerRateNew
			,margin
			,marginNew
			,isUpdated
			,modType
			,cMin
			,cMax
			,pMin
			,pMax
			,cRateMaskMulBd
			,cRateMaskMulAd
			,pRateMaskMulBd
			,pRateMaskMulAd
			,crossRateMaskAd
			,lastModifiedBy
			,lastModifiedDate
			,modifiedBy
			,hasChanged
			,hasBranchWiseRate
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
		RETURN	
	END
	
	IF @flag = 'ms'						--Modify Summary
	BEGIN
		INSERT INTO #exRateIdTemp
		SELECT value FROM dbo.Split(',', @exRateTreasuryIds)
		
		SELECT
			 exRateOpId = main.exRateTreasuryId
			,tranType = ISNULL(tt.typeTitle, 'All')
			,cCountry = main.cCountry
			,cCountryName = cc.countryName
			,cCountryCode = cc.countryCode
			,cAgent = main.cAgent
			,cAgentName = ISNULL(cam.agentName, '[All]')
			,pCountry = main.pCountry
			,pCountryName = pc.countryName
			,pCountryCode = pc.countryCode
			,pAgent = main.pAgent
			,pAgentName = ISNULL(pam.agentName, '[All]')
			,cCurrency = main.cCurrency
			,pCurrency = main.pCurrency
			,cRateFactor = main.cRateFactor
			,pRateFactor = main.pRateFactor
			,cRate = main.cRate
			,cMargin = main.cMargin
			,cHoMargin = main.cHoMargin
			,cAgentMargin = main.cAgentMargin
			,pRate = main.pRate
			,pMargin = main.pMargin
			,pHoMargin = main.pHoMargin
			,pAgentMargin = main.pAgentMargin
			,crossRate = main.crossRate
			,tolerance = main.tolerance
			,premium = main.premium
			,customerRate = main.crossRate + main.premium
			,margin = main.tolerance - main.premium
							
			,[status] = CASE WHEN ISNULL(main.isActive, 'N') = 'Y' THEN 'Active' ELSE 'Inactive' END
			
			,modType = CASE WHEN main.approvedBy IS NULL THEN 'Insert' ELSE 'Update' END		
			,modifiedBy = ISNULL(main.modifiedBy,main.createdBy)
			,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
		FROM exRateTreasury main WITH(NOLOCK)
		INNER JOIN #exRateIdTemp erit ON main.exRateTreasuryId = erit.exRateTreasuryId
		LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
		LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
		LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
		LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
		LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
		ORDER BY cCountryName, cAgentName, pCountryName, pAgentName
	END
	
	ELSE IF @flag IN ('m')				--Approve List
	BEGIN
		SET @hasRight = dbo.FNAHasRight(@user, CAST(@ApprovedFunctionId AS VARCHAR))
		IF @sortBy IS NULL
			SET @sortBy = 'exRateOpId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'	
		   
		SET @m = '(
					SELECT
						 exRateOpId = main.exRateOpId
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,cCurrency = main.cCurrency
						,pCurrency = main.pCurrency
						,cRateFactor = main.cRateFactor
						,pRateFactor = main.pRateFactor
						,cRate = main.cRate
						,cMargin = main.cMargin
						,pRate = main.pRate
						,pMargin = main.pMargin
						
						,maxCrossRateOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.maxCrossRate END
						,crossRateOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.crossRate END
						,toleranceOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.tolerance END
						,costOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cost END
						,marginOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.margin END
						
						,maxCrossRateNew = CASE WHEN main.approvedBy IS NULL THEN main.maxCrossRate ELSE mode.maxCrossRate END
						,crossRateNew = CASE WHEN main.approvedBy IS NULL THEN main.crossRate ELSE mode.crossRate END
						,toleranceNew = CASE WHEN main.approvedBy IS NULL THEN main.tolerance ELSE mode.tolerance END
						,costNew = CASE WHEN main.approvedBy IS NULL THEN main.tolerance ELSE mode.cost END
						,marginNew = CASE WHEN main.approvedBy IS NULL THEN main.margin ELSE mode.margin END
						
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.approvedBy END		
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.exRateOpId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM exRateOperation main WITH(NOLOCK)
					LEFT JOIN exRateOperationHistory mode WITH(NOLOCK) ON main.exRateOpId = mode.exRateOpId AND mode.approvedBy IS NULL				
						AND (
								mode.createdBy = ''' + @user + '''
								OR ''Y'' = ''' + @hasRight + '''
							)
					
					WHERE  (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' + @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateOpId	
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''All'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''All'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,main.pRate
							,main.cMargin
							,main.pMargin
							,main.maxCrossRateOld
							,main.crossRateOld
							,main.toleranceOld
							,main.costOld
							,main.marginOld
							,main.maxCrossRateNew
							,main.crossRateNew
							,main.toleranceNew
							,main.costNew
							,main.marginNew
							,modType = CASE WHEN main.modType = ''I'' THEN ''Insert'' WHEN main.modType = ''U'' THEN ''Update'' END
							,main.modifiedBy
							,main.hasChanged	
						FROM ' + @m + ' main
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
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
				
		SET @select_field_list = '
			 exRateOpId		
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,pRate
			,cMargin
			,pMargin
			,maxCrossRateOld
			,crossRateOld
			,toleranceOld
			,costOld
			,marginOld
			,maxCrossRateNew
			,crossRateNew
			,toleranceOld
			,costNew
			,marginNew
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
		
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			IF ISNULL(@isUpdated, 'N') = 'N'
			BEGIN
				UPDATE exRateTreasury SET
					 premium				= @premium
					,modifiedByOperation	= @user
					,modifiedDateOperation	= GETDATE()
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			ELSE
			BEGIN
				UPDATE ero SET
					 ero.premium				= @premium
					,ero.toleranceOperation		= ero.tolerance
					,ero.crossRateOperation		= ero.customerRate
					,isUpdatedOperation			= 'N'
					,ero.modifiedByOperation	= @user
					,ero.modifiedDateOperation	= GETDATE()
				FROM exRateTreasury ero
				WHERE ero.exRateTreasuryId = @exRateTreasuryId
			END
			
			INSERT INTO exRateTreasuryHistory(
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingValue,sharingType,pSharingValue,pSharingType
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,tranType
				,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
				,premium,crossRateFactor
				,modType,modFor
				,createdBy,createdDate,approvedBy,approvedDate
			)
			SELECT
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingValue,sharingType,pSharingValue,pSharingType
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,tranType
				,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
				,premium,crossRateFactor
				,'U','O'		--T - Treasury, O - Operation
				,@user,GETDATE(),@user,GETDATE()
			FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
					
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag = 'uxml'				--Bulk Update XML
	BEGIN
		DECLARE @exRateList TABLE(id INT IDENTITY(1,1),exRateOpId INT, premium FLOAT, isUpdated CHAR(1), errorCode VARCHAR(10), msg VARCHAR(300))
		INSERT @exRateList(exRateOpId, premium, isUpdated, errorCode)
		SELECT
			 exRateOpId			= p.value('@exRateOpId','INT')
			,premium			= p.value('@premium','FLOAT')		
			,isUpdated			= p.value('@isUpdated','CHAR(1)')
			,errorCode			= '0'
		FROM @xml.nodes('/root/row') AS tmp(p)
		
		BEGIN TRANSACTION
			IF EXISTS(SELECT TOP 1 'X' FROM exRateTreasury ert WITH(NOLOCK) INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateOpId
						WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'N')
			BEGIN
				UPDATE exRateTreasury SET
					 premium				= list.premium
					,modifiedByOperation	= @user
					,modifiedDateOperation	= GETDATE()
				FROM exRateTreasury ert
				INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateOpId
				WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'N'
			END
			
			IF EXISTS(SELECT TOP 1 'X' FROM exRateTreasury ert WITH(NOLOCK) INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateOpId
						WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'Y')
			BEGIN
				UPDATE ero SET
					 ero.premium				= list.premium
					,ero.toleranceOperation		= ero.tolerance
					,ero.crossRateOperation		= ero.customerRate
					,isUpdatedOperation			= 'N'
					,ero.modifiedByOperation	= @user
					,ero.modifiedDateOperation	= GETDATE()
				FROM exRateTreasury ero
				INNER JOIN @exRateList list ON ero.exRateTreasuryId = list.exRateOpId
				WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'Y'
			END
			
			INSERT INTO exRateTreasuryHistory(
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingValue,sharingType,pSharingValue,pSharingType
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,tranType
				,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
				,premium,crossRateFactor
				,modType,modFor
				,createdBy,createdDate,approvedBy,approvedDate
			)
			SELECT
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingValue,sharingType,pSharingValue,pSharingType
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,tranType
				,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
				,ert.premium,crossRateFactor
				,'U','O'		--T - Treasury, O - Operation
				,@user,GETDATE(),@user,GETDATE()
			FROM exRateTreasury ert WITH(NOLOCK)
			INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateOpId
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SELECT @exRateTreasuryIds = COALESCE(ISNULL(@exRateTreasuryIds + ',', ''), '') + CAST(exRateOpId AS VARCHAR) FROM @exRateList WHERE errorCode = '0'
		SELECT @exRateTreasuryIds
		RETURN
	END
	
	ELSE IF @flag = 'ufm'				--Bulk Update From Master Record
	BEGIN
		IF(ISNULL(@exRateTreasuryIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to update', NULL
			RETURN
		END
		SET @sql = '
					UPDATE ero SET
						 ero.toleranceOperation = tolerance
						,ero.crossRateOperation = customerRate
						,ero.isUpdatedOperation = ''N''
						,ero.modifiedBy = ''' + @user + '''
						,ero.modifiedDate = GETDATE()
					FROM exRateTreasury ero
					WHERE ero.exRateTreasuryId IN (' + @exRateTreasuryIds + ')
					'
		EXEC (@sql)
		
		SET @sql = '
					INSERT INTO exRateTreasuryHistory(
						 exRateTreasuryId
						,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingValue,sharingType,pSharingValue,pSharingType
						,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,tranType
						,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
						,premium,crossRateFactor
						,modType,modFor
						,createdBy,createdDate,approvedBy,approvedDate
					)
					SELECT
						 exRateTreasuryId
						,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingValue,sharingType,pSharingValue,pSharingType
						,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,tranType
						,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
						,premium,crossRateFactor
						,''U'',''O''
						,''' + @user + ''',GETDATE(),''' + @user + ''',GETDATE()
					FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId IN (' + @exRateTreasuryIds + ')
					'
		EXEC (@sql)
		
		EXEC proc_errorHandler 0, 'Rate updated successfully', NULL
	END
	
	ELSE IF @flag = 'ib'				--Insert Branchwise Premium
	BEGIN
		IF EXISTS(SELECT 'X' FROM exRateBranchWise WITH(NOLOCK) WHERE cBranch = @cBranch AND exRateTreasuryId = @exRateTreasuryId)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END 

		SELECT @tolerance = toleranceOperation, @crossRate = crossRateOperation FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
		
		IF @crossRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please update rate before adding branch wise rate', NULL
			RETURN
		END
		
		IF @premium > @tolerance
		BEGIN
			EXEC proc_errorHandler 1, 'Premium exceeded max tolerance', NULL
			RETURN
		END
		SET @customerRate = ROUND(@crossRate + @premium, 8)
		BEGIN TRANSACTION
			--SELECT * FROM exRateBranchWise
			--SELECT * FROM exRateOperation
			INSERT INTO exRateBranchWise(
				 exRateTreasuryId
				,cBranch
				,premium
				,isActive
				,createdBy
				,createdDate
			)
			SELECT
				 @exRateTreasuryId
				,@cBranch
				,@premium
				,'Y'
				,@user
				,GETDATE()
		
			SET @exRateTreasuryId = SCOPE_IDENTITY()
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully', NULL
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		DECLARE @crossRateDecimalMask INT
		SELECT @crossRateDecimalMask = dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency) FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
		SELECT 
			 main.*
			,cMin = crm.cMin
			,cMax = crm.cMax
			,pMin = prm.pMin
			,pMax = prm.pMax
			,crossRateMaskAd = @crossRateDecimalMask
			,cCountryName	= ISNULL(ccm.countryName, 'All')
			,cCountryCode	= ISNULL(ccm.countryCode, '')
			,cAgentName		= ISNULL(cam.agentName, 'All')
			,pCountryName	= ISNULL(pcm.countryName, 'All')
			,pCountryCode	= ISNULL(pcm.countryCode, '')
			,pAgentName		= ISNULL(pam.agentName, 'All')
			,tranTypeName	= ISNULL(tt.typeTitle, 'All')
		FROM exRateTreasury main WITH(NOLOCK)
		INNER JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency
		INNER JOIN rateMask prm WITH(NOLOCK) ON main.pCurrency = prm.currency
		LEFT JOIN countryMaster ccm WITH(NOLOCK) ON main.cCountry = ccm.countryId
		LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
		LEFT JOIN countryMaster pcm WITH(NOLOCK) ON main.pCountry = pcm.countryId
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId 
		LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
		WHERE exRateTreasuryId = @exRateTreasuryId
	END
	
	ELSE IF @flag = 'sb'				--Branchwise Rate List
	BEGIN
		--IF @sortBy IS NULL
			SET @sortBy = 'cBranchName'
		--IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'	
		
		--SELECT * FROM exRateOperation
		SET @m = '(
					SELECT
						 exRateBranchWiseId = erbw.exRateBranchWiseId
						,tranType = main.tranType
						,cCurrency = main.cCurrency
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,cBranch = erbw.cBranch
						,cRateFactor = main.cRateFactor
						,cRate = main.cRate
						,cMargin = main.cMargin
						,pCurrency = main.pCurrency
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,pRateFactor = main.pRateFactor
						,pRate = main.pRate
						,pMargin = main.pMargin
						,crossRate = main.crossRateOperation
						,tolerance = main.toleranceOperation
						,premium = erbw.premium
						,customerRate = ROUND(main.crossRateOperation + erbw.premium, 10)
						,margin = ROUND(main.toleranceOperation - erbw.premium, 10)
						,isActive = main.isActive		
						,erbw.createdBy
						,erbw.createdDate
						,modifiedBy = ISNULL(erbw.modifiedBy, erbw.createdBy)
						,modifiedDate = ISNULL(erbw.modifiedDate, erbw.createdDate)
					FROM exRateTreasury main WITH(NOLOCK)
					INNER JOIN exRateBranchWise erbw WITH(NOLOCK) ON main.exRateTreasuryId = erbw.exRateTreasuryId 
					AND ISNULL(erbw.isActive, ''N'') = ''' + @isActive + '''
					WHERE erbw.exRateTreasuryId = ' + CAST(@exRateTreasuryId AS VARCHAR) + '
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateBranchWiseId
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCurrency	
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''All'')
							,main.cBranch
							,cBranchName = ISNULL(cbm.agentName, ''All'')
							,main.cRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0.0)
							,main.pCurrency
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''All'')
							,main.pRateFactor
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0.0)
							,main.crossRate
							,main.tolerance
							,main.premium
							,main.customerRate
							,main.margin
							,crm.cMin
							,crm.cMax
							,prm.pMin
							,prm.pMax	
							,cRateMaskMulBd = CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulBd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivBd END
							,cRateMaskMulAd = CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulAd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivAd END
							,pRateMaskMulBd = CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulBd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivBd END
							,pRateMaskMulAd = CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulAd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivAd END
							,crossRateMaskAd = dbo.FNAGetCrossRateDecimalMask(main.cCurrency, main.pCurrency)
							,main.modifiedBy
							,main.modifiedDate
						FROM ' + @m + ' main
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN agentMaster cbm WITH(NOLOCK) ON main.cBranch = cbm.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						LEFT JOIN rateMask prm WITH(NOLOCK) ON main.pCurrency = prm.currency AND ISNULL(prm.isActive, ''N'') = ''Y''
						WHERE 1 = 1
						'
							
		SET @table =  @table + ') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''

		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))

		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
			
		SET @select_field_list = '
			 exRateBranchWiseId
			,tranType
			,cCurrency		
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranch
			,cBranchName
			,cRateFactor
			,cRate
			,cMargin
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,pCurrency
			,pRateFactor
			,pRate
			,pMargin
			,crossRate
			,tolerance
			,premium
			,customerRate
			,margin
			,cMin
			,cMax
			,pMin
			,pMax
			,cRateMaskMulBd
			,cRateMaskMulAd
			,pRateMaskMulBd
			,pRateMaskMulAd
			,crossRateMaskAd
			,modifiedBy
			,modifiedDate
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
	
	ELSE IF @flag = 'ub'				--Update Branchwise Rate
	BEGIN
		IF(ISNULL(@exRateBranchWiseId, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to update', NULL
			RETURN
		END
		
		SELECT @tolerance = toleranceOperation, @crossRate = crossRateOperation FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = (SELECT exRateTreasuryId FROM exRateBranchwise WHERE exRateBranchwiseId = @exRateBranchWiseId)
		
		IF @premium > @tolerance
		BEGIN
			EXEC proc_errorHandler 1, 'Premium exceeded max tolerance', NULL
			RETURN
		END
		
		SET @customerRate = ROUND(@crossRate + @premium, 8)
		BEGIN TRANSACTION
			UPDATE exRateBranchWise SET
				 premium = @premium
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE exRateBranchWiseId = @exRateBranchWiseId
			
			INSERT INTO exRateBranchWiseHistory(
				 exRateBranchWiseId
				,exRateTreasuryId
				,cBranch
				,premium
				,modType
				,createdBy
				,createdDate
			)
			SELECT
				 exRateBranchWiseId
				,exRateTreasuryId
				,cBranch
				,@premium
				,'U'
				,@user
				,GETDATE()
			FROM exRateBranchWise WITH(NOLOCK) 
			WHERE exRateBranchWiseId = @exRateBranchWiseId
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been updated successfully', NULL
	END
	
	ELSE IF @flag = 'ucb'				--Update Checked Branchwise Rate
	BEGIN
		IF(ISNULL(@exRateBranchWiseIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to update', NULL
			RETURN
		END
		
		IF @customerRate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Please define new customer rate to update', NULL
			RETURN
		END
		
		CREATE TABLE #exRateBranchWiseIds(exRateBranchWiseId INT)
		INSERT INTO #exRateBranchWiseIds
		SELECT value FROM dbo.Split(',', @exRateBranchWiseIds)
		
		SELECT @tolerance = toleranceOperation, @crossRate = crossRateOperation FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = (SELECT exRateTreasuryId FROM exRateBranchwise WHERE exRateBranchwiseId = (SELECT TOP 1 exRateBranchWiseId FROM #exRateBranchWiseIds))
		
		SET @premium = ROUND(@customerRate - @crossRate, 8)
		IF @premium > @tolerance
		BEGIN
			EXEC proc_errorHandler 1, 'Premium exceeded max tolerance', NULL
			RETURN
		END
		
		--SELECT @crossRate, @premium, @customerRate
		--RETURN
		--SELECT @premium, @tolerance, @crossRate, @customerRate
		--RETURN
		BEGIN TRANSACTION
			UPDATE exRateBranchWise SET
				 premium = @premium
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			FROM exRateBranchWise erbw
			INNER JOIN #exRateBranchWiseIds t ON erbw.exRateBranchWiseId = t.exRateBranchWiseId
			
			INSERT INTO exRateBranchWiseHistory(
				 exRateBranchWiseId
				,exRateTreasuryId
				,cBranch
				,premium
				,modType
				,createdBy
				,createdDate
			)
			SELECT
				 erbw.exRateBranchWiseId
				,exRateTreasuryId
				,cBranch
				,@premium
				,'U'
				,@user
				,GETDATE()
			FROM exRateBranchWise erbw WITH(NOLOCK)
			INNER JOIN #exRateBranchWiseIds t ON erbw.exRateBranchWiseId = t.exRateBranchWiseId
				
		
		--EXEC (@sql)
		--PRINT @sql
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Rate updated successfully', NULL
	END
	
	ELSE IF @flag = 'ubxml'				--Update Branchwise Rate XML
	BEGIN
		BEGIN TRANSACTION
			--1. Update Main Record----------------------------------------------------------------------------------------------
			IF ISNULL(@isUpdated, 'N') = 'N'
			BEGIN
				UPDATE exRateTreasury SET
					 premium				= @premium
					,modifiedByOperation	= @user
					,modifiedDateOperation	= GETDATE()
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			ELSE
			BEGIN
				UPDATE ero SET
					 ero.premium				= @premium
					,ero.toleranceOperation		= ero.tolerance
					,ero.crossRateOperation		= ero.customerRate
					,isUpdatedOperation			= 'N'
					,ero.modifiedByOperation	= @user
					,ero.modifiedDateOperation	= GETDATE()
				FROM exRateTreasury ero
				WHERE ero.exRateTreasuryId = @exRateTreasuryId
			END
			
			INSERT INTO exRateTreasuryHistory(
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingValue,sharingType,pSharingValue,pSharingType
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,tranType
				,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
				,premium,crossRateFactor
				,modType,modFor
				,createdBy,createdDate,approvedBy,approvedDate
			)
			SELECT
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingValue,sharingType,pSharingValue,pSharingType
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,tranType
				,crossRate,crossRateOperation,maxCrossRate,customerRate,tolerance,toleranceOperation
				,premium,crossRateFactor
				,'U','O'		--T - Treasury, O - Operation
				,@user,GETDATE(),@user,GETDATE()
			FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
			---------------------------------------------------------------------------------------------------------------------
			
			SELECT @crossRate = crossRateOperation FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
			DECLARE @exRateBranchWiseList TABLE(id INT IDENTITY(1,1),exRateBranchWiseId INT, customerRate FLOAT, errorCode VARCHAR(10), msg VARCHAR(300))
			INSERT @exRateBranchWiseList(exRateBranchWiseId, customerRate, errorCode)
			SELECT
				 exRateBranchWiseId	= p.value('@exRateBranchWiseId','INT')
				,customerRate		= p.value('@customerRate','FLOAT')		
				,errorCode			= '0'
			FROM @xml.nodes('/root/row') AS tmp(p)
			
			--2. Update Branch Wise Rate-----------------------------------------------------------------------------------------
			IF EXISTS(SELECT TOP 1 'X' FROM @exRateBranchWiseList)
			BEGIN
				INSERT INTO exRateBranchWiseHistory(
					 exRateBranchWiseId
					,exRateTreasuryId
					,cBranch
					,premium
					,modType
					,createdBy
					,createdDate
				)
				SELECT
					 erbw.exRateBranchWiseId
					,exRateTreasuryId
					,cBranch
					,ROUND(t.customerRate - @crossRate, 10)
					,'U'
					,@user
					,GETDATE()
				FROM exRateBranchWise erbw WITH(NOLOCK)
				INNER JOIN @exRateBranchWiseList t ON erbw.exRateBranchWiseId = t.exRateBranchWiseId 
				WHERE premium <> ROUND(t.customerRate - @crossRate, 10)
				
				UPDATE exRateBranchWise SET
					 premium		= ROUND(t.customerRate - @crossRate, 10)
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()
				FROM exRateBranchWise erbw
				INNER JOIN @exRateBranchWiseList t ON erbw.exRateBranchWiseId = t.exRateBranchWiseId
			END
			----------------------------------------------------------------------------------------------------------------------
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag = 'ai'				--Set Active Inactive
	BEGIN
		INSERT INTO #exRateBranchWiseIdTemp
		SELECT value FROM dbo.Split(',', @exRateBranchWiseIds)
		
		BEGIN TRANSACTION
			--1. Set Active/Inactive to unapproved main table record
			UPDATE exRateBranchWise SET
				 isActive			= @isActive
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			FROM exRateBranchWise erbw
			INNER JOIN #exRateBranchWiseIdTemp t ON erbw.exRateBranchWiseId = t.exRateBranchWiseId
			
			INSERT INTO exRateBranchWiseHistory(
				 exRateBranchWiseId,exRateTreasuryId,cBranch,premium,isActive
				,modType,createdBy,createdDate
			)
			SELECT 
				 erbw.exRateBranchWiseId, erbw.exRateTreasuryId, cBranch, premium, isActive
				,'U', @user, GETDATE()
			FROM exRateBranchWise erbw
			INNER JOIN #exRateBranchWiseIdTemp t ON erbw.exRateBranchWiseId = t.exRateBranchWiseId
					
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		IF @isActive = 'Y'
			SET @msg = 'Record(s) set active'
		ELSE
			SET @msg = 'Record(s) set inactive'
		EXEC proc_errorHandler 0, @msg, @exRateBranchWiseIds		
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @exRateTreasuryId
END CATCH

GO
