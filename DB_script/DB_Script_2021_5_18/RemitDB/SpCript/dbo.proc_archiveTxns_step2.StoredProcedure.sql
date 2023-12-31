USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_archiveTxns_step2]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_archiveTxns_step2]
AS

SET XACT_ABORT ON;
SET NOCOUNT ON;

PRINT CONVERT(VARCHAR, GETDATE(), 109)
BEGIN TRY

	BEGIN TRANSACTION

		EXEC proc_PrintLog 'STEP - 2, Moving Data - Started', 'tranCancelrequest'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.tranCancelrequest(
			id,tranId,controlNo,cancelReason,cancelStatus,scRefund,createdDate,createdBy,approvedDate,approvedBy,approvedRemarks
			,teller,refundDate,assignTellerDate,assignTellerBy,tranStatus,isScRefund
		)
		SELECT 
			id,tranId,controlNo,cancelReason,cancelStatus,scRefund,createdDate,createdBy,approvedDate,approvedBy,approvedRemarks
			,teller,refundDate,assignTellerDate,assignTellerBy,tranStatus,isScRefund
		FROM tranCancelrequest rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId = trt.t_id

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM tranCancelrequest rt	INNER JOIN archiveTxnQueue trt ON rt.controlNo= trt.t_controlNo
 
		--EXEC proc_PrintLog 'tranCancelrequest', 'tranModifyLog'
		--INSERT INTO FastMoneyPro_remit_Archive.dbo.tranModifyLog(
		--	rowId,tranId,controlNo,message,createdBy,createdDate,fileType,MsgType,dcInfo,status,resolvedBy,resolvedDate,fieldName
		--	,fieldValue,oldValue,ScChargeMod
		--)
		--SELECT 
		--	rowId,tranId,controlNo,message,createdBy,createdDate,fileType,MsgType,dcInfo,status,resolvedBy,resolvedDate,fieldName
		--	,fieldValue,oldValue,ScChargeMod
		--FROM tranModifyLog rt WITH(NOLOCK)
		--INNER JOIN archiveTxnQueue trt ON rt.controlNo= trt.t_controlNo or rt.tranId = trt.t_holdTranId

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM tranModifyLog rt INNER JOIN archiveTxnQueue trt ON rt.controlNo= trt.t_controlNo
 
		EXEC proc_PrintLog 'tranModifyLog', 'tranViewHistory'		
		INSERT INTO FastMoneyPro_remit_Archive.dbo.tranViewHistory(
			id,controlNumber,tranViewType,agentId,createdBy,createdDate,dcInfo,tranId,remarks,ipAddress
		)
		SELECT
			id,controlNumber,tranViewType,agentId,createdBy,createdDate,dcInfo,tranId,remarks,ipAddress
		FROM tranViewHistory rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.controlNumber= trt.t_controlNo

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM tranViewHistory rt INNER JOIN archiveTxnQueue trt ON rt.controlNumber= trt.t_controlNo
 
		EXEC proc_PrintLog 'tranViewHistory', 'cancelTranHistory'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.cancelTranHistory(
			id,tranId,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin
			,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
			,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm
			,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm
			,pSuperAgentCommCurrency,promotionCode,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent
			,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName
			,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode,collCurr,tAmt
			,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
			,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal
			,paidBy,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate
			,cancelApprovedDateLocal,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,sendEOD
			,payEOD,cancelEOD,tranType,ContNo,uploadLogId,company,voucherNo,controlNo2,pBankType,trnStatusBeforeCnlReq,senderName
			,receiverName,expectedPayoutAgent,routedBy,routedDate,incrRpt
		)
		SELECT 
			id,tranId,controlNo,sCurrCostRate,sCurrHoMargin,sCurrSuperAgentMargin,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin
			,pCurrSuperAgentMargin,pCurrAgentMargin,agentCrossSettRate,customerRate,sAgentSettRate,pDateCostRate,agentFxGain
			,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,serviceCharge,handlingFee,sAgentComm
			,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency,pAgentComm,pAgentCommCurrency,pSuperAgentComm
			,pSuperAgentCommCurrency,promotionCode,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent
			,sAgentName,sBranch,sBranchName,pCountry,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName
			,paymentMethod,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,externalBankCode,collMode,collCurr,tAmt
			,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal
			,createdBy,modifiedDate,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal
			,paidBy,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate
			,cancelApprovedDateLocal,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId,sendEOD
			,payEOD,cancelEOD,tranType,ContNo,uploadLogId,company,voucherNo,controlNo2,pBankType,trnStatusBeforeCnlReq,senderName
			,receiverName,expectedPayoutAgent,routedBy,routedDate,incrRpt
		FROM cancelTranHistory rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM cancelTranHistory rt INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id
 
		EXEC proc_PrintLog 'cancelTranHistory', 'cancelTranReceiversHistory'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.cancelTranReceiversHistory(
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district
			,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber
			,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,validDate2,relationType,relativeName
			,gender,address2,dcInfo,ipAddress
		)
		SELECT 
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district
			,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber
			,idPlaceOfIssue,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,validDate2,relationType,relativeName
			,gender,address2,dcInfo,ipAddress
		FROM cancelTranReceiversHistory rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM cancelTranReceiversHistory rt INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id
 
		EXEC proc_PrintLog 'cancelTranReceiversHistory', 'cancelTranSendersHistory'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.cancelTranSendersHistory(
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district
			,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber
			,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,gender
			,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer
		)
		SELECT 
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,fullName,country,address,STATE,district
			,zipCode,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber
			,idPlaceOfIssue,issuedDate,validDate,extCustomerId,cwPwd,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,gender
			,salary,companyName,address2,dcInfo,ipAddress,notifySms,txnTestQuestion,txnTestAnswer
		FROM cancelTranSendersHistory rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM cancelTranSendersHistory rt INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id
 
		EXEC proc_PrintLog 'cancelTranSendersHistory', 'errPaidTran'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.errPaidTran(
			eptId,tranId,oldSettlingAgent,oldPBranch,oldPBranchName,oldPSuperAgentComm,oldPSuperAgentCommCurrency,oldPAgentComm
			,oldPAgentCommCurrency,oldPaidDate,newSettlingAgent,newPBranch,newPBranchName,newPSuperAgent,newPSuperAgentName
			,newPAgent,newPAgentName,newPSuperAgentComm,newPSuperAgentCommCurrency,newPAgentComm,newPAgentCommCurrency,payoutAmt
			,narration,createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate,newPaidBy,newPaidDate,rIdType,rIdNo
			,expiryType,issueDate,validDate,placeOfIssue,mobileNo,rRelativeType,rRelativeName,tranStatus,isDeleted
			,newDeliveryMethod,payRemarks
		)
		SELECT 
			eptId,tranId,oldSettlingAgent,oldPBranch,oldPBranchName,oldPSuperAgentComm,oldPSuperAgentCommCurrency,oldPAgentComm
			,oldPAgentCommCurrency,oldPaidDate,newSettlingAgent,newPBranch,newPBranchName,newPSuperAgent,newPSuperAgentName
			,newPAgent,newPAgentName,newPSuperAgentComm,newPSuperAgentCommCurrency,newPAgentComm,newPAgentCommCurrency,payoutAmt
			,narration,createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate,newPaidBy,newPaidDate,rIdType,rIdNo
			,expiryType,issueDate,validDate,placeOfIssue,mobileNo,rRelativeType,rRelativeName,tranStatus,isDeleted
			,newDeliveryMethod,payRemarks
		FROM errPaidTran rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM errPaidTran rt INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id
 
		EXEC proc_PrintLog 'errPaidTran', 'errPaidTranHistory'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.errPaidTranHistory(
			rowId,eptId,tranId,oldSettlingAgent,oldPBranch,oldPBranchName,oldPSuperAgentComm,oldPSuperAgentCommCurrency
			,oldPAgentComm,oldPAgentCommCurrency,oldPaidDate,newSettlingAgent,newPBranch,newPBranchName,newPSuperAgent
			,newPSuperAgentName,newPAgent,newPAgentName,newPSuperAgentComm,newPSuperAgentCommCurrency,newPAgentComm
			,newPAgentCommCurrency,payoutAmt,narration,createdBy,createdDate,approvedBy,approvedDate,modType,newDeliveryMethod
		)
		SELECT 
			rowId,eptId,tranId,oldSettlingAgent,oldPBranch,oldPBranchName,oldPSuperAgentComm,oldPSuperAgentCommCurrency
			,oldPAgentComm,oldPAgentCommCurrency,oldPaidDate,newSettlingAgent,newPBranch,newPBranchName,newPSuperAgent
			,newPSuperAgentName,newPAgent,newPAgentName,newPSuperAgentComm,newPSuperAgentCommCurrency,newPAgentComm
			,newPAgentCommCurrency,payoutAmt,narration,createdBy,createdDate,approvedBy,approvedDate,modType,newDeliveryMethod
		FROM errPaidTranHistory rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id

		--EXEC proc_PrintLog 'Deleting...',NULL
		--DELETE rt FROM errPaidTranHistory rt INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id

		EXEC proc_PrintLog 'errPaidTranHistory', 'STEP - 2, Moving Data - Completed'

	COMMIT TRANSACTION

	SELECT '0' errorCode, CAST((SELECT COUNT(*) FROM archiveTxnQueue) AS VARCHAR) + ' Transaction(s) archived successfully: Step:2' msg, NULL id

END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT '1' rrrorCode, ERROR_MESSAGE() msg, NULL id

END CATCH



GO
