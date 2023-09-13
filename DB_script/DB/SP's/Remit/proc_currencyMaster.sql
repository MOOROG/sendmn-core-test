
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_currencyMaster]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_currencyMaster

GO
*/

ALTER PROC [dbo].[proc_currencyMaster]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@currencyId                        VARCHAR(30)		= NULL
	,@currencyCode                      VARCHAR(10)		= NULL
	,@isoNumeric						VARCHAR(5)		= NULL
	,@currencyName                      VARCHAR(50)		= NULL
	,@currencyDesc						VARCHAR(50)		= NULL
	,@currencyDecimalName               VARCHAR(50)		= NULL
	,@countAfterDecimal                 INT				= NULL
	,@roundNoDecimal                    INT				= NULL
	,@factor							CHAR(1)			= NULL
	,@rateMin							FLOAT			= NULL
	,@rateMax							FLOAT			= NULL
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
	SELECT
		 @logIdentifier = 'currencyId'
		,@logParamMain = 'currencyMaster'
		,@logParamMod = 'currencyMasterMod'
		,@module = '20'
		,@tableAlias = 'Currency Master'
		
	IF @flag = 'cul'  -- currency List
	BEGIN
		SELECT [0], [1] FROM (
			SELECT NULL [0], 'All' [1] UNION ALL
			
			SELECT 
				 TOP 100 PERCENT
				 ccm.currencyId [0]
				,ccm.currencyCode [1]
			FROM currencyMaster ccm WITH (NOLOCK) 
			WHERE ISNULL(ccm.isDeleted, 'N')  <> 'Y'  
		) x ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END	
		RETURN	
	END
	
	ELSE IF @flag = 'bcul'	--Base Currency List
	BEGIN
		SELECT [0], [1] FROM (
			SELECT NULL [0], 'All' [1] UNION ALL
			
			SELECT 
				 TOP 100 PERCENT
				 ccm.currencyId [0]
				,ccm.currencyCode [1]
			FROM currencyMaster ccm WITH (NOLOCK) 
			WHERE ISNULL(ccm.isDeleted, 'N')  <> 'Y'
			AND currencyId = 2  
		) x ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END	
		RETURN
	END
	ELSE IF @flag = 'l'
	BEGIN
		SELECT 
			 currencyId
			,currencyCode = currencyCode + ISNULL(' - ' + currencyName, '')
		FROM currencyMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') <> 'Y'
		ORDER BY currencyCode
		
		RETURN
	END
	
	ELSE IF @flag = 'l2'
	BEGIN
		SELECT DISTINCT
			 curr.currencyCode
			,currencyDesc = ISNULL(curr.currencyCode, '') + ISNULL(' - ' + curr.currencyName, '')
		FROM countryCurrency cc
		INNER JOIN currencyMaster curr ON cc.currencyId = curr.currencyId
		INNER JOIN countryMaster cm ON cc.countryId = cm.countryId AND ISNULL(cm.isOperativeCountry, 'N') = 'Y'
		WHERE ISNULL(cc.isDeleted, 'N') = 'N'
		
		--EXEC proc_countryCurrency @flag = 'lAll'
		--SELECT
		--	 currencyCode
		--	,currencyDesc = currencyCode + ISNULL(' - ' + currencyName, '')
		--FROM currencyMaster WITH(NOLOCK)
		--WHERE ISNULL(isDeleted, 'N') <> 'Y'
		--ORDER BY currencyCode
		
		RETURN
	END
	--- selecting a country id type
	ELSE IF @flag = 'id'
	BEGIN
		SELECT 
			valueId
			,detailTitle 
		FROM staticDataValue  WITH (NOLOCK)
		WHERE typeID=1300 AND ISNULL(IS_DELETE,'') <> 'Y'
		ORDER BY detailTitle 
		
		RETURN
	END
	
	ELSE IF @flag = 'bc'		--Base Currency							
	BEGIN
		SELECT
			 currencyId
			,currencyCode
		FROM currencyMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') <> 'Y'
		AND currencyCode IN ('USD', 'JPY')
		
		RETURN
	END
	
	ELSE IF @flag = 'bcd'		--Base Currency Domestic					
	BEGIN
		SELECT
			 currencyId
			,currencyCode
		FROM currencyMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') <> 'Y'
		AND currencyCode IN ('NPR')
		RETURN
	END
	
	ELSE IF @flag = 'bcl'
	BEGIN
		SELECT
			 currencyId
			,currencyCode
		FROM currencyMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') <> 'Y'
		AND currencyCode IN ('NPR', 'USD')
	END
	ELSE IF @flag = 'bcl1'
	BEGIN
		SELECT
			 currencyId
			,currencyCode
		FROM currencyMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') <> 'Y'
		AND currencyCode IN ('USD')
	END
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM currencyMaster WITH(NOLOCK) WHERE currencyCode = @currencyCode AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Currency code already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO currencyMaster (
				 currencyCode
				,isoNumeric
				,currencyName
				,currencyDesc
				,currencyDecimalName
				,countAfterDecimal
				,roundNoDecimal
				,factor
				,rateMin
				,rateMax
				,createdBy
				,createdDate
			)
			SELECT
				 @currencyCode
				,@isoNumeric
				,@currencyName
				,@currencyDesc
				,@currencyDecimalName
				,@countAfterDecimal
				,@roundNoDecimal
				,@factor
				,@rateMin
				,@rateMax
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @currencyId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @currencyId, @user, @oldValue, @newValue, @module
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @currencyId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @currencyId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM currencyMaster WITH(NOLOCK) WHERE currencyId = @currencyId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE currencyMaster SET
				 currencyCode			= @currencyCode
				,isoNumeric				= @isoNumeric
				,currencyName			= @currencyName
				,currencyDesc			= @currencyDesc
				,currencyDecimalName	= @currencyDecimalName
				,countAfterDecimal		= @countAfterDecimal
				,roundNoDecimal			= @roundNoDecimal
				,factor					= @factor
				,rateMin				= @rateMin
				,rateMax				= @rateMax
				,modifiedBy				= @user
				,modifiedDate			= GETDATE()
			WHERE currencyId = @currencyId
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @currencyId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @currencyId, @user, @oldValue, @newValue, @module
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @currencyId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @currencyId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE currencyMaster SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE currencyId = @currencyId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @currencyId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @currencyId, @user, @oldValue, @newValue, @module
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @currencyId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @currencyId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'currencyId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.currencyId
					,main.currencyCode
					,main.isoNumeric
					,main.currencyName
					,main.currencyDesc
					,main.currencyDecimalName
					,main.countAfterDecimal
					,main.roundNoDecimal
					,main.factor
					,main.rateMin
					,main.rateMax
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM currencyMaster main WITH(NOLOCK)
					WHERE 1 = 1 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @currencyCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND currencyCode = ''' + @currencyCode + ''''
		
		IF @isoNumeric IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isoNumeric = ''' + @isoNumeric + ''''
		
		IF @currencyName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND currencyName = ''%' + @currencyName + '%'''
			
		SET @select_field_list ='
			 currencyId
			,currencyCode
			,isoNumeric
			,currencyName
			,currencyDesc
			,currencyDecimalName
			,countAfterDecimal
			,roundNoDecimal
			,factor
			,rateMin
			,rateMax
			,createdBy
			,createdDate
			,isDeleted '
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
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @currencyId
END CATCH




