USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_externalBankSetup]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_externalBankSetup]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@agentId							VARCHAR(30)		= NULL
     ,@parentId							VARCHAR(30)		= NULL
     ,@agentName						VARCHAR(100)	= NULL
     ,@agentCode	                    VARCHAR(50)		= NULL
     ,@agentAddress	                    VARCHAR(200)	= NULL
     ,@agentCountryId					INT				= NULL
     ,@agentCountry						VARCHAR(100)	= NULL
     ,@agentLocation					VARCHAR(200)	= NULL
     ,@agentPhone						VARCHAR(20)		= NULL
     ,@agentFax							VARCHAR(20)		= NULL
     ,@agentType						INT				= NULL
     ,@mapCodeInt						VARCHAR(20)		= NULL
     ,@mapCodeDom						VARCHAR(20)		= NULL
     ,@agentDetails						VARCHAR(MAX)	= NULL
     ,@parentName						VARCHAR(100)	= NULL
     ,@haschanged						CHAR(1)			= NULL
     ,@isActive							CHAR(1)			= NULL
     ,@extCode							VARCHAR(200)	= NULL
     ,@swiftCode						VARCHAR(200)	= NULL
     ,@routingCode						VARCHAR(200)	= NULL 
     ,@isHeadOffice						CHAR(1)			= NULL    
     ,@isDeleted                        CHAR(1)			= NULL     
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL
     ,@isBlocked						VARCHAR(20)		= NULL


AS
SET NOCOUNT ON
	
DECLARE @glcode VARCHAR(10), @acct_num VARCHAR(20);
CREATE TABLE #tempACnum (acct_num VARCHAR(20));
   
if @flag='s'
begin
	SET @agentType='2905'
	--SET @parentId='3'
end
if @flag='t'
begin
	SET @agentType='2906'
