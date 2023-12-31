USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationUsers]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_applicationUsers]
	  @flag					VARCHAR(50)	= NULL
     ,@userId				INT			= NULL
     ,@user					VARCHAR(30)	= NULL
     ,@userName				VARCHAR(30)	= NULL
     ,@firstName			VARCHAR(30)	= NULL
     ,@middleName			VARCHAR(30)	= NULL
     ,@lastName				VARCHAR(30)	= NULL
     ,@gender				VARCHAR(10)	= NULL
     ,@telephoneNo			VARCHAR(15)	= NULL
     ,@address				VARCHAR(50)	= NULL
     ,@city					VARCHAR(30)	= NULL
     ,@mobileNo				VARCHAR(15)	= NULL
     ,@email				VARCHAR(255)= NULL
     ,@pwd					VARCHAR(255)= NULL
     ,@oldPwd				VARCHAR(255)= NULL
     ,@isActive				CHAR(1)		= NULL
     ,@isDeleted			CHAR(1)		= NULL
     ,@accessMode			CHAR(1)		= NULL
     ,@country				VARCHAR(50) = NULL
     ,@state				VARCHAR(50) = NULL
     ,@pwdChangeDay			INT			= NULL
     ,@pwdWarnDay			INT			= NULL
     ,@sessionTime			INT			= NULL
     ,@maxReportViewDay		INT			= NULL
     ,@loginTime			TIME		= NULL
     ,@logoutTime			TIME		= NULL
     ,@branchId				INT			= NULL
     ,@branchName			VARCHAR(50)	= NULL
     ,@userType				CHAR(1)		= NULL
     
     ,@sortBy				VARCHAR(50)	= NULL
     ,@sortOrder			VARCHAR(5)	= NULL
     ,@pageSize				INT			= NULL
     ,@pageNumber			INT			= NULL
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
     DECLARE
			 @sql				VARCHAR(MAX)
			,@select_field_list VARCHAR(MAX)
			,@extra_field_list  VARCHAR(MAX)
			,@table             VARCHAR(MAX)
			,@sql_filter        VARCHAR(MAX)
		DECLARE @agentCode varchar(30)

IF @flag = 'hs'
BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'userId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT 
							userId
							,UserName
							,firstName+'' ''+ISNULL(middleName,'''')+'' ''+ISNULL(lastName,'''') name
							, address
							,lastLoginTs
							,lastPwdChangedOn
							,city
							,createdDate 
							,createdBy
							,lockStatus = CASE WHEN ISNULL(isLocked,''N'') = ''Y'' THEN ''Locked'' ELSE ''Unlock'' END
					FROM applicationUsers WITH(NOLOCK) WHERE ISNULL(isDeleted,''N'') <> ''Y'' AND userType =''A''
					) x'
					
		SET @sql_filter = ''		
		IF @userName IS NOT NULL
			SET @sql_filter= @sql_filter +'  AND username='''+@userName+''''
			
		IF @firstName IS NOT NULL
			SET @sql_filter= @sql_filter +'  AND fullname LIKE '''+@firstName+'%'''
			
		SET @select_field_list ='
				userId
			   ,userName
			   ,name
			   ,address  
			   ,lastLoginTs
			   ,lastPwdChangedOn
			   ,lockStatus
			   ,city
			   ,createdDate   
			   ,createdBy
			   '        	
		--select @table
		--return;	
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber
	END
ELSE IF @flag ='A'
BEGIN
	SELECT * FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId
	RETURN
END
ELSE IF @flag = 'I'
BEGIN
	IF EXISTS(SELECT 'A' FROM applicationUsers WITH(NOLOCK) WHERE userName = @username)
	BEGIN
		EXEC proc_errorHandler '1','User already Created',@username 
		RETURN
	END
	
	INSERT INTO applicationUsers(userName,firstName,middleName,lastName,gender,address,city,telephoneNo,mobileNo,email,pwd,accessMode
		,createdBy,createdDate,country,userState,pwdChangeDay,pwdWarnDay,sessionTime,maxReportViewDay,loginTime,logoutTime
		,usertype,agentid,isLocked,agentCode)
	SELECT @userName,@firstName,@middleName,@lastName,@gender,@address,@city,@telephoneNo,@mobileNo,@email,dbo.FNAEncryptString(@userName),@accessMode
		,@user,GETDATE(),@country,@state,ISNULL(@pwdChangeDay,15),ISNULL(@pwdWarnDay,12),ISNULL(@sessionTime,300)
		,ISNULL(@maxReportViewDay,60),ISNULL(@loginTime,'00:00:00'),ISNULL(@logoutTime,'18:00:00')
		,@userType,@branchId,'Y',@agentCode
	
	EXEC proc_errorHandler '0','User Created Successfully',@username 
	RETURN
