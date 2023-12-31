USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentUserLimit]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_agentUserLimit]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@userLimitId						INT				= NULL
	,@agentId							INT				= NULL
	,@userId							INT				= NULL
	,@currencyId                        INT				= NULL
	,@payLimit							MONEY			= NULL
	,@sendLimit							MONEY			= NULL
	,@isEnable							CHAR(1)			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


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
		,@oldAgent			INT
		,@ApprovedFunctionId	VARCHAR(8)
		

	SELECT
		 @logIdentifier = 'userLimitId'
		,@logParamMain = 'userLimit'
		,@logParamMod = 'userLimitMod'
		,@module = '20'
		,@tableAlias = 'User Limit Setup'
		,@ApprovedFunctionId = '10101130'
		
	
	IF @flag IN ('s') 
	BEGIN
		--SELECT * FROM userLimit
		SET @table = '(
					SELECT
						 userLimitId		= ISNULL(mode.userLimitId, main.userLimitId)
						,currencyId			= ISNULL(mode.currencyId, main.currencyId)
						,userId				= ISNULL(mode.userId, main.userId)
						,payLimit			= ISNULL(mode.payLimit,main.payLimit)
						,sendLimit			= ISNULL(mode.sendLimit,main.sendLimit)
						,isEnable			= ISNULL(mode.isEnable,main.isEnable)
						,main.createdBy
						,main.createdDate			
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy	END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.userLimitId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END
					FROM userLimit main WITH(NOLOCK)
					LEFT JOIN userLimitMod mode ON main.userLimitId = mode.userLimitId 
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
				) '
	
	END	
		
	IF @flag = 'i'
	BEGIN
		
		--select * from userLimit
		IF EXISTS(SELECT 'X' FROM userLimit WITH(NOLOCK) WHERE currencyId = @currencyId AND userId=@userId AND ISNULL(isDeleted,'N')<>'y')
		BEGIN
		   EXEC proc_errorHandler 1, 'Record already exists!',@currencyId
		   RETURN
		END
			
		BEGIN TRANSACTION
			INSERT INTO userLimit (
				 currencyId
				,userId
				,payLimit
				,sendLimit
				,isEnable				
				,createdBy
				,createdDate
			)
			SELECT
				 @currencyId
				,@userId
				,@payLimit
				,@sendLimit
				,@isEnable
				,@user
				,GETDATE()
			SET @modType = 'Insert'

		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @userLimitId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		--select * from userLimit
		IF EXISTS(SELECT 'X' FROM userLimit WHERE currencyId = @currencyId AND userId = @userId and userLimitId <> @userLimitId
								AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
		   EXEC proc_errorHandler 1, 'Record already exists!', @userLimitId
		   RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM userLimit WITH(NOLOCK) WHERE userLimitId = @userLimitId AND approvedBy IS NULL AND createdBy = @user)
			BEGIN
				UPDATE userLimit SET
					 currencyId			= @currencyId
					,userId				= @userId
					,payLimit			= @payLimit
					,sendLimit			= @sendLimit
					,isEnable			= @isEnable
					,modifiedBy			= @user
					,modifiedDate		= GETDATE() 
				WHERE userLimitId = @userLimitId
			END 
			ELSE
			BEGIN
				DELETE FROM userLimitMod WHERE userLimitId = @userLimitId
					
				INSERT INTO userLimitMod (
					 userLimitId
					,currencyId
					,userId
					,payLimit
					,sendLimit
					,isEnable             
					,createdDate
					,createdBy
					,modType                    
				)
				SELECT
					 @userLimitId
					,@currencyId
					,@userId
					,@payLimit
					,@sendLimit 
					,@isEnable			           
					,GETDATE()
					,@user
					,'U'            
			END
        COMMIT TRANSACTION       
        EXEC proc_errorHandler 0, 'Record updated successfully', @userLimitId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM userLimitMod WITH(NOLOCK) WHERE userLimitId = @userLimitId AND createdBy = @user)
		BEGIN
			SELECT 
				 userLimitId, currencyId, userId
				,payLimit = dbo.[ShowDecimalExceptComma](payLimit)
				,sendLimit = dbo.[ShowDecimalExceptComma](sendLimit)
				,isEnable = ISNULL(isEnable, 'N')
			FROM userLimitMod WITH(NOLOCK) 
			WHERE userLimitId = @userLimitId	
		END
		ELSE
		BEGIN
			SELECT 
				 userLimitId, currencyId, userId
				,payLimit = dbo.[ShowDecimalExceptComma](payLimit)
				,sendLimit = dbo.[ShowDecimalExceptComma](sendLimit)
				,isEnable = ISNULL(isEnable, 'N')
			FROM userLimit WITH(NOLOCK) 
			WHERE userLimitId = @userLimitId		
		END
	END
	
	ELSE IF @flag='d'--- deleting agent user limit
	BEGIN
		IF EXISTS (SELECT 'X' FROM userLimit WITH(NOLOCK) WHERE userLimitId = @userLimitId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @userLimitId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM userLimitMod WITH(NOLOCK) WHERE userLimitId = @userLimitId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @userLimitId
			RETURN
		END
		
		BEGIN TRANSACTION	
		IF EXISTS (SELECT 'X' FROM userLimit WITH(NOLOCK) WHERE userLimitId = @userLimitId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM userLimit WHERE userLimitId = @userLimitId
		END
		ELSE
		BEGIN
			INSERT INTO userLimitMod (
				 userLimitId
				,currencyId
				,userId
				,payLimit
				,sendLimit  
				,isEnable     		                 
				,createdDate
				,createdBy
				,modType                  
			)
			SELECT
				 userLimitId
				,currencyId
				,userId
				,payLimit
				,sendLimit
				,isEnable           		                 				           
				,GETDATE()
				,@user
				,'D'
			FROM userLimit WHERE userLimitId = @userLimitId
		END
		
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @userLimitId
	END	

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'userLimitId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT 
					 main.userLimitId
					,cm.currencyCode
					,au.userName
					,main.payLimit
					,main.sendLimit
					,main.createdBy
					,createdDate = convert(varchar,main.createdDate,107)
					,main.modifiedBy
					,main.haschanged
				FROM ' + @table + ' main 
				INNER JOIN currencyMaster cm WITH(NOLOCK) ON main.currencyId = cm.currencyId
				INNER JOIN applicationUsers au WITH(NOLOCK) ON au.userId = main.userId
				 WHERE main.userId = ' + CAST(@userId AS VARCHAR) + ' 
			) x'
			
		PRINT @table
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter 
		SET @select_field_list ='
			 userLimitId
			,currencyCode
			,userName
			,payLimit
			,sendLimit
			,createdBy
			,createdDate
			,modifiedBy
			,haschanged
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
	ELSE IF @flag='s1'-- populating agent label
	begin

		SELECT agentName,b.userName FROM agentMaster a inner join applicationUsers b on a.agentId=b.agentId
		where b.userId=@userId
		
	end
	ELSE IF @flag='s2'-- populating agent currency type
	begin
		--Exec proc_agentUserLimit @flag='s2',@agentId='3859',@currencyId='4'
		--select * from agentCurrency 
		DECLARE @countryId INT
		SELECT @countryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
		IF EXISTS(SELECT 'X' FROM countryCurrency WHERE countryId = @countryId AND currencyId = @currencyId AND ISNULL(isDeleted, 'N') = 'N' AND applyToAgent = 'Y')
		BEGIN
			SELECT spFlag FROM countryCurrency WITH(NOLOCK) WHERE countryId = @countryId AND currencyId = @currencyId AND ISNULL(isDeleted, 'N') = 'N' AND applyToAgent = 'Y'
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 'X' FROM agentCurrency WHERE currencyId = @currencyId AND agentId = @agentId AND ISNULL(isDeleted, 'N') = 'N')
			BEGIN
				SELECT spFlag FROM agentCurrency WHERE currencyId = @currencyId AND agentId = @agentId AND ISNULL(isDeleted, 'N') = 'N'
				RETURN
			END
			
			SET @oldAgent=@agentId
			SELECT @agentId = parentId FROM agentMaster WHERE agentId = @oldAgent
			IF EXISTS(SELECT 'X' FROM agentCurrency WHERE currencyId = @currencyId AND agentId = @agentId AND ISNULL(isDeleted, 'N') = 'N')
			BEGIN
				SELECT spFlag FROM agentCurrency WHERE currencyId = @currencyId AND agentId = @agentId AND ISNULL(isDeleted, 'N') = 'N'
				RETURN
			END
			
			SET @oldAgent=@agentId
			SELECT @agentId = parentId FROM agentMaster WHERE agentId=@oldAgent
			IF EXISTS(SELECT 'X' FROM agentCurrency WHERE currencyId = @currencyId AND agentId=@agentId AND ISNULL(isDeleted, 'N') = 'N')
			BEGIN
				SELECT spFlag FROM agentCurrency WHERE currencyId = @currencyId AND agentId = @agentId AND ISNULL(isDeleted, 'N') = 'N'
				RETURN
			END
			
			IF EXISTS(SELECT TOP 1 * FROM agentCurrency WHERE currencyId = @currencyId AND agentId = (SELECT dbo.FNAGetSuperAgent(@agentId)))
			BEGIN
				SELECT spFlag FROM agentCurrency WHERE currencyId = @currencyId AND agentId = (SELECT dbo.FNAGetSuperAgent(@agentId))
				RETURN		 
			END
			SELECT '' AS spFlag
		END
	end
	else if @flag='dl'---populating currency for agent
	begin  
			declare @agentType as int,@superAgentId as int,@originalAgentId as int
			select @agentId=agentId from applicationUsers where userId=@userId
			select @agentType=agentType from agentMaster where agentId=@agentId						  
			set @originalAgentId=@agentId
			
			if exists(select 'X' from agentCurrency where agentId=@agentId)
			begin
					select b.currencyId,b.currencyCode 
					from agentCurrency a inner join currencyMaster b on a.currencyId=b.currencyId
					where agentId=@agentId
					return;
			end
	
		
			set @oldAgent=@agentId
			
			select @agentId=parentId from agentMaster where agentId=@oldAgent
			
			if exists(select 'X' from agentCurrency where agentId=@agentId)
			begin
					select b.currencyId,b.currencyCode 
					from agentCurrency a inner join currencyMaster b on a.currencyId=b.currencyId
					where agentId=@agentId
					return;
			end	
			set @oldAgent=@agentId
			select @agentId=parentId from agentMaster where agentId=@oldAgent
			
			if exists(select 'X' from agentCurrency where agentId=@agentId)
			begin
					select b.currencyId,b.currencyCode 
					from agentCurrency a inner join currencyMaster b on a.currencyId=b.currencyId
					where agentId=@agentId
					return;
			end		
			select  @superAgentId  =dbo.FNAGetSuperAgent(@originalAgentId)
			
			
			-- exec	 [proc_agentUserLimit] @flag='dl',@agentId='7'

			if exists(select top 1 * from countryCurrency where countryId =(select agentCountryId from agentMaster where agentId= @superAgentId ))
			begin
				 select b.currencyId,b.currencyCode  from countryCurrency a inner join currencyMaster b on a.currencyId=b.currencyId
				  where countryId =(select agentCountryId from agentMaster where agentId= @superAgentId)
				  return;				 
			end
			
			select b.currencyId,b.currencyCode 
				from agentCurrency a inner join currencyMaster b on a.currencyId=b.currencyId
				where 1=2
		
	end
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM userLimit WITH(NOLOCK) WHERE userLimitId = @userLimitId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM userLimitMod WITH(NOLOCK) WHERE userLimitId = @userLimitId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userLimitId
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM userLimit WHERE userLimitId = @userLimitId AND approvedBy IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLimitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userLimitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @userLimitId
					RETURN
				END
				DELETE FROM userLimit WHERE userLimitId = @userLimitId				
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLimitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userLimitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @userLimitId
					RETURN
				END
				DELETE FROM userLimitMod WHERE @userLimitId = @userLimitId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @userLimitId
	END
	
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM userLimit WITH(NOLOCK) WHERE userLimitId = @userLimitId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM userLimitMod WITH(NOLOCK) WHERE userLimitId = @userLimitId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @userLimitId
			RETURN
		END
		BEGIN TRANSACTION		
			IF EXISTS (SELECT 'X' FROM userLimit WHERE approvedBy IS NULL AND userLimitId = @userLimitId)
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM userLimitMod WHERE userLimitId = @userLimitId
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE userLimit SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE userLimitId = @userLimitId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLimitId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLimitId, @oldValue OUTPUT				
				
				UPDATE main SET
					 main.userId						= mode.userId
					,main.currencyId					= mode.currencyId
					,main.payLimit						= mode.payLimit
					,main.sendLimit						= mode.sendLimit
					,main.isEnable						= mode.isEnable	            
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM userLimit main
				INNER JOIN userLimitMod mode ON mode.userLimitId= main.userLimitId
					WHERE mode.userLimitId = @userLimitId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLimitId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @userLimitId, @oldValue OUTPUT
				UPDATE userLimit SET
					 isDeleted		= 'Y'
					,isActive		= 'N'
					,modifiedDate	= GETDATE()
					,modifiedBy		= @user

				WHERE userLimitId = @userLimitId
				
			END
			
			DELETE FROM userLimitMod WHERE userLimitId = @userLimitId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @userLimitId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @userLimitId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @userLimitId
	END	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @userLimitId
END CATCH


GO
