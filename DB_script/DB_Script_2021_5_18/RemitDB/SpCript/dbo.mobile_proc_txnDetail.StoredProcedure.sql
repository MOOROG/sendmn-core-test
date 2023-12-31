USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_txnDetail]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[mobile_proc_txnDetail](
 @flag					VARCHAR(100)=NULL
,@User					VARCHAR(100)=NULL
,@SenderId				VARCHAR(100)=NULL
,@ReceiverId			VARCHAR(100)=NULL
,@DeliveryMethodId		VARCHAR(100)=NULL
,@PBranch 				VARCHAR(100)=NULL
,@PAgent 				VARCHAR(100)=NULL
,@PCurr					VARCHAR(100)=NULL
,@CollCurr				VARCHAR(100)=NULL
,@CollAmt				VARCHAR(100)=NULL
,@PayoutAmt				VARCHAR(100)=NULL
,@TransferAmt			VARCHAR(100)=NULL
,@ServiceCharge			VARCHAR(100)=NULL
,@Discount				VARCHAR(100)=NULL
,@ExRate				VARCHAR(100)=NULL
,@CalBy					VARCHAR(100)=NULL
,@PurposeOfRemittance	VARCHAR(100)=NULL
,@SourceOfFund			VARCHAR(100)=NULL
,@Occupation       		VARCHAR(100)=NULL
,@RelWithSender			VARCHAR(100)=NULL
,@IpAddress        		VARCHAR(100)=NULL
,@RState				VARCHAR(100)=NULL
,@RLocation 			VARCHAR(100)=NULL
,@TpExRate				VARCHAR(100)=NULL
,@TpPCurr				VARCHAR(100)=NULL
,@PayOutPartner			VARCHAR(100)=NULL
,@FOREX_SESSION_ID		VARCHAR(100)=NULL
,@KftcLogId				VARCHAR(100)=NULL
,@PaymentType			VARCHAR(100)=NULL
,@IsAgreed				VARCHAR(100)=NULL
,@TxnPassword			VARCHAR(100)=NULL
,@ProcessId				VARCHAR(100)=NULL
,@ReceiverAccountNo		VARCHAR(100)=NULL
,@controlNo				VARCHAR(30) =NULL
,@tranId                BIGINT      =NULL
,@Message				VARCHAR(200)=NULL

)AS
BEGIN
	IF @flag='detail'
	BEGIN

		DECLARE @ErrorCode VARCHAR(10)='0',@Msg VARCHAR(100)='Success'

		IF NOT EXISTS(SELECT 'x' FROM dbo.customerMaster (NOLOCK)AS CM 
			WHERE CM.customerId = @SenderId AND CM.customerPassword = dbo.FNAEncryptString(@TxnPassword)
			AND Email = @User
			)
		BEGIN
			SET @ErrorCode='1'
			SET @Msg='Invalid transaction password'			 	
		END


		IF ISNULL(@IsAgreed,'False') = 'False'
		BEGIN
			SET @ErrorCode='1'
			SET @Msg='Please agree term and condition.'			 	
		END

		IF OBJECT_ID('tempdb..#sender') IS NOT NULL
			DROP TABLE #sender

		IF OBJECT_ID('tempdb..#receiver') IS NOT NULL
			DROP TABLE #receiver


		SELECT TOP 1 
			 CM.firstName as SenderFirstName
			,CM.middleName as SenderMiddleName
			,CM.lastName1 as SenderLastName1
			,CM.lastName2 as SenderLastName2
			,CM.idExpiryDate as SenderIdExpiryDate
			,CM.occupation as SenderOccuption
			,CM.dob as SenderBirthDate
			,CM.email as SenderEmail
			,CM.city as SenderCity
			,CM.postalCode as SenderPostalCode
			,CM.nativeCountry as SenderNativeCountry
			,(SELECT TOP 1 SDV.detailTitle FROM dbo.staticDataValue (NOLOCK)AS SDV WHERE SDV.valueId=CM.idType) as SenderIdType
			,CM.idNumber as SenderIdNo
			,CM.mobile as SenderMobile
			,CM.address as SenderAddress
			,CM.sourceOfFund
			,'1' AS SS
		INTO #sender
		FROM dbo.customerMaster(NOLOCK) AS CM 
		WHERE CM.customerId = @SenderId


		SELECT TOP 1
			ReceiverFullName = RI.firstName + ISNULL(' '+RI.middleName,'')+ ISNULL(' '+RI.lastName1,'')
			,RI.firstName  AS ReceiverFirstName
			,RI.middleName as ReceiverMiddleName
			,RI.lastName1 as ReceiverLastName
			,'' as ReceiverIdType
			,'' as ReceiverIdNo
			,'' as ReceiverIdValid
			,'' as ReceiverDob
			,RI.homePhone as ReceiverTel
			,RI.mobile as ReceiverMobile
			,RI.country as ReceiverNativeCountry
			,RI.city as ReceiverCity
			,RI.address as ReceiverAdd1
			,RI.email as ReceiverEmail
			,@ReceiverAccountNo AS ReceiverAccountNo
			,CM.countryName as ReceiverCountry
			,CM.countryId as ReceiverCountryId
			,RI.state AS RState
			,RI.state AS RStateText
			,RI.district AS RLocation
			,RI.district AS RLocationText
			,'1' AS RR
		INTO #receiver
		FROM dbo.receiverInformation(NOLOCK) AS RI 
		INNER JOIN dbo.countryMaster(NOLOCK) AS CM ON RI.country=CM.countryName
		WHERE RI.receiverId = @ReceiverId
		AND RI.customerId = @SenderId

		DECLARE @PBranchName VARCHAR(100),@PAgentName VARCHAR(100)

		SELECT @PBranchName = AM.agentName FROM dbo.agentMaster(NOLOCK) AS AM WHERE AM.agentId = @PBranch
		SELECT @PAgentName = AM.agentName FROM dbo.agentMaster(NOLOCK) AS AM WHERE AM.agentId = @PAgent

		--SELECT * FROM #sender AS S
		--SELECT * FROM #receiver AS R


		SELECT 
		 @ErrorCode AS ErrorCode
		,@Msg AS Msg
		,@User as [User]
		,@SenderId as SenderId
		,S.*
		,@ReceiverId as ReceiverId
		,R.*
		,DeliveryMethod = (select typeTitle from serviceTypeMaster(nolock) where serviceTypeId = @DeliveryMethodId)
		,@DeliveryMethodId as DeliveryMethodId
		,@PBranch as PBranch
		,@PBranchName as PBranchName
		,'' as PBranchCity
		,@PAgent as PAgent
		,@PAgentName as PAgentName
		,'M' as PBankType
		,@PCurr as PCurr
		,@CollCurr as CollCurr
		,@CollAmt as CollAmt
		,@PayoutAmt as PayoutAmt
		,@TransferAmt as TransferAmt
		,@ServiceCharge as ServiceCharge
		,@Discount as Discount
		,@ExRate as ExRate
		,@CalBy as CalBy
		,@PurposeOfRemittance as PurposeOfRemittance
		,S.sourceOfFund
		,(SELECT TOP 1 SDV.detailTitle FROM dbo.staticDataValue(nolock) AS SDV WHERE SDV.valueId=@RelWithSender) as RelWithSender
		,@Occupation as Occupation
		,'' as PayoutMsg
		,'2080' as SendingAgent
		,'GME Online' as SendingAgentName
		,'1008' as SendingSuperAgent
		,@IpAddress as IpAddress
		,'118' as SCountryId
		,'South Korea' as SenderCountry
		,'' as AgentRefId		
		,'2080' as SBranch		
		,@TpExRate as TpExRate
		,@TpPCurr as TpPCurr
		,'' as TpRefNo
		,'' as TpTranId
		,@PayOutPartner as PayOutPartner
		,@FOREX_SESSION_ID as FOREX_SESSION_ID
		,@KftcLogId as KftcLogId
		,@PaymentType as PaymentType
		,@ProcessId as ProcessId
		,'' as DepositMode		
		FROM  #sender AS S INNER JOIN #receiver AS R	ON R.RR=S.SS	
	END

	ELSE IF @flag='track-transaction'
	BEGIN
		DECLARE @payStatus VARCHAR(100);
		IF NOT EXISTS(SELECT 'x' FROM dbo.remitTran(NOLOCK) rt WHERE rt.controlNo=dbo.FNAEncryptString(@controlNo))
		BEGIN
			SELECT '1' ErrorCode, 'Control No Not Found' Msg, NULL Id	
			RETURN
		END
		--@payStatus=	CASE WHEN (rt.payStatus='Unpaid' AND rt.transtatus='Payment') THEN 'In Send Queue'
		--						 WHEN (rt.payStatus = 'Post' AND rt.tranStatus = 'Payment') THEN 'Ready for Payment' 
		--						 WHEN (rt.payStatus='Unpaid' AND rt.transtatus='Hold') THEN 'Waiting for Approval'
		--						 WHEN (rt.payStatus='Unpaid' AND rt.transtatus='Compliance Hold') THEN 'Waiting for Approval' 
		--						 ELSE rt.payStatus 
		--						 END
		SELECT 
			 errorCode='0'
			,payStatus=rt.payStatus
			,bank=rt.pBankName
			,branch=rt.pBankBranchName
			,AccountNo=rt.accountNo
			,Receiver=rt.receiverName
			,SendDate=CONVERT(VARCHAR(10),rt.createdDate,120)
			,CollAmt=CAST(rt.cAmt AS DECIMAL)
			,PayAmount=rt.pAmt
		FROM remittran(NOLOCK) rt
		WHERE dbo.FNAEncryptString(@controlNo)=rt.controlNo

	END

	ELSE IF	@flag='amend-transaction'
	BEGIN
		SET @controlNo = dbo.FNAEncryptString(@controlNo)
		IF NOT EXISTS(SELECT 'x' FROM dbo.remitTran(NOLOCK) rt WHERE rt.controlNo = @controlNo AND rt.id = @tranId)
		BEGIN
			SELECT '1' ErrorCode, 'Wrong Control No/TransactionId.' Msg, NULL Id	
			RETURN	
		END

		INSERT INTO tranModifyLog(tranId,controlNo,[message],createdBy,createdDate,MsgType,[status]	)
		SELECT @tranId,@controlNo,@message,@user,GETDATE(),'MODIFY','REQUEST'

		SELECT '0' ErrorCode,'Your request for Amend transaction is successful...' Msg,NULL Id
	END

	ELSE IF	@flag='cancel-transaction'
	BEGIN
		IF NOT EXISTS(SELECT 'x' FROM dbo.remitTran(NOLOCK) rt WHERE rt.controlNo=dbo.FNAEncryptString(@controlNo) AND rt.id=@tranId)
		BEGIN
			SELECT '1' ErrorCode, 'Wrong Control No/TransactionId.' Msg, NULL Id	
			RETURN	
		END

		IF EXISTS(SELECT 'x' FROM dbo.remitTran(NOLOCK) rt WHERE rt.controlNo=dbo.FNAEncryptString(@controlNo) AND rt.id=@tranId AND tranStatus IN ('CancelRequest', 'Cancel'))
		BEGIN
			SELECT '1' ErrorCode, 'Transaction already cancelled or requested.' Msg, NULL Id	
			RETURN	
		END

		INSERT INTO tranModifyLog(tranId,controlNo,[message],createdBy,createdDate,MsgType,[status]	)
		SELECT @tranId,@controlNo,@message,@user,GETDATE(),'CANCEL','REQUEST'

		INSERT INTO tranCancelrequest(tranId, controlNo, cancelReason, cancelStatus, createdBy, createdDate, tranStatus)
		SELECT ID, CONTROLNO, @message, 'CancelRequest', @user, GETDATE(), tranStatus
		FROM dbo.remitTran(NOLOCK) rt WHERE rt.controlNo=dbo.FNAEncryptString(@controlNo) AND rt.id=@tranId

		UPDATE dbo.remitTran SET tranStatus='CancelRequest' 
		WHERE controlNo=dbo.FNAEncryptString(@controlNo) 
		AND id=@tranId

		SELECT '0' ErrorCode,'Your request for Cancel transaction is successful...' Msg,NULL Id
	END



END

GO
