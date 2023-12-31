USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_enrollCommSetup]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_enrollCommSetup]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@enrollCommId								INT				= NULL
	,@agentId                         VARCHAR(30)		= NULL
	,@agentName						VARCHAR(200)		= NULL
	,@commRate                       VARCHAR(10)		= NULL
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
		 @logIdentifier = 'countryId'
		,@logParamMain = 'countryMaster'
		,@logParamMod = 'countryMasterMod'
		,@module = '20'
		,@tableAlias = 'Country Master'	

	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM enrollcommsetup WITH(NOLOCK) WHERE agentId = @agentId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Enroll Commission Rate already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			
			INSERT INTO enrollcommsetup (
				 agentId
				,commRate
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@commRate
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @enrollCommId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @enrollCommId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @enrollCommId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @enrollCommId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT enrollCommId,a.agentId,commRate,B.agentName		
		FROM enrollcommsetup a WITH(NOLOCK) INNER JOIN agentMaster B WITH(NOLOCK)
		ON a.agentId=B.agentId WHERE enrollCommId = @enrollCommId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE 
			       enrollcommsetup SET
				   agentId = @agentId
				  ,commRate = @commRate
				  ,modifiedBy = @user
				  ,modifiedDate = GETDATE()
			WHERE enrollCommId = @enrollCommId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @enrollCommId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @enrollCommId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @enrollCommId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @enrollCommId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE enrollcommsetup SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE enrollCommId = @enrollCommId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @enrollCommId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @enrollCommId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @enrollCommId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @enrollCommId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'enrollCommId'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '(
				SELECT
					 main.enrollCommId
					,main.agentId
					,agentName=case when am.agentName is null then ''All Agent'' else am.agentName end 
					,main.commRate					   
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM enrollcommsetup main WITH(NOLOCK) left join agentMaster am on am.agentId=main.agentId
					WHERE 1 = 1 
					) x'

		SET @sql_filter = ''

		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentId = ''' + @agentId + ''''
			
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
			
		IF @commRate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND commRate = ''' + @commRate + ''''
			
		SET @select_field_list ='
			 enrollCommId
			,agentId
			,agentName
			,commRate
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
     EXEC proc_errorHandler 1, @errorMessage, @enrollCommId
END CATCH


GO
