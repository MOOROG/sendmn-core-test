USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRANGLO_SYNC_STATUS]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_TRANGLO_SYNC_STATUS]
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
			,@tranStatus varchar(50),@vPcountry VARCHAR(50), @email VARCHAR(150), @extra2Status INT = 0

			SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus,@vPcountry = pCountry
			FROM remitTran (NOLOCK) 
			WHERE CONTNO = @GTN AND pAgent='394703' 

			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) 
				WHERE controlNo = @ENCRYPTEDGTN AND pAgent='394703' 
			END
			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) 
				WHERE controlNo = DBO.FNAEncryptString(@transId) AND pAgent='394703' 
			END

			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) 
				WHERE controlNo = DBO.FNAEncryptString(@payoutID) AND pAgent='394703' 
			END

			IF @TRANID IS NULL
			BEGIN
				SELECT @TRANID = ID, @CONTROLNOFORCASH = DBO.FNADecryptString(controlNo), @PAYMENTMETHOD = paymentMethod ,@tranStatus = tranStatus
				FROM remitTran (NOLOCK) WHERE controlNo2 = DBO.FNAEncryptString(@transId) AND pAgent='394703' 
			END

			IF @TRANID IS NULL
			BEGIN
				SELECT 1 errorCode, 'Transaction not found.' Msg, NULL Id
				RETURN
			END
			IF @tranStatus = 'Cancel'
			BEGIN
				SELECT 1 errorCode, 'Transaction already been cancelled' Msg, NULL Id
				RETURN
			END
			IF @tranStatus = 'Paid'
			BEGIN
				SELECT 1 errorCode, 'Transaction already been Paid' Msg, NULL Id
				RETURN
			END
			DECLARE @CustomerId INT,@Mobile varchar(20),@SMSBody VARCHAR(90),@refund char(1)
			SELECT @CustomerId = customerId FROM tranSenders (NOLOCK)
			WHERE tranId = @TRANID

			SELECT @Mobile = mobile, @email = email 
			FROM customerMaster(NOLOCK) 
			WHERE customerId = @CustomerId

			SET @Mobile = REPLACE(@Mobile,'+976','')


			--CANCEL TRANSACTION
			IF @trxStatus NOT IN ('000', '945', '966', '967', '968', '969', '911')			
			BEGIN
				--SET @refund = CASE WHEN @trxStatus IN ('930') THEN 'R' ELSE 'N' END
				IF @payoutStatus = 'Cancelled' --AND @PAYMENTMETHOD = 'CASH PAYMENT'
				BEGIN
					SET @extra2Status = 101
					--notify for cancelled txn via message
					SET @SMSBody = 'Your transaction is rejected,please resend transaction with correct receiver details.SENDMN'

					SELECT 0 errorCode, @SMSBody Msg, @email Id, @Mobile Extra, @extra2Status Extra2

					SET @refund ='N'
					EXEC proc_cancelTran @flag = 'cancel', @user = 'system', @controlNo = @CONTROLNOFORCASH, @cancelReason = 'Transaction Rejected. Incorrect beneficiary details', @refund = @refund
				END
				ELSE IF @trxStatus IN ('922', '930', '903') -- CASE WHEN @payoutStatus IS NULL AND STILL TRANSACTION IS CANCELLED
				BEGIN
					SET @extra2Status = 101
					--notify for cancelled txn via message
					SET @SMSBody = 'Your transaction is rejected,please resend transaction with correct receiver details.SENDMN'

					SELECT 0 errorCode, @SMSBody Msg, @email Id, @Mobile Extra, @extra2Status Extra2

					SET @refund ='N'
					EXEC proc_cancelTran @flag = 'cancel', @user = 'system', @controlNo = @CONTROLNOFORCASH, @cancelReason = 'Transaction Rejected. Incorrect beneficiary details', @refund = @refund
				END
				RETURN
			END
			ELSE IF @trxStatus = '000'
			BEGIN
				IF @PAYMENTMETHOD = 'CASH PAYMENT'
				BEGIN
					IF @vPcountry = 'Cambodia'
						SET @payoutID = @payoutPin

					IF @CONTROLNOFORCASH <> @payoutID
					BEGIN
						SET @extra2Status = 101

						IF EXISTS(SELECT 'A' FROM SendMnPro_Account.DBO.tran_master(NOLOCK) WHERE FIELD1 = @GTN AND field2 = 'Remittance Voucher' and acc_num = '1000003')
						BEGIN
							UPDATE SendMnPro_Account.DBO.tran_master SET FIELD1 = @payoutID  WHERE FIELD1 = @GTN AND field2 = 'Remittance Voucher'
						END

						UPDATE remitTran SET 
								controlNo = DBO.FNAEncryptString(@payoutID), 
								controlNo2 = DBO.FNAEncryptString(@transId),
								ContNo = @GTN
						WHERE ID = @TRANID AND pAgent='394703' 

						--notify for pin changed via message
						SET @SMSBody = 'Please provide SENDMN PIN number for your transaction as '+@payoutID+'.SENDMN'
					END
					IF @payoutStatus <> 'Claimed'
					BEGIN
						UPDATE remitTran SET payStatus = 'Post', postedBy = 'system', postedDate = getdate(), postedDateLocal = GETUTCDATE() 
						WHERE id = @TRANID  AND pAgent='394703' 
					END
					IF @payoutStatus = 'Claimed'
					BEGIN
						UPDATE remitTran SET payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'system', paidDate = GETDATE() WHERE id = @TRANID  AND pAgent='394703' 				
					END
				END
				ELSE IF @PAYMENTMETHOD = 'BANK DEPOSIT'
				BEGIN
					UPDATE remitTran SET payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'system', paidDate = GETDATE() 
					WHERE id = @TRANID  AND pAgent='394703' 
				END
				ELSE IF @PAYMENTMETHOD = 'MOBILE WALLET'
				BEGIN
					UPDATE remitTran SET payStatus = 'Paid', tranStatus = 'Paid', paidBy = 'system', paidDate = GETDATE() 
					WHERE id = @TRANID  AND pAgent='394703' 
				END
			END

			SELECT 0 errorCode, @SMSBody Msg, @email Id, @Mobile Extra, @extra2Status Extra2
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
