USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_extBankMigrate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	SELECT * FROM TEMP_INT_AGENT WHERE agentCode = 33300366
	SELECT * FROM TEMP_INT_BRANCH WHERE agentCode = 33300366
	SELECT * FROM TEMP_INT_BRANCH WHERE agent_branch_Code = 33422891
*/

--EXEC proc_extBankMigrate @flag = 'i', @mapCodeInt = '33300366'
CREATE procEDURE [dbo].[proc_extBankMigrate]
	 @flag			VARCHAR(50)		= NULL
	,@mapCodeInt	VARCHAR(30)		= NULL
AS
SET NOCOUNT ON

IF @flag = 'i'
BEGIN
	DECLARE @agentId INT, @agentName VARCHAR(200)
	IF EXISTS(SELECT 'X' FROM agentMaster WITH(NOLOCK) WHERE mapCodeInt = @mapCodeInt)
	BEGIN
		EXEC proc_errorHandler 1, 'Record already exist', NULL
		RETURN
	END
	INSERT INTO agentMaster(
		 agentType,agentName,mapCodeInt
		,agentAddress,agentCountry,agentCountryId
		,agentPhone1,agentFax1
		,isActive,createdBy,createdDate)
	SELECT 
		 2905,companyName,agentCode
		,[Address],country,151
		,Phone1,Fax
		,'Y','admin',GETDATE() 
	FROM TEMP_INT_AGENT WITH(NOLOCK) WHERE agentCode = @mapCodeInt
	
	SET @agentId = SCOPE_IDENTITY()
	SELECT @agentName = companyName FROM TEMP_INT_AGENT WITH(NOLOCK) WHERE agentCode = @mapCodeInt
	
	INSERT INTO agentMaster(
		 parentId,agentType,agentName,mapCodeInt
		,agentAddress,agentCountry,agentCountryId
		,agentPhone1,agentFax1
		,isActive,createdBy,createdDate)
	SELECT 
		 @agentId,2906,@agentName + ' - ' + branch,agent_branch_code
		,branch,country,151
		,Telephone,Fax
		,'Y','admin',GETDATE() 
	FROM TEMP_INT_BRANCH WHERE agentCode = @mapCodeInt
END
	

GO
