USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_AcDepositUnpaidSummary]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PROC_AcDepositUnpaidSummary]
AS
BEGIN

    SET NOCOUNT ON;

    SELECT 
		receiveAgentId	= m.receiveAgentID
	   --,rBankID		= bb.mapCodeInt
	   ,rBankName		= CASE WHEN m.receiveAgentId = -1 THEN 'IME Nepal' ELSE ISNULL(bank.agentName, 'Others') END
	   ,Txn				= count(*)
	   ,AMT				= sum(totalroundamt)
    FROM ime_plus_01.[dbo].AccountTransaction m WITH(NOLOCK) 
	LEFT JOIN agentMaster bank WITH(NOLOCK) ON m.receiveAgentID=bank.mapCodeInt
    WHERE 1=1
	   --AND m.receiveAgentid='11600000'  
    AND [STATUS] = 'Un-Paid' AND paymenttype = 'Bank Transfer' AND TransStatus='Payment'
    AND receiveAgentid IS NOT NULL 
    --AND bank.mapCodeInt IS NOT NULL
    GROUP BY bank.agentName, m.receiveAgentID
    ORDER BY rbankName
END



GO
