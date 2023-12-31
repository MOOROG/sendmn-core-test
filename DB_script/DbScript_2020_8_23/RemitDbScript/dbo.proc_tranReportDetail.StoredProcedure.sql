USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranReportDetail]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_tranReportDetail @flag = 'details', @tranId = '501'
EXEC proc_tranReportDetail @flag = 'details', @user = 'admin', @tranId = '501'

*/

CREATE proc [dbo].[proc_tranReportDetail] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@tranId			INT				= NULL	
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS


DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

SET NOCOUNT ON
SET XACT_ABORT ON
--select * from customers

IF @flag = 'details'
BEGIN
	SELECT 
		 trn.id
		,trn.controlNo
		
		,sMemId = sen.membershipId
		,sCustomerId = sen.customerId
		,sName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
		,sCountryName = trn.sCountry 
		,sStateName = sen.[state]
		,sCity = sen.city
		,sAddress = sen.[address]
		,sContactNo = COALESCE(sen.mobile, sen.homePhone, sen.workPhone)
		
		,rMemId = rec.membershipId
		,rCustomerId = rec.customerId
		,rName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		,rCountryName = rec.country
		,rStateName = rec.[state]
		,rCity = rec.city
		,rAddress = rec.[address]
		,rContactNo = COALESCE(rec.mobile, rec.homePhone, rec.workPhone)
		
		,senAgentName = sa.agentName
		,senCountryName = trn.sCountry
		,senLocation = sd.districtName
		,senAddress = sa.agentAddress 
		
		,pAgentName = ISNULL(pa.agentName, '[Any]')
		,pCountryName = trn.pCountry 
		,pStateName = trn.pState
		,pLocation = pd.districtName
		,pAddress = pa.agentAddress
		
		,relationship = trn.relWithSender
		,purpose = trn.purposeOfRemit
		,trn.tAmt
		,trn.serviceCharge
		,trn.handlingFee
		,trn.cAmt
		,trn.collCurr
		,exRate = 1
		,trn.pAmt
		,trn.payoutCurr
		,collMode = trn.collMode
		,paymentMethod = trn.paymentMethod
		,trn.payoutCurr
		,tranStatus = trn.tranStatus
		,payStatus = trn.payStatus
		,pMessage = ISNULL(trn.pMessage, 'N/A')
	FROM remitTran trn WITH(NOLOCK)
	LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
	LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId

	LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sAgent = sa.agentId
	LEFT JOIN api_districtList sd WITH(NOLOCK) ON sa.agentLocation = sd.districtCode
	
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pAgent = pa.agentId
	LEFT JOIN api_districtList pd WITH(NOLOCK) ON pa.agentLocation = pd.districtCode
	WHERE trn.id = @tranId
		
END





GO
