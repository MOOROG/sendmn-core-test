SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

/*
Invalid object name 'applicationRqoleFunctions'.
proc_applicationRoles  's', 'user1', 0, 'a'
exec [proc_applicationRoles] @flag = 's'  ,@pageNumber='1', @pageSize='10', @sortBy='roleId',
 @sortOrder='ASC', @user = ''
*/

ALTER proc [dbo].[proc_applicationRoles]
	 @flag				CHAR(1)	
	,@userName			VARCHAR(30)	= NULL
	,@user				VARCHAR(30)	= NULL		
	,@roleId			INT			= NULL
	,@roleName			VARCHAR(50) = NULL	
	,@roleType			VARCHAR(1)	= NULL
	,@isActive			VARCHAR(1)  = NULL
	,@haschanged		CHAR(1)		= NULL	
	,@createdBy			VARCHAR(50) = NULL
	,@modifiedBy		VARCHAR(50) = NULL	
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
							,roleType = CASE WHEN ar.roleType = ''H'' THEN ''HO/Admin'' 
											 WHEN ar.roleType = ''A'' THEN ''Agent'' END 
							,ar.isActive							
							,ar.createdBy
							,ar.createdDate
							,modifiedBy = ISNULL(x.createdBy, ar.modifiedBy)
							,modifiedDate = ISNULL(x.createdDate, ar.modifiedDate)
							,hasChanged = CASE WHEN (x.roleId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
						FROM applicationRoles ar WITH(NOLOCK)
						LEFT JOIN (
							SELECT --DISTINCT 
								 roleId
								,createdBy = MAX(createdBy)
								,createdDate = MAX(createdDate)
							FROM applicationRoleFunctionsMod arfm WITH(NOLOCK)
							GROUP BY roleId
						) x ON ar.roleId = x.roleId		
		
					  ) x'	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
							roleId, roleName, roleType, isActive,hasChanged, createdDate
							,createdBy, modifiedDate, modifiedBy 
						'
			
		IF @roleName IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND roleName LIKE ''' + @roleName + '%'''
				
		IF @roleType IS NOT NULL
			 SET @sqlFilter = @sqlFilter + ' AND roleType like ''' + @roleType + '%'''
			
		IF @createdBy IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND createdBy LIKE ''' + @createdBy + '%'''
		
		IF @modifiedBy IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND modifiedBy LIKE ''' + @modifiedBy + '%'''

		IF @haschanged IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND haschanged = ''' + @haschanged + ''''

		IF @isActive IS NOT NULL
			SET @sqlFilter = @sqlFilter +' AND isActive='''+@isActive+''''

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
			roleId, roleName, roleType
			,createdDate, createdBy, modifiedDate, modifiedBy, isActive
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
		--------Audit data starts----------------	
						
			SET  @newValue = ''			
			EXEC [dbo].proc_GetColumnToRow  'applicationRoles', 'roleId', @roleId, @oldValue OUTPUT
			
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, 'Delete', 'Role Setup', @roleId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'X' FROM #msg WHERE errorCode <> 0 )
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				SELECT 1 errorCode, 'Role can not be deleted.' mes, @roleId id
				RETURN
			END
					
		--------------Audit data ends-------------
		
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
				,roleType		
				,createdDate
				,createdBy
				,isActive
			)
			SELECT 	
			 @roleName	
			,@roleType	
			,GETDATE()
			,@user
			,@isActive

			SET @roleId = SCOPE_IDENTITY()
		
			--Audit data starts				
			SET @oldValue = ''			
			EXEC [dbo].proc_GetColumnToRow  'applicationRoles', 'roleId', @roleId, @newValue OUTPUT
			--Audit data ends
		
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, 'Insert', 'Role Setup', @roleId, @user, @oldValue, @newValue	
			
			IF EXISTS (SELECT 'X' FROM #msg WHERE errorCode <> 0 )
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				SELECT 1 errorCode, 'Role can not be added.' mes, @roleId id
				RETURN
			END
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
	
	      --Audit data starts					
			EXEC [dbo].proc_GetColumnToRow  'applicationRoles', 'roleId', @roleId, @oldValue OUTPUT						
		 --Audit data ends
		 
			UPDATE applicationRoles SET
				 roleName	= @roleName
				,roleType=@roleType			
				,modifiedDate = GETDATE()
				,modifiedBy = @user
				,isActive = ISNULL(@isActive, 'Y')
			WHERE roleId = @roleId
			
			--Audit data starts
			EXEC [dbo].proc_GetColumnToRow  'applicationRoles', 'roleId', @roleId, @newValue OUTPUT	
			--Audit data ends	
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, 'Update', 'Role Setup', @roleId, @user, @oldValue, @newValue	
			
			IF EXISTS (SELECT 'X' FROM #msg WHERE errorCode <> 0 )
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				SELECT 1 errorCode, 'Role can not be added.' mes, @roleId id
				RETURN
			END
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