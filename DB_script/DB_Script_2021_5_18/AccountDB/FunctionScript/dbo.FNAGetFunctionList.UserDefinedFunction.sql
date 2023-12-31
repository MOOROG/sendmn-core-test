USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetFunctionList]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		
        
CREATE FUNCTION [dbo].[FNAGetFunctionList](
	 @parentFunctionId		INT
	,@roleId				INT
	,@userId				INT
	,@user					VARCHAR(30)
	,@ApproveFunctionId		INT
	,@viewRole				CHAR(1)
)  
RETURNS VARCHAR(MAX)
AS  
BEGIN
	DECLARE @str VARCHAR(MAX)
	IF @roleId IS NOT NULL AND @viewRole IS NULL
	BEGIN
		BEGIN
			SELECT
				@str = ISNULL(@str + '<br />', '') 
				+ '<input type = "checkbox"'
				+ ' value = "'				+ CAST(af.functionId AS VARCHAR) + '"'
				+ ' id = "chk_'				+ CAST(af.functionId AS VARCHAR) + '"'
				+ ' name = "functionId"'
				+ CASE WHEN arf.functionId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
				+ '> <label class = "rights" for = "chk_'	+ CAST(af.functionId AS VARCHAR) + '">' + functionName + '</label>'
			 FROM applicationFunctions af WITH(NOLOCK)
			 LEFT JOIN applicationRoleFunctions arf WITH(NOLOCK) 
				ON af.functionId = arf.functionId AND arf.roleId = @roleId	
			 WHERE af.parentFunctionId = @parentFunctionId 
		END 
		 
	END
	----ELSE IF @userId IS NOT NULL
	----BEGIN
	----	BEGIN
	----		SELECT
	----			@str = ISNULL(@str + '<br />', '') 
	----			+ '<input type = "checkbox"'
	----			+ ' value = "'				+ CAST(af.functionId AS VARCHAR) + '"'
	----			+ ' id = "chk_'				+ CAST(af.functionId AS VARCHAR) + '"'
	----			+ ' name = "functionId"'
	----			+ CASE WHEN x.functionId IS NOT NULL THEN ' disabled = "disabled"' ELSE '' END
	----			+ CASE WHEN (x.functionId IS NOT NULL OR auf.functionId IS NOT NULL) THEN ' checked = "checked" ' ELSE '' END
	----			+ '> <label class = "rights" for = "chk_'	+ CAST(af.functionId AS VARCHAR) + '">' + functionName + '</label>'
	----		 FROM applicationFunctions af WITH(NOLOCK)
	----		 LEFT JOIN applicationUserFunctions auf WITH(NOLOCK) 
	----			ON af.functionId = auf.functionId AND auf.userId = @userId		
	----		 LEFT JOIN (			
	----					SELECT DISTINCT
	----						arf.functionId functionId
	----					FROM applicationRoleFunctions arf WITH(NOLOCK)
	----					WHERE roleId IN (SELECT roleId FROM applicationUserRoles WHERE userId = @userId)
					
	----		)x ON af.functionId = x.functionId		 
			 
	----		 WHERE af.parentFunctionId = @parentFunctionId	
	----	END
	----END	
	ELSE IF @viewRole IS NOT NULL
	BEGIN
		BEGIN
			SELECT
				@str = ISNULL(@str + '<br />', '') 
				+ '<input type = "checkbox" disabled = "disabled"'
				+ ' value = "'				+ CAST(af.functionId AS VARCHAR) + '"'
				+ ' id = "chk_'				+ CAST(af.functionId AS VARCHAR) + '"'
				+ ' name = "functionId"'
				+ CASE WHEN arf.functionId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
				+ '> <label class = "rights" for = "chk_'	+ CAST(af.functionId AS VARCHAR) + '">' + functionName + '</label>'
			 FROM applicationFunctions af WITH(NOLOCK)
			 LEFT JOIN applicationRoleFunctions arf WITH(NOLOCK) 
				ON af.functionId = arf.functionId AND arf.roleId = @roleId	
			 WHERE af.parentFunctionId = @parentFunctionId 
			 AND arf.functionId IS NOT NULL
		END 
	END
	
	RETURN @str
		
END



GO
