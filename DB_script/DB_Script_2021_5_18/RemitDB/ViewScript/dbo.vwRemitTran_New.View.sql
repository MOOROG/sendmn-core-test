USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwRemitTran_New]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwRemitTran_New]
AS

SELECT 
	 [id]
	,[holdTranId]
	,[controlNo]
	,[sCurrCostRate],[sCurrHoMargin],[sCurrSuperAgentMargin],[sCurrAgentMargin]
	,[pCurrCostRate],[pCurrHoMargin],[pCurrSuperAgentMargin],[pCurrAgentMargin]
	,[agentCrossSettRate],[customerRate],[sAgentSettRate],[pDateCostRate]
	,[agentFxGain],[treasuryTolerance],[customerPremium],[schemePremium]
	,[sharingValue],[sharingType]
	,[serviceCharge],[handlingFee]
	,[sAgentComm],[sAgentCommCurrency],[sSuperAgentComm],[sSuperAgentCommCurrency]
	,[pAgentComm],[pAgentCommCurrency],[pSuperAgentComm],[pSuperAgentCommCurrency]
	,[promotionCode],[promotionType],[pMessage]

	,[sCountry] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN 'United States' else sCountry END 
	,[sSuperAgent] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN '4641' else sSuperAgent end 
	,[sSuperAgentName] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN 'INTERNATIONAL AGENTS' else sSuperAgentName end 
	,[sAgent] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN '21295' else sAgent end 
	,[sAgentName] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN 'Continental Exchange Solutions' else sAgentName end 
	,[sBranch] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN '21295' else sBranch end 
	,[sBranchName] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN 'Continental Exchange Solutions' else sBranchName end 

	,[pCountry],[pSuperAgent],[pSuperAgentName],[pAgent],[pAgentName],[pBranch],[pBranchName]
	,[paymentMethod],[pBank],[pBankName],[pBankBranch],[pBankBranchName],[accountNo],[externalBankCode]
	,[collMode]
	,[collCurr],[tAmt],[cAmt],[pAmt],[payoutCurr]
	,[relWithSender],[purposeOfRemit],[sourceOfFund]
	,[tranStatus],[payStatus]
	,[createdDate] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN paidDate else createdDate end 
	,[createdDateLocal],[createdBy]
	,[modifiedDate],[modifiedDateLocal],[modifiedBy]
	,[approvedDate] = CASE WHEN paidDate > '2015-06-18' and sAgent IN (4746,4812) THEN paidDate else approvedDate end
	,[approvedDateLocal],[approvedBy]
	,[paidDate],[paidDateLocal],[paidBy]
	,[cancelRequestDate],[cancelRequestDateLocal],[cancelRequestBy]
	,[cancelReason],[refund],[cancelCharge]
	,[cancelApprovedDate],[cancelApprovedDateLocal],[cancelApprovedBy]
	,[blockedDate],[blockedBy]
	,[lockStatus],[lockedDate],[lockedDateLocal],[lockedBy],[payTokenId]
	,[tranType],[ContNo],[uploadLogId]
	,[voucherNo],[controlNo2]
	,[pBankType],[expectedPayoutAgent]
	,[routedBy],[routedDate],[senderName],[receiverName],[trnStatusBeforeCnlReq]
	,[schemeId],[bonusPoint],pLocation,pState,pDistrict,sRouteId
FROM remitTran WITH(NOLOCK)
UNION ALL
SELECT
	 [id]
	,[id]
	,[controlNo]
	,[sCurrCostRate],[sCurrHoMargin],[sCurrSuperAgentMargin],[sCurrAgentMargin]
	,[pCurrCostRate],[pCurrHoMargin],[pCurrSuperAgentMargin],[pCurrAgentMargin]
	,[agentCrossSettRate],[customerRate],[sAgentSettRate],[pDateCostRate]
	,[agentFxGain],[treasuryTolerance],[customerPremium],[schemePremium]
	,[sharingValue],[sharingType]
	,[serviceCharge],[handlingFee]
	,[sAgentComm],[sAgentCommCurrency],[sSuperAgentComm],[sSuperAgentCommCurrency]
	,[pAgentComm],[pAgentCommCurrency],[pSuperAgentComm],[pSuperAgentCommCurrency]
	,[promotionCode],[promotionType],[pMessage]
	,[sCountry],[sSuperAgent],[sSuperAgentName],[sAgent],[sAgentName],[sBranch],[sBranchName]
	,[pCountry],[pSuperAgent],[pSuperAgentName],[pAgent],[pAgentName],[pBranch],[pBranchName]
	,[paymentMethod],[pBank],[pBankName],[pBankBranch],[pBankBranchName],[accountNo],[externalBankCode]
	,[collMode]
	,[collCurr],[tAmt],[cAmt],[pAmt],[payoutCurr]
	,[relWithSender],[purposeOfRemit],[sourceOfFund]
	,[tranStatus],[payStatus]
	,[createdDate],[createdDateLocal],[createdBy]
	,[modifiedDate],[modifiedDateLocal],[modifiedBy]
	,[approvedDate],[approvedDateLocal],[approvedBy]
	,[paidDate],[paidDateLocal],[paidBy]
	,[cancelRequestDate],[cancelRequestDateLocal],[cancelRequestBy]
	,[cancelReason],[refund],[cancelCharge]
	,[cancelApprovedDate],[cancelApprovedDateLocal],[cancelApprovedBy]
	,[blockedDate],[blockedBy]
	,[lockStatus],[lockedDate],[lockedDateLocal],[lockedBy],[payTokenId]
	,[tranType],[ContNo],[uploadLogId]
	,[voucherNo],[controlNo2]
	,[pBankType],[expectedPayoutAgent]
	,[routedBy],[routedDate],[senderName],[receiverName],[trnStatusBeforeCnlReq]
	,[schemeId],[bonusPoint],pLocation,pState,pDistrict,NULL
FROM remitTranTemp WITH(NOLOCK)



GO
