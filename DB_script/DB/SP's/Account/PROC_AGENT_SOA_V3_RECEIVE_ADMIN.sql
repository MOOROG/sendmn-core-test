
ALTER PROC [dbo].[PROC_AGENT_SOA_V3_RECEIVE_ADMIN]
     @FLAG  VARCHAR (20)
    ,@FLAG2  VARCHAR (20) = NULL
    ,@AGENT VARCHAR (20) 
    ,@DATE1 VARCHAR (20) 
    ,@DATE2 VARCHAR (20) 
    ,@BRANCH VARCHAR(10) = NULL
	,@user VARCHAR(50)	= NULL
	,@ACCTYPE CHAR(5) = NULL
	,@TRANDATE VARCHAR(20)= NULL 
AS
	SET NOCOUNT ON;
	DECLARE @isCentSett VARCHAR(20),@date2old VARCHAR (20)
 
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

	SET @ACCTYPE = CASE WHEN @ACCTYPE IS NULL THEN NULL 
					WHEN @ACCTYPE = 'P' THEN 'TP'
					WHEN @ACCTYPE = 'COMM' THEN 'TC'
					END

	--get settling agent for accounts and get all the related accounts with settling agent/branch
	CREATE TABLE #TEMP_ACCOUNTS(ACCOUNT_NO VARCHAR(30), ACCOUNT_TYPE VARCHAR(30))
	DECLARE @IS_SETTLING CHAR(1), @isExternalAgent CHAR(1)

	--GET THE PRINCIPLE AND COMMISSION ACCOUNT
	INSERT INTO #TEMP_ACCOUNTS 
	SELECT ACCT_NUM, ACCT_TYPE = CASE WHEN acct_rpt_code = 'TP' THEN 'PRINCIPLE_ACC' 
										WHEN acct_rpt_code = 'TC' THEN 'COMM_ACC' 
								 END
	FROM  dbo.ac_master
	WHERE agent_id = @AGENT 
	AND gl_code in ('77', '78') 
	AND acct_rpt_code = ISNULL(@ACCTYPE, acct_rpt_code)
	
IF @FLAG ='SOA'
BEGIN
    DECLARE @OPENINGBAL MONEY,@tran_date VARCHAR(30)

	IF CAST(@date1 AS DATE) >= '2015-07-17'
	BEGIN 
		SELECT @OPENINGBAL = ISNULL(SUM (CASE WHEN part_tran_type='dr' 
											THEN tran_amt*-1 ELSE tran_amt END) ,0)
		FROM tran_master TM WITH(NOLOCK) 
		INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = TM.acc_num
		WHERE 1 = 1 
		AND TM.tran_date < @DATE1
	END	
	
	DECLARE 
		@urlSendIntl AS VARCHAR(500),
		@urlCancel AS VARCHAR(500)
	SET @urlSendIntl ='"'+FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&mode=download&rtpType=SEND-I&fromDate='+@DATE1+'&toDate='+@DATE2+'&branch='+ISNULL(@BRANCH, '')+'&agent='+@AGENT+'"'
	SET @urlCancel ='"'+FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&mode=download&rtpType=CANCEL-I&fromDate='+@DATE1+'&toDate='+@DATE2+'&branch='+ISNULL(@BRANCH, '')+'&agent='+@AGENT+'"'
	
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

			SELECT CONVERT( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=RECEIVED_INTL&reportName=statementofaccountrec&FLAG2=PRINCIPLE_ACC&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+'&BRANCH='+CONVERT ( VARCHAR,ISNULL(@BRANCH, ''), 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Received - Int`l Remitt - '+
					 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+ FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&REQUESTBY=RECEIVEADMIN&FLAG2=PRINCIPLE_ACC&mode=download&rtpType=RECEIVED-I&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&fromDate='+@DATE1+'&toDate='+@date2old+'&branch='+ISNULL(@BRANCH, '')+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   ,1 TXN, 0 DR,SUM(tran_amt) CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.field2 = 'Remittance Voucher'
			AND TMP.ACCOUNT_TYPE = 'PRINCIPLE_ACC'
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101) 

			UNION ALL 

			SELECT CONVERT ( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=CANCEL_INTL&reportName=statementofaccountrec&FLAG2=PRINCIPLE_ACC&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+'&BRANCH='+CONVERT ( VARCHAR,ISNULL(@BRANCH, ''), 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Cancelled Remitt - '+
					 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+  FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&REQUESTBY=RECEIVEADMIN&FLAG2=PRINCIPLE_ACC&mode=download&rtpType=CANCEL-I&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&fromDate='+@DATE1+'&toDate='+@date2old+'&branch='+ISNULL(@BRANCH, '')+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   ,2 TXN,SUM(tran_amt) DR,0 CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.field2 = 'Remittance Voucher'
			AND RTM.acct_type_code = 'Reverse'
			AND TMP.ACCOUNT_TYPE = 'PRINCIPLE_ACC'
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101) 

			UNION ALL 

			SELECT CONVERT( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=PAY_INTL_COMM&reportName=statementofaccountrec&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,@DATE1, 101 )+'&BRANCH='+CONVERT ( VARCHAR,ISNULL(@BRANCH, ''), 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,@DATE2, 101 )+'">Pay - Int`l Commission - '+
					 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+ FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20161700&REQUESTBY=RECEIVEADMIN&mode=download&rtpType=PAY_COMM&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&fromDate='+@DATE1+'&toDate='+@date2old+'&branch='+ISNULL(@BRANCH, '')+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   ,2 TXN, 0 DR,SUM(tran_amt) CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.field2 = 'Remittance Voucher'
			AND TMP.ACCOUNT_TYPE = 'COMM_ACC'
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101) 
		)T 
		ORDER BY CAST(T.DT AS DATE), TXN
