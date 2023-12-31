USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetFilterModule]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetFilterModule](@userName VARCHAR(30))
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF EXISTS(SELECT 'X' FROM dbo.FNAGetAdmins() WHERE admin = @userName)	
		RETURN ''
		
	DECLARE @module VARCHAR(MAX)
	
	DECLARE @moduleList TABLE(module VARCHAR(100))
	
	INSERT @moduleList(module)
	
	SELECT DISTINCT am.module FROM (
		SELECT 
			arf.functionId functionId
		FROM applicationRoleFunctions arf WITH(NOLOCK)
		WHERE roleId IN (SELECT roleId FROM applicationUserRoles WHERE userId = (SELECT userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName))
		UNION
		SELECT
			auf.functionId  functionId
		FROM applicationUserFunctions auf WITH(NOLOCK)
		WHERE userId = (SELECT userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName)
	) x 
	INNER JOIN applicationFunctions af ON x.functionId = af.functionId
	INNER JOIN applicationMenus am ON am.functionId = af.parentFunctionId
	WHERE ISNULL(am.isActive, 'Y') = 'Y'
	
	SELECT @module = ISNULL(@module + ', ', '') + '''' + module + '''' FROM @moduleList
	IF @module IS NULL
		RETURN ' AND 1 = 2 '
		
	RETURN 'AND module IN(' +  @module + ')'
	

END


GO
