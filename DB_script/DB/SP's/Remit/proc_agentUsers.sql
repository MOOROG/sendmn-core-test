
ALTER PROC [dbo].[proc_agentUsers]
    @flag VARCHAR(50) = NULL ,
    @userId INT = NULL ,
    @user VARCHAR(30) = NULL ,
    @userName VARCHAR(30) = NULL ,
    @agentName VARCHAR(100) = NULL ,
    @agentCode VARCHAR(20) = NULL ,
    @firstName VARCHAR(30) = NULL ,
    @middleName VARCHAR(30) = NULL ,
    @lastName VARCHAR(30) = NULL ,
    @salutation VARCHAR(10) = NULL ,
    @gender VARCHAR(10) = NULL ,
    @telephoneNo VARCHAR(15) = NULL ,
    @address VARCHAR(50) = NULL ,
    @city VARCHAR(30) = NULL ,
    @countryId INT = NULL ,
    @countryName VARCHAR(100) = NULL ,
    @state INT = NULL ,
    @district INT = NULL ,
    @zip VARCHAR(10) = NULL ,
    @mobileNo VARCHAR(15) = NULL ,
    @email VARCHAR(255) = NULL ,
    @pwd VARCHAR(255) = NULL ,
    @isActive CHAR(1) = NULL ,
    @isLocked CHAR(1) = NULL ,
    @agentId INT = NULL ,
    @sessionTimeOutPeriod INT = NULL ,
    @tranApproveLimit MONEY = NULL ,
    @agentCrLimitAmt MONEY = NULL ,
    @loginTime VARCHAR(10) = NULL ,
    @logoutTime VARCHAR(10) = NULL ,
    @userAccessLevel CHAR(1) = NULL ,
    @perDayTranLimit INT = NULL ,
    @fromSendTrnTime TIME = NULL ,
    @toSendTrnTime TIME = NULL ,
    @fromPayTrnTime TIME = NULL ,
    @toPayTrnTime TIME = NULL ,
    @fromRptViewTime TIME = NULL ,
    @toRptViewTime TIME = NULL ,
    @isDeleted CHAR(1) = NULL ,
    @approvedDate DATETIME = NULL ,
    @lastLoginTs DATETIME = NULL ,
    @pwdChangeDays INT = NULL ,
    @pwdChangeWarningDays INT = NULL ,
    @lastPwdChangedOn DATETIME = NULL ,
    @forceChangePwd CHAR(1) = NULL ,
    @oldPwd VARCHAR(255) = NULL ,
    @name VARCHAR(50) = NULL ,
    @file VARCHAR(500) = NULL ,
    @changesApprovalQueueRowId BIGINT = NULL ,
    @haschanged CHAR(1) = NULL ,
    @sortBy VARCHAR(50) = NULL ,
    @sortOrder VARCHAR(5) = NULL ,
    @pageSize INT = NULL ,
    @pageNumber INT = NULL ,
    @UserInfoDetail VARCHAR(MAX) = NULL ,
    @maxReportViewDays INT = NULL ,
    @lockReason VARCHAR(500) = NULL ,
    @employeeId VARCHAR(10) = NULL ,
    @userType VARCHAR(2) = NULL ,
    @txnPwd VARCHAR(255) = NULL
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
     
        CREATE TABLE #msg
            (
              errorCode INT ,
              msg VARCHAR(100) ,
              id INT
            );

        DECLARE @sql VARCHAR(MAX) ,
            @oldValue VARCHAR(MAX) ,
            @newValue VARCHAR(MAX) ,
            @tableName VARCHAR(50) ,
            @logIdentifier VARCHAR(100) ,
            @logParamMain VARCHAR(100) ,
            @tableAlias VARCHAR(100) ,
            @modType VARCHAR(6) ,
            @module INT ,
            @select_field_list VARCHAR(MAX) ,
            @extra_field_list VARCHAR(MAX) ,
            @table VARCHAR(MAX) ,
            @sql_filter VARCHAR(MAX) ,
            @ApprovedFunctionId INT ,
            @msg VARCHAR(200) ,
            @parentAgentId INT;

        SELECT  @logIdentifier = 'userId' ,
                @logParamMain = 'applicationUsers' ,
                @tableAlias = 'User Setup' ,
                @module = 10 ,
                @ApprovedFunctionId = 20221030;
		
        IF @userId IS NULL
            SELECT  @userId = userId
            FROM    applicationUsers WITH ( NOLOCK )
            WHERE   userName = @user;
	
        IF @parentAgentId IS NULL
            SELECT  @parentAgentId = parentId
            FROM    agentMaster WITH ( NOLOCK )
            WHERE   agentId = @agentId;

        
            IF @flag = 's'
                BEGIN
                    IF @sortBy IS NULL
                        SET @sortBy = 'userId';
                    IF @sortOrder IS NULL
                        SET @sortOrder = 'ASC';
                    SET @table = '(
						SELECT 
							 U.userId
							,U.UserName
							,A.agentName AgentName
							,A.agentId
							,U.isDeleted
							,U.agentCode
							,firstName+'' ''+ISNULL(middleName,'''')+'' ''+ISNULL(lastName,'''') name
							,U.address
							,U.lastLoginTs
							,U.lastPwdChangedOn
							,U.createdDate 
							,U.createdBy
							,lockStatus = CASE WHEN ISNULL(isLocked,''N'') = ''Y'' THEN ''Locked'' ELSE ''Unlock'' END
					FROM applicationUsers U WITH(NOLOCK)
					INNER JOIN agentmaster A WITH(NOLOCK) ON U.agentid = A.agentId
						WHERE userType =''A'' AND U.agentId = '''+CAST(@agentId AS VARCHAR)+'''
					) x';
					
                    SET @sql_filter = '';		
                    IF @userName IS NOT NULL
                        SET @sql_filter = @sql_filter + '  AND username='''
                            + @userName + '''';
			
                    IF @firstName IS NOT NULL
                        SET @sql_filter = @sql_filter + '  AND name LIKE '''
                            + @firstName + '%''';
		
                    IF @isActive IS NOT NULL
                        SET @sql_filter += ' AND  lockStatus=''' + @isActive
                            + '''';
		
                    IF @isDeleted IS NOT NULL
                        SET @sql_filter += ' AND isDeleted = ''' + @isDeleted
                            + '''';
                    ELSE
                        SET @sql_filter += ' AND ISNULL(isDeleted,''N'')<> ''Y''';
			
                    SET @select_field_list = '
				userId
				,userName
				,agentId
				,isDeleted
				,AgentName
				,agentCode
				,name
				,address  
				,lastLoginTs
				,lastPwdChangedOn
				,lockStatus
				,createdDate   
				,createdBy
				';        	
                    EXEC dbo.proc_paging @table, @sql_filter,
                        @select_field_list, @extra_field_list, @sortBy,
                        @sortOrder, @pageSize, @pageNumber;
                END;
