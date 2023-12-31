USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SCHEDULER_PUSH_TXN_VCBR]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PROC_SCHEDULER_PUSH_TXN_VCBR](
	 @flag VARCHAR(100) = NULL
	,@id		VARCHAR(100)= NULL
	,@ControlNo	VARCHAR(100)=NULL
)AS
BEGIN
	declare @pAgent int = 393229
	IF @flag='push-list-Vcbr'
	BEGIN
		SELECT TOP 30
			 SendTime=Rt.approvedDate
			,TxId=Rt.id
			,TxPin= dbo.FNADecryptString(Rt.controlNo)
			,SenderName=Rt.senderName
			,SenderPhoneNumber=TS.mobile
			,SenderAddress=TS.address
			,ReceiverName=RT.receivername
			,ReceiverDateOfBirth=TR.dob
			,ReceiverAddress=TR.address
			,ReceiveDistrict=Tr.district
			,ReceiveProvince=tr.state
			,ReceiverPhoneNumber=TR.mobile
			,SendAmount=RT.tAmt
			,SendCurrency='WON'
			,ExchangeRate=Rt.sCurrCostRate
			,ReceiveAmount=RT.pAmt
			,ReceiveCurrency=Rt.payoutCurr
			,ReceiveAmountText=NULL--'one lakh'
			,FeeAmount= ROUND(pagentcomm / (sCurrCostRate+sCurrHoMargin),2)
			,IdentificationType=TR.idType
			,IdentificationNumber=TR.idNumber
			,IdentificationIssuedDate=TR.issuedDate
			,IdentificationIssuedAddress=Tr.idPlaceOfIssue
			,ReceiverAccountNumber=RT.accountNo
			,ReceiveBank=Rt.pBankName
			,ReceiveBranch=Rt.pBankBranch
			,TxType=CASE WHEN RT.paymentMethod='BANK DEPOSIT' THEN 'AD' ELSE 'CP' END
			,BrachAddress=AM.agentAddress
			,MessageFromSender=NULL
			,MessageForAgent=NULL
			,AgentCode=NULL
			,TxIdByAgent=NULL
			,SendCountry='Korea'
			,ReceiveCountry=RT.pCountry
		FROM dbo.remitTran AS RT(NOLOCK) 
		INNER JOIN tranSenders TS (NOLOCK) ON TS.tranId = RT.id
		INNER JOIN tranReceivers TR (NOLOCK) ON TR.tranId = RT.id
		LEFT JOIN agentMaster AM (NOLOCK) ON AM.agentId = RT.pBank
		WHERE RT.approvedBy IS NOT NULL AND RT.payStatus ='Unpaid'
		AND RT.tranStatus = 'payment'
		AND RT.pAgent = @pAgent 
	END
	ELSE IF @flag='sync-list-Vcbr'
	BEGIN
		SELECT RT.id AS TranId,dbo.FNADecryptString(Rt.controlNo) AS controlNo FROM dbo.remitTran AS RT(NOLOCK) 
		WHERE RT.pAgent = @pAgent
		and RT.tranStatus='Payment' and RT.payStatus='Post'
	END
	ELSE IF @flag='mark-paid-Vcbr'
	BEGIN
		UPDATE remitTran 
			SET payStatus='Paid', tranStatus='Paid' 
			,paidDate = getdate()
			,paidDateLocal = GETUTCDATE()
			,paidBy='Scheduler'
		WHERE id = @id AND payStatus ='Post'
		AND tranStatus = 'payment' AND pAgent = @pAgent
		
		SELECT '0' ErrorCode,'Update success' Msg, NULL Id
	END
	ELSE IF @flag='mark-post-Vcbr'
	BEGIN
		UPDATE remitTran SET 
			 payStatus	= 'Post'
			,postedBy	= 'system'
			,postedDate	=GETDATE()
			,postedDateLocal=GETUTCDATE()
			,controlNo2=Dbo.FNAEncryptString(@ControlNo) 
			,ContNo = @ControlNo
		WHERE id = @id AND payStatus ='Unpaid'
		AND tranStatus = 'payment' AND pAgent = @pAgent 
		
		SELECT '0' ErrorCode,'Update success' Msg, NULL Id
	END
END


GO
