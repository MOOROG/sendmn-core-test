USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_amlOCrpt]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_amlOCrpt]
	 @flag					VARCHAR(10)
	,@user					VARCHAR(30)
	-------------------------------------------
	,@sCountry				VARCHAR(50) = NULL
	,@rCountry				VARCHAR(50) = NULL
	,@sAgent				VARCHAR(50) = NULL
	,@rAgent				VARCHAR(50) = NULL
	,@rMode					VARCHAR(50) = NULL
	,@dateType				VARCHAR(50)	= NULL
	,@frmDate				VARCHAR(50) = NULL
	,@toDate				VARCHAR(50) = NULL
	-------------------------------------------
	,@rptBy					VARCHAR(50) = NULL
	,@rptFor				VARCHAR(50) = NULL
	,@tcNo					VARCHAR(50) = NULL
	-------------------------------------------
	,@ocType				VARCHAR(50) = NULL
	,@ocRptType				VARCHAR(50) = NULL
	-------------------------------------------
	,@recName				VARCHAR(100) = NULL
	,@date					VARCHAR(10)	 = NULL
	,@sCustomer				VARCHAR(10)	 = NULL
	-------------------------------------------
	,@pageNumber			INT			= 1
	,@pageSize				INT			= 50
	,@isExportFull			VARCHAR(1)	= NULL
AS


