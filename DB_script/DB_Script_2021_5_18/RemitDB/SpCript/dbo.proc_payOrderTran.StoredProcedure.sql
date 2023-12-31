USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payOrderTran]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC proc_payTran @flag = 'details', @user = 'bajrashali_b1', @tranId = '1', @controlNo = '91191505349'

*/

CREATE proc [dbo].[proc_payOrderTran] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(50)		= NULL
	,@user				VARCHAR(50)		= NULL
	,@agentId			VARCHAR(50)		= NULL
) 
AS

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE
		 @code						VARCHAR(50)
		,@userName					VARCHAR(50)
		,@password					VARCHAR(50)
		,@controlNoEncrypted		VARCHAR(200)  

SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

BEGIN TRY
IF @flag = 'payOrder'	
BEGIN
	DECLARE @tranId INT
	SELECT @tranId = id FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
	IF NOT EXISTS(SELECT tranId,newPAgent,newPAgentName FROM errPaidTran WHERE approvedBy IS NOT NULL AND tranId = @tranId AND tranStatus = 'Unpaid' AND newPBranch = @agentId)
	BEGIN
		EXEC proc_errorHandler 1000, 'No Transaction Found', @controlNoEncrypted
		RETURN;
	END
	
	EXEC proc_errorHandler 0, 'Transaction Verification Successful', @controlNoEncrypted
	SELECT 
		 trn.id
		,errTranId = ERRT.eptId
		,controlNo = dbo.FNADecryptString(trn.controlNo)
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
		
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,rCountryName = rec.country
		,rStateName = rec.state
		,rDistrict = rec.district
		,rCity = rec.city
		,rAddress = rec.address
		,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)
		,rIdType = rec.idType
		,rIdNo = rec.idNumber
		
		,sAgent = trn.sBranchName
		,sAgentCountry = sa.agentCountry
		
		,pBranchName = ISNULL(trn.pBranchName, 'Any')
		,pCountryName = trn.pCountry
		,pStateName = trn.pState
		,pDistrictName = trn.pDistrict
		,pLocationName = pLoc.districtName
		,pAddress = pa.agentAddress
		
		,trn.tAmt
		,trn.serviceCharge
		,handlingFee = ISNULL(trn.handlingFee, 0)
		,trn.cAmt
		,trn.pAmt
		
		,relationship = ISNULL(trn.relWithSender, '-')
		,purpose = ISNULL(trn.purposeOfRemit, '-')
		,sourceOfFund = ISNULL(trn.sourceOfFund, '-')
		,trn.pAmt
		,collMode = trn.collMode
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,trn.tranStatus
		,trn.payStatus
		,payoutMsg = ISNULL(trn.pMessage, '-')
		,send_agent = COALESCE(trn.sBranchName, trn.sAgentName)
		,txn_date = trn.createdDateLocal
		,trn.payTokenId
	FROM remitTran trn WITH(NOLOCK)
	INNER JOIN errPaidTran ERRT WITH(NOLOCK) ON trn.id = ERRT.tranId
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId	
	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
	LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
	WHERE trn.controlNo = @controlNoEncrypted AND ERRT.tranId = @tranId  AND ERRT.newPBranch = @agentId
	
	--Log Details---------------------------------------------------------------------------
	SELECT 
		 message
		--,createdBy = au.firstName + ISNULL( ' ' + au.middleName, '') + ISNULL( ' ' + au.lastName, '')
		,trn.createdBy
		,trn.createdDate
	FROM tranModifyLog trn WITH(NOLOCK)
	LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName 
	WHERE trn.controlNo = @controlNoEncrypted
	ORDER BY trn.createdDate DESC

	
END

END TRY
BEGIN CATCH

     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentId

END CATCH

	



GO
