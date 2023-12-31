USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryStateMaster]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_countryStateMaster]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@stateId                           VARCHAR(30)		= NULL
	,@countryId							INT				= NULL
	,@stateCode                         VARCHAR(10)		= NULL
	,@stateName							VARCHAR(50)		= NULL
	,@countryName						VARCHAR(200)	= NULL
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
		 @logIdentifier = 'stateId'
		,@logParamMain = 'countryStateMaster'
		,@logParamMod = 'countryStateMasterMod'
		,@module = '20'
		,@tableAlias = ''
	
	IF @flag = 'csl'
	BEGIN
		SELECT 
			 stateId
			,stateName 
		FROM countryStateMaster WITH(NOLOCK) 
		WHERE countryId = @countryId
		AND ISNULL(isDeleted, 'N') <> 'Y'
		ORDER BY stateName
	END		
	IF @flag = 'csl2'
	BEGIN
		SELECT 
			 stateId
			,stateName 
		FROM countryStateMaster a WITH(NOLOCK) 
		inner join countryMaster b with(nolock) on a.countryId=b.countryId
		WHERE b.countryName = @countryName
		AND ISNULL(A.isDeleted, 'N') <> 'Y'
		ORDER BY stateName
	END	
	ELSE IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			IF EXISTS (SELECT countryId FROM dbo.countryStateMaster WHERE stateCode = @stateCode)
			BEGIN
				ROLLBACK TRANSACTION
			    EXEC proc_errorHandler 1, 'State with same state code already exists.', NULL
			END
                
				INSERT INTO countryStateMaster(
				 countryId
				,stateCode
				,stateName
				,createdBy
				,createdDate
				)
				SELECT
					 @countryId
					,@stateCode
					,@stateName
					,@user
					,GETDATE()
				SET @modType = 'Insert'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @stateId , @newValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @stateId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @stateId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @stateId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM countryStateMaster WITH(NOLOCK) WHERE stateId = @stateId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			EXEC [dbo].proc_GetColumnToRow @logParamMain, @logIdentifier, @stateId, @oldValue OUTPUT
			UPDATE countryStateMaster SET
				 countryId = @countryId
				,stateCode = @stateCode
				,stateName = @stateName
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE stateId = @stateId
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow @logParamMain, @logIdentifier, @stateId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @stateId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @stateId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @stateId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE countryStateMaster SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE stateId = @stateId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @stateId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @stateId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @stateId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @stateId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'stateId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.stateId
					,main.countryId
					,main.stateCode
					,main.stateName
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM countryStateMaster main WITH(NOLOCK)
					WHERE 1 = 1 AND main.countryId = ' + CAST(@countryId AS VARCHAR) + '
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @stateCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND stateCode LIKE ''' + @stateCode + '%'''
			
		IF @stateName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND stateName LIKE ''' + @stateName + '%'''	

		SET @select_field_list ='
			 stateId
			,countryId
			,stateCode
			,stateName
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
     EXEC proc_errorHandler 1, @errorMessage, @stateId
END CATCH


GO
