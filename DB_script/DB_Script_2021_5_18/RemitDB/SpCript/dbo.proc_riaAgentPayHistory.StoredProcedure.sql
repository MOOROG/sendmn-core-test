USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_riaAgentPayHistory]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_riaAgentPayHistory] (
 @flag						VARCHAR(50)
	,@user						VARCHAR(50) 			
	,@rowId						BIGINT			= NULL
	----------------------------------------------------
--> from ria API
	,@transRefID			VARCHAR(100)	= NULL 
	,@orderFound			VARCHAR(100)	= NULL
	,@pIN					VARCHAR(100)	= NULL
	,@orderNo				VARCHAR(100)	= NULL
	,@seqIDRA				VARCHAR(100)	= NULL	
	,@orderDate				DATETIME		= NULL	
	,@custNameFirst			VARCHAR(100)	= NULL
	,@custNameLast1			VARCHAR(100)	= NULL
	,@custNameLast2			VARCHAR(100)	= NULL
	,@custAddress			VARCHAR(100)	= NULL
	,@custCity				VARCHAR(100)	= NULL
	,@custState				VARCHAR(100)	= NULL
	,@custCountry			VARCHAR(100)	= NULL
	,@custZip				VARCHAR(100)	= NULL
	,@custTelNo				VARCHAR(100)	= NULL
	,@beneNameFirst			VARCHAR(100)	= NULL
	,@beneNameLast1			VARCHAR(100)	= NULL
	,@beneNameLast2			VARCHAR(100)	= NULL
	,@beneAddress			VARCHAR(100)	= NULL
	,@beneCity				VARCHAR(100)	= NULL
	,@beneState				VARCHAR(100)	= NULL
	,@beneCountry			VARCHAR(100)	= NULL
	,@beneZip				VARCHAR(100)	= NULL
	,@beneTelNo				VARCHAR(100)	= NULL
	,@beneAmount			MONEY			= NULL
	,@responseDateTimeUTC	DATETIME	= NULL	
	----------------------------------------------------
			
	,@payConfirmationNo			VARCHAR(100)	= NULL
	
	,@apiStatus					VARCHAR(100)	= NULL
	,@payResponseCode			VARCHAR(20)		= NULL
	,@payResponseMsg			VARCHAR(100)	= NULL
	,@recordStatus				VARCHAR(50)		= NULL
	,@tranPayProcess			VARCHAR(20)		= NULL
	,@createdDate				DATETIME		= NULL
	,@createdBy					VARCHAR(30)		= NULL
	,@paidDate					DATETIME		= NULL
	,@paidBy					VARCHAR(30)		= NULL
	,@pBranch					INT				= NULL
	,@pBranchName				VARCHAR(100)	= NULL
	,@pAgent					INT				= NULL
	,@pAgentName				VARCHAR(100)	= NULL
	,@rIdType					VARCHAR(30)		= NULL
	,@rIdNumber					VARCHAR(30)		= NULL
	,@rIdPlaceOfIssue			VARCHAR(50)		= NULL
	,@rValidDate				DATETIME		= NULL
	,@rDob						DATETIME		= NULL
	,@rAddress					VARCHAR(100)	= NULL
	,@rOccupation				VARCHAR(100)	= NULL
	,@rContactNo				VARCHAR(50)		= NULL
	,@rCity						VARCHAR(100)	= NULL
	,@rNativeCountry			VARCHAR(100)	= NULL
	,@relationType				VARCHAR(50)		= NULL
	,@relativeName				VARCHAR(100)	= NULL
	,@remarks					VARCHAR(500)	= NULL
	,@approveBy					VARCHAR(30)		= NULL
	,@approvePwd				VARCHAR(100)	= NULL
	,@sCountry					VARCHAR(100)    = NULL
	
	,@sortBy					VARCHAR(50)		= NULL
	,@sortOrder					VARCHAR(5)		= NULL
	,@pageSize					INT				= NULL
	,@pageNumber				INT				= NULL
	
/*
-- as of globalBank
	 @flag						VARCHAR(50)
	,@user						VARCHAR(50) 			
	
	,@rowId						BIGINT			= NULL
	,@tokenId					VARCHAR(100)	= NULL
	,@radNo						VARCHAR(100)	= NULL
	,@benefName					VARCHAR(100)	= NULL
	,@benefTel					VARCHAR(100)	= NULL
	,@benefMobile				VARCHAR(100)	= NULL
	,@benefAddress				VARCHAR(100)	= NULL
	,@benefAccIdNo				VARCHAR(100)	= NULL
	,@benefIdType				VARCHAR(100)	= NULL
	,@senderName				VARCHAR(100)	= NULL
	,@senderAddress				VARCHAR(100)	= NULL
	,@senderTel					VARCHAR(100)	= NULL
	,@senderMobile				VARCHAR(100)	= NULL
	,@senderIdType				VARCHAR(100)	= NULL
	,@senderIdNo				VARCHAR(100)	= NULL
	,@remittanceEntryDt			VARCHAR(100)	= NULL
	,@remittanceAuthorizedDt	VARCHAR(100)	= NULL
	
	
	,@remitType					VARCHAR(100)	= NULL
	,@pCurrency					VARCHAR(100)	= NULL
	,@rCurrency					VARCHAR(100)	= NULL
	,@pCommission				VARCHAR(100)	= NULL
	,@amount					VARCHAR(100)	= NULL
	,@localAmount				VARCHAR(100)	= NULL
	,@exchangeRate				VARCHAR(100)	= NULL
	,@dollarRate				VARCHAR(100)	= NULL
	,@payConfirmationNo			VARCHAR(100)	= NULL
	
	,@apiStatus					VARCHAR(100)	= NULL
	,@payResponseCode			VARCHAR(20)		= NULL
	,@payResponseMsg			VARCHAR(100)	= NULL
	,@recordStatus				VARCHAR(50)		= NULL
	,@tranPayProcess			VARCHAR(20)		= NULL
	,@createdDate				DATETIME		= NULL
	,@createdBy					VARCHAR(30)		= NULL
	,@paidDate					DATETIME		= NULL
	,@paidBy					VARCHAR(30)		= NULL
	,@pBranch					INT				= NULL
	,@pBranchName				VARCHAR(100)	= NULL
	,@pAgent					INT				= NULL
	,@pAgentName				VARCHAR(100)	= NULL
	,@rIdType					VARCHAR(30)		= NULL
	,@rIdNumber					VARCHAR(30)		= NULL
	,@rIdPlaceOfIssue			VARCHAR(50)		= NULL
	,@rValidDate				DATETIME		= NULL
	,@rDob						DATETIME		= NULL
	,@rAddress					VARCHAR(100)	= NULL
	,@rOccupation				VARCHAR(100)	= NULL
	,@rContactNo				VARCHAR(50)		= NULL
	,@rCity						VARCHAR(100)	= NULL
	,@rNativeCountry			VARCHAR(100)	= NULL
	,@relationType				VARCHAR(50)		= NULL
	,@relativeName				VARCHAR(100)	= NULL
	,@remarks					VARCHAR(500)	= NULL
	,@approveBy					VARCHAR(30)		= NULL
	,@approvePwd				VARCHAR(100)	= NULL
	,@sCountry					VARCHAR(100)    = NULL
	
	,@sortBy					VARCHAR(50)		= NULL
	,@sortOrder					VARCHAR(5)		= NULL
	,@pageSize					INT				= NULL
	,@pageNumber				INT				= NULL
	
	*/
)
AS

