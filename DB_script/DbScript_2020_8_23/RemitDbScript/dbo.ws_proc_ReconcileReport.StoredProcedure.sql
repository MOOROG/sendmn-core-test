USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_ReconcileReport]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ws_proc_ReconcileReport] (	 
	@ACCESSCODE			VARCHAR(50),
	@USERNAME			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(150),	
	@PAID_DATE			VARCHAR(50)	
)

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	

DECLARE @errCode INT
DECLARE @autMsg	VARCHAR(500)

EXEC ws_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT, @autMsg OUT

DECLARE @errorTable TABLE (
	 CODE VARCHAR(150)
	,MESSAGE VARCHAR(200)
	,AGENT_SESSION_ID VARCHAR(50)
	,PAID_DATE VARCHAR(10)
	,PAYOUT_AMT MONEY
	,PAYOUT_CCY VARCHAR(20)
	,RECEIVER_NAME VARCHAR(10)
	,REFNO VARCHAR(10)
	,SENDER_NAME VARCHAR(10)
	,TRAN_TYPE VARCHAR(10)
)

INSERT INTO @errorTable(AGENT_SESSION_ID) SELECT @AGENT_SESSION_ID

IF (@errCode = 1)
BEGIN
	SELECT
		'1002' CODE
		,ISNULL(@autMsg,'Authentication Fail') MESSAGE
		,* 
	FROM @errorTable
	RETURN
END
IF EXISTS(
	SELECT 'x' FROM applicationUsers WITH (NOLOCK) 
	WHERE userName = @USERNAME AND forceChangePwd = 'Y')
BEGIN
	SELECT 
		'1002' CODE
		,'You are required to change your password!' MESSAGE
		,* 
	FROM @errorTable
	RETURN
END
------------------VALIDATION-------------------------------
IF @AGENT_SESSION_ID IS NULL
BEGIN
	SELECT 
		'1001' CODE
		,'AGENT SESSION ID Field is Required' MESSAGE
		,* 
	FROM @errorTable
	RETURN;
END

IF  @PAID_DATE IS NULL
BEGIN
	SELECT 
		'1001' CODE
		,'PAID DATE Field is Required' MESSAGE
		,* 
	FROM @errorTable
	RETURN;
END
IF ISDATE(@PAID_DATE) = 0 
BEGIN
	SELECT 
		'1001' CODE
		,'PAID DATE Field is Invalid' MESSAGE
		,* 
	FROM @errorTable
	RETURN;
END

	
DECLARE		
	 @pCountryId		INT
	,@pAgent			INT
	,@pAgentMapCode		VARCHAR(10)
	,@pBranch			INT
	,@pBranchMapCode	VARCHAR(10)
	,@tranId			INT
	,@tranStatus		VARCHAR(50)

-- PICK AGENTID ,COUNTRY FROM USER
SELECT 
	@pCountryId = countryId,
	@pBranch = agentId 
FROM applicationUsers WITH(NOLOCK)
WHERE userName = @USERNAME AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'

SELECT @pAgent = parentId, @pBranchMapCode = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
SELECT @pAgentMapCode = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent

DECLARE @controlNoTable TABLE(controlNo VARCHAR(50))

INSERT INTO @controlNoTable(controlNo)
SELECT controlNo FROM remitTran WITH(NOLOCK) 
WHERE pAgent = @pAgent AND payStatus = 'Paid' AND tranStatus = 'Paid' AND paidDateLocal BETWEEN @PAID_DATE AND CONVERT(VARCHAR, @PAID_DATE,101) + ' 23:59:59.99'


--AND paymentMethod = 'Bank Deposit'

IF NOT EXISTS(SELECT TOP 1 'X' FROM @controlNoTable)
BEGIN
	SELECT '2003' CODE, 'No transaction found to download' [Message], * FROM @errorTable
	RETURN
END




SELECT 
	CODE				= 0,
	AGENT_SESSION_ID	= @AGENT_SESSION_ID,
	MESSAGE				= 'Success',
	PAID_DATE			= RT.paidDateLocal,
	PAYOUT_AMT			= RT.pAmt,
	PAYOUT_CCY			= RT.payoutCurr,
	RECEIVER_NAME		= RT.receiverName,
	REFNO				= dbo.FNADecryptString(RT.controlNo),
	SENDER_NAME			= RT.senderName,
	TRAN_TYPE			= RT.paymentMethod
 FROM remitTran RT WITH (NOLOCK)  
 INNER JOIN @controlNoTable cn ON cn.controlNo = RT.controlNo




END TRY
BEGIN CATCH

SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'[ws_proc_ReconcileReport]',@USERNAME, GETDATE()

END CATCH

/*

EXEC ws_proc_ReconcileReport @ACCESSCODE='IMENPADB001',@USERNAME='adbramshah123',@PASSWORD='adbramshah1231',@AGENT_SESSION_ID='4397693869386',@PAID_DATE='2015-09-24'

*/
GO
