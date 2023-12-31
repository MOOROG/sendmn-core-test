USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetOverseasTxnSummaryRpt]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_GetOverseasTxnSummaryRpt]
	@flag			VARCHAR(50),
	@user			VARCHAR(50)		= NULL,
	@sBranch		VARCHAR(10) 	= NULL,
	@sAgent			VARCHAR(10)		= NULL,
	@pCountry		VARCHAR(50)		= NULL,
	@pAgentId		VARCHAR(10)		= NULL,
	@status			VARCHAR(50)		= NULL,
	@DateType		VARCHAR(20)		= NULL,
	@fromDate		VARCHAR(10)		= NULL,
	@toDate			VARCHAR(10)		= NULL,
	@countryBankId	VARCHAR(10)		= NULL,
	@pageNumber		INT				= NULL,
	@pageSize		INT				= NULL
	
AS 
SET NOCOUNT ON;

	IF(DATEDIFF(D,@fromDate,GETDATE())>90 )
    BEGIN
    	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
    	EXEC proc_errorHandler '1', '<font color="red"><b>Date Rage is not valid, You can only view transaction upto 90 days.</b></font>', NULL
    	RETURN;
    END
		
	IF(DATEDIFF(D,@fromDate,@toDate))>32 
	BEGIN
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		EXEC proc_errorHandler '1', '<font color="red"><b>Date Rage is not valid, Please select date range of 32 days.</b></font>', NULL
		RETURN;
	END
	
	IF OBJECT_ID('tempdb..#listBranch') IS NOT NULL
		DROP TABLE #listBranch
	DECLARE @SQL VARCHAR(MAX),@userType varchar(2),@regionalBranchId INT,@branchId INT
	CREATE TABLE #listBranch (branchId INT,branchName VARCHAR(200))

	IF @userType IS NULL
		SELECT @userType=usertype,@regionalBranchId=agentId 
		FROM applicationUsers WITH(NOLOCK) WHERE userName=@user

	IF @userType = 'RH'
	BEGIN
		INSERT INTO #listBranch
		SELECT DISTINCT b.agentId branchId, b.agentName branchName
		FROM (		
			SELECT
				am.agentId 
				,am.agentName
			FROM agentMaster am WITH(NOLOCK)
			INNER JOIN regionalBranchAccessSetup rba WITH(NOLOCK) ON am.agentId = rba.memberAgentId
			WHERE rba.agentId = @regionalBranchId 
			AND ISNULL(rba.isDeleted, 'N') = 'N'
			AND ISNULL(rba.isActive, 'N') = 'Y'
			AND am.isInternal ='Y'
			AND am.agentType = '2904'
			UNION ALL
			SELECT agentId, agentName
			FROM agentMaster WITH(NOLOCK) WHERE agentId = @regionalBranchId
			
		) b  WHERE b.agentId=ISNULL(@sBranch,b.agentId)
		ORDER BY agentName ASC	
	END	
	ELSE IF @userType ='HO'
	BEGIN
		INSERT INTO #listBranch
		SELECT b.agentId branchId, b.agentName branchName 
		FROM agentMaster a WITH(NOLOCK)
		INNER JOIN agentMaster b WITH(NOLOCK) ON  b.parentId = a.agentId
		WHERE ISNULL(b.isDeleted, 'N') <> 'Y'
				AND b.agentType = '2904' 
				AND ISNULL(a.isActive, 'N') = 'Y'
				AND b.agentId = @sBranch
				--AND a.agentId = @sAgent
	END
	ELSE IF @userType ='AH'
	BEGIN
		INSERT INTO #listBranch
		SELECT DISTINCT A.agentId,A.agentName 
		FROM agentMaster A WITH(NOLOCK)
		INNER JOIN applicationUsers U WITH (NOLOCK) ON A.agentId = U.agentId
		WHERE parentId = (SELECT parentId FROM agentMaster B WITH (NOLOCK) 
						INNER JOIN applicationUsers AU WITH (NOLOCK) ON B.agentId=AU.agentId WHERE AU.userName = @user)
	END
	ELSE
	BEGIN
		INSERT INTO #listBranch
		SELECT agentId , agentName 
		FROM agentMaster a WITH(NOLOCK) WHERE agentId = @regionalBranchId
	END

