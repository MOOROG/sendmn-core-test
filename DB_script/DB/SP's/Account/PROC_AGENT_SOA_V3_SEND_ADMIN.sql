SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[PROC_AGENT_SOA_V3_SEND_ADMIN]
     @FLAG  VARCHAR (20)
    ,@FLAG2  VARCHAR (20) = NULL
    ,@AGENT VARCHAR (20) 
    ,@DATE1 VARCHAR (10) 
    ,@DATE2 VARCHAR (20) 
    ,@BRANCH VARCHAR(10) = NULL
	,@user VARCHAR(50)	= NULL
	,@ACCTYPE CHAR(5) = NULL
	,@TRANDATE VARCHAR(10) = NULL
	,@userId		VARCHAR(10) = NULL
	,@country		VARCHAR(20) = NULL
AS
	SET NOCOUNT ON;
	DECLARE @isCentSett VARCHAR(20),@date2old VARCHAR (20),@walletAgentId  VARCHAR(20)
	select @walletAgentId = agentId from FastMoneyPro_Remit.dbo.vw_getAgentId WHERE SearchText= 'PayTxnFromMobile'
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
	CREATE TABLE #TEMP_ACCOUNTS(ACCOUNT_NO VARCHAR(30), ACCOUNT_TYPE VARCHAR(30))
	DECLARE @IS_SETTLING CHAR(1), @AGENT_ID BIGINT, @isExternalAgent CHAR(1)

IF @AGENT = @walletAgentId
BEGIN 
			IF @Flag = 'SOA' 
			BEGIN 
				INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
				SELECT acct_num FROM
				FastMoneyPro_Remit.dbo.RemitTran(Nolock) rt 
				INNER JOIN FastMoneyPro_Remit.dbo.tranSenders(nolock) ts ON rt.id = ts.tranId
				INNER JOIN ac_Master(nolock) ac ON  ts.customerId = ac.agent_Id
				WHERE sAgent  = @AGENT and rt.createdDate BETWEEN @DATE1 AND @DATE2 

				INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
				SELECT '161000439'
			END
			ELSE 
			BEGIN 
				INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
				SELECT acct_num FROM
				FastMoneyPro_Remit.dbo.RemitTran(Nolock) rt 
				INNER JOIN FastMoneyPro_Remit.dbo.tranReceivers(nolock) tr ON rt.id = tr.tranId
				INNER JOIN ac_Master(nolock) ac ON  tr.customerId = ac.agent_Id
				WHERE pAgent  = @AGENT and rt.paidDate BETWEEN @DATE1 AND @DATE2 

				INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
				SELECT '161000439'
			END
	 END 
ELSE
BEGIN
		--Wallet Online Branch End
		IF @userId = '' OR @userId IS NULL 
		BEGIN
		 INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
		 SELECT acct_num from ac_master(NOLOCK) am
		 INNER JOIN FastMoneyPro_Remit.dbo.applicationUsers(NOLOCK) au ON am.agent_id = au.userId
		 WHERE agentId = @AGENT 

		IF @FLAG IN ('SOA','SOA-Receive')
		BEGIN
			INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
			SELECT acct_num from ac_master(NOLOCK) am
			WHERE agent_id = @AGENT  
		END
		 --ahile dubai aune banako xa comm and principle
		 --and acct_rpt_code = 'VAC'  

		END 
		ELSE
		BEGIN
			INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
		 SELECT acct_num from ac_master(NOLOCK) am
		 WHERE agent_id = @userId  --ahile dubai aune banako xa comm and principle
		 --and acct_rpt_code = 'VAC'  
		END 

		IF @ACCTYPE = 'COMM' 
		BEGIN
			DELETE FROM #TEMP_ACCOUNTS

			IF  @userId IS  NULL  OR @userId = ''
			BEGIN
				INSERT INTO #TEMP_ACCOUNTS(ACCOUNT_NO)
				 SELECT acct_num from ac_master(NOLOCK) am
				 WHERE agent_id = @AGENT and acct_rpt_code = 'CAC' --commission acc indicator (VAC)
			END 
		END
	END
