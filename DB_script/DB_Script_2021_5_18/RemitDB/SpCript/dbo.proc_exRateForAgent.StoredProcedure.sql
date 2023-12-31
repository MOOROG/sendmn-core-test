USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_exRateForAgent]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_exRateForAgent]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)
	,@exRateTreasuryId					VARCHAR(30)		= NULL
	,@exRateTreasuryIds					VARCHAR(MAX)	= NULL
	,@tranType							INT				= NULL
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
	,@customerRate						FLOAT			= NULL
	,@tolerance							FLOAT			= NULL
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
	
	DECLARE @rateIdList TABLE(rowId INT IDENTITY(1,1), exRateTreasuryId INT)	
	DECLARE @rateMaskAd INT, @colMaskAd INT
	DECLARE @tolMax FLOAT, @tolMin FLOAT, @msg VARCHAR(MAX)
	DECLARE @exRateHistoryId BIGINT, @date DATETIME = GETDATE()
	
	SELECT
		 @logIdentifier = 'exRateTreasuryId'
		,@logParamMain = 'exRateTreasury'
		,@logParamMod = 'exRateTreasuryHistory'
		,@module = '20'
		,@tableAlias = 'Exchange Rate V1'
		,@ApprovedFunctionId = 20111330
	
	DECLARE @cDefExRateId INT, @pDefExRateId INT, @errorMsg VARCHAR(200)
	DECLARE @cOffer FLOAT, @pOffer FLOAT, @cCustomerOffer FLOAT, @pCustomerOffer FLOAT
	
	
	IF @flag = 'lr'
	BEGIN
		DECLARE @defExRateId INT, @agentCountryId INT, @agentOperationType CHAR(1)
		SELECT @agentCountryId = agentCountryId, @agentOperationType = agentRole FROM agentMaster WITH(NOLOCK) WHERE agentId = @agent
		
		SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent = @agent AND country = @agentCountryId
		IF @defExRateId IS NULL
			SELECT @defExRateId = defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND agent IS NULL AND country = @agentCountryId
		
		SELECT 
			 cRate = ag.cRate
			,pRate = ag.pRate
			,ag.currency
			,rm.cMin
			,rm.cMax
			,rm.pMin
			,rm.pMax
			,rateMaskBd = ISNULL(CASE WHEN ag.factor = 'M' THEN rm.rateMaskMulBd ELSE rm.rateMaskDivBd END, 6)
			,rateMaskAd = ISNULL(CASE WHEN ag.factor = 'M' THEN rm.rateMaskMulAd ELSE rm.rateMaskDivAd END, 6)
			,agentOperationType = @agentOperationType
		FROM defExRate ag WITH(NOLOCK)
		LEFT JOIN rateMask rm WITH(NOLOCK) ON ag.currency = rm.currency
		WHERE defExRateId = @defExRateId
	END
	
	ELSE IF @flag = 'crdm'		--Cross Rate Decimal Mask
	BEGIN
		SELECT ISNULL(rateMaskAd, 6) FROM crossRateDecimalMask WITH(NOLOCK) WHERE cCurrency = @cCurrency AND pCurrency = @pCurrency
	END
	
	ELSE IF @flag IN ('s')		
	BEGIN
		--IF @sortBy IS NULL
			SET @sortBy = 'pCountryName,pAgentName'
		--IF @sortOrder IS NULL
		   SET @sortOrder = ''	
		
		DECLARE @m VARCHAR(MAX)
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
						,crossRateFactor = main.crossRateFactor		
						,main.createdBy
						,main.createdDate
						,lastModifiedBy = ISNULL(main.modifiedBy, main.createdBy)
						,lastModifiedDate = ISNULL(main.modifiedDate, main.createdDate)
					FROM exRateTreasury main WITH(NOLOCK)
					WHERE cAgent = ' + CAST(@cAgent AS VARCHAR) + ' AND ISNULL(main.isActive, ''N'') = ''Y'' AND main.approvedBy IS NOT NULL
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
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
							,main.crossRateFactor
							,cMin = crm.cMin
							,cMax = crm.cMax
							,pMin = prm.pMin
							,pMax = prm.pMax
							,cRateMaskMulBd = ISNULL(CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulBd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivBd END, 6)
							,cRateMaskMulAd = ISNULL(CASE WHEN main.cRateFactor = ''M'' THEN crm.rateMaskMulAd WHEN main.cRateFactor = ''D'' THEN crm.rateMaskDivAd END, 6)
							,pRateMaskMulBd = ISNULL(CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulBd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivBd END, 6)
							,pRateMaskMulAd = ISNULL(CASE WHEN main.pRateFactor = ''M'' THEN prm.rateMaskMulAd WHEN main.pRateFactor = ''D'' THEN prm.rateMaskDivAd END, 6)
							,crossRateMaskAd = dbo.FNAGetCrossRateDecimalMask(main.cCurrency, main.pCurrency)	
							,lastModifiedBy = CASE WHEN au.agentId = 1001 THEN ''IME HO'' ELSE main.lastModifiedBy END
							,main.lastModifiedDate
						FROM ' + @m + ' main
						INNER JOIN applicationUsers au WITH(NOLOCK) ON main.lastModifiedBy = au.userName
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						LEFT JOIN rateMask prm WITH(NOLOCK) ON main.pCurrency = prm.currency AND ISNULL(prm.isActive, ''N'') = ''Y''
						LEFT JOIN crossRateDecimalMask crdm WITH(NOLOCK) ON main.cCurrency = crdm.cCurrency AND main.pCurrency = crdm.pCurrency
						WHERE 1 = 1
						
						'
							
		SET @table =  @table + ') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		
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
			,cost
			,margin
			,crossRateFactor
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

	ELSE IF @flag = 'uscr'		--Update Agent Send Cost Rate
	BEGIN
		SELECT @defExRateId = defExRateId, @currency = currency, @cRateFactor = factor FROM defExRate WITH(NOLOCK) WHERE setupType = 'AG' AND agent = @agent AND ISNULL(isActive, 'N') = 'Y'
		SELECT @tolMin = cMin, @tolMax = cMax FROM rateMask WITH(NOLOCK) WHERE currency = @currency AND ISNULL(isActive, 'N') = 'Y'
		
		IF @cRate > @tolMax
		BEGIN
			SET @msg = 'Change in send cost rate exceeded the max cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF @cRate < @tolMin
		BEGIN
			SET @msg = 'Change in send cost rate deceeded the min cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE (@cRate + cMargin + cHoMargin + cAgentMargin) > @tolMax AND cCurrency = @currency AND cAgent = @agent)
		BEGIN
			SET @msg = 'Change in send cost rate exceeded the max cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE (@cRate + cMargin + cHoMargin + cAgentMargin) < @tolMin AND cCurrency = @currency AND cAgent = @agent)
		BEGIN
			SET @msg = 'Change in send cost rate deceeded the min cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		SELECT @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END FROM rateMask WHERE currency = @currency
		
		BEGIN TRANSACTION
			UPDATE defExRate SET
				 cRate = @cRate
				,modifiedBy = @user
				,modifiedDate = @date
			WHERE defExRateId = @defExRateId
			
			--Send Cost History--------------------------------------------------------------------------------------------------------
			INSERT INTO defExRateHistory(
				 defExRateId,currency,country,agent
				,cRate,cMargin,cMin,cMax
				,pRate,pMargin,pMin,pMax
				,factor,isEnable,modType
				,createdBy,createdDate,approvedBy,approvedDate
			)
			SELECT
				 defExRateId,currency,country,agent
				,@cRate,cMargin,cMin,cMax
				,pRate,pMargin,pMin,pMax
				,factor,isEnable,'U'
				,@user,@date,@user,@date
			FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId
			
			--Treasury Rate History------------------------------------------------------------------------------------------------------
			INSERT INTO exRateTreasuryHistory(
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingType,sharingValue
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,crossRate
				,customerRate
				,maxCrossRate
				,tolerance
				,crossRateFactor
				,modType,createdBy,createdDate, approvedBy, approvedDate
			)
			SELECT 
				 exRateTreasuryId
				,ert.cCurrency,cCountry,cAgent,cRateFactor,@cRate,cMargin,cHoMargin,cAgentMargin
				,ert.pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,ert.sharingType,ert.sharingValue
				,ert.toleranceOn,ert.agentTolMin,ert.agentTolMax,ert.customerTolMin,ert.customerTolMax
				,ROUND((pRate - pMargin - pHoMargin)/(@cRate + cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ROUND((pRate - pMargin - pHoMargin - pAgentMargin)/(@cRate + cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ROUND(pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,tolerance
				,crossRateFactor
				,'U',@user,@date,@user,@date
			FROM exRateTreasury ert WITH(NOLOCK)
			WHERE ert.cRateId = @defExRateId
			
			UPDATE ert SET
				 ert.cRate				= @cRate
				,ert.maxCrossRate		= ROUND(ert.pRate/(@cRate), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ert.crossRate			= ROUND((ert.pRate - ert.pMargin - ert.pHoMargin)/(@cRate + ert.cMargin + ert.cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ert.customerRate		= ROUND((ert.pRate - ert.pMargin - ert.pHoMargin - ert.pAgentMargin)/(@cRate + ert.cMargin + ert.cHoMargin + ert.cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ert.modifiedBy			= @user
				,ert.modifiedDate		= @date
				,ert.exRateHistoryId	= erth.rowId
			FROM exRateTreasury ert
			INNER JOIN exRateTreasuryHistory erth ON ert.exRateTreasuryId = erth.exRateTreasuryId AND erth.createdBy = @user AND erth.createdDate = @date
			WHERE ert.cRateId = @defExRateId AND ISNULL(ert.isActive, 'N') = 'Y'
			
			IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE cRateId = @defExRateId)
			BEGIN
				UPDATE ertMod SET
					 ertMod.cRate				= @cRate
					,ertMod.maxCrossRate		= ROUND(pRate/(@cRate), dbo.FNAGetCrossRateDecimalMask(ertMod.cCurrency, ertMod.pCurrency))
					,ertMod.crossRate			= ROUND((pRate - pMargin - pHoMargin)/(@cRate + cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ertMod.cCurrency, ertMod.pCurrency))
					,ertMod.customerRate		= ROUND((pRate - pMargin - pHoMargin - pAgentMargin)/(@cRate + cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ertMod.cCurrency, ertMod.pCurrency))
				FROM exRateTreasuryMod ertMod
				WHERE ertMod.cRateId = @defExRateId
			END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Send cost rate updated successfully', NULL
		
	END
	
	ELSE IF @flag = 'urcr'		--Update Agent Receive Cost Rate
	BEGIN
		SELECT @defExRateId = defExRateId, @currency = currency FROM defExRate WITH(NOLOCK) WHERE setupType = 'AG' AND agent = @agent AND ISNULL(isActive, 'N') = 'Y'
		SELECT @tolMin = pMin, @tolMax = pMax FROM rateMask WITH(NOLOCK) WHERE currency = @currency AND ISNULL(isActive, 'N') = 'Y'
		
		IF @pRate > @tolMax
		BEGIN
			SET @msg = 'Change in receive cost rate exceeded the max cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF @pRate < @tolMin
		BEGIN
			SET @msg = 'Change in receive cost rate deceeded the min cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE (@pRate - pMargin - pHoMargin - pAgentMargin) > @tolMax)
		BEGIN
			SET @msg = 'Change in receive cost rate exceeded the max cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE (@pRate - pMargin - pHoMargin - pAgentMargin) < @tolMin)
		BEGIN
			SET @msg = 'Change in receive cost rate deceeded the min cost rate. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		SELECT @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END FROM rateMask WHERE currency = @currency
		
		BEGIN TRANSACTION
			UPDATE defExRate SET
				 pRate = @pRate
				,modifiedBy = @user
				,modifiedDate = @date
			WHERE defExRateId = @defExRateId
			
			--Receive Cost History-----------------------------------------------------------------------------------------------------
			INSERT INTO defExRateHistory(
				 defExRateId,currency,country,agent
				,cRate,cMargin,cMin,cMax
				,pRate,pMargin,pMin,pMax
				,factor,isEnable,modType
				,createdBy,createdDate,approvedBy,approvedDate
			)
			SELECT
				 defExRateId,currency,country,agent
				,cRate,cMargin,cMin,cMax
				,@pRate,pMargin,pMin,pMax
				,factor,isEnable,'U'
				,@user,@date,@user,@date
			FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId
			
			--Treasury Rate History------------------------------------------------------------------------------------------------------
			INSERT INTO exRateTreasuryHistory(
				 exRateTreasuryId
				,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
				,sharingType,sharingValue
				,toleranceOn,agentTolMin,agentTolMax,customerTolMin,customerTolMax
				,crossRate
				,customerRate
				,maxCrossRate
				,tolerance
				,crossRateFactor
				,modType,createdBy,createdDate, approvedBy, approvedDate
			)
			SELECT 
				 exRateTreasuryId
				,ert.cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
				,ert.pCurrency,pCountry,pAgent,pRateFactor,@pRate,pMargin,pHoMargin,pAgentMargin
				,ert.sharingType,ert.sharingValue
				,ert.toleranceOn,ert.agentTolMin,ert.agentTolMax,ert.customerTolMin,ert.customerTolMax
				,ROUND((@pRate - pMargin - pHoMargin)/(cRate + cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ROUND((@pRate - pMargin - pHoMargin - pAgentMargin)/(cRate + cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ROUND(@pRate/cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,tolerance
				,crossRateFactor
				,'U',@user,@date,@user,@date
			FROM exRateTreasury ert WITH(NOLOCK)
			WHERE ert.pRateId = @defExRateId
			
			UPDATE ert SET
				 ert.pRate				= @pRate
				,ert.maxCrossRate		= ROUND(@pRate/ert.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ert.crossRate			= ROUND((@pRate - ert.pMargin - ert.pHoMargin)/(ert.cRate + ert.cMargin + ert.cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ert.crossRateOperation = ROUND((@pRate - ert.pMargin - ert.pHoMargin)/(ert.cRate + ert.cMargin + ert.cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ert.customerRate		= ROUND((@pRate - ert.pMargin - ert.pHoMargin - ert.pAgentMargin)/(ert.cRate + ert.cMargin + ert.cHoMargin + ert.cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
				,ert.modifiedBy			= @user
				,ert.modifiedDate		= @date
			FROM exRateTreasury ert
			INNER JOIN exRateTreasuryHistory erth ON ert.exRateTreasuryId = erth.exRateTreasuryId AND erth.createdBy = @user AND erth.createdDate = @date
			WHERE ert.pRateId = @defExRateId AND ISNULL(ert.isActive, 'N') = 'Y'
			
			UPDATE ertMod SET
				 ertMod.pRate				= @pRate
				,ertMod.maxCrossRate		= ROUND(@pRate/cRate, dbo.FNAGetCrossRateDecimalMask(ertMod.cCurrency, ertMod.pCurrency))
				,ertMod.crossRate			= ROUND((@pRate - pMargin - pHoMargin)/(cRate + cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ertMod.cCurrency, ertMod.pCurrency))
				,ertMod.customerRate		= ROUND((@pRate - pMargin - pHoMargin - pAgentMargin)/(cRate + cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ertMod.cCurrency, ertMod.pCurrency))
			FROM exRateTreasuryMod ertMod
			WHERE ertMod.pRateId = @defExRateId
			
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Receive cost rate updated successfully', NULL
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		DECLARE @agentCrossRate FLOAT, @crossRateMargin FLOAT, @minCustomerRate FLOAT, @maxCustomerRate FLOAT
		SELECT 
			 @cRateFactor = cRateFactor, @cCurrency = cCurrency, @pCurrency = pCurrency
			,@cMargin = cMargin, @cHoMargin = cHoMargin
			,@pRate = pRate, @pMargin = pMargin, @pHoMargin = pHoMargin, @pAgentMargin = pAgentMargin
			,@tolerance = tolerance
			,@agentTolMin = agentTolMin, @agentTolMax = agentTolMax, @agentCrossRate = crossRate
			,@customerTolMin = customerTolMin, @customerTolMax = customerTolMax
		FROM exRateTreasury WITH(NOLOCK) 
		WHERE exRateTreasuryId = @exRateTreasuryId
		
		SELECT 
			 @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END
			,@tolMin = cMin
			,@tolMax = cMax 
		FROM rateMask WITH(NOLOCK) WHERE currency = @cCurrency
		SELECT @rateMaskAd = dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency)
		
		DECLARE @cost FLOAT
		SET @cost = ROUND((@pRate - @pMargin - @pHoMargin - @pAgentMargin)/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd) 
		--SET @cost = ROUND(@pRate/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd)
		
		IF @cost > @tolMax
		BEGIN
			SET @msg = 'Cost rate violates defined tolerance. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @cost < @tolMin
		BEGIN
			SET @msg = 'Cost rate violates defined tolerance. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		SET @crossRateMargin = @agentCrossRate - @customerRate
		SET @crossRateMargin = ROUND(@crossRateMargin, 8)
		IF @crossRateMargin < (@agentTolMax * -1)
		BEGIN
			SET @msg = 'Calculated Cross Rate Margin = ' + CAST(@crossRateMargin AS VARCHAR) + ' violates defined tolerance. Cross Rate Margin must lie between ' + CAST(@customerTolMin AS VARCHAR) + ' and ' + CAST(@customerTolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @crossRateMargin > @agentTolMin
		BEGIN
			SET @msg = 'Calculated Cross Rate Margin = ' + CAST(@crossRateMargin AS VARCHAR) + ' violates defined tolerance. Cross Rate Margin must lie between ' + CAST(@customerTolMin AS VARCHAR) + ' and ' + CAST(@customerTolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		BEGIN TRANSACTION
		--Insert into history table
			INSERT INTO exRateTreasuryHistory(						
				 exRateTreasuryId
				,tranType
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,cAgentMargin
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
				,agentCrossRateMargin
				,tolerance
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
				,isActive
				,modType
			)
			SELECT
				 @exRateTreasuryId
				,tranType
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,@cAgentMargin
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
				,@customerTolMin
				,@customerTolMax
				,maxCrossRate
				,crossRate
				,@customerRate
				,@crossRateMargin
				,tolerance
				,@user
				,@date
				,@user
				,@date
				,isActive
				,'U'
			FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
			
			SET @exRateHistoryId = SCOPE_IDENTITY()
			
			--Update main table data with history Id
			UPDATE exRateTreasury SET
				 cAgentMargin			= @cAgentMargin
				,customerRate			= @customerRate
				,agentCrossRateMargin	= @crossRateMargin
				,customerTolMin			= @customerTolMin
				,customerTolMax			= @customerTolMax
				,modifiedBy				= @user
				,modifiedDate			= @date
				,exRateHistoryId		= @exRateHistoryId
			WHERE exRateTreasuryId = @exRateTreasuryId
			
			IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId)
			BEGIN
				UPDATE exRateTreasuryMod SET
					 cAgentMargin			= @cAgentMargin
					,customerRate			= CASE WHEN ISNULL(toleranceOn, '') IN ('S','R','') THEN ROUND((pRate - pMargin - pHoMargin - pAgentMargin)/(cRate + cMargin + cHoMargin + @cAgentMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
													WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((ROUND((pRate - pMargin - pHoMargin)/(cRate + cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency)) - @crossRateMargin), 10) END
					,agentCrossRateMargin	= @crossRateMargin
					,customerTolMin			= @customerTolMin
					,customerTolMax			= @customerTolMax
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
					
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag = 'us'			--Update Send Margin(In Grid)
	BEGIN
		SELECT 
			 @cRateFactor = cRateFactor, @cCurrency = cCurrency, @pCurrency = pCurrency
			,@cMargin = cMargin, @cHoMargin = cHoMargin
			,@pRate = pRate, @pMargin = pMargin, @pHoMargin = pHoMargin, @pAgentMargin = pAgentMargin
			,@tolerance = tolerance
			,@agentTolMin = agentTolMin, @agentTolMax = agentTolMax, @agentCrossRate = crossRate
			,@customerTolMin = customerTolMin, @customerTolMax = customerTolMax
		FROM exRateTreasury WITH(NOLOCK)
		WHERE exRateTreasuryId = @exRateTreasuryId
		
		SELECT 
			 @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END
			,@tolMin = cMin
			,@tolMax = cMax 
		FROM rateMask WITH(NOLOCK) WHERE currency = @cCurrency
		SELECT @rateMaskAd = dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency)
		
		SET @cost = ROUND((@pRate - @pMargin - @pHoMargin - @pAgentMargin)/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd) 
		--SET @cost = ROUND(@pRate/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd)
		
		IF @cost > @tolMax
		BEGIN
			SET @msg = 'Cost rate violates defined tolerance. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @cost < @tolMin
		BEGIN
			SET @msg = 'Cost rate violates defined tolerance. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF @cAgentMargin < (@agentTolMax * -1)
		BEGIN
			SET @msg = 'Calculated Cost Rate Margin = ' + CAST(@cAgentMargin AS VARCHAR) + ' violates defined tolerance. Cost Rate Margin must lie between ' + CAST((@agentTolMax * -1) AS VARCHAR) + ' and ' + CAST(@agentTolMin AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @cAgentMargin > @agentTolMin
		BEGIN
			SET @msg = 'Calculated Cost Rate Margin = ' + CAST(@cAgentMargin AS VARCHAR) + ' violates defined tolerance. Cost Rate Margin must lie between ' + CAST((@agentTolMax * -1) AS VARCHAR) + ' and ' + CAST(@agentTolMin AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		BEGIN TRANSACTION
		--Insert into history table
			INSERT INTO exRateTreasuryHistory(						
				 exRateTreasuryId
				,tranType
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,cAgentMargin
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
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
				,isActive
				,modType
			)
			SELECT
				 @exRateTreasuryId
				,tranType
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,@cAgentMargin
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
				,@customerTolMin
				,@customerTolMax
				,maxCrossRate
				,crossRate
				,@customerRate
				,tolerance
				,@user
				,@date
				,@user
				,@date
				,isActive
				,'U'
			FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
			
			SET @exRateHistoryId = SCOPE_IDENTITY()
			
			--Update main table data with history Id
			UPDATE exRateTreasury SET
				 cAgentMargin			= @cAgentMargin
				,customerRate			= @customerRate
				,customerTolMin			= @customerTolMin
				,customerTolMax			= @customerTolMax
				,modifiedBy				= @user
				,modifiedDate			= @date
				,exRateHistoryId		= @exRateHistoryId
			WHERE exRateTreasuryId = @exRateTreasuryId
			
			IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId)
			BEGIN
				UPDATE exRateTreasuryMod SET
					 cAgentMargin			= @cAgentMargin
					,customerRate			= ROUND((pRate - pMargin - pHoMargin - pAgentMargin)/(cRate + cMargin + cHoMargin + @cAgentMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,customerTolMin			= @customerTolMin
					,customerTolMax			= @customerTolMax
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
					
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag = 'ur'			--Update Receive Margin(In Grid)
	BEGIN
		SELECT 
			 @cRateFactor = cRateFactor, @cCurrency = cCurrency, @pCurrency = pCurrency
			,@cRate = cRate, @cMargin = cMargin, @cHoMargin = cHoMargin, @cAgentMargin = cAgentMargin
			,@pRate = pRate, @pMargin = pMargin, @pHoMargin = pHoMargin
			,@tolerance = tolerance
			,@agentTolMin = agentTolMin, @agentTolMax = agentTolMax, @agentCrossRate = crossRate
			,@customerTolMin = customerTolMin, @customerTolMax = customerTolMax
		FROM exRateTreasury WITH(NOLOCK)
		WHERE exRateTreasuryId = @exRateTreasuryId
		
		SELECT 
			 @colMaskAd = CASE @cRateFactor WHEN 'M' THEN rateMaskMulAd WHEN 'D' THEN rateMaskDivAd ELSE 6 END
			,@tolMin = cMin
			,@tolMax = cMax 
		FROM rateMask WITH(NOLOCK) WHERE currency = @cCurrency
		SELECT @rateMaskAd = dbo.FNAGetCrossRateDecimalMask(@cCurrency, @pCurrency)
		
		SET @cost = ROUND((@pRate - @pMargin - @pHoMargin - @pAgentMargin)/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd) 
		--SET @cost = ROUND(@pRate/(@crossRate + ISNULL(@tolerance, 0)), @colMaskAd)
		
		IF @cost > @tolMax
		BEGIN
			SET @msg = 'Cost rate violates defined tolerance. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @cost < @tolMin
		BEGIN
			SET @msg = 'Cost rate violates defined tolerance. Rate must lie between ' + CAST(@tolMin AS VARCHAR) + ' and ' + CAST(@tolMax AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		IF @pAgentMargin < (@agentTolMax * -1)
		BEGIN
			SET @msg = 'Calculated Cost Rate Margin = ' + CAST(@pAgentMargin AS VARCHAR) + ' violates defined tolerance. Cost Rate Margin must lie between ' + CAST((@agentTolMax * -1) AS VARCHAR) + ' and ' + CAST(@agentTolMin AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		IF @pAgentMargin > @agentTolMin
		BEGIN
			SET @msg = 'Calculated Cost Rate Margin = ' + CAST(@pAgentMargin AS VARCHAR) + ' violates defined tolerance. Cost Rate Margin must lie between ' + CAST((@agentTolMax * -1) AS VARCHAR) + ' and ' + CAST(@agentTolMin AS VARCHAR)
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		BEGIN TRANSACTION
		--Insert into history table
			INSERT INTO exRateTreasuryHistory(						
				 exRateTreasuryId
				,tranType
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,cAgentMargin
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
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
				,isActive
				,modType
			)
			SELECT
				 @exRateTreasuryId
				,tranType
				,cCurrency
				,cCountry
				,cAgent
				,cRateFactor
				,cRate
				,cMargin
				,cHoMargin
				,cAgentMargin
				,pCurrency
				,pCountry
				,pAgent
				,pRateFactor
				,pRate
				,pMargin
				,pHoMargin
				,@pAgentMargin
				,sharingType
				,sharingValue
				,toleranceOn
				,agentTolMin
				,agentTolMax
				,@customerTolMin
				,@customerTolMax
				,maxCrossRate
				,crossRate
				,@customerRate
				,tolerance
				,@user
				,@date
				,@user
				,@date
				,isActive
				,'U'
			FROM exRateTreasury WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId
			
			SET @exRateHistoryId = SCOPE_IDENTITY()
			
			--Update main table data with history Id
			UPDATE exRateTreasury SET
				 pAgentMargin			= @pAgentMargin
				,customerRate			= @customerRate
				,customerTolMin			= @customerTolMin
				,customerTolMax			= @customerTolMax
				,modifiedBy				= @user
				,modifiedDate			= @date
				,exRateHistoryId		= @exRateHistoryId
			WHERE exRateTreasuryId = @exRateTreasuryId
			
			IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE exRateTreasuryId = @exRateTreasuryId)
			BEGIN
				UPDATE exRateTreasuryMod SET
					 pAgentMargin			= @pAgentMargin
					,customerRate			= ROUND((pRate - pMargin - pHoMargin - @pAgentMargin)/(cRate + cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(cCurrency, pCurrency))
					,customerTolMin			= @customerTolMin
					,customerTolMax			= @customerTolMax
				WHERE exRateTreasuryId = @exRateTreasuryId
			END
					
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @exRateTreasuryId
	END
	
	ELSE IF @flag = 'getmenu'
	BEGIN
		--SELECT * FROM agentExRateMenu
		--EXEC proc_exRateForAgent @flag = 'getmenu', @user = 'hossain', @country = '113', @agent = '1097'
		DECLARE @menuId INT
		SELECT @menuId = menuId FROM agentExRateMenu WITH(NOLOCK) WHERE agentId = @agent
		IF @menuId IS NULL
			SELECT @menuId = menuId FROM agentExRateMenu WITH(NOLOCK) WHERE countryId = @country AND agentId IS NULL
		
		SELECT @menuId menuId
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
