USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SETTLEMENT_REPORT]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

Exec PROC_SETTLEMENT_REPORT @FLAG='m', 
@AGENT='33300379',@DATE1='09/29/2012',@DATE2='10/01/2012',@BRANCH='33300379',
@USER='gibbaglung123'


	Exec PROC_SETTLEMENT_REPORT @FLAG='m2', 
		@AGENT='33300134',@DATE1='2012-11-04',@DATE2='2012-11-04',@BRANCH=Null 

Exec PROC_SETTLEMENT_REPORT @FLAG='PAY_COUNTRY', 
    @AGENT='33422706',@DATE1='1/7/2013',@DATE2='1/7/2013',@BRANCH='33422706' 

Exec PROC_SETTLEMENT_REPORT @FLAG='SEND_USER_D', 
    @AGENT='33300134',@DATE1='09/01/2012',@DATE2='09/07/2012',@BRANCH='12801300' 

Exec PROC_SETTLEMENT_REPORT @FLAG='PAY_USER_D', 
    @AGENT='33300134',@DATE1='09/01/2012',@DATE2='09/07/2012',@BRANCH='12801300' 

Exec PROC_SETTLEMENT_REPORT @FLAG='CANCEL_USER_D', 
    @AGENT='33300134',@DATE1='09/01/2012',@DATE2='09/07/2012',@BRANCH='12801300' 


select map_code, agent_name from agentTable where central_sett_code ='33300134' 


*/

CREATE PROC [dbo].[PROC_SETTLEMENT_REPORT]
     @FLAG VARCHAR(50)
    ,@AGENT VARCHAR(20)
    ,@BRANCH VARCHAR(20)= null
    ,@DATE1 VARCHAR(20)
    ,@DATE2 VARCHAR(20)
    ,@USER VARCHAR(20)=null
    ,@COUNTRY VARCHAR(200)=null

AS

SET NOCOUNT ON;
DECLARE @isCentSett varchar(20), @commCode varchar(20)
DECLARE @LastCharInDomTxn CHAR(1) = dbo.FNALastCharInDomTxn()

set @DATE2 = REPLACE(@DATE2,' 23:59:59','')
set @DATE2=@DATE2 +' 23:59:59'


/*

DECLARE 
	 @AGENT VARCHAR(20)='18100000' 
	 --  @AGENT VARCHAR(20)='10300300' 
	  --,@BRANCH VARCHAR(20)='33415841'
	  ,@BRANCH VARCHAR(20)= null
	  ,@DATE1 VARCHAR(20)='2012-8-1'
	  ,@DATE2 VARCHAR(20)='2012-9-1 23:59'
	  ,@isCentSett varchar(20)
*/


    select  
	   @isCentSett = isnull(central_sett,'n'), @commCode= map_code2  
    from agentTable with (nolock) where map_code =@AGENT


if @FLAG ='PAY_COUNTRY'
BEGIN

     SELECT '' DT, isnull(S_COUNTRY, 'Worldwide Others') S_COUNTRY,
	   '<a href="sett_drilldown_user.asp?flag=PAY_USER&BRANCH='+ 
	   CAST(@BRANCH AS VARCHAR)+'&AGENT='+ CONVERT(VARCHAR,@AGENT, 101 )+
	   '&DATE1='+ CONVERT (VARCHAR,@DATE1, 101 )+
	   '&COUNTRY='+ isnull(S_COUNTRY, 'Worldwide Others') +'&DATE2='+ CONVERT (VARCHAR,@DATE2, 101 )+
	    '">'+ isnull(S_COUNTRY, 'Worldwide Others') +' - '+ cast(sum(TXN) as varchar(20)) +'</a>' as Particulars, 
    sum(T.TXN) TXN, sum(T.AMT) AMT, isnull(sum(COMMISSION),'0.00')COMMISSION  FROM
    (
	   SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
		  , S_AGENT, S_COUNTRY  
		  ,COUNT ( TRN_REF_NO) TXN, SUM(P_AMT) AMT,  SUM(ISNULL(SC_P_AGENT,0)) COMMISSION ,TRN_TYPE
	   FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
	   WHERE 
		  case when @isCentSett ='y' then P_AGENT 
				else P_BRANCH end = @AGENT
	   and P_BRANCH = @BRANCH
	   AND PAID_DATE BETWEEN  @DATE1 AND @DATE2
      
	   GROUP BY CONVERT(VARCHAR , paid_date, 101) ,S_AGENT, TRN_TYPE, S_COUNTRY

    )T 
    GROUP BY T.S_COUNTRY
    ORDER BY T.S_COUNTRY 

