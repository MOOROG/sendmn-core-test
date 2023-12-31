USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetRSPTxnSummaryReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[proc_GetRSPTxnSummaryReport]
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
    	EXEC proc_errorHandler '1', '<font color="red"><b>Date Range is not valid, You can only view transaction upto 90 days.</b></font>', NULL
    	RETURN;
    END
		
	IF(DATEDIFF(D,@fromDate,@toDate))>32 
	BEGIN
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		EXEC proc_errorHandler '1', '<font color="red"><b>Date Range is not valid, Please select date range of 32 days.</b></font>', NULL
		RETURN;
	END

	IF OBJECT_ID('tempdb..#listBranch') IS NOT NULL
		DROP TABLE #listBranch
	DECLARE @SQL VARCHAR(MAX),@userType varchar(2),@regionalBranchId INT,@branchId INT
	CREATE TABLE #listBranch (branchId INT,branchName VARCHAR(200))

	IF @userType IS NULL
		SELECT @userType = usertype,@regionalBranchId = agentId 
		FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
	
	INSERT INTO #listBranch
	select agentId,agentName from agentmaster(nolock) where agentid = @regionalBranchId

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
		 AND Rt.pCountry='''+@pCountry+'''
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
		 AND Rt.pCountry='''+@pCountry+'''
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
		 AND Rt.pCountry='''+@pCountry+'''
		 GROUP BY collCurr
		 
		 '
					
--PRINT @SQL
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
					,[Status]			= CASE WHEN CAST(RT.createdDate AS DATE)=CAST(RT.approvedDate AS DATE) THEN ''<b><span style="color:blue;"> Same Day Confirmed </span></b>'' WHEN CAST(RT.approvedDate AS DATE) IS NULL THEN ''<b><span style="color:red;">Not Confirmed </spa
