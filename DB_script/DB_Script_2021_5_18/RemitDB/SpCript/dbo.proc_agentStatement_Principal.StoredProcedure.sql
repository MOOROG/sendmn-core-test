USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentStatement_Principal]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[proc_agentStatement_Principal]
	 @fromDate				DATETIME
	,@toDate				DATETIME
	,@agentId				INT
	,@pageSize				INT			= NULL
	,@pageNumber			INT			= NULL
	,@user					VARCHAR(50)
AS

SET NOCOUNT ON;
SET @toDate= @toDate+ ' 23:59:59'
SET @pageSize = ISNULL(@pageSize,500)
SET @pageNumber = ISNULL(@pageNumber,1)

DECLARE @maxReportViewDays INT,@ACagentId INT

SELECT @maxReportViewDays = ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
	
	IF CAST(DATEDIFF(DD,@fromDate,@toDate) AS INT)>@maxReportViewDays
	BEGIN
		SELECT 'Agent Statement (Principal)' title
		EXEC proc_errorHandler '1', 'Report viewing range exceeded.', @agentId
		RETURN
	END

SELECT @ACagentId = agent_id FROM SendMnPro_Account.dbo.agenttable a (nolock) WHERE map_code = @agentId


SELECT TXNCOUNT = COUNT('A'),
			PAGESIZE = @pageSize,
			PAGENUMBER=@pageNumber
FROM (
	SELECT *
	 FROM (
		
		SELECT
		   '' as tranId 
		   ,NULL AS [CTRNO],@fromDate [dt],'OPENING' [REMARKS]
		FROM SendMnPro_Account.dbo.tran_master T
		INNER JOIN SendMnPro_Account.dbo.ac_master A ON T.acc_num=A.acct_num AND A.agent_id = @ACagentId
		WHERE tran_date < @FROMDATE

		UNION ALL

		SELECT id, controlNo
				,CASE WHEN paidDate IS NOT NULL THEN paidDate 
					  WHEN cancelApprovedDate IS NOT NULL THEN cancelApprovedDate ELSE approvedDate END
				,CASE WHEN paidDate IS NOT NULL THEN 'PAID' 
					  WHEN cancelApprovedDate IS NOT NULL THEN 'CANCEL' ELSE 'SEND' END
		FROM remitTran WHERE (approvedDate BETWEEN @FROMDATE AND @TODATE OR cancelApprovedDate BETWEEN @FROMDATE AND @TODATE OR paidDate BETWEEN @FROMDATE AND @TODATE)
		AND sAgent = @agentId
		GROUP BY approvedDate,paidDate,cancelApprovedDate,controlNo,id
		------UNION ALL

		------SELECT id, controlNo,cancelApprovedDate,'CANCEL'
		------FROM remitTran WHERE cancelApprovedDate BETWEEN @FROMDATE AND @TODATE AND sAgent =@agentId
		------GROUP BY cancelApprovedDate,controlNo,id
		------UNION ALL
		
		------SELECT id, controlNo,paidDate,'PAID'
		------FROM remitTran WHERE paidDate BETWEEN @FROMDATE AND @TODATE AND PAgent =@agentId
		------GROUP BY paidDate,controlNo,id
	)X
	GROUP BY X.dt,X.REMARKS,X.CTRNO, X.tranId
)Y

SELECT [DATE]= CONVERT(VARCHAR,Y.DATE,101),Y.REMARKS,Y.TRN,Y.DR,Y.CR FROM (
	SELECT ROW_NUMBER() over (order by tranId asc) [ROWID],[DATE]=CONVERT(DATE,X.dt,102)
	,X.REMARKS
	,[TRN]=CASE WHEN X.REMARKS<>'OPENING' THEN '<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=agenttrandetail&flag=' + LEFT(X.REMARKS,1) + '&fromdate='+ cast(@fromDate AS VARCHAR)
	+'&AgentId=' + cast(@agentId AS VARCHAR) + '&tranId=' + CAST(X.tranId AS VARCHAR) + ''')">' +  CAST(SUM(X.TRN) AS VARCHAR) + '</a>'
	ELSE '' END
	,SUM(ISNULL(X.DRAMT,0))[DR]
	,SUM(ISNULL(X.CRAMT,0))[CR]

	 FROM (
		
		SELECT
		   '' as tranId 
		   ,NULL AS [CTRNO],@fromDate [dt],'OPENING' [REMARKS],0 [TRN]
		,SUM(CASE WHEN T.part_tran_type='DR' THEN ISNULL(tran_amt,0)
				ELSE -ISNULL(tran_amt,0) END) [DRAMT],0 [CRAMT]
		,SUM(CASE WHEN T.part_tran_type='DR' THEN ISNULL(tran_amt,0)
		ELSE -ISNULL(tran_amt,0) END) [OBAL],0 [SBAL],0 [PBAL], 0 [CBAL]
		FROM SendMnPro_Account.dbo.tran_master T
		INNER JOIN SendMnPro_Account.dbo.ac_master A ON T.acc_num=A.acct_num AND A.agent_id = @ACagentId
		WHERE tran_date < @FROMDATE

		UNION ALL

		SELECT id, controlNo,approvedDate,'SEND',COUNT('A') [TRN],SUM(ISNULL(tAmt,0)) [DRAMT],0 [CRAMT]
		,0,SUM(ISNULL(tAmt,0)),0,0
		FROM remitTran WHERE approvedDate BETWEEN @FROMDATE AND @TODATE AND sAgent =@agentId
		GROUP BY approvedDate,controlNo,id
		UNION ALL

		SELECT id, controlNo,cancelApprovedDate,'CANCEL',COUNT('A') [TRN],0 [DRAMT],SUM(ISNULL(tAmt,0)) [CRAMT]
		,0,0,0,SUM(ISNULL(tAmt,0))
		FROM remitTran WHERE cancelApprovedDate BETWEEN @FROMDATE AND @TODATE AND sAgent =@agentId
		GROUP BY cancelApprovedDate,controlNo,id
		UNION ALL
		
		SELECT id, controlNo,paidDate,'PAID',COUNT('A') [TRN],0 [DRAMT],SUM(ISNULL(PAmt,0)) [CRAMT]
		,0,0,SUM(ISNULL(PAmt,0)) ,0
		FROM remitTran WHERE paidDate BETWEEN @FROMDATE AND @TODATE AND PAgent =@agentId
		GROUP BY paidDate,controlNo,id
	)X

	GROUP BY X.dt,X.REMARKS,X.CTRNO, X.tranId
) Y 
WHERE ROWID BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND @pageSize * @pageNumber

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', @agentId

SELECT 'Agent' head, ISNULL((SELECT agentName FROM agentMaster WHERE agentId = @agentId),'All') value
UNION ALL
SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value

SELECT 'Agent Statement (Principal)' title



GO
