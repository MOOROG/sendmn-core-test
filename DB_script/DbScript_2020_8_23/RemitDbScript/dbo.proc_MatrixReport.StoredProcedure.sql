USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_MatrixReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[proc_MatrixReport](
--DECLARE
	 @flag			VARCHAR(20)
	,@user			VARCHAR(30)
	,@userName		VARCHAR(30) = NULL
	,@roleId		INT = NULL
	,@functionId	VARCHAR(50) = NULL
)
AS
SET NOCOUNT ON
BEGIN TRY	
IF @flag = 'udt'
BEGIN
	SELECT [dbo].[FNADateFormatTZ](GETDATE(), @user) dt

END
ELSE IF @flag = 'nrl'
BEGIN
	SELECT roleId, roleName FROM applicationRoles ORDER BY roleName
	RETURN
END

ELSE IF @flag = 'nrlReport'
BEGIN
	SELECT
		[AGENT NAME] = AM1.agentName+' ('+am.agentName+')',
		[USER NAME] = au.firstName + ISNULL(' ' + au.middleName, '') + ISNULL(' ' + au.lastName, '') + '(' + au.userName + ')'		
	FROM applicationUsers au WITH(NOLOCK)
	INNER JOIN applicationUserRoles aur WITH(NOLOCK) ON au.userId = aur.userId
	INNER join dbo.agentMaster am WITH(NOLOCK) ON am.agentid = au.agentId
	INNER JOIN AGENTMASTER AM1 WITH(NOLOCK) ON AM1.agentId = am.parentId
	
	WHERE aur.roleId = @roleId 
		and isnull(au.isDeleted,'N') ='N'
		and isnull(au.isActive,'Y') = 'Y'
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	DECLARE @roleName VARCHAR(100)

	SELECT
		@roleName = ar.roleName
	FROM applicationRoles ar WITH(NOLOCK)
	WHERE ar.roleId = @roleId
	
	SELECT 
		'Role Name' head
		,@roleName	value

	SELECT 'User Matrix Report (Role » User)' title
	
END

ELSE IF @flag = 'nrlReport2'
BEGIN
	SELECT
		Name = am.menuGroup + ' » ' + am.menuName + ' » ' + af.functionName 
	FROM applicationMenus am WITH(NOLOCK)
	INNER JOIN applicationFunctions af WITH(NOLOCK) ON am.functionId = af.parentFunctionId
	INNER JOIN applicationRoleFunctions arf WITH(NOLOCK) ON af.functionId = arf.functionId
	WHERE arf.roleId = @roleId
	ORDER BY am.menuGroup , am.menuName, af.functionName 
	
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	

	SELECT
		@roleName = ar.roleName
	FROM applicationRoles ar WITH(NOLOCK)
	WHERE ar.roleId = @roleId
	
	SELECT 
		'Role Name' head
		,@roleName	value

	SELECT 'User Matrix Report (Role » Function)' title
	
END
ELSE IF @flag = 'nfl'
BEGIN
	SELECT
		af.functionId 
		,functionName = am.menuGroup + ' » ' + am.menuName + ' » ' + af.functionName 
	FROM applicationMenus am WITH(NOLOCK)
	INNER JOIN applicationFunctions af WITH(NOLOCK) ON am.functionId = af.parentFunctionId
	
	ORDER BY am.menuGroup , am.menuName, af.functionName 
	RETURN
END

ELSE IF @flag = 'nflReport'
BEGIN
	SELECT 
		Name = au.firstName + ISNULL(' ' + au.middleName, '') + ISNULL(' ' + au.lastName, '') + '(' + au.userName + ')'
		,Type = 'USER  '
		INTO #rTmp
	FROM applicationUsers au
	INNER JOIN (
		SELECT
			arf.functionId functionId
			,aur.userId
		FROM applicationRoleFunctions arf WITH(NOLOCK)
		INNER JOIN applicationUserRoles aur WITH(NOLOCK) ON arf.roleId = aur.roleId
		WHERE arf.roleId IN (SELECT roleId FROM applicationUserRoles)

		UNION
		SELECT
			 auf.functionId  functionId
			,auf.userId
		FROM applicationUserFunctions auf WITH(NOLOCK)
	) x ON au.userId = x.userId
	WHERE x.functionId = @functionId
	ORDER BY au.firstName
	
	INSERT INTO #rTmp
	
	SELECT
		Name = ar.roleName
		,Type = '[ROLE]' 
	FROM applicationRoleFunctions arf WITH(NOLOCK)
	INNER JOIN applicationRoles ar WITH(NOLOCK) ON arf.roleId = ar.roleId
	 WHERE functionId = @functionId
	 ORDER BY ar.roleName
	
	SELECT * FROM #rTmp
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	DECLARE @functionName VARCHAR(500)

	SELECT
		@functionName = am.menuGroup + ' » ' + am.menuName + ' » ' + af.functionName 
	FROM applicationMenus am WITH(NOLOCK)
	INNER JOIN applicationFunctions af WITH(NOLOCK) ON am.functionId = af.parentFunctionId
	WHERE af.functionId = @functionId
	
	SELECT
		'Function Name' head
		,@functionName	value

	SELECT 'User Matrix Report (Function)' title
