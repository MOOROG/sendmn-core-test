USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SCHEDULAR_PUSH_TXN_BNI]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PROC_SCHEDULAR_PUSH_TXN_BNI](
	 @flag VARCHAR(100) = NULL
	,@id		VARCHAR(100)= NULL
)AS
BEGIN
	IF @flag='push-list-bni'
	BEGIN
		 SELECT TOP 10 
			refNumber		= dbo.FNADecryptString(RT.controlNo)
			,serviceType	= CASE WHEN RT.pBank = 393369 THEN 'BNI' --##PT. BANK NEGARA INDONESIA (PERSERO),TBK
								WHEN RT.pBank <> 393369 AND RT.pAmt BETWEEN 0 AND 25000000 THEN 'INTERBANK'
								WHEN RT.pBank <> 393369 AND RT.pAmt BETWEEN 25000000 AND 500000000 THEN 'CLR'
								WHEN RT.pBank <> 393369 AND RT.pAmt > 500000000 THEN 'RTGS'
							END
			,trxDate		= FORMAT(RT.approvedDate,'yyyy-MM-ddTHH:mm:ss')
			,currency		= RT.payoutCurr
			,amount			= RT.pAmt
			,orderingName	= RT.senderName 
			,orderingAddress1 = LEFT(TS.ADDRESS,50)
			,orderingAddress2 = TS.ADDRESS2
			,orderingPhoneNumber = TS.mobile 
			,beneficiaryAccount = RT.accountNo
			,beneficiaryName = RT.receiverName
			,beneficiaryAddress1 = TR.ADDRESS
			,beneficiaryAddress2 = TR.ADDRESS2
			,beneficiaryPhoneNumber = TR.mobile
			,acctWithInstcode = 'A'
			,acctWithInstName = CASE WHEN RT.pBank = 393369 THEN AM.routingCode + 'XXX' --##PT. BANK NEGARA INDONESIA (PERSERO),TBK
									WHEN RT.pBank <> 393369 AND RT.pAmt BETWEEN 0 AND 25000000 THEN AM.agentCode
									WHEN RT.pBank <> 393369 AND RT.pAmt BETWEEN 25000000 AND 500000000 THEN AM.routingCode
									WHEN RT.pBank <> 393369 AND RT.pAmt > 500000000 THEN AM.routingCode
								END
			,acctWithInstAddress1 = ''
			,acctWithInstAddress2 = ''
			,acctWithInstAddress3 = ''
			,detailPayment1 = ''
			,detailPayment2 = ''
			,detailCharges = 'OUR'
			,RT.ID
		FROM dbo.remitTran AS [RT] (NOLOCK)
		INNER JOIN tranSenders AS [TS] (NOLOCK) ON TS.TRANID = RT.ID
		INNER JOIN tranReceivers AS [TR] (NOLOCK) ON TR.TRANID = RT.ID
		INNER JOIN agentMaster AS [AM] (NOLOCK) ON AM.agentId = RT.pBank
		WHERE RT.pCountry = 'Indonesia'
		AND	RT.payStatus = 'Unpaid'	AND RT.tranStatus = 'Payment'
		AND RT.pAgent = 392227
		ORDER BY RT.ID 
	END
	ELSE IF @flag='sync-list-Bni'
	BEGIN
		--SELECT TOP 1 '1234' AS TranId,'1234' AS refNumber,GETDATE() AS trxDate FROM dbo.remitTran AS RT(NOLOCK)
		SELECT 
			refNumber	= dbo.FNADecryptString(RT.controlNo)
			,trxDate	= FORMAT(RT.approvedDate,'yyyy-MM-dd-THH:mm:ss')
		FROM dbo.remitTran AS RT(NOLOCK)		
		WHERE RT.pCountry = 'Indonesia'
		AND RT.payStatus = 'Post'
		AND RT.tranStatus = 'Payment'
		AND RT.pAgent = 392227	
	END
	ELSE IF @flag='mark-paid-bni'
	BEGIN
		UPDATE remitTran SET 
			payStatus		=	'Paid'
			,tranStatus		=	'Paid' 
			,paidBy			=	'system'
			,paidDate		=	GETDATE()
			,paidDateLocal	=	GETUTCDATE()
		WHERE Id=@id and pAgent = 392227 and payStatus = 'Post' AND tranStatus = 'Payment'
	END
	ELSE IF @flag='mark-post-bni'
	BEGIN
		UPDATE remitTran SET 
		payStatus		=	'Post'
		,postedBy		=	'Scheduler'
		,postedDate		=	GETDATE()
		,postedDateLocal=	GETUTCDATE()  
		WHERE Id = @id and pAgent = 392227 and payStatus = 'Unpaid' AND tranStatus = 'Payment'
	END
END
GO
