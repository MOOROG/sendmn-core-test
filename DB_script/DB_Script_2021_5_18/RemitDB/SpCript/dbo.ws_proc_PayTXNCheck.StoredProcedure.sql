USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_PayTXNCheck]    Script Date: 5/18/2021 5:17:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ws_proc_PayTXNCheck] (	 
	@ACCESSCODE			VARCHAR(50),
	@USERNAME			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@REFNO				VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(150)
)

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

	DECLARE @apiRequestId BIGINT
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE,'AGENT SESSION ID Field is Empty' MESSAGE
				,AGENT_SESSION_ID	= @AGENT_SESSION_ID	
		RETURN;
	END

	INSERT INTO apiRequestLogPay(ACCESSCODE,USERNAME,PASSWORD,REFNO,AGENT_SESSION_ID,requestedDate)
	SELECT @ACCESSCODE,@USERNAME,@PASSWORD,@REFNO,@AGENT_SESSION_ID,GETDATE()
	
	SET @apiRequestId = SCOPE_IDENTITY()
	
	DECLARE @errCode INT, @controlNoEnc VARCHAR(50) = dbo.FNAENcryptString(@REFNO)
	DECLARE @autMsg	VARCHAR(500), @errorCode VARCHAR(10), @errorMsg VARCHAR(MAX), @remarks VARCHAR(30) = 'Pay Search'
	EXEC ws_proc_checkAuthntication @USERNAME, @PASSWORD, @ACCESSCODE, @errCode OUT, @autMsg OUT

	DECLARE @errorTable TABLE(
		 AGENT_SESSION_ID	VARCHAR(150)
		,REFNO				VARCHAR(50)
		,SEND_AGENT			VARCHAR(50)
		,SENDER_NAME		VARCHAR(200)
		,SENDER_MOBILE		VARCHAR(50)
		,SENDER_CITY		VARCHAR(100)
		,SENDER_COUNTRY		VARCHAR(100)
		,RECEIVER_NAME		VARCHAR(200)
		,RECEIVER_ADDRESS	VARCHAR(200)
		,RECEIVER_PHONE		VARCHAR(50)
		,RECEIVER_CITY		VARCHAR(100)
		,RECEIVER_COUNTRY	VARCHAR(100)
		,PAYOUT_AMT			MONEY
		,SENDING_AMT		MONEY
		,PAYOUT_CURRENCY	VARCHAR(3)
		,PAYMENT_TYPE		VARCHAR(100)
		,TXN_DATE			VARCHAR(50)
		,PAY_TOKEN_ID		VARCHAR(50)
		,ISLOCAL			VARCHAR(5)
		,TRANID				VARCHAR(50)
		,RECEIVERMOBILE		VARCHAR(50)
	)

	INSERT INTO @errorTable(AGENT_SESSION_ID, REFNO) 
	SELECT @AGENT_SESSION_ID, @REFNO

	IF @errCode = 1
	BEGIN
		SELECT @errorCode = '1002', @errorMsg = ISNULL(@autMsg,'Authentication Fail')
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END

	IF EXISTS(SELECT 'x' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USERNAME AND forceChangePwd = 'Y'
	)
	BEGIN
		SELECT @errorCode = '1002', @errorMsg = 'You are required to change your password.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	------------------VALIDATION-------------------------------
	/*
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE,'AGENT SESSION ID Field is Empty' MESSAGE,* FROM @errorTable
		RETURN
	END
	*/
	IF @REFNO IS NULL
	BEGIN
		SELECT @errorCode = '1001', @errorMsg = 'Control Number Field is Required'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN;
	END
	

	--IF @REFNO IS NOT NULL AND ISNUMERIC(@REFNO)=0
	--BEGIN
	--	SELECT @errorCode = '2003', @errorMsg = 'Technical Error: PINNO must be numeric'
	--	EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
	--	SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
	--	RETURN;
	--END

	-- GET AGENT DETAIL
	DECLARE		
		@pAgent					INT,
		@pAgentTran				INT,
		@tranId					BIGINT,
		@tranStatus				VARCHAR(50),
		@pCountry				VARCHAR(50),
		@userCountry			VARCHAR(50),
		@paymentMethod			VARCHAR(100),
		@lock_status			VARCHAR(50),
		@MESSAGE				VARCHAR(50),
		@SEND_AGENT				VARCHAR(50),
		@SENDER_NAME			VARCHAR(200),
		@SENDER_ADDRESS			VARCHAR(200),
		@SENDER_MOBILE			VARCHAR(50),
		@SENDER_CITY			VARCHAR(100),
		@SENDER_COUNTRY			VARCHAR(100),
		@RECEIVER_NAME			VARCHAR(200),
		@RECEIVER_ADDRESS		VARCHAR(200),
		@RECEIVER_PHONE			VARCHAR(50),
		@RECEIVER_CITY			VARCHAR(100),
		@RECEIVER_COUNTRY		VARCHAR(100),
		@PAYOUT_AMT				VARCHAR(50),
		@SENDING_AMT			VARCHAR(50),
		@PAYOUT_COMM			VARCHAR(50),
		@PAYOUT_CURRENCY		VARCHAR(3),
		@PAYMENT_TYPE			VARCHAR(100),
		@TXN_DATE				VARCHAR(50),
		@PAY_TOKEN_ID			VARCHAR(50),
		@Status					VARCHAR(50),
        @lockedBy				VARCHAR(100),
	    @pAgentName				VARCHAR(200),
	    @pAgentNameI			VARCHAR(100),
	    @isLocal				VARCHAR(100)

	-- PICK AGENTID ,COUNTRY FROM USER
	
	SELECT
			@pAgent		= am.parentId
		,@userCountry	= cm.countryName
	FROM applicationUsers au WITH(NOLOCK)
	INNER JOIN countryMaster cm WITH(NOLOCK) ON au.countryId = cm.countryId
	LEFT JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
	WHERE userName = @USERNAME
	
	
	SELECT @pAgentNameI = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
	--------------------------------------------------------------------------------------------------

	SELECT	
		 @tranId				= rt.id
		,@tranStatus			= rt.tranStatus
		,@pCountry				= rt.pCountry
		,@pAgentTran			= rt.pAgent
		,@pAgentName			= rt.pAgentName
		,@paymentMethod			= rt.paymentMethod
		,@lock_status			= rt.lockStatus
	    ,@lockedBy				= rt.lockedBy
		,@MESSAGE				= @REFNO
		,@SEND_AGENT			= rt.sAgentName
		,@SENDER_NAME			= rt.SenderName
		,@SENDER_ADDRESS		= sen.Address
		,@SENDER_MOBILE			= sen.mobile
		,@SENDER_CITY			= sen.city
		,@SENDER_COUNTRY		= rt.sCountry
		,@RECEIVER_NAME			= rt.ReceiverName
		,@RECEIVER_ADDRESS		= rec.address
		,@RECEIVER_PHONE		= rec.mobile
		,@RECEIVER_CITY			= rec.city
		,@RECEIVER_COUNTRY		= rt.pCountry
		,@PAYOUT_AMT			= rt.pAmt
		,@SENDING_AMT			= rt.tAmt
		,@PAYOUT_CURRENCY		= rt.payoutCurr
		,@PAYMENT_TYPE		    = rt.paymentMethod
		,@TXN_DATE				= RT.createdDate
		,@Status				= rt.payStatus
		,@isLocal				= CASE WHEN tranType ='D' THEN 'P' ELSE 'R' END 
	FROM vwRemitTran rt WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	WHERE controlNo = @controlNoEnc
	
	IF @tranStatus IS NULL 
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'Transaction does not exist. Please check your GME No(GME NUMBER).'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @pCountry <> @userCountry
	BEGIN
		SELECT @errorCode = '2003', @errorMsg = 'Transaction does not exist. Please check your GME No(GME NUMBER).'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @paymentMethod <> 'Cash Payment' AND @paymentMethod <> 'ML CARES DONATION' AND @paymentMethod <> 'Cash Payment USD'
	BEGIN
		SELECT @errorCode = '2005', @errorMsg = 'This transaction is not Cash Pay Transaction'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF (@tranStatus LIKE '%Hold%')
	BEGIN
		SELECT @errorCode = '2006', @errorMsg = 'The Transaction is not approved. Kindly contact info@gmeremit.com.np to approve the transction.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF (ISNULL(@Status,'') = 'Paid')
	BEGIN
		SELECT @errorCode = '2007', @errorMsg = 'Transaction ' + @REFNO + ' is already PAID'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END

    IF (@pAgentTran IS NOT NULL AND @pAgentTran <> @pAgent)
	BEGIN
		SELECT @errorCode = '2007', @errorMsg = 'This transaction belongs to : ' + @pAgentName 
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END

	IF (ISNULL(@tranStatus,'') <> 'Payment')
	BEGIN
		SELECT @errorCode = '2006', @errorMsg = 'This transaction is not currently available for payment. Kindly contact info@gmeremit.com.np for the details.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF @Status = 'Post'
	BEGIN
		SELECT @errorCode = '2006', @errorMsg = 'This transaction is not currently available for payment. Kindly contact info@gmeremit.com.np for the details.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	IF (ISNULL(@Status,'') <> 'Unpaid')
	BEGIN
		SELECT @errorCode = '2006', @errorMsg = 'This transaction is not currently available for payment. Kindly contact info@gmeremit.com.np for the details.'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END

	IF (@lock_status = 'locked' and @USERNAME <> @lockedBy)
	BEGIN
		SELECT @errorCode = '2005', @errorMsg = 'Transaction is locked, Please Contact Head Office'
		EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks
		SELECT @errorCode CODE, @errorMsg MESSAGE, * FROM @errorTable
		RETURN
	END
	
	-->>Pay Search Log
	INSERT INTO tranViewHistory(
		 controlNumber, tranViewType, agentId
		,createdBy, createdDate
		,tranId, dcInfo
	)
	SELECT
		 @controlNoEnc, 'PAY', @pAgent
		,@USERNAME, GETDATE()
		,@tranId, 'API : ' + @USERNAME + '(' + @pAgentNameI + ')'
	--<<Pay Search Log
	
	DECLARE 
		  @tokenId INT 
		 ,@maxRandomValue BIGINT = 9999
		 ,@minRandomValue BIGINT = 1923; ----SWIFT 
	 
	SELECT @tokenId = CAST(((@maxRandomValue + 1)) * RAND() * 2 + @minRandomValue * 3 AS BIGINT) 

	UPDATE remitTran SET
		 lockStatus		= 'locked'
		,lockedBy		= @USERNAME
		,lockedDate		= GETDATE()
		,payTokenId		= @tokenId
	WHERE controlNo = @controlNoEnc

	UPDATE apiRequestLogPay SET
		 errorCode			= '0'
		,errorMsg			= 'Search Success'
		,PAY_TOKEN_ID		= @tokenId
		,remarks			= @remarks
	WHERE rowId = @apiRequestId


	--UPDATE irh_ime_plus_01.dbo.moneySend SET 
	--	 lock_status	= 'locked'
	--	,lock_by		= @USERNAME
	--	,lock_dot		= dbo.FNADateFormatTZ(GETDATE(), @USERNAME)
	--	,txn_token_id	= @tokenId
	--WHERE refno = @controlNoEnc


	SELECT 
		CODE				= '0',
		REFNO				= @REFNO,
		AGENT_SESSION_ID	= @AGENT_SESSION_ID,
		MESSAGE				= 'Success',
		SEND_AGENT			= @SEND_AGENT,
		SENDER_NAME			= @SENDER_NAME ,
		SENDER_ADDRESS		= @SENDER_ADDRESS,
		SENDER_MOBILE		= @SENDER_MOBILE,
		SENDER_CITY			= @SENDER_CITY,
		SENDER_COUNTRY		= @SENDER_COUNTRY,
		RECEIVER_NAME		= @RECEIVER_NAME,
		RECEIVER_ADDRESS	= @RECEIVER_ADDRESS,
		RECEIVER_PHONE		= @RECEIVER_PHONE,
		RECEIVER_CITY		= @RECEIVER_CITY,
		RECEIVER_COUNTRY	= @RECEIVER_COUNTRY,
		PAYOUT_AMT			= @PAYOUT_AMT,
		SENDING_AMT			= @SENDING_AMT,
		PAYOUT_CURRENCY		= @PAYOUT_CURRENCY,
		PAYMENT_TYPE		= CASE WHEN @PAYMENT_TYPE = 'Cash Payment' THEN 'Cash Pay' ELSE @PAYMENT_TYPE END,
		TXN_DATE			= @TXN_DATE,
		PAY_TOKEN_ID		= @tokenId,
		ISLOCAL				= isnull(@isLocal,'R'),
		TRANID				= @tranId,
		RECEIVERMOBILE		= @RECEIVER_PHONE
