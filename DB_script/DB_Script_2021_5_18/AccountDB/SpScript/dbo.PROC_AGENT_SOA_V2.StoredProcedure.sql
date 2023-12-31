USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_AGENT_SOA_V2]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[PROC_AGENT_SOA_V2]
     @FLAG  VARCHAR (20)
    ,@AGENT VARCHAR (20) 
    ,@DATE1 VARCHAR (10) 
    ,@DATE2 VARCHAR (20) 
    ,@BRANCH VARCHAR(10) = NULL
    ,@AGENT2 VARCHAR(10) = NULL
    ,@TRN_TYPE VARCHAR(15) = NULL
	,@user VARCHAR(50)	= NULL
AS
	SET NOCOUNT ON;
	DECLARE @isCentSett VARCHAR(20),@date2old VARCHAR (20)
    DECLARE @LastCharInDomTxn CHAR(1) = dbo.FNALastCharInDomTxn()
 
	SET @date2old = @DATE2
	SET @DATE2 = @DATE2+ ' 23:59:59'

	IF(DATEDIFF(day,@DATE1,GETDATE())>120)
	BEGIN
		SELECT DATE =GETDATE(),
				Particulars ='<font color="red"><b>Date Range is not valid, You can only view transaction upto 120 days.</b></font>',
				DR =0,
				CR =0				
		RETURN
	END

	IF (DATEDIFF(day,@DATE1,@date2old) > 120)
	BEGIN
		SELECT DATE =GETDATE(),
				Particulars ='<font color="red"><b>Please select date range of 120 days.</b></font>',
				DR =0,
				CR =0				
		RETURN
	END

	SELECT  @isCentSett = ISNULL(central_sett,'n')  
	FROM agentTable WITH (NOLOCK) WHERE map_code =@AGENT

IF @FLAG ='PAID-I'
BEGIN
	--SELECT 
	--	  [S.N.] = ROW_NUMBER() OVER(PARTITION BY AT.AGENT_NAME ORDER BY AT.AGENT_NAME,RTM.paid_date)
	--	, [BRANCH] = AT.AGENT_NAME
	--	, [PAID DATE] = CONVERT(VARCHAR,paid_date, 101 ) 
	--	, [CONTROL NO.] = dbo.decryptDb(TRN_REF_NO)
	--	, [SENDER NAME] = UPPER(SENDER_NAME) 
	--	, [RECEIVER NAME] = UPPER(RECEIVER_NAME)  
	--	, [PAYOUT AMT] = P_AMT
	--	, [COMM] = SC_P_AGENT  
	--	, [PAID USER] = paidBy 
	--FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
	--INNER JOIN agenttable AT WITH(NOLOCK) ON RTM.P_BRANCH = AT.MAP_CODE
	--WHERE CASE WHEN @isCentSett ='y' THEN P_AGENT 
	--		 ELSE P_BRANCH END = @AGENT 
	--AND PAID_DATE BETWEEN @DATE1 AND @DATE2
	--ORDER BY AT.AGENT_NAME,RTM.paid_date

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id  
	SELECT 'AGENT' head, (SELECT AGENT_NAME FROM agenttable WITH(NOLOCK) WHERE MAP_CODE =@AGENT) value UNION ALL
	SELECT 'FROM DATE', @DATE1 UNION ALL
	SELECT 'TO DATE', @DATE2 
	SELECT 'Paid International - Detail' title
END

IF @FLAG ='PAID-D'
BEGIN
	--SELECT
	--		[S.N.]				= ROW_NUMBER() OVER(PARTITION BY AT.agent_name ORDER BY AT.agent_name,P_DATE),
	--		[BRANCH]			= AT.agent_name,
	--		[DATE]				= CONVERT(VARCHAR,P_DATE, 101),
	--		[CONTROL NO.]		= dbo.decryptDbLocal(TRN_REF_NO) ,
	--		[SENDER NAME]		= UPPER(SENDER_NAME),  
	--		[RECEIVER NAME]		= UPPER(RECEIVER_NAME),		
	--		[AMOUNT]			= P_AMT,
	--		[COMM]				= R_SC,
	--		[PAID USER]			= paidBy 
	--FROM VWREMIT_TRN_LOCAL RTL WITH(NOLOCK)
	--INNER JOIN agentTable AT WITH(NOLOCK) ON RTL.R_AGENT = AT.AGENT_IME_CODE
	--WHERE ISNULL(AT.central_sett_code,map_code)= @AGENT
	--	  AND P_DATE BETWEEN @DATE1 AND @DATE2
	--ORDER BY AT.agent_name,P_DATE

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id  
	SELECT 'AGENT' head, (SELECT AGENT_NAME FROM agenttable WITH(NOLOCK) WHERE MAP_CODE =@AGENT) value UNION ALL
	SELECT 'FROM DATE', @DATE1 UNION ALL
	SELECT 'TO DATE', @DATE2 
	SELECT 'Paid Domestic - Detail' title
END

IF @FLAG ='SEND-D'
BEGIN
	--SELECT 
	--	[S.N.]				= ROW_NUMBER() OVER(PARTITION BY AT.agent_name ORDER BY AT.agent_name,CONFIRM_DATE),
	--	[BRANCH]			= AT.agent_name,
	--	[DATE]				= CONVERT(VARCHAR,CONFIRM_DATE, 101),
	--	[CONTROL NO.]		= dbo.decryptDbLocal(TRN_REF_NO) ,
	--	[SENDER NAME]		= UPPER(SENDER_NAME),  
	--	[RECEIVER NAME]		= UPPER(RECEIVER_NAME),		
	--	[AMOUNT]			= S_AMT,
	--	[COMM]				= S_SC,
	--	[PAID USER]			= SEMPID 
	--FROM REMIT_TRN_LOCAL RTL WITH(NOLOCK)
	--INNER JOIN agentTable AT WITH (NOLOCK) ON RTL.S_AGENT = AT.AGENT_IME_CODE
	--WHERE ISNULL (AT.central_sett_code,map_code)= @AGENT
	--	AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2
	--	AND ISNULL(TranType,'') <> 'B'
	--ORDER BY AT.agent_name,CONFIRM_DATE

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id  
	SELECT 'AGENT' head, (SELECT AGENT_NAME FROM agenttable WITH(NOLOCK) WHERE MAP_CODE = @AGENT) value UNION ALL
	SELECT 'FROM DATE', @DATE1 UNION ALL
	SELECT 'TO DATE', @DATE2 
	SELECT 'Send Domestic - Detail' title
