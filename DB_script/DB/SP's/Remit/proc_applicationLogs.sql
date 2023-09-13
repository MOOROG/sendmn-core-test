use fastmoneypro_remit
go

ALTER PROC [dbo].[proc_applicationLogs]
	 @flag				VARCHAR(50)
	,@rowId				BIGINT			= NULL OUT
	,@logType			VARCHAR(50)		= NULL
	,@tableName			VARCHAR(100)	= NULL	
	,@dataId			VARCHAR(50)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@oldData			VARCHAR(MAX)	= NULL
	,@newData			VARCHAR(MAX)	= NULL
	,@module			VARCHAR(50)		= NULL
	,@tableDescription	VARCHAR(50)		= NULL
	,@createdBy			VARCHAR(30)		= NULL
	,@createdDate		DATETIME        = NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
    ,@IP			    VARCHAR(50)		= NULL
	,@Reason		    VARCHAR(2000)	= NULL
	,@UserData			VARCHAR(max)	= NULL
	,@fieldValue		VARCHAR(2000)	= NULL
	,@agentId			VARCHAR(20)		= NULL
	,@dcSerialNumber	VARCHAR(100)	= NULL
	,@dcUserName		VARCHAR(100)	= NULL
	,@LOGIN_COUNTRY NVARCHAR(50)		= NULL
	,@LOGIN_COUNTRY_CODE NVARCHAR(30)	= NULL
	,@LOGIN_CITY NVARCHAR(200)			= NULL 
	,@LOGIN_REGION NVARCHAR(200)		= NULL 
	,@LOGIN_LAT NVARCHAR(20)			= NULL 
	,@LOGIN_LONG NVARCHAR(20)			= NULL 
	,@LOGIN_TIMEZONE NVARCHAR(30)		= NULL 
	,@LOGIN_ZIPCODDE NVARCHAR(30)		= NULL 
	,@OTP_USED VARCHAR(10)				= NULL
	,@IS_SUCCESSFUL BIT					= NULL
AS

SET NOCOUNT ON;

/*
	@flag,	
	i				= Insert
	auditRole		= Audit Role Report
	auditFunction	= Audit Function Report
	
*/
DECLARE @sql VARCHAR(MAX)
IF @LOGIN_COUNTRY = 'Nnull'
	SET @LOGIN_COUNTRY = NULL
IF @LOGIN_COUNTRY_CODE = 'Nnull'
	SET @LOGIN_COUNTRY_CODE = NULL
IF @LOGIN_CITY = 'Nnull'
	SET @LOGIN_CITY = NULL
IF @LOGIN_REGION = 'Nnull'
	SET @LOGIN_REGION = NULL
IF @LOGIN_LAT = 'Nnull'
	SET @LOGIN_LAT = NULL
IF @LOGIN_LONG = 'Nnull'
	SET @LOGIN_LONG = NULL
IF @LOGIN_TIMEZONE = 'Nnull'
	SET @LOGIN_TIMEZONE = NULL
IF @LOGIN_ZIPCODDE = 'Nnull'
	SET @LOGIN_ZIPCODDE = NULL

IF @flag = 'log-update'
BEGIN
	UPDATE LoginLogs SET IS_SUCCESSFUL = @IS_SUCCESSFUL
	WHERE rowId = @rowId
END
IF @flag = 'i'
BEGIN
	INSERT INTO applicationLogs (	
		 logType
		,tableName
		,dataId
		,oldData
		,newData
		,module
		,createdBy
		,createdDate
	)
	SELECT 
		@logType
		,@tableName
		,@dataId
		,@oldData
		,@newData
		,@module
		,@user
		,GETDATE()
		
	SET @rowId = SCOPE_IDENTITY()
	SELECT 0 errorCode, 'Log recorded successfully.' mes, @rowId id	

END


