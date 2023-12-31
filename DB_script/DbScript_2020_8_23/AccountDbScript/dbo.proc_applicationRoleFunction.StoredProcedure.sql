USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationRoleFunction]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
			[Module] = CASE am.Module WHEN '10' THEN 'System Module' END 		
			,menuGroup
			, menuDescription
			,dbo.FNAGetFunctionList(am.functionId, @roleId, NULL,@user, 10101030,'Y') [Rights]
			,CASE am.Module 
				WHEN '10'	THEN 10			
				WHEN '20'	THEN 20
				WHEN '30'	THEN 30			
				ELSE 100
			END [modulePostion]
			,am.groupPosition
			,am.position
			,am.functionId
	from applicationFunctions AF
	INNER JOIN applicationMenus AM ON AM.functionId=AF.parentFunctionId 
	INNER JOIN applicationROLEFunctions ARF ON ARF.functionId=AF.functionId AND ARF.roleId=@roleId


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
	FROM #menuList
	--ORDER BY modulePosition ASC, groupPosition ASC, menuPosition ASC

END


IF @flag IN('ufl', 'rfl')
BEGIN
	DECLARE @roleType AS VARCHAR(1)
		
	IF @roleId IS NULL
		SELECT @roleId = roleId from applicationUserRoles where userId=@userId AND roleId<>'-1'
		
	----SELECT @roleType = roleType FROM applicationRoles where roleId = @roleId

	--IF @roleType='A'
	--BEGIN
	--	INSERT INTO #menuList(moduleName, menuGroup, menu, rights, modulePosition, groupPosition, menuPosition, functionId)
	--	SELECT
	--		[Module] = CASE am.Module WHEN '40' THEN 'Exchange Module' END 	
	--		,MenuGroup		
	--		,menuDescription		
	--		,CASE @flag
	--			WHEN 'rfl' THEN dbo.FNAGetFunctionList(functionId, @roleId, NULL, @user, 10101030,NULL) 
	--			--WHEN 'ufl' THEN dbo.FNAGetFunctionList(functionId, NULL, @userId, @user, 10101130,NULL) 
	--			ELSE ''
	--		 END [Rights]
	--		,CASE am.Module 
	--			WHEN '10'	THEN 10			
	--			WHEN '20'	THEN 20
	--			WHEN '30'	THEN 30			
	--			ELSE 100
	--		END [modulePostion]
	--		,am.groupPosition
	--		,am.position
	--		,am.functionId
	--	FROM applicationMenus am WITH(NOLOCK)
	--	WHERE ISNULL(am.isActive, 'Y') = 'Y' AND Module = 40
	--	ORDER BY 
	--		CASE am.Module 
	--			WHEN '10'	THEN 10			
	--			WHEN '20'	THEN 20
	--			WHEN '30'	THEN 30
	--			ELSE 100
	--		END	ASC
	--		,am.groupPosition ASC
	--		,am.position ASC
	--END
	--IF @roleType='H'
	BEGIN
		INSERT INTO #menuList(moduleName, menuGroup, menu, rights, modulePosition, groupPosition, menuPosition, functionId)
		SELECT
			 [Module] = CASE am.Module WHEN '10' THEN 'System Module' WHEN '20' THEN 'Exchange Module' END 	
			,menuGroup		
			,menuDescription		
			,CASE @flag
				WHEN 'rfl' THEN dbo.FNAGetFunctionList(functionId, @roleId, NULL, @user, null,NULL) 
				WHEN 'ufl' THEN dbo.FNAGetFunctionList(functionId, NULL, @userId, @user, null,NULL) 
				ELSE ''
			 END [Rights]
			,am.Module [modulePostion]
			,am.groupPosition
			,am.position
			,am.functionId
		FROM applicationMenus am WITH(NOLOCK)
		WHERE ISNULL(am.isActive, 'Y') = 'Y'
		ORDER BY 
			am.Module ASC
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
		 '<span class="moduleGroupReport"	onclick = "SelectFunctions(this,''' + LEFT(functionId, 2) + ''');">' + moduleName	+ '</span>'	[Module]
		,'<span class="menuReport"			onclick = "SelectFunctions(this,''' + LEFT(functionId, 4) + ''');">' + menuGroup	+ '</span>'	[Group]
		,'<span class="subMenuReport"		onclick = "SelectFunctions(this,''' + LEFT(functionId, 6) + ''');">' + menu			+ '</span>'	[Menu]			
		,'<span class="rights">' + rights + '</span>'	[Rights]
	FROM #menuList
	ORDER BY modulePosition ASC, groupPosition ASC, menuPosition ASC	
END

ELSE iF @flag = 'rfi'
BEGIN
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
		SELECT -1, @roleId, @user, GETDATE()
		
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION	
	EXEC proc_errorHandler 0, 'Role function successfully assigned.', @roleId	
END

ELSE iF @flag = 'ufi'
BEGIN

	SET @sql = '
		SELECT 
			functionId 
		FROM applicationFunctions af WITH(NOLOCK) 
		WHERE functionId IN (' + @functionIds + ')'
	INSERT @function_list
	EXEC (@sql)

	BEGIN TRANSACTION	
		DELETE FROM applicationUserFunctions WHERE  [userId] = @userId
		INSERT applicationUserFunctions(functionId, [userId], modType, createdBy, createdDate)
		SELECT functionId, @userId, 'U', @user, GETDATE() FROM @function_list	
		
		INSERT applicationUserFunctions(functionId, [userId], modType, createdBy, createdDate)
		SELECT -1, @userId, 'U', @user, GETDATE()
	
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'User Function successfully assigned.', @userId	

END	

ELSE IF @flag = 'rl'
BEGIN
	DECLARE @AROLETYPE CHAR(1)
	
	SELECT 
	@AROLETYPE = case when ISNULL(USERTYPE,'A') in ('A') then 'H' else 'A' end 
	from applicationUsers  WITH(NOLOCK)
	WHERE userId = @userId

	    SELECT		
		    --ar.role_type			
		    '<input type = "checkbox"'
		    + ' value = "'				+ CAST(ar.roleId AS VARCHAR) + '"'
		    + ' id = "chk_'				+ CAST(ar.roleId AS VARCHAR) + '"'
		    + ' name = "roleId"'
		    + CASE WHEN aur.roleId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
		    + '> <label class = "rights" for = "chk_'	+ CAST(ar.roleId AS VARCHAR) + '">
			<a href="../ApplicationRoleSetup/Viewrolefunction.aspx?roleId=' + cast(ar.roleId as varchar(20)) + '&roleName=' + ar.roleName + '">' + ar.roleName + '</a></label>' [Roles]
	    FROM applicationRoles ar WITH(NOLOCK)
	    LEFT JOIN applicationUserRoles aur WITH(NOLOCK) ON ar.roleId = aur.roleId AND aur.[userId] = @userId
	    ----WHERE ar.roleType = @AROLETYPE
END
ELSE IF @flag ='uri'
BEGIN
	SET @sql = '
		SELECT 
			roleId 
		FROM applicationRoles  WITH(NOLOCK) 
		WHERE roleId IN (' + @roleIds + ')'
	INSERT @function_list
	EXEC (@sql)
	BEGIN TRANSACTION		
		DELETE FROM applicationUserRoles WHERE userId = @userId
		INSERT applicationUserRoles(userId, roleId, createdBy, createdDate)
		SELECT @userId, functionId, @user, GETDATE() FROM @function_list
		
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION	
	EXEC proc_errorHandler 0, 'Role successfully assigned.', @roleId	
END

GO
