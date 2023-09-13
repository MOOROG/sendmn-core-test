
ALTER procEDURE [dbo].[proc_remitTranTempToMain]
 @id BIGINT

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
BEGIN TRANSACTION
	DECLARE @tranId BIGINT
	INSERT INTO remitTran(
		 [holdTranId]
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
		,[lockedDate],[lockedDateLocal],[lockedBy],[payTokenId]
		,[tranType],[ContNo],[uploadLogId]
		,[voucherNo],[controlNo2]
		,[pBankType],[expectedPayoutAgent]
		,[routedBy],[routedDate],[senderName],[receiverName]
		,[bonusPoint]
		,pState
		,pDistrict
		,pLocation
		,sRouteId
		,isScMaunal
		,originalSC
		,isOnBehalf
		,PayerId
		,PayerBranchId
		)
	SELECT
		 [id]
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
		,[lockedDate],[lockedDateLocal],[lockedBy],[payTokenId]
		,[tranType],[ContNo],[uploadLogId]
		,[voucherNo],[controlNo2]
		,[pBankType],[expectedPayoutAgent]
		,[routedBy],[routedDate],[senderName],[receiverName]
		,[bonusPoint]
		,pState
		,pDistrict
		,pLocation
		,sRouteId
		,isScMaunal
		,originalSC
		,isOnBehalf
		,PayerId
		,PayerBranchId
	FROM remitTranTemp WITH(NOLOCK) WHERE id = @id AND ISNULL(sRouteId,'0')='0'
	
	SET @tranId = SCOPE_IDENTITY()

	INSERT INTO tranSenders(
		 [tranId]
		,[holdTranId]
		,[customerId]
		,[membershipId]
		,[firstName],[middleName],[lastName1],[lastName2],[fullName]
		,[country],[address],[state],[district],[zipCode],[city]
		,[email],[homePhone],[workPhone],[mobile]
		,[nativeCountry],[dob],[placeOfIssue]
		,[customerType],[occupation]
		,[idType],[idNumber],[idPlaceOfIssue],[issuedDate],[validDate]
		,[extCustomerId],[cwPwd],[ttName]
		,[isFirstTran],[customerRiskPoint],[countryRiskPoint]
		,[gender],[salary],[companyName],[address2]
		,[dcInfo],[ipAddress],[notifySms],[txnTestQuestion],[txnTestAnswer] 
	)
	SELECT 
		 @tranId
		,[tranId]
		,[customerId]
		,[membershipId]
		,[firstName],[middleName],[lastName1],[lastName2],[fullName]
		,[country],[address],[state],[district],[zipCode],[city]
		,[email],[homePhone],[workPhone],[mobile]
		,[nativeCountry],[dob],[placeOfIssue]
		,[customerType],[occupation]
		,[idType],[idNumber],[idPlaceOfIssue],[issuedDate],[validDate]
		,[extCustomerId],[cwPwd],[ttName]
		,[isFirstTran],[customerRiskPoint],[countryRiskPoint]
		,[gender],[salary],[companyName],[address2]
		,[dcInfo],[ipAddress],[notifySms],[txnTestQuestion],[txnTestAnswer] 
	FROM tranSendersTemp WITH(NOLOCK) WHERE tranId = @id
	
	INSERT INTO tranReceivers(
		 [tranId]
		,[holdTranId]
		,[customerId]
		,[membershipId]
		,[firstName],[middleName],[lastName1],[lastName2],[fullName]
		,[country],[address],[state],[district],[zipCode],[city]
		,[email],[homePhone],[workPhone],[mobile]
		,[nativeCountry],[dob],[placeOfIssue]
		,[customerType],[occupation]
		,[idType],[idNumber],[idPlaceOfIssue]
		,[issuedDate],[validDate]
		,[idType2],[idNumber2],[idPlaceOfIssue2],[issuedDate2],[validDate2]
		,[relationType],[relativeName]
		,[gender],[address2]
		,[dcInfo],[ipAddress]
	)
	SELECT
		 @tranId
		,[tranId]
		,[customerId]
		,[membershipId]
		,[firstName],[middleName],[lastName1],[lastName2],[fullName]
		,[country],[address],[state],[district],[zipCode],[city]
		,[email],[homePhone],[workPhone],[mobile]
		,[nativeCountry],[dob],[placeOfIssue]
		,[customerType],[occupation]
		,[idType],[idNumber],[idPlaceOfIssue]
		,[issuedDate],[validDate]
		,[idType2],[idNumber2],[idPlaceOfIssue2],[issuedDate2],[validDate2]
		,[relationType],[relativeName]
		,[gender],[address2]
		,[dcInfo],[ipAddress]
	FROM tranReceiversTemp WITH(NOLOCK) WHERE tranId = @id
	
	UPDATE bankCollectionVoucherDetail SET mainTranId = @tranId WHERE tempTranId = @id

	DELETE FROM remitTranTemp WHERE id = @id
	DELETE FROM tranSendersTemp WHERE tranId = @id
	DELETE FROM tranReceiversTemp WHERE tranId = @id

COMMIT TRANSACTION 

END



