USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_fileFormat]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_fileFormat]
 	 @flag                 	VARCHAR(50)    	= NULL
	,@user                 	VARCHAR(30)    	= NULL
	,@flFormatId           	VARCHAR(30)    	= NULL
	,@formatCode           	VARCHAR(10)    	= NULL
	,@formatType           	VARCHAR(50)    	= NULL
	,@flDescription        	VARCHAR(500)   	= NULL
	,@fldSeperator         	VARCHAR(20)    	= NULL
	,@fixDataLength        	CHAR(1)        	= NULL
	,@dataSourceCode       	VARCHAR(50)    	= NULL
     ,@sourceType			VARCHAR(50)    	= NULL
	,@includeColHeader  	CHAR(1)        	= NULL
	,@recordSeperator   	VARCHAR(10)    	= NULL
	,@filterClause			VARCHAR(MAX)	= NULL
	,@includeSerialNo		CHAR(1)			= NULL
	,@headerFormatCode		INT				= NULL
	,@isActive				CHAR(1)			= NULL
	,@agentId				INT				= NULL
	,@fileFormatIds			VARCHAR(MAX)	= NULL
	,@agentFfId				BIGINT			= NULL
	,@agentCountryId	 	INT				= NULL
	,@sortBy             	VARCHAR(50)    	= NULL
	,@sortOrder          	VARCHAR(5)     	= NULL
	,@pageSize            	INT            	= NULL
	,@pageNumber          	INT            	= NULL
AS

