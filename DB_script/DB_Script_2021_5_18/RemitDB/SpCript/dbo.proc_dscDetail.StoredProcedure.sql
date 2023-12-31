USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dscDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dscDetail]
	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@dscDetailId                        VARCHAR(30)    = NULL
	,@dscMasterId                        INT            = NULL
	,@fromAmt                            MONEY          = NULL
	,@toAmt                              MONEY          = NULL
	,@pcnt                               FLOAT          = NULL
	,@minAmt                             MONEY          = NULL
	,@maxAmt                             MONEY          = NULL
	,@sortBy                             VARCHAR(50)    = NULL
	,@sortOrder                          VARCHAR(5)     = NULL
	,@pageSize                           INT            = NULL
	,@pageNumber                         INT            = NULL


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
		 @ApprovedFunctionId = 20141030
		,@logIdentifier = 'dscDetailId'
		,@logParamMain = 'dscDetail'
		,@logParamMod = 'dscDetailHistory'
		,@module = '20'
		,@tableAlias = 'Default Service Charge Detail'
	
	
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dscDetail
				WHERE dscMasterId = '+ CAST(ISNULL(@dscMasterId, 0) AS VARCHAR) + '					
				AND dscDetailId <> ' + CAST(ISNULL(@dscDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dscDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dscDetailId
			RETURN	
		END
	END
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscMasterHistory WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dscDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @dscDetailId
			RETURN
		END
		
		--------IF(ISNULL(@pcnt,0)!=0 )
		--------BEGIN
		--------	IF( ISNULL(@minAmt,0) = 0 OR ISNULL(@maxAmt,0) = 0)
		--------	BEGIN
		--------		EXEC proc_errorHandler 1, 'Min or Max Amt can not be null..', @dscDetailId
		--------		RETURN
		--------	END
		--------END
		
		--------IF(ISNULL(@pcnt,0)=0 AND ISNULL(@minAmt,0) = 0 )
		--------BEGIN
		--------	EXEC proc_errorHandler 1, 'Min Amt can not be null..', @dscDetailId
		--------	RETURN
		--------END
		
		
		BEGIN TRANSACTION
			INSERT INTO dscDetail (
				 dscMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dscMasterId
				,@fromAmt
				,@toAmt
				,ISNULL(@pcnt,0)
				,ISNULL(@minAmt,0)
				,ISNULL(@maxAmt,ISNULL(@minAmt,0))
				,@user
				,GETDATE()
				
				
			SET @dscDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dscDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dscDetailHistory WITH(NOLOCK)
				WHERE dscDetailId = @dscDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dscDetailHistory mode WITH(NOLOCK)
			INNER JOIN dscDetail main WITH(NOLOCK) ON mode.dscDetailId = main.dscDetailId
			WHERE mode.dscDetailId= @dscDetailId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dscDetail WITH(NOLOCK) WHERE dscDetailId = @dscDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscMasterHistory WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscDetail WITH(NOLOCK)
			WHERE dscDetailId = @dscDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @dscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscDetailHistory WITH(NOLOCK)
			WHERE dscDetailId  = @dscDetailId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @dscDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @dscDetailId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dscDetail WHERE approvedBy IS NULL AND dscDetailId  = @dscDetailId)			
			BEGIN				
				UPDATE dscDetail SET
				 dscMasterId = @dscMasterId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = ISNULL(@pcnt,0)
				,minAmt = ISNULL(@minAmt,0)
				,maxAmt = ISNULL(@maxAmt,ISNULL(@minAmt,0))
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE dscDetailId = @dscDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM dscDetailHistory WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL
				INSERT INTO dscDetailHistory(
					 dscDetailId
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
					 @dscDetailId
					,@fromAmt
					,@toAmt
					,ISNULL(@pcnt,0)
					,ISNULL(@minAmt,0)
					,ISNULL(@maxAmt,0)
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dscDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscMasterHistory WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscDetail WITH(NOLOCK)
			WHERE dscDetailId = @dscDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @dscDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscDetailHistory  WITH(NOLOCK)
			WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @dscDetailId
			RETURN
		END
		SELECT @dscMasterId = dscMasterId FROM dscDetail WHERE dscDetailId = @dscDetailId
		IF EXISTS(SELECT 'X' FROM dscDetail WITH(NOLOCK) WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM dscDetail WHERE dscDetailId = @dscDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dscMasterId
			RETURN
		END
			INSERT INTO dscDetailHistory(
					 dscDetailId
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
					 dscDetailId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dscDetail
				WHERE dscDetailId = @dscDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dscMasterId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dscDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dscDetailId = ISNULL(mode.dscDetailId, main.dscDetailId)
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
											(mode.dscDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dscDetail main WITH(NOLOCK)
					LEFT JOIN dscDetailHistory mode ON main.dscDetailId = mode.dscDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dscMasterId = ' + CAST (@dscMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dscDetailId
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
			SELECT 'X' FROM dscDetail WITH(NOLOCK)
			WHERE dscDetailId = @dscDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dscDetail WITH(NOLOCK)
			WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dscDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dscDetail WHERE approvedBy IS NULL AND dscDetailId = @dscDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dscDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dscDetailId
					RETURN
				END
			DELETE FROM dscDetail WHERE dscDetailId =  @dscDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dscDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dscDetailId
					RETURN
				END
				DELETE FROM dscDetailHistory WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dscDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dscDetail WITH(NOLOCK)
			WHERE dscDetailId = @dscDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dscDetail WITH(NOLOCK)
			WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dscDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dscDetail WHERE approvedBy IS NULL AND dscDetailId = @dscDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dscDetailHistory WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dscDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dscDetailId = @dscDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dscDetail main
				INNER JOIN dscDetailHistory mode ON mode.dscDetailId = main.dscDetailId
				WHERE mode.dscDetailId = @dscDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dscDetail', 'dscDetailId', @dscDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscDetailId, @oldValue OUTPUT
				UPDATE dscDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dscDetailId = @dscDetailId
			END
			
			UPDATE dscDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dscDetailId = @dscDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dscDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dscDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dscDetailId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dscDetailId
END CATCH


GO
