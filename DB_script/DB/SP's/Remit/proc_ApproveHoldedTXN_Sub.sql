/*
EXEC proc_ApproveHoldedTXN_Sub @user='SYSTEM',@idList='<root><row id="10010026" /><row id="10010027" /></root>'

*/
ALTER proc [dbo].[proc_ApproveHoldedTXN_Sub]
	 @user				VARCHAR(30)
	,@idList			XML

AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON
	DECLARE 
		 @cAmt MONEY
		,@userId INT
		,@tranId BIGINT
		,@createdBy	VARCHAR(50)

	DECLARE @confirm_process_id VARCHAR(200), @controlNoEnc VARCHAR(50)
	SET @confirm_process_id = NEWID()

	DECLARE @PinList TABLE(id VARCHAR(50), pin VARCHAR(50),hasProcess CHAR(1),isOFAC CHAR(1),errorMsg VARCHAR(MAX),createdBy	VARCHAR(50))
	DECLARE @TempcompTable TABLE(errorCode INT,msg VARCHAR(MAX),id VARCHAR(50))


		DECLARE @SendList TABLE(amt MONEY, userId INT)
		
		INSERT @PinList(id)
		SELECT
			p.value('@id','VARCHAR(50)') id
		FROM @idList.nodes('/root/row') as tmp(p)
		
		UPDATE @PinList SET
			 pin = r.controlNo
		FROM @PinList pl
		INNER JOIN remitTranTemp r ON pl.id = r.id
		
		--send email to customers
		INSERT INTO tempTransactionMailQueue(controlNo, createdDate, [status])--tranType is used to know either mail is sent or not, we put 'N' for not sent
		SELECT rt.controlNo, GETDATE(), 'N' FROM @PinList pl 
		INNER JOIN remitTranTemp rt ON rt.id = pl.id

		BEGIN TRANSACTION
			UPDATE r SET
				  tranStatus				= CASE WHEN tranStatus = 'Hold' THEN 'Payment'
										       WHEN tranStatus = 'Compliance Hold' THEN 'Compliance'
										       WHEN tranStatus = 'OFAC Hold' THEN 'OFAC'
										       WHEN tranStatus = 'OFAC/Compliance Hold' THEN 'OFAC/Compliance'
											  ELSE 'Payment' END		
				 ,approvedBy				= @user
				 ,approvedDate				= DBO.FNADateFormatTZ(GETDATE(), @user)
				 ,approvedDateLocal			= GETDATE()			 
				 ,controlNo2				= r.controlNo 
			FROM remitTranTemp r WITH(NOLOCK)
			INNER JOIN @PinList p ON r.id = p.id
			
			INSERT INTO remitTran(
				 [holdTranId]
				,[controlNo]
				,[sCurrCostRate],[sCurrHoMargin],[sCurrSuperAgentMargin],[sCurrAgentMargin]
				,[pCurrCostRate],[pCurrHoMargin],[pCurrSuperAgentMargin],[pCurrAgentMargin]
				,[agentCrossSettRate],[customerRate],[sAgentSettRate],[pDateCostRate],[agentFxGain]
				,[treasuryTolerance],[customerPremium],[schemePremium],[sharingValue],[sharingType]
				,[serviceCharge],[handlingFee]
				,[sAgentComm],[sAgentCommCurrency],[sSuperAgentComm],[sSuperAgentCommCurrency]
				,[pAgentComm],[pAgentCommCurrency],[pSuperAgentComm],[pSuperAgentCommCurrency]
				,[promotionCode],[promotionType],[pMessage]
				,[sCountry],[sSuperAgent],[sSuperAgentName],[sAgent],[sAgentName],[sBranch],[sBranchName]
				,[pCountry],[pSuperAgent],[pSuperAgentName],[pAgent],[pAgentName],[pBranch],[pBranchName]
				,[paymentMethod]
				,[pBank],[pBankName],[pBankBranch],[pBankBranchName],[accountNo],[externalBankCode]
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
				,[lockedDate],[lockedDateLocal],[lockedBy]
				,[payTokenId]
				,[tranType],[ContNo],[uploadLogId],[voucherNo],[controlNo2]
				,[pBankType],[expectedPayoutAgent]
				,[routedBy],[routedDate]
				,[senderName],[receiverName]
				,[bonusPoint]
				,pState
				,pDistrict
				,isScMaunal
				,originalSC
			)
			SELECT
				 r.[id]
				,[controlNo]
				,[sCurrCostRate],[sCurrHoMargin],[sCurrSuperAgentMargin],[sCurrAgentMargin]
				,[pCurrCostRate],[pCurrHoMargin],[pCurrSuperAgentMargin],[pCurrAgentMargin]
				,[agentCrossSettRate],[customerRate],[sAgentSettRate],[pDateCostRate],[agentFxGain]
				,[treasuryTolerance],[customerPremium],[schemePremium],[sharingValue],[sharingType]
				,[serviceCharge],[handlingFee]
				,[sAgentComm],[sAgentCommCurrency],[sSuperAgentComm],[sSuperAgentCommCurrency]
				,[pAgentComm],[pAgentCommCurrency],[pSuperAgentComm],[pSuperAgentCommCurrency]
				,[promotionCode],[promotionType],[pMessage]
				,[sCountry],[sSuperAgent],[sSuperAgentName],[sAgent],[sAgentName],[sBranch],[sBranchName]
				,[pCountry],[pSuperAgent],[pSuperAgentName],[pAgent],[pAgentName],[pBranch],[pBranchName]
				,[paymentMethod]
				,[pBank],[pBankName],[pBankBranch],[pBankBranchName],[accountNo],[externalBankCode]
				,[collMode]
				,[collCurr],[tAmt],[cAmt],[pAmt],[payoutCurr]
				,[relWithSender],[purposeOfRemit],[sourceOfFund]
				,[tranStatus],[payStatus]
				,[createdDate],[createdDateLocal],r.[createdBy]
				,[modifiedDate],[modifiedDateLocal],[modifiedBy]
				,[approvedDate],[approvedDateLocal],[approvedBy]
				,[paidDate],[paidDateLocal],[paidBy]
				,[cancelRequestDate],[cancelRequestDateLocal],[cancelRequestBy]
				,[cancelReason],[refund],[cancelCharge]
				,[cancelApprovedDate],[cancelApprovedDateLocal],[cancelApprovedBy]
				,[blockedDate],[blockedBy]
				,[lockedDate],[lockedDateLocal],[lockedBy]
				,[payTokenId]
				,[tranType],[ContNo],[uploadLogId],[voucherNo],[controlNo2]
				,[pBankType],[expectedPayoutAgent]
				,[routedBy],[routedDate]
				,[senderName],[receiverName]
				,[bonusPoint]
				,pState
				,pDistrict
				,isScMaunal
				,originalSC
			FROM remitTranTemp r WITH(NOLOCK)
			INNER JOIN @PinList p ON r.id = p.id 
			
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
				 main.id
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
			FROM tranSendersTemp sen WITH(NOLOCK) 
			INNER JOIN remitTran main WITH(NOLOCK) ON sen.tranId = main.holdTranId
			INNER JOIN @PinList p ON sen.tranId = p.id
			
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
				 main.id
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
			FROM tranReceiversTemp rec WITH(NOLOCK)
			INNER JOIN remitTran main WITH(NOLOCK) ON rec.tranId = main.holdTranId
			INNER JOIN @PinList p ON rec.tranId = p.id
			
			DELETE FROM remitTranTemp 
			FROM remitTranTemp r
			INNER JOIN @PinList p ON r.id = p.id
			
			DELETE FROM tranSendersTemp
			FROM tranSendersTemp sen
			INNER JOIN @PinList p ON sen.tranId = p.id
			
			DELETE FROM tranReceiversTemp
			FROM tranReceiversTemp rec
			INNER JOIN @PinList p ON rec.tranId = p.id
			
			INSERT INTO PinQueueList(ICN)
			SELECT pin FROM @PinList WHERE ISNULL(pin, '') <> ''
			
			UPDATE utl SET
				 utl.sendTodays = ISNULL(sendTodays, 0) + ISNULL(s.amt, 0)
			FROM userWiseTxnLimit utl
			INNER JOIN @SendList s ON utl.userId = s.userId			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
			
		DECLARE @msg VARCHAR(MAX)='One or more transaction(s) Approved Successfully',@code INT=0
		IF EXISTS(SELECT 'X' FROM @PinList WHERE hasProcess = 'Y' AND isOFAC IN ('C','Y'))
		BEGIN
			SELECT @code=10 FROM @PinList WHERE isOFAC IN ('C','Y')
			
			SELECT @msg = CASE WHEN COUNT(*)>0 THEN  'Transaction Approved Successfully count : '+CAST(COUNT(*) AS VARCHAR) ELSE ' ' END  FROM @PinList WHERE ISNULL(isOFAC,'N') = 'N'
			SELECT @msg = @msg+ CASE WHEN COUNT(*)>0 THEN  '  <br> Transaction under compliance count : '+CAST(COUNT(*) AS VARCHAR) ELSE ' ' END  FROM @PinList WHERE ISNULL(isOFAC,'N') = 'Y'
			SELECT @msg = @msg+ CASE WHEN COUNT(*)>0 THEN ' <br> Unsuccess/Same users TXN count : '+CAST(COUNT(*) AS VARCHAR) ELSE ' ' END  FROM @PinList WHERE ISNULL(isOFAC,'N') = 'C'
		END
		
		EXEC proc_errorHandler @code, @msg, @user
		--EXEC proc_pushBulkToAc @flag = 'i',@idList = @idList

END