END
ELSE IF @flag = 'U'
BEGIN
	
	UPDATE applicationUsers SET
		firstName		= @firstName,
		middleName		= @middleName,
		lastName		= @lastName,
		gender			= @gender,
		address			= @address,
		city			= @city,
		telephoneNo		= @telephoneNo,
		mobileNo		= @mobileNo,
		email			= @email,
		accessMode		= @accessMode,
		COUNTRY			= @country,
		userState		= @state,
		pwdChangeDay	= ISNULL(@pwdChangeDay,15),
		pwdWarnDay		= ISNULL(@pwdWarnDay,12),
		sessionTime		= ISNULL(@sessionTime,300),
		maxReportViewDay = ISNULL(@maxReportViewDay,60),
		loginTime		= ISNULL(@loginTime,'00:00:00'),
		logoutTime		= ISNULL(@logoutTime,'18:00:00'),
		agentId			= @branchId,
		userType		= @userType,
		agentCode		= @agentCode,
		modifiedBy		= @user,
		modifiedDate	= GETDATE()
	WHERE userId = @userId
	EXEC proc_errorHandler '0','User updated Successfully',@username 
	RETURN
END
ELSE IF @flag = 'D'
BEGIN
	UPDATE applicationUsers SET isDeleted = 'Y' ,isActive = 'N',modifiedBy = @user,modifiedDate = GETDATE() WHERE userId = @userId
	EXEC proc_errorHandler '0','User deleted Successfully',@userId 
	RETURN
END
ELSE IF @flag = 'lockUser'
BEGIN
	SELECT @isActive = ISNULL(isLocked,'N') FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId
	
	UPDATE applicationUsers 
		SET isLocked = CASE @isActive WHEN 'Y' THEN 'N' ELSE 'Y' END ,modifiedBy = @user,modifiedDate = GETDATE()
		,isActive = CASE @isActive WHEN 'Y' THEN 'Y' ELSE 'N' END
	WHERE userId = @userId
	
	SELECT @sql_filter = CASE WHEN @isActive = 'Y' THEN 'User unlocked Successfully' ELSE 'User locked Successfully' END
	
	EXEC proc_errorHandler '0',@sql_filter,@userId 
	RETURN;
END
ELSE IF @flag = 'resetPwd'
BEGIN
	SET @pwd = LEFT(NEWID(),8)
	SET @sql_filter = 'Password  changed,New password is : ' + @pwd
	UPDATE applicationUsers 
		SET lastPwdChangedOn = GETDATE(),pwd = dbo.FNAEncryptString(@pwd),modifiedBy = @user,modifiedDate = GETDATE(),isForcePwdChanged ='Y'
	WHERE userId = @userId
	EXEC proc_errorHandler '0',@sql_filter,@userId 
	RETURN
