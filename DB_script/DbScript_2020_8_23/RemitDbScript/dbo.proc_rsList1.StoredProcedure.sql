USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_rsList1]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Exec [proc_rsList1] @flag = 'A', @rowid = '1'
    Exec [proc_rsList1] @flag = 'SENDL'
*/
CREATE proc [dbo].[proc_rsList1]
	@flag                       VARCHAR(50)	= NULL
	,@user                      VARCHAR(30)	= NULL
    ,@rowid						INT			= NULL
    ,@countryId					VARCHAR(50) = NULL
	,@agentId					VARCHAR(50) = NULL
    ,@rsCountryId				VARCHAR(50) = NULL
    ,@countryName				VARCHAR(100)= NULL
    ,@rsAgentId					VARCHAR(50) = NULL
    ,@roleType					CHAR(1)		= NULL
    ,@listType					VARCHAR(5)	= NULL
    ,@tranType					VARCHAR(20)	= NULL
    ,@applyToAgent				CHAR(1)		= NULL
    ,@isDeleted                 CHAR(1)		= NULL     
    ,@sortBy                    VARCHAR(50)	= NULL
    ,@sortOrder                 VARCHAR(5)	= NULL
    ,@pageSize                  INT			= NULL
    ,@pageNumber                INT			= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
		,@errorMsg			VARCHAR(MAX)

	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)

IF @flag = 'pcl'
BEGIN
	DECLARE @agentType INT, @agent INT
	SELECT @agentType = agentType, @agent = parentId, @countryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
	IF(@agentType = 2903)
		SET @agent = @agentId
		
	SELECT x.countryId, x.countryName INTO #payoutCountryList FROM
	(
		SELECT 
			 cm.countryId
			,cm.countryName
			,rsl.listType
		FROM countryMaster cm
		INNER JOIN rsList1 rsl WITH(NOLOCK) ON cm.countryId = rsl.rsCountryId AND roleType = 's'
		WHERE rsl.countryId = @countryId AND applyToAgent = 'Y'

		UNION ALL

		SELECT 
			 cm.countryId
			,cm.countryName
			,rsl.listType
		FROM countryMaster cm
		INNER JOIN rsList1 rsl WITH(NOLOCK) ON cm.countryId = rsl.rsCountryId AND roleType = 's' AND listType = 'in'
		WHERE rsl.agentId = @agent
	)x

	DELETE FROM #payoutCountryList 
	FROM #payoutCountryList pcl
	INNER JOIN rsList1 rsl WITH(NOLOCK) ON pcl.countryId = rsl.rsCountryId AND roleType = 's'
	WHERE rsl.agentId = @agent AND listType = 'ex'

	SELECT * FROM #payoutCountryList
END
IF @flag = 'a'
BEGIN 
    
    SELECT * From rsList1 with (nolock)
    where rowid= @rowid

END
----------------FILTER AGENT FROM SENDING COUNTRY WISE NOT EXCLUSIVE AGENT
--------ELSE IF @flag = 'notExc'
--------BEGIN
--------	SELECT agentId,agentName 
--------	FROM agentMaster 
--------	WHERE agentCountryId  = @rsCountryId AND agentId NOT IN
--------		(SELECT ISNULL(rsAgentId,0) FROM rsList1 WHERE rsCountryId =@rsCountryId AND agentId =@agentId )
--------END
------SHOW COUNTRY WISE SERVICE TYPE
ELSE IF @flag = 'cST'
BEGIN
	SELECT *  FROM dbo.FNAGetServiceTypeFromCountry(@rsCountryId,@agentId)
		WHERE serviceTypeId IS NOT NULL
	
	----IF EXISTS(SELECT 'A' FROM rsList1 WHERE rsCountryId =@rsCountryId AND countryId = 
	----			(SELECT agentCountryId FROM agentMaster WHERE agentId = @agentId) 
	----		AND tranType IS NOT NULL)
	----BEGIN
	----	SELECT serviceTypeId,typeTitle 
	----	FROM serviceTypeMaster 
	----	WHERE ISNULL(isDeleted,'N')='N' AND ISNULL(isActive,'Y')='Y'
	----	AND serviceTypeId IN (SELECT tranType FROM rsList1 WHERE rsCountryId =@rsCountryId
	----	AND countryId = (SELECT agentCountryId FROM agentMaster WHERE agentId = @agentId))
	----END
	----ELSE
	----	SELECT serviceTypeId,typeTitle 
	----	FROM serviceTypeMaster 
	----	WHERE ISNULL(isDeleted,'N')='N' AND ISNULL(isActive,'Y')='Y'
