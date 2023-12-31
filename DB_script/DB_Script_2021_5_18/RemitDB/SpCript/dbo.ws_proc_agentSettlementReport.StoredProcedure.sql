USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_agentSettlementReport]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_proc_agentSettlementReport](	
	 @USER_ID			VARCHAR(50)	= NULL
	,@PASSWORD			VARCHAR(50)	= NULL
	,@AGENT_CODE		VARCHAR(50)	= NULL
	,@AGENT_SESSION_ID	VARCHAR(50)	= NULL
	,@FROM_DATE			VARCHAR(20)	= NULL
	,@TO_DATE			VARCHAR(20)	= NULL
	,@REPORT_TYPE		CHAR(1)		= NULL
	,@flag				VARCHAR(20) = NULL
)
AS

DECLARE @errCode INT
EXEC proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT

IF (@errCode=1 )
BEGIN
	SELECT 1000 ErrorCode, 'Authentication Fail' Msg, NULL Id
	RETURN
END
------------------------------------- Validation -------------------------------------------------- 

IF	@REPORT_TYPE IS NULL
	BEGIN
		EXEC proc_errorHandler 1105, 'Report Type Field is Empty' , NULL 
		RETURN
	END

--IF	@FROM_DATE IS NULL
--	BEGIN
--		EXEC proc_errorHandler 1105, 'From Date Field is Empty' , NULL 
--			RETURN
--		END
--IF	ISDATE(@FROM_DATE)=0 AND @FROM_DATE IS NOT NULL
--	BEGIN
--		EXEC proc_errorHandler 1102, 'From Date is Invalid!' , NULL 
--			RETURN
--		END

--IF	@TO_DATE IS NULL
--	BEGIN
--		EXEC proc_errorHandler 1105, 'To Date Field is Empty' , NULL 
--			RETURN
--		END
--IF	ISDATE(@TO_DATE)=0 AND @TO_DATE IS NOT NULL
--	BEGIN
--		EXEC proc_errorHandler 1102, 'To Date is Invalid!' , NULL 
--			RETURN
--		END
------------------------------------- Validation Ends -------------------------------------------------- 
		
DECLARE @agentId INT

SELECT @agentId=agentId FROM applicationUsers WHERE userName = @USER_ID AND pwd=DBO.FNAEncryptString(@PASSWORD)

IF @REPORT_TYPE = 'P'
BEGIN

IF NOT EXISTS(SELECT 'A' FROM remittran RM WITH (NOLOCK)
				INNER JOIN tranSenders TS WITH (NOLOCK) ON RM.Id = TS.tranId
				INNER JOIN tranreceivers TR WITH (NOLOCK) ON RM.Id = TR.tranId
				WHERE paidDate BETWEEN @FROM_DATE AND @TO_DATE
				AND (sAgent = @agentId OR pAgent = @agentId)
				AND LEN(dbo.FNAdecryptString(controlNo))=11
			)
BEGIN
	 SELECT '100' ErrorCode,'Success' Msg,NULL PINNO,NULL SENDER_NAME,NULL RECEIVER_NAME,NULL PAYOUTAMT,NULL TXN_DATE,NULL PAYOUTCURRENCY,NULL [STATUS],NULL STATUS_DATE
	RETURN
END	 
SELECT 100 ErrorCode,'Success' Msg
		,PINNO			=	dbo.FNAdecryptString(controlNo) 
		,SENDER_NAME	=	TS.firstName+' '+ISNULL(TS.middleName,'')+' '+ISNULL(TS.lastName1,'')+' '+ISNULL(TS.lastName2,'')
		,RECEIVER_NAME	=	TR.firstName+' '+ISNULL(TR.middleName,'')+' '+ISNULL(TR.lastName1,'')+' '+ISNULL(TR.lastName2,'') 
		,PAYOUT_AMT		=	pAmt 
		,TXN_DATE		=	createdDate 
		,PAYOUT_CURRENCY	=	payoutCurr 
		,[STATUS]		=	CASE WHEN transtatus='Payment'THEN 'Un-Paid' WHEN  transtatus='CancelRequest' THEN 'Hold' ELSE transtatus END 
		,STATUS_DATE	=	CASE WHEN transtatus='Paid' THEN paidDate WHEN transtatus='Cancel' THEN cancelapproveddate END 
	FROM remittran RM WITH (NOLOCK)
	INNER JOIN tranSenders TS WITH (NOLOCK) ON RM.Id = TS.tranId
	INNER JOIN tranreceivers TR WITH (NOLOCK) ON RM.Id = TR.tranId
	WHERE paidDate BETWEEN @FROM_DATE AND @TO_DATE
	AND (sAgent = @agentId OR pAgent = @agentId)
	--AND LEN(dbo.FNAdecryptString(controlNo))=11
	
	
	
END	

IF @REPORT_TYPE = 'S'
BEGIN

IF NOT EXISTS(SELECT 'A' FROM remittran RM WITH (NOLOCK)
			INNER JOIN tranSenders TS WITH (NOLOCK) ON RM.Id = TS.tranId
			INNER JOIN tranreceivers TR WITH (NOLOCK) ON RM.Id = TR.tranId
			WHERE createdDate BETWEEN @FROM_DATE AND @TO_DATE
			AND (sAgent = @agentId OR pAgent = @agentId)
			--AND LEN(dbo.FNAdecryptString(controlNo))=11
		)
BEGIN
	 SELECT '100' ErrorCode,'Success' Msg,NULL PINNO,NULL SENDER_NAME,NULL RECEIVER_NAME,NULL PAYOUTAMT,NULL TXN_DATE,NULL PAYOUTCURRENCY,NULL [STATUS],NULL STATUS_DATE
	RETURN
END

SELECT 100 ErrorCode,'Success' Msg
		,PINNO			=	dbo.FNAdecryptString(controlNo)  
		,SENDER_NAME	=	TS.firstName+' '+ISNULL(TS.middleName,'')+' '+ISNULL(TS.lastName1,'')+' '+ISNULL(TS.lastName2,'') 
		,RECEIVER_NAME	=	TR.firstName+' '+ISNULL(TR.middleName,'')+' '+ISNULL(TR.lastName1,'')+' '+ISNULL(TR.lastName2,'') 
		,PAYOUT_AMT		=	pAmt 
		,TXN_DATE		=	 createdDate 
		,PAYOUT_CURRENCY =	payoutCurr 
		,[STATUS]		=	CASE WHEN transtatus='Payment'THEN 'Un-Paid' WHEN  transtatus='CancelRequest' THEN 'Hold' ELSE transtatus END 
		,STATUS_DATE	=	CASE WHEN transtatus='Paid' THEN paidDate WHEN transtatus='Cancel' THEN cancelapproveddate END 
	FROM remittran RM WITH (NOLOCK)
	INNER JOIN tranSenders TS WITH (NOLOCK) ON RM.Id = TS.tranId
	INNER JOIN tranreceivers TR WITH (NOLOCK) ON RM.Id = TR.tranId
	WHERE createdDate BETWEEN @FROM_DATE AND @TO_DATE
	AND (sAgent = @agentId OR pAgent = @agentId)
	--AND LEN(dbo.FNAdecryptString(controlNo))=11

END	




GO
