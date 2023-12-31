USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_archiveTxns_step1]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Text
---- EXEC proc_archiveTxns_step1
---- EXEC proc_archiveTxns_step2
---- EXEC proc_archiveTxns_step_delete



CREATE  PROC [dbo].[proc_archiveTxns_step1]
AS

SET XACT_ABORT ON;
SET NOCOUNT ON;

DECLARE @date DATETIME = CONVERT(VARCHAR, GETDATE() - 90, 101)

PRINT CONVERT(VARCHAR, GETDATE(), 109)

BEGIN TRY
	TRUNCATE TABLE archiveTxnQueue;

	INSERT archiveTxnQueue
	SELECT TOP 500000
		rt.id, rt.holdTranId, rt.controlNo 
	FROM remitTran rt WITH(NOLOCK) 
	LEFT JOIN FastMoneyPro_remit_Archive.dbo.remitTran rta  WITH(NOLOCK) ON rt.id = rta.id
	LEFT JOIN errPaidTran ep WITH(NOLOCK) ON rt.id=ep.tranId AND ep.newPaidDate IS NULL
	WHERE 
		(
			(rt.Transtatus = 'Paid' AND rt.paidDate < @date)
			OR
			((rt.Transtatus = 'Cancel' OR rt.Transtatus = 'CANCELLED') AND rt.cancelApprovedDate < @date)
		)
	AND rta.Id IS NULL 
	AND ep.tranId IS NULL
	ORDER by rt.id

	DELETE FROM RT
	FROM archiveTxnQueue RT 
	JOIN  FastMoneyPro_remit_Archive.DBO.remitTran H WITH(NOLOCK) ON RT.t_controlNo = H.controlNo

	

	BEGIN TRANSACTION

		print '1'

		EXEC proc_PrintLog 'STEP - 1, Moving Data - Started', 'remitTran'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.remitTran(
			id,controlNo,sCurrCostRate,sCurrHoMargin,pCurrCostRate,pCurrHoMargin,sCurrAgentMargin,pCurrAgentMargin
			,sCurrSuperAgentMargin,pCurrSuperAgentMargin,customerRate,sAgentSettRate,pDateCostRate,serviceCharge
			,handlingFee,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency,sHubComm,sHubCommCurrency
			,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,pHubComm,pHubCommCurrency,promotionCode
			,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry
			,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName,pState,pDistrict,pLocation,paymentMethod
			,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,collMode,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender
			,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal,createdBy,modifiedDate
			,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
			,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate
			,cancelApprovedDateLocal,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId
			,sendEOD,payEOD,cancelEOD,tranType,oldSysTranNo,pRouteID,senderName,receiverName,holdTranId,agentCrossSettRate
			,agentFxGain,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,externalBankCode,lockStatus
			,ContNo,uploadLogId,voucherNo,controlNo2,pBankType,expectedPayoutAgent,routedBy,routedDate,trnStatusBeforeCnlReq
			,schemeId,bonusPoint,incrRpt,isBonusUpdated,sRouteId, downloadedBy, downloadedDate, downloadLogId, pAmtAct, postedBy
			,postedDate, postedDateLocal
		)
		SELECT 
			id,controlNo,sCurrCostRate,sCurrHoMargin,pCurrCostRate,pCurrHoMargin,sCurrAgentMargin,pCurrAgentMargin
			,sCurrSuperAgentMargin,pCurrSuperAgentMargin,customerRate,sAgentSettRate,pDateCostRate,serviceCharge
			,handlingFee,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency,sHubComm,sHubCommCurrency
			,pAgentComm,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency,pHubComm,pHubCommCurrency,promotionCode
			,promotionType,pMessage,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,sBranchName,pCountry
			,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName,pState,pDistrict,pLocation,paymentMethod
			,pBank,pBankName,pBankBranch,pBankBranchName,accountNo,collMode,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender
			,purposeOfRemit,sourceOfFund,tranStatus,payStatus,createdDate,createdDateLocal,createdBy,modifiedDate
			,modifiedDateLocal,modifiedBy,approvedDate,approvedDateLocal,approvedBy,paidDate,paidDateLocal,paidBy
			,cancelRequestDate,cancelRequestDateLocal,cancelRequestBy,cancelReason,refund,cancelCharge,cancelApprovedDate
			,cancelApprovedDateLocal,cancelApprovedBy,blockedDate,blockedBy,lockedDate,lockedDateLocal,lockedBy,payTokenId
			,sendEOD,payEOD,cancelEOD,tranType,oldSysTranNo,pRouteID,senderName,receiverName,holdTranId,agentCrossSettRate
			,agentFxGain,treasuryTolerance,customerPremium,schemePremium,sharingValue,sharingType,externalBankCode,lockStatus
			,ContNo,uploadLogId,voucherNo,controlNo2,pBankType,expectedPayoutAgent,routedBy,routedDate,trnStatusBeforeCnlReq
			,schemeId,bonusPoint,incrRpt,isBonusUpdated,sRouteId, downloadedBy, downloadedDate, downloadLogId, pAmtAct, postedBy
			,postedDate, postedDateLocal
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.id= trt.t_id

		
		print '2'
		EXEC proc_PrintLog 'remitTran', 'tranSenders'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.tranSenders(
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,country,address,state,district,zipCode
			,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber
			,idPlaceOfIssue,issuedDate,validDate,extCustomerId,gender,fullName,holdTranId,ipAddress,address2,dcInfo,cwPwd
			,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,salary,companyName,notifySms,txnTestQuestion,txnTestAnswer
		)
		SELECT 
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,country,address,state,district,zipCode
			,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber
			,idPlaceOfIssue,issuedDate,validDate,extCustomerId,gender,fullName,holdTranId,ipAddress,address2,dcInfo,cwPwd
			,ttName,isFirstTran,customerRiskPoint,countryRiskPoint,salary,companyName,notifySms,txnTestQuestion,txnTestAnswer
		FROM tranSenders rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id
	
		print '3'
		EXEC proc_PrintLog 'tranSenders', 'tranReceivers'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.tranReceivers(
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,country,address,state,district,zipCode,city
			,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber,idPlaceOfIssue
			,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,validDate2,relationType,relativeName,stdName
			,stdLevel,stdRollRegNo,stdSemYr,stdCollegeId,feeTypeId,accountName,gender,fullName,holdTranId,address2,ipAddress,dcInfo
			,bankName, branchName, chequeNo, accountNo
		)
		SELECT 
			id,tranId,customerId,membershipId,firstName,middleName,lastName1,lastName2,country,address,state,district,zipCode,city
			,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,occupation,idType,idNumber,idPlaceOfIssue
			,issuedDate,validDate,idType2,idNumber2,idPlaceOfIssue2,issuedDate2,validDate2,relationType,relativeName,stdName
			,stdLevel,stdRollRegNo,stdSemYr,stdCollegeId,feeTypeId,accountName,gender,fullName,holdTranId,address2,ipAddress,dcInfo
			,bankName, branchName, chequeNo, accountNo
		FROM tranReceivers rt WITH(NOLOCK)
		INNER JOIN archiveTxnQueue trt ON rt.tranId= trt.t_id
	
		print '3'
		EXEC proc_PrintLog 'tranReceivers', 'remitTranCompliance'
		INSERT INTO FastMoneyPro_remit_Archive.dbo.remitTranCompliance(
			rowId,TranId,csDetailTranId,matchTranId,approvedRemarks,approvedBy,approvedDate,reason
		)
		SELECT 
			rowId,TranId,csDetailTranId,matchTranId,approvedRemarks,approvedBy,approvedDate,reason
		FROM remitTranCompliance rt WITH(NOLOCK) 
		INNER JOIN archiveTxnQueue trt ON rt.tranId = trt.t_id
		UNION ALL
		SELECT 
			rowId,TranId,csDetailTranId,matchTranId,approvedRemarks,approvedBy,approvedDate,reason
		FROM remitTranCompliance rt WITH(NOLOCK) 
		INNER JOIN archiveTxnQueue trt ON rt.TranId = trt.t_holdTranId

		COMMIT TRANSACTION;

		EXEC proc_PrintLog 'remitTranCompliance', 'STEP - 1, Moving Data - Completed'
		
	
	SELECT '0' errorCode, CAST((SELECT COUNT(*) FROM archiveTxnQueue) AS VARCHAR) + ' Transaction(s) archived successfully: Step:1' msg, NULL id

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT '1' rrrorCode, ERROR_MESSAGE() msg, NULL id
END CATCH



GO
