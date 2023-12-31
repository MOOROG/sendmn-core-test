USE [SendMnPro_Account]
GO
/****** Object:  View [dbo].[vwREMIT_TRN_LOCAL]    Script Date: 5/18/2021 5:21:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwREMIT_TRN_LOCAL]
AS
SELECT 
	R_AGENT = ISNULL(pm.mapCodeInt, RTL.R_AGENT)
	,TRAN_ID, TRN_REF_NO, S_AGENT, SENDER_NAME, RECEIVER_NAME, S_AMT, P_AMT, ROUND_AMT, TOTAL_SC
	,OTHER_SC, S_SC, R_SC, EXT_SC, R_BANK, R_BANK_NAME, R_BRANCH, R_AGENT R_AGENT1, TRN_TYPE, TRN_STATUS
	,PAY_STATUS, TRN_DATE, P_DATE, CONFIRM_DATE, CANCEL_DATE, F_SENDTRN, F_STODAY_PTODAY, F_STODAY_NOTPTODAY
	,F_PTODAY_SYESTERDAY, F_STODAY_CTODAY, F_CODAY_SYESTERDAY, bank_id, SEmpID, paidBy ,tranno, CANCEL_USER
	,TranIdNew, tranType, accountNo	
FROM REMIT_TRN_LOCAL RTL (NOLOCK)
LEFT JOIN FastMoneyPro_remit.dbo.agentMaster am (NOLOCK) on rtl.R_AGENT = am.mapCodeInt
LEFT JOIN FastMoneyPro_remit.dbo.BankCodeMaping bm (NOLOCK) ON am.agentId = bm.subBankCode
LEFT JOIN FastMoneyPro_remit.dbo.agentMaster pm (NOLOCK) ON bm.mainBankCode = pm.agentId
GO
