ALTER  PROC [dbo].[PROC_REFERRAL_STATEMENT]
(
	@FLAG VARCHAR(30)
	,@FROM_DATE VARCHAR(20)
	,@TO_DATE VARCHAR(20)
	,@REFERRAL_CODE VARCHAR(30)
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @ACC_NUM VARCHAR(30);

	IF EXISTS(SELECT * FROM SendMnPro_Remit.dbo.REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @REFERRAL_CODE AND AGENT_ID <> 0)
	BEGIN
		SELECT @ACC_NUM = AC.ACCT_NUM 
		FROM SendMnPro_Remit.dbo.REFERRAL_AGENT_WISE R(NOLOCK) 
		INNER JOIN SendMnPro_Remit.dbo.APPLICATIONUSERS AU(NOLOCK) ON AU.AGENTID = R.AGENT_ID
		INNER JOIN AC_MASTER AC(NOLOCK) ON AC.AGENT_ID = AU.USERID
		WHERE R.REFERRAL_CODE = @REFERRAL_CODE
		AND AC.ACCT_RPT_CODE = 'TCA';
	END
	ELSE
	BEGIN
		SELECT @ACC_NUM = AC.ACCT_NUM 
		FROM ac_master AC(NOLOCK)
		INNER JOIN SendMnPro_Remit.dbo.REFERRAL_AGENT_WISE R(NOLOCK) ON R.ROW_ID = AC.AGENT_ID
		WHERE R.REFERRAL_CODE = @REFERRAL_CODE
		AND AC.ACCT_RPT_CODE = 'RA';
	END

	set @TO_DATE = @TO_DATE +' 23:59:59'

	CREATE TABLE #AC_STATEMENT(TranDate VARCHAR(20), JMENumber VARCHAR(200), Amount MONEY, TranType CHAR(2), field1 VARCHAR(30), field2 VARCHAR(20))

	INSERT INTO #AC_STATEMENT
	SELECT '' TranDate,'Balance Brought Forward' JMENumber
		,Amount = ISNULL(SUM(CASE WHEN part_tran_type='dr' THEN tran_amt*-1 ELSE tran_amt END), 0)
		,TranType =case when SUM(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) >0 then 'cr' else 'dr' end
		,'' field1,'' field2
	FROM tran_master(NOLOCK) 
	WHERE tran_date < @FROM_DATE AND acc_num = @ACC_NUM
	GROUP BY acc_num
	
	INSERT INTO #AC_STATEMENT
	SELECT convert(varchar,tran_date,102) TranDate,JMENumber = CASE WHEN FIELD2 = 'Remittance Voucher' AND ACCT_TYPE_CODE IS NULL THEN field1
																WHEN FIELD2 = 'Remittance Voucher' AND ACCT_TYPE_CODE = 'REVERSE' THEN field1 + ' - Cancelled' ELSE 'Cash Settled' END
		,Amount = ISNULL((case when part_tran_type='dr' then tran_amt*-1 else tran_amt end), 0)
		,t.part_tran_type TranType
		,field1, field2
	FROM tran_master T(NOLOCK) 
	INNER JOIN tran_masterDetail D (NOLOCK) ON T.REF_NUM = D.REF_NUM AND T.TRAN_TYPE = D.TRAN_TYPE
	WHERE tran_date BETWEEN @FROM_DATE AND @TO_DATE
	AND acc_num = @ACC_NUM

	ALTER TABLE #AC_STATEMENT ADD CONTROLNO VARCHAR(50)
	
	UPDATE #AC_STATEMENT SET CONTROLNO = CASE WHEN field2 = 'Remittance Voucher' THEN DBO.FNAENCRYPTSTRING(field1) ELSE NULL END

	SELECT A.*, SenderName = CASE WHEN A.CONTROLNO IS NOT NULL THEN R.SENDERNAME ELSE '-' END
	FROM #AC_STATEMENT A
	LEFT JOIN SendMnPro_Remit.dbo.REMITTRAN R(NOLOCK) ON R.CONTROLNO = A.CONTROLNO
	ORDER BY TranDate ASC
END


GO