END

if @FLAG ='PAY_USER'
begin

	  if @COUNTRY ='Worldwide Others'
	  SET @COUNTRY = null


       SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
		  , dbo.decryptDb(TRN_REF_NO)TRN_REF_NO
		  , UPPER(SENDER_NAME) as SENDER_NAME
		  , UPPER(RECEIVER_NAME) as RECEIVER_NAME
		  , P_AMT
		  , (ISNULL(SC_P_AGENT,0)) COMMISSION
		  , paidBy P_USER, S_COUNTRY
	   FROM REMIT_TRN_MASTER RTM WITH (NOLOCK), agentTable A
	   WHERE RTM.S_AGENT = A.map_code and
		  case when @isCentSett ='y' then P_AGENT 
			 else P_BRANCH end = @AGENT 
	   AND P_BRANCH = @BRANCH
	   AND S_COUNTRY= ISNULL(@COUNTRY,S_COUNTRY)
	   AND PAID_DATE BETWEEN @DATE1 AND @DATE2
	   Order by  paid_date desc

end

IF @FLAG ='SEND_USER_D'
BEGIN

	   SELECT CONVERT(VARCHAR , CONFIRM_DATE, 101) [Date],dbo.decryptDbLocal(TRN_REF_NO) Refno ,
		    UPPER(SENDER_NAME) as [Sender Name]
		  , UPPER(RECEIVER_NAME) as [Benificiary Name]
		  , S_AMT Amount,(ISNULL(S_SC,0)) [Comm.], SEMPID as [User] 
	   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
		  AND map_code = isnull(@BRANCH , map_code)
		  --AND SEMPID = ISNULL(@USER,SEMPID)
		  AND isnull(TranType,'') <> 'B'
		  Order by  CONFIRM_DATE DESC
          
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @DATE1, 101) value UNION
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @DATE2, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @AGENT),'All')  
		
	SELECT title = 'Domestic Send Report'
END

IF @FLAG ='PAY_USER_D'
BEGIN

	   SELECT CONVERT(VARCHAR , P_DATE, 101)DT ,
		   UPPER(SENDER_NAME) as SENDER_NAME
		  , UPPER(RECEIVER_NAME) as RECEIVER_NAME
		  ,dbo.decryptDbLocal(TRN_REF_NO) TRN_REF_NO, P_AMT, (ISNULL(R_SC,0)) COMMISSION ,paidBy as P_USER 
	   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND P_DATE BETWEEN @DATE1 AND @DATE2 
		  AND map_code = isnull(@BRANCH , map_code)
		  Order by  P_DATE DESC
          
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @DATE1, 101) value UNION
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @DATE2, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @AGENT),'All')  
		
	SELECT title = 'Domestic Pay Report'
END

IF @FLAG ='CANCEL_USER_D'
BEGIN

	   SELECT CONVERT(VARCHAR , CANCEL_DATE, 101)DT ,
		   UPPER(SENDER_NAME) as SENDER_NAME
		  , UPPER(RECEIVER_NAME) as RECEIVER_NAME
		  ,dbo.decryptDbLocal(TRN_REF_NO) TRN_REF_NO, CASE WHEN CAST(CONFIRM_DATE AS DATE) =CAST(CANCEL_DATE AS DATE) THEN  S_AMT ELSE P_AMT + ISNULL(R_SC,0) END  P_AMT
		  , CASE WHEN CAST(CONFIRM_DATE AS DATE) =CAST(CANCEL_DATE AS DATE) THEN ISNULL(S_SC,0) ELSE 0 END COMMISSION
		  ,isnull(CANCEL_USER,SEmpID) as P_USER 
	   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
		  AND map_code = isnull(@BRANCH , map_code)
		  --AND SEMPID = ISNULL(@USER,SEMPID)
		  Order by CANCEL_DATE DESC
          
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @DATE1, 101) value UNION
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @DATE2, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @AGENT),'All')  
		
	SELECT title = 'Domestic Cancel Report'

