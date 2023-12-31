USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_CancelTxnReceipt]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_CancelTxnReceipt]
(
	 @user	VARCHAR(30)		= NULL
	,@controlNo	VARCHAR(50) = NULL
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON


	BEGIN
		 SELECT 
			dbo.FNADecryptString(ct.controlNo) controlNo
			,ct.createdBy	
			,ct.createdDate	  	
			,ct.approvedBy
			,ct.approvedDate
			,ct.cancelRequestBy
			,ct.cancelRequestDate
			,ct.cancelApprovedBy
			,ct.cancelApprovedDate
			,ct.tranId
			,'need to update' expectedPayoutAgent
			,ct.paidBy
			,ct.paidDate
			,ct.paidDateLocal
			,ct.createdDateLocal
			,ct.approvedDateLocal
			
			,s.firstName + isnull(' '+s.middleName,'')+isnull(' '+s.lastName1,'')+isnull(' '+s.lastName2,'') senderName
			,s.address sAddress
			,s.country sCountryName
			,s.city   sCity
			,s.mobile sContactNo
			,s.homePhone sTelNo
			,s.idType sIdType
			,s.idNumber sIdNo
			,s.validDate
			,s.email   sEmail
			,s.membershipId
			,s.nativeCountry   nativeCountry
			,s.membershipId sMemId
			
			,r.firstName + isnull(' '+r.middleName,'')+isnull(' '+r.lastName1,'')+isnull(' '+r.lastName2,'') receiverName
			,r.address rAddress
			,r.country  rCountryName
			,r.city   rCity
			,r.mobile  rContactNo
			,r.homePhone   rTelNo
			,r.idType  rIdType
			,r.idNumber   rIdNo
			,r.validDate
			,r.relationType 
			
			,ct.sAgentName
			,ct.sBranchName
			,sm.agentAddress  sAgentAddress
			,sm.agentCountry  sCountryName
			
			,ct.pAgentName 
			,ct.pBranchName
			,rm.agentAddress  pAgentAddress
			,rm.agentCountry  pAgentCountry
			
			,ct.cAmt
			,ct.serviceCharge
			,ct.collCurr
			,ct.tAmt
			,ct.collCurr
			,ct.customerRate  custRate
			,ct.pAmt
			,ct.payoutCurr 
			,ct.pAgentComm
			,ct.pAgentCommCurrency 
			,ct.collMode CashOrBank
			
			
			,ct.paymentMethod
			,ct.payStatus  
			,ct.tranStatus
			,ct.accountNo  accountNo
			,ct.pBankName  BankName
			,ct.pBankBranchName BranchName  
			,ct.sourceOfFund
			,ct.purposeOfRemit
			,ct.pMessage payoutMsg
			,ct.relWithSender relationship
			,ct.payTokenId 
		
		FROM cancelTranHistory ct WITH (NOLOCK)
		LEFT JOIN cancelTranSendersHistory s WITH (NOLOCK) ON s.tranId = ct.tranId
		LEFT JOIN cancelTranReceiversHistory r WITH (NOLOCK) ON r.tranId = ct.tranId
		INNER JOIN agentMaster sm WITH (NOLOCK) ON sm.agentId= ct.sBranch
		LEFT JOIN  agentMaster rm WITH (NOLOCK) ON rm.agentId = ct.pBranch
		WHERE ct.controlNo = dbo.FNAEncryptString(@controlNo)
		
		
	SELECT 
		 bankName = ISNULL(B.bankName, 'Cash')
		,C.collMode
		,amt = ISNULL(amt, 0)
		,collDate
		,voucherNo = A.voucherNo
		,narration
	FROM collectionDetails C WITH (NOLOCK)	
	LEFT JOIN countryBanks B WITH (NOLOCK) ON C.countryBankId = B.countryBankId 
	INNER JOIN cancelTranHistory A WITH(NOLOCK) ON C.tranId=A.tranId
    WHERE A.controlNo = dbo.FNAEncryptString(@controlNo)

END

GO
