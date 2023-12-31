USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_commissionReport]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    
EXEC proc_commissionReport 
	 @flag = 'srpt'
	,@user = 'bharat'
	,@fromDate = '2012-1-3'
	,@toDate = '2012-5-30'	
	,@AgentId	='9'


EXEC proc_commissionReport 
	 @flag = 'drs'
	,@user = 'bharat'
	,@fromDate = '05/27/2012'
	,@AgentId	='9'
EXEC proc_commissionReport @flag = 'drs', @user = 'admin', @fromDate = '06/21/2012',
 @toDate = '06/21/2012', @date = '06/21/2012', @AgentId = '9', @pageNumber = '1', @pageSize = '100'

EXEC proc_commissionReport @flag = 'drs', @user='bharat', @date='2012-03-09'
EXEC proc_commissionReport @flag = 'srpt', @user = 'prakash', @fromDate = '2012-3-11', @toDate = '2012-3-11'
	
*/

CREATE procEDURE [dbo].[proc_commissionReport]
	 @flag					VARCHAR(20)
	,@user					VARCHAR(30)	
	,@fromDate				DATETIME	= NULL
	,@toDate				DATETIME	= NULL
	,@date					DATETIME	= NULL
    ,@AgentId				VARCHAR(30) = NULL
    ,@pageNumber			INT			= NULL
    ,@pageSize				INT			= NULL
AS

SET NOCOUNT ON;

DECLARE @branch	INT,@maxReportViewDays INT
	
     set @branch = @AgentId
	 SET @pageNumber = ISNULL(@pageNumber,1)
	 SET @pageSize = ISNULL(@pageSize ,100)

	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
	
	IF CAST(DATEDIFF(DD,@fromDate,@toDate) AS INT)>@maxReportViewDays
	BEGIN
		SELECT 'Commission Report' title
		EXEC proc_errorHandler '1', 'Report viewing range exceeded.', @agentId
		RETURN
	END

 --    if @AgentId is null
	--SELECT @branch = agentId FROM applicationUsers WHERE userName = @user



--http://localhost:52196/SwiftSystem/Reports/Reports.aspx?reportName=comm&fromDate=2012-11-01&AgentId=&toDate=2012-11-01&reportType=srpt

IF @flag = 'srpt'				--Summary Report
BEGIN
	SELECT
		 [DATE] = CONVERT(VARCHAR, approvedDate, 101)
		,dbo.GetAgentNameFromId(sBranch) [Branch Name]
		,[Transaction] = 'Sent Transaction'
		,[Txn Count] = '<a href="#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=commsenddetail&date=' + CONVERT(VARCHAR, approvedDate, 101) + '&AgentId=' + CAST(sBranch AS VARCHAR) + ' '')">' + CAST(COUNT(*) AS VARCHAR) + '</a>'
		,[Txn Amount] = SUM(ISNULL(cAmt, 0)) 
		,[Commission] = SUM(ISNULL(sAgentComm, 0)) * -1
	FROM remitTran rt 
	WHERE sBranch = ISNULL(@branch,sBranch) 
	AND approvedDate BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate + '23:59:59', '2100-12-31')
	GROUP BY CONVERT(VARCHAR, approvedDate,101),sBranch

	UNION ALL

	SELECT
		 [DATE] = CONVERT(VARCHAR, paidDate, 101)
		,dbo.GetAgentNameFromId(pBranch) [Branch Name]
		,[Transaction] = 'Paid Transaction'
		,[No. Of Txn] = '<a href="#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=commpaydetail&date=' + CONVERT(VARCHAR, paidDate, 101) +  '&AgentId=' + CAST(pBranch AS VARCHAR) + ''')">' + CAST(COUNT(*) AS VARCHAR) + '</a>'
		,[Amount] = SUM(ISNULL(pAmt, 0)) * -1
		,[Commission] = SUM(ISNULL(pAgentComm, 0)) * -1
	FROM remitTran rt 
	WHERE pBranch = ISNULL(@branch,sBranch) 
	AND paidDate BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate + '23:59:59', '2100-12-31')
	GROUP BY CONVERT(VARCHAR, paidDate,101),pBranch
	
	ORDER BY [DATE]
	
END

ELSE IF @flag = 'drs'			--Detail Report Send
BEGIN

	set @date = cast(@date as DATE) 

	SELECT 
		ROW_NUMBER() OVER (ORDER BY rt.controlNo ASC) [ROWID]
		 ,[Date] = CONVERT(VARCHAR, rt.approvedDate, 101)
		,[Reference No] = dbo.FNADecryptString(rt.controlNo)
		,[Sender] = ts.firstName + ISNULL( ' ' + ts.middleName, '') + ISNULL( ' ' + ts.lastName1, '') + ISNULL( ' ' + ts.lastName2, '')
					 + ' | <a href="#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/ReprintVoucher/SendReceipt.aspx?controlNo=' + dbo.FNADecryptString(rt.controlNo) + ''')">Receipt</a>'
		,[Collected Amount] = rt.cAmt
		,[Commission] = ISNULL(rt.sAgentComm, 0) * -1
		INTO #COMMISSIONDETAILREPORT
		FROM remitTran rt
		LEFT JOIN tranSenders ts ON rt.id = ts.tranId
		WHERE sBranch = ISNULL(@branch,sBranch) 
		AND rt.approvedDate BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate + '23:59:59', '2100-12-31')

		------###### COUNT RECORD FOR PAGING-----------
		SELECT TXNCOUNT = COUNT('A'),
			PAGESIZE = @pageSize ,
			PAGENUMBER = @pageNumber
		FROM #COMMISSIONDETAILREPORT
		
		SELECT	[Date]
				,[Reference No] 
				,[Sender]
				,[Collected Amount]
				,[Commission]
		FROM #COMMISSIONDETAILREPORT
		WHERE ROWID BETWEEN ((@pageNumber-1)*@pageSize +1) AND (@pageNumber * @pageSize)
	
		DROP TABLE #COMMISSIONDETAILREPORT

END

ELSE IF @flag = 'drp'			--Detail Report Pay
BEGIN


     set @date = cast(@date as DATE) 

	SELECT
		 [Date] = CONVERT(VARCHAR, rt.paidDate, 101)
		,[Reference No] = dbo.FNADecryptString(rt.controlNo)
		,[Beneficiary] = tr.firstName + ISNULL( ' ' + tr.middleName, '') + ISNULL( ' ' + tr.lastName1, '') + ISNULL( ' ' + tr.lastName2, '')
		,[Pay Amount] = rt.pAmt * -1
		,[Commission] = ISNULL(rt.pAgentComm, 0) * -1
		FROM remitTran rt
		LEFT JOIN tranReceivers tr ON rt.id = tr.tranId
		WHERE pBranch = ISNULL(@branch,sBranch) 
		AND rt.paidDate BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate + '23:59:59', '2100-12-31')

END

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

SELECT 'Agent' head, ISNULL((SELECT agentName FROM agentMaster WHERE agentId = @agentId),'All') value
UNION ALL
SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value

SELECT 'Commission Report' title


GO