SET NOCOUNT ON
BEGIN TRY 
	DECLARE @table VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @globalFilter VARCHAR(MAX) = ''
	DECLARE @branchFilter VARCHAR(MAX) = ''
	DECLARE @URL	VARCHAR(MAX) = ''
	DECLARE @reportHead		VARCHAR(100) = ''
	
	SET @recName = REPLACE(@recName,'__',' ')
	SET @rMode = REPLACE(@rMode,'__',' ')

	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))

	SET @pageNumber	= ISNULL(@pageNumber, 1)
	SET @pageSize	= ISNULL(@pageSize, 100)

	SET @globalFilter = ' AND rt.tranStatus <> ''Cancel'''
	
	IF @sCountry is not null 
	BEGIN
		INSERT @FilterList
		SELECT 'Sender Country', @sCountry
		SET @globalFilter = @globalFilter + ' AND rt.sCountry = ''' + @sCountry + ''''
	END
	IF @rCountry is not null 
	BEGIN
		INSERT @FilterList
		SELECT 'Receiver Country', @rCountry
		SET @globalFilter = @globalFilter + ' AND rt.pCountry = ''' + @rCountry + ''''
	END	
	IF @sAgent IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Sender Agent', am.agentName 
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @sAgent
		SET @globalFilter = @globalFilter + ' AND rt.sAgent = ''' + @sAgent + ''''
	END
	IF @rAgent IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Receiver Agent', am.agentName 
		FROM agentMaster am WITH(NOLOCK) WHERE agentId = @rAgent
		SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @rAgent + ''''
	END	
	IF @rMode IS NOT NULL
	BEGIN
		INSERT @FilterList
		SELECT 'Receiving Mode', @rMode
		SET @globalFilter = @globalFilter + ' AND rt.paymentMethod = ''' + @rMode + ''''
	END	
	INSERT @FilterList
	SELECT 'Date Type',  
	case when @dateType = 'txnDate' then 'TXN Date'
		when @dateType = 'confirmDate' then 'Confirm Date'
		when @dateType = 'paidDate' then 'Paid Date' end

	IF @dateType = 'txnDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.createdDate BETWEEN  ''' + @frmDate + ''' AND ''' + @toDate + ' 23:59:59'''
		INSERT @FilterList
		SELECT 'To Date', @toDate
	END	
	IF @dateType = 'confirmDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate BETWEEN ''' + @frmDate + ''' AND ''' + @toDate + ' 23:59:59'''
		INSERT @FilterList
		SELECT 'To Date', @toDate
	END	
	IF @dateType = 'paidDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.paidDate BETWEEN ''' + @frmDate + ''' AND ''' + @toDate + ' 23:59:59'''
		INSERT @FilterList
		SELECT 'To Date', @toDate
	END	


	IF @flag = 'oc'
	BEGIN 
		DECLARE @JOIN_TABLE AS VARCHAR(100)

		IF @ocRptType ='3'
			SET @JOIN_TABLE = ' INNER JOIN remitTranCompliance OFAC WITH (NOLOCK) ON rt.holdTranId = OFAC.tranId'
		ELSE
			SET @JOIN_TABLE = ' INNER JOIN remitTranOfac OFAC WITH (NOLOCK) ON rt.holdTranId = OFAC.tranId'
		SET @table = '
		SELECT
			 [TXN Date]				= rt.createdDate
			,[TXN No.]				= CAST(rt.holdTranId AS VARCHAR)	
			,[Number of TXN]		= 1				  
			,[Sender Name]			= rt.senderName
			,[Receiver Name]		= rt.receiverName
			,[Sending_Country]		= rt.sCountry 
			,[Sending_Agent]		= rt.sAgentName 
			,[Sending_Branch]		= rt.sBranchName
			,[Sending_User]			= rt.createdBy 
			,[Collection_Currency]	= rt.collCurr 
			,[Collection_Amount]	= rt.cAmt		
			,[Payout_USD AMT]		= ISNULL(rt.tAmt / NULLIF(rt.sCurrCostRate, 0), 0)
			,[Payout_Currency]		= rt.payoutCurr 
			,[Payout_Amount]		= rt.pAmt		
			,[Payout_Country]		= rt.pCountry 	
			,[Approved By]			= rt.approvedBy
			,[Approved On]			= rt.approvedDate 	
			,[Hold Reason]          = OFAC.reason
			,[Released By]			= OFAC.approvedBy
			,[Released Date]		= OFAC.approvedDate
			,[Released Remarks]		= OFAC.approvedRemarks		
			,[Reason]				= OFAC.reason			
		FROM vwremitTran rt WITH(NOLOCK)
		'
			+@JOIN_TABLE+

		'
		WHERE 1=1 and rt.tranStatus <>''cancel''	'+
		CASE @ocType
			WHEN '2' THEN REPLACE(@globalFilter, 'rt.createdDate', 'OFAC.approvedDate')
			ELSE @globalFilter
		END	
		
		if @ocRptType ='1'
			SET @table =  @table + ' AND isnull(OFAC.flag,'''') IN (''A'',''O'','''')'
		
		if @ocRptType ='2'
			SET @table =  @table + ' AND OFAC.flag IN (''A'',''M'')'

		INSERT @FilterList
		SELECT 'OFAC Date Type ',CASE WHEN @ocType = '1' THEN 'TXN Date' ELSE 'Approved Date' END
	
		INSERT @FilterList
		SELECT 'Report Type', 
			CASE @ocRptType
				WHEN '1' THEN 'OFAC'
				WHEN '2' THEN 'Black List'
				WHEN '3' THEN 'Compliance'
			END

		IF @isExportFull = 'Y'
		BEGIN
			SET @sql = '
				SELECT
					 [Sno.]	= [S.N]
					,[TXN Date]
					,[TXN No.] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([TXN No.] AS VARCHAR(50)) + '');">'' +  CAST([TXN No.] AS VARCHAR(50)) + ''</span>''				  
					,[Sender Name]
					,[Receiver Name]
					,[Sending_Country]
					,[Sending_Agent]
					,[Sending_Branch]
					,[Sending_User]
					,[Collection_Currency]
					,[Collection_Amount]
					,[Payout_USD AMT]
					,[Payout_Currency]
					,[Payout_Amount]
					,[Payout_Country]					
					,[Approved By]
					,[Approved On]
					,[Hold Reason]	
					,[Released By]	
					,[Released Date]
					,[Released Remarks]
				FROM (		
					SELECT 
						ROW_NUMBER() OVER (ORDER BY [Number of TXN]) AS [S.N],* 
					FROM (' + @table + ') x		
				) AS tmp'
		
			PRINT @sql
			EXEC (@sql)
		END
		ELSE
		BEGIN
			SET @sql = 'SELECT 
						COUNT(*) AS TXNCOUNT
						,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
						,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
					FROM (' + @table + ') x'
			
			EXEC (@sql)
			
			SET @sql = '
				SELECT
					 [Sno.]	= [S.N]
					,[TXN Date]
					,[TXN No.] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([TXN No.] AS VARCHAR(50)) + '');">'' +  CAST([TXN No.] AS VARCHAR(50)) + ''</span>''				  
					,[Sender Name]
					,[Receiver Name]
					,[Sending_Country]
					,[Sending_Agent]
					,[Sending_Branch]
					,[Sending_User]
					,[Collection_Currency]
					,[Collection_Amount]
					,[Payout_USD AMT]
					,[Payout_Currency]
					,[Payout_Amount]
					,[Payout_Country]					
					,[Approved By]
					,[Approved On]
					,[Hold Reason]	
					,[Released By]	
					,[Released Date]
					,[Released Remarks]
				FROM (		
					SELECT 
						ROW_NUMBER() OVER (ORDER BY [Number of TXN]) AS [S.N],* 
					FROM (' + @table + ') x		
				) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
		
			PRINT @sql
			EXEC (@sql)
		END	
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
  
	SELECT * FROM @FilterList
   
	SELECT 'AML Reports : '+@reportHead title

	END TRY

	BEGIN CATCH
		 IF @@TRANCOUNT > 0
		 ROLLBACK TRANSACTION
		 DECLARE @errorMessage VARCHAR(MAX)
		 SET @errorMessage = ERROR_MESSAGE()
		 EXEC proc_errorHandler 1, @errorMessage ,NULL 
	END CATCH



GO
