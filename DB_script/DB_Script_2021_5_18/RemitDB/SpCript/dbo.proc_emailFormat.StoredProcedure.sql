USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_emailFormat]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM remitTran
EXEC proc_cancelTran @flag = 'details', @user = 'shree_b1', @controlNo = '91191505349'

*/

CREATE proc [dbo].[proc_emailFormat] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(50)		= NULL
	,@filterKey			VARCHAR(50)		= NULL
	,@message			VARCHAR(MAX)	= NULL
	,@user				VARCHAR(50)		= NULL
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON
/*
		DECLARE @subject VARCHAR(MAX), @body VARCHAR(MAX)
		EXEC proc_parseEmailTemplate 9, NULL, 'bharat', 'Cancel', @subject OUTPUT, @body OUTPUT
		EXEC proc_emailFormat @flag='C',@filterKey='1',@message='TESTED MSG',@user='ADMIN'
*/

DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

IF @flag = 'Trouble' --## CANCEL EMAIL FORMAT
BEGIN
	--EXEC proc_emailFormat @flag = 'c', @filterKey = 4000, @message = 'Change sender name'
	DECLARE @subject VARCHAR(MAX), @body VARCHAR(MAX),@agentName varchar(200), @sBranch INT, @sAgent INT
	SELECT 
		 smtpServer
		,smtpPort
		,sendID
		,sendPSW 
	FROM emailServerSetup
	
	SELECT @sBranch = sBranch, @sAgent = sAgent, @controlNoEncrypted = controlNo FROM remitTran WITH(NOLOCK) WHERE id = @filterKey 
	
	SELECT  
		 name
		,email
	FROM SystemEmailSetup WHERE ISNULL(isTrouble, 'No') = 'Yes' AND (agent = dbo.FNAGetHOAgentId() OR agent = @sAgent)
	
	EXEC proc_parseEmailTemplate @sBranch, @controlNoEncrypted, @user, 'Trouble', @subject, @body, @message 
END	

IF @flag = 'Cancel'
BEGIN
	SELECT 
		 smtpServer
		,smtpPort
		,sendID
		,sendPSW 
	FROM emailServerSetup
	
	SELECT @sBranch = sBranch, @sAgent = sAgent FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	
	SELECT  
		 name
		,email
	FROM SystemEmailSetup WHERE ISNULL(isCancel, 'No') = 'Yes' AND (agent = dbo.FNAGetHOAgentId() OR agent = @sAgent) 
	/*
	UNION ALL
	SELECT
		 userName
		,email
	FROM applicationUsers WHERE agentId = @sBranch AND ISNULL(isActive, 'N') = 'Y'
	*/
 
	EXEC proc_parseEmailTemplate @sBranch, @controlNoEncrypted, @user, 'Cancel', @subject, @body, NULL 
END

ELSE IF @flag = 'PwdReset'
BEGIN
	--EXEC proc_emailFormat @flag = 'PwdReset', @filterkey = 'prabhu'
	SELECT
		 smtpServer
		,smtpPort
		,sendID
		,sendPSW
	FROM emailServerSetup
	
	SELECT
		 username
		,email
	FROM applicationUsers WITH(NOLOCK) WHERE userName = @filterKey
	
	EXEC proc_parseEmailTemplate NULL, NULL, @filterKey, 'Reset Password', @subject, @body, NULL
END
-----------------------------------------------------------------------------------------------------------------

GO
