﻿use fastmoneypro_account
go
--EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_AGENT_AGEING_REPORT @user='admin',@TO_DATE='2019-10-29'


ALTER PROC PROC_AGENT_AGEING_REPORT
(
	@USER VARCHAR(50)
	,@TO_DATE VARCHAR(20)
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @FROM_DATE VARCHAR(20) = '2018-12-31'

	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL DROP TABLE #TEMP

	SELECT ROW_ID, REFERRAL_CODE, REFERRAL_NAME, BRANCH_ID
	INTO #TEMP
	FROM FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE (NOLOCK)

	ALTER TABLE #TEMP ADD ACC_NUM VARCHAR(30)

	UPDATE T SET ACC_NUM = A.ACCT_NUM
	FROM #TEMP T
	INNER JOIN AC_MASTER A ON A.AGENT_ID = T.ROW_ID AND A.GL_CODE = 0 AND ACCT_RPT_CODE = 'RA'

	SELECT PART_TRAN_TYPE, CAST(TRAN_DATE AS DATE) TRAN_DATE, TRAN_AMT, T.* 
	INTO #FINAL_TABLE
	FROM #TEMP T
	INNER JOIN TRAN_MASTER M (NOLOCK) ON M.ACC_NUM = T.ACC_NUM
	WHERE TRAN_DATE BETWEEN @FROM_DATE AND @TO_DATE + ' 23:59:59'
	
	SELECT SUM(ISNULL(TRAN_AMT, 0)) TRAN_AMT
			, REFERRAL_NAME, ACC_NUM 
	INTO #BELOW_FOUR_DAYS
	FROM #FINAL_TABLE
	WHERE TRAN_DATE BETWEEN DATEADD(DAY, -4, @TO_DATE) AND @TO_DATE + ' 23:59:59'
	AND PART_TRAN_TYPE = 'DR'
	GROUP BY REFERRAL_NAME, ACC_NUM

	DECLARE @AGEING_DATE VARCHAR(20) =  CONVERT(VARCHAR, DATEADD(DAY, -4, @TO_DATE), 110)

	SELECT SUM(ISNULL(TRAN_AMT, 0)) TRAN_AMT
			, REFERRAL_NAME, ACC_NUM 
	INTO #OVER_FOUR_DAYS
	FROM #FINAL_TABLE
	WHERE TRAN_DATE BETWEEN DATEADD(DAY, -1, DATEADD(MONTH, -1, @TO_DATE)) AND DATEADD(DAY, -1, @AGEING_DATE) + ' 23:59:59'
	AND PART_TRAN_TYPE = 'DR'
	GROUP BY REFERRAL_NAME, ACC_NUM

	SET @AGEING_DATE =  CONVERT(VARCHAR, DATEADD(MONTH, -3, @TO_DATE), 110)

	SELECT SUM(ISNULL(TRAN_AMT, 0)) TRAN_AMT
			, REFERRAL_NAME, ACC_NUM 
	INTO #OVER_ONE_MONTH
	FROM #FINAL_TABLE
	WHERE TRAN_DATE BETWEEN DATEADD(DAY, -1, @AGEING_DATE) AND DATEADD(DAY, -2, DATEADD(MONTH, -1, @TO_DATE)) + ' 23:59:59'
	AND PART_TRAN_TYPE = 'DR'
	GROUP BY REFERRAL_NAME, ACC_NUM

	SELECT SUM(ISNULL(TRAN_AMT, 0)) TRAN_AMT
			, REFERRAL_NAME, ACC_NUM 
	INTO #OVER_THREE_MONTH
	FROM #FINAL_TABLE
	WHERE TRAN_DATE BETWEEN DATEADD(DAY, -1, DATEADD(MONTH, -6, @TO_DATE)) AND DATEADD(DAY, -2, @AGEING_DATE) + ' 23:59:59'
	AND PART_TRAN_TYPE = 'DR'
	GROUP BY REFERRAL_NAME, ACC_NUM

	SET @AGEING_DATE = CONVERT(VARCHAR, DATEADD(MONTH, -6, @TO_DATE), 110)

	SELECT SUM(ISNULL(TRAN_AMT, 0)) TRAN_AMT
			, REFERRAL_NAME, ACC_NUM 
	INTO #OVER_SIX_MONTH
	FROM #FINAL_TABLE
	WHERE TRAN_DATE BETWEEN @FROM_DATE AND DATEADD(DAY, -2, @AGEING_DATE) + ' 23:59:59'
	AND PART_TRAN_TYPE = 'DR'
	GROUP BY REFERRAL_NAME, ACC_NUM

	CREATE TABLE #AGEING_TABLE(AGENT_NAME VARCHAR(100), ACCOUNT_NUMBER VARCHAR(30), TOTAL_OUT_STANDING MONEY, BELOW_FOUR_DAYS MONEY, OVER_FOUR_DAYS MONEY, OVER_ONE_MONTH MONEY
									, OVER_THREE_MONTH MONEY, OVER_SIX_MONTH MONEY)

	INSERT INTO #AGEING_TABLE(ACCOUNT_NUMBER, AGENT_NAME)
	SELECT DISTINCT ACC_NUM, REFERRAL_NAME
	FROM #FINAL_TABLE S

	UPDATE A SET A.OVER_SIX_MONTH = S.TRAN_AMT
	FROM #AGEING_TABLE A 
	INNER JOIN #OVER_SIX_MONTH S ON S.ACC_NUM = A.ACCOUNT_NUMBER

	UPDATE A SET A.OVER_THREE_MONTH = S.TRAN_AMT
	FROM #AGEING_TABLE A 
	INNER JOIN #OVER_THREE_MONTH S ON S.ACC_NUM = A.ACCOUNT_NUMBER

	UPDATE A SET A.OVER_ONE_MONTH = S.TRAN_AMT
	FROM #AGEING_TABLE A 
	INNER JOIN #OVER_ONE_MONTH S ON S.ACC_NUM = A.ACCOUNT_NUMBER

	UPDATE A SET A.OVER_FOUR_DAYS = S.TRAN_AMT
	FROM #AGEING_TABLE A 
	INNER JOIN #OVER_FOUR_DAYS S ON S.ACC_NUM = A.ACCOUNT_NUMBER

	UPDATE A SET A.BELOW_FOUR_DAYS = S.TRAN_AMT
	FROM #AGEING_TABLE A 
	INNER JOIN #BELOW_FOUR_DAYS S ON S.ACC_NUM = A.ACCOUNT_NUMBER

	UPDATE A SET A.TOTAL_OUT_STANDING = X.TRAN_AMT
	FROM #AGEING_TABLE A 
	INNER JOIN (
	SELECT SUM(ISNULL(TRAN_AMT, 0)) TRAN_AMT
			, ACC_NUM
	FROM #FINAL_TABLE 
	WHERE PART_TRAN_TYPE = 'DR'
	GROUP BY ACC_NUM
	)X ON X.ACC_NUM = A.ACCOUNT_NUMBER

	SELECT SUM(TRAN_AMT) TRAN_AMT, ACC_NUM
	FROM (
		SELECT SUM(CASE WHEN PART_TRAN_TYPE = 'CR' THEN ISNULL(TRAN_AMT, 0) ELSE 0 END) TRAN_AMT, ACC_NUM
		FROM #FINAL_TABLE F
		--WHERE acc_num = '8080000071'
		GROUP BY ACC_NUM, PART_TRAN_TYPE
	)X GROUP BY ACC_NUM

	--SELECT * FROM #AGEING_TABLE WHERE ACCOUNT_NUMBER = '8080000071'

	SELECT AGENT_NAME + ' | ' + ACCOUNT_NUMBER AS AGENT_NAME, ACCOUNT_NUMBER, TOTAL_OUT_STANDING, BELOW_FOUR_DAYS, OVER_FOUR_DAYS, OVER_ONE_MONTH, OVER_THREE_MONTH,
			OVER_SIX_MONTH 
	FROM #AGEING_TABLE
	ORDER BY AGENT_NAME
END
--EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_AGENT_AGEING_REPORT @user='admin',@TO_DATE='2019-10-29'
