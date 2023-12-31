USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_AGENT_SOA_DOMESTIC_COMM_V2]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PROC_AGENT_SOA_DOMESTIC_COMM_V2]
     @FLAG  VARCHAR (20)
    ,@AGENT VARCHAR (20) 
    ,@DATE1 VARCHAR (10) 
    ,@DATE2 VARCHAR (20) 
    ,@BRANCH VARCHAR(10) = NULL
    ,@AGENT2 VARCHAR(10) = NULL
    ,@TRN_TYPE VARCHAR(15) = NULL

AS

	SET NOCOUNT ON;
	SET @DATE2 = @DATE2+ ' 23:59:59'
	DECLARE @isCentSett varchar(20)
    DECLARE @LastCharInDomTxn CHAR(1) = dbo.FNALastCharInDomTxn()

	select  @isCentSett = isnull(central_sett,'n')  
	from agentTable with (nolock) where map_code =@AGENT

IF @FLAG ='PAY_USER'
BEGIN

	   SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
		  , dbo.decryptDb(TRN_REF_NO)TRN_REF_NO
		  , upper(SENDER_NAME) as SENDER_NAME
		  , upper(RECEIVER_NAME) as RECEIVER_NAME
		  , SC_P_AGENT
		  , paidBy P_USER
	   FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
	   WHERE 
		  case when @isCentSett ='y' then P_AGENT 
			 else P_BRANCH end = @AGENT 
		  and P_BRANCH = @BRANCH
	   AND PAID_DATE BETWEEN @DATE1 AND @DATE2 

END

IF @FLAG ='PAY_COMPANY'
BEGIN

    SELECT T.DT,S_AGENT,

	   '<a href="drilDownUserDComm.aspx?flag=PAY_USER&BRANCH='+ 
	   CAST(@BRANCH AS VARCHAR)+'&AGENT='+ CONVERT(VARCHAR,@AGENT, 101 )+
	   '&AGENT2='+ CONVERT(VARCHAR,S_AGENT, 101 )+ 
	   '&DATE1='+ CONVERT (VARCHAR,@DATE1, 101) + '&DATE2='+ CONVERT (VARCHAR,@DATE2, 101 )+
	    '">'+ A.agent_name +' - '+ cast(TXN as varchar(20)) +'</a>' as Particulars, 

    T.TXN, T.AMT FROM
    (
    SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
	   , S_AGENT  
	   ,COUNT (TRN_REF_NO) TXN, SUM(SC_P_AGENT) AMT 
    FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
    WHERE 
	   case when @isCentSett ='y' then P_AGENT 
			 else P_BRANCH end = @AGENT
	   and P_BRANCH = @BRANCH
    AND PAID_DATE BETWEEN  @DATE1 AND @DATE2 
    GROUP BY CONVERT(VARCHAR , paid_date, 101) ,S_AGENT
    )T , agentTable A
    WHERE T.S_AGENT = A.map_code
    ORDER BY T.DT, A.agent_name 

END

