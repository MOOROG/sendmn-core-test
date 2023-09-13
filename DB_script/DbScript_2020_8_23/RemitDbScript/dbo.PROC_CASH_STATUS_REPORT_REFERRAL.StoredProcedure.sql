ALTER PROC [dbo].[PROC_CASH_STATUS_REPORT_REFERRAL]
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
		CREATE TABLE #TEMP_RPT_DRILL_DOWN(BRANCH_NAME VARCHAR(100), BRANCH_ID INT, OPENING_BALANCE MONEY, IN_AMOUNT MONEY
											, OUT_AMOUNT MONEY, CLOSING_BALANCE MONEY, ACCT_NAME VARCHAR(100), ACCT_NUM VARCHAR(30)
											, TOTAL_SENT INT, TOTAL_CANCEL INT)

		--CREATE TABLE #ALL_AGENT(AGENT_ID INT, AGENT_NAME VARCHAR(100), ACCT_TYPE CHAR(1))
		INSERT INTO #TEMP_RPT_DRILL_DOWN(BRANCH_ID, BRANCH_NAME, ACCT_NAME, ACCT_NUM)
		SELECT R.BRANCH_ID, R.REFERRAL_NAME, AC.ACCT_NAME, AC.ACCT_NUM 
		FROM REFERRAL_AGENT_WISE R(NOLOCK)
		INNER JOIN SendMnPro_Account.dbo.AC_MASTER AC(NOLOCK) ON AC.AGENT_ID = R.ROW_ID AND AC.ACCT_RPT_CODE = 'RA'
		WHERE R.AGENT_ID = 0
		AND R.BRANCH_ID = ISNULL(@AGENT_ID, R.BRANCH_ID)
		
		CREATE TABLE #TMP(ACCT_NUM VARCHAR(30), AMOUNT MONEY)
		
		INSERT INTO #TMP(ACCT_NUM, AMOUNT)
		SELECT ACCT_NUM = T.ACC_NUM, OPENING_BALANCE = ISNULL(SUM (CASE WHEN part_tran_type='CR' 
											THEN tran_amt*-1 ELSE tran_amt END) ,0)
		FROM #TEMP_RPT_DRILL_DOWN A(NOLOCK)
		INNER JOIN SendMnPro_Account.dbo.TRAN_MASTER T(NOLOCK) ON A.ACCT_NUM = T.ACC_NUM
		WHERE T.tran_date < @DATE
		GROUP BY ACC_NUM

		UPDATE TM SET TM.OPENING_BALANCE = T.AMOUNT
		FROM #TMP T
		INNER JOIN #TEMP_RPT_DRILL_DOWN TM ON TM.ACCT_NUM = T.ACCT_NUM

		SELECT CAST(CAST(REF_NUM AS NUMERIC) AS BIGINT) REF_NUM
		INTO #REF_NUMBER
		FROM SendMnPro_Account.dbo.TRAN_MASTER T(NOLOCK) 
		INNER JOIN #TEMP_RPT_DRILL_DOWN A ON A.ACCT_NUM = T.ACC_NUM
		WHERE T.tran_date BETWEEN @DATE AND @DATE + ' 23:59:59'
		GROUP BY CAST(CAST(REF_NUM AS NUMERIC) AS BIGINT)
		HAVING COUNT(1) = 1

		SELECT part_tran_type, tran_amt, ACC_NUM, ACCT_TYPE_CODE, field2
		INTO #TRAN_MASTER
		FROM SendMnPro_Account.dbo.TRAN_MASTER T(NOLOCK) 
		INNER JOIN #REF_NUMBER R ON R.REF_NUM = CAST(CAST(T.REF_NUM AS NUMERIC) AS BIGINT)
		INNER JOIN #TEMP_RPT_DRILL_DOWN A ON A.ACCT_NUM = T.ACC_NUM
		WHERE T.tran_date BETWEEN @DATE AND @DATE + ' 23:59:59'
		
		SELECT IN_AMOUNT = SUM(CASE WHEN part_tran_type = 'dr' THEN tran_amt ELSE 0 END) , 
				OUT_AMOUNT = SUM(CASE WHEN part_tran_type = 'cr' THEN tran_amt ELSE 0 END), 
				ACCT_NUM = ACC_NUM,
				TOTAL_SENT = SUM(CASE WHEN part_tran_type = 'dr' AND field2 = 'Remittance Voucher' THEN 1 ELSE 0 END) , 
				TOTAL_CANCEL = SUM(CASE WHEN part_tran_type = 'cr' AND field2 = 'Remittance Voucher' THEN 1 ELSE 0 END)
		INTO #TT_TOTAL
		FROM #TEMP_RPT_DRILL_DOWN A(NOLOCK)
		INNER JOIN #TRAN_MASTER T(NOLOCK) ON A.ACCT_NUM = T.ACC_NUM
		GROUP BY ACC_NUM

		UPDATE R SET R.IN_AMOUNT = T.IN_AMOUNT, R.OUT_AMOUNT = T.OUT_AMOUNT, R.TOTAL_SENT = ISNULL(T.TOTAL_SENT, 0), R.TOTAL_CANCEL = ISNULL(T.TOTAL_CANCEL, 0)
		FROM #TEMP_RPT_DRILL_DOWN R
		INNER JOIN #TT_TOTAL T ON T.ACCT_NUM = R.ACCT_NUM

		UPDATE #TEMP_RPT_DRILL_DOWN SET CLOSING_BALANCE = ISNULL(OPENING_BALANCE, 0) + ISNULL(IN_AMOUNT, 0) - ISNULL(OUT_AMOUNT, 0)

		DELETE FROM #TEMP_RPT_DRILL_DOWN WHERE ISNULL(CLOSING_BALANCE, 0) = 0 AND ISNULL(OPENING_BALANCE, 0) = 0 AND ISNULL(IN_AMOUNT, 0) = 0 AND ISNULL(OUT_AMOUNT, 0) = 0

	
		SELECT AGENTID, AGENTNAME
		FROM AGENTMASTER AM(NOLOCK)
		INNER JOIN (SELECT DISTINCT BRANCH_ID FROM #TEMP_RPT_DRILL_DOWN)X ON X.BRANCH_ID = AM.AGENTID
		
		SELECT AGENT_NAME, OPENING_BALANCE, IN_AMOUNT, OUT_AMOUNT, CLOSING_BALANCE, BRANCH_ID, ADD_BRANCH
		FROM (
			--AccountReport/AccountStatement/StatementDetails.aspx?startDate=2019-07-06&endDate=2019-07-06&acNum=101003966&acName=101003966%20|%20Transit%20Charges%20(Intermediary%20Charge)&curr=&type=a
			SELECT AGENT_NAME = '<a href=''/AccountReport/AccountStatement/StatementDetails.aspx?endDate='+@DATE+'&type=a&startDate='+@DATE+'&acNum='+ACCT_NUM+'&acName='+BRANCH_NAME+'''>'+BRANCH_NAME+' ('+CAST(ISNULL(TOTAL_SENT, 0) AS VARCHAR)+' - '+CAST(ISNULL(TOTAL_CANCEL, 0) AS VARCHAR)+')</a>',
			  		OPENING_BALANCE, 
					IN_AMOUNT, 
					OUT_AMOUNT, 
					CLOSING_BALANCE, 
					BRANCH_ID,
					RPT_TYPE = 'A',
					BRANCH_NAME ,
					ADD_BRANCH = 'Y'
			FROM #TEMP_RPT_DRILL_DOWN

			UNION ALL
		
			SELECT AGENT_NAME = REFERRAL_NAME + ' (' + CAST(COUNT(1) AS VARCHAR) +')'
					, OPENING_BALANCE = 0
					, IN_AMOUNT = SUM(CAMT)
					, OUT_AMOUNT = 0
					, CLOSING_BALANCE = 0
					, R.BRANCH_ID
					, RPT_TYPE = 'B'
					, BRANCH_NAME = 'Z'
					, ADD_BRANCH = 'N'
			FROM REFERRAL_AGENT_WISE R(NOLOCK)
			INNER JOIN remitTran RT(NOLOCK) ON RT.promotionCode = R.REFERRAL_CODE
			WHERE REFERRAL_TYPE_CODE = 'RB'
			AND RT.createdDate BETWEEN @DATE AND @DATE + ' 23:59:59'
			AND RT.tranStatus <> 'CANCEL'
			AND RT.COLLMODE = 'CASH COLLECT'
			AND R.BRANCH_ID = ISNULL(@AGENT_ID, R.BRANCH_ID)
			GROUP BY R.REFERRAL_NAME, R.BRANCH_ID
		)X ORDER BY RPT_TYPE, BRANCH_NAME ASC 
			--EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			--SELECT  'As Of Date' head, @DATE 

		--SELECT  'Cash Status Report - Referral' title
	END
END



GO
