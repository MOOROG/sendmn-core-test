USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentInfo]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentInfo]
 	 @flag								VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@agentInfoId                       VARCHAR(30)    = NULL
	,@agentId                           INT            = NULL
	,@date                              DATETIME       = NULL
	,@subject                           VARCHAR(100)   = NULL
	,@description                       VARCHAR(MAX)   = NULL
	,@sortBy                            VARCHAR(50)    = NULL
	,@sortOrder                         VARCHAR(5)     = NULL
	,@pageSize                          INT            = NULL
	,@pageNumber                        INT            = NULL


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
		 @logIdentifier = 'agentInfoId'
		,@logParamMain = 'agentInfo'
		,@logParamMod = 'agentInfoMod'
		,@module = '20'
		,@tableAlias = ''
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO agentInfo (
				 agentId
				,[date]
				,[subject]
				,[description]
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@date
				,@subject
				,@description
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentInfoId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentInfoId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @agentInfoId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentInfoId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			 *
			,CONVERT(VARCHAR,[date],101)date1
		FROM agentInfo WITH(NOLOCK) WHERE agentInfoId = @agentInfoId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentInfo SET
				 agentId = @agentId
				,[date] = @date
				,[subject] = @subject
				,[description] = @description
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE agentInfoId = @agentInfoId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentInfoId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentInfoId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @agentInfoId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @agentInfoId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentInfo SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE agentInfoId = @agentInfoId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @agentInfoId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @agentInfoId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @agentInfoId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentInfoId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'agentInfoId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.agentInfoId
					,main.agentId
					,date = CONVERT(VARCHAR,main.date,101)
					,main.subject
					,main.description
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentInfo main WITH(NOLOCK)
					WHERE agentId = ' + CAST(@agentId AS VARCHAR) + ' AND 1 = 1 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 agentInfoId
			,agentId
			,date
			,subject
			,description
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
     EXEC proc_errorHandler 1, @errorMessage, @agentInfoId
END CATCH



GO
