USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_domesticTransactionReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_domesticTransactionReport]
          @user			VARCHAR(30),
          @fromDate		VARCHAR(50), 
          @toDate		VARCHAR(50),
          @flag			Varchar(50),
          @agent        VARCHAR(10) = NULL,
          @rptType		CHAR(1) = NULL,
          @dateType		CHAR(1) = NULL
	        
AS
SET NOCOUNT ON  
SET @toDate = @toDate +' 23:59:59'

DECLARE @sql varchar(MAX),@rptDateType varchar(MAX)

IF @flag = 'TXNR'  -- TRANSACTION REPORT
BEGIN

	SET @rptDateType = CASE WHEN @dateType = 'S' THEN 'rt.createdDate' 
					WHEN @dateType = 'P' THEN 'rt.paidDate'
					WHEN @dateType = 'C' THEN 'rt.cancelApprovedDate'
					END

IF @rptType = 'D'
	BEGIN
	SET @sql ='SELECT
		[Date] = CONVERT(VARCHAR,'+@rptDateType+' ,101)
		,[Txn Count] = ''<a href = "Reports.aspx?reportName=domtxndetail&reportType='+@rptType+'&dateType='+@dateType+'&fromDate=''+CONVERT(VARCHAR,'+@rptDateType+' ,101)+''&toDate=''+CONVERT(VARCHAR,'+@rptDateType+' ,101)+''">''+cast(count(*)as varchar)+''</a>''
		,[Txn Amount] =SUM(tAmt)
		FROM remitTran rt  WITH(NOLOCK)
		WHERE '+@rptDateType+' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +'''
		AND rt.tranType =''D''
		GROUP BY CONVERT(VARCHAR,'+@rptDateType+' ,101)'
	END
	
	IF @rptType = 'S'
	BEGIN
	SET @sql ='SELECT
		[Sending Agent] = am.agentName
		,[Txn Count] = ''<a href = "Reports.aspx?reportName=domtxndetail&reportType='+@rptType+'&dateType='+@dateType+'&fromDate='+@fromDate+'&toDate='+LEFT(@toDate ,10)+'&agent=''+cast(rt.sAgent as varchar)+''">''+cast(count(*)as varchar)+''</a>''
		,[Txn Amount] =SUM(tAmt)
		FROM remitTran rt  WITH(NOLOCK)
		LEFT JOIN agentMaster am WITH(NOLOCK) ON AM.agentId = rt.sAgent
		WHERE '+@rptDateType+' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +'''
		AND rt.tranType =''D''
		GROUP BY rt.sAgent, am.agentName'
	END
	
	IF @rptType = 'R'
	BEGIN
	SET @sql ='SELECT
		 [Reciving Agent] = am.agentName
		,[Txn Count] = ''<a href = "Reports.aspx?reportName=domtxndetail&reportType='+@rptType+'&dateType='+@dateType+'&fromDate='+@fromDate+'&toDate='+LEFT(@toDate ,10)+'&agent=''+cast(rt.pAgent as varchar)+''">''+cast(count(*)as varchar)+''</a>''
		,[Txn Amount] =SUM(tAmt)
		FROM remitTran rt  WITH(NOLOCK)
		LEFT JOIN agentMaster am WITH(NOLOCK) ON AM.agentId = rt.pAgent
		WHERE '+@rptDateType+' BETWEEN '''+ @FROMDATE +''' AND '''+ @TODATE +'''
		AND rt.tranType =''D''
		GROUP BY rt.pAgent, am.agentName'
	END
	
	PRINT @sql
	EXEC(@sql)
	 
	 EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		  
	SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' To '+CONVERT(VARCHAR,@toDate,101)  value
	UNION all
	SELECT 'Report Type' head, value = CASE WHEN @dateType ='D' THEN 'Date Wise' WHEN @dateType = 'S' THEN 'Sending Agent Wise' WHEN @dateType = 'P' THEN 'Receiving Agent Wise' END 
	UNION all
	SELECT 'Date Type' head, value = CASE WHEN @dateType ='s' THEN 'Send Date' WHEN @dateType = 'P' THEN 'Paid Date' WHEN @dateType = 'C' THEN 'Cancel Date' END 

	SELECT 'Domestic TRANSACTION REPORT' title
	 
END

else if @flag = 'TXNDetail'  -- TRANSACTION REPORT
BEGIN
	
	if @agent=0
	set @agent=null

	 select createdDate, dbo.FNADecryptString(controlNo)controlNo,cAmt, sAgentName, pAgentName,pAmt, senderName, receiverName
	 from remitTran r with (nolock) 
	where  r.createdDate between @fromDate AND @toDate
	and r.tranType ='D'
	AND (sAgent= ISNULL(@agent,sAgent) OR ISNULL(pAgent,0)= ISNULL(@agent,ISNULL(pAgent,0)))
	
END

ELSE IF @flag = 'domtxndetail' 
BEGIN
	SET @rptDateType = CASE WHEN @dateType = 'S' THEN 'r.createdDate' 
					WHEN @dateType = 'P' THEN 'r.paidDate'
					WHEN @dateType = 'C' THEN 'r.cancelApprovedDate'
					END
					
	IF @agent=0
		SET @agent=null

	SET @sql = 'SELECT Date = CONVERT(VARCHAR,'+@rptDateType+' ,101)
		,[Control No.] = dbo.FNADecryptString(controlNo)
		,[Sending Agent] = sAgentName
		,[Collection Amount] = cAmt		
		,[Payout Agent] = pAgentName
		,[Payout Amount] = pAmt
		,[Sender Name] = senderName
		,[Receiver Name] = receiverName
	 FROM remitTran r WITH (NOLOCK) 
	 WHERE  '+@rptDateType+' BETWEEN '''+ @fromDate +''' AND '''+ @toDate +''' AND r.tranType =''D'''
	
	IF @rptType = 'S'
		SET @sql = @sql +' AND sAgent='''+@agent+''''
	 
	IF @rptType = 'R'
		SET @sql = @sql +' AND pAgent='''+@agent+''''
		
	print @sql
	EXEC(@sql)
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		  
	SELECT 'Date Range' head, 'From '+CONVERT(VARCHAR,@fromDate,101)+' To '+CONVERT(VARCHAR,@toDate,101)  value
	UNION all
	SELECT 'Report Type' head, value = CASE WHEN @dateType ='D' THEN 'Date Wise' WHEN @dateType = 'S' THEN 'Sending Agent Wise' WHEN @dateType = 'P' THEN 'Receiving Agent Wise' END 
	UNION all
	SELECT 'Date Type' head, value = CASE WHEN @dateType ='s' THEN 'Send Date' WHEN @dateType = 'P' THEN 'Paid Date' WHEN @dateType = 'C' THEN 'Cancel Date' END 

	SELECT 'DOMESTIC TRANSACTION REPORT -DETAIL' title
END




GO
