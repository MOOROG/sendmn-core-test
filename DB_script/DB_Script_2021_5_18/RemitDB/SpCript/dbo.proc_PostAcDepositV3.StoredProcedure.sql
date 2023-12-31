USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PostAcDepositV3]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_PostAcDepositV3]
	 @flag			VARCHAR(50)
	,@pAgent		INT				= NULL
	,@mapCodeInt	VARCHAR(100)	= NULL
	,@tranIds		VARCHAR(MAX)	= NULL
	,@fromDate		VARCHAR(25)		= NULL
	,@toDate		VARCHAR(25)		= NULL
	,@controlNo		VARCHAR(50)		= NULL
	,@remarks		VARCHAR(MAX)	= NULL
	,@user			VARCHAR(50)		= NULL
	,@fromTime		VARCHAR(20)		= NULL
	,@toTime		VARCHAR(20)		= NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE  
		 @pAgentName varchar(200)
		,@pBranch int
		,@pBranchName varchar(200)
		,@pState varchar(200)
		,@pDistrict	varchar(200)
		,@pLocation	varchar(50)
		,@tranNos VARCHAR(MAX)
		,@sql VARCHAR(MAX)

	/*
		ALTER TABLE remitTran ADD postedBy VARCHAR(50),postedDate datetime,postedDateLocal datetime	
		Exec proc_PostAcDepositV3 @flag='pendingList',@user='admin'
		Exec proc_PostAcDepositV3 @flag='pendingListDom',@mapCodeInt = '11300000',@user='dipesh'
		EXEC proc_PostAcDepositV3 @flag = 'domList', @user = 'dipesh', @bankId = '11300000'
	*/
	IF @fromTime IS NOT NULL
		SET @fromDate = @fromDate+' '+@fromTime
	ELSE 
		SET @fromDate = @fromDate+' 00:00:00'
	IF @toTime IS NOT NULL
		SET @toDate = @toDate+' '+@toTime 
	ELSE
		SET @toDate = @toDate+' 23:59:59'

	IF @flag = 'pending'
	BEGIN
		SET @sql =
		'SELECT
			 pAgent			= pAgent
			,pAgentName		= pAgentName
			,txnCount		= COUNT(*)
			,amt			= SUM(pAmt)
		FROM remitTran rt WITH(NOLOCK)
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		BEGIN			
			SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		END
		SET @sql = @sql +'
			AND paymentMethod in (''Bank Deposit'' ,''Relief Fund'')
			AND tranStatus = ''Payment'' 
			AND payStatus = ''Unpaid'' 
			AND tranType = ''I''
			GROUP BY pAgent, pAgentName'

		EXEC(@sql)
		
		SET @sql= 'SELECT
			 pAgent			= rt.pBank
			,pAgentName		= rt.pBankName
			,txnCount		= COUNT(*)
			,amt			= SUM(rt.pAmt)
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN agentMaster am on rt.pBank=am.agentId
		WHERE 1=1  
		AND (am.agentGrp =''4301'' OR am.agentGrp IS NULL) 
		AND (am.agentType=''2903'' OR am.agentType=''2905'')
		'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
			AND paymentMethod = ''Bank Deposit'' 
			AND tranStatus = ''Payment'' 
			AND payStatus = ''Unpaid'' 
			AND tranType = ''D''
			GROUP BY pBank, pBankName'
		EXEC(@sql)

	 SET @sql= 'SELECT
			 pAgent			= rt.pBank
			,pAgentName		= rt.pBankName
			,txnCount		= COUNT(*)
			,amt			= SUM(rt.pAmt)
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN agentMaster am on rt.pBank=am.agentId
		WHERE am.agentGrp=''8026'' AND am.agentType IN(''2903'',''2904'')
		'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
			AND rt.paymentMethod = ''Bank Deposit'' 
			AND rt.tranStatus = ''Payment'' 
			AND rt.payStatus = ''Unpaid'' 
			AND rt.tranType = ''D''
			GROUP BY pBank, pBankName'
			
			print @sql 
		EXEC(@sql)
	
		RETURN
	END

	IF @flag = 'pendingIntl'				
	BEGIN
		SET @sql =
		'SELECT
			 [Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Tran No]			= rt.id
			,[Sending Country]	= rt.sCountry
			,[Sending Agent]	= rt.sAgentName
			,[Bank Name]		= rt.pBankName
			,[Branch Name]		= rt.pBankBranchName								
			,[Receiver Name]	= rt.receiverName --rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
			,[Bank A/C No]		= rt.accountNo
			,[Confirm Date]		= rt.approvedDate
			,[Payout Amount]	= rt.pAmt
			,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
		FROM [dbo].remitTran rt WITH(NOLOCK)
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
		AND pAgent = '''+CAST(@pAgent AS VARCHAR)+'''
		AND tranStatus = ''Payment''
		AND paymentMethod IN (''Bank Deposit'' ,''Relief Fund'')
		AND payStatus = ''Unpaid'' 
		AND rt.sCountry <> ''Nepal''
		AND rt.tranType = ''I''
		ORDER BY [Unpaid Days] DESC'

		EXEC(@sql)
		RETURN
		
	END

	IF @flag = 'pendingDom'				
	BEGIN
		
		SET @sql =
		'SELECT
			 [Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Tran No]			= rt.id
			,[Sending Agent]	= rt.sAgentName
			,[Bank Name]		= rt.pBankName
			,[Branch Name]		= rt.pBankBranchName								
			,[Receiver Name]	= rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
			,[Bank A/C No]		= rt.accountNo
			,[Confirm Date]		= rt.approvedDate
			,[Payout Amount]	= rt.pAmt
			,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
		FROM [dbo].remitTran rt WITH(NOLOCK)
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
		AND pBank = '''+CAST(@pAgent AS VARCHAR)+'''
		AND tranStatus = ''Payment''
		AND paymentMethod = ''Bank Deposit''
		AND payStatus = ''Unpaid'' 
		AND rt.sCountry = ''Nepal''
		AND tranType = ''D''
		ORDER BY [Unpaid Days] DESC'

		EXEC(@sql)
		RETURN
		
	END


	IF @flag = 'postIntl'
	BEGIN
		DECLARE @tranDetail TABLE(id INT IDENTITY(1,1), tranId VARCHAR(50), controlNo VARCHAR(50), sRouteId VARCHAR(5))
		SET @sql = 'SELECT id, controlNo, sRouteId FROM dbo.remitTran WITH(NOLOCK) WHERE id IN (' + @tranIds + ') AND tranStatus = ''Payment'' AND payStatus = ''Unpaid'''
		
		INSERT INTO @tranDetail
		EXEC (@sql)

		IF NOT EXISTS(SELECT 'X' FROM @tranDetail)
		BEGIN
			EXEC proc_errorHandler 1, 'No Transaction Found.', NULL
			RETURN
		END	
		BEGIN TRAN
		UPDATE remitTran SET
			--,tranStatus					= 'POST'
			 payStatus					= 'Post'
			,postedBy					= @user
			,postedDate					= dbo.FNAGetDateInNepalTZ()
			,postedDateLocal			= GETDATE()	
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN @tranDetail td on rt.id = td.tranId
		COMMIT TRAN		
		EXEC proc_errorHandler 0, 'Transaction(s) post successfully', NULL
		RETURN
	END
