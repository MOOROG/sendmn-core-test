USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_QueryTXNStatus]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --
/*

    EXEC ws_proc_QueryTXNStatus 
    @AGENT_CODE = 'IMEARE01', 
    @USER_ID = 'testapi', @PASSWORD = 'ime@12345',
    @AGENT_SESSION_ID='11223344',
    @PINNO='90408187599'

*/

CREATE proc [dbo].[ws_int_proc_QueryTXNStatus](	 
		@AGENT_CODE			VARCHAR(50),
		@USER_ID			VARCHAR(50),
		@PASSWORD			VARCHAR(50),
		@PINNO				VARCHAR(20),
		@AGENT_SESSION_ID	VARCHAR(150)
)

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY

	DECLARE @apiRequestId BIGINT
INSERT INTO requestApiLogOther(
		 AGENT_CODE			
		,USER_ID 			
		,PASSWORD 			
		,REFNO
		,AGENT_SESSION_ID
		
		,METHOD_NAME
		,REQUEST_DATE


	)
	SELECT
		 @AGENT_CODE				
		,@USER_ID 			
		,@PASSWORD 			
		,@PINNO
		,@AGENT_SESSION_ID
		
		,'ws_int_proc_QueryTXNStatus'
		,GETDATE()


	SET @apiRequestId = SCOPE_IDENTITY()	





DECLARE @errCode INT,@controlNoEnc VARCHAR(50) = dbo.FNAEncryptString(@PINNO)
DECLARE @autMsg	VARCHAR(500)
EXEC ws_int_proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT,@autMsg OUT

DECLARE @errorTable TABLE(
	 AGENT_SESSION_ID VARCHAR(150)
	,PINNO VARCHAR(50)
	,SENDER_NAME VARCHAR(100)
	,RECEIVER_NAME VARCHAR(100)
	,PAYOUTAMT MONEY
	,PAYOUTCURRENCY VARCHAR(3)
	,STATUS VARCHAR(30)
	,STATUS_DATE VARCHAR(20)
)

INSERT INTO @errorTable (AGENT_SESSION_ID,PINNO)
SELECT @AGENT_SESSION_ID,@PINNO

IF (@errCode=1 )
BEGIN
	SELECT '1002' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, *  FROM @errorTable
	RETURN
END

IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USER_ID AND forceChangePwd = 'Y')
BEGIN
	SELECT '1002' CODE, 'You logged on first time,must first change your password and try again!' MESSAGE, * FROM @errorTable
	RETURN
END

------------------VALIDATION-------------------------------
IF @PINNO IS NULL
BEGIN
	SELECT '1001' CODE, 'PINNO Field is Empty' MESSAGE, * FROM @errorTable
	RETURN
END
IF ISNUMERIC(@PINNO) = 0 AND @PINNO IS NOT NULL
BEGIN
	SELECT '9001' CODE, 'Technical Error: PINNO must be numeric' MESSAGE, * FROM @errorTable
	RETURN
END
IF @AGENT_SESSION_ID IS NULL
BEGIN
	SELECT '1001' CODE, 'AGENT SESSION ID Field is Empty' MESSAGE, * FROM @errorTable
	RETURN
END


DECLARE		
	 @pAgent		VARCHAR(50)	
	,@tranId		INT	
	,@tranStatus	VARCHAR(50)	
	,@status		VARCHAR(50)	
	,@txnBranch		INT
	,@txnAgent		INT
	,@sBranch INT
	,@sAgent INT
	
	SELECT 		
		@sBranch = sb.agentId,
		@sAgent = sb.parentId		
	FROM applicationUsers au WITH(NOLOCK) 
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON au.agentId = sb.agentId
	WHERE userName = @USER_ID
		AND ISNULL(sb.isActive,'N') = 'Y'

	SELECT 
		@tranId = id, 
		@tranStatus = tranStatus, 
		@txnAgent = sAgent,
		@txnBranch = sBranch 		
	FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEnc 

	IF @tranStatus IS NULL
	BEGIN
		SELECT '2003' CODE, 'Transaction Not Found PINNO: ' + @PINNO MESSAGE, * FROM @errorTable
		RETURN
	END

	IF @txnAgent <> @sAgent 
	BEGIN
		SELECT '1003' CODE, 'You are not allow to view this transaction' MESSAGE, * FROM @errorTable
		RETURN
	END

	IF @tranStatus IS NOT NULL
	BEGIN
		INSERT INTO tranViewHistory(
			controlNumber
			,tranViewType
			,agentId
			,createdBy
			,createdDate
			,tranId
		)
		SELECT
			@controlNoEnc
			,'View'
			,@sAgent
			,@USER_ID
			,GETDATE()
			,@tranId
	END

	SELECT  
		CODE				= '0',
		AGENT_SESSION_ID	= @AGENT_SESSION_ID,
		MESSAGE				= 'TXN Summary',
		PINNO				= @PINNO,
		SENDER_NAME			= RT.senderName,
		RECEIVER_NAME		= RT.receiverName,
		PAYOUTAMT			= RT.pAmt,
		PAYOUTCURRENCY		= RT.payoutCurr,
		STATUS				= CASE WHEN RT.tranStatus='Payment' THEN 'Un-paid' ELSE RT.tranStatus END,
		STATUS_DATE			= CASE WHEN RT.payStatus='Paid' THEN RT.paidDate WHEN RT.tranStatus='Cancel' THEN RT.cancelApprovedDate END,
		TOKEN_ID			= ''
	FROM remitTran RT WITH(NOLOCK) 
	WHERE RT.id = @tranId
	UNION ALL
	SELECT  
		CODE				= '0' ,
		AGENT_SESSION_ID	= @AGENT_SESSION_ID,
		MESSAGE				= 'TXN Summary',
		PINNO				= @PINNO,
		SENDER_NAME			= RT.senderName,
		RECEIVER_NAME		= RT.receiverName,
		PAYOUTAMT			= RT.pAmt,
		PAYOUTCURRENCY		= RT.payoutCurr,
		STATUS				= CASE WHEN RT.tranStatus='Payment' THEN 'Un-paid' ELSE RT.tranStatus END,
		STATUS_DATE			= CASE WHEN RT.payStatus='Paid' THEN RT.paidDate WHEN RT.tranStatus='Cancel' THEN RT.cancelApprovedDate END,
		TOKEN_ID			= ''
	FROM cancelTranHistory RT WITH(NOLOCK) 
	WHERE RT.tranId = @tranId

UPDATE requestApiLogOther SET 
			errorCode = '0'
		,errorMsg = 'Success'			
	WHERE rowId = @apiRequestId

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRAN
SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, * FROM @errorTable
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error', 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, 'ws_int_proc_QueryTXNStatus', @USER_ID, GETDATE()
END CATCH


GO