end

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
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)
		,@ApprovedFunctionId INT	
		
	SELECT
		 @logIdentifier = 'agentId'
		,@logParamMain = 'agentMaster'
		,@tableAlias = 'External Bank'
		,@module = 20
		,@ApprovedFunctionId = 20101030
	
	IF @flag = 'a'
	BEGIN
		SELECT isBlocked = agentBlock,* FROM agentMaster where agentId = @agentId		
	END
	
    ELSE IF @flag = 'i'
    BEGIN
		IF EXISTS(SELECT 'X' FROM agentMaster 
					WHERE agentName = @agentName AND agentType IN (2905, 2906) 
					AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Agent with this name already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO agentMaster (
				 parentId
				,agentName
				,agentCode
				,agentAddress
				,agentCountryId
				,agentCountry
				,agentLocation
				,agentPhone1
				,agentType
				,mapCodeInt
				,mapCodeIntAc
				,mapCodeDom	
				,extCode
				,swiftCode
				,routingCode
				,isHeadOffice
				,payOption
				,isActive		                 
				,createdDate
				,createdBy 
				,agentBlock                 
			)
			SELECT
				 @parentId
				,@agentName
				,@agentCode
				,@agentAddress
				,@agentCountryId
				,@agentCountry
				,@agentLocation
				,@agentPhone
				,@agentType
				,@mapCodeInt
				,@mapCodeInt
				,@mapCodeDom
				,@extCode
				,@swiftCode
				,@routingCode
				,@isHeadOffice
				,40	
				,'Y'	           
				,GETDATE()
				,@user
				,@isBlocked
                    
			SET @agentId = SCOPE_IDENTITY()
			
			UPDATE dbo.agentMaster SET
				 mapCodeInt				= @agentId
				,mapCodeDom				= @agentId
				,mapCodeDomAC			= @agentId -- used for a/c pay domestic
				,mapCodeIntAc			= @agentId
			WHERE agentId = @agentId
			
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentId, @newValue OUTPUT
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
    
    ELSE IF @flag = 'u'
    BEGIN
    /*
		IF EXISTS(SELECT 'X' FROM agentMaster WITH(NOLOCK)
					 WHERE agentName = @agentName AND agentType IN (2905, 2906) AND agentId <> @agentId 
					 AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Agent with this name already exists', NULL
			RETURN 
		END*/
			
		BEGIN TRANSACTION
			UPDATE agentMaster SET
				 agentName						= @agentName
				,agentCode						= @agentCode
				,agentAddress					= @agentAddress
				,agentCountryId					= @agentCountryId
				,agentCountry					= @agentCountry
				,agentLocation					= @agentLocation
				,agentPhone1					= @agentPhone
				,agentType						= @agentType
				,mapCodeInt						= @mapCodeInt
				,mapCodeDom						= @mapCodeDom
				,mapCodeDomAc					= @mapCodeDom
				,extCode						= @extCode
				,swiftCode						= @swiftCode
				,routingCode					= @routingCode
				,isHeadOffice					= @isHeadOffice
				,agentBlock						= @isBlocked
			WHERE agentId = @agentId
		
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @agentId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @agentId
     END

	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION	
		UPDATE agentMaster SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE agentId = @agentId
			
			SET @modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentId, @user, @oldValue, @newValue
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

    ELSE IF @flag ='t'
    BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		   
		SET @table = '(
						SELECT
							 main.parentId
							,main.agentId
							,main.agentName                    
							,main.agentAddress 
							,countryName = main.agentCountry 
							,main.agentLocation
							,location = adl.districtName
							,main.agentPhone1                  
							,main.agentType	
							,bankMapCode = main.mapCodeDom
							,main.mapCodeInt	
							,main.extCode
							,main.swiftCode
							,main.routingCode
							,main.isHeadOffice
							,main.createdBy
							,isBlocked=ISNULL(main.agentBlock,''N'')				
						FROM agentMaster main 
						LEFT JOIN api_districtList adl WITH(NOLOCK) ON main.agentLocation = adl.districtCode		
						WHERE main.agentType = 2906 AND main.parentId='+CAST(@parentId as varchar)+' 
						AND isnull(main.isDeleted,''N'') = ''N''
						)  x'
					
		SET @sql_filter = ''		
		
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
			
		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryName, '''') = ''' + CAST(@agentCountry AS VARCHAR) + ''''
			
		IF @agentType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentType, '''') = ' + CAST(@agentType AS  VARCHAR)
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
		
		IF @parentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(parentName, '''') LIKE ''%' + @parentName + '%'''
			
		IF @isBlocked IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isBlocked LIKE ''%' + @isBlocked + '%'''
	

		SET @select_field_list ='
							 parentId
							,agentId
							,agentName                    
							,agentAddress 
							,countryName
							,agentLocation
							,location
							,agentPhone1                  
							,agentType
							,bankMapCode
							,mapCodeInt
							,extCode
							,swiftCode
							,routingCode
							,isHeadOffice
							,createdBy	
							,isBlocked
               '      
                 	
		--PRINT @table	
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
	
    ELSE IF @flag ='s'
    BEGIN

		--IF @sortBy IS NULL
		   SET @sortBy = 'agentName'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		   

		SET @table = '(
						SELECT
							 main.agentId
							,main.agentName                    
							,main.agentAddress 
							,countryName = main.agentCountry 
							,main.agentLocation
							,main.agentPhone1                  
							,main.agentType	
							,main.mapCodeInt
							,main.mapCodeDom	
							,main.extCode
							,main.swiftCode
							,main.routingCode
							,main.isHeadOffice
							,agentType1 = sdv.detailTitle
							,main.createdBy	
							,isBlocked=ISNULL(main.agentBlock,''N'')			
						FROM agentMaster main 
						LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.agentType = sdv.valueId		
						WHERE main.agentType=2905
						and isnull(main.isDeleted,''N'')<>''Y'' 
						)  x'
									
		SET @sql_filter = ''		
		
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
			
		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryName, '''') = ''' + CAST(@agentCountry AS VARCHAR) + ''''
			
		IF @agentType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentType, '''') = ' + CAST(@agentType AS  VARCHAR)
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
			
		IF @isBlocked IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isBlocked LIKE ''%' + @isBlocked + '%'''
	----print @table

		SET @select_field_list ='							
							 agentId
							,agentName                    
							,agentAddress 
							,countryName
							,agentLocation
							,agentPhone1                  
							,agentType
							,mapCodeInt
							,mapCodeDom
							,extCode
							,swiftCode
							,routingCode
							,isHeadOffice
							,agentType1 
							,createdBy
							,isBlocked	
               '      
                 	
		--SELECT @table	
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
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
