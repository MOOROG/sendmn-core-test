USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[Vw_GetAgentID]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Vw_GetAgentID]
AS

 SELECT '394680' agentId,'SendMN Online Branch'  agentName,'PayTxnFromMobile' SearchText union all
 SELECT '394679' agentId,'SendMN Money Transfer'  agentName,'SENDMNHQ' SearchText  union all --super agent
 SELECT '394685' agentId,'KHAN BANK'  agentName,'khankBank' SearchText  union all
 SELECT '394683' agentId,'Mongolia Main Branch'  agentName,'payBankHO' SearchText  union all  --Bank deposit Ho
 SELECT '394681' agentId,'GME-Korea Super Agent'  agentName,'koreaAgent' SearchText  union all
 SELECT '394702' agentId,'Tranglo Super Agent'  agentName,'trangloAgent' SearchText  union all
 SELECT '394705' agentId,'Ria Super Agent'  agentName,'riaAgent' SearchText  union all
SELECT 'MNT' agentId,'GME-Korea Super Agent'  agentName,'KoreaScBaseCurr' SearchText 



GO
