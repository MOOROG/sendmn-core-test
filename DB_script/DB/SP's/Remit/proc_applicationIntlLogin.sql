use fastmoneypro_remit
go

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[proc_applicationIntlLogin]
	  @flag							VARCHAR(50)		= NULL
     ,@userId						VARCHAR(10)		= NULL
     ,@user                         VARCHAR(30)		= NULL
     ,@userName                     VARCHAR(30)		= NULL
     ,@agentCode					VARCHAR(20)		= NULL
     ,@pwd                          VARCHAR(255)	= NULL
     ,@UserInfoDetail				VARCHAR(MAX)	= NULL
     ,@employeeId					VARCHAR(10)		= NULL
     ,@ipAddress					VARCHAR(100)	= NULL
	 ,@dcLogindcUserName			VARCHAR(MAX)	= NULL
	 ,@dcSerialNumber				VARCHAR(100)	= NULL
	 ,@dcUserName					VARCHAR(100)	= NULL
	 ,@LOGIN_COUNTRY NVARCHAR(50)					= NULL
	 ,@LOGIN_COUNTRY_CODE NVARCHAR(30)				= NULL
	 ,@LOGIN_CITY NVARCHAR(200)						= NULL 
	 ,@LOGIN_REGION NVARCHAR(200)					= NULL 
	 ,@LOGIN_LAT NVARCHAR(20)						= NULL 
	 ,@LOGIN_LONG NVARCHAR(20)						= NULL 
	 ,@LOGIN_TIMEZONE NVARCHAR(30)					= NULL 
	 ,@LOGIN_ZIPCODDE NVARCHAR(30)					= NULL 
	 ,@OTP_USED VARCHAR(10)							= NULL
	 ,@IS_OTP_ENABLED CHAR(1)						= NULL
	 ,@selectedAgentId INT							= NULL
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

	DECLARE
		 @UserData				VARCHAR(200)
		,@parentAgentId			VARCHAR(200)
		,@agentType				VARCHAR(20)
		,@actAsBranch			VARCHAR(20)
		,@lastPwdChangedOn		DATETIME
		,@forceChangePwd		CHAR(1)
		,@pwdChangeDays			VARCHAR(20)
		,@msg					VARCHAR(2000) 
		,@pwdChangeWarningDays	VARCHAR(5)
		,@agentId				INT
		 
	DECLARE 
		 @countryId				INT 
		,@country				VARCHAR(50)
		,@branch				INT
		,@branchName			VARCHAR(100)
		,@agent					INT
		,@superAgent			INT
		,@superAgentName		VARCHAR(100)
		,@mapCodeInt			VARCHAR(8)
		,@parentMapCodeInt		VARCHAR(8)
		,@agentName				VARCHAR(250)
		,@settlingAgent			INT
		,@parentId				INT
		,@mapCodeDom			VARCHAR(8)
		,@isHeadOffice			CHAR(1)
		,@superAgentId			VARCHAR(10)
		
	DECLARE 
	     @agentActiveStatus		CHAR(1)
	    ,@branchActiveStatus	CHAR(1)
		,@loginUserName			VARCHAR(100)
		,@loginPwd				VARCHAR(100)
		,@userActive			CHAR(1)
		,@loginUserAgtCode		VARCHAR(100)
		,@loginUserAgtId		VARCHAR(100)
		,@empId					VARCHAR(100)
		,@isLocked				CHAR(1)
		,@isDeleted				CHAR(1)
		,@loginTime				TIME
		,@logoutTime			TIME
		,@startDate				DATETIME
		,@endDate				DATETIME
		,@lastLoginTs			DATETIME
		,@lockUserDays			INT
		,@userDcSerialNumber	VARCHAR(100)
		,@agentLocation			INT
		,@agentGrp				INT
		,@agentEmail			VARCHAR(100)
		,@agentPhone			VARCHAR(100)
		,@invalidPwdCount		TINYINT

