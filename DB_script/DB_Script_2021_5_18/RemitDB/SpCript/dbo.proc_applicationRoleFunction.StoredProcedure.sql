USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationRoleFunction]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
exec proc_applicationRoleFunction @flag = 'rfl', @roleId ='2', @user ='admin'
*/
CREATE PROC [dbo].[proc_applicationRoleFunction]
	 @flag						VARCHAR(100)
	,@roleId					INT			= NULL
	,@functionId				INT			= NULL	
	,@userId					INT			= NULL
	,@user						VARCHAR(30)	= NULL
	,@functionIds				VARCHAR(MAX)= NULL
	,@roleIds					VARCHAR(MAX)= NULL
AS

/*

@flag 
rfl -> role function list
ufl -> user function list
rl  -> role list
rfi -> role function insert
ufi -> user fuction insert
uri -> user role insert

*/


SET NOCOUNT ON;


DECLARE
	 @sql VARCHAR(MAX)
	,@oldValue VARCHAR(MAX)
	,@newValue VARCHAR(MAX)
	,@ApproveFunctionId INT


DECLARE @function_list TABLE(functionId INT)
CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id VARCHAR(20))

IF OBJECT_ID('tempdb..#menuList') IS NOT NULL
	DROP TABLE #menuList

CREATE TABLE #menuList(
	 id					INT IDENTITY(1, 1)
	,moduleName			VARCHAR(100)	
	,menuGroup			VARCHAR(100)
	,menu				VARCHAR(100)
	,rights				VARCHAR(MAX)
	,modulePosition		INT
	,groupPosition		INT
	,menuPosition		INT
	,functionId			VARCHAR(10)
)
--SELECT 'functionId', @roleId, NULL, @user
SET @ApproveFunctionId = 10101030

