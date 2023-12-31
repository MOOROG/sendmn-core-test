USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendIntlReceipt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_sendIntlReceipt] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@tranId			INT				= NULL
	,@msgType			CHAR(1)			= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

SET NOCOUNT ON;

DECLARE @controlNoEncrypted	VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

IF @flag = 'receipt' 
BEGIN
	
	DECLARE @voucherNo VARCHAR(20), @bonusSchemeId int,@holdTranId INT

	--6.Message
	DECLARE  @headMsg				NVARCHAR(MAX)
			,@commonMsg			NVARCHAR(MAX)
			,@countrySpecificMsg	NVARCHAR(MAX)
			,@bonusPointPending		MONEY
			,@bonusPoint			MONEY
			,@customerId			INT
			
			,@sAgent		INT
			,@sCountry		VARCHAR(50)
			,@sBranch		INT
			,@rCountry		VARCHAR(50)
			,@rAgent		INT
			,@sUser			VARCHAR(50)
			,@sUserFullName	VARCHAR(75)
		     ,@paymentMethod	VARCHAR(75)
		

	SELECT 
		 @tranId			= rt.id
		,@holdTranId		= rt.holdTranId
		,@sCountry			= sc.countryId
		,@sAgent			= sAgent
		,@sBranch			= sBranch
		,@rCountry			= rc.countryId
		,@rAgent			= pAgent 
		,@sUser				= rt.createdBy
		,@voucherNo			= voucherNo
		,@customerId		= sen.customerId
		,@paymentMethod     = rt.paymentMethod
	FROM vwRemitTran rt WITH(NOLOCK)
	LEFT JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN countryMaster sc WITH(NOLOCK) ON rt.sCountry = sc.countryName
	LEFT JOIN countryMaster rc WITH(NOLOCK) ON rt.pCountry = rc.countryName
	WHERE rt.controlNo = @controlNoEncrypted
	
	SELECT 
		 tranId = ISNULL(trn.holdTranId, trn.id)
		 ,collMode =collMode
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		--Sender Information
		,sMemId = isnull(cm.postalcode,cm.membershipid)
		,sDob = CONVERT(varchar, sen.dob, 23)
		,sen.companyName 
		,sCustomerId = sen.customerId
		,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = sen.country
		,sNativeCountry=sen.nativeCountry
		,sAddress =ISNULL(sen.address,cm.ADDITIONALADDRESS)
		,sContactNo = isnull(sen.mobile, cm.mobile)
		,sIdType = sen.idType
		,sIdNo = sen.idNumber
		,Email = sen.email
		,SDV.detailTitle visaStatus
		
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
		,relWithSender =CASE WHEN ISNUMERIC(ISNULL(trn.relWithSender, 0))=1 THEN rel.detailTitle ELSE ISNULL(trn.relWithSender, '-') END
		
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
		,pAgent = trn.pAgentName
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
		,pBankName = ISNULL(trn.pBankName,ISNULL(BB.BANK_NAME,'[ANY WHERE] - '+ trn.pCountry) ) 
		,trn.pBranchName
		,BankName = trn.pBankName
		,BranchName = trn.pBankBranchName
		,headMsg = sa.headMessage
		,trn.accountNo
		,trn.pCountry
		,relationship =CASE WHEN ISNUMERIC(ISNULL(trn.relWithSender, '0'))=1 THEN rel.detailTitle ELSE ISNULL(trn.relWithSender,'-') END 
		,purpose =CASE WHEN ISNUMERIC(ISNULL(trn.purposeOfRemit, 0))=1 THEN por.detailTitle ELSE ISNULL(trn.purposeOfRemit, '-') END
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
	LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.typeTitle
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	LEFT JOIN schemeSetup SCH WITH (NOLOCK) ON SCH.rowId = trn.SchemeId
	LEFT JOIN dbo.staticDataValue SDV WITH (NOLOCK) ON SDV.valueId = cm.visaStatus
	LEFT JOIN tbl_japan_address_detail detail WITH (NOLOCK) ON detail.zip_code = sen.zipcode
	LEFT JOIN dbo.countryStateMaster SS(NOLOCK) ON cast(SS.stateId as int)= detail.state_Id
	LEFT JOIN dbo.API_BANK_LIST BB WITH (NOLOCK) ON BB.BANK_ID=trn.pBank
	LEFT JOIN dbo.staticDataValue por WITH(NOLOCK) ON CAST(por.valueId AS VARCHAR(200))=trn.purposeOfRemit
	LEFT JOIN dbo.staticDataValue rel WITH(NOLOCK) ON CAST(rel.valueId AS VARCHAR(200))=trn.relWithSender
	WHERE trn.controlNo = dbo.fnaencryptstring(@controlNo)
	
