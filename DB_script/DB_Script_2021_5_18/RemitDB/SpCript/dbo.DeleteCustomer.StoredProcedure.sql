USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[DeleteCustomer]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DeleteCustomer @email='mahendrapandit10@gmail.com'
SELECT * FROM dbo.customerMaster(NOLOCK) AS CM WHERE email='mahendrapandit10@gmail.com'
SELECT * FROM dbo.customerMaster_Deleted(NOLOCK) AS CM WHERE email='mahendrapandit10@gmail.com'

*/



CREATE PROC [dbo].[DeleteCustomer](@email VARCHAR(100))
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN

	DECLARE @customerId BIGINT=NULL,@balance MONEY=NULL, @txnCnt BIGINT=0

	SELECT 
		@balance=CM.availableBalance,@customerId=CM.customerId 
	FROM dbo.customerMaster(NOLOCK) AS CM WHERE CM.email=@email


	IF @customerId IS NULL
	BEGIN
		SELECT 1,'cannot delete the customer.' Msg
		RETURN
	END

	IF ISNULL(@balance,0)<>0
	BEGIN
		SELECT 1,'cannot delete the customer.' Msg
		RETURN
	END

	SELECT @txnCnt=COUNT('x') FROM dbo.tranSenders(NOLOCK) AS TS WHERE TS.customerId=@customerId
	IF @txnCnt>0
	BEGIN
		SELECT 1,'cannot delete the customer.' Msg
		RETURN
	END
	BEGIN TRAN

	INSERT INTO customerMaster_Deleted
	(
	customerId,membershipId,firstName,middleName,lastName1,lastName2,country,address,state,zipCode,district,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
	occupation,isBlackListed,createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate,isDeleted,lastTranId,relationId,relativeName,address2,fullName,postalCode,idExpiryDate,
	idType,idNumber,telNo,companyName,gender,salaryRange,bonusPointPending,Redeemed,bonusPoint,todaysSent,todaysNoOfTxn,agentId,branchId,memberIDissuedDate,memberIDissuedByUser,
	memberIDissuedAgentId,memberIDissuedBranchId,totalSent,idIssueDate,onlineUser,customerPassword,customerStatus,isActive,islocked,sessionId,lastLoginTs,howDidYouHear,ansText,
	ansEmail,state2,ipAddress,marketingSubscription,paidTxn,firstTxnDate,verifyDoc1,verifyDoc2,verifiedBy,verifiedDate,verifyDoc3,isForcedPwdChange,bankName,bankAccountNo,walletAccountNo,
	availableBalance,obpId,CustomerBankName,referelCode,isEmailVerified,verificationCode,SelfieDoc,HasDeclare,AuditDate,AuditBy,SchemeStartDate,invalidAttemptCount
	)
	SELECT 
		customerId,membershipId,firstName,middleName,lastName1,lastName2,country,address,state,zipCode,district,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue,customerType,
		occupation,isBlackListed,createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate,isDeleted,lastTranId,relationId,relativeName,address2,fullName,postalCode,idExpiryDate,
		idType,idNumber,telNo,companyName,gender,salaryRange,bonusPointPending,Redeemed,bonusPoint,todaysSent,todaysNoOfTxn,agentId,branchId,memberIDissuedDate,memberIDissuedByUser,
		memberIDissuedAgentId,memberIDissuedBranchId,totalSent,idIssueDate,onlineUser,customerPassword,customerStatus,isActive,islocked,sessionId,lastLoginTs,howDidYouHear,ansText,
		ansEmail,state2,ipAddress,marketingSubscription,paidTxn,firstTxnDate,verifyDoc1,verifyDoc2,verifiedBy,verifiedDate,verifyDoc3,isForcedPwdChange,bankName,bankAccountNo,walletAccountNo,
		availableBalance,obpId,CustomerBankName,referelCode,isEmailVerified,verificationCode,SelfieDoc,HasDeclare,AuditDate,AuditBy,SchemeStartDate,invalidAttemptCount
	FROM dbo.customerMaster(NOLOCK) AS CM 
	WHERE CM.customerId=@customerId

	DELETE FROM dbo.customerMaster WHERE customerId=@customerId

	COMMIT TRAN

	SELECT * FROM dbo.customerMaster(NOLOCK) AS CM WHERE CM.email=@email

	IF @@TRANCOUNT<>0
	BEGIN
		SELECT '1','Error Occured while deleting customer' Msg
		RETURN
	END

	SELECT '0','Customer DEleted' Msg
	RETURN
END
GO
