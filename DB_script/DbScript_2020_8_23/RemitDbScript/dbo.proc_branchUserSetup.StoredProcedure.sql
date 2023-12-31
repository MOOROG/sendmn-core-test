USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_branchUserSetup]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

[proc_agentMaster] @flag = 'bc', @agentId = '1'
[proc_agentMaster] @flag = 's', @user = 'admin', @parentId = 1

*/
CREATE proc [dbo].[proc_branchUserSetup]
      @flag                             VARCHAR(50)		= NULL
     ,@userId							INT				= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@userName                         VARCHAR(30)		= NULL
     ,@agentCode						VARCHAR(10)		= NULL
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
     ,@parentId							VARCHAR(30)		= NULL
     ,@agentName						VARCHAR(100)	= NULL
     ,@agentCountry						VARCHAR(100)	= NULL
     ,@agentLocation					INT				= NULL
     ,@agentType						INT				= NULL
     ,@actAsBranch						CHAR(1)			= NULL
     ,@isSettlingAgent					CHAR(1)			= NULL    
     ,@populateBranch					CHAR(1)			= NULL


AS
SET NOCOUNT ON
	
DECLARE @glcode VARCHAR(10), @acct_num VARCHAR(20);
CREATE TABLE #tempACnum (acct_num VARCHAR(20));
       

SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql					VARCHAR(MAX)
		,@oldValue				VARCHAR(MAX)
		,@newValue				VARCHAR(MAX)
		,@tableName				VARCHAR(50)
		,@logIdentifier			VARCHAR(100)
		,@logParamMain			VARCHAR(100)
		,@tableAlias			VARCHAR(100)
		,@modType				VARCHAR(6)
		,@module				INT	
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@table					VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@ApprovedFunctionId	INT	
		
	SELECT
		 @logIdentifier = 'agentId'
		,@logParamMain = 'agentMaster'
		,@tableAlias = 'Agent Setup'
		,@module = 20
		,@ApprovedFunctionId = 20101030
	
	IF @flag = 'su'							--Select Users
	BEGIN
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
							OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
						)
				WHERE ISNULL(au.isDeleted, ''N'')  <> ''Y''
					AND (
							au.approvedBy IS NOT NULL 
							OR au.createdBy = ''' +  @user + ''' 
							OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
						)
					
			) '
		
		PRINT (@table)
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
							,lockStatus = CASE WHEN ISNULL(main.isLocked, ''N'') = ''N'' THEN ''N | <a href="#" onclick="UnlockUser('' + CAST(main.userId AS VARCHAR) + '')">Lock</a>''
											WHEN ISNULL(main.isLocked, ''N'') = ''Y'' THEN ''Y | <a href="#" onclick="UnlockUser('' + CAST(main.userId AS VARCHAR) + '')">Unlock</a>'' END     
											           
							,userGroup = CASE WHEN am.agentType = ''2904'' OR am.actAsBranch = ''Y'' THEN ''''
											ELSE 
											''<a href="/SwiftSystem/UserManagement/ApplicationUserSetup/UserGroupMaping.aspx?userName='' + main.userName + ''&userId='' + CAST(main.userId AS VARCHAR) + ''&agentId='' + CAST(main.agentId AS VARCHAR) + ''" ">
											<img src="/images/user_icon.gif" border=0 title="User Grouping" alt="User Group" /></a>'' END                
							,main.haschanged
							,main.modifiedBy
							,main.createdBy				
						FROM ' + @table + ' main 
						INNER JOIN agentMaster am ON main.agentId = am.agentId
						LEFT JOIN countryMaster cm ON main.countryId = cm.countryId
						WHERE userName <> ''' + @user + '''
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
		
		IF @address IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(address, '''') LIKE ''%' + @address + '%'''
		
		IF @countryId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryId, '''') = ' + CAST(@countryId AS VARCHAR)
		
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentId, '''') = ' + CAST(@agentId AS VARCHAR)	
		
		IF @agentCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentCode, '''') = ''' + @agentCode + ''''
			
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
	ELSE IF @flag = 'sa'					--Select Agents
	BEGIN
		SET @table = '(
					SELECT
						 parentId = ISNULL(amh.parentId, am.parentId)
						,agentId = ISNULL(amh.agentId, am.agentId)
						,agentCode = ISNULL(amh.agentCode, am.agentCode)
						,agentName = ISNULL(amh.agentName, am.agentName)
						,agentAddress = ISNULL(amh.agentAddress, am.agentAddress)
						,agentCity = ISNULL(amh.agentCity, am.agentCity)
						,agentCountry = ISNULL(amh.agentCountry, am.agentCountry)
						,agentState = ISNULL(amh.agentState, am.agentState)
						,agentDistrict = ISNULL(amh.agentDistrict, am.agentDistrict)
						,agentZip = ISNULL(amh.agentZip, am.agentZip)
						,agentLocation = ISNULL(amh.agentLocation, am.agentLocation)
						,agentPhone1 = ISNULL(amh.agentPhone1, am.agentPhone1)
						,agentPhone2 = ISNULL(amh.agentPhone2, am.agentPhone2)
						,agentFax1 = ISNULL(amh.agentFax1, am.agentFax1)
						,agentFax2 = ISNULL(amh.agentFax2, am.agentFax2)
						,agentMobile1 = ISNULL(amh.agentMobile1, am.agentMobile1)
						,agentMobile2 = ISNULL(amh.agentMobile2, am.agentMobile2)
						,agentEmail1 = ISNULL(amh.agentEmail1, am.agentEmail1)
						,agentEmail2 = ISNULL(amh.agentEmail2, am.agentEmail2)
						,businessOrgType = ISNULL(amh.businessOrgType, am.businessOrgType)
						,businessType = ISNULL(amh.businessType, am.businessType)
						,agentRole = ISNULL(amh.agentRole, am.agentRole)
						,agentType = ISNULL(amh.agentType, am.agentType)
						,actAsBranch = ISNULL(amh.actAsBranch, am.actAsBranch)
						,contractExpiryDate = ISNULL(amh.contractExpiryDate, am.contractExpiryDate)
						,renewalFollowupDate = ISNULL(amh.renewalFollowupDate, am.renewalFollowupDate)
						,isSettlingAgent = ISNULL(amh.isSettlingAgent, am.isSettlingAgent)
						,agentGrp = ISNULL(amh.agentGrp, am.agentGrp)
						,businessLicense = ISNULL(amh.businessLicense, am.businessLicense)
						,agentBlock = ISNULL(amh.agentBlock, am.agentBlock)
						,agentcompanyName = ISNULL(amh.agentcompanyName, am.agentcompanyName)
						,companyAddress = ISNULL(amh.companyAddress, am.companyAddress)
						,companyCity = ISNULL(amh.companyCity, am.companyCity)
						,companyCountry = ISNULL(amh.companyCountry, am.companyCountry)
						,companyState = ISNULL(amh.companyState, am.companyState)
						,companyDistrict = ISNULL(amh.companyDistrict, am.companyDistrict)
						,companyZip = ISNULL(amh.companyZip, am.companyZip)
						,companyPhone1 = ISNULL(amh.companyPhone1, am.companyPhone1)
						,companyPhone2 = ISNULL(amh.companyPhone2, am.companyPhone2)
						,companyFax1 = ISNULL(amh.companyFax1, am.companyFax1)
						,companyFax2 = ISNULL(amh.companyFax2, am.companyFax2)
						,companyEmail1 = ISNULL(amh.companyEmail1, am.companyEmail1)
						,companyEmail2 = ISNULL(amh.companyEmail2, am.companyEmail2)
						,localTime = ISNULL(amh.localTime, am.localTime)
						,agentDetails = ISNULL(amh.agentDetails, am.agentDetails)
						,am.createdDate
						,am.createdBy
						,amh.modType
						,modifiedDate = CASE WHEN am.approvedBy IS NULL THEN am.createdDate ELSE amh.createdDate END
						,modifiedBy = CASE WHEN am.approvedBy IS NULL THEN am.createdBy ELSE amh.createdBy END
						,hasChanged = CASE WHEN (am.approvedBy IS NULL) OR 
												(amh.agentId IS NOT NULL)  
											THEN ''Y'' ELSE ''N'' END
					FROM agentMaster am WITH(NOLOCK)
					LEFT JOIN agentMasterMod amh ON am.agentId = amh.agentId
						AND (
								amh.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE ISNULL(am.isDeleted, ''N'')  <> ''Y''
						AND (
								am.approvedBy IS NOT NULL 
								OR am.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(amh.modType, '''') = ''D'' AND amh.createdBy = ''' + @user + ''')  
				) '
		
		IF @sortBy IS NULL
		   SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.parentId
							,main.agentId
							,main.agentCode
							,main.agentName                    
							,main.agentAddress 
							,main.agentCity
							,main.agentLocation
							,countryName = main.agentCountry 
							,main.agentPhone1                  
							,main.agentType
							,main.actAsBranch
							,main.contractExpiryDate
							,main.renewalFollowupDate
							,main.isSettlingAgent
							,main.haschanged
							,agentType1 = sdv.detailTitle
							,parentName = am.agentName
							,main.modifiedBy
							,main.createdBy	
							,main.businessOrgType
							,main.businessType
			
						FROM ' + @table + ' main 
						LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.agentType = sdv.valueId
						INNER JOIN agentMaster am WITH(NOLOCK) ON main.parentId = am.agentId
						WHERE 1=1 AND main.agentType NOT IN (2905,2906)
					) x'
					
		SET @sql_filter = ''		
			
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
			
		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryName, '''') = ''' + CAST(@agentCountry AS VARCHAR) + ''''
			
		IF @agentType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentType, '''') = ' + CAST(@agentType AS  VARCHAR)

		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
			
		IF @agentLocation IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentLocation, '''') = ' + CAST(@agentLocation AS VARCHAR)
		
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentId = ' + CAST(@agentId AS VARCHAR)
			
		IF @parentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND parentId = ' + CAST(@parentId AS VARCHAR)
		
		IF @actAsBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(actAsBranch, ''N'') = ''' + @actAsBranch + ''''
		
		IF @populateBranch = 'Y'
			SET @sql_filter = @sql_filter + ' AND (ISNULL(agentType, '''') = 2904 OR actAsBranch = ''Y'')'
			
		IF @isSettlingAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isSettlingAgent, ''N'') = ''' + @isSettlingAgent + ''''
			
		IF @agentCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentCode = ''' + @agentCode + ''''
		
		
		SET @select_field_list ='
				parentId
               ,agentId
               ,agentCode
               ,agentName               
               ,agentAddress
               ,agentCity 
               ,agentLocation
               ,agentPhone1              
               ,agentType
               ,agentType1
               ,contractExpiryDate
               ,renewalFollowupDate
               ,isSettlingAgent
               ,countryName
               ,parentName
               ,haschanged
               ,modifiedBy
               ,createdBy
               '        	
		--PRINT @table	
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
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH


GO
