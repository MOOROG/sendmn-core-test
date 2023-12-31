USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PayAcDepositAgentV2_Dom]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_PayAcDepositAgentV2_Dom]
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

	IF @flag = 'pendingList-dom'
	BEGIN
		
		IF OBJECT_ID(N'tempdb..#tmpBankMaping') IS NOT NULL
		BEGIN
			DROP TABLE #tmpBankMaping
		END
		 
		CREATE TABLE #tmpBankMaping (bankCode INT PRIMARY KEY)

		INSERT INTO #tmpBankMaping
			SELECT DISTINCT subBankCode FROM BankCodeMaping WHERE mainBankCode = @pAgent

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
				,accountNo = ''<a href="Domestic.aspx?tranId='' + CAST(rt.id AS VARCHAR) + ''">'' + CAST(rt.accountNo AS VARCHAR) + ''</a>''
				,rt.approvedDate
				,rt.pAmt
				,unpaidDays = DATEDIFF(D,rt.approvedDate,GETDATE())
			FROM [dbo].remitTran rt WITH(NOLOCK)
			INNER JOIN #tmpBankMaping bm ON rt.pBank = bm.bankCode
				WHERE tranStatus = ''Payment''
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
	
	


GO
