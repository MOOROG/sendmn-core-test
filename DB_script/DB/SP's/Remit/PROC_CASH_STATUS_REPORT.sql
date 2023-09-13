--EXEC  PROC_CASH_STATUS_REPORT @FLAG = 'cash-rpt',@user='admin',@DATE='2019-07-10',@AGENT_ID=394392
--EXEC  PROC_CASH_STATUS_REPORT @FLAG = 'drill-down1',@user='admin',@DATE='2019-01-03',@AGENT_ID='394390'
--EXEC  PROC_CASH_STATUS_REPORT @FLAG = 'cash-rpt',@user='admin',@DATE='2019-01-03',@AGENT_ID=null

ALTER PROC PROC_CASH_STATUS_REPORT
(
	@FLAG VARCHAR(20)
	,@DATE VARCHAR(25) = NULL
	,@USER VARCHAR(50) = NULL
	,@AGENT_ID INT = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @FLAG = 'cash-rpt'
	BEGIN
		CREATE TABLE #TEMP_RPT(BRANCH_NAME VARCHAR(100), BRANCH_ID INT, OPENING_BALANCE MONEY, IN_AMOUNT MONEY, OUT_AMOUNT MONEY,
							VAULT_IN MONEY, VAULT_OUT MONEY, CLOSING_BALANCE MONEY, ACC_NUM VARCHAR(30))

		INSERT INTO #TEMP_RPT (BRANCH_ID, BRANCH_NAME, ACC_NUM)
		SELECT AM.AGENTID, AM.AGENTNAME, AC.ACCT_NUM
		FROM AGENTMASTER AM(NOLOCK) 
		INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK) ON AM.AGENTID = AC.AGENT_ID
		WHERE AM.PARENTID = 393877 
		--AND ISNULL(ISINTL, 0) = 0
		AND AM.AGENTID <> 394395
		AND AC.ACCT_RPT_CODE = 'BVA'

		UNION ALL

		SELECT AM.AGENTID, AM.AGENTNAME, ACC.ACCT_NUM 
		FROM APPLICATIONUSERS AU(NOLOCK) 
		INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = AU.AGENTID
		INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER ACC(NOLOCK) ON AU.USERID = ACC.AGENT_ID
		WHERE AU.USERTYPE = 'A'

		UNION ALL

		SELECT AGENTID = 0, AGENTNAME = 'Cash in Transit', ACCT_NUM
		FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK)
		WHERE GL_CODE = 0

		UNION ALL

		SELECT AGENTID = -1, AGENTNAME = 'Bank Collected', ACCT_NUM = NULL
		

		CREATE TABLE #OPENING_BAL(ACC_NUM VARCHAR(30), OPENING_BALANCE MONEY)

		INSERT INTO #OPENING_BAL(ACC_NUM, OPENING_BALANCE)
		SELECT BRANCH = B.ACC_NUM, OPENING_BALANCE = SUM(CASE WHEN PART_TRAN_TYPE = 'DR' THEN TRAN_AMT ELSE -1*TRAN_AMT END)
		FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER B(NOLOCK)
		INNER JOIN #TEMP_RPT AM(NOLOCK) ON AM.ACC_NUM = B.ACC_NUM
		WHERE TRAN_DATE < @DATE
		GROUP BY B.ACC_NUM


		UPDATE T SET T.OPENING_BALANCE = O.OPENING_BALANCE
		FROM #TEMP_RPT T
		INNER JOIN #OPENING_BAL O ON O.ACC_NUM = T.ACC_NUM

		--INSERT INTO #TEMP_RPT(BRANCH_NAME, BRANCH_ID, OPENING_BALANCE)
		
		SELECT inAmount = CASE WHEN PART_TRAN_TYPE = 'DR' THEN TRAN_AMT ELSE 0 END
				, outAmount = CASE WHEN PART_TRAN_TYPE = 'CR' THEN TRAN_AMT ELSE 0 END
				, ACC_NUM , TRAN_DATE = CAST(TRAN_DATE AS DATE), FIELD1, ISNULL(FIELD2, '') FIELD2, ACCT_RPT_CODE
		INTO #BRANCH_CASH_IN_OUT
		FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER B(NOLOCK)
		INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK) ON AC.ACCT_NUM = B.ACC_NUM
		WHERE TRAN_DATE BETWEEN @DATE AND @DATE + ' 23:59:59'
		

		DELETE FROM #BRANCH_CASH_IN_OUT
		WHERE FIELD1 IN (SELECT FIELD1 FROM #BRANCH_CASH_IN_OUT GROUP BY FIELD1 HAVING COUNT(1) = 2)

		SELECT SUM(CASE WHEN ISNULL(FIELD2, '') = 'Remittance Voucher' THEN inAmount ELSE 0 END) IN_AMOUNT, SUM(CASE WHEN ISNULL(FIELD2, '') = 'Remittance Voucher' THEN outAmount ELSE 0 END) OUT_AMOUNT
				, SUM(CASE WHEN ISNULL(FIELD2, '') <> 'Remittance Voucher' AND ACCT_RPT_CODE = 'BVA' THEN inAmount ELSE 0 END) VAULT_IN
				, SUM(CASE WHEN ISNULL(FIELD2, '') <> 'Remittance Voucher' AND ACCT_RPT_CODE = 'BVA' THEN outAmount ELSE 0 END) VAULT_OUT
				, ACC_NUM
		INTO #TEMP
		FROM #BRANCH_CASH_IN_OUT B(NOLOCK)
		GROUP BY ACC_NUM

		--SELECT SUM(CASE WHEN HEAD = 'Txn Send' THEN inAmount ELSE 0 END) IN_AMOUNT, SUM(CASE WHEN HEAD = 'Transfer To Vault' THEN outAmount ELSE 0 END) OUT_AMOUNT
		--,SUM(CASE WHEN HEAD <> 'Txn Send' AND USERID = 0 THEN inAmount ELSE 0 END) VAULT_IN, SUM(CASE WHEN HEAD <> 'Txn Send' AND USERID = 0 THEN outAmount ELSE 0 END) VAULT_OUT, branchId
		--INTO #TEMP
		--FROM #BRANCH_CASH_IN_OUT B(NOLOCK)
		--GROUP BY branchId

		UPDATE R SET R.IN_AMOUNT = T.IN_AMOUNT, R.OUT_AMOUNT = T.OUT_AMOUNT, R.VAULT_IN = T.VAULT_IN, R.VAULT_OUT = T.VAULT_OUT
		FROM #TEMP_RPT R
		INNER JOIN #TEMP T ON T.ACC_NUM = R.ACC_NUM
		
		SELECT SUM(CASE WHEN ISNULL(CANCELAPPROVEDDATE, '1917-01-01') BETWEEN @DATE AND @DATE + ' 23:59:59' THEN 0 ELSE CAMT END) IN_AMOUNT
		INTO #BANKTXN
		FROM REMITTRAN (NOLOCK)
		WHERE CREATEDDATE BETWEEN @DATE AND @DATE + ' 23:59:59'
		AND COLLMODE = 'BANK DEPOSIT'

		UPDATE T SET T.IN_AMOUNT =  TR.IN_AMOUNT 
		FROM #BANKTXN TR(NOLOCK)
		INNER JOIN #TEMP_RPT T(NOLOCK) ON T.BRANCH_ID = -1

		UPDATE #TEMP_RPT SET CLOSING_BALANCE = ISNULL(OPENING_BALANCE, 0) + ISNULL(IN_AMOUNT, 0) - ISNULL(OUT_AMOUNT, 0) + ISNULL(VAULT_IN, 0) - ISNULL(VAULT_OUT, 0)
		WHERE BRANCH_ID <> -1

		SELECT BRANCH_NAME = CASE WHEN BRANCH_ID NOT IN (0, -1) THEN'<a href=''/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=cashstatus&flag=drill-down1&asOfDate='+@DATE+'&branchId='+CAST(BRANCH_ID AS VARCHAR)+'''>'+BRANCH_NAME+'</a>'
								ELSE BRANCH_NAME END
				, OPENING_BALANCE = SUM(OPENING_BALANCE)
				, IN_AMOUNT = SUM(IN_AMOUNT)
				, OUT_AMOUNT = SUM(OUT_AMOUNT)
				, VAULT_IN = SUM(VAULT_IN)
				, VAULT_OUT = SUM(VAULT_OUT)
				, CLOSING_BALANCE = SUM(CLOSING_BALANCE)
		FROM (
			SELECT BRANCH_NAME,
			  		OPENING_BALANCE, 
					IN_AMOUNT, 
					OUT_AMOUNT, 
					VAULT_IN,
					VAULT_OUT,
					CLOSING_BALANCE,
					BRANCH_ID
			FROM #TEMP_RPT)X
		GROUP BY BRANCH_NAME, BRANCH_ID
		ORDER BY BRANCH_ID DESC

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'As Of Date' head, @DATE 

		SELECT  'Cash Status Report' title
		RETURN
	END
	IF @FLAG = 'drill-down1'
	BEGIN
		CREATE TABLE #TEMP_RPT_DRILL_DOWN(BRANCH_NAME VARCHAR(100), BRANCH_ID INT, OPENING_BALANCE MONEY, IN_AMOUNT MONEY, OUT_AMOUNT MONEY, CLOSING_BALANCE MONEY
		,VAULT_IN MONEY, VAULT_OUT MONEY, ACCT_TYPE CHAR(1), ACCT_NAME VARCHAR(100), ACC_NUM VARCHAR(30))

		--CREATE TABLE #ALL_AGENT(AGENT_ID INT, AGENT_NAME VARCHAR(100), ACCT_TYPE CHAR(1))
		INSERT INTO #TEMP_RPT_DRILL_DOWN(BRANCH_ID, BRANCH_NAME, ACCT_TYPE, ACCT_NAME, ACC_NUM)
		SELECT AGENTID, AC.ACCT_NAME, 'V', AC.ACCT_NAME, AC.ACCT_NUM
		FROM AGENTMASTER AM(NOLOCK)
		INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK) ON AC.AGENT_ID = AM.AGENTID 
		AND AM.AGENTID = @AGENT_ID
		AND AC.ACCT_RPT_CODE = 'BVA'
		

		INSERT INTO #TEMP_RPT_DRILL_DOWN(BRANCH_ID, BRANCH_NAME, ACCT_TYPE, ACCT_NAME, ACC_NUM)
		SELECT USERID, AC.ACCT_NAME, 'T', AC.ACCT_NAME, AC.ACCT_NUM
		FROM APPLICATIONUSERS AU(NOLOCK)
		INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK) ON AC.AGENT_ID = AU.USERID 
		WHERE AC.ACCT_RPT_CODE = 'TCA'
		AND AU.AGENTID = @AGENT_ID


		CREATE TABLE #TMP(ACC_NUM VARCHAR(30), AMOUNT MONEY)
		
		INSERT INTO #TMP(ACC_NUM, AMOUNT)
		SELECT ACC_NUM = B.ACC_NUM, OPENING_BALANCE = SUM(CASE WHEN PART_TRAN_TYPE = 'DR' THEN TRAN_AMT ELSE -1*TRAN_AMT END)
		FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER B(NOLOCK)
		INNER JOIN #TEMP_RPT_DRILL_DOWN A(NOLOCK) ON A.ACC_NUM = B.ACC_NUM
		WHERE TRAN_DATE < @DATE
		GROUP BY B.ACC_NUM

		UPDATE TM SET TM.OPENING_BALANCE = T.AMOUNT
		FROM #TMP T
		INNER JOIN #TEMP_RPT_DRILL_DOWN TM ON TM.ACC_NUM = T.ACC_NUM

		SELECT inAmount = CASE WHEN PART_TRAN_TYPE = 'DR' THEN TRAN_AMT ELSE 0 END
				, outAmount = CASE WHEN PART_TRAN_TYPE = 'CR' THEN TRAN_AMT ELSE 0 END
				, B.ACC_NUM , TRAN_DATE = CAST(TRAN_DATE AS DATE), FIELD1, ISNULL(FIELD2, '') FIELD2, ACCT_RPT_CODE
		INTO #BRANCH_CASH_IN_OUT1
		FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER B
		INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK) ON AC.ACCT_NUM = B.ACC_NUM
		WHERE TRAN_DATE BETWEEN @DATE AND @DATE + ' 23:59:59'

		DELETE FROM #BRANCH_CASH_IN_OUT1
		WHERE FIELD1 IN (SELECT FIELD1 FROM #BRANCH_CASH_IN_OUT1 WHERE ISNULL(FIELD2, '') = 'Remittance Voucher' GROUP BY FIELD1 HAVING COUNT(1) = 2 ) 
		
		SELECT SUM(CASE WHEN ISNULL(FIELD2, '') = 'Remittance Voucher' THEN inAmount ELSE 0 END) IN_AMOUNT, 
				0 OUT_AMOUNT, B.ACC_NUM,
				SUM(CASE WHEN ISNULL(FIELD2, '') <> 'Remittance Voucher' THEN inAmount ELSE 0 END) VAULT_IN, 
				SUM(CASE WHEN ISNULL(FIELD2, '') <> 'Remittance Voucher' THEN outAmount ELSE 0 END) VAULT_OUT
		INTO #TT_VAULT
		FROM #BRANCH_CASH_IN_OUT1 B(NOLOCK)
		INNER JOIN #TEMP_RPT_DRILL_DOWN A(NOLOCK) ON A.ACC_NUM = B.ACC_NUM
		WHERE ACCT_RPT_CODE = 'BVA'
		GROUP BY B.ACC_NUM

		SELECT SUM(inAmount) IN_AMOUNT, 
				SUM(outAmount) OUT_AMOUNT, B.ACC_NUM,
				0 VAULT_IN, 
				0 VAULT_OUT
		INTO #TT_TELLER
		FROM #BRANCH_CASH_IN_OUT1 B(NOLOCK)
		INNER JOIN #TEMP_RPT_DRILL_DOWN A(NOLOCK) ON A.ACC_NUM = B.ACC_NUM
		WHERE ACCT_RPT_CODE <> 'BVA'
		GROUP BY B.ACC_NUM

		UPDATE R SET R.IN_AMOUNT = T.IN_AMOUNT, R.OUT_AMOUNT = T.OUT_AMOUNT, R.VAULT_IN = T.VAULT_IN, R.VAULT_OUT = T.VAULT_OUT
		FROM #TEMP_RPT_DRILL_DOWN R
		INNER JOIN #TT_VAULT T ON T.ACC_NUM = R.ACC_NUM

		UPDATE R SET R.IN_AMOUNT = T.IN_AMOUNT, R.OUT_AMOUNT = T.OUT_AMOUNT, R.VAULT_IN = T.VAULT_IN, R.VAULT_OUT = T.VAULT_OUT
		FROM #TEMP_RPT_DRILL_DOWN R
		INNER JOIN #TT_TELLER T ON T.ACC_NUM = R.ACC_NUM

		UPDATE #TEMP_RPT_DRILL_DOWN SET CLOSING_BALANCE = ISNULL(OPENING_BALANCE, 0) + ISNULL(IN_AMOUNT, 0) - ISNULL(OUT_AMOUNT, 0) + ISNULL(VAULT_IN, 0) - ISNULL(VAULT_OUT, 0)
--AccountReport/AccountStatement/StatementDetails.aspx?startDate=2019-07-06&endDate=2019-07-06&acNum=101003966&acName=101003966%20|%20Transit%20Charges%20(Intermediary%20Charge)&curr=&type=a
		SELECT BRANCH_NAME = '<a href=''/AccountReport/AccountStatement/StatementDetails.aspx?endDate='+@DATE+'&type=a&startDate='+@DATE+'&acNum='+ACC_NUM+'&acName='+ACCT_NAME+'''>'+BRANCH_NAME+'</a>',
			  	OPENING_BALANCE, 
				IN_AMOUNT, 
				OUT_AMOUNT, 
				VAULT_IN,
				VAULT_OUT,
				CLOSING_BALANCE  
		FROM #TEMP_RPT_DRILL_DOWN
		
		DECLARE @AGENT_NAME VARCHAR(100) = (SELECT AGENTNAME FROM AGENTMASTER (NOLOCK) WHERE AGENTID = @AGENT_ID)

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'As Of Date' head, @DATE union all
		SELECT  'Branch' head, @AGENT_NAME

		SELECT  'Cash Status Report - Drill Down ( '+@AGENT_NAME+')' title
	END
END

--EXEC  PROC_CASH_STATUS_REPORT @FLAG = 'drill-down1',@user='admin',@DATE='2019-07-05',@AGENT_ID=394392

--SELECT * FROM APPLICATIONUSERS WHERE USERID=394392