--ALTER TABLE remitTran ADD postedBy VARCHAR(50),postedDate DATETIME,postedDateLocal DATETIME
	IF @flag = 'postDom'
	BEGIN
		DECLARE @tranDomDetail TABLE(id INT IDENTITY(1,1),tranId VARCHAR(50),controlNo VARCHAR(50), controlNoEncInficare VARCHAR(20))
		DECLARE @sqlDom VARCHAR(MAX)
		SET @sqlDom = 'SELECT id, controlNo, controlNoEncInficare = dbo.encryptDbLocal(dbo.FNADecryptString(controlNo)) FROM dbo.remitTran WITH(NOLOCK) WHERE id IN (' + @tranIds + ') AND tranStatus = ''Payment'' AND payStatus = ''Unpaid'''
		INSERT INTO @tranDomDetail
		EXEC (@sqlDom)
				
		IF NOT EXISTS(SELECT 'X' FROM @tranDomDetail)
		BEGIN
			EXEC proc_errorHandler 1, 'No Transaction Found.', NULL
			RETURN
		END
		
		BEGIN TRAN
		UPDATE remitTran SET
			--,tranStatus					= 'POST'
			 payStatus					= 'Post'
			,postedBy					= @user
			,postedDate					= dbo.FNAGetDateInNepalTZ()
			,postedDateLocal			= GETDATE()	
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN @tranDomDetail td ON rt.id = td.tranId		
		COMMIT TRAN		
		EXEC proc_errorHandler 0, 'Transaction(s) post successfully', NULL		
	END

	IF @flag = 'post-unpaid'
	BEGIN
		DECLARE @tranId BIGINT,@encryptedControlNo VARCHAR(50)
		SELECT @tranId = id,@encryptedControlNo = controlNo ,@remarks ='POST TO UNPAID: '+ ISNULL(@remarks,'')
			FROM remitTran rt WITH(NOLOCK) WHERE controlNo = dbo.fnaEncryptString(@controlNo)
		BEGIN TRANSACTION
			UPDATE remitTran SET payStatus = 'Unpaid' WHERE controlNo = @encryptedControlNo		
			EXEC proc_transactionLogs @flag = 'i',@user = @user, @tranId = @tranId, @message = @remarks, @msgType = 'MODIFY',  @controlNo = @encryptedControlNo
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION	
		EXEC [proc_errorHandler] 0, 'Transaction has been updated successfully.', @controlNo
	END

	IF @flag = 'pendingCooperative'				
	BEGIN
		
		SET @sql =
		'SELECT
			 [Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Tran No]			= rt.id
			,[Sending Agent]	= rt.sAgentName
			,[Bank Name]		= rt.pBankName
			,[Branch Name]		= rt.pBankBranchName								
			,[Receiver Name]	= rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
			,[Bank A/C No]		= rt.accountNo
			,[Confirm Date]		= rt.approvedDate
			,[Payout Amount]	= rt.pAmt
			,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
		FROM [dbo].remitTran rt WITH(NOLOCK)
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		INNER JOIN agentMaster am on rt.pBank=am.agentId
	    WHERE am.agentGrp=''8026'' AND am.agentType IN(''2903'',''2904'')
		'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
		AND pBank = '''+CAST(@pAgent AS VARCHAR)+'''
		AND tranStatus = ''Payment''
		AND paymentMethod = ''Bank Deposit''
		AND payStatus = ''Unpaid'' 
		AND rt.sCountry = ''Nepal''
		AND tranType = ''D''
		ORDER BY [Unpaid Days] DESC'

		print @sql
		EXEC(@sql)
		RETURN
		
	END	
	IF @flag = 'postCop'
	BEGIN
		DECLARE @tranCopDetail TABLE(id INT IDENTITY(1,1),tranId VARCHAR(50),controlNo VARCHAR(50), controlNoEncInficare VARCHAR(20))
		DECLARE @sqlCop VARCHAR(MAX)
		SET @sqlCop = 'SELECT id, controlNo, controlNoEncInficare = dbo.encryptDbLocal(dbo.FNADecryptString(controlNo)) FROM dbo.remitTran WITH(NOLOCK) WHERE id IN (' + @tranIds + ') AND tranStatus = ''Payment'' AND payStatus = ''Unpaid'''
		INSERT INTO @tranCopDetail
		EXEC (@sqlCop)
				
		IF NOT EXISTS(SELECT 'X' FROM @tranCopDetail)
		BEGIN
			EXEC proc_errorHandler 1, 'No Transaction Found.', NULL
			RETURN
		END
		
		BEGIN TRAN
		UPDATE remitTran SET
			--,tranStatus					= 'POST'
			 payStatus					= 'Post'
			,postedBy					= @user
			,postedDate					= dbo.FNAGetDateInNepalTZ()
			,postedDateLocal			= GETDATE()	
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN @tranCopDetail td ON rt.id = td.tranId		
		COMMIT TRAN		
		EXEC proc_errorHandler 0, 'Transaction(s) post successfully', NULL		
	END


END TRY	
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, NULL
END CATCH




GO