END TRY
BEGIN CATCH

DECLARE @errorLogId BIGINT
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error',@errorMsg MESSAGE, 'ws_proc_PayTXNCheck', @USERNAME, GETDATE()
SET @errorLogId = SCOPE_IDENTITY()

SELECT @errorCode = '9001', @errorMsg = 'Technical Error : ' + ERROR_MESSAGE() + ', Error Log Id : ' + CAST(@errorLogId AS VARCHAR)
EXEC ws_proc_responseLog @flag = 'p', @requestId = @apiRequestId, @errorCode = @errorCode, @errorMsg = @errorMsg, @remarks = @remarks

SELECT @errorCode CODE, 'Technical Error occurred, Error Log Id : ' + CAST(@errorLogId AS VARCHAR) MESSAGE, * FROM @errorTable

END CATCH

/*

	EXEC ws_proc_PayTXNCheck 
    @ACCESSCODE='IMEBGUBL085',
    @USERNAME='apitest02',@PASSWORD='ime@9999',
    @AGENT_SESSION_ID='1234567',
    @REFNO='90407878675'

*/
--EXEC ws_proc_PayTXNCheck @ACCESSCODE='IMEPH01',@USERNAME='clapiuser01',@PASSWORD='ime1212',@AGENT_SESSION_ID='1234567',@REFNO='90401774056'
GO
