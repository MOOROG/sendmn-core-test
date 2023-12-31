USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_transactionViewEduPay]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[proc_transactionViewEduPay] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@controlNo			VARCHAR(30)		= NULL
	,@tranId			BIGINT			= NULL
	,@message			VARCHAR(500)	= NULL
	,@messageComplaince VARCHAR(500)	= NULL
	,@messageOFAC		VARCHAR(500)	= NULL
	,@lockMode			CHAR(1)			= NULL
	,@viewType			VARCHAR(50)		= NULL
	,@viewMsg			VARCHAR(MAX)	= NULL
	,@branch			INT				= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

SET @controlNo = UPPER(@controlNo)
IF @tranId IS NULL 
	SELECT @tranId=id FROM remitTran WHERE controlNo=dbo.FNAEncryptString(@controlNo)
DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

DECLARE @controlNoEncrypted VARCHAR(100)
		
		,@code						VARCHAR(50)
		,@userName					VARCHAR(50)
		,@password					VARCHAR(50)	
		
SET NOCOUNT ON
SET XACT_ABORT ON

IF @flag = 's'
BEGIN
	DECLARE @tranStatus VARCHAR(20)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	--Transaction View History--------------------------------------------------------------------------------------
	
		EXEC proc_tranViewHistory 'i', @user, @tranId, @controlNo, NULL,@viewType,@viewMsg
	
	--End-----------------------------------------------------------------------------------------------------------
	--Transaction Details------------------------------------------------------------
	SELECT 
		 tranId = trn.id
		,controlNo = dbo.FNADecryptString(trn.controlNo)
		
		--Sender Information
		,sMemId = sen.membershipId
		,sCustomerId = sen.customerId
		,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = sen.country
		,sStateName = sen.state
		,sDistrict = sen.district
		,sCity = sen.city
		,sAddress = sen.address
		,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)
		,sIdType = sen.idType
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
		,rCity = rec.city
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = ISNULL(rec.idType, rec.idType2)
		,rIdNo = ISNULL(rec.idNumber, rec.idNumber2)
		
		--Sending Agent Information
		,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN '-' ELSE trn.sAgentName END
		,sBranchName = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		,sAgentState = sa.agentState
		,sAgentDistrict = sa.agentDistrict
		,sAgentLocation = sLoc.districtName
		,sAgentCity = sa.agentCity
		,sAgentAddress = sa.agentAddress
		
		--Payout Agent Information
		,pAgentName = CASE WHEN trn.pAgentName = trn.pBranchName THEN '-' ELSE trn.pAgentName END
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
		,trn.pAmt
		
		,relationship = ISNULL(trn.relWithSender, '-')
		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,collMode = trn.collMode
		,trn.collCurr
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,BranchName = trn.pBankBranchName
		,trn.accountNo
		,BankName = trn.pBankName
		,trn.tranStatus
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
		,stdName
		,stdLevel = sl.name
		,stdRollRegNo
		,stdSemYr = dbo.FNAGetDataValue(stdSemYr)
		,stdCollegeId
		,feeTypeId = sf.feeType
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	LEFT JOIN apiLocationMapping ALM WITH(NOLOCK) ON pLoc.districtCode=ALM.apiDistrictCode
	LEFT JOIN zoneDistrictMap ZDM WITH(NOLOCK) ON ZDM.districtId=ALM.districtId
	LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
	left join schoolFee sf with(nolock) on sf.rowId = rec.feeTypeId
	left join schoolLevel sl with(nolock) on sl.rowId = rec.stdLevel
	WHERE trn.controlNo = @controlNoEncrypted OR trn.id = @tranId
	
	--End of Transaction Details------------------------------------------------------------
	
	--Lock Transaction----------------------------------------------------------------------
	IF (@lockMode = 'Y')
	BEGIN
		UPDATE remitTran SET
			 tranStatus = 'Lock'
			,lockedBy = @user
			,lockedDate = GETDATE()
			,lockedDateLocal = dbo.FNADateFormatTZ(GETDATE(), @user)
		WHERE (tranStatus = 'Payment' AND tranStatus <> 'CancelRequest') 
		  AND payStatus = 'Unpaid' AND (controlNo = @controlNoEncrypted OR id = @tranId)

	END
	--End of Lock Transaction---------------------------------------------------------------
	
	--Log Details---------------------------------------------------------------------------
	SELECT 
		 rowId
		,message
		,trn.createdBy
		,trn.createdDate
		,isnull(trn.fileType,'')fileType
	FROM tranModifyLog trn WITH(NOLOCK)
	LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
	WHERE trn.tranId = @tranId --OR trn.controlNo = @controlNoEncrypted
	ORDER BY trn.createdDate DESC

END




GO
