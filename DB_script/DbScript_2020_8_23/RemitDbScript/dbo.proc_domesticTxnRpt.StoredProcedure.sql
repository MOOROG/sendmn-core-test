ALTER  PROCEDURE [dbo].[proc_domesticTxnRpt]
@flag			VARCHAR(10),
@user			VARCHAR(50),
@fromDate		VARCHAR(10),
@toDate			VARCHAR(10)

AS 
SET NOCOUNT ON;	
  ----SELECT @fromDate='2014-04-15',@toDate='2014-04-15',@flag='summary'		
		  		
BEGIN 		
				
	IF @flag='d'			
	BEGIN			
		SELECT UPPER(A.AGENT_NAME) AGENT, 		
			  SUM(S_TXN) SEND_TXN,
			  SUM(S_AMT) SEND_AMT,
			  SUM(S_SC) SEND_SC, 		
			  SUM(P_TXN) PAID_TXN, 
			  SUM(P_AMT) PAID_AMT, 
			  SUM(P_RC) PAID_RC,		
			  SUM(C_TXN) [SAME DAY CANCEL_TXN], 
			  SUM(C_AMT) [SAME DAY CANCEL_AMT], 
			  SUM(TXN) [NEXT DAY CANCEL_TXN], 
			  SUM(samt) [NEXT DAY CANCEL_AMT] 		
		FROM (		
			SELECT S_AGENT ,
			COUNT(TRN_REF_NO) S_TXN,	
			SUM(s_Amt)  S_AMT,	
			SUM(ISNULL(s_sc,0))  S_SC,
			0 P_TXN, 0 P_AMT, 0 P_RC,		
			0 C_TXN, 0 C_AMT, 0 TXN, 0 samt		
		FROM		
		 (
			SELECT  ISNULL (AT.central_sett_code,map_code)   S_AGENT,  TRN_REF_NO , S_Amt ,total_sc,s_sc,p_amt,R_sc		
			FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK) 
		    RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH (NOLOCK) ON	R.S_AGENT=AT.AGENT_IME_CODE
			WHERE  confirm_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
		) X	
		GROUP BY S_AGENT 		
				
		UNION ALL		
				
		SELECT R_AGENT,0,0,0,COUNT(TRN_REF_NO) TXN,	SUM(P_AMT) PAYOUT, SUM(r_sc)  PCOM,0,0,0,0	
		FROM		
		 (
			SELECT  ISNULL (AT.central_sett_code,map_code)   R_AGENT,  TRN_REF_NO ,r_sc,p_amt		
			FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)  
			RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH (NOLOCK) ON	R.R_AGENT=AT.AGENT_IME_CODE
			WHERE  P_DATE   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
		) X	
		GROUP BY R_AGENT 		
		 		
		UNION ALL		
				
		SELECT S_AGENT,0,0,0,0,0,0,COUNT(TRN_REF_NO) C_TXN ,SUM(S_AMT) C_AMT  ,	  0  ,0  
		FROM		
		 (
			SELECT  ISNULL (AT.central_sett_code,map_code)   S_AGENT,  TRN_REF_NO ,  S_AMT		
			FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)  
			RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH(NOLOCK) ON	R.S_AGENT=AT.AGENT_IME_CODE
			WHERE cancel_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
			AND CAST(CANCEL_DATE AS DATE)=CAST(CONFIRM_DATE AS DATE) 	
		) X	
		GROUP BY S_AGENT 		
				
		UNION ALL		
		SELECT  S_AGENT,0,0,0,0,0,0,0 C_TXN , 0 C_AMT  , COUNT(TRN_REF_NO)	TXN, SUM(P_AMT+R_sc) samt 	
		FROM		
		 (
			SELECT  ISNULL (AT.central_sett_code,map_code)   S_AGENT,  TRN_REF_NO , 	p_amt , R_SC	
			FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)  
			RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH (NOLOCK) ON 	R.S_AGENT=AT.AGENT_IME_CODE
			WHERE cancel_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
			AND CAST(CANCEL_DATE AS DATE)<>CAST(CONFIRM_DATE AS DATE)	
		) X	
		GROUP BY S_AGENT 		
		) Z, SendMnPro_Account.dbo.AGENTTABLE A WITH (NOLOCK) WHERE Z.S_AGENT=A.MAP_CODE		
		GROUP BY AGENT_NAME		
		ORDER BY AGENT_NAME		
				
	END					
	IF @flag='s' 			
	BEGIN			
				
	SELECT 'Txn Send' particulars
		,COUNT(TRN_REF_NO) TXN
		,SUM(p_AMT) AMT
		,SUM(S_SC) SC
		,SUM(r_SC) RC
		,SUM(ISNULL(total_sc,0) - ISNULL(s_sc,0)-ISNULL(R_sc,0)) HO
		,SUM(p_AMT+ISNULL(total_sc,0)) TOTAL 		
		FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)   			
		WHERE  confirm_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	

	UNION ALL			
	SELECT 'Send Today Paid Today' particulars,	COUNT(TRN_REF_NO) S_TXN, SUM(P_AMT) S_AMT, 0 S_SC, SUM(ISNULL(r_SC,0)) R_SC, 0 S_HO ,SUM(P_AMT +ISNULL(R_SC,0)) TOTAL		
		FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)   			
		WHERE  p_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
		AND CAST (P_DATE AS DATE)=CAST (CONFIRM_DATE AS DATE) 	

	UNION ALL			
	SELECT 'Send Yesterday Paid Today' particulars,	COUNT(TRN_REF_NO) S_TXN, SUM(P_AMT) S_AMT,0 S_SC, SUM(r_SC) R_SC, 0 S_HO,SUM(P_AMT +ISNULL(R_SC,0)) TOTAL		
			FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)  
			RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH (NOLOCK) ON	R.S_AGENT=AT.AGENT_IME_CODE		
			WHERE  p_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
			AND CAST (P_DATE AS DATE)<>CAST (CONFIRM_DATE AS DATE) 	

	UNION ALL			
	SELECT 'Send Today Cancel Today' particulars,	COUNT(TRN_REF_NO) TXN, SUM(P_AMT) AMT, 		
		   SUM(S_SC) S_SC, SUM(ISNULL(R_SC,0)) R_SC, SUM(ISNULL(total_sc,0) - ISNULL(s_sc,0)-ISNULL(R_sc,0)) S_HO			
		   ,SUM(P_AMT +ISNULL(total_sc,0)) TOTAL			
	        FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)  
			RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH (NOLOCK) ON	R.S_AGENT=AT.AGENT_IME_CODE		
			WHERE  cancel_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
			AND CAST (cancel_date AS DATE)=CAST (CONFIRM_DATE AS DATE) 	

	UNION ALL			
	SELECT 'Send Yesterday Cancel Today' particulars,	COUNT(TRN_REF_NO) TXN, SUM(P_AMT) AMT, 		
			0 S_SC, SUM(ISNULL(R_SC,0)) R_SC, 0 S_HO,SUM(P_AMT +ISNULL(r_sc,0)) total			
			FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)  
			RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH (NOLOCK) ON	R.S_AGENT=AT.AGENT_IME_CODE		
			WHERE  cancel_date   BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
			AND CAST (cancel_date AS DATE)<>CAST (CONFIRM_DATE AS DATE) 	
				
	UNION ALL			
				
	SELECT 'Send Today Not Paid Today' particulars,	COUNT(TRN_REF_NO) TXN, SUM(P_AMT) AMT, 		
			0 S_SC, 0 R_SC, 0 S_HO,0 total			
			FROM SendMnPro_Account.dbo.REMIT_TRN_local R  WITH (NOLOCK)  
			RIGHT JOIN SendMnPro_Account.dbo.agentTable AT WITH (NOLOCK) ON	R.S_AGENT=AT.AGENT_IME_CODE		
			WHERE  confirm_date  BETWEEN @fromDate AND @toDate + ' 23:59:59:998'	
				AND( 
				  (PAY_STATUS ='Paid' and P_DATE >  @toDate + ' 23:59:59:998' )
			 OR   (PAY_STATUS  in ('Un-Paid','Payment')  and TRN_STATUS <>'Cancel')	
			 OR	  (TRN_STATUS ='Cancel' and CANCEL_DATE >  @toDate + ' 23:59:59:998' )
			 )	
				
	END	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value

	SELECT Title = CASE WHEN @flag = 'd' THEN 'Domestic Ac TXN Report Detail' ELSE 'Domestic Ac TXN Report Summary' END		
END



GO
