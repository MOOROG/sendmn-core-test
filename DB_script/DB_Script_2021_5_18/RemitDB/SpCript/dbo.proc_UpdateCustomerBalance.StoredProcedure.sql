USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_UpdateCustomerBalance]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_UpdateCustomerBalance]
(
	 @controlNo VARCHAR(20)=NULL,
	 @type VARCHAR(20)=NULL
)
AS 
BEGIN
IF(@type='deduct')
BEGIN
	UPDATE cm
	SET cm.availableBalance=ISNULL(cm.availableBalance,0) -rt.cAmt
	FROM dbo.vwRemitTran rt WITH (NOLOCK)
	INNER JOIN DBO.VWTRANSENDERS TS (NOLOCK) ON TS.TRANID = RT.ID
	INNER JOIN dbo.customerMaster cm ON TS.CUSTOMERID=cm.CUSTOMERID
	WHERE rt.controlNo=@controlNo
END
ELSE 
BEGIN
	UPDATE cm
	SET cm.availableBalance=ISNULL(cm.availableBalance,0) + rt.cAmt
	FROM dbo.vwRemitTran rt WITH (NOLOCK)
	INNER JOIN DBO.VWTRANSENDERS TS (NOLOCK) ON TS.TRANID = RT.ID
	INNER JOIN dbo.customerMaster cm ON TS.CUSTOMERID=cm.CUSTOMERID
	WHERE rt.controlNo=@controlNo
	END
END

GO
