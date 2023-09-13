
--exec menu_proc @flag = 'agent', @user = 'tokyouser'

ALTER PROC menu_proc
    @flag CHAR(25) ,
    @user VARCHAR(50)
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
IF @flag = 'admin'
BEGIN
	IF @user IN (select [admin] from dbo.FNAGetAdmins())
	BEGIN
		SELECT * FROM (
		SELECT DISTINCT menuGroup,groupPosition
		FROM dbo.applicationMenus (NOLOCK)
		WHERE ISNULL(AgentMenuGroup,'') = '' AND isActive = 'Y'
		
		UNION ALL
		SELECT 'Service Charge & Commission',12 
		
		UNION ALL
		SELECT 'Customer Management', 12

		UNION ALL
		SELECT 'Utilities', 13

		UNION ALL
		SELECT 'Accounts', 14

		UNION ALL
		SELECT 'EXCHANGE SETUP', 18
		)X
		ORDER BY groupPosition,menuGroup DESC


		SELECT linkPage ,menuName 
		,menuGroup = CASE WHEN menuName IN  ('Domestic Commission','Commission Group Mapping','Agent Commission Rule') THEN 'Service Charge & Commission' 
		WHEN menuName IN ('Customer Setup', 'Approve Customer', 'Customer Statement','Customer Modify', 'Modify Customer Bank') THEN 'Customer Management' 
		WHEN menuName IN ('Reprint Receipt', 'Agent Finder') THEN 'Utilities'
		WHEN menuName IN ('Create Ledger', 'Account Detail', 'Account Statement', 'Move Ledger', 'Manual Voucher') THEN 'Accounts'
		--WHEN menuGroup IN ('Service Charge/Commission', 'Credit Risk') THEN 'Intl Operation'
		ELSE menuGroup END
		FROM dbo.applicationMenus (NOLOCK)
		WHERE ISNULL(AgentMenuGroup,'') = '' AND isActive = 'Y'
		and functionId <> '90100000'
		ORDER BY groupPosition,menuGroup DESC
	END;
	ELSE
	BEGIN
		DECLARE @sql VARCHAR(MAX) 
		IF NOT EXISTS(SELECT 1 
					FROM applicationRoles AR(NOLOCK) 
					INNER JOIN applicationUserRoles AUR(NOLOCK) ON AUR.roleId = AR.roleId
					INNER JOIN applicationUsers AU(NOLOCK) ON AU.userId = AUR.userId
					WHERE AU.userName = @user
					AND ISNULL(AR.isActive, 'Y') = 'Y')
		BEGIN
			SELECT menuGroup = '', groupPosition = ''

			SELECT linkPage = '', menuName = ''
							,menuGroup = '' 

			RETURN;
		END
		SET @sql = 'SELECT * FROM 
		(SELECT DISTINCT AM.menuGroup, AM.groupPosition
		FROM dbo.applicationUserRoles AR(NOLOCK)
		INNER JOIN dbo.applicationRoleFunctions AF(NOLOCK) ON AF.roleId = AR.roleId
		INNER JOIN dbo.applicationMenus AM(NOLOCK) ON AM.functionId = AF.functionId
		INNER JOIN dbo.applicationUsers AU(NOLOCK) ON AU.userId = AR.userId
		WHERE AU.userName = '''+@user+''' AND ISNULL(am.AgentMenuGroup,'''') = '''' AND AM.isActive = ''Y''
		and AM.functionId <> ''90100000'' '
		
		IF EXISTS (SELECT AM.menuName FROM dbo.applicationUserRoles AR(NOLOCK)
		INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
		INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
		INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
		WHERE AU.userName = @user
		AND ISNULL(am.AgentMenuGroup,'') = '' AND AM.isActive = 'Y'
		AND AM.menuName IN ('Domestic Commission','Commission Group Mapping'))
		BEGIN
			SET @sql += ' UNION ALL
			SELECT ''Service Charge & Commission'', 12'
		END

		IF EXISTS (SELECT AM.menuName FROM dbo.applicationUserRoles AR(NOLOCK)
		INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
		INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
		INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
		WHERE AU.userName = @user
		AND ISNULL(am.AgentMenuGroup,'') = '' AND AM.isActive = 'Y'
		AND AM.menuName IN ('Customer Setup', 'Approve Customer', 'Modify Customer Bank'))
		BEGIN
			SET @sql += ' UNION ALL
			SELECT ''Customer Management'', 12'
		END

		IF EXISTS (SELECT AM.menuName FROM dbo.applicationUserRoles AR(NOLOCK)
		INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
		INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
		INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
		WHERE AU.userName = @user
		AND ISNULL(am.AgentMenuGroup,'') = '' AND AM.isActive = 'Y'
		AND AM.menuName IN ('Reprint Receipt', 'Agent Finder'))
		BEGIN
			SET @sql += ' UNION ALL
			SELECT ''Utilities'', 13'
		END

		IF EXISTS (SELECT AM.menuName FROM dbo.applicationUserRoles AR(NOLOCK)
		INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
		INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
		INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
		WHERE AU.userName = @user
		AND ISNULL(am.AgentMenuGroup,'') = '' AND AM.isActive = 'Y'
		AND AM.menuName IN ('Create Ledger', 'Account Detail', 'Account Statement', 'Move Ledger', 'Manual Voucher'))
		BEGIN
			SET @sql += ' UNION ALL
			SELECT ''Accounts'', 14'
		END
		
		SET @sql += ')X
		ORDER BY X.groupPosition,X.menuGroup DESC'

		EXEC(@sql);

		SELECT AM.linkPage,AM.menuName 
		,menuGroup = CASE WHEN AM.menuName IN  ('Domestic Commission','Commission Group Mapping','Agent Commission Rule') THEN 'Service Charge & Commission' 
		WHEN AM.menuName IN ('Customer Setup', 'Approve Customer','Customer Statement','Customer Modify', 'Modify Customer Bank','Customer Registration') THEN 'Customer Management' 
		WHEN AM.menuName IN ('Reprint Receipt', 'Agent Finder') THEN 'Utilities'
		WHEN AM.menuName IN ('Create Ledger', 'Account Detail', 'Account Statement', 'Move Ledger', 'Manual Voucher') THEN 'Accounts' 
		ELSE menuGroup END
		FROM dbo.applicationUserRoles AR (NOLOCK)
		INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
		INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
		INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
		WHERE AU.userName = @user
		AND ISNULL(am.AgentMenuGroup,'') = '' AND AM.isActive = 'Y'
		and AM.functionId <> '90100000'
		ORDER BY AM.groupPosition, AM.menuGroup DESC;
	END;
	
END;
IF @flag = 'agent'
BEGIN
	
	DECLARE @MENULIST TABLE(AgentMenuGroup VARCHAR(100),groupPosition INT)
	IF NOT EXISTS(SELECT 1 
				FROM applicationRoles AR(NOLOCK) 
				INNER JOIN applicationUserRoles AUR(NOLOCK) ON AUR.roleId = AR.roleId
				INNER JOIN applicationUsers AU(NOLOCK) ON AU.userId = AUR.userId
				WHERE AU.userName = @user
				AND ISNULL(AR.isActive, 'Y') = 'Y')
	BEGIN
		SELECT * FROM @MENULIST

		SELECT linkPage = '', menuName = ''
						,AgentMenuGroup = '' 

		RETURN;
	END
	INSERT INTO @MENULIST
	SELECT DISTINCT AM.AgentMenuGroup, AM.groupPosition
	FROM dbo.applicationUserRoles AR (NOLOCK)
	INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
	INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
	INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
	WHERE   AU.userName = @user
	AND AM.AgentMenuGroup IS NOT NULL 
	AND ISNULL(AM.isActive, 'Y') = 'Y'

	IF EXISTS (SELECT AM.menuName FROM dbo.applicationUserRoles AR(NOLOCK)
	INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
	INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
	INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
	WHERE AU.userName = @user
	AND AM.AgentMenuGroup IS NOT NULL 
	AND ISNULL(AM.isActive, 'Y') = 'Y'
	AND AM.menuName IN ('Domestic Send', 'Approve Transaction', 'Send Transaction','Send On Behalf'))
	BEGIN
		INSERT INTO @MENULIST
		SELECT 'Send Money', 20
	 --   SET @sql += ' UNION ALL
		--SELECT ''Send Money'', 1'
	END

	IF EXISTS (SELECT AM.menuName FROM dbo.applicationUserRoles AR(NOLOCK)
	INNER JOIN dbo.applicationRoleFunctions AF (NOLOCK) ON AF.roleId = AR.roleId
	INNER JOIN dbo.applicationMenus AM (NOLOCK) ON AM.functionId = AF.functionId
	INNER JOIN dbo.applicationUsers AU (NOLOCK) ON AU.userId = AR.userId
	WHERE AU.userName = @user
	AND AM.AgentMenuGroup IS NOT NULL 
	AND ISNULL(AM.isActive, 'Y') = 'Y'
	AND AM.menuName = 'Pay Transaction')
	BEGIN
		INSERT INTO @MENULIST
		SELECT 'Pay Money', 2
		--SET @sql += ' UNION ALL
		--SELECT ''Pay Money'', 2'
	END
	
	--SET @sql += ')X
	--ORDER BY X.groupPosition,X.AgentMenuGroup'
	--EXEC(@sql);

	SELECT DISTINCT * FROM @MENULIST ORDER BY groupPosition,AgentMenuGroup

	SELECT AM.linkPage ,AM.menuName 
	,AgentMenuGroup = CASE WHEN AM.menuName IN ('Domestic Send', 'Approve Transaction', 'Send Transaction','Send On Behalf') THEN 'Send Money' 
	WHEN AM.menuName = 'Pay Transaction' THEN 'Pay Money' ELSE AM.AgentMenuGroup END
	FROM dbo.applicationUserRoles AR
	INNER JOIN dbo.applicationRoleFunctions AF(NOLOCK) ON AF.roleId = AR.roleId
	INNER JOIN dbo.applicationMenus AM(NOLOCK) ON AM.functionId = AF.functionId
	INNER JOIN dbo.applicationUsers AU(NOLOCK) ON AU.userId = AR.userId
	WHERE AU.userName = @user
	AND AM.AgentMenuGroup IS NOT NULL 
	AND ISNULL(AM.isActive, 'Y') = 'Y'
	ORDER BY AM.POSITION
END;