IF @flag = 'Detail'
BEGIN
	create table #SettlementReport (remarks VARCHAR(100),qty INT,settAmount MONEY,collCurr VARCHAR(5),sn INT)	
	SET @SQL = '
	INSERT INTO #SettlementReport	
		SELECT ''Remittance Send(+)'' remarks
		,COUNT(*) QTY
		,SUM(camt) - SUM(ISNULL(sAgentComm,0))  - SUM(ISNULL(agentFxGain,0)) [settAmt]
		,collCurr	Currency
		,1 sn
		 FROM vwRemitTran Rt
		 INNER JOIN #listBranch T ON RT.sBranch=T.branchId
		 WHERE approvedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''
		 GROUP BY collCurr
		 UNION ALL
		 SELECT ''Remittance Paid(-)'' remarks
				
				,COUNT(*) QTY
				,[settAmt] = SUM(pamt) + SUM((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0)))*ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0))))  
				,payoutCurr	Currency
				, 2 sn
		 FROM vwRemitTran Rt
		 INNER JOIN #listBranch T ON RT.pBranch=T.branchId
		 WHERE paidDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''
		 GROUP BY payoutCurr
		  UNION ALL
		  SELECT ''Remittance Cancel(-)'' remarks
				
				,COUNT(*) QTY
				,[settAmt] = SUM(camt) - SUM(ISNULL(sAgentComm,0))  - SUM(ISNULL(agentFxGain,0))
				,collCurr	Currency
				, 3 sn
		 FROM vwRemitTran Rt
		 INNER JOIN #listBranch T ON RT.sBranch=T.branchId
		 WHERE cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''
		 GROUP BY collCurr
		 
		 '
					
PRINT @SQL
EXEC(@SQL)
DECLARE @CNT INT=2,@holdAmt MONEY,@process MONEY,@setCurr VARCHAR(5)
select @holdAmt=settAmount,@setCurr=COLLCURR  from #SettlementReport where SN=1
WHILE @CNT<=3
BEGIN
	select @process=settAmount  from #SettlementReport where sn=@CNT
	SET @holdAmt = @holdAmt -ISNULL(@process,0)
	SET @CNT = @CNT+1
END

