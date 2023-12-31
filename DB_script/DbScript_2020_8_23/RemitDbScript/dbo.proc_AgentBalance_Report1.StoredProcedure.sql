ALTER PROCEDURE [dbo].[proc_AgentBalance_Report1]
	 @fromDate		DATETIME
	,@toDate		DATETIME
	,@agentId		INT		=NULL
	,@pageSize		INT			= NULL
	,@pageNumber	INT			= NULL
	,@user			VARCHAR(50)
AS

SET NOCOUNT ON;
SET @TODATE = @TODATE + ' 23:59:59'
DECLARE 
	 @NUM			INT
	,@ROWNUM		INT
	,@CLOSEAMT		MONEY
	,@REPORTHEAD	VARCHAR(40)
	,@maxReportViewDays	INT

SET @NUM=0
SET @pageSize = ISNULL(@pageSize,500)

	SET @pageNumber = ISNULL(@pageNumber,1)
	
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
	
	IF CAST(DATEDIFF(DD,@fromDate,@toDate) AS INT)>@maxReportViewDays
	BEGIN
		SELECT 'Agent Balance Report' title
		EXEC proc_errorHandler '1', 'Report viewing range exceeded.', @agentId
		RETURN
	END

SELECT 
	 Y.agent_id
	,[OPENING]			= SUM(ISNULL(OPENING,0)) 
	,[SPRINC]			= SUM(ISNULL(SPRINC,0)) 
	,[SCOMM]			= SUM(ISNULL(SCOMM,0)) 
	,[STRN]				= SUM(ISNULL(STRN,0)) 
	,[PPRINC]			= SUM(ISNULL(PPRINC,0)) 
	,[PCOMM]			= SUM(ISNULL(PCOMM,0)) 
	,[PTRN]				= SUM(ISNULL(PTRN,0)) 
	,[CPRINC]			= SUM(ISNULL(CPRINC,0)) 
	,[CCOMM]			= SUM(ISNULL(CCOMM,0)) 
	,[CTRN]				= SUM(ISNULL(CTRN,0)) 
	,[TRANSFER_AMT]		= SUM(ISNULL(TRANSFER_AMT,0)) 
	,[TRANSFER_TRN]		= SUM(ISNULL(TRANSFER_TRN,0)) 
	,[RECEIVED_AMT]		= SUM(ISNULL(RECEIVED_AMT,0)) 
	,[RECEIVED_TRN]		= SUM(ISNULL(RECEIVED_TRN,0)) 
	,[TOTAL]			= CAST(0 AS MONEY)
	,[CLOSING]			= CAST(0 AS MONEY) 
	,[DR/CR]			= NULL 