IF @flag = 'i'
BEGIN
    IF NOT EXISTS ( SELECT  'X' FROM    agentMaster WITH ( NOLOCK )WHERE   agentId = @agentId AND ISNULL(isActive, 'N') = 'Y' )
    BEGIN
        EXEC proc_errorHandler 1,
            'Corresponding Agent has not been approved yet',@employeeId;
        RETURN;
    END;
    IF EXISTS ( SELECT  'X' FROM    applicationUsers (NOLOCK)WHERE   [userName] = @userName )
    BEGIN
        SET @msg = 'User Name ' + @userName + ' already exist';
        EXEC proc_errorHandler 1, @msg, @employeeId;
        RETURN;		
    END;

    BEGIN TRANSACTION;
    INSERT  INTO applicationUsers
            ( [userName] ,agentCode ,firstName ,middleName ,lastName ,salutation ,gender ,countryId ,state ,district ,zip ,
                city ,[address] ,telephoneNo ,mobileNo ,email ,pwd ,agentId ,sessionTimeOutPeriod ,tranApproveLimit ,
                agentCrLimitAmt ,loginTime ,logoutTime ,userAccessLevel ,perDayTranLimit ,fromSendTrnTime ,toSendTrnTime ,
                fromPayTrnTime ,toPayTrnTime ,fromRptViewTime ,toRptViewTime ,isDeleted ,approvedDate ,lastLoginTs ,pwdChangeDays ,
                pwdChangeWarningDays ,lastPwdChangedOn ,forceChangePwd ,maxReportViewDays ,createdBy ,createdDate ,employeeId ,
                userType ,isActive ,txnPwd)
            SELECT  @userName,@agentCode,@firstName,@middleName,@lastName ,@salutation ,@gender ,@countryId ,@state ,@district,@zip ,
                    @city ,@address ,@telephoneNo ,@mobileNo ,@email ,dbo.FNAEncryptString(@userName + '@123') ,@agentId ,@sessionTimeOutPeriod ,@tranApproveLimit ,
                    @agentCrLimitAmt ,@loginTime ,@logoutTime ,@userAccessLevel ,@perDayTranLimit ,@fromSendTrnTime ,@toSendTrnTime ,
                    @fromPayTrnTime ,@toPayTrnTime ,@fromRptViewTime ,@toRptViewTime ,@isDeleted ,@approvedDate ,@lastLoginTs ,@pwdChangeDays ,
                    @pwdChangeWarningDays ,@lastPwdChangedOn ,'Y' ,@maxReportViewDays ,@user ,GETDATE() ,@employeeId ,
                    @userType ,'N' ,@txnPwd;

    SET @userId = SCOPE_IDENTITY();
				
    IF @employeeId IS NULL
        BEGIN
            UPDATE  applicationUsers
            SET     employeeId = CAST(@userId AS VARCHAR)
            WHERE   userId = @userId;
        END;
				
    IF @agentCode IS NULL
    BEGIN
        SELECT  @agentCode = agentCode FROM agentMaster WITH ( NOLOCK ) WHERE   agentId = @agentId;
        UPDATE  applicationUsers
        SET     agentCode = @agentCode
        WHERE   userId = @userId;
    END;
    ELSE
        IF @agentCode IS NOT NULL
        BEGIN
            UPDATE  agentMaster
            SET     agentCode = @agentCode
            WHERE   agentId = @agentId;
        END;
	--Keep Password History--------------------------------------
    INSERT  INTO passwordHistory( userName ,pwd ,createdDate)
    SELECT  @userName ,dbo.FNAEncryptString(@pwd) ,GETDATE();
	--------------------------------------------------------------
    COMMIT TRANSACTION;

    SELECT  0 errorCode ,
            'Record has been added successfully with User Code '+ CAST(@userId AS VARCHAR) mes ,@userId id;
	INSERT INTO AGENT_BRANCH_RUNNING_BALANCE 
	VALUES (@userId,'U',@userName,0,0,0,0)
