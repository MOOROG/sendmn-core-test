USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_archiveTxns_step_delete]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_archiveTxns_step_delete]

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT CONVERT(VARCHAR, GETDATE(), 109)

BEGIN TRY

	-- SELECT count(*) FROM remitTran rta WITH(NOLOCK)	
	-- SELECT count(*) FROM FastMoneyPro_remit_Archive.dbo.remitTran rta WITH(NOLOCK)


	CREATE TABLE #archiveTxnQueue(t_id BIGINT UNIQUE, t_holdTranId BIGINT, t_controlNo VARCHAR(20))

	INSERT #archiveTxnQueue
	SELECT
		rt.id, rt.holdTranId, rt.controlNo 
	FROM FastMoneyPro_remit_Archive.dbo.remitTran rta WITH(NOLOCK)	
	INNER JOIN remitTran rt WITH(NOLOCK) ON rt.id = rta.id
	

	CREATE NONCLUSTERED INDEX atq_t_controlNo ON #archiveTxnQueue(t_controlNo) INCLUDE(t_holdTranId)


	BEGIN TRANSACTION
		EXEC proc_PrintLog 'Deleting... remitTran',NULL
		DELETE rt FROM remitTran rt INNER JOIN #archiveTxnQueue trt ON rt.id= trt.t_id
		EXEC proc_PrintLog 'Deleting... tranSenders',NULL
		DELETE rt FROM tranSenders rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... tranReceivers',NULL
		DELETE rt FROM tranReceivers rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... remitTranCompliance - id',NULL

		DELETE rt FROM remitTranCompliance rt INNER JOIN #archiveTxnQueue trt ON rt.tranId = trt.t_id
		EXEC proc_PrintLog 'Deleting... remitTranCompliance - holdTranId',NULL
		DELETE rt FROM remitTranCompliance rt INNER JOIN #archiveTxnQueue trt ON rt.tranId = trt.t_holdTranId
		EXEC proc_PrintLog 'Deleting... tranCancelrequest',NULL
		DELETE rt FROM tranCancelrequest rt	INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		--EXEC proc_PrintLog 'Deleting... tranModifyLog',NULL 
		--DELETE rt FROM tranModifyLog rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... tranViewHistory',NULL
		DELETE rt FROM tranViewHistory rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... cancelTranHistory',NULL
		DELETE rt FROM cancelTranHistory rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... cancelTranReceiversHistory',NULL
		DELETE rt FROM cancelTranReceiversHistory rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... cancelTranSendersHistory',NULL
		DELETE rt FROM cancelTranSendersHistory rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... errPaidTran',NULL
		DELETE rt FROM errPaidTran rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id
		EXEC proc_PrintLog 'Deleting... errPaidTranHistory',NULL
		DELETE rt FROM errPaidTranHistory rt INNER JOIN #archiveTxnQueue trt ON rt.tranId= trt.t_id 

	COMMIT TRANSACTION

	
	SELECT '0' errorCode, CAST((SELECT COUNT(*) FROM #archiveTxnQueue) AS VARCHAR) + ' Transaction(s) deleted successfully' msg, NULL id

END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT '1' rrrorCode, ERROR_MESSAGE() msg, NULL id

END CATCH








GO
