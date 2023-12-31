USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_externalBankBranch]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_externalBankBranch]
		  @flag						VARCHAR(10)		= NULL
		 ,@extBranchId				INT				= NULL
		 ,@extBankId				INT				= NULL
		 ,@branchName				VARCHAR(250)	= NULL
		 ,@branchCode				VARCHAR(50)		= NULL
		 ,@country					VARCHAR(50)		= NULL
		 ,@state					VARCHAR(50)		= NULL
		 ,@district					VARCHAR(100)	= NULL
		 ,@location					VARCHAR(100)	= NULL
		 ,@address					VARCHAR(500)	= NULL
		 ,@phone					VARCHAR(20)		= NULL
		 ,@swiftCode				VARCHAR(50)		= NULL
		 ,@routingCode				VARCHAR(50)		= NULL
		 ,@externalCode				VARCHAR(50)		= NULL
		 ,@externalBankType			VARCHAR(20)		= NULL
		 ,@user						VARCHAR(50)		= NULL
		 ,@isDeleted				CHAR(1)			= NULL
		 ,@createdDate				DATETIME		= NULL
		 ,@createdBy				VARCHAR(100)	= NULL
		 ,@modifiedDate				DATETIME		= NULL
		 ,@modifiedBy				VARCHAR(100)	= NULL
		 ,@countryId				VARCHAR(50)		= NULL
		 ,@pageSize					VARCHAR(MAX)	= NULL
		 ,@pageNumber				VARCHAR(MAX)	= NULL
		 ,@sortBy					VARCHAR(MAX)	= NULL
		 ,@sortOrder				VARCHAR(MAX)	= NULL
		 ,@city						VARCHAR(10)		= NULL
		 ,@isBlocked				VARCHAR(20)		= NULL
		
	AS 
	
	SET NOCOUNT ON
	SET XACT_ABORT ON 
	
	/*
	 ______________________________
	|							   |
	|	flag		Purpose		   |
    |------------------------------|
		i			Insert	   
		d			Delete
		u			Update
		s			Select
		a			Select By Id
	*/
	
	
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @oldValue			VARCHAR(MAX)
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
		 @logIdentifier = 'extBranchId'
		,@logParamMain = 'externalBankBranch'
		,@module = ''
		,@tableAlias = 'externalBankBranch'	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			IF @location is null
				set @location = @city
			INSERT INTO externalBankBranch (
				  extBankId					
				 ,branchName				
				 ,branchCode				
				 ,country					
				 ,state					
				 ,district					
				 ,pLocation					
				 ,address				
				 ,phone					
				 ,swiftCode				
				 ,routingCode				
				 ,externalCode		
				 ,externalBankType
				 ,createdBy
				 ,createdDate
				 ,isBlocked		
			)
			SELECT
				  @extBankId					
				 ,@branchName				
				 ,@branchCode				
				 ,@country					
				 ,@state					
				 ,@district					
				 ,@location					
				 ,@address				
				 ,@phone					
				 ,@swiftCode				
				 ,@routingCode				
				 ,@externalCode		
				 ,@externalBankType
				 ,@user
				 ,GETDATE()
				 ,@isBlocked
			SET @extBranchId = 	@@IDENTITY	
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @extBranchId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @extBranchId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @extBranchId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @extBranchId
	END
	ELSE IF @flag = 'u'
	BEGIN
		--alter table externalBankBranch add isBlocked char(1)
		BEGIN TRANSACTION
			UPDATE externalBankBranch SET
						   extBankId	=	@extBankId				
						  ,branchName	=	@branchName				
						  ,branchCode	=	@branchCode			
						  ,country		=	@country			
						  ,state		=	@state		
						  ,district		=	@district			
						  ,pLocation	=	@location		
						  ,address		=	@address		
						  ,phone		=	@phone		
						  ,swiftCode	=	@swiftCode		
						  ,routingCode	=	@routingCode		
						  ,externalCode	=	@externalCode	
						  ,externalBankType =	@externalBankType	
						  ,modifiedBy	=  @user
						  ,modifiedDate =  GETDATE()
						  ,isBlocked	=  @isBlocked
						  
			WHERE extBranchId = @extBranchId
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @extBranchId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @extBranchId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @extBranchId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @extBranchId
	END	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE externalBankBranch SET
					 isDeleted = 'Y'
					,modifiedBy = @user 
					,modifiedDate = GETDATE()
				WHERE extBranchId = @extBranchId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @extBranchId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @extBranchId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @extBranchId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @extBranchId
	END	
	ELSE IF @flag = 'a'
		BEGIN
			SELECT * FROM externalBankBranch WHERE extBranchId = @extBranchId
		END
	ELSE IF @flag ='s'
    BEGIN

		--IF @sortBy IS NULL
		   SET @sortBy = 'branchName'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		   

		SET @table = '(
						SELECT
							  EB.extBranchId
							 ,EB.branchName
							 ,EB.branchCode
							 ,EB.phone
							 ,EB.country
							 ,EB.address
							 ,BANK.BANKNAME
							 ,EB.externalCode
							 ,EB.swiftCode
							 ,l.districtName pLocation
							 ,isBlocked=ISNULL(EB.isBlocked,''N'')
							 --,link =ISNULL(CASE WHEN detailTitle=''Agent Specific'' THEN ''<a href="" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Administration/ExternalBankSetup/BranchWiseBankCode/List.aspx?parentId=''+CAST(EB.extBankId AS VARCHAR)+''&bankName=''+BANK.BANKNAME+''&branchName=''+EB.branchName+''&extBranchId=''+CAST(extBranchId AS VARCHAR)+'''''')">Agent Bank Code</a>'' END,'''')
							 ,link = ''''
						FROM externalBankBranch  EB WITH (NOLOCK) 
						INNER JOIN externalBank BANK WITH(NOLOCK) ON BANK.extBankId = EB.extBankId
						LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sdv.valueId = EB.externalBankType 
						left join api_districtList l with(nolock) on l.districtCode = eb.pLocation	
						WHERE ISNULL(EB.isDeleted,''N'')<>''Y'' AND EB.extBankId='''+CAST(@extBankId AS VARCHAR)+'''
						)  x'
					
		SET @sql_filter = ''
			
		IF @country IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND country LIKE  ''%' + @country + '%'''
			
		IF @branchName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND branchName LIKE ''%' + @branchName + '%'''
		
		IF @isBlocked IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isBlocked LIKE ''%' + @isBlocked + '%'''

		SET @select_field_list ='							
							  extBranchId
							 ,branchName
							 ,country
							 ,address
							 ,branchCode
							 ,phone
							 ,pLocation
							 ,externalCode
							 ,swiftCode
							 ,link
							 ,isBlocked
							'      
                 	
		print(@table)
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
     SELECT 1 error_code, ERROR_MESSAGE() mes, @extBranchId
     
END CATCH

GO