IF @FLAG IN ('SOA','SOA-Receive')
BEGIN
    DECLARE @OPENINGBAL MONEY,@tran_date VARCHAR(30)
	
	IF CAST(@date1 AS DATE) >= '2015-07-17'
	BEGIN 
		SELECT @OPENINGBAL = ISNULL(SUM (CASE WHEN part_tran_type='dr' 
											THEN tran_amt*-1 ELSE tran_amt END) ,0)
		FROM tran_master TM WITH(NOLOCK) 
		INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = TM.acc_num
		WHERE  TM.tran_date < @DATE1
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

			SELECT CONVERT ( VARCHAR,tran_date, 101 ) DATE 
				,	 '<a href="/AccountReport/AccountStatement/userreportResultSingle.aspx?company_id=1&vouchertype=s&type=trannumber&trn_date='
	 +CONVERT ( VARCHAR,tran_date, 101 )+'&tran_num='+ ref_num +'">'+Field2 + ', RefNo:' + field1 +'|Ac:'+ acc_num + '</a>' Particulars
				,2 TXN
				, case when part_tran_type = 'dr' then tran_amt else 0 end  DR
				,case when part_tran_type = 'cr' then tran_amt else 0 end  CR  
			FROM tran_master RTM WITH ( NOLOCK)
			INNER JOIN FastMoneyPro_Remit.dbo.RemitTran(Nolock) main ON dbo.encryptdb(RTM.field1)= main.controlNo
			INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
			WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
			AND scountry = case when @Flag = 'SOA' THEN @country ELSE scountry END 
			AND pCountry =  case when @Flag = 'SOA' THEN pcountry ELSE @country END 
			--AND RTM.field2 = 'Remittance Voucher'
		)T 
		ORDER BY CAST(T.DT AS DATE), TXN

	SELECT * FROM #TEMP_SOA
	
END


IF @FLAG = 'SEND_INTL'
BEGIN
	SELECT field1 
	INTO #TEMP
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.branch_id = ISNULL(@BRANCH, @AGENT_ID)
	AND TMP.ACCOUNT_TYPE = @FLAG2
	GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101),RTM.field1

	UPDATE #TEMP SET field1 = FastMoneyPro_Remit.DBO.FNAENCRYPTSTRING(field1)
	
	SELECT
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
	FROM FastMoneyPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.sBranch = AM.agentId 
	INNER JOIN #TEMP T ON T.field1 = RTM.CONTROLNO
	WHERE RTM.sAgent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END

IF @FLAG = 'CANCEL_INTL'
BEGIN
	
	SELECT field1 
	INTO #TEMP1
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.branch_id = ISNULL(@BRANCH, @AGENT_ID)
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.acct_type_code = 'Reverse'
	AND TMP.ACCOUNT_TYPE IN ('SEND_CASH', 'SEND_BANK')

	UPDATE #TEMP1 SET field1 = FastMoneyPro_Remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBranch = AM.agentId 
	INNER JOIN #TEMP1 T ON T.field1 = RTM.CONTROLNO
	WHERE RTM.sAgent = @AGENT
	AND RTM.CANCELAPPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END
