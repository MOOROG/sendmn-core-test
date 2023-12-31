USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentFinancialService]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentFinancialService]
 	@flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@afsId                              VARCHAR(30)    = NULL
	,@agentId                            INT            = NULL
	,@fService                           INT            = NULL
	,@serviceList						 VARCHAR(MAX)	= NULL
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
		 @logIdentifier = 'afsId'
		,@logParamMain = 'agentFinancialService'
		,@logParamMod = 'agentFinancialServiceMod'
		,@module = '20'
		,@tableAlias = ''
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = 'SELECT 
						 agentId = ' + CAST(@agentId AS VARCHAR) + '
						,valueId
						,createdBy = ''' + @user + '''
						,createdDate = GETDATE()
						,approvedBy = ''system''
						,approvedDate = GETDATE()					
					FROM staticDataValue 
					WHERE typeId = 4400 AND valueId IN(' + @serviceList + ')	
					'
					
		BEGIN TRANSACTION
			--DELETE FROM rsList WHERE agentId = @agentId AND agentRole = @agentRole
		
			INSERT INTO agentFinancialService (
				 agentId
				,fService
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
			)
			
			EXEC (@sql)
				
			SET @modType = CASE WHEN @flag = 'i' THEN 'Insert' ELSE 'Update' END
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @afsId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @afsId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @afsId
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @afsId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			DELETE FROM agentFinancialService WHERE afsId = @afsId
			
			SET @modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @afsId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @afsId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @afsId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @afsId
	END

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'afsId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.afsId
					,main.agentId
					,main.fService
					,service = sdv.detailTitle
					,description = sdv.detailDesc
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentFinancialService main WITH(NOLOCK)
				LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.fService = sdv.valueId
					WHERE 1 = 1 AND main.agentId = ' + CAST(@agentId AS VARCHAR) + '
					) x'
					
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		SET @select_field_list ='
			 afsId
			,agentId
			,fService
			,service
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
     EXEC proc_errorHandler 1, @errorMessage, @afsId
END CATCH


GO
