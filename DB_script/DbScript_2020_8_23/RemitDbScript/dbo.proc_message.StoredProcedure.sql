USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_message]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_message]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@msgId                             VARCHAR(30)		= NULL
	,@countryId                         INT				= NULL
	,@countryName						VARCHAR(200)	= NULL
	,@agentId                           INT				= NULL
	,@branchId							INT				= NULL
	,@agentName							VARCHAR(200)	= NULL
	,@branchName						VARCHAR(200)	= NULL
	,@headMsg							NVARCHAR(MAX)	= NULL
	,@commonMsg                         NVARCHAR(MAX)	= NULL
	,@countrySpecificMsg                NVARCHAR(MAX)	= NULL
	,@promotionalMsg                    NVARCHAR(MAX)	= NULL
	,@newsFeederMsg						NVARCHAR(MAX)	= NULL
	,@isActive							VARCHAR(10)		= NULL
	,@msgType                           CHAR(1)			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@transactionType					varchar(10)		= NULL
	,@userType							VARCHAR(2)		= NULL
	,@rCountry							VARCHAR(50)		= NULL
	,@rAgent							VARCHAR(100)	= NULL
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
	SELECT
		 @logIdentifier = 'msgId'
		,@logParamMain = 'message'
		,@logParamMod = 'messageMod'
		,@module = '10'
		,@tableAlias = 'Message Setup'
	
	
	IF @flag = 'ml' --Message list for agent/admin user
	BEGIN
