USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentPicker]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_agentPicker]
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
     ,@agentPhone1						VARCHAR(20)		= NULL
     ,@agentPhone2						VARCHAR(20)		= NULL
     ,@agentFax1						VARCHAR(20)		= NULL
     ,@agentFax2						VARCHAR(20)		= NULL
     ,@agentMobile1						VARCHAR(20)		= NULL
     ,@agentMobile2						VARCHAR(20)		= NULL
     ,@agentEmail1						VARCHAR(100)	= NULL
     ,@agentEmail2						VARCHAR(100)	= NULL
     ,@businessOrgType					INT				= NULL
     ,@agentRole						CHAR(1)			= NULL
     ,@agentType						INT				= NULL
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
     ,@companyZip						VARCHAR(20)		= NULL
     ,@companyPhone1					VARCHAR(20)		= NULL
     ,@companyPhone2					VARCHAR(20)		= NULL
     ,@companyFax1						VARCHAR(20)		= NULL
     ,@companyFax2						VARCHAR(20)		= NULL
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
     ,@populateBankBranch				CHAR(1)			= NULL
     ,@headMessage						VARCHAR(MAX)	= NULL
     ,@filterColumn						VARCHAR(100)	= NULL
	,@filterValue						VARCHAR(100)	= NULL
	,@controlNo							VARCHAR(20)		= NULL


AS
SET NOCOUNT ON
	
