USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranAnalysisIntl_20162310]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procEDURE [dbo].[proc_tranAnalysisIntl_20162310]
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
	@sLocation			VARCHAR(50)	= NULL,
	@rLocation			VARCHAR(50)	= NULL,
	@rZone				VARCHAR(50)	= NULL,
	@rDistrict			VARCHAR(50)	= NULL,	
	@sZone				VARCHAR(50)	= NULL,
	@sDistrict			VARCHAR(50) = NULL,
	@tranType			VARCHAR(50) = NULL,
	@USER				VARCHAR(50)	= NULL,
	@pageSize			VARCHAR(50)	= NULL,
	@pageNumber			VARCHAR(50) = NULL,
	@groupById			VARCHAR(200)= NULL,
	@searchBy			VARCHAR(50)	= NULL,
	@searchByText		VARCHAR(200)= NULL,
	@fromTime			VARCHAR(20)	= NULL,
	@toTime				VARCHAR(20) = NULL,
	@isExportFull		VARCHAR(1)	= NULL,
	@sAgentGrp			VARCHAR(10)	= NULL,
	@rAgentGrp			VARCHAR(10)	= NULL


AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;

 IF @toTime IS NULL OR @toTime = '00:00:00' OR @toTime = ' 00:00:00'
	SET @toTime = '23:59:59'

	IF @rZone ='All'
		SET @rZone = NULL
	IF @sZone ='All'
		SET @sZone= NULL
		
	IF @rDistrict ='All'
		SET @rDistrict = NULL
	IF @sDistrict ='All'
		SET @sDistrict= NULL
	
	IF @rLocation ='All'
		SET @rLocation = NULL
	IF @sLocation ='All'
		SET @sLocation= NULL
	IF @status ='Unpaid'
		SET @status = 'Payment'
	
	IF @GROUPBY = 'Datewise' AND @controlNo IS NULL
		SET @FLAG = 'Datewise'

	DECLARE @DateCondition VARCHAR(50),
			@GroupCondition VARCHAR(50),
			@ReportTypeCond	VARCHAR(50),
			@SQL VARCHAR(MAX),
			@SQL1 VARCHAR(MAX),
			@maxReportViewDays INT,
			@GroupSelect VARCHAR(50),
			@GroupId	VARCHAR(50),
			@Currency	VARCHAR(50),
			@Amt		VARCHAR(50),
			@statusField	VARCHAR(50),
			@Date			VARCHAR(50)
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(5000))
	DECLARE @globalFilter VARCHAR(MAX) = ''
	SET @fromDate=@fromDate+' '+@fromTime
	SET @toDate= @toDate+' '+@toTime 	
			
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
			
	SELECT @DateCondition = CASE 
								WHEN @DATETYPE = 't' THEN 'createdDate'
								WHEN @DATETYPE = 'S' THEN 'approvedDate' 
								WHEN @DATETYPE = 'P' THEN 'paidDate' 
								WHEN @DATETYPE = 'C' THEN 'cancelApprovedDate' 
							END
							
	SELECT @GroupCondition   =	CASE WHEN @GROUPBY = 'SC' THEN 'sCountry' 
	
								WHEN @GROUPBY = 'SZ' THEN 'SBRANCH.agentState' 
								WHEN @GROUPBY = 'SD' THEN 'SBRANCH.agentDistrict' 
								WHEN @GROUPBY = 'SL' THEN 'SLOC.districtName'  
								
								WHEN @GROUPBY = 'SA' THEN 'sAgentName' 
								WHEN @GROUPBY = 'SB' THEN 'sBranchName' 
								
								WHEN @GROUPBY = 'RC' THEN 'pCountry' 
								
								WHEN @GROUPBY = 'RZ' THEN 'PLOC.zoneName' 
								WHEN @GROUPBY = 'RD' THEN 'PLOC.districtName' 
								WHEN @GROUPBY = 'RL' THEN 'PLOC.locationName' 								
								
								WHEN @GROUPBY = 'RA' THEN 'pAgentName' 
								WHEN @GROUPBY = 'RB' THEN 'pBranchName'
								WHEN @GROUPBY = 'Datewise' THEN 'CONVERT(VARCHAR,MAIN.'+@DateCondition+' ,101)' END								
								
						
			
			,@Currency		=	CASE WHEN @GROUPBY IN ('SC','SA','SB','SZ','SD','SL') THEN 'collCurr'
								WHEN @GROUPBY IN ('RC','RA','RB','RZ','RD','RL') THEN 'payoutCurr' END
								
			,@Amt		=		CASE WHEN @GROUPBY IN ('SC','SA','SB','SZ','SD','SL') THEN 'pAmt'
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
								WHEN @GROUPBY = 'Datewise' THEN 
															CASE 
																WHEN @DATETYPE = 't' THEN 'TXN Date'
																WHEN @DATETYPE = 'S' THEN 'Confirm Date' 
																WHEN @DATETYPE = 'P' THEN 'Paid Date' 
																WHEN @DATETYPE = 'C' THEN 'Canecel Date' 
															END

								WHEN @GROUPBY = 'detail' THEN CASE 
																WHEN @DATETYPE = 't' THEN 'TXN Date'
																WHEN @DATETYPE = 'S' THEN 'Confirm Date' 
																WHEN @DATETYPE = 'P' THEN 'Paid Date' 
																WHEN @DATETYPE = 'C' THEN 'Canecel Date' END 
								END
								
			,@GroupId   =CASE  WHEN  @GROUPBY = 'SC' THEN 'sCountry' 
			
								WHEN @GROUPBY = 'SZ' THEN 'SBRANCH.agentState' 
								WHEN @GROUPBY = 'SD' THEN 'SBRANCH.agentDistrict' 
								WHEN @GROUPBY = 'SL' THEN 'SLOC.districtName' 
								
								WHEN @GROUPBY = 'SA' THEN 'sAgent' 
								WHEN @GROUPBY = 'SB' THEN 'sBranch' 
								WHEN @GROUPBY = 'RC' THEN 'pCountry' 
								
								WHEN @GROUPBY = 'RZ' THEN 'PLOC.zoneName' 
								WHEN @GROUPBY = 'RD' THEN 'PLOC.districtName' 
								WHEN @GROUPBY = 'RL' THEN 'PLOC.locationName' 
								
								WHEN @GROUPBY = 'RA' THEN 'pAgent' 
								WHEN @GROUPBY = 'RB' THEN 'pBranch'
								WHEN @GROUPBY = 'Datewise' THEN 'CONVERT(VARCHAR,MAIN.'+@DateCondition+' ,101)' 
								END
							
								
			,@ReportTypeCond  =	CASE WHEN @GROUPBY = 'SC' THEN 'sCountry' 

									WHEN @GROUPBY	= 'SZ' THEN 'SBRANCH.agentState' 
									WHEN @GROUPBY	= 'SD' THEN 'SBRANCH.agentDistrict' 
									WHEN @GROUPBY	= 'SL' THEN 'SBRANCH.agentLocation' 								
									WHEN @GROUPBY	= 'SA' THEN 'sAgent' 
									WHEN @GROUPBY	= 'SB' THEN 'sBranch' 
									WHEN @GROUPBY	= 'RC' THEN 'pCountry' 								
									WHEN @GROUPBY	= 'RZ' THEN 'PLOC.zoneId' 
									WHEN @GROUPBY	= 'RD' THEN 'PLOC.districtId' 
									WHEN @GROUPBY	= 'RL' THEN 'MAIN.pLocation' 								
									WHEN @GROUPBY	= 'RA' THEN 'pAgent' 
									WHEN @GROUPBY	= 'RB' THEN 'pBranch'
									WHEN @GROUPBY	= 'Datewise' THEN 'CONVERT(VARCHAR,MAIN.'+@DateCondition+' ,101)' 
								END

			,@statusField	=	 CASE WHEN @status IN ('Unpaid','Paid') THEN 'payStatus' 
								WHEN @status='Cancel' THEN 'tranStatus' END			
	
