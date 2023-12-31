USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scPayDetailSA]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_scPayDetailSA]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@scPayDetailSAId                   VARCHAR(30)		= NULL
	,@scPayMasterSAId                   INT				= NULL
	,@oldScPayMasterSAId				INT				= NULL
	,@fromAmt                           MONEY			= NULL
	,@toAmt                             MONEY			= NULL
	,@pcnt                              FLOAT			= NULL
	,@minAmt                            MONEY			= NULL
	,@maxAmt                            MONEY			= NULL
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
		 @ApprovedFunctionId = 20131430
		,@logIdentifier = 'scPayDetailSAId'
		,@logParamMain = 'scPayDetailSA'
		,@logParamMod = 'scPayDetailSAHistory'
		,@module = '20'
		,@tableAlias = 'Super Agent Pay Commission Detail'
	
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM scPayDetailSA
				WHERE scPayMasterSAId = '+ CAST(ISNULL(@scPayMasterSAId, 0) AS VARCHAR) + '					
				AND scPayDetailSAId <> ' + CAST(ISNULL(@scPayDetailSAId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @scPayDetailSAId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @scPayDetailSAId
			RETURN	
		END
	END
	
	ELSE IF @flag = 'cs'					--Copy Slab
	BEGIN
		IF EXISTS(SELECT 'X' FROM scPayDetailSA WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND scPayMasterSAId = @scPayMasterSAId)
		BEGIN
			EXEC proc_errorHandler 1, 'Amount Slab already exists. Copy process terminated', @scPayMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scPayDetailSA(
				 scPayMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scPayMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,@user
				,GETDATE()
			FROM scPayDetailSA WITH(NOLOCK) WHERE scPayMasterSAId = @oldScPayMasterSAId	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Copy has been done successfully.', @scPayMasterSAId	
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterSA WITH(NOLOCK)
			WHERE scPayMasterSAId = @scPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterSAHistory WITH(NOLOCK)
			WHERE scPayMasterSAId = @scPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scPayDetailSA (
				 scPayMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scPayMasterSAId
				,@fromAmt
				,@toAmt
				,ISNULL(@pcnt, 0)
				,ISNULL(@minAmt, 0)
				,ISNULL(@maxAmt, 0)
				,@user
				,GETDATE()
				
				
			SET @scPayDetailSAId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scPayDetailSAId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayDetailSAHistory WITH(NOLOCK)
				WHERE scPayDetailSAId = @scPayDetailSAId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scPayDetailSAHistory mode WITH(NOLOCK)
			INNER JOIN scPayDetailSA main WITH(NOLOCK) ON mode.scPayDetailSAId = main.scPayDetailSAId
			WHERE mode.scPayDetailSAId= @scPayDetailSAId and mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scPayDetailSA WITH(NOLOCK) WHERE scPayDetailSAId = @scPayDetailSAId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterSA WITH(NOLOCK)
			WHERE scPayMasterSAId = @scPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterSAHistory WITH(NOLOCK)
			WHERE scPayMasterSAId = @scPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailSA WITH(NOLOCK)
			WHERE scPayDetailSAId = @scPayDetailSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailSAHistory WITH(NOLOCK)
			WHERE scPayDetailSAId  = @scPayDetailSAId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayDetailSA WHERE approvedBy IS NULL AND scPayDetailSAId  = @scPayDetailSAId)			
			BEGIN				
				UPDATE scPayDetailSA SET
				 scPayMasterSAId = @scPayMasterSAId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE scPayDetailSAId = @scPayDetailSAId			
			END
			ELSE
			BEGIN
				DELETE FROM scPayDetailSAHistory WHERE scPayDetailSAId = @scPayDetailSAId AND approvedBy IS NULL
				INSERT INTO scPayDetailSAHistory(
					 scPayDetailSAId
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
					 @scPayDetailSAId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scPayDetailSAId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterSA WITH(NOLOCK)
			WHERE scPayMasterSAId = @scPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterSAHistory WITH(NOLOCK)
			WHERE scPayMasterSAId = @scPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailSA WITH(NOLOCK)
			WHERE scPayDetailSAId = @scPayDetailSAId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailSAHistory  WITH(NOLOCK)
			WHERE scPayDetailSAId = @scPayDetailSAId AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.',  @scPayDetailSAId
			RETURN
		END
		SELECT @scPayMasterSAId = scPayMasterSAId FROM scPayDetailSA WHERE scPayDetailSAId = @scPayDetailSAId
		IF EXISTS(SELECT 'X' FROM scPayDetailSA WITH(NOLOCK) WHERE scPayDetailSAId = @scPayDetailSAId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM scPayDetailSA WHERE scPayDetailSAId = @scPayDetailSAId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @scPayMasterSAId
		END
			INSERT INTO scPayDetailSAHistory(
					 scPayDetailSAId
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
					 scPayDetailSAId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM scPayDetailSA
				WHERE scPayDetailSAId = @scPayDetailSAId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scPayMasterSAId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'scPayDetailSAId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scPayDetailSAId = ISNULL(mode.scPayDetailSAId, main.scPayDetailSAId)
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
											(mode.scPayDetailSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scPayDetailSA main WITH(NOLOCK)
					LEFT JOIN scPayDetailSAHistory mode ON main.scPayDetailSAId = mode.scPayDetailSAId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.scPayMasterSAId = ' + CAST (@scPayMasterSAId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
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
			 scPayDetailSAId
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
			SELECT 'X' FROM scPayDetailSA WITH(NOLOCK)
			WHERE scPayDetailSAId = @scPayDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayDetailSA WITH(NOLOCK)
			WHERE scPayDetailSAId = @scPayDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayDetailSAId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scPayDetailSA WHERE approvedBy IS NULL AND scPayDetailSAId = @scPayDetailSAId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayDetailSAId
					RETURN
				END
			DELETE FROM scPayDetailSA WHERE scPayDetailSAId =  @scPayDetailSAId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayDetailSAId
					RETURN
				END
				DELETE FROM scPayDetailSAHistory WHERE scPayDetailSAId = @scPayDetailSAId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scPayDetailSAId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scPayDetailSA WITH(NOLOCK)
			WHERE scPayDetailSAId = @scPayDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayDetailSA WITH(NOLOCK)
			WHERE scPayDetailSAId = @scPayDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayDetailSA WHERE approvedBy IS NULL AND scPayDetailSAId = @scPayDetailSAId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scPayDetailSAHistory WHERE scPayDetailSAId = @scPayDetailSAId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scPayDetailSA SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scPayDetailSAId = @scPayDetailSAId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailSAId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scPayDetailSA main
				INNER JOIN scPayDetailSAHistory mode ON mode.scPayDetailSAId = main.scPayDetailSAId
				WHERE mode.scPayDetailSAId = @scPayDetailSAId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scPayDetailSA', 'scPayDetailSAId', @scPayDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailSAId, @oldValue OUTPUT
				UPDATE scPayDetailSA SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scPayDetailSAId = @scPayDetailSAId
			END
			
			UPDATE scPayDetailSAHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scPayDetailSAId = @scPayDetailSAId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailSAId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scPayDetailSAId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @scPayDetailSAId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scPayDetailSAId
END CATCH



GO