END;

	ELSE IF @flag = 'a'
		BEGIN
			IF EXISTS (SELECT 'X' FROM applicationUsersMod WITH(NOLOCK) WHERE userId = @userId AND createdBy = @user)
			BEGIN
				SELECT 
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
					 main.*
					,agentName = am.agentName + '|' + CAST(am.agentId AS VARCHAR) + '|' + CAST(am.agentType AS VARCHAR)
					,dbo.FNADecryptString(pwd) as DePWD
					,dbo.FNADecryptString(txnPwd) as DeTxnPWD
				FROM applicationUsers main WITH(NOLOCK)
				LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
				WHERE main.userId = @userId	
	
			END
		END	

        
        IF @flag = 'u'
                BEGIN
	
                    IF EXISTS ( SELECT  'X'
                                FROM    applicationUsers WITH ( NOLOCK )
                                WHERE   userId = @userId
                                        AND approvedBy IS NULL
                                        AND createdBy <> @user )
                        BEGIN
                            EXEC proc_errorHandler 1,
                                'You can not modify this record. Previous Modification has not been approved yet.',
                                @userId;
                            RETURN;
                        END;
                    IF EXISTS ( SELECT  'X'
                                FROM    applicationUsersMod WITH ( NOLOCK )
                                WHERE   userId = @userId
                                        AND createdBy <> @user )
                        BEGIN
                            EXEC proc_errorHandler 1,
                                'You can not modify this record. Previous Modification has not been approved yet.',
                                @userId;
                            RETURN;
                        END; 
                    IF EXISTS ( SELECT  'X'
                                FROM    applicationUserRolesMod WITH ( NOLOCK )
                                WHERE   userId = @userId
                                        AND createdBy <> @user )
                        BEGIN
                            EXEC proc_errorHandler 1,
                                'You can not modify this record. Previous Modification has not been approved yet.',
                                @userId;
                            RETURN;
                        END;
                    IF EXISTS ( SELECT  'X'
                                FROM    applicationUserFunctionsMod WITH ( NOLOCK )
                  WHERE   userId = @userId
                                        AND createdBy <> @user )
                        BEGIN
                            EXEC proc_errorHandler 1,
                                'You can not modify this record. Previous Modification has not been approved yet.',@userId;
                            RETURN;
                        END;	
                    BEGIN TRANSACTION;
		
                    SELECT  @agentId = agentId
                    FROM    applicationUsers WITH ( NOLOCK )
                    WHERE   userId = @userId;
                    IF EXISTS ( SELECT  'X'
                                FROM    applicationUsers WITH ( NOLOCK )
                                WHERE   userId = @userId
                                        AND approvedBy IS NULL
                                        AND createdBy = @user )
                        BEGIN
                            UPDATE  applicationUsers
                            SET     firstName = @firstName ,
                                    middleName = @middleName ,
                                    lastName = @lastName ,
                                    salutation = @salutation ,
                                    gender = @gender ,
                                    telephoneNo = @telephoneNo ,
                                    mobileNo = @mobileNo ,
                                    state = @state ,
                                    district = @district ,
                                    zip = @zip ,
                                    [address] = @address ,
                                    city = @city ,
                                    countryId = @countryId ,
                                    email = @email ,
                                    agentId = @agentId ,
                                    sessionTimeOutPeriod = @sessionTimeOutPeriod ,
                                    tranApproveLimit = @tranApproveLimit ,
                                    agentCrLimitAmt = @agentCrLimitAmt ,
                                    loginTime = @loginTime ,
                                    logoutTime = @logoutTime ,
                                    userAccessLevel = @userAccessLevel ,
                                    perDayTranLimit = @perDayTranLimit ,
                                    fromSendTrnTime = @fromSendTrnTime ,
                                    toSendTrnTime = @toSendTrnTime ,
                                    fromPayTrnTime = @fromPayTrnTime ,
                                    toPayTrnTime = @toPayTrnTime ,
                                    fromRptViewTime = @fromRptViewTime ,
                                    toRptViewTime = @toRptViewTime ,
                                    pwdChangeDays = @pwdChangeDays ,
                                    pwdChangeWarningDays = @pwdChangeWarningDays ,
                                    maxReportViewDays = @maxReportViewDays ,
                                    userType = @userType ,
                                    isActive = @isActive
                            WHERE   userId = @userId;
                        END; 
                    ELSE
                        BEGIN
                            DELETE  FROM applicationUsersMod
                            WHERE   userId = @userId;
					
                            INSERT  INTO applicationUsersMod
                                    ( userId ,
                                      agentCode
					--,employeeId
                                      ,
                                      userName ,
                                      firstName ,
                                      middleName ,
                                      lastName ,
                                      salutation ,
                                      gender ,
                                      telephoneNo ,
                                 mobileNo ,
                                      state ,
                                      district ,
                                      zip ,
                                      [address] ,
                                      city ,
         countryId ,
                                      email ,
                                      agentId ,
                                      sessionTimeOutPeriod ,
                                      tranApproveLimit ,
                                      agentCrLimitAmt ,
                                      loginTime ,
                                      logoutTime ,
                                      userAccessLevel ,
                                      perDayTranLimit ,
                                      fromSendTrnTime ,
                                      toSendTrnTime ,
                                      fromPayTrnTime ,
                                      toPayTrnTime ,
                                      fromRptViewTime ,
                                      toRptViewTime ,
                                      pwdChangeDays ,
                                      pwdChangeWarningDays ,
                                      maxReportViewDays ,
                                      createdDate ,
                                      createdBy ,
                                      modType ,
                                      userType ,
                                      isActive            
				                    )
                                    SELECT  @userId ,
                                            @agentCode
					--,@employeeId
                                            ,
                                            @userName ,
                                            @firstName ,
                                            @middleName ,
                                            @lastName ,
                                            @salutation ,
                                            @gender ,
                                            @telephoneNo ,
                                            @mobileNo ,
                                            @state ,
                                            @district ,
                                            @zip ,
                                            @address ,
                                            @city ,
                                            @countryId ,
                                            @email ,
                                            @agentId ,
                                            @sessionTimeOutPeriod ,
                                            @tranApproveLimit ,
                                            @agentCrLimitAmt ,
                                            @loginTime ,
                                            @logoutTime ,
                                            @userAccessLevel ,
                                            @perDayTranLimit ,
                                            @fromSendTrnTime ,
                                            @toSendTrnTime ,
                                            @fromPayTrnTime ,
                                            @toPayTrnTime ,
                                            @fromRptViewTime ,
                                            @toRptViewTime ,
                                            @pwdChangeDays ,
                                            @pwdChangeWarningDays ,
                                            @maxReportViewDays ,
                                            GETDATE() ,
                                            @user ,
                                            'U' ,
                                            @userType ,
                                            isActive
								FROM applicationUsers  (NOLOCK) WHERE userId = @userId        
                        END;
                    COMMIT TRANSACTION;       
                    EXEC proc_errorHandler 0, 'Record updated successfully',
                        @agentId;
                END;
            
            IF @flag = 'lockUser'
                    BEGIN
    SELECT  @isActive = ISNULL(isLocked, 'N')
                        FROM    applicationUsers WITH ( NOLOCK )
                        WHERE   userId = @userId;
	
                        UPDATE  applicationUsers
                        SET     isLocked = CASE @isActive
                                             WHEN 'Y' THEN 'N'
                                             ELSE 'Y'
                                           END ,
                                modifiedBy = @user ,
                                modifiedDate = GETDATE() ,
                                isActive = CASE @isActive
                                             WHEN 'Y' THEN 'Y'
                                             ELSE 'N'
                                           END
                        WHERE   userId = @userId;
	
                        SELECT  @sql_filter = CASE WHEN @isActive = 'Y'
                                                   THEN 'User unlocked Successfully'
                                                   ELSE 'User locked Successfully'
                                              END;
	
                        EXEC proc_errorHandler '0', @sql_filter, @userId; 
                        RETURN;
                    END;

		IF @flag = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userId, @oldValue OUTPUT
				UPDATE applicationUsers SET
						isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user

				WHERE userId = @userId
					
				EXEC proc_errorHandler 0, 'Record deleted successfully', @userId
			END
		IF @flag = 'lockUser'
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

		IF @flag = 'resetPwd'
			BEGIN
				SET @pwd = LEFT(NEWID(),8)
				SET @sql_filter = 'Password  changed,New password is : ' + @pwd
				UPDATE applicationUsers 
					SET lastPwdChangedOn = GETDATE(),pwd = dbo.FNAEncryptString(@pwd),modifiedBy = @user,modifiedDate = GETDATE(),forceChangePwd ='Y'
				WHERE userId = @userId
				EXEC proc_errorHandler '0',@sql_filter,@userId 
				RETURN
			END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT  1 errorCode ,
                ERROR_MESSAGE() mes ,
                NULL id;
    END CATCH;


