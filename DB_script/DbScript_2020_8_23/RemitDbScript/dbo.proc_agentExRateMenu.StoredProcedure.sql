USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentExRateMenu]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_agentExRateMenu]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(50)		= NULL
	,@rowId				INT				= NULL
	,@countryId			INT				= NULL
	,@agentId			INT				= NULL
	,@menuId			INT				= NULL
	,@countryName		VARCHAR(100)	= NULL
	,@agentName			VARCHAR(100)	= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL

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
		 @logIdentifier = 'rowId'
		,@logParamMain = 'agentExRateMenu'
		,@logParamMod = 'agentExRateMenuMod'
		,@module = '20'
		,@tableAlias = 'Agent Exchange Rate Menu'
		
	IF @flag IN ('i')
	BEGIN	
		IF EXISTS(SELECT 'X' FROM agentExRateMenu WITH(NOLOCK) WHERE countryId = @countryId AND ISNULL(agentId, 0) = ISNULL(@agentId, 0))
		BEGIN
			EXEC proc_errorHandler 1, 'Menu already assigned for this setting', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO agentExRateMenu (
				 countryId
				,agentId
				,menuId
				,createdBy
				,createdDate
			)
			SELECT
				 @countryId
				,@agentId
				,@menuId
				,@user
				,GETDATE()
				
			SET @rowId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'X' FROM agentExRateMenu WITH(NOLOCK) WHERE rowId <> @rowId AND countryId = @countryId AND ISNULL(agentId, 0) = ISNULL(@agentId, 0))
		BEGIN
			EXEC proc_errorHandler 1, 'Menu already assigned for this setting', NULL
			RETURN
		END
		BEGIN TRANSACTION
			UPDATE agentExRateMenu SET
				 countryId			= @countryId
				,agentId			= @agentId
				,menuId				= @menuId
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			WHERE rowId = @rowId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @rowId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			SET @modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @rowId
				RETURN
			END
			
			DELETE FROM agentExRateMenu WHERE rowId = @rowId
			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		--SELECT * FROM agentExRateMenu
		SELECT * FROM agentExRateMenu WITH(NOLOCK) WHERE rowId = @rowId
	END
	
	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'rowId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.rowId
					,main.countryId
					,countryName = cm.countryName
					,main.agentId
					,agentName = ISNULL(am.agentName, ''All'')
					,main.menuId
					,menuName = sdv.detailTitle
					,modifiedBy = ISNULL(main.modifiedBy, main.createdBy)
					,modifiedDate = ISNULL(main.modifiedDate, main.createdDate)
				FROM agentExRateMenu main WITH(NOLOCK)
				LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.countryId = cm.countryId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
				LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.menuId = sdv.valueId
					WHERE 1 = 1
					) x'
					
		SET @sql_filter = ''
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''	
		
		SET @select_field_list ='
			 rowId
			,countryId
			,countryName
			,agentId
			,agentName
			,menuId
			,menuName
			,modifiedBy
			,modifiedDate
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
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowId
END CATCH


GO
