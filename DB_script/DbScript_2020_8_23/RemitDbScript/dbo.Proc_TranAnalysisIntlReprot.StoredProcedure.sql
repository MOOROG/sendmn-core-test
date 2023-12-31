USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TranAnalysisIntlReprot]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
		EXEC Proc_TranAnalysisReprot  @flag = 'main', @user = 'admin', @fromDate = '2012-09-06', @toDate = '2012-09-20', 
		@SendingAgent = null, @SendingCountry = 'Nepal', @SendingBranch = null, @ReceivingCountry = 'Nepal', @ReecivingAgent = null, 
		@ReceivingBranch = null, @groupBy = 'detail', @dateType = 'S', @ReportType = null, @Id = null, @status = null, 
		@controlNo = null, @rZone = 'All', @rDistrict = 'All', @sZone = 'All', @sDistrict = 'All', @sLocation = null, @rLocation = null

		EXEC Proc_TranAnalysisReprot  @flag = 'main', @user = 'admin', @fromDate = '2012-09-06', @toDate = '2012-09-20', 
		@SendingAgent = null, @SendingCountry = 'Nepal', @SendingBranch = null, @ReceivingCountry = 'Nepal', @ReecivingAgent = null, 
		@ReceivingBranch = null, @groupBy = 'detail', @dateType = 'S', @ReportType = null, @Id = null, @status = null, 
		@controlNo = '7697345364D', @rZone = null, @rDistrict = null, @sZone = null, @sDistrict = null, @sLocation = null, @rLocation = null
*/
CREATE procEDURE [dbo].[Proc_TranAnalysisIntlReprot]
	@FLAG				VARCHAR(20),
	@FROMDATE			VARCHAR(20)	= NULL,
	@TODATE				VARCHAR(30) = NULL,
	@DATETYPE			VARCHAR(5)	= NULL,
	@SendingAgent		VARCHAR(50)	= NULL,
	@SendingCountry		VARCHAR(50)	= NULL,
	@SendingBranch		VARCHAR(50)	= NULL,
	@ReceivingCountry	VARCHAR(50)	= NULL,
	@ReecivingAgent		VARCHAR(50)	= NULL,
	@ReceivingBranch	VARCHAR(50)	= NULL,
	@Id					VARCHAR(50) = NULL,
	@ReportType			VARCHAR(50) = NULL,
	@GROUPBY			VARCHAR(50)	= NULL,
	@status				VARCHAR(50)	= NULL,
	@controlNo			VARCHAR(50)	= NULL,
	@rLocation			VARCHAR(50)	= NULL,
	@rZone				VARCHAR(50)	= NULL,
	@rDistrict			VARCHAR(50)	= NULL,	
	@tranType			VARCHAR(50) = NULL,
	@USER				VARCHAR(50)	= NULL,
	@pageSize			VARCHAR(50)	= NULL,
	@pageNumber			VARCHAR(50) = NULL,
	@groupById			VARCHAR(200) = NULL

AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;


	IF @rZone ='All'
		set @rZone = null
	
	IF @rDistrict ='All'
		set @rDistrict = null
	
	IF @rLocation ='All'
		set @rLocation = null
	
	--select 	@rZone,@sZone,@rDistrict,@sDistrict,@rLocation,@sLocation
	
	IF @GROUPBY = 'Datewise'
		SET @FLAG = 'Datewise'

			DECLARE @DateCondition VARCHAR(50),
			@GroupCondition varchar(50),
			@ReportTypeCond	VARCHAR(50),
			@SQL VARCHAR(MAX),
			@SQL1 VARCHAR(MAX),
			@maxReportViewDays INT,
			@GroupSelect VARCHAR(50),
			@GroupId	VARCHAR(50),
			@Currency	VARCHAR(50),
			@Amt		VARCHAR(50),
			@statusField	varchar(50),
			@Date			VARCHAR(50)
			
			
			
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
			
	SELECT @DateCondition = CASE WHEN @DATETYPE = 'S' THEN 'approvedDate' 
							WHEN @DATETYPE = 'P' THEN 'paidDate' 
							WHEN @DATETYPE = 'C' THEN 'cancelApprovedDate' END
							
	SELECT @GroupCondition   =	CASE WHEN @GROUPBY = 'SC' THEN 'sCountry' 
	
								WHEN @GROUPBY = 'SZ' THEN 'B.agentState' 
								WHEN @GROUPBY = 'SD' THEN 'B.agentDistrict' 
								WHEN @GROUPBY = 'SL' THEN 'D.districtName'  
								
								WHEN @GROUPBY = 'SA' THEN 'sAgentName' 
								WHEN @GROUPBY = 'SB' THEN 'sBranchName' 
								
								WHEN @GROUPBY = 'RC' THEN 'pCountry' 
								
								WHEN @GROUPBY = 'RZ' THEN 'C.agentState' 
								WHEN @GROUPBY = 'RD' THEN 'C.agentDistrict' 
								WHEN @GROUPBY = 'RL' THEN 'E.districtName' 								
								
								WHEN @GROUPBY = 'RA' THEN 'pAgentName' 
								WHEN @GROUPBY = 'RB' THEN 'pBranchName'
								WHEN @GROUPBY = 'Datewise' THEN 'CONVERT(VARCHAR,a.'+@DateCondition+' ,101)' END								
								
						
			
			,@Currency		=	CASE WHEN @GROUPBY IN ('SC','SA','SB','SZ','SD','SL') THEN 'collCurr'
								WHEN @GROUPBY IN ('RC','RA','RB','RZ','RD','RL') THEN 'payoutCurr' END
								
			,@Amt		=		CASE WHEN @GROUPBY IN ('SC','SA','SB','SZ','SD','SL') THEN 'tAmt'
								WHEN @GROUPBY IN ('RC','RA','RB','RZ','RD','RL') THEN 'pAmt' END
								
			,@GroupSelect	=	CASE WHEN @GROUPBY = 'SC' THEN 'Sending Country' 
			
								WHEN @GROUPBY = 'SZ' THEN 'Sending Zone' 
								WHEN @GROUPBY = 'SD' THEN 'Sending District' 
								WHEN @GROUPBY = 'SL' THEN 'Sending Location' 
								
								WHEN @GROUPBY = 'SA' THEN 'Sending Agent' 
								WHEN @GROUPBY = 'SB' THEN 'Sending Branch' 
								
								WHEN @GROUPBY = 'RC' THEN 'Receiving Country' 								
								WHEN @GROUPBY = 'RZ' THEN 'Receiving Zone' 
								WHEN @GROUPBY = 'RD' THEN 'Receiving District' 
								WHEN @GROUPBY = 'RL' THEN 'Receiving Location' 
								
								WHEN @GROUPBY = 'RA' THEN 'Receiving Agent' 
								WHEN @GROUPBY = 'RB' THEN 'Receiving Branch'
								WHEN @GROUPBY = 'Datewise' THEN CASE WHEN @DATETYPE = 'S' THEN 'Send Date' 
																WHEN @DATETYPE = 'P' THEN 'Paid Date' 
																WHEN @DATETYPE = 'C' THEN 'Canecel Date' END
								WHEN @GROUPBY = 'detail' THEN CASE WHEN @DATETYPE = 'S' THEN 'Send Date' 
																WHEN @DATETYPE = 'P' THEN 'Paid Date' 
																WHEN @DATETYPE = 'C' THEN 'Canecel Date' END 
								END
								
			,@GroupId   =CASE  WHEN  @GROUPBY = 'SC' THEN 'sCountry' 
			
								WHEN @GROUPBY = 'SZ' THEN 'B.agentState' 
								WHEN @GROUPBY = 'SD' THEN 'B.agentDistrict' 
								WHEN @GROUPBY = 'SL' THEN 'D.districtName' 
								
								WHEN @GROUPBY = 'SA' THEN 'sAgent' 
								WHEN @GROUPBY = 'SB' THEN 'sBranch' 
								WHEN @GROUPBY = 'RC' THEN 'pCountry' 
								
								WHEN @GROUPBY = 'RZ' THEN 'C.agentState' 
								WHEN @GROUPBY = 'RD' THEN 'C.agentDistrict' 
								WHEN @GROUPBY = 'RL' THEN 'E.districtName' 
								
								WHEN @GROUPBY = 'RA' THEN 'pAgent' 
								WHEN @GROUPBY = 'RB' THEN 'pBranch'
								WHEN @GROUPBY = 'Datewise' THEN 'CONVERT(VARCHAR,a.'+@DateCondition+' ,101)' 
								END
							
								
			,@ReportTypeCond  =	CASE WHEN @GROUPBY = 'SC' THEN 'sCountry' 

									WHEN @GROUPBY	= 'SZ' THEN 'B.agentState' 
									WHEN @GROUPBY	= 'SD' THEN 'B.agentDistrict' 
									WHEN @GROUPBY	= 'SL' THEN 'B.agentLocation' 								
									WHEN @GROUPBY	= 'SA' THEN 'sAgent' 
									WHEN @GROUPBY	= 'SB' THEN 'sBranch' 
									WHEN @GROUPBY	= 'RC' THEN 'pCountry' 								
									WHEN @GROUPBY	= 'RZ' THEN 'C.agentState' 
									WHEN @GROUPBY	= 'RD' THEN 'C.agentDistrict' 
									WHEN @GROUPBY	= 'RL' THEN 'C.agentLocation' 								
									WHEN @GROUPBY	= 'RA' THEN 'pAgent' 
									WHEN @GROUPBY	= 'RB' THEN 'pBranch'
									WHEN @GROUPBY	= 'Datewise' THEN 'CONVERT(VARCHAR,a.'+@DateCondition+' ,101)' 
								END

			,@statusField	=	 CASE WHEN @status IN ('Unpaid','Paid') THEN 'payStatus' 
								WHEN @status='Cancel' THEN 'tranStatus' END			
	
