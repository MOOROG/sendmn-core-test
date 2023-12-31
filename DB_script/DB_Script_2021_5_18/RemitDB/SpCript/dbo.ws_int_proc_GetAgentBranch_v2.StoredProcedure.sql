USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_GetAgentBranch_v2]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_GetAgentList]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_GetAgentList

GO
*/

--EXEC ws_int_proc_GetAgentBranch_v2  @AGENT_CODE = '1001', @USER_ID = 's_brijan', @PASSWORD = 'karee123', @AGENT_ID = '1', @AGENT_SESSION_ID = '34534534'
--EXEC ws_proc_GetAgentBranch @AGENT_CODE='IMEARE01',@USER_ID='arapi01',@PASSWORD='ime@123123',@LOCATIONID='1533',@AGENT_SESSION_ID='1234567',@PAYMENTTYPE='B',@PAYOUT_COUNTRY='NEPAL'
-- EXEC ws_int_proc_GetAgentBranch_v2  @AGENT_CODE = null, @USER_ID = 's_brijan', @PASSWORD = 'karee123', @AGENT_ID = '1', @AGENT_SESSION_ID = '34534534'


CREATE proc [dbo].[ws_int_proc_GetAgentBranch_v2]
	@AGENT_CODE			VARCHAR(50),
	@USER_ID			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(50),
	@AGENT_ID			VARCHAR(50)
AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	DECLARE @errCode INT
	DECLARE @autMsg	VARCHAR(500)

	
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
		
	DECLARE @PAYMODE VARCHAR(50), @PAYOUT_COUNTRY VARCHAR(50), @pcountryId INT, @pCurr VARCHAR(5), @countryId INT, @agentId INT, @branchId INT,@agent VARCHAR(500)

	SELECT 
		 @countryId = au.countryId
		,@branchId = au.agentId 
		,@agentId = am.parentId
	FROM applicationUsers au WITH(NOLOCK) 
	LEFT JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
	WHERE au.userName = @USER_ID AND ISNULL(au.isDeleted, 'N') = 'N'


	
	SELECT 
		@PAYOUT_COUNTRY = agentCountry, @pcountryId = agentCountryId 
	FROM agentMaster WITH(NOLOCK) WHERE mapCodeInt= @AGENT_ID
	
	IF @PAYOUT_COUNTRY IS NULL
		SELECT @PAYOUT_COUNTRY = country FROM externalBank WHERE externalCode = @AGENT_ID 
	
	--------------------------------------------------------------------------------------
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


	IF @AGENT_ID = '2054'
	BEGIN

		INSERT INTO #tempResult(LOCATIONID, AGENT, BRANCH, ADDRESS, CITY, BANKID)
		SELECT 
			 mapcodeint
			,agentName
			,agentAddress
			,''
			,agentCity    = ISNULL(agentCity,'') 
			,extCode    = ISNULL(extCode, '') 
		FROM agentMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') = 'N'
		AND agentType = '2904'
		AND parentId =  @AGENT_ID 

		SELECT @agent=AGENTNAME FROM AGENTMASTER WHERE AGENTID=@AGENT_ID
      
	END
	ELSE IF @AGENT_ID <> '2054'
	BEGIN
		INSERT INTO #tempResult(LOCATIONID, AGENT, BRANCH, ADDRESS, CITY, BANKID)
		SELECT 
				 EB.mapcodeint
				,agent = bankname
				,agentName   = branchName
				,agentAddress  = EBB.address
				,agentCity   = ISNULL(city, '')
				,extCode   = ISNULL(EBB.externalCode, '')
		FROM externalBankBranch EBB WITH(NOLOCK)
		INNER JOIN externalbank EB WITH(NOLOCK) ON EBB.extBankId=EB.extBankId
		WHERE ISNULL(EBB.isDeleted, 'N') = 'N'
		AND EBB.extBankId = @AGENT_ID 

		SELECT @agent=BankName FROM externalbank WHERE extBankId=@AGENT_ID
  
	END
	
	SELECT @agent AGENT_ID
			,CODE					= '0' 
			,AGENT_SESSION_ID		= @AGENT_SESSION_ID 
			,MESSAGE				= 'Success'
			,CURRENCY				= @pCurr

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
		 AGENT_ID				= NULL 
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