IF @controlNo IS NOT NULL
BEGIN
	SET @SQL ='SELECT 
			 [Control No] =''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'/Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(MAIN.id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
			,[Send Date]			= CONVERT(VARCHAR,MAIN.approvedDate,101)		
			,[Sending Country]		= sCountry
			,[Sending Location]		= SLOC.districtName
			,[Sending Agent]		= sAgentName
			,[Sending Branch]		= sBranchName
			,[Sending Amt]			= tAmt
			,[Sending Currency]		= collCurr
			,[Status]				= MAIN.tranStatus
			,[Receiving Country]	= ISNULL(pCountry,''-'')
			,[Receiving Location]	= PLOC.locationName
			,[Receiving Agent]		= case when MAIN.paymentMethod=''Bank Deposit'' then MAIN.pBankName else ISNULL(MAIN.pAgentName,''-'') end
			,[Receiving Branch]		= case when MAIN.paymentMethod=''Bank Deposit'' then MAIN.pBankBranchName else ISNULL(MAIN.pBranchName,''-'') end
			,[Receiving Amt]		= pAmt
			,[Account No.]			= ISNULL(MAIN.accountNo,''-'')
			,[Tran Type]			= MAIN.paymentMethod
			,[Sender Name]=TSEND.firstName + ISNULL('' '' + TSEND.middleName, '''') + ISNULL('' '' + TSEND.lastName1, '''') + ISNULL('' '' + TSEND.lastName2,'''')
			,[Receiver Name]=TREC.firstName + ISNULL('' '' + TREC.middleName, '''') + ISNULL('' '' + TREC.lastName1, '''') + ISNULL('' '' + TREC.lastName2, '''')
	FROM vwRemitTran_New MAIN WITH(NOLOCK)  
	LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
	LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
	LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
	LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
	LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
	LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
	WHERE ISNULL(MAIN.sCountry,'''')<>''Nepal'' 
	AND main.sAgent not in (4746,4812)
	AND MAIN.controlNo = '''+ dbo.FNAEncryptString(@controlNo) +''''
	EXEC @SQL
	INSERT INTO @FilterList
	SELECT 'CONTROL NO ' head, @controlNo value
END
ELSE
BEGIN	
	IF @groupById IS NOT NULL OR @groupById<>''
	BEGIN
		IF @GROUPBY='sc'
			SET @SendingCountry=@groupById
		IF @GROUPBY='sz'
			SET @sZone=@groupById
		IF @GROUPBY='sd'
			SET @sDistrict=@groupById
		IF @GROUPBY='sl'
			SET @sLocation=@groupById
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
		IF @GROUPBY='rc'
			SET @ReceivingCountry=@groupById
		IF @GROUPBY='Datewise'
			SET @Date=@groupById 			
		SET @GROUPBY='DETAIL'
		SET @FLAG='MAIN'
		SET @GroupSelect = CASE	
						WHEN @DATETYPE = 'S'  THEN 'Confirm Date' 
						WHEN @DATETYPE = 't'  THEN 'TXN Date' 
						WHEN @DATETYPE = 'P' THEN 'Paid Date' 
						WHEN @DATETYPE = 'C' THEN 'Canecel Date' END 
	END

	IF @SendingCountry IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SENDING COUNTRY' head,ISNULL(@SendingCountry,'All')
		SET @globalFilter = @globalFilter + ' AND sCountry = ''' + @SendingCountry + ''''	
	END		
	IF @ReceivingCountry IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'RECEIVING COUNTRY ' head,ISNULL(@ReceivingCountry,'All')
		SET @globalFilter = @globalFilter + ' AND pCountry = ''' + @ReceivingCountry + ''''
	END			
	IF @SendingAgent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SENDING AGENT ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @SendingAgent),'All')
		SET @globalFilter = @globalFilter + ' AND sAgent = ''' + @SendingAgent + ''''
	END		
	IF @SendingBranch IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SENDING BRANCH ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @SendingBranch),'All')
		SET @globalFilter = @globalFilter + ' AND sBranch = '''+ @SendingBranch +''''
	END			
	IF @ReecivingAgent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'RECEIVING AGENT ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @ReecivingAgent),'All')
		SET @globalFilter = @globalFilter + ' AND pAgent = ''' + @ReecivingAgent + ''''
	END
	IF @ReceivingBranch IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'RECEIVING BRANCH ' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @ReceivingBranch),'All')
		SET @globalFilter = @globalFilter + 'AND  pBranch = '''+ @ReceivingBranch +''''			
	END		
	IF @status IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'TRAN STATUS ' head, ISNULL(@status,'All') value
		SET @globalFilter = @globalFilter + 'AND  tranStatus = '''+ @status +''''
	END				
	IF @sLocation IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SENDING LOCATION ' head,ISNULL((SELECT districtName FROM api_districtList WHERE districtCode=@sLocation),'All')
		SET @globalFilter = @globalFilter + 'AND  SBRANCH.agentLocation = '''+ @sLocation +''''
	END				
	IF @rLocation IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'RECEIVING LOCATION ' head,ISNULL((SELECT districtName FROM api_districtList WHERE districtCode=@rLocation),'All')
		SET @globalFilter = @globalFilter + 'AND  pLocation = '''+ @rLocation +''''			
	END			
	IF @sZone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SENDING ZONE ' head,ISNULL(@sZone,'All')
		SET @globalFilter = @globalFilter + 'AND  SBRANCH.agentState = '''+ @sZone +''''
	END		
	IF @rZone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'RECEIVING ZONE ' head,ISNULL(@rZone,'All')
		SET @globalFilter = @globalFilter + 'AND  PLOC.zoneName = '''+ @rZone +''''
	END	
	IF @sDistrict IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SENDING DISTRICT ' head,ISNULL(@sDistrict,'All')
		SET @globalFilter = @globalFilter + 'AND  SBRANCH.agentDistrict = '''+ @sDistrict +''''
	END			
	IF @rDistrict IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'RECEIVING DISTRICT ' head,ISNULL(@rDistrict,'All')
		SET @globalFilter = @globalFilter + ' AND  PLOC.districtName = '''+ @rDistrict +''''
	END			
	IF @tranType IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'TRAN TYPE ' head, ISNULL(@tranType,'All') value
		SET @globalFilter = @globalFilter + ' AND  MAIN.paymentMethod = '''+ @tranType +''''
	END			
	IF @Id IS NOT NULL
	BEGIN
		SET @globalFilter = @globalFilter + '  AND '+ @ReportTypeCond +' = '''+ @Id +''''	
	END				
	IF @searchByText IS NOT NULL AND @searchBy ='sender'
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SEARCH BY TEXT ' head, ISNULL(@searchByText,'All') value
		SET @globalFilter =@globalFilter+ ' AND main.senderName LIKE ''%' + @searchByText + '%'''
	END	
	IF @searchByText IS NOT NULL AND @searchBy ='receiver'
		SET @globalFilter = @globalFilter+ ' AND main.receiverName LIKE ''%' + @searchByText + '%'''
				
	IF @searchByText IS NOT NULL AND @searchBy ='cAmt'
		SET @globalFilter = @globalFilter+ ' AND MAIN.cAmt = ' + @searchByText + ''
						
	IF @searchByText IS NOT NULL AND @searchBy ='pAmt'
		SET @globalFilter = @globalFilter+ ' AND MAIN.pAmt = ' + @searchByText + ''	
				
	IF @searchByText IS NOT NULL AND @searchBy ='extCustomerId'
		SET @globalFilter = @globalFilter+ ' AND TSEND.extCustomerId = ' + @searchByText + ''	

	IF @searchByText IS NOT NULL AND @searchBy IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SEARCH BY ' head,@searchBy value
		INSERT INTO @FilterList
		SELECT 'SEARCH BY TEXT ' head, @searchByText value
	END
	IF @sAgentGrp IS NOT NULL
	BEGIN
		INSERT INTO @FilterList
		SELECT 'SENDING AGENT GROUP' head, CASE WHEN @sAgentGrp IS NULL THEN 'All' ELSE (SELECT detailTitle FROM staticdataValue WHERE valueId = @sAgentGrp) END
		SET @globalFilter = @globalFilter+ ' AND SBRANCH.agentGrp = ''' + @sAgentGrp + '''' 
	END	
	IF @rAgentGrp IS NOT NULL
    BEGIN	
		INSERT INTO @FilterList
		SELECT 'RECEIVING AGENT GROUP' head, CASE WHEN @rAgentGrp IS NULL THEN 'All' ELSE (SELECT detailTitle FROM staticdataValue WHERE valueId = @rAgentGrp) END
		SET @globalFilter = @globalFilter+ ' AND PBRANCH.agentGrp = ''' + @rAgentGrp + '''' 
	END

	IF @FLAG = 'MAIN' AND @GROUPBY = 'DETAIL'
	BEGIN	
		SET @SQL ='
		SELECT 
			 [Control No] =''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(MAIN.id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
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
			,[Receiving Agent]		= case when MAIN.paymentMethod=''Bank Deposit'' then MAIN.pBankName else ISNULL(MAIN.pAgentName,''-'') end
			,[Receiving Branch]		= case when MAIN.paymentMethod=''Bank Deposit'' then MAIN.pBankBranchName else ISNULL(MAIN.pBranchName,''-'') end
			,[Receiving Amt]		= pAmt
			,[Account No.]			= ISNULL(MAIN.accountNo,''-'')
			,[Tran Type]			= MAIN.paymentMethod
			,[Sender Name]			= TSEND.firstName + ISNULL('' '' + TSEND.middleName, '''') + ISNULL('' '' + TSEND.lastName1, '''') + ISNULL('' '' + TSEND.lastName2,'''')
			,[Receiver Name]		= TREC.firstName + ISNULL('' '' + TREC.middleName, '''') + ISNULL('' '' + TREC.lastName1, '''') + ISNULL('' '' + TREC.lastName2, '''')
		FROM vwRemitTran_New MAIN WITH(NOLOCK)  
		LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
		LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
		LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
		LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
		LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
		LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
		WHERE ISNULL(MAIN.sCountry,'''') <> ''Nepal'' 
		AND main.sAgent not in (4746,4812)
		AND MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''			
			
		SET @SQL = @SQL + @globalFilter	
													
		IF @Date IS NOT NULL
			SET @SQL = @SQL + 'AND convert(varchar,MAIN.'+ @DATECONDITION +',101) = convert(varchar,'''+ @Date +''',101)'	
	END
	
	IF @FLAG = 'Datewise'
	BEGIN
		SET @SQL = '
		SELECT 
			[groupBy] = '+ @ReportTypeCond +'
			,['+ @GroupSelect +'] = '+ @GroupCondition +' 
			,[Txn Count]  = COUNT(''x'')  
			,[Txn Amount] = SUM(pAmt) 
		FROM vwRemitTran_New MAIN WITH(NOLOCK)  
		LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId = MAIN.sBranch
		LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId = MAIN.pBranch
		LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode = SBRANCH.agentLocation
		LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId = MAIN.pLocation
		LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
		LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
		WHERE ISNULL(MAIN.sCountry,'''')<>''Nepal'' 
		AND main.sAgent not in (4746,4812) AND 
		MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''

		SET @SQL = @SQL + @globalFilter											
		SET @SQL = @SQL + ' GROUP BY '+ @GroupCondition +''

	END	

	IF @FLAG = 'MAIN' AND @GROUPBY <>'DETAIL'
	BEGIN	
		SET @SQL = '
		SELECT 	
			 [groupBy] =  '+ @ReportTypeCond +' 			
			,['+ @GroupSelect +'] ='+ @GroupCondition +'
			,[Txn Count] = COUNT(''X'') 
			,[Txn Amount] = SUM('+@Amt+') 				
		FROM vwRemitTran_New MAIN WITH(NOLOCK)  
		LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch			
		LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
		LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
		LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
		LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
		LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
		WHERE  ISNULL(MAIN.sCountry,'''')<>''Nepal'' 
		AND main.sAgent not in (4746,4812) AND
		MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''					
		SET @SQL = @SQL + @globalFilter											
		SET @SQL = @SQL + ' GROUP BY '+ @GroupCondition +','+ @ReportTypeCond +''
	END	
		
	IF OBJECT_ID('tempdb..#temp_table') IS NOT NULL
		DROP TABLE #temp_table
	
	IF @GroupSelect IS NULL
		SET @GroupSelect = 'Send Date'
	DECLARE @SQL2 AS VARCHAR(MAX)
	SET @SQL2=' SELECT ROW_NUMBER() OVER (ORDER BY ['+@GroupSelect+'] ) AS [S.N.],* 
				INTO #temp_table
				FROM 
				(
					'+ @SQL +'
				) AS aa ORDER BY ['+@GroupSelect+'] '


	IF @isExportFull = 'Y'
	BEGIN
		SET @SQL1 = @SQL2+'; SELECT * FROM #temp_table'		
	END
	ELSE
	BEGIN
		SET @SQL1 = @SQL2+';
		SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM #temp_table;
		SELECT * FROM #temp_table  WHERE [S.N.] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''
	END
	EXEC(@SQL1)
END				
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL


SELECT 'GROUP BY '  head ,@GroupSelect value 
UNION ALL
SELECT 'DATE TYPE ' head,CASE 
						WHEN @DATETYPE = 't' THEN 'TXN Date' 
						WHEN @DATETYPE = 'S' THEN 'Confirm Date' 
						WHEN @DATETYPE = 'P' THEN 'Paid Data' 
						WHEN @DATETYPE = 'C' THEN 'Cancel Date' END value
UNION ALL
SELECT 'FROM DATE ' head, CONVERT(VARCHAR, @fromDate, 101) value
UNION ALL
SELECT 'TO DATE ' head, CONVERT(VARCHAR, @toDate, 101) value
UNION ALL
SELECT * FROM @FilterList


SELECT 'TRANSACTION ANALYSIS REPORT- (INTERNATIONAL) ' title




GO
