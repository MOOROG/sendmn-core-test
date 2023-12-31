USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Remittance_Payable_v2]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[Proc_Remittance_Payable_v2]  
(  
     @sAgent VARCHAR (100) = NULL  
    ,@fromDate VARCHAR (10) = NULL  
    ,@toDate VARCHAR (10) = NULL  
    ,@rptType CHAR(1) = NULL  
 ,@user  VARCHAR(50) = NULL  
)  
AS   
SET NOCOUNT ON;  
   
IF @rptType='S'   
BEGIN  
  -- ## GLOBAL API TXN  
  if @SAGENT = '33300007'  
  BEGIN  
   SELECT [S.N.] = row_number() over(order by [Agent Name] desc),* FROM   
   (  
   /*  
    SELECT   
      [Agent Name] = UPPER(AGENT_NAME),  
      [Particulars] = TRN_TYPE+'- Korea',    
      [No. of Txn.] = COUNT(TRANNO),  
      [Amount] = SUM ( P_AMT),  
      [Commission] = CASE   
           WHEN S_AGENT='12500000' THEN ROUND ( SUM ( ROUND(ISNULL( agent_receiverSCommission,0)/ (case when EX_USD=0 then 1 else EX_USD end),4,1)),2)   
            ELSE ROUND(SUM(ROUND ( sc_ho/(case when EX_USD=0 then 1 else EX_USD end),4,1)), 2 )   
          END  
     FROM REMIT_TRN_MASTER R WITH(NOLOCK)  
     INNER JOIN agentTable A WITH(NOLOCK) ON R .S_AGENT = A.map_code  
     WHERE TRN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'  
      AND R.S_AGENT = '33300007'  
      AND s_country = 'Korea'  
     GROUP BY AGENT_NAME,S_AGENT,TRN_TYPE  
  
    UNION ALL  
  
    SELECT   
      [Agent Name] = UPPER(AGENT_NAME),  
      [Particulars] = TRN_TYPE+'- United Arab Emirates',    
      [No. of Txn.] = COUNT(TRANNO),  
      [Amount] = SUM ( P_AMT),  
      [Commission] = CASE   
           WHEN S_AGENT='12500000' THEN ROUND ( SUM ( ROUND(ISNULL( agent_receiverSCommission,0)/ (case when EX_USD=0 then 1 else EX_USD end),4,1)),2)   
            ELSE ROUND(SUM(ROUND ( sc_ho/(case when EX_USD=0 then 1 else EX_USD end),4,1)), 2 )   
          END  
     FROM REMIT_TRN_MASTER R WITH(NOLOCK)  
     INNER JOIN agentTable A WITH(NOLOCK) ON R .S_AGENT = A.map_code  
     WHERE TRN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'  
      AND R.S_AGENT = '33300007'  
      AND s_country = 'United Arab Emirates'  
     GROUP BY AGENT_NAME,S_AGENT,TRN_TYPE  
  
    UNION ALL  
    */  
     SELECT   
      [Agent Name] = UPPER(AGENT_NAME),  
      [Particulars] = TRN_TYPE+'- India',    
      [No. of Txn.] = COUNT(TRANNO),  
      [Amount] = SUM ( P_AMT),  
      [Commission] = CASE   
           WHEN S_AGENT='12500000' THEN ROUND ( SUM ( ROUND(ISNULL( agent_receiverSCommission,0)/ (case when EX_USD=0 then 1 else EX_USD end),4,1)),2)   
            ELSE ROUND(SUM(ROUND ( sc_ho/(case when EX_USD=0 then 1 else EX_USD end),4,1)), 2 )   
          END  
     FROM REMIT_TRN_MASTER R WITH(NOLOCK)  
     INNER JOIN agentTable A WITH(NOLOCK) ON R .S_AGENT = A.map_code  
     WHERE TRN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'  
      AND R.S_AGENT = '33300007'  
      AND s_country = 'India'  
     GROUP BY AGENT_NAME,S_AGENT,TRN_TYPE  
    UNION ALL  
  
    SELECT   
      [Agent Name] = UPPER(AGENT_NAME),  
      [Particulars] = TRN_TYPE+'-  UAE Exchange Center LLC',    
      [No. of Txn.] = COUNT(TRANNO),  
      [Amount] = SUM ( P_AMT),  
      [Commission] = CASE   
           WHEN S_AGENT='12500000' THEN ROUND ( SUM ( ROUND(ISNULL( agent_receiverSCommission,0)/ (case when EX_USD=0 then 1 else EX_USD end),4,1)),2)   
            ELSE ROUND(SUM(ROUND ( sc_ho/(case when EX_USD=0 then 1 else EX_USD end),4,1)), 2 )   
          END  
    FROM REMIT_TRN_MASTER R WITH ( NOLOCK)  
    INNER JOIN DBO.agentTable A WITH (NOLOCK) ON R .S_AGENT =A.map_code  
    WHERE TRN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'  
     AND R.S_AGENT = '33300007'  
     AND s_country = 'United Arab Emirates' 
     AND SC_P_AGENT = 50  
    GROUP BY AGENT_NAME,S_AGENT,TRN_TYPE  
  
    UNION ALL  
     SELECT   
      [Agent Name] = UPPER(AGENT_NAME),  
      [Particulars] = TRN_TYPE+'- Worldwide',    
      [No. of Txn.] = COUNT(TRANNO),  
      [Amount] = SUM ( P_AMT),  
      [Commission] = CASE   
WHEN S_AGENT='12500000' THEN ROUND ( SUM ( ROUND(ISNULL( agent_receiverSCommission,0)/ (case when EX_USD=0 then 1 else EX_USD end),4,1)),2)   
            ELSE ROUND(SUM(ROUND ( sc_ho/(case when EX_USD=0 then 1 else EX_USD end),4,1)), 2 )   
          END  
     FROM REMIT_TRN_MASTER R WITH ( NOLOCK)  
     INNER JOIN agentTable A WITH (NOLOCK) ON R .S_AGENT =A.map_code  
     WHERE 
      (TRN_DATE BETWEEN @fromDate and  @toDate + ' 23:59:59'  
      AND R.S_AGENT = '33300007' 
      AND SC_P_AGENT <> 50) OR (TRN_DATE BETWEEN @fromDate and  @toDate + ' 23:59:59'   
     and R.S_AGENT = '33300007'      
     and isnull(s_country,'World Wide') not in ( 'India' ,'World Wide','United Arab Emirates') 
       AND SC_P_AGENT = 50  )
     GROUP BY AGENT_NAME,S_AGENT,TRN_TYPE  
     
     
   )x  
   ORDER BY [Agent Name] DESC  
  END  
  ELSE  
  BEGIN   
   SELECT   
    [S.N.]   = row_number() over(order by AGENT_NAME, TRN_TYPE desc),  
    [Agent Name] = UPPER( AGENT_NAME),  
    [Particulars] = TRN_TYPE,  
    [No. of Txn.] = COUNT(TRANNO),  
    [Amount]  = SUM ( P_AMT),  
    [Commission] = ISNULL(CASE   
          WHEN S_AGENT='12500000' THEN ROUND ( SUM ( ROUND(ISNULL( agent_receiverSCommission,0)/(case when EX_USD=0 then 1 else EX_USD end),4,1)),2)   
          ELSE ROUND(SUM(ROUND ( sc_ho/(case when EX_USD=0 then 1 else EX_USD end),4,1)), 2 )   
             END,0)   
   FROM REMIT_TRN_MASTER R WITH(NOLOCK)  
   INNER JOIN agentTable A WITH(NOLOCK) ON R .S_AGENT =A.map_code  
   WHERE TRN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'  
    AND R.S_AGENT = ISNULL(@sAgent,R.S_AGENT)  
   GROUP BY AGENT_NAME,S_AGENT,TRN_TYPE  
   ORDER BY AGENT_NAME, TRN_TYPE DESC  
  END  
