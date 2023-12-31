USE [FastMoneyPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_applicationUsers]    Script Date: 2/5/2019 5:19:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[proc_applicationUsers]
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
	 ,@countryName						VARCHAR(100)	= NULL
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
     ,@approvedDate                     DATETIME		= NULL
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
	 ,@userType							VARCHAR(2)		= NULL
	 ,@txnPwd							VARCHAR(255)	= NULL	
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
		
	IF @userId is null
		SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) 
		WHERE userName = @user
	
	if @parentAgentId is null
		select 	@parentAgentId=parentId from agentMaster WITH(NOLOCK)  
		where agentId=@agentId
	
	IF @flag = 'an'
	BEGIN
		SELECT agentName FROM agentMaster WHERE
		agentId = (SELECT agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user)
	END
	
	IF @flag = 'HO' ---## POPULATE HO USER
	BEGIN
		select userName from applicationUsers a with(nolock) inner join agentMaster b with(nolock) 
		on a.agentId=b.agentId where b.agentType=2901 and
		a.isActive='Y' and ISNULL(a.isDeleted,'N')<>'Y' order by userName
	END
	
	IF @flag = 'agent' ---## POPULATE AGENT USER
	BEGIN
		select userName,B.agentType from applicationUsers a with(nolock) inner join agentMaster b with(nolock) 
		on a.agentId=b.agentId where b.agentType<>2901 and
		a.isActive='Y' and ISNULL(a.isDeleted,'N')<>'Y' order by userName
	END
	
	ELSE IF @flag = 'lu'			--lu - Lock/Unlock
	BEGIN
		SELECT @userName = userName, @isLocked = isLocked FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId
		UPDATE applicationUsers SET
			 isLocked = CASE WHEN @isLocked = 'N' THEN 'Y' ELSE 'N' END
		WHERE userId = @userId
		 
		IF @isLocked = 'Y'
		BEGIN
			SET @msg = 'User with Username ' + @userName + ' unlocked successfully'
			EXEC proc_errorHandler 0, @msg, @userId
			INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
			SELECT @userName, 'User account unlocked successfully', @user, GETDATE()
		END
		ELSE
		BEGIN
			SET @msg = 'User with Username ' + @userName + ' locked successfully'
			EXEC proc_errorHandler 0, @msg, @userId
			INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
			SELECT @userName, 'Account locked by administrator', @user, GETDATE()
		END
		
	END
	
	ELSE IF @flag = 'lr'
	BEGIN
		SELECT TOP 1
			 createdBy
			,createdDate
			,lockReason
		FROM userLockHistory WITH(NOLOCK) 
		WHERE username = @userName 
		ORDER BY ulhId DESC
	END	
	
	ELSE IF @flag = 'userDetail'
	BEGIN
		DECLARE 
			@branch INT, @branchName VARCHAR(100), @agent INT, @superAgent INT, @superAgentName VARCHAR(100),
			@mapCodeInt VARCHAR(8), @parentMapCodeInt VARCHAR(8), @agentType INT, @settlingAgent INT, @parentId INT, @actAsBranch CHAR(1),
			@mapCodeDom	VARCHAR(8)
		SELECT @branch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName
		SELECT 
			@branchName = agentName, @agentName = agentName, 
			@mapCodeInt = mapCodeInt, @parentmapCodeInt = mapCodeInt, @mapCodeDom = mapCodeDom,
			@agentType = agentType, @actAsBranch = actAsBranch, @agent = parentId, @superAgent = parentId, @parentId = parentId
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @branch
		IF @branch <> dbo.FNAGetHOAgentId()
		BEGIN
			IF(@agentType = 2903)
			BEGIN
				SET @agent = @branch
			END
			ELSE
			BEGIN
				SELECT @agentName = agentName, @parentMapCodeInt = mapCodeInt, @superAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agent
			END
			SELECT @superAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @superAgent
			
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @branch AND isSettlingAgent = 'Y'
			IF @settlingAgent IS NULL
				SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agent AND isSettlingAgent = 'Y'
			IF @settlingAgent IS NULL
				SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @superAgent AND isSettlingAgent = 'Y'
		END
		
		SELECT 
			 au.*
			,fullName = au.firstName + ISNULL(' ' + au.middleName, '') + ISNULL(' ' + au.lastName, '') 
			,parentId = ISNULL(@parentId, 0)
			,agentType = ISNULL(@agentType, 2901)
			,settlingAgent = ISNULL(@settlingAgent, 0)
			,actAsBranch = ISNULL(@actAsBranch, 'N')
			,mapCodeInt = ISNULL(@mapCodeInt, '0000')
			,parentMapCodeInt = ISNULL(@parentMapCodeInt, '0000')
			,mapCodeDom = ISNULL(@mapCodeDom, '0000')
			,branch = @branch
			,branchName = @branchName
			,agent = @agent
			,agentName = @agentName
			,superAgent = ISNULL(@superAgent, 0)
			,superAgentName = ISNULL(@superAgentName, 0)
		FROM applicationUsers au WITH(NOLOCK)
        WHERE au.userName = @userName
	END
	
	IF @flag IN ('hs') 
	BEGIN
		DECLARE @hasRight CHAR(1)
		SET @hasRight = dbo.FNAHasRight(@user, CAST(@ApprovedFunctionId AS VARCHAR))

		SET @table = '(
				SELECT
					 userId				= ISNULL(aum.userId, au.userId)
					,[userName]			= ISNULL(aum.userName, au.userName)
					,agentCode			= ISNULL(aum.agentCode, au.agentCode)
					,firstName			= ISNULL(aum.firstName, au.firstName)
					,middleName			= ISNULL(aum.middleName, au.middleName)
					,lastName			= ISNULL(aum.lastName, au.lastName)
					,salutation			= ISNULL(aum.salutation, au.salutation)
					,gender				= ISNULL(aum.gender, au.gender)
					,[address]			= ISNULL(aum.address, au.address)
					,city				= ISNULL(aum.city, au.city)
					,countryId			= ISNULL(aum.countryId, au.countryId)
					,state				= ISNULL(aum.state, au.state)
					,district			= ISNULL(aum.district, au.district)
					,zip				= ISNULL(aum.zip, au.zip)
					,telephoneNo		= ISNULL(aum.telephoneNo, au.telephoneNo)
					,mobileNo			= ISNULL(aum.mobileNo, au.mobileNo)
					,email				= ISNULL(aum.email, au.email)
					,pwd				= ISNULL(aum.pwd, au.pwd)
					,isActive			= ISNULL(aum.isActive, au.isActive)
					,isLocked			= au.isLocked
					,agentId			= ISNULL(aum.agentId, au.agentId)
					,sessionTimeOutPeriod	= ISNULL(aum.sessionTimeOutPeriod, au.sessionTimeOutPeriod)
					,loginTime				= ISNULL(aum.loginTime, au.loginTime)
					,logoutTime				= ISNULL(aum.logoutTime, au.logoutTime)
					,userAccessLevel		= ISNULL(aum.userAccessLevel, au.userAccessLevel)
					,lastLoginTs			= ISNULL(aum.lastLoginTs, au.lastLoginTs)
					,pwdChangeDays			= ISNULL(aum.pwdChangeDays, au.pwdChangeDays)
					,pwdChangeWarningDays	= ISNULL(aum.pwdChangeWarningDays, au.pwdChangeWarningDays)
					,lastPwdChangedOn		= ISNULL(aum.lastPwdChangedOn, au.lastPwdChangedOn)
					,forceChangePwd			= ISNULL(aum.forceChangePwd, au.forceChangePwd)
					,maxReportViewDays		= ISNULL(aum.maxReportViewDays, au.maxReportViewDays)
					,au.createdBy
					,au.createdDate	
					,modifiedDate = CASE WHEN au.approvedBy IS NULL THEN au.createdDate ELSE aum.createdDate END
					,modifiedBy = CASE WHEN au.approvedBy IS NULL THEN au.createdBy ELSE aum.createdBy END
					,hasChanged = CASE WHEN (au.approvedBy IS NULL) OR 
											(aum.userId IS NOT NULL) OR
											(x.userId IS NOT NULL) OR 
											(y.userId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM 
				applicationUsers au with(nolock)
				LEFT JOIN (
						SELECT 
							 userId
							,createdBy = MAX(createdBy)
							,createdDate = MAX(createdDate)
						FROM applicationUserFunctionsMod aufm WITH(NOLOCK)
						GROUP BY userId
					) x ON au.userId = x.userId	
				LEFT JOIN (
						SELECT 
							 userId
							,createdBy = MAX(createdBy)
							,createdDate = MAX(createdDate)
						FROM applicationUserRolesMod aurm WITH(NOLOCK)
						GROUP BY userId
					) y ON au.userId = y.userId	
				LEFT JOIN applicationUsersMod aum ON au.userId = aum.userId 
					AND (
							aum.createdBy = ''' +  @user + ''' 
							OR ''Y'' = ''' + @hasRight + '''
						)
				WHERE ISNULL(au.isDeleted, ''N'')  <> ''Y''
					AND (
							au.approvedBy IS NOT NULL 
							OR au.createdBy = ''' +  @user + ''' 
							OR ''Y'' = ''' + @hasRight + '''
						)
					
			) '
	END
	
	ELSE IF @flag IN ('s','t') 
	BEGIN
		SET @hasRight = dbo.FNAHasRight(@user, CAST(@ApprovedFunctionId AS VARCHAR))
		IF (@user IN ('admin', 'admin1'))
		BEGIN
			SET @table = '(
					SELECT
						 userId				= ISNULL(aum.userId, au.userId)
						,[userName]			= ISNULL(aum.userName, au.userName)
						,agentCode			= ISNULL(aum.agentCode, au.agentCode)
						,userType			= ISNULL(aum.userType, au.userType)
						,firstName			= ISNULL(aum.firstName, au.firstName)
						,middleName			= ISNULL(aum.middleName, au.middleName)
						,lastName			= ISNULL(aum.lastName, au.lastName)
						,salutation			= ISNULL(aum.salutation, au.salutation)
						,gender				= ISNULL(aum.gender, au.gender)
						,[address]			= ISNULL(aum.address, au.address)
						,city				= ISNULL(aum.city, au.city)
						,countryId			= ISNULL(aum.countryId, au.countryId)
						,state				= ISNULL(aum.state, au.state)
						,district			= ISNULL(aum.district, au.district)
						,zip				= ISNULL(aum.zip, au.zip)
						,telephoneNo		= ISNULL(aum.telephoneNo, au.telephoneNo)
						,mobileNo			= ISNULL(aum.mobileNo, au.mobileNo)
						,email				= ISNULL(aum.email, au.email)
						,pwd				= ISNULL(aum.pwd, au.pwd)
						,isActive			= ISNULL(aum.isActive, au.isActive)
						,isLocked			= au.isLocked
						,agentId			= ISNULL(aum.agentId, au.agentId)
						,sessionTimeOutPeriod	= ISNULL(aum.sessionTimeOutPeriod, au.sessionTimeOutPeriod)
						,loginTime				= ISNULL(aum.loginTime, au.loginTime)
						,logoutTime				= ISNULL(aum.logoutTime, au.logoutTime)
						,userAccessLevel		= ISNULL(aum.userAccessLevel, au.userAccessLevel)
						,lastLoginTs			= ISNULL(aum.lastLoginTs, au.lastLoginTs)
						,pwdChangeDays			= ISNULL(aum.pwdChangeDays, au.pwdChangeDays)
						,pwdChangeWarningDays	= ISNULL(aum.pwdChangeWarningDays, au.pwdChangeWarningDays)
						,lastPwdChangedOn		= ISNULL(aum.lastPwdChangedOn, au.lastPwdChangedOn)
						,forceChangePwd			= ISNULL(aum.forceChangePwd, au.forceChangePwd)
						,maxReportViewDays		= ISNULL(aum.maxReportViewDays, au.maxReportViewDays)
						,employeeId				= au.employeeId
						,au.createdBy
						,au.createdDate			
						,modifiedDate = CASE WHEN au.approvedBy IS NULL THEN au.createdDate ELSE aum.createdDate END
						,modifiedBy = CASE WHEN au.approvedBy IS NULL THEN au.createdBy ELSE aum.createdBy END
						,hasChanged = CASE WHEN (au.approvedBy IS NULL) OR 
												(aum.userId IS NOT NULL) OR
												(x.userId IS NOT NULL) OR 
												(y.userId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END
					FROM 
					applicationUsers au with(nolock)
					LEFT JOIN (
							SELECT 
								 userId
								,createdBy = MAX(createdBy)
								,createdDate = MAX(createdDate)
							FROM applicationUserFunctionsMod aufm WITH(NOLOCK)
							GROUP BY userId
						) x ON au.userId = x.userId	
					LEFT JOIN (
							SELECT 
								 userId
								,createdBy = MAX(createdBy)
								,createdDate = MAX(createdDate)
							FROM applicationUserRolesMod aurm WITH(NOLOCK)
							GROUP BY userId
						) y ON au.userId = y.userId	
					LEFT JOIN applicationUsersMod aum ON au.userId = aum.userId 
						AND (
								aum.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
					WHERE ISNULL(au.isDeleted, ''N'')  <> ''Y''
						AND (
								au.approvedBy IS NOT NULL 
								OR au.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
						
				) '
		END
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#userId') IS NOT NULL
				DROP TABLE #userId
			CREATE TABLE #userId(userId INT)
			INSERT INTO #userId 
			SELECT userId FROM applicationUsers WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N'
			
			DELETE FROM #userId
			FROM #userId ui
			INNER JOIN
			userGroupMapping ugm ON ui.userId = ugm.userId
			WHERE ugm.groupCat = '6900' AND ISNULL(ugm.isDeleted, 'N') = 'N'
			
			INSERT INTO #userId
			SELECT DISTINCT userId FROM applicationUsers au WITH(NOLOCK) 
			INNER JOIN(
			SELECT DISTINCT agm.agentId FROM agentGroupMaping agm 
			WHERE agm.groupDetail IN (SELECT groupDetail FROM userGroupMapping WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N')
			AND ISNULL(agm.isDeleted, 'N') = 'N'
			)x ON au.agentId = x.agentId

			SET @table = '(
					SELECT
						 userId					= ISNULL(aum.userId, au.userId)
						,[userName]				= ISNULL(aum.userName, au.userName)
						,agentCode				= ISNULL(aum.agentCode, au.agentCode)
						,userType				= ISNULL(aum.userType, au.userType)
						,firstName				= ISNULL(aum.firstName, au.firstName)
						,middleName				= ISNULL(aum.middleName, au.middleName)
						,lastName				= ISNULL(aum.lastName, au.lastName)
						,salutation				= ISNULL(aum.salutation, au.salutation)
						,gender					= ISNULL(aum.gender, au.gender)
						,[address]				= ISNULL(aum.address, au.address)
						,city					= ISNULL(aum.city, au.city)
						,countryId				= ISNULL(aum.countryId, au.countryId)
						,state					= ISNULL(aum.state, au.state)
						,district				= ISNULL(aum.district, au.district)
						,zip					= ISNULL(aum.zip, au.zip)
						,telephoneNo			= ISNULL(aum.telephoneNo, au.telephoneNo)
						,mobileNo				= ISNULL(aum.mobileNo, au.mobileNo)
						,email					= ISNULL(aum.email, au.email)
						,pwd					= ISNULL(aum.pwd, au.pwd)
						,isActive				= ISNULL(aum.isActive, au.isActive)
						,isLocked				= au.isLocked
						,agentId				= ISNULL(aum.agentId, au.agentId)
						,sessionTimeOutPeriod	= ISNULL(aum.sessionTimeOutPeriod, au.sessionTimeOutPeriod)
						,loginTime				= ISNULL(aum.loginTime, au.loginTime)
						,logoutTime				= ISNULL(aum.logoutTime, au.logoutTime)
						,userAccessLevel		= ISNULL(aum.userAccessLevel, au.userAccessLevel)
						,lastLoginTs			= ISNULL(aum.lastLoginTs, au.lastLoginTs)
						,pwdChangeDays			= ISNULL(aum.pwdChangeDays, au.pwdChangeDays)
						,pwdChangeWarningDays	= ISNULL(aum.pwdChangeWarningDays, au.pwdChangeWarningDays)
						,lastPwdChangedOn		= ISNULL(aum.lastPwdChangedOn, au.lastPwdChangedOn)
						,forceChangePwd			= ISNULL(aum.forceChangePwd, au.forceChangePwd)
						,maxReportViewDays		= ISNULL(aum.maxReportViewDays, au.maxReportViewDays)
						,au.employeeId
						,au.createdBy
						,au.createdDate			
						,modifiedDate = CASE WHEN au.approvedBy IS NULL THEN au.createdDate ELSE aum.createdDate END
						,modifiedBy = CASE WHEN au.approvedBy IS NULL THEN au.createdBy ELSE aum.createdBy END
						,hasChanged = CASE WHEN (au.approvedBy IS NULL) OR 
												(aum.userId IS NOT NULL) OR
												(x.userId IS NOT NULL) OR 
												(y.userId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END
					FROM applicationUsers au WITH(NOLOCK) 
					INNER JOIN
					(					
						--SELECT * FROM userGroupMapping
						--SELECT aum.* FROM userGroupMapping ugm 
						--inner join agentGroupMaping agm on ugm.groupDetail=agm.groupDetail
						--inner join applicationUsers aum on aum.userId = ugm.userId
						--where a.userName= ''' +  @user + ''' 
						SELECT DISTINCT userId FROM #userId

					) u ON au.userId = u.userId 
					LEFT JOIN (
							SELECT 
								 userId
								,createdBy = MAX(createdBy)
								,createdDate = MAX(createdDate)
							FROM applicationUserFunctionsMod aufm WITH(NOLOCK)
							GROUP BY userId
						) x ON au.userId = x.userId	
					LEFT JOIN (
							SELECT 
								 userId
								,createdBy = MAX(createdBy)
								,createdDate = MAX(createdDate)
							FROM applicationUserRolesMod aurm WITH(NOLOCK)
							GROUP BY userId
						) y ON au.userId = y.userId	
					LEFT JOIN applicationUsersMod aum ON au.userId = aum.userId 
						AND (
								aum.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
					WHERE ISNULL(au.isDeleted, ''N'')  <> ''Y''
						AND (
								au.approvedBy IS NOT NULL 
								OR au.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
						
				) '
		end	
	
	END
	
	IF @flag = 'i'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Corresponding Agent has not been approved yet', @employeeId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM applicationUsers WHERE [userName] = @userName )
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
                    ,approvedDate
                    ,lastLoginTs
                    ,pwdChangeDays
                    ,pwdChangeWarningDays
                    ,lastPwdChangedOn
                    ,forceChangePwd
                    ,maxReportViewDays
                    ,createdBy
                    ,createdDate
                    ,employeeId
					,userType
					,isActive
					,txnPwd
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
                    ,@approvedDate
                    ,@lastLoginTs
                    ,@pwdChangeDays
                    ,@pwdChangeWarningDays
                    ,@lastPwdChangedOn
                    ,'Y'
                    ,@maxReportViewDays
                    ,@user
                    ,GETDATE()
                    ,@employeeId
					,@userType
					,'N'
					,@txnPwd

               SET @userId = SCOPE_IDENTITY()
               
				IF @employeeId IS NULL
				BEGIN
					UPDATE applicationUsers SET
						 employeeId = CAST(@userId AS VARCHAR)
					WHERE userId = @userId
				END
				
				IF @agentCode IS NULL
				BEGIN
					SELECT @agentCode = agentCode FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
					UPDATE applicationUsers SET
						 agentCode		= @agentCode
					WHERE userId = @userId
				END
				
				ELSE IF @agentCode IS NOT NULL
				BEGIN
					UPDATE agentMaster SET agentCode = @agentCode WHERE agentId = @agentId
				END
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
               SELECT 0 errorCode, 'Record has been added successfully with User Code ' + CAST(ISNULL(@userId, '') AS VARCHAR) mes, @userId id
	 END

	ELSE IF @flag = 'u'
    BEGIN
	
		IF EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM applicationUserFunctionsMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END	
		BEGIN TRANSACTION
		
			SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId
			IF EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL AND createdBy = @user)
			BEGIN
				UPDATE applicationUsers SET
					  firstName						= @firstName
					 ,middleName                    = @middleName
					 ,lastName                      = @lastName
					 ,salutation                    = @salutation
					 ,gender                        = @gender
					 ,telephoneNo                   = @telephoneNo
					 ,mobileNo                      = @mobileNo
					 ,state							= @state
					 ,district						= @district
					 ,zip							= @zip
					 ,[address]						= @address
					 ,city							= @city
					 ,countryId						= @countryId
					 ,email                         = @email
					 ,agentId                       = @agentId
					 ,sessionTimeOutPeriod			= @sessionTimeOutPeriod 
					 ,tranApproveLimit				= @tranApproveLimit
					 ,agentCrLimitAmt				= @agentCrLimitAmt
					 ,loginTime						= @loginTime
					 ,logoutTime					= @logoutTime
					 ,userAccessLevel				= @userAccessLevel
					 ,perDayTranLimit				= @perDayTranLimit
					 ,fromSendTrnTime				= @fromSendTrnTime
					,toSendTrnTime					= @toSendTrnTime
                    ,fromPayTrnTime					= @fromPayTrnTime
                    ,toPayTrnTime					= @toPayTrnTime
                    ,fromRptViewTime				= @fromRptViewTime
                    ,toRptViewTime					= @toRptViewTime	
					 ,pwdChangeDays                 = @pwdChangeDays
					 ,pwdChangeWarningDays          = @pwdChangeWarningDays 	
					 ,maxReportViewDays				= @maxReportViewDays
					 ,userType						= @userType	
					 ,isActive						= ISNULL(@isActive,'Y')	
				WHERE userId = @userId
			END 
			ELSE
			BEGIN
				DELETE FROM applicationUsersMod WHERE userId = @userId
					
				INSERT INTO applicationUsersMod (
					 userId
					,agentCode
					--,employeeId
					,userName
					,firstName						
					,middleName                    
					,lastName                    
					,salutation        
					,gender               
					,telephoneNo               
					,mobileNo 
					,state 
					,district
					,zip                  
					,[address]					
					,city						
					,countryId					
					,email                                                         
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
					,pwdChangeDays                 
					,pwdChangeWarningDays   
					,maxReportViewDays       		                 
					,createdDate
					,createdBy
					,modType    
					,userType    
					,isActive            
				)
				SELECT
					 @userId
					,@agentCode
					--,@employeeId
					,@userName
					,@firstName
					,@middleName
					,@lastName
					,@salutation
					,@gender
					,@telephoneNo
					,@mobileNo
					,@state
					,@district
					,@zip
					,@address
					,@city
					,@countryId
					,@email
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
					,@pwdChangeDays
					,@pwdChangeWarningDays 		
					,@maxReportViewDays	           
					,GETDATE()
					,@user
					,'U'  
					,@userType
					,isActive
			FROM applicationUsers  (NOLOCK) WHERE userId = @userId        
			END
        COMMIT TRANSACTION       
        EXEC proc_errorHandler 0, 'Record updated successfully', @agentId
     END

	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId AND createdBy = @user)
		BEGIN
			SELECT 
			     pwd = dbo.decryptDb(main.pwd),
				 mode.*
				,agentName = am.agentName + '|' + CAST(am.agentId AS VARCHAR) + '|' + CAST(am.agentType AS VARCHAR)
				,dbo.FNADecryptString(mode.pwd) as DePWD
				,main.modifiedBy
				,main.modifiedDate
				,dbo.FNADecryptString(mode.txnPwd) as DeTxnPWD
			FROM applicationUsersMod mode WITH(NOLOCK) 
			INNER JOIN applicationUsers main WITH(NOLOCK) ON mode.userId = main.userId
			LEFT JOIN agentMaster am WITH(NOLOCK) ON mode.agentId = am.agentId
			WHERE mode.userId = @userId	

		END
		ELSE
		BEGIN
			SELECT 
				 pwd = dbo.decryptDb(pwd),
				 main.*
				,agentName = am.agentName + '|' + CAST(am.agentId AS VARCHAR) + '|' + CAST(am.agentType AS VARCHAR)
				,dbo.FNADecryptString(pwd) as DePWD
				,dbo.FNADecryptString(txnPwd) as DeTxnPWD
				
			FROM applicationUsers main WITH(NOLOCK)
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			WHERE main.userId = @userId	
	
		END
	END	
	
	ELSE IF @flag = 'a1'
	BEGIN
		
			SELECT 
				 main.*
				,agentName = am.agentName + '|' + CAST(am.agentId AS VARCHAR) + '|' + CAST(am.agentType AS VARCHAR)
				,dbo.FNADecryptString(pwd) as DePWD
				,dbo.FNADecryptString(txnPwd) as DeTxnPWD
			FROM applicationUsers main WITH(NOLOCK)
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			WHERE main.userId = @userId	
	
		
	END	
	
	ELSE IF @flag = 'pullDefault'
	BEGIN
		--SELECT top 1 main.* FROM applicationUsers main WITH(NOLOCK) WHERE agentId = @parentAgentId
		
		SELECT TOP 1 
			 city = agentCity
			 ,agentName = agentName + '|' + CAST(agentId AS VARCHAR) + '|' + CAST(agentType AS VARCHAR)
			,countryId = agentCountryId
			,[state] = agentState
			,[district] = agentDistrict
			,zip = agentZip
			,[address] = agentAddress 
			,phone1 = agentPhone1
			,phone2 = agentPhone2
			,mobile1 = agentMobile1
			,mobile2 = agentMobile2
			,email = agentEmail1
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
		--SELECT  main.* FROM applicationUsers main WITH(NOLOCK) WHERE agentId = 1
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF @userId = 1
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete admin user', @userId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM applicationUserRolesMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM applicationUserFunctionsMod WITH(NOLOCK) WHERE userId = @userId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @userId
			RETURN
		END	
		
		BEGIN TRANSACTION	
		IF EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM applicationUsers WHERE userId = @userId
		END
		ELSE
		BEGIN
			INSERT INTO applicationUsersMod (
				 userId
				,userName
				,agentCode
				,firstName						
				,middleName                    
				,lastName                    
				,salutation        
				,gender               
				,telephoneNo               
				,mobileNo  
				,state
				,district
				,zip                 
				,[address]					
				,city						
				,countryId					
				,email                                                           
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
				,pwdChangeDays                 
				,pwdChangeWarningDays      
				,maxReportViewDays    		                 
				,createdDate
				,createdBy
				,modType  
				,userType    
				,isActive            
			)
			SELECT
				 userId
				,userName
				,agentCode
				,firstName						
				,middleName                    
				,lastName                    
				,salutation        
				,gender               
				,telephoneNo               
				,mobileNo 
				,state
				,district
				,zip                  
				,[address]					
				,city						
				,countryId					
				,email                                                            
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
				,pwdChangeDays                 
				,pwdChangeWarningDays 
				,@maxReportViewDays         		                 				           
				,GETDATE()
				,@user
				,'D'
				,userType
				,isActive
			FROM applicationUsers WHERE userId = @userId
		END
		
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @userId
	END
	
	ELSE IF @flag = 'hs'
    BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'userId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.userId
							,main.userName
							,name = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName, '''')
							,main.firstName
							,main.middleName
							,main.lastName
							,main.address
							,main.countryId 
							,countryName = cm.countryName
							,main.agentId       
							,am.agentName
							,main.agentCode
							,main.isLocked
							,main.lastLoginTs
							,main.lastPwdChangedOn
							,lockStatus = CASE WHEN ISNULL(main.isLocked, ''N'') = ''N'' THEN ''N | <a href="#" onclick="LockUnlock('' + CAST(main.userId AS VARCHAR) + '', ''''l'''')">Lock</a>''
											WHEN ISNULL(main.isLocked, ''N'') = ''Y'' THEN ''Y | <a href="#" onclick="LockUnlock('' + CAST(main.userId AS VARCHAR) + '', ''''l'''')">Unlock</a> | <a id="showSlab_'' + CAST(main.userId AS VARCHAR) + ''" href="#" onclick="ShowSlab('' + CAST(main.userId 
AS VARCHAR) + '','''''' + main.userName + '''''')">View Reason</a>'' END     
											           
							,userGroup = CASE WHEN am.agentType = ''2904'' OR am.actAsBranch = ''Y'' THEN ''''
											ELSE 
											''<a href="/SwiftSystem/UserManagement/ApplicationUserSetup/UserGroupMaping.aspx?userName='' + main.userName + ''&userId='' + CAST(main.userId AS VARCHAR) + ''&agentId='' + CAST(main.agentId AS VARCHAR) + ''" ">
											<img src="/images/user_icon.gif" border=0 title="User Grouping" alt="User Group" /></a>'' END                
							,main.haschanged
							,main.modifiedBy
							,main.createdBy	
							,main.isActive			
						FROM ' + @table + ' main 
						INNER JOIN agentMaster am ON main.agentId = am.agentId
						LEFT JOIN countryMaster cm ON main.countryId = cm.countryId
						WHERE userName <> ''' + @user + ''' AND am.agentType = 2901
					) x'
					
		SET @sql_filter = ''		
		
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + @haschanged + ''''
			
		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userName, '''') LIKE ''%' + @userName + '%'''
			
		IF @firstName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(firstName, '''') LIKE ''%' + @firstName + '%'''
		
		IF @lastName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(lastName, '''') LIKE ''%' + @lastName + '%'''
		
		IF @countryId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryId, '''') = ' + CAST(@countryId AS VARCHAR)
		
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentId, '''') = ' + CAST(@agentId AS VARCHAR)	
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
		
		IF @isLocked IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isLocked, ''N'') = ''' + @isLocked + ''''

		IF @isActive IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isActive, ''Y'') = ''' + @isActive + ''''
			
		SET @select_field_list ='
				userId
			   ,userName
			   ,name
			   ,firstName               
			   ,middleName
			   ,lastName
			   ,address  
			   ,countryId
			   ,countryName   
			   ,agentId          
			   ,agentName
			   ,agentCode
			   ,isLocked
			   ,lockStatus
			   ,userGroup
			   ,haschanged
			   ,modifiedBy
			   ,createdBy
			   ,isActive
			   ,lastLoginTs
			   ,lastPwdChangedOn
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
	
	ELSE IF @flag = 's'
    BEGIN

		IF @sortBy IS NULL
		   SET @sortBy = 'userId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.userId
							,main.userName
							,name = ISNULL(main.firstName, '''') + ISNULL( '' '' + main.middleName, '''')+ ISNULL( '' '' + main.lastName, '''')
							,main.firstName
							,main.middleName
							,main.lastName
							,main.address
							,contactNo = ISNULL(main.telephoneNo, main.mobileNo)
							,main.countryId 
							,countryName = cm.countryName
							,main.agentId       
							,am.agentName
							,main.agentCode
							,main.employeeId
							,main.isLocked
							,main.userType
							,lockStatus = CASE WHEN ISNULL(main.isLocked, ''N'') = ''N'' THEN ''N | <a href="#" onclick="LockUnlock('' + CAST(main.userId AS VARCHAR) + '', ''''l'''')">Lock</a>''
											WHEN ISNULL(main.isLocked, ''N'') = ''Y'' THEN ''Y | <a href="#" onclick="LockUnlock('' + CAST(main.userId AS VARCHAR) + '', ''''l'''')">Unlock</a> | <a id="showSlab_'' + CAST(main.userId AS VARCHAR) 
											+ ''" href="#" onclick="ShowSlab('' + CAST(main.userId AS VARCHAR) + '','''''' + main.userName + '''''')">View Reason</a>'' END    
											           
							,userGroup = CASE WHEN am.agentType = ''2904'' OR am.actAsBranch = ''Y'' THEN ''''
											ELSE 
											''<a href="/SwiftSystem/UserManagement/ApplicationUserSetup/UserGroupMaping.aspx?userName='' + main.userName + ''&userId='' + CAST(main.userId AS VARCHAR) + ''&agentId='' + CAST(main.agentId AS VARCHAR) + ''" ">
											<img src="/images/user_icon.gif" border=0 title="User Grouping" alt="User Group" /></a>'' END                
							,main.haschanged
							,main.modifiedBy
							,main.createdBy	
							,main.isActive	
							,main.lastLoginTs
							,main.lastPwdChangedOn	
						FROM ' + @table + ' main 
						INNER JOIN agentMaster am ON main.agentId = am.agentId
						LEFT JOIN countryMaster cm ON main.countryId = cm.countryId
						WHERE 
						userName <> ''' + @user + ''' AND am.agentType <> 2901
					) x'
					
		SET @sql_filter = ''		
	
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + @haschanged + ''''

		IF @userType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND userType = ''' + @userType + ''''	

		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userName, '''') LIKE ''' + @userName + '%'''
			
		IF @firstName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(firstName, '''') LIKE ''' + @firstName + '%'''
		
		IF @lastName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(lastName, '''') LIKE ''' + @lastName + '%'''
		
		IF @countryId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryId, '''') = ' + CAST(@countryId AS VARCHAR)
		
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentId, '''') = ' + CAST(@agentId AS VARCHAR)	
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''' + @agentName + '%'''
		
		IF @isLocked IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isLocked, ''N'') = ''' + @isLocked + ''''		
		
		IF @isActive IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isActive, ''Y'') = ''' + @isActive + ''''

		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryName, '''') LIKE ''' + @countryName + '%'''
				
		SET @select_field_list ='
				userId
			   ,userName
			   ,userType
			   ,name
			   ,firstName               
			   ,middleName
			   ,lastName
			   ,address  
			   ,contactNo
			   ,countryId
			   ,countryName   
			   ,agentId          
			   ,agentName
			   ,agentCode
			   ,employeeId
			   ,isLocked
			   ,lockStatus
			   ,userGroup
			   ,haschanged
			   ,modifiedBy
			   ,createdBy
			   ,isActive
			   ,lastLoginTs
			   ,lastPwdChangedOn
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
	
	ELSE IF @flag = 'cps'			--Check Password Status
	BEGIN
		SELECT forceChangePwd FROM applicationUsers WITH(NOLOCK) WHERE userName = @userName
	END
	
	ELSE IF @flag = 'cpcwd'			--Check Password Change Warning Days
	BEGIN
		SELECT 
				 @lastPwdChangedOn = ISNULL(lastPwdChangedOn, GETDATE())
				,@pwdChangeDays = pwdChangeDays
				,@pwdChangeWarningDays = pwdChangeWarningDays
			FROM applicationUsers au WITH(NOLOCK) WHERE au.[userName] = @userName
		
		DECLARE @pwdDays INT
		SET @pwdDays = DATEDIFF(d, @lastPwdChangedOn, GETDATE())
		IF @pwdDays >= @pwdChangeWarningDays
		BEGIN
			SELECT 
				 '101' errorCode
				,'Your password will expire in ' + CAST(@pwdChangeDays - @pwdDays AS VARCHAR) + ' day(s). <a href="/SwiftSystem/UserManagement/ApplicationUserSetup/ChangePassword.aspx" target="frmame_main" >Change Password</a>' msg 
				,NULL id	
			RETURN		
		END
		ELSE
			SELECT '0' errorCode, NULL msg, NULL id	
	END
	
    ELSE IF @flag = 'cp'
	BEGIN

		IF NOT EXISTS (SELECT 'X' FROM applicationUsers au WITH(NOLOCK) 
			 WHERE au.[userName] = @userName AND pwd = dbo.FNAEncryptString(@oldPwd))
		BEGIN		
			
			SELECT 1 errorCode, 'Old password is not correct.' mes, @userName id
			RETURN
		END
		
		DECLARE @pwdHistoryNum INT = NULL
		DECLARE @tempPwdTable TABLE(pwd VARCHAR(50))

		SELECT @pwdHistoryNum = pwdHistoryNum FROM passwordFormat WITH(NOLOCK)

		SET @sql = 'SELECT TOP ' + CAST(@pwdHistoryNum AS VARCHAR) + ' pwd FROM passwordHistory WITH(NOLOCK) WHERE userName = ''' + @userName + ''' ORDER BY createdDate DESC'
		INSERT INTO @tempPwdTable

		EXEC(@sql)


		IF dbo.FNAEncryptString(@pwd) IN (SELECT pwd FROM @tempPwdTable)
		BEGIN
			EXEC proc_errorHandler 1, 'Password has been already used previously. Please enter the new one.', @userName
			RETURN
		END
		
		--Validate Password From Password Policy---------------------------------------------------------------
		IF(SELECT TOP 1 errorCode FROM dbo.FNAValidatePassword(@pwd)) <> 0
		BEGIN
			SELECT * FROM dbo.FNAValidatePassword(@pwd)
			RETURN
		END
		-------------------------------------------------------------------------------------------------------
		
		UPDATE applicationUsers SET
			 pwd = dbo.FNAEncryptString(@pwd)
			,lastPwdChangedOn = GETDATE()
			,forceChangePwd = 'N'
		WHERE  [userName]= @userName
		
		--Keep password History---------------------------------------------------------------------
		INSERT INTO passwordHistory(
			 userName
			,pwd
			,createdDate
			,createdBy
		)
		SELECT @userName, dbo.FNAEncryptString(@pwd), GETDATE(),@userName
		---------------------------------------------------------------------------------------------
		
		SELECT 0 errorCode, 'Password has been changed successfully.' mes, @userName id	

	END	
	
	ELSE IF @flag = 'loc'
	BEGIN
		UPDATE applicationUsers SET
			 isLocked = 'Y'			
		WHERE  [userName]= @userName
		
		INSERT INTO userLockHistory(userName, lockReason, createdBy, createdDate)
		SELECT @userName, @lockReason, 'system', GETDATE()
		SELECT 0 errorCode, 'Your account has been locked. Please, contact your administrator.' mes, @userName id
	END	
	
	ELSE IF @flag = 'r'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE userName = @userName)
		BEGIN
			SELECT 1 errorCode, 'User not found' mes, @userName id
			RETURN
		END

		UPDATE applicationUsers SET
			 pwd = dbo.FNAEncryptString(@pwd)
			,forceChangePwd = 'Y'
		WHERE  [userName] = @userName 

		--Keep password History---------------------------------------------------------------------
		
		INSERT INTO passwordHistory(
			 userName
			,pwd
			,createdDate
			,createdBy
		)
		SELECT @userName, dbo.FNAEncryptString(@pwd), GETDATE(),@user
		---------------------------------------------------------------------------------------------

		SELECT 0 errorCode, 'Password has been reset successfully.' mes, @userName id
		RETURN
	END	
	
	ELSE IF @flag = 'l' --Login
	BEGIN
		DECLARE  @UserData varchar(2000)


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
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Invalid Username',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
			RETURN
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			SET @UserInfoDetail = 'Reason = Login fails, User Locked .-:::-'+@UserInfoDetail
			SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='User Not Actived',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
			 RETURN

		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND userId = @userId AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			 SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			 SET @UserInfoDetail = 'Reason = Login fails, Invalid password.-:::-'+@UserInfoDetail
			 EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Invalid Password',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	
			RETURN
					
		END
		
		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName AND userId = @userId  AND pwd = dbo.FNAEncryptString(@pwd) AND ISNULL(isLocked, 'N') = 'Y')
		BEGIN
			SELECT 1 errorCode, 'Your account has been locked. Please, contact your administrator.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, Your account has been locked. Please, contact your administrator.-:::-'+@UserInfoDetail
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='User Locked ',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
			RETURN		
		END	
	
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE userName = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND userId = @userId  AND ISNULL(isDeleted, 'N') <> 'Y' AND CAST(GETDATE() AS TIME) > loginTime AND CAST(GETDATE() AS TIME) < logoutTime)
		BEGIN
			SELECT 1 errorCode, 'You are not permitted to login at this time. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator.-:::-'+@UserInfoDetail
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Login time Exeeded ',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	
			RETURN
	    END

	   -- DATE to DATE Lock setting
	    IF EXISTS(SELECT 'X' FROM userLockDetail 
			 WHERE userId=@userId AND GETDATE() BETWEEN startDate AND endDate
			 AND ISNULL(isDeleted, 'N') = 'N'
		)
		BEGIN
			SELECT 1 errorCode, 'You account is locked in this period. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You account is locked in this period. Please, contact your administrator.-:::-'+@UserInfoDetail
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login in this period ',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	

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
				,lastLoginTs=getdate()
			where userId = @userId

			SELECT 1 errorCode, 'You are locked this time. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are locked this time. Please, contact your administrator.-:::-'+@UserInfoDetail
	
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not Login for fix period, now user is locked',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	
			
			INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
			SELECT @userName, 'Your account has been locked due to not login for fix period', 'system', GETDATE()
			RETURN;

		END

		IF EXISTS(select top 1 'y' from userLockDetail 
				where userId =@userId and GETDATE() between startDate 
				and convert(varchar(20), endDate,101) +' 23:59:59' 
				and isnull(isDeleted,'N')='N'
	     )
		BEGIN

			SELECT 1 errorCode, 'You are not permitted to login for this date. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
			
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login for this date',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	

			RETURN;
		END

		BEGIN TRANSACTION	
		
			SELECT
				0 errorCode				
				,REPLACE(ISNULL(au.firstName, '') + ISNULL(' ' + au.middleName, '')  + ISNULL(' ' + au.lastName, ''), '  ', ' ') mes
				,id = CAST(au.userId AS VARCHAR) + '|' + @userName + '|' + CAST(ISNULL(lastLoginTs, GETDATE()) AS VARCHAR) 
			FROM applicationUsers au WITH(NOLOCK)			
			WHERE au.[userName] = @userName AND au.pwd = dbo.FNAEncryptString(@pwd)
			
			SELECT 
				 @lastPwdChangedOn = ISNULL(lastPwdChangedOn, GETDATE())
				,@forceChangePwd = ISNULL(forceChangePwd, 'N')	
				,@pwdChangeDays = pwdChangeDays
				,@pwdChangeWarningDays = pwdChangeWarningDays
			FROM applicationUsers au WITH(NOLOCK) WHERE au.[userName] = @userName AND au.pwd = dbo.FNAEncryptString(@pwd)		

			UPDATE applicationUsers SET	
				lastLoginTs = GETDATE()
			WHERE  [userName]= @userName
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION	
		
			IF @forceChangePwd = 'Y'
			BEGIN
				SELECT '100' errorCode, 'You are required to change your password.' msg , null id	
				
				SET @UserInfoDetail = 'Reason = You are required to change your password.-:::-'+@UserInfoDetail
			
				EXEC proc_applicationLogs 
					@flag='login',
					@logType='Login', 
					@createdBy = @userName, 
					@Reason='Admin Login',
					@UserData = @UserData,
					@fieldValue = @UserInfoDetail,
					@agentId=@agentId
				
				RETURN		
			END
			
			DECLARE @password_days INT
			SET @password_days = DATEDIFF(d, @lastPwdChangedOn, GETDATE())
			
			IF @password_days >= @pwdChangeDays
			BEGIN
				SET @msg = 'Your password has expired. <a href="/SwiftSystem/UserManagement/ApplicationUserSetup/ChangePassword.aspx?userName=' + @userName + '&mode=admin" target="frmame_main" >Change Password</a>'
				SELECT '101' errorCode, @msg msg , null id
				
				SET @UserInfoDetail = 'Reason = Your password has expired.-:::-'+@UserInfoDetail
			
				EXEC proc_applicationLogs 
					@flag='login',
					@logType='Login fails', 
					@createdBy = @userName, 
					@Reason='Password expired',
					@UserData = @UserData,
					@fieldValue = @UserInfoDetail,
					@agentId=@agentId	
					
				RETURN		
			END
			
			IF @password_days >= @pwdChangeWarningDays
			BEGIN

				SELECT '102' errorCode, 'Your password will expire in' + CAST(@pwdChangeDays - @password_days AS VARCHAR) + ' day(s).' msg , null id
				
				SET @UserInfoDetail = 'Reason = Your password will expire in' + CAST(@pwdChangeDays - @password_days AS VARCHAR) + ' day(s).-:::-'+@UserInfoDetail
			
				EXEC proc_applicationLogs 
					@flag='login',
					@logType='Login', 
					@createdBy = @userName, 
					@Reason='Admin Login',
					@UserData = @UserData,
					@fieldValue = @UserInfoDetail,
					@agentId=@agentId	
						
				RETURN
		
			END	
			SELECT 0 errorCode, 'Login success.' mes, @userName id	
			
			--Audit data starts
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login', 
				@createdBy = @userName, 
				@Reason='Admin Login',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
			--Audit data ends			
	END
	
	ELSE IF @flag = 'lfa' --Login for Agent
	BEGIN	
		set @UserData ='User:'+ @userName +', UserCode:'+  cast(@userId as varchar(20))
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
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Invalid Username',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId			

			RETURN		
		END
		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE userName = @userName AND pwd = dbo.FNAEncryptString(@pwd) AND agentCode = @agentCode AND userId = @userId AND ISNULL(isActive, 'N') = 'N')
		BEGIN
			SELECT 1 errorCode, 'User has not been approved.' mes, @userName id
			SET @UserInfoDetail = 'Reason = User has not been approved.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='User has not been approved',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId			

			RETURN	
			
		END
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
			 AND ISNULL(isActive, 'N') = 'Y')
		BEGIN
			SELECT 1 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, User is not Active.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='User is not Active',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId			

			RETURN		
		END
    
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y')
		BEGIN

			SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect password.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Incorrect password',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId		

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
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Incorrect AgentCode',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId		

			RETURN		
		END

		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) and ISNULL(isActive, 'N') = 'Y' 
		  AND agentCode = @agentCode AND userId = @userId )
		BEGIN

			SELECT 2 errorCode, 'Login fails, Incorrect user name or password.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Login fails, Incorrect userId.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Incorrect userId',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId		

			RETURN		
		END

		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) AND agentCode = @agentCode 
		  AND userId = @userId AND ISNULL(isLocked, 'N') = 'Y')
		BEGIN

			SELECT 1 errorCode, 'Your account has been locked. Please, contact your administrator.' mes, @userName id
			SET @UserInfoDetail = 'Reason = Your account has been locked. Please, contact your administrator.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Your account has been locked',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId		

			RETURN;		
		END	
	
		IF NOT EXISTS(SELECT 'X' FROM applicationUsers WHERE userName = @userName 
		  AND pwd = dbo.FNAEncryptString(@pwd) AND agentCode = @agentCode 
		  AND userId = @userId AND ISNULL(isDeleted, 'N') <> 'Y' 
		  AND CAST(GETDATE() AS TIME) > loginTime AND CAST(GETDATE() AS TIME) < logoutTime)
		BEGIN

			SELECT 1 errorCode, 'You are not permitted to login at this time. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
			
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login at this time',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	

			RETURN
		END

		IF EXISTS(select top 1 'y' from userLockDetail 
				where userId =@userId and GETDATE() between startDate 
				and convert(varchar(20), endDate,101) +' 23:59:59' 
				and isnull(isDeleted,'N')='N')
		BEGIN

			SELECT 1 errorCode, 'You are not permitted to login for this date. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
			
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login for this date',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	

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
				,lastLoginTs=getdate()
			where userId = @userId

			SELECT 1 errorCode, 'You are locked this time. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are locked this time. Please, contact your administrator.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not Login for fix period, now user is locked',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	
			
			INSERT INTO userLockHistory(username, lockReason, createdBy, createdDate)
			SELECT @userName, 'Your account has been locked due to not login for fix period', 'system', GETDATE()
			
			RETURN;

		END

		IF EXISTS(select top 1 'y' from userLockDetail 
				where userId =@userId and GETDATE() between startDate 
				and convert(varchar(20), endDate,101) +' 23:59:59' 
				and isnull(isDeleted,'N')='N'
	     )
		BEGIN

			SELECT 1 errorCode, 'You are not permitted to login for this date. Please, contact your administrator' mes, @userName id
			SET @UserInfoDetail = 'Reason = You are not permitted to login at this time. Please, contact your administrator-:::-'+@UserInfoDetail
			
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @userName, 
				@Reason='Not permitted to login for this date',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId	

			RETURN;
		END

		BEGIN TRANSACTION	

		
			SELECT
				0 errorCode				
				,REPLACE(ISNULL(au.firstName, '') + ISNULL(' ' + au.middleName, '')  + ISNULL(' ' + au.lastName, ''), '  ', ' ') mes
				,id = CAST(au.userId AS VARCHAR) + '|' + @userName + '|' + CAST(ISNULL(lastLoginTs, GETDATE()) AS VARCHAR) 
			FROM applicationUsers au WITH(NOLOCK)			
			WHERE au.[userName] = @userName AND au.pwd = dbo.FNAEncryptString(@pwd)	
			
			SELECT 
				 @lastPwdChangedOn = ISNULL(lastPwdChangedOn, GETDATE())
				,@forceChangePwd = ISNULL(forceChangePwd, 'N')	
				,@pwdChangeDays = pwdChangeDays
				,@pwdChangeWarningDays = pwdChangeWarningDays
			FROM applicationUsers au WITH(NOLOCK) WHERE au.[userName] = @userName AND au.pwd = dbo.FNAEncryptString(@pwd)		
		
			
			UPDATE applicationUsers SET	
				lastLoginTs = GETDATE()
			WHERE  [userName]= @userName


			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION	
		
			IF @forceChangePwd = 'Y'
			BEGIN
				SELECT '100' errorCode, 'You are required to change your password.' msg , null id
				SET @UserInfoDetail = 'Reason = You are required to change your password.-:::-'+@UserInfoDetail
			
				EXEC proc_applicationLogs 
					@flag = 'login',
					@logType = 'Login', 
					@createdBy = @userName, 
					@Reason = 'Agent Login',
					@UserData = @UserData,
					@fieldValue = @UserInfoDetail,
					@agentId=@agentId
				
				RETURN		
			END
			
			SET @password_days = DATEDIFF(d, @lastPwdChangedOn, GETDATE())
			
			IF @password_days >= @pwdChangeDays
			BEGIN
				SET @msg = 'Your password has expired. <a href="/SwiftSystem/UserManagement/ApplicationUserSetup/ChangePassword.aspx?userName=' + @userName + '&mode=agent" target="frmame_main" >Change Password</a>'
				SELECT '101' errorCode, @msg msg , null id
				
				SET @UserInfoDetail = 'Reason = You password has expired.-:::-'+@UserInfoDetail
			
				EXEC proc_applicationLogs 
					@flag = 'login',
					@logType = 'Login fails', 
					@createdBy = @userName, 
					@Reason = 'Password Expired',
					@UserData = @UserData,
					@fieldValue = @UserInfoDetail,
					@agentId=@agentId
						
				RETURN		
			END
			
			IF @password_days >= @pwdChangeWarningDays
			BEGIN
				SELECT '102' errorCode, 'Your password will expire in' + CAST(@pwdChangeDays - @password_days AS VARCHAR) + ' day(s).' msg , null id
				
				SET @UserInfoDetail = 'Reason = Your password will expire in' + CAST(@pwdChangeDays - @password_days AS VARCHAR) + ' day(s).-:::-'+@UserInfoDetail
			
				EXEC proc_applicationLogs 
					@flag = 'login',
					@logType = 'Login', 
					@createdBy = @userName, 
					@Reason = 'Agent Login',
					@UserData = @UserData,
					@fieldValue = @UserInfoDetail,
					@agentId=@agentId
						
				RETURN		
			END	


			SELECT 0 errorCode, 'Login success.' mes, @userName id	
	
			--Audit data starts
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login', 
				@createdBy = @userName, 
				@Reason='Agent Login',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@agentId=@agentId
			--Audit data ends			
	END 	
	
	ELSE IF @flag = 'cpe' ---Check Password Expiry
	BEGIN
		SELECT 
				 @lastPwdChangedOn = ISNULL(lastPwdChangedOn, GETDATE())	
				,@pwdChangeDays = pwdChangeDays
			FROM applicationUsers au WITH(NOLOCK) WHERE au.[userName] = @userName
		SET @password_days = DATEDIFF(d, @lastPwdChangedOn, GETDATE())
		IF @password_days >= @pwdChangeDays
			SELECT 'Y'
		ELSE
			SELECT 'N'
		
	END
	ELSE IF @flag = 'lockUser'
	BEGIN
		SELECT @isActive = ISNULL(isLocked,'N') FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId
	
		UPDATE applicationUsers 
			SET isLocked = CASE @isActive WHEN 'Y' THEN 'N' ELSE 'Y' END ,modifiedBy = @user,modifiedDate = GETDATE()
			,isActive = CASE @isActive WHEN 'Y' THEN 'Y' ELSE 'N' END
			,wrongPwdCount = 0
		WHERE userId = @userId
	
		SELECT @sql_filter = CASE WHEN @isActive = 'Y' THEN 'User unlocked Successfully' ELSE 'User locked Successfully' END
	
		EXEC proc_errorHandler '0',@sql_filter,@userId 
		RETURN;
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
	ELSE IF @flag = 'cu' --check user
	BEGIN
		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName AND ISNULL(isActive, 'N') <> 'Y')
		BEGIN
			SELECT 1 errorCode, 'Access is denied.' mes, @userName id
			SET @UserInfoDetail = 'Access is denied-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 'i', NULL, 'Login fails', 'Login fails', @userName, @userName,'', @UserInfoDetail, @module		

			RETURN		
		END
		IF EXISTS(SELECT 'X' FROM applicationUsers WHERE [userName] = @userName AND ISNULL(isLocked, 'N') = 'Y')
		BEGIN

			SELECT 1 errorCode, 'Your account has been locked. Please, contact your administrator.' mes, @userName id
			SET @UserInfoDetail = 'Your account has been locked. Please, contact your administrator.-:::-'+@UserInfoDetail

			EXEC proc_applicationLogs 'i', NULL, 'Login fails', 'Login fails', @userName, @userName,'', @UserInfoDetail, @module		

			RETURN
		
		END		
		
		BEGIN TRANSACTION
			SELECT
				0 errorCode				
				,REPLACE(ISNULL(au.firstName, '') + ' ' + ISNULL(au.middleName, '')  + ' ' + ISNULL(au.lastName, ''), '  ', ' ') mes
				,@userName id
			FROM applicationUsers au WITH(NOLOCK)
			
			WHERE au.[userName] = @userName
			
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
	END	
	ELSE IF @flag = 'lo' --Log Out
	BEGIN
		BEGIN TRANSACTION
			SELECT
				0 errorCode				
				,REPLACE(ISNULL(au.firstName, '') + ' ' + ISNULL(au.middleName, '')  + ' ' + ISNULL(au.lastName, ''), '  ', ' ') mes
				,@userName id
			FROM applicationUsers au WITH(NOLOCK)			
			WHERE au.[userName] = @userName
			
			 EXEC proc_applicationLogs 
				@flag='login',
				@logType='Logout', 
				@createdBy = @userName, 
				@Reason='Logout',
				@UserData = @UserData,
				@agentId=@agentId

			 --Audit data ends	
			
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
	END	
	
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userId
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM applicationUsers WHERE userId = @userId AND approvedBy IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userId, @user, @oldValue, @newValue, @module
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @userId
					RETURN
				END
				DELETE FROM applicationUsers WHERE userId = @userId			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userId, @user, @oldValue, @newValue, @module
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @userId
					RETURN
				END
				DELETE FROM applicationUsersMod WHERE userId = @userId
				
				DELETE FROM passwordHistory WHERE userName = (SELECT userName FROM applicationUsers WITH(NOLOCK) WHERE userId = @userId)
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @userId
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
						,main.modifiedDate					= GETDATE()
						,main.modifiedBy					= @user
						,main.userType						= mode.userType
						,main.isActive						= mode.isActive
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
			ELSE
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE AGENT_ID = @userId AND acct_rpt_code = 'TCA')
				BEGIN
					DECLARE @ACC_NUMBER VARCHAR(30), @ACC_NAME VARCHAR(80), @GL_CODE VARCHAR(10)

					SELECT @ACC_NAME = 'Teller Cash - ' + USERNAME, @AGENTID = AGENTID 
					FROM APPLICATIONUSERS (NOLOCK) WHERE USERID = @userId

					SELECT TOP 1  @GL_CODE = GL_CODE 
					FROM FastMoneyPro_Account.dbo.ac_master 
					WHERE AGENT_ID = @AGENTID

					SELECT @ACC_NUMBER = MAX(CAST(acct_num AS BIGINT))+1 FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE acct_rpt_code = 'TCA'

					----## AUTO CREATE LEDGER FOR CASH TELLER ACCOUNT
					INSERT INTO FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
					acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
					lien_amt, utilised_amt, available_amt,created_date,created_by,company_id, ac_currency)
					select @ACC_NUMBER,@ACC_NAME,@GL_CODE, @userId,'o',0,'TCA',getdate(),0,0,0,0,0,getdate(),'system',1, 'JPY'
				END
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

