USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[remoteSP_tranModify]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[remoteSP_tranModify]
AS

SET XACT_ABORT ON
BEGIN
	BEGIN TRANSACTION
		IF EXISTS(SELECT TOP 1 'X' FROM rs_remitTranModify WITH(NOLOCK))
		BEGIN
			SELECT rtm.* INTO #tempData FROM rs_remitTranModify rtm WITH(NOLOCK)
			INNER JOIN remitTran rt WITH(NOLOCK) ON rtm.controlNo = rt.controlNo
			
			UPDATE remitTran SET
				 senderName				= CASE WHEN rs.modifyField = 'senderName' THEN rs.newValue ELSE SenderName END
				,receiverName			= CASE WHEN rs.modifyField = 'receiverName' THEN rs.newValue ELSE ReceiverName END
				,accountNo				= CASE WHEN rs.modifyField = 'accountNo' THEN rs.newValue ELSE accountNo END
				,pBankBranchName		= CASE WHEN rs.modifyField = 'branchname' THEN rs.newValue ELSE pBankBranchName END
			FROM remitTran rt
			INNER JOIN #tempData rs ON rt.controlNo = rs.controlNo
			
			IF EXISTS(SELECT 'X' FROM #tempData WHERE modifyField IN ('senderName','sAddress'))
			BEGIN
				UPDATE tranSenders SET
					 firstName			= (SELECT firstName FROM dbo.FNASplitName(rs.newValue))
					,middleName			= (SELECT middleName FROM dbo.FNASplitName(rs.newValue))
					,lastName1			= (SELECT lastName1 FROM dbo.FNASplitName(rs.newValue))
					,lastName2			= (SELECT lastName2 FROM dbo.FNASplitName(rs.newValue))
					,fullName			= rs.newValue
				FROM tranSenders sen
				INNER JOIN remitTran rt ON sen.tranId = rt.id
				INNER JOIN #tempData rs ON rt.controlNo = rs.controlNo
				WHERE modifyField IN ('senderName')
				
				UPDATE tranSenders SET
					 address			= CASE WHEN rs.modifyField = 'sAddress' THEN rs.newValue ELSE address END
				FROM tranSenders sen
				INNER JOIN remitTran rt ON sen.tranId = rt.id
				INNER JOIN #tempData rs ON rt.controlNo = rs.controlNo
				WHERE modifyField IN ('sAddress')
			END
			
			IF EXISTS(SELECT 'X' FROM #tempData WHERE modifyField IN ('receiverName','rAddress','rIdType','rIdNo','rContactNo'))
			BEGIN
				UPDATE tranReceivers SET
					 firstName			= (SELECT firstName FROM dbo.FNASplitName(rs.newValue))
					,middleName			= (SELECT middleName FROM dbo.FNASplitName(rs.newValue))
					,lastName1			= (SELECT lastName1 FROM dbo.FNASplitName(rs.newValue))
					,lastName2			= (SELECT lastName2 FROM dbo.FNASplitName(rs.newValue))
					,fullName			= rs.newValue
				FROM tranReceivers rec
				INNER JOIN remitTran rt ON rec.tranId = rt.id
				INNER JOIN #tempData rs ON rt.controlNo = rs.controlNo
				WHERE modifyField IN ('receiverName')
				
				UPDATE tranReceivers SET
					 address			= CASE WHEN rs.modifyField = 'rAddress' THEN rs.newValue ELSE address END
					,idType				= CASE WHEN rs.modifyField = 'rIdType' THEN rs.newValue ELSE idType END
					,idNumber			= CASE WHEN rs.modifyField = 'rIdNo' THEN rs.newValue ELSE idNumber END
					,homePhone			= CASE WHEN rs.modifyField = 'rContactNo' THEN rs.newValue ELSE homePhone END
				FROM tranReceivers rec
				INNER JOIN remitTran rt ON rec.tranId = rt.id
				INNER JOIN #tempData rs ON rt.controlNo = rs.controlNo
				WHERE modifyField IN ('rAddress','rIdType','rIdNo','rContactNo')
			END
			
			DELETE FROM rs_remitTranModify
			FROM rs_remitTranModify rs
			INNER JOIN #tempData t ON rs.id = t.id
			
			DROP TABLE #tempData
		END
	COMMIT TRANSACTION
END



GO
