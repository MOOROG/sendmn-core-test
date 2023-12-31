USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_OTP_SEND_TXN]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EXEC PROC_OTP_SEND_TXN @FLAG = 'RE-SEND', @CUSTOMERID = '1'
--EXEC PROC_OTP_SEND_TXN @FLAG = 'VERIFY', @CUSTOMERID = '1', @OTP_NUMBER = '6740'
--exec proc_CallToSendSMS @FLAG = 'I',@SMSBody='Your GME Wallet is successfully credited by KRW 10000 Thank you for using GME.',@MobileNo='01095215079'

--SELECT DBO.decryptDb(OTP_NUMBER), DATEDIFF(MI, ASSIGNED_DATE, GETDATE()),* FROM TBL_OTP_FOR_AUTODEBIT

CREATE PROC [dbo].[PROC_OTP_SEND_TXN]
(
	@FLAG VARCHAR(20) 
	,@OTP_NUMBER VARCHAR(10) = NULL
	,@CUSTOMERID BIGINT = NULL
	,@CUSTOMEREMAIL VARCHAR(100) = NULL
	,@AMT		VARCHAR(100) = NULL
	,@ACCOUNTNUM VARCHAR(50) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @MOBILE_NUMBER VARCHAR(15)
	DECLARE @SMS_MESSAGE VARCHAR(200)

	SET @AMT = REPLACE(@AMT,'.00','')
	SET @ACCOUNTNUM = '**'+RIGHT(@ACCOUNTNUM,6)
	IF @FLAG = 'SEND'
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM customerMaster (NOLOCK) WHERE email = @CUSTOMEREMAIL AND customerId = @CUSTOMERID)
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Request!', NULL;
			RETURN
		END

		
		DECLARE @RANDOM_NUMBER VARCHAR(4) = RIGHT(CHECKSUM(NEWID()),4)		
		SELECT @MOBILE_NUMBER = mobile FROM customerMaster(NOLOCK) WHERE customerId = @CUSTOMERID		
		SET @SMS_MESSAGE = 'Your GME OTP = '+ CAST(@RANDOM_NUMBER AS VARCHAR)+' .KRW ' + @AMT + ' will be deducted from your Bank Ac no.' + @ACCOUNTNUM 

		IF EXISTS(SELECT 1 FROM TBL_OTP_FOR_AUTODEBIT (NOLOCK) WHERE CUSTOMERID = @CUSTOMERID)
		BEGIN
			UPDATE TBL_OTP_FOR_AUTODEBIT 
			SET OTP_NUMBER = DBO.FNAEncryptString(@RANDOM_NUMBER), 
				ASSIGNED_DATE = GETDATE() 
			WHERE CUSTOMERID = @CUSTOMERID

			EXEC proc_CallToSendSMS @FLAG = 'I',@SMSBody=@SMS_MESSAGE, @MobileNo=@MOBILE_NUMBER

			EXEC proc_errorHandler 0, 'Success!', @RANDOM_NUMBER;
			RETURN
		END
		ELSE 
		BEGIN
			INSERT INTO TBL_OTP_FOR_AUTODEBIT(CUSTOMERID, OTP_NUMBER, ASSIGNED_DATE)
			SELECT @CUSTOMERID, DBO.FNAEncryptString(@RANDOM_NUMBER), GETDATE()

			EXEC proc_CallToSendSMS @FLAG = 'I',@SMSBody=@SMS_MESSAGE, @MobileNo=@MOBILE_NUMBER

			EXEC proc_errorHandler 0, 'Success!', @RANDOM_NUMBER;
			RETURN
		END
	END
	ELSE IF @FLAG = 'RE-SEND'
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM customerMaster (NOLOCK) WHERE email = @CUSTOMEREMAIL AND customerId = @CUSTOMERID)
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Request!', NULL;
			RETURN
		END

		SET @RANDOM_NUMBER = RIGHT(CHECKSUM(NEWID()),4)
		SELECT @MOBILE_NUMBER = mobile FROM customerMaster WHERE customerId = @CUSTOMERID		
		SET @SMS_MESSAGE = 'Your GME OTP = '+CAST(@RANDOM_NUMBER AS VARCHAR)+' .KRW ' + @AMT + ' will be deducted from your Bank Ac no.' + @ACCOUNTNUM 

		IF EXISTS(SELECT 1 FROM TBL_OTP_FOR_AUTODEBIT (NOLOCK) WHERE CUSTOMERID = @CUSTOMERID)
		BEGIN
			UPDATE TBL_OTP_FOR_AUTODEBIT 
			SET OTP_NUMBER = DBO.FNAEncryptString(@RANDOM_NUMBER), 
				ASSIGNED_DATE = GETDATE() 
			WHERE CUSTOMERID = @CUSTOMERID

			EXEC proc_CallToSendSMS @FLAG = 'I',@SMSBody=@SMS_MESSAGE, @MobileNo=@MOBILE_NUMBER

			EXEC proc_errorHandler 0, 'Success!', @RANDOM_NUMBER;
			RETURN
		END
		ELSE 
		BEGIN
			INSERT INTO TBL_OTP_FOR_AUTODEBIT(CUSTOMERID, OTP_NUMBER, ASSIGNED_DATE)
			SELECT @CUSTOMERID, DBO.FNAEncryptString(@RANDOM_NUMBER), GETDATE()

			EXEC proc_CallToSendSMS @FLAG = 'I',@SMSBody=@SMS_MESSAGE, @MobileNo=@MOBILE_NUMBER

			EXEC proc_errorHandler 0, 'Success!', @RANDOM_NUMBER;
			RETURN
		END
	END
	ELSE IF @FLAG = 'VERIFY'
	BEGIN
		DECLARE @ASSIGNED_DATE DATETIME = NULL

		IF LEN(@OTP_NUMBER) <> 4
		BEGIN
			EXEC proc_errorHandler 1, 'The OTP you entered is invalid. Please enter a valid OTP(4 digit)!', @RANDOM_NUMBER;
			RETURN
		END

		SELECT @RANDOM_NUMBER = @OTP_NUMBER, 
				@ASSIGNED_DATE = ASSIGNED_DATE 
		FROM TBL_OTP_FOR_AUTODEBIT (NOLOCK) 
		WHERE CUSTOMERID = @CUSTOMERID 
		AND OTP_NUMBER = DBO.FNAEncryptString(@OTP_NUMBER)
		
		IF @ASSIGNED_DATE IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'The 4 digit pin OTP entered does not match. Please try again!', @RANDOM_NUMBER;
		END
		ELSE IF DATEDIFF(MI, @ASSIGNED_DATE, GETDATE()) >= 2
		BEGIN
			EXEC proc_errorHandler 1, 'The 4 digit OTP you entered is expired. Please click on resend OTP!', @RANDOM_NUMBER;
		END
		ELSE 
		BEGIN
			EXEC proc_errorHandler 0, 'Success!', @RANDOM_NUMBER;
		END
	END
END




GO