SELECT Remarks,Qty,settAmount [Settlement Amount],COLLCURR [Settlement Curr] FROM (
SELECT remarks,QTY,settAmount,COLLCURR,SN FROM #SettlementReport 
UNION ALL
SELECT 'Net Settlement' ,0,@holdAmt,@setCurr,10
) X ORDER BY SN
	
	
	-->>SUMMARY REPORT
	SET @SQL ='SELECT 
					 [TRN Date]			= CAST(CAST(RT.createdDate AS DATE) AS VARCHAR) 
					,[Approved Date]	= CAST(CAST(RT.approvedDate AS DATE)AS VARCHAR) 
					,[Status]			= CASE WHEN CAST(RT.createdDate AS DATE)=CAST(RT.approvedDate AS DATE) THEN ''<b><span style="color:blue;"> Same Day Confirmed </span></b>'' WHEN CAST(RT.approvedDate AS DATE) IS NULL THEN ''<b><span style="color:red;">Not Confirmed </span></b>''  ELSE ''<b><span style="color:red;">Not Same Day Confirmed </span></b>'' END 
					,[No of Txn.]		= COUNT(*) 
					,[Collected Amt(LCY)]= SUM(cAmt) 
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE RT.'+@DateType+' BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
				
	IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''
					
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND pCountry='''+@pCountry+''''
	IF @pAgentId IS NOT NULL
		SET @SQL  = @SQL +' AND pAgent='''+@pAgentId+''''	
	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		SET @SQL = @SQL +' GROUP BY CAST(RT.createdDate AS DATE),CAST(RT.approvedDate AS DATE)'	
		
	PRINT @SQL
	EXEC(@SQL)

END	

IF @flag = 'BranchWise'
BEGIN
	
	SET @SQL =' SELECT	
				 [Agent]					= sAgentName 
				,[Branch]					= sBranchName 
				,[NOs]						 = COUNT(*) 
				,[Total <BR/>Collected(LCY)] = SUM(RT.cAmt)
				,[Agent <BR/>Comm(LCY)]		= ISNULL(SUM(RT.sAgentComm),0) 
				,[Total <BR/>SCharge(LCY)]	= SUM(RT.serviceCharge) 
				,[Total <BR/>Payable(LCY)]	= SUM(RT.tAmt) 
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE RT.'+@DateType+' BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
	
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''
		
	IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
		
	IF @pAgentId IS NOT NULL
		SET @SQL  = @SQL +' AND RT.pAgent='''+@pAgentId+''''	
	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND RT.payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		SET @SQL = @SQL +' GROUP BY RT.sAgentName,RT.sBranchName'	
		
	PRINT @SQL
	EXEC(@SQL)

	SET @SQL =' SELECT	[Agent]					= sAgentName 
				,[Branch]						= sBranchName 
				,[NOs]							= COUNT(*) 
				,[Total <BR/>Collected(LCY)]	= SUM(RT.cAmt)
				,[Agent <BR/>Comm(LCY)]			= ISNULL(SUM(RT.sAgentComm),0) 
				,[Total <BR/>SCharge(LCY)]		= SUM(RT.serviceCharge) 
				,[Total Cancel <BR/>To Agent(LCY)]= SUM(X.tAmt) 
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			LEFT JOIN 
			(
				SELECT SUM(tAmt) tAmt,sBranch FROM vwremitTran WITH (NOLOCK)
					WHERE sBranch = '''+@sBranch+''' AND payStatus=''Cancel''
					GROUP BY sBranch
			)X ON X.sBranch = RT.sBranch
			WHERE RT.cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''  AND RT.payStatus IN (''Cancel'')'
				
	IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
		
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''
		
	IF @pAgentId IS NOT NULL
		SET @SQL  = @SQL +' AND (RT.pAgent='''+@pAgentId+''' OR rt.pAgent IS NULL)'	
	
	SET @SQL = @SQL +' GROUP BY RT.sAgentName,RT.sBranchName'
		

	SET @SQL =@SQL+ '    UNION ALL 
				SELECT	sAgentName [Agent]
				,sBranchName [Branch]
				,COUNT(*) [NOs]
				,SUM(RT.cAmt)[Total <BR/>Collected(LCY)]
				,ISNULL(SUM(RT.sAgentComm),0) [Agent <BR/>Comm(LCY)]
				,SUM(RT.serviceCharge) [Total <BR/>SCharge(LCY)]
				,SUM(X.tAmt) [Total Cancel <BR/>To Agent(LCY)]
			FROM cancelTranHistory RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			LEFT JOIN 
			(
				SELECT SUM(tAmt) tAmt,sBranch FROM cancelTranHistory WITH (NOLOCK)
				WHERE sBranch = '''+@sBranch+''' AND payStatus=''Unpaid''
				AND cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''
				GROUP BY sBranch
			)X ON X.sBranch = RT.sBranch
			
			WHERE RT.cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''  AND RT.payStatus IN (''Unpaid'')'
				
	IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
			
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''
		
	IF @pAgentId IS NOT NULL
		SET @SQL  = @SQL +' AND (RT.pAgent='''+@pAgentId+''' OR rt.pAgent IS NULL)'	
	
		SET @SQL = @SQL +' GROUP BY RT.sAgentName,RT.sBranchName'	
		
	PRINT @SQL
	EXEC(@SQL)
END

IF @flag = 'ReceivingAgentCountryWise'
BEGIN

	SET @SQL = 'SELECT [Agent Name]= 
						''<a href="Reports.aspx?reportName=40112500txnsummaryrpt&pCountry=''+RT.pCountry+''&sAgent='+ @sAgent+'&sBranch='+ ISNULL(@sBranch,'') +'&dateType='+@DateType+'&fromDate='+@fromDate+'&toDate='+@toDate+'&rptType=ReceivingAgentWise&status='+ISNULL(@status,'')+'"> ''+RT.pCountry+'' </a>'' 
				,[Total <BR/>Send TRN]				= COUNT(*) 
				,[Total Collection <BR/>Amount(LCY)] = SUM(RT.cAmt)
				,[Total <BR/>SCharge(LCY)]			 = SUM(RT.serviceCharge) 
				,[Customer <BR/>Rec. Amount]		 = SUM(RT.pAmt)
				,[Rec.<br/> Curr]					 = RT.payoutCurr
				,[Total Payable <BR/>to Agent(LCY)]	 = ISNULL(SUM(RT.tAmt),0) 
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE RT.'+@DateType+' BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
	
      IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
			
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''

	IF @pAgentId IS NOT NULL
		SET @SQL  = @SQL +' AND RT.pAgent='''+@pAgentId+''''	

	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND RT.payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		SET @SQL = @SQL +' GROUP BY RT.pCountry,RT.payoutCurr'	
		
	PRINT @SQL
	EXEC(@SQL)
END

IF @flag = 'ReceivingAgentWise'
BEGIN
	SET @SQL = 'SELECT [Country Name]= 
						''<a href="Reports.aspx?reportName=40112500txnsummaryrpt&pCountry=''+RT.pCountry+''&sBranch='+ ISNULL(@sBranch,'') +'&dateType='+@DateType+'&fromDate='+@fromDate+'&toDate='+@toDate+'&rptType=ReceivingAgentDetail&pAgent=''+CAST(ISNULL(pAgent,'''') AS VARCHAR)+''&status='+ISNULL(@status,'')+'"> ''+ISNULL(RT.pAgentName,''Anywhere'')+''-''+RT.pCountry+'' </a>'' 
				,[Total <BR/>Send TRN]				= COUNT(*) 
				,[Total Collection <BR/>Amount(LCY)] = SUM(RT.cAmt)
				,[Total <BR/>SCharge(LCY)]			 = SUM(RT.serviceCharge) 
				,[Customer <BR/>Rec. Amount]		 = SUM(RT.pAmt)
				,[Rec.<br/> Curr]					 = RT.payoutCurr
				,[Total Payable <BR/>to Agent(LCY)]	 = ISNULL(SUM(RT.tAmt),0) 
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE RT.'+@DateType+' BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''

	IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
			
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''

	IF @pAgentId IS NOT NULL
		SET @SQL  = @SQL +' AND RT.pAgent='''+@pAgentId+''''	
	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND RT.payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		SET @SQL = @SQL +' GROUP BY pAgentName,pAgent,RT.pCountry,RT.payoutCurr  ORDER BY RT.pCountry'	
		
	PRINT @SQL
	EXEC(@SQL)
END

IF @flag = 'ReceivingAgentDetail'
BEGIN

	SET @SQL = 'SELECT 
						 [TRN Date]					= ''<a href="Reports.aspx?reportName=40112500txnsummaryrpt&pCountry='+@pCountry+'&dateType='+@DateType+'&fromDate=''+CAST(CAST(RT.createdDate AS DATE) AS VARCHAR)+''&toDate=''+CAST(CAST(RT.createdDate AS DATE) AS VARCHAR)+''&rptType=ReceivingDateWise&sBranch='+ ISNULL(@sBranch,'') +'&pAgent=''+CAST(ISNULL(pAgent,0) AS VARCHAR)+''&status='+ISNULL(@status,'')+'"> ''+CAST(CAST(RT.createdDate AS DATE) AS VARCHAR)+'' </a>'' 
						,[Agent Name]				= ISNULL(RT.pAgentName,''Anywhere-''+'''+@pCountry+''') 
						,[Total <BR/>Send TRN]		= COUNT(*) 
						,[Total Collection <BR/>Amount(LCY)] = SUM(RT.cAmt)
						,[Total <BR/>SCharge(LCY)]	= SUM(RT.serviceCharge) 
						,[Agent <BR/>Comm(LCY)]		= ISNULL(SUM(RT.sAgentComm),0) 
						,[Customer Rate]			= RT.customerRate 
						,[Customer <BR/>Rec. Amount]		= SUM(RT.pAmt)
						,[Rec.<br/> Curr]					= RT.payoutCurr
						,[Total Payable <BR/>to Agent(LCY)] = ISNULL(SUM(RT.tAmt),0) 
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE RT.'+@DateType+' BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
	
  

	IF @sAgent IS NOT NULL AND @sAgent > 0
		SET @SQL = @SQL +' AND RT.sAgent = '''+ @sAgent+''''
	
	
     IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
		

	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''

     
	IF @pAgentId IS NOT NULL AND @pAgentId > 0
		SET @SQL  = @SQL +' AND RT.pAgent='''+@pAgentId+''''	

	 
	IF @pAgentId =0
		SET @SQL  = @SQL +' AND RT.pAgent IS NULL'	
     

	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND RT.payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		SET @SQL = @SQL +' GROUP BY pAgentName,CAST(CAST(RT.createdDate AS DATE) AS VARCHAR),RT.customerRate
							,RT.pAgent,RT.payoutCurr'	
	
     	
	
	EXEC(@SQL)
	
	--Cancel datewise trn
	
	SET @SQL = 'SELECT	[TRN Date(CancelDate)]				= CAST(CAST(RT.cancelApprovedDate AS DATE) AS VARCHAR) 
						,[Agent Name]						= RT.pAgentName					
						,[Total <BR/>Cancel TRN]			= COUNT(*)						
						,[Total Collection <BR/>Amount(LCY)] = SUM(RT.cAmt)					
						,[Total <BR/>SCharge(LCY)]			= SUM(RT.serviceCharge)			
						,[Agent <BR/>Comm(LCY)]				= ISNULL(SUM(RT.sAgentComm),0)	
						,[ExRate]							= RT.customerRate				
						,[Customer <BR/>Rec. Amount]		= SUM(RT.pAmt)		
						,[Rec.<br/> Curr]					= RT.payoutCurr			
						,[Total Cancel <BR/>to Agent]		= ISNULL(SUM(X.tAmt),0) 
			FROM vwremitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			LEFT JOIN (
				SELECT ISNULL(SUM(tAmt),0) tAmt,sBranch FROM vwremitTran WITH (NOLOCK)
					WHERE payStatus=''Cancel'' 
					GROUP BY sBranch
				)X ON X.sBranch = RT.sBranch
			WHERE 
				RT.cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''  AND RT.payStatus IN (''Cancel'')'
	
	IF @sAgent IS NOT NULL AND @sAgent > 0
		SET @SQL = @SQL +' AND RT.sAgent = '''+@sAgent+''''

    IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
		

	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''
	IF @pAgentId IS NOT NULL AND @pAgentId > 0
		SET @SQL  = @SQL +' AND (RT.pAgent='''+@pAgentId+''' OR RT.pAgent IS NULL)'	
	
	IF @pAgentId =0
		SET @SQL  = @SQL +' AND RT.pAgent IS NULL'	
		
	SET @SQL = @SQL +' GROUP BY pAgentName,CAST(RT.cancelApprovedDate AS DATE),RT.customerRate
						,RT.payoutCurr'	
	
	-------------------------------------------------------
		
		SET @SQL =@SQL+ '   UNION ALL 
					 SELECT	[TRN Date(CancelDate)]				= CAST(CAST(RT.cancelApprovedDate AS DATE) AS VARCHAR) 
						,[Agent Name]						= ISNULL(RT.pAgentName,''Anywhere-''+rt.pcountry)				
						,[Total <BR/>Cancel TRN]			= COUNT(*)						
						,[Total Collection <BR/>Amount(LCY)] = SUM(RT.cAmt)					
						,[Total <BR/>SCharge(LCY)]			= SUM(RT.serviceCharge)			
						,[Agent <BR/>Comm(LCY)]				= ISNULL(SUM(RT.sAgentComm),0)	
						,[ExRate]							= RT.customerRate				
						,[Customer <BR/>Rec. Amount]		= SUM(RT.pAmt)		
						,[Rec.<br/> Curr]					= RT.payoutCurr			
						,[Total Cancel <BR/>to Agent]		= ISNULL(SUM(X.tAmt),0) 
			FROM cancelTranHistory RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			LEFT JOIN (
				SELECT ISNULL(SUM(tAmt),0) tAmt,sBranch FROM cancelTranHistory WITH (NOLOCK)
					WHERE payStatus=''Unpaid''
					AND cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'' 
					GROUP BY sBranch
				)X ON X.sBranch = RT.sBranch
			WHERE RT.cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59''  AND RT.payStatus IN (''Unpaid'')'
	
	IF @sAgent IS NOT NULL AND @sAgent > 0
		SET @SQL = @SQL +' AND RT.sAgent = '''+@sAgent+''''

     IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''	
		

	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''
				
	IF @pAgentId IS NOT NULL AND @pAgentId > 0
		SET @SQL  = @SQL +' AND (RT.pAgent='''+@pAgentId+''' OR RT.pAgent IS NULL)'	
	IF @pAgentId =0
		SET @SQL  = @SQL +' AND RT.pAgent IS NULL'	
		
	SET @SQL = @SQL +' GROUP BY pAgentName,CAST(RT.cancelApprovedDate AS DATE),RT.customerRate,rt.pcountry
						,RT.payoutCurr'
		
	--PRINT @SQL
	EXEC(@SQL)
	
END
	
IF @flag = 'ReceivingDateWise'	
BEGIN

	SET @SQL =' 
		SELECT 
			 [ICN]								= DBO.FNADecryptstring(RT.controlNo)
			,[Sender Name]						= RT.senderName
			,[Receiver Name]					= RT.receiverName
			,[Tran Status]						= CASE WHEN RT.tranStatus=''Payment'' THEN ''Unpaid'' ELSE RT.tranStatus END 
			,[DOT/Paid Date]					= CONVERT(VARCHAR,RT.createdDate,101)+ISNULL(''/''+CONVERT(VARCHAR,RT.paidDate,101),'''')
			,[ExRate]							= RT.customerRate 
			,[Total Collection <BR/>Amount(LCY)] = CAST(RT.cAmt AS VARCHAR) 
			,[Total Sent <BR/>Amount(LCY)]		= CAST(RT.tAmt AS VARCHAR) 
			,[Charge<BR/>(MYR)]						= CAST(RT.serviceCharge AS VARCHAR) 
			,[Customer <BR/>Rec. Amount]		= CAST(RT.pAmt AS VARCHAR)
			,[Rec.<br/> Curr]					= RT.payoutCurr			
			,[User Name]						= RT.createdBy 
		FROM vwremitTran RT WITH (NOLOCK)
		INNER JOIN #listBranch T ON RT.sBranch=T.branchId
		WHERE  RT.'+@DateType+' BETWEEN '''+@fromDate+''' AND '''+@fromDate+' 23:59:59'''
	
	
     IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''

	IF @pAgentId = 0
		SET @SQL = @SQL +' AND RT.pAgent IS NULL'
				
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''

	IF @pAgentId IS NOT NULL AND @pAgentId > 0
		SET @SQL  = @SQL +' AND RT.pAgent='''+@pAgentId+''''	

	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND RT.payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		
	PRINT @SQL
	EXEC(@SQL)
END

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
SELECT 'Beneficiary' head,isnull(@pCountry,'All') VALUE 
UNION ALL
SELECT 'Sending Agent' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentid=@sAgent),'ALL') VALUE
UNION ALL
SELECT 'Sending Branch' head,(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentid=@sBranch) VALUE
UNION ALL
SELECT 'Date Type ' head, CASE WHEN @DateType='createdDate' THEN 'By TRN Date'
										WHEN @DateType='approvedDate' THEN 'By Confirm Date'
										WHEN @DateType='PaidDate' THEN 'By Paid Date' END value
UNION ALL
SELECT 'From Date' head,@fromDate value
UNION ALL
SELECT 'To Date' head,	@toDate

SELECT 'Transaction Summary Report : '+@flag title



GO
