USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[remoteSP_tranCancel]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[remoteSP_tranCancel]
AS

SET XACT_ABORT ON
BEGIN
	BEGIN TRANSACTION
		IF EXISTS(SELECT TOP 1 'X' FROM rs_remitTranCancel WITH(NOLOCK))
		BEGIN
			SELECT rtc.* INTO #tempData FROM rs_remitTranCancel rtc WITH(NOLOCK)
			INNER JOIN dbo.remitTran rt WITH(NOLOCK) ON rtc.controlNo = rt.controlNo
			
			UPDATE dbo.remitTran SET
				 tranStatus					= 'Cancel'
				,cancelApprovedBy			= rs.cancelBy
				,cancelApprovedDate			= rs.cancelDate
				,cancelApprovedDateLocal	= rs.cancelDate	
			FROM dbo.remitTran rt
			INNER JOIN #tempData rs ON rt.controlNo = rs.controlNo
			
			INSERT INTO tranModifyLog(controlNo, message, createdDate, createdBy)
			SELECT rs.controlNo, 'Transaction has been cancelled : ' + rs.cancelReason, rs.cancelDate, rs.cancelBy
			FROM #tempData rs WITH(NOLOCK)
			INNER JOIN dbo.remitTran rt WITH(NOLOCK) ON rt.controlNo = rs.controlNo
			
			DELETE FROM rs_remitTranCancel
			FROM rs_remitTranCancel rs
			INNER JOIN #tempData t ON rs.id = t.id
			
			DROP TABLE #tempData
		END
	COMMIT TRANSACTION
END

GO