END

IF @FLAG ='ERR_USER_D'
BEGIN

    SELECT CONVERT (VARCHAR , EP_date, 101)DT , 
		ref_no as TRN_REF_NO,UPPER(SENDER_NAME) as SENDER_NAME
		  , UPPER(RECEIVER_NAME) as RECEIVER_NAME 
	   , SUM(EP.amount) P_AMT
	   , SUM(ISNULL(EP.EP_commission,0) ) COMMISSION ,EP_User P_USER 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_LOCAL RT WITH (NOLOCK)
    WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
    AND EP_AgentCode= @AGENT
    AND EP_BranchCode = @BRANCH 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn
    AND EP_date BETWEEN @DATE1 AND @DATE2
    GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,EP_User,CONVERT (VARCHAR , EP_date, 101)
	Order by DT DESC
    
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @DATE1, 101) value UNION
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @DATE2, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @AGENT),'All')  
		
	SELECT title = 'Domestic Error Report'

END

IF @FLAG ='PAYORD_USER_D'
BEGIN

    SELECT CONVERT (VARCHAR , PO_date, 101)DT , 
		ref_no as TRN_REF_NO, UPPER(SENDER_NAME) as SENDER_NAME
		  , UPPER(RECEIVER_NAME) as RECEIVER_NAME
	  	, SUM(EP.amount) P_AMT
	   , SUM(ISNULL(EP.PO_commission,0) ) COMMISSION ,PO_User P_USER 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_LOCAL RT WITH ( NOLOCK )
    WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
    AND PO_AgentCode= @AGENT
    AND PO_BranchCode = @BRANCH 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn
    AND PO_date BETWEEN @DATE1 AND  @DATE2
	GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,PO_User,CONVERT (VARCHAR , PO_date, 101)
	Order by DT DESC
    
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @DATE1, 101) value UNION
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @DATE2, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @AGENT),'All')  
		
	SELECT title = 'Domestic Pay Order Report'
	
END

IF @FLAG ='ERR_USER'
BEGIN

    SELECT CONVERT (VARCHAR , EP_date, 101)DT , 
		ref_no as TRN_REF_NO, UPPER(SENDER_NAME) as SENDER_NAME
		  , UPPER(RECEIVER_NAME) as RECEIVER_NAME 
		   , SUM(EP.amount) P_AMT
	   , SUM(ISNULL(EP.EP_commission,0) ) COMMISSION ,EP_User P_USER 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH (NOLOCK)
    WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
    AND EP_AgentCode= @AGENT
    AND EP_BranchCode = @BRANCH 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
    AND EP_date BETWEEN @DATE1 AND @DATE2
    GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,EP_User,CONVERT (VARCHAR , EP_date, 101)
	order by DT desc

END

IF @FLAG ='PAYORD_USER'
BEGIN

    SELECT CONVERT (VARCHAR , PO_date, 101)DT , 
		ref_no as TRN_REF_NO, UPPER(SENDER_NAME) as SENDER_NAME
		  , UPPER(RECEIVER_NAME) as RECEIVER_NAME 
	 	   , SUM( EP.amount) P_AMT
	   , SUM(ISNULL(EP.PO_commission,0) ) COMMISSION ,PO_User P_USER 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH ( NOLOCK )
    WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
    AND PO_AgentCode= @AGENT
    AND PO_BranchCode=@BRANCH
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn
    AND PO_date BETWEEN @DATE1 AND  @DATE2
    GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,PO_User,CONVERT (VARCHAR , PO_date, 101)
	order by DT desc
	
END

