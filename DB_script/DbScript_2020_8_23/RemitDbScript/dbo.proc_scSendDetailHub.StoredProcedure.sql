USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scSendDetailHub]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_scSendDetailHub]
	 @flag                              VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@scSendDetailHubId                 VARCHAR(30)    = NULL
	,@scSendMasterHubId                    INT            = NULL
	,@fromAmt                           MONEY          = NULL
	,@toAmt                             MONEY          = NULL
	,@pcnt                              FLOAT          = NULL
	,@minAmt                            MONEY          = NULL
	,@maxAmt                            MONEY          = NULL
	,@sortBy                            VARCHAR(50)    = NULL
	,@sortOrder                         VARCHAR(5)     = NULL
	,@pageSize                          INT            = NULL
	,@pageNumber                        INT            = NULL


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
		 @ApprovedFunctionId = 20131130
		,@logIdentifier = 'scSendDetailHubId'
		,@logParamMain = 'scSendDetailHub'
		,@logParamMod = 'scSendDetailHubHistory'
		,@module = '20'
		,@tableAlias = 'Hub Custom Send Commission Detail'
	
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM scSendDetailHub
				WHERE scSendMasterHubId = '+ CAST(ISNULL(@scSendMasterHubId, 0) AS VARCHAR) + '					
				AND scSendDetailHubId <> ' + CAST(ISNULL(@scSendDetailHubId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @scSendDetailHubId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @scSendDetailHubId
			RETURN	
		END
	END
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHub WITH(NOLOCK)
			WHERE scSendMasterHubId = @scSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHubHistory WITH(NOLOCK)
			WHERE scSendMasterHubId = @scSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scSendDetailHub (
				 scSendMasterHubId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scSendMasterHubId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @scSendDetailHubId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scSendDetailHubId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHubHistory WITH(NOLOCK)
				WHERE scSendDetailHubId = @scSendDetailHubId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scSendDetailHubHistory mode WITH(NOLOCK)
			INNER JOIN scSendDetailHub main WITH(NOLOCK) ON mode.scSendDetailHubId = main.scSendDetailHubId
			WHERE mode.scSendDetailHubId= @scSendDetailHubId and mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scSendDetailHub WITH(NOLOCK) WHERE scSendDetailHubId = @scSendDetailHubId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHub WITH(NOLOCK)
			WHERE scSendMasterHubId = @scSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHubHistory WITH(NOLOCK)
			WHERE scSendMasterHubId = @scSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHub WITH(NOLOCK)
			WHERE scSendDetailHubId = @scSendDetailHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHubHistory WITH(NOLOCK)
			WHERE scSendDetailHubId  = @scSendDetailHubId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scSendDetailHub WHERE approvedBy IS NULL AND scSendDetailHubId  = @scSendDetailHubId)			
			BEGIN				
				UPDATE scSendDetailHub SET
				 scSendMasterHubId = @scSendMasterHubId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE scSendDetailHubId = @scSendDetailHubId			
			END
			ELSE
			BEGIN
				DELETE FROM scSendDetailHubHistory WHERE scSendDetailHubId = @scSendDetailHubId AND approvedBy IS NULL
				INSERT INTO scSendDetailHubHistory(
					 scSendDetailHubId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @scSendDetailHubId
					,@fromAmt
					,@toAmt
					,@pcnt
					,@minAmt
					,@maxAmt
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scSendDetailHubId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHub WITH(NOLOCK)
			WHERE scSendMasterHubId = @scSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHubHistory WITH(NOLOCK)
			WHERE scSendMasterHubId = @scSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHub WITH(NOLOCK)
			WHERE scSendDetailHubId = @scSendDetailHubId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHubHistory  WITH(NOLOCK)
			WHERE scSendDetailHubId = @scSendDetailHubId AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.',  @scSendDetailHubId
			RETURN
		END
		SELECT @scSendMasterHubId = scSendMasterHubId FROM scSendDetailHub WHERE scSendDetailHubId = @scSendDetailHubId
		IF EXISTS(SELECT 'X' FROM scSendDetailHub WITH(NOLOCK) WHERE scSendDetailHubId = @scSendDetailHubId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM scSendDetailHub WHERE scSendDetailHubId = @scSendDetailHubId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @scSendMasterHubId
			RETURN
		END
		
			INSERT INTO scSendDetailHubHistory(
					 scSendDetailHubId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 scSendDetailHubId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM scSendDetailHub
				WHERE scSendDetailHubId = @scSendDetailHubId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scSendMasterHubId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'scSendDetailHubId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scSendDetailHubId = ISNULL(mode.scSendDetailHubId, main.scSendDetailHubId)
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END	
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.scSendDetailHubId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scSendDetailHub main WITH(NOLOCK)
					LEFT JOIN scSendDetailHubHistory mode ON main.scSendDetailHubId = mode.scSendDetailHubId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.scSendMasterHubId = ' + CAST (@scSendMasterHubId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 scSendDetailHubId
			,fromAmt
			,toAmt
			,pcnt
			,minAmt
			,maxAmt
			,createdBy
			,createdDate
			,modifiedBy
			,hasChanged 
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
			SELECT 'X' FROM scSendDetailHub WITH(NOLOCK)
			WHERE scSendDetailHubId = @scSendDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scSendDetailHub WITH(NOLOCK)
			WHERE scSendDetailHubId = @scSendDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scSendDetailHubId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scSendDetailHub WHERE approvedBy IS NULL AND scSendDetailHubId = @scSendDetailHubId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scSendDetailHubId
					RETURN
				END
			DELETE FROM scSendDetailHub WHERE scSendDetailHubId =  @scSendDetailHubId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scSendDetailHubId
					RETURN
				END
				DELETE FROM scSendDetailHubHistory WHERE scSendDetailHubId = @scSendDetailHubId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scSendDetailHubId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scSendDetailHub WITH(NOLOCK)
			WHERE scSendDetailHubId = @scSendDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scSendDetailHub WITH(NOLOCK)
			WHERE scSendDetailHubId = @scSendDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scSendDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scSendDetailHub WHERE approvedBy IS NULL AND scSendDetailHubId = @scSendDetailHubId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scSendDetailHubHistory WHERE scSendDetailHubId = @scSendDetailHubId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scSendDetailHub SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scSendDetailHubId = @scSendDetailHubId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailHubId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scSendDetailHub main
				INNER JOIN scSendDetailHubHistory mode ON mode.scSendDetailHubId = main.scSendDetailHubId
				WHERE mode.scSendDetailHubId = @scSendDetailHubId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scSendDetailHub', 'scSendDetailHubId', @scSendDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailHubId, @oldValue OUTPUT
				UPDATE scSendDetailHub SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scSendDetailHubId = @scSendDetailHubId
			END
			
			UPDATE scSendDetailHubHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scSendDetailHubId = @scSendDetailHubId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailHubId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scSendDetailHubId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @scSendDetailHubId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scSendDetailHubId
END CATCH



GO