/*
		--SELECT * FROM [message]
		--SELECT commonMsg [Message] FROM message 
		--	 WHERE commonMsg IS NOT NULL AND (userType = @userType OR userType IS NULL) 
		--	 AND ISNULL(isActive, 'Active') = 'Active'
		--UNION ALL
		--SELECT countrySpecificMsg FROM message WHERE countrySpecificMsg IS NOT NULL AND countryId = @countryId AND (userType = @userType OR userType IS NULL)
		--UNION ALL

		if exists(select 'x' from 
		(
			SELECT 'x' a FROM message 
				 WHERE newsFeederMsg IS NOT NULL AND (countryId = @countryId AND agentId is null) 
				 AND ISNULL(isActive, 'Active') = 'Active' AND ISNULL(isDeleted,'')<>'Y'

			UNION ALL

			SELECT 'x' a FROM message 
				 WHERE newsFeederMsg IS NOT NULL AND  
					agentId in (select parentId from agentMaster where agentId = @agentId) 
				 AND ISNULL(isActive, 'Active') = 'Active' AND ISNULL(isDeleted,'')<>'Y'
		)s)
		begin

			SELECT newsFeederMsg FROM message 
			WHERE newsFeederMsg IS NOT NULL AND (countryId = @countryId AND agentId is null) 
			AND ISNULL(isActive, 'Active') = 'Active' AND ISNULL(isDeleted,'')<>'Y'

			UNION ALL

			SELECT newsFeederMsg FROM message 
					WHERE newsFeederMsg IS NOT NULL AND  
					agentId in (select parentId from agentMaster where agentId = @agentId) 
					AND ISNULL(isActive, 'Active') = 'Active' AND ISNULL(isDeleted,'')<>'Y'
			return;
		end


		SELECT commonMsg FROM message 
			 WHERE commonMsg IS NOT NULL 
			 AND countryId = @countryId
			 AND ISNULL(isActive, 'Active') = 'Active' 
			 AND ISNULL(isDeleted,'')<>'Y'

		UNION ALL

		SELECT commonMsg FROM message 
			 WHERE commonMsg IS NOT NULL 
			 AND countryId is null
			 AND ISNULL(isActive, 'Active') = 'Active' 
			 AND ISNULL(isDeleted,'')<>'Y'

		RETURN	
		
		SELECT newsFeederMsg FROM message 
			 WHERE newsFeederMsg IS NOT NULL AND (countryId = @countryId AND agentId is null) 
			 AND ISNULL(isActive, 'Active') = 'Active' AND ISNULL(isDeleted,'')<>'Y'

	     UNION ALL

		SELECT newsFeederMsg FROM message 
			 WHERE newsFeederMsg IS NOT NULL AND  
				agentId in (select parentId from agentMaster where agentId = @agentId) 
			 AND ISNULL(isActive, 'Active') = 'Active' AND ISNULL(isDeleted,'')<>'Y'

*/
		-->> News for all 

		DECLARE @agentNature AS VARCHAR(50) = null
		if @agentId is not null
			SELECT @agentNature = agentRole FROM agentMaster with(nolock) where agentId = @agentId

		-->> all
		select newsFeederMsg from [message] WITH(NOLOCK)
		where newsFeederMsg is not null 
		and countryId is null 
		and agentId is null 
		and (msgType ='B' or msgType = @agentNature)
		and ISNULL(isDeleted,'N') = 'N' 
		and isnull(isActive,'Active') = 'Active'

		union all

		-->> country specific
		select newsFeederMsg from [message] WITH(NOLOCK)
		where newsFeederMsg  is not null  
		and countryId = @countryId 
		and agentId is null  
		and (msgType = 'B' or msgType = @agentNature)
		and ISNULL(isDeleted,'N') = 'N' 
		and isnull(isActive,'Active') = 'Active'

		union all

		-->> country & agent specific
		select newsFeederMsg from [message] WITH(NOLOCK)
		where newsFeederMsg is not null 
		and countryId = @countryId 
		and agentId = @agentId 
		and (msgType = 'B' or msgType = @agentNature)
		and ISNULL(isDeleted,'N') = 'N' 
		and isnull(isActive,'Active') = 'Active'

	END	

	IF @flag IN ('i', 'u', 'd')
	BEGIN
		IF @flag IN ('d')
		BEGIN
			SELECT @headMsg = headMsg
				, @commonMsg = commonMsg
				, @countrySpecificMsg = countrySpecificMsg
				, @promotionalMsg = promotionalMsg
				, @newsFeederMsg = newsFeederMsg 
			FROM message WITH(NOLOCK) WHERE msgId = @msgId
		END
		IF @headMsg IS NOT NULL
			SET @tableAlias = 'Head Message'
		ELSE IF @commonMsg IS NOT NULL
			SET @tableAlias = 'Common Message'
		ELSE IF @promotionalMsg IS NOT NULL
			SET @tableAlias = 'Promotional Message'
		ELSE IF @countrySpecificMsg IS NOT NULL
			SET @tableAlias = 'Country Specific Message'
		ELSE IF @newsFeederMsg IS NOT NULL
			SET @tableAlias = 'News Feeder Message'
	END

	IF @flag = 'i'
	BEGIN
		--IF EXISTS(SELECT 'X' FROM message WHERE countryId = @countryId AND commonMsg IS NOT NULL AND @msgType IS NULL AND @commonMsg IS NOT NULL)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Message Setup already done for this country', @msgId
		--	RETURN
		--END
		--IF EXISTS(SELECT 'X' FROM message WHERE countryId = @countryId AND msgType = @msgType AND countrySpecificMsg IS NOT NULL AND @countrySpecificMsg IS NOT NULL) 
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Message Setup already done for this country and message type', @msgId
		--	RETURN
		--END
		--IF EXISTS(SELECT 'X' FROM message WHERE agentId = @agentId AND msgType = @msgType AND promotionalMsg IS NOT NULL AND @promotionalMsg IS NOT NULL)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Message Setup already done for this agent and message type', @msgId
		--	RETURN
		--END
		IF EXISTS(
			SELECT 'X' FROM message WHERE msgType = @msgType 
			AND ISNULL(countryId, 0) = ISNULL(@countryId, ISNULL(countryId, 0)) 
			AND ISNULL(agentId, 0) = ISNULL(@agentId, ISNULL(agentId, 0))
			AND rCountry = @rCountry 
			AND ISNULL(rAgent, '') = ISNULL(@rAgent, ISNULL(rAgent, '')) 
			AND ISNULL(transactionType, '') = ISNULL(@transactionType, ISNULL(transactionType, '')) 
			AND ISNULL(isDeleted, 'N') = 'N'
		)
		BEGIN
			EXEC proc_errorHandler 1, 'Message Setup already done', @msgId
			RETURN	
		END

		BEGIN TRANSACTION

			INSERT INTO [message] (
				 countryId
				,agentId
				,headMsg
				,commonMsg
				,countrySpecificMsg
				,promotionalMsg
				,newsFeederMsg
				,isActive
				,msgType
				,createdBy
				,createdDate
				,userType
				,transactionType
				,rCountry
				,rAgent
				,branchId
				

				
			)
			SELECT
				 @countryId
				,@agentId
				,@headMsg
				,@commonMsg
				,@countrySpecificMsg
				,@promotionalMsg
				,@newsFeederMsg
				,@isActive
				,@msgType
				,@user
				,GETDATE()
				,@userType
				,@transactionType
				,@rCountry
				,@rAgent
				,@branchId
				
				
			
			SET @msgId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @msgId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @msgId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @msgId
				RETURN
			END

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @msgId

	END

	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM message WITH(NOLOCK) WHERE msgId = @msgId
	END
	
	ELSE IF @flag = 'populateAgent'
	BEGIN
		SELECT agentId,agentName 
		FROM agentMaster WITH(NOLOCK) WHERE agentRole = @msgType and isnull(isDeleted,'N')<>'Y'
		ORDER BY agentName 
	END
	
	ELSE IF @flag = 'u'
	BEGIN
	
	IF EXISTS(
			SELECT 'X' FROM message WHERE msgType = @msgType 
			AND ISNULL(countryId, 0) = ISNULL(@countryId, ISNULL(countryId, 0)) 
			AND ISNULL(agentId, 0) = ISNULL(@agentId, ISNULL(agentId, 0))
			AND rCountry = @rCountry 
			AND ISNULL(rAgent, '') = ISNULL(@rAgent, ISNULL(rAgent, '')) 
			AND ISNULL(transactionType, '') = ISNULL(@transactionType, ISNULL(transactionType, '')) 
			AND ISNULL(isDeleted, 'N') = 'N' AND msgId <> @msgId
		)
		BEGIN
			EXEC proc_errorHandler 1, 'Message Setup already done', @msgId
			RETURN	
		END
		
		BEGIN TRANSACTION
			UPDATE message SET
				 countryId = @countryId
				,agentId = @agentId
				,headMsg = @headMsg
				,commonMsg = @commonMsg
				,countrySpecificMsg = @countrySpecificMsg
				,promotionalMsg = @promotionalMsg
				,newsFeederMsg = @newsFeederMsg
				,isActive = @isActive
				,msgType = @msgType
				,modifiedBy = @user
				,modifiedDate = GETDATE()
				,userType = @userType
				,transactionType = @transactionType
				,rCountry = @rCountry
				,rAgent = @rAgent
				,branchId = @branchId
			WHERE msgId = @msgId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @msgId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @msgId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @msgId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @msgId
	END

	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE message SET
				isDeleted =	'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy	= @user
			WHERE msgId	= @msgId
			SET	@modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow	@logParamMain, @logIdentifier,	@msgId,	@oldValue OUTPUT
			INSERT INTO	#msg(errorCode,	msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,	 @msgId, @user,	@oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg	WHERE errorCode	<> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete	record.', @msgId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @msgId
	END	  

	ELSE IF @flag IN ('s1')			--Common Message
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'msgId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.msgId
					,main.countryId
					,countryName = ISNULL(cm.countryName, ''All'')
					,main.agentId 
					,agentName = ISNULL(am.agentName, ''All'')
					,main.headMsg
					,main.commonMsg
					,main.countrySpecificMsg
					,main.promotionalMsg
					,main.newsFeederMsg
					,main.isActive
					,main.msgType
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM message main WITH(NOLOCK)
				LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.countryId = cm.countryId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId				
					WHERE main.commonMsg IS NOT NULL 
					) x'
	END
	
	ELSE IF @flag IN ('s2')		--countrySpecificMsg
	BEGIN
		IF @sortBy IS NULL
			SET	@sortBy	= 'msgId'
		IF @sortOrder IS NULL
			SET	@sortOrder = 'ASC'
		SET	@table = '(
				SELECT
					 main.msgId
					,main.countryId
					,CountryName =  CASE WHEN SC.countryName IS NULL  THEN ''ALL'' ELSE SC.countryName END
				     ,rCountry = CASE WHEN RC.countryName IS NULL THEN  ''ALL'' ELSE RC.countryName END
					,main.agentId
					,AgentName =  CASE WHEN SA.agentName IS NULL THEN ''ALL'' ELSE SA.agentName  END
				     ,rAgent = CASE WHEN RA.agentName IS NULL THEN ''ALL'' ELSE RA.agentName END
					,main.headMsg
					,main.commonMsg
					,main.countrySpecificMsg
					,main.promotionalMsg
					,main.newsFeederMsg
					,main.isActive
					,msgType = CASE	WHEN main.msgType =	''S'' THEN ''Send''	
									WHEN main.msgType =	''R'' THEN ''Receive''
									WHEN main.msgType =	''B'' THEN ''Both''
									ELSE '''' END
					,main.createdBy
					,main.createdDate
					,main.isDeleted
					,main.branchId 
					,branchName = ISNULL(SA.agentName, ''All'')
				FROM message main WITH(NOLOCK)

				LEFT JOIN countryMaster	sc WITH(NOLOCK) ON main.countryId =	sc.countryId
			    LEFT JOIN countryMaster Rc WITH(NOLOCK) ON main.rCountry =	RC.countryId
				LEFT JOIN agentMaster SA WITH(NOLOCK) ON main.agentId =	SA.agentId
				LEFT JOIN agentMaster RA WITH(NOLOCK) ON main.rAgent =	RA.agentId
			
				
				WHERE main.countrySpecificMsg IS NOT NULL 
				) x'
				
				
				SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
			
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''
			
		IF @rCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rCountry LIKE ''%' + @rCountry + '%'''
			
		IF @rAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rAgent LIKE ''%' + @rAgent + '%'''
			
			  print @table

			 SET @select_field_list ='
			 msgId
			,countryId
			,countryName
			,rcountry
			,agentId 
			,agentName
			, ragent
			,headMsg
			,commonMsg
			,countrySpecificMsg
			,promotionalMsg
			,newsFeederMsg
			,isActive
			,msgType
			,createdBy
			,createdDate
			,isDeleted '
			
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
	
	ELSE IF @flag IN ('s3')		--promotionalMsg
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'msgId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.msgId
					,main.countryId
					,countryName = cm.countryName
					,main.agentId
					,agentName = am.agentName
					,main.headMsg
					,main.commonMsg
					,main.countrySpecificMsg
					,main.promotionalMsg
					,main.newsFeederMsg
					,main.isActive
					,msgType = CASE WHEN main.msgType = ''S'' THEN ''Send'' 
									WHEN main.msgType = ''R'' THEN ''Receive''
									WHEN main.msgType =	''B'' THEN ''Both''
									ELSE '''' END
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM message main WITH(NOLOCK)
				LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.countryId = cm.countryId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
				WHERE main.promotionalMsg IS NOT NULL 
					) x'
	END
	
	ELSE IF @flag IN ('s4')     --head msg
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'msgId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.msgId
					,main.countryId
					,countryName = ISNULL(cm.countryName, ''All'')
					,main.agentId
					,agentName = am.agentName
					,main.headMsg
					,main.commonMsg
					,main.countrySpecificMsg
					,main.promotionalMsg
					,main.newsFeederMsg
					,main.isActive
					,main.msgType
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM message main WITH(NOLOCK)
				LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.countryId = cm.countryId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
					WHERE main.headMsg IS NOT NULL 
					) x'
	END
	
	ELSE IF @flag IN ('s5')		--newsfeeder
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'msgId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.msgId
					,main.countryId
					,countryName = ISNULL(cm.countryName, ''All'')
					,main.agentId 
					,agentName = ISNULL(am.agentName, ''All'')			
					,main.headMsg
					,main.commonMsg
					,main.countrySpecificMsg
					,main.promotionalMsg
					,main.newsFeederMsg
					,main.isActive
					,userType = isnull(sd.detailDesc,''All'') 
					,msgType = CASE WHEN main.msgType = ''S'' THEN ''Send'' 
									WHEN main.msgType = ''R'' THEN ''Receive''
									WHEN main.msgType =	''B'' THEN ''Both''
									ELSE '''' END
					,main.createdBy
					,main.createdDate
					,main.isDeleted
					,main.branchId 
					,branchName = ISNULL(am1.agentName, ''All'')
					,isActiveF = case when main.isActive = ''Active'' then ''Y'' when main.isActive = ''Inactive'' then ''N'' else NULL end
					,userTypeF = userType					
				FROM message main WITH(NOLOCK)
				LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.countryId = cm.countryId
				LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
				LEFT JOIN staticDatavalue sd ON sd.detailTitle = main.userType
				left join agentmaster am1 with(nolock) on main.branchId= am1.agentId
					WHERE main.newsFeederMsg IS NOT NULL 
					) x'
	END
	
	IF @flag IN('s1','s3','s4','s5')
	BEGIN
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND countryName LIKE ''%' + @countryName + '%'''
			
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName LIKE ''%' + @agentName + '%'''		  

		IF @flag='s5'
		BEGIN			

			if @branchName is not null or @branchName <> ''
				SET @sql_filter = @sql_filter + ' AND branchName LIKE ''%' + @branchName + '%'''	
			
			if @userType is not null or @userType <> ''
				SET @sql_filter = @sql_filter + ' AND userTypeF = ''' + @userType + ''''

			if @isActive is not null or @isActive <> ''
				SET @sql_filter = @sql_filter + ' AND isActiveF = ''' + @isActive + ''''


			 SET @select_field_list ='
					 msgId
					,countryId
					,countryName
					,agentId 
					,agentName
					,headMsg
					,commonMsg
					,countrySpecificMsg
					,promotionalMsg
					,newsFeederMsg
					,isActive
					,userType
					,msgType
					,createdBy
					,createdDate
					,isDeleted
					,branchId
					,branchName '
		END
		ELSE
		BEGIN
			SET @select_field_list ='
			 msgId
			,countryId
			,countryName
			,agentId 
			,agentName
			,headMsg
			,commonMsg
			,countrySpecificMsg
			,promotionalMsg
			,newsFeederMsg
			,isActive
			,msgType
			,createdBy
			,createdDate
			,isDeleted '
		END

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

	if @flag='userType'
	begin
		select null VALUE ,'All' [TEXT]
		union all
		select detailTitle,detailDesc from staticDataValue with(nolock) where typeId=7300
	end

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @msgId
END CATCH







GO
