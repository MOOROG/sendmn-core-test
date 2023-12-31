USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_CancelTXN]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ws_int_proc_CancelTXN](	 
		@ACCESSCODE			VARCHAR(50),
		@USERNAME 			VARCHAR(50),
		@PASSWORD 			VARCHAR(50),
		@REFNO 				VARCHAR(20),
		@AGENT_TXN_REF_ID	VARCHAR(150),
		@CANCEL_REASON 		VARCHAR(500)
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
		,REFNO 				
		,AGENT_TXN_REF_ID	
		,CANCEL_REASON
		,METHOD_NAME
		,REQUEST_DATE
	)
	SELECT
		 @ACCESSCODE				
		,@USERNAME 			
		,@PASSWORD 			
		,@REFNO 				
		,@AGENT_TXN_REF_ID	
		,@CANCEL_REASON
		,'ws_int_proc_CancelTXN'
		,GETDATE()
	SET @apiRequestId = SCOPE_IDENTITY()	



	DECLARE @errCode INT, @controlNoEnc VARCHAR(50), @DT DATETIME
	DECLARE @autMsg	VARCHAR(500)
	SET @DT = GETDATE() 

	SET @controlNoEnc = dbo.FNAEncryptString(@REFNO)
	EXEC ws_int_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT, @autMsg OUT

	DECLARE @errorTable TABLE(
		 AGENT_TXN_REF_ID VARCHAR(150),REFNO VARCHAR(50),COLLECT_AMT MONEY,COLLECT_CURRENCY VARCHAR(3)
		,EXCHANGE_RATE MONEY,SERVICE_CHARGE MONEY,PAYOUTAMT MONEY,PAYOUTCURRENCY VARCHAR(3),TXN_DATE DATETIME
	)

	INSERT INTO @errorTable (AGENT_TXN_REF_ID, REFNO)
	SELECT @AGENT_TXN_REF_ID, @REFNO

	IF(@errCode = 1 )
	BEGIN
		SELECT '1002' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, * FROM @errorTable
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USERNAME AND forceChangePwd = 'Y')
	BEGIN
		SELECT '1002' CODE, 'You logged on first time,must first change your password and try again!' MESSAGE, * FROM @errorTable
		RETURN
	END

	IF @REFNO IS NULL
	BEGIN
		SELECT '1001' CODE, 'PINNO Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @CANCEL_REASON IS NULL
	BEGIN
		SELECT '1001' CODE, 'CANCEL REASON Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @AGENT_TXN_REF_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT SESSION ID Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END

	DECLARE		
		 @sCountryId		INT
		,@sAgent			INT
		,@sBranch			INT
		,@tranId			INT
		,@tranStatus		VARCHAR(50)
		,@payStatus			VARCHAR(50)
		,@serviceCharge		MONEY
		,@tAmt				MONEY
		,@cAmt				MONEY
		,@createdBy			VARCHAR(50)
		,@txnSbranch		INT
		,@txnSAgent			INT
		,@pCountry			VARCHAR(50)

	SELECT 
		@sCountryId = countryId, 
		@sBranch = sb.agentId,
		@sAgent = sb.parentId 
	FROM applicationUsers  au WITH(NOLOCK) 
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON au.agentId = sb.agentId
	WHERE userName = @USERNAME
	AND ISNULL(sb.isActive,'N') = 'Y'

			
		DECLARE @cancelReason1 VARCHAR(500)
		SELECT 
			 @tranId		= id,
			 @serviceCharge	= serviceCharge,
			 @tAmt			= tAmt,
			 @cAmt			= cAmt,
			 @createdBy		= createdBy,
			 @tranStatus	= tranStatus,
			 @payStatus		= payStatus,
			 @txnSbranch	= sBranch,
			 @txnSAgent		= sAgent,
			 @pCountry		= pCountry
		FROM remitTran  WITH(NOLOCK) 
		WHERE controlNo = dbo.FNAEncryptString(@REFNO)
			
		IF (@tranStatus IS NULL)
		BEGIN
			SELECT '2001' CODE, 'RefNo: '+ @REFNO + ' Not Found or can not cancel. Please contact Headoffice' MESSAGE
			,* FROM @errorTable
			RETURN
		END
		
		IF @sAgent <> @txnSAgent 
		BEGIN
			SELECT '2002' CODE, 'You are not allow to cancel this transaction' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Cancel')
		BEGIN
			SELECT '2003' CODE, 'Transaction already been cancelled' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Lock')
		BEGIN
			SELECT '2004' CODE, 'Transaction is locked. Please contact HO' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Block')
		BEGIN
			SELECT '2005' CODE, 'Transaction is blocked. Please contact HO' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@payStatus = 'Post')
		BEGIN
			SELECT '2002' CODE, 'Transaction is not in Authorized Mode' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Paid')
		BEGIN
			SELECT '2002' CODE, 'Transaction is not in Authorized Mode' MESSAGE, * FROM @errorTable
			RETURN
		END
		
		BEGIN TRANSACTION			
		UPDATE remitTran SET
				 tranStatus					= 'CancelRequest'
				,cancelRequestDate			= GETDATE()
				,cancelRequestDateLocal		= dbo.FNADateFormatTZ(GETDATE(), @USERNAME)
				,cancelRequestBy			= @USERNAME
				,cancelReason				= @CANCEL_REASON
				--,cancelApprovedBy			= @USERNAME
				--,cancelApprovedDate			= dbo.FNADateFormatTZ(GETDATE(), @USERNAME)
				--,cancelApprovedDateLocal	= GETDATE()
		WHERE id = @tranId
		
		INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus, tranStatus,createdBy,createdDate)
		SELECT @tranId, dbo.FNAEncryptString(@REFNO), @CANCEL_REASON, 'CancelRequest', @tranStatus, @USERNAME, GETDATE()
		
		DELETE FROM @errorTable
				
		INSERT INTO @errorTable (AGENT_TXN_REF_ID,REFNO,COLLECT_AMT,COLLECT_CURRENCY,EXCHANGE_RATE,SERVICE_CHARGE,PAYOUTAMT,PAYOUTCURRENCY,TXN_DATE)	
		SELECT @AGENT_TXN_REF_ID,@REFNO,cAmt,collCurr,customerRate,serviceCharge,pAmt,payoutCurr,createdDateLocal
		FROM remitTran WITH (NOLOCK) WHERE id = @tranId
		
		EXEC proc_transactionLogs 'i', @USERNAME, @tranId, @CANCEL_REASON, 'Cancel Request'
		
	    IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		SELECT 0 CODE, 'Cancel Txn success, and waiting for approval!' MESSAGE, * FROM @errorTable	
	
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
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_CancelTransaction',@USERNAME , GETDATE()
END CATCH



GO
