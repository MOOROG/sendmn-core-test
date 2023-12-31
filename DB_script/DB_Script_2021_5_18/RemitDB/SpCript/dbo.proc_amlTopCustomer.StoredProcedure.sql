USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_amlTopCustomer]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  proc [dbo].[proc_amlTopCustomer]
	 @flag					VARCHAR(10)
	,@user					VARCHAR(30)
	-------------------------------------------
	,@sCountry				VARCHAR(50) = NULL
	,@rCountry				VARCHAR(50) = NULL
	,@sAgent				VARCHAR(50) = NULL
	,@rAgent				VARCHAR(50) = NULL
	,@rMode					VARCHAR(50) = NULL
	,@dateType				VARCHAR(10)	= NULL
	,@frmDate				VARCHAR(50) = NULL
	,@toDate				VARCHAR(50) = NULL
	-------------------------------------------
	,@rptBy					VARCHAR(50) = NULL
	,@rptFor				VARCHAR(50) = NULL
	,@tcNo					VARCHAR(50) = NULL
	-------------------------------------------
	,@pageNumber			INT			= 1
	,@pageSize				INT			= 50
	,@isExportFull			VARCHAR(1)	= NULL
	,@reportType			VARCHAR(50) = NULL
AS
SET NOCOUNT ON

BEGIN TRY 
	DECLARE @table VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @globalFilter VARCHAR(MAX) = ''
	DECLARE @URL	VARCHAR(MAX) = ''
	DECLARE @reportHead		VARCHAR(100) = ''
	
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
	--IF @tranType IS NOT NULL
	--BEGIN
	--	INSERT @FilterList
	--	SELECT 'Tran Type', @tranType
	--	SET @globalFilter = @globalFilter + ' AND rt.tranType = ''' + @tranType + ''''
	--END	
	INSERT @FilterList
	SELECT 'Date Type',  
	case when @dateType = 'txnDate' then 'TXN Date'
		when @dateType = 'confirmDate' then 'Confirm Date'
		when @dateType = 'paidDate' then 'Paid Date' end

	IF @dateType = 'txnDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.createdDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', @toDate
		SET @globalFilter = @globalFilter + ' AND rt.createdDate <= ''' + @toDate + ' 23:59:59'''
	END	
	IF @dateType = 'confirmDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', @toDate
		SET @globalFilter = @globalFilter + ' AND rt.approvedDate <= ''' + @toDate + ' 23:59:59'''
	END	
	IF @dateType = 'paidDate'
	BEGIN
		INSERT @FilterList
		SELECT 'From Date', @frmDate
		SET @globalFilter = @globalFilter + ' AND rt.paidDate >= ''' + @frmDate + ''''
		INSERT @FilterList
		SELECT 'To Date', @toDate
		SET @globalFilter = @globalFilter + ' AND rt.paidDate <= ''' + @toDate + ' 23:59:59'''
	END	


