USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PayAcDepositV2]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_PayAcDepositV2]
	 @flag			VARCHAR(50)
	,@pAgent		INT				= NULL
	,@mapCodeInt	VARCHAR(100)	= NULL
	,@tranIds		VARCHAR(MAX)	= NULL
	,@fromDate		VARCHAR(20)		= NULL
	,@toDate		VARCHAR(20)		= NULL
	,@user			VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE  @pAgentName varchar(200)
		,@pBranch int
		,@pBranchName varchar(200)
		,@pState varchar(200)
		,@pDistrict	varchar(200)
		,@pLocation	varchar(50)
		,@tranNos VARCHAR(MAX)
		,@sql VARCHAR(MAX)

	/*
		Exec proc_PayAcDepositV2 @flag='pendingList',@user='admin'
		Exec proc_PayAcDepositV2 @flag='pendingListDom',@mapCodeInt = '11300000',@user='dipesh'
		EXEC proc_domesticUnpaidListApi @flag = 'domList', @user = 'dipesh', @bankId = '11300000'
	*/

	IF @flag = 'pendingList'
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
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''
		SET @sql = @sql +'
			AND paymentMethod in (''Bank Deposit'' ,''Relief Fund'')
			AND tranStatus = ''Payment'' 
			AND payStatus = ''Unpaid'' 
			AND tranType = ''I''
			GROUP BY pAgent, pAgentName'

		EXEC(@sql)
		
		SET @sql= 'SELECT
			 pAgent			= pBank
			,pAgentName		= pBankName
			,txnCount		= COUNT(*)
			,amt			= SUM(pAmt)
		FROM remitTran rt WITH(NOLOCK)
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''
		SET @sql = @sql +'
			AND paymentMethod = ''Bank Deposit'' 
			AND tranStatus = ''Payment'' 
			AND payStatus = ''Unpaid'' 
			AND tranType = ''D''
			GROUP BY pBank, pBankName'
		EXEC(@sql)
		RETURN
	END

	IF @flag = 'pendingListIntl'				
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
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''
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

	IF @flag = 'pendingListDom'				
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
		SET @sql = @sql +' AND rt.createdDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''
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

	IF @flag = 'payIntl'
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
		
		SELECT  
		     @pAgent			= am.agentId
			,@pAgentName		= am.agentName
			,@pBranch			= bm.agentId
			,@pBranchName		= bm.agentName 
			,@pState			= bm.agentState
			,@pDistrict			= bm.agentDistrict
			,@pLocation			= bm.agentLocation
		FROM agentMaster am WITH(NOLOCK)
		LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId AND bm.isHeadOffice = 'Y'
		WHERE am.agentId = @pAgent and isnull(bm.isDeleted,'N') = 'N' and bm.isActive = 'Y'
		
		IF @pBranch IS NULL
		BEGIN
			SELECT TOP 1
				 @pAgent			= am.agentId
				,@pAgentName		= am.agentName
				,@pBranch			= bm.agentId
				,@pBranchName		= bm.agentName 
				,@pState			= bm.agentState
				,@pDistrict			= bm.agentDistrict
				,@pLocation			= bm.agentLocation
			FROM agentMaster am WITH(NOLOCK)
			LEFT JOIN agentMaster bm WITH(NOLOCK) ON am.agentId = bm.parentId
			WHERE am.agentId = @pAgent and isnull(bm.isDeleted,'N') = 'N' and bm.isActive = 'Y'
		END
		
		BEGIN TRAN
			UPDATE remitTran SET
				 pBranch					= @pBranch
				,pBranchName				= @pBranchName
				,pState						= @pState
				,pDistrict					= @pDistrict
				,pAgentComm					= case when rt.paymentMethod='Relief Fund' then 0 else (
												 SELECT amount FROM dbo.FNAGetPayComm(
														NULL
														,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = rt.sCountry), NULL, 1002, 151, @pLocation, @pBranch, 'NPR'
														,2, rt.cAmt, rt.pAmt, rt.serviceCharge, NULL, NULL
													)
												)
												end
				,pAgentCommCurrency			= 'NPR'
				,pSuperAgentComm			= 0
				,pSuperAgentCommCurrency	= 'NPR'
				,tranStatus					= 'Paid'
				,payStatus					= 'Paid'
				,paidBy						= @user
				,paidDate					= dbo.FNAGetDateInNepalTZ()
				,paidDateLocal				= GETDATE()	
			FROM remitTran rt WITH(NOLOCK)
			INNER JOIN @tranDetail td on rt.id = td.tranId

			-- ## Update Accounting
			EXEC dbo.proc_payAcDepositAC
				 @flag				= 'payIntl'
				,@user				= @user
				,@tranIds			= @tranIds

			-- ## sending sms
			insert into smsQueueAcDepositTxn(tranId)
			select tranId from @tranDetail
				
			-- ## Queue Table for Data Integration
			INSERT INTO payQueue2(controlNo, pAgent, pAgentName, pBranch, pBranchName, paidBy, paidDate, paidBenIdType, paidBenIdNumber, routeId)
			SELECT controlNo, @pAgent, @pAgentName, @pBranch, @pBranchName, @user, dbo.FNAGetDateInNepalTZ(), NULL, NULL, sRouteId
			FROM @tranDetail WHERE sRouteId IS NOT NULL
						
		COMMIT TRAN
		
		EXEC proc_errorHandler 0, 'Transaction(s) paid successfully', NULL
		RETURN
	END

	IF @flag = 'payDom'
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
				 tranStatus					= 'Paid'
				,payStatus					= 'Paid'
				,pAgent						= pBank
				,pAgentName					= pBankName
				,pBranch					= pBankBranch
				,pBranchName				= pBankBranchName
				,pSuperAgentComm			= 0
				,pSuperAgentCommCurrency	= 'NPR'
				,pAgentComm					= 0
				,pAgentCommCurrency			= 'NPR'
				,paidBy						= @user
				,paidDate					= dbo.FNAGetDateInNepalTZ()
				,paidDateLocal				= GETDATE()
			FROM remitTran rt WITH(NOLOCK)
			INNER JOIN @tranDomDetail td ON rt.id = td.tranId

			-- ## Update Accounting
			EXEC dbo.proc_payAcDepositAC
				 @flag				= 'payDom'
				,@user				= @user
				,@tranIds			= @tranIds
		
		COMMIT TRAN		
		EXEC proc_errorHandler 0, 'Transaction(s) paid successfully', NULL		
	END

GO
