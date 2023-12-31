USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_GetStatusByTxnRefId]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_GetStatus]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_GetStatus

GO 
*/
 /*

EXEC ws_int_proc_GetStatus   
 @ACCESSCODE = 'MF1986', 
 @USERNAME = 'imetest', 
 @PASSWORD = 'ime@1111', 
 @TXN_REF_ID = '30137052786',
  @AGENT_TXN_REF_ID = '3563'

  SELECT	
	 id
	,tranStatus
	,pCountry
	,pAgent
	,pbranch
FROM remitTran WITH (NOLOCK) 
WHERE controlNo = dbo.FNAENcryptString('99991867251') 


SELECT 
	au.agentId 
	,cm.countryName
FROM applicationUsers au WITH(NOLOCK)
INNER JOIN countryMaster cm WITH(NOLOCK) ON au.countryId = cm.countryId
WHERE userName = 'testdhaka'

SELECT * FROM agentMaster where agentID = 2236 OR agentId = 1023
 
*/
 
CREATE PROC [dbo].[ws_int_proc_GetStatusByTxnRefId] (	 
	@ACCESSCODE		VARCHAR(50),
	@USERNAME		VARCHAR(50),
	@PASSWORD		VARCHAR(50),
	@TXN_REF_ID			VARCHAR(20),
	@AGENT_TXN_REF_ID  VARCHAR(150)
)

AS

SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE @apiRequestId BIGINT
	INSERT INTO requestApiLogOther(
		 AGENT_CODE			
		,USER_ID 			
		,PASSWORD 			
		,AGENT_TXN_REF_ID
		,REFNO
		,METHOD_NAME
		,REQUEST_DATE
		
	)
	SELECT
		 @ACCESSCODE				
		,@USERNAME 			
		,@PASSWORD 			
		,@AGENT_TXN_REF_ID
		,@TXN_REF_ID
		,'ws_int_proc_GetStatusByTxnRefId'
		,GETDATE()
	
	SET @apiRequestId = SCOPE_IDENTITY()		


	

DECLARE @errCode INT,@controlNoEnc VARCHAR(50) = dbo.FNAENcryptString(@TXN_REF_ID)
DECLARE @autMsg	VARCHAR(500)
EXEC ws_int_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT, @autMsg OUT

 DECLARE @errorTable TABLE(
	 AGENT_REFID  VARCHAR(150)
	,REFID VARCHAR(50)
	,SENDER_NAME VARCHAR(100)
	,RECEIVER_NAME VARCHAR(100)
	,PAYOUTAMT MONEY
	,PAYOUTCURRENCY VARCHAR(3)
	,STATUS VARCHAR(30)
	,STATUS_DATE VARCHAR(20)
	,TOKEN_ID INT
)

INSERT INTO @errorTable(AGENT_REFID) 
SELECT @AGENT_TXN_REF_ID

IF (@errCode='1' )
BEGIN
	SELECT 	'102' CODE,ISNULL(@autMsg,'Authentication Fail') MESSAGE	,* FROM @errorTable
	RETURN
END
IF EXISTS(
	SELECT 'x' FROM applicationUsers WITH (NOLOCK) 
	WHERE userName = @USERNAME 
		AND forceChangePwd = 'Y'
)
BEGIN
	SELECT 
		 '102' CODE,'You logged on first time,must first change your password and try again!' MESSAGE,* 	FROM @errorTable
	RETURN
END
------------------VALIDATION-------------------------------
IF @TXN_REF_ID IS NULL
BEGIN
	SELECT 
		'102' CODE,'REFNO Field is Empty' MESSAGE,* FROM @errorTable
	RETURN;
END
IF ISNUMERIC(@TXN_REF_ID) = 0 AND @TXN_REF_ID IS NOT NULL
BEGIN
	SELECT 
		'9001' CODE,'Technical Error: REFNO must be numeric' MESSAGE	,* FROM @errorTable
	RETURN;
END
IF @AGENT_TXN_REF_ID IS NULL
BEGIN
	SELECT 
		'102' CODE,'AGENT SESSION ID Field is Empty' MESSAGE,* FROM @errorTable
	RETURN;
END

