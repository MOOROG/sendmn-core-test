USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentBusinessHistory]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentBusinessHistory]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@abhId                              VARCHAR(30)    = NULL
	,@agentId                            INT            = NULL
	,@remitCompany                       VARCHAR(100)   = NULL
	,@fromDate                           VARCHAR(10)    = NULL
	,@toDate                             VARCHAR(10)    = NULL
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
		 @logIdentifier = 'abhId'
		,@logParamMain = 'agentBusinessHistory'
		,@logParamMod = 'agentBusinessHistoryMod'
		,@module = '20'
		,@tableAlias = ''
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO agentBusinessHistory (
				 agentId
				,remitCompany
				,fromDate
				,toDate
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@remitCompany
				,@fromDate
				,@toDate
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @abhId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @abhId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @abhId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @abhId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM agentBusinessHistory WITH(NOLOCK) WHERE abhId = @abhId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentBusinessHistory SET
				 agentId = @agentId
				,remitCompany = @remitCompany
				,fromDate = @fromDate
				,toDate = @toDate
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE abhId = @abhId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @abhId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @abhId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @abhId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @abhId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentBusinessHistory SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE abhId = @abhId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @abhId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @abhId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @abhId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @abhId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'status'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					main.abhId
					,main.agentId
					,main.remitCompany
					,main.fromDate
					,main.toDate
					,status = CASE WHEN main.toDate IS NULL THEN ''Current'' ELSE ''Past'' END
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentBusinessHistory main WITH(NOLOCK)
					WHERE agentId = ' + CAST(@agentId AS VARCHAR) + '
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 abhId
			,agentId
			,remitCompany
			,fromDate
			,toDate
			,status
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
     EXEC proc_errorHandler 1, @errorMessage, @abhId
END CATCH



GO
