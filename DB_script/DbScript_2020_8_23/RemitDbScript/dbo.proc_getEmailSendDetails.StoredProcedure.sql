USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_getEmailSendDetails]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_getEmailSendDetails]
	 @user				VARCHAR(30) = null
	,@flag				VARCHAR(20) = null
	,@rowId				BIGINT = null
AS
BEGIN
SET NOCOUNT ON
SET XACT_ABORT ON
	IF @flag = 'get'
	BEGIN
		IF OBJECT_ID('tempdb..#TEMPQUELIST') IS NOT NULL
			DROP TABLE #TEMPQUELIST

		SELECT TOP 10 s.rowId, rt.SenderName, rt.createdBy, rt.collCurr, rt.payoutCurr, dbo.decryptDb(rt.controlNo) controlNoDec, rt.controlNo,
			rt.tAmt, rt.paymentMethod, rt.pcountry, 
			payountBankOrAgent = CASE WHEN rt.paymentMethod = 'CASH PAYMENT' THEN '[ANY WHERE]' ELSE rt.pBankName END,
			accNo = CASE WHEN rt.paymentMethod = 'CASH PAYMENT' THEN '[N/A]' ELSE rt.accountNo END,
			receiverName, pAmt
		INTO #TEMPQUELIST
		FROM tempTransactionMailQueue s (NOLOCK)
		INNER JOIN remitTran rt (NOLOCK) ON rt.controlNo = s.controlNo
		WHERE s.status = 'N'
		
		UPDATE s SET s.status = 'Y'
		FROM tempTransactionMailQueue s
		INNER JOIN #TEMPQUELIST t ON T.controlNo = s.controlNo

		SELECT * FROM #TEMPQUELIST
	END
	IF @flag = 'error'
	BEGIN
		UPDATE tempTransactionMailQueue SET status = 'N' where rowId = @rowId
	END
END


GO
