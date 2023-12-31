USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationLogin]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* 
	exec [proc_applicationLogin] @flag = 'l', @userName ='admin', @pwd = 'admin+123',@userId = '1'
*/

CREATE PROC [dbo].[proc_applicationLogin]
	  @flag                         VARCHAR(50)		
     ,@userId						VARCHAR(30)		
     ,@userName                     VARCHAR(30)		
     ,@pwd                          VARCHAR(255)	
     ,@ipAddress					VARCHAR(20)		= NULL
     ,@UserData						VARCHAR(MAX)	= NULL	
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @UserInfoDetail VARCHAR(500) ='',@USERCODE VARCHAR(30)
DECLARE @isActive CHAR(1),@isLocked CHAR(1),@lastLoginTs DATETIME,@accessMode CHAR(1)
DECLARE @IDELDAY INT,@msg varchar(500)

IF @flag = 'l' ----
BEGIN 
	
	SELECT 
		@USERCODE				= userId
		,@isActive				= ISNULL(isActive, 'N')
		,@isLocked				= ISNULL(isLocked, 'N')
		--,@loginTime				= loginTime
		--,@logoutTime			= logoutTime
		,@lastLoginTs			= lastLoginTs
		,@accessMode			= ISNULL(accessMode,'S')
	FROM applicationUsers WITH(NOLOCK)
	WHERE convert(varbinary(255),userName) = convert(varbinary(255),@userName) AND ISNULL(isDeleted, 'N') = 'N'
	AND PWD = dbo.FNAEncryptString(@pwd) AND userId = @userId
	---- AND userType = 'A'
	
	IF ISNULL(@USERCODE,'') = ''
	BEGIN
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect user name.-:::-' + @UserInfoDetail
		EXEC proc_errorHandler 1,'Invalid Username or password!',@userName
		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Invalid Username',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@IP				= @ipAddress
		RETURN;
	END
	
	IF @isActive = 'N'
	BEGIN
		EXEC proc_errorHandler 1,'User is not active.',@userName
		SET @UserInfoDetail = 'Reason = User is not active.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'User is not active',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@IP				= @ipAddress

		RETURN
	END
	
	IF @isLocked = 'Y'
	BEGIN
		EXEC proc_errorHandler 1,'Your account has been locked. Please, contact your administrator.',@userName
		SET @UserInfoDetail = 'Reason = Your account has been locked. Please, contact your administrator.-:::-'+@UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Your account has been locked',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@IP				= @ipAddress

		RETURN		
	END
	
	SELECT @IDELDAY = lockUserDays  FROM passwordFormat
	IF EXISTS(SELECT 'A' FROM applicationUsers WHERE UserName = @userName AND DATEDIFF(D,ISNULL(lastLoginTs,GETDATE()),GETDATE()) 
		> @IDELDAY AND ISNULL(@IDELDAY,0) >0   AND UserName <>'admin')
	BEGIN
		SET @msg ='User is locked,not login '+CAST(@IDELDAY AS VARCHAR)+ ' days, please contact administrator.'
		EXEC proc_errorHandler 1,@msg,@userName
		SET @UserInfoDetail = 'Reason = User is locked,not login '+CAST(@IDELDAY AS VARCHAR)+ ' days, please contact administrator.-:::-'+@UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= @msg,
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@IP				= @ipAddress

		RETURN	
	
	END
	
	UPDATE applicationUsers SET	lastLoginTs = GETDATE() WHERE  [userName] = @userName
	
	SELECT 0 ErrorCode,'Login Success!' msg
		,firstName+' '+ISNULL(middleName,'')+' '+ISNULL(lastName,'') fullName,address
		,userId,lastLoginTs,ISNULL(accessMode,'S') accessMode,isForcePwdChanged
		,null branchId,null BRANCH_NAME,a.userType
	FROM applicationUsers A WITH(NOLOCK)
	WHERE userName  = @userName AND PWD = dbo.FNAEncryptString(@pwd) 
	AND userId = @userId AND ISNULL(isDeleted, 'N') = 'N'
	
	EXEC proc_applicationLogs 
		@flag			= 'login',
		@logType		= 'Login', 
		@createdBy		= @userName, 
		@Reason			= 'Admin Login',
		@UserData		= @UserData,
		@fieldValue		= @UserInfoDetail,
		@IP				= @ipAddress
	RETURN
	
END	

GO