IF @flag = 'login'
BEGIN

	INSERT INTO LoginLogs 
     (	
		  [logType]
           ,[IP]
           ,[Reason]
		 ,[UserData]
           ,[fieldValue]
           ,[createdBy]
           ,[createdDate]
		 ,[agentId]
		 ,dcSerialNumber
		 ,dcUserName
		 ,LOGIN_COUNTRY
		 ,LOGIN_COUNTRY_CODE
		 ,LOGIN_CITY
		 ,LOGIN_REGION
		 ,LOGIN_LAT
		 ,LOGIN_LONG
		 ,LOGIN_TIMEZONE
		 ,LOGIN_ZIPCODDE
		 ,OTP_USED
		 ,IS_SUCCESSFUL
	)
	SELECT 
		 @logType
		,@IP
		,@Reason
		,@UserData
		,@fieldValue
		,@createdBy
		,GETDATE()
		,@agentId
		,@dcSerialNumber
		,@dcUserName
		,@LOGIN_COUNTRY
		,@LOGIN_COUNTRY_CODE
		,@LOGIN_CITY
		,@LOGIN_REGION
		,@LOGIN_LAT
		,@LOGIN_LONG
		,@LOGIN_TIMEZONE
		,@LOGIN_ZIPCODDE
		,@OTP_USED
		,@IS_SUCCESSFUL
		
	SELECT @ROWID = @@IDENTITY
END

-- exec proc_applicationLogs 's'

IF @flag = 's'
BEGIN 
	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
			
		--IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		--IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		SET @table = '(
						SELECT 
							 id = rowid
							,logType = CASE WHEN al.logType = ''I'' THEN ''Insert'' 
											WHEN al.logType = ''U'' THEN ''Update''
											WHEN al.logType = ''D'' THEN ''Delete''
										END
							,al.tableName
							,al.dataId
							,al.oldData
							,al.newData	
							,al.module					
							,al.createdBy
							,al.createdDate
						FROM applicationLogs al WITH(NOLOCK)
					) x'		
					
		SET @sqlFilter = ISNULL(dbo.FNAGetFilterModule(@user), '')
		
		SET @selectFieldList = '
			 id 
			,logType
			,tableName
			,dataId
			,oldData
			,newData
			,module
			,createdBy
			,createdDate 
			'
			
		IF @logType IS NOT NULL
		BEGIN
			IF @logType IN ('Insert', 'Delete', 'Update')
				SET @logType = LEFT(@logType, 1)
			SET @sqlFilter = @sqlFilter + ' AND logType LIKE ''' + @logType + '%'''
		END
			
		IF @module IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND module LIKE ''%' + @module + '%'''	

		IF @tableName IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND tableName LIKE ''%' + @tableName + '%'''	
						
		IF @createdDate IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND createdDate BETWEEN ''' + CONVERT(VARCHAR, @createdDate,101) + ''' AND ''' + CONVERT(VARCHAR, @createdDate, 101) + ' 23:59:59'''
		
		IF @createdBy IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND createdBy LIKE ''' + @createdBy + '%'''
			
			
		IF @dataId IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND dataId LIKE ''' + @dataId + '%'''
			
		IF @oldData IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND oldData LIKE ''' + @oldData + '%'''
		
		IF @newData IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND newData LIKE ''' + @newData + '%'''
		
		IF @createdBy IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND createdBy LIKE ''' + @createdBy + '%'''
		
	
						
		SET @extraFieldList = ',''<a href ="'' + CASE WHEN tableName =''RF Upload'' THEN ''manageDetail'' ELSE ''manage'' END + ''.aspx?log_Id='' + CAST(id AS VARCHAR(50)) + ''"><img border = "0" title = "View Log" src="' + '../../../images/but_view.gif" /></a>

								''[edit]'
		
		PRINT(@table)				
		
		EXEC dbo.proc_paging
			@table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber	

END

ELSE IF @flag = 'a'
BEGIN
	--select @rowId
	SELECT 
		rowId [log_Id],logType ,
		tableName,dataId,oldData,module,
		newData,createdBy,createdDate
	FROM  applicationLogs 
	WHERE rowId=@rowId
