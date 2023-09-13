
ALTER PROC [dbo].[PROC_AGENT_SOA_V3]
     @FLAG  VARCHAR (20)
    ,@FLAG2  VARCHAR (20) = NULL
    ,@AGENT VARCHAR (20) 
    ,@DATE1 VARCHAR (10) 
    ,@DATE2 VARCHAR (20) 
    ,@BRANCH VARCHAR(10) = NULL
	,@user VARCHAR(50)	= NULL
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

	--get settling agent for accounts and get all the related accounts with settling agent/branch
	CREATE TABLE #TEMP_ACCOUNTS(ACCOUNT_NO VARCHAR(30), ACCOUNT_TYPE VARCHAR(10))
	DECLARE @IS_SETTLING CHAR(1), @AGENT_ID BIGINT, @isExternalAgent CHAR(1)
	
	SET @AGENT_ID = @AGENT

	SELECT @IS_SETTLING = ISNULL(ISSETTLINGAGENT, 'N'), @isExternalAgent = CASE WHEN ISNULL(ISINTL, 0) = 1 THEN 'Y' ELSE 'N' END
	FROM FASTMONEYPRO_REMIT.DBO.AGENTMASTER (NOLOCK) 
	WHERE AGENTID = @BRANCH
	
	IF @IS_SETTLING = 'Y'
	BEGIN
		SET @AGENT_ID = @BRANCH
	END

	--GET THE PRINCIPLE ACCOUNT
	INSERT INTO #TEMP_ACCOUNTS 
	SELECT ACCT_NUM, 'SEND_CASH'
	FROM AC_MASTER (NOLOCK) WHERE AGENT_ID = @AGENT_ID
	AND ACCT_RPT_CODE = CASE WHEN @isExternalAgent = 'Y' THEN 'APR' ELSE 'BR' END

	--GET COMMISSION ACCOUNT ONLY IF AGENT IS EXTERNAL AGENT
	IF @isExternalAgent = 'Y'
		INSERT INTO #TEMP_ACCOUNTS 
		SELECT ACCT_NUM, 'COMM_ACC'
		FROM AC_MASTER (NOLOCK) WHERE AGENT_ID = @AGENT_ID
		AND ACCT_RPT_CODE = 'ACP'

	--GET THE LIST OF JAPAN BANKS
	INSERT INTO #TEMP_ACCOUNTS 
	SELECT ACCT_NUM, 'SEND_BANK'
	FROM AC_MASTER AC(NOLOCK)
	INNER JOIN FASTMONEYPRO_REMIT.DBO.STATICDATAVALUE SD(NOLOCK) ON SD.VALUEID = AC.AGENT_ID 
	WHERE SD.TYPEID = 7010
	AND AC.ACCT_RPT_CODE = 'TB'
	
IF @FLAG = 'SEND_INTL'
BEGIN
	SELECT field1 
	INTO #TEMP
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.branch_id = @BRANCH
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.field2 IS NOT NULL
	AND TMP.ACCOUNT_TYPE = @FLAG2

	UPDATE #TEMP SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.SBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP T ON T.field1 = RTM.CONTROLNO
	WHERE sagent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END
IF @FLAG = 'SEND_INTL_COMM'
BEGIN
	SELECT field1 
	INTO #TEMP2
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.branch_id = @BRANCH
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
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.SBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP2 T ON T.field1 = RTM.CONTROLNO
	WHERE sagent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END
