USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcManagement]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_dcManagement]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@requestId							VARCHAR(30)				= NULL
	,@dcRequestId						VARCHAR(30)				= NULL
	,@userId							VARCHAR(30)				= NULL
	,@userName							VARCHAR(30)		= NULL
	,@pwd								VARCHAR(50)		= NULL
	,@agentCode							VARCHAR(20)		= NULL
	,@userAddress						VARCHAR(100)	= NULL
	,@companyName						VARCHAR(150)	= NULL
	,@branchName						VARCHAR(150)	= NULL
	,@approvedDate						DATETIME		= NULL
	,@approvedFromDate					DATETIME		= NULL
	,@approvedToDate					DATETIME		= NULL
	,@isActive							CHAR(1)			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@ipAddress							VARCHAR(50)		= NULL
    ,@dcSerialNumber					VARCHAR(100)	= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY

	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)
		,@ApprovedFunctionId INT
		,@userDcSerialNumber VARCHAR(100)
		,@userDcUserName VARCHAR(100)
	SELECT
		 @logIdentifier = 'requestId'
		,@logParamMain = 'certificateMaster'
		,@tableAlias = 'Digital Certificate'
		,@module = 10
	
	IF @flag = 'loginAdmin'							--Check if IPAddress exist
	BEGIN
		DECLARE  @UserData varchar(2000), @agentType INT, @actAsBranch CHAR(1), @agentId INT, @userInfoDetail VARCHAR(200)

		SET @UserData ='User:'+ @userName +', UserCode:'+  CAST(@userId as varchar(20))

		SELECT TOP 1 @agentType = agentType, @actAsBranch = actAsBranch, @agentId = agentId
		  FROM agentMaster WITH(NOLOCK)
			WHERE agentId = (
			 SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName
		)	

		IF (@agentType = (2904) OR @actAsBranch = 'Y')
		BEGIN
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect user name.-:::-'+@UserInfoDetail
			SELECT 1 errorCode, 'Login fails, Agent Cannot Login from here.' mes, @userName id
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='Invalid Username',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
				,@IP = @ipAddress
			RETURN
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			SET @UserInfoDetail = 'Reason = Login fails, User Locked .-:::-'+@UserInfoDetail
			SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='User Not Actived',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
				,@IP = @ipAddress
			 RETURN

		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND userId = @userId AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			 SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			 SET @UserInfoDetail = 'Reason = Login fails, Invalid password.-:::-'+@UserInfoDetail
			 EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='Invalid Password',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
				,@IP = @ipAddress
			RETURN
					
		END
		
		SELECT TOP 1 @requestId = ISNULL(requestId, 0) FROM certificateMaster WITH(NOLOCK) ORDER BY requestId DESC
		SET @requestId = 1 + ISNULL(@requestId, 0)

		SELECT 
			 errorCode		= 0
			,agentId		= au.agentId
			,agentUserId	= userId
			,userName		= userName
			,agentCode		= au.agentCode
			,userFullName	= firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '')
			,agentName		= am.agentName
			,branchName		= am.agentName
			,country		= am.agentCountry
			,contactNo		= COALESCE(am.agentPhone1, am.agentPhone2, am.agentMobile1, am.agentMobile2)
			,email			= COALESCE(au.email, am.agentEmail1)
			,GMT			= tz.GMT
			,GMTName		= tz.name
			,dcRequestId	= au.dcApprovedId
			,dcApprovedDate= au.dcApprovedDate
		FROM applicationUsers au WITH(NOLOCK) 
		INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
		LEFT JOIN timeZones tz WITH(NOLOCK) ON am.localTime = tz.ROWID
		WHERE userName = @userName
			
		--Audit data starts
		EXEC proc_applicationLogs 
			@flag='login',
			@logType='Login/certsrv', 
			@createdBy = @userName, 
			@Reason='Admin Login',
			@UserData = @UserData,
			@fieldValue = @UserInfoDetail,
			@agentId=@agentId
			,@IP = @ipAddress
		--Audit data ends	
	END	
	
	ELSE IF @flag = 'loginAgent'
	BEGIN
		-- exec [proc_applicationUsers] @flag = 'lfg', @userName ='bharat', @pwd = 'bharat', @agentCode='ncb001', @userId=''

		SET @UserData ='User:'+ @userName +', UserCode:'+  cast(@userId as varchar(20))
						  +', AgentCode:'+  cast(@agentCode as varchar(20))
		
		SELECT top 1 @agentType = agentType, @actAsBranch = actAsBranch, @agentId = agentId
		  FROM agentMaster WITH(NOLOCK)
			WHERE agentId = (
			 SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName
		)
		
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName)
		BEGIN
			SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect user name.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='Invalid Username',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId			
				,@IP = @ipAddress
			RETURN		
		END
		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE userName = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND agentCode = @agentCode AND userId = @userId AND ISNULL(isActive, 'N') = 'N')
		BEGIN
			SELECT 1 errorCode, 'User has not been approved.' mes, @userName id
			SET @UserInfoDetail = 'Reason = User has not been approved.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='User has not been approved',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId			
				,@IP = @ipAddress
			RETURN	
			
		END
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
			 AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, User is not Active.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='User is not Active',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId			
				,@IP = @ipAddress
			RETURN		
		END
    
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y')
		BEGIN

			SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect password.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='Incorrect password',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId		
				,@IP = @ipAddress
			RETURN		
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y' 
		  AND agentCode = @agentCode)
		BEGIN

			SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect AgentCode.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='Incorrect AgentCode',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId		
			     ,@IP = @ipAddress
			RETURN		
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y' 
		  AND agentCode = @agentCode AND employeeId = @userId )
		BEGIN

			SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect userId.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails/certsrv', 
				@createdBy = @userName, 
				@Reason='Incorrect userId',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
				,@IP = @ipAddress		

			RETURN		
		END

		--alter table applicationUsers add dcApprovedId varchar(20), dcApprovedDate datetime
		

		SELECT 
			 errorCode		= 0
			,agentId		= au.agentId
			,agentUserId	= userId
			,userName		= userName
			,agentCode		= au.agentCode
			,userFullName	= firstName + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, '')
			,agentName		= CASE WHEN am.agentType = 2904 THEN pam.agentName ELSE LEFT(am.agentName,60) END
			,branchName		= LEFT(am.agentName,60)
			,country		= am.agentCountry
			,contactNo		= COALESCE(am.agentPhone1, am.agentPhone2, am.agentMobile1, am.agentMobile2)
			,email			= COALESCE(au.email, am.agentEmail1)
			,GMT			= tz.GMT
			,GMTName		= tz.name
			,dcRequestId	= au.dcApprovedId
			,dcApprovedDate= au.dcApprovedDate
		FROM applicationUsers au WITH(NOLOCK) 
		INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
		INNER JOIN agentMaster pam WITH(NOLOCK) ON am.parentId = pam.agentId
		LEFT JOIN timeZones tz WITH(NOLOCK) ON am.localTime = tz.ROWID
		WHERE userName = @userName


		--Audit data starts
		EXEC proc_applicationLogs 
			@flag='login',
			@logType='Login/certsrv', 
			@createdBy = @userName, 
			@Reason='Agent Login',
			@UserData = @UserData,
			@fieldValue = @UserInfoDetail,
			@agentId=@agentId
			,@IP = @ipAddress
			--Audit data ends	
	END
	
	IF @flag = 'i'
	BEGIN
		IF @userId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Mandatory Field Missing', @dcRequestId
			RETURN
		END

		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE  userName = @user  
			 AND (dcApprovedId IS NOT NULL and dcApprovedDate IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'Your certificate request is still pending. You must wait for an administrator to issue the certificate you have requested.', @dcRequestId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE userId = @userId AND dcApprovedId IS NOT NULL AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Your Digital Certificate has already been activated.', @dcRequestId
			RETURN
		END
		BEGIN TRANSACTION

			INSERT INTO certificateMaster(
				 dcRequestId
				,userId
				,requestedBy
				,requestedDate
			)
			SELECT
				 @dcRequestId
				,@userId
				,@user
				,GETDATE()

			SET @requestId = SCOPE_IDENTITY()
			

			 update applicationUsers
				set dcApprovedId= @dcRequestId
			 where userId = @userId  

		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcRequestId
	END		
	
	ELSE IF @flag='a'
	BEGIN
		SELECT 
			*
		FROM certificateMaster where requestId = @requestId
	END

	ELSE IF @flag = 'dcClear'
	BEGIN		
		SELECT
			 @dcSerialNumber		= ISNULL(dcSerialNumber, '') + '|' + dcApprovedId
			,@userDcSerialNumber	= dcSerialNumber
			,@userDcUserName		= dcUserName
			,@dcRequestId			= dcApprovedId
		FROM applicationusers WITH(NOLOCK) WHERE userId = @userId
		
		BEGIN TRAN
			UPDATE certificateMaster SET
				 dcSerialNumber			= @userDcSerialNumber
				,dcUserName				= @userDcUserName
			WHERE dcRequestId = @dcRequestId
			
			UPDATE applicationusers SET 
				 dcApprovedDate			= NULL
				,dcApprovedId			= NULL
				,dcSerialNumber			= NULL
				,dcUserName				= NULL
			WHERE userId = @userId	
			
			INSERT INTO dcClearHistory(userId, dcRequestId, dcSerialNumber, dcUserName, createdBy, createdDate)
			SELECT @userId, @dcRequestId, @userDcSerialNumber, @userDcUserName, @user, GETDATE()
			
		COMMIT TRAN

		EXEC proc_errorHandler 0, 'DC Clear Successfully.', @dcSerialNumber
	END

     ELSE IF @flag = 's'
     BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'requestId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.requestId
							,main.dcRequestId
							,main.userId
							,au.userName
							,userFullName = au.firstName + ISNULL('' '' + au.middleName, '''') + ISNULL('' '' + au.lastName, '''')
							,country = am.agentCountry
							,state = am.agentState
							,district = am.agentDistrict
							,address = am.agentAddress
							,companyName = am.agentName
							,main.requestedBy                                  
							,main.requestedDate				
						FROM certificateMaster main WITH(NOLOCK)
						INNER JOIN applicationUsers au WITH(NOLOCK) ON main.userId = au.userId
						INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
						WHERE main.approvedBy IS NULL
					) x'
					
		SET @sql_filter = ''		
		
		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userName, '''') LIKE ''%' + @userName + '%'''
		
		IF @companyName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(companyName, '''') LIKE ''%' + @companyName + '%'''
		
		SET @select_field_list ='
				 requestId
				,dcRequestId
				,userId
				,userName
				,userFullName
				,country
				,state
				,district
				,address
				,companyName
				,requestedBy
				,requestedDate
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
	
	ELSE IF @flag = 'dcl'		
	BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'userId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 dcRequestId = au.dcApprovedId
							,au.userId
							,au.userName
							,userFullName = au.firstName + ISNULL('' '' + au.middleName, '''') + ISNULL('' '' + au.lastName, '''')
							,country = am.agentCountry
							,state = am.agentState
							,district = am.agentDistrict
							,address = am.agentAddress
							,companyName = am.agentName
							,au.dcApprovedDate
							,cm.approvedBy			
						FROM applicationUsers au WITH(NOLOCK)
						INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
						LEFT JOIN certificateMaster cm WITH(NOLOCK) ON au.dcApprovedId = cm.dcRequestId
						WHERE au.dcApprovedId IS NOT NULL
					) x'
					
		SET @sql_filter = ''		
		
		IF @dcRequestId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND dcRequestId = ''' + CAST(@dcRequestId AS VARCHAR) + ''''
			
		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userName, '''') LIKE ''%' + @userName + '%'''
		
		IF @companyName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(companyName, '''') LIKE ''%' + @companyName + '%'''
			
		IF @approvedFromDate IS NOT NULL AND @approvedToDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND dcApprovedDate BETWEEN ''' + CONVERT(VARCHAR,@approvedFromDate,101) + ' 00:00:00'' AND ''' + CONVERT(VARCHAR,@approvedToDate,101) + ' 23:59:59'''
		
		PRINT @sql_filter
		SET @select_field_list ='
				 dcRequestId
				,userId
				,userName
				,userFullName
				,country
				,state
				,district
				,address
				,companyName
				,dcApprovedDate
				,approvedBy
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
	
	ELSE IF @flag = 'reject'
	BEGIN
		SELECT @userName = requestedBy FROM certificateMaster WITH(NOLOCK) WHERE dcRequestId = @requestId
		/*
		  IF NOT EXISTS (SELECT 'X' FROM applicationusers WITH(NOLOCK) 
			 WHERE dcApprovedId = @requestId AND dcApprovedDate IS NULL)
		  BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @requestId
			RETURN
		  END
		*/
		UPDATE applicationusers 
			SET dcApprovedId = null
		WHERE userName = @userName

		DELETE FROM certificateMaster WHERE dcRequestId = @requestId
			
		EXEC proc_applicationLogs 
			@flag='dcReject',
			@logType='dcReject', 
			@createdBy = @user, 
			@Reason='DC Reject',
			@UserData = @requestId,
			@fieldValue = @UserInfoDetail,
			@agentId=''

		   EXEC proc_errorHandler 0, 'Changes Rejected Successfully.', @requestId

	END
	
	ELSE IF @flag = 'approve'
	BEGIN
		  /*	 
			 EXEC proc_dcManagement @flag = 'approve', 
			 @userName = 'bajrasub123', @requestId = '61', @user='admin'
		  */

		IF NOT EXISTS (SELECT 'X' FROM applicationusers WITH(NOLOCK) 
			 WHERE dcApprovedId = @requestId AND dcApprovedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @requestId
			RETURN
		END

		    UPDATE applicationusers 
					   set dcApprovedDate =GETDATE() 
		    WHERE dcApprovedId = @requestId
    				
		    --select * from certificateMaster

		    UPDATE certificateMaster 
					   set approvedBy  = @user 
					   ,approvedDate  =GETDATE() 
		    WHERE dcRequestId = @requestId


		    EXEC proc_applicationLogs 
			    @flag='dcApprove',
			    @logType='dcApprove', 
			    @createdBy = @user, 
			    @Reason='DC Approce',
			    @UserData = @requestId,
			    @fieldValue = '',
			    @agentId=''

		   EXEC proc_errorHandler 0, 'Changes approved successfully.', @requestId

	END	
	
	ELSE IF @flag = 'dcRemove'
	BEGIN
		SELECT
			 @dcSerialNumber		= ISNULL(dcSerialNumber, '') + '|' + dcApprovedId
			,@userDcSerialNumber	= dcSerialNumber
			,@userDcUserName		= dcUserName
			,@dcRequestId			= dcApprovedId
		FROM applicationusers WITH(NOLOCK) WHERE userId = @userId
		
		BEGIN TRAN
			UPDATE certificateMaster SET
				 dcSerialNumber			= @userDcSerialNumber
				,dcUserName				= @userDcUserName
			WHERE dcRequestId = @dcRequestId
			
			UPDATE applicationusers SET 
				 dcApprovedDate			= NULL
				,dcApprovedId			= NULL
				,dcSerialNumber			= NULL
				,dcUserName				= NULL
			WHERE userId = @userId	
			
			INSERT INTO dcClearHistory(userId, dcRequestId, dcSerialNumber, dcUserName, createdBy, createdDate)
			SELECT @userId, @dcRequestId, @userDcSerialNumber, @userDcUserName, @user, GETDATE()
			
		COMMIT TRAN

		EXEC proc_errorHandler 0, 'DC has been removed Successfully.', @dcSerialNumber
	END

	ELSE IF @flag = 'dcClear-1'
	BEGIN		
		SELECT
			 @userDcSerialNumber	= dcSerialNumber
			,@userDcUserName		= dcUserName
		FROM applicationusers WITH(NOLOCK) WHERE userId = @userId
		
		BEGIN TRAN
			
			UPDATE applicationusers SET 
				 dcSerialNumber			= NULL
				,dcUserName				= NULL
			WHERE userId = @userId	
			
			INSERT INTO dcClearHistory(userId, dcRequestId, dcSerialNumber, dcUserName, createdBy, createdDate)
			SELECT @userId, @dcRequestId, @userDcSerialNumber, @userDcUserName, @user, GETDATE()
			
		COMMIT TRAN

		EXEC proc_errorHandler 0, 'DC has been cleared Successfully.', @dcSerialNumber
	END

END TRY
BEGIN CATCH

     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @requestId

END CATCH




GO
