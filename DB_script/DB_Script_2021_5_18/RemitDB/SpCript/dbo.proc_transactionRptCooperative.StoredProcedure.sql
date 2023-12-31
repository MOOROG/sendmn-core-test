USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_transactionRptCooperative]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	EXEC proc_transactionRptCooperative  @flag = 'main', @user = 'admin', @fromDate = '2012-11-06', @toDate = '2012-11-06', 
	@SendingAgent = null, @SendingCountry = 'Nepal', @SendingBranch = null, @ReceivingCountry = 'Nepal',
	@ReecivingAgent = null, @ReceivingBranch = null, @groupBy = 'sl', @dateType = 'S', @ReportType = null, 
	@Id = null, @status = null, @controlNo = null, @rZone = 'All', @rDistrict = 'All', @sZone = 'All', 
	@sDistrict = 'All', @sLocation = null, @rLocation = null, @pageSize = '1000', @pageNumber ='1', @groupById =null
		
*/
CREATE procEDURE [dbo].[proc_transactionRptCooperative]
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
	@toTime				VARCHAR(20) = NULL


AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;


	IF @rZone ='All'
		set @rZone = null
	if @sZone ='All'
		set @sZone= null
		
	IF @rDistrict ='All'
		set @rDistrict = null
	if @sDistrict ='All'
		set @sDistrict= null
	
	IF @rLocation ='All'
		set @rLocation = null
	if @sLocation ='All'
		set @sLocation= null
	IF @status ='Unpaid'
		set @status = 'Payment'
		
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
			
			
	SET @fromDate=@fromDate+' '+@fromTime
	SET @toDate= @toDate+' '+@toTime 		
		
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers with(nolock) WHERE userName = @user
			
	SELECT @DateCondition = CASE WHEN @DATETYPE = 'S' THEN 'approvedDate' 
							WHEN @DATETYPE = 'P' THEN 'paidDate' 
							WHEN @DATETYPE = 'C' THEN 'cancelApprovedDate' END							
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
								
		,@GroupId  = CASE  WHEN  @GROUPBY = 'SC' THEN 'sCountry' 			
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
						WHEN @GROUPBY = 'Datewise' THEN 'CONVERT(VARCHAR,MAIN.'+@DateCondition+' ,101)' END								
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
		,@statusField	=	CASE WHEN @status IN ('Unpaid','Paid') THEN 'payStatus' 
								WHEN @status='Cancel' THEN 'tranStatus' END			
	
