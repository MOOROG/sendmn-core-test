USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vWAgentClrBal]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vWAgentClrBal]
AS

    SELECT map_code = a.map_code, AGENT_IME_CODE = a.agent_Id, clr_bal_amt
		, ISNULL(l.todaysSent,0) todaysSend,  ISNULL(l.todaysPaid,0) todaysPaid
	     , ISNULL(l.todaysCancelled,0) todaysCancel
		,ISNULL(l.todaysEPI,0) todaysEPI ,ISNULL(l.todaysPOI,0) todaysPOI 
		,0 todaysEPD  ,0 todaysPOD
	   FROM FastMoneyPro_account.dbo.agentTable a WITH (NOLOCK) 
	   inner join FastMoneyPro_account.dbo.ac_master c WITH (NOLOCK) on a.agent_Id = c.agent_id
	   inner join FastMoneyPro_remit.dbo.creditlimit l WITH (NOLOCK) on a.map_code = l.agentid
    WHERE a.agent_Id = c.agent_id AND acct_rpt_code ='20'

GO