END
ELSE IF @flag = 'SENDL'
BEGIN 
    
    SELECT countryId,countryName FROM countryMaster WHERE countryId NOT IN(    
    SELECT countryId From rsList1 with (nolock)
    where roleType='s' AND ISNULL(isDeleted,'N')<>'Y')
    ORDER BY countryName 

END

ELSE IF @flag = 'd'
BEGIN 
    BEGIN TRANSACTION
    
		UPDATE rsList1 
		 set isDeleted ='Y', ModifiedBy=@user, ModifiedDate=GETDATE()
		where rowid= @rowid

	INSERT INTO #msg(errorCode, msg, id)
	EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
	
	IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
	BEGIN
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		EXEC proc_errorHandler 1, 'Failed to delete record.', @rowid
		RETURN
	END
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	EXEC proc_errorHandler 0, 'Record has been deleted successfully.', @rowid
END
---------- COUNTRY WISE COUNTRY SETUP
ELSE IF @flag = 'i'
BEGIN 
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND countryId = @countryId AND rsCountryId = @rsCountryId AND tranType IS NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'All Transaction type is setup..', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND countryId = @countryId 
				AND rsCountryId = @rsCountryId AND tranType IS NOT NULL)
	BEGIN
		IF @tranType IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'All Transaction type can not setup..', @rowid
			RETURN;
		END
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND countryId = @countryId AND rsCountryId = @rsCountryId AND tranType = @tranType)
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added..', @rowid
		RETURN;
	END
	
	BEGIN TRANSACTION
	     INSERT INTO 
		 rsList1 (
			 agentId
			,countryId
			,rsagentId
			,rscountryId
			,roleType
			,listType
			,tranType
			,applyToAgent
			,createdBy
			,createdDate
		)
		SELECT
			 @agentId
			,@countryId
			,@rsAgentId
			,@rsCountryId
			,@roleType
			,@listType
			,@tranType
			,@applyToAgent
			,@user
			,GETDATE()

		SET @rowid = SCOPE_IDENTITY()
		
	    INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowid
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowid

END

ELSE IF @flag = 'u'
BEGIN 
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND countryId = @countryId AND rsCountryId = @rsCountryId AND tranType IS NULL AND rowId<> @rowid)
	BEGIN
		EXEC proc_errorHandler 1, 'All Transaction type is setup..', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND countryId = @countryId 
				AND rsCountryId = @rsCountryId AND tranType IS NOT NULL AND rowId<> @rowid)
	BEGIN
		IF @tranType IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'All Transaction type can not setup..', @rowid
			RETURN;
		END
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND countryId = @countryId AND rsCountryId = @rsCountryId 
				AND tranType = @tranType AND rowId <> @rowid)
	BEGIN
		EXEC proc_errorHandler 1, 'Record already added..', @rowid
		RETURN;
	END
	
	BEGIN TRANSACTION
	     UPDATE  rsList1 SET 
			countryId = @countryId
			,rscountryId = @rsCountryId
			,roleType = @roleType
			,listType = @listType
			,tranType = @tranType
			,applyToAgent = @applyToAgent
			,modifiedBy = @user
			,modifiedDate = GETDATE()
		WHERE rowId = @rowid
		
	    INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'u', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rowid
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @rowid

