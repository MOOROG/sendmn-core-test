USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCriteriaList]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		
/*

csCriteriaHistory
*/   
CREATE FUNCTION [dbo].[FNAGetCriteriaList](
	 @csDetailId		INT	
	,@user				VARCHAR(30)
)  
RETURNS VARCHAR(MAX)
AS  
BEGIN
	DECLARE @str VARCHAR(MAX)
	--DECLARE @criteriaList TABLE(criteriaId INT, criteriaName VARCHAR(250))
	--INSERT @criteriaList(criteriaId, criteriaName)
	--SELECT valueId, detailTitle FROM staticDataValue WHERE typeID = 5000	

	IF EXISTS(SELECT 'X' FROM csCriteriaHistory WITH(NOLOCK) WHERE csDetailId = @csDetailId AND @user = createdBy)
	BEGIN		
		--SELECT
		--	@str = ISNULL(@str + '', '')			
		--	+ '<span class = "frmLableBold" id = "spn_'  + CAST(cl.criteriaId AS VARCHAR) + '">'
		--	+ '<input type = "checkbox"'
		--	+ ' value = "'				+ CAST(cl.criteriaId AS VARCHAR) + '"'
		--	+ ' id = "chk_'				+ CAST(cl.criteriaId AS VARCHAR) + '"'
		--	+ ' name = "criteriaId"'
		--	+ CASE WHEN cs.criteriaId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
		--	+ '><label for = "chk_'	+ CAST(cl.criteriaId AS VARCHAR) + '">' + cl.criteriaName + '</label>'
		--	+ '</span>'
		-- FROM @criteriaList cl 
		-- LEFT JOIN csCriteriaHistory cs WITH(NOLOCK) ON cl.criteriaId = cs.criteriaId
		--	AND cs.csDetailId = @csDetailId	
		
		SELECT
			@str = ISNULL(@str + ',', '') + CAST(cs.criteriaId AS VARCHAR)			
		 FROM csCriteriaHistory cs WITH(NOLOCK) 
		 WHERE cs.csDetailId = @csDetailId	
		
	END
	ELSE
	BEGIN
		--SELECT
		--	@str = ISNULL(@str + '', '')
		--	+ '<span class = "frmLableBold" id = "spn_'  + CAST(cl.criteriaId AS VARCHAR) + '">'
		--	+ '<input type = "checkbox"'
		--	+ ' value = "'				+ CAST(cl.criteriaId AS VARCHAR) + '"'
		--	+ ' id = "chk_'				+ CAST(cl.criteriaId AS VARCHAR) + '"'
		--	+ ' name = "criteriaId"'
		--	+ CASE WHEN cs.criteriaId IS NOT NULL THEN ' checked = "checked" ' ELSE '' END
		--	+ '><label for = "chk_'	+ CAST(cl.criteriaId AS VARCHAR) + '">' + cl.criteriaName + '</label>'
		--	+ '</span>'
		-- FROM @criteriaList cl 
		-- LEFT JOIN csCriteria cs WITH(NOLOCK) ON cl.criteriaId = cs.criteriaId
		--	AND cs.csDetailId = @csDetailId	
		
		SELECT
			@str = ISNULL(@str + ',', '') + CAST(cs.criteriaId AS VARCHAR)			
		FROM csCriteria cs WITH(NOLOCK) 
		WHERE cs.csDetailId = @csDetailId		
	END
	RETURN @str
END	
GO
