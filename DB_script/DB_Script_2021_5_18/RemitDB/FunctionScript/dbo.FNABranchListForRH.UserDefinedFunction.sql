USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNABranchListForRH]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	SELECT * FROM dbo.FNABranchListForRH('admin') 
*/
CREATE FUNCTION [dbo].[FNABranchListForRH](
	@user VARCHAR(30)
)
RETURNS @listBranch TABLE(agentId INT,mapCodeInt VARCHAR(50))
AS
BEGIN
	DECLARE @userType AS VARCHAR(50),@regionalBranchId AS INT,@agentId AS INT
	SELECT @userType=usertype,@regionalBranchId=agentId FROM applicationUsers with(nolock) WHERE userName=@user
	SELECT @agentId=parentId FROM AgentMaster with(nolock)  WHERE agentId=@regionalBranchId
		
	IF @userType = 'RH'
	BEGIN
		INSERT INTO @listBranch
		SELECT b.agentId branchId,B.mapCodeInt
		FROM (		
			SELECT
				 am.agentId ,am.mapCodeInt
			FROM agentMaster am WITH(NOLOCK)
			INNER JOIN regionalBranchAccessSetup rba with(nolock) ON am.agentId = rba.memberAgentId
			WHERE rba.agentId = @regionalBranchId 
			AND ISNULL(rba.isDeleted, 'N') = 'N'
			AND ISNULL(rba.isActive, 'N') = 'Y'
			AND am.agentType = '2904'
			UNION ALL
			SELECT agentId,mapCodeInt
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @regionalBranchId
			
		) b  
	END
	ELSE IF @userType ='HO'
	BEGIN
		INSERT INTO @listBranch
		SELECT b.agentId branchId,B.mapCodeInt
		FROM agentMaster a WITH(NOLOCK)
		INNER JOIN agentMaster b WITH(NOLOCK) ON  b.parentId = a.agentId
		WHERE ISNULL(b.isDeleted, 'N') <> 'Y'
				AND b.agentType = '2904' 
				AND ISNULL(a.isActive, 'N') = 'Y'
	END
	ELSE IF @userType ='AH'
	BEGIN
		INSERT INTO @listBranch
		SELECT a.agentId branchId,a.mapCodeInt
		FROM agentMaster a WITH(NOLOCK)		
		WHERE ISNULL(a.isDeleted, 'N') <> 'Y'
				AND a.parentId = @agentId 
				AND a.agentType = '2904' 
				AND ISNULL(a.isActive, 'N') = 'Y'
	END
	ELSE
	BEGIN
		INSERT INTO @listBranch
		SELECT agentId ,mapCodeInt
		FROM agentMaster a WITH(NOLOCK) WHERE agentId=@regionalBranchId
	END
	RETURN
END

GO