/*

     EXEC proc_fileFormat @flag = 'sfl', @dataSourceCode = 'tran' -- vw_Export_tran
	@flag,
	rs			- Displays row serperator in a list
	sfl			- Displays Field List From a Data source (generally View)
	ft			- File Format Type List

*/
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	IF @filterClause IS NOT NULL
		SET @filterClause = REPLACE(@filterClause,'"','''')

	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql					VARCHAR(MAX)
		,@oldValue				VARCHAR(MAX)
		,@newValue				VARCHAR(MAX)
		,@module				VARCHAR(10)
		,@tableAlias			VARCHAR(100)
		,@logIdentifier			VARCHAR(50)
		,@logParamMod			VARCHAR(100)
		,@logParamMain			VARCHAR(100)
		,@table					VARCHAR(MAX)
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@modType				VARCHAR(6)

	SELECT
		 @logIdentifier = 'flFormatId'
		,@logParamMain = 'fileFormat'
		,@logParamMod = 'fileFormatMod'
		,@module = '10'
		,@tableAlias = 'fileFormat'
	
	IF @formatType IN ('csv')
	BEGIN
		SELECT 
			 @fldSeperator = ',' 			
	END
	
	IF @flag = 'sfl'
	BEGIN
		SELECT 
			  dataTypeGroup + '-' + columnName AS value
			 ,columnName f --title
			 ,columnName title
		FROM (	
			SELECT 
				COLUMN_NAME columnName
				,CASE 
					WHEN data_type IN ('real', 'money', 'decimal', 'float') THEN 'n' 
					WHEN data_type IN ('date', 'datetime') THEN 'd'
					ELSE 'o'
				END dataTypeGroup 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'vw_Export_' + @dataSourceCode 
			AND COLUMN_NAME NOT IN ('filterDate', 'tranId', 'filterAgent')
		) x
	     ORDER BY value
		RETURN
	END		
	ELSE IF @flag = 'rs' -- Row Seperator
	BEGIN
		SELECT 
'
' AS rowSeperatorId, 'New Line' AS rowSeperatorName UNION ALL
		SELECT '', 'No Seperator' UNION ALL
		SELECT '|', 'Pipe (|)' UNION ALL
		SELECT ';', 'Semi-Colon (;)' UNION ALL		
		SELECT ',', 'Comma (,)'
	END
     ELSE IF @flag = 'fdsp' --File format data source
	BEGIN

		SELECT 
			 Name dataSourceCodeId
			,Name dataSourceCodeName
		FROM (
			 SELECT name
			 FROM sys.objects
			 WHERE [type] = 'P'
			 AND name like 'proc_exportFile_%'
		) vw

		--select * FROM INFORMATION_SCHEMA.COLUMNS

		RETURN
	END
	ELSE IF @flag = 'fds' --File format data source
	BEGIN

		SELECT 
			 Name dataSourceCodeId
			,Name dataSourceCodeName
		FROM (
			SELECT DISTINCT
				SUBSTRING(t.TABLE_NAME,11 ,800) Name
			FROM INFORMATION_SCHEMA.VIEWS t
			INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
			WHERE t.TABLE_NAME LIKE 'vw_Export_%' AND c.COLUMN_NAME IN ('filterDate', 'filterAgent') 	
		) vw

		--select * FROM INFORMATION_SCHEMA.COLUMNS

		RETURN
	END
	ELSE IF @flag = 'ft' --File Format Type
	BEGIN		
		
		SELECT 'csv' AS formatTypeId, 'CSV' AS formatTypeName UNION ALL
		SELECT 'html', 'HTML' UNION ALL
		SELECT 'xls', 'Excel (.xls)' UNION ALL	
		SELECT 'txt', 'Text' UNION ALL
		SELECT 'xml', 'XML'  
		RETURN	
	END
	ELSE IF @flag = 'ff-list-d' --File format for agent list for drop down
	BEGIN

		SELECT
			 aff.flFormatId			
			,ff.formatCode + ' ( ' + ff.formatType + ')' formatCode	
		FROM fileFormat ff WITH(NOLOCK)
		INNER JOIN agentFileFormat aff WITH(NOLOCK) ON ff.flFormatId = aff.flFormatId
		WHERE aff.agentId = @agentId
		ORDER BY formatCode ASC	
	
		RETURN;

	END
	ELSE IF @flag = 'al' --Agent List 
	BEGIN
		
		SELECT distinct am.agentId, am.agentName AS agentName
		FROM agentMaster am	  
		  INNER JOIN agentFileFormat F on am.agentId = F.agentId
		WHERE am.agentType = '2903'
		AND am.agentCountryId = @agentCountryId		
		
		RETURN
	END
	ELSE IF @flag = 'ff-list' -- File format for agent list
	BEGIN
		SELECT 1 totalRow, 1  pageNumber, 1 totalPage, 0 pageSize
		SET @table = '
					SELECT
						 aff.agentFfId
						,aff.agentId
						,ff.formatCode
						,ff.formatType						
						,ff.flDescription
					FROM fileFormat ff WITH(NOLOCK)
					INNER JOIN agentFileFormat aff WITH(NOLOCK) ON ff.flFormatId = aff.flFormatId
					WHERE aff.agentId =' +  CAST(@agentId AS VARCHAR(50)) +
					' ORDER BY ' + ISNULL(@sortBy, 'formatCode') + ' ' + ISNULL(@sortOrder, '')
					
		EXEC(@table)
		RETURN
	END	
	ELSE IF @flag = 'ff-list-show' -- File format for agent list
	BEGIN
		SELECT 1 totalRow, 1  pageNumber, 1 totalPage, 0 pageSize
		SET @table = 
		'
		SELECT * FROM fileFormat
		WHERE flFormatId NOT IN (SELECT flFormatId FROM agentFileFormat WHERE agentId =' +  CAST(@agentId AS VARCHAR(50)) + ')' +
		' ORDER BY ' + ISNULL(@sortBy, 'formatCode') + ' ' + ISNULL(@sortOrder, '')
		
		print @table	
		EXEC(@table)
	END	
	ELSE IF @flag = 'ff-insert' --Insert file format for agent
	BEGIN		
		SET @sql = '
					INSERT INTO agentFileFormat(agentId, flFormatId, createdBy, createdDate)
					SELECT agentId=' + CAST(@agentId AS VARCHAR(50)) + ', flFormatId, ''' + @user + ''', GETDATE()
					FROM fileFormat 
					WHERE flFormatId IN (' + ISNULL(NULLIF(@fileFormatIds,''), '0') + ') 
						AND flFormatId NOT IN(SELECT flFormatId FROM agentFileFormat WHERE agentId =' +  CAST(@agentId AS VARCHAR(50)) + ')
					'
		BEGIN TRY			
				EXEC(@sql)			
			SELECT 0 errorCode, 'File format has been added successfully.' msg, @agentId id
		END TRY					
		BEGIN CATCH			 		 
			 SELECT 1 errorCode, ERROR_MESSAGE() msg, @agentId id
		END CATCH	
		RETURN	
	END	
	ELSE IF @flag = 'ff-delete' --delete agent file format
	BEGIN
		DELETE FROM agentFileFormat WHERE agentFfId = @agentFfId
		SELECT 0 errorCode, 'File format has been deleted successfully.' msg, @agentFfId id
		RETURN	
	END
	
	ELSE IF @flag = 'ifl' --IS fixed Length
	BEGIN
		SELECT ISNULL(fixDataLength, 'N') fixDataLength FROM fileFormat WHERE flFormatId = @flFormatId
		RETURN	
	END
	
	ELSE IF @flag = 'i'
	BEGIN
		IF EXISTS (SELECT 'x' FROM fileFormat WHERE formatCode = @formatCode AND ISNULL(isDeleted, '') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Please check the Format code. Format code already exists.', @flFormatId
			RETURN
		END	

		  -- alter table fileFormat add sourceType varchar(200)
		  -- @sourceType

		BEGIN TRANSACTION

			INSERT INTO fileFormat (
				 formatCode
				,formatType
				,flDescription
				,fldSeperator
				,fixDataLength
				,dataSourceCode
				,includeColHeader
				,recordSeperator
				,filterClause
				,headerFormatCode
				,includeSerialNo
				,isActive
				,createdBy
				,createdDate
				,sourceType
			)
			SELECT
				 @formatCode
				,@formatType
				,@flDescription
				,@fldSeperator
				,@fixDataLength
				,@dataSourceCode
				,@includeColHeader
				,@recordSeperator
				,@filterClause
				,@headerFormatCode
				,@includeSerialNo
				,@isActive
				,@user
				,GETDATE()
				,@sourceType

			SET @modType = 'I'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @flFormatId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @flFormatId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @flFormatId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @flFormatId
	END
	ELSE IF @flag = 'a'
	BEGIN

		SELECT * FROM fileFormat WITH(NOLOCK) WHERE flFormatId = @flFormatId
	END
     ELSE IF @flag = 'sourceType'
	BEGIN
		SELECT sourceType formatType, dataSourceCode FROM fileFormat WITH(NOLOCK) WHERE flFormatId = @flFormatId
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'x' FROM fileFormat WHERE formatCode = @formatCode AND ISNULL(isDeleted, '') <> 'Y' AND flFormatId <> @flFormatId)
		BEGIN
			EXEC proc_errorHandler 1, 'Please check the Format code. Format code already exists.', @flFormatId
			RETURN
		END
		
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @flFormatId, @oldValue OUTPUT
		BEGIN TRANSACTION
			UPDATE fileFormat SET
				 formatCode = @formatCode
				,formatType = @formatType
				,flDescription = @flDescription
				,fldSeperator = @fldSeperator
				,fixDataLength = @fixDataLength
				,dataSourceCode = @dataSourceCode
				,includeColHeader = @includeColHeader
				,recordSeperator = @recordSeperator
				,filterClause = @filterClause
				,headerFormatCode = @headerFormatCode				
				,isActive = @isActive
				,includeSerialNo = @includeSerialNo
				,modifiedBy = @user
				,modifiedDate = GETDATE()
				,sourceType=@sourceType
			WHERE flFormatId = @flFormatId
			
			IF @fixDataLength = 'N'
			BEGIN
				UPDATE fileFormatDetails SET
					size = NULL
				WHERE flFormatId = @flFormatId	
			END
			
			SET @modType = 'U'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @flFormatId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @flFormatId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @flFormatId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @flFormatId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (SELECT 'x' FROM fileFormatDetails WHERE flFormatId = @flFormatId)
		BEGIN
			SELECT 1 errorCode, 'Can not delete this File Format. File Format is in use.' Msg, @flFormatId id
			RETURN
		END	
		BEGIN TRANSACTION
			UPDATE fileFormat SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE flFormatId = @flFormatId
			SET @modType = 'D'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @flFormatId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @flFormatId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @flFormatId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @flFormatId
	END

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'flFormatId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.flFormatId
					,main.formatCode
					,main.formatType
					,main.flDescription
					,main.fldSeperator
					,main.fixDataLength
					,main.dataSourceCode
					,main.includeColHeader
					,main.recordSeperator
					,main.headerFormatCode					
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM fileFormat main WITH(NOLOCK)
					WHERE ISNULL(isDeleted, '''') <> ''Y''
					) x'
					
		SET @sql_filter = ''
		
		IF @formatCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(formatCode, '''') LIKE ''' + @formatCode + '%'''
		
		IF @flDescription IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(formatCode, '''') LIKE ''' + @flDescription + '%'''
		
		
		SET @select_field_list ='
			 flFormatId
			,formatCode
			,formatType
			,flDescription
			,fldSeperator
			,fixDataLength
			,dataSourceCode
			,includeColHeader
			,recordSeperator
			,headerFormatCode
			,createdBy
			,createdDate
			,isDeleted
			'
			
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
     EXEC proc_errorHandler 1, @errorMessage, @flFormatId
END CATCH



GO