END

IF @FLAG = 'RECEIVED_INTL'
BEGIN
	SELECT field1 
	INTO #TEMP
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.field2 = 'Remittance Voucher'
	AND TMP.ACCOUNT_TYPE = 'PRINCIPLE_ACC' 
	
	UPDATE #TEMP SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)
	
	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(pamt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP T ON T.field1 = RTM.CONTROLNO
	WHERE pAgent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END
IF @FLAG = 'PAY_INTL_COMM'
BEGIN
	SELECT field1 
	INTO #TEMP2
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.field2 IS NOT NULL
	AND TMP.ACCOUNT_TYPE = 'COMM_ACC'

	UPDATE #TEMP2 SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Comm Amount] = ISNULL(ROUND(pagentComm,2),0)						
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP2 T ON T.field1 = RTM.CONTROLNO
	WHERE pagent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END
IF @FLAG = 'CANCEL_INTL'
BEGIN
	SELECT field1 
	INTO #TEMP1
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.acct_type_code = 'Reverse'
	AND TMP.ACCOUNT_TYPE = 'PRINCIPLE_ACC' 

	UPDATE #TEMP1 SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(pamt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP1 T ON T.field1 = RTM.CONTROLNO
	WHERE pagent = @AGENT
	AND RTM.CANCELAPPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END

IF @FLAG = 'RECEIVED-I'
BEGIN
	SELECT field1 
	INTO #TEMP4
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.field2 = 'Remittance Voucher'
	AND TMP.ACCOUNT_TYPE = 'PRINCIPLE_ACC' 
	UPDATE #TEMP4 SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)
	SELECT 
		 [Date1] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(pamt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP4 T ON T.field1 = RTM.CONTROLNO
	WHERE pAgent = @AGENT
	AND RTM.approvedDate BETWEEN @TRANDATE  AND @TRANDATE +' 23:59:59' 


	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Received - Detail' title
END
IF @FLAG = 'PAY_COMM'
BEGIN
	SELECT field1 
	INTO #TEMP5
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.field2 IS NOT NULL
	AND TMP.ACCOUNT_TYPE = 'COMM_ACC'

	UPDATE #TEMP5 SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Comm Amount] = ISNULL(ROUND(pagentComm,2),0)						
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP5 T ON T.field1 = RTM.CONTROLNO
	WHERE pagent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @TRANDATE AND @TRANDATE +' 23:59:59' 

	
	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Pay - Detail' title
END
IF @FLAG = 'CANCEL-I'
BEGIN
	SELECT field1 
	INTO #TEMP6
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.acct_type_code = 'Reverse'
	AND TMP.ACCOUNT_TYPE = 'PRINCIPLE_ACC' 

	UPDATE #TEMP6 SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(pamt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP6 T ON T.field1 = RTM.CONTROLNO
	WHERE pagent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @TRANDATE AND @TRANDATE +' 23:59:59' 

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Cancel - Detail' title
END
