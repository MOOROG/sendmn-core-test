USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scPayDetail]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_scPayDetail]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@scPayDetailId                     VARCHAR(30)		= NULL
	,@scPayMasterId                     INT				= NULL
	,@oldScPayMasterId					INT				= NULL
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
		 @ApprovedFunctionId = 20131230
		,@logIdentifier = 'scPayDetailId'
		,@logParamMain = 'scPayDetail'
		,@logParamMod = 'scPayDetailHistory'
		,@module = '20'
		,@tableAlias = 'Agent Pay Commission Detail'
	
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM scPayDetail
				WHERE scPayMasterId = '+ CAST(ISNULL(@scPayMasterId, 0) AS VARCHAR) + '					
				AND scPayDetailId <> ' + CAST(ISNULL(@scPayDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @scPayDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @scPayDetailId
			RETURN	
		END
	END
	
	ELSE IF @flag = 'cs'					--Copy Slab
	BEGIN
		IF EXISTS(SELECT 'X' FROM scPayDetail WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND scPayMasterId = @scPayMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'Amount Slab already exists. Copy process terminated', @scPayMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scPayDetail(
				 scPayMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scPayMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,@user
				,GETDATE()
			FROM scPayDetail WITH(NOLOCK) WHERE scPayMasterId = @oldScPayMasterId AND ISNULL(isDeleted, 'N') = 'N'	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Copy has been done successfully.', @scPayMasterId	
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMaster WITH(NOLOCK)
			WHERE scPayMasterId = @scPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHistory WITH(NOLOCK)
			WHERE scPayMasterId = @scPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scPayDetail (
				 scPayMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scPayMasterId
				,@fromAmt
				,@toAmt
				,ISNULL(@pcnt, 0)
				,ISNULL(@minAmt, 0)
				,ISNULL(@maxAmt, 0)
				,@user
				,GETDATE()
				
				
			SET @scPayDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scPayDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHistory WITH(NOLOCK)
				WHERE scPayDetailId = @scPayDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scPayDetailHistory mode WITH(NOLOCK)
			INNER JOIN scPayDetail main WITH(NOLOCK) ON mode.scPayDetailId = main.scPayDetailId
			WHERE mode.scPayDetailId= @scPayDetailId and mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scPayDetail WITH(NOLOCK) WHERE scPayDetailId = @scPayDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMaster WITH(NOLOCK)
			WHERE scPayMasterId = @scPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHistory WITH(NOLOCK)
			WHERE scPayMasterId = @scPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetail WITH(NOLOCK)
			WHERE scPayDetailId = @scPayDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHistory WITH(NOLOCK)
			WHERE scPayDetailId  = @scPayDetailId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayDetail WHERE approvedBy IS NULL AND scPayDetailId  = @scPayDetailId)			
			BEGIN				
				UPDATE scPayDetail SET
				 scPayMasterId = @scPayMasterId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE scPayDetailId = @scPayDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM scPayDetailHistory WHERE scPayDetailId = @scPayDetailId AND approvedBy IS NULL
				INSERT INTO scPayDetailHistory(
					 scPayDetailId
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
					 @scPayDetailId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scPayDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMaster WITH(NOLOCK)
			WHERE scPayMasterId = @scPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHistory WITH(NOLOCK)
			WHERE scPayMasterId = @scPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetail WITH(NOLOCK)
			WHERE scPayDetailId = @scPayDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayDetailHistory  WITH(NOLOCK)
			WHERE scPayDetailId = @scPayDetailId AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.',  @scPayDetailId
			RETURN
		END
		SELECT @scPayMasterId = scPayMasterId FROM scPayDetail WHERE scPayDetailId = @scPayDetailId
		IF EXISTS(SELECT 'X' FROM scPayDetail WITH(NOLOCK) WHERE scPayDetailId = @scPayDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM scPayDetail WHERE scPayDetailId = @scPayDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @scPayMasterId
		END
			INSERT INTO scPayDetailHistory(
					 scPayDetailId
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
					 scPayDetailId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM scPayDetail
				WHERE scPayDetailId = @scPayDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scPayMasterId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'scPayDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scPayDetailId = ISNULL(mode.scPayDetailId, main.scPayDetailId)
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
											(mode.scPayDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scPayDetail main WITH(NOLOCK)
					LEFT JOIN scPayDetailHistory mode ON main.scPayDetailId = mode.scPayDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.scPayMasterId = ' + CAST (@scPayMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
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
			 scPayDetailId
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
			SELECT 'X' FROM scPayDetail WITH(NOLOCK)
			WHERE scPayDetailId = @scPayDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayDetail WITH(NOLOCK)
			WHERE scPayDetailId = @scPayDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scPayDetail WHERE approvedBy IS NULL AND scPayDetailId = @scPayDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayDetailId
					RETURN
				END
			DELETE FROM scPayDetail WHERE scPayDetailId =  @scPayDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayDetailId
					RETURN
				END
				DELETE FROM scPayDetailHistory WHERE scPayDetailId = @scPayDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scPayDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scPayDetail WITH(NOLOCK)
			WHERE scPayDetailId = @scPayDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayDetail WITH(NOLOCK)
			WHERE scPayDetailId = @scPayDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayDetail WHERE approvedBy IS NULL AND scPayDetailId = @scPayDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scPayDetailHistory WHERE scPayDetailId = @scPayDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scPayDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scPayDetailId = @scPayDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scPayDetail main
				INNER JOIN scPayDetailHistory mode ON mode.scPayDetailId = main.scPayDetailId
				WHERE mode.scPayDetailId = @scPayDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scPayDetail', 'scPayDetailId', @scPayDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayDetailId, @oldValue OUTPUT
				UPDATE scPayDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scPayDetailId = @scPayDetailId
			END
			
			UPDATE scPayDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scPayDetailId = @scPayDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scPayDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @scPayDetailId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scPayDetailId
END CATCH



GO
