USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwCustomerLastTxn]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create VIEW [dbo].[vwCustomerLastTxn]
AS
SELECT
	 customerId 
	,tranId = lastTranId
	,lastTxnDate		
FROM customers cth WITH(NOLOCK)
WHERE lastTxnDate > (GETDATE()-730)
GO
