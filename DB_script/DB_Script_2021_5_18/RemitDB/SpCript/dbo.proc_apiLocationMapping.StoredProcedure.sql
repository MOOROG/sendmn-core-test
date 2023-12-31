USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_apiLocationMapping]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_apiLocationMapping]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@rowId                              VARCHAR(30)    = NULL
	,@stateId                            INT            = NULL
	,@districtId                         INT            = NULL
	,@apiDistrictCode                    INT            = NULL
	,@sortBy                             VARCHAR(50)    = NULL
	,@sortOrder                          VARCHAR(5)     = NULL
	,@pageSize                           INT            = NULL
	,@pageNumber                         INT            = NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql			VARCHAR(MAX)
		,@oldValue		VARCHAR(MAX)
		,@newValue		VARCHAR(MAX)
		,@module		VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table			VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType		VARCHAR(6)
	SELECT
		 @logIdentifier = 'rowId'
		,@logParamMain = 'apiLocationMapping'
		,@logParamMod = 'apiLocationMappingMod'
		,@module = ''
		,@tableAlias = 'API Location Mapper'
	
	IF @flag = 'dl'		--district list
	BEGIN
		SELECT
			 loc.districtId
			,districtName = dist.districtName
		FROM apiLocationMapping loc
		INNER JOIN zoneDistrictMap dist ON loc.districtId = dist.districtId
		WHERE loc.apiDistrictCode = @apiDistrictCode
	END
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
		IF EXISTS(SELECT 'X' FROM apiLocationMapping WHERE apiDistrictCode = @apiDistrictCode)
		BEGIN
			UPDATE apiLocationMapping SET
				 districtId = @districtId
			WHERE apiDistrictCode = @apiDistrictCode
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
		END
		ELSE
		BEGIN
			INSERT INTO apiLocationMapping (
				 districtId
				,apiDistrictCode
				,createdBy
				,createdDate
			)
			SELECT
				 @districtId
				,@apiDistrictCode
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
		END
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to map Location.', @apiDistrictCode
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Location Mapped successfully.', @apiDistrictCode
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			 alm.*
			,stateId = zdm.zone 
		FROM apiLocationMapping alm WITH(NOLOCK)
		INNER JOIN zoneDistrictMap zdm WITH(NOLOCK) ON alm.districtId = zdm.districtId 
		WHERE apiDistrictCode = @apiDistrictCode
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE apiLocationMapping SET
				 districtId = @districtId
			WHERE apiDistrictCode = @apiDistrictCode
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @apiDistrictCode
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @apiDistrictCode
	END
	
	--ELSE IF @flag = 'd'
	--BEGIN
	--	BEGIN TRANSACTION
	--		UPDATE apiLocationMapping SET
	--			isDeleted = 'Y'
	--			,modifiedDate  = GETDATE()
	--			,modifiedBy = @user
	--		WHERE rowId = @rowId
	--		SET @modType = 'Delete'
	--		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
	--		INSERT INTO #msg(errorCode, msg, id)
	--		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
	--		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
	--		BEGIN
	--				IF @@TRANCOUNT > 0
	--				ROLLBACK TRANSACTION
	--				EXEC proc_errorHandler 1, 'Failed to delete record.', @rowId
	--				RETURN
	--			END
	--		IF @@TRANCOUNT > 0
	--		COMMIT TRANSACTION
	--	EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
	--END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'rowId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.districtId
					,main.apiDistrictCode
					,main.createdBy
					,main.createdDate
				FROM apiLocationMapping main WITH(NOLOCK)
					WHERE 1 = 1 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 districtId
			,apiDistrictCode
			,createdBy
			,createdDate '
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
     EXEC proc_errorHandler 1, @errorMessage, @rowId
END CATCH


GO
