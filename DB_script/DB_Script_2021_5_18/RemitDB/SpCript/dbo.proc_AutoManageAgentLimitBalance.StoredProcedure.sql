USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_AutoManageAgentLimitBalance]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_AutoManageAgentLimitBalance]
AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY


DECLARE @agentTodaysBal table(agentId int, SentAmt money,paidAmt money, cancelAmt money)

INSERT INTO @agentTodaysBal
SELECT SAGENT,SUM(CAMT) AMT,0,0 FROM REMITTRAN(NOLOCK) 
WHERE approvedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()
GROUP BY SAGENT
UNION ALL
SELECT SBRANCH,SUM(CAMT) AMT,0,0 FROM REMITTRAN(NOLOCK) 
WHERE approvedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()
AND SAGENT <> SBRANCH
GROUP BY SBRANCH

UNION ALL
SELECT PAGENT,0,SUM(PAMT) AMT,0 FROM REMITTRAN(NOLOCK) 
WHERE paidDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()
GROUP BY PAGENT
UNION ALL
SELECT PBRANCH,SUM(PAMT) AMT,0,0 FROM REMITTRAN(NOLOCK) 
WHERE paidDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()
AND PAGENT <> PBRANCH
GROUP BY PBRANCH

UNION ALL
SELECT SAGENT,0,0,SUM(CAMT) AMT FROM REMITTRAN(NOLOCK) 
WHERE cancelApprovedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()
GROUP BY SAGENT
UNION ALL
SELECT SBRANCH,SUM(CAMT) AMT,0,0 FROM REMITTRAN(NOLOCK) 
WHERE cancelApprovedDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE()
AND SAGENT <> SBRANCH
GROUP BY SBRANCH

SELECT AGENTID
		, SentAmt = SUM(SentAmt) 
		, paidAmt = SUM(paidAmt) 
		, cancelAmt = SUM(cancelAmt) 
	FROM @agentTodaysBal GROUP BY AGENTID

return

--select acct_num,acct_name,clr_bal_amt,amt
--FROM SendMnPro_Account.dbo.ac_master A,(
--SELECT ACC_NUM, SUM (CASE WHEN PART_TRAN_TYPE='Dr' THEN ISNULL(TRAN_AMT,0)*-1 ELSE ISNULL(TRAN_AMT,0) END) AMT 
--FROM SendMnPro_Account.dbo.TRAN_MASTER WITH (NOLOCK) GROUP BY ACC_NUM) X
--WHERE A.acct_num = X.acc_num
--AND isnull(A.clr_bal_amt,0)<>isnull(X.AMT,0)
--RETURN

UPDATE SendMnPro_Account.dbo.AC_MASTER SET CLR_BAL_AMT=AMT,available_amt = AMT
 FROM SendMnPro_Account.dbo.ac_master A,(
SELECT ACC_NUM, SUM (CASE WHEN PART_TRAN_TYPE='Dr' THEN ISNULL(TRAN_AMT,0)*-1 ELSE ISNULL(TRAN_AMT,0) END) AMT 
FROM SendMnPro_Account.dbo.TRAN_MASTER WITH (NOLOCK) GROUP BY ACC_NUM) X
WHERE A.acct_num=X.acc_num
AND isnull(A.clr_bal_amt,0) <> isnull(X.AMT,0)

UPDATE C SET C.todaysSent = X.SentAmt 
			,C.todaysPaid = X.paidAmt
			,C.todaysCancelled = X.cancelAmt
			,topUpTillYesterday = ISNULL(C.topUpTillYesterday,0)
			,yesterdaysBalance = ISNULL(C.yesterdaysBalance,0)
			,topUpToday = ISNULL(C.topUpToday,0)
			,todaysEPI = ISNULL(C.todaysEPI,0)
			,todaysPOI = ISNULL(C.todaysPOI,0)
FROM creditLimit C
INNER JOIN (
	SELECT AGENTID
		, SentAmt = SUM(SentAmt) 
		, paidAmt = SUM(paidAmt) 
		, cancelAmt = SUM(cancelAmt) 
	FROM @agentTodaysBal GROUP BY AGENTID
)X ON C.AgentId = x.AgentId

PRINT 'Balance updated ...!'
END TRY 

BEGIN CATCH
PRINT ERROR_MESSAGE()
END CATCH
GO
