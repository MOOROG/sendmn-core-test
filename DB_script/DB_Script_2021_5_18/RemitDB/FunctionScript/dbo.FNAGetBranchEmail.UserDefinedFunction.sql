USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetBranchEmail]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetBranchEmail](@branchId INT,@user VARCHAR(50))  
RETURNS VARCHAR(100) AS  
BEGIN

	DECLARE  @email VARCHAR(100),@email1 VARCHAR(100),@email2 VARCHAR(100),@agentId INT
	SELECT 
	     @email = a.agentEmail1
		,@email1 = a.agentEmail2
		,@email2 = cpEmail
		,@agentId = parentId
	FROM agentMaster a WITH(NOLOCK) 
	     INNER JOIN applicationUsers b WITH(NOLOCK) ON a.agentId=b.agentId
	WHERE b.userName = @user

	IF @email IS NULL OR @email = ''
		SET @email = @email1

	IF @email IS NULL OR @email = ''
		SET @email = @email2

	IF @email IS NULL OR @email = ''
	BEGIN
		SELECT @email = ISNULL(a.agentEmail1,a.agentEmail2) 
		FROM agentMaster a WITH(NOLOCK)	WHERE agentId = @agentId
	END

	DECLARE @rhEmail VARCHAR(MAX)= NULL
	SELECT  @rhEmail = RTRIM(CAST(email AS VARCHAR(200)))+';' + ISNULL(@rhEmail, '')  
	FROM applicationusers a WITH(NOLOCK) 
	INNER JOIN
	(
		SELECT agentId FROM regionalBranchAccessSetup WITH(NOLOCK) WHERE memberAgentId = @branchId
	) b ON a.agentId= b.agentId
	AND userType = 'RH'

	IF @email IS NULL
		SET @email = 'info@gmeremit.com' 
	 
	IF @rhEmail IS NOT NULL AND @rhEmail <> ''
		SET @email = RTRIM(CAST(@email AS VARCHAR(200)))+';' + ISNULL(@rhEmail, '') 

	RETURN @email
END





GO
