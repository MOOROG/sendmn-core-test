USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PostAcDepositISO]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_PostAcDepositISO]
	 @flag			VARCHAR(50)
	,@pAgent		INT				= NULL
	,@mapCodeInt	VARCHAR(100)	= NULL
	,@tranIds		VARCHAR(MAX)	= NULL
	,@fromDate		VARCHAR(20)		= NULL
	,@toDate		VARCHAR(20)		= NULL
	,@controlNo		VARCHAR(50)		= NULL
	,@remarks		VARCHAR(MAX)	= NULL
	,@user			VARCHAR(50)		= NULL
	,@fromTime		VARCHAR(20)		= NULL
	,@toTime		VARCHAR(20)		= NULL
	,@xml			XML		= NULL
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
	IF NOT @flag = 'recon'
	BEGIN
		IF @fromTime IS NOT NULL
			SET @fromDate = @fromDate+' '+@fromTime
		ELSE 
			SET @fromDate = @fromDate+' 23:59:59'
		IF @toTime IS NOT NULL
			SET @toDate = @toDate+' '+@toTime 
		ELSE
			SET @toDate = @toDate+' 23:59:59'
	END

	IF @flag = 'recon'
	BEGIN
		DECLARE @error VARCHAR(500)
		SELECT TOP 1
			@error = c.value('@error', 'varchar(500)')
		FROM @xml.nodes('root/row') r(c)
		IF NULLIF(LTRIM(@error), '') IS NOT NULL
		BEGIN	
			SELECT 1 As ErrorCode, @error [Message] --, Null	ID		
		END
		ELSE
		BEGIN
			DECLARE @referenceIdList TABLE (id BIGINT PRIMARY KEY, IME VARCHAR(10), GIBL VARCHAR(10))
			
			INSERT @referenceIdList(id, IME, GIBL)
			SELECT 
				rt.id, 'PAID', 'UNPAID'
			FROM remitTran rt (READPAST)
			INNER JOIN vwBankDepositFromISO vw ON rt.id = vw.id 
			WHERE paidDate BETWEEN @fromDate AND @toDate+' 23:59:59'
			AND pAgent = 2054
			
			INSERT @referenceIdList(id, IME, GIBL)
			SELECT 
				x.id, 'UNPAID', 'PAID'
			FROM (
				SELECT 
					Id = SUBSTRING(c.value('@id', 'VARCHAR(40)'), 4, 900)
				FROM @xml.nodes('root/row') r(c)
			) x 
			LEFT JOIN @referenceIdList t ON x.Id = x.Id 
			WHERE t.Id IS NULL

			UPDATE t SET 
				t.GIBL='PAID'
			FROM @referenceIdList t
			INNER JOIN (
				SELECT 
					Id = SUBSTRING(c.value('@id', 'VARCHAR(40)'), 4, 900)
				FROM @xml.nodes('root/row') r(c)			
			) x ON t.id = x.Id 

			SELECT 
				 [AC Number] = rt.accountNo
				,[Send Date] = CONVERT(VARCHAR(10), rt.createdDate, 101) 
				,[Paid Date] = CONVERT(VARCHAR(10), rt.paidDate, 101) 
				,[Amount] = rt.pAmt
				,[IME Status] = CASE WHEN t.IME = 'PAID' THEN '<span style="color:green">' ELSE '<span style="color:red">' END + t.IME + '</span>'
				,[GIBL Status] = CASE WHEN t.GIBL = 'PAID' THEN '<span style="color:green">' ELSE '<span style="color:red">' END + t.GIBL + '</span>'
				,dbo.decryptDb(controlNo) [Control Number]
			FROM remitTran rt (NOLOCK) 
			INNER JOIN @referenceIdList t ON t.id = rt.id 
		END

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value		

		SELECT title = 'Global Bank Direct Deposit (ISO)'

		RETURN	
	END
	IF @flag = 'pending'
	BEGIN
		SET @sql =
		'SELECT
			 pAgent			= rt.pAgent
			,pAgentName		= rt.pAgentName
			,txnCount		= COUNT(*)
			,amt			= SUM(rt.pAmt)
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN IsoBankSetup b with(nolock) on rt.pAgent = b.bankId 
		AND ISNULL(b.isActive,''Y'') <> ''N''
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
			AND rt.paymentMethod in (''Bank Deposit'' ,''Relief Fund'')
			AND rt.tranStatus = ''Payment'' 
			AND rt.payStatus = ''Unpaid'' 
			AND rt.tranType = ''I''
			GROUP BY rt.pAgent, rt.pAgentName'

		EXEC(@sql)
		
		SET @sql= 'SELECT
			 pAgent			= rt.pAgent
			,pAgentName		= rt.pAgentName
			,txnCount		= COUNT(*)
			,amt			= SUM(rt.pAmt)
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN IsoBankSetup b with(nolock) on rt.pAgent = b.bankId 
		AND ISNULL(b.isActive,''Y'') <> ''N''
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
			AND rt.paymentMethod = ''Bank Deposit'' 
			AND rt.tranStatus = ''Payment'' 
			AND rt.payStatus = ''Unpaid'' 
			AND rt.tranType = ''D''
			GROUP BY rt.pAgent, rt.pAgentName'
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
		AND pAgent = '''+CAST(@pAgent AS VARCHAR)+'''
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
		IF NOT EXISTS(SELECT 'x' FROM dbo.IsoBankSetup WITH(NOLOCK) WHERE bankId = @pAgent AND ISNULL(isActive,'Y') <> 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'ISO bank has not been setup for this BANK yet.', NULL
			RETURN
		END 
		BEGIN TRAN
		UPDATE remitTran SET
			 expectedPayoutAgent		= 'iso'
			,payStatus					= 'Post'
			,postedBy					= @user
			,postedDate					= dbo.FNAGetDateInNepalTZ()
			,postedDateLocal			= GETDATE()	
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN @tranDetail td on rt.id = td.tranId

		INSERT INTO acDepositQueueIso(tranId,pBank,toAc,toBankCode,amount,remarks,createdBy,createdDate, referenceId)
		SELECT rt.id,rt.pAgent,rt.accountNo,NULL,rt.pAmt, dbo.decryptdb(rt.controlNo) ,@user,dbo.FNAGetDateInNepalTZ(), 'IME' + CAST(rt.id AS VARCHAR(15))
		FROM dbo.remitTran rt WITH(NOLOCK) 
		INNER JOIN @tranDetail t ON rt.id = t.tranId

		COMMIT TRAN		
		EXEC proc_errorHandler 0, 'Transaction(s) posted to ISO successfully', NULL
		RETURN
	END
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
		IF NOT EXISTS(SELECT 'x' FROM dbo.IsoBankSetup WITH(NOLOCK) WHERE bankId = @pAgent AND ISNULL(isActive,'Y') <> 'N') AND @pAgent <> 3259
		BEGIN
			EXEC proc_errorHandler 1, 'ISO bank has not been setup for this BANK yet.', NULL
			RETURN
		END 
		BEGIN TRAN
		UPDATE remitTran SET
			 expectedPayoutAgent		= 'iso'
			,payStatus					= 'Post'
			,postedBy					= @user
			,postedDate					= dbo.FNAGetDateInNepalTZ()
			,postedDateLocal			= GETDATE()	
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN @tranDomDetail td ON rt.id = td.tranId	
		
		INSERT INTO acDepositQueueIso(tranId,pBank,toAc,toBankCode,amount,remarks,createdBy,createdDate)
		SELECT rt.id,pAgent,rt.accountNo,NULL,rt.pAmt, dbo.decryptdb(rt.controlNo), @user,dbo.FNAGetDateInNepalTZ() 
		FROM dbo.remitTran rt WITH(NOLOCK) INNER JOIN @tranDomDetail t ON rt.id = t.tranId
			
		COMMIT TRAN		
		EXEC proc_errorHandler 0, 'Transaction(s) posted to ISO successfully', NULL		
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
