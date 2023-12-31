USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ThirdpartyTXN_report]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_ThirdpartyTXN_report]
	 @user				VARCHAR(30)		= NULL
	,@dateType			VARCHAR(50)		= NULL
	,@dateFrom			VARCHAR(20)		= NULL
	,@dateTo			VARCHAR(20)		= NULL
	,@tAgent			VARCHAR(40)		= NULL
	,@sBranch			VARCHAR(10)		= NULL
	,@status			VARCHAR(50)		= NULL
	,@reportType		VARCHAR(100)	= NULL
	,@groupBy			VARCHAR(10)		= NULL	
	,@pCountry			VARCHAR(200)	= NULL
	,@scharge			VARCHAR(20)		= NULL
	,@pageNumber		INT				= NULL
	,@pageSize			INT				= NULL
	,@isExportFull		VARCHAR(1)		= NULL
	,@sCountry			VARCHAR(200)	= NULL
AS
	SET NOCOUNT ON
	DECLARE @table VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	DECLARE @globalFilter VARCHAR(MAX) = ''
	SET @pageNumber	= ISNULL(@pageNumber, 1)
	SET @pageSize	= ISNULL(@pageSize, 100)

	DECLARE @displayTranNo CHAR(1) = 'Y',@reportHead VARCHAR(100)
	
	IF @reportType = 'D'
	BEGIN
		--SET @pageSize = 10000
		SET @reportHead = ' Detail'	
				INSERT @FilterList
		SELECT 'Third Party Agent', (select agentName from agentMaster with(nolock) where agentId = @tAgent)

		INSERT @FilterList
		SELECT 'Branch', case when @sBranch is null then 'All' else (select agentName from agentMaster with(nolock) where agentId = @sBranch)end

		INSERT @FilterList
		SELECT 'Date Type', 
				case 
					when @dateType = 'txnDate' then 'TXN Date' 
					when @dateType = 'confirmDate' then 'Confirmed Date' 
					when @dateType = 'paidDate' then 'Paid Date' 
					when @dateType = 'cancelDate' then 'Cancel Date'
				end
		IF @dateType = 'txnDate' -->> sending 
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo
			SET @globalFilter = @globalFilter + ' AND rt.createdDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''
			SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @tAgent + ''''
			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.sBranch = ''' + @sBranch + ''''	
			end
		END	

		IF @dateType = 'confirmDate' -->> sending 
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo

			SET @globalFilter = @globalFilter + ' AND rt.approvedDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''
			SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @tAgent + ''''
			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.sBranch = ''' + @sBranch + ''''	
			end
		END	

		IF @dateType = 'paidDate' --> receiving
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo
			SET @globalFilter = @globalFilter + ' AND rt.paidDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''		
			SET @globalFilter = @globalFilter + ' AND rt.sAgent = ''' + @tAgent + ''''	

			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.pBranch = ''' + @sBranch + ''''	
			end
		END	

		IF @dateType = 'cancelDate' --> cancel date
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo
			SET @globalFilter = @globalFilter + ' AND rt.cancelApprovedDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''		
			SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @tAgent + ''''	

			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.pBranch = ''' + @sBranch + ''''	
			end
		END	

		if @status is not null and @status ='Post'
			SET @globalFilter = @globalFilter +' AND rt.payStatus = '''+@status+''''	

		if @status is not null and @status <> 'Post'	
		begin			
			if @status ='Unpaid'
				set @status = 'Payment'
			SET @globalFilter = @globalFilter +' AND rt.tranStatus = '''+@status+''' and rt.payStatus <> ''Post'''	
		END
        
		IF @sCountry IS NOT NULL
			SET @globalFilter = @globalFilter +' AND rt.sCountry = '''+REPLACE(@sCountry,'_',' ')+''''

		INSERT @FilterList
		SELECT 'Status', isnull(@status,'All')

		SET @table = '
		SELECT 
			 [Tran No] = isnull(rt.holdTranId,rt.id)
			,[Sender Name]				= TS.firstName + ISNULL( '' '' + TS.middleName, '''') + ISNULL( '' '' + TS.lastName1, '''') + ISNULL( '' '' + TS.lastName2, '''')
			,[Sender Company]			= TS.companyName
			,[Receiver Name]			= rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
			,[DOT]						= CONVERT(VARCHAR(20), rt.createdDate, 120) 
			,[Paid Date]				= ISNULL(CONVERT(VARCHAR(50), rt.paidDate, 120), '''')
			,[Ex Rate]					= CAST(isnull(rt.customerRate,''1'') AS VARCHAR) + '' '' + rt.payoutCurr 
			,[Payment Type]				= rt.paymentMethod
			,[Tot Collected_Amt]		= rt.cAmt
			,[Tot Collected_Curr]		= rt.collCurr
			,[Send_Amt]					= rt.tAmt
			,[Send_Curr]				= rt.collCurr
			,[Charge_Amt]				= rt.serviceCharge
			,[Charge_Curr]				= rt.collCurr
			,[Receive_Amt]				= rt.pAmt
			,[Receive_Curr]				= rt.payoutCurr
			,[User ID]					= rt.paidBy 	
			,[Send Country]				= ISNULL(rt.sCountry,'''') 
			,[Receive Country]			= ISNULL(rt.pCountry,'''')
			,[Tran Status]				= case 
											when rt.tranStatus = ''Payment''  and rt.payStatus <> ''Post''
												then ''Unpaid'' 
											when rt.payStatus = ''Post'' and rt.payStatus = ''Post''
												then ''Post'' 
											else rt.tranStatus 
										  end
			,rt.tranStatus
			,rt.payStatus
			,[ICN]						= dbo.FNADecryptString(rt.controlNo)
		FROM remitTran rt WITH(NOLOCK)
		INNER JOIN tranSenders TS WITH (NOLOCK) ON rt.id = TS.tranId
		INNER JOIN tranReceivers rec WITH (NOLOCK) ON rt.id = rec.tranId
		WHERE paymentMethod = ''Cash Payment'' '
		SET @table = @table + @globalFilter 

		IF @isExportFull = 'Y'
		BEGIN
			SET @sql = '
				SELECT
					 [S.N] ' +
					CASE WHEN @displayTranNo = 'Y' THEN ',[Tran No] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([Tran No] AS VARCHAR(50)) + '');">'' +  CAST([Tran No] AS VARCHAR(50)) + ''</span>'''  ELSE '' END + '
					,[Sender Name]
					,[Send/Receive Country] =  [Send Country] + ''<br />'' + [Receive Country]
					,[Receiver Name]			
					,[DOT/Paid Date] = DOT + ''<br />'' + [Paid Date]
					,[Ex Rate]
					,[Payment Type]
					,[Tot Collected_Amt]
					,[Tot Collected_Curr]
					,[Send_Amt]
					,[Send_Curr]
					,[Charge_Amt]
					,[Charge_Curr]
					,[Receive_Amt]
					,[Receive_Curr]
					,[User ID]	
					,[Tran Status]
					,[ICN]
					,rowColor = CASE 
									WHEN payStatus = ''post'' THEN ''#c8e8ea''  
									WHEN tranStatus = ''Payment'' THEN ''#fef3b8''							
									WHEN tranStatus = ''Block'' THEN ''#FF6B6B''
									WHEN tranStatus = ''Hold'' OR tranStatus = ''Compliance Hold'' OR tranStatus = ''ofac Hold'' THEN ''#bef9dd''
									ELSE ''#FFFFFF''
								END
				FROM (
					SELECT 
						ROW_NUMBER() OVER (ORDER BY [Send Country] ) AS [S.N],* 
					FROM (' + @table + ') x		
				) AS tmp '
	
			EXEC(@sql)
			print(@sql)
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
					 [S.N] ' +
					CASE WHEN @displayTranNo = 'Y' THEN ',[Tran No] = ''<span class = "link" onclick ="ViewTranDetail('' + CAST([Tran No] AS VARCHAR(50)) + '');">'' +  CAST([Tran No] AS VARCHAR(50)) + ''</span>'''  ELSE '' END + '
					,[Sender Name]
					,[Send/Receive Country] =  [Send Country] + ''<br />'' + [Receive Country]
					,[Receiver Name]			
					,[DOT/Paid Date] = DOT + ''<br />'' + [Paid Date]
					,[Ex Rate]
					,[Payment Type]
					,[Tot Collected_Amt]
					,[Tot Collected_Curr]
					,[Send_Amt]
					,[Send_Curr]
					,[Charge_Amt]
					,[Charge_Curr]
					,[Receive_Amt]
					,[Receive_Curr]
					,[User ID]	
					,[Tran Status]
					,[ICN]			
					,rowColor = CASE 
									WHEN payStatus = ''post'' THEN ''#c8e8ea''  
									WHEN tranStatus = ''Payment'' THEN ''#fef3b8''							
									WHEN tranStatus = ''Block'' THEN ''#FF6B6B''
									WHEN tranStatus = ''Hold'' OR tranStatus = ''Compliance Hold'' OR tranStatus = ''ofac Hold'' THEN ''#bef9dd''
									ELSE ''#FFFFFF''
								END
				FROM (
					SELECT 
						ROW_NUMBER() OVER (ORDER BY [Send Country] ) AS [S.N],* 
					FROM (' + @table + ') x		
				) AS tmp WHERE [S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
	
			PRINT(@sql)
			EXEC (@sql)
		END
	END

	IF @reportType = 'S'
	BEGIN 
		SET @reportHead ='Summary'
		INSERT @FilterList
		SELECT 'Third Party Agent', (select agentName from agentMaster with(nolock) where agentId = @tAgent)

		INSERT @FilterList
		SELECT 'Branch', case when @sBranch is null then 'All' else (select agentName from agentMaster with(nolock) where agentId = @sBranch)end

		INSERT @FilterList
		SELECT 'Date Type', case when @dateType = 'txnDate' then 'TXN Date' when @dateType = 'confirmDate' then 'Confirmed Date' else 'Paid Date' end
		IF @dateType = 'txnDate' -->> sending 
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo
			SET @globalFilter = @globalFilter + ' AND rt.createdDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''
			SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @tAgent + ''''
			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.sBranch = ''' + @sBranch + ''''	
			end
		END	

		IF @dateType = 'confirmDate' -->> sending 
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo

			SET @globalFilter = @globalFilter + ' AND rt.approvedDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''
			SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @tAgent + ''''
			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.sBranch = ''' + @sBranch + ''''	
			end
		END	

		IF @dateType = 'paidDate' --> receiving
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo
			SET @globalFilter = @globalFilter + ' AND rt.paidDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''		
			SET @globalFilter = @globalFilter + ' AND rt.sAgent = ''' + @tAgent + ''''	

			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.pBranch = ''' + @sBranch + ''''	
			end
		END
			
		IF @dateType = 'cancelDate' --> receiving
		BEGIN
			INSERT @FilterList
			SELECT 'From Date', @dateFrom
			INSERT @FilterList
			SELECT 'To Date', @dateTo
			SET @globalFilter = @globalFilter + ' AND rt.cancelApprovedDate between ''' + @dateFrom + ''' and ''' + @dateTo + ' 23:59:59'''		
			SET @globalFilter = @globalFilter + ' AND rt.pAgent = ''' + @tAgent + ''''	

			if @sBranch is not null
			begin
				INSERT @FilterList
				SELECT 'Branch', @sBranch
				SET @globalFilter = @globalFilter + ' AND rt.sBranch = ''' + @sBranch + ''''	
			end
		END	

		if @status is not null and @status ='Post'
			SET @globalFilter = @globalFilter +' AND RT.payStatus = '''+@status+''''	
		

		if @status is not null and @status <> 'Post'		
			SET @globalFilter = @globalFilter +' AND RT.tranStatus = '''+@status+''''	
		
		
		if @groupBy = 'C' -->> Sending country wise
		begin
			SET @SQL = 'SELECT 
			             [Payout Country]= RT.pCountry
						,[Total <BR/>Paid TXN]					= COUNT(*) 
						,[Total Paid <BR/>Amount]				= SUM(RT.cAmt)
						,[Total <BR/>Agent Commission]	= SUM(isnull(RT.pAgentComm,0)) 
					FROM remitTran RT WITH (NOLOCK) where paymentMethod = ''Cash Payment'' '

			SET @SQL = @SQL + @globalFilter + ' 
					GROUP BY RT.pCountry'
		end

		if @groupBy = 'B' -->> Branch wise
		begin
			SET @SQL = 'SELECT [Branch Name]					= RT.pBranchName 
						,[Total <BR/>Paid TXN]					= COUNT(*) 
						,[Total Paid <BR/>Amount]				= SUM(RT.pAmt)
						,[Total <BR/>Agent Commission]	= SUM(isnull(RT.pAgentComm,0)) 
					FROM remitTran RT WITH (NOLOCK) where paymentMethod = ''Cash Payment'' '

			SET @SQL = @SQL + @globalFilter + ' 
					GROUP BY RT.pBranchName'
		end

		if @groupBy='SCW'----->>sending country wise
		begin
			SET @SQL = 'SELECT 
			             [Sending Country]					= ''<a href="' + dbo.FNAGetUrl() + 'SwiftSystem/Reports/Reports.aspx?reportName=20167300&dateType=' + @dateType + '&fromDate=' + @dateFrom + '&toDate=' + @dateTo +'&tAgent=' + @tAgent + '&status=' + ISNULL(@status, '') + '&rptType=D&sCountry='' + REPLACE(RT.sCountry,'' '',''_'') + ''" title="View Detail">'' + RT.sCountry + ''</a>''
						,[Total <BR/>TXN]					= COUNT(''x'') 
						,[Total <BR/>Amount]				= SUM(RT.cAmt)
						,[Total <BR/>Agent Commission]		= SUM(isnull(RT.sSuperAgentComm,0)) 
					FROM remitTran RT WITH (NOLOCK) where paymentMethod = ''Cash Payment'' '

			SET @SQL = @SQL + @globalFilter + ' 
					GROUP BY RT.sCountry'
		end

		if @groupBy='SAW'----->>sending agent wise
		begin
			SET @SQL = 'SELECT [Branch Name]					= RT.sBranchName 
						,[Total <BR/>TXN]						= COUNT(*) 
						,[Total <BR/>Amount]				= SUM(RT.cAmt)
						,[Total <BR/>Agent Commission]	= SUM(isnull(RT.sSuperAgentComm,0)) 
					FROM remitTran RT WITH (NOLOCK) where paymentMethod = ''Cash Payment'' '

			SET @SQL = @SQL + @globalFilter + ' 
					GROUP BY RT.sBranchName'
		end

		INSERT @FilterList
		SELECT 'Status', isnull(@status,'All')

		INSERT @FilterList
		SELECT 'Group By', case 
								when @groupBy = 'C' then 'Payout Country Wise' 
								when @groupBy='SCW' then 'Sending Country Wise'
								when @groupBy='SAW' then 'Sending Agent Wise'
								else 'Payout Branch Wise' end

		PRINT @SQL
		EXEC(@SQL)
	END

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	  
	SELECT * FROM @FilterList
	   
	SELECT 'Thirdparty Transaction Report (Cash Payment Only): '+@reportHead  title
	
	
	
		
	


GO
