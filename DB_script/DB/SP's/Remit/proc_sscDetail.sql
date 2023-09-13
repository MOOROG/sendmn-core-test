

ALTER proc [dbo].[proc_sscDetail]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@sscDetailId                       VARCHAR(30)		= NULL
	,@sscMasterId                       INT				= NULL
	,@oldSscMasterId					INT				= NULL
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
		,@MSG				VARCHAR(100)
	SELECT
		 @ApprovedFunctionId = 30001030
		,@logIdentifier = 'sscDetailId'
		,@logParamMain = 'sscDetail'
		,@logParamMod = 'sscDetailHistory'
		,@module = '20'
		,@tableAlias = 'Service Charge Detail'
		
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM sscDetail
				WHERE sscMasterId = '+ CAST(ISNULL(@sscMasterId, 0) AS VARCHAR) + '					
				AND sscDetailId <> ' + CAST(ISNULL(@sscDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @sscDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @sscDetailId
			RETURN	
		END
	END	
	
	ELSE IF @flag = 'cs'					--Copy Slab
	BEGIN
		IF EXISTS(SELECT 'X' FROM sscDetail WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND sscMasterId = @sscMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'Amount Slab already exists. Copy process terminated', @sscMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO sscDetail(
				 sscMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @sscMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,@user
				,GETDATE()
			FROM sscDetail WITH(NOLOCK) WHERE sscMasterId = @oldSscMasterId	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Copy has been done successfully.', @sscMasterId	
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @sscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM sscMasterHistory WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @sscDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @sscDetailId
			RETURN
		END
		
		BEGIN TRANSACTION
			INSERT INTO sscDetail (
				 sscMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @sscMasterId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @sscDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @sscDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM sscDetailHistory WITH(NOLOCK)
				WHERE sscDetailId = @sscDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM sscDetailHistory mode WITH(NOLOCK)
			INNER JOIN sscDetail main WITH(NOLOCK) ON mode.sscDetailId = main.sscDetailId
			WHERE mode.sscDetailId= @sscDetailId and mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM sscDetail WITH(NOLOCK) WHERE sscDetailId = @sscDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @sscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM sscMasterHistory WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @sscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM sscDetail WITH(NOLOCK)
			WHERE sscDetailId = @sscDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @sscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM sscDetailHistory WITH(NOLOCK)
			WHERE sscDetailId  = @sscDetailId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @sscDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @sscDetailId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM sscDetail WHERE approvedBy IS NULL AND sscDetailId  = @sscDetailId)			
			BEGIN				
				UPDATE sscDetail SET
				 sscMasterId = @sscMasterId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE sscDetailId = @sscDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM sscDetailHistory WHERE sscDetailId = @sscDetailId AND approvedBy IS NULL
				INSERT INTO sscDetailHistory(
					 sscDetailId
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
					 @sscDetailId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @sscDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @sscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM sscMasterHistory WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @sscDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sscDetail WITH(NOLOCK) WHERE sscDetailId = @sscDetailId  AND createdBy <> @user AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @sscDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sscDetailHistory  WITH(NOLOCK) WHERE sscDetailId = @sscDetailId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @sscDetailId
			RETURN
		END
		SELECT @sscMasterId = sscMasterId FROM sscDetail WHERE sscDetailId = @sscDetailId
		IF EXISTS(SELECT 'X' FROM sscDetail WITH(NOLOCK) WHERE sscDetailId = @sscDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM sscDetail WHERE sscDetailId = @sscDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @sscMasterId
			RETURN
		END
			INSERT INTO sscDetailHistory(
					 sscDetailId
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
					 sscDetailId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM sscDetail
				WHERE sscDetailId = @sscDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @sscMasterId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'sscDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 sscDetailId = ISNULL(mode.sscDetailId, main.sscDetailId)
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
											(mode.sscDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM sscDetail main WITH(NOLOCK)
					LEFT JOIN sscDetailHistory mode ON main.sscDetailId = mode.sscDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.sscMasterId = ' + CAST (@sscMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
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
			 sscDetailId
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
			SELECT 'X' FROM sscDetail WITH(NOLOCK)
			WHERE sscDetailId = @sscDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM sscDetail WITH(NOLOCK)
			WHERE sscDetailId = @sscDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @sscDetailId
			RETURN
		END
		SELECT @sscMasterId = sscMasterId FROM sscDetail WHERE sscDetailId = @sscDetailId
		IF EXISTS (SELECT 'X' FROM sscDetail WHERE approvedBy IS NULL AND sscDetailId = @sscDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sscDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @sscMasterId
					RETURN
				END
			DELETE FROM sscDetail WHERE sscDetailId =  @sscDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sscDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @sscMasterId
					RETURN
				END
				DELETE FROM sscDetailHistory WHERE sscDetailId = @sscDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @sscMasterId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM sscDetail WITH(NOLOCK)
			WHERE sscDetailId = @sscDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM sscDetail WITH(NOLOCK)
			WHERE sscDetailId = @sscDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @sscDetailId
			RETURN
		END
		SELECT @sscMasterId = sscMasterId FROM sscDetail WHERE sscDetailId = @sscDetailId
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM sscDetail WHERE approvedBy IS NULL AND sscDetailId = @sscDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM sscDetailHistory WHERE sscDetailId = @sscDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE sscDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE sscDetailId = @sscDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM sscDetail main
				INNER JOIN sscDetailHistory mode ON mode.sscDetailId = main.sscDetailId
				WHERE mode.sscDetailId = @sscDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'sscDetail', 'sscDetailId', @sscDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscDetailId, @oldValue OUTPUT
				UPDATE sscDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE sscDetailId = @sscDetailId
			END
			
			UPDATE sscDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE sscDetailId = @sscDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sscDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @sscMasterId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @sscMasterId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @sscDetailId
END CATCH



