USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_REFERRAL_TRANSACTION_REPORT]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PROC_REFERRAL_TRANSACTION_REPORT]
(
	@FLAG VARCHAR(30)
	,@FROM_DATE VARCHAR(20) = NULL
	,@TO_DATE VARCHAR(20) = NULL
	,@REFERRAL_CODE VARCHAR(30) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @FLAG = 'S'
	BEGIN
		SELECT DBO.DECRYPTDB(CONTROLNO) CONTROLNO, CONVERT(VARCHAR,CREATEDDATE,102) CREATEDDATE, CAMT, SENDERNAME, COLLMODE
		FROM REMITTRAN (NOLOCK)
		WHERE PROMOTIONCODE = @REFERRAL_CODE
		AND TRANSTATUS <> 'CANCEL'
		AND CREATEDDATE BETWEEN @FROM_DATE AND @TO_DATE + ' 23:59:59'
	END
	IF @FLAG = 'TOP-5'
	BEGIN
		SELECT TOP 5 DBO.DECRYPTDB(CONTROLNO) CONTROLNO, CONVERT(VARCHAR,CREATEDDATE,102) CREATEDDATE, CAMT, SENDERNAME, COLLMODE
		FROM REMITTRAN (NOLOCK)
		WHERE PROMOTIONCODE = @REFERRAL_CODE
		AND TRANSTATUS <> 'CANCEL'
		ORDER BY CREATEDDATE DESC
	END
END
GO
