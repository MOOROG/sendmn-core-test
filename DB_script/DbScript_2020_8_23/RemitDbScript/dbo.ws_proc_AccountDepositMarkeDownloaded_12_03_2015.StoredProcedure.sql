USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_AccountDepositMarkeDownloaded_12_03_2015]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ws_proc_AccountDepositMarkeDownloaded_12_03_2015] (	 
	@ACCESSCODE			VARCHAR(50),
	@USERNAME			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(50),
	@DOWNLOAD_TOKENID	VARCHAR(50)
)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY


	DECLARE @errCode INT
     DECLARE @count INT 

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
			,'You logged on first time,must first change your password and try again!' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
	------------------VALIDATION-------------------------------
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT 
			 '1001' CODE
			,'AGENT SESSION ID Field is Empty' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN;
	END
	IF @DOWNLOAD_TOKENID IS NULL
	BEGIN
		SELECT 
			 '1001' CODE
			,'DOWNLOAD TOKENID Field is Empty' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN;
	END
	
	DECLARE		
		 @pCountryId INT
		,@pAgent INT
		,@pBranch INT
		,@tranId INT
		,@tranStatus VARCHAR(50)
		,@pAgentMapCode VARCHAR(10)

	-- PICK AGENTID ,COUNTRY FROM USER
	SELECT 
		@pCountryId		= countryId,
		@pAgentMapCode	= A.mapCodeInt,
		@pAgent			= A.agentId
	FROM applicationUsers U WITH(NOLOCK) 
	JOIN agentMaster B WITH(NOLOCK) ON U.agentId = B.agentId
	JOIN agentMaster A WITH(NOLOCK) ON B.parentId = A.agentId
	WHERE userName = @USERNAME
	
 
    --SELECT top 10 * FROM irh_ime_plus_01.dbo.moneySend WITH (NOLOCK) 
    --WHERE paymentType = 'Bank transfer'
    --print @pAgentMapCode
	
	DECLARE @controlNoTable TABLE(controlNo VARCHAR(50))
	INSERT INTO @controlNoTable(controlNo)
	SELECT controlNo FROM remitTran WITH(NOLOCK) 
	WHERE  pAgent = @pAgent 
		AND payTokenId = @DOWNLOAD_TOKENID 
		AND payStatus = 'Unpaid' 
		AND tranStatus = 'Payment'
		AND paymentMethod = 'Bank Deposit'
	
	IF NOT EXISTS(SELECT TOP 1 'X' FROM @controlNoTable)
	BEGIN
		SELECT 
			 '1004' CODE
			,'There are no Transaction with the given Token ID to be set as Downloaded' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
	

	UPDATE remitTran SET
		 payStatus = 'Post'
	FROM remitTran rt
	INNER JOIN @controlNoTable cn ON rt.controlNo = cn.controlNo
	

	--UPDATE irh_ime_plus_01.dbo.moneySend SET
	--	 status			= 'Post'
	--	,downloaded_by	= @USERNAME
	--	,downloaded_ts	= GETDATE()
	--FROM irh_ime_plus_01.dbo.moneySend ms
	--INNER JOIN @controlNoTable cn ON ms.refno = cn.controlNo

     SET @count = @@ROWCOUNT

	SELECT
	 0 CODE
	,@AGENT_SESSION_ID AGENT_SESSION_ID
	,CAST(@count AS VARCHAR(10)) + ' transaction(s) downloaded'	MESSAGE


END TRY
BEGIN CATCH

SELECT '9001' CODE, 'Technical Error : ' + ERROR_MESSAGE() MESSAGE

INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_AccountDepositMarkeDownloaded',@USERNAME, GETDATE()

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
