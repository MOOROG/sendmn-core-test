USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_LIQUIDITY_REPORT]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PROC_LIQUIDITY_REPORT]  
(
	@FLAG VARCHAR(10)
	,@DATE VARCHAR(20) = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @FLAG = 'LIQ-S'
	BEGIN
		DECLARE @CASH_BALANCE MONEY, @BANK_BALANCE MONEY, @RECEIVABLES_BELOW_FOUR_DAYS MONEY, @CORRESPONDENT_RECEIVABLES MONEY
				, @CUSTOMER_LIAB1 MONEY, @CUSTOMER_LIAB2 MONEY
		
		SELECT @CASH_BALANCE = ISNULL(SUM(CASE WHEN PART_TRAN_TYPE = 'CR' THEN TRAN_AMT * -1 ELSE TRAN_AMT END), 0) 
		FROM TRAN_MASTER (NOLOCK) WHERE 1=1
		AND ACC_NUM IN ('100139297552', '100139297553', '100139208487', '100139219838', '100139297551', '100139292573', '100139258568')
		AND TRAN_DATE <= '2020-05-25' 
		
		SELECT @BANK_BALANCE = ISNULL(SUM(CASE WHEN PART_TRAN_TYPE = 'CR' THEN TRAN_AMT * -1 ELSE TRAN_AMT END), 0) 
		FROM TRAN_MASTER (NOLOCK) WHERE 1=1
		AND GL_SUB_HEAD_CODE = 23
		AND TRAN_DATE <= '2020-05-25' 

		SELECT @CORRESPONDENT_RECEIVABLES = ISNULL(SUM(CASE WHEN PART_TRAN_TYPE = 'CR' THEN TRAN_AMT * -1 ELSE TRAN_AMT END), 0) 
		FROM TRAN_MASTER (NOLOCK) WHERE 1=1
		AND GL_SUB_HEAD_CODE = 110
		AND TRAN_DATE <= '2020-05-25' 
		
		SELECT @CUSTOMER_LIAB1 = ISNULL(SUM(CASE WHEN PART_TRAN_TYPE = 'CR' THEN TRAN_AMT * -1 ELSE TRAN_AMT END), 0) 
		FROM TRAN_MASTER (NOLOCK) WHERE 1=1
		AND GL_SUB_HEAD_CODE = 79 		
		AND TRAN_DATE <= '2020-05-25' 

		SELECT @CUSTOMER_LIAB2 = ISNULL(SUM(CASE WHEN PART_TRAN_TYPE = 'CR' THEN TRAN_AMT * -1 ELSE TRAN_AMT END), 0) 
		FROM TRAN_MASTER (NOLOCK) WHERE 1=1
		AND ACC_NUM = '100339261593'
		AND TRAN_DATE <= '2020-05-25' 

		SELECT ISNULL(@CASH_BALANCE, 0) CASH_BALANCE, ISNULL(@BANK_BALANCE, 0) BANK_BALANCE, ISNULL(@CORRESPONDENT_RECEIVABLES, 0) CORRESPONDENT_RECEIVABLES
				, ISNULL(@RECEIVABLES_BELOW_FOUR_DAYS, 0) BELOW_FOUR_DAYS
				, ISNULL(@CUSTOMER_LIAB1, 0) + ISNULL(@CUSTOMER_LIAB2, 0) CUSTOMER_LIAB
				, TOTAL = ISNULL(@CASH_BALANCE, 0) + ISNULL(@BANK_BALANCE, 0) + ISNULL(@CORRESPONDENT_RECEIVABLES, 0) 
							+ ISNULL(@RECEIVABLES_BELOW_FOUR_DAYS, 0) + ISNULL(@CUSTOMER_LIAB1, 0) + ISNULL(@CUSTOMER_LIAB2, 0)
	END
END



GO