n></b>''  ELSE ''<b><span style="color:red;">Not Same Day Confirmed </span></b>'' END 
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
	
	-- total cancel to agent
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
	--IF @status IS NOT NULL
	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND RT.payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		SET @SQL = @SQL +' GROUP BY RT.sAgentName,RT.sBranchName'	
		
	PRINT @SQL
	EXEC(@SQL)

	-- total cancel to agent
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
		
		
	----------------------
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
						''<a href="Reports.aspx?reportName=rsptxnsummaryrpt&beneficiary=''+RT.pCountry+''&agentName='+ 
	ISNULL(@pAgentId,'')+'&branch='+ ISNULL(@sBranch,'') +'&date='+@DateType+'&from='+@fromDate+'&to='+@toDate+
	'&rType=ReceivingAgentWise&status='+ISNULL(@status,'')+'"> ''+RT.pCountry+'' </a>'' 
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

	--IF @status IS NOT NULL
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
						''<a href="Reports.aspx?reportName=rsptxnsummaryrpt&beneficiary=''+RT.pCountry+''&branch='+
	 ISNULL(@sBranch,'') +'&date='+@DateType+'&from='+@fromDate+'&to='+@toDate+'&rType=ReceivingAgentDetail&agentName=''+CAST(ISNULL(pAgent,'''') AS VARCHAR)+''&status='+ISNULL(@status,'')
	 +'"> ''+ISNULL(RT.pAgentName,''Anywhere'')+''-''+RT.pCountry+'' </a>'' 
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

	--IF @status IS NOT NULL
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
						 [TRN Date]					= ''<a href="Reports.aspx?reportName=rsptxnsummaryrpt&beneficiary='+@pCountry+
'&date='+@DateType+'&from=''+CAST(CAST(RT.createdDate AS DATE) AS VARCHAR)+''&to=''+CAST(CAST(RT.createdDate AS DATE) AS VARCHAR)+''&rType=ReceivingDateWise&branch='+ 
ISNULL(@sBranch,'') +'&sAgent=''+CAST(ISNULL(pAgent,0) AS VARCHAR)+''&agentName='+ISNULL(@pAgentId,'')+'&status='+ISNULL(@status,'')+'"> ''+CAST(CAST(RT.createdDate AS DATE) AS VARCHAR)+'' </a>'' 
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
	--IF @status IS NOT NULL
     

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
	
	IF @sAgent IS NOT NULL AND @sAgent > 0
		SET @SQL = @SQL +' AND RT.pAgent = '''+@sAgent+''''
	
     IF @sBranch IS NOT NULL
		SET @SQL  = @SQL +' AND RT.sBranch='''+@sBranch+''''

	IF @pAgentId = 0
		SET @SQL = @SQL +' AND RT.pAgent IS NULL'
				
	IF @pCountry <>'all'
		SET @SQL  = @SQL +' AND RT.pCountry='''+@pCountry+''''

	IF @pAgentId IS NOT NULL AND @pAgentId > 0
		SET @SQL  = @SQL +' AND RT.pAgent='''+@pAgentId+''''	
	--IF @status IS NOT NULL
	IF @status IS NOT NULL
		SET @SQL = @SQL +' AND RT.payStatus IN ('''+@status+''')'
	ELSE
		SET @SQL = @SQL +' AND RT.payStatus IN (''Unpaid'',''Paid'',''Post'')'
		
	PRINT @SQL
	EXEC(@SQL)
END


IF @flag = 'SettlementReport'
BEGIN

	IF OBJECT_ID('tempdb..#TempResult') IS NOT NULL
		DROP TABLE  #TempResult
	CREATE TABLE #TempResult(SN INT,[Date] Date,Remarks VARCHAR(100),Qty INT,[Collection Amt] MONEY ,[Total Charge] MONEY
			,PayoutAmt MONEY,[Agt Comm] MONEY ,margin MONEY,[Sett. Amount] MONEY,Currency VARCHAR(5))
	
	SET @SQL = '
			INSERT INTO #TempResult
			SELECT SN
				,CONVERT(VARCHAR,Date,101) Date
				,Remarks
				,CASE WHEN Remarks=''Remittance Send(+)'' then Qty ELSE Qty*-1 END  Qty
				,cAmt [Collection Amt]
				,serviceCharge [Total Charge]
				,PayoutAmt
				,sAgentComm [Agt Comm]
				,ISNULL(margin,0) margin
				,CASE WHEN Remarks=''Remittance Send(+)'' then (cAmt-sAgentComm-ISNULL(margin,0)) ELSE (cAmt-sAgentComm-ISNULL(margin,0))*-1 END [Sett. Amount]
				,collCurr
			 FROM(
			SELECT  1 SN,X.Date,remarks,COUNT(*) qty,SUM(X.cAmt) cAmt,SUM(X.serviceCharge) serviceCharge,SUM(X.[PayoutAmt]) [PayoutAmt]
			,SUM(X.sAgentComm) sAgentComm
			,(SUM(settleAmt)-SUM(payAmt))/SUM([agentSettelRate]) [Ex.Gain]
			,SUM(X.cAmt)-SUM(X.sAgentComm) [Sett. Amount]
			,SUM(margin) margin
			,collCurr
			 FROM (
			SELECT CAST(createdDate AS DATE) [Date],''Remittance Send(+)'' remarks,(cAmt) cAmt,serviceCharge,
				(cAmt-serviceCharge) [PayoutAmt],sAgentComm 
				,agentCrossSettRate [agentSettelRate]
				,(agentCrossSettRate*tAmt) settleAmt
				,(customerRate*tAmt) payAmt
				,((agentCrossSettRate*tAmt)-(customerRate*tAmt))/agentCrossSettRate [margin]
				,collCurr
			FROM VWRemitTran RT
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
		IF @sBranch IS NOT NULL
			SET @SQL  = @SQL +' AND sBranch='''+@sBranch+''''
		IF @pCountry <>'all'
			SET @SQL  = @SQL +' AND pCountry='''+@pCountry+''''
		IF @pAgentId IS NOT NULL
			SET @SQL  = @SQL +' AND pAgent='''+@pAgentId+''''	
		SET @SQL =@SQL + ' 
			)X
			GROUP BY X.Date,remarks,collCurr
			UNION ALL
			SELECT 2,X.Date,remarks,COUNT(*) qty,SUM(X.cAmt) cAmt,SUM(X.serviceCharge) serviceCharge,SUM(X.[PayoutAmt]) [PayoutAmt],SUM(X.sAgentComm) sAgentComm
			,(SUM(settleAmt)-SUM(payAmt))/SUM([agentSettelRate]) [Ex.Gain]
			,SUM(X.cAmt)-SUM(X.sAgentComm) [Sett. Amount]
			,SUM(margin) margin
			,payoutCurr
			 FROM (
			SELECT CAST(paidDate AS DATE) [Date],''Remittance Paid(-)'' remarks,(cAmt) cAmt,serviceCharge,
				(cAmt-serviceCharge) [PayoutAmt],sAgentComm 
				,agentCrossSettRate [agentSettelRate]
				,(agentCrossSettRate*tAmt) settleAmt
				,(customerRate*tAmt) payAmt
				,((agentCrossSettRate*tAmt)-(customerRate*tAmt))/agentCrossSettRate [margin]
				,payoutCurr
			FROM RemitTran rt WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.pBranch=T.branchId
			WHERE paidDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
		IF @sBranch IS NOT NULL
			SET @SQL  = @SQL +' AND pBranch='''+@sBranch+''''
		IF @pCountry <>'all'
			SET @SQL  = @SQL +' AND sCountry='''+@pCountry+''''
		IF @pAgentId IS NOT NULL
			SET @SQL  = @SQL +' AND sAgent='''+@pAgentId+''''	
		SET @SQL =@SQL + ' 
			)X
			GROUP BY X.Date,remarks,payoutCurr
			UNION ALL
			
			SELECT 3,X.Date,remarks,COUNT(*) qty,SUM(X.cAmt) cAmt,SUM(X.serviceCharge) serviceCharge,SUM(X.[PayoutAmt]) [PayoutAmt],SUM(X.sAgentComm) sAgentComm
			,(SUM(settleAmt)-SUM(payAmt))/SUM([agentSettelRate]) [Ex.Gain]
			,SUM(X.cAmt)-SUM(X.sAgentComm) [Sett. Amount]
			,SUM(margin) margin
			,collCurr
			 FROM (
			SELECT CAST(cancelApprovedDate AS DATE) [Date],''Remittance Cancel(-)'' remarks,(cAmt) cAmt,serviceCharge,
				(cAmt-serviceCharge) [PayoutAmt],sAgentComm 
				,agentCrossSettRate [agentSettelRate]
				,(agentCrossSettRate*tAmt) settleAmt
				,(customerRate*tAmt) payAmt
				,ISNULL(((agentCrossSettRate*tAmt)-(customerRate*tAmt))/agentCrossSettRate,0) [margin]
				,collCurr
			FROM RemitTran rt  WITH (NOLOCK) 
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
		IF @sBranch IS NOT NULL
			SET @SQL  = @SQL +' AND sBranch='''+@sBranch+''''
		IF @pCountry <>'all'
			SET @SQL  = @SQL +' AND pCountry='''+@pCountry+''''
		IF @pAgentId IS NOT NULL
			SET @SQL  = @SQL +' AND pAgent='''+@pAgentId+''''	
		SET @SQL =@SQL + ' 
			)X
			GROUP BY X.Date,remarks,collCurr
			) Y '	
			
		
	PRINT @SQL
	EXEC(@SQL)
	
	
	SELECT ROW_NUMBER() over (ORDER BY SN) SN, Date,Remarks,Qty,[Collection Amt],[Total Charge],PayoutAmt,[Agt Comm],margin,[Sett. Amount],Currency
	 FROM #TempResult ORDER BY SN 
	
	SELECT Remarks = CASE WHEN Remarks='Remittance Send(+)' THEN
		'<a href="Reports.aspx?reportName=rsptxnsummaryrpt&beneficiary='+ISNULL(@pCountry,'')+'&agentName='+ISNULL(@pAgentId,'')+'&branch='+ISNULL(@sBranch,'')+'&date='+@DateType+'&from='+@fromDate+'&to='+@toDate+'&rType=SettlementReport_Send&status='+ISNULL(@status,'')+'"> '+REMARKS+' </a>'
			WHEN Remarks='Remittance Paid(-)' THEN
		'<a href="Reports.aspx?reportName=rsptxnsummaryrpt&beneficiary='+ISNULL(@pCountry,'')+'&agentName='+ISNULL(@pAgentId,'')+'&branch='+ISNULL(@sBranch,'')+'&date='+@DateType+'&from='+@fromDate+'&to='+@toDate+'&rType=SettlementReport_Paid&status='+ISNULL(@status,'')+'"> '+REMARKS+' </a>'
			WHEN Remarks='Remittance Cancel(-)' THEN
		'<a href="Reports.aspx?reportName=rsptxnsummaryrpt&beneficiary='+ISNULL(@pCountry,'')+'&agentName='+ISNULL(@pAgentId,'')+'&branch='+ISNULL(@sBranch,'')+'&date='+@DateType+'&from='+@fromDate+'&to='+@toDate+'&rType=SettlementReport_Cancel&status='+ISNULL(@status,'')+'"> '+REMARKS+' </a>'
			END
		,X.Nos,[Sett. Amount],Currency FROM (
		SELECT SN,Remarks,SUM(Qty) Nos,SUM([Sett. Amount]) [Sett. Amount],Currency FROM #TempResult 
		GROUP BY Remarks,Currency,SN
	) X ORDER BY SN

END

IF @flag='SettlementReport_Send'
BEGIN

	SET @SQL = 'SELECT ROW_NUMBER() OVER (ORDER BY Date) SN
					,Date Date
					, ''Remittance Send(+)'' Remarks
					,cAmt [Collection Amt]
					,serviceCharge [Total Charge]
					,PayoutAmt
					,sAgentComm [Agt Comm]
					,ROUND(ISNULL(margin,0),4) margin
					,(cAmt-sAgentComm-ISNULL(margin,0)) [Sett. Amount]
			 FROM(
			SELECT  X.Date,(X.cAmt) cAmt,(X.serviceCharge) serviceCharge,(X.[PayoutAmt]) [PayoutAmt]
			,(X.sAgentComm) sAgentComm
			,((settleAmt)-(payAmt))/([agentSettelRate]) [Ex.Gain]
			,(X.cAmt)-(X.sAgentComm) [Sett. Amount]
			,(margin) margin
			 FROM (
			SELECT createdDate  [Date],(cAmt) cAmt,serviceCharge,
				(cAmt-serviceCharge) [PayoutAmt],sAgentComm 
				,agentCrossSettRate [agentSettelRate]
				,(agentCrossSettRate*tAmt) settleAmt
				,(customerRate*tAmt) payAmt
				,ISNULL(((agentCrossSettRate*tAmt)-(customerRate*tAmt))/agentCrossSettRate,0) [margin]
			FROM VWRemitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE createdDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
		IF @sBranch IS NOT NULL
			SET @SQL  = @SQL +' AND sBranch='''+@sBranch+''''
		IF @pCountry <>'all'
			SET @SQL  = @SQL +' AND pCountry='''+@pCountry+''''
		IF @pAgentId IS NOT NULL
			SET @SQL  = @SQL +' AND pAgent='''+@pAgentId+''''
			
		SET @SQL  = @SQL +' ) X
		) Y ' 
			
	PRINT 	@SQL
	EXEC(@SQL)
END
IF @flag='SettlementReport_Cancel'
BEGIN

	SET @SQL = 'SELECT ROW_NUMBER() OVER (ORDER BY Date) SN
					,Date Date
					, ''Remittance Cancel(+)'' Remarks
					,cAmt [Collection Amt]
					,serviceCharge [Total Charge]
					,PayoutAmt,sAgentComm [Agt Comm]
					,ROUND(ISNULL(margin,0),4) margin
					,(cAmt-sAgentComm-ISNULL(margin,0)) [Sett. Amount]
			 FROM(
			SELECT  X.Date,(X.cAmt) cAmt,(X.serviceCharge) serviceCharge,(X.[PayoutAmt]) [PayoutAmt]
			,(X.sAgentComm) sAgentComm
			,((settleAmt)-(payAmt))/([agentSettelRate]) [Ex.Gain]
			,(X.cAmt)-(X.sAgentComm) [Sett. Amount]
			,(margin) margin
			 FROM (
			SELECT createdDate  [Date],(cAmt) cAmt,serviceCharge,
				(cAmt-serviceCharge) [PayoutAmt],sAgentComm 
				,agentCrossSettRate [agentSettelRate]
				,(agentCrossSettRate*tAmt) settleAmt
				,(customerRate*tAmt) payAmt
				,ISNULL(((agentCrossSettRate*tAmt)-(customerRate*tAmt))/agentCrossSettRate,0) [margin]
			FROM RemitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE cancelApprovedDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
		IF @sBranch IS NOT NULL
			SET @SQL  = @SQL +' AND sBranch='''+@sBranch+''''
		IF @pCountry <>'all'
			SET @SQL  = @SQL +' AND pCountry='''+@pCountry+''''
		IF @pAgentId IS NOT NULL
			SET @SQL  = @SQL +' AND pAgent='''+@pAgentId+''''
			
		SET @SQL  = @SQL +' ) X
		) Y ' 
			
	PRINT 	@SQL
	EXEC(@SQL)
END

IF @flag='SettlementReport_Paid'
BEGIN

	SET @SQL = 'SELECT ROW_NUMBER() OVER (ORDER BY Date) SN
					,Date Date
					, ''Remittance Paid(+)'' Remarks
					,cAmt [Collection Amt]
					,serviceCharge [Total Charge]
					,PayoutAmt,sAgentComm [Agt Comm]
					,ROUND(ISNULL(margin,0),4) margin
					,(cAmt-sAgentComm-ISNULL(margin,0)) [Sett. Amount]
			 FROM(
			SELECT  X.Date,(X.cAmt) cAmt,(X.serviceCharge) serviceCharge,(X.[PayoutAmt]) [PayoutAmt]
			,(X.sAgentComm) sAgentComm
			,((settleAmt)-(payAmt))/([agentSettelRate]) [Ex.Gain]
			,(X.cAmt)-(X.sAgentComm) [Sett. Amount]
			,(margin) margin
			 FROM (
			SELECT createdDate  [Date],(cAmt) cAmt,serviceCharge,
				(cAmt-serviceCharge) [PayoutAmt],sAgentComm 
				,agentCrossSettRate [agentSettelRate]
				,(agentCrossSettRate*tAmt) settleAmt
				,(customerRate*tAmt) payAmt
				,ISNULL(((agentCrossSettRate*tAmt)-(customerRate*tAmt))/agentCrossSettRate,0) [margin]
			FROM RemitTran RT WITH (NOLOCK)
			INNER JOIN #listBranch T ON RT.sBranch=T.branchId
			WHERE paidDate BETWEEN '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''
		IF @sBranch IS NOT NULL
			SET @SQL  = @SQL +' AND sBranch='''+@sBranch+''''
		IF @pCountry <>'all'
			SET @SQL  = @SQL +' AND pCountry='''+@pCountry+''''
		IF @pAgentId IS NOT NULL
			SET @SQL  = @SQL +' AND pAgent='''+@pAgentId+''''
			
		SET @SQL  = @SQL +' ) X
		) Y ' 
			
	PRINT 	@SQL
	EXEC(@SQL)
END

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL


SELECT 'Branch' head,(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentid=@sBranch) VALUE
UNION ALL
SELECT 'Beneficiary' head,isnull(@pCountry,'All') VALUE 
UNION ALL
SELECT 'Agent' head,ISNULL((SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentid=ISNULL(@pAgentId,@sAgent)),'ALL') VALUE
UNION ALL
SELECT 'Transaction Report ' head, CASE WHEN @DateType='createdDate' THEN 'By TRN Date'
										WHEN @DateType='approvedDate' THEN 'By Confirm Date'
										WHEN @DateType='PaidDate' THEN 'By Paid Date' END value
UNION ALL
SELECT 'From Date' head,@fromDate value
UNION ALL
SELECT 'To Date' head,	@toDate


SELECT 'Transaction Summary Report : '+@flag title

GO