IF @FLAG ='PAY_BRANCH'
BEGIN

    SELECT T.DT, P_BRANCH,
	   '<a href="drilDownUserDComm.aspx?flag=PAY_COMPANY&BRANCH='+ 
	   CAST(P_BRANCH AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
	   '&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 )+'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+
	    '">'+ A.agent_name  +' - '+ cast(TXN as varchar(20)) +'</a>' as Particulars, T.TXN, T.AMT FROM
	   (
		  SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
			 , P_BRANCH  
			 ,COUNT ( TRN_REF_NO) TXN, SUM(SC_P_AGENT) AMT 
		  FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
		  WHERE 
			 case when @isCentSett ='y' then P_AGENT 
				else P_BRANCH end = @AGENT
		  AND PAID_DATE BETWEEN   @DATE1 AND @DATE2  
		  GROUP BY CONVERT(VARCHAR , paid_date, 101) ,P_BRANCH
	   )T , agentTable A
    WHERE T.P_BRANCH = A.map_code
    ORDER BY T.DT, A.agent_name 

END

IF @FLAG ='SEND_BRANCH_D'
BEGIN

	   SELECT CONVERT(VARCHAR , CONFIRM_DATE, 101)DT ,
		   S_AGENT, 
		  '<a href="drilDownUserDComm.aspx?flag=SEND_USER_D&AGENT2='+ 
		  CAST(S_AGENT AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 )+'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+
		  '">'+  agent_name +' - '+ cast(COUNT ( TRN_REF_NO)as varchar(20)) +' </a>' AS  Particulars 
		  ,COUNT ( TRN_REF_NO) TXN, SUM(S_SC) AMT 
	   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
	   WHERE RTL.S_AGENT = AT.AGENT_IME_CODE 
	   AND ISNULL (AT.central_sett_code,map_code)= @AGENT
	   AND CONFIRM_DATE BETWEEN   @DATE1 AND @DATE2  
	   GROUP BY CONVERT(VARCHAR , CONFIRM_DATE, 101) ,S_AGENT, agent_name 
	
END

IF @FLAG ='SEND_USER_D'
BEGIN
	   SELECT CONVERT(VARCHAR , CONFIRM_DATE, 101)DT ,
		    upper(SENDER_NAME) as SENDER_NAME
		  , upper(RECEIVER_NAME) as RECEIVER_NAME
		  ,dbo.decryptDbLocal(TRN_REF_NO)TRN_REF_NO, S_SC as P_AMT, SEMPID as P_USER 
	   FROM REMIT_TRN_LOCAL RTL WITH(NOLOCK), agentTable AT WITH (NOLOCK) 
	   WHERE RTL.S_AGENT = AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND S_AGENT = @AGENT2
		  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2

END

IF @FLAG ='PAID_BRANCH_D'
BEGIN

	   SELECT CONVERT(VARCHAR , P_DATE, 101)DT ,
		  R_AGENT,   '<a href="drilDownUserDComm.aspx?flag=PAID_USER_D&AGENT2='+ 
		  CAST(R_AGENT AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 )+'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+
		  '">'+  agent_name +' - '+ cast(COUNT ('x')as varchar(20)) +' </a>' AS  Particulars 
		  ,COUNT(TRN_REF_NO) TXN, SUM(R_SC) AMT 
	   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
	   WHERE RTL.R_AGENT = AT.AGENT_IME_CODE 
	   AND ISNULL (AT.central_sett_code,map_code)= @AGENT
	   AND P_DATE BETWEEN  @DATE1 AND @DATE2  
	   GROUP BY CONVERT(VARCHAR , P_DATE, 101) ,R_AGENT, agent_name 
	
END

IF @FLAG ='PAID_USER_D'
BEGIN

	   SELECT CONVERT(VARCHAR , P_DATE, 101)DT ,
		   upper(SENDER_NAME) as SENDER_NAME
		  , upper(RECEIVER_NAME) as RECEIVER_NAME
		  , dbo.decryptDbLocal(TRN_REF_NO)TRN_REF_NO, R_SC as P_AMT, paidBy as P_USER
	   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
	   WHERE RTL.R_AGENT = AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT
		  AND R_AGENT = @AGENT2
		  AND P_DATE BETWEEN  @DATE1 AND @DATE2  
	   
	
END

IF @FLAG ='CANCEL_BRANCH_D'
BEGIN


    SELECT CONVERT(VARCHAR , CANCEL_DATE, 101)DT ,S_AGENT,
	    '<a href="drilDownUserDComm.aspx?flag=CANCEL_USER_D&AGENT2='+ 
		  CAST(S_AGENT AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,CANCEL_DATE, 101 )+'&DATE2='+CONVERT ( VARCHAR,CANCEL_DATE, 101 )+
		  '">'+  agent_name +' - '+ cast(COUNT ( TRN_REF_NO)as varchar(20)) +' </a>' AS Particulars 
	   ,COUNT (TRN_REF_NO) Txn, 
	   SUM(S_SC ) AMT 
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH (NOLOCK ) 
    WHERE RTL.S_AGENT = AT .AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT
    AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2  
    GROUP BY CONVERT(VARCHAR , CANCEL_DATE, 101),agent_name,S_AGENT


END

IF @FLAG ='CANCEL_USER_D'
BEGIN


    SELECT CONVERT(VARCHAR, CANCEL_DATE, 101)DT ,
		    upper(SENDER_NAME) as SENDER_NAME
		  , upper(RECEIVER_NAME) as RECEIVER_NAME
		  ,dbo.decryptDbLocal(TRN_REF_NO)TRN_REF_NO, 
		  P_AMT = S_SC, 
		  SEmpID P_USER
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH (NOLOCK ) 
    WHERE RTL.S_AGENT = AT .AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT
    AND S_AGENT = @AGENT2 
    AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 


END

IF @FLAG ='ERR_BRANCH_D'
BEGIN

   SELECT CONVERT (VARCHAR , EP_date, 101)DT , 
		'<a href="drilDownUserDComm.aspx?flag=ERR_USER_D&AGENT2='+ 
		  CAST(EP_BranchCode AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,EP_date, 101 )+'&DATE2='+CONVERT ( VARCHAR,EP_date, 101 )+
		  '">'+  agent_name +' - '+ cast(COUNT('x')as varchar(20)) +' </a>'
		  as  Particulars 
	   , COUNT(REF_NO ) TXN, SUM (EP_commission ) AMT 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.EP_BranchCode = AT.map_code 
    AND  (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
    AND RIGHT(ref_no,1)=@LastCharInDomTxn 
    AND EP_date BETWEEN @DATE1 AND @DATE2
    GROUP BY CONVERT (VARCHAR, EP_date, 101),agent_name,EP_BranchCode


END

IF @FLAG ='ERR_USER_D'
BEGIN

    SELECT CONVERT (VARCHAR , EP_date, 101)DT , 
		ref_no as TRN_REF_NO, SENDER_NAME, RECEIVER_NAME 
	   , EP_commission P_AMT, EP_User P_USER 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_LOCAL RT WITH (NOLOCK)
    WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
    AND (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
    AND EP_BranchCode = @AGENT2 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn 
    AND EP_date BETWEEN @DATE1 AND @DATE2


END

IF @FLAG ='PAYORD_BRANCH_D'
BEGIN
    SELECT CONVERT (VARCHAR , PO_date, 101)DT , 
		'<a href="drilDownUserDComm.aspx?flag=PAYORD_USER_D&AGENT2='+ 
		  CAST(PO_BranchCode AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,PO_date, 101 )+'&DATE2='+CONVERT ( VARCHAR,PO_date, 101 )+
		  '">'+  agent_name +' - '+ cast(COUNT('x')as varchar(20)) +' </a>'
		  as  Particulars  
	   , COUNT(REF_NO ) TXN, SUM (PO_commission ) AMT 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.PO_BranchCode = AT.map_code 
    AND  (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT) 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn 
    AND PO_date BETWEEN @DATE1 AND  @DATE2
    GROUP BY CONVERT (VARCHAR, PO_date, 101),agent_name,PO_BranchCode


END

IF @FLAG ='PAYORD_USER_D'
BEGIN

    SELECT CONVERT (VARCHAR , PO_date, 101)DT , 
		ref_no as TRN_REF_NO, SENDER_NAME, RECEIVER_NAME 
	   , PO_commission P_AMT, PO_User P_USER 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_LOCAL RT WITH ( NOLOCK )
    WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
    AND (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
    AND PO_BranchCode = @AGENT2 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn 
    AND PO_date BETWEEN @DATE1 AND  @DATE2


END

IF @FLAG ='ERR_BRANCH'
BEGIN
    SELECT CONVERT (VARCHAR , approved_ts, 101)DT , 
		'<a href="drilDownUserDComm.aspx?flag=ERR_USER&AGENT2='+ 
		  CAST(branch_code AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,approved_ts, 101 )+'&DATE2='+CONVERT ( VARCHAR,approved_ts, 101 )+
		  '">'+  agent_name +' - '+ cast(COUNT('x')as varchar(20)) +' </a>'
		  as  Particulars 
	   , COUNT(REF_NO ) TXN, SUM (Amount ) AMT 
    FROM ErroneouslyPayment EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.branch_code = AT.map_code 
    AND  AGENTCODE=@AGENT 
    AND companyName='Commission Account' 
    AND MODE='Dr' 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
    AND approved_ts BETWEEN @DATE1 AND @DATE2
    GROUP BY CONVERT (VARCHAR, approved_ts, 101),agent_name,branch_code


END

IF @FLAG ='ERR_USER'
BEGIN

    SELECT CONVERT (VARCHAR , approved_ts, 101)DT , 
		ref_no as TRN_REF_NO, upper(SENDER_NAME) as SENDER_NAME
		  , upper(RECEIVER_NAME) as RECEIVER_NAME
	   , Amount P_AMT, approved_by P_USER 
    FROM ErroneouslyPayment EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH (NOLOCK)
    WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
    AND AGENTCODE= @AGENT
    AND branch_code = @AGENT2 
    AND companyName='Commission Account' 
    AND MODE='Dr' 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
    AND approved_ts BETWEEN @DATE1 AND @DATE2


END

IF @FLAG ='PAYORD_BRANCH'
BEGIN

    SELECT CONVERT (VARCHAR , approved_ts, 101)DT , 
		'<a href="drilDownUserDComm.aspx?flag=PAYORD_USER&AGENT2='+ 
		  CAST(branch_code AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,approved_ts, 101 )+'&DATE2='+CONVERT ( VARCHAR,approved_ts, 101 )+
		  '">'+  agent_name +' - '+ cast(COUNT('x')as varchar(20)) +' </a>'
		  as  Particulars  
	   , COUNT(REF_NO ) TXN, SUM (Amount ) AMT 
    FROM ErroneouslyPayment EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.branch_code = AT.map_code 
    AND  AGENTCODE= @AGENT 
    AND companyName='Commission Account' 
    AND MODE='cr' 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
    AND approved_ts BETWEEN @DATE1 AND  @DATE2
    GROUP BY CONVERT (VARCHAR, approved_ts, 101),agent_name,branch_code

END

IF @FLAG ='PAYORD_USER'
BEGIN

    SELECT CONVERT (VARCHAR , approved_ts, 101)DT , 
		ref_no as TRN_REF_NO, upper(SENDER_NAME) as SENDER_NAME
		  , upper(RECEIVER_NAME) as RECEIVER_NAME
	   , Amount P_AMT, approved_by P_USER 
    FROM ErroneouslyPayment EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH ( NOLOCK )
    WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
    AND AGENTCODE= @AGENT
    AND branch_code = @AGENT2 
    AND companyName='Commission Account' 
    AND MODE='cr' 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
    AND approved_ts BETWEEN @DATE1 AND  @DATE2

END

IF @FLAG ='SOA'
BEGIN
    declare @AGENT_AC varchar(20), @OPENINGBAL Money
    select @AGENT_AC = acct_num from agentTable ag(nolock), ac_master ac(nolock)
    where ac.agent_id = ag.agent_id 
    and  ag.map_code = @AGENT
    and ac.acct_rpt_code = '22'


	IF cast(@date1 as date)>='2014-07-17'
	begin 
		select @OPENINGBAL = isnull(sum (case when part_tran_type='dr' 
				then tran_amt*-1 else tran_amt end) ,0)
		from tran_master  WITH (NOLOCK) where acc_num=@AGENT_AC 
		and tran_date < @DATE1
	end

SELECT  cast(T.DT as DATE) as DATE 
		,Particulars
		,DR
		,CR 
FROM 
(    
    select CONVERT (VARCHAR,cast(@DATE1 as DATETIME), 101 ) DT,'Opening Balance' Particulars,0 TXN,
		isnull(@OPENINGBAL,0.00) DR ,'0' CR 
	
    UNION ALL 

    SELECT CONVERT(VARCHAR , CONFIRM_DATE, 101)DATE , 
	   '<a href="drilDownDomComm.aspx?FLAG=SEND_BRANCH_D&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,CONFIRM_DATE, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,CONFIRM_DATE, 101 )+'">Send - Domestic Remitt. - '+
	    cast(COUNT('x') as varchar(20))+' </a> ' Particulars 
	   ,4, 0 Debit, SUM(S_SC) Credit 
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
    WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
    GROUP BY CONVERT(VARCHAR , CONFIRM_DATE, 101) 

    UNION ALL 

    SELECT CONVERT(VARCHAR,P_DATE, 101)DATE , 
		'<a href="drilDownDomComm.aspx?FLAG=PAID_BRANCH_D&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,P_DATE, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,P_DATE, 101 )+'">Paid - Domestic Remitt. - '+
	    cast(COUNT('x') as varchar(20))+' </a> ' Particulars 
	   ,5, 0 Debit, SUM(R_SC) Credit 
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
    WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND P_DATE BETWEEN @DATE1 AND @DATE2 
    GROUP BY CONVERT(VARCHAR ,P_DATE , 101) 

    UNION ALL

    SELECT CONVERT(VARCHAR , CANCEL_DATE, 101)DATE ,
	   '<a href="drilDownDomComm.aspx?FLAG=CANCEL_BRANCH_D&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,CANCEL_DATE, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,CANCEL_DATE, 101 )+'">Cancel - Domestic Remitt. - '+
	    cast(COUNT('x') as varchar(20))+' </a> ' as Particulars 
	   ,6, SUM(S_SC) Debit, 
	   0 Credit 
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH (NOLOCK ) 
    WHERE RTL.S_AGENT= AT .AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
    GROUP BY CONVERT(VARCHAR , CANCEL_DATE, 101) 

    UNION ALL 

    SELECT CONVERT(VARCHAR , EP_date, 101)DATE , 
		  '<a href="drilDownDomComm.aspx?FLAG=ERR_BRANCH_D&AGENT='+
			 CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,EP_date, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,EP_date, 101 )+'"> Erroneously Paid -Domestic -'
		  +cast(COUNT('x') as varchar(20)) +'</a>' Particulars 
		  ,7, SUM (EP_commission ) Debit, 0 Credit 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
    WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT ) 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn 
    AND EP_date between @DATE1 and  @DATE2
    Group by EP_date


    UNION ALL 

    SELECT CONVERT(VARCHAR,PO_date, 101)DATE , 
		  '<a href="drilDownDomComm.aspx?FLAG=PAYORD_BRANCH_D&AGENT='+
			 CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,PO_date, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,PO_date, 101 )+'"> Payment Order -Domestic -'
		  +cast(COUNT('x') as varchar(20)) +'</a>' Particulars 
		  , 8, 0 Debit , SUM ( PO_commission) Credit 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
    WHERE (PO_AgentCode=@AGENT  OR PO_BranchCode=@AGENT ) 
    AND RIGHT(ref_no,1)= @LastCharInDomTxn 
    AND PO_date between @DATE1 and  @DATE2  
    Group by PO_date

    UNION ALL
 
    SELECT CONVERT(VARCHAR,T.tran_date, 101 ) DATE , TD.tran_particular Particulars , 0.1
	   ,CASE WHEN T . part_tran_type='DR' THEN T.tran_amt ELSE 0 END Debit , 
	   CASE WHEN part_tran_type='CR' THEN tran_amt ELSE 0 END Credit 
    FROM tran_master t WITH ( NOLOCK )
	   , tran_masterDetail TD WITH (NOLOCK) 
    WHERE T.acc_num = @AGENT_AC
    AND T.ref_num=TD.ref_num 
    AND T.tran_type=TD.tran_type 
    AND T.tran_date BETWEEN @DATE1 AND @DATE2 
    AND (isnull(T.rpt_code,'') <>'S' AND isnull(T.rpt_code,'')<>'POI' 
    AND isnull(T.rpt_code,'') <> 'EPI' AND isnull(T.rpt_code,'')<>'POD' 
    AND isnull(T.rpt_code,'')<> 'EPD' OR T.rpt_code is null ) 
	AND  T.tran_date>=(CASE WHEN cast(@DATE1 as date)<'2014-07-18' THEN '2014-07-17' ELSE @DATE1 END)

)T 
order by DATE, TXN

END

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

SELECT 'From Date' head, CONVERT(VARCHAR(10), @DATE1, 101) value
UNION ALL
SELECT 'To Date' head, CONVERT(VARCHAR(10), @DATE2, 101) value union 
SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_id = @BRANCH),'All') 
	
SELECT title = 'STATEMENT OF ACCOUNT - DOMESTIC COMMISSION'


GO
