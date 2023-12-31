USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SyncDomTxnStatus]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[PROC_SyncDomTxnStatus]
@FLAG CHAR(1)
AS
SET NOCOUNT ON

DECLARE @list TABLE(controlNo VARCHAR(20) PRIMARY KEY, PayStatus VARCHAR(40), TranStatus VARCHAR(40), cancelDate DATETIME, cancelBy VARCHAR(50))

IF @FLAG = 'C'
BEGIN
	INSERT @list
	SELECT 
		controlNo, payStatus, tranStatus, cancelApprovedDate, cancelApprovedBy
	FROM SendMnPro_Remit.dbo.remitTran  rt (NOLOCK)
	INNER JOIN [REMIT_TRN_LOCAL] rtl (NOLOCK) ON rt.controlNo = rtl.TRN_REF_NO
	WHERE tranStatus = 'Cancel' and rtl.CANCEL_USER IS NULL
	
	UPDATE rtl SET
		CANCEL_USER = l.cancelBy
		,CANCEL_DATE = l.cancelDate
		,PAY_STATUS  = 'Un-Paid'
		,TRN_STATUS  = 'Cancel'
	FROM [REMIT_TRN_LOCAL] rtl
	INNER JOIN @list l on rtl.TRN_REF_NO = l.controlNo

print 'cancel transaction synchronization completed'

END  
GO
