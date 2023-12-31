USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_temp_to_main]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_online_temp_to_main]
	@id BIGINT ouTPUT
	,@voucherDetails xml = null
AS
SET XACT_ABORT ON;
SET NOCOUNT ON;
BEGIN Transaction
	
	declare @tranId bigint
	INSERT INTO remitTranTemp(
					   [controlNo]
					  ,[sCurrCostRate]
					  ,[sCurrHoMargin]
					  ,[sCurrSuperAgentMargin]
					  ,[sCurrAgentMargin]
					  ,[pCurrCostRate]
					  ,[pCurrHoMargin]
					  ,[pCurrSuperAgentMargin]
					  ,[pCurrAgentMargin]
					  ,[agentCrossSettRate]
					  ,[customerRate]
					  ,[sAgentSettRate]
					  ,[pDateCostRate]
					  ,[agentFxGain]
					  ,[treasuryTolerance]
					  ,[customerPremium]
					  ,[schemePremium]
					  ,[sharingValue]
					  ,[sharingType]
					  ,[serviceCharge]
					  ,[handlingFee]
					  ,[sAgentComm]
					  ,[sAgentCommCurrency]
					  ,[sSuperAgentComm]
					  ,[sSuperAgentCommCurrency]
					  ,[pAgentComm]
					  ,[pAgentCommCurrency]
					  ,[pSuperAgentComm]
					  ,[pSuperAgentCommCurrency]
					  ,[promotionCode]
					  ,[promotionType]
					  ,[pMessage]
					  ,[sCountry]
					  ,[sSuperAgent]
					  ,[sSuperAgentName]
					  ,[sAgent]
					  ,[sAgentName]
					  ,[sBranch]
					  ,[sBranchName]
					  ,[pCountry]
					  ,[pSuperAgent]
					  ,[pSuperAgentName]
					  ,[pAgent]
					  ,[pAgentName]
					  ,[pBranch]
					  ,[pBranchName]
					  ,[paymentMethod]
					  ,[pBank]
					  ,[pBankName]
					  ,[pBankBranch]
					  ,[pBankBranchName]
					  ,[accountNo]
					  ,[externalBankCode]
					  ,[collMode]
					  ,[collCurr]
					  ,[tAmt]
					  ,[cAmt]
					  ,[pAmt]
					  ,[payoutCurr]
					  ,[relWithSender]
					  ,[purposeOfRemit]
					  ,[sourceOfFund]
					  ,[tranStatus]
					  ,[payStatus]
					  ,[createdDate]
					  ,[createdDateLocal]
					  ,[createdBy]
					  ,[modifiedDate]
					  ,[modifiedDateLocal]
					  ,[modifiedBy]
					  ,[approvedDate]
					  ,[approvedDateLocal]
					  ,[approvedBy]
					  ,[paidDate]
					  ,[paidDateLocal]
					  ,[paidBy]
					  ,[cancelRequestDate]
					  ,[cancelRequestDateLocal]
					  ,[cancelRequestBy]
					  ,[cancelReason]
					  ,[refund]
					  ,[cancelCharge]
					  ,[cancelApprovedDate]
					  ,[cancelApprovedDateLocal]
					  ,[cancelApprovedBy]
					  ,[blockedDate]
					  ,[blockedBy]
					  ,[lockedDate]
					  ,[lockedDateLocal]
					  ,[lockedBy]
					  ,[payTokenId]
					  ,[sendEOD]
					  ,[payEOD]
					  ,[cancelEOD]
					  ,[tranType]
					  ,[ContNo]
					  ,[uploadLogId]
					  ,[company]
					  ,[voucherNo]
					  ,[controlNo2]
					  ,[pBankType]
					  ,[expectedPayoutAgent]
					  ,[routedBy]
					  ,[routedDate]
					  ,[senderName]
					  ,[receiverName]
					  ,[trnStatusBeforeCnlReq]
					  ,[schemeId]
					  ,[lockStatus]
					  ,[isOnlineTxn]
					  ,pState,pDistrict, sRouteId
					)
					SELECT 
					   controlNo
					  ,[sCurrCostRate]
					  ,[sCurrHoMargin]
					  ,[sCurrSuperAgentMargin]
					  ,[sCurrAgentMargin]
					  ,[pCurrCostRate]
					  ,[pCurrHoMargin]
					  ,[pCurrSuperAgentMargin]
					  ,[pCurrAgentMargin]
					  ,[agentCrossSettRate]
					  ,[customerRate]
					  ,[sAgentSettRate]
					  ,[pDateCostRate]
					  ,[agentFxGain]
					  ,[treasuryTolerance]
					  ,[customerPremium]
					  ,[schemePremium]
					  ,[sharingValue]
					  ,[sharingType]
					  ,[serviceCharge]
					  ,[handlingFee]
					  ,[sAgentComm]
					  ,[sAgentCommCurrency]
					  ,[sSuperAgentComm]
					  ,[sSuperAgentCommCurrency]
					  ,[pAgentComm]
					  ,[pAgentCommCurrency]
					  ,[pSuperAgentComm]
					  ,[pSuperAgentCommCurrency]
					  ,[promotionCode]
					  ,[promotionType]
					  ,[pMessage]
					  ,[sCountry]
					  ,[sSuperAgent]
					  ,[sSuperAgentName]
					  ,[sAgent]
					  ,[sAgentName]
					  ,[sBranch]
					  ,[sBranchName]
					  ,[pCountry]
					  ,[pSuperAgent]
					  ,[pSuperAgentName]
					  ,[pAgent]
					  ,[pAgentName]
					  ,[pBranch]
					  ,[pBranchName]
					  ,[paymentMethod]
					  ,[pBank]
					  ,[pBankName]
					  ,[pBankBranch]
					  ,[pBankBranchName]
					  ,[accountNo]
					  ,[externalBankCode]
					  ,[collMode]
					  ,[collCurr]
					  ,[tAmt]
					  ,[cAmt]
					  ,[pAmt]
					  ,[payoutCurr]
					  ,[relWithSender]
					  ,[purposeOfRemit]
					  ,[sourceOfFund]
					  --,CASE WHEN @customerStatus ='PendingUser' THEN 'Hold' ELSE 'Payment'  END
					  ,[transtatus]
					  ,[payStatus]
					  ,[createdDate]
					  ,[createdDateLocal]
					  ,[createdBy] 
					  ,[modifiedDate]
					  ,[modifiedDateLocal]
					  ,[modifiedBy]
					  ,[approvedDate]--CASE WHEN @customerStatus ='PendingUser' THEN null ELSE DBO.FNADateFormatTZ(GETDATE(), 'admin') END --[approvedDate]
					  ,[approvedDateLocal]--CASE WHEN @customerStatus ='PendingUser' THEN null ELSE GETDATE() END --[approvedDateLocal]
					  ,[approvedBy]--CASE WHEN @customerStatus ='PendingUser' THEN null ELSE @txnUser END --[approvedBy]
					  ,[paidDate]
					  ,[paidDateLocal]
					  ,[paidBy]
					  ,[cancelRequestDate]
					  ,[cancelRequestDateLocal]
					  ,[cancelRequestBy]
					  ,[cancelReason]
					  ,[refund]
					  ,[cancelCharge]
					  ,[cancelApprovedDate]
					  ,[cancelApprovedDateLocal]
					  ,[cancelApprovedBy]
					  ,[blockedDate]
					  ,[blockedBy]
					  ,[lockedDate]
					  ,[lockedDateLocal]
					  ,[lockedBy]
					  ,[payTokenId]
					  ,[sendEOD]
					  ,[payEOD]
					  ,[cancelEOD]
					  ,[tranType]
					  ,[ContNo]
					  ,[id]
					  ,[company]
					  ,[voucherNo]
					  ,[controlNo2]
					  ,[pBankType]
					  ,[expectedPayoutAgent]
					  ,[routedBy]
					  ,[routedDate]
					  ,[senderName]
					  ,[receiverName]
					  ,[trnStatusBeforeCnlReq]
					  ,[schemeId]
					  ,[lockStatus]
					  ,[isOnlineTxn]
					  ,pState,pDistrict, sRouteId
					FROM remitTranTempOnline WITH (NOLOCK)
					WHERE id = @id
					
				SET @tranId = @@IDENTITY
    
				INSERT INTO [tranSendersTemp](
						   [tranId]
						  ,[customerId]
						  ,[membershipId]
						  ,[firstName]
						  ,[middleName]
						  ,[lastName1]
						  ,[lastName2]
						  ,[fullName]
						  ,[country]
						  ,[address]
						  ,[state]
						  ,[district]
						  ,[zipCode]
						  ,[city]
						  ,[email]
						  ,[homePhone]
						  ,[workPhone]
						  ,[mobile]
						  ,[nativeCountry]
						  ,[dob]
						  ,[placeOfIssue]
						  ,[customerType]
						  ,[occupation]
						  ,[idType]
						  ,[idNumber]
						  ,[idPlaceOfIssue]
						  ,[issuedDate]
						  ,[validDate]
						  ,[extCustomerId]
						  ,[cwPwd]
						  ,[ttName]
						  ,[isFirstTran]
						  ,[customerRiskPoint]
						  ,[countryRiskPoint]
						  ,[gender]
						  ,[salary]
						  ,[companyName]
						  ,[address2]
						  ,[dcInfo]
						  ,[ipAddress]
						  ,[notifySms]
						  ,[txnTestQuestion]
						  ,[txnTestAnswer]	  
					)
					SELECT 
						   @tranId
						  ,[customerId]
						  ,[membershipId]
						  ,[firstName]
						  ,[middleName]
						  ,[lastName1]
						  ,[lastName2]
						  ,[fullName]
						  ,[country]
						  ,[address]
						  ,[state]
						  ,[district]
						  ,[zipCode]
						  ,[city]
						  ,[email]
						  ,[homePhone]
						  ,[workPhone]
						  ,[mobile]
						  ,[nativeCountry]
						  ,[dob]
						  ,[placeOfIssue]
						  ,[customerType]
						  ,[occupation]
						  ,[idType]
						  ,[idNumber]
						  ,[idPlaceOfIssue]
						  ,[issuedDate]
						  ,[validDate]
						  ,[extCustomerId]
						  ,[cwPwd]
						  ,[ttName]
						  ,[isFirstTran]
						  ,[customerRiskPoint]
						  ,[countryRiskPoint]
						  ,[gender]
						  ,[salary]
						  ,[companyName]
						  ,[address2]
						  ,[dcInfo]
						  ,[ipAddress]
						  ,[notifySms]
						  ,[txnTestQuestion]
						  ,[txnTestAnswer]
					FROM [tranSendersTempOnline] WITH (NOLOCK) WHERE tranId = @id
					  
				INSERT INTO [tranReceiversTemp](
						 [tranId]
						  ,[customerId]
						  ,[membershipId]
						  ,[firstName]
						  ,[middleName]
						  ,[lastName1]
						  ,[lastName2]
						  ,[fullName]
						  ,[country]
						  ,[address]
						  ,[state]
						  ,[district]
						  ,[zipCode]
						  ,[city]
						  ,[email]
						  ,[homePhone]
						  ,[workPhone]
						  ,[mobile]
						  ,[nativeCountry]
						  ,[dob]
						  ,[placeOfIssue]
						  ,[customerType]
						  ,[occupation]
						  ,[idType]
						  ,[idNumber]
						  ,[idPlaceOfIssue]
						  ,[issuedDate]
						  ,[validDate]
						  ,[idType2]
						  ,[idNumber2]
						  ,[idPlaceOfIssue2]
						  ,[issuedDate2]
						  ,[validDate2]
						  ,[relationType]
						  ,[relativeName]
						  ,[gender]
						  ,[address2]
						  ,[dcInfo]
						  ,[ipAddress]
						  )		  
						SELECT
						   @tranId
						  ,[customerId]
						  ,[membershipId]
						  ,[firstName]
						  ,[middleName]
						  ,[lastName1]
						  ,[lastName2]
						  ,[fullName]
						  ,[country]
						  ,[address]
						  ,[state]
						  ,[district]
						  ,[zipCode]
						  ,[city]
						  ,[email]
						  ,[homePhone]
						  ,[workPhone]
						  ,[mobile]
						  ,[nativeCountry]
						  ,[dob]
						  ,[placeOfIssue]
						  ,[customerType]
						  ,[occupation]
						  ,[idType]
						  ,[idNumber]
						  ,[idPlaceOfIssue]
						  ,[issuedDate]
						  ,[validDate]
						  ,[idType2]
						  ,[idNumber2]
						  ,[idPlaceOfIssue2]
						  ,[issuedDate2]
						  ,[validDate2]
						  ,[relationType]
						  ,[relativeName]
						  ,[gender]
						  ,[address2]
						  ,[dcInfo]
						  ,[ipAddress]
					  FROM [tranReceiversTempOnline] WITH (NOLOCK)
					  WHERE tranId = @id
					  
				INSERT INTO collectionDetails(
					   tranId
					  ,collMode
					  ,countryBankId
					  ,amt
					  ,collDate
					  ,narration
					  ,branchId
					  ,createdBy
					  ,createdDate)
				SELECT 
					  @tranId
					  ,collMode
					  ,countryBankId
					  ,amt
					  ,collDate
					  ,narration
					  ,branchId
					  ,createdBy
					  ,createdDate
					  FROM collectionDetailsOnline
					  WHERE tranId = @id
					  
				INSERT INTO customerTxnHistory
					(
						 Tranno,refno
						,senderFax,senderPassport
						,SenderName,sender_mobile,SenderAddress,SenderCountry,customerId,membershipId
						,receiverIDDescription,receiverID
						,receiverName,ReceiverPhone,receiver_mobile,ReceiverAddress,ReceiverCity,ReceiverCountry
						,rBankACNo,rBankName,rBankBranch,rBankID
						,ben_bank_id,ben_bank_name,rBankAcType
						,receiveAgentID,expected_payoutagentid,paymentType
						,paidAmt
						,confirmDate
						,paidCType,receiveCType
						,pAgent,pAgentName,pBranch,pBranchName
						,pBank,pBankName,pBankBranch,pBankBranchName
					)
					SELECT 
						 rt.id,rt.controlNo
						,ts.idType,ts.idNumber
						,ts.fullName,ts.mobile,ts.address,ts.companyName,ts.customerId,ts.membershipId
						,tv.idType,tv.idNumber
						,tv.fullName,tv.homePhone,tv.mobile,tv.address,tv.city,pCountry
						,rt.accountNo,pAgentName,pBranchName,pBranch
						,NULL,pBankName,pBankBranchName
						,pAgent,pAgent,paymentMethod
						,cAmt
						,NULL
						,collCurr,payoutCurr
						,pAgent,pAgentName,pBranch,pBranchName
						,pBank,pBankName,pBankBranch,pBankBranchName
					FROM vwRemitTran rt WITH(NOLOCK) --customers 
					INNER JOIN vwTranSenders ts WITH(NOLOCK) ON rt.id=ts.tranId
					INNER JOIN vwTranReceivers tv WITH(NOLOCK) ON rt.id=tv.tranId
					--INNER JOIN customers cus WITH(NOLOCK) ON ts.customerId = cus.customerId
					where rt.id = @tranId  	
				DELETE FROM remitTranTempOnline where id = @id
				DELETE FROM tranSendersTempOnline where tranId = @id
				DELETE FROM tranReceiversTempOnline where tranId = @id

				SET @id = @tranId

COMMIT TRANSACTION



GO