INTO #TEMPAGENTBALANCE
FROM (
	SELECT 
		 X.agent_id
		,[OPENING]		= CASE WHEN REMARKS='OPENING'  THEN  SUM(ISNULL(AMT,0)) END 
		,[SPRINC]		= CASE WHEN REMARKS='SEND' THEN SUM(ISNULL(AMT,0)) END 
		,[SCOMM]		= CASE WHEN REMARKS='SEND' THEN SUM(ISNULL(COMMISSION,0)) END 
		,[STRN]			= CASE WHEN REMARKS='SEND' THEN SUM(ISNULL(TRN,0)) END 
		,[PPRINC]		= CASE WHEN REMARKS='PAID' THEN SUM(ISNULL(AMT,0)) END 
		,[PCOMM]		= CASE WHEN REMARKS='PAID' THEN SUM(ISNULL(COMMISSION,0)) END 
		,[PTRN]			= CASE WHEN REMARKS='PAID' THEN SUM(ISNULL(TRN,0)) END 
		,[CPRINC]		= CASE WHEN REMARKS='CANCEL' THEN SUM(ISNULL(AMT,0)) END 
		,[CCOMM]		= CASE WHEN REMARKS='CANCEL' THEN SUM(ISNULL(COMMISSION,0)) END 
		,[CTRN]			= CASE WHEN REMARKS='CANCEL' THEN SUM(ISNULL(TRN,0)) END 
		,[TRANSFER_AMT] = CASE WHEN REMARKS='Fund Transfered' THEN SUM(ISNULL(AMT,0)) END 
		,[TRANSFER_TRN]	= CASE WHEN REMARKS='Fund Transfered' THEN SUM(ISNULL(TRN,0)) END 
		,[RECEIVED_AMT]	= CASE WHEN REMARKS='Fund Received' THEN SUM(ISNULL(AMT,0)) END 
		,[RECEIVED_TRN] = CASE WHEN REMARKS='Fund Received' THEN SUM(ISNULL(TRN,0)) END 
	 FROM (
		 SELECT 
			 A.REMARKS
			,A.agent_id agent_id
			,SUM(ISNULL(A.dr_principal,0))[AMT]
			,0 [COMMISSION]
			,0 [TRN] FROM (
							SELECT 
								 A.agent_id
								,'OPENING' [REMARKS]
								,[dr_principal] = ISNULL(SUM(CASE WHEN T.part_tran_type='DR' THEN T.tran_amt ELSE -T.tran_amt END),0)
							FROM SendMnPro_Account.dbo.tran_master T WITH(NOLOCK)
							INNER JOIN SendMnPro_Account.dbo.ac_master A WITH(NOLOCK) ON T.acc_num=A.acct_num 
							WHERE tran_date<@fromdate AND A.agent_id=ISNULL(@agentId,A.agent_id) and A.acct_rpt_code = '22'
							AND T.rpt_code IS NULL
							GROUP BY A.agent_id
	
							UNION ALL
							
							SELECT 
								 sAgent
								,[Particulars] = 'Opening'
								,[dr_principal] = SUM(CASE WHEN CAST(approvedDate AS DATE) = CAST(cancelApprovedDate AS DATE) THEN ISNULL(CAmt,0)-ISNULL(cAmt,0) 
											ELSE ISNULL(CAmt,0) END)
							FROM remitTran T WITH(NOLOCK)
							WHERE approvedDate < @fromdate AND ISNULL(sAgent,0) = ISNULL(@agentid,ISNULL(sAgent,0))
							GROUP BY sAgent
							) A	GROUP BY A.REMARKS,A.agent_id

		UNION ALL
	
		SELECT 
			 'SEND' 
			 ,sAgent
			 ,SUM(ISNULL(tAmt,0))
			 ,SUM(ISNULL(cAmt,0)-ISNULL(tAmt,0))
			 ,COUNT('A')
		FROM remitTran T
		WHERE approvedDate BETWEEN @FROMDATE AND @TODATE  AND ISNULL(sAgent,0) =ISNULL(@agentId,ISNULL(sAgent,0))
		GROUP BY sAgent
	
		UNION ALL
		
		SELECT 'CANCEL',sAgent,SUM(ISNULL(tAmt,0)),SUM(ISNULL(cAmt,0)-ISNULL(tAmt,0)),COUNT('A')
		FROM remitTran T
		WHERE cancelApprovedDate BETWEEN @FROMDATE AND @TODATE AND ISNULL(sAgent,0) =ISNULL(@agentId,ISNULL(sAgent,0))
		GROUP BY sAgent
		
		UNION ALL
		
		SELECT 'PAID'
				,PAgent
				,SUM(ISNULL(pAmt,0))
				,SUM(ISNULL(pAgentComm,0))
				,COUNT('A')
		FROM remitTran T
		WHERE paidDate BETWEEN @FROMDATE AND @TODATE AND ISNULL(pAgent,0) =ISNULL(@agentId,ISNULL(pAgent,0))
		GROUP BY pAgent
		
		UNION ALL
		
		SELECT 'Fund Transfered'[REMARKS],A.agent_id
		,SUM(T.tran_amt ) [cr_principal],0 [cr_comm],COUNT('A') TXN
		FROM SendMnPro_Account.dbo.ac_master A WITH(NOLOCK)
		INNER JOIN SendMnPro_Account.dbo.tran_master T WITH(NOLOCK) ON T.acc_num=A.acct_num 
		INNER JOIN tran_masterDetail TD WITH(NOLOCK) ON T.ref_num =TD.ref_num
		WHERE tran_date BETWEEN @fromdate AND @TODATE AND A.agent_id=ISNULL(@agentId,A.agent_id) and A.acct_rpt_code='22'
		AND T.RPT_CODE IS NULL AND T.part_tran_type='CR'
		GROUP BY A.agent_id
		
		UNION ALL
		
		SELECT 'Fund Received'[REMARKS],A.agent_id
		,SUM(T.tran_amt ) [cr_principal],0 [cr_comm],COUNT('A') TXN
		FROM SendMnPro_Account.dbo.ac_master A WITH(NOLOCK)
		INNER JOIN SendMnPro_Account.dbo.tran_master T WITH(NOLOCK) ON T.acc_num=A.acct_num 
		INNER JOIN SendMnPro_Account.dbo.tran_masterDetail TD WITH(NOLOCK) ON T.ref_num =TD.ref_num
		WHERE tran_date BETWEEN @fromdate AND @TODATE AND A.agent_id=ISNULL(@agentId,A.agent_id) and A.acct_rpt_code='22'
		AND T.RPT_CODE IS NULL AND T.part_tran_type='DR'
		GROUP BY A.agent_id
	) X
	GROUP BY X.agent_id,X.REMARKS
)Y
GROUP BY Y.agent_id

