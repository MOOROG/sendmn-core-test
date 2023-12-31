USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwLuckyDrawNumbers]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwLuckyDrawNumbers]
AS
SELECT -- top 2
    controlNo
    ,isnull(TS.firstName,'') +' '+ isnull(TS.middleName,'') +' '+ isnull(TS.lastName1,'') as senderName
    ,isnull(TR.firstName,'') +' '+ isnull(TR.middleName,'') +' '+ isnull(TR.lastName1,'') as receiverName
	,tr.Address
    ,sCountry
	, pAgent = ISNULL(rt.pAgent, rt.pBank)
	, pAgentName =  ISNULL(pAgentName, pBankName)
	,am.agentAddress
FROM remitTran RT with (nolock) 
    JOIN tranSenders TS with (nolock) ON RT.id= TS.tranId
    JOIN tranReceivers TR with (nolock)  on RT.id = TR.tranId
	JOIN agentMaster am with(nolock) On ISNULL(rt.pAgent, rt.pBank) = am.agentId
WHERE rt.approvedDate between '2013-8-17' and '2013-10-17'
and payStatus ='Paid'
and tranType='I'
and left(controlNo,1)='R'
and LEN(controlNo)=11
GO
