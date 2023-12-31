ALTER  PROC [dbo].[PROC_AGENT_SOA_V3]
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
	FROM SendMnPro_Remit.dbo.AGENTMASTER (NOLOCK) 
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
	INNER JOIN SendMnPro_Remit.dbo.STATICDATAVALUE SD(NOLOCK) ON SD.VALUEID = AC.AGENT_ID 
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

	UPDATE #TEMP SET field1 = SendMnPro_Remit.dbo.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = SendMnPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM SendMnPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN SendMnPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.SBRANCH=AM.mapCodeInt 
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

	UPDATE #TEMP2 SET field1 = SendMnPro_Remit.dbo.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = SendMnPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Comm Amount] = ISNULL(ROUND(pagentComm,2),0)						
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM SendMnPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN SendMnPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.SBRANCH=AM.mapCodeInt 
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

	UPDATE #TEMP1 SET field1 = SendMnPro_Remit.dbo.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = SendMnPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM SendMnPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN SendMnPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.SBRANCH=AM.mapCodeInt 
	INNER JOIN #TEMP1 T ON T.field1 = RTM.CONTROLNO
	WHERE sagent = @AGENT
	AND RTM.cancelapproveddate BETWEEN @DATE1 AND @DATE2 
END
IF @FLAG ='SOA'
BEGIN
    DECLARE @OPENINGBAL MONEY,@tran_date VARCHAR(30),@accNum VARCHAR(20)

	SELECT @accNum = acct_num from Ac_Master(NOLOCK) ac
	INNER JOIN SendMnPro_Remit.dbo.applicationUsers(NOLOCK) ap ON ac.agent_Id = ap.userId
	 WHERE userName = @user and agentId = @BRANCH


	IF CAST(@date1 AS DATE) >= '2015-07-17'
	BEGIN 
		SELECT @OPENINGBAL = ISNULL(SUM (CASE WHEN part_tran_type='dr' THEN tran_amt*-1 ELSE tran_amt END) ,0)
		FROM tran_master TM WITH(NOLOCK) 
		WHERE TM.tran_date < @DATE1
		AND  acc_num = @accNum
		--select @accNum
	END	

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
				'<a href="/AccountReport/AccountStatement/userreportResultSingle.aspx?company_id=1&vouchertype=s&type=trannumber&trn_date='
	 +CONVERT ( VARCHAR,tran_date, 101 )+'&tran_num='+ ref_num +'">'+Field2 + ', RefNo:' + field1 +'|Ac:'+ acc_num + '</a>' Particulars ,1 TXN
			   , case when part_tran_type = 'dr' then tran_amt else 0 end  DR
			   ,case when part_tran_type = 'cr' then tran_amt else 0 end  CR  
			FROM tran_master RTM WITH ( NOLOCK) 
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND RTM.acc_num = @accNum
			--AND RTM.field2 = 'Remittance Voucher'
		)T 
		ORDER BY CAST(T.DT AS DATE), TXN
		SELECT * FROM #TEMP_SOA
END




GO
