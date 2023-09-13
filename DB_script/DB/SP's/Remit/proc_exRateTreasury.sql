

ALTER PROC [dbo].[proc_exRateTreasury]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@exRateTreasuryId					VARCHAR(30)		= NULL
	,@exRateTreasuryIds					VARCHAR(MAX)	= NULL
	,@defExRateId						INT				= NULL
	,@tranType							INT				= NULL
	,@cRateId							INT				= NULL
	,@pRateId							INT				= NULL
	,@cCountry                          INT				= NULL
	,@cAgent							INT				= NULL
	,@pCountry							INT				= NULL
	,@pAgent							INT				= NULL
	,@cCurrency							VARCHAR(3)		= NULL
	,@pCurrency							VARCHAR(3)		= NULL
	,@cRateFactor						CHAR(1)			= NULL
	,@pRateFactor						CHAR(1)			= NULL
	,@cRate								FLOAT			= NULL
	,@pRate								FLOAT			= NULL
	,@cMargin							FLOAT			= NULL
	,@cHoMargin							FLOAT			= NULL
	,@cAgentMargin						FLOAT			= NULL
	,@pMargin							FLOAT			= NULL
	,@pHoMargin							FLOAT			= NULL
	,@pAgentMargin						FLOAT			= NULL
	,@sharingType						CHAR(1)			= NULL
	,@sharingValue						MONEY			= NULL
	,@toleranceOn						CHAR(1)			= NULL
	,@agentTolMin						FLOAT			= NULL
	,@agentTolMax						FLOAT			= NULL
	,@customerTolMin					FLOAT			= NULL
	,@customerTolMax					FLOAT			= NULL
	,@maxCrossRate						FLOAT			= NULL
	,@crossRate							FLOAT			= NULL
	,@agentCrossRateMargin				FLOAT			= NULL
	,@customerRate						FLOAT			= NULL
	,@tolerance							FLOAT			= NULL
	,@crossRateFactor					CHAR(1)			= NULL
	,@hasChanged                        CHAR(1)			= NULL
	,@currency							VARCHAR(3)		= NULL
	,@country							INT				= NULL
	,@agent								INT				= NULL
	,@rateType							CHAR(1)			= NULL
	,@cBranch							INT				= NULL
	,@cCountryName						VARCHAR(100)	= NULL
	,@cAgentName						VARCHAR(100)	= NULL
	,@pCountryName						VARCHAR(100)	= NULL
	,@pAgentName						VARCHAR(100)	= NULL
	,@isActive							CHAR(1)			= NULL
	,@isUpdated							CHAR(1)			= NULL
	,@applyFor							CHAR(1)			= NULL
	,@applyAgent						INT				= NULL
	,@xml								XML				= NULL
	,@filterByPCountryOnly				CHAR(1)			= NULL
	,@sortBy                            VARCHAR(100)	= NULL
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
	
	CREATE TABLE #exRateIdTemp(exRateTreasuryId INT)
	
	DECLARE @exRateHistoryId BIGINT, @date DATETIME = GETDATE()
	DECLARE @rateIdList TABLE(rowId INT IDENTITY(1,1), exRateTreasuryId INT)	
	DECLARE @crossRateDecimalMask INT, @colMaskAd INT
	SELECT
		 @logIdentifier = 'exRateTreasuryId'
		,@logParamMain = 'exRateTreasury'
		,@logParamMod = 'exRateTreasuryHistory'
		,@module = '20'
		,@tableAlias = 'Treasury Exchange Rate'
		,@ApprovedFunctionId = 20111330
	
	DECLARE @hasRight CHAR(1) 
	DECLARE @exRateMsg VARCHAR(MAX)
	DECLARE @cDefExRateId INT, @pDefExRateId INT, @errorMsg VARCHAR(200)
	DECLARE @cOffer FLOAT, @pOffer FLOAT, @cCustomerOffer FLOAT, @pCustomerOffer FLOAT
	
	IF @flag = 'cr'						--Load Cost Rate according to Currency
	BEGIN
		SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @agent AND country = @country AND currency = @currency
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent IS NULL AND country = @country AND currency = @currency
		
		IF @rateType = 'C'
		BEGIN
			SELECT 
				 costRate = cRate
				,margin = cMargin
				,factor
				,factorName = CASE WHEN factor = 'M' THEN 'Multiplication' WHEN factor = 'D' THEN 'Division' END
			FROM defExRate WITH(NOLOCK) 
			WHERE defExRateId = @defExRateId	
		END
		ELSE IF @rateType = 'P'
		BEGIN
			SELECT 
				 costRate = pRate
				,margin = pMargin
				,factor
				,factorName = CASE WHEN factor = 'M' THEN 'Multiplication' WHEN factor = 'D' THEN 'Division' END
			FROM defExRate WITH(NOLOCK) 
			WHERE defExRateId = @defExRateId	
		END
	END
	
	ELSE IF @flag = 'crdm'				--Cross Rate Decimal Mask
	BEGIN
		SELECT dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency)
	END
	
	ELSE IF @flag IN ('s')				--Load Grid Exchange Rate Treasury
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cCountryName,cAgentName,pCountryName,pAgentName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'pCountryName,pAgentName,cCountryName,cAgentName'
		SET @sortOrder = ''		
		
		DECLARE @m VARCHAR(MAX)
		SET @m = '(
					SELECT
						 exRateTreasuryId = main.exRateTreasuryId
						,cRateId = main.cRateId
						,cRateIdNew = mode.cRateId
						,pRateId = main.pRateId
						,pRateIdNew = mode.pRateId
						,tranType = main.tranType
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,cCurrency = main.cCurrency
						,pCurrency = main.pCurrency
						,cRateFactor = main.cRateFactor
						,pRateFactor = main.pRateFactor
						,cRate = main.cRate
						,cRateNew = mode.cRate
						,cMargin = main.cMargin
						,cMarginNew = mode.cMargin
						,cHoMargin = main.cHoMargin
						,cHoMarginNew = mode.cHoMargin
						,cAgentMargin = main.cAgentMargin
						,cAgentMarginNew = mode.cAgentMargin
						,pRate = main.pRate
						,pRateNew = mode.pRate
						,pMargin = main.pMargin
						,pMarginNew = mode.pMargin
						,pHoMargin = main.pHoMargin
						,pHoMarginNew = mode.pHoMargin
						,pAgentMargin = main.pAgentMargin
						,pAgentMarginNew = mode.pAgentMargin
						,sharingType = main.sharingType
						,sharingTypeNew = mode.sharingType
						,sharingValue = main.sharingValue
						,sharingValueNew = mode.sharingValue
						,toleranceOn = main.toleranceOn
						,toleranceOnNew = mode.toleranceOn
						,agentTolMin = main.agentTolMin
						,agentTolMinNew = mode.agentTolMin
						,agentTolMax = main.agentTolMax
						,agentTolMaxNew = mode.agentTolMax
						,customerTolMin = main.customerTolMin
						,customerTolMinNew = mode.customerTolMin
						,customerTolMax = main.customerTolMax
						,customerTolMaxNew = mode.customerTolMax
						,maxCrossRate = main.maxCrossRate
						,maxCrossRateNew = mode.maxCrossRate
						,crossRate = main.crossRate
						,crossRateNew = mode.crossRate
						,agentCrossRateMargin = main.agentCrossRateMargin
						,agentCrossRateMarginNew = mode.agentCrossRateMargin
						,customerRate = main.customerRate
						,customerRateNew = mode.customerRate
						,tolerance = main.tolerance
						,toleranceNew = mode.tolerance
						,crossRateFactor = main.crossRateFactor	
						,isActive = ISNULL(main.isActive, ''N'')
						,isActiveNew = ISNULL(mode.isActive, ''N'')
						,lastModifiedBy = ISNULL(main.modifiedBy, main.createdBy)
						,lastModifiedDate = ISNULL(main.modifiedDate, main.createdDate)
						,main.isUpdated		
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.exRateTreasuryId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.modType END
						,crossRateDecimalMask = dbo.FNAGetCrossRateDecimalMask(main.cCurrency, main.pCurrency)
					FROM exRateTreasury main WITH(NOLOCK)
					LEFT JOIN exRateTreasuryMod mode WITH(NOLOCK) ON main.exRateTreasuryId = mode.exRateTreasuryId
					WHERE  (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + '''
							)
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,main.cRateId
							,main.cRateIdNew
							,main.pRateId
							,main.pRateIdNew
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,cAgent = ISNULL(main.cAgent, 0)
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,pAgent = ISNULL(main.pAgent, 0)
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cRateNew
							,cMargin = ISNULL(main.cMargin, 0)
							,cMarginNew = ISNULL(main.cMarginNew, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cHoMarginNew = ISNULL(cHoMarginNew, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,cAgentMarginNew = ISNULL(cAgentMarginNew, 0)
							,main.pRate
							,pRateNew
							,pMargin = ISNULL(main.pMargin, 0)
							,pMarginNew = ISNULL(main.pMarginNew, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pHoMarginNew = ISNULL(main.pHoMarginNew, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,pAgentMarginNew = ISNULL(main.pAgentMarginNew, 0)
							,sharingType
							,sharingTypeNew
							,sharingValue = ISNULL(main.sharingValue, 0)
							,sharingValueNew = ISNULL(main.sharingValueNew, 0)
							,toleranceOn
							,toleranceOnNew
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMinNew = ISNULL(main.agentTolMinNew, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,agentTolMaxNew = ISNULL(main.agentTolMaxNew, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMinNew = ISNULL(main.customerTolMinNew, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,customerTolMaxNew = ISNULL(main.customerTolMaxNew, 0)
							,main.maxCrossRate
							,maxCrossRateNew
							,main.crossRate
							,crossRateNew
							,main.agentCrossRateMargin
							,main.agentCrossRateMarginNew
							,main.customerRate
							,main.customerRateNew
							,main.tolerance
							,toleranceNew
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,costNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)
							,marginNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)) - cRateNew, crm.rateMaskMulAd)			
							,main.crossRateFactor
							,status = CASE WHEN main.isActive = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,statusNew = CASE WHEN main.isActiveNew = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,main.isUpdated
							,cRateMaskMulBd = ISNULL(CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulBd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivBd END, 6)
							,cRateMaskMulAd = ISNULL(CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulAd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivAd END, 6)
							,cMin = ISNULL(crm.cMin, 0)
							,cMax = ISNULL(crm.cMax, 0)
							,pRateMaskMulBd = ISNULL(CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulBd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivBd END, 6)
							,pRateMaskMulAd = ISNULL(CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulAd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivAd END, 6)
							,pMin = ISNULL(prm.pMin, 0)
							,pMax = ISNULL(prm.pMax, 0)
							,crossRateMaskAd = dbo.FNAGetCrossRateDecimalMask(main.cCurrency, main.pCurrency)
							,main.lastModifiedBy
							,main.lastModifiedDate
							,main.modifiedBy
							,main.hasChanged
							,main.isActive
							,main.modType	
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

		IF @defExRateId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (cRateId = ' + CAST(@defExRateId AS VARCHAR) + ' OR pRateId = ' + CAST(@defExRateId AS VARCHAR) + ')'
		
		IF @cRateId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (cRateId = ' + CAST(@cRateId AS VARCHAR) + ')'
		
		IF @pRateId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (pRateId = ' + CAST(@pRateId AS VARCHAR) + ')'
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged + ''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
		IF @isActive IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isActive, ''N'') = ''' + @isActive + ''''
		
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
		BEGIN
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
			IF ISNULL(@filterByPCountryOnly, 'N') = 'Y'
				SET @sql_filter = @sql_filter + ' AND pAgent = 0'
		END
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
		
		--PRINT(@sql_filter)	
		SET @select_field_list = '
			 exRateTreasuryId
			,cRateId
			,cRateIdNew
			,pRateId
			,pRateIdNew
			,tranType			
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
			,cRateNew
			,cMargin
			,cMarginNew
			,cHoMargin
			,cHoMarginNew
			,cAgentMargin
			,cAgentMarginNew
			,pRate
			,pRateNew
			,pMargin
			,pMarginNew
			,pHoMargin
			,pHoMarginNew
			,pAgentMargin
			,pAgentMarginNew
			,sharingType
			,sharingTypeNew
			,sharingValue
			,sharingValueNew
			,toleranceOn
			,toleranceOnNew
			,agentTolMin
			,agentTolMinNew
			,agentTolMax
			,agentTolMaxNew
			,customerTolMin
			,customerTolMinNew
			,customerTolMax
			,customerTolMaxNew
			,maxCrossRate
			,maxCrossRateNew
			,crossRate
			,crossRateNew
			,agentCrossRateMargin
			,agentCrossRateMarginNew
			,customerRate
			,customerRateNew
			,tolerance
			,toleranceNew
			,cost
			,costNew
			,margin
			,marginNew
			,crossRateFactor
			,status
			,statusNew
			,isUpdated
			,cRateMaskMulBd
			,cRateMaskMulAd
			,cMin
			,cMax
			,pRateMaskMulBd
			,pRateMaskMulAd
			,pMin
			,pMax
			,crossRateMaskAd
			,lastModifiedBy
			,lastModifiedDate
			,modifiedBy
			,hasChanged
			,modType
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
	
	ELSE IF @flag IN ('s2')				--Load Grid After Cost Change	
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cCountryName,cAgentName,pCountryName,pAgentName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'pCountryName,pAgentName,cCountryName,cAgentName'
		SET @sortOrder = ''		
		
		SET @m = '(
					SELECT
						 exRateTreasuryId = main.exRateTreasuryId
						,cRateId = main.cRateId
						,cRateIdNew = mode.cRateId
						,pRateId = main.pRateId
						,pRateIdNew = mode.pRateId
						,tranType = main.tranType
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,cCurrency = main.cCurrency
						,pCurrency = main.pCurrency
						,cRateFactor = main.cRateFactor
						,pRateFactor = main.pRateFactor
						,cRate = main.cRate
						,cRateNew = mode.cRate
						,cMargin = main.cMargin
						,cMarginNew = mode.cMargin
						,cHoMargin = main.cHoMargin
						,cHoMarginNew = mode.cHoMargin
						,cAgentMargin = main.cAgentMargin
						,cAgentMarginNew = mode.cAgentMargin
						,pRate = main.pRate
						,pRateNew = mode.pRate
						,pMargin = main.pMargin
						,pMarginNew = mode.pMargin
						,pHoMargin = main.pHoMargin
						,pHoMarginNew = mode.pHoMargin
						,pAgentMargin = main.pAgentMargin
						,pAgentMarginNew = mode.pAgentMargin
						,sharingType = main.sharingType
						,sharingTypeNew = mode.sharingType
						,sharingValue = main.sharingValue
						,sharingValueNew = mode.sharingValue
						,toleranceOn = main.toleranceOn
						,toleranceOnNew = mode.toleranceOn
						,agentTolMin = main.agentTolMin
						,agentTolMinNew = mode.agentTolMin
						,agentTolMax = main.agentTolMax
						,agentTolMaxNew = mode.agentTolMax
						,customerTolMin = main.customerTolMin
						,customerTolMinNew = mode.customerTolMin
						,customerTolMax = main.customerTolMax
						,customerTolMaxNew = mode.customerTolMax
						,maxCrossRate = main.maxCrossRate
						,maxCrossRateNew = mode.maxCrossRate
						,crossRate = main.crossRate
						,crossRateNew = mode.crossRate
						,agentCrossRateMargin = main.agentCrossRateMargin
						,agentCrossRateMarginNew = mode.agentCrossRateMargin
						,customerRate = main.customerRate
						,customerRateNew = mode.customerRate
						,tolerance = main.tolerance
						,toleranceNew = mode.tolerance
						,crossRateFactor = main.crossRateFactor	
						,isActive = ISNULL(main.isActive, ''N'')
						,isActiveNew = ISNULL(mode.isActive, ''N'')
						,main.isUpdated		
						,main.createdBy
						,main.createdDate
						,lastModifiedBy = ISNULL(main.modifiedBy, main.createdBy)
						,lastModifiedDate = ISNULL(main.modifiedDate, main.createdDate)
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.exRateTreasuryId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.modType END
						,crossRateDecimalMask = dbo.FNAGetCrossRateDecimalMask(main.cCurrency, main.pCurrency)
					FROM exRateTreasury main WITH(NOLOCK)
					LEFT JOIN exRateTreasuryMod mode WITH(NOLOCK) ON main.exRateTreasuryId = mode.exRateTreasuryId			
					WHERE  (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + '''
							)
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,main.cRateId
							,main.cRateIdNew
							,main.pRateId
							,main.pRateIdNew
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,cAgent = ISNULL(main.cAgent, 0)
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,pAgent = ISNULL(main.pAgent, 0)
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cRateNew
							,cMargin = ISNULL(main.cMargin, 0)
							,cMarginNew = ISNULL(main.cMarginNew, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cHoMarginNew = ISNULL(cHoMarginNew, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,cAgentMarginNew = ISNULL(cAgentMarginNew, 0)
							,main.pRate
							,pRateNew
							,pMargin = ISNULL(main.pMargin, 0)
							,pMarginNew = ISNULL(main.pMarginNew, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pHoMarginNew = ISNULL(main.pHoMarginNew, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,pAgentMarginNew = ISNULL(main.pAgentMarginNew, 0)
							,sharingType
							,sharingTypeNew
							,sharingValue = ISNULL(main.sharingValue, 0)
							,sharingValueNew = ISNULL(main.sharingValueNew, 0)
							,toleranceOn
							,toleranceOnNew
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMinNew = ISNULL(main.agentTolMinNew, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,agentTolMaxNew = ISNULL(main.agentTolMaxNew, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMinNew = ISNULL(main.customerTolMinNew, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,customerTolMaxNew = ISNULL(main.customerTolMaxNew, 0)
							,main.maxCrossRate
							,maxCrossRateNew
							,main.crossRate
							,crossRateNew
							,main.agentCrossRateMargin
							,main.agentCrossRateMarginNew
							,main.customerRate
							,main.customerRateNew
							,main.tolerance
							,toleranceNew
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,costNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)
							,marginNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)) - cRateNew, crm.rateMaskMulAd)			
							,main.crossRateFactor
							,status = CASE WHEN main.isActive = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,statusNew = CASE WHEN main.isActiveNew = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,main.isUpdated
							,cRateMaskMulBd = ISNULL(CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulBd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivBd END, 6)
							,cRateMaskMulAd = ISNULL(CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulAd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivAd END, 6)
							,cMin = ISNULL(crm.cMin, 0)
							,cMax = ISNULL(crm.cMax, 0)
							,pRateMaskMulBd = ISNULL(CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulBd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivBd END, 6)
							,pRateMaskMulAd = ISNULL(CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulAd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivAd END, 6)
							,pMin = ISNULL(prm.pMin, 0)
							,pMax = ISNULL(prm.pMax, 0)
							,crossRateMaskAd = dbo.FNAGetCrossRateDecimalMask(main.cCurrency, main.pCurrency)
							,main.modifiedBy
							,lastModifiedBy
							,lastModifiedDate
							,main.hasChanged
							,main.isActive
							,main.modType	
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

		IF @defExRateId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (cRateId = ' + CAST(@defExRateId AS VARCHAR) + ' OR pRateId = ' + CAST(@defExRateId AS VARCHAR) + ')'
		
		IF @cRateId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (cRateId = ' + CAST(@cRateId AS VARCHAR) + ')'
		
		IF @pRateId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND (pRateId = ' + CAST(@pRateId AS VARCHAR) + ')'
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged + ''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
		IF @isActive IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isActive, ''N'') = ''' + @isActive + ''''
			
		SET @select_field_list = '
			 exRateTreasuryId
			,cRateId
			,cRateIdNew
			,pRateId
			,pRateIdNew
			,tranType			
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
			,cRateNew
			,cMargin
			,cMarginNew
			,cHoMargin
			,cHoMarginNew
			,cAgentMargin
			,cAgentMarginNew
			,pRate
			,pRateNew
			,pMargin
			,pMarginNew
			,pHoMargin
			,pHoMarginNew
			,pAgentMargin
			,pAgentMarginNew
			,sharingType
			,sharingTypeNew
			,sharingValue
			,sharingValueNew
			,toleranceOn
			,toleranceOnNew
			,agentTolMin
			,agentTolMinNew
			,agentTolMax
			,agentTolMaxNew
			,customerTolMin
			,customerTolMinNew
			,customerTolMax
			,customerTolMaxNew
			,maxCrossRate
			,maxCrossRateNew
			,crossRate
			,crossRateNew
			,agentCrossRateMargin
			,agentCrossRateMarginNew
			,customerRate
			,customerRateNew
			,tolerance
			,toleranceNew
			,cost
			,costNew
			,margin
			,marginNew
			,crossRateFactor
			,status
			,statusNew
			,isUpdated
			,cRateMaskMulBd
			,cRateMaskMulAd
			,cMin
			,cMax
			,pRateMaskMulBd
			,pRateMaskMulAd
			,pMin
			,pMax
			,crossRateMaskAd
			,modifiedBy
			,lastModifiedBy
			,lastModifiedDate
			,hasChanged
			,modType
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
	
	ELSE IF @flag IN ('m')				--Approve List
	BEGIN
		--IF @sortBy IS NULL
			SET @sortBy = 'modifiedDate,cCountryName,cAgentName,pCountryName,pAgentName'
		--IF @sortOrder IS NULL
		   SET @sortOrder = ''	
		   
		SET @m = '(
					SELECT
						 exRateTreasuryId = main.exRateTreasuryId
						,tranType = main.tranType
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,cCurrency = main.cCurrency
						,pCurrency = main.pCurrency
						,cRateFactor = main.cRateFactor
						,pRateFactor = main.pRateFactor
						,cRate = main.cRate
						,cRateNew = mode.cRate
						,cMargin = main.cMargin
						,cMarginNew = mode.cMargin
						,cHoMargin = main.cHoMargin
						,cHoMarginNew = mode.cHoMargin
						,cAgentMargin = main.cAgentMargin
						,cAgentMarginNew = mode.cAgentMargin
						,pRate = main.pRate
						,pRateNew = mode.pRate
						,pMargin = main.pMargin
						,pMarginNew = mode.pMargin
						,pHoMargin = ISNULL(main.pHoMargin, 0)
						,pHoMarginNew = ISNULL(mode.pHoMargin, 0)
						,pAgentMargin = main.pAgentMargin
						,pAgentMarginNew = mode.pAgentMargin
						,sharingType = main.sharingType
						,sharingTypeNew = mode.sharingType
						,sharingValue = main.sharingValue
						,sharingValueNew = mode.sharingValue
						,toleranceOn = main.toleranceOn
						,toleranceOnNew = mode.toleranceOn
						,agentTolMin = main.agentTolMin
						,agentTolMinNew = mode.agentTolMin
						,agentTolMax = main.agentTolMax
						,agentTolMaxNew = mode.agentTolMax
						,customerTolMin = main.customerTolMin
						,customerTolMinNew = mode.customerTolMin
						,customerTolMax = main.customerTolMax
						,customerTolMaxNew = mode.customerTolMax
						,maxCrossRate = main.maxCrossRate
						,crossRate = main.crossRate
						,agentCrossRateMargin = main.agentCrossRateMargin
						,customerRate = main.customerRate
						,tolerance = main.tolerance	
						,maxCrossRateNew = mode.maxCrossRate
						,crossRateNew = mode.crossRate
						,agentCrossRateMarginNew = mode.agentCrossRateMargin
						,customerRateNew = mode.customerRate
						,toleranceNew = mode.tolerance
						
						,status = ISNULL(main.isActive, ''N'')
						,statusNew = ISNULL(mode.isActive, ''N'')
						
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.modType END		
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.exRateTreasuryId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM exRateTreasury main WITH(NOLOCK)
					LEFT JOIN exRateTreasuryMod mode WITH(NOLOCK) ON main.exRateTreasuryId = mode.exRateTreasuryId			
					--WHERE  (
					--			main.approvedBy IS NOT NULL 
					--			OR main.createdBy = ''' +  @user + '''
					--		)
							--AND ISNULL(main.isUpdated, ''N'') <> ''Y''
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''All'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,main.cRateNew
							,main.pRate
							,main.pRateNew
							,main.cMargin
							,main.cMarginNew
							,pMargin = main.pMargin
							,main.pMarginNew
							,main.cHoMargin
							,main.cHoMarginNew
							,main.cAgentMargin
							,main.cAgentMarginNew
							,main.pHoMargin
							,pHoMarginNew = ISNULL(main.pHoMarginNew, 0)
							,main.pAgentMargin
							,main.pAgentMarginNew
							
							,main.sharingType
							,main.sharingTypeNew
							,main.sharingValue
							,main.sharingValueNew
							,main.toleranceOn
							,main.toleranceOnNew
							,main.agentTolMin
							,main.agentTolMinNew
							,main.agentTolMax
							,main.agentTolMaxNew
							,main.customerTolMin
							,main.customerTolMinNew
							,main.customerTolMax
							,main.customerTolMaxNew
							
							,main.maxCrossRate
							,main.crossRate
							,main.agentCrossRateMargin
							,main.customerRate
							,main.tolerance
							
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,costNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)
							,marginNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)) - cRateNew, crm.rateMaskMulAd)	
							
							,main.maxCrossRateNew
							,main.crossRateNew
							,main.agentCrossRateMarginNew
							,main.customerRateNew
							,main.toleranceNew
							,status = CASE WHEN main.status = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,statusNew = CASE WHEN main.statusNew = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,modType = CASE WHEN main.modType = ''I'' THEN ''Insert'' WHEN main.modType = ''U'' THEN ''Update'' END
							,main.modifiedBy
							,main.modifiedDate
							,main.hasChanged	
						FROM ' + @m + ' main
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE 1=1 AND hasChanged = ''Y''
						
						'
							
		SET @table =  @table + ') x'
		PRINT @table	
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
			 exRateTreasuryId	
			,tranType	
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
			,cHoMargin
			,cAgentMargin
			,pHoMargin
			,pAgentMargin
			
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			
			,maxCrossRate
			,crossRate
			,agentCrossRateMargin
			,customerRate
			,tolerance
			,cost
			,margin
			,cRateNew
			,pRateNew
			,cMarginNew
			,pMarginNew
			
			,cHoMarginNew
			,cAgentMarginNew
			,pHoMarginNew
			,pAgentMarginNew
			
			,sharingTypeNew
			,sharingValueNew
			,toleranceOnNew
			,agentTolMinNew
			,agentTolMaxNew
			,customerTolMinNew
			,customerTolMaxNew
			
			,maxCrossRateNew
			,crossRateNew
			,agentCrossRateMarginNew
			,customerRateNew
			,toleranceNew
			,costNew
			,marginNew
			,status
			,statusNew
			,modType
			,modifiedBy
			,modifiedDate
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
	
	ELSE IF @flag IN ('rl')				--Reject List
	BEGIN
		--IF @sortBy IS NULL
			SET @sortBy = 'modifiedDate,cCountryName,cAgentName,pCountryName,pAgentName'
		--IF @sortOrder IS NULL
		   SET @sortOrder = ''	
		   
		SET @m = '(
					SELECT
						 exRateTreasuryId = main.exRateTreasuryId
						,tranType = main.tranType
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,cCurrency = main.cCurrency
						,pCurrency = main.pCurrency
						,cRateFactor = main.cRateFactor
						,pRateFactor = main.pRateFactor
						,cRate = main.cRate
						,cRateNew = mode.cRate
						,cMargin = main.cMargin
						,cMarginNew = mode.cMargin
						,cHoMargin = main.cHoMargin
						,cHoMarginNew = mode.cHoMargin
						,cAgentMargin = main.cAgentMargin
						,cAgentMarginNew = mode.cAgentMargin
						,pRate = main.pRate
						,pRateNew = mode.pRate
						,pMargin = main.pMargin
						,pMarginNew = mode.pMargin
						,pHoMargin = main.pHoMargin
						,pHoMarginNew = mode.pHoMargin
						,pAgentMargin = main.pAgentMargin
						,pAgentMarginNew = mode.pAgentMargin
						,sharingType = main.sharingType
						,sharingTypeNew = mode.sharingType
						,sharingValue = main.sharingValue
						,sharingValueNew = mode.sharingValue
						,toleranceOn = main.toleranceOn
						,toleranceOnNew = mode.toleranceOn
						,agentTolMin = main.agentTolMin
						,agentTolMinNew = mode.agentTolMin
						,agentTolMax = main.agentTolMax
						,agentTolMaxNew = mode.agentTolMax
						,customerTolMin = main.customerTolMin
						,customerTolMinNew = mode.customerTolMin
						,customerTolMax = main.customerTolMax
						,customerTolMaxNew = mode.customerTolMax
						,maxCrossRate = main.maxCrossRate
						,crossRate = main.crossRate
						,customerRate = main.customerRate
						,tolerance = main.tolerance	
						,maxCrossRateNew = mode.maxCrossRate
						,crossRateNew = mode.crossRate
						,customerRateNew = mode.customerRate
						,toleranceNew = mode.tolerance
						
						,agentCrossRateMargin = main.agentCrossRateMargin
						,agentCrossRateMarginNew = mode.agentCrossRateMargin
						
						,status = ISNULL(main.isActive, ''N'')
						,statusNew = ISNULL(mode.isActive, ''N'')
						
						,main.isUpdated
						
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.modType END		
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.exRateTreasuryId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM exRateTreasury main WITH(NOLOCK)
					LEFT JOIN exRateTreasuryMod mode WITH(NOLOCK) ON main.exRateTreasuryId = mode.exRateTreasuryId
					WHERE  (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + '''
							)
							--AND ISNULL(main.isUpdated, ''N'') <> ''Y''
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''All'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,main.cRateNew
							,main.pRate
							,main.pRateNew
							,main.cMargin
							,main.cMarginNew
							,main.pMargin
							,main.pMarginNew
							,main.cHoMargin
							,main.cHoMarginNew
							,main.cAgentMargin
							,main.cAgentMarginNew
							,main.pHoMargin
							,main.pHoMarginNew
							,main.pAgentMargin
							,main.pAgentMarginNew
							
							,main.sharingType
							,main.sharingTypeNew
							,main.sharingValue
							,main.sharingValueNew
							,main.toleranceOn
							,main.toleranceOnNew
							,main.agentTolMin
							,main.agentTolMinNew
							,main.agentTolMax
							,main.agentTolMaxNew
							,main.customerTolMin
							,main.customerTolMinNew
							,main.customerTolMax
							,main.customerTolMaxNew
							
							,main.maxCrossRate
							,main.crossRate
							,main.customerRate
							,main.tolerance
							
							,main.agentCrossRateMargin
							,main.agentCrossRateMarginNew
							
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,costNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)
							,marginNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)) - cRateNew, crm.rateMaskMulAd)	
							
							,main.maxCrossRateNew
							,main.crossRateNew
							,main.customerRateNew
							,main.toleranceNew
							,status = CASE WHEN main.status = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,statusNew = CASE WHEN main.statusNew = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,isUpdated
							,modType = CASE WHEN main.modType = ''I'' THEN ''Insert'' WHEN main.modType = ''U'' THEN ''Update'' END
							,main.modifiedBy
							,main.modifiedDate
							,main.hasChanged	
						FROM ' + @m + ' main
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE 1=1 AND hasChanged = ''Y'' AND ISNULL(main.isUpdated, ''N'') = ''N''
						
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
			 exRateTreasuryId	
			,tranType	
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
			,cHoMargin
			,cAgentMargin
			,pHoMargin
			,pAgentMargin
			
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			
			,maxCrossRate
			,crossRate
			,customerRate
			,tolerance
			,cost
			,margin
			,cRateNew
			,pRateNew
			,cMarginNew
			,pMarginNew
			
			,cHoMarginNew
			,cAgentMarginNew
			,pHoMarginNew
			,pAgentMarginNew
			
			,sharingTypeNew
			,sharingValueNew
			,toleranceOnNew
			,agentTolMinNew
			,agentTolMaxNew
			,customerTolMinNew
			,customerTolMaxNew
			
			,maxCrossRateNew
			,crossRateNew
			,customerRateNew
			,toleranceNew
			,agentCrossRateMargin
			,agentCrossRateMarginNew
			,costNew
			,marginNew
			,status
			,statusNew
			,isUpdated
			,modType
			,modifiedBy
			,modifiedDate
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
	
	ELSE IF @flag IN ('mcl')			--My Changes List
	BEGIN
		--IF @sortBy IS NULL
			SET @sortBy = 'cCountryName,cAgentName,pCountryName,pAgentName'
		--IF @sortOrder IS NULL
		   SET @sortOrder = ''	
		   
		SET @m = '(
					SELECT
						 exRateTreasuryId = main.exRateTreasuryId
						,tranType = main.tranType
						,cCountry = main.cCountry
						,cAgent = main.cAgent
						,pCountry = main.pCountry
						,pAgent = main.pAgent
						,cCurrency = main.cCurrency
						,pCurrency = main.pCurrency
						,cRateFactor = main.cRateFactor
						,pRateFactor = main.pRateFactor
						,cRate = main.cRate
						,cRateNew = mode.cRate
						,cMargin = main.cMargin
						,cMarginNew = mode.cMargin
						,cHoMargin = main.cHoMargin
						,cHoMarginNew = mode.cHoMargin
						,cAgentMargin = main.cAgentMargin
						,cAgentMarginNew = mode.cAgentMargin
						,pRate = main.pRate
						,pRateNew = mode.pRate
						,pMargin = main.pMargin
						,pMarginNew = mode.pMargin
						,pHoMargin = main.pHoMargin
						,pHoMarginNew = mode.pHoMargin
						,pAgentMargin = main.pAgentMargin
						,pAgentMarginNew = mode.pAgentMargin
						,sharingType = main.sharingType
						,sharingTypeNew = mode.sharingType
						,sharingValue = main.sharingValue
						,sharingValueNew = mode.sharingValue
						,toleranceOn = main.toleranceOn
						,toleranceOnNew = mode.toleranceOn
						,agentTolMin = main.agentTolMin
						,agentTolMinNew = mode.agentTolMin
						,agentTolMax = main.agentTolMax
						,agentTolMaxNew = mode.agentTolMax
						,customerTolMin = main.customerTolMin
						,customerTolMinNew = mode.customerTolMin
						,customerTolMax = main.customerTolMax
						,customerTolMaxNew = mode.customerTolMax
						,maxCrossRate = main.maxCrossRate
						,crossRate = main.crossRate
						,customerRate = main.customerRate
						,tolerance = main.tolerance	
						,maxCrossRateNew = mode.maxCrossRate
						,crossRateNew = mode.crossRate
						,customerRateNew = mode.customerRate
						,toleranceNew = mode.tolerance
						
						,agentCrossRateMargin = main.agentCrossRateMargin
						,agentCrossRateMarginNew = mode.agentCrossRateMargin
						
						,status = ISNULL(main.isActive, ''N'')
						,statusNew = ISNULL(mode.isActive, ''N'')
						,main.isUpdated
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.modType END		
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN ISNULL(mode.createdBy, main.createdBy) ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN ISNULL(mode.createdDate, main.createdDate) ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.exRateTreasuryId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM exRateTreasury main WITH(NOLOCK)
					LEFT JOIN exRateTreasuryMod mode WITH(NOLOCK) ON main.exRateTreasuryId = mode.exRateTreasuryId			
					WHERE  (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + '''
							)
							--AND ISNULL(main.isUpdated, ''N'') <> ''Y''
				) '
				
					
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,main.cRateNew
							,main.pRate
							,main.pRateNew
							,main.cMargin
							,main.cMarginNew
							,main.pMargin
							,main.pMarginNew
							,main.cHoMargin
							,main.cHoMarginNew
							,main.cAgentMargin
							,main.cAgentMarginNew
							,main.pHoMargin
							,main.pHoMarginNew
							,main.pAgentMargin
							,main.pAgentMarginNew
							
							,main.sharingType
							,main.sharingTypeNew
							,main.sharingValue
							,main.sharingValueNew
							,main.toleranceOn
							,main.toleranceOnNew
							,main.agentTolMin
							,main.agentTolMinNew
							,main.agentTolMax
							,main.agentTolMaxNew
							,main.customerTolMin
							,main.customerTolMinNew
							,main.customerTolMax
							,main.customerTolMaxNew
							
							,main.maxCrossRate
							,main.crossRate
							,main.customerRate
							,main.tolerance
							
							,main.agentCrossRateMargin
							,main.agentCrossRateMarginNew
							
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,costNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)
							,marginNew = ROUND(pRateNew/(crossRateNew + ISNULL(toleranceNew, 0)) - cRateNew, crm.rateMaskMulAd)	
							
							,main.maxCrossRateNew
							,main.crossRateNew
							,main.customerRateNew
							,main.toleranceNew
							,status = CASE WHEN main.status = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,statusNew = CASE WHEN main.statusNew = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,isUpdated = ISNULL(main.isUpdated, ''N'')
							,modType = CASE WHEN main.modType = ''I'' THEN ''Insert'' WHEN main.modType = ''U'' THEN ''Update'' END
							,main.modifiedBy
							,main.modifiedDate
							,main.hasChanged	
						FROM ' + @m + ' main
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE 1=1 AND hasChanged = ''Y'' AND main.modifiedBy = ''' + @user + '''
						
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
			 exRateTreasuryId	
			,tranType	
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
			,cHoMargin
			,cAgentMargin
			,pHoMargin
			,pAgentMargin
			
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			
			,maxCrossRate
			,crossRate
			,customerRate
			,tolerance
			,cost
			,margin
			,cRateNew
			,pRateNew
			,cMarginNew
			,pMarginNew
			
			,cHoMarginNew
			,cAgentMarginNew
			,pHoMarginNew
			,pAgentMarginNew
			
			,sharingTypeNew
			,sharingValueNew
			,toleranceOnNew
			,agentTolMinNew
			,agentTolMaxNew
			,customerTolMinNew
			,customerTolMaxNew
			
			,maxCrossRateNew
			,crossRateNew
			,customerRateNew
			,toleranceNew
			,agentCrossRateMargin
			,agentCrossRateMarginNew
			,costNew
			,marginNew
			,status
			,statusNew
			,isUpdated
			,modType
			,modifiedBy
			,modifiedDate
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
	
	ELSE IF @flag = 'i'
	BEGIN
		IF (dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency) = 10)
		BEGIN
			EXEC proc_errorHandler 1, 'Cross Rate Decimal Mask not defined yet for this setup', NULL
			RETURN
		END
		/*
		IF(@cAgent IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @cAgent AND currency = @cCurrency)
			BEGIN
				EXEC proc_errorHandler 1, 'Sending agent rate has not been defined yet', NULL
				RETURN
			END
		END
		IF(@pAgent IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @pAgent AND currency = @pCurrency)
			BEGIN
				EXEC proc_errorHandler 1, 'Receiving agent rate has not been defined yet', NULL
				RETURN
			END
		END
		*/
		SELECT @cDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @cAgent AND country = @cCountry AND currency = @cCurrency
		IF @cDefExRateId IS NULL
			SELECT @cDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent IS NULL AND country = @cCountry AND currency = @cCurrency
		
		SELECT @pDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @pAgent AND country = @pCountry AND currency = @pCurrency
		IF @pDefExRateId IS NULL
			SELECT @pDefExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent IS NULL AND country = @pCountry AND currency = @pCurrency
		
		SELECT 
			 @cRate = cRate, @cMargin = cMargin, @cRateFactor = factor 
			,@cOffer = CASE factor WHEN 'M' THEN cRate + cMargin + ISNULL(@cHoMargin, 0) WHEN 'D' THEN cRate - cMargin - ISNULL(@cMargin, 0) END
			,@cCustomerOffer = CASE factor WHEN 'M' THEN cRate + cMargin + ISNULL(@cHoMargin, 0) + ISNULL(@cAgentMargin, 0) WHEN 'D' THEN cRate - cMargin - ISNULL(@cHoMargin, 0) - ISNULL(@cAgentMargin, 0) END
		FROM defExRate WITH(NOLOCK) WHERE defExRateId = @cDefExRateId
		
		SELECT 
			 @pRate = pRate, @pMargin = pMargin, @pRateFactor = factor
			,@pOffer = CASE factor WHEN 'M' THEN pRate - pMargin - ISNULL(@pHoMargin, 0) WHEN 'D' THEN pRate + pMargin + ISNULL(@pMargin, 0) END
			,@pCustomerOffer = CASE factor WHEN 'M' THEN pRate - pMargin - ISNULL(@pHoMargin, 0) - ISNULL(@pAgentMargin, 0) WHEN 'D' THEN pRate - pMargin - ISNULL(@pHoMargin, 0) - ISNULL(@pAgentMargin, 0) END
		FROM defExRate WITH(NOLOCK) WHERE defExRateId = @pDefExRateId
		
		DECLARE @tolCMax FLOAT, @tolCMin FLOAT, @tolPMax FLOAT, @tolPMin FLOAT, @msg VARCHAR(300)
		SELECT @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END FROM rateMask WHERE currency = @cCurrency
		SELECT @crossRateDecimalMask = dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency)
		
		SET @crossRate = ROUND(@pOffer/@cOffer, @crossRateDecimalMask)
		SET @maxCrossRate = ROUND(@pRate/@cRate, @crossRateDecimalMask)
		SET @customerRate = ROUND(@pCustomerOffer/@cCustomerOffer, @crossRateDecimalMask)
		
		DECLARE @cost FLOAT, @margin FLOAT
		SET @cost = ROUND(@pRate/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd)
		SET @margin = ROUND(@cost - @cRate, @colMaskAd)
		
		SELECT @tolCMax = cMax, @tolCMin = cMin FROM rateMask WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND currency = @cCurrency
		IF @cost > @tolCMax
		BEGIN
			SET @msg = 'Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @cost < @tolCMin
		BEGIN
			SET @msg = 'Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE 
					cCountry = @cCountry 
					AND ISNULL(cAgent, 0) = ISNULL(@cAgent, 0)
					AND cCurrency = @cCurrency
					AND pCountry = @pCountry
					AND ISNULL(pAgent, 0) = ISNULL(@pAgent, 0)
					AND pCurrency = @pCurrency
					AND ISNULL(tranType, 0) = ISNULL(@tranType, 0)
				)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		
		BEGIN TRANSACTION
			INSERT INTO exRateTreasury(
				 tranType
				,cRateId
				,cCountry
				,cAgent
				,cCurrency
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,cAgentMargin
				,pRateId
				,pCountry
				,pAgent
				,pCurrency
				,pRateFactor
				,pRate
				,pMargin
				,pHoMargin
				,pAgentMargin
				,sharingType
				,sharingValue
				,toleranceOn
				,agentTolMin
				,agentTolMax
				,customerTolMin
				,customerTolMax
				,crossRate
				,maxCrossRate
				,customerRate
				,tolerance
				,crossRateFactor
				,isUpdated
				,isUpdatedOperation
				,isActive
				,createdBy
				,createdDate
			)
			SELECT
				 @tranType
				,@cDefExRateId
				,@cCountry
				,@cAgent
				,@cCurrency
				,@cRateFactor
				,@cRate
				,@cMargin
				,ISNULL(@cHoMargin, 0)
				,ISNULL(@cAgentMargin, 0)
				,@pDefExRateId
				,@pCountry
				,@pAgent
				,@pCurrency
				,@pRateFactor
				,@pRate
				,@pMargin
				,ISNULL(@pHoMargin, 0)
				,ISNULL(@pAgentMargin, 0)
				,ISNULL(@sharingType,'F')
				,ISNULL(@sharingValue, 0)
				,ISNULL(@toleranceOn, 'C')
				,ISNULL(@agentTolMin, 0)
				,ISNULL(@agentTolMax, 0)
				,ISNULL(@customerTolMin, 0)
				,ISNULL(@customerTolMax, 0)
				,@crossRate
				,@maxCrossRate
				,@customerRate
				,@tolerance
				,@crossRateFactor
				,'N'
				,'N'
				,'Y'
				,@user
				,GETDATE()
		
			SET @exRateTreasuryId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId AND (createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @exRateTreasuryId
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId AND ISNULL(createdBy, '') <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @exRateTreasuryId
			RETURN
		END
		
		SELECT 
			 @cRateFactor = cRateFactor
			,@cCurrency = cCurrency, @cRate = cRate, @cMargin = cMargin
			,@pCurrency = pCurrency, @pRate = pRate, @pMargin = pMargin 
		FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
		
		SELECT @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END FROM rateMask WHERE currency = @cCurrency
		SELECT @crossRateDecimalMask = dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency)
		
		SELECT @tolCMax = cMax, @tolCMin = cMin FROM rateMask WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND currency = @cCurrency
		SELECT @tolPMax = pMax, @tolPMin = pMin FROM rateMask WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND currency = @pCurrency
		
		SET @cost = ROUND((@pRate - @pMargin - @pHoMargin - @pAgentMargin)/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd) 
		--SET @cost = ROUND(@pRate/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd)

		IF (@cRate + @cMargin + @cHoMargin) > @tolCMax
		BEGIN
			SET @msg = 'HO Send Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF (@cRate + @cMargin + @cHoMargin) < @tolCMin
		BEGIN
			SET @msg = 'HO Send Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF (@cRate + @cMargin + @cHoMargin + @cAgentMargin) > @tolCMax
		BEGIN
			SET @msg = 'Agent Send Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF (@cRate + @cMargin + @cHoMargin + @cAgentMargin) < @tolCMin
		BEGIN
			SET @msg = 'Agent Send Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF (@pRate - @pMargin - @pHoMargin) > @tolPMax
		BEGIN
			SET @msg = 'HO Receive Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF (@pRate - @pMargin - @pHoMargin) < @tolPMin
		BEGIN
			SET @msg = 'HO Receive Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF (@pRate - @pMargin - @pHoMargin - @pAgentMargin) > @tolPMax
		BEGIN
			SET @msg = 'Agent Receive Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF (@pRate - @pMargin - @pHoMargin - @pAgentMargin) < @tolPMin
		BEGIN
			SET @msg = 'Agent Receive Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		/*
		IF @cost > @tolCMax
		BEGIN
			SET @msg = 'Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @cost < @tolCMin
		BEGIN
			SET @msg = 'Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		*/
		BEGIN TRANSACTION
			IF ISNULL(@isUpdated, 'N') = 'N'
			BEGIN
				IF EXISTS (SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE approvedBy IS NULL AND exRateTreasuryId  = @exRateTreasuryId)			
				BEGIN
					UPDATE exRateTreasury SET
						 cHoMargin			= @cHoMargin
						,cAgentMargin		= @cAgentMargin
						,pHoMargin			= @pHoMargin
						,pAgentMargin		= @pAgentMargin
						,sharingType		= @sharingType
						,sharingValue		= @sharingValue
						,toleranceOn		= @toleranceOn
						,agentTolMin		= @agentTolMin
						,agentTolMax		= @agentTolMax
						,customerTolMin		= @customerTolMin
						,customerTolMax		= @customerTolMax
						,crossRate			= @crossRate
						,customerRate		= CASE WHEN ISNULL(@toleranceOn, '') IN ('S','P', '') THEN @customerRate WHEN ISNULL(@toleranceOn, '') = 'C' THEN @crossRate - ISNULL(@agentCrossRateMargin, 0) END
						,agentCrossRateMargin = 
												CASE WHEN @agentCrossRateMargin >= 0 THEN
													CASE WHEN @agentCrossRateMargin > @agentTolMin THEN @agentTolMin ELSE @agentCrossRateMargin END
												ELSE
													CASE WHEN (@agentCrossRateMargin * -1) > @agentTolMax THEN @agentTolMax ELSE @agentCrossRateMargin END
												END
						,tolerance			= @tolerance
						,modifiedBy			= @user
						,modifiedDate		= GETDATE()
					WHERE exRateTreasuryId = @exRateTreasuryId
				END
				ELSE
				BEGIN
					DELETE FROM exRateTreasuryMod WHERE exRateTreasuryId = @exRateTreasuryId
					INSERT INTO exRateTreasuryMod(						
						 exRateTreasuryId
						,tranType
						,cRateId
						,cCurrency
						,cCountry
						,cAgent
						,cRateFactor
						,cRate
						,cMargin
						,cHoMargin
						,cAgentMargin
						,pRateId
						,pCurrency
						,pCountry
						,pAgent
						,pRateFactor
						,pRate
						,pMargin
						,pHoMargin
						,pAgentMargin
						,sharingType
						,sharingValue
						,toleranceOn
						,agentTolMin
						,agentTolMax
						,customerTolMin
						,customerTolMax
						,maxCrossRate
						,agentCrossRateMargin
						,crossRate
						,customerRate
						,tolerance
						,isActive
						,createdBy
						,createdDate
						,modType
					)
					SELECT
						 @exRateTreasuryId
						,tranType
						,cRateId
						,cCurrency
						,cCountry
						,cAgent
						,cRateFactor
						,cRate
						,cMargin
						,@cHoMargin
						,@cAgentMargin
						,pRateId
						,pCurrency
						,pCountry
						,pAgent
						,pRateFactor
						,pRate
						,pMargin
						,@pHoMargin
						,@pAgentMargin
						,@sharingType
						,@sharingValue
						,@toleranceOn
						,@agentTolMin
						,@agentTolMax
						,@customerTolMin
						,@customerTolMax
						,maxCrossRate
						,CASE WHEN @agentCrossRateMargin >= 0 THEN
								CASE WHEN agentCrossRateMargin > @agentTolMin THEN @agentTolMin ELSE @agentCrossRateMargin END
							ELSE
								CASE WHEN (@agentCrossRateMargin * -1) > @agentTolMax THEN @agentTolMax ELSE @agentCrossRateMargin END
							END
						,@crossRate
						,CASE WHEN ISNULL(@toleranceOn, '') IN ('S','P', '') THEN @customerRate WHEN ISNULL(@toleranceOn, '') = 'C' THEN @crossRate - ISNULL(@agentCrossRateMargin, 0) END
						,@tolerance
						,isActive
						,@user
						,GETDATE()
						,'U'
					FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
					
					SELECT 
						 @cCurrency = cCurrency, @cCountry = cCountry, @cAgent = cAgent
						,@pCurrency = pCurrency, @pCountry = pCountry, @pAgent = pAgent
					FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
				END
			END
			ELSE
			BEGIN
				UPDATE exRateTreasuryMod SET
					 cHoMargin			= @cHoMargin
					,cAgentMargin		= @cAgentMargin
					,pHoMargin			= @pHoMargin
					,pAgentMargin		= @pAgentMargin
					,sharingType		= @sharingType
					,sharingValue		= @sharingValue
					,toleranceOn		= @toleranceOn
					,agentTolMin		= @agentTolMin
					,agentTolMax		= @agentTolMax
					,customerTolMin		= @customerTolMin
					,customerTolMax		= @customerTolMax
					,tolerance			= @tolerance
					,crossRate			= @crossRate
					,agentCrossRateMargin = CASE WHEN @agentCrossRateMargin >= 0 THEN
													CASE WHEN @agentCrossRateMargin > @agentTolMin THEN @agentTolMin ELSE @agentCrossRateMargin END
												ELSE
													CASE WHEN (@agentCrossRateMargin * -1) > @agentTolMax THEN @agentTolMax ELSE @agentCrossRateMargin END
											END
					,customerRate		= CASE WHEN ISNULL(@toleranceOn, '') IN ('S','P', '') THEN @customerRate WHEN ISNULL(@toleranceOn, '') = 'C' THEN @crossRate - ISNULL(@agentCrossRateMargin, 0) END
				WHERE exRateTreasuryId = @exRateTreasuryId
				
				/*		
				UPDATE exRateTreasury SET
					 isUpdated = 'N'
				WHERE exRateTreasuryId = @exRateTreasuryId
				*/
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag = 'uxml'				--Bulk Update XML
	BEGIN
		DECLARE @exRateList TABLE(id INT IDENTITY(1,1),exRateTreasuryId INT, tolerance FLOAT, cHoMargin FLOAT, cAgentMargin FLOAT, pHoMargin FLOAT, pAgentMargin FLOAT, 
									sharingType CHAR(1), sharingValue FLOAT, toleranceOn VARCHAR(2), agentTolMin FLOAT, agentTolMax FLOAT, 
									customerTolMin FLOAT, customerTolMax FLOAT,
									crossRate FLOAT, agentCrossRateMargin FLOAT, customerRate FLOAT, isUpdated CHAR(1), errorCode VARCHAR(10), msg VARCHAR(300))
		INSERT @exRateList(exRateTreasuryId, tolerance, cHoMargin, cAgentMargin, pHoMargin, pAgentMargin, 
							sharingType, sharingValue, toleranceOn, agentTolMin, agentTolMax,
							customerTolMin, customerTolMax, 
							crossRate, agentCrossRateMargin, customerRate, isUpdated, errorCode)
		SELECT
			 exRateTreasuryId		= p.value('@exRateTreasuryId','INT')
			,tolerance				= p.value('@tolerance','FLOAT')		
			,cHoMargin				= p.value('@cHoMargin','FLOAT')
			,cAgentMargin			= p.value('@cAgentMargin','FLOAT')
			,pHoMargin				= p.value('@pHoMargin','FLOAT')
			,pAgentMargin			= p.value('@pAgentMargin','FLOAT')
			,sharingType			= p.value('@sharingType','VARCHAR(1)')
			,sharingValue			= p.value('@sharingValue','FLOAT')
			,toleranceOn			= p.value('@toleranceOn','VARCHAR(2)')
			,agentTolMin			= p.value('@agentTolMin','FLOAT')
			,agentTolMax			= p.value('@agentTolMax','FLOAT')
			,customerTolMin			= p.value('@customerTolMin','FLOAT')
			,customerTolMax			= p.value('@customerTolMax','FLOAT')
			,crossRate				= p.value('@crossRate','FLOAT')
			,agentCrossRateMargin	= p.value('@agentCrossRateMargin', 'FLOAT')
			,customerRate			= p.value('@customerRate','FLOAT')
			,isUpdated				= p.value('@isUpdated','CHAR(1)')
			,errorCode				= '0'
		FROM @xml.nodes('/root/row') AS tmp(p)
		
		DECLARE @totalRows INT, @count INT = 1
		SELECT @totalRows = COUNT(exRateTreasuryId) FROM @exRateList
		WHILE(@count <= @totalRows)
		BEGIN
			SELECT
				 @exRateTreasuryId		= exRateTreasuryId
				,@tolerance				= tolerance
				,@cHoMargin				= cHoMargin
				,@cAgentMargin			= cAgentMargin
				,@pHoMargin				= pHoMargin
				,@pAgentMargin			= pAgentMargin
				,@sharingType			= sharingType
				,@sharingValue			= sharingValue
				,@toleranceOn			= toleranceOn
				,@agentTolMin			= agentTolMin
				,@agentTolMax			= agentTolMax
				,@customerTolMin		= customerTolMin
				,@customerTolMax		= customerTolMax
				,@crossRate				= crossRate
				,@agentCrossRateMargin	= agentCrossRateMargin
				,@customerRate			= customerRate
				,@isUpdated				= isUpdated 
			FROM @exRateList WHERE id = @count
			
			IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId AND (createdBy <> @user AND approvedBy IS NULL))
			BEGIN
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= 'You can not modify this record. Previous modification has not been approved yet.'
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId AND ISNULL(createdBy, '') <> @user)
			BEGIN
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= 'You can not modify this record. Previous modification has not been approved yet.'
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			SELECT 
				 @cRateFactor = cRateFactor
				,@cCurrency = cCurrency, @cRate = cRate, @cMargin = cMargin
				,@pCurrency = pCurrency, @pRate = pRate, @pMargin = pMargin 
			FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
			
			SELECT @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END FROM rateMask WHERE currency = @cCurrency
			SELECT @crossRateDecimalMask = dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency)
			
			SELECT @tolCMax = cMax, @tolCMin = cMin FROM rateMask WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND currency = @cCurrency
			SELECT @tolPMax = pMax, @tolPMin = pMin FROM rateMask WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND currency = @pCurrency
			
			SET @cost = ROUND((@pRate - @pMargin - @pHoMargin - @pAgentMargin)/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd) 
			--SET @cost = ROUND(@pRate/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd)

			IF (@cRate + @cMargin + @cHoMargin) > @tolCMax
			BEGIN
				SET @msg = 'HO Send Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF (@cRate + @cMargin + @cHoMargin) < @tolCMin
			BEGIN
				SET @msg = 'HO Send Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF (@cRate + @cMargin + @cHoMargin + @cAgentMargin) > @tolCMax
			BEGIN
				SET @msg = 'Agent Send Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF (@cRate + @cMargin + @cHoMargin + @cAgentMargin) < @tolCMin
			BEGIN
				SET @msg = 'Agent Send Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF (@pRate - @pMargin - @pHoMargin) > @tolPMax
			BEGIN
				SET @msg = 'HO Receive Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF (@pRate - @pMargin - @pHoMargin) < @tolPMin
			BEGIN
				SET @msg = 'HO Receive Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF (@pRate - @pMargin - @pHoMargin - @pAgentMargin) > @tolPMax
			BEGIN
				SET @msg = 'Agent Receive Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF (@pRate - @pMargin - @pHoMargin - @pAgentMargin) < @tolPMin
			BEGIN
				SET @msg = 'Agent Receive Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolPMin AS VARCHAR) + ' and ' + CAST(@tolPMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF @cost > @tolCMax
			BEGIN
				SET @msg = 'Cost rate exceeds maximum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			
			IF @cost < @tolCMin
			BEGIN
				SET @msg = 'Cost rate exceeds minimum tolerance rate. Rate must lie between ' + CAST(@tolCMin AS VARCHAR) + ' and ' + CAST(@tolCMax AS VARCHAR)
				UPDATE @exRateList SET
					 errorCode	= 1
					,msg		= @msg
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
			SET @count = @count + 1
		END
		
		--SELECT * FROM @exRateList
		--RETURN
		BEGIN TRANSACTION
			IF EXISTS(SELECT 'X' FROM exRateTreasury ert WITH(NOLOCK) INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateTreasuryId 
			WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'N' AND ert.approvedBy IS NULL)
			BEGIN
				UPDATE ert SET
					 ert.cHoMargin			= list.cHoMargin
					,ert.cAgentMargin		= list.cAgentMargin
					,ert.pHoMargin			= list.pHoMargin
					,ert.pAgentMargin		= list.pAgentMargin
					,ert.sharingType		= list.sharingType
					,ert.sharingValue		= list.sharingValue
					,ert.toleranceOn		= list.toleranceOn
					,ert.agentTolMin		= list.agentTolMin
					,ert.agentTolMax		= list.agentTolMax
					,ert.customerTolMin		= list.customerTolMin
					,ert.customerTolMax		= list.customerTolMax
					,ert.crossRate			= list.crossRate
					,ert.customerRate		= CASE WHEN ISNULL(ert.toleranceOn, '') IN ('S','P', '') THEN list.customerRate WHEN ISNULL(ert.toleranceOn, '') = 'C' THEN list.crossRate - ISNULL(list.agentCrossRateMargin, 0) END
					,ert.agentCrossRateMargin = CASE WHEN list.agentCrossRateMargin >= 0 THEN
														CASE WHEN list.agentCrossRateMargin > list.agentTolMin THEN list.agentTolMin ELSE list.agentCrossRateMargin END
													ELSE
														CASE WHEN (list.agentCrossRateMargin * -1) > list.agentTolMax THEN list.agentTolMax ELSE list.agentCrossRateMargin END
												END
					,ert.tolerance			= list.tolerance
					,ert.modifiedBy			= @user
					,ert.modifiedDate		= GETDATE()
				FROM exRateTreasury ert
				INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateTreasuryId 
				WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'N' AND ert.approvedBy IS NULL
			END
			
			IF EXISTS(SELECT 'X' FROM exRateTreasury ert WITH(NOLOCK)
				INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateTreasuryId
				WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'N' AND ert.approvedBy IS NOT NULL
				)
			BEGIN
				DELETE FROM exRateTreasuryMod
				FROM exRateTreasuryMod ertm
				INNER JOIN exRateTreasury ert ON ertm.exRateTreasuryId = ert.exRateTreasuryId
				INNER JOIN @exRateList list ON ertm.exRateTreasuryId = list.exRateTreasuryId
				WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'N' AND ert.approvedBy IS NOT NULL
			
				INSERT INTO exRateTreasuryMod(
					 exRateTreasuryId
					,tranType
					,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin
					,cHoMargin,cAgentMargin
					,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin
					,pHoMargin,pAgentMargin
					,sharingType,sharingValue
					,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
					,maxCrossRate,crossRate
					,agentCrossRateMargin
					,customerRate
					,tolerance,isActive
					,createdBy,createdDate,modType
				)
				SELECT
					 list.exRateTreasuryId
					,tranType
					,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin
					,list.cHoMargin,list.cAgentMargin
					,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin
					,list.pHoMargin,list.pAgentMargin
					,list.sharingType,list.sharingValue
					,list.toleranceOn,list.agentTolMin,list.agentTolMax,list.customerTolMin,list.customerTolMax
					,maxCrossRate,list.crossRate
					,CASE WHEN list.agentCrossRateMargin >= 0 THEN
							CASE WHEN list.agentCrossRateMargin > list.agentTolMin THEN list.agentTolMin ELSE list.agentCrossRateMargin END
						ELSE
							CASE WHEN (list.agentCrossRateMargin * -1) > list.agentTolMax THEN list.agentTolMax ELSE list.agentCrossRateMargin END
						END
					,CASE WHEN ISNULL(ert.toleranceOn, '') IN ('S','P', '') THEN list.customerRate WHEN ISNULL(ert.toleranceOn, '') = 'C' THEN list.crossRate - ISNULL(list.agentCrossRateMargin, 0) END
					,list.tolerance,isActive
					,@user,GETDATE(),'U'
				FROM exRateTreasury ert WITH(NOLOCK)
				INNER JOIN @exRateList list ON ert.exRateTreasuryId = list.exRateTreasuryId
				WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'N' AND ert.approvedBy IS NOT NULL
			END
			
			IF EXISTS(SELECT 'X' FROM exRateTreasuryMod ertm WITH(NOLOCK)
						INNER JOIN @exRateList list ON ertm.exRateTreasuryId = list.exRateTreasuryId
						WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'Y'
						)
			BEGIN
				UPDATE ertm SET
					 ertm.cHoMargin			= list.cHoMargin
					,ertm.cAgentMargin		= list.cAgentMargin
					,ertm.pHoMargin			= list.pHoMargin
					,ertm.pAgentMargin		= list.pAgentMargin
					,ertm.sharingType		= list.sharingType
					,ertm.sharingValue		= list.sharingValue
					,ertm.toleranceOn		= list.toleranceOn
					,ertm.agentTolMin		= list.agentTolMin
					,ertm.agentTolMax		= list.agentTolMax
					,ertm.customerTolMin	= list.customerTolMin
					,ertm.customerTolMax	= list.customerTolMax
					,ertm.tolerance			= list.tolerance
					,ertm.crossRate			= list.crossRate
					,ertm.agentCrossRateMargin = CASE WHEN list.agentCrossRateMargin >= 0 THEN
														CASE WHEN list.agentCrossRateMargin > list.agentTolMin THEN list.agentTolMin ELSE list.agentCrossRateMargin END
													ELSE
														CASE WHEN (list.agentCrossRateMargin * -1) > list.agentTolMax THEN list.agentTolMax ELSE list.agentCrossRateMargin END
													END
					,ertm.customerRate		= CASE WHEN ISNULL(ertm.toleranceOn, '') IN ('S','P', '') THEN list.customerRate WHEN ISNULL(ertm.toleranceOn, '') = 'C' THEN list.crossRate - ISNULL(list.agentCrossRateMargin, 0) END
				FROM exRateTreasuryMod ertm
				INNER JOIN @exRateList list ON ertm.exRateTreasuryId = list.exRateTreasuryId
				WHERE list.errorCode = '0' AND ISNULL(list.isUpdated, 'N') = 'Y'
			END
	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		SELECT @exRateTreasuryIds = COALESCE(ISNULL(@exRateTreasuryIds + ',', ''), '') + CAST(exRateTreasuryId AS VARCHAR) FROM @exRateList WHERE errorCode = '0'
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
		/*
		SET @sql = 'UPDATE exRateTreasury SET isUpdated = ''N'' WHERE exRateTreasuryId IN (' + @exRateTreasuryIds + ')'
		EXEC (@sql)
		*/
		
		EXEC proc_errorHandler 0, 'Rate updated successfully', NULL
	END
	
	ELSE IF @flag IN('reject')
	BEGIN
		IF(ISNULL(@exRateTreasuryIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to approve', NULL
			RETURN
		END
		BEGIN TRANSACTION
			SET @sql = 'SELECT exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId IN (' + @exRateTreasuryIds + ')'
			INSERT @rateIdList
			EXEC (@sql)
			WHILE EXISTS(SELECT 'X' FROM @rateIdList)
			BEGIN
				SELECT TOP 1 @exRateTreasuryId = exRateTreasuryId FROM @rateIdList
				IF EXISTS (SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE approvedBy IS NULL AND exRateTreasuryId = @exRateTreasuryId)
				BEGIN --New record			
					SET @modType = 'Reject'
					DELETE FROM exRateTreasury WHERE exRateTreasuryId =  @exRateTreasuryId
				END
				ELSE
				BEGIN
					SET @modType = 'Reject'
					DELETE FROM exRateTreasuryMod WHERE exRateTreasuryId = @exRateTreasuryId
				END
					
				UPDATE exRateTreasury SET
					 isUpdated = 'N'
				WHERE exRateTreasuryId = @exRateTreasuryId
				
				DELETE FROM @rateIdList WHERE exRateTreasuryId = @exRateTreasuryId
			END	
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag  IN ('approve')
	BEGIN
		IF(ISNULL(@exRateTreasuryIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to approve', NULL
			RETURN
		END
		BEGIN TRANSACTION
			SET @sql = 'SELECT exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId IN (' + @exRateTreasuryIds + ')'
			INSERT @rateIdList
			EXEC (@sql)
			WHILE EXISTS(SELECT 'X' FROM @rateIdList)
			BEGIN
				SELECT TOP 1 @exRateTreasuryId = exRateTreasuryId FROM @rateIdList
				IF EXISTS (SELECT 'X' FROM exRateTreasury WHERE approvedBy IS NULL AND exRateTreasuryId = @exRateTreasuryId)
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM exRateTreasuryMod WHERE exRateTreasuryId = @exRateTreasuryId
				IF @modType = 'I'
				BEGIN --New record
					INSERT INTO exRateTreasuryHistory(
						 exRateTreasuryId
						,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingValue,sharingType,pSharingValue,pSharingType
						,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,tranType
						,crossRate,crossRateOperation,maxCrossRate,agentCrossRateMargin,customerRate,tolerance,toleranceOperation
						,premium,crossRateFactor
						,isActive,modType,modFor
						,createdBy,createdDate,approvedBy,approvedDate
					)
					SELECT
						 exRateTreasuryId
						,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingValue,sharingType,pSharingValue,pSharingType
						,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,tranType
						,crossRate,crossRateOperation,maxCrossRate,agentCrossRateMargin,customerRate,tolerance,toleranceOperation
						,premium,crossRateFactor
						,isActive,'I','T'		--T - Treasury, O - Operation
						,createdBy,createdDate,@user,@date
					FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
					
					SET @exRateHistoryId = SCOPE_IDENTITY()
					
					UPDATE exRateTreasury SET
						 premium			= 0
						,isActive			= 'Y'
						,approvedBy			= @user
						,approvedDate		= @date
						,exRateHistoryId	= @exRateHistoryId
						,isUpdated			= 'N'
						,isUpdatedOperation = 'Y'
					WHERE exRateTreasuryId = @exRateTreasuryId
				END
				
				ELSE IF @modType = 'U'
				BEGIN
					INSERT INTO exRateTreasuryHistory(
						 exRateTreasuryId
						,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingValue,sharingType,pSharingValue,pSharingType
						,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,tranType
						,crossRate,maxCrossRate,agentCrossRateMargin,customerRate,tolerance,crossRateFactor
						,isActive,modType,modFor
						,createdBy,createdDate,approvedBy,approvedDate
					)
					SELECT
						 mode.exRateTreasuryId
						,mode.cRateId,mode.cCurrency,mode.cCountry,mode.cAgent,mode.cRateFactor,mode.cRate,mode.cMargin,mode.cHoMargin,mode.cAgentMargin
						,mode.pRateId,mode.pCurrency,mode.pCountry,mode.pAgent,mode.pRateFactor,mode.pRate,mode.pMargin,mode.pHoMargin,mode.pAgentMargin
						,mode.sharingValue,mode.sharingType,mode.pSharingValue,mode.pSharingType
						,mode.toleranceOn,mode.agentTolMin,mode.agentTolMax,mode.customerTolMin,mode.customerTolMax
						,mode.tranType
						,mode.crossRate,mode.maxCrossRate,mode.agentCrossRateMargin,mode.customerRate,mode.tolerance,mode.crossRateFactor
						,mode.isActive,mode.modType,'T'
						,mode.createdBy,mode.createdDate,@user,GETDATE()
					FROM exRateTreasuryMod mode WITH(NOLOCK)
					INNER JOIN exRateTreasury main WITH(NOLOCK) ON mode.exRateTreasuryId = main.exRateTreasuryId
					WHERE mode.exRateTreasuryId = @exRateTreasuryId
					
					SET @exRateHistoryId = SCOPE_IDENTITY()
					
					UPDATE main SET
						 main.cRateId				= mode.cRateId
						,main.cRate					= mode.cRate
						,main.cMargin				= mode.cMargin
						,main.cHoMargin				= mode.cHoMargin
						,main.cAgentMargin			= mode.cAgentMargin
						,main.pRateId				= mode.pRateId
						,main.pRate					= mode.pRate
						,main.pMargin				= mode.pMargin
						,main.pHoMargin				= mode.pHoMargin
						,main.pAgentMargin			= mode.pAgentMargin
						,main.sharingType			= mode.sharingType
						,main.sharingValue			= mode.sharingValue
						,main.toleranceOn			= mode.toleranceOn
						,main.agentTolMin			= mode.agentTolMin
						,main.agentTolMax			= mode.agentTolMax
						,main.customerTolMin		= mode.customerTolMin
						,main.customerTolMax		= mode.customerTolMax
						,main.maxCrossRate			= mode.maxCrossRate
						,main.crossRate				= mode.crossRate
						,main.agentCrossRateMargin	= mode.agentCrossRateMargin
						,main.customerRate			= mode.customerRate
						,main.tolerance				= mode.tolerance
						,main.isActive				= mode.isActive
						,main.modifiedBy			= mode.createdBy
						,main.modifiedDate			= mode.createdDate
						,main.approvedBy			= @user
						,main.approvedDate			= @date
						,main.exRateHistoryId		= @exRateHistoryId
						,main.isUpdated				= 'N'
						,main.isUpdatedOperation	= 'Y'
					FROM exRateTreasury main
					INNER JOIN exRateTreasuryMod mode ON mode.exRateTreasuryId = main.exRateTreasuryId
					WHERE mode.exRateTreasuryId = @exRateTreasuryId
				END
				
				ELSE IF @modType = 'D'
				BEGIN
					INSERT INTO exRateTreasuryHistory(
						 exRateTreasuryId
						,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingValue,sharingType,pSharingValue,pSharingType
						,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,tranType
						,crossRate,maxCrossRate,agentCrossRateMargin,customerRate,tolerance,crossRateFactor
						,isActive,modType,modFor
						,createdBy,createdDate,approvedBy,approvedDate
					)
					SELECT
						 mode.exRateTreasuryId
						,mode.cRateId,mode.cCurrency,mode.cCountry,mode.cAgent,mode.cRateFactor,mode.cRate,mode.cMargin,mode.cHoMargin,mode.cAgentMargin
						,mode.pRateId,mode.pCurrency,mode.pCountry,mode.pAgent,mode.pRateFactor,mode.pRate,mode.pMargin,mode.pHoMargin,mode.pAgentMargin
						,mode.sharingValue,mode.sharingType,mode.pSharingValue,mode.pSharingType
						,mode.toleranceOn,mode.agentTolMin,mode.agentTolMax,mode.customerTolMin,mode.customerTolMax
						,mode.tranType
						,mode.crossRate,mode.maxCrossRate,mode.agentCrossRateMargin,mode.customerRate,mode.tolerance,mode.crossRateFactor
						,mode.isActive,mode.modType,'T'
						,mode.createdBy,mode.createdDate,@user,@date
					FROM exRateTreasuryMod mode WITH(NOLOCK)
					INNER JOIN exRateTreasury main WITH(NOLOCK) ON mode.exRateTreasuryId = main.exRateTreasuryId
					WHERE mode.exRateTreasuryId = @exRateTreasuryId
					
					SET @exRateHistoryId = SCOPE_IDENTITY()
					
					UPDATE exRateTreasury SET
						 isActive			= 'N'
						,modifiedDate		= @date
						,modifiedBy			= @user	
						,isUpdated			= 'N'
						,isUpdatedOperation = 'Y'
						,exRateHistoryId = @exRateHistoryId				
					WHERE exRateTreasuryId = @exRateTreasuryId
				END
				
				IF @modType IN ('U', 'D')
				BEGIN
					DELETE FROM exRateTreasuryMod WHERE exRateTreasuryId = @exRateTreasuryId
				END
				
				SELECT @cCountry = NULL, @cAgent = NULL, @pRate = NULL, @pMargin = NULL, @pHoMargin = NULL, @pCountry = NULL, @pAgent = NULL, @pCurrency = NULL
				SELECT 
					 @cCountry = cCountry, @cAgent = cAgent, @pRate = pRate, @pMargin = pMargin
					,@pHoMargin = pHoMargin, @pCountry = pCountry
					,@pAgent = pAgent, @pCurrency = pCurrency
				FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
				
				--IF (@cCountry = 233 AND @cAgent = 4818) OR (@cCountry = 133 AND @cAgent = 4746)
				--BEGIN
				--	DECLARE @partnerExRate TABLE(id INT IDENTITY(1,1), cAgent INT, cost_payoutRate FLOAT, payout_countryName VARCHAR(100), payout_agent VARCHAR(10), pAgent INT, pCurrency VARCHAR(3))
				--	DECLARE @cost_payoutRate FLOAT, @payout_agent VARCHAR(10)
				--	SET @cost_payoutRate = ROUND((@pRate - ISNULL(@pMargin, 0) - ISNULL(@pHoMargin, 0)), 10)
				--	SELECT @pCountryName = countryName FROM countryMaster WITH(NOLOCK) WHERE countryId = @pCountry
				--	SET @payout_agent = NULL
				--	SELECT @payout_agent = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
					
				--	INSERT INTO @partnerExRate(cAgent, cost_payoutRate, payout_countryName, payout_agent, pAgent, pCurrency)
				--	SELECT @cAgent, @cost_payoutRate, @pCountryName, @payout_agent, @pAgent, @pCurrency
					
				--	IF @cCountry = 133 AND @cAgent = 4746
				--	BEGIN
				--		SELECT @exRateMsg = 'IME M, IME Nepal ExRate for 1 USD = ' + CAST(@cost_payoutRate AS VARCHAR) + ' NPR as of date ' + CONVERT(VARCHAR, GETDATE(), 109)
				--	END
				--	IF @cCountry = 233 AND @cAgent = 4818
				--	BEGIN
				--		SELECT @exRateMsg = 'IME UK, IME Nepal ExRate for 1 USD = ' + CAST(@cost_payoutRate AS VARCHAR) + ' NPR as of date ' + CONVERT(VARCHAR, GETDATE(), 109)					
				--	END
				--	SELECT @cCountryName = countryName FROM countryMaster WITH(NOLOCK) WHERE countryId = @cCountry
				--	EXEC proc_emailSmsHandler @flag = 'sms', @user = @user, @msg = @exRateMsg, @country = @cCountryName
				--END
				
				DELETE FROM @rateIdList WHERE exRateTreasuryId = @exRateTreasuryId
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @exRateTreasuryId
		
	END
	
	ELSE IF @flag = 'r'					--Get Report
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cCountryName,cAgentName,pCountryName,cBranchName,pAgentName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'pCountryName,cBranchName,pAgentName,cCountryName,cAgentName'
		SET @sortOrder = ''
		
		IF @cBranch IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..##tmpXRate') IS NOT NULL
				DROP TABLE ##tmpXRate
	
			SELECT
				 main.exRateTreasuryId	
				,tranType = ISNULL(tt.typeTitle, 'Any')
				,main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,main.cAgent
				,cAgentName = ISNULL(cam.agentName, '[All]')
				,cBranch = @cBranch
				,cBranchName = (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch)
				,main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,main.pAgent
				,pAgentName = ISNULL(pam.agentName, '[All]')
				,main.cCurrency
				,main.pCurrency
				,main.cRateFactor
				,main.pRateFactor
				,main.cRate
				,cMargin = ISNULL(main.cMargin, 0)
				,cHoMargin = ISNULL(main.cHoMargin, 0)
				,cAgentMargin = ISNULL(cAgentMargin, 0)
				,main.pRate
				,pMargin = ISNULL(main.pMargin, 0)
				,pHoMargin = ISNULL(main.pHoMargin, 0)
				,pAgentMargin = ISNULL(main.pAgentMargin, 0)
				,sharingType
				,sharingValue = ISNULL(main.sharingValue, 0)
				,toleranceOn
				,agentTolMin = ISNULL(main.agentTolMin, 0)
				,agentTolMax = ISNULL(main.agentTolMax, 0)
				,customerTolMin = ISNULL(main.customerTolMin, 0)
				,customerTolMax = ISNULL(main.customerTolMax, 0)
				,main.maxCrossRate
				,main.crossRate
				,main.agentCrossRateMargin
				,customerRate = ISNULL(main.crossRateOperation, main.customerRate)
				,main.tolerance
				,premium = main.premium
				,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
				,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
				,main.crossRateFactor
				,main.isUpdated		
				,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedByOperation ELSE
									ISNULL(main.modifiedBy,main.createdBy) END
				,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedDateOperation ELSE
									ISNULL(main.modifiedDate,main.createdDate) END
				,main.approvedBy
				,main.approvedDate
			INTO ##tmpXRate
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
			WHERE cCountry = 133 AND cAgent = @cAgent AND main.approvedBy IS NOT NULL AND ISNULL(main.isActive, 'N') = 'Y'
			ORDER BY pCountryName, pAgentName
			
			UPDATE tmp SET
				 tmp.premium = erbw.premium
				,tmp.modifiedBy = erbw.modifiedBy
				,tmp.modifiedDate = erbw.modifiedDate
				,tmp.approvedBy = erbw.modifiedBy
				,tmp.approvedDate = erbw.modifiedDate
			FROM ##tmpXRate tmp
			INNER JOIN exRateBranchWise erbw ON tmp.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @cBranch AND ISNULL(erbw.isActive, 'N') = 'Y'
			
			SET @table = '(
						SELECT * FROM ##tmpXRate
						)x
					'
		END
		ELSE
		BEGIN
		--SELECT * FROM exRateBranchWise
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = NULL
							,cBranchName = ''[All]''
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,main.maxCrossRate
							,main.crossRate
							,main.agentCrossRateMargin
							,customerRate = ISNULL(main.crossRateOperation, main.customerRate)
							,main.tolerance
							,premium = main.premium
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedByOperation ELSE
												ISNULL(main.modifiedBy,main.createdBy) END
							,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedDateOperation ELSE
												ISNULL(main.modifiedDate,main.createdDate) END
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE ISNULL(main.isActive, ''N'') = ''Y''
						'
		/*	
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,main.maxCrossRate
							,main.crossRate
							,main.customerRate
							,main.tolerance
							,main.premium
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = ISNULL(main.modifiedBy,main.createdBy)
							,modifiedDate = ISNULL(main.modifiedDate,main.createdDate)
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE 1 = 1
						
						'
		*/		
		
		SET @table =  @table + ') x'
		END	
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
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
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
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
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
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
			,cMargin
			,cHoMargin
			,cAgentMargin
			,pRate
			,pMargin
			,pHoMargin
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,maxCrossRate
			,crossRate
			,agentCrossRateMargin
			,customerRate
			,tolerance
			,premium
			,cost
			,margin
			,crossRateFactor
			,isUpdated
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
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
		
		IF OBJECT_ID('tempdb..##tmpXRate') IS NOT NULL
			DROP TABLE ##tmpXRate
	END
	
	ELSE IF @flag = 'or'				--Get Operation Report
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cBranchName,pCountryName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'cBranchName,pCountryName'
		SET @sortOrder = ''
		
		IF @cBranch IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..##tmpRate') IS NOT NULL
				DROP TABLE ##tmpRate
	
			SELECT
				 main.exRateTreasuryId	
				,tranType = ISNULL(tt.typeTitle, 'Any')
				,main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,main.cAgent
				,cAgentName = ISNULL(cam.agentName, '[All]')
				,cBranch = @cBranch
				,cBranchName = (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch)
				,main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,main.pAgent
				,pAgentName = ISNULL(pam.agentName, '[All]')
				,main.cCurrency
				,main.pCurrency
				,main.cRateFactor
				,main.pRateFactor
				,main.cRate
				,cMargin = ISNULL(main.cMargin, 0)
				,cHoMargin = ISNULL(main.cHoMargin, 0)
				,cAgentMargin = ISNULL(cAgentMargin, 0)
				,main.pRate
				,pMargin = ISNULL(main.pMargin, 0)
				,pHoMargin = ISNULL(main.pHoMargin, 0)
				,pAgentMargin = ISNULL(main.pAgentMargin, 0)
				,sharingType
				,sharingValue = ISNULL(main.sharingValue, 0)
				,toleranceOn
				,agentTolMin = ISNULL(main.agentTolMin, 0)
				,agentTolMax = ISNULL(main.agentTolMax, 0)
				,customerTolMin = ISNULL(main.customerTolMin, 0)
				,customerTolMax = ISNULL(main.customerTolMax, 0)
				,main.maxCrossRate
				,main.crossRate
				,customerRate = ISNULL(main.crossRateOperation, main.customerRate)
				,tolerance = ISNULL(main.toleranceOperation, main.tolerance)
				,premium = main.premium
				,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
				,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
				,main.crossRateFactor
				,main.isUpdated		
				,modifiedBy = ISNULL(main.modifiedByOperation, main.approvedBy)
				,modifiedDate = ISNULL(main.modifiedDateOperation, main.approvedDate)
				,approvedBy = main.modifiedByOperation
				,approvedDate = main.modifiedDateOperation
			INTO ##tmpRate
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
			WHERE cCountry = 133 AND cAgent = dbo.FNAGetIMEAgentId() AND main.approvedBy IS NOT NULL AND ISNULL(main.isActive, 'N') = 'Y'
			ORDER BY pCountryName, pAgentName
			
			UPDATE tmp SET
				 tmp.premium = erbw.premium
				,tmp.modifiedBy = erbw.modifiedBy
				,tmp.modifiedDate = erbw.modifiedDate
				,tmp.approvedBy = erbw.modifiedBy
				,tmp.approvedDate = erbw.modifiedDate
			FROM ##tmpRate tmp
			INNER JOIN exRateBranchWise erbw ON tmp.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @cBranch AND ISNULL(erbw.isActive, 'N') = 'Y'
			
			SET @table = '(
						SELECT * FROM ##tmpRate
						)x
					'
		END
		ELSE
		BEGIN		
		--SELECT * FROM exRateBranchWise
			SET @table = '(
							SELECT
								 main.exRateTreasuryId	
								,tranType = ISNULL(tt.typeTitle, ''Any'')
								,main.cCountry
								,cCountryName = cc.countryName
								,cCountryCode = cc.countryCode
								,main.cAgent
								,cAgentName = ISNULL(cam.agentName, ''[All]'')
								,cBranch = NULL
								,cBranchName = ''[All]''
								,main.pCountry
								,pCountryName = pc.countryName
								,pCountryCode = pc.countryCode
								,main.pAgent
								,pAgentName = ISNULL(pam.agentName, ''[All]'')
								,main.cCurrency
								,main.pCurrency
								,main.cRateFactor
								,main.pRateFactor
								,main.cRate
								,cMargin = ISNULL(main.cMargin, 0)
								,cHoMargin = ISNULL(main.cHoMargin, 0)
								,cAgentMargin = ISNULL(cAgentMargin, 0)
								,main.pRate
								,pMargin = ISNULL(main.pMargin, 0)
								,pHoMargin = ISNULL(main.pHoMargin, 0)
								,pAgentMargin = ISNULL(main.pAgentMargin, 0)
								,sharingType
								,sharingValue = ISNULL(main.sharingValue, 0)
								,toleranceOn
								,agentTolMin = ISNULL(main.agentTolMin, 0)
								,agentTolMax = ISNULL(main.agentTolMax, 0)
								,customerTolMin = ISNULL(main.customerTolMin, 0)
								,customerTolMax = ISNULL(main.customerTolMax, 0)
								,main.maxCrossRate
								,main.crossRate
								,customerRate = ISNULL(main.crossRateOperation, main.customerRate)
								,main.tolerance
								,premium = main.premium
								,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
								,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
								,main.crossRateFactor
								,main.isUpdated		
								,modifiedBy = ISNULL(main.modifiedByOperation, main.approvedBy)
								,modifiedDate = ISNULL(main.modifiedDateOperation, main.approvedDate)
								,approvedBy = main.modifiedByOperation
								,approvedDate = main.modifiedDateOperation
							FROM exRateTreasury main WITH(NOLOCK)
							LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
							LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
							LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
							LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
							LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
							LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
							WHERE ISNULL(main.isActive, ''N'') = ''Y''
							'
			/*	
			SET @table = '(
							SELECT
								 main.exRateTreasuryId	
								,tranType = ISNULL(tt.typeTitle, ''Any'')
								,main.cCountry
								,cCountryName = cc.countryName
								,cCountryCode = cc.countryCode
								,main.cAgent
								,cAgentName = ISNULL(cam.agentName, ''[All]'')
								,main.pCountry
								,pCountryName = pc.countryName
								,pCountryCode = pc.countryCode
								,main.pAgent
								,pAgentName = ISNULL(pam.agentName, ''[All]'')
								,main.cCurrency
								,main.pCurrency
								,main.cRateFactor
								,main.pRateFactor
								,main.cRate
								,cMargin = ISNULL(main.cMargin, 0)
								,cHoMargin = ISNULL(main.cHoMargin, 0)
								,cAgentMargin = ISNULL(cAgentMargin, 0)
								,main.pRate
								,pMargin = ISNULL(main.pMargin, 0)
								,pHoMargin = ISNULL(main.pHoMargin, 0)
								,pAgentMargin = ISNULL(main.pAgentMargin, 0)
								,sharingType
								,sharingValue = ISNULL(main.sharingValue, 0)
								,toleranceOn
								,agentTolMin = ISNULL(main.agentTolMin, 0)
								,agentTolMax = ISNULL(main.agentTolMax, 0)
								,customerTolMin = ISNULL(main.customerTolMin, 0)
								,customerTolMax = ISNULL(main.customerTolMax, 0)
								,main.maxCrossRate
								,main.crossRate
								,main.customerRate
								,main.tolerance
								,main.premium
								,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
								,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
								,main.crossRateFactor
								,main.isUpdated		
								,modifiedBy = ISNULL(main.modifiedBy,main.createdBy)
								,modifiedDate = ISNULL(main.modifiedDate,main.createdDate)
								,main.approvedBy
								,main.approvedDate
							FROM exRateTreasury main WITH(NOLOCK)
							LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
							LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
							LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
							LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
							LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
							LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
							WHERE 1 = 1
							
							'
			*/
							
			SET @table =  @table + ') x'
		END
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
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
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
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
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
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
			,cMargin
			,cHoMargin
			,cAgentMargin
			,pRate
			,pMargin
			,pHoMargin
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,maxCrossRate
			,crossRate
			,customerRate
			,tolerance
			,premium
			,cost
			,margin
			,crossRateFactor
			,isUpdated
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
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
		
		IF OBJECT_ID('tempdb..##tmpRate') IS NOT NULL
			DROP TABLE ##tmpRate
	END
	
	ELSE IF @flag = 'ms'				--Modify Summary
	BEGIN
		INSERT INTO #exRateIdTemp
		SELECT value FROM dbo.Split(',', @exRateTreasuryIds)
		
		SELECT
			 exRateTreasuryId = main.exRateTreasuryId
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
			,cRateNew = mode.cRate
			,cMargin = main.cMargin
			,cMarginNew = mode.cMargin
			,cHoMargin = main.cHoMargin
			,cHoMarginNew = mode.cHoMargin
			,cAgentMargin = main.cAgentMargin
			,cAgentMarginNew = mode.cAgentMargin
			,pRate = main.pRate
			,pRateNew = mode.pRate
			,pMargin = main.pMargin
			,pMarginNew = mode.pMargin
			,pHoMargin = main.pHoMargin
			,pHoMarginNew = mode.pHoMargin
			,pAgentMargin = main.pAgentMargin
			,pAgentMarginNew = mode.pAgentMargin
			,sharingType = main.sharingType
			,sharingTypeNew = mode.sharingType
			,sharingValue = main.sharingValue
			,sharingValueNew = mode.sharingValue
			,toleranceOn = main.toleranceOn
			,toleranceOnNew = mode.toleranceOn
			,agentTolMin = main.agentTolMin
			,agentTolMinNew = mode.agentTolMin
			,agentTolMax = main.agentTolMax
			,agentTolMaxNew = mode.agentTolMax
			,customerTolMin = main.customerTolMin
			,customerTolMinNew = mode.customerTolMin
			,customerTolMax = main.customerTolMax
			,customerTolMaxNew = mode.customerTolMax
			,maxCrossRate = main.maxCrossRate
			,crossRate = main.crossRate
			,customerRate = main.customerRate
			,tolerance = main.tolerance	
			,maxCrossRateNew = mode.maxCrossRate
			,crossRateNew = mode.crossRate
			,customerRateNew = mode.customerRate
			,toleranceNew = mode.tolerance
			
			,agentCrossRateMargin = main.agentCrossRateMargin
			,agentCrossRateMarginNew = mode.agentCrossRateMargin
			
			,cost = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)), crm.rateMaskMulAd)
			,costNew = ROUND(mode.pRate/(mode.crossRate + ISNULL(mode.tolerance, 0)), crm.rateMaskMulAd)
			,margin = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)) - main.cRate, crm.rateMaskMulAd)
			,marginNew = ROUND(mode.pRate/(mode.crossRate + ISNULL(mode.tolerance, 0)) - mode.cRate, crm.rateMaskMulAd)	
							
			,[status] = CASE WHEN ISNULL(main.isActive, 'N') = 'Y' THEN 'Active' ELSE 'Inactive' END
			,statusNew = CASE WHEN ISNULL(mode.isActive, 'N') = 'Y' THEN 'Active' ELSE 'Inactive' END
			
			,modType = CASE WHEN main.approvedBy IS NULL THEN 'Insert' ELSE 'Update' END		
			,main.createdBy
			,main.createdDate
			,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
			,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
			,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.exRateTreasuryId IS NOT NULL) THEN 'Y' ELSE 'N' END
		FROM exRateTreasury main WITH(NOLOCK)
		INNER JOIN #exRateIdTemp erit ON main.exRateTreasuryId = erit.exRateTreasuryId
		LEFT JOIN exRateTreasuryMod mode WITH(NOLOCK) ON main.exRateTreasuryId = mode.exRateTreasuryId
		LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
		LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
		LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
		LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
		LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
		ORDER BY cCountryName, cAgentName, pCountryName, pAgentName
						--AND ISNULL(main.isUpdated, ''N'') <> ''Y''
	END
	
	ELSE IF @flag = 'as'				--Approve Summary
	BEGIN
		INSERT INTO #exRateIdTemp
		SELECT value FROM dbo.Split(',', @exRateTreasuryIds)
		
		SELECT
			 exRateTreasuryId = main.exRateTreasuryId
			,tranType = ISNULL(tt.typeTitle, 'All')
			,cCountry = main.cCountry
			,cCountryName = cc.countryName
			,cCountryCode = cc.countryCode
			,cAgent = main.cAgent
			,cAgentName = ISNULL(cam.agentName, 'All')
			,pCountry = main.pCountry
			,pCountryName = pc.countryName
			,pCountryCode = pc.countryCode
			,pAgent = main.pAgent
			,pAgentName = ISNULL(pam.agentName, 'All')
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
			,sharingType = main.sharingType
			,sharingValue = main.sharingValue
			,toleranceOn = main.toleranceOn
			,agentTolMin = main.agentTolMin
			,agentTolMax = main.agentTolMax
			,customerTolMin = main.customerTolMin
			,customerTolMax = main.customerTolMax
			,maxCrossRate = main.maxCrossRate
			,crossRate = main.crossRate
			,agentCrossRateMargin = main.agentCrossRateMargin
			,customerRate = main.customerRate
			,tolerance = main.tolerance	
			
			,cost = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)), crm.rateMaskMulAd)
			,margin = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)) - main.cRate, crm.rateMaskMulAd)
							
			,[status] = CASE WHEN ISNULL(main.isActive, 'N') = 'Y' THEN 'Active' ELSE 'Inactive' END
			
			,modType = CASE WHEN main.approvedBy IS NULL THEN 'I' ELSE 'U' END		
			,main.createdBy
			,main.createdDate
			,modifiedBy = ISNULL(main.modifiedBy, main.createdBy)
			,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
			,main.approvedBy
			,main.approvedDate
		FROM exRateTreasury main WITH(NOLOCK)
		INNER JOIN #exRateIdTemp erit ON main.exRateTreasuryId = erit.exRateTreasuryId
		LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
		LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
		LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
		LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
		LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
		ORDER BY cCountryName, cAgent, pCountryName, pAgent
						--AND ISNULL(main.isUpdated, ''N'') <> ''Y''
	END
	
	ELSE IF @flag = 'ai'				--Set Active Inactive
	BEGIN
		IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @exRateTreasuryId
			RETURN
		END
		
		INSERT INTO #exRateIdTemp
		SELECT value FROM dbo.Split(',', @exRateTreasuryIds)
		
		BEGIN TRANSACTION
			--1. Set Active/Inactive to unapproved main table record
			UPDATE exRateTreasury SET
				 isActive			= @isActive
				,isUpdated			= 'Y'
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			FROM exRateTreasury ert
			INNER JOIN #exRateIdTemp erit ON ert.exRateTreasuryId = erit.exRateTreasuryId AND ert.approvedBy IS NULL
			
			--2. Delete From Mod table
			DELETE FROM exRateTreasuryMod 
			FROM exRateTreasuryMod ertm
			INNER JOIN #exRateIdTemp erit ON ertm.exRateTreasuryId = erit.exRateTreasuryId
			
			--3. Insert changes to Mod table
			INSERT INTO exRateTreasuryMod(						
				 exRateTreasuryId
				,tranType
				,cRateId
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,cAgentMargin
				,pRateId
				,pCurrency
				,pCountry
				,pAgent
				,pRateFactor
				,pRate
				,pMargin
				,pHoMargin
				,pAgentMargin
				,sharingType
				,sharingValue
				,toleranceOn
				,agentTolMin
				,agentTolMax
				,customerTolMin
				,customerTolMax
				,maxCrossRate
				,crossRate
				,customerRate
				,tolerance
				,isActive
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 ert.exRateTreasuryId
				,tranType
				,cRateId
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,cAgentMargin
				,pRateId
				,pCurrency
				,pCountry
				,pAgent
				,pRateFactor
				,pRate
				,pMargin
				,pHoMargin
				,pAgentMargin
				,sharingType
				,sharingValue
				,toleranceOn
				,agentTolMin
				,agentTolMax
				,customerTolMin
				,customerTolMax
				,maxCrossRate
				,crossRate
				,customerRate
				,tolerance
				,@isActive
				,@user
				,GETDATE()
				,'U'
			FROM exRateTreasury ert WITH(NOLOCK)
			INNER JOIN #exRateIdTemp erit WITH(NOLOCK) ON ert.exRateTreasuryId = erit.exRateTreasuryId AND approvedBy IS NOT NULL
			
			UPDATE exRateTreasury SET
				isUpdated			= 'Y'
			FROM exRateTreasury ert
			INNER JOIN #exRateIdTemp erit ON ert.exRateTreasuryId = erit.exRateTreasuryId
					
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		IF @isActive = 'Y'
			SET @msg = 'Record(s) set active'
		ELSE
			SET @msg = 'Record(s) set inactive'
		EXEC proc_errorHandler 0, @msg, @exRateTreasuryIds		
	END
	
	/*
	ELSE IF @flag = 'cl'				--Copy List
	BEGIN	
		--EXEC proc_exRateTreasury @flag = 'cl', @cCountry = 133, @applyFor = 'C'
		SET @table = '
			SELECT
				 exRateTreasuryId = main.exRateTreasuryId
				,tranType = ISNULL(tt.typeTitle, ''All'')
				,cCountry = main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,cAgent = main.cAgent
				,cAgentName = ISNULL(cam.agentName, ''All'')
				,pCountry = main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,pAgent = main.pAgent
				,pAgentName = ISNULL(pam.agentName, ''All'')
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
				,sharingType = main.sharingType
				,sharingValue = main.sharingValue
				,toleranceOn = main.toleranceOn
				,agentTolMin = main.agentTolMin
				,agentTolMax = main.agentTolMax
				,customerTolMin = main.customerTolMin
				,customerTolMax = main.customerTolMax
				,maxCrossRate = main.maxCrossRate
				,crossRate = main.crossRate
				,customerRate = main.customerRate
				,tolerance = main.tolerance	
				
				,cost = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)), crm.rateMaskMulAd)
				,margin = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)) - main.cRate, crm.rateMaskMulAd)
								
				,[status] = CASE WHEN ISNULL(main.isActive, ''N'') = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
				
				,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE ''U'' END		
				,main.createdBy
				,main.createdDate
				,modifiedBy = ISNULL(main.modifiedBy, main.createdBy)
				,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
				,main.approvedBy
				,main.approvedDate
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
			WHERE ISNULL(main.isActive, ''N'') = ''Y'' AND main.approvedBy IS NOT NULL
			'
		
		IF @cCountry IS NOT NULL
			SET @table = @table + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR)
		
		IF @applyFor = 'C'
		BEGIN
			IF @cAgent IS NULL AND @cCountry IS NOT NULL
				SET @table = @table + ' AND cAgent IS NULL'
			ELSE IF @cAgent IS NULL AND @cCountry IS NULL
				SET @table = @table
			ELSE
				SET @table = @table + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR)
			
			IF @pAgent IS NOT NULL
				SET @table = @table + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR)
		END
		ELSE
		BEGIN
			IF @cAgent IS NOT NULL
				SET @table = @table + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR)
			
			IF @pAgent IS NULL AND @pCountry IS NOT NULL
				SET @table = @table + ' AND pAgent IS NULL'
			ELSE IF @pAgent IS NULL AND @pCountry IS NULL
				SET @table = @table
			ELSE IF @pAgent IS NOT NULL
				SET @table = @table + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR)
		END
		
		IF @pCountry IS NOT NULL
			SET @table = @table + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR)
			
		SET @table = @table + (CASE WHEN @applyFor = 'C' THEN ' ORDER BY pCountryName, pAgent, cCountryName, cAgent' ELSE ' ORDER BY cCountryName, cAgent, pCountryName, pAgent' END) 
		
		EXEC(@table)
		--PRINT(@table)
	END
	*/
	
	ELSE IF @flag = 'cl'				--Copy List
	BEGIN
		--EXEC proc_exRateTreasury @flag = 'cl', @cCountry = 133, @applyFor = 'C'
		DECLARE @applyAgentName VARCHAR(100)
		SELECT @applyAgent = agentId, @applyAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @applyAgent 
		
		IF @applyFor = 'c'
		BEGIN
			IF EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE agent = @applyAgent AND ISNULL(isActive, 'N') = 'Y')
			BEGIN
				SELECT @cRate = cRate, @cMargin = ISNULL(cMargin, 0)
				FROM defExRate def WITH(NOLOCK)
				WHERE agent = @applyAgent AND ISNULL(def.isActive, 'N') = 'Y'
			END
			ELSE
			BEGIN
				SELECT @cRate = cRate, @cMargin = ISNULL(cMargin, 0)
				FROM defExRate def WITH(NOLOCK)
				WHERE country = @cCountry AND agent IS NULL AND ISNULL(def.isActive, 'N') = 'Y'
			END
			
			--SELECT @applyAgent, @applyAgentName, @cRate, @cMargin
			--RETURN
			SET @table = '
				SELECT
					 exRateTreasuryId = main.exRateTreasuryId
					,tranType = ISNULL(tt.typeTitle, ''All'')
					,cCountry = main.cCountry
					,cCountryName = cc.countryName
					,cCountryCode = cc.countryCode
					,cAgent = ' + CAST(@applyAgent AS VARCHAR) + '
					,cAgentName = ''' + @applyAgentName + '''
					,pCountry = main.pCountry
					,pCountryName = pc.countryName
					,pCountryCode = pc.countryCode
					,pAgent = main.pAgent
					,pAgentName = ISNULL(pam.agentName, ''[All]'')
					,cCurrency = main.cCurrency
					,pCurrency = main.pCurrency
					,cRateFactor = main.cRateFactor
					,pRateFactor = main.pRateFactor
					,cRate = ' + CAST(@cRate AS VARCHAR) + '
					,cMargin = ' + CAST(@cMargin AS VARCHAR) + '
					,cHoMargin = main.cHoMargin
					,cAgentMargin = main.cAgentMargin
					,pRate = main.pRate
					,pMargin = main.pMargin
					,pHoMargin = main.pHoMargin
					,pAgentMargin = main.pAgentMargin
					,sharingType = main.sharingType
					,sharingValue = main.sharingValue
					,toleranceOn = main.toleranceOn
					,agentTolMin = main.agentTolMin
					,agentTolMax = main.agentTolMax
					,customerTolMin = main.customerTolMin
					,customerTolMax = main.customerTolMax
					,maxCrossRate = main.maxCrossRate
					,crossRate = main.crossRate
					,customerRate = main.customerRate
					,tolerance = main.tolerance	
					
					,cost = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)), crm.rateMaskMulAd)
					,margin = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)) - ' + CAST(@cRate AS VARCHAR) + ', crm.rateMaskMulAd)
									
					,[status] = CASE WHEN ISNULL(main.isActive, ''N'') = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
					
					,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE ''U'' END		
					,main.createdBy
					,main.createdDate
					,modifiedBy = ISNULL(main.modifiedBy, main.createdBy)
					,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
					,main.approvedBy
					,main.approvedDate
				FROM exRateTreasury main WITH(NOLOCK)
				LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
				LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
				LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
				LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
				LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
				LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
				WHERE ISNULL(main.isActive, ''N'') = ''Y'' AND main.approvedBy IS NOT NULL
				'
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE agent = @applyAgent AND ISNULL(isActive, 'N') = 'Y')
			BEGIN
				SELECT @pRate = pRate, @pMargin = ISNULL(pMargin, 0)
				FROM defExRate def WITH(NOLOCK)
				WHERE agent = @applyAgent AND ISNULL(def.isActive, 'N') = 'Y'
			END
			ELSE
			BEGIN
				SELECT @pRate = pRate, @pMargin = ISNULL(pMargin, 0)
				FROM defExRate def WITH(NOLOCK)
				WHERE country = @pCountry AND agent IS NULL AND ISNULL(def.isActive, 'N') = 'Y'
			END
			
			--SELECT @applyAgent, @applyAgentName, @cRate, @cMargin
			--RETURN
			SET @table = '
				SELECT
					 exRateTreasuryId = main.exRateTreasuryId
					,tranType = ISNULL(tt.typeTitle, ''All'')
					,cCountry = main.cCountry
					,cCountryName = cc.countryName
					,cCountryCode = cc.countryCode
					,cAgent = main.cAgent
					,cAgentName = ISNULL(cam.agentName, ''[All]'')
					,pCountry = main.pCountry
					,pCountryName = pc.countryName
					,pCountryCode = pc.countryCode
					,pAgent = ' + CAST(@applyAgent AS VARCHAR) + '
					,pAgentName = ISNULL(pam.agentName, ''[All]'')
					,cCurrency = main.cCurrency
					,pCurrency = main.pCurrency
					,cRateFactor = main.cRateFactor
					,pRateFactor = main.pRateFactor
					,cRate = main.cRate
					,cMargin = main.cMargin
					,cHoMargin = main.cHoMargin
					,cAgentMargin = main.cAgentMargin
					,pRate = ' + CAST(@pRate AS VARCHAR) + '
					,pMargin = ' + CAST(@pMargin AS VARCHAR) + '
					,pHoMargin = main.pHoMargin
					,pAgentMargin = main.pAgentMargin
					,sharingType = main.sharingType
					,sharingValue = main.sharingValue
					,toleranceOn = main.toleranceOn
					,agentTolMin = main.agentTolMin
					,agentTolMax = main.agentTolMax
					,customerTolMin = main.customerTolMin
					,customerTolMax = main.customerTolMax
					,maxCrossRate = main.maxCrossRate
					,crossRate = main.crossRate
					,customerRate = main.customerRate
					,tolerance = main.tolerance	
					
					,cost = ROUND(' + CAST(@pRate AS VARCHAR) + '/(main.crossRate + ISNULL(main.tolerance, 0)), crm.rateMaskMulAd)
					,margin = ROUND(' + CAST(@pRate AS VARCHAR) + '/(main.crossRate + ISNULL(main.tolerance, 0)) - main.cRate, crm.rateMaskMulAd)
									
					,[status] = CASE WHEN ISNULL(main.isActive, ''N'') = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
					
					,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE ''U'' END		
					,main.createdBy
					,main.createdDate
					,modifiedBy = ISNULL(main.modifiedBy, main.createdBy)
					,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
					,main.approvedBy
					,main.approvedDate
				FROM exRateTreasury main WITH(NOLOCK)
				LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
				LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
				LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
				LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
				LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
				LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
				WHERE ISNULL(main.isActive, ''N'') = ''Y'' AND main.approvedBy IS NOT NULL
				'
		END
		
		IF @cCountry IS NOT NULL
			SET @table = @table + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR)
		
		IF @applyFor = 'C'
		BEGIN
			IF @cAgent IS NULL AND @cCountry IS NOT NULL
				SET @table = @table + ' AND cAgent IS NULL'
			ELSE IF @cAgent IS NULL AND @cCountry IS NULL
				SET @table = @table
			ELSE
				SET @table = @table + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR)
			
			IF @pAgent IS NOT NULL
				SET @table = @table + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR)
		END
		ELSE
		BEGIN
			IF @cAgent IS NOT NULL
				SET @table = @table + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR)
			
			IF @pAgent IS NULL AND @pCountry IS NOT NULL
				SET @table = @table + ' AND pAgent IS NULL'
			ELSE IF @pAgent IS NULL AND @pCountry IS NULL
				SET @table = @table
			ELSE IF @pAgent IS NOT NULL
				SET @table = @table + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR)
		END
		
		IF @pCountry IS NOT NULL
			SET @table = @table + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR)
			
		SET @table = @table + (CASE WHEN @applyFor = 'C' THEN ' ORDER BY pCountryName, pAgent, cCountryName, cAgent' ELSE ' ORDER BY cCountryName, cAgent, pCountryName, pAgent' END) 
		
		PRINT(@table)
		EXEC(@table)
	END
	
	ELSE IF @flag = 'copy'				--Copy
	BEGIN
		INSERT INTO #exRateIdTemp
		SELECT value FROM dbo.Split(',', @exRateTreasuryIds)
		
		BEGIN TRANSACTION
			IF @applyFor = 'C'
			BEGIN
				SELECT @cCountry = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @applyAgent
				IF EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE agent = @applyAgent AND ISNULL(isActive, 'N') = 'Y')
				BEGIN
					SELECT @cRateId = defExRateId, @cRate = cRate, @cMargin = ISNULL(cMargin, 0)
					FROM defExRate def WITH(NOLOCK)
					WHERE agent = @applyAgent AND ISNULL(def.isActive, 'N') = 'Y'
				END
				ELSE
				BEGIN
					SELECT @cRateId = defExRateId, @cRate = cRate, @cMargin = ISNULL(cMargin, 0)
					FROM defExRate def WITH(NOLOCK)
					WHERE country = @cCountry AND agent IS NULL AND ISNULL(def.isActive, 'N') = 'Y'
				END
				
				--1. Copy Selected value to temp table----------------------------------------------------------------------------
				SELECT
					 tranType
					,cRateId = @cRateId,cCountry,cAgent = @applyAgent,cCurrency,cRateFactor,cRate = @cRate,cMargin = @cMargin,cHoMargin,cAgentMargin
					,pRateId,pCountry,pAgent,pCurrency,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
					,sharingType,sharingValue,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
					,crossRate = ROUND((pRate - pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,maxCrossRate = ROUND(pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,customerRate = ROUND((pRate - pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,tolerance,crossRateFactor
					,isUpdated,isUpdatedOperation
					,createdBy = @user
					,createdDate = GETDATE()
				INTO #tempCAgentRate
				FROM exRateTreasury main WITH(NOLOCK)
				
				INNER JOIN #exRateIdTemp erit ON main.exRateTreasuryId = erit.exRateTreasuryId
				--END-------------------------------------------------------------------------------------------------------------
				
				--2. Delete already exist setting from temp table-----------------------------------------------------------------
				DELETE FROM #tempCAgentRate
				FROM #tempCAgentRate tmp
				INNER JOIN exRateTreasury main
				ON main.cCountry = tmp.cCountry AND main.cAgent = tmp.cAgent
				AND main.pCountry = tmp.pCountry AND ISNULL(main.pAgent, 0) = ISNULL(tmp.pAgent, 0)
				--END-------------------------------------------------------------------------------------------------------------
				
				--3. Copy setting to main table from temp table-------------------------------------------------------------------
				IF EXISTS(SELECT 'X' FROM #tempCAgentRate)
				BEGIN
					INSERT INTO exRateTreasury(
						 tranType
						,cRateId,cCountry,cAgent,cCurrency,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pRateId,pCountry,pAgent,pCurrency,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingType,sharingValue,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,crossRate,maxCrossRate,customerRate,tolerance,crossRateFactor
						,isUpdated,isUpdatedOperation
						,createdBy
						,createdDate
					)
					SELECT * FROM #tempCAgentRate
				END
				--END-------------------------------------------------------------------------------------------------------------
			END
			ELSE IF @applyFor = 'P'
			BEGIN
				SELECT @pCountry = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @applyAgent
				IF EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE agent = @applyAgent AND ISNULL(isActive, 'N') = 'Y')
				BEGIN
					SELECT @pRateId = defExRateId, @pRate = pRate, @pMargin = ISNULL(pMargin, 0)
					FROM defExRate def WITH(NOLOCK)
					WHERE agent = @applyAgent AND ISNULL(def.isActive, 'N') = 'Y'
				END
				ELSE
				BEGIN
					SELECT @pRateId = defExRateId, @pRate = pRate, @pMargin = ISNULL(pMargin, 0)
					FROM defExRate def WITH(NOLOCK)
					WHERE country = @pCountry AND agent IS NULL AND ISNULL(def.isActive, 'N') = 'Y'
				END
				--1. Copy Selected value to temp table----------------------------------------------------------------------------
				SELECT
					 tranType
					,cRateId,cCountry,cAgent,cCurrency,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
					,pRateId = @pRateId,pCountry,pAgent = @applyAgent,pCurrency,pRateFactor,pRate = @pRate,pMargin = @pMargin,pHoMargin,pAgentMargin
					,sharingType,sharingValue,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
					,crossRate = ROUND((@pRate - @pMargin - pHoMargin)/(cRate + cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,maxCrossRate = ROUND(@pRate/cRate, dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,customerRate = ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(cRate + cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,tolerance,crossRateFactor
					,isUpdated,isUpdatedOperation
					,createdBy = @user
					,createdDate = GETDATE() 
				INTO #tempPAgentRate
				FROM exRateTreasury main WITH(NOLOCK)
				INNER JOIN #exRateIdTemp erit ON main.exRateTreasuryId = erit.exRateTreasuryId
				--END-------------------------------------------------------------------------------------------------------------
				
				--2. Delete already exist setting from temp table-----------------------------------------------------------------
				DELETE FROM #tempPAgentRate
				FROM #tempPAgentRate tmp 
				INNER JOIN exRateTreasury main 
				ON main.cCountry = tmp.cCountry AND ISNULL(main.cAgent, 0) = ISNULL(tmp.cAgent, 0)
				AND main.pCountry = tmp.pCountry AND main.pAgent = tmp.pAgent
				--END-------------------------------------------------------------------------------------------------------------

				--3. Copy setting to main table from temp table-------------------------------------------------------------------				
				IF EXISTS(SELECT 'X' FROM #tempPAgentRate)
				BEGIN
					INSERT INTO exRateTreasury(
						 tranType
						,cRateId,cCountry,cAgent,cCurrency,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
						,pRateId,pCountry,pAgent,pCurrency,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
						,sharingType,sharingValue,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
						,crossRate,maxCrossRate,customerRate,tolerance,crossRateFactor
						,isUpdated,isUpdatedOperation
						,createdBy
						,createdDate
					)
					SELECT * FROM #tempPAgentRate
				END
				--END-------------------------------------------------------------------------------------------------------------
			END
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		IF @applyFor = 'C'
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM #tempCAgentRate)
			BEGIN
				EXEC proc_errorHandler 1, 'Selected rate setting(s) already exist in the system', NULL
				RETURN
			END
		END
		ELSE IF @applyFor = 'P'
		BEGIN
			IF NOT EXISTS(SELECT 'X' FROM #tempPAgentRate)
			BEGIN
				EXEC proc_errorHandler 1, 'Selected rate setting(s) already exist in the system', NULL
				RETURN
			END
		END
		EXEC proc_errorHandler 0, 'Rate setting(s) applied successfully', NULL
	END
	
	ELSE IF @flag = 'cs'				--Copy Summary
	BEGIN
		INSERT INTO #exRateIdTemp
		SELECT value FROM dbo.Split(',', @exRateTreasuryIds)
		
		SET @table = '
			SELECT
				 exRateTreasuryId = main.exRateTreasuryId
				,tranType = ISNULL(tt.typeTitle, ''All'')
				,cCountry = main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,cAgent = main.cAgent
				,cAgentName = ISNULL(cam.agentName, ''All'')
				,pCountry = main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,pAgent = main.pAgent
				,pAgentName = ISNULL(pam.agentName, ''All'')
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
				,sharingType = main.sharingType
				,sharingValue = main.sharingValue
				,toleranceOn = main.toleranceOn
				,agentTolMin = main.agentTolMin
				,agentTolMax = main.agentTolMax
				,customerTolMin = main.customerTolMin
				,customerTolMax = main.customerTolMax
				,maxCrossRate = main.maxCrossRate
				,crossRate = main.crossRate
				,customerRate = main.customerRate
				,tolerance = main.tolerance	
				
				,cost = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)), crm.rateMaskMulAd)
				,margin = ROUND(main.pRate/(main.crossRate + ISNULL(main.tolerance, 0)) - main.cRate, crm.rateMaskMulAd)
								
				,[status] = CASE WHEN ISNULL(main.isActive, ''N'') = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
				
				,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE ''U'' END		
				,main.createdBy
				,main.createdDate
				,modifiedBy = ISNULL(main.modifiedBy, main.createdBy)
				,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
				,main.approvedBy
				,main.approvedDate
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
			WHERE DATEDIFF(S, main.createdDate, GETDATE()) < 15 AND main.approvedBy IS NULL AND ' + (CASE WHEN @applyFor = 'C' THEN ' main.cAgent = ' + CAST(@applyAgent AS VARCHAR) + ' ORDER BY pCountryName, pAgent, cCountryName, cAgent ' ELSE ' main.pAgent = ' +



 CAST(@applyAgent AS VARCHAR) + ' ORDER BY cCountryName, cAgent, pCountryName, pAgent' END) + '
			'
		
		--PRINT @table
		EXEC (@table)
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @exRateTreasuryId
END CATCH




