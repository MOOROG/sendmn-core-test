USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_apiLocation]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC proc_apiLocation @flag = 'l', @user='bharat'
	EXEC proc_apiLocation @flag = 'apil', @user = 'admin'
	EXEC proc_apiLocation @flag = 'fl'
*/

CREATE proc [dbo].[proc_apiLocation]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@cod								INT				= NULL
	,@districtId						INT				= NULL
	,@districtCode						INT				= NULL
	,@districtName						VARCHAR(50)		= NULL
	,@district							VARCHAR(100)	= NULL	
	,@zone								VARCHAR(100)	= NULL
	,@region							VARCHAR(100)	= NULL
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
		 @sql           VARCHAR(MAX)
		,@oldValue      VARCHAR(MAX)
		,@newValue      VARCHAR(MAX)
		,@tableName     VARCHAR(50)
    DECLARE
         @select_field_list VARCHAR(MAX)
        ,@extra_field_list  VARCHAR(MAX)
        ,@table             VARCHAR(MAX)
        ,@sql_filter        VARCHAR(MAX)
    DECLARE
		 @gridName              VARCHAR(50)
        ,@modType               VARCHAR(6)

	DECLARE
		 @code						VARCHAR(50)
		,@userName					VARCHAR(50)
		,@password					VARCHAR(50)
	
	
	--EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT
	
	IF @flag = 'l'
	BEGIN
		SELECT 
			 districtCode
			,districtName = UPPER(districtName) 
		FROM api_districtList WITH(NOLOCK) 
		WHERE ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'Y') = 'Y'
		ORDER BY districtName
	END

	ELSE IF @flag = 'apil'		--API Location List
	BEGIN
		Exec [192.168.2.1].ime_plus_01.dbo.spa_SOAP_Domestic_DistrictList 
		@code,@userName,@password,'1234','c'
	END

	ELSE IF @flag = 'fl'
	BEGIN
		SELECT [value], [text] FROM (
			SELECT NULL [value], 'All' [text] UNION ALL
			
			SELECT
				 dl.districtCode [value]
				,dl.districtName [text]
				--,am.agentType
			FROM api_districtList dl WITH(NOLOCK)
			WHERE ISNULL(dl.isDeleted, 'N') <> 'Y'	
		) x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.[value] AS VARCHAR) ELSE x.[text] END
		RETURN
	END
	
	ELSE IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM api_districtList WHERE ISNULL(isDeleted, 'N') <> 'Y' AND districtCode = @districtCode)
		BEGIN
			EXEC proc_errorHandler 1, 'District Code already exist', NULL
			RETURN
		END 
		IF EXISTS(SELECT 'X' FROM api_districtList WHERE ISNULL(isDeleted, 'N') <> 'Y' AND districtName = @districtName)
		BEGIN
			EXEC proc_errorHandler 1, 'District Name already exist', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO api_districtList(
				 districtCode
				,districtName
				,fromAPI
				,isActive
				,createdBy
				,createdDate
			)
			SELECT
				 @districtCode
				,@districtName
				,'N'
				,@isActive
				,@user
				,GETDATE()
			
			SET @districtId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  'api_districtList', 'rowId', @districtId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, 'API Location', @districtId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @districtId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @districtId
	END
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			EXEC [dbo].proc_GetColumnToRow  'api_districtList', 'rowId', @districtId, @oldValue OUTPUT
			UPDATE api_districtList SET
				 districtCode	= @districtCode
				,districtName	= @districtName
				,modifiedBy		= @user
				,modifiedDate	= GETDATE()
				,isActive       = @isActive
			WHERE rowId = @districtId
			EXEC [dbo].proc_GetColumnToRow  'api_districtList', 'rowId', @districtId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, 'API Location', @districtId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @districtId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @districtId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM api_districtList WHERE rowId = @districtId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM api_districtList WHERE rowId = @districtId AND fromAPI = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Cannot delete this record', @districtId
			RETURN
		END
		BEGIN TRANSACTION
			UPDATE api_districtList SET
				 isActive	= 'N'
				,isDeleted	= 'Y'
			WHERE rowId = @districtId
			SET @modType = SCOPE_IDENTITY()
			EXEC [dbo].proc_GetColumnToRow 'api_districtList', 'rowId', @districtId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, 'API Location', @districtId, @user, @oldValue, @newValue
			IF EXISTS(SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @districtId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @districtId
		
	END
	ELSE IF @flag = 'ii'
	BEGIN
		IF EXISTS(SELECT 'X' FROM api_districtList WHERE
						code = @cod
					AND districtCode = @districtCode
					AND districtName = @districtName)
		BEGIN
			RETURN
		END
		INSERT INTO api_districtList(
			 code
			,districtCode
			,districtName
		)
		SELECT
			 @cod
			,@districtCode
			,UPPER(@districtName)
	END

	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'districtCode'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
			--SELECT * FROM api_districtList
			--SELECT * FROM apiLocationMapping
			--SELECT * FROM zoneDistrictMap
		SET @table = '(
							SELECT 
								 adl.rowId 
								,locationCode=adl.districtCode
								,locationName=adl.districtName
								,zoneName = csm.stateName
								,districtName=zdm.districtName
								,regionName=SDV.detailTitle
								,adl.isDeleted
								,isActive=case when adl.isActive=''N'' then ''No'' else ''Yes'' end
							FROM api_districtList adl
							LEFT JOIN apiLocationMapping alm WITH(NOLOCK) ON adl.districtCode = alm.apiDistrictCode
							LEFT JOIN zoneDistrictMap zdm WITH(NOLOCK) ON alm.districtId = zdm.districtId
							LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON csm.stateId = zdm.zone
							LEFT JOIN staticDataValue SDV WITH(NOLOCK) ON SDV.valueId=zdm.regionId
							WHERE 1=1
				) x'
		SET @sql_filter = ' AND ISNULL(isDeleted, ''N'') <> ''Y'''
			
		IF @districtCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(locationCode, '''') = ' + CAST(@districtCode AS VARCHAR)
		
		IF @districtName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(locationName, '''') LIKE ''%' + @districtName + '%'''

		IF @district IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(districtName, '''') LIKE ''%' + @district + '%'''
		
		IF @zone IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(zoneName, '''') LIKE ''%' + @zone + '%'''
			
		IF @region IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(regionName, '''') LIKE ''%' + @region + '%'''
			
		SET @select_field_list ='
			 rowId
			,locationCode
			,locationName
			,zoneName
			,districtName
			,regionName
			,isActive
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

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