IF @controlNo IS NULL
BEGIN
	
	IF @groupById IS NOT NULL OR @groupById<>''
	BEGIN
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
				FROM vwremitTran MAIN WITH(NOLOCK)  
				LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
				LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
				LEFT JOIN agentMaster SAGENT WITH(NOLOCK) ON SAGENT.agentId=MAIN.sAgent
				LEFT JOIN agentMaster PAGENT WITH(NOLOCK) ON PAGENT.agentId=MAIN.pAgent
				LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
				LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
				LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
				LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
				WHERE MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''
	
		SET @SQL = @SQL + ' AND (SAGENT.BUSINESSTYPE = ''6204'' OR PAGENT.BUSINESSTYPE = ''6204'')'

		IF @SendingCountry IS NOT NULL
			SET @SQL = @SQL + ' AND MAIN.sCountry = ''' + @SendingCountry + ''''					
			
		IF @SendingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND sAgent = ''' + @SendingAgent + ''''

		IF @SendingBranch IS NOT NULL
			SET @SQL = @SQL + ' AND sBranch = '''+ @SendingBranch +''''
			
		IF @ReecivingAgent IS NOT NULL
			SET @SQL = @SQL + ' AND pAgent = ''' + @ReecivingAgent + ''''
		
		IF @ReceivingBranch IS NOT NULL
			SET @SQL = @SQL + 'AND  pBranch = '''+ @ReceivingBranch +''''			
			
		IF @status IS NOT NULL
			SET @SQL = @SQL + 'AND  tranStatus = '''+ @status +''''
			
		IF @sLocation IS NOT NULL
			SET @SQL = @SQL + 'AND  SBRANCH.agentLocation = '''+ @sLocation +''''
			
		IF @rLocation IS NOT NULL
			SET @SQL = @SQL + 'AND  pLocation = '''+ @rLocation +''''			
			
		IF @sZone IS NOT NULL
			SET @SQL = @SQL + 'AND  SBRANCH.agentState = '''+ @sZone +''''
			
		IF @rZone IS NOT NULL
			SET @SQL = @SQL + 'AND  PLOC.zoneName = '''+ @rZone +''''
		
		IF @sDistrict IS NOT NULL
			SET @SQL = @SQL + 'AND  SBRANCH.agentDistrict = '''+ @sDistrict +''''
			
		IF @rDistrict IS NOT NULL
			SET @SQL = @SQL + 'AND  PLOC.districtName = '''+ @rDistrict +''''
		
		IF @tranType IS NOT NULL
			SET @SQL = @SQL + 'AND  MAIN.paymentMethod = '''+ @tranType +''''
			
		IF @searchByText IS NOT NULL AND @searchBy ='sender'
			SET @SQL =@SQL+ ' AND TSEND.firstName LIKE ''%' + @searchByText + '%'''
		
		IF @searchByText IS NOT NULL AND @searchBy ='receiver'
			SET @SQL =@SQL+ ' AND TREC.firstName LIKE ''%' + @searchByText + '%'''	
		
		IF @searchByText IS NOT NULL AND @searchBy ='cAmt'
			SET @SQL =@SQL+ ' AND MAIN.cAmt = ' + @searchByText + ''
							
		IF @searchByText IS NOT NULL AND @searchBy ='pAmt'
			SET @SQL =@SQL+ ' AND MAIN.pAmt = ' + @searchByText + ''	

		IF @searchByText IS NOT NULL AND @searchBy ='extCustomerId'
			SET @SQL =@SQL+ ' AND TSEND.extCustomerId = ' + @searchByText + ''
									
		IF @Date IS NOT NULL
			SET @SQL = @SQL + 'AND convert(varchar,MAIN.'+ @DATECONDITION +',101) = convert(varchar,'''+ @Date +''',101)'				
	
	
	END
	
	IF @FLAG = 'Datewise'
	BEGIN
		SET @SQL = 'SELECT 
					 '+@ReportTypeCond+' [groupBy]	
					,'+ @GroupCondition +' ['+ @GroupSelect +']
					,COUNT(*) [Txn Count]  
					,SUM(tAmt) [Txn Amount]
					FROM vwremitTran MAIN WITH(NOLOCK)  
					LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
					LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
					LEFT JOIN agentMaster SAGENT WITH(NOLOCK) ON SAGENT.agentId=MAIN.sAgent
					LEFT JOIN agentMaster PAGENT WITH(NOLOCK) ON PAGENT.agentId=MAIN.pAgent
					LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
					LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
					LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
					LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
					WHERE MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''
					
		
			SET @SQL = @SQL + ' AND (SAGENT.BUSINESSTYPE = ''6204'' OR PAGENT.BUSINESSTYPE = ''6204'')'

			IF @SendingCountry IS NOT NULL
				SET @SQL = @SQL + ' AND MAIN.sCountry = ''' + @SendingCountry + ''''

			IF @SendingAgent IS NOT NULL
				SET @SQL = @SQL + ' AND sAgent = ''' + @SendingAgent + ''''
			
			IF @SendingBranch IS NOT NULL
				SET @SQL = @SQL + ' AND sBranch = '''+ @SendingBranch +''''
				
			IF @ReecivingAgent IS NOT NULL
				SET @SQL = @SQL + ' AND pAgent = ''' + @ReecivingAgent + ''''
			
			IF @ReceivingBranch IS NOT NULL
				SET @SQL = @SQL + 'AND  pBranch = '''+ @ReceivingBranch +''''			
				
			IF @status IS NOT NULL
				SET @SQL = @SQL + 'AND  tranStatus = '''+ @status +''''
				
			IF @sLocation IS NOT NULL
				SET @SQL = @SQL + 'AND  SBRANCH.agentLocation = '''+ @sLocation +''''
				
			IF @rLocation IS NOT NULL
				SET @SQL = @SQL + 'AND  pLocation = '''+ @rLocation +''''			
				
			IF @sZone IS NOT NULL
				SET @SQL = @SQL + 'AND  SBRANCH.agentState = '''+ @sZone +''''
				
			IF @rZone IS NOT NULL
				SET @SQL = @SQL + 'AND  PLOC.zoneName = '''+ @rZone +''''
			
			IF @sDistrict IS NOT NULL
				SET @SQL = @SQL + 'AND  SBRANCH.agentDistrict = '''+ @sDistrict +''''
				
			IF @rDistrict IS NOT NULL
				SET @SQL = @SQL + 'AND  PLOC.districtName = '''+ @rDistrict +''''
				
			IF @tranType IS NOT NULL
				SET @SQL = @SQL + 'AND  MAIN.paymentMethod = '''+ @tranType +''''
				
			IF @searchByText IS NOT NULL AND @searchBy ='sender'
				SET @SQL =@SQL+ ' AND TSEND.firstName LIKE ''%' + @searchByText + '%'''
			
			IF @searchByText IS NOT NULL AND @searchBy ='receiver'
				SET @SQL =@SQL+ ' AND TREC.firstName LIKE ''%' + @searchByText + '%'''		
			
			IF @searchByText IS NOT NULL AND @searchBy ='cAmt'
				SET @SQL =@SQL+ ' AND MAIN.cAmt = ' + @searchByText + ''
							
			IF @searchByText IS NOT NULL AND @searchBy ='pAmt'
				SET @SQL =@SQL+ ' AND MAIN.pAmt = ' + @searchByText + ''	

			IF @searchByText IS NOT NULL AND @searchBy ='extCustomerId'
				SET @SQL =@SQL+ ' AND TSEND.extCustomerId = ' + @searchByText + ''
									
			SET @SQL = @SQL + ' GROUP BY '+ @GroupCondition +''

	END	

	IF @FLAG = 'MAIN' AND @GROUPBY <>'DETAIL'
	BEGIN	
		SET @SQL = 'SELECT 	
			 '+@ReportTypeCond+' [groupBy]			
			,['+ @GroupSelect +'] ='+ @GroupCondition +'
			,COUNT(*) [Txn Count]
			,SUM('+@Amt+') [Txn Amount]			
			FROM vwremitTran MAIN WITH(NOLOCK)  
			LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
			LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
			LEFT JOIN agentMaster SAGENT WITH(NOLOCK) ON SAGENT.agentId=MAIN.sAgent
			LEFT JOIN agentMaster PAGENT WITH(NOLOCK) ON PAGENT.agentId=MAIN.pAgent
			LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
			LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
			LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
			LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
			WHERE  MAIN.'+ @DATECONDITION +' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +''''

			SET @SQL = @SQL + ' AND (SAGENT.BUSINESSTYPE = ''6204'' OR PAGENT.BUSINESSTYPE = ''6204'')'
			IF @SendingCountry IS NOT NULL
				SET @SQL = @SQL + ' AND MAIN.sCountry = ''' + @SendingCountry + ''''

			IF @SendingAgent IS NOT NULL
				SET @SQL = @SQL + ' AND sAgent = ''' + @SendingAgent + ''''
			
			IF @SendingBranch IS NOT NULL
				SET @SQL = @SQL + ' AND sBranch = '''+ @SendingBranch +''''
				
			IF @ReecivingAgent IS NOT NULL
				SET @SQL = @SQL + ' AND pAgent = ''' + @ReecivingAgent + ''''
			
			IF @ReceivingBranch IS NOT NULL
				SET @SQL = @SQL + 'AND  pBranch = '''+ @ReceivingBranch +''''			
				
			IF @status IS NOT NULL
				SET @SQL = @SQL + 'AND  tranStatus = '''+ @status +''''
				
			IF @sLocation IS NOT NULL
				SET @SQL = @SQL + 'AND  SBRANCH.agentLocation = '''+ @sLocation +''''
				
			IF @rLocation IS NOT NULL
				SET @SQL = @SQL + 'AND  pLocation = '''+ @rLocation +''''			
				
			IF @sZone IS NOT NULL
				SET @SQL = @SQL + 'AND  SBRANCH.agentState = '''+ @sZone +''''
				
			IF @rZone IS NOT NULL
				SET @SQL = @SQL + 'AND  PLOC.zoneName = '''+ @rZone +''''
			
			IF @sDistrict IS NOT NULL
				SET @SQL = @SQL + 'AND  SBRANCH.agentDistrict = '''+ @sDistrict +''''
				
			IF @rDistrict IS NOT NULL
				SET @SQL = @SQL + ' AND  PLOC.districtName = '''+ @rDistrict +''''
				
			IF @tranType IS NOT NULL
				SET @SQL = @SQL + ' AND  MAIN.paymentMethod = '''+ @tranType +''''
				
			IF @Id IS NOT NULL
				SET @SQL = @SQL + '  AND '+ @ReportTypeCond +' = '''+ @Id +''''		
				
			IF @searchByText IS NOT NULL AND @searchBy ='sender'
				SET @SQL =@SQL+ ' AND TSEND.firstName LIKE ''%' + @searchByText + '%'''
			
			IF @searchByText IS NOT NULL AND @searchBy ='receiver'
				SET @SQL =@SQL+ ' AND TREC.firstName LIKE ''%' + @searchByText + '%'''	
				
			IF @searchByText IS NOT NULL AND @searchBy ='cAmt'
				SET @SQL =@SQL+ ' AND MAIN.cAmt = ' + @searchByText + ''
							
			IF @searchByText IS NOT NULL AND @searchBy ='pAmt'
				SET @SQL =@SQL+ ' AND MAIN.pAmt = ' + @searchByText + ''	
				
			IF @searchByText IS NOT NULL AND @searchBy ='extCustomerId'
				SET @SQL =@SQL+ ' AND TSEND.extCustomerId = ' + @searchByText + ''		
							
			SET @SQL = @SQL + ' GROUP BY '+ @GroupCondition +','+@ReportTypeCond+'
			'

	END
