USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentComMaster]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_agentComMaster]
	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@COMM_ID                            VARCHAR(30)    = NULL
	,@COMM_NAME                          VARCHAR(200)   = NULL
	,@COMM_DESC                          VARCHAR(500)   = NULL
	,@IS_ACTIVE                          CHAR(10)       = NULL
	,@sortBy                             VARCHAR(50)    = NULL
	,@sortOrder                          VARCHAR(5)     = NULL
	,@pageSize                           INT            = NULL
	,@pageNumber                         INT            = NULL
	
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

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
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@functionId		INT
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@verifyInsert		CHAR(1)
		,@verifyUpdate		CHAR(1)
		,@verifyDelete		CHAR(1)

	SELECT
		 @functionId = 0
		,@logIdentifier = 'COMM_ID'
		,@logParamMain = 'agentComMaster'
		,@logParamMod = 'agentComMasterMod'
		,@module = ''
		,@tableAlias = ''

		
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
		
		
			INSERT INTO agentComMaster (
				 COMM_NAME
				,COMM_DESC
				,IS_ACTIVE
				,created_By
				,created_Date
			)
			SELECT
				 @COMM_NAME
				,@COMM_DESC
				,@IS_ACTIVE
				,@user
				,GETDATE()
				
			SET @id = SCOPE_IDENTITY()
			IF @verifyInsert = 'N'
			BEGIN
				UPDATE agentComMaster SET
					approved_By= 'system'
					,approved_Date= GETDATE()
				WHERE COMM_ID = @id
				
				SET @modType = 'Insert'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @COMM_ID , @newValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @COMM_ID, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
				
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to add new record.', @COMM_ID
					RETURN
				
				END
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @COMM_ID
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		
			SELECT * FROM agentComMaster WITH(NOLOCK) WHERE COMM_ID = @COMM_ID
	
	END
	ELSE IF @flag = 's'
	BEGIN
		
			SELECT * FROM agentComMaster WITH(NOLOCK)
	
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentComMaster WITH(NOLOCK)
			WHERE COMM_ID = @COMM_ID AND ( created_By <> @user AND approved_By IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @COMM_ID
			RETURN
		END
		
		
		BEGIN TRANSACTION
			
			IF EXISTS (SELECT 'X' FROM agentComMaster WHERE approved_By IS NULL AND COMM_ID  = @COMM_ID)
				OR @verifyUpdate = 'N'
			BEGIN
			
				SET @modType = 'Insert'
				--Record in main table not approved yet
				
				IF EXISTS(SELECT 'X' FROM agentComMaster WHERE approved_By IS NOT NULL AND COMM_ID = @COMM_ID)
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @COMM_ID, @oldValue OUTPUT
					SET @modType = 'Update'
				END
				
				UPDATE agentComMaster SET
					 COMM_NAME                     = @COMM_NAME
					,COMM_DESC                     = @COMM_DESC
					,IS_ACTIVE                     = @IS_ACTIVE
					,modify_By = CASE WHEN @verifyUpdate = 'N' THEN @user ELSE modify_By END
					,modify_Date = CASE WHEN @verifyUpdate = 'N' THEN GETDATE() ELSE modify_Date END
				WHERE COMM_ID = @COMM_ID
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @COMM_ID, @newValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @COMM_ID, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to update record.', @COMM_ID
					RETURN
				END
			END
			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @COMM_ID
	END
	ELSE IF @flag = 'd'
	BEGIN
	
		IF EXISTS (
			SELECT 'X' FROM agentComMaster WITH(NOLOCK)
			WHERE COMM_ID = @COMM_ID  AND (created_By <> @user AND approved_By IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @COMM_ID
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentComMasterMod  WITH(NOLOCK)
			WHERE COMM_ID = @COMM_ID
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @COMM_ID
			RETURN
		END

			BEGIN TRANSACTION
		
				UPDATE agentComMaster SET
					is_Delete = 'Y'
					,modify_Date  = GETDATE()
					,modify_By = @user
				WHERE COMM_ID = @COMM_ID
				SET @modType = 'Delete'
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @COMM_ID, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @COMM_ID, @user, @oldValue, @newValue
				
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @COMM_ID
					RETURN
				END
				
				
			IF @@TRANCOUNT > 0
			
			COMMIT TRANSACTION
		

			EXEC proc_errorHandler 0, 'Record deleted successfully.', @COMM_ID
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @COMM_ID
END CATCH


GO
