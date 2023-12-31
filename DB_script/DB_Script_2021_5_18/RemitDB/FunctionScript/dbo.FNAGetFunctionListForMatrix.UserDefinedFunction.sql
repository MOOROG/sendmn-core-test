USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetFunctionListForMatrix]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		
        
CREATE FUNCTION [dbo].[FNAGetFunctionListForMatrix](
	 @parentFunctionId	INT	
	,@userName			VARCHAR(30)
)  
RETURNS VARCHAR(MAX)
AS  
BEGIN
	DECLARE @str VARCHAR(MAX)	
	
	SELECT
		@str = ISNULL(@str + '<br />', '') 
		+ '<input type = "checkbox" disabled = "disabled"'
		+ ' value = "'				+ CAST(af.functionId AS VARCHAR) + '"'
		+ ' id = "chk_'				+ CAST(af.functionId AS VARCHAR) + '"'
		+ ' name = "function_id"'			
		+ CASE WHEN (x.functionId IS NOT NULL OR auf.functionId IS NOT NULL) THEN ' checked = "checked" ' ELSE '' END
		+ '> <label class = "rights" for = "chk_'	+ CAST(af.functionId AS VARCHAR) + '">' + functionName + '</label>'
	 FROM applicationFunctions af WITH(NOLOCK)
	 LEFT JOIN applicationUserFunctions auf WITH(NOLOCK) 
		ON af.functionId = auf.functionId AND auf.[userName] = @userName		
	 LEFT JOIN (			
				SELECT DISTINCT
					arf.functionId [functionId]
				FROM applicationRoleFunctions arf WITH(NOLOCK)
				WHERE roleId IN (SELECT roleId FROM applicationUserRoles WHERE [userName] = @userName)
				
	)x ON af.functionId = x.functionId		 
	 
	 WHERE af.parentFunctionId = @parentFunctionId
		
	RETURN @str
		
END



GO
