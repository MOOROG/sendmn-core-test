ALTER  PROC [dbo].[PROC_AGENT_SOA_INT]
     @FLAG  VARCHAR (50)
    ,@AGENT VARCHAR (20) 
    ,@DATE1 VARCHAR (10) 
    ,@DATE2 VARCHAR (20)   
AS
SET NOCOUNT ON;

DECLARE @StartDate DATETIME,@EndDate datetime

SELECT @StartDate =StartDate,@EndDate = EndDate  FROM FiscalYear (nolock) where IsFY = 1

	DECLARE	 @GRACEDAYS INT	
			,@GRACESTARTDATE VARCHAR(10)
			,@OPENINGBAL MONEY
			,@AGENT_AC VARCHAR(20)
			,@AGENTADDRESS INT 
			,@URL varchar(max)
			,@MSG VARCHAR(MAX)
			,@IsIntlAgent BIT  = 0
	
	IF CAST(@DATE1 AS DATE) NOT BETWEEN @StartDate AND @EndDate
	BEGIN
		SELECT GETDATE() DT, '<font color="red"><b>'+CONVERT(VARCHAR,@EndDate,101)+' is closing date, Please search before or after this date.</b></font>'Particulars, '0'DR, '0'CR 			
    	RETURN;
	END	
	IF CAST(@DATE2 AS DATE) NOT BETWEEN @StartDate AND @EndDate
	BEGIN
		SELECT GETDATE() DT, '<font color="red"><b>'+CONVERT(VARCHAR,@EndDate,101)+' is closing date, Please search before or after this date.</b></font>'Particulars, '0'DR, '0'CR 			
    	RETURN;
	END	

	SET @GRACEDAYS=7
	SET @GRACESTARTDATE=DATEADD(D,-@GRACEDAYS,CAST(@DATE1 AS DATE))
	SELECT @DATE2 = @DATE2 + ' 23:59:59'
	SET @DATE2 = @DATE2+ ' 23:59:59'
			
	SELECT @AGENT = mapCodeInt 
	FROM SendMnPro_Remit.dbo.agentMaster WITH (NOLOCK) 
	WHERE agentId = @AGENT
		
	SELECT @IsIntlAgent = 1 FROM SendMnPro_Remit.dbo.AgentMaster(NOLOCK) 
	where agentId = @AGENT AND agentCountry <> 'Nepal'
		
	IF OBJECT_ID(N'tempdb..#REPORT') IS NOT NULL
		DROP TABLE #REPORT
    
	SELECT  * INTO #REPORT FROM REMIT_TRN_MASTER WITH (NOLOCK)
	WHERE 
	 (S_AGENT = @AGENT AND TRN_DATE BETWEEN CAST(@GRACESTARTDATE AS DATETIME) AND CAST(@DATE2 AS DATETIME))
	 OR
	 (S_AGENT = @AGENT AND CANCEL_DATE BETWEEN CAST(@GRACESTARTDATE AS DATETIME) AND CAST(@DATE2 AS DATETIME))

