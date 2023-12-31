USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_ChangePassword]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ws_proc_ChangePassword]
	@AGENT_CODE			VARCHAR(50),
	@USER_ID			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@NEW_PASSWORD		VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(50)

AS
SET NOCOUNT ON;

DECLARE @errCode INT,@NEW_PASSWORDENCRYPT VARCHAR(100)
EXEC ws_proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT

	IF (@errCode=1 )
	BEGIN
		SELECT 1002 CODE
				, 'Authentication Fail' MESSAGE
				,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID 
		RETURN
	END
	----IF EXISTS(SELECT 'A' FROM applicationUsers WITH (NOLOCK) WHERE 
	----		userName = @USER_ID AND forceChangePwd = 'Y')
	----	BEGIN
	----		SELECT 1002 CODE
	----			, 'You must first change your password and try again!' MESSAGE
	----			,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID 
	----		RETURN
	----END
	
	SET @NEW_PASSWORDENCRYPT =dbo.FNAEncryptString(@NEW_PASSWORD)
	
	BEGIN
	
		IF @NEW_PASSWORD IS NULL
		BEGIN
			SELECT 1001 CODE
					,'NEW PASSWORD Field is Required' MESSAGE
					,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID 
			RETURN;
		END
		IF @AGENT_SESSION_ID IS NULL
		BEGIN
			SELECT 1001 CODE
					,'AGENT SESSION ID Field is Required' MESSAGE
					,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID 
			RETURN;
		END

		DECLARE @pwdHistoryNum INT = NULL
		DECLARE @tempPwdTable TABLE(pwd VARCHAR(50))

		SELECT @pwdHistoryNum = pwdHistoryNum FROM passwordFormat WITH(NOLOCK)
		DECLARE @sql VARCHAR(MAX)
		
		SET @sql = 'SELECT TOP ' + CAST(@pwdHistoryNum AS VARCHAR) + ' pwd FROM passwordHistory WITH(NOLOCK) WHERE userName = ''' + @USER_ID + ''' ORDER BY createdDate DESC'
		INSERT INTO @tempPwdTable
		EXEC(@sql)
		
		IF @NEW_PASSWORD = @PASSWORD
		BEGIN
			SELECT 1002 CODE
					, 'Password has been already used previously. Please enter the new one.' MESSAGE
					,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID 
			RETURN
		END

		IF @NEW_PASSWORDENCRYPT IN (SELECT pwd FROM @tempPwdTable)
		BEGIN
			SELECT 1002 CODE
					, 'Password has been already used previously. Please enter the new one.' MESSAGE
					,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID 
			RETURN
		END
		
		------Validate Password From Password Policy---------------------------------------------------------------
		IF(SELECT TOP 1 errorCode FROM dbo.FNAValidatePassword(@NEW_PASSWORD)) <> 0
		BEGIN
			SELECT '1001' CODE, errorMsg MESSAGE,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID  
				FROM dbo.FNAValidatePassword(@NEW_PASSWORD)
			RETURN
		END
		-------------------------------------------------------------------------------------------------------
		
		UPDATE applicationUsers SET
			 pwd = @NEW_PASSWORDENCRYPT
			,lastPwdChangedOn = GETDATE()
			,forceChangePwd = 'N'
		WHERE  [userName]= @USER_ID
		
		--Keep password History---------------------------------------------------------------------
		INSERT INTO passwordHistory( userName,pwd,createdDate)
		SELECT @USER_ID, @NEW_PASSWORDENCRYPT, GETDATE()
		---------------------------------------------------------------------------------------------
		
		----UPDATE irh_ime_plus_01.dbo.agentsub SET 
		----	 User_pwd			= dbo.FNAEncryptString(@pwd)
		----	,lastdateChanged	= GETDATE()
		----WHERE User_login_Id = @userName
		SELECT		CODE				= '0' 
				,	MESSAGE				=  'Your password is changed. New Password will take effect next time when login.' 
				,	AGENT_TXN_REF_ID	= @AGENT_SESSION_ID 
		
	END


--EXEC ws_proc_ChangePassword @AGENT_CODE='IMEAM01',@USER_ID='apialmirqab',@PASSWORD='apialmirqab123',@NEW_PASSWORD='ime1234',@AGENT_SESSION_ID='1234567'
--EXEC ws_proc_ChangePassword @AGENT_CODE='IMEAM01',@USER_ID='apialmirqab',@PASSWORD='ime1234',@NEW_PASSWORD='apialmirqab123',@AGENT_SESSION_ID='1234567'
GO
