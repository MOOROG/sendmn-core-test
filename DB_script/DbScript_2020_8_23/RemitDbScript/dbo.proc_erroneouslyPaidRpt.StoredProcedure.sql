USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_erroneouslyPaidRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_erroneouslyPaidRpt]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(50)		= NULL
	,@controlNo							VARCHAR(100)	= NULL
	,@fromDate							VARCHAR(20) 	= NULL
	,@toDate							VARCHAR(20)		= NULL
	,@reportFor							VARCHAR(20)		= NULL
	,@paymentMethod						VARCHAR(50)		= NULL
	,@tranType							VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(50)		= NULL
	,@pageSize                          VARCHAR(20)		= NULL
	,@pageNumber                        VARCHAR(20)		= NULL
	,@sortBy							VARCHAR(20)		= NULL

AS

SET NOCOUNT ON
SET XACT_ABORT ON
IF @flag = 'a'
BEGIN
	DECLARE @SQL AS VARCHAR(MAX),@SQL1 AS VARCHAR(MAX)
	SET @toDate=@toDate+' 23:59:59'
				
	SET @SQL ='
	SELECT DISTINCT
		 [Control No]		= ''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId=''+ cast(rt.id as varchar) +'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
		,[Payout Amount]	= ep.payoutAmt
		,[EP Date]			= CONVERT(VARCHAR,ep.createdDate,101)
		,[EP By]			= ep.createdBy
		,[EP Agent]			= ep.oldPBranchName
		,[EP COMM]			= ep.oldPAgentComm
		,[PO Date]			= CONVERT(VARCHAR,ep.newPaidDate,101)
		,[PO By]			= ep.newPaidBy
		,[PO Agent]			= ep.newPAgentName
		,[PO COMM]			= ep.newPAgentComm
		,[Sending Agent]	= rt.sAgentName
		,[Sending Branch]	= rt.sBranchName
	FROM errPaidTran ep WITH(NOLOCK)
	INNER JOIN remitTran rt on rt.id=ep.tranId
	WHERE 1=1'
			
		
	IF @reportFor IS NULL AND @controlNo IS NULL
		SET @SQL=@SQL+' AND (ep.createdDate between '''+@fromDate+''' and  '''+@toDate+''' 
		OR ep.newPaidDate between '''+@fromDate+''' and  '''+@toDate+''')'	
			
	IF @paymentMethod IS NOT NULL AND @controlNo IS NULL
		SET @SQL=@SQL+' AND rt.paymentMethod = '''+@paymentMethod+''''
	
	IF @tranType IS NOT NULL AND @controlNo IS NULL
		SET @SQL=@SQL+' AND rt.tranType = '''+@tranType+''''		
			
	IF @reportFor='EP' AND @controlNo IS NULL 
		SET @SQL=@SQL+' AND ep.approvedDate between '''+@fromDate+''' and  '''+@toDate+''''	
				
	IF @reportFor='PO' AND @controlNo IS NULL 
		SET @SQL=@SQL+' AND ep.newPaidDate between '''+@fromDate+''' and  '''+@toDate+''' and newpaidBy is not null and newPBranch is not null'	

	IF @reportFor='EPO' AND @controlNo IS NULL 
		SET @SQL=@SQL+' AND ep.approvedDate between '''+@fromDate+''' and  '''+@toDate+''' AND ep.newPaidDate is null and ep.tranStatus = ''Unpaid''' 
	
	IF @reportFor='EPC' AND @controlNo IS NULL 
		SET @SQL=@SQL+' AND ep.modifiedDate between '''+@fromDate+''' and  '''+@toDate+''' AND ep.tranStatus = ''Cancel''' 
						
	IF @controlNo IS NOT NULL 
		SET @SQL=@SQL+' AND rt.controlNo = '''+dbo.FNAEncryptString(@controlNo)+''''
				

	PRINT( @SQL)	
	SET @SQL1='
		SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @SQL +') AS tmp;

		SELECT * FROM 
		(
		SELECT ROW_NUMBER() OVER (ORDER BY [EP Date]) AS [S.N],* 
		FROM 
		(
			'+ @SQL +'
		) AS aa
		) AS tmp WHERE 1 = 1 AND  tmp.[S.N] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+''

	EXEC(@SQL1)					
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value
	UNION ALL
	SELECT 'Control No' head, @controlNo value
	UNION ALL
	SELECT 'Report For' head, @reportFor value				
	SELECT 'Erroneously Paid & Payment Order Report' title
END	
	
	
	




GO
