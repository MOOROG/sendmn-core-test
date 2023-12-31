USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_ReconcileReport]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_ReconcileReport]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_ReconcileReport

GO
*/
 /*
 EXEC ws_proc_ReconcileReport 
 @ACCESSCODE='IMEARE01'
 ,@USERNAME='testapi'
 ,@PASSWORD='ime@12345'
 ,@AGENT_TXN_REF_ID='112121212'
 ,@REPORT_TYPE='A'
 ,@FROM_DATE='2011-07-17'
 ,@TO_DATE='2013-07-19'
 ,@SHOW_INCREMENTAL='N'


 */


CREATE PROC [dbo].[ws_int_proc_ReconcileReport] (	 
	@ACCESSCODE			VARCHAR(50),
	@USERNAME			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_TXN_REF_ID	VARCHAR(150),
	@REPORT_TYPE		CHAR(1),
	@FROM_DATE			VARCHAR(50),
	@TO_DATE			VARCHAR(50)
)
AS

SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	DECLARE @apiRequestId BIGINT
	INSERT INTO requestApiLogOther(
		 AGENT_CODE			
		,USER_ID 			
		,PASSWORD 			
		,AGENT_TXN_REF_ID	
		,REPORT_TYPE		
		,FROM_DATE			
		,TO_DATE
		,METHOD_NAME
		,REQUEST_DATE		
	

	)
	SELECT
		 @ACCESSCODE				
		,@USERNAME 			
		,@PASSWORD 			
		,@AGENT_TXN_REF_ID	
		,@REPORT_TYPE		
		,@FROM_DATE			
		,@TO_DATE
		,'ws_int_proc_ReconcileReport'
		,GETDATE()

	SET @apiRequestId = SCOPE_IDENTITY()	




DECLARE @SHOW_INCREMENTAL CHAR(1)
DECLARE @errCode INT
DECLARE @autMsg	VARCHAR(500)
EXEC ws_int_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT,@autMsg OUT

DECLARE @errorTable TABLE(AGENT_NAME VARCHAR(100),AGENT_BRANCH VARCHAR(100),TRANSACTION_STATUS VARCHAR(20),PINNO VARCHAR(50),SENDER_NAME VARCHAR(100)
			,RECEIVER_NAME VARCHAR(100),RECEIVER_COUNTRY VARCHAR(50),PAYOUT_AMT MONEY,PAYOUT_CCY VARCHAR(3),TRANSACTION_DATE DATETIME ,STATUS VARCHAR(30)
			,PAID_DATE DATETIME,PAYOUT_AGENT VARCHAR(100),CANCEL_DATE DATETIME,AGENT_TXN_REF_ID VARCHAR(150))

INSERT INTO @errorTable(AGENT_TXN_REF_ID) SELECT @AGENT_TXN_REF_ID

	IF (@errCode=1 )
	BEGIN
		SELECT 1002 CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE
				,* FROM @errorTable
		RETURN
	END
	IF EXISTS(SELECT 'A' FROM applicationUsers WITH (NOLOCK) WHERE 
			userName = @USERNAME AND forceChangePwd = 'Y')
	BEGIN
			SELECT 1002 CODE
				, 'You logged on first time,must first change your password and try again!' MESSAGE
				,* FROM @errorTable
			RETURN
	END
	------------------VALIDATION-------------------------------
	IF @AGENT_TXN_REF_ID IS NULL
	BEGIN
		SELECT 1001 CODE,'AGENT SESSION ID Field is Empty' MESSAGE
				,* FROM @errorTable
		RETURN;
	END
	IF @REPORT_TYPE IS NULL
	BEGIN
		SELECT 1001 CODE,'REPORT TYPE Field is Empty' MESSAGE
				,* FROM @errorTable
		RETURN;
	END
	IF @FROM_DATE IS NULL
	BEGIN
		SELECT 1001 CODE,'FROM DATE Field is Empty' MESSAGE
				,* FROM @errorTable
		RETURN;
	END
	IF ISDATE(@FROM_DATE) = 0 AND @FROM_DATE IS NOT NULL
	BEGIN
		SELECT 9001 CODE
		,'Technical Error: FROM DATE must be date' MESSAGE
				,* FROM @errorTable
		RETURN;
	END
	IF @TO_DATE IS NULL
	BEGIN
		SELECT 1001 CODE,'TO DATE Field is Empty' MESSAGE
				,* FROM @errorTable
		RETURN;
	END
	IF ISDATE(@TO_DATE) = 0 AND @TO_DATE IS NOT NULL
	BEGIN
		SELECT 9001 CODE
		,'Technical Error: TO DATE must be date' MESSAGE
				,* FROM @errorTable
		RETURN;
	END
	IF @REPORT_TYPE NOT IN ('A','S','P','C','U')
	BEGIN
		SELECT 1004 CODE,'Invalid Report Type' MESSAGE
				,* FROM @errorTable
		RETURN;
	END

