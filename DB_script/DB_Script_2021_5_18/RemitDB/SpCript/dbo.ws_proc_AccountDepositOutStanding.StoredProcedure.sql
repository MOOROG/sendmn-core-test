USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_AccountDepositOutStanding]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ws_proc_AccountDepositOutStanding] (	 
	@ACCESSCODE				VARCHAR(50),
	@USERNAME				VARCHAR(50),
	@PASSWORD				VARCHAR(50),
	@AGENT_SESSION_ID		VARCHAR(150)
)

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY


DECLARE @errCode INT
DECLARE @autMsg	VARCHAR(500)

EXEC ws_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT, @autMsg OUT

DECLARE @errorTable TABLE (
	 AGENT_SESSION_ID VARCHAR(150)
	,CONTROLNO INT
	,SENDAGENT INT
	,SENDERNAME VARCHAR(200)
	,SENDERADDRESS VARCHAR(10)
	,SENDER_MOBILE VARCHAR(10)
	,SENDERCITY VARCHAR(10)
	,SENDERCOUNTRY VARCHAR(10)
	,RECEIVERNAME VARCHAR(10)
	,RECEIVERADDRESS varchar(10)
	,RECEIVERPHONE VARCHAR(10)
	,RECEIVERCITY VARCHAR(10)
	,RECEIVERCOUNTRY VARCHAR(10)
	,TRANSFERAMOUNT MONEY
	,SCURRCOSTRATE FLOAT
	,RCURRCOSTRATE FLOAT
	,PAYOUTAMT MONEY
	,PAYOUTCURRENCY VARCHAR(3)
	,PAYMENTTYPE VARCHAR(10)
	,BANKNAME VARCHAR(10)
	,BANKBRANCH VARCHAR(10)
	,BANKACCOUNTNO VARCHAR(10)
	,BANKCODE VARCHAR(10)
	,BANKBRANCHCODE varchar(10)
	,TRNDATE varchar(10)
	,DOWNLOAD_TOKENID INT
	,ISLOCAL VARCHAR(5)
	,TRANID VARCHAR(50)
	,RECEIVERMOBILE VARCHAR(50)
)

INSERT INTO @errorTable(AGENT_SESSION_ID) SELECT @AGENT_SESSION_ID

IF (@errCode = 1)
BEGIN
	SELECT
		'1002' CODE
		,ISNULL(@autMsg,'Authentication Fail') MESSAGE
		,* 
	FROM @errorTable
	RETURN
END
IF EXISTS(
	SELECT 'x' FROM applicationUsers WITH (NOLOCK) 
	WHERE userName = @USERNAME AND forceChangePwd = 'Y')
BEGIN
	SELECT 
		'1002' CODE
		,'You are required to change your password!' MESSAGE
		,* 
	FROM @errorTable
	RETURN
END
------------------VALIDATION-------------------------------
IF @AGENT_SESSION_ID IS NULL
BEGIN
	SELECT 
		'1001' CODE
		,'AGENT SESSION ID Field is Required' MESSAGE
		,* 
	FROM @errorTable
	RETURN;
END

DECLARE		
	 @pCountryId		INT
	,@pAgent			INT
	,@pBranch			INT
	,@pBranchMapCode	VARCHAR(10)
	,@tranId			INT
	,@tranStatus		VARCHAR(50)
	,@psAgent			INT

-- PICK AGENTID ,COUNTRY FROM USER
SELECT 
	@pCountryId = countryId,
	@pBranch = agentId 
FROM applicationUsers WITH(NOLOCK)
WHERE userName = @USERNAME AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'Y') <> 'N'

SELECT @pAgent = parentId FROM agentMaster WITH(NOLOCK) 
WHERE agentId = @pBranch AND ISNULL(isActive, 'Y') <> 'N' AND ISNULL(isDeleted, 'N') = 'N'

SELECT @psAgent = parentId FROM agentMaster WITH(NOLOCK) 
WHERE agentId = @pAgent AND ISNULL(isActive, 'Y') <> 'N' AND ISNULL(isDeleted, 'N') = 'N'


IF @pAgent IS NULL
BEGIN
	SELECT '1001' CODE, 'Invalid Agent Code' [Message], * FROM @errorTable
	RETURN
END

DECLARE
	 @msg VARCHAR(100)
	,@lockInMinutes INT
	,@payTokenId BIGINT 