--## Intl Agent Login
IF @flag = 'lfai' 
BEGIN 		
	DECLARE @rowId BIGINT, @selectedAgentName VARCHAR(150)

	IF @selectedAgentId IS NOT NULL
		SELECT @selectedAgentName = AGENTNAME FROM AGENTMASTER (NOLOCK) WHERE AGENTID = @selectedAgentId

	SET @UserData ='User:' + @userName + ', UserCode:' + CAST(ISNULL(@employeeId, 'OTP ENABLED') AS VARCHAR(20)) + ', SelectedAgent:' + ISNULL(@selectedAgentName, '')
	
	SELECT 
		 @userId			= userId
		,@loginUserName		= userName
		,@userActive		= ISNULL(au.isActive, 'N')
		,@loginPwd			= pwd
		,@loginUserAgtCode	= au.agentCode
		,@loginUserAgtId	= au.agentId
		,@empId				= employeeId
		,@isLocked			= ISNULL(isLocked, 'N')
		,@loginTime			= loginTime
		,@logoutTime		= logoutTime	
		,@lastLoginTs		= lastLoginTs
		,@agentType			= am.agentType
		,@actAsBranch		= am.actAsBranch
		,@agentId			= am.agentId
		,@agentActiveStatus	= ISNULL(am.isActive, 'N')	
		,@userDcSerialNumber= dcSerialNumber
		,@agentLocation		= am.agentLocation
		,@agentGrp			 = am.agentGrp
		,@forceChangePwd		= au.forceChangePwd
		,@invalidPwdCount		= ISNULL(AU.wrongPwdCount, 0)
	FROM applicationUsers au WITH(NOLOCK)
	INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
	WHERE userName = @userName and ISNULL(au.isDeleted, 'N') = 'N'
	AND AM.AGENTCOUNTRY <> 'NEPAL'
		
	IF ISNULL(@invalidPwdCount, 0) > 3
	BEGIN
		UPDATE applicationUsers SET 
			 wrongPwdCount	= ISNULL(wrongPwdCount, 0) + 1
		WHERE userId = @userId

		SELECT 1 errorCode, 'You are locked due to Continious Invalid login attempts. Please, contact your administrator' mes, @userName id, 0 rowId
		RETURN;
	END

	SELECT
		 @startDate			= startDate
		,@endDate			= endDate
	FROM userLockDetail WITH(NOLOCK)
	WHERE userId = @userId 
	AND ISNULL(isDeleted,'N') = 'N'
	
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
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id, @rowId rowId
		RETURN		
	END

	--IF @LOGIN_COUNTRY <> 'Nepal' --AND @userName <> 'raman'
	--BEGIN
	--	SELECT 1 errorCode, 'System is currently down, due to system maintainance.' mes, @userName id, @rowId rowId
	--	RETURN
	--END
	-- ## Except IME EXCHANGE COUNTER- TIA
	--IF @userDcSerialNumber IS NOT NULL AND @userDcSerialNumber <> @dcSerialNumber AND @agentId <> '9943' 
	--BEGIN
	--	SELECT 1 errorCode, 'Login fails, Not a valid Digital Certificate for this user.' mes, @userName id
	--	SET @UserInfoDetail = 'Reason = Login fails, Not a valid Digital Certificate for this user.-:::-'+@UserInfoDetail

	--	EXEC proc_applicationLogs 
	--		@flag			= 'login',
	--		@logType		= 'Login fails', 
	--		@createdBy		= @userName, 
	--		@Reason			= 'Not a valid Digital Certificate for this user',
	--		@UserData		= @UserData,
	--		@fieldValue		= @UserInfoDetail,
	--		@agentId		= @agentId,
	--		@IP				= @ipAddress,
	--		@dcSerialNumber	= @dcSerialNumber,
	--		@dcUserName		= @dcUserName
	--	RETURN
	--END
	
	--IF @dcSerialNumber IS NOT NULL AND @dcSerialNumber not like '%00-05-00-00%' 
	--BEGIN
		
	--	SELECT 1 errorCode, 'Login fails, Not a valid IME CERTIFICATE, Please Use Valid IME Certificate.' mes, @userName id
	--	SET @UserInfoDetail = 'Reason = Login fails, Not a valid IME CERTIFICATE-:::-' + @UserInfoDetail
		
	--	EXEC proc_applicationLogs 
	--		@flag			= 'login',
	--		@logType		= 'Login fails', 
	--		@createdBy		= @userName, 
	--		@Reason			= 'Not a valid IME CERTIFICATE',
	--		@UserData		= @UserData,
	--		@fieldValue		= @UserInfoDetail,
	--		@agentId		= @agentId,
	--		@IP				= @ipAddress,
	--		@dcSerialNumber	= @dcSerialNumber,
	--		@dcUserName		= @dcUserName		

	--	RETURN
	--END
	
	IF @userActive = 'N' 
	BEGIN
		SET @UserInfoDetail = 'Reason = User has not been approved.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'User is not active',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SELECT 1 errorCode, 'User is not active.' mes, @userName id, @rowId rowId
		RETURN
	END
	
	IF @agentActiveStatus = 'N'
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
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SELECT 1 errorCode, 'Your account is blocked.' mes, @userName id, @rowId rowId
		RETURN
	END

	DECLARE @attemptsCount INT
	SELECT TOP 1 @attemptsCount = loginAttemptCount, @lockUserDays = ISNULL(lockUserDays,30) FROM passwordFormat WITH(NOLOCK)
    
	IF (@loginPwd <> ISNULL(dbo.FNAEncryptString(@pwd), ''))
	BEGIN
		UPDATE applicationUsers SET 
			 wrongPwdCount	= ISNULL(wrongPwdCount, 0) + 1
		WHERE userId = @userId

		SET @UserInfoDetail = 'Reason = Login fails, Incorrect password.-:::-'+@UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Incorrect password',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SET @invalidPwdCount += 1
		IF @invalidPwdCount < 3
		BEGIN
			SELECT 2 errorCode, 'Login fails, Incorrect user name or password, attempts left ' + CAST((3 - @invalidPwdCount) AS VARCHAR) mes, @userName id, @attemptsCount ac, @rowId rowId
			RETURN		
		END
	END

	IF ISNULL(@invalidPwdCount, 0) >= 3
	BEGIN
		UPDATE applicationUsers SET 
				isLocked		= 'Y'
			,lastLoginTs	= GETDATE()
			,wrongPwdCount	= ISNULL(wrongPwdCount, 0) + 1
		WHERE userId = @userId

		SET @UserInfoDetail = 'Reason = User Locked due to Invalid login attempts.-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'User Locked due to Invalid login attempts.',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT
		
		SELECT 1 errorCode, 'You are locked due to Continious Invalid login attempts. Please, contact your administrator' mes, @userName id, @rowId rowId
		INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
		SELECT @userName, 'Your account has been locked due to Invalid login attempts', 'system', GETDATE()
		RETURN;
	END

	--IF (@loginUserAgtCode <> ISNULL(@agentCode, ''))
	--BEGIN
	--	SET @UserInfoDetail = 'Reason = Login fails, Incorrect AgentCode.-:::-' + @UserInfoDetail

	--	EXEC proc_applicationLogs 
	--		@flag			= 'login',
	--		@logType		= 'Login fails', 
	--		@createdBy		= @userName, 
	--		@Reason			= 'Incorrect AgentCode',
	--		@UserData		= @UserData,
	--		@fieldValue		= @UserInfoDetail,
	--		@agentId		= @agentId,
	--		@IP				= @ipAddress,
	--		@dcSerialNumber = @dcSerialNumber,
	--		@dcUserName		= @dcUserName ,
	--		@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
	--		@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
	--		@LOGIN_CITY			= @LOGIN_CITY,
	--		@LOGIN_REGION		= @LOGIN_REGION,
	--		@LOGIN_LAT			= @LOGIN_LAT,
	--		@LOGIN_LONG			= @LOGIN_LONG,
	--		@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
	--		@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
	--		@OTP_USED			= @OTP_USED,
	--		@rowId				= @rowId OUT

	--	SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id, @attemptsCount ac, @rowId rowId
	--	RETURN		
	--END
	
	IF (@empId <> ISNULL(@employeeId, '')) AND ISNULL(@IS_OTP_ENABLED, 'N') = 'N'
	BEGIN
		SET @UserInfoDetail = 'Reason = Login fails, Incorrect userId.-:::-'+@UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Incorrect userId',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id, @attemptsCount ac, @rowId rowId
		RETURN		
	END

	IF(@isLocked = 'Y')
	BEGIN
		SET @UserInfoDetail = 'Reason = Your account has been locked. Please, contact your administrator.-:::-'+@UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Your account has been locked',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SELECT 1 errorCode, 'Your account has been locked. Please, contact your administrator.' mes, @userName id, @rowId rowId
		RETURN;		
	END	
	
	IF CAST(GETDATE() AS TIME) < @loginTime OR CAST(GETDATE() AS TIME) > @logoutTime
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
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SELECT 1 errorCode, 'You are not permitted to login at this time. Please, contact your administrator.' mes, @userName id, @rowId rowId
		RETURN
	END

	IF (GETDATE() BETWEEN @startDate AND CONVERT(VARCHAR(20), @endDate,101) + ' 23:59:59')
	BEGIN
		SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
		
		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Not permitted to login for this date',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

		SELECT 1 errorCode, 'You are not permitted to login for this date. Please, contact your administrator' mes, @userName id, @rowId rowId
		RETURN
	END
		
	-- Last Login date check for Locking
    IF(DATEDIFF(DAY, @lastLoginTs, GETDATE()) >= @lockUserDays)
	BEGIN
		UPDATE applicationUsers SET 
			 isLocked		= 'Y'
			,lastLoginTs	= GETDATE()
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
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT
		
		SELECT 1 errorCode, 'You are locked this time. Please, contact your administrator' mes, @userName id, @rowId rowId

		INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
		SELECT @userName, 'Your account has been locked due to not login for fix period', 'system', GETDATE()		
		RETURN;

	END
		
	UPDATE applicationUsers SET	
		 lastLoginTs		= GETDATE()
		,dcSerialNumber		= ISNULL(dcSerialNumber, @dcSerialNumber)
		,dcUserName			= ISNULL(dcUserName, @dcUserName)
	WHERE  [userName] = @userName
			
	SELECT
		 @country			= am.agentCountry
		,@countryId			= am.agentCountryId
		,@branch			= au.agentId 
		,@branchName		= am.agentName
		,@agentName			= am.agentName
		,@mapCodeInt		= am.mapCodeInt
		,@parentmapCodeInt	= am.mapCodeInt
		,@mapCodeDom		= am.mapCodeDom
		,@agentType			= am.agentType
		,@actAsBranch		= actAsBranch
		,@agent				= CASE WHEN am.agentType = 2903 THEN au.agentId ELSE am.parentId END
		,@superAgent		= am.parentId
		,@parentId			= am.parentId
		,@settlingAgent		= CASE WHEN ISNULL(am.isSettlingAgent, 'N') = 'Y' THEN au.agentId ELSE NULL END
		,@agentEmail		= am.agentEmail1
		,@agentPhone		= am.agentPhone1
	FROM agentMaster am WITH(NOLOCK) 
	INNER JOIN applicationUsers au WITH(NOLOCK) ON am.agentId = au.agentId 		
	WHERE au.userName = @userName
	
	IF @country = 'Nepal'
	BEGIN
		SET @UserInfoDetail = 'Reason = You are not permitted from International agent Login panel. Please, contact your administrator-:::-' + @UserInfoDetail

		EXEC proc_applicationLogs 
			@flag			= 'login',
			@logType		= 'Login fails', 
			@createdBy		= @userName, 
			@Reason			= 'Not Login for fix period, now user is locked',
			@UserData		= @UserData,
			@fieldValue		= @UserInfoDetail,
			@agentId		= @agentId,
			@IP				= @ipAddress,
			@dcSerialNumber = @dcSerialNumber,
			@dcUserName		= @dcUserName ,
			@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
			@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
			@LOGIN_CITY			= @LOGIN_CITY,
			@LOGIN_REGION		= @LOGIN_REGION,
			@LOGIN_LAT			= @LOGIN_LAT,
			@LOGIN_LONG			= @LOGIN_LONG,
			@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
			@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
			@OTP_USED			= @OTP_USED,
			@rowId				= @rowId OUT

	    SELECT 1 errorCode, 'You are not permitted to login from International agent Login panel. Please, contact your administrator.' mes, @userName id, @rowId rowId
		RETURN
	END		

	IF(@agentType <> 2903) 
	BEGIN
		SELECT 
			 TOP 1
			 @agentName			= agentName
			,@parentMapCodeInt	= mapCodeInt
			,@superAgent		= parentId 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @agent
	END
		
	SELECT TOP 1 @superAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @superAgent
	
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agent AND isSettlingAgent = 'Y'
	
	EXEC proc_applicationLogs 
		@flag			= 'login',
		@logType		='Login', 
		@createdBy		= @userName, 
		@Reason			= 'Agent Login',
		@UserData		= @UserData,
		@fieldValue		= @UserInfoDetail,
		@agentId		= @agentId,
		@IP				= @ipAddress,
		@dcSerialNumber = @dcSerialNumber,
		@dcUserName		= @dcUserName	 ,
		@LOGIN_COUNTRY      = @LOGIN_COUNTRY, 
		@LOGIN_COUNTRY_CODE = @LOGIN_COUNTRY_CODE,
		@LOGIN_CITY			= @LOGIN_CITY,
		@LOGIN_REGION		= @LOGIN_REGION,
		@LOGIN_LAT			= @LOGIN_LAT,
		@LOGIN_LONG			= @LOGIN_LONG,
		@LOGIN_TIMEZONE		= @LOGIN_TIMEZONE,
		@LOGIN_ZIPCODDE		= @LOGIN_ZIPCODDE,
		@OTP_USED			= @OTP_USED,
		@rowId				= @rowId OUT

		UPDATE applicationUsers SET 
			 wrongPwdCount	= 0
		WHERE userId = @userId

	SELECT 
		TOP 1
		 0 errorCode
		,'Login success.' mes
		, @rowId rowId
		,@userName Id
		,au.userAccessLevel
		,au.sessionTimeOutPeriod
		,au.UserID
		,fullName = au.firstName + ISNULL(' ' + au.middleName, '') + ISNULL(' ' + au.lastName, '') 
		,parentId = ISNULL(@parentId, 0)
		,agentType = ISNULL(@agentType, 2901)
		,settlingAgent = ISNULL(@settlingAgent, 0)
		,isActAsBranch = ISNULL(@actAsBranch, 'N')
		,mapCodeInt = ISNULL(@mapCodeInt, '0000')
		,parentMapCodeInt = ISNULL(@parentMapCodeInt, '0000')
		,mapCodeDom = ISNULL(@mapCodeDom, '0000')
		,country = @country
		,countryId = @countryId
		,branch = @branch
		,branchName = @branchName
		,agent = @agent
		,agentName = @agentName
		,superAgent = ISNULL(@superAgent, 0)
		,superAgentName = ISNULL(@superAgentName, 0)
		,au.lastLoginTs 
		,fromSendTrnTime	= CASE WHEN x.globalOperationTimeEnable = 'Y' AND @settlingAgent <> 1249 THEN operationTimeFrom ELSE au.fromSendTrnTime END
		,toSendTrnTime		= CASE WHEN x.globalOperationTimeEnable = 'Y' AND @settlingAgent <> 1249 THEN operationTimeTo ELSE au.toSendTrnTime END
		,fromPayTrnTime		= CASE WHEN x.globalOperationTimeEnable = 'Y' AND @settlingAgent <> 1249 THEN operationTimeFrom ELSE au.fromPayTrnTime END
		,toPayTrnTime		= CASE WHEN x.globalOperationTimeEnable = 'Y' AND @settlingAgent <> 1249 THEN operationTimeTo ELSE au.toPayTrnTime END
		,au.userType
		,isHeadOffice = @isHeadOffice
		,newBranchId = newBranchId
		,agentLocation = @agentLocation
		,agentGrp	= @agentGrp
		,agentEmail = @agentEmail
		,agentPhone	= @agentPhone
		,isForcePwdChanged = au.forceChangePwd
		,UserUniqueKey = S.USER_UNIQUE_CODE
	FROM applicationUsers au WITH(NOLOCK)
	LEFT JOIN passwordFormat x WITH(NOLOCK) ON 1 = 1
	LEFT JOIN TBL_USER_2FA_SETUP S(NOLOCK) ON S.[USER_ID] = au.UserID
    WHERE au.userName = @userName
	
	RETURN	
END

GO
