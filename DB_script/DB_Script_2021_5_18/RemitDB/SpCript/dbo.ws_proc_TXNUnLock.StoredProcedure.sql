USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_TXNUnLock]    Script Date: 5/18/2021 5:17:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ws_proc_TXNUnLock](	 
		@ACCESSCODE			VARCHAR(50),
		@USERNAME			VARCHAR(50),
		@PASSWORD			VARCHAR(50),
		@REFNO				VARCHAR(20),
		@AGENT_SESSION_ID	VARCHAR(150),
		@PAY_TOKEN_ID		BIGINT = NULL
)

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


BEGIN TRY


DECLARE @errCode INT,@controlNoEnc VARCHAR(50) = dbo.FNAENcryptString(@REFNO)
EXEC ws_proc_checkAuthntication @USERNAME,@PASSWORD,@ACCESSCODE,@errCode OUT

	IF (@errCode=1 )
	BEGIN
		SELECT 1002 CODE, 'Authentication Fail' MESSAGE
			,AGENT_SESSION_ID	= @AGENT_SESSION_ID
		RETURN
	END
	IF EXISTS(SELECT 'A' FROM applicationUsers WITH (NOLOCK) WHERE 
			userName = @USERNAME AND forceChangePwd = 'Y')
	BEGIN
			SELECT '1002' CODE
				, 'You logged on first time,must first change your password and try again!' MESSAGE
				,AGENT_SESSION_ID	= @AGENT_SESSION_ID
			RETURN
	END
	------------------VALIDATION-------------------------------
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE,'AGENT SESSION ID Field is Required' MESSAGE
				,AGENT_SESSION_ID	= @AGENT_SESSION_ID	
		RETURN;
	END
	IF @REFNO IS NULL
	BEGIN
		SELECT '1001' CODE,'REFNO Field is Required' MESSAGE
				,AGENT_SESSION_ID	= @AGENT_SESSION_ID
		RETURN;
	END
	IF @REFNO IS NOT NULL AND ISNUMERIC(@REFNO)=0
	BEGIN
		SELECT '2003' CODE
		,'Technical Error: PINNO must be numeric' MESSAGE
				,AGENT_SESSION_ID	= @AGENT_SESSION_ID
		RETURN;
	END

	IF @PAY_TOKEN_ID IS NULL
	BEGIN
		SELECT 1001 CODE,'PAY TOKEN ID Field is Required' MESSAGE
				,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN;
	END
	
	DECLARE	@pCountry		VARCHAR(50), 
			@pBranch		INT,
			@pAgent			INT,
			@tranId			INT,
			@tranStatus		VARCHAR(30),
			@tokenId		VARCHAR(40),
			@userCountry	VARCHAR(50),
			@LockedBy	VARCHAR(50),
			@lockStatus VARCHAR(20)
  
	-- PICK AGENTID ,COUNTRY FROM USER
	SELECT @pBranch = agentId,@userCountry = countryId FROM applicationUsers WHERE userName = @USERNAME
	
	SELECT @userCountry = countryName from countryMaster WITH(NOLOCK) where countryId=@userCountry

	SELECT @tranId = id,
			@tranStatus = tranStatus,
			@tokenId = payTokenId,
			@pAgent	 = pAgent,
			@pCountry	= pCountry,
			@LockedBy = lockedBy,
			@lockStatus = lockStatus
	FROM remitTran WITH (NOLOCK) WHERE controlNo = @controlNoEnc 
		--AND ISNULL(pAgent,@pAgent ) = @pAgent 
	
	IF @lockStatus IS NULL
	BEGIN
		SELECT '2003' CODE,'Invalid Transaction' MESSAGE
				,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
	
	IF @pCountry <> @userCountry 
	BEGIN
		SELECT '2003' CODE,'You are not authorized to view this transaction' MESSAGE
				,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
     
     IF @LockedBy <> @USERNAME 
	BEGIN
		SELECT '2003' CODE,'You are not authorized to view this transaction' MESSAGE
				,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN;
	END
	
	--IF @tokenId IS NULL OR ISNULL(@PAY_TOKEN_ID,0) <> @tokenId
	--BEGIN
	--	SELECT 1007 CODE,'Invalid TokenID' MESSAGE
	--			,@AGENT_SESSION_ID AGENT_SESSION_ID
	--	RETURN
	--END

	IF NOT EXISTS(SELECT 'A' FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch AND agentCountry = @pCountry)
	BEGIN
		SELECT '2001' CODE,'Transaction is not in Authorized Mode' MESSAGE
				,@AGENT_SESSION_ID AGENT_SESSION_ID
				,Confirm_ID		= NULL
				,REFNO			= @REFNO
		RETURN
	END
	IF (@lockStatus <> 'locked')
	BEGIN
		SELECT '2003' CODE,'Transaction is not locked' MESSAGE
				,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
	IF (@tranStatus = 'Block')
	BEGIN
		SELECT '2004' CODE, 'Error while making a payment (need to contact Head office)' MESSAGE
			,@AGENT_SESSION_ID AGENT_SESSION_ID
		RETURN
	END
--#############################
	
	UPDATE remitTran SET 
			 lockStatus			='unlocked'
			,lockedBy			= null
			,lockedDate			= NULL
			,lockedDateLocal	= NULL
			,payTokenId			= NULL
	WHERE id = @tranId and lockStatus = 'locked'
	--AND ISNULL(pAgent,@pAgent ) = @pAgent 
    
     SELECT
	  CODE				= 0	,
	  AGENT_SESSION_ID	= @AGENT_SESSION_ID	,
	MESSAGE				= 'Transaction unlocked successfully'	

    INSERT INTO apiRequestLog(AGENT_CODE, USER_ID, PASSWORD, AGENT_SESSION_ID, 
	   controlNo, REQUESTED_DATE, errorMsg, errorCode)
    SELECT @ACCESSCODE, @USERNAME, @PASSWORD, @AGENT_SESSION_ID, 
    @REFNO, GETDATE(), 'Unlocked',@tokenId 


END TRY
BEGIN CATCH

DECLARE @errorLogId BIGINT
INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
SELECT 'API SP Error', 'Technical Error : ' + ERROR_MESSAGE() MESSAGE, 'ws_proc_TXNUnLock', 'admin', GETDATE()
SET @errorLogId = SCOPE_IDENTITY()

SELECT '9001' CODE, 'Technical Error occurred, Error Log Id : ' + CAST(@errorLogId AS VARCHAR) MESSAGE, @AGENT_SESSION_ID AGENT_SESSION_ID

END CATCH

--EXEC ws_proc_TXNUnLock  @ACCESSCODE = 'IMEPH01', @USERNAME = 'clapiuser01', @PASSWORD = 'ime1212', @REFNO = '90401774056', @AGENT_SESSION_ID = '32323423424', @PAY_TOKEN_ID = '1010968726733094016'

 --EXEC ws_proc_TXNUnLock @ACCESSCODE='IMEPH01',@USERNAME='clapiuser01',@PASSWORD='ime1212',@AGENT_SESSION_ID='1234567',@REFNO='90401774056',@PAY_TOKEN_ID='373512466431898496'
GO
