USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerTxnHistory]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_customerTxnHistory]
	 @controlNo		VARCHAR(30)	= NULL
	,@date			DATETIME	= NULL
	,@fromDate		VARCHAR(50)	= NULL
	,@toDate		VARCHAR(50)	= NULL
AS
BEGIN
	
	IF @controlNo IS NOT NULL
	BEGIN
		IF EXISTS(SELECT 'X' FROM customerTxnHistory WITH(NOLOCK) WHERE refno = @controlNo)
			RETURN
		INSERT INTO customerTxnHistory
			(
				 Tranno
				,refno
				,senderFax
				,senderPassport
				,SenderName
				,sender_mobile 
				,SenderAddress
				,SenderCountry
				,customerId
				,receiverIDDescription
				,receiverID 
				,receiverName
				,ReceiverPhone
				,receiver_mobile
				,ReceiverAddress
				,ReceiverCity
				,ReceiverCountry
				,rBankACNo
				,rBankName
				,rBankBranch 
				,rBankID
				,ben_bank_id
				,ben_bank_name
				,rBankAcType
				,receiveAgentID
				,expected_payoutagentid
				,paymentType
				,paidAmt
				,confirmDate
				,paidCType
				,receiveCType
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,pBank
				,pBankName
				,pBankBranch
				,pBankBranchName
			)

			SELECT 
				 Tranno = rt.id
				,refno = controlNo
				,senderFax = sen.idType
				,senderPassport = sen.idNumber
				,SenderName = rt.senderName
				,sender_mobile = sen.mobile 
				,SenderAddress = sen.address
				,SenderCountry = rt.sCountry
				,customerId = sen.customerId
				,receiverIDDescription = rec.idType
				,receiverID = rec.idNumber 
				,receiverName = rt.receiverName
				,ReceiverPhone = rec.homePhone
				,receiver_mobile = rec.mobile
				,ReceiverAddress = rec.address
				,ReceiverCity = rec.city
				,ReceiverCountry = rt.pCountry
				,rBankACNo = rt.accountNo
				,rBankName = rt.pAgentName
				,rBankBranch = rt.pBranchName 
				,rBankID = rt.pBranch
				,ben_bank_id = rt.externalBankCode
				,ben_bank_name = rt.pBankName
				,rBankAcType = rt.pBankBranchName
				,receiveAgentID = rt.pAgent
				,expected_payoutagentid = rt.pAgent
				,paymentType = rt.paymentMethod
				,paidAmt = cAmt
				,confirmDate = approvedDate
				,paidCType = collCurr
				,receiveCType = payoutCurr
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,pBank
				,pBankName
				,pBankBranch
				,pBankBranchName
		   FROM vwRemitTran rt WITH(NOLOCK)
		   INNER JOIN vwTranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		   INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		   WHERE controlNo = @controlNo 
	END
	ELSE
	BEGIN
		IF @fromDate IS NULL AND @toDate IS NULL AND @date IS NULL
		BEGIN
			SET @fromDate = CONVERT(varchar(20), GETDATE()-1, 101)
			SET @toDate = CONVERT(varchar(20), GETDATE()-1, 101) + ' 23:59:59:998'
		END
		   
		ELSE IF @date IS NOT NULL
		BEGIN
			SET @fromDate = CONVERT(VARCHAR, @date, 101)
			SET @toDate = CONVERT(VARCHAR, @date, 101) + ' 23:59:59:998'
		END
		   
		   --SELECT @fromDate, @toDate
			IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
				DROP TABLE #temp1
			SELECT 
				 Tranno = rt.id
				,refno = controlNo
				,senderFax = sen.idType
				,senderPassport = sen.idNumber
				,SenderName = rt.senderName
				,sender_mobile = sen.mobile 
				,SenderAddress = sen.address
				,SenderCountry = rt.sCountry
				,customerId = sen.customerId
				,receiverIDDescription = rec.idType
				,receiverID = rec.idNumber 
				,receiverName = rt.receiverName
				,ReceiverPhone = rec.homePhone
				,receiver_mobile = rec.mobile
				,ReceiverAddress = rec.address
				,ReceiverCity = rec.city
				,ReceiverCountry = rt.pCountry
				,rBankACNo = rt.accountNo
				,rBankName = rt.pAgentName
				,rBankBranch = rt.pBranchName 
				,rBankID = rt.pBranch
				,ben_bank_id = rt.externalBankCode
				,ben_bank_name = rt.pBankName
				,rBankAcType = rt.pBankBranchName
				,receiveAgentID = rt.pAgent
				,expected_payoutagentid = rt.pAgent
				,paymentType = rt.paymentMethod
				,paidAmt = cAmt
				,confirmDate = approvedDate
				,paidCType = collCurr
				,receiveCType = payoutCurr
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,pBank
				,pBankName
				,pBankBranch
				,pBankBranchName
		   INTO #TEMP1
		   FROM remitTran rt WITH(NOLOCK)
		   INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
		   INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
		   WHERE 1=1 AND tranType = 'I'
		   --AND SenderCountry ='Malaysia'
		   AND createdDate >= @fromDate


		   DELETE T 
		   FROM #TEMP1 T, customerTxnHistory C
		   WHERE T.refno = C.refno
		   

			INSERT INTO customerTxnHistory
			(
				 Tranno
				,refno
				,senderFax
				,senderPassport
				,SenderName
				,sender_mobile 
				,SenderAddress
				,SenderCountry
				,customerId
				,receiverIDDescription
				,receiverID 
				,receiverName
				,ReceiverPhone
				,receiver_mobile
				,ReceiverAddress
				,ReceiverCity
				,ReceiverCountry
				,rBankACNo
				,rBankName
				,rBankBranch 
				,rBankID
				,ben_bank_id
				,ben_bank_name
				,rBankAcType
				,receiveAgentID
				,expected_payoutagentid
				,paymentType
				,paidAmt
				,confirmDate
				,paidCType
				,receiveCType
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,pBank
				,pBankName
				,pBankBranch
				,pBankBranchName
			)

			SELECT 
				 Tranno
				,refno
				,senderFax
				,senderPassport
				,SenderName
				,sender_mobile 
				,SenderAddress
				,SenderCountry
				,customerId
				,receiverIDDescription
				,receiverID 
				,receiverName
				,ReceiverPhone
				,receiver_mobile
				,ReceiverAddress
				,ReceiverCity
				,ReceiverCountry
				,rBankACNo
				,rBankName
				,rBankBranch 
				,rBankID
				,ben_bank_id
				,ben_bank_name
				,rBankAcType
				,receiveAgentID
				,expected_payoutagentid
				,paymentType
				,paidAmt
				,confirmDate
				,paidCType
				,receiveCType
				,pAgent
				,pAgentName
				,pBranch
				,pBranchName
				,pBank
				,pBankName
				,pBankBranch
				,pBankBranchName
		   FROM #TEMP1
	END
END

GO
