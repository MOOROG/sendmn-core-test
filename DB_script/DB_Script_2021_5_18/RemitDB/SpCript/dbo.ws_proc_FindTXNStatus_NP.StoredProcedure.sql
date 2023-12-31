USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_FindTXNStatus_NP]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_proc_FindTXNStatus_NP](	 
		 @AGENT_CODE		VARCHAR(50)
		,@USER_ID			VARCHAR(50)
		,@PASSWORD			VARCHAR(50)
		,@AGENT_SESSION_ID	VARCHAR(50)
		,@PIN_NO			VARCHAR(20)
		,@SENDING_COUNTRY	VARCHAR(100)
		,@PAYOUT_COUNTRY	VARCHAR(100)
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
	DECLARE @controlNoEnc VARCHAR(50) = dbo.FNAEncryptString(@PIN_NO)
	DECLARE @errorTable TABLE(
		 AGENT_REFID VARCHAR(150)
		,REFID VARCHAR(50)
		,SENDER_NAME VARCHAR(100)
		,RECEIVER_NAME VARCHAR(100)
		,PAYOUT_AMT MONEY
		,PAYOUT_CURRENCY VARCHAR(3)
		,[STATUS] VARCHAR(30)
		,STATUS_DATE VARCHAR(20)
	)

	INSERT INTO @errorTable (AGENT_REFID,REFID)
	SELECT @AGENT_SESSION_ID,@PIN_NO
	
	IF @USER_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'USER_ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @AGENT_CODE IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT_CODE Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @PASSWORD IS NULL
	BEGIN
		SELECT '1001' CODE, 'PASSWORD Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @USER_ID <> 'n3p@lU$er' OR @AGENT_CODE <> '1001' OR @PASSWORD <> '36928c11f93d6b0cbf573d0e1ac350f7'
		BEGIN
			SELECT '1002' CODE,'Authentication Failed' MESSAGE
			RETURN
		END
	------------------ VALIDATION -------------------------------
	IF @PIN_NO IS NULL
	BEGIN
		SELECT '1001' CODE, 'PINNO Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @SENDING_COUNTRY <> 'NP' AND ISNUMERIC(@PIN_NO) = 0 AND @PIN_NO IS NOT NULL
	BEGIN
		SELECT '9001' CODE, 'Technical Error: PINNO must be numeric' MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT SESSION ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @SENDING_COUNTRY IS NULL
	BEGIN
		SELECT '1001' CODE, 'SENDING COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @PAYOUT_COUNTRY IS NULL
	BEGIN
		SELECT '1001' CODE, 'RECIEVING COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN
	END


	DECLARE		
		@sCountry		VARCHAR(150), 
		@pCountry		VARCHAR(150),
		@agentId		INT,
		@branchId		INT,
		@tranId			INT,
		@tranStatus		VARCHAR(50),
		@txnSAgent		INT,
		@txnPAgent		INT

	SELECT @pCountry = countryName FROM countryMaster WITH(NOLOCK) WHERE countryCode = @PAYOUT_COUNTRY AND ISNULL(isDeleted,'N')='N'
	SELECT @sCountry = countryName FROM countryMaster WITH(NOLOCK) WHERE countryCode = @SENDING_COUNTRY AND ISNULL(isDeleted,'N')='N'

	SELECT 
		 @tranId = id
		,@tranStatus = tranStatus
		,@txnSAgent = sAgent
		,@txnPAgent = pAgent
		FROM remitTran WITH(NOLOCK)
		WHERE controlNo = @controlNoEnc 
		AND (sCountry = @sCountry OR sCountry = @SENDING_COUNTRY)
		AND (pCountry = @pCountry OR pCountry = @PAYOUT_COUNTRY)
		
	IF @tranStatus IS NULL
	BEGIN
		SELECT '1003' CODE, 'Invalid Transaction' MESSAGE, * FROM @errorTable
		RETURN
	END

	IF @txnSAgent <> @agentId AND @txnPAgent <> @agentId
	BEGIN
		SELECT '1003' CODE, 'You are not allow to view this transaction' MESSAGE, * FROM @errorTable
		RETURN
	END

	SELECT  
		CODE				= '0',
		AGENT_REFID			= @AGENT_SESSION_ID,
		MESSAGE				= 'TXN Summary',
		REFID				= @PIN_NO,
		SENDER_NAME			= RT.senderName,
		RECEIVER_NAME		= RT.receiverName,
		PAYOUT_AMT			= RT.pAmt,
		PAYOUT_CURRENCY		= RT.payoutCurr,
		[STATUS]				= CASE WHEN RT.tranStatus='Payment' THEN 'Un-paid' ELSE RT.tranStatus END,
		STATUS_DATE			= CASE WHEN RT.payStatus='Paid' THEN RT.paidDate WHEN RT.tranStatus='Cancel' THEN RT.cancelApprovedDate END,
		TOKEN_ID			= ''
	FROM remitTran RT WITH(NOLOCK) 
	WHERE RT.id = @tranId
	UNION ALL
	SELECT  
		CODE				= '0' ,
		AGENT_REFID			= @AGENT_SESSION_ID,
		MESSAGE				= 'TXN Summary',
		REFID				= @PIN_NO,
		SENDER_NAME			= RT.senderName,
		RECEIVER_NAME		= RT.receiverName,
		PAYOUT_AMT			= RT.pAmt,
		PAYOUT_CURRENCY		= RT.payoutCurr,
		[STATUS]			= CASE WHEN RT.tranStatus='Payment' THEN 'Un-paid' ELSE RT.tranStatus END,
		STATUS_DATE			= CASE WHEN RT.payStatus='Paid' THEN RT.paidDate WHEN RT.tranStatus='Cancel' THEN RT.cancelApprovedDate END,
		TOKEN_ID			= ''
	FROM cancelTranHistory RT WITH(NOLOCK) 
	WHERE RT.tranId = @tranId

GO