END
---------EXCLUDE/INCLUSIVE AGENT FROM COUNTRY LIST
ELSE IF @flag = 'iAExC'
BEGIN 
	IF NOT EXISTS(SELECT typeTitle  FROM dbo.FNAGetServiceTypeFromCountry(@rsCountryId,@agentId) WHERE ISNULL(serviceTypeId,0) = ISNULL(@tranType,0))
	BEGIN	
		EXEC proc_errorHandler 1, 'Invalid Transaction type setup..', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND agentId = @agentId 
				AND rsCountryId = @rsCountryId AND rsAgentId IS NULL AND listType = @listType )
	BEGIN
		EXEC proc_errorHandler 1, 'All Agent already setup..', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND agentId = @agentId 
				AND rsCountryId = @rsCountryId AND rsAgentId = ISNULL(@rsAgentId,rsAgentId) AND tranType IS NULL AND listType = @listType )
	BEGIN
		EXEC proc_errorHandler 1, 'All Transaction type is setup..', @rowid
		RETURN;
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND agentId = @agentId 
				AND rsCountryId = @rsCountryId AND rsAgentId = ISNULL(@rsAgentId,rsAgentId) AND tranType IS NOT NULL AND listType = @listType )
	BEGIN
		IF @tranType IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'All Transaction type can not setup..', @rowid
			RETURN;
		END
	END
	
	IF EXISTS(SELECT TOP 1 'A' FROM rsList1 WHERE ISNULL(isDeleted,'N')<>'Y' AND agentId = @agentId 
				AND rsCountryId = @rsCountryId AND rsAgentId = ISNULL(@rsAgentId,rsAgentId) AND tranType = @tranType AND listType = @listType )
	BEGIN
		EXEC proc_errorHandler 1, 'Agent already added..', @rowid
		RETURN;
	END
	
	SELECT @countryId = agentCountryId FROM agentMaster WHERE agentId = @agentId
	
	BEGIN TRANSACTION
	     INSERT INTO 
		 rsList1 (
			 agentId
			 ,countryId
			,rsagentId
			,rscountryId
			,roleType
			,listType
			,tranType
			,createdBy
			,createdDate
		)
		SELECT
			 @agentId
			 ,@countryId
			,@rsAgentId
			,@rsCountryId
			,@roleType
			,@listType
			,@tranType
			,@user
			,GETDATE()

		SET @rowid = SCOPE_IDENTITY()
		
	    INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowid
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowid

END


-- AGENT SENDING COUNTRY LIST DISPLAY
ELSE IF @flag = 'aSC'
BEGIN

	SELECT countryId,countryName FROM countryMaster 
	WHERE countryId IN
	(
		SELECT rsCountryId FROM rsList1 
		WHERE countryId =
		(
			SELECT agentCountryId FROM agentMaster WHERE agentId=@agentId
		) AND ISNULL(isDeleted,'N')<>'Y' AND applyToAgent =CASE WHEN @listType = 'ex' THEN 'Y' ELSE 'N'	END
	)

END
--   select country sending/Receiving list setup
ELSE IF @flag = 'sC'
BEGIN 
	
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
						SELECT 
							rs.rowId 
							,rs.countryId
							,ISNULL(ST.typeTitle,''All'') tranType
							,[rscountryId] = rsC.countryName 
							,rs.roleType
							,applyToAgent = CASE WHEN rs.applyToAgent = ''N'' THEN ''NO'' ELSE ''YES'' END
							,[Type]	= CASE WHEN rs.roleType = ''s'' THEN ''Sending'' ELSE ''Receiving'' END 
							,[listType] = CASE WHEN rs.listType = ''in'' THEN ''Inclusive'' ELSE ''Exclusive'' END 
							,rs.createdBy
							,rs.createdDate
						FROM rsList1 RS WITH (NOLOCK)
						INNER JOIN countryMaster rsC WITH (NOLOCK) ON RS.rscountryId = rsC.countryId
						LEFT JOIN serviceTypeMaster ST WITH(NOLOCK) ON ISNULL(RS.tranType,''0'')=ST.serviceTypeId
					    WHERE ISNULL(rs.isDeleted,''N'') <> ''Y''
						AND rs.countryId = '''+ @countryId +'''
			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,countryId
						  ,rscountryId
						  ,tranType
						  ,roleType 
						  ,Type
						  ,listType
						  ,applyToAgent
						  ,createdBy
						  ,createdDate
						'
			
		IF @roleType IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND roleType  =  ''' + @roleType + ''''		

	     
		IF @rsCountryId IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND rscountryId like '''+ @rsCountryId + '%'''

		
		  SET @table =  @table +') x '



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