END
IF @FLAG ='PAY_USER_ISO'
BEGIN
			/*
			str.Append("<th><div align=\"left\">SN</div></th>");
            str.Append("<th><div align=\"left\">Date</div></th>");
            str.Append("<th><div align=\"left\">IME Tran No.</div></th>");
            str.Append("<th><div align=\"left\">Sender Name</div></th>");
            str.Append("<th><div align=\"left\">Benificiary Name</div></th>");
            str.Append("<th><div align=\"right\">Amount</div></th>");
            str.Append("<th><div align=\"left\">User</div></th>");
			*/
		--IF @TRN_TYPE = 'Bank Transfer'
		--BEGIN
				--SELECT 
				--	  [S.N.] = ROW_NUMBER() OVER(ORDER BY paid_date)
				--	, [Date] =  CONVERT(VARCHAR,paid_date, 101 ) 
				--	, [Tran No.] = dbo.decryptDb(TRN_REF_NO)
				--	, [Sender Name] = UPPER(SENDER_NAME)  
				--	, [Benificiary Name] = UPPER(RECEIVER_NAME)  
				--	, [Amount] = P_AMT
				--	, [User] = paidBy
				--	, [Account Number] = CustomerId
				--FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
				--INNER JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTM.TRN_REF_NO = iso.controlNo 
				--WHERE 
				--CASE WHEN @isCentSett ='y' THEN P_AGENT 
				--	ELSE P_BRANCH END = @AGENT 
				--AND P_BRANCH = @BRANCH
				--AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
				--AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
				
				--ORDER BY paid_date
				RETURN;
		--END
		/*
	   SELECT 
	        [S.N.] = ROW_NUMBER() OVER(ORDER BY paid_date)
		  , [Date] =  CONVERT(VARCHAR,paid_date, 101 ) 
		  , [IME Tran No.] = dbo.decryptDb(TRN_REF_NO)
		  , [Sender Name] = UPPER(SENDER_NAME)  
		  , [Benificiary Name] = UPPER(RECEIVER_NAME)  
		  , [Amount] = P_AMT
		  , [User] = paidBy
	   FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
	   WHERE 
		  CASE WHEN @isCentSett ='y' THEN P_AGENT 
			 ELSE P_BRANCH END = @AGENT 
		  AND P_BRANCH = @BRANCH
		  AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
	   AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
	 ORDER BY paid_date
	 */
END
IF @FLAG ='PAY_USER'
BEGIN
			/*
			str.Append("<th><div align=\"left\">SN</div></th>");
            str.Append("<th><div align=\"left\">Date</div></th>");
            str.Append("<th><div align=\"left\">IME Tran No.</div></th>");
            str.Append("<th><div align=\"left\">Sender Name</div></th>");
            str.Append("<th><div align=\"left\">Benificiary Name</div></th>");
            str.Append("<th><div align=\"right\">Amount</div></th>");
            str.Append("<th><div align=\"left\">User</div></th>");
			*/
		--IF @TRN_TYPE = 'Bank Transfer'
		--BEGIN
		--		SELECT 
		--			  [S.N.] = ROW_NUMBER() OVER(ORDER BY paid_date)
		--			, [Date] =  CONVERT(VARCHAR,paid_date, 101 ) 
		--			, [Tran No.] = dbo.decryptDb(TRN_REF_NO)
		--			, [Sender Name] = UPPER(SENDER_NAME)  
		--			, [Benificiary Name] = UPPER(RECEIVER_NAME)  
		--			, [Amount] = P_AMT
		--			, [User] = paidBy
		--			, [Account Number] = CustomerId
		--		FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
		--		LEFT JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTM.TRN_REF_NO = iso.controlNo 
		--		WHERE 
		--		CASE WHEN @isCentSett ='y' THEN P_AGENT 
		--			ELSE P_BRANCH END = @AGENT 
		--		AND P_BRANCH = @BRANCH
		--		AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
		--		AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
		--		AND iso.controlNo IS NULL
		--		ORDER BY paid_date
		--		RETURN;
		--END

	 --  SELECT 
	 --       [S.N.] = ROW_NUMBER() OVER(ORDER BY paid_date)
		--  , [Date] =  CONVERT(VARCHAR,paid_date, 101 ) 
		--  , [Tran No.] = dbo.decryptDb(TRN_REF_NO)
		--  , [Sender Name] = UPPER(SENDER_NAME)  
		--  , [Benificiary Name] = UPPER(RECEIVER_NAME)  
		--  , [Amount] = P_AMT
		--  , [User] = paidBy
	 --  FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
	 --  WHERE 
		--  CASE WHEN @isCentSett ='y' THEN P_AGENT 
		--	 ELSE P_BRANCH END = @AGENT 
		--  AND P_BRANCH = @BRANCH
		--  AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
	 --  AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
	 --ORDER BY paid_date
	 return
END

