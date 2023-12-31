USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_AccountDepositOutStanding_12_03_2015]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_proc_AccountDepositOutStanding_12_03_2015] (	 
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
		,'AGENT SESSION ID Field is Empty' MESSAGE
		,* 
	FROM @errorTable
	RETURN;
END

--SELECT 
--		1001 CODE
--		,'Please try after a while' MESSAGE
--		,* 
--	FROM @errorTable
--	RETURN;
	
DECLARE		
	 @pCountryId		INT
	,@pAgent			INT
	,@pAgentMapCode		VARCHAR(10)
	,@pBranch			INT
	,@pBranchMapCode	VARCHAR(10)
	,@tranId			INT
	,@tranStatus		VARCHAR(50)

-- PICK AGENTID ,COUNTRY FROM USER
SELECT 
	@pCountryId = countryId,
	@pBranch = agentId 
FROM applicationUsers WITH(NOLOCK)
WHERE userName = @USERNAME AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'

SELECT @pAgent = parentId, @pBranchMapCode = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
SELECT @pAgentMapCode = mapCodeInt FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent

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
SELECT controlNo FROM remitTran WITH(NOLOCK) 
WHERE pAgent = @pAgent AND payStatus = 'Unpaid' AND tranStatus = 'Payment' AND paymentMethod = 'Bank Deposit'

IF NOT EXISTS(SELECT TOP 1 'X' FROM @controlNoTable)
BEGIN
	SELECT '2003' CODE, 'No transaction found to download' [Message], * FROM @errorTable
	RETURN
END

/*
IF NOT EXISTS(
	SELECT 'x' FROM remitTran WITH (NOLOCK) 
	WHERE pAgent = @pBranch 
		AND payStatus = 'Unpaid' 
		AND tranStatus = 'Payment' 
		AND paymentMethod = 'BANK DEPOSIT'
)
BEGIN		
	IF @payTokenId IS NULL
		SET @msg = 'No Transaction found to download'
	ELSE		
		SET @msg = 'No Transaction found to download. Please try after ' + CAST(10 - @lockInMinutes AS VARCHAR) + ' minutes'		
				
	SELECT 
		2001 CODE
		,@msg MESSAGE
		,* 
	FROM @errorTable 
	RETURN
END
*/

SET @payTokenId = LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR) + '00000000000', 10)

--print @pAgentMapCode

UPDATE remitTran SET 
	 payTokenId	= @payTokenId
FROM remitTran rt
INNER JOIN @controlNoTable ct ON rt.controlNo = ct.controlNo

--UPDATE irh_ime_plus_01.dbo.moneySend SET
--	 process_id = @payTokenId
--FROM irh_ime_plus_01.dbo.moneySend ms
--INNER JOIN @controlNoTable ct ON ms.refno = ct.controlNo

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
	PAYOUTAMT			= RT.pAmt,
	PAYOUTCURRENCY		= RT.payoutCurr,
	PAYMENTTYPE			= UPPER(RT.paymentMethod),
	BANKNAME			= RT.pBankName,
	BANKBRANCH			= RT.pBankBranchName,
	BANKACCOUNTNO		= RT.accountNo,
	BANKCODE			= RT.pBank,
	BANKBRANCHCODE		= AG.extCode,
	TRNDATE				= RT.createdDate,
	DOWNLOAD_TOKENID	= @payTokenId,
	RECEIVERMOBILE		= TR.mobile,
	ISLOCAL				= CASE WHEN tranType ='D' THEN 'P' ELSE 'R' END ,
	TRANID				= RT.id
 FROM remitTran RT WITH (NOLOCK) 
 LEFT JOIN agentMaster AG WITH (NOLOCK) ON RT.pBankBranch = AG.agentId 
 INNER JOIN tranSenders TS WITH (NOLOCK) ON RT.id = TS.tranId
 INNER JOIN tranReceivers TR WITH (NOLOCK) ON RT.id = TR.tranId
 INNER JOIN @controlNoTable cn ON cn.controlNo = RT.controlNo



/*

select paymentMethod, externalBankCode, pBranch,pBankBranch, * 
from remitTran where controlNo = dbo.encryptDb('90401413417')
select extCode, * from agentMaster where agentId ='17543'


SELECT 
	CODE				= 0,
	AGENT_SESSION_ID	= @AGENT_SESSION_ID,
	MESSAGE			= 'Success',
	CONTROLNO			= dbo.FNADecryptString(ms.refno),
	SENDAGENT			= ms.agentid,
	SENDERNAME		= ms.SenderName,
	SENDERADDRESS		= ms.SenderAddress,
	SENDER_MOBILE		= ms.sender_mobile,
	SENDERCITY		= ms.SenderCity,
	SENDERCOUNTRY		= ms.SenderCountry,
	RECEIVERNAME		= ms.ReceiverName,
	RECEIVERADDRESS	= ms.ReceiverAddress,
	RECEIVERPHONE		= ms.ReceiverPhone,
	RECEIVERCITY		= ms.ReceiverCity,
	RECEIVERCOUNTRY	= ms.ReceiverCountry,
	PAYOUTAMT			= ms.TotalRoundAmt,
	PAYOUTCURRENCY		= ms.receiveCType,
	PAYMENTTYPE		= ms.paymentType,
	BANKNAME			= ms.rBankName,
	BANKBRANCH		= ms.rBankBranch,
	BANKACCOUNTNO		= ms.rBankACNo,
	BANKCODE			= ms.receiveAgentID,
	BANKBRANCHCODE		= a.ext_branch_code, --ms.rBankID,
	TRNDATE			= ms.DOT,
	DOWNLOAD_TOKENID	= @payTokenId
 FROM irh_ime_plus_01.dbo.moneySend ms WITH(NOLOCK)
	   LEFT JOIN irh_ime_plus_01.dbo.agentbranchdetail a WITH(NOLOCK) ON ms.rBankID = a.agent_branch_code 
 WHERE receiveAgentID = @pAgentMapCode
	 AND ms.Status = 'Un-paid' 
	 AND ms.TransStatus = 'Payment'
	 AND ms.paymentType = 'Bank Transfer' --Account Deposit To Other Bank
	 AND ms.process_id = @payTokenId
      
*/


END TRY
BEGIN CATCH

SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_AccountDepositOutStanding',@USERNAME, GETDATE()

END CATCH

/*

EXEC ws_proc_AccountDepositOutStanding 
    @ACCESSCODE='NSB01',
    @USERNAME='apiusernsb01',
    @PASSWORD='xvp2avq7x',
    @AGENT_SESSION_ID='123'

    SELECT * FROM irh_ime_plus_01.dbo.moneySend ms WITH(NOLOCK)
    WHERE receiveAgentID = '33300156'
	 AND ms.Status = 'Un-paid' 
	 AND ms.TransStatus = 'Payment'
	 AND ms.paymentType = 'Bank Transfer' --Account Deposit To Other Bank
	 AND ms.process_id = '11111222222'
*/


GO