ELSE IF @flag = 'rC'
BEGIN 
	
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
						SELECT 
							rs.rowId 
							,rs.rscountryId
							,ISNULL(ST.typeTitle,''All'') tranType
							,[rsCountryName] = rsC.countryName 
							,rs.roleType
							,rs.createdBy
							,rs.createdDate
						FROM rsList1 RS WITH (NOLOCK)
						INNER JOIN countryMaster rsC WITH (NOLOCK) ON RS.CountryId = rsC.countryId
						LEFT JOIN serviceTypeMaster ST WITH(NOLOCK) ON ISNULL(RS.tranType,''0'')=ST.serviceTypeId
					    WHERE ISNULL(rs.isDeleted,''N'') <> ''Y''
					    AND RS.rsCountryId = '''+ @countryId +'''
			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,rscountryId
						  ,tranType
						  ,rsCountryName 
						  ,roleType 
						  ,createdBy
						  ,createdDate
						'
			
		
		IF @rsCountryId IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND rsCountryName like '''+ @rsCountryId + '%'''

		
		  SET @table =  @table +') x '



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

--- select agent sending/receiving list setup
ELSE IF @flag = 'sA'
BEGIN 
	
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
						SELECT 
							rs.rowId
							,rs.agentId
							,AgentName = ISNULL(aM.AgentName,''All'')
							,cM.countryName 
							,rs.roleType
							,rs.listType
							,ISNULL(ST.typeTitle,''All'') tranType
							,sDV.detailTitle [agentType]
							,rs.createdBy
							,rs.createdDate
						FROM rsList1 RS WITH (NOLOCK)
						INNER JOIN countryMaster cM WITH (NOLOCK) ON RS.rscountryId = cM.countryId
						LEFT JOIN agentMaster aM WITH (NOLOCK) ON RS.RSagentId = aM.agentId
						LEFT JOIN staticDataValue sDV ON aM.agentType = sDV.valueId 
						LEFT JOIN serviceTypeMaster ST WITH(NOLOCK) ON ISNULL(RS.tranType,''0'')=ST.serviceTypeId
					   WHERE ISNULL(rs.isDeleted,''N'') <> ''Y''
						AND rs.agentId = '''+ @agentId +'''
			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,agentId
						  ,AgentName
						  ,CountryName 
						  ,roleType 
						  ,listType
						  ,tranType
						  ,agentType
						  ,createdBy
						  ,createdDate
						'
			
		IF @roleType IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND roleType  =  ''' + @roleType + ''''		

	     
		IF @listType IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND listType = '''+ @listType + ''''

		
		  SET @table =  @table +') x '



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

ELSE IF @flag = 'rA'
BEGIN 
	
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
						SELECT 
							rs.rowId
							,AgentName = ISNULL(aM.AgentName,''All'')
							,cM.countryName 
							,rs.roleType
							,rs.listType
							,ISNULL(ST.typeTitle,''All'') tranType
							,sDV.detailTitle [agentType]
							,rs.createdBy
							,rs.createdDate
						FROM rsList1 RS WITH (NOLOCK)
						INNER JOIN countryMaster cM WITH (NOLOCK) ON RS.countryId = cM.countryId
						LEFT JOIN agentMaster aM WITH (NOLOCK) ON RS.agentId = aM.agentId
						LEFT JOIN staticDataValue sDV ON aM.agentType = sDV.valueId 
						LEFT JOIN serviceTypeMaster ST WITH(NOLOCK) ON ISNULL(RS.tranType,''0'')=ST.serviceTypeId
					   WHERE ISNULL(rs.isDeleted,''N'') <> ''Y''
						AND rs.rsagentId = '''+ @agentId +'''
			 '	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
						   rowID
						  ,AgentName
						  ,CountryName 
						  ,roleType 
						  ,listType
						  ,tranType
						  ,agentType
						  ,createdBy
						  ,createdDate
						'
			
		IF @roleType IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND roleType  =  ''' + @roleType + ''''		

	     
		IF @listType IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND listType = '''+ @listType + ''''

		
		  SET @table =  @table +') x '



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


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowid
END CATCH



GO