END
ELSE IF @flag = 'cp'  ---- CHANGE PASSWORD
BEGIN
	IF NOT EXISTS(SELECT 'A' FROM applicationUsers WITH(NOLOCK) WHERE convert(varbinary(255),userName) = convert(varbinary(255),@userName) 
		AND pwd = dbo.FNAEncryptString(@oldPwd))
	BEGIN
		EXEC proc_errorHandler '1','Old Password did not matched',@userName 
		RETURN
	END
	
		DECLARE @pwdHistoryNum INT = NULL
		DECLARE @tempPwdTable TABLE(pwd VARCHAR(50))
		DECLARE @newPwd VARCHAR(50)
		SET @newPwd = @Pwd

		SELECT @pwdHistoryNum = pwdHistoryNum FROM passwordFormat WITH(NOLOCK)

		SET @sql = 'SELECT TOP ' + CAST(@pwdHistoryNum AS VARCHAR) + ' pwd FROM passwordHistory WITH(NOLOCK) WHERE userName = ''' + @user + ''' ORDER BY createdDate DESC'
		INSERT INTO @tempPwdTable

		EXEC(@sql)

		IF @newPwd IN (SELECT pwd FROM @tempPwdTable)
		BEGIN
			EXEC proc_errorHandler '1','Password has been already used previously. Please enter the new one.',@userName
			RETURN
		END
		
		--Validate Password From Password Policy---------------------------------------------------------------
		IF(SELECT TOP 1 errorCode FROM dbo.FNAValidatePassword(@newPwd)) <> 0
		BEGIN
			SELECT * FROM dbo.FNAValidatePassword(@newPwd)
			RETURN
		END
	
	INSERT INTO passwordHistory(userName,pwd,createdDate,userType
		)
		SELECT @userName, @newPwd, GETDATE(),'A'
	
	UPDATE applicationUsers 
		SET lastPwdChangedOn = GETDATE(),pwd = dbo.FNAEncryptString(@Pwd),modifiedBy = @user,modifiedDate = GETDATE(),isForcePwdChanged = NULL
	WHERE userName = @userName 
	EXEC proc_errorHandler '0','Password changed successfully',@userName 
	RETURN
END
ELSE IF @flag = 'lo' --Log Out
BEGIN
	BEGIN TRANSACTION
	
		SELECT
			0 errorCode				
			,REPLACE(ISNULL(au.firstName, '') + ' ' + ISNULL(au.middleName, '')  + ' ' + ISNULL(au.lastName, ''), '  ', ' ') mes
			,@userName id
		FROM applicationUsers au WITH(NOLOCK)WHERE au.[userName] = @userName
	
		 EXEC proc_applicationLogs 
			@flag='login',
			@logType='Logout', 
			@createdBy = @userName, 
			@Reason='Logout',
			@UserData = 'LOG OUT'
	
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
END	

ELSE IF @flag = 'S'
BEGIN
	IF @sortBy IS NULL
		   SET @sortBy = 'userId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT 
							userId
							,UserName
							,u.agentId
							,U.isDeleted
							,agentCode
							,firstName+'' ''+ISNULL(middleName,'''')+'' ''+ISNULL(lastName,'''') name
							, address
							,lastLoginTs
							,lastPwdChangedOn
							,U.createdDate 
							,U.createdBy
							,lockStatus = CASE WHEN ISNULL(isLocked,''N'') = ''Y'' THEN ''Locked'' ELSE ''Unlock'' END
					FROM applicationUsers U WITH(NOLOCK)
					) x'
					
		SET @sql_filter = ''		
		IF @userName IS NOT NULL
			SET @sql_filter= @sql_filter +'  AND username='''+@userName+''''
			
		IF @firstName IS NOT NULL
			SET @sql_filter= @sql_filter +'  AND name LIKE '''+@firstName+'%'''

		IF @isActive IS NOT NULL
			SET @sql_filter += ' AND  lockStatus='''+@isActive+''''
		
		IF @isDeleted IS NOT NULL
			SET @sql_filter += ' AND isDeleted = '''+@isDeleted+''''
		ELSE 
			SET @sql_filter += ' AND ISNULL(isDeleted,''N'')<> ''Y'''
			
		SET @select_field_list ='
				userId
			   ,userName
			   ,isDeleted
			   ,agentCode
			   ,name
			   ,address  
			   ,lastLoginTs
			   ,lastPwdChangedOn
			   ,lockStatus
			   ,createdDate   
			   ,createdBy
			   '        	
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber
END

ELSE IF @flag = 'rdu'
BEGIN
	UPDATE applicationUsers SET
		isDeleted = 'N',
		modifiedBy = @user,
		modifiedDate = GETDATE()
	WHERE userId = @userId
	EXEC proc_errorHandler '0','User restored successfully',@userName 
	RETURN
END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errorCode, ERROR_MESSAGE() mes, null id
END CATCH

GO
