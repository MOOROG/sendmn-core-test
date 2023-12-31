USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_groupLocationMap]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
[proc_groupLocationMap] @flag = 'fl', @user = 'admin', @groupId = 1
[proc_groupLocationMap] @flag = 'sa', @groupId = '5004'
EXEC [proc_groupLocationMap] @flag = 's'
SELECT * FROM groupLocationMap
*/
CREATE proc [dbo].[proc_groupLocationMap]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@glmId							INT				= NULL
     ,@detailTitle						VARCHAR(50)		= NULL
     ,@groupId							INT				= NULL
     ,@districtId						INT				= NULL
     ,@districtIds						VARCHAR(MAX)	= NULL
     ,@isActive							CHAR(1)			= NULL
     ,@isDeleted                        CHAR(1)			= NULL     
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL


AS
SET NOCOUNT ON
	
DECLARE @glcode VARCHAR(10), @acct_num VARCHAR(20);
CREATE TABLE #tempACnum (acct_num VARCHAR(20));
       

SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@selectFieldList VARCHAR(MAX)
		,@extraFieldList  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sqlFilter        VARCHAR(MAX)
		,@ApprovedFunctionId INT	
		
	SELECT
		 @logIdentifier = 'groupLocationMapId'
		,@logParamMain = 'groupLocationMap'
		,@tableAlias = 'Agent'
		,@module = 20
		,@ApprovedFunctionId = 20101330
		
	DECLARE @district_list TABLE(districtId INT)
	
	IF @flag = 'u'
	BEGIN
		--Select districtId
		SET @sql = '
			SELECT 
				districtCode 
			FROM api_districtList WITH(NOLOCK) 
			WHERE districtCode IN (' + @districtIds + ')
			'
			
		INSERT @district_list
		EXEC (@sql)
		BEGIN TRANSACTION
			--DELETE FROM agentGroupMod WHERE groupId = @groupId
			INSERT groupLocationMap(groupId, districtId, createdBy, createdDate)
			SELECT @groupId, districtId, @user, GETDATE() FROM @district_list
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		EXEC proc_errorHandler 0, 'Location mapped to Group successfully.', @groupId
	END
	ELSE IF @flag = 'd'
	BEGIN
			--SET @sql = '
			--		DELETE FROM groupLocationMap 
			--		WHERE districtId IN (' + @districtIds + ') AND groupId = ' + CAST(@groupId AS VARCHAR) + ' 
			--		'
			--EXEC (@sql)
			DELETE FROM groupLocationMap WHERE districtId = @districtId AND groupId = @groupId	
		EXEC proc_errorHandler 0, 'Agent deleted From Group successfully.', @groupId
	END
			
	ELSE IF @flag = 's'					--Load All Group
	BEGIN			
		IF @sortBy IS NULL  
			SET @sortBy = 'valueId'			
	
		SET @table = '(		
						SELECT 
							 sdv.valueId
							,sdv.detailTitle
							,sdv.detailDesc							
							,sdv.createdBy
							,sdv.createdDate
						FROM staticDataValue sdv WITH(NOLOCK)	
						WHERE sdv.typeId = 4300
					  ) x'	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
							 valueId
							,detailTitle
							,detailDesc
							,createdDate
							,createdBy 
						'
			
		IF @detailTitle IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND detailTitle LIKE ''' + @detailTitle + '%'''		

		EXEC dbo.proc_paging
			 @table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber
			
				
		
	END
	ELSE IF @flag = 'sa'			--Load Group District Mapping
    BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'districtId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		   
		SET @table = '(
						SELECT
							 main.districtId
							,districtName = dist.districtName                   
							,main.groupId
							,groupName = ag.detailTitle					
						FROM groupLocationMap main 
						LEFT JOIN api_districtList dist ON main.districtId = dist.districtCode
						LEFT JOIN staticDataValue ag ON main.groupId = ag.valueId 
						WHERE main.groupId = ' + CAST(@groupId AS VARCHAR) + '
					) x'	
		
		SET @sqlFilter = ''		
		
		IF @detailTitle IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND ISNULL(districtName, '''') LIKE ''%' + @detailTitle + '%'''
		
		SET @selectFieldList ='
                districtId
               ,districtName               
               ,groupId
               ,groupName
               '        	
			
		EXEC dbo.proc_paging
                @table
               ,@sqlFilter
               ,@selectFieldList
               ,@extraFieldList
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber
	END
	ELSE IF @flag = 'fl'			--Load Filter List of District
    BEGIN
		SET @sortBy = 'districtName'
		IF @sortBy IS NULL
		   SET @sortBy = 'districtName'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 districtId = districtCode
							,districtName					
						FROM api_districtList  
						WHERE districtCode NOT IN
							(SELECT districtId FROM groupLocationMap)  
					) x'
					
		SET @sqlFilter = ''		
		
		IF @detailTitle IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND ISNULL(districtName, '''') LIKE ''%' + @detailTitle + '%'''
		
		SET @selectFieldList ='
                districtId
               ,districtName               
               '        	
			
		EXEC dbo.proc_paging
                @table
               ,@sqlFilter
               ,@selectFieldList
               ,@extraFieldList
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH


GO