IF @FLAG ='SOA'
BEGIN

	--IF @AGENTADDRESS <>'5'
	BEGIN
		SELECT @AGENT_AC = acct_num FROM agentTable ag  WITH (NOLOCK) , ac_master ac WITH (NOLOCK)
		WHERE ac.agent_id = ag.agent_id 
		AND  ag.map_code = @AGENT
		AND ac.acct_rpt_code = '3'	
		 
		SELECT @OPENINGBAL = SUM(OPENINGBAL) FROM (	
			SELECT 
				OPENINGBAL = (CASE WHEN S_CURR ='USD' THEN (USD_AMT) 
					ELSE ROUND((CAST(ROUND(S_AMT/ISNULL(EX_USD,1),2) AS MONEY)),2)
				END)
			FROM #REPORT RTM WITH ( NOLOCK)  
			WHERE S_AGENT = @AGENT 
			AND TRN_DATE < @DATE1  AND F_INIT IS NULL 
			--GROUP BY S_CURR
		)X

		SELECT 
			CONVERT(VARCHAR(20), X.DT, 101) DT,
			Particulars, 
			ISNULL(DR,0.00)AS DR ,
			ISNULL(CR,0.0)AS CR
		FROM 
		(    	  	 
		   SELECT CAST(@DATE1 AS DATE) DT,'Opening Balance' Particulars,0.1 TXN
			, ISNULL(@OPENINGBAL,0)  DR  
			, 0   CR  
             
		  UNION ALL

		SELECT  * FROM (
		  SELECT CONVERT ( VARCHAR,TRN_DATE, 101 ) DATE ,
		  '<a href="SOA_DrillDetail.aspx?flag=SEND_OTHER&AGENT='+ CONVERT(VARCHAR,@AGENT, 101 )+
	   '&DATE1='+ CONVERT (VARCHAR,TRN_DATE, 101) + '&DATE2='+ CONVERT (VARCHAR,TRN_DATE, 101 )+
	    '">Send Txn - '+ CAST(COUNT('x') AS VARCHAR) +'</a>' AS Particulars
		  ,1.0 TXN
		  , DR = SUM(CASE WHEN S_CURR ='USD' THEN (USD_AMT) 
					ELSE ROUND((CAST(ROUND(S_AMT/ISNULL(EX_USD,1),2) AS MONEY)),2)
					END
				)
		  , CR = 0   
		  FROM #REPORT RTM WITH ( NOLOCK) 
		  WHERE S_AGENT = @AGENT 
		  AND TRN_DATE BETWEEN @DATE1 AND @DATE2 
		  GROUP BY CONVERT(VARCHAR , TRN_DATE, 101),S_CURR
           
		UNION ALL

		  SELECT CONVERT ( VARCHAR,TRN_DATE, 101 ) DATE ,
		  'Send Commission - '+ CAST(COUNT('x') AS VARCHAR)   AS Particulars
		  ,1.1 TXN
		  ,DR = CASE WHEN @IsIntlAgent = 0 OR @AGENT = 9495 THEN 0 
				ELSE SUM(CASE WHEN S_CURR ='USD' THEN (SC_TOTAL) 
					ELSE ROUND((CAST(ROUND(SC_TOTAL/ISNULL(EX_USD,1),2) AS MONEY)),2)
					END
				) END
		  --, SUM(ROUND(CAST(ROUND(ISNULL(SC_S_AGENT,0)/ISNULL(EX_USD,1),2) AS MONEY),2))  CR 
		  ,CR = CASE WHEN @IsIntlAgent = 0 THEN SUM(CASE WHEN S_CURR ='USD' THEN (SC_TOTAL) 
					ELSE ROUND((CAST(ROUND(SC_TOTAL/ISNULL(EX_USD,1),2) AS MONEY)),2)
					END
				)
				ELSE 0 END
		  FROM #REPORT RTM WITH ( NOLOCK) 
		  WHERE S_AGENT=@AGENT 
		  AND TRN_DATE BETWEEN @DATE1 AND @DATE2
          GROUP BY CONVERT(VARCHAR , TRN_DATE, 101),S_CURR
		  
		--UNION ALL

		--  SELECT CONVERT ( VARCHAR,TRN_DATE, 101 ) DATE ,
		--  'Send FX - '+ CAST(COUNT('x') AS VARCHAR)   AS Particulars
		--  ,1.2 TXN,0 DR, SUM(ROUND(CAST(ROUND(ISNULL(AGENT_EX_GAIN,0)/ISNULL(EX_USD,1),2) AS MONEY),2)) CR 
		--  FROM #REPORT RTM WITH ( NOLOCK) 
		--  WHERE S_AGENT=@AGENT 
		--  AND TRN_DATE BETWEEN @DATE1 AND @DATE2
  --        GROUP BY CONVERT(VARCHAR , TRN_DATE, 101)              
            
		  UNION ALL

		  SELECT CONVERT ( VARCHAR,CANCEL_DATE, 101 ) DATE ,
		  '<a href="SOA_DrillDetail.aspx?flag=CANCEL_OTHER&AGENT='+ CONVERT(VARCHAR,@AGENT, 101 )+
	   '&DATE1='+ CONVERT (VARCHAR,CANCEL_DATE, 101) + '&DATE2='+ CONVERT (VARCHAR,CANCEL_DATE, 101 )+
	    '">Cancel Txn - '+ CAST(COUNT('x') AS VARCHAR) +'</a>' AS Particulars
		  ,2.0 TXN, 0  DR
		  --,SUM(ROUND(CAST(ROUND(S_AMT/ISNULL(EX_USD,1),2) AS MONEY),2)) CR 
		  ,CR = SUM(CASE WHEN S_CURR ='USD' THEN (USD_AMT) 
					ELSE ROUND((CAST(ROUND(S_AMT/ISNULL(EX_USD,1),2) AS MONEY)),2)
					END
				)
		  FROM #REPORT RTM WITH ( NOLOCK) 
		  WHERE S_AGENT=@AGENT 
		  AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
		  GROUP BY CONVERT ( VARCHAR,CANCEL_DATE, 101 ) ,S_CURR
   
 
		  UNION ALL

		  SELECT CONVERT ( VARCHAR,CANCEL_DATE, 101 ) DATE ,
		 'Cancel Commission - '+ CAST(COUNT('x') AS VARCHAR)  AS Particulars
		   ,2.1 TXN
		   --, SUM(ROUND(CAST(ROUND(ISNULL(SC_S_AGENT,0)/ISNULL(EX_USD,1),2) AS MONEY),2))  DR
		   ,DR = CASE WHEN @IsIntlAgent = 0 THEN SUM(CASE WHEN S_CURR ='USD' THEN (SC_TOTAL) 
					ELSE ROUND((CAST(ROUND(SC_TOTAL/ISNULL(EX_USD,1),2) AS MONEY)),2)
					END
				) ELSE 0 END
		   ,CR = CASE WHEN @IsIntlAgent = 0 THEN 0 ELSE 
					SUM(CASE WHEN S_CURR ='USD' THEN (SC_TOTAL) 
					ELSE ROUND((CAST(ROUND(SC_TOTAL/ISNULL(EX_USD,1),2) AS MONEY)),2)
					END
				)
				END
		  FROM #REPORT RTM WITH ( NOLOCK) 
		  WHERE S_AGENT=@AGENT 
		  AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2
		  GROUP BY CONVERT ( VARCHAR,CANCEL_DATE, 101 ),S_CURR

		 -- 		  UNION ALL

		 -- SELECT CONVERT ( VARCHAR,CANCEL_DATE, 101 ) DATE ,
		 --'Cancel FX - '+ CAST(COUNT('x') AS VARCHAR)  AS Particulars
		 --  ,2.2 TXN, SUM(ROUND(CAST(ROUND(ISNULL(AGENT_EX_GAIN,0)/ISNULL(EX_USD,1),2) AS MONEY),2)) DR, 0  CR
		 -- FROM #REPORT RTM WITH (NOLOCK) 
		 -- WHERE S_AGENT=@AGENT 
		 -- AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2
		 -- GROUP BY CONVERT ( VARCHAR,CANCEL_DATE, 101 )

		  UNION ALL
            
		  SELECT CONVERT(VARCHAR,T.tran_date, 101 ) DATE , TD.tran_particular Particulars , 0.3
		  ,CASE WHEN T . part_tran_type='DR' THEN ISNULL(T.USD_amt,0) ELSE 0 END Debit , 
		  CASE WHEN part_tran_type='CR' THEN ISNULL(USD_amt,0) ELSE 0 END Credit 
		  FROM tran_master t WITH ( NOLOCK )
		  , tran_masterDetail TD WITH (NOLOCK) 
		  WHERE T.acc_num = @AGENT_AC
		  AND T.ref_num=TD.ref_num 
		  AND T.tran_type=TD.tran_type 
		  AND T.tran_type IN ('R','C','J')
		  AND ISNULL(T.rpt_code,'X')<>'s'
		  AND T.tran_date BETWEEN @DATE1 AND @DATE2 


		  --UNION ALL
            
		  --SELECT CONVERT(VARCHAR,T.tran_date, 101 ) DATE , TD.tran_particular Particulars , 0.3
		  --,CASE WHEN T . part_tran_type='DR' THEN ISNULL(T.USD_amt,0) ELSE 0 END Debit , 
		  --CASE WHEN part_tran_type='CR' THEN ISNULL(USD_amt,0) ELSE 0 END Credit 
		  --FROM tran_master t WITH ( NOLOCK )
		  --, tran_masterDetail TD WITH (NOLOCK) 
		  --WHERE T.acc_num = @AGENT_AC
		  --AND T.ref_num=TD.ref_num 
		  --AND T.tran_type=TD.tran_type 
		  --AND T.tran_type ='R' 
		  --AND ISNULL(T.rpt_code,'X')='s'
		  --AND T.tran_date BETWEEN @DATE1 AND @DATE2 
            
		  )T  WHERE  DR <>0 OR CR <>0  ) X
	   ORDER BY DT, TXN
	   RETURN;
	   
	END 
	--ELSE 
	--BEGIN
	--	SELECT @date1 AS DT,Particulars = 'No tranasction found',DR = 0,CR = 0
	--END
