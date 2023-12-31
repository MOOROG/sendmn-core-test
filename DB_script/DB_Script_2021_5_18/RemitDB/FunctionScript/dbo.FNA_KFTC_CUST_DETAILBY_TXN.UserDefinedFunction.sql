USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNA_KFTC_CUST_DETAILBY_TXN]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNA_KFTC_CUST_DETAILBY_TXN] (@TxnId BIGINT)  
returns @list TABLE (tranId BIGINT, bankCodeStd VARCHAR(5), bankName NVARCHAR(100), accountNum VARCHAR(30),accountName NVARCHAR(100),Narration NVARCHAR(500))
as
BEGIN

	DECLARE @HoldTxnId BIGINT 
	SELECT @HoldTxnId = HoldTranId FROM remitTran(NOLOCK) WHERE ID = @TxnId

	INSERT INTO @list
	SELECT M.tranId,C.bankCodeStd,B.bankName,C.accountNum,C.accountName 
			,Narration = ' Autodebit Txn Acc No : '+C.accountNum+' /Bank Name : '+B.BankName
	FROM KFTC_CUSTOMER_TRANSFER(nolock)M
	INNER JOIN KFTC_CUSTOMER_SUB C (NOLOCK) ON C.fintechUseNo = M.fintechUseNo
	LEFT JOIN KoreanBankList(nolock) B ON B.bankCode = C.bankCodeStd
	WHERE tranId = @HoldTxnId
	RETURN
END

--SELECT * FROM DBO.[FNA_KFTC_CUST_DETAILBY_TXN](100305649)
GO