DECLARE @glcode VARCHAR(10), @acct_num VARCHAR(20);
CREATE TABLE #tempACnum (acct_num VARCHAR(20));
       

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
		
	SELECT
		 @logIdentifier = 'agentId'
		,@logParamMain = 'agentMaster'
		,@tableAlias = 'Agent'
		,@module = 20
		,@ApprovedFunctionId = 20101030
	
    IF @flag = 'dAgent'  -- GET DOMESTIC AGENT FOR SENDING DOMESTIC TRANSACTION
    BEGIN
			SELECT TOP 30 A.agentName+'|'+ CAST(agentId AS VARCHAR) agentName ,A.agentId FROM 
					(
						SELECT 
							 agentId
							,agentName + ISNULL('(' + b.districtName + ')', '') agentName
						FROM agentMaster a WITH(NOLOCK) 
						LEFT JOIN api_districtList b WITH(NOLOCK)
						ON a.agentLocation = b.districtCode
						WHERE agentCountry = 'Nepal'
						AND (actAsBranch = 'Y' OR agentType = 2904)
						AND ISNULL(a.isDeleted, 'N') = 'N'
						AND ISNULL(a.isActive, 'N') = 'Y'
					)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName
    END
    
    ELSE IF @flag = 'dAgent2'
	BEGIN
		SELECT TOP 30 A.agentName+'|'+ mapCodeInt agentName ,A.mapCodeInt FROM 
					(
						SELECT 
							 mapCodeInt
							,agentName + ISNULL('(' + b.districtName + ')', '') agentName
						FROM agentMaster a WITH(NOLOCK) 
						LEFT JOIN api_districtList b WITH(NOLOCK)
						ON a.agentLocation = b.districtCode
						WHERE agentCountry = 'Nepal'
						AND (actAsBranch = 'Y' OR agentType = 2904)
						AND ISNULL(a.isDeleted, 'N') = 'N'
						AND ISNULL(a.isActive, 'N') = 'Y'
					)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName
	END
	
	ELSE IF @flag = 'privateAgent'
	BEGIN
		SELECT TOP 30 A.agentName+'|'+ CAST(agentId AS VARCHAR) agentName ,A.agentId FROM 
					(
						SELECT 
							 agentId
							,agentName + ISNULL('(' + b.districtName + ')', '') agentName
						FROM agentMaster a WITH(NOLOCK) 
						LEFT JOIN api_districtList b WITH(NOLOCK)
						ON a.agentLocation = b.districtCode
						WHERE agentCountry = 'Nepal'
						AND (agentType = 2904 OR actAsBranch = 'Y')
						AND ISNULL(a.isDeleted, 'N') = 'N'
						AND ISNULL(a.isActive, 'N') = 'Y'
					)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName
	END
	
	ELSE IF @flag = 'dBank'
	BEGIN
		SELECT TOP 30 A.agentName+'|'+ CAST(agentId AS VARCHAR) agentName ,A.agentId FROM 
					(
						SELECT 
							 agentId
							,agentName + ISNULL('(' + b.districtName + ')', '') agentName
						FROM agentMaster a WITH(NOLOCK) 
						LEFT JOIN api_districtList b WITH(NOLOCK)
						ON a.agentLocation = b.districtCode
						WHERE agentCountry = 'Nepal'
						AND (agentType IN (2904, 2906)) AND mapCodeIntAc IS NOT NULL
						AND ISNULL(a.isDeleted, 'N') = 'N'
						AND ISNULL(a.isActive, 'N') = 'Y'
					)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName
					
	END
	
	ELSE IF @flag = 'acdepositbank'
	BEGIN
		IF RIGHT(@controlNo, 1) = 'D'			-- For Domestic
		BEGIN
			SELECT TOP 30 A.agentName+'|'+ CAST(agentId AS VARCHAR) agentName ,A.agentId FROM 
				(
					SELECT 
						 agentId
						,agentName + ISNULL('(' + b.districtName + ')', '') agentName
					FROM agentMaster a WITH(NOLOCK) 
					LEFT JOIN api_districtList b WITH(NOLOCK)
					ON a.agentLocation = b.districtCode
					WHERE agentCountry = 'Nepal'
					AND (agentType IN (2906))
					AND ISNULL(a.isDeleted, 'N') = 'N'
					AND ISNULL(a.isActive, 'N') = 'Y'
				)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName
		END
		ELSE									-- For International
		BEGIN
			--SELECT TOP 30 A.agentName+'|'+ CAST(agentId AS VARCHAR) agentName ,A.agentId FROM 
			--	(
			--		SELECT 
			--			 agentId
			--			,agentName + ISNULL('(' + b.districtName + ')', '') agentName
			--		FROM agentMaster a WITH(NOLOCK) 
			--		LEFT JOIN api_districtList b WITH(NOLOCK)
			--		ON a.agentLocation = b.districtCode
			--		WHERE agentCountry = 'Nepal'
			--		AND (agentType IN (2904, 2906)) --AND mapCodeIntAc IS NOT NULL
			--		AND ISNULL(a.isDeleted, 'N') = 'N'
			--		AND ISNULL(a.isActive, 'N') = 'Y'
			--	)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName

			SELECT TOP 30 A.agentName+'|'+ CAST(agentId AS VARCHAR) agentName ,A.agentId FROM 
				(
					SELECT 
						 a.agentId
						,a.agentName + ISNULL('(' + b.districtName + ')', '') agentName
					FROM agentMaster a WITH(NOLOCK) 
					INNER JOIN agentMaster am with(nolock) on a.parentId =am.agentId
					LEFT JOIN api_districtList b WITH(NOLOCK)
					ON a.agentLocation = b.districtCode
					WHERE a.agentCountry = 'Nepal'
					AND a.agentType =2906 
					AND am.agentType = 2905
					AND ISNULL(a.isDeleted, 'N') = 'N'
					AND ISNULL(a.isActive, 'N') = 'Y'
					AND ISNULL(a.agentBlock, 'N') = 'N'
				)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName
		END
					
	END
	
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
							,main.agentGrp
							,main.allowAccountDeposit
							,agentGroup = ag.detailTitle
							,agentType1 = sdv.detailTitle
							,parentName = am.agentName
							,main.isActive
							,main.isDeleted				
						FROM agentMaster main 
						LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.agentType = sdv.valueId
						LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGrp = ag.valueId
						LEFT JOIN agentMaster am WITH(NOLOCK) ON main.parentId = am.agentId
						WHERE 1=1 
		) x'

		
		SET @sql_filter = ''		
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'' '
		SET @sql_filter = @sql_filter + ' AND ISNULL(isActive, '''') = ''Y'' '

		IF @filterColumn IS NOT NULL and @filterValue IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND '+ @filterColumn +' = '''+ @filterValue +''' '


		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryName, '''') = ''' + CAST(@agentCountry AS VARCHAR) + ''''
			
		IF @agentType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentType, '''') = ' + CAST(@agentType AS  VARCHAR)
		
		IF @agentGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentGrp, '''') = ' + CAST(@agentGroup AS VARCHAR)
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
		
		IF @parentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(parentName, '''') LIKE ''%' + @parentName + '%'''
			
		IF @agentLocation IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentLocation, '''') = ' + CAST(@agentLocation AS VARCHAR)
		
		IF @parentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND parentId = ' + CAST(@parentId AS VARCHAR)
		
		IF @actAsBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(actAsBranch, ''N'') = ''' + @actAsBranch + ''''
		
		IF @populateBranch = 'Y'
			SET @sql_filter = @sql_filter + ' AND (ISNULL(agentType, '''') = 2904 OR actAsBranch = ''Y'')'
		
		IF @populateBankBranch = 'Y'
			SET @sql_filter = @sql_filter + ' AND (ISNULL(agentType, '''') = 2906 OR allowAccountDeposit = ''Y'')'
			
		IF @contractExpiryDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND contractExpiryDate = ''' + @contractExpiryDate + ''''
		
		IF @renewalFollowupDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND renewalFollowupDate = ''' + @renewalFollowupDate + '''' 
			
		IF @isSettlingAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isSettlingAgent, ''N'') = ''' + @isSettlingAgent + ''''
		
		
		SET @select_field_list ='
		      parentId
               ,agentId
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
               ,agentGroup
               ,parentName
  
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

	IF @flag = 'dAgent3'  -- GET SCHOOL/COLLEGE AGENT
	BEGIN
		SELECT TOP 30 A.agentName+'|'+ CAST(agentId AS VARCHAR) agentName ,A.agentId FROM 
				(
					SELECT 
							agentId
						,agentName + ISNULL('(' + b.districtName + ')', '') agentName
					FROM agentMaster a WITH(NOLOCK) 
					LEFT JOIN api_districtList b WITH(NOLOCK)
					ON a.agentLocation = b.districtCode
					WHERE parentId = '5576'
					AND ISNULL(a.isDeleted, 'N') = 'N'
					AND ISNULL(a.isActive, 'N') = 'Y'
				)A WHERE A.agentName LIKE '%'+@agentName+'%' ORDER BY A.agentName

	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
