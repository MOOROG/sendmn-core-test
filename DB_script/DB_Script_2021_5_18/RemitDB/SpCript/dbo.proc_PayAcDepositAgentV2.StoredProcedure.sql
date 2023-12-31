USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PayAcDepositAgentV2]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_PayAcDepositAgentV2]
	 @flag				VARCHAR(50)
	,@pAgent			INT				= NULL
	,@tranIds			VARCHAR(MAX)	= NULL
	,@user				VARCHAR(50)		= NULL
	,@sortBy            VARCHAR(50)		= NULL
    ,@sortOrder         VARCHAR(5)		= NULL
    ,@pageSize          INT				= NULL
    ,@pageNumber        INT				= NULL
	,@approvedDate      VARCHAR(100)	= NULL
	,@approvedDateTo	VARCHAR(100)	= NULL
	,@controlNo			VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

/*
	Exec proc_PayAcDepositAgentV2 @flag='pendingList-dom', @pAgent = 4618
	Exec proc_PayAcDepositV2 @flag='pendingListDom',@mapCodeInt = '11300000',@user='dipesh'
	EXEC proc_domesticUnpaidListApi @flag = 'domList', @user = 'dipesh', @bankId = '11300000'
*/

DECLARE  
	@pAgentName varchar(200)
	,@pBranch int
	,@pBranchName varchar(200)
	,@pState varchar(200)
	,@pDistrict	varchar(200)
	,@pLocation	varchar(50)
	,@tranNos VARCHAR(MAX)
	,@select_field_list VARCHAR(MAX) = ''
	,@extra_field_list  VARCHAR(MAX) = ''
	,@table             VARCHAR(MAX) = ''
	,@sql_filter        VARCHAR(MAX) = ''

	IF @flag = 'pendingList-int'
	BEGIN
	
		-- ## International Txn Unpaid List
		IF @sortBy IS NULL
		   SET @sortBy = 'unpaidDays'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'DESC'
		SET @table = '(
			SELECT
				 controlNo		= dbo.FNADecryptString(rt.controlNo)
				,rt.id
				,rt.sCountry
				,rt.sAgentName
				,rt.pBankName
				,rt.pBankBranchName								
				,rt.ReceiverName
				,accountNo = ''<a href="International.aspx?tranId='' + CAST(rt.id AS VARCHAR) + ''">'' + CAST(rt.accountNo AS VARCHAR) + ''</a>''
				,rt.approvedDate
				,rt.pAmt
				,unpaidDays	 = DATEDIFF(D,rt.approvedDate,GETDATE())
			FROM [dbo].remitTran rt WITH(NOLOCK)
			WHERE tranStatus = ''Payment''
				AND paymentMethod in (''Bank Deposit'',''Relief Fund'')
				AND payStatus = ''Unpaid'' 
				AND rt.sCountry <> ''Nepal''
				AND rt.tranType = ''I''
				'
				+
				CASE WHEN @approvedDate IS NOT NULL THEN ' AND rt.approvedDate >= ''' + @approvedDate + '''' ELSE '' END 
				+
				CASE WHEN @approvedDateTo IS NOT NULL THEN ' AND rt.approvedDate <= ''' + @approvedDateTo + ' 23:59:59''' ELSE '' END 
				+
				CASE WHEN @controlNo IS NOT NULL THEN ' AND rt.controlNo = ''' + dbo.encryptdb(@controlNo) + '''' ELSE '' END 
				+

				'
		) x'
		SET @sql_filter = ''
		SET @select_field_list ='
				controlNo, id, sCountry, sAgentName
			   ,pBankName, pBankBranchName, ReceiverName
			   ,accountNo, approvedDate, pAmt, unpaidDays
			   '
			   
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber

		RETURN
	END
	
	IF @flag = 'pendingList-dom'
	BEGIN
		-- ## Domestic Txn Unpaid List
		IF @sortBy IS NULL
		   SET @sortBy = 'unpaidDays'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'DESC'
		SET @table = '(
			SELECT
				 controlNo = dbo.FNADecryptString(rt.controlNo)
				,rt.id
				,rt.sAgentName
				,rt.pBankName
				,rt.pBankBranchName								
				,rt.ReceiverName
				,rt.accountNo
				,rt.approvedDate
				,rt.pAmt
				,unpaidDays = DATEDIFF(D,rt.approvedDate,GETDATE())
			FROM [dbo].remitTran rt WITH(NOLOCK)
				WHERE pBank = ' + CAST(@pAgent AS VARCHAR(10)) + '
				AND tranStatus = ''Payment''
				AND paymentMethod = ''Bank Deposit''
				AND payStatus = ''Unpaid'' 
				AND rt.sCountry = ''Nepal''
				AND tranType = ''D'''
				+
				CASE WHEN @approvedDate IS NOT NULL THEN ' AND rt.approvedDate >= ''' + @approvedDate + '''' ELSE '' END 
				+
				CASE WHEN @approvedDateTo IS NOT NULL THEN ' AND rt.approvedDate <= ''' + @approvedDateTo + ' 23:59:59''' ELSE '' END 
				+
				CASE WHEN @controlNo IS NOT NULL THEN ' AND rt.controlNo = ''' + dbo.encryptdb(@controlNo) + '''' ELSE '' END 
				+
				'
		) x'

		SET @sql_filter = ''
		
		SET @select_field_list ='
				controlNo, id, sAgentName
			   ,pBankName, pBankBranchName, ReceiverName
			   ,accountNo, approvedDate, pAmt, unpaidDays
			   '
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber

		RETURN;		
		
	END
	IF @flag = 'pendingList'
	BEGIN
		-- ## International Txn Unpaid List
		SELECT
			 [Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Tran No]			= rt.id
			,[Sending Country]	= rt.sCountry
			,[Sending Agent]	= rt.sAgentName
			,[Bank Name]		= rt.pBankName
			,[Branch Name]		= rt.pBankBranchName								
			,[Receiver Name]	= rt.ReceiverName
			,[Bank A/C No]		= rt.accountNo
			,[Confirm Date]		= rt.approvedDate
			,[Payout Amount]	= rt.pAmt
			,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
		FROM [dbo].remitTran rt WITH(NOLOCK)
		WHERE pAgent = @pAgent
		AND tranStatus = 'Payment'
		AND paymentMethod in ('Bank Deposit','Relief Fund')
		AND payStatus = 'Unpaid' 
		AND rt.sCountry <> 'Nepal'
		AND rt.tranType = 'I'
		ORDER BY [Unpaid Days] DESC
		
		-- ## Domestic Txn Unpaid List
		SELECT
			 [Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Tran No]			= rt.id
			,[Sending Agent]	= rt.sAgentName
			,[Bank Name]		= rt.pBankName
			,[Branch Name]		= rt.pBankBranchName								
			,[Receiver Name]	= rt.ReceiverName
			,[Bank A/C No]		= rt.accountNo
			,[Confirm Date]		= rt.approvedDate
			,[Payout Amount]	= rt.pAmt
			,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
		FROM [dbo].remitTran rt WITH(NOLOCK)
		INNER JOIN agentMaster am on rt.pBank=am.agentId
		WHERE 1=1  
		AND (am.agentGrp ='4301' OR am.agentGrp IS NULL) 
		AND (am.agentType='2903' OR am.agentType='2905')
		AND pBank = @pAgent
		AND tranStatus = 'Payment'
		AND paymentMethod = 'Bank Deposit'
		AND payStatus = 'Unpaid' 
		AND rt.sCountry = 'Nepal'
		AND tranType = 'D'
		ORDER BY [Unpaid Days] DESC
		RETURN;		
		
	END
	IF @flag = 'payIntl'
	BEGIN
		DECLARE @tranDetail TABLE(id INT IDENTITY(1,1), tranId VARCHAR(50), controlNo VARCHAR(50), sRouteId VARCHAR(5))
		DECLARE @sql VARCHAR(MAX)
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
		WHERE am.agentId = @pAgent
		
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
			WHERE am.agentId = @pAgent
		END
		
		IF EXISTS(SELECT TOP 1 'A' FROM APPLICATIONUSERS(NOLOCK) WHERE UserName = @user and userType ='HO')
		BEGIN
			SELECT @pAgentName = agentName,@pAgent = agentId,@pBranch = agentId,@pBranchName = agentName
			FROM AGENTMASTER(NOLOCK) WHERE agentId = 4680
		END

		BEGIN TRAN
			UPDATE remitTran SET
				 pBranch					= @pBranch
				,pBranchName				= @pBranchName
				,pAgent						= ISNULL(@pAgent,pAgent)
				,pAgentName					= ISNULL(@pAgentName,pAgentName)
				,pState						= @pState
				,pDistrict					= @pDistrict
				,pLocation					= @pLocation
				,pAgentComm					= CASE WHEN rt.paymentMethod = 'Relief Fund' THEN 0 ELSE  (
												 SELECT amount FROM dbo.FNAGetPayComm
												 (NULL,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = rt.sCountry), 
													 NULL, 1002, 151, @pLocation, @pBranch, 'NPR'
														,2, rt.cAmt, rt.pAmt, rt.serviceCharge, NULL, NULL
													)
												 )
												END
				,pAgentCommCurrency			= 'NPR'
				,tranStatus					= 'Paid'
				,payStatus					= 'Paid'
				,paidBy						= @user
				,paidDate					= dbo.FNAGetDateInNepalTZ()
				,paidDateLocal				= GETDATE()	
			FROM remitTran rt with(nolock) 
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
	END

	IF @flag = 'payDom'
	BEGIN
		DECLARE @tranDomDetail TABLE(id INT IDENTITY(1,1),tranId VARCHAR(50),controlNo VARCHAR(50), controlNoEncInficare VARCHAR(20))
		DECLARE @sqlDom VARCHAR(MAX)
		SET @sqlDom = 'SELECT id, controlNo, controlNoEncInficare = dbo.encryptDbLocal(dbo.FNADecryptString(controlNo)) 
		FROM dbo.remitTran WITH(NOLOCK) WHERE id IN (' + @tranIds + ') AND tranStatus = ''Payment'' AND payStatus = ''Unpaid'''
		INSERT INTO @tranDomDetail
		EXEC (@sqlDom)
	
		IF NOT EXISTS(SELECT 'X' FROM @tranDomDetail)
		BEGIN
			EXEC proc_errorHandler 1, 'No Transaction Found.', NULL
			RETURN
		END
		
		IF EXISTS(SELECT TOP 1 'A' FROM APPLICATIONUSERS(NOLOCK) WHERE UserName = @user and userType ='HO')
		BEGIN
			SELECT @pAgentName = agentName,@pAgent = agentId,@pBranch = agentId,@pBranchName = agentName
			FROM AGENTMASTER(NOLOCK) WHERE agentId = 4680
		END
		BEGIN TRAN
			UPDATE remitTran SET
				 tranStatus					= 'Paid'
				,payStatus					= 'Paid'
				,pAgent						= ISNULL(@pAgent,pBank)
				,pAgentName					= ISNULL(@pAgentName,pBankName)
				,pBranch					= ISNULL(@pBranch,pBankBranch)
				,pBranchName				= ISNULL(@pBranchName,pBankBranchName)
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
	IF @flag = 'payCooperative'	
	BEGIN
		DECLARE @tranDomDetailCo TABLE(id INT IDENTITY(1,1),tranId VARCHAR(50),controlNo VARCHAR(50), controlNoEncInficare VARCHAR(20),sBranch INT,pAmt MONEY,pBranch INT,pAgentComm MONEY  ,pSuperAgentComm MONEY)
		DECLARE @sqlDomCo VARCHAR(MAX)
		SET @sqlDomCo = 'SELECT id, controlNo, controlNoEncInficare = dbo.encryptDbLocal(dbo.FNADecryptString(controlNo)) ,sBranch,pAmt,pBranch	,0 pAgentComm,0	pSuperAgentComm
							FROM dbo.remitTran WITH(NOLOCK) WHERE id IN (' + @tranIds + ')
							AND tranStatus = ''Payment'' AND payStatus = ''Unpaid'''
		INSERT INTO @tranDomDetailCo
		EXEC (@sqlDomCo)
				
		IF NOT EXISTS(SELECT 'X' FROM @tranDomDetailCo)
		BEGIN
			EXEC proc_errorHandler 1, 'No Transaction Found.', NULL
			RETURN
		END
		
		  UPDATE t SET 
			t.pAgentComm=ISNULL(X.pAgentComm, 0),
			t.pSuperAgentComm=ISNULL(X.psAgentComm, 0)
		  from  @tranDomDetailCo t
		  CROSS APPLY dbo.FNAGetDomesticPayComm(t.sBranch,@pAgent,2,t.pAmt)X	
		  
		  	
		BEGIN TRAN
		UPDATE remitTran SET
			 tranStatus					= 'Paid'
			,payStatus					= 'Paid'
			,pAgent						= pBank
			,pAgentName					= pBankName
			,pBranch					= pBankBranch
			,pBranchName				= pBankBranchName
			,pSuperAgentComm			= td.pSuperAgentComm
			,pSuperAgentCommCurrency	= 'NPR'
			,pAgentComm					= td.pAgentComm
			,pAgentCommCurrency			= 'NPR'
			,paidBy						= @user
			,paidDate					= dbo.FNAGetDateInNepalTZ()
			,paidDateLocal				= GETDATE()
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN @tranDomDetailCo td ON rt.id = td.tranId

		-- ## Update Accounting
		EXEC dbo.proc_payAcDepositAC
			 @flag				= 'payCooperative'
			,@user				= @user
			,@tranIds			= @tranIds
		
		COMMIT TRAN		
		EXEC proc_errorHandler 0, 'Transaction(s) paid successfully', NULL		
	END
	IF @flag = 'pendingListCop'
	BEGIN
		
		-- ## Cooperation Txn Unpaid List
		SELECT
			 [Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Tran No]			= rt.id
			,[Sending Agent]	= rt.sAgentName			
			,[Branch Name]		= rt.pBankBranchName								
			,[Receiver Name]	= rt.ReceiverName
			,[Bank A/C No]		= rt.accountNo
			,[Confirm Date]		= rt.approvedDate
			,[Payout Amount]	= rt.pAmt
			,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
		FROM [dbo].remitTran rt WITH(NOLOCK)
		INNER JOIN agentMaster am on rt.pBank=am.agentId
	    WHERE (am.agentGrp='8026' OR am.agentGrp='9906') AND am.agentType IN('2903','2904')
		AND pBankBranch=@pAgent
		AND  tranStatus = 'Payment'
		AND paymentMethod = 'Bank Deposit'
		AND payStatus = 'Unpaid' 
		AND rt.sCountry = 'Nepal'
		AND tranType = 'D'
		ORDER BY [Unpaid Days] DESC
		RETURN;		
		
	END

GO
