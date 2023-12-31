USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_checkAuthntication]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ws_proc_checkAuthntication]
	@userName	VARCHAR(100),
	@pwd		VARCHAR(100),
	@agentCode	VARCHAR(100),
	@errCode	INT			 =	NULL	OUTPUT,
	@autMsg		VARCHAR(500) =	NULL	OUTPUT

AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY

	SELECT @userName = ISNULL(@userName, ''), @pwd = ISNULL(@pwd, ''), @agentCode = ISNULL(@agentCode, '')
	
	DECLARE @agentId INT, @userId INT, @UserInfoDetail VARCHAR(200), @UserData VARCHAR(200)
	,@ipAddress VARCHAR(20),@attemptsCount INT, @isAPIUser VARCHAR(10), @GMTDate varchar(200)
    ,@userPwd VARCHAR(50), @userAgentCode VARCHAR(50), @isActive CHAR(1), @isLocked CHAR(1), @loginTime TIME, @logoutTime TIME
    ,@lastLoginTs DATETIME, @isBranchActive CHAR(1), @isAgentActive CHAR(1)
    
    SET @GMTDate = dbo.FNADateFormatTZ(GETDATE(), @userName)
    
	SELECT @ipAddress = CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR)
    
	SELECT 
		 @userId			= userId
		,@agentId			= au.agentId
		,@isAPIUser			= accessMode
		,@userPwd			= pwd
		,@userAgentCode		= au.agentCode
		,@isActive			= ISNULL(au.isActive, 'N')
		,@isLocked			= ISNULL(isLocked, 'N')
		,@loginTime			= loginTime
		,@logoutTime		= logoutTime
		,@lastLoginTs		= lastLoginTs
		,@isBranchActive	= ISNULL(am.isActive, 'N')
		,@isAgentActive		= ISNULL(pam.isActive, 'N')
	FROM applicationUsers au WITH(NOLOCK)
	INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
	INNER JOIN agentMaster pam WITH(NOLOCK) ON am.parentId = pam.agentId
	WHERE userName = @userName AND ISNULL(au.isDeleted, 'N') = 'N'
	
	SET @UserData = 'User:' + @userName + ', AgentCode:' + CAST(@agentCode AS VARCHAR(20))
	
	IF @isAPIUser <> 'WS'
	BEGIN
		SET @UserInfoDetail = 'Reason = you do not have access.-:::-' + @UserInfoDetail
		
		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'User not allowed to access Web Service',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress
			
		SET @errCode = '1' 
		SET @autMsg = 'You do not have access to login.'
		RETURN
	END
		
	IF @userId IS NULL
	BEGIN
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect user name.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Invalid Username',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress
						
		SET @errCode = '1' 
		SET @autMsg = 'Login fails, Incorrect user name.'
		RETURN
	END
	
	IF @isActive = 'N'
	BEGIN
		SET @UserInfoDetail = 'Reason = User is not active.-:::-'+@UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'User is not active',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress			
		
		SET @errCode = '1' 
		SET @autMsg = 'User is not active'
		RETURN
		
	END
    
    IF @isBranchActive = 'N'
	BEGIN
		SET @UserInfoDetail = 'Reason = Branch is not active.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Branch is not active',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress			
		
		SET @errCode = '1' 
		SET @autMsg = 'Branch is not active'
		RETURN
	END
	
	IF @isAgentActive = 'N'
	BEGIN
		SET @UserInfoDetail = 'Reason = Agent is not active.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Agent is not active',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress		
		
		SET @errCode = '1' 
		SET @autMsg = 'Agent is not active'
		RETURN
	END
	
	SELECT TOP 1 @attemptsCount = loginAttemptCount FROM passwordFormat WITH(NOLOCK)
	
	IF @userPwd <> dbo.FNAEncryptString(@pwd)
	BEGIN
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect password.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Incorrect password',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress		
		
		SET @errCode = '1' 
		SET @autMsg = 'Login fails, Incorrect password.'
		RETURN		
	END
	
	IF @userAgentCode <> @agentCode
	BEGIN
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect AgentCode.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Incorrect AgentCode',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress		
		
		SET @errCode = '1' 
		SET @autMsg = 'Login fails, Incorrect AgentCode.'
		RETURN		
	END
	
	IF @isLocked = 'Y'
	BEGIN
		SET @UserInfoDetail = 'Reason = Your account has been locked. Please, contact your administrator.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Your account has been locked',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress		
		
		SET @errCode = '1' 
		SET @autMsg = 'Your account has been locked. Please, contact your administrator.'
		RETURN;		
	END	
	
	IF CAST(GETDATE() AS TIME) < @loginTime AND CAST(GETDATE() AS TIME) > @logoutTime
	BEGIN
		SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-' + @UserInfoDetail
		
		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Not permitted to login at this time',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress	
		
		SET @errCode = '1' 
		SET @autMsg = 'You are not permitted to login at this time1. Please, contact your administrator.'
		RETURN
	END

	IF EXISTS(SELECT TOP 1 'X' FROM userLockDetail WITH(NOLOCK)
			WHERE userId = @userId and GETDATE() BETWEEN startDate 
			AND CONVERT(VARCHAR(20), endDate,101) + ' 23:59:59' 
			AND ISNULL(isDeleted, 'N') = 'N')
	BEGIN
		SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-' + @UserInfoDetail
		
		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Not permitted to login for this date',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress	
		
		SET @errCode = '1' 
		SET @autMsg = 'You are not permitted to login at this time. Please, contact your administrator.'
		RETURN
	END

    -- Last Login date check for Locking
    IF DATEDIFF(DAY, @lastLoginTs, GETDATE()) >= (SELECT TOP 1 ISNULL(lockUserDays, 30) FROM passwordFormat WHERE ISNULL(isActive, 'N') = 'Y')
	BEGIN
		UPDATE applicationUsers SET 
			 isLocked		= 'Y'
			,lastLoginTs	= @GMTDate
		WHERE userId = @userId

		SET @UserInfoDetail = 'Reason = You are locked this time. Please, contact your administrator.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Not Login for fix period, now user is locked',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress	
		
		INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
		SELECT @userName, 'Your account has been locked due to not login for fix period', 'system', GETDATE()
		
		SET @errCode = '1' 
		SET @autMsg = 'Your account has been locked due to not login for fix period.'
		RETURN;
	END
		
	-->> ON SUCCESS
	UPDATE applicationUsers SET	
		lastLoginTs = @GMTDate
	WHERE [userName] = @userName
	
	--EXEC proc_applicationUsers @flag = 'userDetail', @userName = @userName
			--Audit data starts
			--EXEC proc_applicationLogs 
			--	@flag='login',
			--	@logType='Login', 
			--	@createdBy = @userName, 
			--	@Reason='Agent Login',
			--	@UserData = @UserData,
			--	@fieldValue = @UserInfoDetail,
			--	@agentId=@agentId,
			--	@IP = @ipAddress
			--Audit data ends	
	SET @errCode = '0' 
	SET @autMsg = 'Success'
	RETURN
END TRY
BEGIN CATCH
	SET @errCode = '1' 
	SET @autMsg = 'Authentication Fail,something went wrong !'
END CATCH

---EXEC ws_proc_checkAuthntication 'admin','1swift+9','1001'
GO
