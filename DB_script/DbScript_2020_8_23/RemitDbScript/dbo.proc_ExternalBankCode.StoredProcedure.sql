USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ExternalBankCode]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_ExternalBankCode]
 	 @flag								VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@extBankCodeId						VARCHAR(20)		= NULL
	,@agentId							VARCHAR(20)		= NULL
	,@bankId							VARCHAR(20)		= NULL
	,@externalCode						VARCHAR(50)		= NULL
	,@agentName							VARCHAR(100)	=NULL
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
		 @logIdentifier = 'extBankCodeId'
		,@logParamMain = 'ExternalBankCode'
		,@module = '20'
		,@tableAlias = ''
		
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO ExternalBankCode (
				 agentId
				,bankId
				,externalCode
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@bankId
				,@externalCode
				,@user
				,GETDATE()
				
			SET @extBankCodeId = @@IDENTITY
			SET @modType = 'Insert'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @extBankCodeId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @logParamMain, @extBankCodeId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @extBankCodeId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @extBankCodeId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			exb.*,
			am.agentName
		FROM ExternalBankCode exb WITH(NOLOCK)
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = exb.agentId
		 WHERE exb.extBankCodeId = @extBankCodeId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE ExternalBankCode SET
				 agentId = @agentId
				,bankId = @bankId
				,externalCode = @externalCode
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE extBankCodeId = @extBankCodeId
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @extBankCodeId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @logParamMain, @extBankCodeId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @extBankCodeId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @extBankCodeId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE ExternalBankCode SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE extBankCodeId = @extBankCodeId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @extBankCodeId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @logParamMain,  @extBankCodeId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @extBankCodeId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @extBankCodeId
	END

	ELSE IF @flag ='s'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'extBankCodeId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
					SELECT 
						EBC.extBankCodeId
						,EBC.externalCode
						,AM.agentName 
						,EB.bankName
						,EBC.createdBy
						,EBC.createdDate
						,EBC.isDeleted
						,EBC.bankId
					FROM ExternalBankCode EBC WITH(NOLOCK)
					INNER JOIN agentMaster AM WITH (NOLOCK) ON AM.agentId = EBC.agentId
					INNER JOIN ExternalBank EB WITH (NOLOCK) ON EBC.bankId = EB.extBankId
					WHERE EBC.extBranchId is null
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		IF @bankId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND bankId = '''+@bankId+''''
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE  '''+@agentName+'%'''
		SET @select_field_list ='
			 extBankCodeId
			,externalCode
			,agentName
			,bankName
			,createdBy
			,createdDate'
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
     EXEC proc_errorHandler 1, @errorMessage, @extBankCodeId
END CATCH



GO
