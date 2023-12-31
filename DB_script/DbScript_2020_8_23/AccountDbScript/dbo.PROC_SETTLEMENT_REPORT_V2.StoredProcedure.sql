USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SETTLEMENT_REPORT_V2]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PROC_SETTLEMENT_REPORT_V2]
     @FLAG				VARCHAR(50)
    ,@AGENT				VARCHAR(20)			= NULL
    ,@BRANCH			VARCHAR(20)			= NULL
    ,@DATE1				VARCHAR(20)			= NULL
    ,@DATE2				VARCHAR(20)			= NULL
    ,@USER				VARCHAR(20)			= NULL
    ,@COUNTRY			VARCHAR(200)		= NULL
	,@pageNumber		INT					= NULL
	,@pageSize			INT					= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON ;	
BEGIN TRY

	DECLARE @isCentSett varchar(20), @commCode varchar(20),@DATE3 VARCHAR(20)
	SET @DATE3 = @DATE2
	SET @DATE2 = REPLACE(@DATE2,' 23:59:59','')
	SET @DATE2=@DATE2 +' 23:59:59'
	DECLARE @LastCharInDomTxn CHAR(1) = dbo.FNALastCharInDomTxn()
	if (datediff(day,@DATE1,GETDATE())>90)
	begin
		select '1' [S.N.], '<font color="red"><b>Date Range is not valid, You can only view transaction upto 90 days.</b></font>' Remarks				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT 'From Date' head,@DATE1 VALUE
		UNION ALL 
		SELECT 'TO Date' head,@DATE3 VALUE
		UNION ALL 
		SELECT 'Agent' head,(SELECT agent_name FROM agentTable WITH(NOLOCK) WHERE map_code = @AGENT) VALUE
		UNION ALL 
		SELECT 'Branch' head,CASE WHEN @BRANCH IS NULL THEN '-' ELSE (SELECT agent_name FROM agentTable WITH(NOLOCK) WHERE central_sett_code = @BRANCH) END  VALUE
		SELECT 'Settlement Report' title	
		RETURN

	END
    
	if (datediff(day,@DATE1,@DATE3) > 32)
	begin
		select '1' [S.N.], '<font color="red"><b>Date Range is not valid, Please select date range of 32 days.</b></font>' Remarks				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT 'From Date' head,@DATE1 VALUE
		UNION ALL 
		SELECT 'TO Date' head,@DATE3 VALUE
		UNION ALL 
		SELECT 'Agent' head,(SELECT agent_name FROM agentTable WITH(NOLOCK) WHERE map_code = @AGENT) VALUE
		UNION ALL 
		SELECT 'Branch' head,CASE WHEN @BRANCH IS NULL THEN '-' ELSE (SELECT agent_name FROM agentTable WITH(NOLOCK) WHERE central_sett_code = @BRANCH) END  VALUE
		SELECT 'Settlement Report' title	
		RETURN

	end

    SELECT  
	   @isCentSett = ISNULL(central_sett,'n'), @commCode= map_code2  
    FROM agentTable WITH (NOLOCK) WHERE map_code =@AGENT

	IF @FLAG = 'DDL_BRANCH'
	BEGIN
		IF (select central_sett from agentTable where map_code= @AGENT)='Y'
		BEGIN
			select map_code,agent_name,central_sett from agentTable where central_sett_code =  @AGENT order by agent_name
		END
		ELSE
		BEGIN
			SELECT 
				map_code = agent_id
			,agent_name = agent_name,central_sett from agentTable WHERE 1=2
		END
		return;
	END

	IF @FLAG ='PAY_COUNTRY'
	BEGIN

		 SELECT 
		 [S.N.] = ROW_NUMBER() OVER(ORDER BY S_COUNTRY)
		,[Country] = isnull(S_COUNTRY, 'Worldwide Others')
		,[Particulars] =  '<a href="Reports.aspx?reportName=settlementdom&flag=PAY_USER&BRANCH='+ 
							CAST(@BRANCH AS VARCHAR)+'&AGENT='+ CONVERT(VARCHAR,@AGENT, 101 )+
							'&DATE1='+ CONVERT (VARCHAR,@DATE1, 101 )+
							'&COUNTRY='+ isnull(S_COUNTRY, 'Worldwide Others') +'&DATE2='+ CONVERT (VARCHAR,@DATE2, 101 )+
							'">'+ isnull(S_COUNTRY, 'Worldwide Others') +' - '+ cast(sum(TXN) as varchar(20)) +'</a>'
		,[TXN Count] = sum(T.TXN) 
		,[Amount] = sum(T.AMT) 
		,[Commission] =  isnull(sum(COMMISSION),'0.00')  
		FROM
		(
		   SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
			  , S_AGENT, S_COUNTRY  
			  ,COUNT ( TRN_REF_NO) TXN, SUM(P_AMT) AMT
			 --- ,  SUM(CASE WHEN ISNULL(SC_TOTAL,0)=0 THEN 0 ELSE ISNULL(SC_P_AGENT,0) END ) COMMISSION 
			  ,  SUM(ISNULL(SC_P_AGENT,0)) COMMISSION 
			  ,TRN_TYPE
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

	IF @FLAG ='PAY_USER'
	BEGIN

		  if @COUNTRY ='Worldwide Others'
		  begin
				SELECT 
					[S.N.] = ROW_NUMBER() OVER(ORDER BY CONVERT(VARCHAR,paid_date,101) DESC)
				  ,	[DATE] = CONVERT(VARCHAR,paid_date, 101 ) 
				  , [TRN REF NO] = dbo.decryptDb(TRN_REF_NO)
				  , [SENDER NAME] = UPPER(SENDER_NAME)  
				  , [RECEIVER NAME] = UPPER(RECEIVER_NAME)  
				  , [AMOUNT] = P_AMT
				---  , [COMMISSION] = (CASE WHEN ISNULL(SC_TOTAL,0)=0 THEN 0 ELSE ISNULL(SC_P_AGENT,0) END ) 
				  , [COMMISSION] = (ISNULL(SC_P_AGENT,0)) 
				  , [USER] = paidBy 
				  , [COUNTRY] = S_COUNTRY
			   FROM REMIT_TRN_MASTER RTM WITH (NOLOCK), agentTable A
			   WHERE RTM.S_AGENT = A.map_code and
				  case when @isCentSett ='y' then P_AGENT 
					 else P_BRANCH end = @AGENT 
			   AND P_BRANCH = @BRANCH
			   AND S_COUNTRY is null
			   AND PAID_DATE BETWEEN @DATE1 AND @DATE2
			   Order by  CONVERT(VARCHAR,paid_date,101) desc
		  end
		  else
		  begin
		   SELECT 
				[S.N.] = ROW_NUMBER() OVER(ORDER BY CONVERT(VARCHAR,paid_date,101) DESC)
			  ,	[DATE] = CONVERT(VARCHAR,paid_date, 101 ) 
			  , [TRN REF NO] = dbo.decryptDb(TRN_REF_NO)
			  , [SENDER NAME] = UPPER(SENDER_NAME)  
			  , [RECEIVER NAME] = UPPER(RECEIVER_NAME)  
			  , [AMOUNT] = P_AMT
			---- , [COMMISSION] = (CASE WHEN ISNULL(SC_TOTAL,0)=0 THEN 0 ELSE ISNULL(SC_P_AGENT,0) END ) 
			  , [COMMISSION] = (ISNULL(SC_P_AGENT,0)) 
			  , [USER] = paidBy 
			  , [COUNTRY] = S_COUNTRY
		   FROM REMIT_TRN_MASTER RTM WITH (NOLOCK), agentTable A
		   WHERE RTM.S_AGENT = A.map_code and
			  case when @isCentSett ='y' then P_AGENT 
				 else P_BRANCH end = @AGENT 
		   AND P_BRANCH = @BRANCH
		   AND S_COUNTRY= ISNULL(@COUNTRY,S_COUNTRY)
		   AND PAID_DATE BETWEEN @DATE1 AND @DATE2
		   Order by  CONVERT(VARCHAR,paid_date,101) desc
		end

	end

	IF @FLAG ='SEND_USER_D'
	BEGIN

		   SELECT 
				 [S.N.] = ROW_NUMBER() OVER(ORDER BY CONFIRM_DATE DESC)
				,[DATE] = CONVERT(VARCHAR , CONFIRM_DATE, 101)
				,[SENDER NAME] = UPPER(SENDER_NAME)  
				,[RECEIVER NAME] = UPPER(RECEIVER_NAME)  
				,[TRN REF NO] = dbo.decryptDbLocal(TRN_REF_NO) 
				,[AMOUNT] = S_AMT 
			-----	,[COMMISSION] = (CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END ) 
				,[COMMISSION] = (ISNULL(S_SC,0)) 
				,[USER] = SEMPID   
		   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
			  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
			  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
			  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
			  AND map_code = isnull(@BRANCH , map_code)
			  --AND SEMPID = ISNULL(@USER,SEMPID)
			  AND isnull(TranType,'') <> 'B'
			  Order by  CONFIRM_DATE desc
	END

	IF @FLAG ='PAY_USER_D'
	BEGIN

		   SELECT 
				 [S.N.] = ROW_NUMBER() OVER(ORDER BY P_DATE DESC)
				,[DATE] = CONVERT(VARCHAR , P_DATE, 101)
				,[SENDER NAME] = UPPER(SENDER_NAME)
				,[RECEIVER NAME] = UPPER(RECEIVER_NAME) 
				,[TRN REF NO] = dbo.decryptDbLocal(TRN_REF_NO)
				,[AMOUNT] = P_AMT
			----	,[COMMISSION] =CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(R_SC,0) END 
				,[COMMISSION] = (ISNULL(R_SC,0))
				,[USER] = paidBy
		   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
			  WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
			  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
			  AND P_DATE BETWEEN @DATE1 AND @DATE2 
			  AND map_code = isnull(@BRANCH , map_code)
			  Order by  P_DATE desc
	END

	IF @FLAG ='CANCEL_USER_D'
	BEGIN

		   SELECT 
				[S.N.] = ROW_NUMBER() OVER(ORDER BY CANCEL_DATE DESC)
			  ,	[DATE] = CONVERT(VARCHAR , CANCEL_DATE, 101) 
			  , [SENDER NAME] = UPPER(SENDER_NAME) 
			  , [RECEIVER NAME] = UPPER(RECEIVER_NAME) 
			  , [TRN REF NO] = dbo.decryptDbLocal(TRN_REF_NO)
			  , [AMOUNT] = CASE WHEN CAST(CONFIRM_DATE AS DATE) =CAST(CANCEL_DATE AS DATE) THEN  S_AMT ELSE P_AMT + ISNULL(R_SC,0) END  
			 --- , [COMMISSION] = CASE WHEN CAST(CONFIRM_DATE AS DATE) =CAST(CANCEL_DATE AS DATE) THEN (CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END )  ELSE 0 END 
			 , [COMMISSION] = CASE WHEN CAST(CONFIRM_DATE AS DATE) =CAST(CANCEL_DATE AS DATE) THEN ISNULL(S_SC,0) ELSE 0 END 
			  , [USER] = isnull(CANCEL_USER,SEmpID)  
		   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
			  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
			  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
			  AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
			  AND map_code = isnull(@BRANCH , map_code)
			 -- AND SEMPID = ISNULL(@USER,SEMPID)
			  Order by CANCEL_DATE desc

	END

	IF @FLAG ='ERR_USER_D'
	BEGIN

		SELECT 
			  [S.N.] = row_number()over(order by CONVERT(VARCHAR,EP_date,101) DESC)
			, [DATE] = CONVERT(VARCHAR,EP_date,101)
			, [SENDER NAME] = UPPER(SENDER_NAME) 
			, [RECEIVER NAME] = UPPER(RECEIVER_NAME) 
			, [TRN REF NO] = ref_no 
			, [AMOUNT] = SUM(EP.amount) 
			, [COMMISSION] = SUM(ISNULL(EP.EP_commission,0) )  
			, [USER] = EP_User  
		FROM ErroneouslyPaymentNew EP WITH (NOLOCK), REMIT_TRN_LOCAL RT WITH (NOLOCK)
		WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
		AND EP_AgentCode= @AGENT
		AND EP_BranchCode = @BRANCH 
		AND RIGHT(ref_no,1)=@LastCharInDomTxn 
		AND EP_date BETWEEN @DATE1 AND @DATE2
		GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,EP_User,CONVERT(VARCHAR,EP_date,101)
		ORDER BY CONVERT(VARCHAR,EP_date,101) DESC


	END

	IF @FLAG ='PAYORD_USER_D'
	BEGIN	SELECT
				 [S.N.] = ROW_NUMBER() OVER(ORDER BY CONVERT(VARCHAR,PO_date,101) DESC)
				,[DATE] = CONVERT (VARCHAR , PO_date, 101)  
				,[TRN REF NO] =	ref_no  
				,[SENDER NAME] = UPPER(SENDER_NAME)  
				,[RECEIVER NAME] = UPPER(RECEIVER_NAME)   
	 			,[AMOUNT] = SUM( EP.amount) 
				,[COMMISSION] = SUM(ISNULL(EP.PO_commission,0) )  
				,[USER] = PO_User  
		FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_LOCAL RT WITH ( NOLOCK )
		WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
		AND PO_AgentCode= @AGENT
		AND PO_BranchCode = @BRANCH 
		AND RIGHT(ref_no,1)=@LastCharInDomTxn 
		AND PO_date BETWEEN @DATE1 AND  @DATE2
		GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,PO_User,CONVERT (VARCHAR , PO_date, 101)
		Order by CONVERT(VARCHAR,PO_date,101) desc
	
	END

	IF @FLAG ='ERR_USER'
	BEGIN
		
			SELECT 
				  [S.N.] = ROW_NUMBER() OVER(ORDER BY CONVERT(VARCHAR,EP_date,101) DESC)
				, [DATE] = CONVERT(VARCHAR,EP_date,101)
				, [SENDER NAME] = UPPER(SENDER_NAME) 
				, [RECEIVER NAME] = UPPER(RECEIVER_NAME) 
				, [TRN REF NO] = ref_no 
				, [AMOUNT] = SUM(EP.amount) 
				, [COMMISSION] = SUM(ISNULL(EP.EP_commission,0) )  
				, [USER] = EP_User  
			FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH (NOLOCK)
			WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
			AND EP_AgentCode= @AGENT
			AND EP_BranchCode = @BRANCH 
			AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
			AND EP_date BETWEEN @DATE1 AND @DATE2
			GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,EP_User,CONVERT (VARCHAR , EP_date, 101)
			ORDER BY CONVERT(VARCHAR,EP_date,101) DESC

	END

	IF @FLAG ='PAYORD_USER'
	BEGIN

		SELECT 
				 [S.N.] = ROW_NUMBER() OVER(ORDER BY CONVERT (VARCHAR , PO_date, 101) DESC)
				,[DATE] = CONVERT (VARCHAR , PO_date, 101)  
				,[TRN REF NO] =	ref_no  
				,[SENDER NAME] = UPPER(SENDER_NAME)  
				,[RECEIVER NAME] = UPPER(RECEIVER_NAME)   
	 			,[AMOUNT] = SUM( EP.amount) 
				,[COMMISSION] = SUM(ISNULL(EP.PO_commission,0) )  
				,[USER] = PO_User  
		FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH ( NOLOCK )
		WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
		AND PO_AgentCode= @AGENT
		AND PO_BranchCode=@BRANCH
		AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
		AND PO_date BETWEEN @DATE1 AND  @DATE2
		GROUP BY ref_no, SENDER_NAME,RECEIVER_NAME,PO_User,CONVERT (VARCHAR , PO_date, 101)
		order by CONVERT (VARCHAR , PO_date, 101) DESC 
	
	END

	IF @FLAG ='m'
	BEGIN
		   declare @USERVal varchar(200)
		   set @USERVal = ISNULL(@USER,'')

		   SELECT 
			  P_BRANCH BRANCH , A.agent_name, Particulars,
			  TXN, AMT
			,isnull(COMMISSION,'0.00')COMMISSION
			  INTO #TEM1
		   FROM 
		   (    
			  SELECT P_BRANCH,
				 '<a href="sett_drilldown_report.asp?FLAG=PAY_COUNTRY&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ P_BRANCH +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Int`l Remitt </a>' Particulars 
				 ,COUNT('x') TXN, SUM(P_AMT) AMT 
				-- , SUM(CASE WHEN ISNULL(SC_TOTAL,0)=0 THEN 0 ELSE ISNULL(SC_P_AGENT,0) END ) COMMISSION
				, SUM(ISNULL(SC_P_AGENT,0)) COMMISSION
			  FROM REMIT_TRN_MASTER RTM WITH ( NOLOCK) 
			  WHERE case when @isCentSett = 'y' then P_AGENT 
						else P_BRANCH end=@AGENT 
			  AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
			  AND P_BRANCH = isnull(@BRANCH , P_BRANCH)
			  GROUP BY P_BRANCH

			  UNION ALL

			  SELECT  map_code, 
				 '<a href="sett_drilldown_user.asp?FLAG=SEND_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Send - Domestic Remitt.</a>' Particulars 
				 ,COUNT('x') TXN, SUM(S_AMT)*-1 AMT
				---  , SUM(CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END ) COMMISSION
			 , SUM(ISNULL(S_SC,0)) COMMISSION
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
			 ,COUNT('x') TXN, SUM(S_AMT)*-1 AMT
			--  , SUM(CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END ) COMMISSION
			, SUM(ISNULL(S_SC,0)) COMMISSION
		  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
		  AND isnull(TranType,'') = 'B'
		  AND map_code = isnull(@BRANCH , map_code)
		  GROUP BY map_code 
			  UNION ALL 

			  SELECT  map_code, 
				 '<a href="sett_drilldown_user.asp?FLAG=PAY_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Domestic Remitt.</a>' Particulars 
				 ,COUNT('x') TXN, SUM(P_AMT) AMT 
			--	 , SUM(CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(R_SC,0) END ) COMMISSION
			, SUM(ISNULL(R_SC,0)) COMMISSION
			  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
			  WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
			  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
			  AND P_DATE BETWEEN @DATE1 AND @DATE2 
			  AND map_code = isnull(@BRANCH , map_code)
			  GROUP BY map_code 

			  UNION ALL 

			  SELECT  map_code, 
				 '<a href="sett_drilldown_user.asp?FLAG=CANCEL_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Cancel - Domestic Remitt.</a>' Particulars 
				 ,COUNT('x') TXN, SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE)  THEN S_AMT ELSE P_AMT+ ISNULL(R_SC,0) END) AMT
				-- ,SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE) THEN  ( CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END ) END) *-1 COMMISSION
				,SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE) THEN  ISNULL(S_SC,0) END) *-1 COMMISSION
			  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
			  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
			  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
			  AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
			  AND map_code = isnull(@BRANCH , map_code)

			  GROUP BY map_code 
		/*
		 
			  UNION ALL 
		   SELECT EP_BranchCode , '<a href="sett_drilldown_user.asp?FLAG=ERR_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid - Int`l</a>' Particulars 
				 ,COUNT('x') TXN
				 ,SUM (EP.amount)*-1 AMT 
				 ,SUM (CASE WHEN ISNULL(R.SC_TOTAL,0)=0 THEN 0  ELSE EP.EP_commission END )*-1 COMMISSION 
			   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_MASTER  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDB(EP.REF_NO)
			   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
			   AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
			   AND EP_date BETWEEN @DATE1 AND @DATE2
			   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
			   GROUP BY EP_BranchCode

			  UNION ALL 

			  SELECT PO_BranchCode, '<a href="sett_drilldown_user.asp?FLAG=PAYORD_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				   +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				   '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order- Int`l</a>' Particulars 
				   ,COUNT('x') TXN
				   ,SUM ( EP.Amount ) AMT 
				 ,SUM (CASE WHEN ISNULL(R.SC_TOTAL,0)=0 THEN 0  ELSE EP.PO_commission END ) COMMISSION 
			   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_MASTER  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDB(EP.REF_NO)
			  WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
			  AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
			  AND PO_date BETWEEN @DATE1 AND @DATE2
			  AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode)  
			  GROUP BY PO_BranchCode


			  UNION ALL 

			  SELECT EP_BranchCode , 
				 '<a href="sett_drilldown_user.asp?FLAG=ERR_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid -Domestic</a>' Particulars 
				 ,COUNT('x') TXN
				 ,SUM (EP.amount)*-1 AMT 
				 ,SUM (CASE WHEN ISNULL(R.TOTAL_SC,0)=0 THEN 0  ELSE EP.EP_commission END )*-1 COMMISSION 
			   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_LOCAL  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDBLOCAL(EP.REF_NO)
			   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
			   AND RIGHT(ref_no,1)=@LastCharInDomTxn 
			   AND EP_date BETWEEN @DATE1 AND @DATE2
			   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
			   GROUP BY EP_BranchCode

			  UNION ALL 

			  SELECT PO_BranchCode , 
				 '<a href="sett_drilldown_user.asp?FLAG=PAYORD_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order -Domestic</a>' Particulars 
				  ,COUNT('x') TXN
				   ,SUM (EP.Amount ) AMT 
				   ,SUM (CASE WHEN ISNULL(R.TOTAL_SC,0)=0 THEN 0  ELSE EP.PO_commission END ) COMMISSION 
			  	   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_LOCAL  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDBLOCAL(EP.REF_NO)
			    WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
			  AND RIGHT(ref_no,1)=@LastCharInDomTxn 
			  AND PO_date BETWEEN @DATE1 AND @DATE2
			  AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
			  GROUP BY PO_BranchCode
			*/
			
			  UNION ALL 

			   SELECT EP_BranchCode , '<a href="sett_drilldown_user.asp?FLAG=ERR_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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

			  SELECT PO_BranchCode, '<a href="sett_drilldown_user.asp?FLAG=PAYORD_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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
				 '<a href="sett_drilldown_user.asp?FLAG=ERR_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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
				 '<a href="sett_drilldown_user.asp?FLAG=PAYORD_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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
	end

	IF @FLAG ='m2'
	BEGIN
		   set @USERVal = ISNULL(@USER,'')
		   SELECT 
			  P_BRANCH BRANCH , A.agent_name, Particulars,
			  TXN, AMT
			  ,isnull(COMMISSION,'0.00')COMMISSION
			  INTO #TEM2
		   FROM 
		   (    
			  SELECT P_BRANCH,
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=PAY_COUNTRY&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ P_BRANCH +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Int`l Remitt </a>' Particulars 
				 ,COUNT('x') TXN, SUM(P_AMT) AMT
				 --,SUM(CASE WHEN ISNULL(SC_TOTAL,0)=0 THEN 0 ELSE ISNULL(SC_P_AGENT,0) END) COMMISSION 
				 , SUM(ISNULL(SC_P_AGENT,0)) COMMISSION
			  FROM REMIT_TRN_MASTER RTM WITH ( NOLOCK) 
			  WHERE case when @isCentSett = 'y' then P_AGENT 
						else P_BRANCH end=@AGENT 
			  AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
			  AND P_BRANCH = isnull(@BRANCH , P_BRANCH)
			  GROUP BY P_BRANCH

			  UNION ALL

			  SELECT  map_code, 
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=SEND_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Send - Domestic Remitt.</a>' Particulars 
				 ,COUNT('x') TXN, SUM(S_AMT)*-1 AMT
				---  ,SUM(CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END) COMMISSION 
				 , SUM(ISNULL(S_SC,0)) COMMISSION
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
			 ,COUNT('x') TXN, SUM(S_AMT)*-1 AMT
			--- , SUM(CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END ) COMMISSION
			 , SUM(ISNULL(S_SC,0)) COMMISSION
		  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
		  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
		  AND isnull(TranType,'') = 'B'
		  AND map_code = isnull(@BRANCH , map_code)
		  GROUP BY map_code 
		   UNION ALL
			  SELECT  map_code, 
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=PAY_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Paid - Domestic Remitt.</a>' Particulars 
				 ,COUNT('x') TXN, SUM(P_AMT) AMT 
				--- , SUM(CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(R_SC,0) END ) COMMISSION
				, SUM(ISNULL(R_SC,0)) COMMISSION
			  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
			  WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
			  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
			  AND P_DATE BETWEEN @DATE1 AND @DATE2 
			  AND map_code = isnull(@BRANCH , map_code)
			  GROUP BY map_code 

			  UNION ALL 

			  SELECT  map_code, 
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=CANCEL_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ map_code +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Cancel - Domestic Remitt.</a>' Particulars 
				 ,COUNT('x') TXN
				---  , SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE)  THEN S_AMT ELSE P_AMT+ (CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(R_SC,0) END )  END) AMT
				 , SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE)  THEN S_AMT ELSE P_AMT+ ISNULL(R_SC,0) END) AMT
				--- , SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE) THEN  (CASE WHEN ISNULL(TOTAL_SC,0)=0 THEN 0 ELSE ISNULL(S_SC,0) END) END) *-1 COMMISSION
				 , SUM(CASE WHEN CAST(CONFIRM_DATE AS DATE)=CAST(CANCEL_DATE AS DATE) THEN  ISNULL(S_SC,0) END) *-1 COMMISSION
			  FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
			  WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
			  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
			  AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
			  AND map_code = isnull(@BRANCH , map_code)

			  GROUP BY map_code 
			 /*
			 
			    UNION ALL 

			   SELECT EP_BranchCode , '<a href="Reports.aspx?reportName=settlementdom&FLAG=ERR_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid - Int`l</a>' Particulars 
				 ,COUNT('x') TXN
				 ,SUM (EP.amount)*-1 AMT 
				 ,SUM (CASE WHEN ISNULL(R.SC_TOTAL,0)=0 THEN 0  ELSE EP.EP_commission END )*-1 COMMISSION 
			   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_MASTER  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDB(EP.REF_NO)
			   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
			   AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
			   AND EP_date BETWEEN @DATE1 AND @DATE2 
			   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
			   GROUP BY EP_BranchCode

			  UNION ALL 

			  SELECT PO_BranchCode, '<a href="Reports.aspx?reportName=settlementdom&FLAG=PAYORD_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				   +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				   '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order- Int`l</a>' Particulars 
				   ,COUNT('x') TXN
				   ,SUM ( EP.Amount ) AMT 
				   ,SUM (CASE WHEN ISNULL(R.SC_TOTAL,0)=0 THEN 0  ELSE EP.PO_commission END )  COMMISSION 
			   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_MASTER  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDB(EP.REF_NO)
			  WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
			  AND RIGHT(ref_no,1)<>@LastCharInDomTxn 
			  AND PO_date BETWEEN @DATE1 AND @DATE2
			  AND PO_BranchCode = isnull(@BRANCH , PO_BranchCode) 
			  GROUP BY PO_BranchCode


			  UNION ALL 

			  SELECT EP_BranchCode , 
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=ERR_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ EP_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Erroneously Paid -Domestic</a>' Particulars 
				 ,COUNT('x') TXN
				 ,SUM (EP.amount)*-1 AMT 
				,SUM (CASE WHEN ISNULL(R.TOTAL_SC,0)=0 THEN 0  ELSE EP.EP_commission END )*-1 COMMISSION 
			   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_LOCAL  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDBLOCAL(EP.REF_NO)
			   WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
			   AND RIGHT(ref_no,1)=@LastCharInDomTxn 
			   AND EP_date BETWEEN @DATE1 AND @DATE2 
			   AND EP_BranchCode = isnull(@BRANCH , EP_BranchCode) 
			   GROUP BY EP_BranchCode

			  UNION ALL 

			  SELECT PO_BranchCode , 
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=PAYORD_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
				 +'&BRANCH='+ PO_BranchCode +'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+
				 '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Payment Order -Domestic</a>' Particulars 
				  ,COUNT('x') TXN
				   ,SUM (EP.Amount ) AMT 
				   ,SUM (CASE WHEN ISNULL(R.TOTAL_SC,0)=0 THEN 0  ELSE EP.PO_commission END ) COMMISSION 
			   FROM ErroneouslyPaymentNew EP WITH (NOLOCK)  INNER  JOIN  
				REMIT_TRN_LOCAL  R WITH (NOLOCK) 
				ON  R.TRN_REF_NO=DBO.ENCRYPTDBLOCAL(EP.REF_NO)
			  WHERE (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
			  AND RIGHT(ref_no,1)=@LastCharInDomTxn 
			  AND PO_date BETWEEN @DATE1 AND @DATE2
			  AND PO_BranchCode = isnull(@BRANCH , PO_BranchCode) 
			  GROUP BY PO_BranchCode
			 */
			 
			  UNION ALL 

			   SELECT EP_BranchCode , '<a href="Reports.aspx?reportName=settlementdom&FLAG=ERR_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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

			  SELECT PO_BranchCode, '<a href="Reports.aspx?reportName=settlementdom&FLAG=PAYORD_USER&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=ERR_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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
				 '<a href="Reports.aspx?reportName=settlementdom&FLAG=PAYORD_USER_D&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )
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

		   select row_number() over(order by agent_name) SN,agent_name into #temp3 from #TEM2
		   group by agent_name 

			IF (SELECT COUNT('X') FROM #temp3) > 1
			BEGIN
				SELECT 	
					 [S.N.] = x.SN		 
					,[Agent] = x.agent_name 
					,[Particulars] = particulars
					,[TXN Count] = CAST(TXN AS VARCHAR(20)) 
					,[Amount] = AMT
					,[Commission] = COMMISSION 
				FROM #TEM2 t inner join 
				(
					select * from #temp3
				)x on t.agent_name = x.agent_name
				ORDER BY x.agent_name
			END
			ELSE
			BEGIN
				SELECT 	
					 [S.N.] = ROW_NUMBER() OVER(ORDER BY agent_name)		 
					,[Agent] = agent_name 
					,[Particulars] = particulars
					,[TXN Count] = CAST(TXN AS VARCHAR(20)) 
					,[Amount] = AMT
					,[Commission] = COMMISSION 
				FROM #TEM2 
				ORDER BY agent_name
			END

			
	end

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id			

	SELECT 'From Date' head,@DATE1 VALUE
	UNION ALL 
	SELECT 'TO Date' head,@DATE3 VALUE
	UNION ALL 
	SELECT 'Agent' head,(SELECT agent_name FROM agentTable WITH(NOLOCK) WHERE map_code = @AGENT) VALUE
	UNION ALL 
	SELECT 'Branch' head,CASE WHEN @BRANCH IS NULL THEN '-' ELSE (SELECT agent_name FROM agentTable WITH(NOLOCK) WHERE central_sett_code = @BRANCH) END  VALUE

	SELECT 'Settlement Report' title	

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
     print error_line()
END CATCH




GO
