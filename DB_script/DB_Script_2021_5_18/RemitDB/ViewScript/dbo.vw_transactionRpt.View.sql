USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vw_transactionRpt]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_transactionRpt]
AS


SELECT 
	-->> transaction information
	 trn.id as TranNo
	,dbo.FNADecryptString(trn.controlNo) [ICN]
	,trn.approvedDate [Confirm Date]
	,trn.createdDate [TRN Date]
	,trn.paymentMethod [Payment Type]
	,trn.cAmt [Collected Amount]
	,trn.serviceCharge [Sevice Charge]
	,trn.customerRate [Exchange Rate]
	,trn.sCurrCostRate
	,trn.pCurrCostRate
	,trn.purposeOfRemit [Purpose of Remittance]
	,trn.pMessage [Remarks]
	,CASE	WHEN trn.tranStatus = 'Payment' and trn.payStatus ='Post' 
				then 'Post' 
			WHEN trn.tranStatus = 'Payment' and trn.payStatus <> 'Post' 
				THEN 'Unpaid' 
			ELSE  trn.tranStatus 
	END [TRN Status]
	,trn.paidDate [Paid Date]
	,trn.cancelApprovedDate [Cancelled Date]
	,trn.schemePremium [Exchange Rate Premium]
	,trn.handlingFee [Service Charge Discount]
	,trn.trantype [tranType]
	-->> sending agent information
	,am.agentName [Sending Agent Name]
	,am.agentCode [Sending Agent Code]
	,am1.agentName [Sending Branch Name]
	,am1.agentCode [Sending Branch Code]
	,trn.createdBy [Sending User]
	,trn.collCurr [Sending Currency]
	,trn.tAmt [Sending Amount]
	,trn.sAgentComm [Sender Commission]
	,trn.sCountry  [Sending Country]
	
	-->> sender information
	,sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '') [Sender Name]
	,sen.address  [Sender Address]
	,sen.city  [Sender City]
	,sen.membershipId [Sender Member ID]
	----,sen.idType [Sender Id Type]
	,[Sender Id Type]=CASE sen.idType
		WHEN '1301' THEN 'Citizenship'
		WHEN '1302' THEN 'Passport'
		WHEN '1303' THEN 'Election Card'
		WHEN '1304' THEN 'Driving License'
		WHEN '1305' THEN 'PAN/VAT Number'
		WHEN '1306' THEN 'Registration Number'
		WHEN '6208' THEN 'Valid Government ID'
		WHEN '8005' THEN 'Other'
		WHEN '8006' THEN 'Employment Authorization'
		WHEN '8007' THEN 'Learner Permit'
		WHEN '8008' THEN 'National ID'
		WHEN '8009' THEN 'Resident Card'
		WHEN '8010' THEN 'State Id' 
		ELSE CAST(sen.idType AS VARCHAR) END     


	,sen.idNumber [Sender Id Number]
	--,sen.idPlaceOfIssue [ID Issue District]
	,sen.mobile [Sender Mobile]
	,sen.validDate [Visa Expiry Date]
	,sen.nativeCountry [Sender Native Country]

	-->> receiviing agent information
	,pAm.agentName [Receiving Agent Name]
	,pAm.agentCode [Receiving Agent Code]
	,pAm1.agentName [Receiving Branch Name]
	,pAm1.agentCode [Receiving Branch Code]
	,pCountry [Receiving Country]
	,payoutCurr [Receiving Currency]
	,trn.pAmt [Receiving Amount]
	,trn.pAgentComm [Receiver Commission]
	,trn.paidBy [Receiving User]
	,trn.customerRate [Settlement Rate]
	
	-->> receiver information
	,rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '') [Receiver Name]
	,rec.address [Receiver Address]
	,rec.city [Receiver City]
	,rec.membershipId [Receiver Member ID]
	---,rec.idType [Receiver Id Type]
	,[Receiver Id Type]=CASE rec.idType
		WHEN '1301' THEN 'Citizenship'
		WHEN '1302' THEN 'Passport'
		WHEN '1303' THEN 'Election Card'
		WHEN '1304' THEN 'Driving License'
		WHEN '1305' THEN 'PAN/VAT Number'
		WHEN '1306' THEN 'Registration Number'
		WHEN '6208' THEN 'Valid Government ID'
		WHEN '8005' THEN 'Other'
		WHEN '8006' THEN 'Employment Authorization'
		WHEN '8007' THEN 'Learner Permit'
		WHEN '8008' THEN 'National ID'
		WHEN '8009' THEN 'Resident Card'
		WHEN '8010' THEN 'State Id' 
		ELSE CAST(rec.idType AS VARCHAR) END     
	,rec.idNumber [Receiver Id Number]
	,rec.idPlaceOfIssue [ID Issue District]
	,rec.mobile [Receiver Mobile]
	,trn.pBankName [Receiver Bank]
	,trn.pBankBranchName [Receiver Bank Branch]
	,trn.accountNo [Receiver A/C No]
	,rec.country [Receiver Country]
	,'' [External Bank Code]
	,'' [External Branch Code]	
	
	-->> filter fileds (where clause)
	,trn.sCountry
	,trn.pCountry
	,trn.sAgent
	,trn.pAgent
	,trn.sBranch
	,trn.pBranch
	,trn.approvedDate
	,trn.approvedDateLocal
	,trn.paidDate
	,trn.createdDate
	,trn.cancelApprovedDate
	,trn.paymentMethod
	,tranStatus = case when trn.tranStatus = 'Payment' and trn.payStatus = 'Post' then 'Post' else trn.tranStatus end 
	,trn.payStatus
	
	,sen.firstName senFirstName
	,rec.firstName recFirstName
	,sen.middleName senMiddleName
	,rec.middleName recMiddleName
	,sen.lastName1 senLastName
	,rec.lastName1 recLastName
	,sen.lastName2 senSecondLastName
	,rec.lastName2 recSecondLastName
	,sen.mobile senMobile
	,rec.mobile recMobile
	,sen.email senEmail
	,rec.email recEmail
	,sen.idNumber senIdNumber
	,rec.idNumber recIdNumber
	,sen.state senState
	,rec.state recState
	,sen.city senCity
	,rec.city recCity
	,sen.zipCode senZip
	,rec.zipCode recZip
	,trn.id TranId
	,dbo.FNADecryptString(trn.controlNo) controlNo
	,trn.cAmt
	,trn.pAmt
	,'' senderCompany
	
	FROM vwRemitTran trn WITH(NOLOCK) 
	LEFT JOIN vwTranSenders sen ON sen.tranId=trn.id
	LEFT JOIN vwTranReceivers rec ON rec.tranId= trn.id
	LEFT JOIN agentMaster am WITH(NOLOCK) ON trn.sAgent=am.agentId
	LEFT JOIN agentMaster am1 ON am1.agentId=trn.sBranch
	LEFT JOIN agentMaster pAm WITH(NOLOCK) ON trn.pAgent=pAm.agentId
	LEFT JOIN agentMaster pAm1 ON pAm1.agentId=trn.pBranch		

	



GO
