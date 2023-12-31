USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationUsersMigration]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* 
	exec [proc_applicationUsers] 'i', NULL, NULL, 'admin', 'admin', @isActive = 'Y',@pwdChangeDays = 20,@pwdChangeWarningDays = 10
	exec [proc_applicationUsers] 'l', NULL, NULL, 'admin', 'admin'
	exec [proc_applicationUsers] @flag = 'lfg', @userName ='admin', @pwd = 'admin'

*/

CREATE proc [dbo].[proc_applicationUsersMigration]
	  @flag                             VARCHAR(50)		= NULL
     ,@userId							INT				= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@userName                         VARCHAR(30)		= NULL
     ,@agentName						VARCHAR(100)	= NULL
     ,@agentCode						VARCHAR(20)		= NULL
     ,@firstName                        VARCHAR(30)		= NULL
     ,@middleName                       VARCHAR(30)		= NULL
     ,@lastName                         VARCHAR(30)		= NULL
     ,@salutation                       VARCHAR(10)		= NULL
     ,@gender                           VARCHAR(10)		= NULL
     ,@telephoneNo                      VARCHAR(15)		= NULL
     ,@address                          VARCHAR(50)		= NULL
     ,@city                             VARCHAR(30)		= NULL
     ,@countryId                        INT				= NULL
     ,@state							INT				= NULL
     ,@district							INT				= NULL
     ,@zip								VARCHAR(10)		= NULL
     ,@mobileNo                         VARCHAR(15)		= NULL
     ,@email                            VARCHAR(255)	= NULL
     ,@pwd                              VARCHAR(255)	= NULL
     ,@isActive                         CHAR(1)			= NULL
     ,@isLocked                         CHAR(1)			= NULL
     ,@agentId                          INT				= NULL
     ,@sessionTimeOutPeriod				INT				= NULL
     ,@tranApproveLimit					MONEY			= NULL
	 ,@agentCrLimitAmt					MONEY			= NULL
	 ,@loginTime						VARCHAR(10)		= NULL
	 ,@logoutTime						VARCHAR(10)		= NULL
	 ,@userAccessLevel					CHAR(1)			= NULL
	 ,@perDayTranLimit					INT				= NULL
	 ,@fromSendTrnTime					TIME			= NULL
	 ,@toSendTrnTime					TIME			= NULL
	 ,@fromPayTrnTime					TIME			= NULL
	 ,@toPayTrnTime						TIME			= NULL
	 ,@fromRptViewTime					TIME			= NULL
	 ,@toRptViewTime					TIME			= NULL
     ,@isDeleted                        CHAR(1)			= NULL
     ,@lastLoginTs                      DATETIME		= NULL
     ,@pwdChangeDays                    INT				= NULL
     ,@pwdChangeWarningDays             INT				= NULL
     ,@lastPwdChangedOn                 DATETIME		= NULL
     ,@forceChangePwd                   CHAR(1)			= NULL
     ,@oldPwd							VARCHAR(255)	= NULL
     ,@name								VARCHAR(50)		= NULL
	 ,@file								VARCHAR(500)	= NULL
     ,@changesApprovalQueueRowId        BIGINT			= NULL
     ,@haschanged						CHAR(1)			= NULL
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL
     ,@UserInfoDetail					VARCHAR(MAX)	= NULL
	 ,@maxReportViewDays				INT				= NULL
	 ,@lockReason						VARCHAR(500)	= NULL
	 ,@employeeId						VARCHAR(10)		= NULL
	 ,@userType							VARCHAR(20)		= NULL	
	 ,@createdBy						VARCHAR(50)		= NULL
	 ,@createdDate						DATETIME		= NULL
	 ,@approvedBy						VARCHAR(50)		= NULL
	 ,@approvedDate						DATETIME		= NULL		
