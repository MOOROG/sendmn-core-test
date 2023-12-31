USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_checkAuthntication]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---EXEC proc_checkAuthntication 'admin','1swift+9','1001'


CREATE procEDURE [dbo].[proc_checkAuthntication]
	@userName	VARCHAR(100),
	@pwd		VARCHAR(100),
	@agentCode		VARCHAR(100),
	@errCode	INT =NULL  OUTPUT

AS
BEGIN TRY

	DECLARE @agentId INT,@userId INT,@UserInfoDetail VARCHAR(200),@UserData VARCHAR(200),@ipAddress VARCHAR(20),@attemptsCount INT
	SELECT @ipAddress=CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR)

	SELECT @userId = userId,@agentId=agentId FROM applicationUsers WHERE userName = @userName
	SET @UserData ='User:'+ @userName +', AgentCode:'+  CAST(@agentCode AS VARCHAR(20))
		
	SELECT TOP 1 
		@agentId = agentId
	FROM agentMaster WITH(NOLOCK)
	WHERE agentId IN (
		SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName
	)
		
	IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName)
	BEGIN
			--SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect user name.-:::-'+@UserInfoDetail

		EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Invalid Username',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress	
						
			SET @errCode= '1' 
			RETURN		
		END
		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE userName = @userName 
						AND pwd = dbo.FNAEncryptString(@pwd) AND agentCode = @agentCode 
						AND ISNULL(isActive, 'N') = 'N'
				)
		BEGIN
			--SELECT 1 errorCode, 'User has not been approved.' mes, @userName id
			SET @UserInfoDetail = 'Reason = User has not been approved.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='User has not been approved',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress			
			
			SET @errCode= '1' 
			RETURN	
			
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
			 AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			--SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, User is not Active.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='User is not Active',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress			
			
			SET @errCode= '1' 
			RETURN		
		END
    
		SELECT TOP 1 @attemptsCount = loginAttemptCount FROM passwordFormat WITH(NOLOCK)
    
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y')
		BEGIN
			--SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id, @attemptsCount ac
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect password.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Incorrect password',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress		
			
			SET @errCode= '1' 
			RETURN		
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y' 
		  AND agentCode = @agentCode)
		BEGIN
			--SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id, @attemptsCount ac
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect AgentCode.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Incorrect AgentCode',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress		
			
			SET @errCode= '1' 
			RETURN		
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y' 
		  AND agentCode = @agentCode --AND employeeId = @employeeId 
		  )
		BEGIN
			--SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id, @attemptsCount ac
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect userId.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Incorrect userId',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress		
			
			SET @errCode= '1' 
			RETURN		
		END

		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) AND agentCode = @agentCode 
		  --AND employeeId = @employeeId 
		  AND ISNULL(isLocked, 'N') = 'Y')
		BEGIN
			--SELECT 1 errorCode, 'Your account has been locked. Please, contact your administrator.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Your account has been locked. Please, contact your administrator.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Your account has been locked',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress		
			
			SET @errCode= '1' 
			RETURN;		
		END	
	
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE userName = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) AND agentCode = @agentCode 
		  --AND employeeId = @employeeId 
		  AND ISNULL(isDeleted, 'N') <> 'Y' 
		  AND CAST(GETDATE() AS TIME) > loginTime AND CAST(GETDATE() AS TIME) < logoutTime)
		BEGIN

			--SELECT 1 errorCode, 'You are not permitted to login at this time. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
			
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login at this time',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress	
			
			SET @errCode= '1' 
			RETURN
		END

		IF EXISTS(select top 1 'y' from userLockDetail 
				where userId =@userId and GETDATE() between startDate 
				and convert(varchar(20), endDate,101) +' 23:59:59' 
				and isnull(isDeleted,'N')='N')
		BEGIN

			--SELECT 1 errorCode, 'You are not permitted to login for this date. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
			
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login for this date',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress	
			
			SET @errCode= '1' 
			RETURN
		END

	    -- Last Login date check for Locking
	    IF EXISTS(select 'X' from applicationUsers 
			 where userId =@userId and
			 datediff (DAY,lastLoginTs,GETDATE())>=
			 (select top 1 isnull(lockUserDays,30) from passwordFormat 
				where isnull(isActive,'N')='Y')
		)
		BEGIN
			
			update applicationUsers set 
				 isLocked='Y'
				,lastLoginTs=dbo.FNAGetDateInNepalTZ()
			where userId = @userId

			--SELECT 1 errorCode, 'You are locked this time. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are locked this time. Please, contact your administrator.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not Login for fix period, now user is locked',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress	
			
			INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
			SELECT @userName, 'Your account has been locked due to not login for fix period', 'system', GETDATE()
			
			SET @errCode= '1' 
			RETURN;

		END

		IF EXISTS(SELECT TOP 1 'Y' FROM userLockDetail 
				WHERE userId =@userId and GETDATE() between startDate 
				AND CONVERT(VARCHAR(20), endDate,101) +' 23:59:59' 
				AND ISNULL(isDeleted,'N')='N'
	     )
		BEGIN

			--SELECT 1 errorCode, 'You are not permitted to login for this date. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
			
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login for this date',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress	
			
			SET @errCode= '1' 
			RETURN;
		END
		--------------------------------IF SUCCESS
		----UPDATE applicationUsers SET	
		----		lastLoginTs = dbo.FNAGetDateInNepalTZ()
		----	WHERE  [userName]= @userName
	
	--EXEC proc_applicationUsers @flag = 'userDetail', @userName = @userName
			--Audit data starts
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login', 
				@createdBy = @userName, 
				@Reason='Agent Login',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId,
				@IP = @ipAddress
			--Audit data ends	
		SET @errCode= '0' 
		RETURN

END TRY
BEGIN CATCH
	SET @errCode='1' 
END CATCH	
	


GO