IF @flag = 'viewrole'
BEGIN
	INSERT INTO #menuList(moduleName, menuGroup, menu, rights, modulePosition, groupPosition, menuPosition, functionId)
	SELECT	DISTINCT
			--sdv.detailTitle
			CASE am.Module 
				WHEN '10'	THEN 'System'			
				WHEN '20'	THEN 'Remittance'
				WHEN '30'	THEN 'International Operation'		
				ELSE '100'
			END moduleName	
			,menuGroup
			, menuName
			,dbo.FNAGetFunctionList(am.functionId, @roleId, NULL,@user, 10101030,'Y') [Rights]
			,CASE am.Module 
				WHEN '10'	THEN 10			
				WHEN '20'	THEN 20
				WHEN '30'	THEN 30			
				ELSE '100'
			END [modulePostion]
			,am.groupPosition
			,am.position
			,am.functionId
	from applicationFunctions AF
	INNER JOIN applicationMenus AM ON AM.functionId=AF.parentFunctionId 
	--INNER JOIN staticDataValue sdv ON am.module = sdv.valueId
	INNER JOIN applicationROLEFunctions ARF ON ARF.functionId=AF.functionId AND ARF.roleId = @roleId


	UPDATE #menuList SET
		 moduleName = CASE WHEN moduleName = ISNULL((SELECT TOP 1 moduleName FROM #menuList WHERE id = ml.id - 1), '') THEN NULL ELSE '<b>' + moduleName + '</b>' END	
		,menuGroup	= CASE 
							WHEN (
								menuGroup	 = ISNULL((SELECT TOP 1 menuGroup  FROM #menuList WHERE id = ml.id - 1), '') AND
								moduleName = ISNULL((SELECT TOP 1 moduleName FROM #menuList WHERE id = ml.id - 1), '')
							)	THEN NULL
							ELSE  [menuGroup] 
					  END
	FROM #menuList ml
	
	SELECT		 
		 '<span class="moduleGroupReport">' + moduleName	+ '</span>'	[Module]
		,'<span class="menuReport">' + menuGroup	+ '</span>'	[Group]
		,'<span class="subMenuReport">' + menu			+ '</span>'	[Menu]			
		,'<span class="rights">' + rights + '</span>'	[Rights]
	FROM #menuList l
	--LEFT JOIN staticDataValue S ON L.moduleName = '<b>' + CAST(S.valueId AS VARCHAR) + '</b>' 
	--ORDER BY modulePosition ASC, groupPosition ASC, menuPosition ASC

END


IF @flag IN('ufl', 'rfl')
BEGIN
	DECLARE @roleType AS VARCHAR(1)
		
	IF @roleId IS NULL
		SELECT @roleId=roleId from applicationUserRoles where userId=@userId AND roleId<>'-1'
		
	SELECT @roleType  =roleType FROM applicationRoles where roleId=@roleId

	IF @roleType='A'
	BEGIN
		INSERT INTO #menuList(moduleName, menuGroup, menu, rights, modulePosition, groupPosition, menuPosition, functionId)
		SELECT
			 --sdv.detailTitle [Module]	
			 CASE am.Module 
				WHEN '10'	THEN 'System'			
				WHEN '20'	THEN 'Remittance'
				WHEN '30'	THEN 'International Operation'
				WHEN '40'	THEN 'Agent Operation'			
				ELSE '100'
			END moduleName
			,AgentMenuGroup		
			,menuName		
			,CASE @flag
				WHEN 'rfl' THEN dbo.FNAGetFunctionList(functionId, @roleId, NULL, @user, 10101030,NULL) 
				WHEN 'ufl' THEN dbo.FNAGetFunctionList(functionId, NULL, @userId, @user, 10101130,NULL) 
				ELSE ''
			 END [Rights]
			,CASE am.Module 
				WHEN '10'	THEN 10			
				WHEN '20'	THEN 20
				WHEN '30'	THEN 30	
				WHEN '50'	THEN 50		
				ELSE 100
			END [modulePostion]
			,am.groupPosition
			,am.position
			,am.functionId
		FROM applicationMenus am WITH(NOLOCK)
		INNER JOIN staticDataValue sdv ON am.module = sdv.valueId
				
		WHERE ISNULL(am.isActive, 'Y') = 'Y'
		AND ISNULL(AgentMenuGroup,'') <> ''
		ORDER BY 
			am.Module 
			,am.groupPosition ASC
			,am.position ASC
	END
	IF @roleType='H'
	BEGIN
		INSERT INTO #menuList(moduleName, menuGroup, menu, rights, modulePosition, groupPosition, menuPosition, functionId)
		SELECT
			 CASE am.Module 
				WHEN '10'	THEN 'System'						
				WHEN '20'	THEN 'Remittance'
				WHEN '30'	THEN 'International Operation'
				WHEN '40'	THEN 'Agent Operation'					
				ELSE '100'
			END moduleName	
			,menuGroup		
			,menuName		
			,CASE @flag
				WHEN 'rfl' THEN dbo.FNAGetFunctionList(functionId, @roleId, NULL, @user, 10101030,NULL) 
				WHEN 'ufl' THEN dbo.FNAGetFunctionList(functionId, NULL, @userId, @user, 10101130,NULL) 
				ELSE ''
			 END [Rights]
			,CASE am.Module 
				WHEN '10'	THEN 10			
				WHEN '20'	THEN 20
				WHEN '30'	THEN 30	
				WHEN '50'	THEN 50		
				ELSE 100
			END [modulePostion]
			,am.groupPosition
			,am.position
			,am.functionId
		FROM applicationMenus am WITH(NOLOCK)
		INNER JOIN staticDataValue sdv ON am.module = sdv.valueId
		WHERE ISNULL(am.isActive, 'Y') = 'Y'
		AND ISNULL(AgentMenuGroup,'') = ''
		ORDER BY 
			am.Module
			,AM.menuGroup
			,am.groupPosition ASC
			,am.position ASC
	END
	
	UPDATE #menuList SET
		 moduleName = CASE WHEN moduleName = ISNULL((SELECT TOP 1 moduleName FROM #menuList WHERE id = ml.id - 1), '') THEN NULL ELSE '<b>' + moduleName + '</b>' END	
		,menuGroup	= CASE 
							WHEN (
								menuGroup	 = ISNULL((SELECT TOP 1 menuGroup  FROM #menuList WHERE id = ml.id - 1), '') AND
								moduleName = ISNULL((SELECT TOP 1 moduleName FROM #menuList WHERE id = ml.id - 1), '')
							)	THEN NULL
							ELSE  [menuGroup] 
					  END
	FROM #menuList ml
	
	SELECT		 
		 '<span class="moduleGroupReport"	onclick = "SelectFunctions(this,''' + LEFT(functionId, 2) + ''');">' + moduleName + '</span>'	[Module]
		,'<span class="menuReport"			onclick = "SelectFunctions(this,''' + LEFT(functionId, 4) + ''');">' + menuGroup	+ '</span>'	[Group]
		,'<span class="subMenuReport"		onclick = "SelectFunctions(this,''' + LEFT(functionId, 6) + ''');">' + menu			+ '</span>'	[Menu]			
		,'<span class="rights">' + rights + '</span>'	[Rights]
	FROM #menuList L
END

ELSE iF @flag = 'rfi'
BEGIN
	--IF EXISTS (SELECT 'X' FROM applicationRoleFunctionsMod WITH(NOLOCK) WHERE roleId = @roleId AND createdBy <> @user)
	--BEGIN
	--	EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @userId
	--	RETURN
	--END
	
	--select @roleId

	SET @sql = '
		SELECT 
			functionId 
		FROM applicationFunctions af WITH(NOLOCK) 
		WHERE functionId IN (' + @functionIds + ')'
	INSERT @function_list
	EXEC (@sql)
	BEGIN TRANSACTION		
		DELETE FROM applicationRoleFunctions WHERE roleId = @roleId
		INSERT applicationRoleFunctions(functionId, roleId, createdBy, createdDate)
		SELECT functionId, @roleId, @user, GETDATE() FROM @function_list
		
		INSERT applicationRoleFunctions(functionId, roleId, createdBy, createdDate)
		SELECT -1, @roleId,  @user, GETDATE()
		
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION	
	EXEC proc_errorHandler 0, 'Role function successfully assigned.', @roleId	
END

ELSE iF @flag = 'reject' AND @roleId IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM applicationRoleFunctionsMod WITH(NOLOCK) WHERE roleId = @roleId)
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @roleId
		RETURN
	END		
		
	DELETE FROM applicationRoleFunctionsMod WHERE roleId = @roleId
	EXEC proc_errorHandler 0, 'Role function successfully rejected.', @roleId		
			
	--Audit data ends
	

END


ELSE iF @flag = 'approve' AND @roleId IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM applicationRoleFunctionsMod WITH(NOLOCK) WHERE roleId = @roleId)
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @roleId
		RETURN
	END

	DECLARE @roleName VARCHAR(50)
	SELECT TOP 1
		@roleName = ar.roleName 
	FROM applicationRoles ar WITH(NOLOCK) 
	WHERE ar.roleId = @roleId

	SELECT 
		@newValue = ISNULL(@newValue + ',', '') + CAST(functionId AS VARCHAR(50))
	FROM applicationRoleFunctionsMod 
	WHERE roleId = @roleId
	
	EXEC [dbo].proc_GetColumnToRow  'applicationRoleFunctions', 'roleId', @roleId, @oldValue OUTPUT
	
	BEGIN TRANSACTION		
		DELETE FROM applicationRoleFunctions WHERE roleId = @roleId
		INSERT applicationRoleFunctions(functionId, roleId, createdBy, createdDate)
		SELECT functionId, @roleId, @user, GETDATE() FROM applicationRoleFunctionsMod WHERE roleId = @roleId

		DELETE FROM applicationRoleFunctionsMod WHERE roleId = @roleId
		
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, 'update', 'Role Functions', @roleName, @user, @oldValue, @newValue	
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Could not approve the changes.', @roleId
			RETURN
		END
	
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC proc_errorHandler 0, 'Function successfully assigned.', @roleId		
			
	--Audit data ends
	

END


ELSE iF @flag = 'ufi'
BEGIN
	IF EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL AND createdBy <> @user)
	BEGIN
		EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @userId
		RETURN
	END 
	IF EXISTS (SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
	BEGIN
		EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @userId
		RETURN
	END 
	IF EXISTS (SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
	BEGIN
		EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @userId
		RETURN
	END	
	IF EXISTS (SELECT 'X' FROM applicationUserFunctionsMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
	BEGIN
		EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @roleId
		RETURN
	END
	SET @sql = '
		SELECT 
			functionId 
		FROM applicationFunctions af WITH(NOLOCK) 
		WHERE functionId IN (' + @functionIds + ')'
	INSERT @function_list
	EXEC (@sql)

	BEGIN TRANSACTION	
		DELETE FROM applicationUserFunctionsMod WHERE  [userId] = @userId
		INSERT applicationUserFunctionsMod(functionId, [userId], modType, createdBy, createdDate)
		SELECT functionId, @userId, 'U', @user, GETDATE() FROM @function_list	
		
		INSERT applicationUserFunctionsMod(functionId, [userId], modType, createdBy, createdDate)
		SELECT -1, @userId, 'U', @user, GETDATE()
	
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'User Function successfully assigned.', @userId	

END	

ELSE iF @flag = 'reject' AND @userId IS NOT NULL AND @functionIds IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM applicationUserFunctionsMod WITH(NOLOCK) WHERE userId = @userId)
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userId
		RETURN
	END	
		
		
	DELETE FROM applicationUserFunctionsMod WHERE userId = @userId
	EXEC proc_errorHandler 0, 'User function successfully rejected.', @userId		
			
END

ELSE iF @flag = 'approve' AND @userId IS NOT NULL AND @functionIds IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM applicationUserFunctionsMod WITH(NOLOCK) WHERE userId = @userId)
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userId
		RETURN
	END

	SELECT 
		@newValue = ISNULL(@newValue + ',', '') + CAST(functionId AS VARCHAR(50))
	FROM applicationUserFunctionsMod 
	WHERE userId = @userId
	
	EXEC [dbo].proc_GetColumnToRow  'applicationUserFunctions', 'userId', @userId, @oldValue OUTPUT
	
	BEGIN TRANSACTION		
		DELETE FROM applicationUserFunctions WHERE userId = @userId
		INSERT applicationUserFunctions(functionId, userId, createdBy, createdDate)
		SELECT functionId, @userId, @user, GETDATE() FROM applicationUserFunctionsMod WHERE userId = @userId

		DELETE FROM applicationUserFunctionsMod WHERE userId = @userId
		
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, 'update', 'User Functions', @userId, @user, @oldValue, @newValue	
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Could not approve the changes.', @userId
			RETURN
		END
	
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC proc_errorHandler 0, 'User Function successfully approved.', @roleId		
			
	--Audit data ends
	

END

ELSE IF @flag = 'rl'
BEGIN
	DECLARE @AROLETYPE CHAR(1)
	
	SELECT 
	@AROLETYPE = case when ISNULL(AU.userType, mode.userType) in ('AH','AB','BH','RH','VU','A') then 'A' else 'H' end 
	from applicationUsers AU
	LEFT JOIN applicationUsersMod mode ON AU.userId = mode.userId
	WHERE AU.userId = @userId


	IF EXISTS(SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) 
		WHERE userId = @userId AND (@user = createdBy OR 'Y' = dbo.FNAHasRight(@user,@ApproveFunctionId)))
		BEGIN
		    SELECT		
			    --ar.role_type			
			    '<input type = "checkbox"'
			    + ' value = "'				+ CAST(ar.roleId AS VARCHAR) + '"'
			    + ' id = "chk_'				+ CAST(ar.roleId AS VARCHAR) + '"'
			    + ' name = "roleId"'
			    + CASE WHEN aur.roleId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
			    + '> <label class = "rights" for = "chk_'	+ CAST(ar.roleId AS VARCHAR) + '">' + ar.roleName + '</label>' [Roles]
		    FROM applicationRoles ar WITH(NOLOCK)
		    LEFT JOIN applicationUserRolesMod aur WITH(NOLOCK) ON ar.roleId = aur.roleId AND aur.[userId] = @userId
		    WHERE ar.roleType = @AROLETYPE

		END
		ELSE
		BEGIN
		
		    SELECT		
			    --ar.role_type			
			    '<input type = "checkbox"'
			    + ' value = "'				+ CAST(ar.roleId AS VARCHAR) + '"'
			    + ' id = "chk_'				+ CAST(ar.roleId AS VARCHAR) + '"'
			    + ' name = "roleId"'
			    + CASE WHEN aur.roleId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
			    + '> <label class = "rights" for = "chk_'	+ CAST(ar.roleId AS VARCHAR) + '">
				<a href="'+dbo.FNAGetURL()+'SwiftSystem/UserManagement/ApplicationRoleSetup/Viewrolefunction.aspx?roleId=' + cast(ar.roleId as varchar(20)) + '&roleName=' + ar.roleName + '">' + ar.roleName + '</a></label>' [Roles]
		    FROM applicationRoles ar WITH(NOLOCK)
		    LEFT JOIN applicationUserRoles aur WITH(NOLOCK) ON ar.roleId = aur.roleId AND aur.[userId] = @userId
		    WHERE ar.roleType = @AROLETYPE
		END
END
ELSE iF @flag = 'uri'
BEGIN
	DECLARE @role_list TABLE(roleId INT)
	----IF EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL AND createdBy <> @user)
	----BEGIN
	----	EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @userId
	----	RETURN
	----END 
	----IF EXISTS (SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
	----BEGIN
	----	EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @userId
	----	RETURN
	----END 
	----IF EXISTS (SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
	----BEGIN
	----	EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @userId
	----	RETURN
	----END
	----IF EXISTS (SELECT 'X' FROM applicationUserFunctionsMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
	----BEGIN
	----	EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @userId
	----	RETURN
	----END	
	SET @sql = '
		SELECT 
			roleId 
		FROM applicationRoles ar WITH(NOLOCK) 
		WHERE roleId IN (' + @roleIds + ')'
	INSERT @role_list
	EXEC (@sql)
	BEGIN TRANSACTION
		DELETE FROM applicationUserRoles WHERE  [userId] = @userId

		INSERT applicationUserRoles(roleId, [userId], createdBy, createdDate)
		SELECT roleId, @userId, @user, GETDATE() FROM @role_list
		
		INSERT applicationUserRoles(roleId, [userId], createdBy, createdDate)
		SELECT -1, @userId,@user, GETDATE()	
	
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'Role successfully assigned.', @userId	

END

ELSE iF @flag = 'reject' AND @userId IS NOT NULL AND @roleIds IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) WHERE userId = @userId)
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userId
		RETURN
	END	
		
		
	DELETE FROM applicationUserRolesMod WHERE userId = @userId
	EXEC proc_errorHandler 0, 'User function successfully rejected.', @userId		
			
END

ELSE iF @flag = 'approve' AND @userId IS NOT NULL AND @roleIds IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) WHERE userId = @userId)
	BEGIN
		EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userId
		RETURN
	END

	SELECT 
		@newValue = ISNULL(@newValue + ',', '') + CAST(roleId AS VARCHAR(50))
	FROM applicationUserRolesMod 
	WHERE userId = @userId
	
	EXEC [dbo].proc_GetColumnToRow  'applicationUserRoles', 'userId', @userId, @oldValue OUTPUT
	
	BEGIN TRANSACTION		
		DELETE FROM applicationUserRoles WHERE userId = @userId
		INSERT applicationUserRoles(roleId, userId, createdBy, createdDate)
		SELECT roleId, @userId, @user, GETDATE() FROM applicationUserRolesMod WHERE userId = @userId

		DELETE FROM applicationUserRolesMod WHERE userId = @userId
		
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, 'update', 'User Roles', @userId, @user, @oldValue, @newValue	
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Could not approve the changes.', @userId
			RETURN
		END
	
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC proc_errorHandler 0, 'Role successfully approved.', @roleId		
			
	--Audit data ends
	

END

GO