DECLARE @dateType VARCHAR(30),@SQL VARCHAR(MAX)
DECLARE		@sCountryId		INT, 
			@sAgent			INT,
			@sBranch		INT

-- PICK AGENTID ,COUNTRY FROM USER
SELECT @sCountryId=countryId,
			@sBranch = agentId 
		FROM applicationUsers WHERE userName=@USERNAME

SELECT @sAgent	= parentId FROM agentMaster WHERE agentId = @sBranch AND ISNULL(isActive,'Y')='Y'

SET @dateType = CASE WHEN @REPORT_TYPE IN ('A','S','U') THEN 'RT.createdDate'
					WHEN @REPORT_TYPE='P' THEN 'RT.paidDate'
					WHEN @REPORT_TYPE='C' THEN 'RT.cancelApprovedDate' END


	CREATE TABLE #outputList (
		 ID					BIGINT
		,CODE				VARCHAR(20)	
		,[MESSAGE]			VARCHAR(200)
		,AGENT_TXN_REF_ID	VARCHAR(50)
		,AGENT_NAME			VARCHAR(200)
		,AGENT_BRANCH		VARCHAR(200)
		,TRANSACTION_STATUS	VARCHAR(50)
		,REFNO				VARCHAR(50)
		,SENDER_NAME		VARCHAR(200)
		,RECEIVER_NAME		VARCHAR(200)
		,RECEIVER_COUNTRY	VARCHAR(200)
		,PAYOUT_AMT			MONEY
		,PAYOUT_CCY			VARCHAR(20)
		,TRANSACTION_DATE	DATETIME
		,[STATUS]			VARCHAR(50)
		,PAID_DATE			DATETIME
		,PAYOUT_AGENT		VARCHAR(200)
		,CANCEL_DATE		DATETIME
		,isCancelled		CHAR(1)
		,localAmount		MONEY
		,settlementAmt		MONEY
		,usdRate			MONEY
		,settlementRate		MONEY
	)


	SET @SQL =' SELECT * FROM (
		SELECT 
			ID						= rt.Id,
			CODE					= 0	,	
			MESSAGE					= ''Success''	,
			AGENT_TXN_REF_ID		= '''+@AGENT_TXN_REF_ID+''',
			AGENT_NAME				= sAgentName,
			AGENT_BRANCH			= sBranchName ,
			TRANSACTION_STATUS		= CASE WHEN tranStatus=''Hold'' THEN ''Send'' ELSE tranStatus END ,
			REFNO					= DBO.FNADecryptString(controlNo) ,
			SENDER_NAME				= RT.senderName ,
			RECEIVER_NAME			= RT.receiverName,
			RECEIVER_COUNTRY		= TR.country,
			PAYOUT_AMT				= pAmt	,
			PAYOUT_CCY				= payoutCurr	,
			TRANSACTION_DATE		= createdDate,
			STATUS					= CASE WHEN tranStatus=''Payment'' THEN ''Un-Paid'' ELSE tranStatus END,
			PAID_DATE				= paidDateLocal	,
			PAYOUT_AGENT			= pAgentName,
			CANCEL_DATE				= cancelApprovedDate,
			isCancelled				= ''N'',
			localAmount				= cAmt, 
			settlementAmt			= pAmt/pCurrCostRate, 
			usdRate					= pCurrCostRate, 
			settlementRate			= pAmt/cAmt
				
	FROM remitTran RT WITH (NOLOCK)
	INNER JOIN tranReceivers TR WITH (NOLOCK) ON RT.id = TR.tranId
	WHERE '+ @dateType + ' BETWEEN ''' + @FROM_DATE + ''' AND ''' + @TO_DATE + ' 23:59:59'' 
	AND rt.createdBy=''' + @USERNAME + ''''
	--AND RT.sBranch = ''' + CAST(@sBranch AS VARCHAR) + '''' --+
	--CASE WHEN  @SHOW_INCREMENTAL = 'Y' THEN ' AND (RT.incrRpt IS NULL OR RT.incrRpt = ''N'')' ELSE '' END

IF @REPORT_TYPE = 'S'
	SET @SQL  = @SQL +' AND RT.cancelApprovedDate IS NULL '

IF @REPORT_TYPE = 'U'
	SET @SQL  = @SQL +' AND RT.paystatus =''Unpaid'' AND RT.cancelApprovedDate IS NULL '

IF  @REPORT_TYPE IN ('A','C')
BEGIN
-------------------------for cancel txn 
SET @SQL = @SQL  + '   UNION ALL
		SELECT 
			ID						= rt.Id,
			CODE					= 0	,	
			MESSAGE					= ''Success''	,
			AGENT_TXN_REF_ID		= ''' + @AGENT_TXN_REF_ID + ''',
			AGENT_NAME				= sAgentName,
			AGENT_BRANCH			= sBranchName ,
			TRANSACTION_STATUS		= CASE WHEN tranStatus=''Hold'' THEN ''Send'' ELSE tranStatus END ,
			REFNO					= DBO.FNADecryptString(controlNo) ,
			SENDER_NAME				= RT.senderName ,
			RECEIVER_NAME			= RT.receiverName,
			RECEIVER_COUNTRY		= TR.country,
			PAYOUT_AMT				= pAmt,
			PAYOUT_CCY				= payoutCurr,
			TRANSACTION_DATE		= createdDate,
			STATUS					= CASE WHEN tranStatus=''Payment'' THEN ''Un-Paid'' ELSE tranStatus END,
			PAID_DATE				= paidDateLocal	,
			PAYOUT_AGENT			= pAgentName,
			CANCEL_DATE				= cancelApprovedDate,
			isCancelled				= ''Y''	,
			localAmount				= cAmt, 
			settlementAmt			= pAmt/pCurrCostRate, 
			usdRate					= pCurrCostRate, 
			settlementRate			= pAmt/cAmt

	FROM cancelTranHistory RT WITH (NOLOCK)
	INNER JOIN tranReceivers TR WITH (NOLOCK) ON RT.id = TR.tranId
	WHERE ' + @dateType + ' BETWEEN ''' + @FROM_DATE + ''' AND ''' + @TO_DATE + ' 23:59:59'' 
		AND rt.createdBy=''' + @USERNAME + ''''
		--AND RT.sBranch = ''' + CAST(@sBranch AS VARCHAR) + '''' 
		
	
END

SET @SQL  = @SQL +' ) X '

--SELECT @SQL
INSERT INTO #outputList
EXEC(@SQL)

IF NOT EXISTS(SELECT 'x' FROM #outputList)
BEGIN
	--INSERT #outputList(CODE, [MESSAGE], AGENT_TXN_REF_ID)
	SELECT '3013' CODE, 'No Record Found' [MESSAGE], @AGENT_TXN_REF_ID AGENT_TXN_REF_ID
	RETURN
END

SELECT * FROM #outputList


	UPDATE requestApiLogOther SET 
			errorCode = '0'
		,errorMsg = 'Success'			
	WHERE rowId = @apiRequestId

	
END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
ROLLBACK TRAN
SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, * FROM @errorTable

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_int_proc_ReconcileReport', @USERNAME, GETDATE()
END CATCH




GO