/*	
SELECT TOP 1 
	 @lockInMinutes = DATEDIFF(MINUTE, lockedDate, GETDATE())
	,@payTokenId = payTokenId
FROM remitTran WITH (NOLOCK) 
WHERE pAgent = @pBranch 
	AND payStatus = 'Unpaid' 
	AND tranStatus = 'Lock'	
	AND paymentMethod = 'BANK DEPOSIT'		
	ORDER BY lockedDate
---------------------------------------------------------------------
IF @lockInMinutes IS NOT NULL
BEGIN
	UPDATE remitTran SET 
		 tranStatus = 'Payment'
		,payTokenId = NULL
	WHERE pAgent = @pBranch 
		AND payStatus = 'Unpaid' 
		AND tranStatus = 'Lock'				
		AND DATEDIFF(MINUTE, lockedDate, GETDATE()) >= 1
END
---------------------------------------------------------------------
*/

DECLARE @controlNoTable TABLE(controlNo VARCHAR(50))

INSERT INTO @controlNoTable(controlNo)
SELECT TOP 200 controlNo FROM remitTran WITH(NOLOCK) 
WHERE pAgent = @pAgent AND payStatus = 'Unpaid' AND tranStatus = 'Payment' AND paymentMethod = 'Bank Deposit'
--AND 1 = 2
AND tranType IN('I','O','M')

--SELECT @pAgent
IF NOT EXISTS(SELECT TOP 1 'X' FROM @controlNoTable)
BEGIN
	SELECT '2003' CODE, 'No transaction found to download' [Message], * FROM @errorTable
	RETURN
END

SET @payTokenId = LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR) + '00000000000', 10)

--print @pAgentMapCode

UPDATE remitTran SET 
	 payTokenId	= @payTokenId
	,pAgentComm	= (SELECT amount FROM dbo.FNAGetPayComm
					(rt.sBranch,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = rt.sCountry), 
						NULL, @psAgent, @pCountryId, null, @pBranch, rt.sAgentCommCurrency
						,(select serviceTypeId from servicetypemaster(nolock) where typeTitle = rt.paymentMethod)
						, rt.cAmt, rt.pAmt, rt.serviceCharge, NULL, NULL
					))
	,pAgentCommCurrency	= rt.sAgentCommCurrency
FROM remitTran rt
INNER JOIN @controlNoTable ct ON rt.controlNo = ct.controlNo

SELECT 
	CODE				= 0,
	AGENT_SESSION_ID	= @AGENT_SESSION_ID,
	MESSAGE				= 'Success',
	CONTROLNO			= dbo.FNADecryptString(RT.controlNo),
	SENDAGENT			= RT.sAgent,
	SENDERNAME			= RT.senderName,
	SENDERADDRESS		= ISNULL(TS.address,TS.address2),
	SENDER_MOBILE		= ISNULL(TS.mobile,TS.homePhone),
	SENDERCITY			= TS.city,
	SENDERCOUNTRY		= RT.sCountry,
	RECEIVERNAME		= RT.receiverName,
	RECEIVERADDRESS		= ISNULL(TR.address,TR.address2),
	RECEIVERPHONE		= ISNULL(TR.homePhone,TR.mobile),
	RECEIVERCITY		= TR.city,
	RECEIVERCOUNTRY		= UPPER(RT.pCountry),
	TRANSFERAMOUNT		= RT.tAmt,
	SCURRCOSTRATE		= RT.sCurrCostRate,
	RCURRCOSTRATE		= RT.pCurrCostRate,
	PAYOUTAMT			= RT.pAmt,
	PAYOUTCURRENCY		= RT.payoutCurr,
	PAYMENTTYPE			= UPPER(RT.paymentMethod),
	BANKNAME			= RT.pBankName,
	BANKBRANCH			= RT.pBankBranchName,
	BANKACCOUNTNO		= RT.accountNo,
	BANKCODE			= RT.pBank,
	BANKBRANCHCODE		= AG.extCode,
	TRNDATE				= RT.approvedDate,
	DOWNLOAD_TOKENID	= @payTokenId,
	RECEIVERMOBILE		= TR.mobile,
	ISLOCAL				= CASE WHEN tranType ='D' THEN 'P' ELSE 'R' END ,
	TRANID				= RT.id
 FROM remitTran RT WITH (NOLOCK) 
 LEFT JOIN agentMaster AG WITH (NOLOCK) ON RT.pBankBranch = AG.agentId 
 INNER JOIN tranSenders TS WITH (NOLOCK) ON RT.id = TS.tranId
 INNER JOIN tranReceivers TR WITH (NOLOCK) ON RT.id = TR.tranId
 INNER JOIN @controlNoTable cn ON cn.controlNo = RT.controlNo

END TRY
BEGIN CATCH

SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_AccountDepositOutStanding',@USERNAME, GETDATE()

END CATCH






GO