IF @controlNo IS NULL
BEGIN
	
	IF @groupById IS NOT NULL OR @groupById<>''
	BEGIN
		IF @GROUPBY='sa'
			SET @SendingAgent=@groupById
		IF @GROUPBY='sb'
			SET @SendingBranch=@groupById 
		IF @GROUPBY='rz'
			SET @rZone=@groupById
		IF @GROUPBY='rd'
			SET @rDistrict=@groupById
		IF @GROUPBY='rl'
			SET @rLocation=@groupById
		IF @GROUPBY='ra'
			SET @ReecivingAgent=@groupById
		IF @GROUPBY='rb'
			SET @ReceivingBranch=@groupById 
		IF @GROUPBY='Datewise'
			SET @Date=@groupById 
			
		SET @GROUPBY='DETAIL'
		SET @FLAG='MAIN'
		SET @GroupSelect=CASE WHEN @DATETYPE = 'S' THEN 'Send Date' 
																WHEN @DATETYPE = 'P' THEN 'Paid Date' 
																WHEN @DATETYPE = 'C' THEN 'Canecel Date' END 
	END
	
	IF @FLAG = 'MAIN' AND @GROUPBY = 'DETAIL'
	BEGIN		

		SET @SQL ='SELECT 
					 [Control No] =''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
					,['+ @GroupSelect +']	= CONVERT(VARCHAR,a.'+ @DATECONDITION +',101)		
					,[Sending Country]		= sCountry
					,[Sending Location]		= D.districtName
					,[Sending Agent]		= sAgentName
					,[Sending Branch]		= sBranchName
					,[Sending Amt]			= tAmt
					,[Sending Currency]		= collCurr
					,[Status]				= a.tranStatus
					,[Receiving Country]	= ISNULL(pCountry,''-'')
					,[Receiving Location]	= E.districtName
					,[Receiving Agent]		= ISNULL(pAgentName,''-'')
					,[Receiving Branch]		= ISNULL(pBranchName,''-'')
					,[Receiving Amt]		= pAmt
					,[Receiving Currency]	= payoutCurr
				FROM remitTran a with(nolock)  
				LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
				LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
				LEFT JOIN api_districtList D WITH(NOLOCK) ON D.districtCode=B.agentLocation
				LEFT JOIN api_districtList E WITH(NOLOCK) ON E.districtCode=a.pLocation
				WHERE  a.sCountry<>''Nepal'' AND  a.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+''''
			
			
		IF @SendingCountry IS NOT NULL
			SET @SQL = @SQL + ' AND sCountry = ''' + @SendingCountry + ''''
			
		IF @SendingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND sAgent = ''' + @SendingAgent + ''''
		
		IF @SendingBranch IS NOT NULL
			SET @SQL = @SQL + ' AND sBranch = '''+ @SendingBranch +''''
		
		IF @ReceivingCountry IS NOT NULL
			SET @SQL = @SQL + ' AND pCountry = ''' + @ReceivingCountry + ''''
			
		IF @ReecivingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND PAgent = ''' + @ReecivingAgent + ''''
		
		IF @ReceivingBranch IS NOT NULL
			SET @SQL = @SQL + 'AND  pBranch = '''+ @ReceivingBranch +''''			
			
		IF @status IS NOT NULL
			SET @SQL = @SQL + 'AND  tranStatus = '''+ @status +''''
			
		IF @rLocation IS NOT NULL
			SET @SQL = @SQL + 'AND  pLocation = '''+ @rLocation +''''			
			
		IF @rZone IS NOT NULL
			SET @SQL = @SQL + 'AND  c.agentState = '''+ @rZone +''''
		
		IF @rDistrict IS NOT NULL
			SET @SQL = @SQL + 'AND  c.agentDistrict = '''+ @rDistrict +''''
			
		IF @Date IS NOT NULL
			SET @SQL = @SQL + 'AND convert(varchar,a.'+ @DATECONDITION +',101) = convert(varchar,'''+ @Date +''',101)'	
		
	
	END
	
	IF @FLAG = 'Datewise'
	BEGIN
		SET @SQL = 'SELECT 
					 '+@ReportTypeCond+' [groupBy]	
					,'+ @GroupCondition +' ['+ @GroupSelect +']
					,COUNT(*) [Txn Count]  
					,SUM(tAmt) [Txn Amount]
					FROM remitTran a with(nolock)  
					INNER JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
					LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
					LEFT JOIN api_districtList D WITH(NOLOCK) ON D.districtCode=B.agentLocation
					LEFT JOIN api_districtList E WITH(NOLOCK) ON E.districtCode=a.pLocation
					WHERE a.sCountry<>''Nepal'' AND  a.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+''''
					
		IF @SendingCountry IS NOT NULL
			SET @SQL = @SQL + ' AND sCountry = ''' + @SendingCountry + ''''
			
		IF @SendingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND sAgent = ''' + @SendingAgent + ''''
		
		IF @SendingBranch IS NOT NULL
			SET @SQL = @SQL + ' AND sBranch = '''+ @SendingBranch +''''
		
		IF @ReceivingCountry IS NOT NULL
			SET @SQL = @SQL + ' AND pCountry = ''' + @ReceivingCountry + ''''
			
		IF @ReecivingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND PAgent = ''' + @ReecivingAgent + ''''
		
		IF @ReceivingBranch IS NOT NULL
			SET @SQL = @SQL + ' AND  pBranch = '''+ @ReceivingBranch +''''		
				
		IF @status IS NOT NULL
			SET @SQL = @SQL + 'AND  tranStatus = '''+ @status +''''
			
		IF @rLocation IS NOT NULL
			SET @SQL = @SQL + 'AND  a.pLocation = '''+ @rLocation +''''
			
		IF @rZone IS NOT NULL
			SET @SQL = @SQL + 'AND  c.agentState = '''+ @rZone +''''
		
		IF @rDistrict IS NOT NULL
			SET @SQL = @SQL + 'AND  c.agentDistrict = '''+ @rDistrict +''''
			
		SET @SQL = @SQL + ' GROUP BY '+ @GroupCondition +''

	END	

	IF @FLAG = 'MAIN' AND @GROUPBY <>'DETAIL'
	BEGIN	

	
		SET @SQL = 'SELECT 	
			 '+@ReportTypeCond+' [groupBy]			
			,['+ @GroupSelect +'] ='+ @GroupCondition +'
			,COUNT(*) [Txn Count]
			,SUM('+@Amt+') [Txn Amount]			
			FROM remitTran a with(nolock)  
			LEFT JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
			LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
			LEFT JOIN api_districtList D WITH(NOLOCK) ON D.districtCode=B.agentLocation
			LEFT JOIN api_districtList E WITH(NOLOCK) ON E.districtCode=a.pLocation
			WHERE a.sCountry<>''Nepal'' AND  a.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +' 23:59:59'+''''

		IF @SendingCountry IS NOT NULL
			SET @SQL = @SQL + ' AND sCountry = ''' + @SendingCountry + ''''
			
		IF @SendingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND sAgent = ''' + @SendingAgent + ''''
		
		IF @SendingBranch IS NOT NULL
			SET @SQL = @SQL + ' AND sBranch = '''+ @SendingBranch +''''
		
		IF @ReceivingCountry IS NOT NULL
			SET @SQL = @SQL + ' AND pCountry = ''' + @ReceivingCountry + ''''
			
		IF @ReecivingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND PAgent = ''' + @ReecivingAgent + ''''
		
		IF @ReceivingBranch IS NOT NULL
			SET @SQL = @SQL + ' AND  pBranch = '''+ @ReceivingBranch +''''
			
		IF @status IS NOT NULL
			SET @SQL = @SQL + 'AND  tranStatus = '''+ @status +''''	
			
		IF @rLocation IS NOT NULL
			SET @SQL = @SQL + 'AND  a.pLocation = '''+ @rLocation +''''

		IF @rZone IS NOT NULL
			SET @SQL = @SQL + 'AND  c.agentState = '''+ @rZone +''''
		
		IF @rDistrict IS NOT NULL
			SET @SQL = @SQL + 'AND  c.agentDistrict = '''+ @rDistrict +''''
			
		IF @Id IS NOT NULL
			SET @SQL = @SQL + '  AND '+ @ReportTypeCond +' = '''+ @Id +''''		

			
		SET @SQL = @SQL + ' AND '+@GroupCondition+' IS NOT NULL GROUP BY '+ @GroupCondition +','+@ReportTypeCond+''

	END
END	
ELSE
BEGIN
	IF @FLAG = 'MAIN'
	BEGIN		

			SET @SQL ='SELECT 
					 [Control No] =''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'/Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
					,['+ @GroupSelect +']	= CONVERT(VARCHAR,a.'+ @DATECONDITION +',101)		
					,[Sending Country]		= sCountry
					,[Sending Location]		= D.districtName
					,[Sending Agent]		= sAgentName
					,[Sending Branch]		= sBranchName
					,[Sending Amt]			= tAmt
					,[Sending Currency]		= collCurr
					,[Status]				= a.tranStatus
					,[Receiving Country]	= ISNULL(pCountry,''-'')
					,[Receiving Location]	= E.districtName
					,[Receiving Agent]		= ISNULL(pAgentName,''-'')
					,[Receiving Branch]		= ISNULL(pBranchName,''-'')
					,[Receiving Amt]		= pAmt
					,[Receiving Currency]	= payoutCurr
				FROM remitTran a with(nolock)  
				INNER JOIN agentMaster B with(nolock) ON a.sBranch=b.agentId
				LEFT JOIN agentMaster C with(nolock) ON a.pBranch=C.agentId
				LEFT JOIN api_districtList D WITH(NOLOCK) ON D.districtCode=B.agentLocation
				LEFT JOIN api_districtList E WITH(NOLOCK) ON E.districtCode=a.pLocation
				WHERE a.sCountry<>''Nepal'' AND  a.controlNo = '''+ dbo.FNAEncryptString(@controlNo) +''''	
		
	END
END

	--SELECT @SQL
	--RETURN
		
	IF OBJECT_ID('tempdb..##TEMP_TABLE') IS NOT NULL
	DROP TABLE ##TEMP_TABLE
	
	DECLARE @SQL2 AS VARCHAR(MAX)
	SET @SQL2='SELECT ROW_NUMBER() OVER (ORDER BY ['+@GroupSelect+'] DESC) AS [S.N.],* 
				INTO ##TEMP_TABLE
					FROM 
					(
						'+ @SQL +'
					) AS aa'
	
	--select @SQL2
	--return;
	EXEC(@SQL2)

	SET @SQL1='
	SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ##TEMP_TABLE

	SELECT * FROM ##TEMP_TABLE  WHERE [S.N.] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+'
	'
	EXEC(@SQL1)


	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'Date Type ' head,CASE WHEN @DATETYPE = 'S' THEN 'Sending Date' 
							WHEN @DATETYPE = 'P' THEN 'Paid Data' 
							WHEN @DATETYPE = 'C' THEN 'Cancel Date' END value
	UNION ALL
	SELECT 'From Date ' head, CONVERT(VARCHAR, @fromDate, 101) value
	UNION ALL
	SELECT 'To Date ' head, CONVERT(VARCHAR, @toDate, 101) value
	UNION ALL
	SELECT 'Tran Status ' head, @status value
	UNION ALL
	SELECT 'Control No ' head, @controlNo value
	UNION ALL
	SELECT 'Sending Country ' head,ISNULL(@SendingCountry,'All')
	UNION ALL
	SELECT 'Sending Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @SendingAgent),'All')
	UNION ALL
	SELECT 'Sending Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @SendingBranch),'All')
	UNION ALL
	SELECT 'Receiving Country ' head,ISNULL(@ReceivingCountry,'All')
	UNION ALL
	SELECT 'Receiving Zone ' head,@rZone
	UNION ALL
	SELECT 'Receiving District ' head,@rDistrict
	UNION ALL
	SELECT 'Receiving Location ' head,ISNULL((select districtName from api_districtList where districtCode=@rLocation),'All')
	UNION ALL
	SELECT 'Receiving Agent ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @ReecivingAgent),'All')
	UNION ALL
	SELECT 'Receiving Branch ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @ReceivingBranch),'All')

	SELECT 'Transaction Analysis Report - (International)' title


GO