END

ELSE IF @flag = 'lv'
BEGIN
	--select @rowId
	SELECT 
		rowId [log_Id],logType ,
		UserData,Reason,fieldValue,createdBy,createdDate
	FROM  LoginLogs 
	WHERE rowId=@rowId
END

ELSE IF @flag = 'auditPackage'
BEGIN	

	--EXEC proc_applicationLogs @flag = 'auditRule', @oldData = '7015', @newData = '7015'
	SET @sql =  '
		SELECT
			''Rule'' [Field]
			,o.[data] [Old Value]
			,n.[data] [New Value]
			,CASE 
				WHEN ISNULL(o.[data], '''') = ISNULL(n.[data], '''') THEN ''N''
				ELSE ''Y''
			 END [hasChanged]
		FROM (
				SELECT DISTINCT
					 [data] = ''Domestic Rule » '' + dc.code
					,ruleId = dc.scMasterId
				FROM scMaster dc 
				WHERE dc.scMasterId IN (
					SELECT ruleId FROM commissionPackage WHERE ruleType = ''ds'' AND ISNULL(isDeleted, ''N'') = ''N'' AND packageId = ' + @oldData + '
					)	
				UNION ALL
				SELECT DISTINCT
					 [data] = ''Intl Service Charge » '' + dc.code
					,ruleId = dc.sscMasterId
				FROM sscMaster dc 
				WHERE dc.sscMasterId IN (
					SELECT ruleId FROM commissionPackage WHERE ruleType = ''sc'' AND ISNULL(isDeleted, ''N'') = ''N'' AND packageId = ' + @oldData + '
					)
				UNION ALL
				SELECT DISTINCT
					 [data] = ''Intl Send Commission » '' + dc.code
					,ruleId = dc.scSendMasterId
				FROM scSendMaster dc 
				WHERE dc.scSendMasterId IN (
					SELECT ruleId FROM commissionPackage WHERE ruleType = ''cs'' AND ISNULL(isDeleted, ''N'') = ''N'' AND packageId = ' + @oldData + '
					)
				UNION ALL
				SELECT DISTINCT
					 [data] = ''Intl Pay Commission » '' + dc.code
					,ruleId = dc.scPayMasterId
				FROM scPayMaster dc 
				WHERE dc.scPayMasterId IN (
					SELECT ruleId FROM commissionPackage WHERE ruleType = ''cp'' AND ISNULL(isDeleted, ''N'') = ''N'' AND packageId = ' + @oldData + '
					)
			) o
	FULL JOIN (
				SELECT DISTINCT
					 [data] = ''Domestic Rule » '' + dc.code
					,ruleId = dc.scMasterId
				FROM scMaster dc 
				WHERE dc.scMasterId IN (
					SELECT ruleId FROM commissionPackageHistory WHERE ruleType = ''ds'' AND approvedBy IS NULL AND modType <> ''D'' AND packageId = ' + @newData + '
					)
				UNION ALL
				SELECT DISTINCT
					 [data] = ''Intl Service Charge » '' + dc.code
					,ruleId = dc.sscMasterId
				FROM sscMaster dc 
				WHERE dc.sscMasterId IN (
					SELECT ruleId FROM commissionPackageHistory WHERE ruleType = ''sc'' AND approvedBy IS NULL AND modType <> ''D'' AND packageId = ' + @newData + '
					)
				UNION ALL
				SELECT DISTINCT
					 [data] = ''Intl Send Commission » '' + dc.code
					,ruleId = dc.scSendMasterId
				FROM scSendMaster dc 
				WHERE dc.scSendMasterId IN (
					SELECT ruleId FROM commissionPackageHistory WHERE ruleType = ''cs'' AND approvedBy IS NULL AND modType <> ''D'' AND packageId = ' + @newData + '
					)
				UNION ALL
				SELECT DISTINCT
					 [data] = ''Intl Pay Commission » '' + dc.code
					,ruleId = dc.scPayMasterId
				FROM scPayMaster dc 
				WHERE dc.scPayMasterId IN (
					SELECT ruleId FROM commissionPackageHistory WHERE ruleType = ''cp'' AND approvedBy IS NULL AND modType <> ''D'' AND packageId = ' + @newData + '
					)
		) n ON o.[data] = n.[data]
		ORDER BY ISNULL(o.[data], n.[data])
		'
	PRINT @sql
	EXEC (@sql)	
END

ELSE IF @flag = 'auditFunction'
BEGIN		
	SET @sql =  '
		SELECT
			''Function'' [Field]
			,o.[data] [Old Value]
			,n.[data] [New Value]
			,CASE 
				WHEN ISNULL(o.[functionId], 0) = ISNULL(n.[functionId], 0) THEN ''N''
				ELSE ''Y''
			 END [hasChanged]
		FROM (
				SELECT DISTINCT
					 am.menuDescription + '' » '' + af.functionName [data]
					,af.functionId
				FROM applicationMenus am 
				INNER JOIN applicationFunctions af ON am.functionId = af.parentFunctionId
					WHERE af.functionId IN (' + ISNULL(NULLIF(@oldData,'') , 0) + ')			
			) o
	FULL JOIN (
				SELECT DISTINCT
					 am.menuDescription + '' » '' + af.functionName [data]
					,af.functionId
				FROM applicationMenus am 
				INNER JOIN applicationFunctions af ON am.functionId = af.parentFunctionId
					WHERE af.functionId IN (' + ISNULL(NULLIF(@newData,'') , 0) + ')
		) n ON o.functionId = n.functionId 
		ORDER BY ISNULL(o.[data], n.[data])
		'
	--PRINT @sql
	EXEC (@sql)	
END
ELSE IF @flag = 'auditRole'
BEGIN
		
	SET @sql =  '
		SELECT
			''Role'' [Field]
			,o.[data] [Old Value]
			,n.[data] [New Value]
			,CASE 
				WHEN ISNULL(o.[roleId], 0) = ISNULL(n.[roleId], 0) THEN ''N''
				ELSE ''Y''
			 END [hasChanged]
		FROM (
				SELECT DISTINCT
					 ar.roleName [data]
					,ar.roleId
				FROM applicationRoles ar WITH(NOLOCK)
				INNER JOIN applicationUserRoles aur WITH(NOLOCK) ON ar.roleId = aur.roleId
					WHERE ar.roleId IN (' + ISNULL(NULLIF(@oldData,'') , 0) + ')	
			) o
	FULL JOIN (
				SELECT DISTINCT
					 ar.roleName [data]
					,ar.roleId
				FROM applicationRoles ar WITH(NOLOCK)
				INNER JOIN applicationUserRolesMod aur WITH(NOLOCK) ON ar.roleId = aur.roleId
					WHERE ar.roleId IN (' + ISNULL(NULLIF(@newData,'') , 0) + ')	
			)  n ON o.roleId = n.roleId '
	--PRINT @sql
	EXEC (@sql)	
END
ELSE IF @flag = 'auditAgent'
BEGIN		
	SET @sql =  '
		SELECT
			''Agent'' [Field]
			,o.[data] [Old Value]
			,n.[data] [New Value]
			,CASE 
				WHEN ISNULL(o.[agentId], 0) = ISNULL(n.[agentId], 0) THEN ''N''
				ELSE ''Y''
			 END [hasChanged]
		FROM (
				SELECT DISTINCT
					 am.agentName [data]
					,am.agentId
				FROM agentMaster am WITH(NOLOCK)
				WHERE am.agentId IN (' + ISNULL(NULLIF(@oldData,'') , 0) + ')			
			) o
	FULL JOIN (
				SELECT DISTINCT
					 am.agentName [data]
					,am.agentId
				FROM agentMaster am WITH(NOLOCK)
				WHERE am.agentId IN (' + ISNULL(NULLIF(@newData,'') , 0) + ')
		) n ON o.agentId = n.agentId 
		ORDER BY ISNULL(o.[data], n.[data])
		'
	--PRINT @sql
	EXEC (@sql)	
END

ELSE IF @flag = 'auditRuleCriteria'
BEGIN		
	SET @sql =  '
		SELECT
			''Criteria'' [Field]
			,o.[data] [Old Value]
			,n.[data] [New Value]
			,CASE 
				WHEN ISNULL(o.[valueId], 0) = ISNULL(n.[valueId], 0) THEN ''N''
				ELSE ''Y''
			 END [hasChanged]
		FROM (
				SELECT DISTINCT
					 sdv.detailTitle [data]
					,sdv.valueId
				FROM staticDataValue sdv WITH(NOLOCK)
				INNER JOIN csCriteria csc ON sdv.valueId = csc.criteriaId 
				WHERE sdv.valueId IN (' + ISNULL(NULLIF(@oldData,'') , 0) + ')			
			) o
	FULL JOIN (
				SELECT DISTINCT
					 sdv.detailTitle [data]
					,sdv.valueId
				FROM staticDataValue sdv WITH(NOLOCK)
				INNER JOIN csCriteriaHistory csch ON sdv.valueId = csch.criteriaId
				WHERE sdv.valueId IN (' + ISNULL(NULLIF(@newData,'') , 0) + ')
		) n ON o.valueId = n.valueId 
		ORDER BY ISNULL(o.[data], n.[data])
		'
	--PRINT @sql
	EXEC (@sql)	
END

ELSE IF @flag = 'auditIdCriteria'
BEGIN		
	SET @sql =  '
		SELECT
			''Criteria'' [Field]
			,o.[data] [Old Value]
			,n.[data] [New Value]
			,CASE 
				WHEN ISNULL(o.[criteriaId], 0) = ISNULL(n.[criteriaId], 0) THEN ''N''
				ELSE ''Y''
			 END [hasChanged]
		FROM (
				SELECT DISTINCT
					 a.detailTitle + '' » '' + b.detailTitle [data]
					,b.criteriaId
				FROM (SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN (' + ISNULL(NULLIF(@oldData,'') , 0) + ')) a 
				INNER JOIN (SELECT cisc.idTypeId, cisc.criteriaId, detailTitle = ISNULL(sdv.detailTitle,''Any'') FROM cisCriteria cisc
							LEFT JOIN staticDataValue sdv ON cisc.idTypeId = sdv.valueId
							WHERE cisc.cisDetailId = ' + CAST(@dataId AS VARCHAR) + ') b 
				ON a.valueId = b.criteriaId
					WHERE b.criteriaId IN (' + ISNULL(NULLIF(@oldData,'') , 0) + ')			
			) o
	FULL JOIN (
				SELECT DISTINCT
					 a.detailTitle + '' » '' + b.detailTitle [data]
					,b.criteriaId
				FROM (SELECT valueId, detailTitle FROM staticDataValue WHERE valueId IN (' + ISNULL(NULLIF(@newData,'') , 0) + ')) a 
				INNER JOIN (SELECT cisch.idTypeId, cisch.criteriaId, detailTitle = ISNULL(sdv.detailTitle,''Any'') FROM cisCriteriaHistory cisch
							LEFT JOIN staticDataValue sdv ON cisch.idTypeId = sdv.valueId
							WHERE cisch.cisDetailId = ' + CAST(@dataId AS VARCHAR) + ') b 
				ON a.valueId = b.criteriaId
					WHERE b.criteriaId IN (' + ISNULL(NULLIF(@newData,'') , 0) + ')
		) n ON o.criteriaId = n.criteriaId 
		ORDER BY ISNULL(o.[data], n.[data])
		'
	--PRINT @sql
	EXEC (@sql)	
END