END  
   
IF @rptType='D'   
BEGIN  
 SELECT   
     [S.N.]    = row_number() over(order by AGENT_NAME, TRN_TYPE DESC),  
  [AGENT]    = UPPER(AGENT_NAME),  
  [DATE]    = TRN_DATE,  
  [CONTROL NO.]  = DBO.decryptDb(TRN_REF_NO),  
  [SENDER NAME]  = UPPER(SENDER_NAME),   
  [RECEIVER NAME]  = UPPER(RECEIVER_NAME),   
  [PAYMENT TYPE]  = TRN_TYPE,   
  [AMOUNT]   = P_AMT,  
  [COMMISSION]  = CASE WHEN S_AGENT='12500000' THEN ROUND (( ROUND(ISNULL( agent_receiverSCommission,0)/ (case when EX_USD=0 then 1 else EX_USD end),4,1)),2) ELSE ROUND((ROUND ( sc_ho/ (case when EX_USD=0 then 1 else EX_USD end),4,1)), 2 ) END  
 FROM REMIT_TRN_MASTER R WITH ( NOLOCK)INNER JOIN agentTable A WITH (NOLOCK )  
 ON R .S_AGENT =A.map_code  
 WHERE TRN_DATE BETWEEN @fromDate AND @toDate + ' 23:59:59'  
 and R.S_AGENT = ISNULL(@sAgent,R.S_AGENT)  
 ORDER BY AGENT_NAME, TRN_TYPE DESC  
END  
  
EXEC SendMnPro_Remit.dbo.proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value UNION ALL  
SELECT  'Sending Agent' head, case when @sAgent is null then 'All' else (SELECT agent_name FROM dbo.agentTable WITH(NOLOCK) WHERE map_code = @sAgent) end value UNION ALL  
SELECT  'Report Type' head, case when @rptType ='S' then 'Summary' else 'Detail' end value  
SELECT 'Remittance Payable Report' title  
RETURN



GO