END	
ELSE -- ### IF CONTROL NUMBER IS CHOOSEN
BEGIN
	IF @FLAG = 'MAIN'
	BEGIN		

			SET @SQL ='SELECT 
					 [Control No] =''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'/Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(main.id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
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
			FROM vwremitTran MAIN WITH(NOLOCK)  
			LEFT JOIN agentMaster SBRANCH WITH(NOLOCK) ON SBRANCH.agentId=MAIN.sBranch
			LEFT JOIN agentMaster PBRANCH WITH(NOLOCK) ON PBRANCH.agentId=MAIN.pBranch
			LEFT JOIN agentMaster SAGENT WITH(NOLOCK) ON SAGENT.agentId=MAIN.sAgent
			LEFT JOIN agentMaster PAGENT WITH(NOLOCK) ON PAGENT.agentId=MAIN.pAgent
			LEFT JOIN api_districtList SLOC WITH(NOLOCK) ON SLOC.districtCode=SBRANCH.agentLocation
			LEFT JOIN vwZoneDistrictLocation PLOC WITH(NOLOCK) ON PLOC.locationId=MAIN.pLocation
			LEFT JOIN vwtranSenders TSEND WITH(NOLOCK) ON MAIN.id=TSEND.tranId 
			LEFT JOIN vwtranReceivers TREC WITH(NOLOCK) ON MAIN.id=TREC.tranId
			WHERE MAIN.controlNo = '''+ dbo.FNAEncryptString(@controlNo) +''' AND (SAGENT.BUSINESSTYPE = ''6204'' OR PAGENT.BUSINESSTYPE = ''6204'')' 
		
	END