if @FLAG ='m'
begin
	   declare @USERVal varchar(200)
	   set @USERVal = ISNULL(@USER,'')
	   DECLARE @Title NVARCHAR(150) = 'Settlement Report'
	   SELECT 
		  P_BRANCH BRANCH , A.agent_name [Agent Name], Particulars,
		  TXN Txn, AMT Amount,isnull(COMMISSION,'0.00')COMMISSION
		  INTO #TEM1
	   FROM 
	   (    
		  --'<a href="soa_drilldown_report.asp?FLAG=PAY_BRANCH&AGENT='+
		  --CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,paid_date, 101 )+
		  --'&DATE2='+CONVERT ( VARCHAR,paid_date, 101 )+'">Paid - Int`l Remitt - '+
		  --CAST(COUNT('x') AS VARCHAR)+'</a>'

		  SELECT P_BRANCH,
			 '<a href="/AccountReport/Reports.aspx?FLAG=PAY_COUNTRY&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ P_BRANCH +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Int`l Remitt </a>' Particulars 
			 ,COUNT('x') TXN, SUM(P_AMT) AMT , SUM(ISNULL(SC_P_AGENT,0)) COMMISSION
		  FROM REMIT_TRN_MASTER RTM WITH ( NOLOCK) 
		  WHERE case when @isCentSett = 'y' then P_AGENT 
				    else P_BRANCH end=@AGENT 
		  AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
		  AND P_BRANCH = isnull(@BRANCH , P_BRANCH)
		  GROUP BY P_BRANCH

		  --UNION ALL

		  --SELECT  map_code, 
			 --'<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=SEND_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 --+'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 --'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Send - Domestic Remitt.</a>' Particulars 
			 --,COUNT('x') TXN, SUM(S_AMT)*-1 AMT, SUM(ISNULL(S_SC,0)) COMMISSION
		  --FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  --WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  --AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  --AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
		  --AND isnull(TranType,'') <> 'B'
		  --AND map_code = isnull(@BRANCH , map_code)
		  --GROUP BY map_code 
		  
		  --UNION ALL

		  --SELECT  map_code, 
			 --'Send - Domestic Remitt.' Particulars 
			 --,COUNT('x') TXN, SUM(S_AMT)*-1 AMT, SUM(ISNULL(S_SC,0)) COMMISSION
		  --FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  --WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  --AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  --AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
		  --AND isnull(TranType,'') = 'B'
		  --AND map_code = isnull(@BRANCH , map_code)
		  --GROUP BY map_code 

		  --UNION ALL 

		  --SELECT  map_code, 
			 --'<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=PAY_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 --+'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 --'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Domestic Remitt.</a>' Particulars 
			 --,COUNT('x') TXN, SUM(P_AMT) AMT , SUM(ISNULL(R_SC,0)) COMMISSION
		  --FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  --WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
		  --AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  --AND P_DATE BETWEEN @DATE1 AND @DATE2 
		  --AND map_code = isnull(@BRANCH , map_code)
		  --GROUP BY map_code 

		  --UNION ALL 

		  --SELECT  map_code, 
			 --'<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=CANCEL_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 --+'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 --'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Cancel - Domestic Remitt.</a>' Particulars 
			 --,COUNT('x') TXN, SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE)  THEN S_AMT ELSE P_AMT+ ISNULL(R_SC,0) END) AMT,
			 --SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE) THEN  ISNULL(S_SC,0) END) *-1 COMMISSION
		  --FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  --WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  --AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  --AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
		  --AND map_code = isnull(@BRANCH , map_code)

		  --GROUP BY map_code 

		  UNION ALL 

		   SELECT EP_BranchCode , '<a href="/AccountReport/Reports.aspx?FLAG=ERR_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid - Int`l</a>' Particulars 
			 ,COUNT('x') TXN
			 ,SUM (EP.amount)*-1 AMT 
			 ,SUM (EP.EP_commission)*-1 COMMISSION 
		   FROM ErroneouslyPaymentNew EP WITH (NOLOCK) 
		   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
		   AND RIGHT(ref_no,1)<>@LastCharInDomTxn
		   AND EP_date BETWEEN @DATE1 AND @DATE2
		   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
		   GROUP BY EP_BranchCode

		  UNION ALL 

		  SELECT PO_BranchCode, '<a href="/AccountReport/Reports.aspx?FLAG=PAYORD_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			   +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			   '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order- Int`l</a>' Particulars 
			   ,COUNT('x') TXN
			   ,SUM ( EP.Amount ) AMT 
			   ,SUM (EP.PO_commission) COMMISSION 
		  FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
		  WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
		  AND RIGHT(ref_no,1)<>@LastCharInDomTxn
		  AND PO_date BETWEEN @DATE1 AND @DATE2
		  AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode)  
		  GROUP BY PO_BranchCode


		  UNION ALL 

		  SELECT EP_BranchCode , 
			 '<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=ERR_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid -Domestic</a>' Particulars 
			 ,COUNT('x') TXN
			 ,SUM (EP.amount)*-1 AMT 
			 ,SUM (EP.EP_commission)*-1 COMMISSION 
		   FROM ErroneouslyPaymentNew EP WITH (NOLOCK) 
		   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
		   AND RIGHT(ref_no,1)=@LastCharInDomTxn
		   AND EP_date BETWEEN @DATE1 AND @DATE2
		   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
		   GROUP BY EP_BranchCode

		  UNION ALL 

		  SELECT PO_BranchCode , 
			 '<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=PAYORD_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order -Domestic</a>' Particulars 
			  ,COUNT('x') TXN
			   ,SUM (EP.Amount ) AMT 
			   ,SUM (EP.PO_commission) COMMISSION 
		  FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
		  WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
		  AND RIGHT(ref_no,1)=@LastCharInDomTxn
		  AND PO_date BETWEEN @DATE1 AND @DATE2
		  AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
		  GROUP BY PO_BranchCode

	   )T , agentTable A with (nolock) where T.P_BRANCH = A.map_code
	   --order by  A.agent_name


	  SELECT * FROM #TEM1

	  EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head, CONVERT(VARCHAR(10), @DATE1, 101) value UNION
		SELECT 'To Date' head, CONVERT(VARCHAR(10), @DATE2, 101) value union 
		SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @AGENT),'All')  
		
		SELECT title = @Title
end


if @FLAG ='m2'
begin
	   --declare @USERVal varchar(200)
	   set @USERVal = ISNULL(@USER,'')

	   SELECT 
		  P_BRANCH BRANCH , A.agent_name, Particulars,
		  TXN, AMT,isnull(COMMISSION,'0.00')COMMISSION
		  INTO #TEM2
	   FROM 
	   (    
		  --'<a href="soa_drilldown_report.asp?FLAG=PAY_BRANCH&AGENT='+
		  --CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,paid_date, 101 )+
		  --'&DATE2='+CONVERT ( VARCHAR,paid_date, 101 )+'">Paid - Int`l Remitt - '+
		  --CAST(COUNT('x') AS VARCHAR)+'</a>'

		  SELECT P_BRANCH,
			 '<a href="/AccountReport/Reports.aspx?FLAG=PAY_COUNTRY&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ P_BRANCH +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Int`l Remitt </a>' Particulars 
			 ,COUNT('x') TXN, SUM(P_AMT) AMT , SUM(ISNULL(SC_P_AGENT,0)) COMMISSION
		  FROM REMIT_TRN_MASTER RTM WITH ( NOLOCK) 
		  WHERE case when @isCentSett = 'y' then P_AGENT 
				    else P_BRANCH end=@AGENT 
		  AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
		  AND P_BRANCH = isnull(@BRANCH , P_BRANCH)
		  GROUP BY P_BRANCH

		  UNION ALL

		  SELECT  map_code, 
			 '<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=SEND_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Send - Domestic Remitt.</a>' Particulars 
			 ,COUNT('x') TXN, SUM(S_AMT)*-1 AMT, SUM(ISNULL(S_SC,0)) COMMISSION
		  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
		  AND isnull(TranType,'') <> 'B'
		  AND map_code = isnull(@BRANCH , map_code)
		  GROUP BY map_code 
		  
		  UNION ALL

		  SELECT  map_code, 
			 'Send - Domestic Remitt.' Particulars 
			 ,COUNT('x') TXN, SUM(S_AMT)*-1 AMT, SUM(ISNULL(S_SC,0)) COMMISSION
		  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
		  AND isnull(TranType,'') = 'B'
		  AND map_code = isnull(@BRANCH , map_code)
		  GROUP BY map_code 
		  

		  UNION ALL 

		  SELECT  map_code, 
			 '<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=PAY_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Domestic Remitt.</a>' Particulars 
			 ,COUNT('x') TXN, SUM(P_AMT) AMT , SUM(ISNULL(R_SC,0)) COMMISSION
		  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND P_DATE BETWEEN @DATE1 AND @DATE2 
		  AND map_code = isnull(@BRANCH , map_code)
		  GROUP BY map_code 

		  UNION ALL 

		  SELECT  map_code, 
			 '<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=CANCEL_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Cancel - Domestic Remitt.</a>' Particulars 
			 ,COUNT('x') TXN, SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE)  THEN S_AMT ELSE P_AMT+ ISNULL(R_SC,0) END) AMT,
			 SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE) THEN  ISNULL(S_SC,0) END) *-1 COMMISSION
		  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
		  AND map_code = isnull(@BRANCH , map_code)

		  GROUP BY map_code 

		  UNION ALL 

		   SELECT EP_BranchCode , '<a href="/AccountReport/Reports.aspx?FLAG=ERR_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid - Int`l</a>' Particulars 
			 ,COUNT('x') TXN
			 ,SUM (EP.amount)*-1 AMT 
			 ,SUM (EP.EP_commission)*-1 COMMISSION 
		   FROM ErroneouslyPaymentNew EP WITH (NOLOCK) 
		   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
		   AND RIGHT(ref_no,1)<>@LastCharInDomTxn
		   AND EP_date BETWEEN @DATE1 AND @DATE2 
		   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
		   GROUP BY EP_BranchCode

		  UNION ALL 

		  SELECT PO_BranchCode, '<a href="/AccountReport/Reports.aspx?FLAG=PAYORD_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			   +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			   '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order- Int`l</a>' Particulars 
			   ,COUNT('x') TXN
			   ,SUM ( EP.Amount ) AMT 
			   ,SUM (EP.PO_commission) COMMISSION 
		  FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
		  WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
		  AND RIGHT(ref_no,1)<>@LastCharInDomTxn
		  AND PO_date BETWEEN @DATE1 AND @DATE2
		  AND PO_BranchCode = isnull(@BRANCH , PO_BranchCode) 
		  GROUP BY PO_BranchCode


		  UNION ALL 

		  SELECT EP_BranchCode , 
			 '<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=ERR_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid -Domestic</a>' Particulars 
			 ,COUNT('x') TXN
			 ,SUM (EP.amount)*-1 AMT 
			 ,SUM (EP.EP_commission)*-1 COMMISSION 
		   FROM ErroneouslyPaymentNew EP WITH (NOLOCK) 
		   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
		   AND RIGHT(ref_no,1)=@LastCharInDomTxn
		   AND EP_date BETWEEN @DATE1 AND @DATE2 
		   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
		   GROUP BY EP_BranchCode

		  UNION ALL 

		  SELECT PO_BranchCode , 
			 '<a href="/AccountReport/Reports.aspx?reportName=settlementHoReportDrillDown&FLAG=PAYORD_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
			 +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order -Domestic</a>' Particulars 
			  ,COUNT('x') TXN
			   ,SUM (EP.Amount ) AMT 
			   ,SUM (EP.PO_commission) COMMISSION 
		  FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
		  WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
		  AND RIGHT(ref_no,1)=@LastCharInDomTxn
		  AND PO_date BETWEEN @DATE1 AND @DATE2
		  AND PO_BranchCode = isnull(@BRANCH , PO_BranchCode) 
		  GROUP BY PO_BranchCode

	   )T , agentTable A with (nolock) where T.P_BRANCH = A.map_code
	   --order by  A.agent_name

	   SELECT * FROM
	   (
		  SELECT agent_name, particulars,1 'ORD', CAST(TXN as VARCHAR(20)) TXN, AMT, COMMISSION from #TEM2 
		  UNION ALL
		  SELECT agent_name, 'NET SETTLEMENT', 2 'ORD' ,'',  SUM(AMT), SUM(COMMISSION) FROM #TEM2
		  GROUP BY agent_name 
          
	   )A ORDER BY agent_name, ORD

end


GO
