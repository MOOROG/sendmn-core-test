USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationRoles]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_applicationRoles]
	 @flag				CHAR(1)	
	,@userName			VARCHAR(30)	= NULL
	,@user				VARCHAR(30)	= NULL		
	,@roleId			INT			= NULL
	,@roleName			VARCHAR(50) = NULL	
	,@roleDesc			VARCHAR(100)= NULL
	,@isActive			VARCHAR(1)  = NULL
	,@createdBy			VARCHAR(50) = NULL
	,@modifiedBy		VARCHAR(50) = NULL
	,@haschanged		CHAR(1)		= NULL	
	,@sortBy			VARCHAR(50)	= NULL
	,@sortOrder			VARCHAR(5)	= NULL
	,@pageSize			INT			= NULL
	,@pageNumber		INT			= NULL  
AS
/*
	@flag
	s	= select all (with dynamic filters)
	i	= insert
	u	= update
	a	= select by role id
	d	= delete by role id
	
*/

SET NOCOUNT ON

BEGIN TRY
	DECLARE
	        @sql VARCHAR(MAX)
	       ,@oldValue VARCHAR(MAX)
		   ,@newValue VARCHAR(MAX)
		   
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	
	IF @flag = 's'
	BEGIN
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter			VARCHAR(MAX)
			
		--IF @sortBy IS NULL  
			SET @sortBy = 'roleName'			
	
		SET @table = '(		
						SELECT 
							 ar.roleId
							,ar.roleName
							,roleDesc
							,isActive = CASE isActive WHEN ''Y'' THEN ''Yes'' ELSE ''No'' END							
							,ar.createdBy
							,ar.createdDate
							,modifiedBy = ISNULL(ar.createdBy, ar.modifiedBy)
							,modifiedDate = ISNULL(ar.createdDate, ar.modifiedDate)
						FROM applicationRoles ar WITH(NOLOCK)
					  ) x'	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
							roleId, roleName, roleDesc, isActive, createdDate
							,createdBy, modifiedDate, modifiedBy 
						'
			
		IF @roleName IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND roleName LIKE ''' + @roleName + '%'''
				
		IF @isActive IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND isActive like ''' + @isActive + '%'''
			
		IF @createdBy IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND createdBy LIKE ''' + @createdBy + '%'''
		
		IF @modifiedBy IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND modifiedBy LIKE ''' + @modifiedBy + '%'''

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
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			roleId, roleName, roleDesc,ISNULL(isActive,'N') isActive
			,createdDate, createdBy, modifiedDate, modifiedBy
		FROM applicationRoles WITH (NOLOCK)
		WHERE roleId = @roleId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (SELECT 'X' FROM applicationRoleFunctions WITH(NOLOCK) WHERE roleId = @roleId)
		BEGIN
			SELECT 1 errorCode, 'This Role is in use.' mes, @roleId id
			RETURN
		END	
		BEGIN TRANSACTION
		
		DELETE FROM applicationRoles WHERE roleId = @roleId
		COMMIT TRANSACTION
		SELECT 0 errorCode, 'Role successfully deleted.' mes, @roleId paramKey	
	END
	ELSE IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM applicationRoles WHERE roleName = @roleName)
		BEGIN
			SELECT 1 errorCode, 'Role Name already exists.' mes, NULL paramKey
			RETURN
		END
		
		BEGIN TRANSACTION	
			INSERT INTO applicationRoles(
				 roleName	
				,roleDesc
				,isActive		
				,createdDate
				,createdBy
			)
			SELECT 	
			 LTRIM(RTRIM(@roleName))	
			,@roleDesc
			,@isActive
			,GETDATE()
			,@user

			SET @roleId = SCOPE_IDENTITY()
		
		COMMIT TRANSACTION
		SELECT 0 errorCode, 'New role has been added successfully.' mes, @roleId paramKey	
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'X' FROM applicationRoles WHERE roleName = @roleName AND roleId <> @roleId)
		BEGIN
			SELECT 1 errorCode, 'Role Name already exists.' mes, NULL paramKey
			RETURN
		END
		BEGIN TRANSACTION
	
			UPDATE applicationRoles SET
				 roleName	= @roleName
				,roleDesc   = @roleDesc	
				,isActive	= @isActive		
				,modifiedDate = GETDATE()
				,modifiedBy = @user
			WHERE roleId = @roleId
		COMMIT TRANSACTION
		SELECT 0 errorCode, 'Role has been updated successfully.' mes, @roleId paramKey	
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 
	ROLLBACK TRANSACTION
	SELECT 1 errorCode, ERROR_MESSAGE() mes, @roleId paramKey
END CATCH

GO
