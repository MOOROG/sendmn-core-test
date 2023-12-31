USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_categoryContact]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_categoryContact]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@id								INT				= NULL	
	,@catId								INT				= NULL
	,@categoryName						VARCHAR(200)    = NULL
	,@categoryDesc						VARCHAR(max)	= NULL
	,@customerName						VARCHAR(200)    = NULL
	,@customerAddress					VARCHAR(max)	= NULL
	,@mobile							VARCHAR(100)	= NULL
	,@email								VARCHAR(100)	= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


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
		,@ApprovedFunctionId INT
		
	SELECT
		 @logIdentifier = 'id'
		,@logParamMain = 'categoryContact'
		,@module = '20'
		,@tableAlias = 'Customer Category Contact Details'
		
--select * from categoryContact
	IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 id 
					,categoryName
					,categoryDesc
					,createdBy
					,createdDate
					,modifiedDate		
					,modifiedBy			
					,hasChanged = ''Y''

				FROM categoryContact main where isnull(isDeleted,''N'')<>''Y''
			)a '
			--select (@table)
			--return;
	
	END	
	IF @flag = 'i'
	BEGIN
		
			INSERT INTO categoryContact (
				 categoryName
				,categoryDesc
				,createdBy
				,createdDate
			)
			SELECT
				 @categoryName
				 ,@categoryDesc
				 ,@user
				 ,GETDATE()
				 
			SET @id = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
		
	END
	
	ELSE IF @flag = 'a'
	BEGIN
			
			SELECT
				id
				,categoryName
				,categoryDesc
				,createdBy
				,createdDate
				,modifiedBy
				,modifiedDate				
			FROM categoryContact where id=@id
	
	END

	ELSE IF @flag = 'u'
	BEGIN
		
			UPDATE categoryContact SET
				 categoryName = @categoryName
				,categoryDesc = @categoryDesc	
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE id = @id			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @id
	END
	
	ELSE IF @flag = 'd'
	BEGIN

		update categoryContact set isDeleted='Y' WHERE ID=@id	
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
	END
	
	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '( 
				SELECT
					 id
					,categoryName
					,categoryDesc
					,createdBy
					,createdDate
					,modifiedDate	
					,modifiedBy		
					,hasChanged 
				FROM ' + @table + ' 
				) x
		
				'
				
		--select @table
		--return;
		SET @sql_filter = ''
		
			
		SET @select_field_list ='
					 id
					,categoryName
					,categoryDesc
					,createdBy
					,createdDate
					,modifiedDate	
					,modifiedBy		
					,hasChanged 
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
	
	--- ## Customer Contact List ## ---
		

	IF @flag IN ('sc')
	BEGIN
		SET @table = '(
				SELECT
					 id 
					,catId
					,customerName
					,customerAddress
					,email
					,mobile
					,createdBy
					,createdDate
					,modifiedDate		
					,modifiedBy			
					,hasChanged = ''Y''

				FROM customerContactList main where isnull(isDeleted,''N'')<>''Y''
				AND catId=''' +  cast(@catId as varchar)+ ''' 
			)a '
	
	END	
	IF @flag = 'ic'
	BEGIN
		
			INSERT INTO customerContactList 
			(
				 catId
				,customerName
				,customerAddress
				,mobile
				,email
				,createdBy
				,createdDate
			)
			SELECT
				  @catId
				 ,@customerName
				 ,@customerAddress
				 ,@mobile
				 ,@email
				 ,@user
				 ,GETDATE()
				 
			SET @id = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
		
	END
	
	ELSE IF @flag = 'ac'
	BEGIN
			
			SELECT
				 id
				,catId
				,customerName
				,CustomerAddress
				,mobile
				,email
				,createdBy
				,createdDate
				,modifiedBy
				,modifiedDate				
			FROM customerContactList where id=@id
	
	END

	ELSE IF @flag = 'uc'
	BEGIN
		
			UPDATE customerContactList SET
				 catId=@catId
				,customerName = @customerName
				,CustomerAddress = @customerAddress
				,mobile=@mobile
				,email=@email	
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE id = @id			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @id
	END
	
	ELSE IF @flag = 'dc'
	BEGIN

		update customerContactList set isDeleted='Y' WHERE ID=@id	
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
	END
	
	ELSE IF @flag = 'sc'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '( 
				SELECT
					 id
					,catId
					,customerName
					,customerAddress
					,email
					,mobile
					,createdBy
					,createdDate
					,modifiedDate	
					,modifiedBy		
					,hasChanged 
				FROM ' + @table + ' 
				) x
		
				'
				
		--select @table
		--return;
		SET @sql_filter = ''
		
			
		SET @select_field_list ='
					 id
					,catId
					,customerName
					,customerAddress
					,email
					,mobile
					,createdBy
					,createdDate
					,modifiedDate	
					,modifiedBy		
					,hasChanged 
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
     EXEC proc_errorHandler 1, @errorMessage, @id
END CATCH


GO
