USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_sendIntlReceipt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_online_sendIntlReceipt] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(200) = NULL
	,@tranId			INT			 = NULL
	,@fltAmount			VARCHAR(20)  = NULL
	,@intStatus			VARCHAR(200) = NULL
) 
AS
SET NOCOUNT ON;
IF @flag = 'receipt' --All transaction information (sender, receiver, payout)
BEGIN
	SELECT '0' ErrorCode, 'Send Transaction Success - Receipt' Msg
			
	SELECT 
		 tranId = ISNULL(trn.holdTranId, trn.id)
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		
		--Sender Information
		,sMemId = sen.membershipId
		,sCustomerId = sen.customerId
		,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = sen.country
		,sNativeCountry=sen.nativeCountry
		,sAddress = sen.address
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		,sIdType = sen.idType
		,sIdNo = sen.idNumber
		,Email = sen.email
		,sPostalCode = sen.zipcode 
		,sCity = sen.city
		,companyName = sen.companyName
		
		--Receiver Information
		,rMemId = rec.membershipId
		,idExpiry = CONVERT(VARCHAR,sen.validDate,101)
		,rCustomerId = rec.customerId
		,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,rCountryName = rec.country
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = rec.idType
		,rIdNo = rec.idNumber
		,relWithSender = trn.relWithSender
		,rCity	= rec.city
		,rec.firstName AS rFirstName
		,rec.middleName AS rMiddleName
		,rec.lastName1 + ISNULL( ' ' + rec.lastName2, '') AS rLastName
		,rec.email AS rEmail
		,rec.state AS rState
		
		--Sending Agent Information
		,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN trn.sSuperAgentName ELSE trn.sAgentName END
		,sBranchName = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		,headMsg = sa.headMessage
		,sAgentLocation = sLoc.districtName
		,sAgentAddress = sa.agentAddress
		,agentPhone1 = sa.agentPhone1
		
		--Payout Agent Information
		,pAgentCountry = trn.pCountry
		,trn.sCountry
		,pAgent = ISNULL(trn.pBankName, trn.pAgentName)
		
		,sPremium = ISNULL(ROUND((tAmt * schemePremium) / customerRate, 4),0)
		,exRatePremium = ISNULL(schemePremium,0)
		,pPremium = ISNULL((tAmt * schemePremium),0)
		,premiumDisc = 0
		,trn.collMode
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,netServiceCharge = serviceCharge
		,totalServiceCharge = serviceCharge + ISNULL(handlingFee, 0)
		
		,perAmt = '1'
		,scAmt2 = serviceCharge - ISNULL(trn.handlingFee, 0)
		,exRate = customerRate + ISNULL(schemePremium, 0)
		,trn.cAmt
		,trn.pAmt
		,trn.paymentMethod
		,trn.accountNo
		,paymentMode = CASE trn.paymentMethod WHEN 'Cash Payment' THEN 'Cash Pay' WHEN 'Bank Deposit' THEN 'Bank Transfer' ELSE trn.paymentMethod END 
		,stm.category
		,pBankName = CASE WHEN trn.paymentMethod = 'Cash Payment' THEN '[ANY WHERE] - ' + trn.pCountry ELSE trn.pBankName END
		,pBranchName = trn.pBankBranchName
		,BankName = trn.pBankName
		,BranchName = trn.pBankBranchName
		,headMsg = sa.headMessage
		,trn.accountNo
		,trn.pCountry
		,relationship = ISNULL(trn.relWithSender, '')
		,purpose = ISNULL(trn.purposeOfRemit, '')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '')
		,occupation = ISNULL(sen.occupation,'')
		,collMode = trn.collMode
		,trn.collCurr
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,trn.tranStatus
		,payStatus = CASE WHEN (trn.payStatus='Unpaid' AND trn.transtatus='Payment' OR trn.tranStatus='Post') THEN 'Ready for Payment' 
					WHEN (trn.payStatus='Unpaid' AND trn.transtatus='Hold') THEN 'Waiting for Approval' 
					WHEN (trn.payStatus='Unpaid' AND trn.transtatus='Compliance Hold') THEN 'Waiting for Approval' ELSE trn.payStatus 
					END
		,payoutMsg = ISNULL(trn.pMessage, '')
		,trn.createdBy
		--,createdDate = dbo.FNADateFormatTZ(trn.createdDate,trn.createdBy)
		,createdDate = trn.createdDate
		,trn.approvedBy 
		,trn.approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.payTokenId
		,trn.createdDateLocal
		,SCH.action [schemeAction]
		,trn.handlingFee [schemeFee]
		,[custStatus]		= 'Active'
		,couponName			=	''
		,discountType		=	''
		,discountValue		=	''
		,discountPercent	=	''
	FROM vwRemitTran trn WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN schemeSetup SCH WITH (NOLOCK) ON SCH.rowId = trn.SchemeId
	WHERE trn.id = @tranId or trn.holdTranId = @tranId
	
END
GO
