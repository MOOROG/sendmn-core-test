USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PartnerPinView]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_PartnerPinView] (	 
	 @flag				CHAR(1)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@tranId			BIGINT			= NULL
	,@lockMode			CHAR(1)			= NULL
	,@viewType			VARCHAR(50)		= NULL
	,@viewMsg			VARCHAR(MAX)	= NULL
) 
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
	
DECLARE @controlNoEncrypted VARCHAR(100)
			
IF @flag = 's'
BEGIN
	EXEC proc_tranViewHistory 'i', @user, @tranId, @controlNo, NULL,@viewType,@viewMsg
	
	SET @controlNoEncrypted = DBO.FNAENCRYPTSTRING(@controlNo)
	
	SELECT @tranId = ID FROM REMITTRAN(NOLOCK) WHERE ContNo = @controlNo
	IF @tranId IS NULL
		SELECT @tranId = ID FROM REMITTRAN(NOLOCK) WHERE ControlNo = @controlNoEncrypted

	--Transaction Details
	SELECT 
		 tranId = trn.id
		,PartnerPIN = ISNULL(trn.ContNo, '') + ' / '+ dbo.FNADecryptString(trn.controlNo2)
		,controlNo =dbo.FNADecryptString(trn.controlNo)
		
		--Sender Information
		,sMemId = sen.membershipId
		,sCustomerId = sen.customerId
		,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = trn.sCountry
		,sStateName = sen.state
		,sDistrict = sen.district
		,sCity = isnull(sen.city,'')
		,sAddress = sen.address
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		,sIdType = ISNULL(sdv.detailTitle,sen.idType)
		,sIdNo = sen.idNumber
		,sValidDate = sen.validDate
		,sEmail = sen.email
		,extCustomerId = sen.extCustomerId

		--Receiver Information
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,rCountryName = rec.country
		,rStateName = rec.state
		,rDistrict = rec.district
		,rCity = isnull(rec.city,'')
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = ISNULL(rec.idType2, rec.idType)
		,rIdNo = ISNULL(rec.idNumber2, rec.idNumber)+ isnull(' ' + rec.idPlaceOfIssue2,'')
	
		
		--Sending Agent Information
		,sAgentEmail = sa.agentEmail1
		,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN '-' ELSE trn.sAgentName END
		,sBranchName = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		,sAgentState = sa.agentState
		,sAgentDistrict = sa.agentDistrict
		,sAgentLocation = sLoc.districtName
		,sAgentCity = sa.agentCity
		,sAgentAddress = sa.agentAddress
		
		--Payout Agent Information
		,pAgentName = case when trn.pAgentName is null then '[Any Where]' else CASE WHEN trn.pAgentName = trn.pBranchName THEN '-' ELSE trn.pAgentName END end
		,pBranchName = trn.pBranchName
		,pAgentCountry = trn.pCountry
		,pAgentState = trn.pState
		,pAgentDistrict = trn.pDistrict
		,pAgentLocation = pLoc.districtName + ISNULL(', ' + ZDM.districtName,'')
		,pAgentCity = pa.agentCity
		,pAgentAddress = pa.agentAddress
		
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,sAgentComm = isnull(sAgentComm,0)
		,sAgentCommCurrency = ISNULL(sAgentCommCurrency,0)
		,pAgentComm = ISNULL(pAgentComm,0)
		,pAgentCommCurrency = ISNULL(pAgentCommCurrency,0)
		,exRate = customerRate
		,trn.cAmt
		,pAmt = FLOOR(trn.pAmt)
		
		,relationship = ISNULL(trn.relWithSender, ' ')+ ISNULL('   '+ rec.relationType,'') + ISNULL(': '+rec.relativeName,'')

		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,collMode = trn.collMode
		,trn.collCurr
		,paymentMethod = UPPER(trn.paymentMethod)
		,trn.payoutCurr
		,BranchName = trn.pBankBranchName
		,accountNo = trn.accountNo
		,BankName = trn.pBankName
		,tranStatus = CASE when trn.payStatus = 'Post' and trn.tranType='D' then 'Post' else trn.tranStatus end        
		,trn.payStatus
		
		,payoutMsg = ISNULL(trn.pMessage, '-')
		,trn.createdBy
		,trn.createdDate
		,trn.approvedBy
		,trn.approvedDate
		,trn.paidBy
		,trn.paidDate
		,trn.cancelRequestBy
		,trn.cancelRequestDate
		,trn.cancelApprovedBy
		,trn.cancelApprovedDate
		,trn.lockedBy
		,trn.lockedDate
		,trn.payTokenId
		,trn.tranStatus
		,trn.tranType
		,trn.holdTranId
		,sTelNo	= ISNULL(sen.homephone, sen.workphone)
		,rTelNo = ISNULL(rec.homephone, rec.workphone)
		,CashOrBank = ''
		,purposeOfRemit = ISNULL(trn.purposeOfRemit, '-')
		,custRate = isnull(customerRate,0) +isnull(schemePremium,0)
		,settRate = agentCrossSettRate
		,nativeCountry	= sen.nativeCountry
	FROM vwRemitTran trn WITH(NOLOCK)
	LEFT JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	LEFT JOIN apiLocationMapping ALM WITH(NOLOCK) ON pLoc.districtCode=ALM.apiDistrictCode
	LEFT JOIN zoneDistrictMap ZDM WITH(NOLOCK) ON ZDM.districtId=ALM.districtId
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)
	WHERE trn.ID =@tranId
	--End of Transaction Details------------------------------------------------------------
	
	--Log Details---------------------------------------------------------------------------
	SELECT 
		 rowId
		,message
		,trn.createdBy
		,trn.createdDate
		,isnull(trn.fileType,'')fileType
	FROM tranModifyLog trn WITH(NOLOCK)
	LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
	WHERE trn.tranId = @tranId 
	ORDER BY trn.rowId DESC

	SELECT 
		 bankName = 'Cash'
		,collMode = 'Cash'
		,amt = ''
		,collDate = ''
		,voucherNo = ''
		,narration = 'Cash Collection'
END
GO
