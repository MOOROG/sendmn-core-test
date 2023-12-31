USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_AccountDepositMarkPaid]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ws_proc_AccountDepositMarkPaid] (	 
	@ACCESSCODE			VARCHAR(50),
	@USERNAME			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(50),
	@xml				XML
)
AS
/*

SELECT payStatus, tranStatus, pagent, * from remitTran (NOLOCK) where controlNo = dbo.encryptdb('20160070325780018')

EXEC ws_proc_AccountDepositMarkPaid   @ACCESSCODE = 'IMENPADB001', @USERNAME = 'adbapiuser', @PASSWORD = 'adb@API#user!', @AGENT_SESSION_ID = 'y5i0mhyntloih15', 
@xml = '<root><row>20160070325780018</row></root>'

DECLARE @xml XML = '<root><row>20160070325780018</row></root>'
SELECT ICN= dbo.encryptdb(p.value('(text())[01]', 'VARCHAR(100)')) FROM @xml.nodes('/root/row') n1(p)

*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY


	 DECLARE @errCode INT
     DECLARE @count INT ,@msg varchar(max)

	EXEC ws_proc_checkAuthntication @USERNAME, @PASSWORD, @ACCESSCODE, @errCode OUT

	IF (@errCode = 1)
	BEGIN
		SELECT '1002' CODE, 'Authentication Fail' MESSAGE,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
	IF EXISTS(SELECT 'A' FROM applicationUsers WITH (NOLOCK) WHERE 
			userName = @USERNAME AND forceChangePwd = 'Y')
	BEGIN
		SELECT '1002' CODE
			,'You logged on first time,must first change your password and try again' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
	------------------VALIDATION-------------------------------
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT 
			 '1001' CODE
			,'AGENT SESSION ID Field is Required' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN;
	END
	IF @xml IS NULL
	BEGIN
		SELECT 
			 '1001' CODE
			,'CONTROL NO LIST Field is Required' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN;
	END
	
	DECLARE		
		 @pCountryId INT
		,@pAgent INT
		,@pBranch INT
		,@tranId INT
		,@tranStatus VARCHAR(50)

	-- PICK AGENTID ,COUNTRY FROM USER
	SELECT 
		@pCountryId		= countryId,
		@pBranch		= agentId
	FROM applicationUsers U WITH(NOLOCK) 
	WHERE userName = @USERNAME and isnull(u.isActive,'') = 'Y'
	
	DECLARE  
	     @pAgentName varchar(200)
		,@pBranchName varchar(200)
		,@pState varchar(200)
		,@pDistrict	varchar(200)
		,@pLocation	varchar(50)
		,@psAgent int

	SELECT @pBranch=sBranch,@pBranchName = sBranchName,@pAgent = sAgent,@pAgentName = sAgentName,@psAgent=sSuperAgent
	FROM DBO.FNAGetBranchFullDetails(@pBranch)

	DECLARE @controlNoTable TABLE(controlNo VARCHAR(50),tranId BIGINT)
	INSERT INTO @controlNoTable(controlNo)
	SELECT ICN= dbo.encryptdb(p.value('(text())[01]', 'VARCHAR(100)')) FROM @xml.nodes('/root/row') n1(p)
	
	IF NOT EXISTS(SELECT 'X' FROM @controlNoTable)
	BEGIN
		SELECT 
			 '1004' CODE
			,'No record found in file.' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END

	DELETE TD FROM remitTran rt with(nolock) 
	INNER JOIN @controlNoTable td on rt.controlNo = td.controlNo
	WHERE RT.pAgent = 1036 AND (RT.payStatus ='Cancel' or rt.Transtatus ='Cancel')

	DELETE TD FROM remitTran rt with(nolock) 
	INNER JOIN @controlNoTable td on rt.controlNo = td.controlNo
	WHERE RT.pAgent = 1036 AND RT.payStatus ='Paid'

	IF EXISTS(
		SELECT 'X' FROM @controlNoTable icn
		INNER JOIN remitTran rt (NOLOCK) ON icn.controlNo = rt.controlNo 
		WHERE rt.payStatus <> 'Post' AND rt.pAgent = 1036
	)
	BEGIN
		SELECT @msg='Invalid transaction for status sync found in system: '
		SELECT @msg =@msg+ ','+ DBO.FNADecryptString(icn.controlNo) FROM @controlNoTable icn
		INNER JOIN remitTran rt (NOLOCK) ON icn.controlNo = rt.controlNo 
		WHERE rt.payStatus <> 'Post' AND rt.pAgent = 1036
		SELECT 
			 '1004' CODE
			,@msg MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END

	IF NOT EXISTS(SELECT 'X' FROM @controlNoTable)
	BEGIN
		SELECT 
			 '1004' CODE
			,'Requested transactions are already marked as paid' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END

	UPDATE remitTran SET
		 pBranch					= @pBranch
		,pBranchName				= @pBranchName
		,pState						= @pState
		,pDistrict					= @pDistrict
		,pLocation					= @pLocation
		--,pAgentComm					= (SELECT amount FROM dbo.FNAGetPayComm
		--									(rt.sBranch,(SELECT countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = rt.sCountry), 
		--										NULL, @psAgent, @pCountryId, null, @pBranch, rt.sAgentCommCurrency
		--										,(select serviceTypeId from servicetypemaster(nolock) where typeTitle = rt.paymentMethod)
		--										, rt.cAmt, rt.pAmt, rt.serviceCharge, NULL, NULL
		--									))
		--,pAgentCommCurrency			= rt.sAgentCommCurrency
		,tranStatus					= 'Paid'
		,payStatus					= 'Paid'
		,paidBy						= @USERNAME
		,paidDate					= GETDATE()
		,paidDateLocal				= GETDATE()	
	FROM remitTran rt with(nolock) 
	INNER JOIN @controlNoTable td on rt.controlNo = td.controlNo
	WHERE RT.pAgent = 1036

    SET @count = @@ROWCOUNT

	SELECT
		0 CODE
		,@AGENT_SESSION_ID AGENT_SESSION_ID
		,CAST(@count AS VARCHAR(10)) + ' transaction(s) paid'	MESSAGE

END TRY
BEGIN CATCH

SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_AccountDepositMarkPaid',@USERNAME, GETDATE()

END CATCH

/*

EXEC ws_proc_AccountDepositMarkeDownloaded
    @ACCESSCODE='',
    @USERNAME ='',
    @PASSWORD='',
    @AGENT_SESSION_ID='',
    @DOWNLOAD_TOKENID=''

*/


GO