END


	ELSE IF @flag = 'report'
	BEGIN
		IF @userName IS NOT NULL
		BEGIN	
			IF NOT EXISTS(SELECT 'x' FROM applicationUsers au WITH(NOLOCK) WHERE au.userName = @userName)
			BEGIN
				EXEC proc_errorHandler '1', 'User Does not exists.', NULL
				EXEC proc_errorHandler '1', 'User Does not exists.', NULL
				RETURN
			END
		END
	
		IF OBJECT_ID('tempdb..#userList') IS NOT NULL
			DROP TABLE #userList
	
		CREATE TABLE #userList(
			 rowId		INT IDENTITY(1, 1)
			,userName	VARCHAR(30)
			,Name		VARCHAR(50)
			,department	VARCHAR(50)
			,branch		VARCHAR(50)
			,supervisor	VARCHAR(50)	
		)
	
		INSERT INTO #userList(userName, Name, department, branch, supervisor)
		SELECT
			 au.userName
			,au.userName + ' (' + ISNULL(au.firstName, '') + ISNULL(' ' + au.middleName, '') + ISNULL(' ' + au.lastName, '')+')' fullName
			,''
			,am.agentName
			,''
		FROM applicationUsers au WITH(NOLOCK)
		LEFT JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
		WHERE au.userName = ISNULL(@userName, au.userName)
			AND ISNULL(au.isActive, 'N') = 'Y'
			--ORDER BY ISNULL(au1.firstName, '') asc
		
		
		SELECT * FROM #userList

		IF OBJECT_ID('tempdb..#report') IS NOT NULL
			DROP TABLE #report
		
		CREATE TABLE #report(
			 module				VARCHAR(50)
			,modulePostion		INT
			,[group]			VARCHAR(50)
			,groupPostion		INT
			,[menu]				VARCHAR(50)
			,menuPostion		INT
			,id					INT	
		)
		
		DECLARE 
			 @sql					VARCHAR(MAX)
			,@fieldList				VARCHAR(MAX)
			,@fieldListAdd			VARCHAR(MAX)
			,@fieldListSelect		VARCHAR(MAX)
			,@fieldCond				VARCHAR(MAX)
		
		SELECT 
			 @fieldList				= ISNULL(@fieldList + ',' , '')			+ '[' + functionName + ']'
			,@fieldCond				= ISNULL(@fieldCond + ' OR ' , '')			+ '[' + functionName + ']  IS NOT NULL '
			,@fieldListAdd			= ISNULL(@fieldListAdd + ',' , '')		+ '[' + functionName + ']	VARCHAR(100)'	
			,@fieldListSelect		= ISNULL(@fieldListSelect + ',' , '') 
									+ '[' + functionName + '] [' 
									+ 
									CASE functionName 
										WHEN 'Assign Functions' THEN 'Assign<br />Functions'
										WHEN 'Assign Roles' THEN 'Assign<br />Roles'
										WHEN 'View History' THEN 'View<br />History'
										WHEN 'Approve/Reject' THEN 'Approve<br />Reject'
										WHEN 'Add/Edit' THEN 'Add<br />Edit'
										ELSE  functionName
									 END
									+ ']'

		FROM (
			--------SELECT DISTINCT 
			--------	functionName
			--------FROM applicationFunctions
			SELECT DISTINCT functionName
			FROM applicationFunctions aF WITH (NOLOCK)
			INNER JOIN (			
						select DISTINCT functionId from applicationRoleFunctions ARF
						INNER JOIN applicationUserRoles AUR ON ARF.roleId = AUR.roleId
						INNER JOIN applicationUserS AU ON AU.userId = AUR.userId
						WHERE AU.userName = @userName
			) X ON aF.functionId = X.functionId
			INNER JOIN applicationMenus AM ON AM.functionId = aF.parentFunctionId
		) x
		
		SET @sql = 'ALTER TABLE #report ADD ' + @fieldListAdd
		EXEC (@sql)
		
		--SELECT * FROM staticDataValue where typeID = 1400
		
		WHILE EXISTS(SELECT 'X' FROM #userList)
		BEGIN
			SELECT TOP 1 @userName = userName FROM #userList
			DECLARE @userId VARCHAR(20)
			SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName			
			SET @sql = '
			SELECT
				 sdv.detailDesc [Module]
				,CASE am.Module 
					WHEN ''10''	THEN 10			
					WHEN ''20''	THEN 20
					WHEN ''30''	THEN 30
					ELSE 100
				END [modulePostion]
				,am.menuGroup [Group]
				,am.groupPosition
				,x.menuName	  [Menu]
				,am.position
				,ROW_NUMBER() OVER(ORDER BY 
					CASE am.Module 
						WHEN ''10''	THEN 10			
						WHEN ''20''	THEN 20
						WHEN ''30''	THEN 30
						ELSE 100
					END ASC
					,am.groupPosition ASC, am.position) Id
				,' + @fieldList + '
				
			FROM (
				SELECT
					 menuName
					,' + @fieldList + '
					
				FROM (
						SELECT 
							 am.menuName
							,af.functionName							
							,CASE WHEN x.functionId IS NOT NULL THEN ''x'' ELSE NULL END hasAccess 
						FROM applicationMenus am
						INNER JOIN applicationFunctions af ON am.functionId = af.parentFunctionId
						LEFT JOIN(
								SELECT
									 userId = ''' + @userId + '''
									,arf.functionId functionId
								FROM applicationRoleFunctions arf WITH(NOLOCK)
								WHERE roleId IN (SELECT roleId FROM applicationUserRoles WHERE userId =''' +  @userId + ''')
								
								UNION
								SELECT
									 userId = ''' + @userId + '''
									,auf.functionId  functionId
								FROM applicationUserFunctions auf WITH(NOLOCK)
								WHERE userId = ''' + @userId + '''
						) x ON af.functionId = x.functionId
				) x
				PIVOT
				(
					MAX (hasAccess)
					FOR functionName IN
					( 
						' + @fieldList + '						
					)
				) AS pvt
			)x
			INNER JOIN applicationMenus am ON am.menuName = x.menuName
			INNER JOIN staticDataValue sdv ON am.module = sdv.valueId		
			'
			
			TRUNCATE TABLE #report
			INSERT INTO #report
			EXEC(@sql)
		
			SET @sql = '
			SELECT
				 [Module]	= CASE WHEN [Module] = ISNULL((SELECT TOP 1 [Module] FROM #report WHERE id = r.id - 1), '''') THEN NULL ELSE ''<span class="moduleGroup">'' + [Module] + ''</span>'' END
				,[Group]	= CASE 
									WHEN (
										[Group]	 = ISNULL((SELECT TOP 1 [Group]  FROM #report WHERE id = r.id - 1), '''') AND
										[Module] = ISNULL((SELECT TOP 1 [Module] FROM #report WHERE id = r.id - 1), '''')
									)	THEN NULL
									ELSE ''<span class="menu">'' + [Group]  + ''</span>'' 
							  END
				,[Menu]		= ''<span class="subMenu">'' + [Menu] + ''</span>''
				,' + @fieldListSelect + '				
			FROM #report r 
			WHERE ('+@fieldCond +')'

			
			PRINT @sql
			EXEC(@sql)
			DELETE FROM #userList WHERE userName =  @userName 
			--select * FROM #report
			
		END	
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		
		SELECT 
			'User Name' head
			,@userName	value
			
		UNION ALL		
		SELECT
			'Full Name' head
			,ISNULL(au.firstName, '') + ISNULL(' '  + au.middleName, '') + ISNULL(' '  + au.lastName, '') Value
		FROM applicationUsers au WITH(NOLOCK) WHERE au.userName = @userName
		

		SELECT 'User Matrix Report' title
		
		RETURN
	END
	ELSE
	BEGIN
		EXEC proc_errorHandler '1', 'Error', NULL
		EXEC proc_errorHandler '1', 'Error', NULL
	END
	
END TRY
BEGIN CATCH
	DECLARE @msg VARCHAR(100)
	SET @msg = ERROR_MESSAGE()
	
	EXEC proc_errorHandler '1', @msg, NULL
	EXEC proc_errorHandler '1', @msg, NULL
END CATCH






GO
