SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER  PROCEDURE [dbo].[proc_settlement_v2]
	@flag				VARCHAR(20) = NULL,
	@pCountry			VARCHAR(20)	= NULL,
	@sAgent				VARCHAR(50) = NULL,
	@sBranch			VARCHAR(20)	= NULL,
	@fromDate			VARCHAR(30) = NULL,
	@toDate				VARCHAR(50)	= NULL,
	@pageNumber			VARCHAR(50)	= NULL,
	@pageSize			VARCHAR(50)	= NULL,
	@user				VARCHAR(50) = NULL
	
AS
SET NOCOUNT ON;
SET ANSI_NULLS ON;


		
DECLARE @koreaAgent VARCHAR(20)
		
SELECT @koreaAgent =agentId FROM Vw_GetAgentID WHERE SearchText = 'koreaAgent'


IF @pCountry = 'All'
	SET @pCountry = NULL

IF @flag='s_pAgent-drilldown'
BEGIN
		declare @sql varchar(max),@fxGain varchar(1),@agentCountry varchar(200),@isAgentUUM char(1) = null,@cutOffDate VARCHAR(20) = '2014-10-20'

		DECLARE @ACC_NUM VARCHAR(30)

		SELECT @ACC_NUM = M.ACCT_NUM
		FROM APPLICATIONUSERS A(NOLOCK)
		INNER JOIN SendMNPro_Account.DBO.AC_MASTER M(NOLOCK) ON M.AGENT_ID = A.AGENTID
		WHERE USERNAME = @user
		AND ISNULL(ISACTIVE, 'N') = 'Y'
		AND M.ACCT_RPT_CODE = 'TPA'

		SELECT CAST(TRAN_DATE AS DATE) TRAN_DATE
				,TRAN_AMT
				,FIELD1
				,ACCT_TYPE_CODE = ISNULL(ACCT_TYPE_CODE, 'Send')
		INTO #SEND_CANCEL1
		FROM SendMNPro_Account.DBO.TRAN_MASTER (NOLOCK)
		WHERE ACC_NUM = '111004028'
		AND TRAN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
		AND FIELD2 = 'REMITTANCE VOUCHER'
		AND ISNULL(ACCT_TYPE_CODE, 'Send') <> 'Paid'

		SELECT DISTINCT REF_NUM INTO #TEMP1
		FROM SendMNPro_Account.DBO.TRAN_MASTER (NOLOCK) 
		WHERE ACC_NUM = '100241011537'
		AND TRAN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
		
		INSERT INTO #SEND_CANCEL1
		SELECT CAST(TRAN_DATE AS DATE) TRAN_DATE
				,TRAN_AMT
				,FIELD1
				,ACCT_TYPE_CODE = 'Fund Transfer' 
		FROM #TEMP1 T
		INNER JOIN SendMNPro_Account.DBO.TRAN_MASTER M(NOLOCK) ON M.REF_NUM = T.REF_NUM
		WHERE M.ACC_NUM = '111004028'

		ALTER TABLE #SEND_CANCEL1 ADD CONTROLNO VARCHAR(30), [TXN STATUS] VARCHAR(80), [SETTLEMENT RATE] MONEY, [SENDER NAME] VARCHAR(100),
										[RECEIVER NAME] VARCHAR(100), PAMT MONEY, SETTLEMENT_AMT MONEY, COMM_AMT MONEY

		UPDATE #SEND_CANCEL1 SET CONTROLNO = DBO.FNAENCRYPTSTRING(FIELD1) 
		WHERE ACCT_TYPE_CODE IN ('Send', 'Reverse')

		UPDATE S SET S.[TXN STATUS] = R.TRANSTATUS + '/' + R.PAYSTATUS, S.[SETTLEMENT RATE] = R.PCURRCOSTRATE, S.[SENDER NAME] = R.SENDERNAME,
						S.[RECEIVER NAME] = R.RECEIVERNAME, S.PAMT = R.PAMT
		FROM #SEND_CANCEL1 S
		INNER JOIN REMITTRAN R(NOLOCK) ON R.CONTROLNO = S.CONTROLNO
		
		SELECT SETTLEMENT_AMT = MAX(TRAN_AMT), COMM_AMT = MIN(TRAN_AMT), FIELD1, ACCT_TYPE_CODE 
		INTO #MAIN1
		FROM #SEND_CANCEL1
		WHERE ACCT_TYPE_CODE IN ('Send', 'Reverse')
		GROUP BY FIELD1, ACCT_TYPE_CODE
		
		UPDATE #MAIN1 SET COMM_AMT = 0 WHERE SETTLEMENT_AMT = COMM_AMT
		
		SELECT [JME NO]
				,[TRAN DATE]
				,[SETTLEMENT AMOUNT_PRINCIPAL]
				,[SETTLEMENT AMOUNT_COMMISSION]
				,[SETTLEMENT RATE]
				,[TXN STATUS]
				,[SENDER NAME]
				,[RECEIVER NAME]
				,[PAYOUT AMOUNT] = [PAYOUT AMOUNT]/2
				,[FUND TRANSFER]
		FROM
			(SELECT DISTINCT [JME NO] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send') THEN 'Remittance Send-'+T.FIELD1 WHEN T.ACCT_TYPE_CODE IN ('Reverse') THEN 'Remittance Cancel-'+T.FIELD1 ELSE 'Fund Transfer' END 
					,CONVERT(VARCHAR,TRAN_DATE,121) [TRAN DATE]
					,[SETTLEMENT AMOUNT_PRINCIPAL] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send') THEN M.SETTLEMENT_AMT WHEN T.ACCT_TYPE_CODE IN ('Reverse') THEN -1 * M.SETTLEMENT_AMT ELSE 0 END 
					,[SETTLEMENT AMOUNT_COMMISSION] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send') THEN M.COMM_AMT WHEN T.ACCT_TYPE_CODE IN ('Reverse') THEN -1 * M.COMM_AMT ELSE 0 END 
					,[SETTLEMENT RATE] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send', 'Reverse') THEN [SETTLEMENT RATE] ELSE 0 END 
					,[TXN STATUS]
					,[SENDER NAME]
					,[RECEIVER NAME]
					,[PAYOUT AMOUNT] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send') THEN T.PAMT WHEN T.ACCT_TYPE_CODE IN ('Reverse') THEN -1 * T.PAMT ELSE 0 END
					,[FUND TRANSFER] = CASE WHEN T.ACCT_TYPE_CODE IN ('Fund Transfer') THEN T.TRAN_AMT ELSE 0 END
					,T.ACCT_TYPE_CODE
			FROM #SEND_CANCEL1 T
			LEFT JOIN #MAIN1 M ON M.FIELD1 = T.FIELD1 AND M.ACCT_TYPE_CODE = T.ACCT_TYPE_CODE)X
		ORDER BY ACCT_TYPE_CODE

		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head,@fromDate VALUE
		UNION ALL
		SELECT 'To Date' head,@toDate VALUE

		SELECT 'Settlement Report(Paying Agent)' title
		RETURN
 END
ELSE IF @flag='s_pAgent'
BEGIN
		SELECT @ACC_NUM = M.ACCT_NUM
		FROM APPLICATIONUSERS A(NOLOCK)
		INNER JOIN SendMNPro_Account.DBO.AC_MASTER M(NOLOCK) ON M.AGENT_ID = A.AGENTID
		WHERE USERNAME = @user
		AND ISNULL(ISACTIVE, 'N') = 'Y'
		AND M.ACCT_RPT_CODE = 'TPA'

		SELECT CAST(TRAN_DATE AS DATE) TRAN_DATE
				,TRAN_AMT
				,FIELD1
				,ACCT_TYPE_CODE = ISNULL(ACCT_TYPE_CODE, 'Send')
		INTO #SEND_CANCEL
		FROM SendMNPro_Account.DBO.TRAN_MASTER (NOLOCK)
		WHERE ACC_NUM = '111004028'
		AND TRAN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
		AND FIELD2 = 'REMITTANCE VOUCHER'
		AND ISNULL(ACCT_TYPE_CODE, 'Send') <> 'Paid'

		
		SELECT DISTINCT REF_NUM INTO #TEMP 
		FROM SendMNPro_Account.DBO.TRAN_MASTER (NOLOCK) 
		WHERE ACC_NUM = '100241011537'
		AND TRAN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
		
		INSERT INTO #SEND_CANCEL
		SELECT CAST(TRAN_DATE AS DATE) TRAN_DATE
				,TRAN_AMT
				,FIELD1
				,ACCT_TYPE_CODE = 'Fund Transfer' 
		FROM #TEMP T
		INNER JOIN SendMNPro_Account.DBO.TRAN_MASTER M(NOLOCK) ON M.REF_NUM = T.REF_NUM
		WHERE M.ACC_NUM = '111004028'

		ALTER TABLE #SEND_CANCEL ADD CONTROLNO VARCHAR(30), [TXN STATUS] VARCHAR(80), [SETTLEMENT RATE] MONEY, [SENDER NAME] VARCHAR(100),
										[RECEIVER NAME] VARCHAR(100), PAMT MONEY, SETTLEMENT_AMT MONEY, COMM_AMT MONEY

		UPDATE #SEND_CANCEL SET CONTROLNO = DBO.FNAENCRYPTSTRING(FIELD1) 
		WHERE ACCT_TYPE_CODE IN ('Send', 'Reverse')

		UPDATE S SET S.[TXN STATUS] = R.TRANSTATUS + '/' + R.PAYSTATUS, S.[SETTLEMENT RATE] = R.PCURRCOSTRATE, S.[SENDER NAME] = R.SENDERNAME,
						S.[RECEIVER NAME] = R.RECEIVERNAME, S.PAMT = R.PAMT
		FROM #SEND_CANCEL S
		INNER JOIN REMITTRAN R(NOLOCK) ON R.CONTROLNO = S.CONTROLNO
		
		SELECT SETTLEMENT_AMT = MAX(TRAN_AMT), COMM_AMT = MIN(TRAN_AMT), FIELD1, ACCT_TYPE_CODE 
		INTO #MAIN
		FROM #SEND_CANCEL
		WHERE ACCT_TYPE_CODE = 'Send'
		GROUP BY FIELD1, ACCT_TYPE_CODE
		
		--select sum(SETTLEMENT_AMT+COMM_AMT) from #MAIN
		--select sum(tran_amt) from #SEND_CANCEL where ACCT_TYPE_CODE = 'send'

		
		UPDATE #MAIN SET COMM_AMT = 0 WHERE SETTLEMENT_AMT = COMM_AMT
		
		SELECT [TRAN DATE] = '<a href="Reports.aspx?reportName=settlementint_pAgent&from='+[TRAN DATE]+
								'&to='+[TRAN DATE]+'&flag=s_pAgent-drilldown"> '+ [TRAN DATE] +' </a>'
				, [SETTLEMENT AMOUNT</BR>(JPY)_PRINCIPAL] = SUM([SETTLEMENT AMOUNT_PRINCIPAL])
				, [SETTLEMENT AMOUNT</BR>(JPY)_COMMISSION] = SUM([SETTLEMENT AMOUNT_COMMISSION])
				, [SEND TXN COUNT] = SUM(CASE WHEN ACCT_TYPE_CODE = 'Send' THEN 1 ELSE 0 END)
				, [SETTLEMENT RATE</BR>/AVG.] = SUM([SETTLEMENT RATE])/(SUM(CASE WHEN [SETTLEMENT RATE] = 0 THEN 0 ELSE 1 END))
				, [PAYOUT AMOUNT</BR>(NPR)] = SUM([PAYOUT AMOUNT]) / 2
				, [CANCEL AMOUNT</BR>(JPY)] = SUM([CANCEL AMOUNT])
				, [CANCEL TXN COUNT] = SUM(CASE WHEN ACCT_TYPE_CODE = 'Reverse ' THEN 1 ELSE 0 END)
				, [FUND TRANSFER</BR>(JPY)] = SUM([FUND TRANSFER])
				, [NET SETTLEMENT AMOUNT</BR>(JPY)] = SUM([SETTLEMENT AMOUNT_PRINCIPAL]) + SUM([SETTLEMENT AMOUNT_COMMISSION]) - SUM([CANCEL AMOUNT])
		FROM 
			(SELECT DISTINCT CONVERT(VARCHAR,TRAN_DATE,121) [TRAN DATE]
					,[SETTLEMENT AMOUNT_PRINCIPAL] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send') THEN M.SETTLEMENT_AMT ELSE 0 END
					,[SETTLEMENT AMOUNT_COMMISSION] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send') THEN M.COMM_AMT ELSE 0 END
					,[SETTLEMENT RATE] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send', 'Reverse') THEN T.[SETTLEMENT RATE] ELSE 0 END
					,[PAYOUT AMOUNT] = CASE WHEN T.ACCT_TYPE_CODE IN ('Send') THEN PAMT WHEN T.ACCT_TYPE_CODE IN ('Reverse') THEN -1*PAMT ELSE 0 END
					,[CANCEL AMOUNT] = CASE WHEN T.ACCT_TYPE_CODE IN ('Reverse') THEN T.TRAN_AMT ELSE 0 END
					,[FUND TRANSFER] = CASE WHEN T.ACCT_TYPE_CODE IN ('Fund Transfer') THEN T.TRAN_AMT ELSE 0 END
					,T.FIELD1
					,T.ACCT_TYPE_CODE
			FROM #SEND_CANCEL T
			LEFT JOIN #MAIN M ON M.FIELD1 = T.FIELD1 AND M.ACCT_TYPE_CODE = T.ACCT_TYPE_CODE
		)X GROUP BY [TRAN DATE]
		ORDER BY [TRAN DATE]

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head,@fromDate VALUE
		UNION ALL
		SELECT 'To Date' head,@toDate VALUE

		SELECT 'Settlement Report(Paying Agent)' title

		RETURN
 END	
 ELSE IF @flag='s_pAgent_new'
 BEGIN
	SELECT CONVERT(VARCHAR(10), CREATEDDATE, 121) [DOT],
			SUM(TAMT) [TRANSFER AMT],
			SUM(PAMT) [PAYOUT AMT],
			AVG(CUSTOMERRATE) [CUSTOMER RATE],
			AVG(PCURRCOSTRATE) [SETT. RATE],
			SUM(SERVICECHARGE) [SERVICE CHARGE],
			SUM(PAGENTCOMM) [JME NEPAL COMM.]
	FROM REMITTRAN (NOLOCK)
	WHERE PCOUNTRY = 'NEPAL'
	AND PSUPERAGENT = 393880
	AND CREATEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
	AND TRANSTATUS <> 'CANCEL'
	GROUP BY CONVERT(VARCHAR(10), CREATEDDATE, 121)
	ORDER BY CONVERT(VARCHAR(10), CREATEDDATE, 121)

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head,@fromDate VALUE
	UNION ALL
	SELECT 'To Date' head,@toDate VALUE

	SELECT 'Settlement Report(Paying Agent)' title

	RETURN
 END
ELSE IF @flag='s'
BEGIN
		IF OBJECT_ID(N'tempdb..#SETTLEMENT') IS NOT NULL
		DROP TABLE #SETTLEMENT

		SELECT   id,controlNo,holdTranId
				,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin
				,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin,pSuperAgent
				,customerRate,sAgentSettRate
				,pDateCostRate,agentFxGain
				,serviceCharge = CASE WHEN PAGENT = 221227 THEN 0 ELSE serviceCharge END 
				,handlingFee,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency
				,senderName,receiverName,sCountry,sAgent,sAgentName,sBranch,sBranchName
				,pCountry ,pAgent,pAgentName,pBranch,pBranchName
				,collCurr,tAmt,cAmt,pAmt,payoutCurr,tranStatus,payStatus
				,createdDate
				,approvedDate = CAST(approvedDate AS DATE)
				,paidDate
				,cancelApprovedDate = CAST(cancelApprovedDate AS DATE)
		INTO #SETTLEMENT
		FROM remitTran WITH (NOLOCK) 
		WHERE 1=1 
		AND 
		( 
				(SAGENT=ISNULL(@sAgent, SAGENT) AND CREATEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND sCountry =@pCountry AND sBranch = isnull(@sBranch,sBranch))
			OR  (SAGENT=ISNULL(@sAgent, SAGENT) AND CANCELAPPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND sCountry = @pCountry AND sBranch = isnull(@sBranch,sBranch))
			OR  (PAGENT=ISNULL(@sAgent, PAGENT) AND PAIDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND sCountry  = @pCountry AND pBranch = isnull(@sBranch,pBranch))
		) 

		CREATE TABLE #SETTLEMENT_MAIN
		(
			REMARKS VARCHAR(100)  NULL,
			[DATE]  DATE  NULL,
			TOTTRAN INT NULL,
			CURR	VARCHAR(10) NULL,
			LCYCA	MONEY NULL,
			LCYSC	MONEY NULL,
			LCYTA	MONEY NULL,
			LCYCOMM MONEY NULL,
			LCYFX	MONEY NULL,
			LCYSETTL MONEY NULL,
			USDCA	MONEY NULL,
			USDSC	MONEY NULL,
			USDTA	MONEY NULL,
			USDCOMM MONEY NULL,
			USDSETTL MONEY NULL,
			SUMPA	MONEY NULL
		)
		
	
		--INSERT INTO #SETTLEMENT_MAIN(REMARKS,[DATE],TOTTRAN,LCYCA,LCYSC,LCYTA,LCYCOMM,LCYFX,LCYSETTL,USDCA,USDSC,USDTA,USDCOMM,USDSETTL,SUMPA)
			SELECT * FROM 
			(
				SELECT 
					 [Remarks] = '<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+isnull(@sAgent, '')+'&pCountry='+
					 ISNULL(@pCountry,'')+'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+
					 convert(varchar,CREATEDDATE,101)+'&toDate='+convert(varchar,CREATEDDATE,101)+'&flag=Send"> '+ 'Remittance Send(+)' +' </a>' 
					,[DATE]											= convert(varchar,CREATEDDATE,101)
					,[Total Trans]									= COUNT(id) 
					,[Settlement in MNT_Collect Amount]				= SUM(cAmt) 
					,[Settlement in MNT_Transfer Principal]			= SUM(tAmt)
					,[Settlement in MNT_Service Charge]				= SUM(ISNULL(serviceCharge,0)) 
					,[Settlement in MNT_PAgent Commission]			= SUM(PAgentComm)
								
					,[Settlement in USD_Transfer Principal]		= SUM(ROUND(pAmt * pCurrCostRate,2))
					,[Settlement in USD_PAgent Commission]		= SUM(ROUND(PAgentComm/(sCurrCostRate + ISNULL(sCurrHoMargin, 0)),2))

					--ROUND(PAgentComm/(sCurrCostRate + ISNULL(sCurrHoMargin, 0)),2)
				FROM #SETTLEMENT
				WHERE SAGENT = ISNULL(@sAgent, SAGENT) AND CREATEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
				AND tranStatus = 'Paid'
				AND payStatus = 'Paid'
				GROUP BY convert(varchar,CREATEDDATE,101)

				--UNION ALL

				--SELECT 
				--	 [Remarks]	='<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+isnull(@sAgent, '')+'&pCountry='+
				--	 ISNULL(@pCountry,'')+'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+
				--	 convert(varchar,cancelApprovedDate,101)+'&toDate='+convert(varchar,cancelApprovedDate,101)+'&flag=cancel"> '+ 'Remittance Cancel Same day(-)'+' </a>'			 
				--	,[DATE]											= convert(varchar,cancelApprovedDate,101)
				--	,[Nos]											= COUNT(id) * -1
				--	,[IN COLLECTION CURRENCY_Total Collection]		= SUM(cAmt) * -1
				--	,[IN COLLECTION CURRENCY_Total Charge]			= SUM(ISNULL(serviceCharge,0)) * -1
				--	,[IN COLLECTION CURRENCY_Principal Amount]		= SUM(tAmt)* -1
				--	,[IN COLLECTION CURRENCY_Settlement Amount]		= SUM(tAmt + ISNULL(sAgentComm,0))* -1
				--	FROM #SETTLEMENT
				--	WHERE 
				--		SAGENT = ISNULL(@sAgent, SAGENT)  
				--		AND cancelApprovedDate BETWEEN @fromDate AND @toDate + ' 23:59:59'
				--		AND CREATEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59'
				--	GROUP BY  convert(varchar,cancelApprovedDate,101)

				--	UNION ALL

				--	SELECT 
				--	 [Remarks]	='<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+isnull(@sAgent, '')+'&pCountry='+
				--	 ISNULL(@pCountry,'')+'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+
				--	 convert(varchar,cancelApprovedDate,101)+'&toDate='+convert(varchar,cancelApprovedDate,101)+'&flag=cancel"> '+ 'Remittance Cancel Not Same Day(-)'+' </a>'			 
				--	,[DATE]											= convert(varchar,cancelApprovedDate,101)
				--	,[Nos]											= COUNT(id) * -1
				--	,[IN COLLECTION CURRENCY_Total Collection]		= SUM(cAmt) * -1
				--	,[IN COLLECTION CURRENCY_Total Charge]			= SUM(ISNULL(serviceCharge,0)) * -1
				--	,[IN COLLECTION CURRENCY_Principal Amount]		= SUM(tAmt)* -1
				--	FROM #SETTLEMENT
				--	WHERE 
				--		SAGENT = ISNULL(@sAgent, SAGENT)  
				--		AND cancelApprovedDate BETWEEN @fromDate AND @toDate + ' 23:59:59'
				--		AND CREATEDDATE NOT BETWEEN @fromDate AND @toDate + ' 23:59:59'
				--	GROUP BY  convert(varchar,cancelApprovedDate,101)
			) x ORDER BY CAST([DATE] AS DATE)
 END	

--ELSE IF @flag='a'
--BEGIN
--		SELECT * into #PartnerResult FROM 
--			(
--				SELECT 
--					 [Remarks] = 'Post Transactions(+)' 
--					,[DATE] = '<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+@sAgent+'&pCountry='+ISNULL(@pCountry,'')
--					 +'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+convert(varchar,approvedDate,101)+'&toDate='
--					 +convert(varchar,approvedDate,101)+'&flag=Post"> '+convert(varchar,approvedDate,101)+' </a>' 
--					--,[DATE]											= convert(varchar,postedDate,101)
--					,[Total Trans]									= COUNT(id) 
--					,[IN COLLECTION CURRENCY_Total Collection]		= SUM(cAmt) 
--					,[IN COLLECTION CURRENCY_Total Charge]			= SUM(ISNULL(serviceCharge,0)) 
--					,[IN COLLECTION CURRENCY_Principal Amount]		= SUM(tAmt)
--					,[IN COLLECTION CURRENCY_Agent<br /> Commission]= SUM(CASE WHEN pSuperAgent IN ('394132') THEN pAgentComm / customerRate ELSE pAgentComm END)
--					,[IN COLLECTION CURRENCY_Settlement Amount]		= 0 
					
--					,[IN SETT. CURR_Principal Amount]				= CASE WHEN pSuperAgent IN ('394132') THEN SUM(tAmt * customerRate) ELSE SUM(tAmt) END 
--					,[IN SETT. CURR_Agent Comm]						= SUM(ISNULL(pAgentComm,0))
--					,[IN SETT. CURR_Settlement Amount]				=  SUM((pAmt / CASE WHEN PSUPERAGENT = 394132 THEN 1 ELSE pCurrCostRate END) + ISNULL(pAgentComm, 0))
					
--					,[IN Paying_Principal Amount]					= SUM(pAmt)
			
--				FROM remitTran WITH (NOLOCK) 
--				WHERE 1=1 AND pAgent = ISNULL( @sAgent,pAgent) AND pCountry = @pCountry
--				AND approvedDate BETWEEN @fromDate AND @toDate+' 23:59:59'
--				GROUP BY  CONVERT(varchar,approvedDate,101),pSuperAgent

--				UNION ALL 

--				SELECT 
--					 [Remarks] = 'Reverse Transactions(-)' 
--					,[DATE] = '<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+@sAgent+'&pCountry='+ISNULL(@pCountry,'')
--					 +'&sBranch='+ISNULL(CAST(@sBranch AS VARCHAR),'')+'&fromDate='+convert(varchar,cancelapprovedDate,101)+'&toDate='
--					 +convert(varchar,cancelapprovedDate,101)+'&flag=CANCEL"> '+convert(varchar,cancelapprovedDate,101)+' </a>' 
--					--,[DATE]											= convert(varchar,cancelapprovedDate,101)
--					,[Total Trans]									= COUNT(id)*-1
--					,[IN COLLECTION CURRENCY_Total Collection]		= SUM(cAmt)*-1 
--					,[IN COLLECTION CURRENCY_Total Charge]			= SUM(ISNULL(serviceCharge,0)) *-1
--					,[IN COLLECTION CURRENCY_Principal Amount]		= SUM(tAmt)*-1
--					,[IN COLLECTION CURRENCY_Agent<br /> Commission]= SUM(CASE WHEN pSuperAgent IN ('394132') THEN pAgentComm / customerRate ELSE pAgentComm END) *-1
--					,[IN COLLECTION CURRENCY_Settlement Amount]		= 0
--					,[IN SETT. CURR_Principal Amount]				= CASE WHEN pSuperAgent IN ('394132') THEN SUM(tAmt * customerRate) *-1 ELSE SUM(tAmt) *-1 END 
--					,[IN SETT. CURR_Agent Comm]						= SUM(ISNULL(pAgentComm,0)) *-1
--					,[IN SETT. CURR_Settlement Amount]				=  SUM((pAmt / CASE WHEN PSUPERAGENT = 394132 THEN 1 ELSE pCurrCostRate END) + ISNULL(pAgentComm, 0))*-1
						
--					,[IN Paying_Principal Amount]					= SUM(pAmt)*-1 
			
--				FROM remitTran WITH (NOLOCK) 
--				WHERE 1=1 AND pAgent = ISNULL( @sAgent,pAgent)  --AND pCountry = @pCountry
--				AND cancelapprovedDate BETWEEN @fromDate AND @toDate+' 23:59:59'
--				GROUP BY  CONVERT(varchar,cancelapprovedDate,101),pSuperAgent
--			) x order by [Remarks],[DATE]
			
--			UPDATE #PartnerResult 
--				SET [IN COLLECTION CURRENCY_Settlement Amount] = ISNULL([IN COLLECTION CURRENCY_Principal Amount], 0)+ISNULL([IN COLLECTION CURRENCY_Agent<br /> Commission], 0)
--				,[IN SETT. CURR_Settlement Amount] = [IN SETT. CURR_Principal Amount] + [IN SETT. CURR_Agent Comm]
			
--			SELECT * FROM #PartnerResult
-- END	
ELSE  IF @flag='a'
BEGIN
		IF OBJECT_ID(N'tempdb..#SETTLEMENT_A') IS NOT NULL
		DROP TABLE #SETTLEMENT_A

		IF OBJECT_ID(N'tempdb..#SETTLEMENT_MAIN_A') IS NOT NULL
		DROP TABLE #SETTLEMENT_MAIN_A


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
				,sSuperAgent
				,pSuperAgent
		INTO #SETTLEMENT_A
		FROM remitTran WITH (NOLOCK) 
		WHERE 1=1 AND tranType = 'I'
		AND 
		( 
				(SAGENT=ISNULL(@sAgent,sAgent)  AND APPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND sCountry = isnull(@pCountry,sCountry) AND sBranch = isnull(@sBranch,sBranch))
			OR  (SAGENT=ISNULL(@sAgent,sAgent)  AND CANCELAPPROVEDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND sCountry = isnull(@pCountry,sCountry) AND sBranch = isnull(@sBranch,sBranch))
			OR  (PAGENT=ISNULL(@sAgent,pAgent)  AND PAIDDATE BETWEEN @fromDate AND @toDate + ' 23:59:59' AND pCountry  = isnull(@pCountry,pCountry) AND pBranch = isnull(@sBranch,pBranch))
		) 
		
		--SELECT * FROM #SETTLEMENT
		--RETURN
		CREATE TABLE #SETTLEMENT_MAIN_A
		(
			REMARKS		VARCHAR(100)  NULL,
			[DATE]		VARCHAR(MAX)  NULL,
			TOTTRAN		INT NULL,
			CURR		VARCHAR(10) NULL,
			LAMT		MONEY NULL,
			LSC			MONEY NULL,
			PAMT		MONEY NULL,
			PUSD		MONEY NULL,
			SCUSD		MONEY NULL,
			SETTLEUSD	MONEY NULL,
			PEUR		MONEY NULL,
			SCEUR		MONEY NULL,
			SETTLEEUR	MONEY NULL,
		)
		BEGIN
			INSERT INTO #SETTLEMENT_MAIN_A(REMARKS,[DATE],TOTTRAN,CURR,LAMT,LSC,PAMT,PUSD,SCUSD,PEUR,SCEUR)
			SELECT * FROM 
			(
				SELECT 'Remittance Receive' [Remarks] 
				,[DATE]	= '<a href="Reports.aspx?reportName=irhSettDrilDwn&sAgent='+ISNULL(@sAgent,'')+'&pCountry='+ISNULL(@pCountry,'')+'&sBranch='+ISNULL(CAST(ISNULL(@sBranch,'') AS VARCHAR),'')
						+'&fromDate='+convert(varchar,approvedDate,101)+'&toDate='+convert(varchar,approvedDate,101)+'&flag=Post"> '+convert(varchar,approvedDate,101)+' </a>'
					,[Total Trans]						=	COUNT(id) 
					,[Collection_Currency]				=	collCurr 
					,[Collection_Principal]				=	SUM(tAmt) 
					,[Collection_Charge/Commission]		=	SUM(ISNULL(serviceCharge,0)) 

					,[Payout Amount(MNT)]				=	SUM(pAmt)
					,[Settlement in USD_Principal]		=	CASE WHEN collCurr IN('USD','KRW') THEN ROUND(SUM(pAmt/ISNULL(pCurrCostRate,1)),2) ELSE 0 END
					,[Settlement in USD_Commission]		=	CASE WHEN collCurr IN('USD','KRW') THEN SUM(
																	CASE 
																		 WHEN collCurr = 'USD' THEN ISNULL(serviceCharge,0)
																		 WHEN sSuperAgent =  @koreaAgent THEN 
																		 CASE WHEN  pAmt < 230000  THEN 1 ELSE 1.5 END  
																 ELSE ROUND(serviceCharge/ISNULL(pCurrCostRate,1),2) END)
															ELSE 0 END
					,[Settlement in EUR_Principal]		=	CASE WHEN collCurr = 'EUR' THEN ROUND(SUM(pAmt/ISNULL(pCurrCostRate,1)),2) ELSE 0 END
					,[Settlement in EUR_Commission]		=	CASE WHEN collCurr = 'EUR' THEN SUM(
																	CASE 
																		WHEN collCurr = 'EUR' THEN ISNULL(serviceCharge,0)
																		WHEN sSuperAgent =  @koreaAgent THEN 
																		CASE WHEN  pAmt < 230000  THEN 1 ELSE 1.5 END  
																	ELSE ROUND(serviceCharge/ISNULL(pCurrCostRate,1),2) END)
															ELSE 0 END
				FROM #SETTLEMENT_A
				WHERE  pAgent = ISNULL( @sAgent,pAgent) AND pCountry = @pCountry
				GROUP BY CONVERT(VARCHAR,approvedDate,101),collCurr

			) x

			UPDATE #SETTLEMENT_MAIN_A SET SETTLEUSD = PUSD + SCUSD,SETTLEEUR=PEUR+SCUSD
		END

		SELECT 
				 [Particulars]					= REMARKS
				,[DATE]							= [DATE]
				,[No. of Trans]					= TOTTRAN
				,[Collection_Currency]			= CURR		
				,[Collection_Principal]			= LAMT	
				,[Collection_Charge/Commission]	= LSC
				,[Payout Amount(MTN)]			= PAMT	
				,[Settlement in USD_Principal]	= PUSD
				,[Settlement in USD_Commission] = SCUSD
				,[Settlement in EUR_Principal]	= PEUR
				,[Settlement in EUR_Commission] = SCEUR
			--	,[Settlement in USD_Net Settlement] = SETTLEUSD
			FROM #SETTLEMENT_MAIN_A

 END	

ELSE IF @flag='PartnerD'  --##
BEGIN
		SELECT 
			[DATE]											= convert(varchar,approvedDate,101)
			,[GME NO]										= dbo.FNADecryptString(controlNo)
			,[IN COLLECTION CURRENCY_Total Collection]		= (cAmt) 
			,[IN COLLECTION CURRENCY_Total Charge]			= (ISNULL(serviceCharge,0)) 
			,[IN COLLECTION CURRENCY_Principal Amount]		= (tAmt)
			,[IN COLLECTION CURRENCY_Agent<br /> Commission]= (pAgentComm)
			,[IN COLLECTION CURRENCY_Settlement Amount]		= (tAmt + ISNULL(pAgentComm,0))
			
			,[IN SETT. CURR_Principal Amount]				= CASE WHEN pSuperAgent IN ('394132') THEN tAmt * customerRate ELSE tAmt END 
			,[IN SETT. CURR_Agent Comm]						= ISNULL(pAgentComm,0)
			,[IN SETT. CURR_Settlement Amount]				= CASE WHEN pSuperAgent IN ('394132') THEN pAmt + pAgentComm ELSE (pAmt / pCurrCostRate) + ISNULL(pAgentComm, 0)  END
			
			,[IN Paying_Principal Amount]					= (pAmt)
		FROM remitTran WITH (NOLOCK) 
		WHERE 1=1 AND pAgent = @sAgent AND pCountry = @pCountry
		AND approvedDate BETWEEN @fromDate AND @toDate+' 23:59:59'
		ORDER BY approvedDate
			----## if paying agent wise settlement report then check from posted date rest approve date
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

IF @flag='s'			
	SELECT 'Settlement Report(Sending Agent)' title
ELSE IF @flag='a'
	SELECT 'Settlement Report(Paying Agent)' title
ELSE IF @flag='a'
	SELECT 'Settlement Detail(Paying Agent)' title

GO