AS
/*
	@flag
	s	= select all (with dynamic filters)
	i	= insert
	u	= update
	a	= select by role id
	d	= delete by role id
	l	= login
	r	= reset password --@custodian_id, @user, @pwd
	cp  = change password --@user, @pwd, @oldPwd
	loc	= Lock
	cu	= check user
	lo	= Log Out
	[custodian]

*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

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
			,@msg				VARCHAR(200)
			,@parentAgentId		int

     SELECT
		@logIdentifier = 'userId'
		,@logParamMain = 'applicationUsers'
		,@tableAlias = 'User Setup'
		,@module = 10
		,@ApprovedFunctionId = 10101130
	
	IF @flag = 'i'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)
		BEGIN
			SET @msg = 'Branch not exists'
			EXEC proc_errorHandler 1, @msg, @employeeId
			RETURN 
		END
		IF EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE [userName] = @userName )
		BEGIN
			SET @msg = 'User Name ' + @userName + ' already exist'
			EXEC proc_errorHandler 1, @msg, @employeeId
			RETURN		
		END
          BEGIN TRANSACTION
               INSERT INTO applicationUsers (
					[userName]
					,agentCode
                    ,firstName
                    ,middleName
                    ,lastName
                    ,salutation
                    ,gender
                    ,countryId
                    ,state
                    ,district
                    ,zip
                    ,city
                    ,[address]
                    ,telephoneNo
                    ,mobileNo
                    ,email
                    ,pwd
                    ,agentId
                    ,sessionTimeOutPeriod
                    ,tranApproveLimit
                    ,agentCrLimitAmt
                    ,loginTime
                    ,logoutTime
                    ,userAccessLevel
                    ,perDayTranLimit
                    ,fromSendTrnTime
                    ,toSendTrnTime
                    ,fromPayTrnTime
                    ,toPayTrnTime
                    ,fromRptViewTime
                    ,toRptViewTime
                    ,isDeleted
                    ,lastLoginTs
                    ,pwdChangeDays
                    ,pwdChangeWarningDays
                    ,lastPwdChangedOn
                    ,forceChangePwd
                    ,maxReportViewDays
                    ,createdBy
                    ,createdDate
                    ,approvedBy
                    ,approvedDate
                    ,employeeId
                    ,userType
                    ,isActive
               )
               SELECT
					 @userName
					,@agentCode
                    ,@firstName
                    ,@middleName
                    ,@lastName
                    ,@salutation
                    ,@gender
                    ,@countryId
                    ,@state
                    ,@district
                    ,@zip
                    ,@city
                    ,@address
                    ,@telephoneNo
                    ,@mobileNo
                    ,@email
                    ,dbo.FNAEncryptString(@pwd)
                    ,@agentId
                    ,@sessionTimeOutPeriod
                    ,@tranApproveLimit
                    ,@agentCrLimitAmt
                    ,@loginTime
                    ,@logoutTime
                    ,@userAccessLevel
                    ,@perDayTranLimit
                    ,@fromSendTrnTime
                    ,@toSendTrnTime
                    ,@fromPayTrnTime
                    ,@toPayTrnTime
                    ,@fromRptViewTime
                    ,@toRptViewTime
                    ,@isDeleted
                    ,@lastLoginTs
                    ,@pwdChangeDays
                    ,@pwdChangeWarningDays
                    ,@lastPwdChangedOn
                    ,'Y'
                    ,@maxReportViewDays
                    ,'bivash'
                    ,GETDATE()
                    ,'raju'
                    ,GETDATE()
                    ,@employeeId
                    ,@userType
                    ,'Y'

               SET @userId = SCOPE_IDENTITY()
               
				--Keep Password History--------------------------------------
				INSERT INTO passwordHistory(
					 userName
					,pwd
					,createdDate
				)
				SELECT 
					 @userName
					,dbo.FNAEncryptString(@pwd)
					,GETDATE()
				--------------------------------------------------------------
               COMMIT TRANSACTION
               SELECT 0 errorCode, 'Record has been added successfully with User Code ' + CAST(@employeeId AS VARCHAR) mes, @userId id
	 END

	ELSE IF @flag = 'approve'
	BEGIN

		DECLARE 
			 @baseChanges CHAR(1) = 'N'
			,@roleChanges CHAR(1) = 'N'
			,@functionChanges CHAR(1) = 'N'
			
		IF EXISTS(SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL)
		   OR 
		   EXISTS(SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId)
		BEGIN
			SET @baseChanges = 'Y'
		END
	
		IF EXISTS(SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) WHERE userId = @userId)
		BEGIN
			SET @roleChanges = 'Y'
		END
	
		IF EXISTS(SELECT 'X' FROM applicationUserFunctionsMod WITH(NOLOCK) WHERE userId = @userId)
		BEGIN
			SET @functionChanges = 'Y'
		END
		
	
	
		IF @baseChanges <> 'Y' AND @roleChanges <> 'Y' AND @functionChanges <> 'Y'
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userId
			RETURN
		END
		BEGIN TRANSACTION
			IF @baseChanges = 'Y'
			BEGIN
				IF EXISTS (SELECT 'X' FROM applicationUsers WHERE approvedBy IS NULL AND userId = @userId)
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM applicationUsersMod WHERE userId = @userId
					
				IF @modType = 'I'
				BEGIN --New record
					UPDATE applicationUsers SET
						 isActive = 'Y'
						,approvedBy = @user
						,approvedDate= GETDATE()
					WHERE userId = @userId
					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userId, @newValue OUTPUT
					
				END
				ELSE IF @modType = 'U'
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userId, @oldValue OUTPUT				
					
					UPDATE main SET
						 main.firstName						= mode.firstName
						,main.middleName					= mode.middleName
						,main.lastName						= mode.lastName
						,main.salutation					= mode.salutation
						,main.gender						= mode.gender
						,main.telephoneNo					= mode.telephoneNo
						,main.mobileNo						= mode.mobileNo
						,main.state							= mode.state
						,main.district						= mode.district
						,main.zip							= mode.zip
						,main.[address]						= mode.[address]
						,main.city							= mode.city
						,main.countryId						= mode.countryId
						,main.email							= mode.email
						,main.agentId						= mode.agentId
						,main.sessionTimeOutPeriod			= mode.sessionTimeOutPeriod 
						,main.tranApproveLimit				= mode.tranApproveLimit
						,main.agentCrLimitAmt				= mode.agentCrLimitAmt
						,main.loginTime						= mode.loginTime
						,main.logoutTime					= mode.logoutTime
						,main.userAccessLevel				= mode.userAccessLevel
						,main.perDayTranLimit				= mode.perDayTranLimit 
						,main.fromSendTrnTime				= mode.fromSendTrnTime
						,main.toSendTrnTime					= mode.toSendTrnTime
						,main.fromPayTrnTime				= mode.fromPayTrnTime
						,main.toPayTrnTime					= mode.toPayTrnTime
						,main.fromRptViewTime				= mode.fromRptViewTime
						,main.toRptViewTime					= mode.toRptViewTime
						,main.pwdChangeDays					= mode.pwdChangeDays
						,main.pwdChangeWarningDays			= mode.pwdChangeWarningDays 	
						,main.maxReportViewDays				= mode.maxReportViewDays
						,main.userType						= mode.userType          
						,main.modifiedDate					= GETDATE()
						,main.modifiedBy					= @user
					FROM applicationUsers main
					INNER JOIN applicationUsersMod mode ON mode.userId= main.userId
						WHERE mode.userId = @userId
					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userId, @newValue OUTPUT
					
				END
				ELSE IF @modType = 'D'
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userId, @oldValue OUTPUT
					UPDATE applicationUsers SET
						 isDeleted = 'Y'
						,isActive = 'N'
						,modifiedDate = GETDATE()
						,modifiedBy = @user

					WHERE userId = @userId
					
				END
				
				DELETE FROM applicationUsersMod WHERE userId = @userId
				
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userId, @user, @oldValue, @newValue, @module				
			END
			
			IF @roleChanges = 'Y'
			BEGIN
				SELECT 
					@newValue = ISNULL(@newValue + ',', '') + CAST(roleId AS VARCHAR(50))
				FROM applicationUserRolesMod 
				WHERE userId = @userId
				
				EXEC [dbo].proc_GetColumnToRow  'applicationUserRoles', 'userId', @userId, @oldValue OUTPUT
						
					DELETE FROM applicationUserRoles WHERE userId = @userId
					INSERT applicationUserRoles(roleId, userId, createdBy, createdDate)
					SELECT roleId, @userId, @user, GETDATE() FROM applicationUserRolesMod WHERE userId = @userId

					DELETE FROM applicationUserRolesMod WHERE userId = @userId
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Update', 'User Roles', @userId, @user, @oldValue, @newValue, @module
			END
			
			IF @functionChanges = 'Y'
			BEGIN

				SELECT 
					@newValue = ISNULL(@newValue + ',', '') + CAST(functionId AS VARCHAR(50))
				FROM applicationUserFunctionsMod 
				WHERE userId = @userId
				
				EXEC [dbo].proc_GetColumnToRow  'applicationUserFunctions', 'userId', @userId, @oldValue OUTPUT		
					DELETE FROM applicationUserFunctions WHERE userId = @userId
					INSERT applicationUserFunctions(functionId, userId, createdBy, createdDate)
					SELECT functionId, @userId, @user, GETDATE() FROM applicationUserFunctionsMod WHERE userId = @userId

					DELETE FROM applicationUserFunctionsMod WHERE userId = @userId
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Update', 'User Functions', @userId, @user, @oldValue, @newValue, @module
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @userId
				RETURN
			END
			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @userId
	END	
    
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errorCode, ERROR_MESSAGE() mes, null id
END CATCH



GO
