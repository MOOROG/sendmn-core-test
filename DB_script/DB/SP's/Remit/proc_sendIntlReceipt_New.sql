
ALTER PROC [dbo].[proc_sendIntlReceipt_New] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@tranId			VARCHAR(MAX)	= NULL
	,@msgType			CHAR(1)			= NULL
) 
AS

SET NOCOUNT ON;

IF @flag = 'receipt' 
BEGIN
	IF @tranId IS NOT NULL
	BEGIN
		SELECT value INTO #tempTranId FROM dbo.Split(',', @tranId)
	END

	SELECT 
		 tranId = ISNULL(trn.holdTranId, trn.id)
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		
		--Sender Information
		,sMemId = cm.membershipId
		,sen.companyName 
		,sCustomerId = sen.customerId
		,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = sen.country
		,sNativeCountry=sen.nativeCountry
		--,sAddress = isnull(cm.zipcode,'') +  isnull(',' + SS.stateName, '') +ISNULL(', '+CM.CITY, '') + isnull(', ' +cm.street,'') + isnull(', ' + cm.additionaladdress,'')
		,sAddress = ISNULL(substring(detail.zip_code,1,3),'')+'-'+ ISNULL(substring(detail.zip_code,4,7),'') +  isnull(',' + SS.stateName, '') +  isnull(',' + detail.city_name, '') + isnull(', ' +detail.street_name,'') +   ISNULL( ', '+ sen.address2,sen.address)
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		,sIdType = sen.idType
		,sIdNo = sen.idNumber
		,Email = sen.email
		,sDob = CAST(sen.dob AS DATE)
		,SDV.DETAILTITLE visaStatus
		
		--Receiver Information
		,rMemId = rec.membershipId
		,idExpiry = ISNULL(CONVERT(VARCHAR,sen.validDate,101),'-')
		,rCustomerId = rec.customerId
		,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,rCountryName = rec.country
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = rec.idType
		,rIdNo = rec.idNumber
		,relWithSender = trn.relWithSender
		
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
		,pAgent = ISNULL(trn.pAgentName, '-')
		,pAgentDistrict = rec.district
		,pAgentLocation = rec.state
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
		,paymentMode = CASE trn.paymentMethod WHEN 'Cash Payment' THEN 'Cash Pay' WHEN 'Bank Deposit' THEN 'Bank Transfer' ELSE trn.paymentMethod END 
		,stm.category
		,pBankName = ISNULL(trn.pBankName, '[ANY WHERE] - ' + trn.pCountry)
		,trn.pBranchName
		,BankName = trn.pBankName
		,BranchName = trn.pBankBranchName
		,headMsg = sa.headMessage
		,trn.accountNo
		,trn.pCountry
		,relationship = ISNULL(trn.relWithSender, '-')
		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,occupation = ISNULL(sen.occupation,'-')
		,collMode = trn.collMode
		,trn.collCurr
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,trn.tranStatus
		,trn.payStatus
		,payoutMsg = ISNULL(trn.pMessage, '-')
		,trn.createdBy
		,createdDate = trn.createdDate
		,trn.approvedBy
		,trn.approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.payTokenId
		,trn.createdDateLocal
		
		,SCH.action [schemeAction]
		,trn.handlingFee [schemeFee]
		,iTelSoftPinNumber = ''
	FROM vwRemitTran trn WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.CUSTOMERID = SEN.CUSTOMERID
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	INNER JOIN #tempTranId t ON t.value = trn.id
	LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN schemeSetup SCH WITH (NOLOCK) ON SCH.rowId = trn.SchemeId
	LEFT JOIN STATICDATAVALUE SDV (NOLOCK) ON SDV.VALUEID = CM.visaStatus
	LEFT JOIN tbl_japan_address_detail detail WITH (NOLOCK) ON detail.zip_code = sen.zipcode
	LEFT JOIN dbo.countryStateMaster SS(NOLOCK) ON cast(SS.stateId as int)= detail.state_Id
END
