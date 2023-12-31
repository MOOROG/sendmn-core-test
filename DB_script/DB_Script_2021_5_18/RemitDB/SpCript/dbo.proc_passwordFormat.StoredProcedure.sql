USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_passwordFormat]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_passwordFormat]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_passwordFormat

GO
*/

CREATE proc [dbo].[proc_passwordFormat]
 	@flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId                             VARCHAR(30)		= NULL
	,@loginAttemptCount					INT				= NULL
	,@minPwdLength                      INT				= NULL
	,@pwdHistoryNum                     INT				= NULL
	,@specialCharNo                     INT				= NULL
	,@numericNo                         INT				= NULL
	,@capNo                             INT				= NULL
	,@lockUserDays						FLOAT			= NULL
	,@invalidControlNoForDay			INT				= NULL
	,@invalidControlNoContinous			INT				= NULL
	,@operationTimeFrom					TIME			= NULL
	,@operationTimeTo					TIME			= NULL
	,@globalOperationTimeEnable			CHAR(1)			= NULL
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
		,@logParamMain = 'passwordFormat'
		,@logParamMod = 'passwordFormatMod'
		,@module = '10'
		,@tableAlias = ''
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
		IF NOT EXISTS(SELECT 'X' FROM passwordFormat)
		BEGIN
			INSERT INTO passwordFormat (
				 loginAttemptCount
				,minPwdLength
				,pwdHistoryNum
				,specialCharNo
				,numericNo
				,capNo
				,invControlNoForDay
				,invControlNoContinous
				,lockUserDays
				,operationTimeFrom
				,operationTimeTo
				,globalOperationTimeEnable
				,isActive
				,createdBy
				,createdDate
			)
			SELECT
				 @loginAttemptCount
				,@minPwdLength
				,@pwdHistoryNum
				,@specialCharNo
				,@numericNo
				,@capNo
				,@invalidControlNoForDay
				,@invalidControlNoContinous
				,@lockUserDays
				,@operationTimeFrom
				,@operationTimeTo
				,@globalOperationTimeEnable
				,@isActive
				,@user
				,GETDATE()
			
			SET @rowId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
		END
		ELSE
		BEGIN
			UPDATE passwordFormat SET
				 loginAttemptCount				= @loginAttemptCount
				,minPwdLength					= @minPwdLength
				,pwdHistoryNum					= @pwdHistoryNum
				,specialCharNo					= @specialCharNo
				,numericNo						= @numericNo
				,capNo							= @capNo
				,invControlNoForDay				= @invalidControlNoForDay
				,invControlNoContinous			= @invalidControlNoContinous
				,lockUserDays					= @lockUserDays
				,isActive						= @isActive
				,operationTimeFrom				= @operationTimeFrom
				,operationTimeTo				= @operationTimeTo
				,globalOperationTimeEnable		= @globalOperationTimeEnable
				,modifiedBy						= @user
				,modifiedDate					= GETDATE()
			WHERE 1 = 1
			
			SET @rowId = SCOPE_IDENTITY()
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
		END
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
	ELSE IF @flag = 'a'
	BEGIN
		SELECT *, isActive1 = ISNULL(isActive, 'N') FROM passwordFormat WITH(NOLOCK)
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE passwordFormat SET
				 loginAttemptCount				= @loginAttemptCount
				,minPwdLength					= @minPwdLength
				,pwdHistoryNum					= @pwdHistoryNum
				,specialCharNo					= @specialCharNo
				,numericNo						= @numericNo
				,capNo							= @capNo
				,invControlNoForDay				= @invalidControlNoForDay
				,invControlNoContinous			= @invalidControlNoContinous
				,lockUserDays					= @lockUserDays
				,operationTimeFrom				= @operationTimeFrom
				,operationTimeTo				= @operationTimeTo
				,globalOperationTimeEnable		= @globalOperationTimeEnable
				,isActive						= @isActive
				,modifiedBy						= @user
				,modifiedDate					= GETDATE()
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
			UPDATE passwordFormat SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE rowId = @rowId
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
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
	END

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'rowId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.loginAttemptCount
					,main.minPwdLength
					,main.pwdHistoryNum
					,main.specialCharNo
					,main.numericNo
					,main.capNo
					,main.invControlNoForDay
					,main.invControlNoContinous
					,main.lockUserDays
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM passwordFormat main WITH(NOLOCK)
					WHERE 1 = 1 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 loginAttemptCount
			,minPwdLength
			,pwdHistoryNum
			,specialCharNo
			,numericNo
			,capNo
			,invControlNoForDay
			,invControlNoContinous
			,lockUserDays
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
     EXEC proc_errorHandler 1, @errorMessage, @rowId
END CATCH


GO
