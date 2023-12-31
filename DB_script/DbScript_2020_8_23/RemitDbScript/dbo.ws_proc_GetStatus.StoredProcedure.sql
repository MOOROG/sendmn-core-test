USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_GetStatus]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC [ws_proc_GetStatus]
@ACCESSCODE='BRNNP1112'
,@USERNAME='testeverest'
,@PASSWORD='testeverest@123'
,@REFNO='77715967714B'
,@AGENT_SESSION_ID='12310023'

*/

CREATE PROC [dbo].[ws_proc_GetStatus] (	 
	@ACCESSCODE		VARCHAR(50),
	@USERNAME		VARCHAR(50),
	@PASSWORD		VARCHAR(50),
	@REFNO			VARCHAR(20),
	@AGENT_SESSION_ID  VARCHAR(150)
)

AS

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @errCode INT,@controlNoEnc VARCHAR(50) = dbo.FNAENcryptString(@REFNO)
DECLARE @autMsg	VARCHAR(500)
EXEC ws_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT, @autMsg OUT

 DECLARE @errorTable TABLE(
	 AGENT_SESSION_ID VARCHAR(150)
	,REFNO VARCHAR(50)
	,SENDER_NAME VARCHAR(100)
	,RECEIVER_NAME VARCHAR(100)
	,PAYOUTAMT MONEY
	,PAYOUTCURRENCY VARCHAR(3)
	,STATUS VARCHAR(30)
	,STATUS_DATE VARCHAR(20)
	,PAY_TOKEN_ID INT
)

INSERT INTO @errorTable(AGENT_SESSION_ID) 
SELECT @AGENT_SESSION_ID

IF(@errCode = '1')
BEGIN
	SELECT '1002' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, * FROM @errorTable
	RETURN
END

IF EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userName = @USERNAME AND forceChangePwd = 'Y')
BEGIN
	SELECT '1002' CODE, 'You logged on first time,must first change your password and try again!' MESSAGE, * FROM @errorTable
	RETURN
END
------------------VALIDATION-------------------------------
IF @REFNO IS NULL
BEGIN
	SELECT '1001' CODE,'REFNO Field is Required' MESSAGE,* FROM @errorTable
	RETURN;
END
--IF ISNUMERIC(@REFNO) = 0 AND @REFNO IS NOT NULL
--BEGIN
--	SELECT '2003' CODE,'Technical Error: REFNO must be numeric' MESSAGE	,* FROM @errorTable
--	RETURN;
--END
IF @AGENT_SESSION_ID IS NULL
BEGIN
	SELECT '1001' CODE,'AGENT SESSION ID Field is Required' MESSAGE,* FROM @errorTable
	RETURN;
END

DECLARE		
	 @pAgent		INT
	,@agentName		VARCHAR(100)
	,@tranId		INT
	,@pAgentTran	INT
	,@tranStatus	VARCHAR(50)
	,@pCountry		VARCHAR(100)
	,@userCountry	VARCHAR(100)
	,@paidBy		VARCHAR(50)
	,@status		VARCHAR(50)


--PICK AGENTID ,COUNTRY FROM USER
SELECT
	 @pAgent		= ap.agentId
	,@userCountry	= cm.countryName
	,@agentName		= ap.agentName + ' - ' + am.agentName
FROM applicationUsers au WITH(NOLOCK)
INNER JOIN countryMaster cm WITH(NOLOCK) ON au.countryId = cm.countryId
LEFT JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
LEFT JOIN agentMaster ap WITH(NOLOCK) ON am.parentId = ap.agentId
WHERE userName = @USERNAME and isnull(au.isActive,'')='Y'

SELECT	
	 @tranId		= id
	,@tranStatus	= tranStatus
	,@pCountry		= pCountry
	,@pAgentTran	= pAgent
	,@paidBy		= paidBy
	,@status		= payStatus
FROM vwRemitTran WITH(NOLOCK)
WHERE controlNo = @controlNoEnc

IF @tranStatus IS NULL
BEGIN
	SELECT '2003' CODE,'Transaction Not Found RefNo : ' + @REFNO MESSAGE, * FROM @errorTable
	RETURN
END

IF @pCountry <> @userCountry
BEGIN
	SELECT '2005' CODE,'You are not authorized to view this transaction' MESSAGE, * FROM @errorTable
	RETURN
END

IF (@pAgentTran IS NOT NULL AND @pAgentTran <> @pAgent)
BEGIN
	SELECT '2005' CODE	,'You are not authorized to view this transaction' MESSAGE, * FROM @errorTable
	RETURN
END

IF @paidBy <> @USERNAME AND @status = 'paid'
BEGIN
	SELECT '2001' CODE	,'Transaction is already paid' MESSAGE, * FROM @errorTable
	RETURN
END

IF @tranStatus IS NOT NULL
BEGIN
	INSERT INTO tranViewHistory(
		 controlNumber
		,tranViewType
		,agentId
		,createdBy
		,createdDate
		,tranId
		,dcInfo
	)
	
	SELECT
		 @controlNoEnc
		,'Search'
		,@pAgent
		,@USERNAME
		,GETDATE()
		,@tranId
		,'API : ' + @USERNAME + '(' + @agentName + ')'
END

SELECT 
	 CODE				= 0
	,AGENT_SESSION_ID	= @AGENT_SESSION_ID 
	,MESSAGE			= 'TXN Summary'	
	,REFNO				= @REFNO	
	,SENDER_NAME		= RT.SenderName 
	,RECEIVER_NAME		= RT.ReceiverName 
	,PAYOUTAMT			= RT.pAmt 
	,PAYOUTCURRENCY		= RT.payoutCurr 
	,STATUS				= CASE WHEN RT.lockStatus = 'locked' THEN 'Locked'
							WHEN RT.tranStatus LIKE '%Hold%' THEN 'Hold'
							WHEN RT.tranStatus IN ('OFAC', 'Compliance', 'OFAC/Compliance') THEN 'Compliance'
							WHEN RT.tranStatus = 'Payment' AND RT.payStatus = 'Post' THEN 'Post'
							WHEN RT.tranStatus = 'Payment' AND RT.payStatus = 'Unpaid' THEN 'Unpaid' 
							ELSE RT.tranStatus END
	,STATUS_DATE		= CASE WHEN RT.tranStatus = 'Paid' THEN RT.paidDate WHEN RT.tranStatus = 'Cancel' THEN RT.cancelApprovedDate END
	,PAY_TOKEN_ID		= payTokenId
FROM vwRemitTran RT WITH (NOLOCK) 
WHERE controlNo = @controlNoEnc 
 
/*

EXEC ws_proc_GetStatus   
 @ACCESSCODE = 'MF1986', 
 @USERNAME = 'imetest', 
 @PASSWORD = 'ime@1111', 
 @REFNO = '30137052786',
  @AGENT_SESSION_ID = '3563'

  SELECT	
	 id
	,tranStatus
	,pCountry
	,pAgent
	,pbranch
FROM remitTran WITH (NOLOCK) 
WHERE controlNo = dbo.FNAENcryptString('99991867251') 


SELECT 
	au.agentId 
	,cm.countryName
FROM applicationUsers au WITH(NOLOCK)
INNER JOIN countryMaster cm WITH(NOLOCK) ON au.countryId = cm.countryId
WHERE userName = 'testdhaka'

SELECT * FROM agentMaster where agentID = 2236 OR agentId = 1023
 */
 



	
GO
