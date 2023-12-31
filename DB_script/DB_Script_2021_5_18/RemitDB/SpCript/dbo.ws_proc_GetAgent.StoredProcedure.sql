USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_GetAgent]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_proc_GetAgent]
	@AGENT_CODE			VARCHAR(50),
	@USER_ID			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(50),
	@PAYMENT_TYPE		CHAR(1),
	@PAYOUT_COUNTRY		VARCHAR(50)
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
		,AGENT VARCHAR(150)
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
	IF @PAYMENT_TYPE IS NULL
	BEGIN
		SELECT '1001' CODE, 'PAYMENT TYPE Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @PAYOUT_COUNTRY IS NULL
	BEGIN
		SELECT '1001' CODE,'PAYOUT COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @PAYOUT_COUNTRY <> 'NEPAL'
	BEGIN
		SELECT '1001' CODE,'Invalid PAYOUT COUNTRY Field' MESSAGE, * FROM @errorTable
		RETURN;
	END

	IF @PAYMENT_TYPE NOT IN('C','B')
	BEGIN
		SELECT '3001' CODE, 'Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank' MESSAGE, * FROM @errorTable
		RETURN
	END

	----DECLARE @PAYMENTMODE CHAR(1) = 'D',@PAYOUT_COUNTRY VARCHAR(100)='BANGLADESH'
	DECLARE @PAYMODE VARCHAR(50),@pcountryId VARCHAR(10),@pCurr VARCHAR(5), @countryId INT, @agentId INT, @branchId INT

	SELECT
		 @countryId = au.countryId
		,@branchId = au.agentId
		,@agentId = am.parentId
	FROM applicationUsers au WITH(NOLOCK)
	LEFT JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
	WHERE au.userName = @USER_ID AND ISNULL(au.isDeleted, 'N') = 'N'

	SELECT @pcountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @PAYOUT_COUNTRY

	SELECT 
		@pCurr = currencyCode 
	FROM currencyMaster C WITH (NOLOCK)
	INNER JOIN countryCurrency CC WITH (NOLOCK) ON C.currencyId = CC.currencyId
	WHERE CC.countryId = @pcountryId 
		AND ISNULL(C.isActive,'Y') = 'Y' 
		AND ISNULL(C.isDeleted,'N') = 'N'
		AND ISNULL(CC.isActive,'Y') = 'Y' 
		AND ISNULL(CC.isDeleted,'N') = 'N'

	SET @PAYMODE = CASE WHEN @PAYMENT_TYPE = 'B' THEN 'Bank Deposit'
						WHEN @PAYMENT_TYPE = 'C' THEN 'Cash Payment'
					END
	DECLARE	@serviceTypeId INT

	SELECT @serviceTypeId = serviceTypeId FROM serviceTypeMaster WITH (NOLOCK) WHERE typeTitle = @PAYMODE AND ISNULL(isDeleted, 'N') = 'N'

	IF NOT EXISTS(SELECT 'X' FROM countryReceivingMode WITH(NOLOCK) WHERE countryId = @pcountryId)
	BEGIN
		SELECT '5001' CODE, 'You are not allowed to sent to country ' + @PAYOUT_COUNTRY MESSAGE, * FROM @errorTable
		RETURN;
	END

	------------------END VALIDATION-------------------------------
	
	DECLARE @tempResult TABLE(
		 LOCATIONID VARCHAR(50)
		,AGENT VARCHAR(200)		
		,ADDRESS VARCHAR(300)
		,CITY VARCHAR(200)
		,CURRENCY VARCHAR(5)
		,BANKID VARCHAR(350)
		,EXT_BANK_BRANCH_ID VARCHAR(300)
	)

	INSERT INTO @tempResult(LOCATIONID, AGENT, ADDRESS)
	SELECT
		AGENTID,AGENTNAME,ADDRESS
	FROM
	(
		SELECT
				 AGENTID	= extBankId
				,AGENTNAME  = UPPER(bankName)
				,ADDRESS	= ADDRESS
		FROM externalBank EB WITH (NOLOCK) ,
		(
			SELECT maxLimitAmt FROM receiveTranLimit RTL WITH (NOLOCK)  
			WHERE RTL.countryId = @pcountryId
			AND ISNULL(RTL.isActive, 'N') = 'Y'
			AND ISNULL(RTL.isDeleted, 'N') = 'N'
			AND ISNULL(RTL.TRANTYPE, ISNULL(@serviceTypeId, 0)) = ISNULL(@serviceTypeId, 0) 
			AND RTL.agentId IS NULL
		) X
		WHERE EB.COUNTRY = (SELECT countryName FROM countryMaster with(nolock) WHERE countryId = @pcountryId) 
		--AND extBankId <> 90037
		AND ISNULL(receivingMode, ISNULL(@serviceTypeId, 0)) = ISNULL(@serviceTypeId, 0) 

		--UNION ALL
	
		--SELECT AGENTID  = '2054'
		--	,AGENTNAME  = 'GLOBAL IME BANK LIMITED'
		--	,ADDRESS = 'NEPAL'
	)X

	IF EXISTS(SELECT 'X' FROM @TempResult)
		BEGIN
			SELECT 
				 CODE				= '0' 
				,AGENT_SESSION_ID	= @AGENT_SESSION_ID 
				,MESSAGE			= 'Success'			
				,AGENT_ID			= LOCATIONID			
				,AGENT_NAME			= AGENT		
				,ADDRESS			= ADDRESS		
				,CITY				= CITY		 
				,CURRENCY			= currency	
			FROM @TempResult 
			ORDER BY AGENT
		END
		ELSE
		BEGIN
			SELECT 
				 CODE				= '5001'
				,AGENT_SESSION_ID	= @AGENT_SESSION_ID
				,MESSAGE			= 'Location Not Found'
				,AGENT_ID			= NULL
				,AGENT_NAME			= NULL
				,ADDRESS			= NULL
				,CITY				= NULL
				,CURRENCY			= NULL
		END  
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN

	SELECT 
		 CODE				= '9001'
		,AGENT_SESSION_ID	= @AGENT_SESSION_ID
		,MESSAGE			= 'Technical Error : ' + ERROR_MESSAGE()
		,AGENT_ID			= NULL
		,AGENT_NAME			= NULL
		,ADDRESS			= NULL
		,CITY				= NULL
		,CURRENCY			= NULL

	INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
	SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_GetAgent',@USER_ID, GETDATE()
END CATCH



GO
