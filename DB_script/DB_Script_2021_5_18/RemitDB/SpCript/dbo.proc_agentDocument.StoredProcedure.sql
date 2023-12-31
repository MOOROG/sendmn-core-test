USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentDocument]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentDocument]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@adId                               VARCHAR(30)    = NULL
	,@adIds								 VARCHAR(MAX)	= NULL
	,@agentId                            INT            = NULL
	,@fileName							 VARCHAR(50)	= NULL
	,@fileDescription                    VARCHAR(100)   = NULL
	,@fileType                           VARCHAR(10)    = NULL
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
		 @logIdentifier = 'adId'
		,@logParamMain = 'agentDocument'
		,@logParamMod = 'agentDocumentMod'
		,@module = '20'
		,@tableAlias = ''
		
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType
			INSERT INTO agentDocument (
				 agentId
				,[fileName]
				,fileDescription
				,fileType
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@fileName
				,@fileDescription
				,@fileType
				,@user
				,GETDATE()
			
			SET @adId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @adId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @adId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @adId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'File Uploaded Successfully', @fileName
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM agentDocument WITH(NOLOCK) WHERE adId = @adId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentDocument SET
				 fileDescription = @fileDescription
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE adId = @adId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @adId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @adId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @adId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @adId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			--SELECT CAST(adId AS VARCHAR) + '.' + fileType AS [fileName] from agentDocument WHERE adId IN (@adIds)
			SET @sql='SELECT [fileName] FROM agentDocument WHERE adId IN (' + @adIds + ')'
			EXEC(@sql)
			set @sql='DELETE FROM agentDocument where adId in (' + @adIds + ')'
			EXEC(@sql)
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @adId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @adId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					RETURN
			END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
	END

	--ELSE IF @flag = 's'
	--BEGIN
	--	SELECT 
	--		 adId
	--		,agentId
	--		,fileDescription
	--		,fileType
	--		,createdBy
	--		,createdDate
	--		,isDeleted
	--	FROM agentDocument WITH(NOLOCK)
	--	WHERE agentId = @agentId
	--END
	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'adId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.adId
					,main.agentId
					,main.[fileName]
					,main.fileDescription
					,main.fileType
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentDocument main WITH(NOLOCK)
					WHERE agentId = ' + CAST(@agentId AS VARCHAR) + ' 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 adId
			,agentId
			,[fileName]
			,fileDescription
			,createdBy
			,createdDate
			,fileType '
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
     EXEC proc_errorHandler 1, @errorMessage, @adId
END CATCH


GO
