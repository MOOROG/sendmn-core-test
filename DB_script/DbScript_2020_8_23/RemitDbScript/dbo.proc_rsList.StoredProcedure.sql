USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_rsList]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_rsList]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@agentId                            VARCHAR(30)    = NULL
	,@rsListId                           INT            = NULL
	,@rsList							 VARCHAR(MAX)   = NULL
	,@agentType                          INT	        = NULL
	,@agentRole                          CHAR(1)        = NULL
	,@agentName							 VARCHAR(50)	= NULL
	,@listType							 CHAR(2)		= NULL
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
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
	
	SELECT
		 @logIdentifier = 'rsListId'
		,@logParamMain = 'rsList'
		
		,@module = '20'
		,@tableAlias = CASE WHEN @agentRole = 'r' THEN 'Receiving List' ELSE 'Sending List' END
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = 'SELECT 
						 agentId = ' + CAST(@agentId AS VARCHAR) + '
						,rsAgentId = agentId
						,agentRole = ''' + @agentRole + '''
						,listType = '''+ ISNULL(@listType,'0') +'''
						,createdBy = ''' + @user + '''
						,createdDate = GETDATE()
						,approveddBy = ''system''
						,approvedDate = GETDATE()
						,isActive = ''Y''						
					FROM agentMaster
					WHERE agentType IS NOT NULL AND agentId IN(' + @rsList + ')	
					'
					
		BEGIN TRANSACTION
			--DELETE FROM rsList WHERE agentId = @agentId AND agentRole = @agentRole
		
			INSERT INTO rsList (
				 agentId
				,rsAgentId
				,agentRole
				,listType
				,createdBy
				,createdDate
				,approvedBy
				,approvedDate
				,isActive
			)
			
			EXEC (@sql)
				
			SET @modType = CASE WHEN @flag = 'i' THEN 'Insert' ELSE 'Update' END
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @agentId
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			DELETE FROM rsList WHERE rsListId = @rsListId
			
			SET @modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @agentId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @agentId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @agentId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.rsListId
					,main.agentId
					,main.rsAgentId
					,agentName = am.agentName
					,main.agentRole
					,am.agentType
					,agentType1 = sdv.detailTitle
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM rsList main WITH(NOLOCK)
				INNER JOIN agentMaster am WITH(NOLOCK) ON main.rsAgentId = am.agentId
				LEFT JOIN staticDataValue sdv ON am.agentType = sdv.valueId
					WHERE 1 = 1 AND main.AgentId = ' + CAST(@agentId AS VARCHAR) + ' AND ISNULL(main.listType,''0'') = ''' + ISNULL(@listType,'0') + '''
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		PRINT @table
		
		SET @select_field_list ='
			 rsListId
			,agentId
			,rsAgentId
			,agentName
			,agentRole
			,agentType1
			,createdBy
			,createdDate
			,isDeleted '
			
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
			
		IF @agentType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentType = ' + CAST(@agentType AS VARCHAR)
		
		IF @agentRole IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentRole = ''' + @agentRole + ''''
				
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
	
	ELSE IF @flag IN ('ls') --LS
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
			
		SET @table = '(
				SELECT
					 main.agentId					
					,agentName = main.agentName
					,main.agentType
					,agentType1 = sdv.detailTitle
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentMaster main WITH(NOLOCK)
				LEFT JOIN staticDataValue sdv ON main.agentType = sdv.valueId			
					WHERE 1 = 1 AND main.agentType IS NOT NULL AND main.AgentId <> ' + CAST(@agentId AS VARCHAR) + '
					) x '
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y''
											AND agentId NOT IN (
																	SELECT 
																		rsAgentId 
																	FROM rsList 
																	WHERE agentRole = ''' + @agentRole + ''' 
																	AND agentId = ' + CAST(@agentId AS VARCHAR)
																	+
																')'
			

		IF @agentType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentType = ' + CAST(@agentType AS VARCHAR)
		
		SET @select_field_list ='
			 agentId
			,agentName
			,agentType
			,agentType1
			,createdBy
			,createdDate
			,isDeleted '
			
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
				
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
     EXEC proc_errorHandler 1, @errorMessage, @agentId
END CATCH



GO
