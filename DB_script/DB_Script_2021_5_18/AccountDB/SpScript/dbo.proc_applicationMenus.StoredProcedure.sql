USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationMenus]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_applicationMenus]
	 @flag			VARCHAR(10) = NULL
	,@userName		VARCHAR(50) = NULL

AS
/*
exec proc_applicationMenus @userName = 'checker'

SELECT dbo.FNAIsAdmin(NULL)
*/


IF NULLIF(@flag, 's') IS NULL
BEGIN
	DECLARE @USERID INT 
	
	SELECT @USERID = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName
	
	IF @username IN('admin','exadmin')
	BEGIN
		SELECT 
			am.* 
		FROM applicationMenus am WITH(NOLOCK)		
		WHERE ISNULL(am.isActive, 'Y') = 'Y'
		ORDER BY am.groupPosition ASC, am.position ASC		
		RETURN	
	END
	ELSE
	BEGIN
		SELECT 
			am.* 
		FROM applicationMenus am WITH(NOLOCK)	
		INNER JOIN (
		SELECT AU.userId,ARF.functionId FROM dbo.applicationUserRoles AU WITH(NOLOCK)
		INNER JOIN applicationRoleFunctions ARF WITH(NOLOCK) ON AU.roleId = ARF.roleId
		WHERE AU.userId = @USERID
		) R ON am.functionId = R.functionId
		WHERE ISNULL(am.isActive, 'Y') = 'Y'
		ORDER BY am.groupPosition ASC, am.position ASC		
		RETURN	
	END
END

GO
