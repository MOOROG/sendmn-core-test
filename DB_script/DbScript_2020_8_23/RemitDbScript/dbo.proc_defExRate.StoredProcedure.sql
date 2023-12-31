USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_defExRate]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_defExRate]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_defExRate
GO
*/
/*
	proc_defExRate @flag = 'm', @user = 'admin', @setupType = 'CU', @sortBy = 'defExRateId', @sortOrder = 'ASC', @pageSize = '10', @pageNumber = '1'
*/
CREATE proc [dbo].[proc_defExRate]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@defExRateId                       VARCHAR(30)		= NULL
	,@defExRateIds						VARCHAR(MAX)	= NULL
	,@setupType							CHAR(2)			= NULL
	,@currency							VARCHAR(3)		= NULL
	,@country                           INT				= NULL
	,@countryName						VARCHAR(100)	= NULL
	,@agent								INT				= NULL
	,@agentName							VARCHAR(100)	= NULL
	,@baseCurrency						VARCHAR(3)		= NULL
	,@tranType							INT				= NULL
	,@factor							CHAR(1)			= NULL
	,@cRate                             FLOAT			= NULL
	,@cMargin                           FLOAT			= NULL
	,@cMax								FLOAT			= NULL
	,@cMin								FLOAT			= NULL
	,@pRate								FLOAT			= NULL
	,@pMargin							FLOAT			= NULL
	,@pMax								FLOAT			= NULL
	,@pMin								FLOAT			= NULL
	,@hasChanged                        CHAR(1)			= NULL
	,@isEnable                          CHAR(1)			= NULL
	,@isActive							CHAR(1)			= NULL
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
	
	DECLARE @rateIdList TABLE(rowId INT IDENTITY(1,1), defExRateId INT)
	DECLARE @rateIdListCo TABLE(defExRateId INT)
	DECLARE @rateIdListAg TABLE(defExRateId	INT)
	DECLARE @hasRight CHAR(1)
	DECLARE @exRateMsg VARCHAR(MAX)
	DECLARE @msg VARCHAR(MAX)
	CREATE TABLE #defExRateIdTemp(defExRateId INT)
	CREATE TABLE #exRateIdTempMain(exRateTreasuryId INT)
	CREATE TABLE #exRateIdTempMod(exRateTreasuryId INT)
	SELECT
		 @logIdentifier = 'defExRateId'
		,@logParamMain = 'defExRate'
		,@logParamMod = 'defExRateHistory'
		,@module = '20'
		,@tableAlias = 'Default Ex-Rate'
		,@ApprovedFunctionId = CASE @setupType WHEN 'CU' THEN 20111030 WHEN 'CO' THEN 20111130 WHEN 'AG' THEN 20111230 END
	
	IF @flag = 'rateMask'			--Load Rate Mask according to Currency & Factor
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM rateMask WITH(NOLOCK) WHERE currency = @currency)
		BEGIN
			SELECT maskBD='99',maskAD='99',cMin=0,cMax=0,pMin=0,pMax=0 
			RETURN
		END
		SELECT 
			 maskBD = ISNULL(CASE WHEN @factor='M' then rateMaskMulBd when @factor='D' then rateMaskDivBd end,'99')
			,maskAD = ISNULL(CASE WHEN @factor='M' then rateMaskMulAD when @factor='D' then rateMaskDivAd end,'99')
			,cMin
			,cMax
			,pMin
			,pMax
		FROM rateMask WITH(NOLOCK) WHERE currency = @currency
				 
	END
	
	IF @flag IN ('s')
	BEGIN
		SET @hasRight = dbo.FNAHasRight(@user, CAST(@ApprovedFunctionId AS VARCHAR))
		IF(@setupType = 'CU')
			SET @sortBy = 'currencyName'
		ELSE IF(@setupType = 'CO')
			SET @sortBy = 'countryName'
		ELSE IF(@setupType = 'AG')
			SET @sortBy = 'countryName,agentName'
		--IF @sortOrder IS NULL
		   SET @sortOrder = ''	
		   
		DECLARE @m VARCHAR(MAX)
		SET @m = '(
					SELECT
						 defExRateId = ISNULL(mode.defExRateId, main.defExRateId)
						,setupType = ISNULL(mode.setupType, main.setupType)
						,currency = ISNULL(mode.currency, main.currency)
						,country = ISNULL(mode.country, main.country)
						,agent = ISNULL(mode.agent, main.agent)
						,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
						,tranType = ISNULL(mode.tranType, main.tranType)	
						,factor = ISNULL(mode.factor, main.factor)				
						,cRate = ISNULL(mode.cRate, main.cRate)
						,cMargin = ISNULL(mode.cMargin, main.cMargin)		
						,pRate = ISNULL(mode.pRate, main.pRate)
						,pMargin = ISNULL(mode.pMargin, main.pMargin)				
						,isEnable = ISNULL(mode.isEnable, main.isEnable)
						,lastModifiedBy = ISNULL(main.modifiedBy, main.createdBy)
						,lastModifiedDate = ISNULL(main.modifiedDate, main.createdDate)					
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.defExRateId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM defExRate main WITH(NOLOCK)
					LEFT JOIN defExRateHistory mode ON main.defExRateId = mode.defExRateId AND mode.approvedBy IS NULL				
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
					
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
				) '
				
					
		SET @table = '(
						SELECT
							 main.defExRateId
							,main.currency
							,currencyName = curr.currencyName		
							,main.country
							,countryName = c.countryName
							,countryCode = c.countryCode
							,main.agent
							,agentName = ISNULL(am.agentName, ''[All]'')
							,main.baseCurrency
							,main.tranType
							,tranTypeName = ISNULL(stm.typeTitle, ''Any'')
							,main.factor
							,main.cRate
							,main.cMargin
							,cMin = ISNULL(mask.cMin, 0)
							,cMax = ISNULL(mask.cMax, 0)
							,cOffer = CASE WHEN main.factor = ''M'' THEN main.cRate + main.cMargin ELSE main.cRate - main.cMargin END
							,main.pRate
							,main.pMargin
							,pMin = ISNULL(mask.pMin, 0)
							,pMax = ISNULL(mask.pMax, 0)
							,pOffer = CASE WHEN main.factor = ''M'' THEN main.pRate - main.pMargin ELSE main.pRate + main.pMargin END
							,cOperationType = ISNULL(am.agentRole, c.operationType)
							,main.isEnable
							,main.lastModifiedBy
							,main.lastModifiedDate
							,main.modifiedBy
							,main.hasChanged
							,maskMulBD= isnull(rateMaskMulBd,''99'')
							,maskMulAD= isnull(rateMaskMulAd,''99'')
							,maskDivBD= isnull(rateMaskDivBd,''99'')
							,maskDivAD= isnull(rateMaskDivAD,''99'')

						FROM ' + @m + ' main
						LEFT JOIN currencyMaster curr ON main.currency = curr.currencyCode
						LEFT JOIN countryMaster c ON main.country = c.countryId	
						LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agent = am.agentId
						LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId
						LEFT JOIN rateMask MASK(NOLOCK) on MAIN.currency = MASK.currency AND main.baseCurrency = mask.baseCurrency			
						WHERE 1=1
						
						'
		
		IF @setupType IS NOT NULL
			SET @table = @table + ' AND setupType = ''' + @setupType + '''' 
							
		SET @table =  @table + ') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @currency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND currency = ''' + @currency + ''''
			
		IF @country IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND country = ' + CAST(@country AS VARCHAR(50))
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
		
		IF @agent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agent = ' + CAST(@agent AS VARCHAR(50))
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
		
		IF @baseCurrency IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND baseCurrency = ''' + @baseCurrency + ''''
		
				
		SET @select_field_list = '
			 defExRateId	
			,currency
			,currencyName		
			,country
			,countryName
			,countryCode
			,agent
			,agentName
			,baseCurrency
			,tranType
			,tranTypeName
			,factor
			,cRate
			,cMargin
			,cMax
			,cMin
			,cOffer
			,pRate
			,pMargin
			,pMax
			,pMin
			,pOffer
			,cOperationType
			,isEnable
			,lastModifiedBy
			,lastModifiedDate
			,modifiedBy
			,hasChanged
			,maskMulBD
			,maskMulAD
			,maskDivBD
			,maskDivAD
			'
			
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
	
	IF @flag IN ('m')				--Approval List
	BEGIN
		IF(@setupType = 'CU')
			SET @sortBy = 'currencyName'
		ELSE IF(@setupType = 'CO')
			SET @sortBy = 'countryName'
		ELSE IF(@setupType = 'AG')
			SET @sortBy = 'agentName'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'	
		   
		SET @m = '(
					SELECT
						 defExRateId = ISNULL(mode.defExRateId, main.defExRateId)
						,setupType = ISNULL(mode.setupType, main.setupType)
						,currency = ISNULL(mode.currency, main.currency)
						,country = ISNULL(mode.country, main.country)
						,agent = ISNULL(mode.agent, main.agent)
						,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
						,tranType = ISNULL(mode.tranType, main.tranType)	
						,factorOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.factor END				
						,cRateOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cRate END
						,cMarginOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cMargin END	
						,cMaxOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cMax END
						,cMinOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.cMin END	
						,pRateOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pRate END
						,pMarginOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pMargin END	
						,pMaxOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pMax END
						,pMinOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.pMin END
						,isEnableOld = CASE WHEN main.approvedBy IS NULL THEN NULL ELSE main.isEnable END
						,factorNew = CASE WHEN main.approvedBy IS NULL THEN main.factor ELSE mode.factor END
						,cRateNew = CASE WHEN main.approvedBy IS NULL THEN main.cRate ELSE mode.cRate END
						,cMarginNew = CASE WHEN main.approvedBy IS NULL THEN main.cMargin ELSE mode.cMargin END
						,cMaxNew = CASE WHEN main.approvedBy IS NULL THEN main.cMax ELSE mode.cMax END
						,cMinNew = CASE WHEN main.approvedBy IS NULL THEN main.cMin ELSE mode.cMin END
						,pRateNew = CASE WHEN main.approvedBy IS NULL THEN main.pRate ELSE mode.pRate END
						,pMarginNew = CASE WHEN main.approvedBy IS NULL THEN main.pMargin ELSE mode.pMargin END
						,pMaxNew = CASE WHEN main.approvedBy IS NULL THEN main.pMax ELSE mode.pMax END
						,pMinNew = CASE WHEN main.approvedBy IS NULL THEN main.pMin ELSE mode.pMin END
						,isEnableNew = CASE WHEN main.approvedBy IS NULL THEN main.isEnable ELSE mode.isEnable END	
						,modType = CASE WHEN main.approvedBy IS NULL THEN ''I'' ELSE mode.modType END				
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.defExRateId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM defExRate main WITH(NOLOCK)
					LEFT JOIN defExRateHistory mode ON main.defExRateId = mode.defExRateId AND mode.approvedBy IS NULL				
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
				) '
				
					
		SET @table = '(
						SELECT
							 main.defExRateId
							,main.currency
							,currencyName = curr.currencyName		
							,main.country
							,countryName = c.countryName
							,main.agent
							,agentName = ISNULL(am.agentName, ''All'')
							,main.baseCurrency
							,main.tranType
							,tranTypeName = ISNULL(stm.typeTitle, ''Any'')
							,main.factorOld
							,factorNameOld = CASE WHEN main.factorOld = ''M'' THEN ''MUL'' ELSE ''DIV'' END
							,main.cRateOld
							,main.cMarginOld
							,main.cMaxOld
							,main.cMinOld
							,cOfferOld = CASE WHEN main.factorOld = ''M'' THEN main.cRateOld + main.cMarginOld ELSE main.cRateOld - main.cMarginOld END
							,main.pRateOld
							,main.pMarginOld
							,main.pMaxOld
							,main.pMinOld
							,pOfferOld = CASE WHEN main.factorOld = ''M'' THEN main.pRateOld - main.pMarginOld ELSE main.pRateOld + main.pMarginOld END
							,main.isEnableOld
							,main.factorNew
							,factorNameNew = CASE WHEN main.factorNew = ''M'' THEN ''MUL'' ELSE ''DIV'' END
							,main.cRateNew
							,main.cMarginNew
							,main.cMaxNew
							,main.cMinNew
							,cOfferNew = CASE WHEN main.factorNew = ''M'' THEN main.cRateNew + main.cMarginNew ELSE main.cRateNew - main.cMarginNew END
							,main.pRateNew
							,main.pMarginNew
							,main.pMaxNew
							,main.pMinNew	
							,pOfferNew = CASE WHEN main.factorNew = ''M'' THEN main.pRateNew - main.pMarginNew ELSE main.pRateNew + main.pMarginNew END
							,cOperationType = c.operationType
							,main.isEnableNew
							,modType = CASE WHEN main.modType = ''I'' THEN ''Insert'' WHEN main.modType = ''U'' THEN ''Update'' END
							,main.modifiedBy
							,main.hasChanged	
						FROM ' + @m + ' main
						LEFT JOIN currencyMaster curr ON main.currency = curr.currencyCode
						LEFT JOIN countryMaster c ON main.country = c.countryId	
						LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agent = am.agentId
						LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId
						WHERE 1=1 AND main.hasChanged = ''Y''
						
						'
		
		IF @setupType IS NOT NULL
			SET @table = @table + ' AND setupType = ''' + @setupType + '''' 
							
		SET @table =  @table + ') x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @currency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND currency = ''' + @currency + ''''
			
		IF @country IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND country = ' + CAST(@country AS VARCHAR(50))
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
		
		IF @agent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agent = ' + CAST(@agent AS VARCHAR(50))
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
		
		IF @baseCurrency IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND baseCurrency = ''' + @baseCurrency + ''''
				
		SET @select_field_list = '
			 defExRateId	
			,currency
			,currencyName		
			,country
			,countryName
			,agent
			,agentName
			,baseCurrency
			,tranType
			,tranTypeName
			,factorOld
			,factorNameOld
			,cRateOld
			,cMarginOld
			,cMaxOld
			,cMinOld
			,cOfferOld
			,pRateOld
			,pMarginOld
			,pMaxOld
			,pMinOld
			,pOfferOld
			,isEnableOld
			,factorNew
			,factorNameNew
			,cRateNew
			,cMarginNew
			,cMaxNew
			,cMinNew
			,cOfferNew
			,pRateNew
			,pMarginNew
			,pMaxNew
			,pMinNew
			,pOfferNew
			,cOperationType
			,isEnableNew
			,modType
			,modifiedBy
			,hasChanged
			'
			
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
		DECLARE @tolCMax FLOAT, @tolCMin FLOAT, @tolPMax FLOAT, @tolPMin FLOAT, @errorMsg VARCHAR(200), @id INT
		IF(ISNULL(@defExRateId, 0) <> 0)
			SELECT @currency = currency, @tranType = tranType FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId
		
		IF NOT EXISTS(SELECT 'X' FROM rateMask WITH(NOLOCK) WHERE currency = @currency)
		BEGIN
			SET @msg = 'Please define rate mask for currency ' + @currency
			EXEC proc_errorHandler 1, @msg, NULL
			RETURN
		END
		
		SELECT 
			 @tolCMax = ISNULL(cMax, 0.0)
			,@tolCMin = ISNULL(cMin, 0.0)
			,@tolPMax = ISNULL(pMax, 0.0)
			,@tolPMin = ISNULL(pMin, 0.0)
		FROM rateMask WITH(NOLOCK) 
		WHERE currency = @currency

		IF(@factor = 'M')
		BEGIN
			--Collection
			--Upward Max/Min Rate Checking------------------------------------------
			IF((@cRate + ISNULL(@cMargin, 0)) > @tolCMax)
			BEGIN
				SET @errorMsg = 'Collection Offer Rate exceeds Max tolerance Rate. Collection Offer must lie between ' + CAST(@tolCMin AS VARCHAR) + ' AND ' + CAST(@tolCMax AS VARCHAR)	
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END 
			IF((@cRate + ISNULL(@cMargin, 0)) < @tolCMin)
			BEGIN
				SET @errorMsg = 'Collection Offer Rate exceeds Min tolerance Rate. Collection Offer must lie between ' + CAST(@tolCMin AS VARCHAR) + ' AND ' + CAST(@tolCMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END
			
			--Payment
			--Upward Max/Min Rate Checking------------------------------------------
			IF((@pRate - ISNULL(@pMargin, 0)) > @tolPMax)
			BEGIN
				SET @errorMsg = 'Payment Offer Rate exceeds Max tolerance Rate. Payment Offer must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END
			IF((@pRate - ISNULL(@pMargin, 0)) < @tolPMin)
			BEGIN
				SET @errorMsg = 'Payment Offer Rate exceeds Min tolerance Rate. Payment Offer must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END
		END	
		ELSE IF(@factor = 'D')
		BEGIN
			--Collection
			--Upward Max/Min Rate Checking------------------------------------------
			IF((@cRate - @cMargin) > @tolCMax)
			BEGIN
				SET @errorMsg = 'Collection Offer Rate exceeds Max tolerance Rate. Collection Offer must lie between ' + CAST(@tolCMin AS VARCHAR) + ' AND ' + CAST(@tolCMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END
			IF((@cRate - @cMargin) < @tolCMin)
			BEGIN
				SET @errorMsg = 'Collection Offer Rate exceeds Min tolerance Rate. Collection Offer must lie between ' + CAST(@tolCMin AS VARCHAR) + ' AND ' + CAST(@tolCMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END
			
			--Payment
			--Upward Max/Min Rate Checking------------------------------------------
			IF((@pRate + @pMargin) > @tolPMax)
			BEGIN
				SET @errorMsg = 'Payment Offer Rate exceeds Max tolerance Rate. Payment Offer must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END
			IF((@pRate + @pMargin) < @tolPMin)
			BEGIN
				SET @errorMsg = 'Payment Offer Rate exceeds Min tolerance Rate. Payment Offer must lie between ' + CAST(@tolPMin AS VARCHAR) + ' AND ' + CAST(@tolPMax AS VARCHAR)
				EXEC proc_errorHandler 1, @errorMsg, NULL
				RETURN
			END
		END 
	END
			
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM defExRate WHERE @setupType = 'CU' AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND currency = @currency AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM defExRate WHERE @setupType = 'CO' AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND currency = @currency AND country = @country AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM defExRate WHERE @setupType = 'AG' AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND currency = @currency AND country = @country AND ISNULL(agent, 0) = ISNULL(@agent, 0) AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM defExRate WHERE agent = @agent AND country = @country)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', @defExRateId
			RETURN
		END	
		
		BEGIN TRANSACTION
			INSERT INTO defExRate (
				 setupType
				,currency
				,country
				,agent
				,baseCurrency
				,tranType
				,factor
				,cRate
				,cMargin
				,cMax
				,cMin
				,pRate
				,pMargin
				,pMax
				,pMin
				,isEnable
				,isActive
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
			)
			SELECT
				 @setupType
				,@currency
				,@country
				,@agent
				,@baseCurrency
				,@tranType
				,@factor
				,ISNULL(@cRate, 0)
				,ISNULL(@cMargin, 0)
				,@cMax
				,@cMin
				,ISNULL(@pRate, 0)
				,ISNULL(@pMargin, 0)
				,@pMax
				,@pMin
				,@isEnable
				,'Y'
				,@user
				,GETDATE()
				,@user
				,GETDATE()
				
			SET @defExRateId = SCOPE_IDENTITY()
			
			IF @agent IS NOT NULL
			BEGIN
				IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE cAgent = @agent)
				BEGIN
					SET @cMargin = ISNULL(@cMargin, 0)
					
					IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE cAgent = @agent AND approvedBy IS NULL)
					BEGIN
						UPDATE exRateTreasury SET
							 cRateId = @defExRateId
							,cRate = @cRate
							,cMargin = @cMargin
							,isUpdated = 'Y'
						WHERE cCurrency = @currency
						AND cCountry = @country
						AND cAgent = @agent AND approvedBy IS NULL
					END
					
					IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE cAgent = @agent AND approvedBy IS NOT NULL)
					BEGIN
						DELETE FROM exRateTreasuryMod
						WHERE cCurrency = @currency
						AND cCountry = @country
						AND cAgent = @agent
						
						INSERT INTO exRateTreasuryMod(
							 exRateTreasuryId
							,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
							,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
							,sharingType
							,sharingValue
							,toleranceOn
							,agentTolMin
							,agentTolMax
							,customerTolMin
							,customerTolMax
							,crossRate
							,customerRate
							,maxCrossRate
							,tolerance
							,crossRateFactor
							,isActive
							,modType,createdBy,createdDate
						)
						SELECT 
							 exRateTreasuryId
							,@defExRateId,ert.cCurrency,cCountry,cAgent,cRateFactor,@cRate,@cMargin,cHoMargin,cAgentMargin
							,ert.pRateId,ert.pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
							,ert.sharingType
							,ert.sharingValue
							,ert.toleranceOn
							,ert.agentTolMin
							,ert.agentTolMax
							,ert.customerTolMin
							,ert.customerTolMax
							,ROUND((pRate - pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
							,ROUND((pRate - pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
							,ROUND(pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
							,tolerance
							,crossRateFactor
							,isActive
							,'U',@user,GETDATE()
						FROM exRateTreasury ert WITH(NOLOCK)
						WHERE ert.cCurrency = @currency
						AND ert.cCountry = @country
						AND cAgent = @agent AND ert.approvedBy IS NOT NULL
						
						UPDATE exRateTreasury SET
							isUpdated = 'Y'
						WHERE cCurrency = @currency
						AND cCountry = @country
						AND cAgent = @agent AND approvedBy IS NOT NULL
					END
				END
				
				IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE pAgent = @agent)
				BEGIN
					SET @pMargin = ISNULL(@pMargin, 0)
					
					IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE pAgent = @agent AND approvedBy IS NULL)
					BEGIN
						UPDATE exRateTreasury SET
							 pRateId = @defExRateId
							,pRate = @cRate
							,pMargin = @cMargin
							,isUpdated = 'Y'
						WHERE pCurrency = @currency
						AND pCountry = @country
						AND pAgent = @agent AND approvedBy IS NULL
					END
					
					IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE pAgent = @agent AND approvedBy IS NOT NULL)
					BEGIN
						DELETE FROM exRateTreasuryMod
						WHERE pCurrency = @currency
						AND pCountry = @country
						AND pAgent = @agent 
						
						INSERT INTO exRateTreasuryMod(
							 exRateTreasuryId
							,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
							,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
							,sharingType
							,sharingValue
							,toleranceOn
							,agentTolMin
							,agentTolMax
							,customerTolMin
							,customerTolMax
							,crossRate
							,customerRate
							,maxCrossRate
							,tolerance
							,crossRateFactor
							,isActive
							,modType,createdBy,createdDate
						)
						SELECT 
							 exRateTreasuryId
							,ert.cRateId,ert.cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
							,@defExRateId,ert.pCurrency,pCountry,pAgent,pRateFactor,@pRate,@pMargin,pHoMargin,pAgentMargin
							,ert.sharingType
							,ert.sharingValue
							,ert.toleranceOn
							,ert.agentTolMin
							,ert.agentTolMax
							,ert.customerTolMin
							,ert.customerTolMax
							,ROUND((@pRate - @pMargin - pHoMargin)/(cRate + cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
							,ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(cRate + cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
							,ROUND(@pRate/cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
							,tolerance
							,crossRateFactor
							,isActive
							,'U',@user,GETDATE()
						FROM exRateTreasury ert WITH(NOLOCK)
						WHERE ert.pCurrency = @currency
						AND ert.pCountry = @country
						AND pAgent = @agent AND ert.approvedBy IS NOT NULL
						
						UPDATE exRateTreasury SET
							isUpdated = 'Y'
						WHERE pCurrency = @currency
						AND pCountry = @country
						AND pAgent = @agent AND approvedBy IS NOT NULL
					END
				END
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @defExRateId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM defExRateHistory WITH(NOLOCK)
				WHERE defExRateId = @defExRateId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM defExRateHistory mode WITH(NOLOCK)
			INNER JOIN defExRate main WITH(NOLOCK) ON mode.defExRateId = main.defExRateId
			WHERE mode.defExRateId= @defExRateId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		/*
		IF EXISTS (
			SELECT 'X' FROM defExRate WITH(NOLOCK)
			WHERE defExRateId = @defExRateId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @defExRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM defExRateHistory WITH(NOLOCK)
			WHERE defExRateId  = @defExRateId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @defExRateId
			RETURN
		END
		
		IF EXISTS(SELECT 'X' FROM exRateTreasury WITH(NOLOCK) WHERE (cRateId = @defExRateId OR pRateId = @defExRateId) AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @defExRateId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM exRateTreasuryMod WITH(NOLOCK) WHERE (cRateId = @defExRateId OR pRateId = @defExRateId) AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @defExRateId
			RETURN	
		END
		*/
		DECLARE @isCRateUpdate CHAR(1) = 'N', @isPRateUpdate CHAR(1) = 'N'
		IF NOT EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId AND cRate = @cRate)
		BEGIN
			SET @isCRateUpdate = 'Y'
		END
		IF NOT EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId AND cMargin = @cMargin)
		BEGIN
			SET @isCRateUpdate = 'Y'
		END
		IF NOT EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId AND pRate = @pRate)
		BEGIN
			SET @isPRateUpdate = 'Y'
		END
		IF NOT EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId AND pMargin = @pMargin)
		BEGIN
			SET @isPRateUpdate = 'Y'
		END
		SELECT 
			 @setupType = setupType
			,@currency	= currency
			,@country	= country
			,@agent		= agent 
		FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId
		BEGIN TRANSACTION	
				--Currency Rate/ Agent Rate Update------------------------------------------------------------------------------------		
				UPDATE defExRate SET
					 factor				= @factor
					,cRate				= ISNULL(@cRate, 0)
					,cMargin			= ISNULL(@cMargin, 0)
					,cMax				= @cMax
					,cMin				= @cMin
					,pRate				= ISNULL(@pRate, 0)
					,pMargin			= ISNULL(@pMargin, 0)
					,pMax				= @pMax
					,pMin				= @pMin
					,isEnable			= @isEnable
					,modifiedBy			= @user
					,modifiedDate		= GETDATE()					
				WHERE defExRateId = @defExRateId			
				
				--Change Record History-----------------------------------------------------------------------------------------------
				INSERT INTO defExRateHistory(						
					 defExRateId 
					,setupType
					,currency,country,agent,baseCurrency,tranType,factor
					,cRate,cMargin,cMax,cMin
					,pRate,pMargin,pMax,pMin
					,isEnable,createdBy,createdDate,approvedBy,approvedDate,modType
				)
				SELECT
					 @defExRateId
					,main.setupType
					,main.currency,main.country,main.agent,main.baseCurrency,main.tranType,@factor
					,@cRate,@cMargin,@cMax,@cMin
					,@pRate,@pMargin,@pMax,@pMin
					,@isEnable,@user,GETDATE(),@user,GETDATE(),'U'
				FROM defExRate main WITH(NOLOCK) WHERE defExRateId = @defExRateId
			
			IF @isCRateUpdate = 'Y'
			BEGIN
				SET @cMargin = ISNULL(@cMargin, 0)
				
				--1. Get All Corridor records affected by send cost rate change
				DELETE FROM #exRateIdTempMain
				INSERT INTO #exRateIdTempMain
				SELECT exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE cRateId = @defExRateId
				
				--2. Update Records in Mod Table if data already exist in mod table	
				IF EXISTS(SELECT 'X' FROM exRateTreasuryMod mode WITH(NOLOCK) INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId)
				BEGIN
					DELETE FROM #exRateIdTempMod
					INSERT INTO #exRateIdTempMod
					SELECT mode.exRateTreasuryId FROM exRateTreasuryMod mode WITH(NOLOCK)
					INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId
					
					UPDATE ert SET
						 cRate			= @cRate
						,cMargin		= @cMargin
						,maxCrossRate	= ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
						,crossRate		= ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0)
											END
						,createdBy		= @user
						,createdDate	= GETDATE()
					FROM exRateTreasuryMod ert
					INNER JOIN defExRate def ON ert.pRateId = def.defExRateId
					INNER JOIN #exRateIdTempMod temp ON ert.exRateTreasuryId = temp.exRateTreasuryId
				END
				
				--3. Update Record in main table for modType Insert.
				UPDATE ert SET
					 cRate			= @cRate
					,cMargin		= @cMargin
					,maxCrossRate	= ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
					,crossRate		= ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					--,customerRate	= ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN
											ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0)
											END
					,createdBy		= @user
					,createdDate	= GETDATE()
				FROM exRateTreasury ert
				INNER JOIN defExRate def ON ert.pRateId = def.defExRateId
				WHERE cRateId = @defExRateId AND ert.approvedBy IS NULL
				
				--4. Insert records in mod table for modType Update.
				INSERT INTO exRateTreasuryMod(
					 exRateTreasuryId
					,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
					,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
					,sharingType
					,sharingValue
					,toleranceOn
					,agentTolMin
					,agentTolMax
					,customerTolMin
					,customerTolMax
					,crossRate
					,customerRate
					,maxCrossRate
					,agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,isActive
					,modType,createdBy,createdDate
				)
				SELECT 
					 exRateTreasuryId
					,ert.cRateId,ert.cCurrency,cCountry,cAgent,cRateFactor,@cRate,@cMargin,cHoMargin,cAgentMargin
					,ert.pRateId,ert.pCurrency,pCountry,pAgent,pRateFactor,def.pRate,def.pMargin,pHoMargin,pAgentMargin
					,ert.sharingType
					,ert.sharingValue
					,ert.toleranceOn
					,ert.agentTolMin
					,ert.agentTolMax
					,ert.customerTolMin
					,ert.customerTolMax
					,ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((def.pRate - def.pMargin - pHoMargin - pAgentMargin)/(@cRate + @cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) 
						WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((def.pRate - def.pMargin - pHoMargin)/(@cRate + @cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0)  END
					,ROUND(def.pRate/@cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,ert.agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,ert.isActive
					,'U',@user,GETDATE()
				FROM exRateTreasury ert WITH(NOLOCK)
				INNER JOIN defExRate def WITH(NOLOCK) ON ert.pRateId = def.defExRateId
				WHERE ert.cRateId = @defExRateId AND ert.approvedBy IS NOT NULL AND ISNULL(ert.isActive, 'N') = 'Y'
				AND ert.exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)
				
				--5. Mark Records as "has been updated"-----------------------------------------------------------------
				UPDATE exRateTreasury SET
					 isUpdated = 'Y'
				WHERE cRateId = @defExRateId AND approvedBy IS NOT NULL AND ISNULL(isActive, 'N') = 'Y'
				AND exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)
			END
			IF @isPRateUpdate = 'Y'
			BEGIN
				SET @pMargin = ISNULL(@pMargin, 0)
				
				--1. Get All Corridor records affected by receive cost rate change
				DELETE FROM #exRateIdTempMain
				INSERT INTO #exRateIdTempMain
				SELECT exRateTreasuryId FROM exRateTreasury WITH(NOLOCK) WHERE pRateId = @defExRateId
				
				--2. Update Records in Mod Table if data already exist in mod table	
				IF EXISTS(SELECT 'X' FROM exRateTreasuryMod mode WITH(NOLOCK) INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId)
				BEGIN
					DELETE FROM #exRateIdTempMod
					INSERT INTO #exRateIdTempMod
					SELECT mode.exRateTreasuryId FROM exRateTreasuryMod mode WITH(NOLOCK)
					INNER JOIN #exRateIdTempMain temp ON mode.exRateTreasuryId = temp.exRateTreasuryId
					
					UPDATE ert SET
						 pRate			= @pRate
						,pMargin		= @pMargin
						,maxCrossRate	= ROUND(@pRate/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
						,crossRate		= ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
						,createdBy		= @user
						,createdDate	= GETDATE()
					FROM exRateTreasuryMod ert
					INNER JOIN defExRate def ON ert.cRateId = def.defExRateId
					INNER JOIN #exRateIdTempMod temp ON ert.exRateTreasuryId = temp.exRateTreasuryId
				END
				
				--3. Update Record in main table for modType Insert.
				UPDATE ert SET
					 cRate = @cRate
					,cMargin = @cMargin
					,maxCrossRate	= ROUND(@pRate/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))	
					,crossRate		= ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					--,customerRate	= ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,customerRate	= CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
											WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(agentCrossRateMargin, 0) END
					,createdBy		= @user
					,createdDate	= GETDATE()
				FROM exRateTreasury ert
				INNER JOIN defExRate def ON ert.cRateId = def.defExRateId
				WHERE pRateId = @defExRateId AND ert.approvedBy IS NULL
				
				INSERT INTO exRateTreasuryMod(
					 exRateTreasuryId
					,cRateId,cCurrency,cCountry,cAgent,cRateFactor,cRate,cMargin,cHoMargin,cAgentMargin
					,pRateId,pCurrency,pCountry,pAgent,pRateFactor,pRate,pMargin,pHoMargin,pAgentMargin
					,sharingType
					,sharingValue
					,toleranceOn
					,agentTolMin
					,agentTolMax
					,customerTolMin
					,customerTolMax
					,crossRate
					,customerRate
					,maxCrossRate
					,agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,isActive
					,modType,createdBy,createdDate
				)
				SELECT 
					 exRateTreasuryId
					,ert.cRateId,ert.cCurrency,cCountry,cAgent,cRateFactor,def.cRate,def.cMargin,cHoMargin,cAgentMargin
					,ert.pRateId,ert.pCurrency,pCountry,pAgent,pRateFactor,@pRate,@pMargin,pHoMargin,pAgentMargin
					,ert.sharingType
					,ert.sharingValue
					,ert.toleranceOn
					,ert.agentTolMin
					,ert.agentTolMax
					,ert.customerTolMin
					,ert.customerTolMax
					,ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,CASE WHEN ISNULL(toleranceOn, '') IN ('S', 'P', '') THEN ROUND((@pRate - @pMargin - pHoMargin - pAgentMargin)/(def.cRate + def.cMargin + cHoMargin + cAgentMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
						WHEN ISNULL(toleranceOn, '') IN ('C') THEN ROUND((@pRate - @pMargin - pHoMargin)/(def.cRate + def.cMargin + cHoMargin), dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency)) - ISNULL(ert.agentCrossRateMargin, 0) END
					,ROUND(@pRate/def.cRate, dbo.FNAGetCrossRateDecimalMask(ert.cCurrency, ert.pCurrency))
					,ert.agentCrossRateMargin
					,tolerance
					,crossRateFactor
					,ert.isActive
					,'U',@user,GETDATE()
				FROM exRateTreasury ert WITH(NOLOCK)
				INNER JOIN defExRate def WITH(NOLOCK) ON ert.cRateId = def.defExRateId
				WHERE ert.pRateId = @defExRateId AND ert.approvedBy IS NOT NULL AND ISNULL(ert.isActive, 'N') = 'Y'
				AND ert.exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)
				
				UPDATE exRateTreasury SET
					 isUpdated = 'Y'
				WHERE pRateId = @defExRateId AND approvedBy IS NOT NULL AND ISNULL(isActive, 'N') = 'Y'
				AND exRateTreasuryId NOT IN (SELECT exRateTreasuryId FROM #exRateIdTempMod)
				
				SELECT @exRateMsg = 'IME Nepal ExRate for 1 USD = ' + CAST((@pRate - ISNULL(@pMargin, 0)) AS VARCHAR) + ' NPR as of date ' + CONVERT(VARCHAR, GETDATE(), 109) + ' (MST)'
				SELECT @countryName = countryName FROM countryMaster WITH(NOLOCK) WHERE countryId = (SELECT country FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId)
				EXEC proc_emailSmsHandler @flag = 'sms', @user = @user, @msg = @exRateMsg, @country = @countryName
			END
			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @defExRateId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM defExRate WITH(NOLOCK)
			WHERE defExRateId = @defExRateId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @defExRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM defExRateHistory  WITH(NOLOCK)
			WHERE defExRateId = @defExRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @defExRateId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM defExRate WITH(NOLOCK) WHERE defExRateId = @defExRateId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM defExRate WHERE defExRateId = @defExRateId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @defExRateId
			RETURN
		END
			INSERT INTO defExRateHistory(
				 defExRateId 
				,currency
				,country
				,agent
				,baseCurrency
				,tranType
				,factor
				,cRate
				,cMargin
				,cMax
				,cMin
				,pRate
				,pMargin
				,pMax
				,pMin
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 defExRateId 
				,currency
				,country
				,agent
				,baseCurrency
				,tranType
				,factor
				,cRate
				,cMargin
				,cMax
				,cMin
				,pRate
				,pMargin
				,pMax
				,pMin
				,isEnable				
				,@user
				,GETDATE()
				,'D'
			FROM defExRate WHERE defExRateId = @defExRateId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @defExRateId
	END

	ELSE IF @flag IN('reject')
	BEGIN
		IF(ISNULL(@defExRateIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to reject', NULL
			RETURN
		END
		BEGIN TRANSACTION
			SET @sql = 'SELECT defExRateId FROM defExRate WITH(NOLOCK) WHERE defExRateId IN (' + @defExRateIds + ')'
			INSERT @rateIdList
			EXEC (@sql)
			WHILE EXISTS(SELECT 'X' FROM @rateIdList)
			BEGIN
				SELECT TOP 1 @defExRateId = defExRateId FROM @rateIdList
				IF EXISTS (SELECT 'X' FROM defExRate WHERE approvedBy IS NULL AND defExRateId = @defExRateId)
				BEGIN --New record			
						SET @modType = 'Reject'
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @defExRateId, @oldValue OUTPUT
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @defExRateId, @user, @oldValue, @newValue
										
						IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
						BEGIN
							IF @@TRANCOUNT > 0
							ROLLBACK TRANSACTION
							EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @defExRateId
							RETURN
						END
					DELETE FROM defExRate WHERE defExRateId =  @defExRateId
				END
				ELSE
				BEGIN
						SET @modType = 'Reject'
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @defExRateId, @oldValue OUTPUT
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @defExRateId, @user, @oldValue, @newValue
						IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
						BEGIN
							IF @@TRANCOUNT > 0
							ROLLBACK TRANSACTION
							EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @defExRateId
							RETURN
						END
						DELETE FROM defExRateHistory WHERE defExRateId = @defExRateId AND approvedBy IS NULL
					
				END	
				DELETE FROM @rateIdList WHERE defExRateId = @defExRateId	
			END
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @defExRateId
	END

	ELSE IF @flag  IN ('approve')
	BEGIN
		--IF NOT EXISTS (
		--	SELECT 'X' FROM defExRate WITH(NOLOCK)
		--	WHERE defExRateId = @defExRateId
		--)
		--AND
		--NOT EXISTS (
		--	SELECT 'X' FROM defExRate WITH(NOLOCK)
		--	WHERE defExRateId = @defExRateId AND approvedBy IS NULL
		--)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Modification approval is not pending.', @defExRateId
		--	RETURN
		--END
		IF(ISNULL(@defExRateIds, '') = '')
		BEGIN
			EXEC proc_errorHandler 1, 'Please select the record(s) to approve', NULL
			RETURN
		END
		DECLARE @coCountry INT, @coAgent INT, @cocRate FLOAT, @cocMargin FLOAT, @copRate FLOAT, @copMargin FLOAT, @idCo INT, @idAg INT,
								@agcMargin FLOAT, @agcRate FLOAT, @agpRate FLOAT, @agpMargin FLOAT, @cpFlag CHAR(1)
		BEGIN TRANSACTION
			SET @sql = 'SELECT defExRateId FROM defExRate WITH(NOLOCK) WHERE defExRateId IN (' + @defExRateIds + ')'
			INSERT @rateIdList
			EXEC (@sql)
			WHILE EXISTS(SELECT 'X' FROM @rateIdList)
			BEGIN
				SELECT TOP 1 @defExRateId = defExRateId FROM @rateIdList
				IF EXISTS (SELECT 'X' FROM defExRate WHERE approvedBy IS NULL AND defExRateId = @defExRateId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM defExRateHistory WHERE defExRateId = @defExRateId AND approvedBy IS NULL
				IF @modType = 'I'
				BEGIN --New record
					UPDATE defExRate SET
						 isActive = 'Y'
						,approvedBy = @user
						,approvedDate= GETDATE()
					WHERE defExRateId = @defExRateId
					
					SELECT
						 @currency	= currency
						,@country	= country
						,@agent		= agent
						,@tranType	= tranType
						,@factor	= factor
						,@cRate		= cRate
						,@cMargin	= cMargin
						,@cMax		= cMax
						,@cMin		= cMin
						,@pRate		= pRate
						,@pMargin	= pMargin
						,@pMax		= pMax
						,@pMin		= pMin
					FROM defExRateHistory WHERE defExRateId = @defExRateId AND approvedBy IS NULL
					
					IF(@setupType = 'CO')
					BEGIN
					--1. Fetch Cost Rate from currency setup
						SELECT 
							 @cRate = CASE WHEN factor = 'M' THEN cRate + ISNULL(cMargin, 0) ELSE cRate - ISNULL(cMargin, 0) END
							,@pRate = CASE WHEN factor = 'M' THEN pRate - ISNULL(pMargin, 0) ELSE pRate + ISNULL(pMargin, 0) END
						FROM defExRate WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @currency AND ISNULL(tranType, 0) = ISNULL(ISNULL(@tranType, tranType), 0)
					--2. Update Country Rate
						UPDATE defExRate SET
							 cRate = @cRate
							,pRate = @pRate
						WHERE defExRateId = @defExRateId	
					--3. Update Agent Rate Setup according to corresponding country
						UPDATE defExRate SET
							 cRate = CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
							,pRate = CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
						WHERE setupType IN ('AG') AND currency = @currency AND country = @country AND ISNULL(tranType, 0) = ISNULL(ISNULL(@tranType, tranType), 0)
					
					--4. Update Corridor Setup According to Corresponding Country
						UPDATE spExRate SET
							 cRate = CASE WHEN cCountry = @country THEN 
										(
											CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
										) 
									 ELSE cRate END
							,pRate = CASE WHEN pCountry = @country THEN 
										(
											CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
										) 
									 ELSE pRate END
							WHERE cCountry = @country OR pCountry = @country
					
					/*
					--Update Exchange Rate Treasury
						DECLARE @crossRate FLOAT, @maxCrossRate FLOAT, @cost FLOAT, @margin FLOAT
						UPDATE exRateTreasury SET
							 cRate = CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
							,pRate = CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
						WHERE cCurrency = @currency AND ISNULL(cCountry, 0) = ISNULL(@country, 0)
					*/
					
					--5. Update Corridor Setup According to Corresponding Agent		
						INSERT @rateIdListAg
						SELECT defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND currency = @currency AND country = @country
						WHILE EXISTS(SELECT 'X' FROM @rateIdListAg)
						BEGIN
							SELECT TOP 1 @idAg = defExRateId FROM @rateIdListAg
							SELECT @coAgent = agent, @agcRate = cRate, @agcMargin = cMargin, @agpRate = pRate, @agpMargin = pMargin FROM defExRate WHERE defExRateId = @idAg
							
							UPDATE spExRate SET
								 cRate = CASE WHEN cAgent = @coAgent THEN 
											(
												CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) + ISNULL(@agcMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) - ISNULL(@agcMargin, 0) END
											)
										 ELSE cRate END
								,pRate = CASE WHEN pAgent = @coAgent THEN 
											(
												CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) - ISNULL(@agpMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) + ISNULL(@agpMargin, 0) END
											)
										 ELSE pRate END
								WHERE cAgent = @coAgent OR pAgent = @coAgent
							
							DELETE FROM @rateIdListAg WHERE defExRateId = @idAg
						END
					END
					
					IF(@setupType = 'AG')
					BEGIN
					--4. Update Corridor Setup according to corresponding agent
						UPDATE spExRate SET
							 cRate = CASE WHEN cAgent = @agent THEN 
										(
											CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
										)
									 ELSE cRate END
							,pRate = CASE WHEN pAgent = @agent THEN 
										(
											CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
										)
									 ELSE pRate END
							WHERE cAgent = @agent OR pAgent = @agent
					END
					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @defExRateId, @newValue OUTPUT
				END
				ELSE IF @modType = 'U'
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @defExRateId, @oldValue OUTPUT
					UPDATE main SET
						 main.factor			= mode.factor
						,main.cRate				= mode.cRate
						,main.cMargin			= mode.cMargin
						,main.cMax				= mode.cMax
						,main.cMin				= mode.cMin
						,main.pRate				= mode.pRate
						,main.pMargin			= mode.pMargin
						,main.pMax				= mode.pMax
						,main.pMin				= mode.pMin
						,main.isEnable			= mode.isEnable
						,main.modifiedBy		= @user
						,main.modifiedDate		= GETDATE()
					FROM defExRate main
					INNER JOIN defExRateHistory mode ON mode.defExRateId = main.defExRateId
					WHERE mode.defExRateId = @defExRateId AND mode.approvedBy IS NULL
					
					SELECT
						 @currency	= currency
						,@country	= country
						,@agent		= agent
						,@tranType	= tranType
						,@factor	= factor
						,@cRate		= cRate
						,@cMargin	= cMargin
						,@cMax		= cMax
						,@cMin		= cMin
						,@pRate		= pRate
						,@pMargin	= pMargin
						,@pMax		= pMax
						,@pMin		= pMin
					FROM defExRateHistory WHERE defExRateId = @defExRateId AND approvedBy IS NULL
					
					IF(@setupType = 'CU')
					BEGIN
						--1. Update Country Rate Setup
						UPDATE defExRate SET
							 factor = @factor
							,cRate = CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
							,pRate = CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
						WHERE setupType IN ('CO') AND currency = @currency AND ISNULL(tranType, 0) = ISNULL(ISNULL(@tranType, tranType), 0)
						
						INSERT @rateIdListCo
						SELECT defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CO' AND currency = @currency
						
						WHILE EXISTS(SELECT 'X' FROM @rateIdListCo)
						BEGIN
							SELECT TOP 1 @idCo = defExRateId FROM @rateIdListCo
							SELECT @coCountry = country, @cocMargin = cMargin, @copMargin = pMargin FROM defExRate WHERE defExRateId = @idCo
							
							--2. Update Agent Rate Setup according to corresponding country
							UPDATE defExRate SET
								 factor = @factor
								,cRate = CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) + ISNULL(@cocMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) - ISNULL(@cocMargin, 0) END
								,pRate = CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) - ISNULL(@copMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) + ISNULL(@copMargin, 0) END
							WHERE setupType IN ('AG') AND currency = @currency AND country = @coCountry AND ISNULL(tranType, 0) = ISNULL(ISNULL(@tranType, tranType), 0)
							
							--3. Update Corridor Rate Setup according to corresponding country
							UPDATE spExRate SET
								 cRate = CASE WHEN cCountry = @coCountry THEN 
											(
												CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) + ISNULL(@cocMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) - ISNULL(@cocMargin, 0) END
											) 
										 ELSE cRate END
								,pRate = CASE WHEN pCountry = @coCountry THEN 
											(
												CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) - ISNULL(@copMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) + ISNULL(@copMargin, 0) END
											) 
										 ELSE pRate END
								WHERE cCountry = @coCountry OR pCountry = @coCountry
							
							--4. Update Corridor Rate Setup according to Corresponding Agent
							INSERT @rateIdListAg
							SELECT defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND currency = @currency AND country = @coCountry
							WHILE EXISTS(SELECT 'X' FROM @rateIdListAg)
							BEGIN
								SELECT TOP 1 @idAg = defExRateId FROM @rateIdListAg
								SELECT @coAgent = agent, @agcRate = cRate, @agcMargin = cMargin, @agpRate = pRate, @agpMargin = pMargin FROM defExRate WHERE defExRateId = @idAg
								
								UPDATE spExRate SET
									 cRate =  CASE WHEN cAgent = @coAgent THEN 
												(
													CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) + ISNULL(@cocMargin, 0) + ISNULL(@agcMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) - ISNULL(@cocMargin, 0) - ISNULL(@agcMargin, 0) END
												) 
											 ELSE cRate END
									,pRate = CASE WHEN pAgent = @coAgent THEN 
												(
													CASE WHEN @factor = 'M' THEN @pRate + ISNULL(@pMargin, 0) - ISNULL(@copMargin, 0) - ISNULL(@agpMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) + ISNULL(@copMargin, 0) + ISNULL(@agpMargin, 0) END
												) 
											 ELSE pRate END
									WHERE cAgent = @coAgent OR pAgent = @coAgent
								
								DELETE FROM @rateIdListAg WHERE defExRateId = @idAg
							END
							DELETE FROM @rateIdListCo WHERE defExRateId = @idCo
						END
					END
					
					IF(@setupType = 'CO')
					BEGIN
						--1. Fetch cost rate from currency rate setup
						SELECT 
							 @cRate = CASE WHEN factor = 'M' THEN cRate + ISNULL(cMargin, 0) ELSE cRate - ISNULL(cMargin, 0) END
							,@pRate = CASE WHEN factor = 'M' THEN pRate - ISNULL(pMargin, 0) ELSE pRate + ISNULL(pMargin, 0) END
						FROM defExRate WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'CU' AND currency = @currency AND ISNULL(tranType, 0) = ISNULL(ISNULL(@tranType, tranType), 0)
						--2. Update Country Rate
						UPDATE defExRate SET
							 cRate = @cRate
							,pRate = @pRate
						WHERE defExRateId = @defExRateId
						--3. Update Agent Rate according to corresponding Country 
						UPDATE defExRate SET
							 cRate = CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
							,pRate = CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
						WHERE setupType IN ('AG') AND currency = @currency AND country = @country AND ISNULL(tranType, 0) = ISNULL(ISNULL(@tranType, tranType), 0)
						
						--4. Update Corridor Rate according to corresponding Country
						UPDATE spExRate SET
							 cRate = CASE WHEN cCountry = @country THEN 
										(
											CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
										) 
									 ELSE cRate END
							,pRate = CASE WHEN pCountry = @country THEN 
										(
											CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
										) 
									 ELSE pRate END
							WHERE cCountry = @country OR pCountry = @country
						
						--5. Update Corridor Rate according to corresponding Agent		
						INSERT @rateIdListAg
						SELECT defExRateId FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND setupType = 'AG' AND currency = @currency AND country = @country
						WHILE EXISTS(SELECT 'X' FROM @rateIdListAg)
						BEGIN
							SELECT TOP 1 @idAg = defExRateId FROM @rateIdListAg
							SELECT @coAgent = agent, @agcRate = cRate, @agcMargin = cMargin, @agpRate = pRate, @agpMargin = pMargin FROM defExRate WHERE defExRateId = @idAg
							
							UPDATE spExRate SET
								 cRate = CASE WHEN cAgent = @coAgent THEN 
											(
												CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) + ISNULL(@agcMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) - ISNULL(@agcMargin, 0) END
											)
										 ELSE cRate END
								,pRate = CASE WHEN pAgent = @coAgent THEN 
											(
												CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) - ISNULL(@agpMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) + ISNULL(@agpMargin, 0) END
											)
										 ELSE pRate END
								WHERE cAgent = @coAgent OR pAgent = @coAgent
							
							DELETE FROM @rateIdListAg WHERE defExRateId = @idAg
						END
					END
					
					IF(@setupType = 'AG')
					BEGIN
						--4. Update Corridor Rate Setup according to corresponding agent
						UPDATE spExRate SET
							 cRate = CASE WHEN cAgent = @agent THEN 
										(
											CASE WHEN @factor = 'M' THEN @cRate + ISNULL(@cMargin, 0) ELSE @cRate - ISNULL(@cMargin, 0) END
										)
									 ELSE cRate END
							,pRate = CASE WHEN pAgent = @agent THEN 
										(
											CASE WHEN @factor = 'M' THEN @pRate - ISNULL(@pMargin, 0) ELSE @pRate + ISNULL(@pMargin, 0) END
										)
									 ELSE pRate END
							WHERE cAgent = @agent OR pAgent = @agent
					END
					
					EXEC [dbo].proc_GetColumnToRow  'defExRate', 'defExRateId', @defExRateId, @newValue OUTPUT
				END
				ELSE IF @modType = 'D'
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @defExRateId, @oldValue OUTPUT
					UPDATE defExRate SET
						 isDeleted = 'Y'
						,modifiedDate = GETDATE()
						,modifiedBy = @user					
					WHERE defExRateId = @defExRateId
				END
				
				UPDATE defExRateHistory SET
					 approvedBy = @user
					,approvedDate = GETDATE()
				WHERE defExRateId = @defExRateId AND approvedBy IS NULL
				
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @defExRateId, @user, @oldValue, @newValue
				
				DELETE FROM @rateIdList WHERE defExRateId = @defExRateId
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @defExRateId
	END
	
	ELSE IF @flag = 'ai'
	BEGIN
		INSERT INTO #defExRateIdTemp
		SELECT value FROM dbo.Split(',', @defExRateIds)
		
		UPDATE def SET
			 def.isActive = @isActive
			,def.modifiedBy = @user
			,def.modifiedDate = GETDATE()
		FROM defExRate def
		INNER JOIN #defExRateIdTemp tmp ON def.defExRateId = tmp.defExRateId
		
		EXEC proc_errorHandler 0, 'Selected record(s) has been deactivated', NULL
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @defExRateId
END CATCH
GO
