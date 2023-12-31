USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_GetStatus]    Script Date: 8/23/2020 5:48:08 PM ******/
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
 @ACCESSCODE = 'BRNNP1087', 
 @USERNAME = 'dhan321', 
 @PASSWORD = 'dhan123', 
 @REFNO = '90801703625',
  @AGENT_TXN_REF_ID = '356113'

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
 
CREATE PROC [dbo].[ws_int_proc_GetStatus] (	 
	@ACCESSCODE		VARCHAR(50),
	@USERNAME		VARCHAR(50),
	@PASSWORD		VARCHAR(50),
	@REFNO			VARCHAR(20),
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
		,@REFNO
		,'ws_int_proc_GetStatus'
		,GETDATE()
	
	SET @apiRequestId = SCOPE_IDENTITY()		
	
	DECLARE @errCode INT,@controlNoEnc VARCHAR(50) = dbo.FNAENcryptString(@REFNO)
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
		,EXCHANGE_RATE FLOAT
		,localAmount		MONEY
		,settlementAmt		MONEY
		,usdRate			MONEY
		,settlementRate		MONEY
	)

	INSERT INTO @errorTable(AGENT_REFID) 
	SELECT @AGENT_TXN_REF_ID

	IF (@errCode='1' )
	BEGIN
		SELECT 	'1002' CODE,ISNULL(@autMsg,'Authentication Fail') MESSAGE	,* FROM @errorTable
		RETURN
	END
	IF EXISTS(
		SELECT 'x' FROM applicationUsers WITH (NOLOCK) 
		WHERE userName = @USERNAME 
			AND forceChangePwd = 'Y'
	)
	BEGIN
		SELECT 
			 '1002' CODE,'You logged on first time,must first change your password and try again!' MESSAGE,* 	FROM @errorTable
		RETURN
	END

	IF @REFNO IS NULL
	BEGIN
		SELECT 
			'1001' CODE,'REFNO Field is Empty' MESSAGE,* FROM @errorTable
		RETURN;
	END
	--IF ISNUMERIC(@REFNO) = 0 AND @REFNO IS NOT NULL
	--BEGIN
	--	SELECT 
	--		'9001' CODE,'Technical Error: REFNO must be numeric' MESSAGE	,* FROM @errorTable
	--	RETURN;
	--END
	IF @AGENT_TXN_REF_ID IS NULL
	BEGIN
		SELECT 
			'1001' CODE,'AGENT SESSION ID Field is Empty' MESSAGE,* FROM @errorTable
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

	SELECT	
		 @tranId		= id
		,@tranStatus	= tranStatus
		,@txnBranch		= sBranch
		,@txnAgent		= sAgent	
		,@status		= payStatus
	
	FROM remitTran WITH (NOLOCK) 
	WHERE controlNo = @controlNoEnc 

	IF @tranStatus IS NULL
	BEGIN
		SELECT '2001' CODE,'Transaction Not Found RefNo: '+ @REFNO MESSAGE,* FROM @errorTable
		RETURN
	END

	IF @sAgent <> @txnAgent
	BEGIN
		SELECT '2002' CODE,'You are not authorized to view this transaction' MESSAGE,* FROM @errorTable
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

	SELECT 
		 Code				= '0'
		,AGENT_REFID		= @AGENT_TXN_REF_ID
		,Message			= 'TXN Summary'
		,REFID				= @REFNO
		,SENDER_NAME		= rt.senderName
		,RECEIVER_NAME		= rt.receiverName
		,PAYOUTAMT			= pAmt 
		,PAYOUTCURRENCY		= payoutCurr 
		,[STATUS]			= CASE WHEN transtatus='Cancel' THEN 'Cancel' WHEN payStatus='unpaid'THEN 'Un-Paid'  ELSE payStatus END 
		,STATUS_DATE		= CASE WHEN payStatus='Paid' THEN paidDate WHEN transtatus='Cancel' THEN cancelapproveddate END 
		,TOKEN_ID			= rt.payTokenId
		,EXCHANGE_RATE		= rt.customerRate
		,localAmount		= rt.cAmt
		,settlementAmt		= rt.pAmt/rt.pCurrCostRate
		,usdRate			= rt.pCurrCostRate
		,settlementRate		= rt.pAmt/rt.cAmt
	FROM remitTran rt WITH (NOLOCK)
	INNER JOIN tranSenders ts WITH (NOLOCK) ON rt.Id = ts.tranId
	INNER JOIN tranReceivers tr WITH (NOLOCK) ON rt.Id = tr.tranId
	WHERE controlno=@controlNoEnc

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
