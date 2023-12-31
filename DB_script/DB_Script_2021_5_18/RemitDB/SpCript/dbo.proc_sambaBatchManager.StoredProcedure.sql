USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sambaBatchManager]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_sambaBatchManager]
(
	@user VARCHAR(50)
)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF NOT EXISTS(SELECT 'X' FROM RemittanceLogData.dbo.[temp_money] WITH(NOLOCK) WHERE FLAG IS NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction Not Found.', @user 
		RETURN;
	END

	INSERT INTO remitTranTemp 
	(	 
		 [controlNo]					
		,[senderName]	
		,[receiverName]						
		,[sCountry]					
		,[sSuperAgent]					
		,[sSuperAgentName]	
		,[sAgent]						
		,[sAgentName]					
		,[sBranch]						
		,[sBranchName]						
		,[paymentMethod]				
		,[cAmt]							
		,[tAmt]	
		,[pAmt]						
		,[customerRate]					
		,[payoutCurr]
		,[pCountry]			
		,[pBank]			
		,[pbankName]	
		,[pBankBranch]		
		,[pBankBranchName]
		,pBankType
		,[accountNo]
		,[tranStatus]					
		,[payStatus]					
		,[collCurr]					
		,[tranType]	
		,[serviceCharge]
		,[sAgentComm]
		,[sCurrCostRate]
		,[pMessage]		
		,[createdBy]					 			
		,[createdDate]					
		,[createdDateLocal]						
	)
	SELECT  controlNo = refno ,
			senderName = SenderName ,
			ReceiverName receiverName,
			sCountry = SenderCountry ,
			sSuperAgent = '4641',
			sSuperAgentName = 'INTERNATIONAL AGENTS',
			sAgent = '4873',
			sAgentName = 'SAMBA FINANCIAL GROUP',
			sBranch = '4874',
			sBranchName = 'SAMBA FINANCIAL GROUP - RIYADH',

			paymentMethod = CASE WHEN tm.paymentType = 'Cash Pay' THEN 'Cash Payment' WHEN tm.paymentType = 'Bank Transfer' THEN 'Bank Deposit' ELSE tm.paymentType END,
			cAmt = paidAmt-1.87,
			tAmt = paidAmt-1.87,
			pAmt = TotalRoundAmt,
			customerRate = Today_Dollar_rate,
			payoutCurr = receiveCType,

			pCountry = 'Nepal',
			pBank = CASE WHEN tm.paymentType = 'Bank Transfer' THEN eb.extBankId ELSE NULL END,
			pBankName = CASE WHEN tm.paymentType = 'Bank Transfer' THEN eb.bankName ELSE NULL END,
			pBankBranch = NULL,
			pBankBranchName = CASE WHEN tm.paymentType = 'Bank Transfer' THEN rBankBranch ELSE NULL END,
			pBankType = CASE WHEN tm.paymentType = 'Bank Transfer' THEN 'E' ELSE NULL END,
			accountNo = tm.rBankACNo,

			tranStatus = 'Hold',
			payStatus = 'Unpaid',
			collCurr = paidCType,
			tranType = 'I',		
			serviceCharge = 0,
			sAgentComm=0,
			sCurrCostRate = '1',
			pMessage = ReciverMessage,
			createdBy =SEmpID,
			createdDate = local_DOT,
			createdDateLocal = local_DOT 
	FROM RemittanceLogData.dbo.[temp_money] tm WITH(NOLOCK)
	LEFT JOIN agentMaster pb WITH(NOLOCK) ON pb.mapCodeInt = tm.rBankID AND (pb.agentType IN (2904, 2906) OR (pb.agentType = 2903 AND pb.actAsBranch = 'Y'))
	LEFT JOIN agentMaster pa WITH(NOLOCK) ON pb.parentId = pa.agentId AND pa.agentType IN (2903, 2905)
	LEFT JOIN externalBank eb WITH(NOLOCK) ON eb.mapCodeInt = pa.mapCodeInt
	WHERE tm.FLAG is null
	
	INSERT INTO tranSendersTemp(tranId,firstName,address,city,country,nativeCountry,email,companyName,idType,idNumber)
	SELECT rt.id, tm.SenderName, tm.SenderAddress, tm.SenderCity, tm.SenderCountry, tm.SenderNativeCountry,tm.SenderEmail,SenderCompany,'Passport',senderPassport
	FROM RemittanceLogData.dbo.[temp_money] tm WITH(NOLOCK) INNER JOIN remitTranTemp rt ON tm.refno = rt.controlNo
	WHERE tm.FLAG is null

	INSERT INTO tranReceiversTemp(tranId,firstName,address,homePhone,workPhone,city,country,idType,idNumber)
	SELECT rt.id,tm.ReceiverName,ReceiverAddress+'(AC:'+tm.rBankACNo+')', ReceiverPhone,receiver_mobile, ReceiverCity,ReceiverCountry,
	ReceiverIDDescription ,ReceiverID
	FROM RemittanceLogData.dbo.[temp_money] tm WITH(NOLOCK) INNER JOIN remitTranTemp rt ON tm.refno = rt.controlNo
	WHERE tm.FLAG is null
	
	UPDATE RemittanceLogData.dbo.[temp_money] SET FLAG = 'Y' WHERE FLAG IS NULL
	EXEC proc_errorHandler 0, 'Data submitted successfully', @user 

END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH

--alter table temp_money add flag char(1)

GO
