USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_globalUserList]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_globalUserList]
	  @flag                             VARCHAR(50)		= NULL
     ,@userId							INT				= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@userName                         VARCHAR(30)		= NULL
     ,@agentName						VARCHAR(100)	= NULL
     ,@agentCode						VARCHAR(20)		= NULL     
     ,@isActive                         CHAR(1)			= NULL
     ,@isLocked                         CHAR(1)			= NULL
     ,@agentId                          INT				= NULL     
     ,@isDeleted                        CHAR(1)			= NULL  	 
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL  
	 ,@userFullName						VARCHAR(200)	= NULL
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

     DECLARE
			 @sql				VARCHAR(MAX)		
			,@select_field_list VARCHAR(MAX)
			,@extra_field_list  VARCHAR(MAX)
			,@table             VARCHAR(MAX)
			,@sql_filter        VARCHAR(MAX)
			,@ApprovedFunctionId INT
			
		

	IF @flag = 'hs'
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
							,main.address
							,main.countryId 
							,countryName = cm.countryName
							,main.agentId       
							,am.agentName
							,main.agentCode
							,main.isLocked               
							,main.haschanged
							,main.modifiedBy
							,main.createdBy	
							,main.isActive			
						  FROM 
								(
								SELECT
								 userId					= ISNULL(aum.userId, au.userId)
								,[userName]				= ISNULL(aum.userName, au.userName)
								,agentCode				= ISNULL(aum.agentCode, au.agentCode)
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
							WHERE au.agentId <> ''1001''				
								
						) main 
						INNER JOIN agentMaster am ON main.agentId = am.agentId
						LEFT JOIN countryMaster cm ON main.countryId = cm.countryId						
					) x'
					
					
		SET @sql_filter = ''		
					
		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userName, '''') LIKE ''%' + @userName + '%'''
			
		IF @userFullName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(name, '''') LIKE ''%' + @userFullName + '%'''		
				
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
			   ,address  
			   ,countryId
			   ,countryName   
			   ,agentId          
			   ,agentName
			   ,agentCode
			   ,isLocked
			   ,haschanged
			   ,modifiedBy
			   ,createdBy
			   ,isActive
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




GO
