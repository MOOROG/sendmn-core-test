USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_settlementDetailRpt]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EXEC [proc_settlementDetailRpt] @flag ='rpt',@fromDate = '2013-01-01',@toDate = '2013-02-02',@agentId = '33300402'

CREATE PROC [dbo].[proc_settlementDetailRpt]
		 @flag				VARCHAR(10)	 = NULL
		,@user				VARCHAR(30)  = NULL
		,@fromDate			VARCHAR(50)	 = NULL
		,@toDate			VARCHAR(50)	 = NULL
		,@agentId			VARCHAR(50)	 = NULL		
		
AS
SET NOCOUNT ON;
SET XACT_ABORT ON ;	
	DECLARE @Title VARCHAR(50) = 'Settlement Detail Report'
BEGIN TRY
 IF @flag = 'rpt'
 BEGIN
		DECLARE @temp_table TABLE 
		(
			txnDate			VARCHAR(20),
			branchId		VARCHAR(200),

			paidCountIntl	INT,
			paidAmtIntl		MONEY,

			sendCountDom	INT,
			sendAmtDom		MONEY, 

			paidCountDom	INT,
			paidAmtDom		MONEY,

			cancelCountDom	INT,
			cancelAmtDom	MONEY,

			epCount			INT,
			epAmt			MONEY,

			poCount			INT,
			poAmt			MONEY
		)
		-- Domestic Send
		--INSERT INTO @temp_table(txnDate,branchId,sendCountDom,sendAmtDom)		 
		--SELECT 
		--	date = CONVERT(VARCHAR , CONFIRM_DATE, 101), 
		--	sBranch = at.map_code,
		--	sendCount = cast(COUNT('x') as varchar(20)),
		--	sendAmt = SUM(S_AMT) 
		--FROM REMIT_TRN_LOCAL RTL WITH (NOLOCK), agentTable AT WITH ( NOLOCK ) 
		--WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		--AND ISNULL (AT.central_sett_code,map_code)= @agentId 
		--AND CONFIRM_DATE BETWEEN @fromDate AND @toDate +' 23:59:59'
		----AND isnull(TranType,'') <> 'B'
		--GROUP BY CONVERT(VARCHAR,CONFIRM_DATE, 101),at.map_code

		-- Domestic Cancel
		--INSERT INTO @temp_table(txnDate,branchId,cancelCountDom,cancelAmtDom)
		--SELECT 
		--	   date = CONVERT(VARCHAR , CANCEL_DATE, 101),
		--	   sBranch = at.map_code,
		--	   cancelCount = COUNT('x'),
		--	   cancelAmt = SUM(CASE WHEN CONVERT(VARCHAR,CANCEL_DATE , 101)= CONVERT(VARCHAR,CONFIRM_DATE, 101) THEN S_AMT ELSE P_AMT+R_SC END )
		--FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH (NOLOCK ) 
		--WHERE RTL.S_AGENT= AT .AGENT_IME_CODE 
		--AND ISNULL (AT.central_sett_code,map_code)= @agentId 
		--AND CANCEL_DATE BETWEEN @fromDate AND @toDate +' 23:59:59'
		--GROUP BY CONVERT(VARCHAR , CANCEL_DATE, 101),at.map_code
		 
		 --Domestic Paid
		--INSERT INTO @temp_table(txnDate,branchId,paidCountDom,paidAmtDom)
		--SELECT 
		--	date = CONVERT(VARCHAR,P_DATE, 101), 
		--	pBranch = AT.map_code,
		--	payCount = COUNT('x'),
		--	payAmount = SUM(p_AMT)  
		--FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		--WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
		--AND ISNULL (AT.central_sett_code,map_code)= @agentId 
		--AND P_DATE BETWEEN @fromDate AND @toDate +' 23:59:59'
		--GROUP BY CONVERT(VARCHAR ,P_DATE , 101),AT.map_code
		
		-- International Paid
		INSERT INTO @temp_table(txnDate,branchId,paidCountIntl,paidAmtIntl)	
		SELECT	
			date = CONVERT ( VARCHAR,paid_date, 101 ),
		    pBranch = P_BRANCH,
			payCount = COUNT('x'),
			payAmount = SUM(P_AMT)   
		FROM REMIT_TRN_MASTER RTM WITH ( NOLOCK) 
		WHERE P_AGENT = @agentId 
		AND PAID_DATE BETWEEN @fromDate AND @toDate+' 23:59:59'
		GROUP BY CONVERT(VARCHAR,paid_date,101),P_BRANCH 

		 
 	--	-- ## EP
		--INSERT INTO @temp_table(txnDate,branchId,epCount,epAmt)	
		--SELECT 
		--	date  = CONVERT(VARCHAR,EP_date, 101), 
		--	pBranch = EP_BranchCode,
		--	epCount = COUNT('x'),
		--	epAmt = SUM(Amount)
		--FROM ErroneouslyPaymentNew EP WITH (NOLOCK) 
		--WHERE (EP_AgentCode=@agentId OR EP_BranchCode=@agentId) 
		--AND EP_date between  @fromDate AND @toDate+' 23:59:59'
		--Group by EP_date,ep.EP_BranchCode

		---- ## PO
		--INSERT INTO @temp_table(txnDate,branchId,poCount,poAmt)
		--SELECT 
		--	date = CONVERT(VARCHAR,PO_date, 101), 
		--	newPBranch = ep.ep_branchCode,
		--	poCount =  COUNT('x'),
		--	poAmt =  SUM(Amount) 
		--FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
		--WHERE (PO_AgentCode=@agentId  OR PO_BranchCode=@agentId) 
		--AND PO_date BETWEEN @fromDate AND @toDate+' 23:59:59'
		--Group by PO_date,ep.ep_branchCode


			
		SELECT 
			[SN] = ROW_NUMBER()OVER(ORDER BY txnDate,branchId),
			[Date] = txnDate,
			branchName = at.agent_name,
			[Int'l Paid_No. of Txn] = SUM(ISNULL(paidCountIntl,0)),
			[Int'l Paid_Amount] = SUM(ISNULL(paidAmtIntl,0)),

			[D. Send_No. of Txn] = SUM(ISNULL(sendCountDom,0)),
			[D. Send_Amount] = SUM(ISNULL(sendAmtDom,0)),

			[D. Paid_No. of Txn] = SUM(ISNULL(paidCountDom,0)),
			[D. Paid_Amount] = SUM(ISNULL(paidAmtDom,0)),

			[D. Cancel_No. of Txn] = SUM(ISNULL(cancelCountDom,0)),
			[D. Cancel_Amount] = SUM(ISNULL(cancelAmtDom,0)),
					
			--epTxnCount = SUM(ISNULL(epCount,0)),
			--epTxnAmt = SUM(ISNULL(epAmt,0)),

			--poTxnCount = SUM(ISNULL(poCount,0)),
			--poTxnAmt = SUM(ISNULL(poAmt,0)),

			[Total Amount] = SUM(ISNULL(paidAmtIntl,0)) - SUM(ISNULL(sendAmtDom,0)) + SUM(ISNULL(paidAmtDom,0)) + SUM(ISNULL(cancelAmtDom,0)) 
							- SUM(ISNULL(epAmt,0)) + SUM(ISNULL(poAmt,0))
		FROM @temp_table t LEFT JOIN dbo.agentTable at WITH(NOLOCK) ON T.branchId = at.map_code
		GROUP BY txnDate,branchId,at.agent_name

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value UNION
		SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value union 
		SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @agentId),'All')  
	
		SELECT title = @Title

		--SELECT 
		--	[SN] = ROW_NUMBER()OVER(ORDER BY txnDate,branchId),
		--	[Date] = txnDate,
		--	branchName = at.agent_name,
		--	paidTxnCountIntl = SUM(ISNULL(paidCountIntl,0)),
		--	paidTxnAmtIntl = SUM(ISNULL(paidAmtIntl,0)),

		--	sendTxnCountDom = SUM(ISNULL(sendCountDom,0)),
		--	sendTxnAmtDom = SUM(ISNULL(sendAmtDom,0)),

		--	paidTxnCountDom = SUM(ISNULL(paidCountDom,0)),
		--	paidTxnAmtDom = SUM(ISNULL(paidAmtDom,0)),

		--	cancelTxnCountDom = SUM(ISNULL(cancelCountDom,0)),
		--	cancelTxnAmtDom = SUM(ISNULL(cancelAmtDom,0)),
					
		--	epTxnCount = SUM(ISNULL(epCount,0)),
		--	epTxnAmt = SUM(ISNULL(epAmt,0)),

		--	poTxnCount = SUM(ISNULL(poCount,0)),
		--	poTxnAmt = SUM(ISNULL(poAmt,0)),

		--	totAmt = SUM(ISNULL(paidAmtIntl,0)) - SUM(ISNULL(sendAmtDom,0)) + SUM(ISNULL(paidAmtDom,0)) + SUM(ISNULL(cancelAmtDom,0)) 
		--					- SUM(ISNULL(epAmt,0)) + SUM(ISNULL(poAmt,0))
		--FROM @temp_table t LEFT JOIN dbo.agentTable at WITH(NOLOCK) ON T.branchId = at.map_code
		--GROUP BY txnDate,branchId,at.agent_name

END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
     PRINT ERROR_LINE()
END CATCH




GO
