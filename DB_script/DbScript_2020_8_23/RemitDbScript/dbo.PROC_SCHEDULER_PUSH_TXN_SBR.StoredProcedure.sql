USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SCHEDULER_PUSH_TXN_SBR]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PROC_SCHEDULER_PUSH_TXN_SBR](
	 @flag		VARCHAR(100)	=	NULL
	,@id		VARCHAR(100)	=	NULL
	,@ControlNo	VARCHAR(100)	=	NULL
)AS
BEGIN
     DECLARE @pAgent INT = 393862
	IF @flag='push-list-Sbr'
	BEGIN
		SELECT TOP 10
		 dbo.FNADecryptString(RT.controlNo) AS Reference
		,CASE WHEN RT.paymentMethod='Bank Deposit' THEN '3' 
			  WHEN RT.paymentMethod='Home Delivery' THEN '1'
			  WHEN rt.paymentMethod='Cash Payment' THEN '2'
			  ELSE NULL
			  END AS DelMode
		,NULL AS SubAgentID
		,NULL AS PINNo
		,'USD' AS CurrencyID
		,RT.pAmt AS OrderedAmt
		,RT.receiverName AS Beneficiary
		,NULL AS Beneficiary2
		,TR.mobile AS Phone
		,TR.idNumber AS IDCardNo
		,TR.issuedDate AS IssuedOn
		,'Government' AS IssuedBy
		,TR.address AS Address
		,NULL AS ProvinceID
		,NULL AS DistrictID
		,RT.senderName AS Sender
		,TS.mobile AS SenderPhone
		,TS.address AS SenderAddress
		,TS.country AS SenderCountryID
		,NULL AS Message
		,NULL AS BankGroup
		,CASE WHEN RT.paymentMethod='Bank Deposit' THEN RT.accountNo ELSE NULL END AS BankAcctNo
		,CASE WHEN RT.paymentMethod='Bank Deposit' THEN RT.pBankName ELSE NULL END AS BankName
		FROM dbo.remitTran AS RT(NOLOCK) 
		INNER JOIN tranSenders TS (NOLOCK) ON TS.tranId = RT.id
		INNER JOIN tranReceivers TR (NOLOCK) ON TR.tranId = RT.id
		LEFT JOIN agentMaster AM (NOLOCK) ON AM.agentId = RT.pBank
		WHERE RT.approvedBy IS NOT NULL AND RT.payStatus = 'Unpaid'
		AND RT.tranStatus = 'payment'
		AND RT.pAgent = @pAgent
	END
	ELSE IF @flag='sync-list-Sbr'
	BEGIN
		SELECT RT.id AS TranId,dbo.FNADecryptString(RT.controlNo) AS TxPin FROM dbo.remitTran AS RT(NOLOCK) 
		WHERE RT.pAgent = @pAgent 
		AND RT.tranStatus = 'Payment' AND RT.payStatus='Post'
	END
	ELSE IF @flag='mark-paid-Sbr'
	BEGIN
		UPDATE remitTran SET payStatus='Paid', tranStatus = 'Paid' WHERE Id = @id AND pAgent = @pAgent 
		
		SELECT '0' ErrorCode,'Update success' Msg, NULL Id
	END
	ELSE IF @flag='mark-post-Sbr'
	BEGIN
		UPDATE remitTran SET 
			 payStatus='Post'
			,postedBy='system'
			,postedDate=GETDATE()
			,postedDateLocal=GETUTCDATE()
			,controlNo2=Dbo.FNAEncryptString(@ControlNo) 
			,ContNo = @ControlNo
		WHERE controlNo = dbo.FNAEncryptString(@id)
		AND pAgent = @pAgent 
		
		SELECT '0' ErrorCode,'Update success' Msg, NULL Id
	END
END




GO