DECLARE		
	 
	 @tranId		BIGINT	
	,@tranStatus	VARCHAR(50)	
	,@status		VARCHAR(50)	
	,@txnBranch		INT
	,@txnAgent		INT
	,@sBranch INT
	,@sAgent INT
	
	SELECT 		
		@sBranch = sb.agentId,
		@sAgent = sb.parentId 
	FROM applicationUsers  au WITH(NOLOCK) 
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON au.agentId = sb.agentId
	WHERE userName = @USERNAME
		AND ISNULL(sb.isActive,'N') = 'Y'
	


--SELECT * INTO #tempAcTrn FROM ime_plus_02.dbo.moneySend WITH(NOLOCK) WHERE refno = @controlNoEnc


--SELECT	
--	 @tranId		= Tranno
--	,@tranStatus	= TransStatus
--	,@pCountry		= ReceiverCountry
--	,@pAgentTran	= receiveAgentID
--	,@paidBy		= paidBy
--	,@status		= STATUS
--FROM #tempAcTrn WITH (NOLOCK) 
--WHERE refno = @controlNoEnc 

SELECT	
	 @tranId		= id
	,@tranStatus	= tranStatus
	,@txnBranch		= sBranch
	,@txnAgent		= sAgent	
	,@status		= payStatus
	
FROM remitTran WITH (NOLOCK) 
WHERE controlNo2 = @controlNoEnc 



IF @tranStatus IS NULL
BEGIN
	SELECT '203' CODE,'Transaction Not Found RefNo: '+ @TXN_REF_ID MESSAGE,* FROM @errorTable
	RETURN
END

IF @sAgent <> @txnAgent
BEGIN
	SELECT '100' CODE,'You are not authorized to view this transaction' MESSAGE,* FROM @errorTable
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
		,'VIEW'
		,@sAgent
		,@USERNAME
		,GETDATE()
		,@tranId

END

--SELECT 
--	CODE				= 0,
--	AGENT_TXN_REF_ID	= @AGENT_TXN_REF_ID ,
--	MESSAGE				= 'TXN Summary'	,
--	REFNO				= @TXN_REF_ID	,
--	SENDER_NAME			= RT.SenderName ,
--	RECEIVER_NAME		= RT.ReceiverName ,
--	PAYOUTAMT			= RT.TotalRoundAmt ,
--	PAYOUTCURRENCY		= RT.receiveCType ,
--	STATUS				= CASE WHEN RT.lock_status='locked' THEN 'locked' 
--							WHEN RT.status='paid' THEN 'paid' 
--							ELSE 
--								CASE WHEN RT.TransStatus='Payment' THEN 'Un-paid' ELSE RT.TransStatus END  
--							END,
--	STATUS_DATE			= CASE WHEN RT.status='Paid' THEN RT.paidDate WHEN RT.transStatus='Cancel' THEN RT.cancel_date END,
--	PAY_TOKEN_ID		= txn_token_id
-- FROM #tempAcTrn RT WITH (NOLOCK) 
-- WHERE RT.Tranno = @tranId
 
 



SELECT 
	 Code				= '0'
	,AGENT_REFID		= @AGENT_TXN_REF_ID
	,Message			= 'TXN Summary'
	,REFID				= @TXN_REF_ID
	,SENDER_NAME		= rt.senderName
	,RECEIVER_NAME		= rt.receiverName
	,PAYOUTAMT			= pAmt 
	,PAYOUTCURRENCY		= payoutCurr 
	,[STATUS]			= CASE WHEN payStatus='unpaid'THEN 'Un-Paid' ELSE payStatus END 
	,STATUS_DATE		= CASE WHEN payStatus='Paid' THEN paidDate WHEN transtatus='Cancel' THEN cancelapproveddate END 
	,TOKEN_ID			= rt.payTokenId
FROM remitTran rt WITH (NOLOCK)
INNER JOIN tranSenders ts WITH (NOLOCK) ON rt.Id = ts.tranId
INNER JOIN tranReceivers tr WITH (NOLOCK) ON rt.Id = tr.tranId
WHERE controlNo2 = @controlNoEnc

	UPDATE requestApiLogOther SET 
		 errorCode = '0'
		,errorMsg = 'Success'			
	WHERE rowId = @apiRequestId


END TRY
	
BEGIN CATCH

SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, * FROM @errorTable

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)

SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_int_proc_GetStatus',@USERNAME, GETDATE()
END CATCH



GO
