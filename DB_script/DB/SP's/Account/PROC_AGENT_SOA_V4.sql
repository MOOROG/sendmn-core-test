
ALTER PROC [dbo].[PROC_AGENT_SOA_V4]  
     @FLAG  VARCHAR (20)  
    ,@AGENT VARCHAR (20)  
	,@FLAG2 VARCHAR(20) = NULL
    ,@DATE1 VARCHAR (10)   
    ,@BRANCH VARCHAR(10) = NULL  
    ,@TRN_TYPE VARCHAR(15) = NULL  
 ,@user VARCHAR(50) = NULL  
AS  
SET NOCOUNT ON;  
   
	IF(DATEDIFF(day,@DATE1,GETDATE())>120)  
	BEGIN  
		SELECT DATE = GETDATE(),  
				Particulars = '<font color="red"><b>Date Range is not valid, You can only view transaction upto 120 days.</b></font>',  
				DR = 0,  
				CR = 0      
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

IF @FLAG = 'SEND-I'
BEGIN
	SELECT field1 
	INTO #TEMP
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE1 + ' 23:59:59'
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
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE1 + ' 23:59:59'

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Send Int - Detail' title  
END

IF @FLAG = 'CANCEL-I'
BEGIN
	
	SELECT field1 
	INTO #TEMP1
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE1 + ' 23:59:59'
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
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE1 + ' 23:59:59'
	
	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Cancel Request - Detail' title  
END
IF @FLAG = 'SEND_COMM'
BEGIN
	SELECT field1 
	INTO #TEMP2
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE1 + ' 23:59:59'
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
	AND RTM.APPROVEDDATE BETWEEN @DATE1  AND @DATE1 + ' 23:59:59' 

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Cancel Request - Detail' title  
END

  

  
  
  
  