IF @flag = 'tc'
BEGIN 

	SET @reportHead ='Top Customer'
	IF @rptFor = 'Sender'
		SET @URL='"Reports.aspx?dateType='+@dateType+'&frmDate='+@frmDate+'&toDate='+@toDate+'&sCountry='
		+isnull(replace(@sCountry,' ','__'),'')+'&sAgent='+isnull(@sAgent,'')
		+'&rMode='+ISNULL(REPLACE(@rMode,' ','__'),'')+'&rCountry='
		+isnull(replace(@rCountry,' ','__'),'')+'&rAgent='+ISNULL(@rAgent,'')
		+'&rptBy='+@rptBy+'&rptFor='+ISNULL(@rptFor,'')+'&reportName=amlddlreport&recName=' 
		+ CASE WHEN @rptFor = 'Sender' THEN '''+REPLACE(rt.senderName,'' '',''__'')+''' ELSE '''+REPLACE(rt.receiverName,'' '',''__'')+''' END 
		+ '&flag=tc_ddl&country=''+REPLACE(ISNULL(ts.nativeCountry,''''),'' '',''__'') +''&membershipId=''+ISNULL(ts.membershipId,'''') +''&idType=''+ISNULL(ts.idType,'''') +''&idNumber=''+ISNULL(ts.idNumber,'''') +''&company=''+REPLACE(ISNULL(ts.companyName,''''),'' '',''__'')+''"'
	ELSE
		SET @URL='"Reports.aspx?dateType='+@dateType+'&frmDate='+@frmDate+'&toDate='+@toDate+'&sCountry='+isnull(replace(@sCountry,' ','__'),'')
		+'&sAgent='+isnull(@sAgent,'')+'&rMode='+ISNULL(REPLACE(@rMode,' ','__'),'')
		+'&rCountry='+isnull(replace(@rCountry,' ','__'),'')+'&rAgent='+ISNULL(@rAgent,'')
		+'&rptBy='+@rptBy+'&rptFor='+ISNULL(@rptFor,'')+'&reportName=amlddlreport&recName=' + CASE WHEN @rptFor = 'Sender' 
		THEN '''+REPLACE(rt.senderName,'' '',''__'')+''' ELSE '''+REPLACE(rt.receiverName,'' '',''__'')+''' END 
		+ '&flag=tc_ddl&country=''+REPLACE(ISNULL(ts.nativeCountry,''''),'' '',''__'')+''&membershipId=''+ISNULL(ts.membershipId,'''') +''&pCountry=''+REPLACE(ISNULL(rt.pCountry,''''),'' '',''__'')+''"'

	SET @table = '	
		SELECT				
			 [Membership ID]	= ISNULL(ts.mobile,''-'')
			,[Name]				= ''<span class = "link" onclick =ViewAMLDDLReport('+@URL+');>'' + ISNULL(' + CASE WHEN @rptFor = 'Sender' THEN 'rt.senderName' ELSE 'rt.receiverName' END + ',''-'') + ''</span>''
			,[Nationality]		=  ISNULL(ts.nativeCountry,''-'') 
			' +
			
			CASE 
				WHEN @rptFor = 'Sender' THEN '
						,[Id type]			= ts.idType 
						,[ID Number]		= ts.idNumber 
						,[Company]			= ts.companyName	 
					' 
			ELSE 
				'
				'
			END +
			'
				
			,[Number of TXN]	= COUNT(1)
			' +
			
			CASE 
				WHEN @rptFor = 'Sender' THEN '
						,[Collection_USD AMT]		= SUM(ISNULL(rt.cAmt / (NULLIF(rt.sCurrCostRate, 0)+ISNULL(RT.scurrhomargin,0)), 0))
						,[Collection_Currency]		= rt.collCurr 
						,[Collection_Amount]		= ROUND(SUM(rt.cAmt), 2, 0) 
					' 
			ELSE 
				'
				,[Payout_USD AMT]			= ROUND(SUM(ISNULL(rt.tAmt / NULLIF(rt.sCurrCostRate, 0), 0)), 2, 0) 
				,[Payout_Currency]			= rt.payoutCurr 
				,[Payout_Amount]			= ROUND(SUM(rt.pAmt), 2, 0) 		
				,[Payout_Country]			= rt.pCountry 
				'
			END +
			'
	FROM vwremitTran rt WITH(NOLOCK)
	LEFT JOIN ' + CASE WHEN @rptFor = 'Sender' THEN 'vwtranSenders' ELSE 'vwtranReceivers' END + ' ts WITH(NOLOCK) ON rt.id = ts.tranId
	WHERE 1 = 1 and rt.tranStatus <>''cancel'' AND rt.senderName IS NOT NULL 
	'
	
	SET @table = @table + @globalFilter + ' 
		GROUP BY 
		 ts.membershipId
		,' + 		
			CASE 
				WHEN @rptFor = 'Sender' 
			THEN 		
				'rt.senderName		
				,ts.idType 
				,ts.idNumber 
				,ts.mobile
				,ts.companyName' 
			ELSE 
				'rt.receiverName
				,ts.mobile' 
			END + '
		,ts.nativeCountry 
		'
		+
		CASE 
			WHEN @rptFor = 'Sender' THEN 
				',rt.collCurr ' 
			ELSE '
				,rt.collCurr 
				,rt.payoutCurr
				,rt.pCountry 
		'
		END
		
	DECLARE @srColumn AS VARCHAR(50)

	IF @rptFor = 'Sender'
	BEGIN
		SET @srColumn = 'Sender''''s'	
	END
	ELSE	
	BEGIN
		SET @srColumn = 'Receiver''''s'	
	END
	 
	SET @sql = 'SELECT '
		+
		'
		[SN] = ROW_NUMBER() OVER(ORDER BY ' + 
		CASE 
			WHEN @rptFor = 'Sender' THEN
				CASE WHEN @rptBy = 'Amount' THEN '[Collection_USD AMT] DESC, [Number of TXN] DESC' ELSE '[Number of TXN] DESC, [Collection_USD AMT] DESC' END 
			WHEN @rptFor = 'Receiver' THEN
				CASE WHEN @rptBy = 'Amount' THEN '[Payout_USD AMT] DESC, [Number of TXN] DESC' ELSE '[Number of TXN] DESC, [Payout_USD AMT] DESC' END 
		END
				
				+ ' )
		'
		+
			
				CASE WHEN @rptFor = 'Sender' THEN 
				REPLACE('
						,[Membership ID]	[@Mobile No]
						,[Name]			[@Name]
						,[Nationality]	[@Nationality]
						,[Id type]		[@Id type]
						,[ID Number]	[@ID Number]
						,[Company]		[@Company]
						,[Number of TXN]' ,'@' ,'Sender''s_') 
				ELSE
				REPLACE('
						,[Membership ID]	[@Mobile No]
						,[Name]			[@Name]
						,[Nationality]	[@Nationality]
						,[Number of TXN]' ,'@' ,'Receiver''s_') 
				END
				
				+
				CASE 
					WHEN @rptFor = 'Sender' 
				THEN '
						,[Collection_USD AMT]
						,[Collection_Currency]
						,[Collection_Amount]
					'
				ELSE
					'
					,[Payout_USD AMT]
					,[Payout_Currency]
					,[Payout_Amount]
					,[Payout_Country]
					'
				END
				
		+
		' 
		FROM (' + @table + ') x	'
		
	
		IF @rptBy IS NOT NULL
		BEGIN
			INSERT @FilterList
			SELECT 'Report By', @rptBy		
		END
		IF @rptFor IS NOT NULL
		BEGIN
			INSERT @FilterList
			SELECT 'Report For', @rptFor		
		END
		IF @tcNo IS NOT NULL
		BEGIN
			INSERT @FilterList
			SELECT 'TOP No', @tcNo		
		END

		--PRINT ('SELECT *  FROM (' + @sql + ') x WHERE [SN] <= ' + @tcNo ) return
		EXEC ('SELECT *  FROM (' + @sql + ') x WHERE [SN] <= ' + @tcNo )

		
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
