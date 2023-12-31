USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAAgentUserListForCH]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	SELECT * FROM dbo.FNAAgentUserListForCH('test') x
*/
CREATE FUNCTION [dbo].[FNAAgentUserListForCH](
	@userName VARCHAR(30)
)
RETURNS @agentUserList TABLE(agentId INT, userId INT, userName VARCHAR(30))
AS
BEGIN
	IF EXISTS(SELECt 'x' FROM applicationUsers WHERE userName = @userName AND userType = 'CH')
	BEGIN
		;WITH agentList AS (
			SELECT DISTINCT
				 agm.agentId	 
			FROM agentGroupMaping agm WITH(NOLOCK)
			INNER JOIN userGroupMapping ugm WITH(NOLOCK) ON agm.groupDetail = ugm.groupDetail 
				AND ISNULL(ugm.isDeleted, 'N') <> 'Y'
				AND ISNULL(agm.isDeleted, 'N') <> 'Y'
			WHERE ugm.userName = @userName	
			UNION ALL
			SELECT 
				am.agentId
			FROM agentMaster am WITH(NOLOCK)
			INNER JOIN agentList al ON al.agentId = am.parentId 
			AND am.parentId IS NOT NULL
			AND ISNULL(am.isDeleted, 'N') <> 'Y'
		)
		INSERT @agentUserList
		SELECT DISTINCT
			 al.agentId 
			,au.userId 
			,au.userName	
		FROM agentList al
		LEFT JOIN applicationUsers au WITH(NOLOCK) ON au.agentId = al.agentId 
		ORDER BY al.agentId 
		
		OPTION (MAXRECURSION 1000);
	END
	
	RETURN
END

GO