IF @FLAG = 'CANCEL_INTL'
BEGIN
	
	SELECT field1 
	INTO #TEMP1
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.branch_id = @BRANCH
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.acct_type_code = 'Reverse'
	AND TMP.ACCOUNT_TYPE = @FLAG2

	UPDATE #TEMP1 SET field1 = FastMoneyPro_remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.SBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP1 T ON T.field1 = RTM.CONTROLNO
	WHERE sagent = @AGENT
	AND RTM.CANCELAPPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END
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
		AND TM.branch_id = @BRANCH
	END	
	
	DECLARE 
		@urlSendIntl AS VARCHAR(500),
		@urlCancel AS VARCHAR(500)
	SET @urlSendIntl ='"'+FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=40121100&mode=download&rtpType=SEND-I&fromDate='+@tran_date+'&toDate='+@tran_date+'&branch='+@BRANCH+'&agent='+@AGENT+'"'
	SET @urlCancel ='"'+FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=40121100&mode=download&rtpType=CANCEL-I&fromDate='+@tran_date+'&toDate='+@tran_date+'&branch='+@BRANCH+'&agent='+@AGENT+'"'

	SELECT 
			DATE = CONVERT(VARCHAR,CAST(T.DT AS DATE) ,101)
			,Particulars
			,DR
			,CR
	INTO  #TEMP_SOA
	FROM 
	(    
		SELECT CONVERT (VARCHAR,CAST(@DATE1 AS DATETIME), 101 ) DT,'Opening Balance' Particulars,0 TXN,
				ISNULL(@OPENINGBAL,0.00) DR ,'0' CR 
	
			UNION ALL

			SELECT CONVERT( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=SEND_INTL&FLAG2=SEND_CASH&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,tran_date, 101 )+'&BRANCH='+CONVERT ( VARCHAR,@BRANCH, 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,tran_date, 101 )+'">Send - Int`l Remitt - '+
					 CAST(COUNT('x') AS VARCHAR)+' (Cash)</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+ FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=40121100&FLAG2=SEND_CASH&mode=download&rtpType=SEND-I&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&branch='+@BRANCH+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   ,1 TXN, SUM(tran_amt) DR,0 CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.branch_id = @BRANCH
			AND RTM.field2 = 'Remittance Voucher'
			AND RTM.field2 IS NOT NULL
			AND ISNULL(RTM.ACCT_TYPE_CODE, '') <> 'Reverse'
			AND TMP.ACCOUNT_TYPE IN ('SEND_CASH')
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101) 

			UNION ALL
			
			SELECT CONVERT( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=SEND_INTL&FLAG2=SEND_BANK&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,tran_date, 101 )+'&BRANCH='+CONVERT ( VARCHAR,@BRANCH, 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,tran_date, 101 )+'">Send - Int`l Remitt - '+
					 CAST(COUNT('x') AS VARCHAR)+' (Bank)</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+ FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=40121100&FLAG2=SEND_BANK&mode=download&rtpType=SEND-I&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&branch='+@BRANCH+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   ,1 TXN, SUM(tran_amt) DR,SUM(tran_amt) CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.branch_id = @BRANCH
			AND RTM.field2 = 'Remittance Voucher'
			AND RTM.field2 IS NOT NULL
			AND ISNULL(RTM.ACCT_TYPE_CODE, '') <> 'Reverse'
			AND TMP.ACCOUNT_TYPE IN ('SEND_BANK')
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101)

			UNION ALL 

			SELECT CONVERT ( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=CANCEL_INTL&FLAG2=SEND_CASH&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,tran_date, 101 )+'&BRANCH='+CONVERT ( VARCHAR,@BRANCH, 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,tran_date, 101 )+'">Cancelled Remitt - '+
					 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+  FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=40121100&FLAG2=SEND_CASH&mode=download&rtpType=CANCEL-I&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&branch='+@BRANCH+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   ,2 TXN,0 DR,SUM(tran_amt) CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.branch_id = @BRANCH
			AND RTM.field2 = 'Remittance Voucher'
			AND RTM.acct_type_code = 'Reverse'
			AND TMP.ACCOUNT_TYPE IN ('SEND_CASH')
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101) 

			UNION ALL 

			SELECT CONVERT ( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=CANCEL_INTL&FLAG2=SEND_BANK&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,tran_date, 101 )+'&BRANCH='+CONVERT ( VARCHAR,@BRANCH, 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,tran_date, 101 )+'">Cancelled Remitt - '+
					 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+  FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=40121100&FLAG2=SEND_BANK&mode=download&rtpType=CANCEL-I&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&branch='+@BRANCH+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   ,2 TXN,SUM(tran_amt) DR,SUM(tran_amt) CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.branch_id = @BRANCH
			AND RTM.field2 = 'Remittance Voucher'
			AND RTM.acct_type_code = 'Reverse'
			AND TMP.ACCOUNT_TYPE IN ('SEND_BANK')
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101) 
		)T 
		ORDER BY CAST(T.DT AS DATE), TXN

		IF @isExternalAgent = 'Y'
		BEGIN
			INSERT INTO #TEMP_SOA
			SELECT CONVERT( VARCHAR,tran_date, 101 ) DATE ,
			   '<a href="SOA_DrillDetail.aspx?FLAG=SEND_INTL_COMM&AGENT='+
				  CONVERT ( VARCHAR,@AGENT, 101 )+'&DATE1='+CONVERT ( VARCHAR,tran_date, 101 )+'&BRANCH='+CONVERT ( VARCHAR,@BRANCH, 101 )+
				  '&DATE2='+CONVERT ( VARCHAR,tran_date, 101 )+'">Send - Int`l Commission - '+
					 CAST(COUNT('x') AS VARCHAR)+'</a> &nbsp;<span class="link" onclick=DownloadExcel('+
					'"'+ FastMoneyPro_remit.dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=40121100&mode=download&rtpType=SEND_COMM&tranDate='+CONVERT(VARCHAR, tran_date, 101)+'&branch='+@BRANCH+'&agent='+@AGENT+'"'
					 +');>(Export to Excel)</span>' Particulars 
			   , 0 DR,SUM(tran_amt) CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.branch_id = @BRANCH
			AND RTM.field2 = 'Remittance Voucher'
			AND RTM.field2 IS NOT NULL
			AND TMP.ACCOUNT_TYPE IN ('COMM_ACC')
			GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101) 
		END

		SELECT * FROM #TEMP_SOA
END
