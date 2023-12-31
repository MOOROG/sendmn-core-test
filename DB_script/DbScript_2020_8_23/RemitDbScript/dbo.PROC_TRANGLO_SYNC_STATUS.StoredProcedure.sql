ALTER  PROC [dbo].[PROC_TRANGLO_SYNC_STATUS]
(
	@flag						VARCHAR(10)	
	,@appKey					VARCHAR(70) = NULL
	,@date						VARCHAR(25) = NULL
	,@fromBalance				VARCHAR(20) = NULL
	,@toBalance					VARCHAR(20) = NULL
	,@trxStatus					VARCHAR(10) = NULL
	,@transId					VARCHAR(20) = NULL
	,@GTN						VARCHAR(20) = NULL
	,@txCreateDateTime			VARCHAR(25) = NULL
	,@txUpdateDateTime			VARCHAR(25) = NULL
	,@description				VARCHAR(100)= NULL
	,@payoutID					VARCHAR(100)= NULL
	,@payoutPin					VARCHAR(100)= NULL
	,@payoutStatus				VARCHAR(100)= NULL
	,@payoutStatusUpdateTime	VARCHAR(25) = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN
		IF @flag = 'status-t'
		BEGIN
			DECLARE @TRANID BIGINT = NULL, @ENCRYPTEDGTN VARCHAR(30) = DBO.FNAEncryptString(@GTN), @PAYMENTMETHOD VARCHAR(30), @CONTROLNOFORCASH VARCHAR(30)
			,@tranStatus varchar(50)

			SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
			FROM remitTran (NOLOCK) 
			WHERE CONTNO = @GTN

			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) 
				WHERE controlNo = @ENCRYPTEDGTN
			END
			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) 
				WHERE controlNo = DBO.FNAEncryptString(@transId)
			END

			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) 
				WHERE controlNo = DBO.FNAEncryptString(@payoutID)
			END

			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) WHERE controlNo2 = DBO.FNAEncryptString(@transId)
			END

			IF @TRANID IS NULL
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction not found.', NULL
				RETURN
			END
			IF @tranStatus = 'Cancel'
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction already been cancelled', NULL
				RETURN
			END
			IF @tranStatus = 'Paid'
			BEGIN
				EXEC proc_errorHandler 1, 'Transaction already been Paid', NULL
				RETURN
			END
			DECLARE @CustomerId INT,@Mobile varchar(20),@SMSBody VARCHAR(90),@refund char(1)
			SELECT @CustomerId = customerId FROM tranSenders (NOLOCK)
			WHERE tranId = @TRANID

			SELECT @Mobile = mobile FROM customerMaster(NOLOCK) WHERE customerId = @CustomerId
			SET @Mobile = REPLACE(@Mobile,'+82','0')
			SET @Mobile = REPLACE(@Mobile,'82','0')
			--CANCEL TRANSACTION
			IF @trxStatus NOT IN ('000', '945', '966', '967', '968', '969','911')			
			BEGIN
				--SET @refund = CASE WHEN @trxStatus IN ('930') THEN 'R' ELSE 'N' END
				IF @payoutStatus = 'Cancelled' AND @PAYMENTMETHOD = 'CASH PAYMENT'
				BEGIN
					IF LEN(@Mobile)=11
					BEGIN
						SET @SMSBody = 'Your transaction is rejected,please resend transaction with correct account details.GME'
						exec proc_CallToSendSMS @FLAG = 'I',@SMSBody= @SMSBody ,@MobileNo=@Mobile
					END
					SET @refund ='N'
					EXEC proc_cancelTran @flag = 'cancel', @user = 'system', @controlNo = @CONTROLNOFORCASH, @cancelReason = 'Transaction Rejected. Incorrect beneficiary details', @refund = @refund
				END
				
				RETURN
			END
			ELSE IF @trxStatus = '000'
			BEGIN
				IF @PAYMENTMETHOD = 'CASH PAYMENT'
				BEGIN
					IF @CONTROLNOFORCASH <> @payoutID
					BEGIN

						IF EXISTS(SELECT 'A' FROM SendMnPro_Account.dbo.tran_master(NOLOCK) WHERE FIELD1 = @GTN AND field2 = 'Remittance Voucher')
						BEGIN
							UPDATE SendMnPro_Account.dbo.tran_master SET FIELD1 = @payoutID  WHERE FIELD1 = @GTN AND field2 = 'Remittance Voucher'
						END

						UPDATE remitTran SET 
								controlNo = DBO.FNAEncryptString(@payoutID), 
								controlNo2 = DBO.FNAEncryptString(@transId),
								ContNo = @GTN
						WHERE ID = @TRANID

						IF LEN(@Mobile)=11
						BEGIN
							SET @SMSBody = 'Please provide GME PIN number for your transaction as '+@payoutID+'. GME'
							exec proc_CallToSendSMS @FLAG = 'I',@SMSBody= @SMSBody ,@MobileNo=@Mobile
						END
					END
					IF @payoutStatus <> 'Claimed'
					BEGIN
						UPDATE remitTran SET payStatus = 'Post', postedBy = 'system', postedDate = getdate(), postedDateLocal = GETUTCDATE()
						WHERE id = @TRANID 
					END
					IF @payoutStatus = 'Claimed'
					BEGIN
						UPDATE remitTran SET payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'system', paidDate = GETDATE()
						WHERE id = @TRANID 
					END
				END
				ELSE IF @PAYMENTMETHOD = 'BANK DEPOSIT'
				BEGIN
					UPDATE remitTran SET payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'system', paidDate = GETDATE()
					WHERE id = @TRANID 
				END
			END

			EXEC proc_errorHandler 0, 'Status update successfully!', NULL
		END
	END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
		
    DECLARE @errorMessage VARCHAR(MAX);
    SET @errorMessage = ERROR_MESSAGE();
	
    EXEC proc_errorHandler 1, @errorMessage, NULL;
	
END CATCH;

GO
