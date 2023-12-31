USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnDocUpload]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procEDURE [dbo].[proc_txnDocUpload]
				 
		@flag				VARCHAR(10)		
		,@user				VARCHAR(50)		= NULL
		,@id	     		VARCHAR(50)		= NULL
		,@controlNo			VARCHAR(50)		= NULL
		,@rowId				VARCHAR(50)     = NULL
		,@tranId			VARCHAR(50)		= NULL
		,@agent				VARCHAR(50)		= NULL
		,@branch			VARCHAR(50)		= NULL
		,@fileName			VARCHAR(200)	= NULL
		,@fileType			VARCHAR(10)		= NULL
		,@docFolder			VARCHAR(50)		= NULL		
			
AS
SET NOCOUNT ON;
BEGIN
	DECLARE @controlNoEncrypted VARCHAR(50)
	IF @flag='s'
	BEGIN
		DECLARE @table VARCHAR(MAX),@sqlFilter VARCHAR(MAX)='where 1=1'
		
			
		IF @controlNo IS NOT NULL AND @tranId IS NULL
			SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
			
		IF @controlNo IS NULL
		BEGIN
			SELECT @controlNoEncrypted = controlNo, @controlNo = dbo.FNADecryptString(controlNo) FROM vwRemitTran WITH(NOLOCK) WHERE id = @tranId OR holdTranId = @tranId
		END
		
		IF @controlNo IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid ICN or Tran ID.', NULL
			RETURN
		END
		
		
		SELECT				
			DISTINCT
			 ControlNo			= @controlNo
			,sender				= senderName
			,receiver			= receiverName
			,sendingAmount	    = dbo.ShowDecimal(cAMt)
			,receivingAmount	= dbo.ShowDecimal(pAmt)
			,transactionDate    = CONVERT(VARCHAR,T.createdDate ,101)
			,holdTranId		    = holdTranId
			,tranId				= ISNULL(holdTranId, id)	
			,[fileName]			= d.[fileName]
			,fileType			= d.fileType
			,docFolder			= ISNULL(d.txnDocFolder,'')
			,sendingCountry		= t.sCountry
			,receivingCountry   = t.pCountry
			,sendingAgent		= t.sAgent
			,sendingCurrency	= t.collCurr
			,createdBy			= t.createdBy
			,approvedBy			= t.approvedBy
			,docApprovedby		= isnull(d.ApprovedBy,'')
			,docApprovedDate	= isnull(d.ApprovedDate,'')
		FROM vwRemitTran t WITH(NOLOCK) 
		LEFT JOIN txnDocUpload d WITH(NOLOCK) ON t.holdTranId = d.tranId
		WHERE t.controlNo = @controlNoEncrypted 
		UNION
		SELECT				
			DISTINCT
			 ControlNo			= @controlNo
			,sender				= senderName
			,receiver			= receiverName
			,sendingAmount	    = dbo.ShowDecimal(cAMt)
			,receivingAmount	= dbo.ShowDecimal(pAmt)
			,transactionDate    = CONVERT(VARCHAR,T.createdDate ,101)
			,holdTranId		    = holdTranId
			,tranId				= ISNULL(holdTranId, id)	
			,[fileName]			= d.[fileName]
			,fileType			= d.fileType
			,docFolder			= ISNULL(d.txnDocFolder,'')
			,sendingCountry		= t.sCountry
			,receivingCountry   = t.pCountry
			,sendingAgent		= t.sAgent
			,sendingCurrency	= t.collCurr
			,createdBy			= t.createdBy
			,approvedBy			= t.approvedBy
			,docApprovedby		= isnull(d.ApprovedBy,'')
			,docApprovedDate	= isnull(d.ApprovedDate,'')
		FROM FastMoneyPro_remit_Archive.dbo.remitTran t WITH(NOLOCK) 
		LEFT JOIN txnDocUpload d WITH(NOLOCK) ON t.holdTranId = d.tranId
		WHERE t.controlNo = @controlNoEncrypted 
	
	END
		
	IF @flag='i'
	BEGIN
		IF EXISTS(SELECT 'X' from txnDocUpload WHERE tranId = @tranId and fileType = @fileType)
		BEGIN
			UPDATE txnDocUpload SET 
				 modifiedBy			 = @user
				,modifiedDate        = GETDATE()
				,[fileName]			 = @fileName
			WHERE tranId = @tranId and fileType = @fileType

			EXEC proc_errorHandler 0, 'Image updated successfully.', @fileName
		END
		ELSE
		BEGIN 
			INSERT INTO txnDocUpload (
				 tranId
				,[fileName]
				,fileType
				,txnDocFolder
				,createdBy
				,createdDate
			)
			SELECT
				 @tranId
				,@fileName
				,@fileType
				,@docFolder
				,@user
				,GetDATE()

			SET @rowId = SCOPE_IDENTITY()

			EXEC proc_errorHandler 0, 'Image has been added successfully.', @fileName
		END
	END
		
	IF @flag='d'
	BEGIN 
		SELECT @fileName = [fileName],@docFolder=txnDocFolder FROM txnDocUpload WHERE tranId = @tranId AND fileType = @fileType
		DELETE FROM txnDocUpload WHERE tranId = @tranId AND fileType = @fileType

		--EXEC proc_errorHandler 0, 'Image has been deleted successfully.',null, @fileName
		SELECT 0 errorCode,'Image has been deleted successfully.' msg, @fileName id, @docFolder docFolder
	END

	IF @flag='search'
	BEGIN
		
		DECLARE @holdTranId BIGINT

		IF @controlNo IS NOT NULL 
			SELECT @controlNo = dbo.FNADecryptString(controlNo),@holdTranId=holdTranId FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo)
		ELSE 
			SELECT @controlNo = dbo.FNADecryptString(controlNo),@holdTranId=holdTranId FROM vwRemitTran WITH(NOLOCK) WHERE id = @tranId OR holdTranId = @tranId
			 
		IF @controlNo IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid ICN or Tran ID.', NULL
			RETURN
		END

		SELECT rowId,[fileName],fileType,ISNULL(fileDescription,'') fileDescription,ISNULL(txnDocFolder,'') AS docFolder,createdBy, createddate = CONVERT(varchar,createddate,103)				
			FROM txnDocUpload txn WITH(NOLOCK)
			WHERE tranId=@holdTranId
			ORDER BY createdDate DESC
		RETURN
	END	
END







GO
