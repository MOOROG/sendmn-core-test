USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scSendDetail]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_scSendDetail]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_scSendDetail

GO
*/
CREATE proc [dbo].[proc_scSendDetail]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@scSendDetailId                    VARCHAR(30)		= NULL
	,@scSendMasterId                    INT				= NULL
	,@oldScSendMasterId					INT				= NULL
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
		 @ApprovedFunctionId = 20131130
		,@logIdentifier = 'scSendDetailId'
		,@logParamMain = 'scSendDetail'
		,@logParamMod = 'scSendDetailHistory'
		,@module = '20'
		,@tableAlias = 'Agent Send Commission Detail'
	
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM scSendDetail
				WHERE scSendMasterId = '+ CAST(ISNULL(@scSendMasterId, 0) AS VARCHAR) + '					
				AND scSendDetailId <> ' + CAST(ISNULL(@scSendDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @scSendDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @scSendDetailId
			RETURN	
		END
	END
	
	ELSE IF @flag = 'cs'					--Copy Slab
	BEGIN
		IF EXISTS(SELECT 'X' FROM scSendDetail WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND scSendMasterId = @scSendMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'Amount Slab already exists. Copy process terminated', @scSendMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scSendDetail(
				 scSendMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scSendMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,@user
				,GETDATE()
			FROM scSendDetail WITH(NOLOCK) WHERE scSendMasterId = @oldScSendMasterId AND ISNULL(isDeleted, 'N') = 'N'	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Copy has been done successfully.', @scSendMasterId	
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMaster WITH(NOLOCK)
			WHERE scSendMasterId = @scSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHistory WITH(NOLOCK)
			WHERE scSendMasterId = @scSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @scSendDetailId
			RETURN
		END
		
		BEGIN TRANSACTION
			INSERT INTO scSendDetail (
				 scSendMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scSendMasterId
				,@fromAmt
				,@toAmt
				,ISNULL(@pcnt, 0)
				,ISNULL(@minAmt, 0)
				,ISNULL(@maxAmt, 0)
				,@user
				,GETDATE()
				
				
			SET @scSendDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scSendDetailId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHistory WITH(NOLOCK)
				WHERE scSendDetailId = @scSendDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scSendDetailHistory mode WITH(NOLOCK)
			INNER JOIN scSendDetail main WITH(NOLOCK) ON mode.scSendDetailId = main.scSendDetailId
			WHERE mode.scSendDetailId= @scSendDetailId and mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scSendDetail WITH(NOLOCK) WHERE scSendDetailId = @scSendDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMaster WITH(NOLOCK)
			WHERE scSendMasterId = @scSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHistory WITH(NOLOCK)
			WHERE scSendMasterId = @scSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetail WITH(NOLOCK)
			WHERE scSendDetailId = @scSendDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHistory WITH(NOLOCK)
			WHERE scSendDetailId  = @scSendDetailId AND (createdBy<> @user AND modType = 'D')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scSendDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @scSendDetailId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scSendDetail WHERE approvedBy IS NULL AND scSendDetailId  = @scSendDetailId)			
			BEGIN				
				UPDATE scSendDetail SET
				 scSendMasterId = @scSendMasterId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE scSendDetailId = @scSendDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM scSendDetailHistory WHERE scSendDetailId = @scSendDetailId AND approvedBy IS NULL
				INSERT INTO scSendDetailHistory(
					 scSendDetailId
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
					 @scSendDetailId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scSendDetailId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMaster WITH(NOLOCK)
			WHERE scSendMasterId = @scSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterHistory WITH(NOLOCK)
			WHERE scSendMasterId = @scSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetail WITH(NOLOCK)
			WHERE scSendDetailId = @scSendDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @scSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailHistory  WITH(NOLOCK)
			WHERE scSendDetailId = @scSendDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @scSendDetailId
			RETURN
		END
		SELECT @scSendMasterId = scSendMasterId FROM scSendDetail WHERE scSendDetailId = @scSendDetailId
		IF EXISTS(SELECT 'X' FROM scSendDetail WITH(NOLOCK) WHERE scSendDetailId = @scSendDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM scSendDetail WHERE scSendDetailId = @scSendDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @scSendMasterId
			RETURN
		END
		
			INSERT INTO scSendDetailHistory(
					 scSendDetailId
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
					 scSendDetailId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM scSendDetail
				WHERE scSendDetailId = @scSendDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scSendMasterId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		DECLARE @hasRight CHAR(1)
		SET @hasRight = dbo.FNAHasRight(@user, CAST(@ApprovedFunctionId AS VARCHAR))
		IF @sortBy IS NULL
			SET @sortBy = 'scSendDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scSendDetailId = ISNULL(mode.scSendDetailId, main.scSendDetailId)
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
											(mode.scSendDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scSendDetail main WITH(NOLOCK)
					LEFT JOIN scSendDetailHistory mode ON main.scSendDetailId = mode.scSendDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
					WHERE main.scSendMasterId = ' + CAST (@scSendMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight + '''
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 scSendDetailId
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
			SELECT 'X' FROM scSendDetail WITH(NOLOCK)
			WHERE scSendDetailId = @scSendDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scSendDetail WITH(NOLOCK)
			WHERE scSendDetailId = @scSendDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scSendDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scSendDetail WHERE approvedBy IS NULL AND scSendDetailId = @scSendDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scSendDetailId
					RETURN
				END
			DELETE FROM scSendDetail WHERE scSendDetailId =  @scSendDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scSendDetailId
					RETURN
				END
				DELETE FROM scSendDetailHistory WHERE scSendDetailId = @scSendDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scSendDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scSendDetail WITH(NOLOCK)
			WHERE scSendDetailId = @scSendDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scSendDetail WITH(NOLOCK)
			WHERE scSendDetailId = @scSendDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scSendDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scSendDetail WHERE approvedBy IS NULL AND scSendDetailId = @scSendDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scSendDetailHistory WHERE scSendDetailId = @scSendDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scSendDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scSendDetailId = @scSendDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scSendDetail main
				INNER JOIN scSendDetailHistory mode ON mode.scSendDetailId = main.scSendDetailId
				WHERE mode.scSendDetailId = @scSendDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scSendDetail', 'scSendDetailId', @scSendDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailId, @oldValue OUTPUT
				UPDATE scSendDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scSendDetailId = @scSendDetailId
			END
			
			UPDATE scSendDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scSendDetailId = @scSendDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scSendDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @scSendDetailId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scSendDetailId
END CATCH


GO