IF @FLAG ='PAY_COMPANY'
BEGIN

    SELECT T.DT,S_AGENT,
	   '<a href="drilDownUser.aspx?flag=PAY_USER&BRANCH='+ 
	   CAST(@BRANCH AS VARCHAR)+'&AGENT='+ CONVERT(VARCHAR,@AGENT, 101 )+
	   '&AGENT2='+ CONVERT(VARCHAR,S_AGENT, 101 )+ 
	   '&TRAN_TYPE='+CONVERT ( VARCHAR,TRN_TYPE, 101 )+
	   '&DATE1='+ CONVERT (VARCHAR,@DATE1, 101) + '&DATE2='+ CONVERT (VARCHAR,@DATE2, 101 )+
	    '">'+ A.agent_name +' - '+ CAST(TXN AS VARCHAR(20)) +'</a>' AS Particulars, 
    T.TXN, T.AMT FROM
    (
    SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
	   , S_AGENT  
	   ,COUNT ( TRN_REF_NO) TXN, SUM(P_AMT) AMT, TRN_TYPE
    FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
    WHERE 
	   CASE WHEN @isCentSett ='y' THEN P_AGENT 
			 ELSE P_BRANCH END = @AGENT
    AND P_BRANCH = @BRANCH
    AND PAID_DATE BETWEEN  @DATE1 AND @DATE2 
    AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
    GROUP BY CONVERT(VARCHAR , paid_date, 101) ,S_AGENT, TRN_TYPE
    )T , agentTable A
    WHERE T.S_AGENT = A.map_code
    ORDER BY T.DT, A.agent_name 

