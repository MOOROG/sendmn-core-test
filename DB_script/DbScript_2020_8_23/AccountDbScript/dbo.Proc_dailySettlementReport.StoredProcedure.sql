USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[Proc_dailySettlementReport]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*

-----menu script


EXEC Proc_dailySettlementReport
@flag='dsr',
@FROMDATE='2015-7-20',
@TODATE='2015-7-20'




*/

create PROC [dbo].[Proc_dailySettlementReport]     
( 	  
	  @flag			varchar(10)  =NULL
	 ,@FROMDATE		VARCHAR(10)  =NULL 
	 ,@TODATE		VARCHAR(10)  =NULL   
	 ,@ICN			VARCHAR(20)  =NULL
	 ,@S_AGENT		VARCHAR(20)	 =NULL
	 ,@MESSAGE		VARCHAR(100) =NULL
)    
AS   
SET NOCOUNT ON;  

if @flag='dsr'
BEGIN
	
			IF OBJECT_ID(N'tempdb..#TEMPREPORT') IS NOT NULL
				DROP TABLE #TEMPREPORT

	
			SELECT 					
		 				
			 PAID_DATE	=	CONVERT(VARCHAR,PAID_DATE,101)		
			,REMARKS	=	'Paid(+)'  
			,SN			=	1
			,TXN		=	COUNT(*)	
			,PAYOUTAMT	=	SUM(P_AMT_ACT)
			,PAMT		=	SUM(P_AMT)			
			,PAYOUTUSD	=	SUM(ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2))		
			,COMUSD		=	SUM( ROUND(CAST(ROUND(AGENT_RECEIVERSCOMMISSION/SCURRCOSTRATE ,2) AS MONEY),2))	
			,FXUSD		=	SUM(	
				 	
							ROUND((ROUND(CAST(ROUND(
							( ROUND(CAST(S_AMT AS MONEY),2) ---COLLECTION
							-ROUND(ISNULL(CAST(SC_TOTAL AS MONEY),0),2) ----SERVICE FEE
							-ROUND(CAST((ROUND(CASE WHEN S_AGENT ='10100000'  THEN 0 ELSE ISNULL(AGENT_EX_GAIN,0)END ,2 )) AS MONEY),2) ---AGENT FX
							 ) /(CASE WHEN S_CURR='USD' THEN 1.00 ELSE ISNULL(SCURRCOSTRATE,0) END) ,2) AS MONEY),2)
							-
 					
							ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2))* (CASE WHEN (S_COUNTRY='SAUDI ARABIA' AND TRN_TYPE='CASH PAY') THEN 0.15 ELSE 0.1 END),2)
				 	
		 ) 					
		INTO #TEMPREPORT				 
		FROM REMIT_TRN_MASTER  R WITH (NOLOCK) 					
		WHERE S_AGENT IN ('10100000','33300082')					
		AND  TRN_DATE>='2015-06-18'					
		AND PAID_DATE   BETWEEN @FROMDATE AND @TODATE+' 23:59:59:998'					
		GROUP BY  CONVERT(VARCHAR,PAID_DATE,101)					
					
		UNION ALL
 					
		SELECT 					
			 PAID_DATE	=	CONVERT(VARCHAR,CAST(REV_ManualVouDate AS DATE),101)		
			,REMARKS	=	'Cancel(-)'  
			,SN			=	2
			,TXN		=	COUNT(*)*-1	
			,PAYOUTAMT	=	SUM(P_AMT_ACT)	*-1	
			,PAMT		=	SUM(P_AMT)	*-1
			,PAYOUTUSD	=	SUM(ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2))*-1		
			,COMUSD		=	SUM( ROUND(CAST(ROUND(AGENT_RECEIVERSCOMMISSION/SCURRCOSTRATE ,2) AS MONEY),2))	*-1
			,FXUSD		=	SUM(	
				 	
							ROUND((ROUND(CAST(ROUND(
							( ROUND(CAST(S_AMT AS MONEY),2) ---COLLECTION
							-ROUND(ISNULL(CAST(SC_TOTAL AS MONEY),0),2) ----SERVICE FEE
							-ROUND(CAST((ROUND(CASE WHEN S_AGENT ='10100000'  THEN 0 ELSE ISNULL(AGENT_EX_GAIN,0)END ,2 )) AS MONEY),2) ---AGENT FX
							 ) /(CASE WHEN S_CURR='USD' THEN 1.00 ELSE ISNULL(SCURRCOSTRATE,0) END) ,2) AS MONEY),2)
							-
 					
							ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2))* (CASE WHEN (S_COUNTRY='SAUDI ARABIA' AND TRN_TYPE='CASH PAY') THEN 0.15 ELSE 0.1 END),2)
				 	
		 ) 					*-1
					 
		FROM REMIT_TRN_MASTER  R WITH (NOLOCK)
		INNER JOIN  ErroneouslyPaymentNew E WITH (NOLOCK) 	ON R.tranno=E.TRANNO
		WHERE S_AGENT IN ('10100000','33300082')					
		AND  TRN_DATE>='2015-06-18'					
		AND CAST(REV_ManualVouDate AS DATE)   BETWEEN @FROMDATE AND @TODATE+' 23:59:59:998'					
		GROUP BY  CONVERT(VARCHAR,CAST(REV_ManualVouDate AS DATE),101)					

					
		UNION ALL
 					
		SELECT 					
			 PAID_DATE	=	CONVERT(VARCHAR,CAST(REV_ManualVouDate AS DATE),101)		
			,REMARKS	=	'Cancel Old(-)'  
			,SN			=	3
			,TXN		=	COUNT(*)*-1	
			,PAYOUTAMT	=	SUM(P_AMT_ACT)	*-1	
			,PAMT		=	SUM(P_AMT)	*-1
			,PAYOUTUSD	=	SUM(ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2))*-1		
			,COMUSD		=	SUM( ROUND(CAST(ROUND(AGENT_RECEIVERSCOMMISSION/SCURRCOSTRATE ,2) AS MONEY),2))	*-1
			,FXUSD		=	0
					 
		FROM REMIT_TRN_MASTER  R WITH (NOLOCK)
		INNER JOIN  ErroneouslyPaymentNew E WITH (NOLOCK) 	ON R.tranno=E.TRANNO
		WHERE S_AGENT IN ('10100000','33300082')					
		AND  TRN_DATE<'2015-06-18'					
		AND CAST(REV_ManualVouDate AS DATE)   BETWEEN @FROMDATE AND @TODATE+' 23:59:59:998'					
		GROUP BY  CONVERT(VARCHAR,CAST(REV_ManualVouDate AS DATE),101)					
					
		UNION ALL
 					
		SELECT 					
			 PAID_DATE	=	CONVERT(VARCHAR,CANCEL_DATE,101)		
			,REMARKS	=	'Cancel Old(-)'  
			,SN			=	3
			,TXN		=	COUNT(*)*-1	
			,PAYOUTAMT	=	SUM(P_AMT_ACT)	*-1	
			,PAMT		=	SUM(P_AMT)	*-1
			,PAYOUTUSD	=	SUM(ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2))*-1		
			,COMUSD		=	SUM( ROUND(CAST(ROUND(AGENT_RECEIVERSCOMMISSION/SCURRCOSTRATE ,2) AS MONEY),2))	*-1
			,FXUSD		=	0
					 
		FROM REMIT_TRN_MASTER  R WITH (NOLOCK)
		WHERE S_AGENT IN ('10100000','33300082')					
		AND  TRN_DATE<'2015-06-18'					
		AND CANCEL_DATE   BETWEEN @FROMDATE AND @TODATE+' 23:59:59:998'					
		GROUP BY  CONVERT(VARCHAR,CANCEL_DATE,101)					



	SELECT   
		SN,DT DATE,	REMARKS	,TXN,  ROUND(PAYOUTAMT,0) [Receivable NPR], ROUND(PAMT,0) [Payable NPR],[Receivable USD],[Comm. USD],[FX USD],  [Settlement USD]
	FROM(				
	SELECT 	SN,PAID_DATE DT,	REMARKS	,TXN, PAYOUTAMT,PAMT
	,PAYOUTUSD [Receivable USD],COMUSD [Comm. USD],FXUSD [FX USD],  (PAYOUTUSD+COMUSD+FXUSD) [Settlement USD]
	 FROM #TEMPREPORT
	 UNION ALL
	SELECT 	SN,'Sub Total',	REMARKS	,SUM(TXN), SUM(PAYOUTAMT),SUM(PAMT)
	,SUM(PAYOUTUSD),SUM(COMUSD),SUM(FXUSD),SUM(PAYOUTUSD+COMUSD+FXUSD) 
	 FROM #TEMPREPORT GROUP BY SN,REMARKS
	 UNION ALL
	SELECT 	9 SN,'Grand Total',	'Net Settlement'	,SUM(TXN), SUM(PAYOUTAMT),SUM(PAMT)
	,SUM(PAYOUTUSD),SUM(COMUSD),SUM(FXUSD),SUM(PAYOUTUSD+COMUSD+FXUSD) 
	 FROM #TEMPREPORT  
	) Z ORDER BY SN ,DT	

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head, CONVERT(VARCHAR(10), @FROMDATE, 101) value UNION
		SELECT 'To Date' head, CONVERT(VARCHAR(10), @TODATE, 101) 
  
		SELECT title = 'Daily Settlement Report'
	END
	
		