UPDATE #TEMPAGENTBALANCE SET TOTAL = OPENING+SPRINC+SCOMM-PPRINC-PCOMM-CPRINC-CCOMM-TRANSFER_AMT+RECEIVED_AMT

	ALTER TABLE #TEMPAGENTBALANCE
	ADD ROWID INT IDENTITY(1,1)
	
	SELECT @ROWNUM=COUNT(*) FROM #TEMPAGENTBALANCE
	
	WHILE @NUM<=@ROWNUM
	BEGIN
		SELECT @CLOSEAMT = CLOSING FROM #TEMPAGENTBALANCE WHERE ROWID =@NUM-1
		IF @NUM = 1
		BEGIN
			SELECT @CLOSEAMT = TOTAL FROM #TEMPAGENTBALANCE WHERE ROWID =@NUM
			UPDATE #TEMPAGENTBALANCE SET CLOSING = @CLOSEAMT,
			[DR/CR] =CASE WHEN  @CLOSEAMT>0  THEN 0  ELSE 1 END
			WHERE ROWID = 1
			SET @NUM = @NUM +1
		END
		
		UPDATE #TEMPAGENTBALANCE SET CLOSING = @CLOSEAMT+TOTAL
		,[DR/CR] = CASE WHEN CAST(@CLOSEAMT+TOTAL AS MONEY)>0 THEN 0 ELSE 1 END
		 WHERE ROWID = @NUM
		
		SET @NUM = @NUM +1
	END
	
	--SELECT * FROM #TEMPAGENTBALANCE
	
	SELECT TXNCOUNT = COUNT('A'),
			PAGESIZE = @pageSize ,
			PAGENUMBER = @pageNumber
		FROM #TEMPAGENTBALANCE
	
	SELECT 
		 [AGENT NAME] = A.agentName
		,[OPENING_AMOUNT]	= CASE WHEN T.OPENING >= 0 THEN T.OPENING ELSE T.OPENING*-1 END
		,[OPENING_TRN]		= CASE WHEN T.OPENING >= 0 THEN 'DR' ELSE 'CR' END
		,[SEND_AMOUNT]		= T.SPRINC 
		,[SEND_COMMISSION]	= T.SCOMM 
		,[SEND_TXN]			= '<a href = "#" onclick="OpenInNewWindow('''+DBO.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=soadrilldown&agentId='+CAST(T.AGENT_ID AS VARCHAR)+'&fromDate='+CONVERT(VARCHAR,@FROMDATE,101)+'&reportType=d&toDate='+CONVERT(VARCHAR,@TODATE,101)+'&voucherType=s'')">'+CAST(T.STRN AS VARCHAR)+'</a>'
		,[PAID_AMOUNT]		= T.PPRINC 
		,[PAID_COMMISSION]	= T.PCOMM 
		,[PAID_TXN]			= '<a href = "#" onclick="OpenInNewWindow('''+DBO.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=soadrilldown&agentId='+CAST(T.AGENT_ID AS VARCHAR)+'&fromDate='+CONVERT(VARCHAR,@FROMDATE,101)+'&reportType=d&toDate='+CONVERT(VARCHAR,@TODATE,101)+'&voucherType=p'')">'+CAST(T.PTRN AS VARCHAR)+'</a>'
		,[CANCEL_AMOUNT]	= T.CPRINC
		,[CANCEL_COMMISSION]= T.CCOMM 
		,[CANCEL_TXN]		= '<a href = "#" onclick="OpenInNewWindow('''+DBO.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=soadrilldown&agentId='+CAST(T.AGENT_ID AS VARCHAR)+'&fromDate='+CONVERT(VARCHAR,@FROMDATE,101)+'&reportType=d&toDate='+CONVERT(VARCHAR,@TODATE,101)+'&voucherType=c'')">'+CAST(T.CTRN AS VARCHAR)+'</a>'
		,[TRANSFERED_AMOUNT]= T.TRANSFER_AMT 
		,[TRANSFERED_TXN]	= '<a href = "#" onclick="OpenInNewWindow('''+DBO.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=soadrilldown&agentId='+CAST(T.AGENT_ID AS VARCHAR)+'&fromDate='+CONVERT(VARCHAR,@FROMDATE,101)+'&reportType=d&toDate='+CONVERT(VARCHAR,@TODATE,101)+'&voucherType=cr'')">'+CAST(T.TRANSFER_TRN AS VARCHAR)+'</a>'
		,[RECEIVED_AMOUNT]	= T.RECEIVED_AMT 
		,[RECEIVED_TXN]		= '<a href = "#" onclick="OpenInNewWindow('''+DBO.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=soadrilldown&agentId='+CAST(T.AGENT_ID AS VARCHAR)+'&fromDate='+CONVERT(VARCHAR,@FROMDATE,101)+'&reportType=d&toDate='+CONVERT(VARCHAR,@TODATE,101)+'&voucherType=dr'')">'+CAST(T.RECEIVED_TRN AS VARCHAR)+'</a>'
		,[CLOSING_AMOUNT]	= T.CLOSING
		,[CLOSING_TRN]		= CASE WHEN T.[DR/CR] = 0 THEN 'DR' ELSE 'CR' END 
	FROM #TEMPAGENTBALANCE T
	LEFT JOIN agentMaster A WITH (NOLOCK) ON T.AGENT_ID = A.agentId
	WHERE T.ROWID BETWEEN ((@pageNumber-1)*@pageSize +1) AND (@pageNumber * @pageSize)
	
	DROP TABLE #TEMPAGENTBALANCE

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', @agentId

SELECT 'Agent' head, ISNULL((SELECT agentName FROM agentMaster WHERE agentId = @agentId),'All') value
UNION ALL
SELECT 'From Date' head, CONVERT(VARCHAR, @fromDate, 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR, @toDate, 101) value

SELECT 'Agent Balance Report' title



GO
