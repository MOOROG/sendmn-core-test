USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_settlement]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_settlement]
	@flag				VARCHAR(20) = NULL,
	@pCountry			VARCHAR(20)	= NULL,
	@sAgent				VARCHAR(50),
	@sBranch			VARCHAR(20)	= NULL,
	@fromDate			VARCHAR(30) = NULL,
	@toDate				VARCHAR(50)	= NULL,
	@pageNumber			VARCHAR(50)	= NULL,
	@pageSize			VARCHAR(50)	= NULL,
	@user				VARCHAR(50) = NULL

AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;

IF @pCountry = 'All'
	SET @pCountry = NULL

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


IF @flag='s'
BEGIN
		IF OBJECT_ID(N'tempdb..#SETTLEMENT') IS NOT NULL
		DROP TABLE #SETTLEMENT

		SELECT   id,controlNo,holdTranId
				,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin
				,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin
				,customerRate,sAgentSettRate
				,pDateCostRate,agentFxGain
				,serviceCharge,handlingFee,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency
				,senderName,receiverName,sCountry,sAgent,sAgentName,sBranch,sBranchName
				,pCountry ,pAgent,pAgentName,pBranch,pBranchName
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,tranStatus,payStatus
				,createdDate
				,approvedDate
				,paidDate
				,cancelApprovedDate
		INTO #SETTLEMENT
		FROM remitTran WITH (NOLOCK) 
		WHERE 1=1
		AND 
		( 
				(SAGENT=@sAgent  AND APPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND pCountry = isnull(@pCountry,pCountry) AND sBranch = isnull(@sBranch,sBranch))
			OR  (SAGENT=@sAgent  AND CANCELAPPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND pCountry = isnull(@pCountry,pCountry) AND sBranch = isnull(@sBranch,sBranch))
			OR  (PAGENT=@sAgent  AND PAIDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND sCountry  = isnull(@pCountry,sCountry) AND pBranch = isnull(@sBranch,pBranch))
		) 
		SELECT 'Remittance Send(+)' [Remarks]
			,[DATE] = '<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+@sAgent+'&pCountry='+ISNULL(@pCountry,'')+'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+convert(varchar,approvedDate,101)+'&toDate='+convert(varchar,approvedDate,101)+'&flag=Send"> '+convert(varchar,approvedDate,101)+' </a>'
			,[Total Trans]									= COUNT(id) 
			,[IN COLLECTION CURRENCY_Currency]				= collCurr 
			,[IN COLLECTION CURRENCY_Collection Amt]		= SUM(camt) 
			,[IN COLLECTION CURRENCY_Total Charge]			= SUM(ISNULL(serviceCharge,0)) 
			,[IN COLLECTION CURRENCY_Payout Amt]			= SUM(camt-ISNULL(serviceCharge,0)) 
			,[IN COLLECTION CURRENCY_Agent<br /> Commission]	= SUM(ISNULL(sAgentComm,0)) 
			,[IN COLLECTION CURRENCY_Ex. Gain]				= SUM(ISNULL(agentFxGain,0)) 
			,[IN COLLECTION CURRENCY_Sett. Amount]			= SUM(camt) - SUM(ISNULL(sAgentComm,0))  - SUM(ISNULL(agentFxGain,0)) 
			,[IN USD_Collection Amt]						= ROUND(SUM(ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)), 8) 
			,[IN USD_Total Charge]							= ROUND(SUM(ISNULL(ROUND(serviceCharge/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0)), 8) 
			,[IN USD_Payout Amt]							= ROUND(SUM(ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)-ISNULL(ROUND(serviceCharge/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0)), 8)
			,[IN USD_Agent <br /> Commission]				
				= SUM(ROUND(CAST(ROUND(ISNULL(sAgentComm,0)/ISNULL(sCurrCostRate,1),2) AS MONEY),2))--ROUND(SUM(ISNULL(ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0)), 8)  
			
			,[IN USD_Ex. Gain]								= SUM(ISNULL(ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2),0))   
			,[IN USD_Sett. Amount]							= ROUND(SUM(ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)) - 
															  SUM(ISNULL(ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))   - 
															  SUM(ISNULL(ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0)),4)  
		FROM #SETTLEMENT
		WHERE SAGENT=@sAgent  AND APPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
		GROUP BY  convert(varchar,approvedDate,101),collCurr

		UNION ALL

		SELECT [Remarks]			= 'Remittance Paid(-)' 
		,[DATE] = '<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+@sAgent+'&pCountry='+ISNULL(@pCountry,'')+'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+convert(varchar,paidDate,101)+'&toDate='+convert(varchar,paidDate,101)+'&flag=PAID"> '+convert(varchar,paidDate,101)+' </a>'
		,[Nos]						= COUNT(id) 
		,[Currency]					=  payoutCurr 
		,[Collection Amt]			= SUM(pamt) * -1
		,[Total Charge]				=  0 
		,[Payout Amt]				= SUM(pamt) * -1 
		,[Agent Commission]			= ROUND((SUM((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0)))*ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0))))), 4) * -1
		,[Ex. Gain]					= 0 
		,[Settlement Amount]		= ROUND((SUM(pamt) + SUM((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0)))*ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0))))), 4) * -1
		,[Collection Amt]			= ROUND((SUM(pamt/ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0))))), 4) * -1 
		,[Total Charge]				=  0 
		,[Payout Amt]				= ROUND((SUM(pamt/ISNULL(pDateCostRate, (pCurrCostRate - ISNULL(pCurrHoMargin,0))))), 4) * -1
		,[Agent <br /> Commission]	= ROUND((SUM((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0))))), 4) * -1 
		,[Ex. Gain]					=  0 
		,[Settlement Amount]		= ROUND((SUM(pamt/ISNULL(pDateCostRate, (pCurrCostRate - 
										ISNULL(pCurrHoMargin,0)))) + 
										SUM((ISNULL(pAgentComm,0) / (sCurrCostRate+ISNULL(sCurrHoMargin,0))))), 4) * -1
  
		FROM #SETTLEMENT
		WHERE pAGENT=@sAgent  AND paidDate BETWEEN @fromDate AND @toDate + ' 23:59:59'
		GROUP BY  convert(varchar,paidDate,101) ,payoutCurr

		UNION ALL

		SELECT 
			[Remarks]				= 'Remittance Cancel(-)' 
			,[DATE]	= '<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+@sAgent+'&pCountry='+ISNULL(@pCountry,'')+'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+convert(varchar,cancelApprovedDate,101)+'&toDate='+convert(varchar,cancelApprovedDate,101)+'&flag=cancel"> '+convert(varchar,cancelApprovedDate,101)+' </a>'
			
			,[Nos]					= COUNT(id) 
			,[Currency]				= collCurr 
			,[Collection Amt]		= SUM(camt) * -1
			,[Total Charge]			= SUM(ISNULL(serviceCharge,0)) * -1
			,[IN COLLECTION CURRENCY_Payout Amt]			= SUM(camt-ISNULL(serviceCharge,0)) * -1
			,[Agent Commission]		= SUM(ISNULL(sAgentComm,0)) * -1
			,[Ex. Gain]				= SUM(ISNULL(agentFxGain,0)) * -1
			,[Settlement Amount]	= (SUM(camt) - SUM(ISNULL(sAgentComm,0))  - SUM(ISNULL(agentFxGain,0))) * -1
			,[Collection Amt]		= (SUM(ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2))) * -1
			,[Total Charge]			= (SUM(ISNULL(ROUND(serviceCharge/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))) * -1
			,[IN USD_Payout Amt]	= (SUM(ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)-ISNULL(ROUND(serviceCharge/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))) * -1
			,[Agent Commission]		= (SUM(ISNULL(ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))) * -1
			,[Ex. Gain]				= (SUM(ISNULL(ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2),0))) * -1
			,[Settlement Amount]	= (SUM(ROUND(camt/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),2)) - SUM(ISNULL(ROUND(sAgentComm/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0))   - SUM(ISNULL(ROUND(agentFxGain/(sCurrCostRate+ISNULL(sCurrHoMargin,0)),4,1),0)))  * -1
		FROM #SETTLEMENT
		WHERE 
			SAGENT=@sAgent  
			AND cancelApprovedDate BETWEEN @fromDate AND @toDate + ' 23:59:59'
		GROUP BY  convert(varchar,cancelApprovedDate,101),collCurr
 
		ORDER BY remarks desc,DATE  
 END	

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

SELECT 'Receiving Country' head,isnull(@pCountry,'All') value
UNION ALL
SELECT 'Sending Branch' head,case when @sBranch is null then 'All' else
									(SELECT agentName FROM agentMaster WITH (NOLOCK)  WHERE agentId=@sBranch) end VALUE
UNION ALL


SELECT 'From Date' head,@fromDate VALUE
UNION ALL
SELECT 'To Date' head,@toDate VALUE
			
SELECT 'Settlement Report' title

GO