END

	IF @FLAG IN ('SEND_3RD')
	BEGIN
		SELECT 
			X.[Date],
			X.ICN,
			X.[Branch Name],
			X.[Sender Name],
			X.[Receiver Name],
			X.[Principal],
			X.[Commission],
			[Settlement] = X.[Principal]+X.[Commission]+X.[FX Gain],
			X.[USER]		
		FROM 
		(
			SELECT 
				 [Date] = CONVERT(VARCHAR,TRN_DATE, 101) 
				,ICN = dbo.decryptDb(TRN_REF_NO) 
				,[Branch Name] = AM.agentName 
				,[Sender Name] = UPPER(SENDER_NAME)
				,[Receiver Name] = UPPER(RECEIVER_NAME)  
				,[Principal] = ISNULL(ROUND(P_AMT,2,1) ,0)									
				,[Commission] = ISNULL(ROUND(agent_receiverSCommission,2,1),0)			
				,[FX Gain] = 0		    
				,[USER] = APPROVE_BY 
			FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
			INNER JOIN SendMnPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.S_BRANCH=AM.mapCodeInt 
			WHERE S_AGENT = @AGENT
			AND TRN_DATE BETWEEN @DATE1 AND @DATE2 
	  )X
	END
	IF @FLAG IN ('CANCEL_3RD')
	BEGIN
		SELECT 
			X.[Date],
			X.ICN,
			X.[Branch Name],
			X.[Sender Name],
			X.[Receiver Name],
			X.[Principal],
			X.[Commission],
			[Settlement] = X.[Principal]+X.[Commission],
			X.[USER]		
		FROM 
		(
			SELECT 
				 [Date] = CONVERT(VARCHAR,CANCEL_DATE, 101) 
				,ICN = dbo.decryptDb(TRN_REF_NO) 
				,[Branch Name] = AM.agentName 
				,[Sender Name] = UPPER(SENDER_NAME)
				,[Receiver Name] = UPPER(RECEIVER_NAME)  
				,[Principal] = ISNULL(ROUND(CAST(ROUND(P_AMT_ACT/SETTLEMENT_RATE,2) AS MONEY),2),0)								
				,[Commission] = ISNULL(ROUND(CAST(ROUND(agent_receiverSCommission/SCURRCOSTRATE,2) AS MONEY),2),0)
				,[USER] = APPROVE_BY 
			FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
			INNER JOIN SendMnPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.S_BRANCH=AM.mapCodeInt 
			WHERE S_AGENT = @AGENT
			AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
		
	  )X
	END

	
	IF @FLAG IN ('SEND_OTHER')
	BEGIN
		SELECT 
			X.[Date],
			X.ICN,
			X.[Branch Name],
			X.[Sender Name],
			X.[Receiver Name],
			X.[Principal USD],
			X.[Commission USD],
			[Settlement USD] = X.[Principal USD]+X.[Commission USD]+X.[FX Gain USD],
			[USD vs NPR Rate] = Settlement_rate,
			X.[USER]		
		FROM 
		(
			SELECT 
				 [Date] = CONVERT(VARCHAR, TRN_DATE, 101) 
				,ICN = dbo.decryptDb(TRN_REF_NO) 
				,[Branch Name] = AM.agentName 
				,[Sender Name] = UPPER(SENDER_NAME)
				,[Receiver Name] = UPPER(RECEIVER_NAME)  
				,[Principal USD] = ISNULL( CASE WHEN S_CURR  ='USD' THEN USD_AMT ELSE
										ROUND(CAST(ROUND(S_AMT/ISNULL(EX_USD,1),2) AS MONEY),2)
										END
									,0)									
				,[Commission USD] = ISNULL(CASE WHEN S_CURR  = 'USD' THEN SC_TOTAL
											WHEN @AGENT = 9495 THEN 0 
										 ELSE
										ROUND(CAST(ROUND(ISNULL(SC_TOTAL,0)/ISNULL(EX_USD,1),2) AS MONEY),2)
										END
									,0)
				,[FX Gain USD] = ISNULL( CASE WHEN S_CURR  = 'USD' THEN 0 ELSE
										ROUND(CAST(ROUND(ISNULL(AGENT_EX_GAIN,0)/ISNULL(EX_USD,1),2) AS MONEY),2)
										END
									,0)		    
				,[Ex Rate] = ISNULL(CASE WHEN S_CURR  = 'USD' THEN 1 ELSE EX_USD END,0)
				,[USER] = APPROVE_BY 
				,RTM.Settlement_rate
			FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
			INNER JOIN SendMnPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.S_BRANCH=AM.mapCodeInt 
			WHERE S_AGENT = @AGENT 
			AND TRN_DATE BETWEEN @DATE1 AND @DATE2 
	  )X
	END
	IF @FLAG IN ('CANCEL_OTHER')
	BEGIN
		SELECT 
			X.[Date],
			X.ICN,
			X.[Branch Name],
			X.[Sender Name],
			X.[Receiver Name],
			X.[Principal USD],
			X.[Commission USD],
			[Settlement USD] = X.[Principal USD]+X.[Commission USD],
			X.[USER]		
		FROM 
		(
			SELECT 
				 [Date] = CONVERT(VARCHAR,CANCEL_DATE, 101) 
				,ICN = dbo.decryptDb(TRN_REF_NO) 
				,[Branch Name] = AM.agentName 
				,[Sender Name] = UPPER(SENDER_NAME)
				,[Receiver Name] = UPPER(RECEIVER_NAME)  
				,[Principal USD] = ISNULL(ROUND(CAST(ROUND(S_AMT/ISNULL(EX_USD,1),2) AS MONEY),2),0)											
				,[Commission USD] = ISNULL(ROUND(CAST(ROUND(ISNULL(SC_S_AGENT,0)/ISNULL(EX_USD,1),2) AS MONEY),2),0)
				,[FX Gain USD] = ISNULL(ROUND(CAST(ROUND(ISNULL(AGENT_EX_GAIN,0)/ISNULL(EX_USD,1),2) AS MONEY),2),0)
				,[USER] = APPROVE_BY 
			FROM REMIT_TRN_MASTER RTM WITH (NOLOCK) 
			INNER JOIN SendMnPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.S_BRANCH=AM.mapCodeInt 
			WHERE S_AGENT = @AGENT
			AND CANCEL_DATE BETWEEN @DATE1 AND @DATE2 
	  )X
	END


GO
