USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SyncData]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[Proc_SyncData]
(
	@FLAG VARCHAR(90)
	,@TRAN_ID BIGINT = NULL
	,@PROVIDER VARCHAR(30) = NULL
	,@txnStausFromPartner	VARCHAR(20)		= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
DECLARE @CONTROLNO VARCHAR(30), @TRANDATE VARCHAR(30),@paymentMethod VARCHAR(50) =NULL

DECLARE @koreaSupAgent VARCHAR(20)
DECLARE @riaSupAgent VARCHAR(20)
DECLARE @TrangloSupAgent VARCHAR(20)

SELECT @riaSupAgent= agentId  from vw_GetAgentId(NOLOCK) WHERE searchText = 'riaAgent'

SELECT @TrangloSupAgent= agentId  from vw_GetAgentId(NOLOCK) WHERE searchText = 'trangloAgent'
SELECT @koreaSupAgent= agentId  from vw_GetAgentId(NOLOCK) WHERE searchText = 'koreaAgent'

IF @FLAG = 'mark-paid'
BEGIN
	IF @PROVIDER = 'gmekorea'
	BEGIN
		UPDATE dbo.remitTran SET 
			tranStatus = 'Paid',
			payStatus = 'Paid', 
			paidDate = GETDATE(), 
			paidDateLocal = GETDATE()
		WHERE id = @TRAN_ID
	END
	IF @PROVIDER=@TrangloSupAgent --------- if provider is tanglo
	BEGIN
		SELECT @paymentMethod=paymentMethod FROM dbo.remitTran (NOLOCK) WHERE id=@TRAN_ID
		
		IF ISNULL(@paymentMethod,'')='BANK DEPOSIT' AND @txnStausFromPartner='000'
		BEGIN
			UPDATE dbo.remitTran SET 
				tranStatus = 'Paid',
				payStatus = 'Paid', 
				paidDate = GETDATE(), 
				paidDateLocal = GETDATE()
			WHERE id = @TRAN_ID
		END
		ELSE IF ISNULL(@paymentMethod,'')='CASH PAYMENT' AND @txnStausFromPartner='000' ---------- 000 not real value 
		BEGIN
		    UPDATE dbo.remitTran SET 
				tranStatus = 'Paid',
				payStatus = 'Paid', 
				paidDate = GETDATE(), 
				paidDateLocal = GETDATE()
			WHERE id = @TRAN_ID
		END
	END
END
ELSE IF @FLAG = 'sync-list'
BEGIN
	IF @PROVIDER = 'gmekorea'
	BEGIN
		SELECT	id,
			tranNo=ISNULL(uploadLogId,0),
			controlNo = DBO.DECRYPTDB(CONTROLNO),
			partnerPin = DBO.DECRYPTDB(CONTROLNO2),
			pSuperAgent, 
			PCOUNTRY = pCountry
		FROM REMITTRAN (NOLOCK)
		WHERE 1=1
		AND payStatus IN ('Post','Unpaid')
		AND TRANSTATUS IN ( 'Payment','Compliance','OFAC','OFAC/Compliance','Cash Limit','Cash Limit/Compliance','Cash Limit/OFAC','Cash Limit/OFAC/Compliance')
		AND PCOUNTRY = 'South Korea'
	END
	ELSE
	BEGIN
		SELECT	id,
			tranNo=ISNULL(uploadLogId,0),
			controlNo = DBO.DECRYPTDB(CONTROLNO),
			partnerPin = DBO.DECRYPTDB(CONTROLNO2),
			pSuperAgent, 
			PCOUNTRY = pCountry
		FROM REMITTRAN (NOLOCK)
		WHERE  payStatus = 'Post'
		AND TRANSTATUS = 'Payment'
		AND pSuperAgent = @PROVIDER
	END
END
ELSE IF @Flag='List-Mongolia-Pay'
BEGIN
	
	UPDATE remitTran SET
		payStatus					= 'Post'
		,postedBy					= 'scheduler'
		,postedDate					= dbo.FNAGetDateInNepalTZ()
		,postedDateLocal			= GETDATE()	
	FROM remitTran rt WITH(NOLOCK)
	WHERE tranStatus = 'Payment' 
	AND payStatus = 'Unpaid' 
	AND sSuperAgent = @PROVIDER   --@koreaSupAgent
	
	SELECT TOP 40 controlNo = id FROM RemitTran(NOLOCK) rt 
	LEFT JOIN TBL_WALLET_WITHDRAW(NOLOCK) tw  ON rt.id = tw.tranId
	WHERE tw.tranId IS NULL 
	AND tranStatus = 'Payment' 
	AND payStatus = 'Post' 
	AND  sSuperAgent = @PROVIDER  
END
ELSE IF @Flag='Mark-Paid-Partner'
BEGIN
	IF OBJECT_ID('tempdb..#tempBankDeposit') IS NOT NULL
		DROP TABLE #tempBankDeposit

	IF @PROVIDER = @koreaSupAgent 
	BEGIN
		INSERT INTO bankDepositAPIQueu(controlNo,paidDate,txnStatus,createdBy,createdDate,provider)
		SELECT rt.controlNo,rt.paidDate,'payError',rt.createdBy,GetDate(),'GME' 
		FROM RemitTran(NOlock) rt 
		LEFT JOIN bankDepositAPIQueu(Nolock) b ON rt.controlNo = b.controlNo
		WHERE b.controlNo IS NULL
		and rt.sSuperAgent = @koreaSupAgent
		and rt.transtatus = 'paid'
		and rt.paystatus = 'paid'


	    SELECT TOP 100 b.rowId, controlNo = dbo.decryptDb(b.controlNo),b.paidDate 
		INTO #tempBankDeposit
		FROM bankDepositAPIQueu b 
		inner join remitTran(nolock) rt ON b.controlNo = rt.controlNo
		WHERE 
		ISNULL(b.txnStatus, 'payError') in ('payError','readytopay') 
		AND b.provider = 'GME' 
		and rt.transtatus = 'paid'
		and rt.paystatus = 'paid'
		ORDER BY rowId DESC
				
		SELECT * FROM #tempBankDeposit

		UPDATE b SET b.txnStatus = 'readyToPay'
		FROM bankDepositAPIQueu b 
		INNER JOIN #tempBankDeposit t ON t.rowId = b.rowId
	END

	IF @PROVIDER = @riaSupAgent 
	BEGIN
		 
		INSERT INTO bankDepositAPIQueu(controlNo,paidDate,txnStatus,createdBy,createdDate,provider)
		SELECT rt.controlNo,rt.paidDate,'payError',rt.createdBy,GetDate(),'RIA' 
		FROM RemitTran(NOlock) rt 
		LEFT JOIN bankDepositAPIQueu(Nolock) b ON rt.controlNo = b.controlNo
		WHERE b.controlNo IS NULL
		and rt.sSuperAgent = @riaSupAgent
		and rt.transtatus = 'paid'
		and rt.paystatus = 'paid'

		  

		IF OBJECT_ID('tempdb..#TempRia') IS NOT NULL
		DROP TABLE #TempRia

	    SELECT TOP 100 b.rowId, controlNo = dbo.decryptDb(b.controlNo),b.paidDate 
		INTO #TempRia
		FROM bankDepositAPIQueu b 
		inner join remitTran(nolock) rt ON b.controlNo = rt.controlNo
		WHERE 
		ISNULL(b.txnStatus, 'payError') in ('payError','readytopay') 
		AND b.provider = 'RIA' 
		and rt.transtatus = 'paid'
		and rt.paystatus = 'paid'
		ORDER BY rowId DESC
				
		SELECT * FROM #TempRia

		UPDATE b SET b.txnStatus = 'readyToPay'
		FROM bankDepositAPIQueu b 
		INNER JOIN #TempRia t ON t.rowId = b.rowId
	END
END
END






GO
