USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_CallToSendSMS]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----exec proc_CallToSendSMS @FLAG = 'I',@SMSBody='Your GME Wallet is successfully credited by KRW 10000 Thank you for using GME.',@MobileNo='01095215079'

CREATE PROC [dbo].[proc_CallToSendSMS]
@FLAG		VARCHAR(10),
@SMSBody	VARCHAR(90),
@MobileNo	VARCHAR(20)
AS

IF @FLAG = 'I'
BEGIN
	SET @MobileNo = REPLACE(@MobileNo,'+82','0')
	SET @MobileNo = REPLACE(@MobileNo,'+','')
	SET @MobileNo = REPLACE(@MobileNo,'-','')
	SET @MobileNo = CASE WHEN LEFT(@MobileNo,2)='82' THEN STUFF(@MobileNo, 1, 2, '0') ELSE @MobileNo END
	SET @MobileNo = CASE WHEN LEFT(@MobileNo,2)='00' THEN STUFF(@MobileNo,1,2,'0') ELSE @MobileNo END

BEGIN TRY

	IF LEN(@MobileNo) = 11
	BEGIN
		
		--insert into vwtpapilogs(providerName,requestXml,controlNo)
		--select 'SMS',@SMSBody,@MobileNo

		INSERT INTO KT_SMS.dbo.SDK_SMS_SEND ( USER_ID, SCHEDULE_TYPE, SUBJECT, SMS_MSG, NOW_DATE, SEND_DATE, CALLBACK, DEST_INFO)
		SELECT 'globalmoney',0,'Notice',@SMSBody,FORMAT(GETDATE(),'yyyyMMddHHmmss'),FORMAT(GETDATE(),'yyyyMMddHHmmss'),'1588-6864','GME^'+@MobileNo

		
		--insert into vwtpapilogs(providerName,requestXml,controlNo)
		--select 'SMS-OK',@SMSBody,@MobileNo
	END
END TRY
BEGIN CATCH
insert into vwtpapilogs(providerName,requestXml,controlNo)
select 'SMS',ERROR_MESSAGE(),@MobileNo
END CATCH
END


GO
