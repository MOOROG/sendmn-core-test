USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwBankDepositFromISO]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwBankDepositFromISO]
AS
SELECT
	rt.controlNo, rt.id, iso.status
FROM remitTran rt (NOLOCK)
INNER JOIN acDepositQueueIso iso (NOLOCK) ON rt.id = iso.tranId 
WHERE rt.paidDate IS NOT NULL 
AND rt.cancelApprovedDate IS NULL
AND iso.status = 'Success'


GO
