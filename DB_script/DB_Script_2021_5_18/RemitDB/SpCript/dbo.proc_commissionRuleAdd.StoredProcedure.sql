USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_commissionRuleAdd]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*


*/

CREATE proc [dbo].[proc_commissionRuleAdd]
      @flag								VARCHAR(50)    = NULL
     ,@user								VARCHAR(30)    = NULL
     ,@id								INT			   = NULL
     ,@packageId                        INT            = NULL
     ,@ruleId							VARCHAR(100)	= NULL
     ,@ruleType							VARCHAR(10)		= NULL
     ,@code								VARCHAR(100)	= NULL
     ,@sortBy                           VARCHAR(50)    = NULL
	 ,@sortOrder                        VARCHAR(5)     = NULL
	 ,@pageSize                         INT            = NULL
	 ,@pageNumber                       INT            = NULL


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
		,@rulesId			VARCHAR(MAX)

	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
	
	SELECT
		 @logIdentifier = 'packageId'
		,@logParamMain = 'commissionPackage'
		,@logParamMod = 'commissionPackageHistory'
		,@module = '20'
		,@tableAlias = 'Commission Package'
		
	DECLARE @commissionRule TABLE(ruleId INT)
	DECLARE @commissionRuleNew TABLE(ruleId INT)
	DECLARE @found INT = 0
	DECLARE @ssAgent INT, @rsAgent INT,@sCountry INT, @rCountry INT, 
			@sAgent INT, @sBranch INT, @sState INT,	@sGroup INT, @rAgent INT, @rBranch INT, 
			@rState INT, @rGroup INT, @tranType INT
	
     IF @flag = 'i'
     BEGIN		
		SET @rulesId=@ruleId
		SET @ruleId=''
		        
		IF @ruleType='ds'
		BEGIN	
			--New Commission Rule Table From New PackageId
			INSERT @commissionRuleNew
			SELECT  value FROM dbo.Split(',',@rulesId)
			
			--Old Commission Rule Table From Old PackageId assigned to Group
			INSERT @commissionRule
			SELECT DISTINCT ruleId FROM commissionPackage 
			WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
			AND ruleType= 'ds'
				
			WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
			BEGIN
				SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
				SELECT 
					 @sAgent	= sAgent
					,@sBranch	= sBranch
					,@sState	= sState
					,@sGroup	= sGroup
					,@rAgent	= rAgent
					,@rBranch	= rBranch
					,@rState	= rState
					,@rGroup	= rGroup
					,@tranType	= tranType
				FROM scMaster WITH(NOLOCK) WHERE scMasterId = @ruleId
				
				IF EXISTS(SELECT 'X' FROM scMaster WHERE
							ISNULL(sAgent, 0)	= ISNULL(@sAgent, 0)
						AND	ISNULL(sBranch, 0)	= ISNULL(@sBranch, 0)
						AND ISNULL(sState, 0)	= ISNULL(@sState, 0)
						AND ISNULL(sGroup, 0)	= ISNULL(@sGroup, 0)
						AND ISNULL(rAgent, 0)	= ISNULL(@rAgent, 0)
						AND ISNULL(rBranch, 0)	= ISNULL(@rBranch, 0)
						AND ISNULL(rState, 0)	= ISNULL(@rState, 0)
						AND ISNULL(rGroup, 0)	= ISNULL(@rGroup, 0)
						AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) 
						AND ISNULL(isDeleted, 'N') = 'N'
						AND scMasterId IN (SELECT ruleId FROM @commissionRule))
				BEGIN
					SET @found = 1
				END
				DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
			END
			IF @found = 1
			BEGIN
				EXEC proc_errorHandler 1, 'This commission rule criteria which has already been defined in this package!', NULL
				RETURN
			END
		END	
		
		IF @ruleType='sc'
		BEGIN	
			--New Commission Rule Table From New PackageId
			INSERT @commissionRuleNew
			SELECT  value FROM dbo.Split(',',@rulesId)
			
			--Old Commission Rule Table From Old PackageId assigned to Group
			INSERT @commissionRule
			SELECT DISTINCT ruleId FROM commissionPackage 
			WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
			AND ruleType= 'sc'
				
			WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
			BEGIN
				SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
				SELECT 
					 @sCountry  = sCountry
					,@rCountry	= rCountry
					,@ssAgent	= ssAgent
					,@rsAgent	= rsAgent
					,@sAgent	= sAgent
					,@sBranch	= sBranch
					,@sState	= State
					,@sGroup	= agentGroup
					,@rAgent	= rAgent
					,@rBranch	= rBranch
					,@rState	= rState
					,@rGroup	= rAgentGroup
					,@tranType	= tranType
				FROM sscMaster WITH(NOLOCK) WHERE sscMasterId = @ruleId
				
				IF EXISTS(SELECT 'X' FROM sscMaster WHERE
							ISNULL(sAgent, 0)		= ISNULL(@sAgent, 0)
						AND	ISNULL(sBranch, 0)		= ISNULL(@sBranch, 0)
						AND ISNULL(State, 0)		= ISNULL(@sState, 0)
						AND ISNULL(agentGroup, 0)	= ISNULL(@sGroup, 0)
						AND ISNULL(rAgent, 0)		= ISNULL(@rAgent, 0)
						AND ISNULL(rBranch, 0)		= ISNULL(@rBranch, 0)
						AND ISNULL(rState, 0)		= ISNULL(@rState, 0)
						AND ISNULL(rAgentGroup, 0)	= ISNULL(@rGroup, 0)
						AND ISNULL(tranType, 0)		= ISNULL(@tranType, 0)							
						AND ISNULL(sCountry, 0)		= ISNULL(@sCountry, 0)
						AND ISNULL(rCountry, 0)		= ISNULL(@rCountry, 0)							
						AND ISNULL(ssAgent, 0)		= ISNULL(@ssAgent, 0)
						AND ISNULL(rsAgent, 0)		= ISNULL(@rsAgent, 0) 							
						AND ISNULL(isDeleted, 'N')	= 'N'
						AND sscMasterId IN (SELECT ruleId FROM @commissionRule))
				BEGIN
					SET @found = 1
				END
				DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
			END
			IF @found = 1
			BEGIN
				EXEC proc_errorHandler 1, 'This service charge setup criteria which has already been defined in this package!', NULL
				RETURN
			END
		END	
				
		IF @ruleType='cp'
		BEGIN	
			--New Commission Rule Table From New PackageId
			INSERT @commissionRuleNew
			SELECT  value FROM dbo.Split(',',@rulesId)
			
			--Old Commission Rule Table From Old PackageId assigned to Group
			INSERT @commissionRule
			SELECT DISTINCT ruleId FROM commissionPackage 
			WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
			AND ruleType= 'cp'
				
			WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
			BEGIN
				SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
				SELECT 
					 @sCountry  = sCountry
					,@rCountry	= rCountry
					,@ssAgent	= ssAgent
					,@rsAgent	= rsAgent
					,@sAgent	= sAgent
					,@sBranch	= sBranch
					,@sState	= State
					,@sGroup	= agentGroup
					,@rAgent	= rAgent
					,@rBranch	= rBranch
					,@rState	= rState
					,@rGroup	= rAgentGroup
					,@tranType	= tranType
				FROM scPayMaster WITH(NOLOCK) WHERE scPayMasterId = @ruleId

				IF EXISTS(SELECT 'X' FROM scPayMaster WHERE
							ISNULL(sAgent, 0)	= ISNULL(@sAgent, 0)
						AND	ISNULL(sBranch, 0)	= ISNULL(@sBranch, 0)
						AND ISNULL(State, 0)	= ISNULL(@sState, 0)
						AND ISNULL(agentGroup, 0)	= ISNULL(@sGroup, 0)
						AND ISNULL(rAgent, 0)	= ISNULL(@rAgent, 0)
						AND ISNULL(rBranch, 0)	= ISNULL(@rBranch, 0)
						AND ISNULL(rState, 0)	= ISNULL(@rState, 0)
						AND ISNULL(rAgentGroup, 0)	= ISNULL(@rGroup, 0)
						AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) 							
						AND ISNULL(sCountry, 0)	= ISNULL(@sCountry, 0)
						AND ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) 							
						AND ISNULL(ssAgent, 0)	= ISNULL(@ssAgent, 0)
						AND ISNULL(rsAgent, 0) = ISNULL(@rsAgent, 0) 							
						AND ISNULL(isDeleted, 'N') = 'N'
						AND scPayMasterId IN (SELECT ruleId FROM @commissionRule))
				BEGIN
					SET @found = 1
				END
				DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
			END
			IF @found = 1
			BEGIN
				EXEC proc_errorHandler 1, 'This pay commission setup criteria which has already been defined in this package!', NULL
				RETURN
			END
		END			
		
		IF @ruleType='cs'
		BEGIN	
			--New Commission Rule Table From New PackageId
			INSERT @commissionRuleNew
			SELECT  value FROM dbo.Split(',',@rulesId)
			
			--Old Commission Rule Table From Old PackageId assigned to Group
			INSERT @commissionRule
			SELECT DISTINCT ruleId FROM commissionPackage 
			WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
			AND ruleType= 'cs'
				
			WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
			BEGIN
				SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
				SELECT 
					 @sCountry  = sCountry
					,@rCountry	= rCountry
					,@ssAgent	= ssAgent
					,@rsAgent	= rsAgent
					,@sAgent	= sAgent
					,@sBranch	= sBranch
					,@sState	= State
					,@sGroup	= agentGroup
					,@rAgent	= rAgent
					,@rBranch	= rBranch
					,@rState	= rState
					,@rGroup	= rAgentGroup
					,@tranType	= tranType
				FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @ruleId

				IF EXISTS(SELECT 'X' FROM scSendMaster WHERE
							ISNULL(sAgent, 0)	= ISNULL(@sAgent, 0)
						AND	ISNULL(sBranch, 0)	= ISNULL(@sBranch, 0)
						AND ISNULL(State, 0)	= ISNULL(@sState, 0)
						AND ISNULL(agentGroup, 0)	= ISNULL(@sGroup, 0)
						AND ISNULL(rAgent, 0)	= ISNULL(@rAgent, 0)
						AND ISNULL(rBranch, 0)	= ISNULL(@rBranch, 0)
						AND ISNULL(rState, 0)	= ISNULL(@rState, 0)
						AND ISNULL(rAgentGroup, 0)	= ISNULL(@rGroup, 0)
						AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) 							
						AND ISNULL(sCountry, 0)	= ISNULL(@sCountry, 0)
						AND ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) 							
						AND ISNULL(ssAgent, 0)	= ISNULL(@ssAgent, 0)
						AND ISNULL(rsAgent, 0) = ISNULL(@rsAgent, 0) 							
						AND ISNULL(isDeleted, 'N') = 'N'
						AND scSendMasterId IN (SELECT ruleId FROM @commissionRule))
				BEGIN
					SET @found = 1
				END
				DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
			END
			IF @found = 1
			BEGIN
				EXEC proc_errorHandler 1, 'This send commission setup criteria which has already been defined in this package!', NULL
				RETURN
			END
		END	
			
		BEGIN TRANSACTION	
			INSERT INTO commissionPackageHistory(packageId, ruleId, ruleType, modType, createdBy, createdDate)
			SELECT @packageId,value,@ruleType,'I',@user,GETDATE() FROM dbo.Split(',',@rulesId)
			
			INSERT INTO commissionPackage
				(packageId,ruleId,ruleType,isActive,createdBy,createdDate)
			SELECT @packageId,value,@ruleType,NULL,@user,GETDATE() FROM dbo.Split(',',@rulesId)
			
			UPDATE mode SET
				 mode.id = main.id
			FROM commissionPackageHistory mode
			INNER JOIN commissionPackage main ON mode.packageId = main.packageId AND mode.ruleId = main.ruleId AND mode.ruleType = main.ruleType
			WHERE mode.approvedBy IS NULL
			
            INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @Id, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @id
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		
		
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
     END
	
	ELSE IF @flag = 'SC'
	BEGIN 
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
	
		
	SET @table = '(		
						SELECT 
							sscMasterId
							,code = ''<a href="CommissionView.aspx?ruleId= ''+ cast(sscMasterId as varchar) + ''&ruleType=sc">''+ code + ''</a>''
							,description 
						FROM sscMaster WITH (NOLOCK)
						WHERE ISNULL(isDeleted,''N'')<>''Y'' 
						AND ISNULL(isActive,''N'') = ''Y''
						AND sscMasterId NOT IN 
						(
							SELECT ruleId FROM commissionPackage
							WHERE ruleType = ''SC'' AND ISNULL(isDeleted,''N'')<>''Y'' 
							--AND ISNULL(isActive,''N'') = ''Y''
							AND packageId = '''+CAST(@packageId AS VARCHAR)+'''
						)
					

			 '	
					
		SET @sqlFilter = ''	
		
		IF @code IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND code LIKE ''' + @code + '%'''	
		
		SET @selectFieldList = '
						   sscMasterId
						  ,code
						  ,description 
						'
			
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

	ELSE IF @flag = 'CP'
	BEGIN 
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
		
	SET @table = '(		
						SELECT 
							scPayMasterId
							,code = ''<a href="CommissionView.aspx?ruleId= ''+ cast(scPayMasterId as varchar) + ''&ruleType=cp">''+ code + ''</a>''
							,description 
						FROM scPayMaster  WITH (NOLOCK)
						WHERE ISNULL(isDeleted,''N'')<>''Y''
						--AND ISNULL(isActive,''N'') = ''Y''
						AND scPayMasterId NOT IN 
						(
							SELECT ruleId FROM commissionPackage
							WHERE ruleType = ''CP'' AND ISNULL(isDeleted,''N'')<>''Y'' 
							AND ISNULL(isActive,''N'') = ''Y'' 
							AND packageId = '''+CAST(@packageId AS VARCHAR)+'''
						)
				
			 '	
					
		SET @sqlFilter = ''	
		
		IF @code IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND code LIKE ''' + @code + '%'''	
		
		SET @selectFieldList = '
						   scPayMasterId
						  ,code
						  ,description 
						'
			
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
   
   	ELSE IF @flag = 'CS'
	BEGIN 
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
		
	SET @table = '(		
						SELECT 
							scSendMasterId
							,code = ''<a href="CommissionView.aspx?ruleId= ''+ cast(scSendMasterId as varchar) + ''&ruleType=cs">''+ code + ''</a>''
							,description 
						FROM scSendMaster  WITH (NOLOCK)
						WHERE ISNULL(isDeleted,''N'')<>''Y''
						--AND ISNULL(isActive,''N'') = ''Y''
						AND scSendMasterId NOT IN 
						(
							SELECT ruleId FROM commissionPackage
							WHERE ruleType = ''CS'' AND ISNULL(isDeleted,''N'')<>''Y'' 
							AND ISNULL(isActive,''N'') = ''Y'' 
							AND packageId = '''+CAST(@packageId AS VARCHAR)+'''
						)
				
			 '	
					
		SET @sqlFilter = ''	
		
		IF @code IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND code LIKE ''' + @code + '%'''	
		
		SET @selectFieldList = '
						   scSendMasterId
						  ,code
						  ,description 
						'
			
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

	ELSE IF @flag = 'DS'
	BEGIN 
		IF @sortBy IS NULL  
			SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL  
			SET @sortOrder = 'DESC'					
		
	SET @table = '(		
						SELECT 
							scMasterId
							,code = ''<a href="CommissionView.aspx?ruleId= ''+ cast(scMasterId as varchar) + ''&ruleType=ds">''+ code + ''</a>''
							,description 
						FROM scMaster  WITH (NOLOCK)
						WHERE ISNULL(isDeleted,''N'')<>''Y''
						AND ISNULL(isActive,''N'') = ''Y''
						AND scMasterId NOT IN 
						(
							SELECT ruleId FROM commissionPackage
							WHERE ruleType = ''DS'' 
							AND ISNULL(isDeleted,''N'')<>''Y'' 
							--AND ISNULL(isActive,''N'') = ''Y'' 
							AND packageId = '''+CAST(@packageId AS VARCHAR)+'''
						)
				
			 '	
					
		SET @sqlFilter = ''	
		
		IF @code IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND code LIKE ''' + @code + '%'''	
		
		SET @selectFieldList = '
						   scMasterId
						  ,code
						  ,description 
						'
			
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
   
	---------PRINT @table
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM commissionPackage WITH(NOLOCK)
			WHERE packageId = @packageId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM commissionPackage WITH(NOLOCK)
			WHERE packageId = @packageId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @packageId
			RETURN
		END
		DECLARE @ruleTable TABLE(id INT)
		DECLARE @modType2 VARCHAR(20)
		INSERT @ruleTable
		SELECT id FROM commissionPackageHistory WHERE packageId = @packageId AND approvedBy IS NULL
		BEGIN TRANSACTION
		WHILE EXISTS(SELECT 'X' FROM @ruleTable)
		BEGIN
			SELECT TOP 1 @id = id FROM @ruleTable
			SELECT @modType = modType FROM commissionPackageHistory WHERE id = @id
			IF @modType = 'I'
			BEGIN --New record
				SET @modType2 = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @id, @newValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType2, @tableAlias, @id, @user, @oldValue, @newValue
					
				DELETE FROM commissionPackage WHERE packageId =  @packageId AND approvedBy IS NULL
				DELETE FROM commissionPackageHistory WHERE packageId = @packageId AND approvedBy IS NULL
				
			END
			ELSE IF @modType = 'D'
			BEGIN
				SET @modType2 = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @id, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType2, @tableAlias, @id, @user, @oldValue, @newValue

				DELETE FROM commissionPackageHistory WHERE packageId = @packageId AND approvedBy IS NULL
			END
			DELETE FROM @ruleTable WHERE id = @id
		END
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @packageId
			RETURN
		END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @packageId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM commissionPackage WITH(NOLOCK)
			WHERE packageId = @packageId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM commissionPackage WITH(NOLOCK)
			WHERE packageId = @packageId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @packageId
			RETURN
		END
		BEGIN TRANSACTION
			DECLARE @newCriteriaValue VARCHAR(MAX)
			INSERT @ruleTable
			SELECT id FROM commissionPackageHistory WHERE packageId = @packageId AND approvedBy IS NULL
			WHILE EXISTS(SELECT 'X' FROM @ruleTable)
			BEGIN
				SELECT TOP 1 @id = id FROM @ruleTable
				SELECT @modType = modType FROM commissionPackageHistory WHERE id = @id
				IF @modType = 'I'
				BEGIN --New record
					UPDATE commissionPackage SET
						 isActive = 'Y'
						,approvedBy = @user
						,approvedDate= GETDATE()
					WHERE id = @id
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @id, @newValue OUTPUT	
				END
				ELSE IF @modType = 'D'
				BEGIN
					EXEC [dbo].proc_GetColumnToRow @logParamMain, @logIdentifier, @id, @oldValue OUTPUT
					UPDATE commissionPackage SET
						 isDeleted		= 'Y'
						,modifiedBy		= @user
						,modifiedDate	= GETDATE()
					WHERE id = @id
				END
				DELETE FROM @ruleTable WHERE id = @id
				
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @id, @user, @oldValue, @newValue
			END
			UPDATE commissionPackage SET
				 isActive		= 'Y'
				,approvedBy		= @user
				,approvedDate	= GETDATE()
			WHERE packageId = @packageId AND approvedBy IS NULL
			
			UPDATE commissionPackageHistory SET
				 approvedBy		= @user
				,approvedDate	= GETDATE()
			WHERE packageId = @packageId AND approvedBy IS NULL
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @packageId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @packageId
	END 
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH




GO