----------------------------------------------------------------------------------------------

	SELECT
		@sUserFullName = firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '')
	FROM applicationUsers WITH(NOLOCK) WHERE userName = @sUser
	
	SELECT @sCountry = countryId FROM countryMaster WITH(NOLOCK) 
		WHERE countryName = (SELECT agentCountry FROM agentMaster WHERE agentId = @sAgent)
	
	--Head Message
	SELECT @headMsg = headMessage FROM agentMaster WHERE agentId = @sBranch
	
	--print @sAgent
	IF @headMsg IS NULL	   
		SELECT @headMsg = agentDetails FROM agentMaster WHERE agentId = @sAgent
		
	IF @headMsg IS NULL	   
		SELECT @headMsg = headMsg FROM [message] WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
		
	IF(@headMsg IS NULL)
		SELECT @headMsg = headMsg FROM [message] WITH(NOLOCK) WHERE countryId IS NULL AND headMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	--Common Message
	SELECT @commonMsg = commonMsg FROM [message] WITH(NOLOCK) WHERE countryId = @sCountry AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	IF(@commonMsg IS NULL)
		SELECT @commonMsg = commonMsg FROM [message] WITH(NOLOCK) WHERE countryId IS NULL AND commonMsg IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Inactive') = 'Active'
	
	--Country Specific Message
	DECLARE @countryMsg TABLE(sCountry INT,sAgent INT,rCountry INT,rAgent INT,countrySpecificMsg NVARCHAR(MAX), paymentType varchar(100))
	
	INSERT INTO @countryMsg(sCountry,sAgent,rCountry,rAgent,countrySpecificMsg, paymentType)
	SELECT countryId,agentId,rCountry,rAgent,countrySpecificMsg,typeTitle 
	FROM [message] M WITH(NOLOCK) 
     LEFT JOIN serviceTypeMaster S WITH(NOLOCK) ON M.transactionType=S.serviceTypeId
     WHERE  isnull(rCountry,'') = isnull(@rCountry,'') AND ISNULL(M.isDeleted, 'N') = 'N' 
	AND ISNULL(M.isActive, 'Inactive') = 'Active' AND (msgType = 'S' OR msgType ='B')
	IF @countrySpecificMsg IS NULL
		SELECT @countrySpecificMsg = countrySpecificMsg	FROM @countryMsg WHERE sCountry = @sCountry 
		AND ISNULL(sAgent,'0') = ISNULL(@sAgent,ISNULL(sAgent,'0')) AND ISNULL(rCountry,'0') = ISNULL(@rCountry,ISNULL(rCountry,'0'))  
		AND ISNULL(rAgent,'0')=ISNULL(@rAgent,ISNULL(rAgent,0))

     IF @countrySpecificMsg IS NULL
		SELECT @countrySpecificMsg = countrySpecificMsg	FROM @countryMsg WHERE sCountry = @sCountry AND ISNULL(sAgent,'0') = ISNULL(@sAgent,ISNULL(sAgent,'0')) AND ISNULL(rCountry,'0') = ISNULL(@rCountry,ISNULL(rCountry,'0'))

	IF @countrySpecificMsg IS NULL
		SELECT @countrySpecificMsg = countrySpecificMsg	FROM @countryMsg WHERE sCountry = @sCountry AND ISNULL(sAgent,'0') = ISNULL(@sAgent,ISNULL(sAgent,'0')) 

     IF @countrySpecificMsg IS NULL
		SELECT TOP 1 @countrySpecificMsg = countrySpecificMsg FROM @countryMsg WHERE rCountry = @rCountry  AND ISNULL(paymentType,'0') = ISNULL(@paymentMethod,ISNULL(paymentType,'0')) 
    
	IF @countrySpecificMsg IS NULL
		SELECT TOP 1 @countrySpecificMsg = countrySpecificMsg FROM @countryMsg WHERE rCountry = @rCountry 
    
     --print @countrySpecificMsg

     IF @bonusSchemeId is not null
     SELECT @bonusPointPending= bonusPointPending,
		  @bonusPoint=isnull(bonusPoint,0) - isnull(Redeemed,0) 
	FROM customers WITH (NOLOCK)
     where isnull(isDeleted,'N') <> 'Y' and customerId = @customerId
	

	SELECT @headMsg AS headMsg,@commonMsg AS commonMsg, @countrySpecificMsg AS countrySpecificMsg, @sUserFullName AS sUserFullName
		,ISNULL(@bonusPointPending,0) bonusPointPending,ISNULL(@bonusPoint,0) bonusPoint,@bonusSchemeId [IsBonusOffer]


	--SELECT collMode,ISNULL(amt,0) AMT,collDate,@voucherNo [voucherNo] 
	--   FROM collectionDetails WITH (NOLOCK)
	--WHERE tranId = @tranId 
	
	SELECT 
		 bankName = ISNULL(B.bankName, 'Cash')
		,collMode
		,amt = ISNULL(amt, 0)
		,collDate
		,voucherNo = @voucherNo
		,narration
	FROM collectionDetails C WITH (NOLOCK)
	LEFT JOIN countryBanks B WITH (NOLOCK) ON C.countryBankId = B.countryBankId 
    WHERE tranId = @holdTranId

END

ELSE IF @flag = 'c'			--Check Transaction Control No
BEGIN
	DECLARE @tranStatus VARCHAR(20)
	SELECT @tranStatus = tranStatus FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF @tranStatus IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found', @controlNoEncrypted
		RETURN
	END
	IF @tranStatus = 'Cancel'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found', @controlNoEncrypted
		RETURN
	END
	IF @tranStatus = 'Block'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is blocked. Please Contact Head Office.', @controlNoEncrypted
		RETURN
	END
	DECLARE @agentId INT
	SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	IF @agentId = dbo.FNAGetHOAgentId()
	BEGIN
		EXEC proc_errorHandler 0, 'Transaction Found', @controlNoEncrypted
		RETURN
	END
	
	--SET @controlNoEncrypted = dbo.FNADEcryptString(@controlNoEncrypted)
	IF NOT EXISTS(SELECT 'X' FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND 
	(sBranch = (SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user)))
	BEGIN
		EXEC proc_errorHandler 1, 'You are not authorized to view this transaction', @controlNoEncrypted
		RETURN
	END
	EXEC proc_errorHandler 0, 'Transaction Found', @controlNo
END

GO
