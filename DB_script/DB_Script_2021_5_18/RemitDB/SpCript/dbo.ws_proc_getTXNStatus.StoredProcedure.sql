USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_getTXNStatus]    Script Date: 5/18/2021 5:17:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_proc_getTXNStatus](	
	 @USER_ID			VARCHAR(50) = NULL
	,@PASSWORD			VARCHAR(50)	= NULL
	,@AGENT_CODE		VARCHAR(50) = NULL
	,@PINNO				VARCHAR(11)	= NULL
	,@AGENT_SESSION_ID  VARCHAR(50) = NULL
	,@flag				VARCHAR(20) = NULL	
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

DECLARE @errCode INT
EXEC proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT

	IF (@errCode=1 )
	BEGIN
		EXEC proc_errorHandler 1000 , 'Authentication Fail', NULL 
		RETURN
	END

DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(@PINNO))
--1.--------------------------------------------------------- Validation ----------------------------------------------------------------------------------------------
   
	IF @PINNO IS NULL
		BEGIN
			EXEC proc_errorHandler 1105, 'Pin Number field is Empty' , NULL 
			RETURN
		END   
	
	IF @AGENT_SESSION_ID IS NULL
		BEGIN
			EXEC proc_errorHandler 1105, 'Agent Session Id is Empty' , NULL 
			RETURN
		END 
		
--SELECT * FROM @errCode
	IF NOT EXISTS(SELECT 'A' FROM remittran WHERE controlno=@controlNoEncrypted )
	BEGIN
		EXEC proc_errorHandler 1101, 'Pin Number not found' , NULL 
		RETURN
	END

--SELECT 100 ErrorCode, 'UNPAID' Msg, null Id
	SELECT 100 ErrorCode,'Success' Msg
		,PINNO			= @PINNO 
		,SENDER_NAME	= TS.firstName+ISNULL(' '+TS.middleName,'')+ISNULL(' '+TS.lastName1,'')+ISNULL(' '+TS.lastName2,'') 
		,RECEIVER_NAME	= TR.firstName+ISNULL(' '+TR.middleName,'')+ISNULL(' '+TR.lastName1,'')+ISNULL(' '+TR.lastName2,'') 
		,PAYOUTAMT		= pAmt 
		,PAYOUTCURRENCY = payoutCurr 
		,[STATUS]		= CASE WHEN transtatus='Payment'THEN 'Un-Paid' WHEN  transtatus='CancelRequest' THEN 'Hold' ELSE transtatus END 
		,STATUS_DATE	= CASE WHEN transtatus='Paid' THEN paidDate WHEN transtatus='Cancel' THEN cancelapproveddate END 
	FROM remittran RM WITH (NOLOCK)
	INNER JOIN tranSenders TS WITH (NOLOCK) ON RM.Id = TS.tranId
	INNER JOIN tranreceivers TR WITH (NOLOCK) ON RM.Id = TR.tranId
	 WHERE controlno=@controlNoEncrypted

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	EXEC proc_errorHandler 9999, 'Exceptional Error Occured From DB', @controlNoEncrypted
END CATCH


GO
