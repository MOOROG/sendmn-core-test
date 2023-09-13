SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROC [dbo].[proc_customerSoa] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@tranId			VARCHAR(MAX)	= NULL
	,@msgType			CHAR(1)			= NULL
	,@customerId		VARCHAR(50) = NULL
    ) 
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @errorMessage VARCHAR(MAX)
	IF @flag = 'cusotmerSoaReceipt' 
	BEGIN
		IF @tranId IS NOT NULL
		BEGIN
			SELECT value INTO #tempTranId FROM dbo.Split(',', @tranId)
		END

	SELECT 
		 tranId = ISNULL(trn.holdTranId, trn.id)
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		
		--Sender Information
		,sMemId = sen.membershipId
		,sCustomerId = isnull(cm.postalcode,cm.membershipId)
		,senderName = cm.firstName + ISNULL( ' ' + cm.middleName, '') + ISNULL( ' ' + cm.lastName1, '') + ISNULL( ' ' + cm.lastName2, '')	
		,sAddress = cm.address
		,sDob = CONVERT(VARCHAR(10),cm.dob,121)

		
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
	
		--Payout Agent Information
		,pAgentCountry = trn.pCountry
		,trn.sCountry
		,trn.collCurr
		,trn.payoutCurr
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
		,occupation = ISNULL(cm.occupation,'-')
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
		,CAST(trn.approvedDate AS DATE) approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.payTokenId
		,trn.createdDateLocal
		
		,SCH.action [schemeAction]
		,trn.handlingFee [schemeFee]
		,iTelSoftPinNumber = ''
		,convert(varchar(10),GetDate(),111) PrintTime
	FROM vwRemitTran trn WITH(NOLOCK)
	INNER JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	INNER JOIN #tempTranId t ON t.value = trn.id
	INNER JOIN customerMaster cm on cm.customerid = sen.customerid
	LEFT JOIN countryStateMaster csm (nolock) on cast(csm.stateId as varchar) = cm.state
	LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN schemeSetup SCH WITH (NOLOCK) ON SCH.rowId = trn.SchemeId
	where trn.transtatus <> 'cancel'
END

	IF @flag ='s'
		BEGIN
		SELECT fullName FROM dbo.customerMaster WHERE customerId = @customerId
		END
        
END TRY
BEGIN CATCH 
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
	SET @errorMessage = ERROR_MESSAGE() 
	EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH
GO

