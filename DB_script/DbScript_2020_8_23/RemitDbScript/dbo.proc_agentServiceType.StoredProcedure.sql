USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentServiceType]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--agentServiceType

CREATE proc [dbo].[proc_agentServiceType]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@agentId                            VARCHAR(30)    = NULL
	,@agentServiceTypeId				 INT            = NULL
	,@serviceTypeId                      VARCHAR(MAX)   = NULL
	,@agentType                          INT            = NULL
	,@agentName							 VARCHAR(50)	= NULL
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
		 @logIdentifier = 'agentServiceTypeId'
		,@logParamMain = 'agentServiceType'
		
		,@module = '20'
		,@tableAlias = 'Agent Service Type'
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = 'SELECT 
						 agentId = ' + CAST(@agentId AS VARCHAR) + '
						,serviceTypeId						
						,createdBy = ''' + @user + '''
						,createdDate = GETDATE()						
						,approvedBy = ''system''
						,approvedDate = GETDATE()
						,isActive = ''Y''	
					FROM serviceTypeMaster
					WHERE serviceTypeId IN(' + @serviceTypeId + ')	
					'
						
		BEGIN TRANSACTION
			--DELETE FROM agentServiceType WHERE agentId = @agentId AND serviceTypeId = @serviceTypeId
		
			INSERT INTO agentServiceType (				 
				 agentId
				,serviceTypeId				
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
			DELETE FROM agentServiceType WHERE agentServiceTypeId = @agentServiceTypeId
			
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
			SET @sortBy = 'agentServiceTypeId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.agentServiceTypeId
					,main.agentId
					,main.serviceTypeId
					,stm.typeTitle
					,agentName = am.agentName
					,am.agentType
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentServiceType main WITH(NOLOCK)
				INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.serviceTypeId = stm.serviceTypeId
				LEFT JOIN agentMaster am ON am.agentId = main.agentId
					WHERE 1 = 1 AND am.agentType IS NOT NULL
					AND am.agentId = ' + CAST(@agentId AS VARCHAR) + '
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		SET @select_field_list ='
			 agentServiceTypeId
			,agentId
			,serviceTypeId
			,agentName
			,typeTitle
			,agentType
			,createdBy
			,createdDate
			,isDeleted '
			
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
			
		IF @agentType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentType = ' + CAST(@agentType AS VARCHAR)
			
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
			SET @sortBy = 'serviceTypeId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		
		
		SET @table = '(
				SELECT
					 *
				FROM serviceTypeMaster WITH(NOLOCK)			
					WHERE 1 = 1
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y''	
											AND serviceTypeId NOT IN (
																	SELECT 
																		serviceTypeId
																	FROM agentServiceType ast
																	INNER JOIN agentMaster am ON ast.agentId = am.agentId
																	WHERE ast.agentId = ' + CAST(@agentId AS VARCHAR)
																	+
																')'								  
			
			
		
		
		SET @select_field_list = '
			 serviceTypeId
			,serviceCode
			,typeTitle
			,createdBy
			,createdDate
			,isDeleted '
			
		--IF @agentName IS NOT NULL
		--	SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
		
		--SELECT @agentType = agentType FROM agentMaster WHERE agentId = @agentId
		--SET @sql_filter = @sql_filter + ' AND agentType = ' + CAST(@agentType AS VARCHAR)
			
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
