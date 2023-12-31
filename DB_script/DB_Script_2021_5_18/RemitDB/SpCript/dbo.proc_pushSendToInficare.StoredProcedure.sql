USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_pushSendToInficare]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_pushSendToInficare]
AS

IF EXISTS(SELECT TOP 1 'X' FROM domesticSendQueueList WITH(NOLOCK))
BEGIN
	DECLARE @controlNoList TABLE(controlNo VARCHAR(30), controlNoSwiftEnc VARCHAR(30), controlNoInficareEnc VARCHAR(30))
	INSERT INTO @controlNoList(controlNo, controlNoSwiftEnc, controlNoInficareEnc)
	SELECT controlNo, controlNoSwiftEnc, controlNoInficareEnc FROM domesticSendQueueList WITH(NOLOCK)
	
	INSERT hremit.dbo.moneySend(
		 refno
		,agentid
		,agentname
		,district_code
		,district_name
		,SenderName
		,SenderAddress,SenderPhoneno,SenderCity,SenderCountry
		,receiverPassport
		,ReceiverName
		,ReceiverAddress,ReceiverPhone,ReceiverCountry
		,DOT, DOtTime, paidAmt, paidCType, receiveAmt, receiveCType,SCharge
		,ReciverMessage
		,paymentType
		,rBankID
		,rBankName
		,rBankBranch
		,otherCharge
		,TransStatus, status, SEmpID
		,TotalRoundAmt,senderCommission,receivercommission
		,ext_commission, approve_by, confirmdate, local_dot
		,receiveAgentID, bank_id,bank_branch_name,bank_account_detail
		,digital_id_sender,id_type,id_no,email,relation,ReceiverCity
	)        
	SELECT 
		 refno = st.controlNoInficareEnc
		,agentid = sbm.mapCodeDom
		,agentname = CASE WHEN sbm.agentType = 2904 THEN sam.agentName ELSE adl.districtName END
		,district_code = sbm.agentLocation
		,district_name = sl.districtName
		,SenderName = UPPER(sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2, ''))
		,SenderAddress = sen.[address]
		,SenderPhoneno = COALESCE(sen.mobile, sen.homePhone, sen.workPhone)
		,SenderCity = sen.city
		,SenderCountry = sen.country
		,receiverPassport = rec.idNumber
		,ReceiverName = UPPER(rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, ''))
		,ReceiverAddress = rec.[address]
		,ReceiverPhone = COALESCE(sen.mobile, sen.homePhone, sen.workPhone)
		,ReceiverCountry = rec.country
		,DOT = rt.createdDate
		,DotTime = CONVERT(VARCHAR,rt.createdDate,108)
		,paidAmt = rt.cAmt
		,paidCType = 'NPR'
		,receiveAmt = rt.pAmt
		,receiveCType = 'NPR'
		,SCharge = rt.serviceCharge
		,ReciverMessage = rec.idType
		,paymentType = CASE WHEN rt.paymentMethod = 'Cash Payment' THEN 'Cash Pay' WHEN rt.paymentMethod = 'Bank Deposit' THEN 'Bank Transfer' END
		,rBankId = had.agentCode
		,rBankName = ISNULL(bank_name,adl.districtName)
		,rBankBranch = ISNULL(bbm.agentAddress,adl.districtName)
		,otherCharge = 0
		,TransStatus = 'Payment'
		,status = 'Un-Paid'
		,SEmpID = 'S:' + rt.createdBy
		,TotalRoundAmt = rt.pAmt
		,senderCommission = rt.sAgentComm
		,receiverCommission = rt.pAgentComm      
		,ext_commission = 0.00
		,approve_by = 'S:' + rt.createdBy
		,confirmdate = rt.createdDate
		,local_dot = rt.createdDate
		,receiveAgentID = rt.pLocation
		,bank_id = had.bank_id
		,bank_branch_name = rt.pBankName
		,bank_account_detail = rt.accountNo
		,digital_id_sender = 'swift_api'
		,id_type = sen.idType
		,id_no = sen.idNumber
		,email = sen.email
		,relation = rt.relWithSender
		,ReceiverCity = rec.city
	FROM remitTran rt WITH(NOLOCK)
	INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId
	INNER JOIN @controlNoList st ON rt.controlNo = st.controlNoSwiftEnc
	INNER JOIN agentMaster sbm WITH(NOLOCK) ON rt.sBranch = sbm.agentId
	INNER JOIN agentMaster sam WITH(NOLOCK) ON sbm.parentId = sam.agentId
	INNER JOIN api_districtList adl WITH(NOLOCK) ON rt.pLocation = adl.districtCode
	LEFT JOIN api_districtList sl WITH(NOLOCK) ON sbm.agentLocation = sl.districtCode
	LEFT JOIN agentMaster bm WITH(NOLOCK) ON rt.pBank = bm.agentId
	LEFT JOIN hremit.dbo.agentDetail had WITH(NOLOCK) ON bm.mapCodeDom = had.agentCode
	LEFT JOIN hremit.dbo.bank_detail bd WITH(NOLOCK) ON had.bank_id = bd.bank_id
	LEFT JOIN agentMaster bbm WITH(NOLOCK) ON rt.pBankBranch = bbm.agentId
	
	DELETE FROM domesticSendQueueList
	FROM domesticSendQueueList sl
	INNER JOIN @controlNoList cnl ON sl.controlNo = cnl.controlNo
END

GO