END
--PAY_BRANCH_ISO
IF @FLAG ='PAY_BRANCH_ISO'
BEGIN

    --PAY_COMPANY

    SELECT T.DT, P_BRANCH,
	   '<a href="drilDownUser.aspx?flag=PAY_USER_ISO&BRANCH='+ 
	   CAST(P_BRANCH AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
	   '&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 ) +'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+ 
	   '&TRAN_TYPE='+CONVERT ( VARCHAR,TRN_TYPE, 101 )+
	    '">'+ A.agent_name  +' - '+ CAST(TXN AS VARCHAR(20))+' ('+ t.TRN_TYPE +')</a>' AS Particulars
	    ,T.TXN, T.AMT 
    FROM
	   (
		  SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
			 , P_BRANCH  
			 ,COUNT ( TRN_REF_NO) TXN, SUM(P_AMT) AMT, TRN_TYPE 
		  FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
		  INNER JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTM.TRN_REF_NO = iso.controlNo 
		  WHERE 
			 CASE WHEN @isCentSett ='y' THEN P_AGENT 
				ELSE P_BRANCH END = @AGENT
		  AND PAID_DATE BETWEEN   @DATE1 AND @DATE2  
		  GROUP BY CONVERT(VARCHAR , paid_date, 101) ,P_BRANCH, TRN_TYPE
	   )T , agentTable A
    WHERE T.P_BRANCH = A.map_code
    ORDER BY T.DT, A.agent_name 

END

IF @FLAG ='PAY_BRANCH'
BEGIN

    --PAY_COMPANY

    SELECT T.DT, P_BRANCH,
	   '<a href="drilDownUser.aspx?flag=PAY_USER&BRANCH='+ 
	   CAST(P_BRANCH AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
	   '&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 ) +'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+ 
	   '&TRAN_TYPE='+CONVERT ( VARCHAR,TRN_TYPE, 101 )+
	    '">'+ A.agent_name  +' - '+ CAST(TXN AS VARCHAR(20))+' ('+ t.TRN_TYPE +')</a>' AS Particulars
	    ,T.TXN, T.AMT 
    FROM
	   (
		  SELECT CONVERT(VARCHAR,paid_date, 101 ) DT
			 , P_BRANCH  
			 ,COUNT ( TRN_REF_NO) TXN, SUM(P_AMT) AMT, TRN_TYPE 
		  FROM REMIT_TRN_MASTER RTM WITH (NOLOCK)
		  LEFT JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTM.TRN_REF_NO = iso.controlNo 
		  WHERE 
			 CASE WHEN @isCentSett ='y' THEN P_AGENT 
				ELSE P_BRANCH END = @AGENT
		  AND PAID_DATE BETWEEN   @DATE1 AND @DATE2  
		  AND iso.controlNo IS NULL
		  GROUP BY CONVERT(VARCHAR , paid_date, 101) ,P_BRANCH, TRN_TYPE
	   )T , agentTable A
    WHERE T.P_BRANCH = A.map_code
    ORDER BY T.DT, A.agent_name 

END


IF @FLAG ='SEND_BRANCH_D'
BEGIN

	   SELECT CONVERT(VARCHAR , CONFIRM_DATE, 101)DT ,
		   S_AGENT, 
		  '<a href="drilDownUser.aspx?flag=SEND_USER_D&AGENT2='+ 
		  CAST(S_AGENT AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 )+'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+
		  '">'+  agent_name +' - '+ CAST(COUNT ( TRN_REF_NO)AS VARCHAR(20)) +' </a>' AS  Particulars 
		  ,COUNT ( TRN_REF_NO) TXN, SUM(S_AMT) AMT 
	   FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
	   WHERE RTL.S_AGENT = AT.AGENT_IME_CODE 
	   AND ISNULL (AT.central_sett_code,map_code)= @AGENT
	   AND CONFIRM_DATE BETWEEN   @DATE1 AND @DATE2  
	   AND ISNULL(TranType,'') <> 'B'
	   GROUP BY CONVERT(VARCHAR , CONFIRM_DATE, 101) ,S_AGENT, agent_name 
	
END

IF @FLAG ='SEND_USER_D'
BEGIN

	   SELECT 
			 [S.N.] = ROW_NUMBER() OVER(ORDER BY CONFIRM_DATE)
			,[Date] = CONVERT(VARCHAR , CONFIRM_DATE, 101)
		    ,[SENDER NAME] = UPPER(SENDER_NAME)  
		   ,[RECEIVER NAME] = UPPER(RECEIVER_NAME)  
		   ,dbo.decryptDbLocal(TRN_REF_NO) [CONTROL NO.], S_AMT [AMOUNT], SEMPID AS [USER] 
		  ,'' CustomerId
	   FROM REMIT_TRN_LOCAL RTL WITH(NOLOCK), agentTable AT WITH (NOLOCK) 
	   WHERE RTL.S_AGENT = AT.AGENT_IME_CODE 
		  AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
		  AND S_AGENT = @AGENT2
		  AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2
		  AND ISNULL(TranType,'') <> 'B'
		ORDER BY CONFIRM_DATE

END

IF @FLAG ='PAID_BRANCH_D'
BEGIN
return
	   --SELECT CONVERT(VARCHAR , P_DATE, 101)DT ,
		  --R_AGENT,   '<a href="drilDownUser.aspx?flag=PAID_USER_D&AGENT2='+ 
		  --CAST(R_AGENT AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  --'&TRAN_TYPE='+CONVERT ( VARCHAR,TRN_TYPE, 101 )+
		  --'&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 )+'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+
		  --'">'+  agent_name +' - '+ CAST(COUNT ('x')AS VARCHAR(20)) +
		  -- +' ('+ RTL.TRN_TYPE +')</a>' AS  Particulars 
		  --,COUNT(TRN_REF_NO) TXN, SUM(P_AMT) AMT 
	   --FROM VWREMIT_TRN_LOCAL RTL WITH ( NOLOCK)
	   --INNER JOIN  agentTable AT WITH ( NOLOCK ) ON  RTL.R_AGENT = AT.AGENT_IME_CODE 
	   --LEFT JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTL.TRN_REF_NO = iso.controlNo
	   --WHERE  ISNULL (AT.central_sett_code,map_code)= @AGENT
	   --AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
	   --AND P_DATE BETWEEN  @DATE1 AND @DATE2  
	   --AND iso.controlNo IS NULL
	   --GROUP BY CONVERT(VARCHAR , P_DATE, 101) ,R_AGENT, agent_name, TRN_TYPE
	
END

IF @FLAG ='PAID_BRANCH_D_ISO'
BEGIN
return
	   --SELECT CONVERT(VARCHAR , P_DATE, 101)DT ,
		  --R_AGENT,   '<a href="drilDownUser.aspx?flag=PAID_USER_D_ISO&AGENT2='+ 
		  --CAST(R_AGENT AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  --'&TRAN_TYPE='+CONVERT ( VARCHAR,TRN_TYPE, 101 )+
		  --'&DATE1='+ CONVERT ( VARCHAR,@DATE1, 101 )+'&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+
		  --'">'+  agent_name +' - '+ CAST(COUNT ('x')AS VARCHAR(20)) +
		  -- +' ('+ RTL.TRN_TYPE +')</a>' AS  Particulars 
		  --,COUNT(TRN_REF_NO) TXN, SUM(P_AMT) AMT 
	   --FROM VWREMIT_TRN_LOCAL RTL WITH ( NOLOCK)
	   --INNER JOIN agentTable AT WITH ( NOLOCK ) ON  RTL.R_AGENT = AT.AGENT_IME_CODE 
	   --INNER JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTL.TRN_REF_NO = iso.controlNo
	   --WHERE RTL.R_AGENT = AT.AGENT_IME_CODE 
	   --AND ISNULL (AT.central_sett_code,map_code)= @AGENT
	   --AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
	   --AND P_DATE BETWEEN  @DATE1 AND @DATE2  	   
	   --GROUP BY CONVERT(VARCHAR , P_DATE, 101) ,R_AGENT, agent_name, TRN_TYPE
	
END

IF @FLAG ='PAID_USER_D'
BEGIN
return
	  -- SELECT 
			--[S.N.] = ROW_NUMBER() OVER(ORDER BY P_DATE),
	  --      CONVERT(VARCHAR , P_DATE, 101) [DATE] ,
		 --   UPPER(SENDER_NAME) AS [SENDER NAME]
		 -- , UPPER(RECEIVER_NAME) AS [RECEIVER NAME]
		 -- , dbo.decryptDbLocal(TRN_REF_NO) [CONTROL NO.], P_AMT [AMOUNT], paidBy AS [USER] ,'' CustomerId
	  -- FROM VWREMIT_TRN_LOCAL RTL WITH ( NOLOCK)
	  -- INNER JOIN agentTable AT WITH ( NOLOCK ) ON RTL.R_AGENT = AT.AGENT_IME_CODE 
	  -- LEFT JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTL.TRN_REF_NO = iso.controlNo
	  -- WHERE RTL.R_AGENT = AT.AGENT_IME_CODE 
		 -- AND ISNULL (AT.central_sett_code,map_code)= @AGENT
		 -- AND R_AGENT = @AGENT2
		 -- AND P_DATE BETWEEN  @DATE1 AND @DATE2
		 -- AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)
		 -- AND iso.controlNo IS NULL
		 -- ORDER BY P_DATE
END

IF @FLAG ='PAID_USER_D_ISO'
BEGIN
return
	  -- SELECT 
			--[S.N.] = ROW_NUMBER() OVER(ORDER BY P_DATE),
	  --      CONVERT(VARCHAR , P_DATE, 101) [DATE] ,
		 --   UPPER(SENDER_NAME) AS [SENDER NAME]
		 -- , UPPER(RECEIVER_NAME) AS [RECEIVER NAME]
		 -- , dbo.decryptDbLocal(TRN_REF_NO) [CONTROL NO.], P_AMT [AMOUNT], paidBy AS [USER] ,'' CustomerId
	  -- FROM VWREMIT_TRN_LOCAL RTL WITH ( NOLOCK)
	  -- INNER JOIN agentTable AT WITH ( NOLOCK ) ON  RTL.R_AGENT = AT.AGENT_IME_CODE 
	  -- INNER JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTL.TRN_REF_NO = iso.controlNo
	  -- WHERE RTL.R_AGENT = AT.AGENT_IME_CODE 
		 -- AND ISNULL (AT.central_sett_code,map_code)= @AGENT
		 -- AND R_AGENT = @AGENT2
		 -- AND P_DATE BETWEEN  @DATE1 AND @DATE2
		 -- AND TRN_TYPE = ISNULL(@TRN_TYPE , TRN_TYPE)		  
		 -- ORDER BY P_DATE

		 
END
IF @FLAG ='CANCEL_BRANCH_D'
BEGIN


    SELECT CONVERT(VARCHAR , CANCEL_DATE, 101)DT ,S_AGENT,
	    '<a href="drilDownUser.aspx?flag=CANCEL_USER_D&AGENT2='+ 
		  CAST(S_AGENT AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,CANCEL_DATE, 101 )+'&DATE2='+CONVERT ( VARCHAR,CANCEL_DATE, 101 )+
		  '">'+  agent_name +' - '+ CAST(COUNT ( TRN_REF_NO)AS VARCHAR(20)) +' </a>' AS Particulars 
	   ,COUNT (TRN_REF_NO) Txn, 
	   SUM(CASE WHEN CONVERT(VARCHAR,CANCEL_DATE ,101) 
	   = CONVERT(VARCHAR,CONFIRM_DATE, 101) THEN S_AMT ELSE P_AMT+R_SC END ) AMT 
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH (NOLOCK ) 
    WHERE RTL.S_AGENT = AT .AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT
    AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2  
    GROUP BY CONVERT(VARCHAR , CANCEL_DATE, 101),agent_name,S_AGENT


END

IF @FLAG ='CANCEL_USER_D'
BEGIN


    SELECT	[S.N.] = ROW_NUMBER() OVER(ORDER BY CANCEL_DATE),
			[Date] = CONVERT(VARCHAR, CANCEL_DATE, 101),
		   UPPER(SENDER_NAME) AS [SENDER NAME]
		  , UPPER(RECEIVER_NAME) AS [RECEIVER NAME]
		  ,dbo.decryptDbLocal(TRN_REF_NO)[CONTROL NO.], 
		  CASE WHEN CONVERT(VARCHAR,CANCEL_DATE , 101) = 
			 CONVERT(VARCHAR,CONFIRM_DATE, 101) 
		  THEN S_AMT ELSE P_AMT+R_SC END  [AMOUNT],
		  ISNULL(CANCEL_USER,SEmpID) [USER] ,'' CustomerId
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH (NOLOCK ) 
    WHERE RTL.S_AGENT = AT .AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT
    AND S_AGENT = @AGENT2 
    AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
    ORDER BY CANCEL_DATE


END

IF @FLAG ='ERR_BRANCH_D'
BEGIN

     SELECT CONVERT (VARCHAR , EP_date, 101)DT , 
		EP_BranchCode,
		'<a href="drilDownUser.aspx?flag=ERR_USER_D&AGENT2='+ 
		  CAST(EP_BranchCode AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,EP_date, 101 )+'&DATE2='+CONVERT ( VARCHAR,EP_date, 101 )+
		  '">'+  agent_name +' - '+ CAST(COUNT('x')AS VARCHAR(20)) +' </a>'
		  AS  Particulars 
	   , COUNT(REF_NO ) TXN, SUM (Amount ) AMT 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.EP_BranchCode = AT.map_code 
    AND  (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
    AND RIGHT(ref_no,1)=@LastCharInDomTxn 
    AND EP_date BETWEEN @DATE1 AND @DATE2
    GROUP BY CONVERT (VARCHAR, EP_date, 101),agent_name,EP_BranchCode


END

IF @FLAG ='ERR_USER_D'
BEGIN
return
 --   SELECT 
	--	[S.N.] = ROW_NUMBER()OVER(ORDER BY EP_date),
	--	[Date] = CONVERT (VARCHAR , EP_date, 101) , 
	--	ref_no AS [Control No.], SENDER_NAME [Sender Name], RECEIVER_NAME [Receiver Name]
	--   , Amount [Amount], EP_User [User]  ,'' CustomerId
 --   FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), VWREMIT_TRN_LOCAL RT WITH (NOLOCK)
 --   WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
 --   AND (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
 --   AND EP_BranchCode = @AGENT2 
 --   AND RIGHT(ref_no,1)=@LastCharInDomTxn 
 --   AND EP_date BETWEEN @DATE1 AND @DATE2
	--ORDER BY EP_date

END

IF @FLAG ='PAYORD_BRANCH_D'
BEGIN
     SELECT 
			
			DT = CONVERT (VARCHAR , PO_date, 101), 	
				PO_BranchCode,	
			Particulars = '<a href="drilDownUser.aspx?flag=PAYORD_USER_D&AGENT2='+ 
				CAST(PO_BranchCode AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
				'&DATE1='+ CONVERT ( VARCHAR,PO_date, 101 )+'&DATE2='+CONVERT ( VARCHAR,PO_date, 101 )+'">'+  agent_name +' - '+ CAST(COUNT('x')AS VARCHAR(20)) +' </a>',		 
			TXN = COUNT(REF_NO ), 
			P_AMT = SUM(Amount)  
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.PO_BranchCode = AT.map_code 
    AND  (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT) 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn
    AND PO_date BETWEEN @DATE1 AND  @DATE2
    GROUP BY CONVERT (VARCHAR, PO_date, 101),agent_name,PO_BranchCode

END

IF @FLAG ='PAYORD_USER_D'
BEGIN
return
 --   SELECT 
	--	[S.N.] = ROW_NUMBER()OVER(ORDER BY PO_date),
	--	[Date] = CONVERT (VARCHAR , PO_date, 101) , 
	--	ref_no AS [Control No.],[Sender Name] = SENDER_NAME, [Receiver Name] = RECEIVER_NAME 
	--   , Amount [Amount], PO_User [User] ,'' CustomerId
 --   FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), VWREMIT_TRN_LOCAL RT WITH ( NOLOCK )
 --   WHERE dbo.encryptDbLocal(EP.ref_no) = RT.TRN_REF_NO
 --   AND (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
 --   AND PO_BranchCode = @AGENT2 
 --   AND RIGHT(ref_no,1)=@LastCharInDomTxn
 --   AND PO_date BETWEEN @DATE1 AND  @DATE2
	--ORDER BY PO_date

END

IF @FLAG ='ERR_BRANCH'
BEGIN
     SELECT CONVERT (VARCHAR , EP_date, 101)DT , 
		EP_BranchCode,
		'<a href="drilDownUser.aspx?flag=ERR_USER&AGENT2='+ 
		  CAST(EP_BranchCode AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,EP_date, 101 )+'&DATE2='+CONVERT ( VARCHAR,EP_date, 101 )+
		  '">'+  agent_name +' - '+ CAST(COUNT('x')AS VARCHAR(20)) +' </a>'
		  AS  Particulars 
	   , COUNT(REF_NO ) TXN, SUM (Amount ) AMT 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.EP_BranchCode = AT.map_code 
    AND  (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT) 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn
    AND EP_date BETWEEN @DATE1 AND @DATE2
    GROUP BY CONVERT (VARCHAR, EP_date, 101),agent_name,EP_BranchCode


END

IF @FLAG ='ERR_USER'
BEGIN

	SELECT 
		 [S.N.] = ROW_NUMBER() OVER(ORDER BY EP_date)
		,[Date] = CONVERT (VARCHAR , EP_date, 101) 
		,[Control No.] = ref_no 
		,[Sender Name] = SENDER_NAME
		,[Receiver Name] = RECEIVER_NAME 
		,[Amount] = Amount 
		,[User] = EP_User  
		,'' CustomerId
	FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH (NOLOCK)
	WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
	AND (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT)
	AND EP_BranchCode = @AGENT2 
	AND RIGHT(ref_no,1)<>@LastCharInDomTxn
	AND EP_date BETWEEN @DATE1 AND @DATE2
	ORDER BY EP_date


END

IF @FLAG ='PAYORD_BRANCH'
BEGIN

    SELECT CONVERT (VARCHAR , PO_date, 101)DT , 
		P_BRANCH = PO_BranchCode,
		'<a href="drilDownUser.aspx?flag=PAYORD_USER&AGENT2='+ 
		  CAST(PO_BranchCode AS VARCHAR)+'&AGENT='+CONVERT ( VARCHAR,@AGENT, 101 )+ 
		  '&DATE1='+ CONVERT ( VARCHAR,PO_date, 101 )+'&DATE2='+CONVERT ( VARCHAR,PO_date, 101 )+
		  '">'+  agent_name +' - '+ CAST(COUNT('x')AS VARCHAR(20)) +' </a>'
		  AS  Particulars  
	   , COUNT(REF_NO ) TXN, SUM (Amount ) AMT 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) , agentTable AT
    WHERE EP.PO_BranchCode = AT.map_code 
    AND  (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn
    AND PO_date BETWEEN @DATE1 AND  @DATE2
    GROUP BY CONVERT (VARCHAR, PO_date, 101),agent_name,PO_BranchCode

END

IF @FLAG ='PAYORD_USER'
BEGIN

    SELECT 
		[S.N.] = ROW_NUMBER() OVER(ORDER BY PO_date),
		[Date] = CONVERT (VARCHAR , PO_date, 101) , 
		[Control No.] = ref_no, 
		[Sender Name] = SENDER_NAME, 
		[Receiver Name] = RECEIVER_NAME, 
	    [Amount] = Amount, 
		[User] = PO_User,
		'' CustomerId
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ), REMIT_TRN_MASTER RT WITH ( NOLOCK )
    WHERE dbo.encryptDb(EP.ref_no) = RT.TRN_REF_NO
    AND (PO_AgentCode=@AGENT OR PO_BranchCode=@AGENT)
    AND PO_BranchCode = @AGENT2 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn
    AND PO_date BETWEEN @DATE1 AND  @DATE2
	ORDER BY  PO_date

END

IF @FLAG ='SOA'
BEGIN

    DECLARE @AGENT_AC VARCHAR(20), @OPENINGBAL MONEY

    SELECT @AGENT_AC = acct_num FROM agentTable ag, ac_master ac
WHERE ac.agent_id = ag.agent_id 
    AND  ag.map_code = @AGENT
    AND ac.acct_rpt_code = '20'

	IF CAST(@date1 AS DATE) >= '2015-07-17'
	BEGIN 
		SELECT @OPENINGBAL = ISNULL(SUM (CASE WHEN part_tran_type='dr' 
		THEN tran_amt*-1 ELSE tran_amt END) ,0)
		FROM tran_master  WITH (NOLOCK) WHERE acc_num=@AGENT_AC 
		AND tran_date < @DATE1
	END	
	--IF CAST(@date1 AS DATE) <='2015-07-16'
	--BEGIN 
	--	SELECT @OPENINGBAL = SUM (CASE WHEN part_tran_type='dr' 
	--	THEN tran_amt*-1 ELSE tran_amt END) 
	--	FROM tranmasterold  WITH (NOLOCK) WHERE acc_num=@AGENT_AC 
	--	AND tran_date < @DATE1
	--END
	DECLARE 
		@urlPaidIntl AS VARCHAR(500),
		@urlPaidDom AS VARCHAR(500),
		@urlSendDom VARCHAR(500)
	SET @urlPaidIntl ='"'+SendMnPro_Remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&mode=download&rtpType=PAID-I&fromDate='+@DATE1+'&toDate='+@date2old+'&mapCode='+@AGENT+'"'
	SET @urlPaidDom ='"'+SendMnPro_Remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&mode=download&rtpType=PAID-D&fromDate='+@DATE1+'&toDate='+@date2old+'&mapCode='+@AGENT+'"'	
	SET @urlSendDom ='"'+SendMnPro_Remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&mode=download&rtpType=SEND-D&fromDate='+@DATE1+'&toDate='+@date2old+'&mapCode='+@AGENT+'"'		

SELECT 
	 DATE = CONVERT(VARCHAR,CAST(T.DT AS DATE) ,101)
	,Particulars
	,DR
	,CR
 FROM 
(    
    SELECT CONVERT (VARCHAR,CAST(@DATE1 AS DATETIME), 101 ) DT,'Opening Balance' Particulars,0 TXN,
		ISNULL(@OPENINGBAL,0.00) DR ,'0' CR 
	
    UNION ALL

    SELECT CONVERT ( VARCHAR,paid_date, 101 ) DATE ,
	   '<a href="drilDown.aspx?FLAG=PAY_BRANCH&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,paid_date, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,paid_date, 101 )+'">Paid - Int`l Remitt - '+
			 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+@urlPaidIntl+');>(Export to Excel)</span>' Particulars 
	   ,1 TXN, 0 DR, SUM(P_AMT) CR  
    FROM REMIT_TRN_MASTER RTM WITH ( NOLOCK) 
	LEFT JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTM.TRN_REF_NO = iso.controlNo
    WHERE CASE WHEN @isCentSett ='y' THEN P_AGENT 
			 ELSE P_BRANCH END = @AGENT 
    AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
	AND iso.controlNo IS NULL
    GROUP BY CONVERT(VARCHAR , paid_date, 101) 

    UNION ALL 

    SELECT CONVERT(VARCHAR , CONFIRM_DATE, 101)DATE , 
	   '<a href="drilDown.aspx?FLAG=SEND_BRANCH_D&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,CONFIRM_DATE, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,CONFIRM_DATE, 101 )+'">Send - Domestic Remitt. - '+
	    CAST(COUNT('x') AS VARCHAR(20))+' </a> &nbsp;<span class="link" onclick=DownloadExcel('+@urlSendDom+');>(Export to Excel)</span>' Particulars 
	   ,4, SUM(S_AMT) Debit, 0 Credit 
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
    WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
	AND ISNULL(TranType,'') <> 'B'
    GROUP BY CONVERT(VARCHAR , CONFIRM_DATE, 101) 

	UNION ALL 

    SELECT CONVERT(VARCHAR , CONFIRM_DATE, 101)DATE , 
	   'Send - Domestic Remit' Particulars 
	   ,5, SUM(S_AMT) Debit, 0 Credit 
    FROM VWREMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH ( NOLOCK ) 
    WHERE RTL.S_AGENT =AT.AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND CONFIRM_DATE BETWEEN @DATE1 AND @DATE2 
    AND ISNULL(TranType,'') = 'B'
    GROUP BY CONVERT(VARCHAR , CONFIRM_DATE, 101) 

    UNION ALL 

    SELECT CONVERT(VARCHAR,P_DATE, 101)DATE , 
		'<a href="drilDown.aspx?FLAG=PAID_BRANCH_D&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,P_DATE, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,P_DATE, 101 )+'">Paid - Domestic Remitt. - '+
	    CAST(COUNT('x') AS VARCHAR(20))+' </a> &nbsp;<span class="link" onclick=DownloadExcel('+@urlPaidDom+');>(Export to Excel)</span>' Particulars 
	   ,5, 0 Debit, SUM(p_AMT) Credit 
    FROM VWREMIT_TRN_LOCAL RTL WITH ( NOLOCK)
	INNER JOIN agentTable AT WITH ( NOLOCK ) ON  RTL.R_AGENT = AT.AGENT_IME_CODE 
	LEFT JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTL.TRN_REF_NO = iso.controlNo
    WHERE RTL.R_AGENT =AT.AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND P_DATE BETWEEN @DATE1 AND @DATE2 
	AND iso.controlNo IS NULL
	
    GROUP BY CONVERT(VARCHAR ,P_DATE , 101) 

    UNION ALL

    SELECT CONVERT(VARCHAR , CANCEL_DATE, 101)DATE ,
	   '<a href="drilDown.aspx?FLAG=CANCEL_BRANCH_D&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,CANCEL_DATE, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,CANCEL_DATE, 101 )+'">Cancel - Domestic Remitt. - '+
	    CAST(COUNT('x') AS VARCHAR(20))+' </a> ' AS Particulars 
	   ,6, 0 Debit, 
    SUM(S_AMT) Credit 
    FROM REMIT_TRN_LOCAL RTL WITH ( NOLOCK), agentTable AT WITH (NOLOCK ) 
    WHERE RTL.S_AGENT= AT .AGENT_IME_CODE 
    AND ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
    GROUP BY CONVERT(VARCHAR , CANCEL_DATE, 101) 
    
    UNION ALL 
    
    SELECT CONVERT(VARCHAR,EP_date, 101)DATE , 
	   '<a href="drilDown.aspx?FLAG=ERR_BRANCH&AGENT='+
			 CONVERT ( VARCHAR,@AGENT , 101 )+'&DATE1='+CONVERT ( VARCHAR,EP_date, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,EP_date, 101 )+'"> Erroneously Paid - Int`l - '+
		   CAST(COUNT('x') AS VARCHAR(20))+' </a> ' Particulars 
		  ,2, SUM (Amount ) Debit, 0 Credit 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
    WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT ) 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn
    AND EP_date BETWEEN @DATE1 AND  @DATE2
    GROUP BY EP_date

    UNION ALL 

    SELECT CONVERT(VARCHAR,PO_date, 101)DATE , 
		  '<a href="drilDown.aspx?FLAG=PAYORD_BRANCH&AGENT='+
			 CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,PO_date, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,PO_date, 101 )
			 +'"> Payment Order- Int`l - '+
		   CAST(COUNT('x') AS VARCHAR(20))+' </a> ' Particulars 
			 ,3, 0 Debit ,SUM(Amount)Credit 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
    WHERE (PO_AgentCode=@AGENT  OR PO_BranchCode=@AGENT ) 
    AND RIGHT(ref_no,1)<>@LastCharInDomTxn
    AND PO_date BETWEEN @DATE1 AND  @DATE2  
    GROUP BY PO_date

    UNION ALL 

    SELECT CONVERT(VARCHAR , EP_date, 101)DATE , 
		  '<a href="drilDown.aspx?FLAG=ERR_BRANCH_D&AGENT='+
			 CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,EP_date, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,EP_date, 101 )+'"> Erroneously Paid -Domestic -'
		  +CAST(COUNT('x') AS VARCHAR(20)) +'</a>' Particulars 
		  ,7, SUM (Amount ) Debit, 0 Credit 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
    WHERE (EP_AgentCode=@AGENT OR EP_BranchCode=@AGENT ) 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn
    AND EP_date BETWEEN @DATE1 AND  @DATE2
    GROUP BY EP_date

    UNION ALL 

    SELECT CONVERT(VARCHAR,PO_date, 101)DATE , 
		  '<a href="drilDown.aspx?FLAG=PAYORD_BRANCH_D&AGENT='+
			 CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,PO_date, 101 )+
			 '&DATE2='+CONVERT ( VARCHAR,PO_date, 101 )+'"> Payment Order -Domestic -'
		  +CAST(COUNT('x') AS VARCHAR(20)) +'</a>' Particulars 
		  , 8, 0 Debit , SUM ( Amount) Credit 
    FROM ErroneouslyPaymentNew EP WITH ( NOLOCK ) 
    WHERE (PO_AgentCode=@AGENT  OR PO_BranchCode=@AGENT ) 
    AND RIGHT(ref_no,1)=@LastCharInDomTxn
    AND PO_date BETWEEN @DATE1 AND  @DATE2  
    GROUP BY PO_date

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
    AND (ISNULL(T.rpt_code,'') <>'S' AND ISNULL(T.rpt_code,'')<>'POI' 
    AND ISNULL(T.rpt_code,'') <> 'EPI' AND ISNULL(T.rpt_code,'')<>'POD' 
    AND ISNULL(T.rpt_code,'')<> 'EPD' OR T.rpt_code IS NULL ) 
	AND  T.tran_date>= (CASE WHEN CAST(@DATE1 AS DATE)<'2015-07-18' THEN '2015-07-17' ELSE @DATE1 END)


	----UNION ALL
 
 ----   SELECT CONVERT(VARCHAR,T.tran_date, 101 ) DATE , TD.tran_particular Particulars , 0.1
	----   ,CASE WHEN T . part_tran_type='DR' THEN T.tran_amt ELSE 0 END Debit , 
	----   CASE WHEN part_tran_type='CR' THEN tran_amt ELSE 0 END Credit 
 ----   FROM TranMasterOLD t WITH ( NOLOCK )
	----   , TranMasterDetailOld TD WITH (NOLOCK) 
 ----   WHERE T.acc_num = @AGENT_AC
 ----   AND T.ref_num=TD.ref_num 
 ----   AND T.tran_type=TD.tran_type 
 ----   AND T.tran_date BETWEEN @DATE1 AND @DATE2 
 ----   AND (ISNULL(T.rpt_code,'') <>'S' AND ISNULL(T.rpt_code,'')<>'POI' 
 ----   AND ISNULL(T.rpt_code,'') <> 'EPI' AND ISNULL(T.rpt_code,'')<>'POD' 
 ----   AND ISNULL(T.rpt_code,'')<> 'EPD' OR T.rpt_code IS NULL ) 
	
	    UNION ALL

    SELECT CONVERT ( VARCHAR,paid_date, 101 ) DATE ,
	   '<a href="drilDown.aspx?FLAG=PAY_BRANCH_ISO&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,paid_date, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,paid_date, 101 )+'">Paid - Bank Transfer(ISO) - '+
			 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+@urlPaidIntl+');>(Export to Excel)</span>' Particulars 
	   ,1 TXN, 0 DR, SUM(P_AMT) CR  
    FROM REMIT_TRN_MASTER RTM WITH ( NOLOCK) 
	INNER JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTM.TRN_REF_NO = iso.controlNo
    WHERE CASE WHEN @isCentSett ='y' THEN P_AGENT 
			 ELSE P_BRANCH END = @AGENT 
    AND PAID_DATE BETWEEN @DATE1 AND @DATE2 
	
    GROUP BY CONVERT(VARCHAR , paid_date, 101) 
	
	UNION ALL
	SELECT CONVERT(VARCHAR,P_DATE, 101)DATE , 
		'<a href="drilDown.aspx?FLAG=PAID_BRANCH_D_ISO&AGENT='+
		  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,P_DATE, 101 )+
		  '&DATE2='+CONVERT ( VARCHAR,P_DATE, 101 )+'">Paid - Bank Transfer DOM(ISO) - '+
	    CAST(COUNT('x') AS VARCHAR(20))+' </a> &nbsp;<span class="link" onclick=DownloadExcel('+@urlPaidDom+');>(Export to Excel)</span>' Particulars 
	   ,5, 0 Debit, SUM(p_AMT) Credit 
    FROM VWREMIT_TRN_LOCAL RTL WITH ( NOLOCK) 
	INNER JOIN agentTable AT WITH ( NOLOCK ) ON RTL.R_AGENT =AT.AGENT_IME_CODE  	
	INNER JOIN SendMnPro_Remit.dbo.vwBankDepositFromISO iso ON RTL.TRN_REF_NO = iso.controlNo
    WHERE ISNULL (AT.central_sett_code,map_code)= @AGENT 
    AND P_DATE BETWEEN @DATE1 AND @DATE2 	
    GROUP BY CONVERT(VARCHAR ,P_DATE , 101) 

)T 
ORDER BY CAST(T.DT AS DATE), TXN

END





GO
