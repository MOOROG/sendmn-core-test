USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_amlCustomerRpt_daily]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [dbo].[proc_amlCustomerRpt_daily]
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
	,@fromAmt				VARCHAR(50) = NULL
	,@toAmt					VARCHAR(50) = NULL
	,@includeSenderDetails	VARCHAR(50) = NULL
	,@orderBY				VARCHAR(50) = NULL
	
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
	IF @flag = 'cr'
	BEGIN
		SET @reportHead ='Customer Report'
		SET @URL='"Reports.aspx?dateType='+@dateType+'&frmDate='+@frmDate+'&toDate='+@toDate+'&sCountry='+ISNULL(replace(@sCountry,' ','__'),'')+'&sAgent='+ISNULL(@sAgent,'')
		+'&rMode='+ISNULL(REPLACE(@rMode,' ','__'),'')+'&rCountry=''+REPLACE(ISNULL(rt.pCountry,''''),'' '',''__'')+''&rAgent='+ISNULL(@rAgent,'')
		+'&reportName=amlddlreport&isAdmin=Y&flag=cd_ddl&fAmt='+ISNULL(@fromAmt,'')+'&tAmt='+ISNULL(@toAmt,'')
		DECLARE 
			 @name VARCHAR(500)
			,@customerDetails VARCHAR(500) = ''
			,@customerDetailsGrp VARCHAR(500) = ''
			,@customerDetailsFS VARCHAR(500) = ''
			,@orderByColumn VARCHAR(500)
			,@amtColumn VARCHAR(100) = ''
			,@amtColumnMain VARCHAR(100) = ''
		SET @name = 'rt.senderName'		

		SET @amtColumn = '[Collection_Amount]'		
		SET @amtColumnMain = 'rt.cAmt'				

		IF @includeSenderDetails = 'Y'
		BEGIN
			
			SET @URL=@URL+'&recName=''+isnull(replace(rt.senderName,'' '',''__''),'''')+''&idType=''+isnull(replace(ts.idType,'' '',''__''),'''')+''&idNumber=''+isnull(replace(ts.idNumber,'' '',''__''),'''')+''"'
		
			SET @customerDetails = '
						 --,[Sender''s_Member ID]		= ts.membershipId
						 ,[Sender''s_Name]			= ' + @name + '
						 ,[Sender''s_Nationality]	= ts.country  
						 ,[Sender''s_Id type]		= ts.idType 
						 ,[Sender''s_ID Number]		= ts.idNumber 
						 ,[Sender''s_Contact Number]= ts.mobile
					'
			SET @orderByColumn = '[Sender''s_Name]'
			SET @customerDetailsGrp = '
							--,ts.membershipId
							,' + @name + '
							,ts.country 
							,ts.idType
							,ts.idNumber 
							,ts.mobile
							'
			SET @customerDetailsFS = '
						 --,[Sender''s_Member ID]
						 ,[Sender''s_Name]
						 ,[Sender''s_Nationality]
						 ,[Sender''s_Id type]
						 ,[Sender''s_ID Number]
						 ,[Sender''s_Contact Number]
						 '
							
		END
		ELSE
		BEGIN
			SET @URL=@URL+'&recName=''+isnull(replace(rt.senderName,'' '',''__''),'''')+''&idType=''+isnull(replace(ts.idType,'' '',''__''),'''')+''&idNumber=''+isnull(replace(ts.idNumber,'' '',''__''),'''')+''"'				
			SET @customerDetailsGrp = '
							--,ts.membershipId
							,rt.senderName							
							,ts.idType
							,ts.idNumber 							
							'
		END	
		
		IF ISNULL(@orderBY, '') <> 'cName' or ISNULL(@orderBY, '') <> 'Customer Name'
		BEGIN
			SET @orderByColumn = @amtColumn	
		END		
		
		SET @table = '
		SELECT 		 
			 [Number of TXN]			= COUNT(1)		 
			,[Date]						= ''<span class = "link" onclick =ViewAMLDDLReport('+@URL+');>'' + convert(varchar, rt.approvedDate, 111) + ''</span>''		
			,[Collection_USD AMT]		= SUM(ISNULL(rt.cAmt / (NULLIF(rt.sCurrCostRate, 0)+ISNULL(RT.scurrhomargin,0)), 0))
			,[Collection_Currency]		= rt.collCurr 
			,[Collection_Amount]		= SUM(rt.cAmt) 		
			--,[Payout_USD AMT]			= SUM(ISNULL(rt.tAmt / NULLIF(rt.sCurrCostRate, 0), 0))
			--,[Payout_Currency]			= rt.payoutCurr 
			--,[Payout_Amount]			= SUM(rt.pAmt)		
			,[Payout_Country]			= rt.pCountry 
			' + @customerDetails + '			
		FROM vwRemitTran rt WITH(NOLOCK)
		LEFT JOIN agentMaster ams WITH(NOLOCK) ON rt.sBranch = ams.agentId
		LEFT JOIN vwTranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
		LEFT JOIN customerMaster tsc WITH (NOLOCK) ON ts.customerId = tsc.customerId 
		LEFT JOIN vwTranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId
		LEFT JOIN customerMaster trc WITH (NOLOCK) ON tr.customerId = trc.customerId 
		WHERE 1 = 1 and rt.tranStatus <>''cancel''
		'
		
		IF @fromAmt IS NOT NULL
		BEGIN
			INSERT @FilterList
			SELECT 'From Amt', @fromAmt
			SET @table = @table + ' AND ' + @amtColumnMain + ' >= ' + @fromAmt
		END
		
		IF @toAmt IS NOT NULL
		BEGIN
			INSERT @FilterList
			SELECT 'To Amt', @toAmt
			SET @table = @table + ' AND ' + @amtColumnMain + ' <= ' + @toAmt
		END
		
		IF @includeSenderDetails = 'Y'
		BEGIN
			INSERT @FilterList
			SELECT 'Include Sender Details', 'Y'		
		END
			
		SET @table = @table + @globalFilter + ' 
		GROUP BY
			 rt.collCurr 
			--,rt.payoutCurr
			,rt.pCountry 
			,convert(varchar, rt.approvedDate, 111)
			' + @customerDetailsGrp	
				
		IF @isExportFull = 'Y'
		BEGIN
		
			SET @sql = '
				SELECT		
					 [Sno.] = [S.N]
					'+@customerDetailsFS+'
					,[Date]
					,[Number of TXN]
					,[Collection_USD AMT]
					,[Collection_Currency]
					,[Collection_Amount]
					--,[Payout_USD AMT]
					--,[Payout_Currency]
					--,[Payout_Amount]
					,[Payout_Country]
					'		
					+
					'
				FROM (		
					SELECT 
						[S.N] = ROW_NUMBER() OVER (ORDER BY ' + @orderByColumn + ' DESC)
						,* 
					FROM (' + @table + ') x		
				) AS tmp '
		
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
			PRINT @sql
			EXEC (@sql)
			
		
			SET @sql = '
				SELECT		
					 [Sno.] = [S.N]
					'+@customerDetailsFS+'
					,[Date]
					,[Number of TXN]
					,[Collection_USD AMT]
					,[Collection_Currency]
					,[Collection_Amount]
					--,[Payout_USD AMT]
					--,[Payout_Currency]
					--,[Payout_Amount]
					,[Payout_Country]
					'		
					+
					'
				FROM (		
					SELECT 
						[S.N] = ROW_NUMBER() OVER (ORDER BY ' + @orderByColumn + ' DESC)
						,* 
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
