USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scPayDetailHub]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_scPayDetailHub]
	 @flag                              VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@scPayDetailHubId                  VARCHAR(30)    = NULL
	,@scPayMasterHubId                  INT            = NULL
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
		 @ApprovedFunctionId = 20201330
		,@logIdentifier = 'scPayDetailHubId'
		,@logParamMain = 'scPayDetailHub'
		,@logParamMod = 'scPayDetailHubHistory'
		,@module = '20'
		,@tableAlias = 'Hub Custom Pay Commission Detail'
	
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM scPayDetailHub
				WHERE scPayMasterHubId = '+ CAST(ISNULL(@scPayMasterHubId, 0) AS VARCHAR) + '					
				AND scPayDetailHubId <> ' + CAST(ISNULL(@scPayDetailHubId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @scPayDetailHubId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @scPayDetailHubId
			RETURN	
		END
	END
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHubHistory WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scPayDetailHub (
				 scPayMasterHubId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scPayMasterHubId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @scPayDetailHubId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scPayDetailHubId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHubHistory WITH(NOLOCK)
				WHERE scPayDetailHubId = @scPayDetailHubId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scPayDetailHubHistory mode WITH(NOLOCK)
			INNER JOIN scPayDetailHub main WITH(NOLOCK) ON mode.scPayDetailHubId = main.scPayDetailHubId
			WHERE mode.scPayDetailHubId= @scPayDetailHubId and mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scPayDetailHub WITH(NOLOCK) WHERE scPayDetailHubId = @scPayDetailHubId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHubHistory WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHub WITH(NOLOCK)
			WHERE scPayDetailHubId = @scPayDetailHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHubHistory WITH(NOLOCK)
			WHERE scPayDetailHubId  = @scPayDetailHubId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayDetailHub WHERE approvedBy IS NULL AND scPayDetailHubId  = @scPayDetailHubId)			
			BEGIN				
				UPDATE scPayDetailHub SET
				 scPayMasterHubId = @scPayMasterHubId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE scPayDetailHubId = @scPayDetailHubId			
			END
			ELSE
			BEGIN
				DELETE FROM scPayDetailHubHistory WHERE scPayDetailHubId = @scPayDetailHubId AND approvedBy IS NULL
				INSERT INTO scPayDetailHubHistory(
					 scPayDetailHubId
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
					 @scPayDetailHubId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scPayDetailHubId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHubHistory WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHub WITH(NOLOCK)
			WHERE scPayDetailHubId = @scPayDetailHubId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHubHistory  WITH(NOLOCK)
			WHERE scPayDetailHubId = @scPayDetailHubId AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.',  @scPayDetailHubId
			RETURN
		END
		SELECT @scPayMasterHubId = scPayMasterHubId FROM scPayDetailHub WHERE scPayDetailHubId = @scPayDetailHubId
		IF EXISTS(SELECT 'X' FROM scPayDetailHub WITH(NOLOCK) WHERE scPayDetailHubId = @scPayDetailHubId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM scPayDetailHub WHERE scPayDetailHubId = @scPayDetailHubId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @scPayMasterHubId
		END
			INSERT INTO scPayDetailHubHistory(
					 scPayDetailHubId
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
					 scPayDetailHubId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM scPayDetailHub
				WHERE scPayDetailHubId = @scPayDetailHubId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scPayMasterHubId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'scPayDetailHubId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scPayDetailHubId = ISNULL(mode.scPayDetailHubId, main.scPayDetailHubId)
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
											(mode.scPayDetailHubId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scPayDetailHub main WITH(NOLOCK)
					LEFT JOIN scPayDetailHubHistory mode ON main.scPayDetailHubId = mode.scPayDetailHubId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.scPayMasterHubId = ' + CAST (@scPayMasterHubId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
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
			 scPayDetailHubId
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
			SELECT 'X' FROM scPayDetailHub WITH(NOLOCK)
			WHERE scPayDetailHubId = @scPayDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayDetailHub WITH(NOLOCK)
			WHERE scPayDetailHubId = @scPayDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayDetailHubId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scPayDetailHub WHERE approvedBy IS NULL AND scPayDetailHubId = @scPayDetailHubId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayDetailHubId
					RETURN
				END
			DELETE FROM scPayDetailHub WHERE scPayDetailHubId =  @scPayDetailHubId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayDetailHubId
					RETURN
				END
				DELETE FROM scPayDetailHubHistory WHERE scPayDetailHubId = @scPayDetailHubId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scPayDetailHubId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scPayDetailHub WITH(NOLOCK)
			WHERE scPayDetailHubId = @scPayDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayDetailHub WITH(NOLOCK)
			WHERE scPayDetailHubId = @scPayDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayDetailHub WHERE approvedBy IS NULL AND scPayDetailHubId = @scPayDetailHubId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scPayDetailHubHistory WHERE scPayDetailHubId = @scPayDetailHubId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scPayDetailHub SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scPayDetailHubId = @scPayDetailHubId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailHubId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scPayDetailHub main
				INNER JOIN scPayDetailHubHistory mode ON mode.scPayDetailHubId = main.scPayDetailHubId
				WHERE mode.scPayDetailHubId = @scPayDetailHubId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scPayDetailHub', 'scPayDetailHubId', @scPayDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailHubId, @oldValue OUTPUT
				UPDATE scPayDetailHub SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scPayDetailHubId = @scPayDetailHubId
			END
			
			UPDATE scPayDetailHubHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scPayDetailHubId = @scPayDetailHubId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailHubId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scPayDetailHubId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @scPayDetailHubId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scPayDetailHubId
END CATCH



GO
