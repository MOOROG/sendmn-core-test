	

ALTER PROC PROC_TP_TXN_PUSH
(
	@FLAG VARCHAR(30)
	,@TRAN_ID BIGINT = NULL
	,@PROVIDER VARCHAR(30) = NULL
	,@doSyncAll CHAR(1) = NULL
	,@statusDate VARCHAR(30) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF ISDATE(@statusDate) = 0
		SET @statusDate = NULL
	
	IF @FLAG = 'GET-LIST'
	BEGIN
		--SELECT ID, CONTROLNO = DBO.DECRYPTDB(CONTROLNO), PAYMENTMETHOD, PCOUNTRY, CREATEDDATE
		--FROM REMITTRAN (NOLOCK)
		--WHERE 1=1
		----AND TRANSTATUS = 'Payment'
		----AND CREATEDDATE >= '2020-02-15'
		----AND PCOUNTRY = 'VIETNAM'
		----AND PAYMENTMETHOD = 'BANK DEPOSIT'
		----AND PCOUNTRY IN ('VIETNAM', 'NEPAL')
		----AND ID not in (100381773, 100381840, 100382294, 100382021)
		--AND controlno = dbo.fnaencryptstring('211050743')
		--ORDER BY ID DESC

		SELECT ID, CONTROLNO = DBO.DECRYPTDB(CONTROLNO), PAYMENTMETHOD, PCOUNTRY, CREATEDDATE, pbankname, pbank
		FROM REMITTRAN (NOLOCK)
		WHERE 1=1
		AND payStatus = 'unpaid'
		AND tranStatus = 'Payment'
		AND CREATEDDATE >= '2020-02-15'
		--AND PCOUNTRY IN ('VIETNAM')
		AND PCOUNTRY IN ('VIETNAM', 'NEPAL')
		AND controlNo <> dbo.FNAEncryptString('211592780')
		ORDER BY ID DESC

		--AND ((PCOUNTRY = 'VIETNAM') OR (PCOUNTRY = 'NEPAL' AND PAYMENTMETHOD='CASH PAYMENT'))
		--and PAYMENTMETHOD='CASH PAYMENT'
	END
	ELSE IF @FLAG = 'UPDATE-POST'
	BEGIN
		UPDATE dbo.remitTran SET payStatus = 'POST',
								postedBy = 'Scheduler', 
								postedDate = GETDATE(), 
								postedDateLocal = GETDATE()
		WHERE id = @TRAN_ID
	END
	ELSE IF @FLAG = 'mark-paid'
	BEGIN
		IF CAST(ISNULL(@statusDate, GETDATE()) AS DATE) < '2020-05-01'
			SET @statusDate = NULL

		DECLARE @CONTROLNO VARCHAR(30), @TRANDATE VARCHAR(30)
		UPDATE dbo.remitTran SET tranStatus = 'Paid',
								payStatus = 'Paid', 
								paidBy = 'Scheduler', 
								paidDate = ISNULL(@statusDate, GETDATE()), 
								paidDateLocal = ISNULL(@statusDate, GETDATE())
		WHERE id = @TRAN_ID
			
		SELECT @CONTROLNO = DBO.DECRYPTDB(CONTROLNO),
				@TRANDATE = PAIDDATE
		FROM dbo.remitTran (NOLOCK)
		WHERE id = @TRAN_ID
			
		EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_TRANSACTION_PAID_VOUCHER_ENTRY @controlNo = @CONTROLNO, @tranDate = @TRANDATE
	END
	ELSE IF @FLAG = 'sync-list'
	BEGIN
		IF ISNULL(@doSyncAll, 'N') = 'N'
		BEGIN
			IF @PROVIDER = 'donga'
			BEGIN
				SELECT TOP 30 id, controlNo = DBO.DECRYPTDB(CONTROLNO), pSuperAgent, PCOUNTRY, partnerPin = DBO.DECRYPTDB(CONTROLNO)
				FROM REMITTRAN (NOLOCK)
				WHERE 1=2
				AND payStatus = 'Post'
				AND TRANSTATUS = 'Payment'
				AND CREATEDDATE >= '2020-02-15'
				AND PCOUNTRY = 'VIETNAM'
				--AND ID = 100381773
			END
			ELSE IF @PROVIDER = 'jmenepal'
			BEGIN
				SELECT TOP 40 id, controlNo = DBO.DECRYPTDB(CONTROLNO), pSuperAgent, PCOUNTRY, partnerPin = DBO.DECRYPTDB(CONTROLNO), createdDate
				FROM REMITTRAN (NOLOCK)
				WHERE 1=1
				AND payStatus = 'Post'
				AND TRANSTATUS = 'Payment'
				AND CREATEDDATE >= '2020-02-15'
				AND PCOUNTRY = 'NEPAL'
				ORDER BY ID DESC
				--AND id=dbo.fnaencryptstring('211517849')
			END
			ELSE IF @PROVIDER = 'transfast'
			BEGIN
				SELECT TOP 30 id, controlNo = DBO.DECRYPTDB(CONTROLNO), pSuperAgent, PCOUNTRY, partnerPin = DBO.DECRYPTDB(CONTROLNO)
				FROM REMITTRAN (NOLOCK)
				WHERE 1=2
				AND CREATEDDATE >= '2020-03-31'
				AND PCOUNTRY NOT IN ('NEPAL','VIETNAM')
				AND payStatus = 'Post'
				AND TRANSTATUS = 'Payment'
				ORDER BY ID DESC
			END
		END
		ELSE
		BEGIN
			IF @PROVIDER = 'donga'
			BEGIN
				SELECT id, controlNo = DBO.DECRYPTDB(CONTROLNO), pSuperAgent, PCOUNTRY, partnerPin = DBO.DECRYPTDB(CONTROLNO)
				FROM REMITTRAN (NOLOCK)
				WHERE 1=1
				AND payStatus = 'Post'
				AND TRANSTATUS = 'Payment'
				AND CREATEDDATE >= '2020-02-15'
				AND PCOUNTRY = 'VIETNAM'
				--AND ID = 100381773
			END
			ELSE IF @PROVIDER = 'jmenepal'
			BEGIN
				SELECT id, controlNo = DBO.DECRYPTDB(CONTROLNO), pSuperAgent, createddate, partnerPin = DBO.DECRYPTDB(CONTROLNO)
				FROM REMITTRAN (NOLOCK)
				WHERE 1=1
				AND payStatus = 'Post'
				AND TRANSTATUS = 'Payment'
				AND CREATEDDATE >= '2020-02-15'
				AND PCOUNTRY = 'NEPAL'
				--AND id=dbo.fnaencryptstring('211517849')
			END
			ELSE IF @PROVIDER = 'transfast'
			BEGIN
				SELECT id, controlNo = DBO.DECRYPTDB(CONTROLNO), pSuperAgent, PCOUNTRY, partnerPin = DBO.DECRYPTDB(CONTROLNO)
				FROM REMITTRAN (NOLOCK)
				WHERE 1=1
				AND CREATEDDATE >= '2020-03-31'
				AND PCOUNTRY NOT IN ('NEPAL','VIETNAM')
				AND payStatus = 'Post'
				AND TRANSTATUS = 'Payment'
			END
		END
	END
	ELSE IF @Flag = 'GET-RELEASE-LIST'
	BEGIN
		SELECT  ID, CONTROLNO = DBO.DECRYPTDB(CONTROLNO), PAYMENTMETHOD,
			PCOUNTRY, CREATEDDATE, pbankname, pbank,sSuperAgent = pSuperAgent,
			[partner] = 'transfast' 
		FROM REMITTRAN (NOLOCK)
		WHERE 1=1
		AND CREATEDDATE >= '2020-03-31'
		AND PCOUNTRY NOT IN ('VIETNAM', 'NEPAL')
		AND payStatus = 'unpaid'
		AND tranStatus = 'Payment'
		--and controlNo = DBO.FNAEncryptString('33TF099232155')
			
		--SELECT ID, CONTROLNO = DBO.DECRYPTDB(CONTROLNO), PAYMENTMETHOD, PCOUNTRY, CREATEDDATE, pbankname, pbank
		--FROM REMITTRAN (NOLOCK)
		--WHERE 1=1
		--AND payStatus = 'unpaid'
		--AND tranStatus = 'Payment'
		--AND CREATEDDATE >= '2020-02-15'
		--AND PCOUNTRY NOT IN ('VIETNAM', 'NEPAL')
		--ORDER BY ID DESC

	END
END
