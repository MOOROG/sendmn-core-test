USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_globalAgentList]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_globalAgentList]
     @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@agentId							VARCHAR(30)		= NULL
     ,@parentId							VARCHAR(30)		= NULL
     ,@agentName						VARCHAR(100)	= NULL
     ,@agentCode	                    VARCHAR(50)		= NULL
     ,@agentAddress	                    VARCHAR(200)	= NULL
     ,@agentCity						VARCHAR(100)	= NULL
     ,@agentCountryId					INT				= NULL
     ,@agentCountry						VARCHAR(100)	= NULL
     ,@agentState						VARCHAR(100)	= NULL
     ,@agentDistrict					VARCHAR(100)	= NULL
     ,@agentZip							VARCHAR(20)		= NULL
     ,@agentLocation					INT				= NULL
     ,@agentPhone1						VARCHAR(50)		= NULL
     ,@agentPhone2						VARCHAR(50)		= NULL
     ,@agentFax1						VARCHAR(50)		= NULL
     ,@agentFax2						VARCHAR(50)		= NULL
     ,@agentMobile1						VARCHAR(50)		= NULL
     ,@agentMobile2						VARCHAR(50)		= NULL
     ,@agentEmail1						VARCHAR(100)	= NULL
     ,@agentEmail2						VARCHAR(100)	= NULL
     ,@businessOrgType					INT				= NULL
     ,@businessType						INT				= NULL
     ,@agentRole						CHAR(1)			= NULL
     ,@agentType						INT				= NULL
     ,@allowAccountDeposit				CHAR(1)			= NULL
     ,@actAsBranch						CHAR(1)			= NULL
     ,@contractExpiryDate				DATETIME		= NULL
     ,@renewalFollowupDate				DATETIME		= NULL
     ,@isSettlingAgent					CHAR(1)			= NULL
     ,@agentGroup						INT				= NULL
     ,@businessLicense					VARCHAR(100)	= NULL
     ,@agentBlock						CHAR(1)			= NULL
     ,@agentcompanyName					VARCHAR(200)	= NULL
     ,@companyAddress					VARCHAR(200)	= NULL
     ,@companyCity						VARCHAR(100)	= NULL	
     ,@companyCountry					VARCHAR(100)	= NULL
     ,@companyState						VARCHAR(100)	= NULL
     ,@companyDistrict					VARCHAR(100)	= NULL
     ,@companyZip						VARCHAR(50)		= NULL
     ,@companyPhone1					VARCHAR(50)		= NULL
     ,@companyPhone2					VARCHAR(50)		= NULL
     ,@companyFax1						VARCHAR(50)		= NULL
     ,@companyFax2						VARCHAR(50)		= NULL
     ,@companyEmail1					VARCHAR(100)	= NULL
     ,@companyEmail2					VARCHAR(100)	= NULL
     ,@localTime						INT				= NULL
     ,@localCurrency					INT				= NULL
     ,@agentDetails						VARCHAR(MAX)	= NULL
     ,@parentName						VARCHAR(100)	= NULL
     ,@haschanged						CHAR(1)			= NULL
     ,@isActive							CHAR(1)			= NULL
     ,@isDeleted                        CHAR(1)			= NULL     
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL
     ,@populateBranch					CHAR(1)			= NULL
     ,@headMessage						VARCHAR(MAX)	= NULL
     ,@mapCodeInt						VARCHAR(20)		= NULL
     ,@mapCodeDom						VARCHAR(20)		= NULL
     ,@commCodeInt						VARCHAR(20)		= NULL
     ,@commCodeDom						VARCHAR(20)		= NULL
     ,@urlRoot							VARCHAR(200)	= NULL
     ,@joinedDate						DATETIME		= NULL
     ,@mapCodeIntAc						VARCHAR(50)		= NULL
     ,@mapCodeDomAc						VARCHAR(50)		= NULL
	 ,@payOption						INT				= NULL
	 ,@agentSettCurr					VARCHAR(50)		= NULL

AS
SET NOCOUNT ON

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
	
IF @flag = 's'
    BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.parentId
							,main.agentId
							,main.agentCode
							,main.mapCodeInt
							,main.agentName                    
							,main.agentAddress 
							,main.agentCity
							,agentLocation = adl.districtName
							,main.agentDistrict
							,main.agentState
							,countryName = main.agentCountry 
							,main.agentPhone1
							,main.agentPhone2                  
							,main.agentType
							,main.actAsBranch
							,main.contractExpiryDate
							,main.renewalFollowupDate
							,main.isSettlingAgent
							,main.haschanged
							,agentType1 = sdv.detailTitle
							,main.modifiedBy
							,main.createdBy	
							,main.businessOrgType
							,main.businessType
							,main.agentBlock
							,main.isActive
						FROM 
							(
								SELECT
									 parentId = ISNULL(amh.parentId, am.parentId)
									,agentId = ISNULL(amh.agentId, am.agentId)
									,agentCode = ISNULL(amh.agentCode, am.agentCode)
									,mapCodeInt = ISNULL(amh.mapCodeInt, am.mapCodeInt)
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
									,isActive = ISNULL(amh.isActive, am.isActive)
									,localTime = ISNULL(amh.localTime, am.localTime)
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
								)main 
						LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.agentType = sdv.valueId
						LEFT JOIN api_districtList adl WITH(NOLOCK) ON main.agentLocation = adl.districtCode
						WHERE main.agentType NOT IN (2905,2906)
					) x'
					
					
				--Print @table	
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

		IF @businessOrgType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isnull(businessOrgType,'''') = ''' + CAST(@businessOrgType AS VARCHAR)+''''
		
		IF @businessType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND isnull(businessType,'''') = ''' + CAST(@businessType AS VARCHAR)+''''
		
		IF @actAsBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(actAsBranch, ''N'') = ''' + @actAsBranch + ''''
		
		IF @populateBranch = 'Y'
			SET @sql_filter = @sql_filter + ' AND (ISNULL(agentType, '''') = 2904 OR actAsBranch = ''Y'')'
		
		IF @contractExpiryDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND contractExpiryDate = ''' + @contractExpiryDate + ''''
		
		IF @renewalFollowupDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND renewalFollowupDate = ''' + @renewalFollowupDate + '''' 
			
		IF @isSettlingAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isSettlingAgent, ''N'') = ''' + @isSettlingAgent + ''''
			
		IF @agentCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentCode = ''' + @agentCode + ''''
		
		IF @mapCodeInt IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND mapCodeInt = ''' + @mapCodeInt + ''''

		IF @agentBlock IS NOT NULL
		BEGIN
			IF @agentBlock = 'Y' 
				SET @agentBlock ='B'
			ELSE
				SET @agentBlock = 'U'
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentBlock,''U'') = ''' + @agentBlock + ''''
		END

		IF @isActive IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isActive,''Y'') = ''' + @isActive + ''''


			
		SET @select_field_list ='
				parentId
               ,agentId
               ,agentCode
               ,mapCodeInt
               ,agentName               
               ,agentAddress
               ,agentCity 
               ,agentLocation
               ,agentDistrict
               ,agentState
               ,agentPhone1
               ,agentPhone2              
               ,agentType
               ,agentType1
               ,contractExpiryDate
               ,renewalFollowupDate
               ,isSettlingAgent
               ,countryName
               ,haschanged
               ,modifiedBy
               ,createdBy
			   ,isActive
			   ,agentBlock
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
	
	


GO
