USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[remoteSP_routeTroubleTicket]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[remoteSP_routeTroubleTicket]
AS

SET XACT_ABORT ON
BEGIN
	BEGIN TRANSACTION
		IF EXISTS(SELECT TOP 1 'X' FROM rs_remitTranTroubleTicket WITH(NOLOCK) WHERE category IS NULL)
		BEGIN
			SELECT rs.* INTO #tempData FROM rs_remitTranTroubleTicket rs WITH(NOLOCK)
			INNER JOIN remitTran rt WITH(NOLOCK) ON rs.refno = rt.controlNo
			WHERE rs.category IS NULL
			
			INSERT INTO tranModifyLog(controlNo, message, createdDate, createdBy)
			SELECT rs.refno, Comments, DatePosted, PostedBy
			FROM #tempData rs WITH(NOLOCK)
			
			DELETE FROM rs_remitTranTroubleTicket
			FROM rs_remitTranTroubleTicket rs
			INNER JOIN #tempData t ON rs.id = t.id
			
			DROP TABLE #tempData
		END
	COMMIT TRANSACTION
END


GO
