USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwRemitTran]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwRemitTran]
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
	,[schemeId],[bonusPoint],pLocation,pState,pDistrict,sRouteId,postedBy,postedDate
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
	,[schemeId],[bonusPoint],pLocation,pState,pDistrict,NULL,NULL,NULL
FROM remitTranTemp WITH(NOLOCK)



GO
