USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[remoteSP_tranStatusUpdate]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[remoteSP_tranStatusUpdate]
AS

SET XACT_ABORT ON
BEGIN
	BEGIN TRANSACTION
		IF EXISTS(SELECT TOP 1 'X' FROM rs_remitTranStatusUpdate WITH(NOLOCK))
		BEGIN
			SELECT rts.* INTO #tempData FROM rs_remitTranStatusUpdate rts WITH(NOLOCK)
			INNER JOIN dbo.remitTran rt WITH(NOLOCK) ON rts.controlNo = rt.controlNo
			
			UPDATE remitTran SET
				 tranStatus		= rs.tranStatus
			FROM remitTran rt
			INNER JOIN #tempData rs ON rt.controlNo = rs.controlNo

			DELETE FROM rs_remitTranStatusUpdate
			FROM rs_remitTranStatusUpdate rs
			INNER JOIN #tempData t ON rs.id = t.id
			
			DROP TABLE #tempData
		END
	COMMIT TRANSACTION
END


GO