IF @FLAG = 'SEND_INTL_COMM'
BEGIN
	SELECT field1 
	INTO #TEMP2
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.branch_id = ISNULL(@BRANCH, @AGENT_ID)
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.field2 IS NOT NULL
	AND TMP.ACCOUNT_TYPE = 'COMM_ACC'
	
	UPDATE #TEMP2 SET field1 = FastMoneyPro_Remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
			[Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		--,[Comm Amount] = ISNULL(ROUND(pagentComm,2),0)						
		,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBranch = AM.agentId
	INNER JOIN #TEMP2 T ON T.field1 = RTM.CONTROLNO
	WHERE RTM.sAgent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @DATE1 AND @DATE2 
END

IF @FLAG = 'SEND-I'
BEGIN
	SELECT field1 
	INTO #TEMP3
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.branch_id = ISNULL(@BRANCH, @AGENT_ID)
	AND TMP.ACCOUNT_TYPE = @FLAG2
	GROUP BY CONVERT(VARCHAR , RTM.tran_date, 101),RTM.field1

	UPDATE #TEMP3 SET field1 = FastMoneyPro_Remit.DBO.FNAENCRYPTSTRING(field1)
	
	SELECT
		 [Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
	FROM FastMoneyPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.sBranch = AM.agentId 
	INNER JOIN #TEMP3 T ON T.field1 = RTM.CONTROLNO
	WHERE RTM.sAgent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @TRANDATE AND @TRANDATE + ' 23:59:59' 

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_Remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Send Int - Detail' title  
END

IF @FLAG = 'CANCEL-I'
BEGIN
	
	SELECT field1 
	INTO #TEMP4
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.branch_id = ISNULL(@BRANCH, @AGENT_ID)
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.acct_type_code = 'Reverse'
	AND TMP.ACCOUNT_TYPE IN ('SEND_CASH', 'SEND_BANK')

	UPDATE #TEMP4 SET field1 = FastMoneyPro_Remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
		 [Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		,[Principal] = ISNULL(ROUND(camt,2),0)								
		--,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBranch = AM.agentId 
	INNER JOIN #TEMP4 T ON T.field1 = RTM.CONTROLNO
	WHERE RTM.sAgent = @AGENT
	AND RTM.CANCELAPPROVEDDATE BETWEEN @TRANDATE AND @TRANDATE + ' 23:59:59' 
	
	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_Remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Cancel Request - Detail' title  
END
IF @FLAG = 'SEND_COMM'
BEGIN
	SELECT field1 
	INTO #TEMP5
	FROM tran_master RTM WITH ( NOLOCK) 
	INNER JOIN #TEMP_ACCOUNTS TMP (NOLOCK) ON  TMP.ACCOUNT_NO = RTM.acc_num
	WHERE RTM.tran_date BETWEEN @DATE1 AND @DATE2 
	AND RTM.branch_id = ISNULL(@BRANCH, @AGENT_ID)
	AND RTM.field2 = 'Remittance Voucher'
	AND RTM.field2 IS NOT NULL
	AND TMP.ACCOUNT_TYPE = 'COMM_ACC'
	
	UPDATE #TEMP5 SET field1 = FastMoneyPro_Remit.DBO.FNAENCRYPTSTRING(field1)

	SELECT 
		 [Date] = CONVERT(VARCHAR,RTM.approveddate, 101) 
		,ICN = FastMoneyPro_Remit.dbo.decryptDb(controlno) 
		,[Branch Name] = AM.agentName 
		,[Sender Name] = UPPER(senderName)
		,[Receiver Name] = UPPER(receiverName)  
		,[USER] = RTM.approvedBy
		--,[Comm Amount] = ISNULL(ROUND(pagentComm,2),0)						
		,[Commission] = ISNULL(ROUND(sagentcomm,2),0)
	FROM FastMoneyPro_Remit.dbo.REMITTRAN RTM WITH (NOLOCK) 
	INNER JOIN FastMoneyPro_Remit.dbo.agentMaster AM WITH (NOLOCK) ON RTM.pBranch = AM.agentId
	INNER JOIN #TEMP5 T ON T.field1 = RTM.CONTROLNO
	WHERE RTM.sAgent = @AGENT
	AND RTM.APPROVEDDATE BETWEEN @TRANDATE AND @TRANDATE + ' 23:59:59'  

	SELECT '0' errorCode, 'Report has been prepared successfully.' msg, NULL id    
	SELECT 'AGENT' head, ( SELECT agentName FROM FastMoneyPro_Remit.dbo.agentMaster WHERE agentId=@AGENT) value UNION ALL  
	SELECT 'TXN DATE', @DATE1 
	SELECT 'Send Commision - Detail' title  
END
GO