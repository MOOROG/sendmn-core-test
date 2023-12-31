USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_GetAgentBranch]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_GetAgentList]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_GetAgentList

GO
*/
--EXEC ws_int_proc_GetAgentBranch @AGENT_CODE='IMEQAUAE001',@USER_ID='testuser',@PASSWORD='test@user',@AGENT_SESSION_ID='1234567', @AGENT_ID =90001

CREATE PROC [dbo].[ws_int_proc_GetAgentBranch]
	@AGENT_CODE			VARCHAR(50),
	@USER_ID			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(50),
	@AGENT_ID			VARCHAR(50)
AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	DECLARE @errCode	INT
		, @autMsg		VARCHAR(500)
		, @agentName	varchar(500)
		, @mapCodeInt	varchar(50)
		, @parentId		INT

	
	EXEC ws_int_proc_checkAuthntication @USER_ID, @PASSWORD, @AGENT_CODE, @errCode OUT, @autMsg OUT

	DECLARE @errorTable TABLE(
		 AGENT_SESSION_ID VARCHAR(150)
		,LOCATIONID MONEY
		,AGENT_ID VARCHAR(150)
		,BRANCH VARCHAR(150)
		,ADDRESS VARCHAR(150)
		,CITY VARCHAR(150)
		,CURRENCY VARCHAR(150)
		,BANKID VARCHAR(150)
	)

	INSERT INTO @errorTable(AGENT_SESSION_ID) 
	SELECT @AGENT_SESSION_ID

	IF @errCode = 1
	BEGIN
		SELECT '1002' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, * FROM @errorTable
		RETURN;
	END

	IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USER_ID AND forceChangePwd = 'Y')
	BEGIN
		SELECT '1002' CODE, 'You logged on first time,must first change your password and try again!' MESSAGE, * FROM @errorTable
		RETURN;
	END
	------------------VALIDATION-------------------------------
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT SESSION ID Field is Empty' MESSAGE, AGENT_SESSION_ID = @AGENT_SESSION_ID, * FROM @errorTable
		RETURN;
	END
	
	IF @AGENT_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END

	SELECT @parentId = parentId FROM dbo.agentMaster WHERE agentId = @AGENT_ID

	IF EXISTS (SELECT 'X' FROM dbo.agentMaster WHERE agentId = @AGENT_ID AND ISNULL(IsIntl, 0) = 0)
	BEGIN
		SELECT '1021' CODE, 'Invalid BANK ID' MESSAGE, * FROM @errorTable
		RETURN;
	END

	CREATE  TABLE #tempResult(
		 LOCATIONID VARCHAR(50)
		,AGENT VARCHAR(200)
		,BRANCH VARCHAR(200)
		,ADDRESS VARCHAR(300)
		,CITY VARCHAR(200)
		,CURRENCY VARCHAR(5)
		,BANKID VARCHAR(350)
		,EXT_BANK_BRANCH_ID VARCHAR(300)
	)
	
	--SELECT 
	--	@mapCodeInt = mapCodeInt,@agentName = BankName 
	--from externalbank with(nolock) where extBankId=@AGENT_ID
	--SELECT @parentId = agentId FROM agentMaster am with(nolock) WHERE mapCodeInt = @mapCodeInt

	--INSERT INTO #tempResult(LOCATIONID, AGENT, BRANCH, ADDRESS, CITY, BANKID)
	--SELECT			 
	--	 mapCodeInt = ebb.extBranchId
	--	,agent = @agentName
	--	,agentName = branchName
	--	,agentAddress = ebb.address 
	--	,agentCity = ebb.city 
	--	,extCode = ebb.extBranchId --am.mapCodeInt
	--FROM externalBankBranch ebb WITH(NOLOCK) 
	--WHERE ebb.extBankId = @AGENT_ID 
	--AND ISNULL(ebb.isBlocked, 'N') = 'N' 
	--AND ISNULL(ebb.isDeleted, 'N') = 'N'
	
	INSERT INTO #tempResult(LOCATIONID, AGENT, BRANCH, ADDRESS, CITY, BANKID)
	SELECT			 
		 mapCodeInt = AM.mapCodeInt
		,agent = @agentName
		,agentName = AM.agentName
		,agentAddress = AM.agentAddress 
		,agentCity = AM.agentCity 
		,extCode = AM.mapCodeInt --am.mapCodeInt
	FROM dbo.agentMaster AM WITH(NOLOCK) 
	WHERE AM.parentId = @AGENT_ID 
	AND AM.agentType = '2904'
	AND ISNULL(AM.isActive, 'Y') = 'Y' 
	AND ISNULL(AM.isDeleted, 'N') = 'N'

	SELECT   @AGENT_ID				AGENT_ID
			,CODE					= '0' 
			,AGENT_SESSION_ID		= @AGENT_SESSION_ID 
			,MESSAGE				= 'Success'
			,CURRENCY				= 'NPR'

	IF EXISTS(SELECT 'X' FROM #TempResult)
	BEGIN
		SELECT 
			 LOCATIONID				= LOCATIONID
			,AGENT					= AGENT
			,BRANCH					= BRANCH		
			,ADDRESS				= ADDRESS		
			,CITY					= CITY		 
			,BANK_ID				= BANKID	
			,EXT_BANK_BRANCH_ID		= EXT_BANK_BRANCH_ID			
		FROM #TempResult 
		ORDER BY AGENT
	END
	ELSE
	BEGIN
		SELECT 
			 BRANCH					= NULL
			,ADDRESS				= NULL
			,CITY					= NULL
			,BANK_ID				= NULL
			,EXT_BANK_BRANCH_ID		= NULL
	END  

END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
	ROLLBACK TRAN

	SELECT
		 AGENT_ID				= @AGENT_ID 
		,CODE					= '1' 
		,AGENT_SESSION_ID		= @AGENT_SESSION_ID 
		,MESSAGE				= 'Technical Error : ' + ERROR_MESSAGE()	

	SELECT 
		 BRANCH					= NULL
		,ADDRESS				= NULL
		,CITY					= NULL
		,BANK_ID				= NULL
		,EXT_BANK_BRANCH_ID		= NULL

	INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
	SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_GetAgentBranch', @USER_ID, GETDATE()

END CATCH

GO