END

		
	IF OBJECT_ID('tempdb..##TEMP_TABLE') IS NOT NULL
	DROP TABLE ##TEMP_TABLE
	
	DECLARE @SQL2 AS VARCHAR(MAX)
	SET @SQL2='SELECT ROW_NUMBER() OVER (ORDER BY ['+@GroupSelect+']) AS [S.N.],* 
				INTO ##TEMP_TABLE
					FROM 
					(
						'+ @SQL +'
					) AS aa ORDER BY ['+@GroupSelect+'] '
	
	PRINT(@SQL)
	EXEC(@SQL2)
	
	SET @SQL1='
	SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ##TEMP_TABLE

	SELECT * FROM ##TEMP_TABLE  WHERE [S.N.] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+'
	'
	EXEC(@SQL1)
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'GROUP BY '  head ,@GroupSelect value
	UNION ALL
	SELECT 'DATE TYPE ' head,CASE WHEN @DATETYPE = 'S' THEN 'Sending Date' 
							WHEN @DATETYPE = 'P' THEN 'Paid Date' 
							WHEN @DATETYPE = 'C' THEN 'Cancel Date' END value
	UNION ALL
	SELECT 'FROM DATE ' head, CONVERT(VARCHAR, @fromDate, 101) value
	UNION ALL
	SELECT 'TO DATE ' head, CONVERT(VARCHAR, @toDate, 101) value
	UNION ALL
	SELECT 'TRAN STATUS ' head, ISNULL(@status,'All') value
	UNION ALL
	SELECT 'TRAN TYPE ' head, ISNULL(@tranType,'All') value
	UNION ALL
	SELECT 'SEARCH BY TEXT ' head, ISNULL(@searchByText,'All') value
	UNION ALL
	SELECT 'SEARCH BY ' head,CASE WHEN @searchByText IS NULL THEN 'N/A' ELSE @searchBy END value
	UNION ALL
	SELECT 'CONTROL NO ' head, ISNULL(@controlNo,'N/A') value
	UNION ALL
	SELECT 'SENDING COUNTRY' head,ISNULL(@SendingCountry,'All')
	UNION ALL
	SELECT 'SENDING ZONE ' head,isnull(@sZone,'All')
	UNION ALL
	SELECT 'SENDING DISTRICT ' head,isnull(@sDistrict,'All')
	UNION ALL
	SELECT 'SENDING LOCATION ' head,ISNULL((select districtName from api_districtList where districtCode=@sLocation),'All')
	UNION ALL
	SELECT 'SENDING AGENT ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @SendingAgent),'All')
	UNION ALL
	SELECT 'SENDING BRANCH ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @SendingBranch),'All')
	UNION ALL
	SELECT 'RECEIVING COUNTRY ' head,ISNULL(@ReceivingCountry,'All')
	UNION ALL
	SELECT 'RECEIVING ZONE ' head,isnull(@rZone,'All')
	UNION ALL
	SELECT 'RECEIVING DISTRICT ' head,isnull(@rDistrict,'All')
	UNION ALL
	SELECT 'RECEIVING LOCATION ' head,ISNULL((select districtName from api_districtList where districtCode=@rLocation),'All')
	UNION ALL
	SELECT 'RECEIVING AGENT ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @ReecivingAgent),'All')
	UNION ALL
	SELECT 'RECEIVING BRANCH ' head,ISNULL((SELECT agentName FROM agentMaster with(nolock) WHERE agentId = @ReceivingBranch),'All')

	SELECT 'TRANSACTION REPORT- (COOPERATIVE) ' title

GO
