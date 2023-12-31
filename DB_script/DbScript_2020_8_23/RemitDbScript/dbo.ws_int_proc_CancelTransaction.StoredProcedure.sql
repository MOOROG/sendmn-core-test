USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_CancelTransaction]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_int_proc_CancelTransaction](	 
		@AGENT_CODE			VARCHAR(50),
		@USER_ID			VARCHAR(50),
		@PASSWORD			VARCHAR(50),
		@PINNO				VARCHAR(20),
		@AGENT_SESSION_ID	VARCHAR(150),
		@CANCEL_REASON		VARCHAR(500)
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
		,AGENT_SESSION_ID
		,CANCEL_REASON		
		,METHOD_NAME
		,REQUEST_DATE


	)
	SELECT
		 @AGENT_CODE				
		,@USER_ID 			
		,@PASSWORD 			
		,@PINNO
		,@AGENT_SESSION_ID
		,@CANCEL_REASON	
		,'ws_int_proc_CancelTransaction'
		,GETDATE()


	SET @apiRequestId = SCOPE_IDENTITY()	

	DECLARE @errCode INT, @controlNoEnc VARCHAR(50), @DT DATETIME
	DECLARE @autMsg	VARCHAR(500)
	SET @DT = GETDATE() 
	SET @controlNoEnc = dbo.FNAEncryptString(@PINNO)
	EXEC ws_int_proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT, @autMsg OUT

	DECLARE @errorTable TABLE(
		 AGENT_SESSION_ID VARCHAR(150),PINNO VARCHAR(50),AGENT_TXNID INT,COLLECT_AMT MONEY,COLLECT_CURRENCY VARCHAR(3)
		,EXCHANGE_RATE MONEY,SERVICE_CHARGE MONEY,PAYOUTAMT MONEY,PAYOUTCURRENCY VARCHAR(3),TXN_DATE DATETIME
	)

	INSERT INTO @errorTable (AGENT_SESSION_ID, PINNO)
	SELECT @AGENT_SESSION_ID, @PINNO

	IF(@errCode = 1 )
	BEGIN
		SELECT '1002' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, * FROM @errorTable
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USER_ID AND forceChangePwd = 'Y')
	BEGIN
		SELECT '1002' CODE, 'You logged on first time,must first change your password and try again!' MESSAGE, * FROM @errorTable
		RETURN
	END
	IF @PINNO IS NULL
	BEGIN
		SELECT '1001' CODE, 'PINNO Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @CANCEL_REASON IS NULL
	BEGIN
		SELECT '1001' CODE, 'CANCEL REASON Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @AGENT_SESSION_ID IS NULL
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
	FROM applicationUsers au WITH(NOLOCK) 
	LEFT JOIN agentMaster sb WITH(NOLOCK) ON au.agentId = sb.agentId
	WHERE userName = @USER_ID
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
		FROM remitTran WITH(NOLOCK) 
		WHERE controlNo = dbo.FNAEncryptString(@PINNO)
			
		IF (@tranStatus IS NULL)
		BEGIN
			SELECT '2003' CODE, 'RefNo: '+ @PINNO + ' Not Found or can not cancel. Please contact Headoffice' MESSAGE
			,* FROM @errorTable
			RETURN
		END
		
		IF @sAgent <> @txnSAgent 
		BEGIN
			SELECT '1003' CODE, 'You are not allow to cancel this transaction' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Cancel')
		BEGIN
			SELECT '2003' CODE, 'Transaction already been cancelled' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Lock')
		BEGIN
			SELECT '2003' CODE, 'Transaction is locked. Please contact HO' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Block')
		BEGIN
			SELECT '2003' CODE, 'Transaction is blocked. Please contact HO' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@payStatus = 'Post')
		BEGIN
			SELECT '2001' CODE, 'Transaction is not in Authorized Mode' MESSAGE, * FROM @errorTable
			RETURN
		END
		IF (@tranStatus = 'Paid')
		BEGIN
			SELECT '2001' CODE, 'Transaction is not in Authorized Mode' MESSAGE, * FROM @errorTable
			RETURN
		END
		BEGIN TRANSACTION
			UPDATE remitTran SET
				 tranStatus					= 'Cancel'
				,cancelRequestDate			= GETDATE() 
				,cancelRequestDateLocal		= dbo.FNADateFormatTZ(GETDATE(), @USER_ID)
				,cancelRequestBy			= @USER_ID
				,cancelReason				= @CANCEL_REASON
				,cancelApprovedBy			= @USER_ID
				,cancelApprovedDate			= dbo.FNADateFormatTZ(GETDATE(), @USER_ID)
				,cancelApprovedDateLocal	= GETDATE()
			WHERE id = @tranId

		
		-->> UPDATE CANCEL HISTORY TABLE SELECT * FROM tranCancelrequest
		INSERT INTO tranCancelrequest(tranId,controlNo,cancelReason,cancelStatus,createdBy,createdDate,approvedBy,approvedDate,approvedRemarks)
		SELECT @tranId, dbo.FNAEncryptString(@PINNO), @CANCEL_REASON, 'Approved', @USER_ID, GETDATE(), @USER_ID, GETDATE(), @CANCEL_REASON
		
		DELETE FROM @errorTable
				
		INSERT INTO @errorTable (AGENT_SESSION_ID,PINNO,AGENT_TXNID,COLLECT_AMT,COLLECT_CURRENCY,EXCHANGE_RATE,SERVICE_CHARGE,PAYOUTAMT,PAYOUTCURRENCY,TXN_DATE)	
		SELECT @AGENT_SESSION_ID,@PINNO,'123456',cAmt,collCurr,customerRate,serviceCharge,pAmt,payoutCurr,createdDateLocal
		FROM remitTran WITH (NOLOCK) WHERE id = @tranId
				
		IF @tranStatus LIKE '%HOLD%'
		BEGIN	
			INSERT INTO cancelTranHistory(
				tranId,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate,cancelApprovedDateLocal
				,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,senderName,receiverName
			)
			SELECT 
				id,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate
				,pCurrHoMargin,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
				,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency
				,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,promotionCode
				,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName
				,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
				,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
				,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,@cancelReason1,refund,cancelCharge,dbo.FNADateFormatTZ(GETDATE(), @USER_ID),GETDATE()
				,@USER_ID,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,tranType,ContNo
				,uploadLogId,voucherNo,controlNo2,pBankType,senderName,receiverName
			 FROM remitTran WITH (NOLOCK) WHERE id = @tranId
			
			INSERT INTO cancelTranSendersHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district,
			zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,
			idNumber,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,
			gender,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer 
			FROM transenders WITH(NOLOCK) WHERE tranId = @tranId
			
			INSERT INTO cancelTranReceiversHistory 
			(tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress)
			SELECT tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,
			STATE,district,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
			occupation,idType,idNumber,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,
			validDate2,relationType,relativeName,gender,address2,dcInfo,ipAddress
			FROM tranReceivers WITH(NOLOCK)	WHERE tranId = @tranId

			DELETE FROM remitTran WHERE id = @tranId
			DELETE FROM tranSenders WHERE tranId = @tranId
			DELETE FROM tranReceivers WHERE tranId = @tranId		
		END
		COMMIT TRANSACTION

		SELECT 0 CODE, 'success' MESSAGE, * FROM @errorTable


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
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_CancelTransaction','admin', GETDATE()
END CATCH	




GO
