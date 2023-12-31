USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sambaBatchTxn]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_sambaBatchTxn]
(
	 @flag				VARCHAR(50)	= NULL
	,@user				VARCHAR(50)	= NULL
	,@id				INT			= NULL
    ,@extBankId			INT			= NULL
	,@extBankName		VARCHAR(200)= NULL
    ,@extBankBranchId	INT			= NULL
    ,@pBankType			VARCHAR(50) = NULL
    ,@extBankBranchName VARCHAR(200)= NULL
)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF @flag ='i'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM RemittanceLogData.dbo.[temp_money] WITH(NOLOCK) WHERE FLAG IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found.', @user 
			RETURN;
		END

		INSERT INTO sambaBatch 
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
			,[sCurrCostRate]
			,[pMessage]		
			,[createdBy]					 			
			,[createdDate]					
			,[createdDateLocal]	
			
			,senName
			,senAddress
			,senCity
			,senCountry
			,senNativeCountry
			,senEmail
			,senCompanyName
			,senIdType
			,senIdNumber
			
			,recName
			,recAddress
			,recHomePhone
			,recWorkPhone
			,recCity
			,recCountry
			,recIdType
			,recIdNumber					
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
				serviceCharge = SCharge,
				sCurrCostRate = '1',
				pMessage = ReciverMessage,
				createdBy =SEmpID,
				createdDate = local_DOT,
				createdDateLocal = local_DOT,

				tm.SenderName, 
				tm.SenderAddress, 
				tm.SenderCity, 
				tm.SenderCountry, 
				tm.SenderNativeCountry,
				tm.SenderEmail,
				SenderCompany,
				'Passport',
				senderPassport,

				tm.ReceiverName,
				ReceiverAddress+'(AC:'+tm.rBankACNo+')', 
				ReceiverPhone,
				receiver_mobile, 
				ReceiverCity,
				ReceiverCountry,
				ReceiverIDDescription ,
				ReceiverID

		FROM RemittanceLogData.dbo.[temp_money] tm WITH(NOLOCK)
		LEFT JOIN agentMaster pb WITH(NOLOCK) ON pb.mapCodeInt = tm.rBankID AND (pb.agentType IN (2904, 2906) OR (pb.agentType = 2903 AND pb.actAsBranch = 'Y'))
		LEFT JOIN agentMaster pa WITH(NOLOCK) ON pb.parentId = pa.agentId AND pa.agentType IN (2903, 2905)
		LEFT JOIN externalBank eb WITH(NOLOCK) ON eb.mapCodeInt = pa.mapCodeInt
		WHERE tm.FLAG is null
	
		UPDATE RemittanceLogData.dbo.[temp_money] SET FLAG = 'Y' WHERE FLAG IS NULL
		EXEC proc_errorHandler 0, 'Data submitted successfully', @user 

	END

	IF @flag = 's'
	BEGIN
		SELECT 
			id,
			[Control No] = dbo.FNADecryptString(controlNo),
			[Sender Name] = senderName,
			[Receiver Name] = receiverName,
			[Sending Country] = sCountry,
			[Payment Method] = paymentMethod,
			[Payout Amount] = pAmt,
			[Bank Name] = pBankName,
			[Branch Name] = pBankBranchName,
			[Account No.] = accountNo,
			[Receiver Address] = recAddress	
		FROM sambaBatch with(nolock) where approvedDate is null			
	END

	IF @flag = 'u'
	BEGIN
		UPDATE sambaBatch SET pBank = '',pBankName='',pBankBranch = '',pBankBranchName = '' WHERE ID = @ID 
	END

	IF @flag = 'd'
	BEGIN
		DELETE FROM sambaBatch WHERE id = @id
		EXEC proc_errorHandler 0, 'Record has been deleted successfully', @user
	END

	IF	@flag='update-bank' 
	BEGIN
		DECLARE @pAgent INT,@pBranch INT,@pAgentName VARCHAR(200)
		IF @pBankType = 'I'
		BEGIN
			SET @pAgent = @extBankId
		END
		ELSE
		BEGIN
			SELECT @pAgent = internalCode FROM externalBank WITH(NOLOCK) WHERE extBankId = @extBankId
		END
		
		SELECT @pAgentName = agentName FROM agentMaster  WITH(NOLOCK) WHERE agentId = @pAgent

		IF @pBranch IS NULL
			SELECT TOP 1 @pBranch = agentId FROM agentMaster WITH(NOLOCK) WHERE parentId = @pAgent AND isHeadOffice = 'Y'
			
		UPDATE sambaBatch SET
			  pBranch			= @pBranch
			 ,pBank				= @extBankId
			 ,pBankBranch		= @extBankBranchId
			 ,pBankBranchName	= @extBankBranchName
			 ,pBankType			= @pBankType	
			 ,pBankName		    = @extBankName
			 ,modifiedBy		= @user
			 ,modifiedDate		= Getdate()
			 ,pAgent			= @pAgent
			 ,pAgentName		= @pAgentName
		WHERE id = @id

		EXEC [proc_errorHandler] 0, 'Bank Updated Successfully.', @id
	END	

	IF @flag = 'a'
	BEGIN
		SELECT 
			id,
			controlNo = dbo.FNADecryptString(controlNo),
			senderName,
			receiverName,
			sCountry,
			sSuperAgent,
			sSuperAgentName,
			sAgent,
			sAgentName,
			sBranch,
			sBranchName,
			paymentMethod,
			tAmt,
			cAmt,
			pAmt,
			customerRate,
			payoutCurr,
			pCountry,

			pBank,
			pBankName,
			pBankBranch,
			pBankBranchName,

			pBankType,
			accountNo,
			tranStatus,
			payStatus,
			collCurr,
			tranType,
			serviceCharge,
			sCurrCostRate,
			pMessage,

			senName,
			senAddress,
			senCity,
			senCountry,
			senNativeCountry,
			senEmail,
			senCompanyName,
			senIdType,
			senIdNumber,
			senContactNo = '',

			recName,
			recAddress,
			recContactNo = isnull(recHomePhone,'')+' , '+isnull(recWorkPhone,''),
			recHomePhone,
			recWorkPhone,
			recCity,
			recCountry,
			recIdType,
			recIdNumber 
			FROM sambaBatch WITH(NOLOCK) WHERE id = @id
	END

	IF @flag ='approve'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM sambaBatch WITH(NOLOCK) WHERE approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found.', @user 
			RETURN;
		END
		DECLARE @tranId BIGINT,@controlNoEncrypted VARCHAR(50)

		SELECT @controlNoEncrypted = controlNo FROM sambaBatch WITH(NOLOCK) WHERE id = @id
		INSERT INTO remitTran 
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
			,pAgent
			,pAgentName		
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
			,[sCurrCostRate]
			,[pMessage]		
			,[createdBy]					 			
			,[createdDate]					
			,[createdDateLocal]		
			,approvedBy 
			,approvedDate
			,approvedDateLocal				
		)
		SELECT  
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
			,[paymentMethod] = case when pBankBranch is not null then 'Bank Deposit' else [paymentMethod] end			
			,[cAmt]							
			,[tAmt]	
			,[pAmt]						
			,[customerRate]					
			,[payoutCurr]
			,[pCountry]	
			,pAgent
			,pAgentName		
			,[pBank]			
			,[pbankName]	
			,[pBankBranch]		
			,[pBankBranchName]

			,pBankType
			,[accountNo]
			,'Payment'					
			,'Unpaid'	
						
			,[collCurr]					
			,[tranType]	
			,[serviceCharge]
			,[sCurrCostRate]
			,[pMessage]		
			,[createdBy]					 			
			,[createdDate]					
			,[createdDateLocal]	
			,approvedBy =@user
			,approvedDate = getdate()
			,approvedDateLocal = getdate()
		FROM sambaBatch WITH(NOLOCK) WHERE id = @id
	
		SET @tranId = @@IDENTITY
		INSERT INTO tranSenders(tranId,firstName,address,city,country,nativeCountry,email,companyName,idType,idNumber)
		SELECT 
			@tranId,
			senName,
			senAddress,
			senCity,
			senCountry,
			senNativeCountry,
			senEmail,
			senCompanyName,
			senIdType,
			senIdNumber 
		FROM sambaBatch tm WITH(NOLOCK) WHERE id = @id

		INSERT INTO tranReceivers(tranId,firstName,address,homePhone,workPhone,city,country,idType,idNumber)
		SELECT 
			@tranId,
			recName,
			recAddress,
			recHomePhone,
			recWorkPhone,
			recCity,
			recCountry,
			recIdType,
			recIdNumber
		FROM sambaBatch tm WITH(NOLOCK) WHERE id = @id

		UPDATE sambaBatch SET approvedBy = @user,approvedDate=GETDATE() WHERE id = @id

		EXEC proc_pushToAc @flag= 'i', @controlNoEncrypted = @controlNoEncrypted	

		EXEC proc_errorHandler 0, 'Transaction has been approved successfully.', @tranId 

	END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH


GO