/*
@flag = 'a'  --> Select top 1 record  [done for Ria]
@flag = 'i'  --> Insert into riaPayHistory table  [done for Ria]
@flag = 'readyToPay' --> Update the status of data   [done for Ria]
@flag = 'payError'  -- error [done for Ria]

*/

SET XACT_ABORT ON

BEGIN TRY
	DECLARE		 
	@transRefIDEnc	VARCHAR(100) = dbo.FNAEncryptString(@transRefID)

	--IF @flag = 'a'
	--BEGIN 
	--	SELECT TOP 1
	--		 rowId
	--		,[controlNo]	= dbo.FNADecryptString(ria.transRefID)
	--		,[sCountry]		= 'Malaysia'
	--		,[sName]		= ria.senderName
	--		,[sAddress]		= ISNULL(ria.senderAddress,'')
	--		,[sIdType]		= ria.senderIdType
	--		,[sIdNumber]	= ria.senderIdNo
	--		,[rCountry]		= 'Nepal'
	--		,[rName]		= ria.beneNameFirst
	--		,[rAddress]		= ria.rAddress
	--		,[rCity]		= ria.rCity
	--		,[rPhone]		= ISNULL(ria.rContactNo,'')
	--		,[rIdType]		= ria.rIdType
	--		,[rIdNumber]	= ria.rIdNumber
	--		,[pAmt]			= ria.amount
	--		,[pCurr]		= ria.pCurrency
	--		,[pBranch]		= am.agentName
	--		,[pUser]		= ria.createdBy
	--	FROM riaRemitPayHistory ria WITH(NOLOCK)
	--	INNER JOIN agentMaster am WITH(NOLOCK) ON ria.pBranch = am.agentId
	--	WHERE recordStatus <> ('DRAFT') AND transRefID = dbo.FNAEncryptString(@transRefID)
	--	ORDER BY rowId DESC
	--	RETURN
	--END 
			
	IF @flag = 'i'
	BEGIN
		IF EXISTS (SELECT 'x' FROM riaAgentPayHistory WITH(NOLOCK) WHERE transRefID= @transRefIDEnc)
		BEGIN
			UPDATE riaAgentPayHistory SET 
				recordStatus = 'EXPIRED'
			WHERE transRefID = @transRefIDEnc AND recordStatus <> 'READYTOPAY'
		END
		/*
		---------------------------------------
		--> as of globalBalnPayHistory
		INSERT INTO riaAgentPayHistory (
			 transRefID						
			,tokenId	
			,benefName
			,benefTel
			,benefMobile 
			,benefAddress
			,benefAccIdNo
			,benefIdType 
			,senderName 
			,senderAddress 
			,senderTel 
			,senderMobile 
			,senderIdType 
			,senderIdNo 
			,remittanceEntryDt
			,remittanceAuthorizedDt
			,remarks
			,remitType 
			,rCurrency 
			,pCurrency 
			,pCommission 
			,amount 
			,localAmount 
			,exchangeRate 
			,dollarRate 
			,apiStatus
			,recordStatus
			,pBranch
			,createdDate
			,createdBy 
			)
		SELECT
			 @radNoEnc
			,@tokenId
			,@benefName
			,@benefTel
			,@benefMobile
			,@benefAddress
			,@benefAccIdNo
			,@benefIdType 
			,@senderName 
			,@senderAddress 
			,@senderTel 
			,@senderMobile 
			,@senderIdType 
			,@senderIdNo 
			,@remittanceEntryDt
			,@remittanceAuthorizedDt
			,@remarks
			,@remitType 
			,@rCurrency 
			,@pCurrency 
			,@pCommission 
			,FLOOR(@amount)
			,@localAmount 
			,@exchangeRate 
			,@dollarRate 
			,@apiStatus
			,'DRAFT'
			,@pBranch
			,GETDATE()
			,@user	
			*/
			-----------------------
			
			INSERT INTO riaAgentPayHistory (
			transRefID
			,orderFound  
			,pin
			,orderNo  
			,seqIDRA  
			,orderDate  
			,custNameFirst  
			,custNameLast1  
			,custNameLast2  
			,custAddress  
			,custCity  
			,custState  
			,custCountry  
			,custZip  
			,custTelNo  
			,beneNameFirst  
			,beneNameLast1  
			,beneNameLast2  
			,beneAddress  
			,beneCity  
			,beneState  
			,beneCountry  
			,beneZip  
			,beneTelNo  
			,beneAmount  
			,responseDateTimeUTC 		
			---------------------
			,remarks
			,apiStatus
			,recordStatus
			,pBranch
			,createdDate
			,createdBy 
			)
		SELECT
			 @transRefIDEnc
			,@orderFound  
			,@pIN  
			,@orderNo  
			,@seqIDRA  
			,@orderDate  
			,@custNameFirst  
			,@custNameLast1  
			,@custNameLast2  
			,@custAddress  
			,@custCity  
			,@custState  
			,@custCountry  
			,@custZip  
			,@custTelNo  
			,@beneNameFirst  
			,@beneNameLast1  
			,@beneNameLast2  
			,@beneAddress  
			,@beneCity  
			,@beneState  
			,@beneCountry  
			,@beneZip  
			,@beneTelNo  
			,@beneAmount  
			,@responseDateTimeUTC  
			-----------------------
		
			,@remarks
			,@apiStatus
			,'DRAFT'
			,@pBranch
			,GETDATE()
			,@user	
		
		SET @rowId = SCOPE_IDENTITY()
		EXEC [proc_errorHandler] 0, 'Transaction Has Been Saved Successfully', @rowId
		RETURN 
	END
	
	IF @flag = 'readyToPay'
	BEGIN
		UPDATE riaAgentPayHistory SET 
			 recordStatus 	 = 'READYTOPAY'
			,pBranch 	  	 = @pBranch 
			,rIdType 	  	 = @rIdType 
			,rIdNumber 	  	 = @rIdNumber 
			,rIdPlaceOfIssue = @rIdPlaceOfIssue
			,rValidDate	  	 = @rValidDate
			,rDob 		  	 = @rDob 
			,rAddress 	  	 = @rAddress 
			,rCity 		  	 = @rCity 
			,rOccupation  	 = @rOccupation 
			,rContactNo   	 = @rContactNo 
			,nativeCountry	 = @rNativeCountry 
			,relationType	 = @relationType
			,relativeName	 = @relativeName
			,remarks 	  	 = @remarks 
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Ready to pay has been recorded successfully.', @rowId
		RETURN
	END
	
	IF @flag = 'payError'
	BEGIN
		UPDATE riaAgentPayHistory SET 
			 recordStatus	 = 'PAYERROR'
			,payResponseCode = @payResponseCode
			,payResponseMsg  = @payResponseMsg 		
		WHERE rowId = @rowId
		EXEC [proc_errorHandler] 0, 'Pay error has been recorded successfully.', @rowId
		RETURN
	END
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION 
	SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
END CATCH

GO
