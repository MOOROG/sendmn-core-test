USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentLimitMaster]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_agentLimitMaster]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@limitId							VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@currency                          INT				= NULL
	,@drBalLim							MONEY			= NULL
	,@topUpAmt							MONEY			= NULL
	
	,@agentName							VARCHAR(100)	= NULL
	,@agentCountry						VARCHAR(100)	= NULL
	,@agentGroup						INT				= NULL
	
	,@haschanged						CHAR(1)			= NULL
	,@parentId							INT				= NULL
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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20181230
		,@logIdentifier = 'limitId'
		,@logParamMain = 'agentLimitMaster'
		,@logParamMod = 'agentLimitMasterHistory'
		,@module = '20'
		,@tableAlias = 'Agent Credit Limit'
	
	IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 limitId			= ISNULL(mode.limitId, main.limitId)
					,agentId			= ISNULL(mode.agentId, main.agentId)
					,currency			= ISNULL(mode.currency, main.currency)
					,drBalLim			= ISNULL(mode.drBalLim, main.drBalLim)
					,topUpToday			= main.topUpToday
					,main.createdBy
					,main.createdDate
					,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
					,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.limitId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM agentLimitMaster main WITH(NOLOCK)
					LEFT JOIN agentLimitMasterHistory mode ON main.limitId = mode.limitId AND mode.approvedBy IS NULL
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
			PRINT (@table)
	
	END	
	
	IF @flag = 'i'
	BEGIN
		--IF (@limitAmt > @maxLimitAmt)
		--BEGIN
		--	EXEC proc_errorHandler 1, 'Limit Amount defined greater than Max Limit Amt', @limitId
		--	RETURN
		--END
		BEGIN TRANSACTION
			INSERT INTO agentLimitMaster (
				 agentId
				,currency
				,drBalLim
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@currency
				,@drBalLim
				,@user
				,GETDATE()
				
				
			SET @limitId = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @limitId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentLimitMasterHistory WITH(NOLOCK)
				WHERE limitId = @limitId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM agentLimitMasterHistory mode WITH(NOLOCK)
			INNER JOIN agentLimitMaster main WITH(NOLOCK) ON mode.limitId = main.limitId
			WHERE mode.limitId= @limitId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				*
			FROM agentLimitMaster WITH(NOLOCK) WHERE limitId = @limitId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentLimitMaster WITH(NOLOCK)
			WHERE limitId = @limitId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet1.', @limitId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentLimitMasterHistory WITH(NOLOCK)
			WHERE limitId  = @limitId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet2.', @limitId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM agentLimitMaster WHERE approvedBy IS NULL AND limitId  = @limitId)			
			BEGIN				
				UPDATE agentLimitMaster SET
					 agentId		= @agentId
					,currency		= @currency
					,drBalLim		= @drBalLim
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()
				WHERE limitId = @limitId			
			END
			ELSE
			BEGIN
				DELETE FROM agentLimitMasterHistory WHERE limitId = @limitId AND approvedBy IS NULL
				INSERT INTO agentLimitMasterHistory(
					 limitId
					,agentId
					,currency
					,drBalLim
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @limitId
					,@agentId
					,@currency
					,@drBalLim
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @limitId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentLimitMaster WITH(NOLOCK)
			WHERE limitId = @limitId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @limitId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentLimitMasterHistory  WITH(NOLOCK)
			WHERE limitId = @limitId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @limitId
			RETURN
		END
		SELECT @agentId = agentId FROM agentLimitMaster WHERE limitId = @limitId
		IF EXISTS(SELECT 'X' FROM agentLimitMaster WITH(NOLOCK) WHERE limitId = @limitId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM agentLimitMaster WHERE limitId = @limitId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
			RETURN
		END
			INSERT INTO agentLimitMasterHistory(
					 limitId
					,agentId
					,currency
					,drBalLim
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 limitId
					,agentId
					,currency
					,drBalLim
					,@user
					,GETDATE()					
					,'D'
				FROM agentLimitMaster
				WHERE limitId = @limitId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
	END


	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'agentName'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '( 
				SELECT
					 main.limitId
					,am.agentId
					,am.agentName
					,am.agentCountry
					,am.agentGrp
					,currency = ISNULL(cm.currencyCode, ''N/A'')
					,drBalLim = ISNULL(CAST(main.drBalLim AS VARCHAR), ''N/A'')
					,main.createdBy
					,main.createdDate
					,main.modifiedBy							
					,haschanged
				FROM ( 
						SELECT * FROM agentMaster WHERE parentId = ' + CAST(@parentId AS VARCHAR) + '
					)am 
				LEFT JOIN ' + @table + ' main ON am.agentId = main.agentId
				LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyId
				) x
	
				'
					
		SET @sql_filter = ''
		
		IF @haschanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
			
		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentCountry, '''') = ''' + @agentCountry + ''''
		
		IF @agentGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentGrp, '''') = ' + CAST(@agentGroup AS VARCHAR)
		
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''
			
		SET @select_field_list ='
			 limitId
			,agentId
			,agentName
			,agentCountry
			,agentGrp
			,currency
			,drBalLim
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
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentLimitMaster WITH(NOLOCK)
			WHERE limitId = @limitId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM agentLimitMaster WITH(NOLOCK)
			WHERE limitId = @limitId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @limitId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM agentLimitMaster WHERE approvedBy IS NULL AND limitId = @limitId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @limitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @limitId
					RETURN
				END
			DELETE FROM agentLimitMaster WHERE limitId =  @limitId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @limitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @limitId
					RETURN
				END
				DELETE FROM agentLimitMasterHistory WHERE limitId = @limitId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @limitId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM agentLimitMaster WITH(NOLOCK)
			WHERE limitId = @limitId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM agentLimitMaster WITH(NOLOCK)
			WHERE limitId = @limitId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @limitId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM agentLimitMaster WHERE approvedBy IS NULL AND limitId = @limitId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM agentLimitMasterHistory WHERE limitId = @limitId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE agentLimitMaster SET
					 isActive		= 'Y'
					,approvedBy		= @user
					,approvedDate	= GETDATE()
				WHERE limitId = @limitId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @newValue OUTPUT

			--END
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				UPDATE main SET
					 main.agentId		= mode.agentId
					,main.currency		= mode.currency
					,main.drBalLim		= mode.drBalLim
					,main.modifiedDate	= GETDATE()
					,main.modifiedBy	= @user
				FROM agentLimitMaster main
				INNER JOIN agentLimitMasterHistory mode ON mode.limitId = main.limitId
				WHERE mode.limitId = @limitId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'agentLimitMaster', 'limitId', @limitId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				UPDATE agentLimitMaster SET
					 isDeleted		= 'Y'
					,modifiedDate	= GETDATE()
					,modifiedBy		= @user					
				WHERE limitId = @limitId
			END
			
			UPDATE agentLimitMasterHistory SET
				 approvedBy			= @user
				,approvedDate		= GETDATE()
			WHERE limitId = @limitId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @limitId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @limitId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @limitId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @limitId
END CATCH




GO
