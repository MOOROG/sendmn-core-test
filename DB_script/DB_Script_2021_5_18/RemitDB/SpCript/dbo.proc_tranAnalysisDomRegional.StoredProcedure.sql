USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranAnalysisDomRegional]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_tranAnalysisDomRegional]
	@flag				VARCHAR(20),
	@dateType			VARCHAR(5)	= NULL,
	@fromDate			VARCHAR(20)	= NULL,
	@fromTime			VARCHAR(20)	= NULL,
	@toDate				VARCHAR(30) = NULL,
	@toTime				VARCHAR(20) = NULL,
	@remitProduct		VARCHAR(1)	= NULL,
	@sAgentGrp			VARCHAR(10)	= NULL,
	@sCountry			VARCHAR(50)	= NULL,
	@sZone				VARCHAR(50)	= NULL,
	@sDistrict			VARCHAR(50)	= NULL,
	@sLocation			VARCHAR(50)	= NULL,
	@sAgent				VARCHAR(50)	= NULL,
	@sBranch			VARCHAR(50)	= NULL,
	@rAgentGrp			VARCHAR(10)	= NULL,
	@rCountry			VARCHAR(50)	= NULL,
	@rZone				VARCHAR(50)	= NULL,
	@rDistrict			VARCHAR(50)	= NULL,
	@rLocation			VARCHAR(50)	= NULL,
	@rAgent				VARCHAR(50)	= NULL,
	@rBranch			VARCHAR(50)	= NULL,
	@groupBy			VARCHAR(50)	= NULL,
	@id					VARCHAR(50) = NULL,
	@reportType			VARCHAR(50) = NULL,
	@pageSize			VARCHAR(50)	= NULL,
	@pageNumber			VARCHAR(50) = NULL,
	@groupById			VARCHAR(200)= NULL,
	@isExportFull		VARCHAR(1)	= NULL,
	@user				VARCHAR(50)	= NULL

AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;
			
	DECLARE @DateCondition			VARCHAR(50),
			@GroupCondition			VARCHAR(50),
			@ReportTypeCond			VARCHAR(50),
			@SQL					VARCHAR(MAX),
			@SQL1					VARCHAR(MAX),
			@GroupSelect			VARCHAR(50),
			@GroupId				VARCHAR(50),
			@Amt					VARCHAR(50),
			@Date					VARCHAR(50),
			@globalFilter			VARCHAR(MAX),
			@joinTables				VARCHAR(MAX)		
			
	SET @fromDate=@fromDate+' '+@fromTime
	SET @toDate= @toDate+' '+@toTime 		
			
	SELECT @DateCondition = CASE WHEN @dateType = 's' THEN 'approvedDate' 
							WHEN @dateType = 'p' THEN 'paidDate' END
	SELECT @joinTables = CASE WHEN 	@dateType = 's' THEN 'LEFT JOIN userZoneMapping szm with(nolock) on sbranch.agentState = szm.zoneName'	
								WHEN 	@dateType = 'p' THEN 'LEFT JOIN userZoneMapping pzm with(nolock) on pbranch.agentState = pzm.zoneName' END
	SELECT @GroupCondition = CASE 
								WHEN @dateType='s' AND @groupBy = 'c' THEN 'sCountry' 	
								WHEN @dateType='s' AND @groupBy = 'z' THEN 'SBRANCH.agentState' 
								WHEN @dateType='s' AND @groupBy = 'd' THEN 'SBRANCH.agentDistrict' 
								WHEN @dateType='s' AND @groupBy = 'l' THEN 'SLOC.districtName'								
								WHEN @dateType='s' AND @groupBy = 'a' THEN 'sAgentName' 
								WHEN @dateType='s' AND @groupBy = 'b' THEN 'sBranchName' 	
															
								WHEN @dateType='p' AND @groupBy = 'c' THEN 'pCountry' 								
								WHEN @dateType='p' AND @groupBy = 'z' THEN 'PLOC.zoneName' 
								WHEN @dateType='p' AND @groupBy = 'd' THEN 'PLOC.districtName' 
								WHEN @dateType='p' AND @groupBy = 'l' THEN 'PLOC.locationName' 
								WHEN @dateType='p' AND @groupBy = 'a' THEN 'pAgentName' 
								WHEN @dateType='p' AND @groupBy = 'b' THEN 'pBranchName'
								WHEN @groupBy = 'datewise' THEN 'CONVERT(VARCHAR,MAIN.'+@DateCondition+' ,101)'
							 END	
								
	,@Amt			=	CASE WHEN @dateType='s' AND @groupBy IN ('c','a','b','z','d','l','datewise') THEN 'tAmt'
						WHEN @dateType='p' AND @groupBy IN ('c','a','b','z','d','l','datewise') THEN 'pAmt' END
								
	,@GroupSelect = CASE 
						WHEN @dateType='s' AND @groupBy = 'c' THEN 'Sending Country' 			
						WHEN @dateType='s' AND @groupBy = 'z' THEN 'Sending Zone' 
						WHEN @dateType='s' AND @groupBy = 'd' THEN 'Sending District' 
						WHEN @dateType='s' AND @groupBy = 'l' THEN 'Sending Location' 								
						WHEN @dateType='s' AND @groupBy = 'a' THEN 'Sending Agent' 
						WHEN @dateType='s' AND @groupBy = 'b' THEN 'Sending Branch'								
						WHEN @dateType='p' AND @groupBy = 'c' THEN 'Receiving Country' 								
						WHEN @dateType='p' AND @groupBy = 'z' THEN 'Receiving Zone' 
						WHEN @dateType='p' AND @groupBy = 'd' THEN 'Receiving District' 
						WHEN @dateType='p' AND @groupBy = 'l' THEN 'Receiving Location' 								
						WHEN @dateType='p' AND @groupBy = 'a' THEN 'Receiving Agent' 
						WHEN @dateType='p' AND @groupBy = 'b' THEN 'Receiving Branch'
						WHEN @groupBy = 'datewise' THEN CASE WHEN @dateType = 's' THEN 'Send Date' 
														WHEN @dateType = 'p' THEN 'Paid Date' END
						WHEN @groupBy = 'detail' THEN CASE WHEN @dateType = 's' THEN 'Send Date' 
														WHEN @dateType = 'p' THEN 'Paid Date' END 
					END
								
	,@GroupId  = CASE  
						WHEN @dateType='s' AND @groupBy = 'c' THEN 'sCountry' 			
						WHEN @dateType='s' AND @groupBy = 'z' THEN 'SBRANCH.agentState' 
						WHEN @dateType='s' AND @groupBy = 'd' THEN 'SBRANCH.agentDistrict' 
						WHEN @dateType='s' AND @groupBy = 'l' THEN 'SLOC.districtName' 								
						WHEN @dateType='s' AND @groupBy = 'a' THEN 'sAgent' 
						WHEN @dateType='s' AND @groupBy = 'b' THEN 'sBranch' 
						WHEN @dateType='p' AND @groupBy = 'c' THEN 'pCountry'								
						WHEN @dateType='p' AND @groupBy = 'z' THEN 'PLOC.zoneName' 
						WHEN @dateType='p' AND @groupBy = 'd' THEN 'PLOC.districtName' 
						WHEN @dateType='p' AND @groupBy = 'l' THEN 'PLOC.locationName'								
						WHEN @dateType='p' AND @groupBy = 'a' THEN 'pAgent' 
						WHEN @dateType='p' AND @groupBy = 'b' THEN 'pBranch'
						WHEN @groupBy = 'datewise' THEN 'CONVERT(VARCHAR,MAIN.'+@DateCondition+' ,101)' 
					END
							
								
	,@ReportTypeCond  =	CASE 
							WHEN @dateType='s' AND @groupBy = 'c' THEN 'sCountry' 
							WHEN @dateType='s' AND @groupBy	= 'z' THEN 'SBRANCH.agentState' 
							WHEN @dateType='s' AND @groupBy	= 'd' THEN 'SBRANCH.agentDistrict' 
							WHEN @dateType='s' AND @groupBy	= 'l' THEN 'SBRANCH.agentLocation' 								
							WHEN @dateType='s' AND @groupBy	= 'a' THEN 'sAgent' 
							WHEN @dateType='s' AND @groupBy	= 'b' THEN 'sBranch' 
							WHEN @dateType='p' AND @groupBy	= 'c' THEN 'pCountry' 								
							WHEN @dateType='p' AND @groupBy	= 'z' THEN 'PLOC.zoneName' 
							WHEN @dateType='p' AND @groupBy	= 'd' THEN 'PLOC.districtName' 
							WHEN @dateType='p' AND @groupBy	= 'l' THEN 'MAIN.pLocation' 								
							WHEN @dateType='p' AND @groupBy	= 'a' THEN 'pAgent' 
							WHEN @dateType='p' AND @groupBy	= 'b' THEN 'pBranch'
							WHEN @groupBy	= 'datewise' THEN 'CONVERT(VARCHAR,MAIN.'+@DateCondition+' ,101)' 
						END
	
	IF @groupById IS NOT NULL OR @groupById<>''
	BEGIN
		IF @groupBy='z' AND @dateType='s'
			SET @sZone = @groupById
		IF @groupBy='d' AND @dateType='s'
			SET @sDistrict = @groupById
		IF @groupBy='l' AND @dateType='s'
			SET @sLocation = @groupById
		IF @groupBy = 'a' AND @dateType='s'
			SET @sAgent = @groupById
		IF @groupBy='b' AND @dateType='s'
			SET @sBranch=@groupById 	
		IF @groupBy='z' AND @dateType='p'
			SET @rZone = @groupById
		IF @groupBy='d' AND @dateType='p'
			SET @rDistrict = @groupById
		IF @groupBy='l' AND @dateType='p'
			SET @rLocation=@groupById
		IF @groupBy='a' AND @dateType='p'
			SET @rAgent=@groupById
		IF @groupBy='b' AND @dateType='p'
			SET @rBranch=@groupById 
		IF @groupBy='datewise'
			SET @Date=@groupById 
			
		SET @groupBy='detail'
		SET @FLAG='main'
		SET @GroupSelect=
						CASE WHEN @dateType = 's' THEN 'Send Date' 
						WHEN @dateType = 'p' THEN 'Paid Date'  END 
	END

	SET @globalFilter = ''
	IF @remitProduct = 'S'
		SET @globalFilter = @globalFilter + ' AND MAIN.tranType = ''D'' and TREC.stdCollegeId is null'
	IF @remitProduct = 'T'
		SET @globalFilter = @globalFilter + ' AND MAIN.tranType = ''B'''
	IF @remitProduct = 'E'
		SET @globalFilter = @globalFilter + ' AND MAIN.tranType = ''D'' and TREC.stdCollegeId is not null'			
	IF @sAgent IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND sAgent = ''' + @sAgent + ''''		
	IF @sBranch IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND sBranch = '''+ @sBranch +''''			
	IF @rAgent IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND pAgent = ''' + @rAgent + ''''		
	IF @rBranch IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND  pBranch = '''+ @rBranch +''''
	IF @sLocation IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND  SBRANCH.agentLocation = '''+ @sLocation +''''			
	IF @rLocation IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND  pLocation = '''+ @rLocation +''''
	IF @sZone IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND  SBRANCH.agentState = '''+ @sZone +''''
	IF @rZone IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND  PLOC.zoneName = '''+ @rZone +''''
	IF @sDistrict IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND  SBRANCH.agentDistrict = '''+ @sDistrict +''''
	IF @rDistrict IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND  PLOC.districtName = '''+ @rDistrict +''''
	IF @sAgentGrp IS NOT NULL
		SET @globalFilter =@globalFilter+ ' AND SBRANCH.agentGrp = ''' + @sAgentGrp + '''' 
	IF @rAgentGrp IS NOT NULL
		SET @globalFilter =@globalFilter+ ' AND PBRANCH.agentGrp = ''' + @rAgentGrp + '''' 
	IF @Date IS NOT NULL
		SET @globalFilter = @globalFilter + ' AND convert(varchar,MAIN.'+ @DATECONDITION +',101) = convert(varchar,'''+ @Date +''',101)'
	IF @user IS NOT NULL AND @dateType ='s'
		SET @globalFilter =@globalFilter+ ' AND szm.userName = ''' + @user + ''' and szm.isDeleted is null ' 
	IF @user IS NOT NULL AND @dateType ='p'
		SET @globalFilter =@globalFilter+ ' AND pzm.userName = ''' + @user + ''' and pzm.isDeleted is null ' 

	IF @FLAG = 'main' AND @groupBy = 'detail'
	BEGIN	
		SET @SQL ='SELECT 
					 [Control No] =''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(main.id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
					,['+ @GroupSelect +']	= CONVERT(VARCHAR,MAIN.'+ @DATECONDITION +',101)		
					,[Sending Country]		= sCountry
					,[Sending Location]		= SLOC.districtName
					,[Sending Agent]		= sAgentName
					,[Sending Branch]		= sBranchName
					,[Sending Amt]			= tAmt
					,[Sending Currency]		= collCurr
					,[Status]				= MAIN.tranStatus
					,[Receiving Country]	= ISNULL(pCountry,''-'')
					,[Receiving Location]	= PLOC.locationName
					,[Receiving Agent]		= ISNULL(pAgentName,''-'')
					,[Receiving Branch]		= ISNULL(pBranchName,''-'')
					,[Receiving Amt]		= pAmt
					,[Receiving Currency]	= payoutCurr
					,[Tran Type]			= MAIN.paymentMethod
					,[Sender Name]=TSEND.firstName + ISNULL('' '' + TSEND.middleName, '''') + ISNULL('' '' + TSEND.lastName1, '''') + ISNULL('' '' + TSEND.lastName2,'''')
					,[Receiver Name]=TREC.firstName + ISNULL('' '' + TREC.middleName, '''') + ISNULL('' '' + TREC.lastName1, '''') + ISNULL('' '' + TREC.lastName2, '''')
					,[Receiver Id Type] = isnull(TREC.idType2, TREC.idType)
					,[Receiver Id Number] = isnull(TREC.idNumber2, TREC.idNumber)
				FROM remitTran MAIN WITH(NOLOCK)  
				LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
				LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
				LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
				LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
				LEFT JOIN tranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
				LEFT JOIN tranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
				'+@joinTables+'
				WHERE MAIN.sCountry=''Nepal'' AND 
				MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' '
		SET @SQL = @SQL + @globalFilter	
	END	
	IF @FLAG = 'datewise'
	BEGIN		
		SET @SQL = 'SELECT 
					 '+@ReportTypeCond+' [groupBy]	
					,'+ @GroupCondition +' ['+ @GroupSelect +']
					,COUNT(*) [Txn Count]  
					,SUM('+@Amt+') [Txn Amount]		
					FROM remitTran MAIN WITH(NOLOCK)  
					LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
					LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
					LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
					LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
					LEFT JOIN tranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
					LEFT JOIN tranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
					'+@joinTables+'
					WHERE MAIN.sCountry=''Nepal'' and 
					MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' '
			SET @SQL = @SQL + @globalFilter		
			SET @SQL = @SQL + ' GROUP BY '+ @GroupCondition +''

	END
	IF @FLAG = 'main' AND @groupBy <>'detail'
	BEGIN		
		--select @ReportTypeCond,@GroupSelect,@GroupCondition,@Amt
		SET @SQL = 'SELECT 	
			 '+@ReportTypeCond+' [groupBy]			
			,['+ @GroupSelect +'] ='+ @GroupCondition +'
			,COUNT(*) [Txn Count]
			,SUM('+@Amt+') [Txn Amount]			
			FROM remitTran MAIN WITH(NOLOCK)  
			LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
			LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
			LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
			LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
			LEFT JOIN tranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
			LEFT JOIN tranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
			'+@joinTables+'
			WHERE  ISNULL(MAIN.sCountry,'''')=''Nepal'' AND 
			MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''' '
		SET @SQL = @SQL + @globalFilter	
		SET @SQL = @SQL + ' GROUP BY '+ @GroupCondition +','+@ReportTypeCond+''
		PRINT(@SQL)
	END

	IF OBJECT_ID('tempdb..#temp_table') IS NOT NULL
	DROP TABLE #temp_table

	DECLARE @SQL2 AS VARCHAR(MAX)
	SET @SQL2='SELECT ROW_NUMBER() OVER (ORDER BY ['+@GroupSelect+']) AS [S.N.],* 
				INTO #temp_table
					FROM 
					(
						'+ @SQL +'
					) AS aa ORDER BY ['+@GroupSelect+'] '

	IF @isExportFull = 'Y'
	BEGIN
		SET @SQL1=@SQL2+'; SELECT * FROM #temp_table'		
	END
	ELSE
	BEGIN
		SET @SQL1=@SQL2+';	SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM #temp_table;
							SELECT * FROM #temp_table  WHERE [S.N.] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''
	END
	PRINT(@SQL1)
	EXEC(@SQL1)


	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'GROUP BY'  head ,@GroupSelect value
	UNION ALL
	SELECT 'DATE TYPE ' head,CASE WHEN @dateType = 'S' THEN 'Sending Date' 
							WHEN @dateType = 'P' THEN 'Paid Date' 
							WHEN @dateType = 'C' THEN 'Cancel Date' END value
	UNION ALL
	SELECT 'FROM DATE ' head, CONVERT(VARCHAR, @fromDate, 101) value
	UNION ALL
	SELECT 'TO DATE ' head, CONVERT(VARCHAR, @toDate, 101) value
	UNION ALL
	SELECT 'Remit Product ' head, (SELECT CASE WHEN @remitProduct ='S' THEN 'Normal Send' 
												WHEN @remitProduct ='T' THEN 'Topup' 
												WHEN @remitProduct ='E' THEN 'Edu Pay'
												ELSE 'All' END) value

	UNION ALL
	SELECT 'SENDING AGENT GROUP' head, CASE WHEN @sAgentGrp IS NULL THEN 'All' ELSE (SELECT detailTitle FROM staticdataValue WHERE valueId = @sAgentGrp) END
	UNION ALL
	SELECT 'SENDING COUNTRY' head,ISNULL(@sCountry,'All')
	UNION ALL
	SELECT 'SENDING ZONE ' head,ISNULL(@sZone,'All')
	UNION ALL
	SELECT 'SENDING DISTRICT ' head,ISNULL(@sDistrict,'All')
	UNION ALL
	SELECT 'SENDING LOCATION ' head,ISNULL((SELECT districtName FROM api_districtList WHERE districtCode=@sLocation),'All')
	UNION ALL
	SELECT 'SENDING AGENT ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent),'All')
	UNION ALL
	SELECT 'SENDING BRANCH ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch),'All')
	UNION ALL
	SELECT 'RECEIVING AGENT GROUP' head, CASE WHEN @rAgentGrp IS NULL THEN 'All' ELSE (SELECT detailTitle FROM staticdataValue WHERE valueId = @rAgentGrp) END
	UNION ALL
	SELECT 'RECEIVING COUNTRY ' head,ISNULL(@rCountry,'All')
	UNION ALL
	SELECT 'RECEIVING ZONE ' head,ISNULL(@rZone,'All')
	UNION ALL
	SELECT 'RECEIVING DISTRICT ' head,ISNULL(@rDistrict,'All')
	UNION ALL
	SELECT 'RECEIVING LOCATION ' head,ISNULL((SELECT districtName FROM api_districtList WHERE districtCode=@rLocation),'All')
	UNION ALL
	SELECT 'RECEIVING AGENT ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @rAgent),'All')
	UNION ALL
	SELECT 'RECEIVING BRANCH ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @rBranch),'All')

	SELECT 'TRANSACTION ANALYSIS REPORT- (DOMESTIC) ' title

GO