if @flag='icn'
BEGIN

			 SELECT @S_AGENT=S_AGENT FROM REMIT_TRN_MASTER WITH (NOLOCK) WHERE TRN_REF_NO=DBO.encryptDbLocal(@ICN)
			 IF @S_AGENT IS NULL
			 SELECT  @MESSAGE=  'ICN:' + @ICN + ' does not exists.'
			 IF ( @S_AGENT <>  '10100000' OR @S_AGENT <> '33300082') 
			 SELECT  @MESSAGE=  'ICN:' + @ICN + ' does not belongs to CES '
			 IF ( @S_AGENT =  '10100000' OR @S_AGENT = '33300082') 
			 SELECT  @MESSAGE='Ok'  
 
			IF  @MESSAGE <>'Ok'

			BEGIN 
				SELECT 'Error' AS msg

				EXEC proc_errorHandler '1', @MESSAGE, NULL

				SELECT 'ICN' head, CONVERT(VARCHAR(10), @ICN, 101) 
  
				SELECT title = 'Individual Txn Report'
				--SELECT 1 AS error, @MESSAGE AS 'msg'
			RETURN
			END 
   
			SELECT 0 AS ERROR, @ICN ICN,TRN_DATE [TXN Date], [Receivable NPR],[Payable NPR]	,[Receivable USD] ,[Comm. USD],[FX USD]	,([Receivable USD]+[Comm. USD]+[FX USD]	) [Settlement USD]
			FROM(				
			SELECT 					
				TRN_DATE	
				, [Receivable NPR]	=	P_AMT_ACT 	
				,[Payable NPR]		=	P_AMT 
				,[Receivable USD]	=	ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2) 		
				,[Comm. USD]		=	ROUND(CAST(ROUND(AGENT_RECEIVERSCOMMISSION/SCURRCOSTRATE ,2) AS MONEY),2) 	
				,[FX USD]			=	CASE WHEN TRN_DATE	>='2015-06-18'	 THEN 
				 	
								ROUND((ROUND(CAST(ROUND(
								( ROUND(CAST(S_AMT AS MONEY),2) ---COLLECTION
								-ROUND(ISNULL(CAST(SC_TOTAL AS MONEY),0),2) ----SERVICE FEE
								-ROUND(CAST((ROUND(CASE WHEN S_AGENT ='10100000'  THEN 0 ELSE ISNULL(AGENT_EX_GAIN,0)END ,2 )) AS MONEY),2) ---AGENT FX
								 ) /(CASE WHEN S_CURR='USD' THEN 1.00 ELSE ISNULL(SCURRCOSTRATE,0) END) ,2) AS MONEY),2)
								-
 					
								ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2))* (CASE WHEN (S_COUNTRY='SAUDI ARABIA' AND TRN_TYPE='CASH PAY') THEN 0.15 ELSE 0.1 END),2)
								ELSE 0 END 		 	
 				
					 
			FROM REMIT_TRN_MASTER  R WITH (NOLOCK) 					
			WHERE TRN_REF_NO=DBO.encryptDbLocal(@ICN)
			) Z									
	
				EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

				SELECT 'ICN' head, CONVERT(VARCHAR(10), @ICN, 101) 
  
				SELECT title = 'Individual Txn Report'
	END	






GO
