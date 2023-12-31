USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scSendDetailSA]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_scSendDetailSA]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@scSendDetailSAId                  VARCHAR(30)		= NULL
	,@scSendMasterSAId                  INT             = NULL
	,@oldScSendMasterSAId				INT				= NULL
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
		 @ApprovedFunctionId = 20131330
		,@logIdentifier = 'scSendDetailSAId'
		,@logParamMain = 'scSendDetailSA'
		,@logParamMod = 'scSendDetailSAHistory'
		,@module = '20'
		,@tableAlias = 'Super Agent Send Commission Detail'
	
		
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM scSendDetailSA
				WHERE scSendMasterSAId = '+ CAST(ISNULL(@scSendMasterSAId, 0) AS VARCHAR) + '					
				AND scSendDetailSAId <> ' + CAST(ISNULL(@scSendDetailSAId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @scSendDetailSAId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @scSendDetailSAId
			RETURN	
		END
	END
	
	ELSE IF @flag = 'cs'					--Copy Slab
	BEGIN
		IF EXISTS(SELECT 'X' FROM scSendDetailSA WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND scSendMasterSAId = @scSendMasterSAId)
		BEGIN
			EXEC proc_errorHandler 1, 'Amount Slab already exists. Copy process terminated', @scSendMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scSendDetailSA(
				 scSendMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scSendMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,@user
				,GETDATE()
			FROM scSendDetailSA WITH(NOLOCK) WHERE scSendMasterSAId = @oldscSendMasterSAId	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Copy has been done successfully.', @scSendMasterSAId	
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMasterSA WITH(NOLOCK)
			WHERE scSendMasterSAId = @scSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterSAHistory WITH(NOLOCK)
			WHERE scSendMasterSAId = @scSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scSendDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scSendDetailSA (
				 scSendMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @scSendMasterSAId
				,@fromAmt
				,@toAmt
				,ISNULL(@pcnt, 0)
				,ISNULL(@minAmt, 0)
				,ISNULL(@maxAmt, 0)
				,@user
				,GETDATE()
				
				
			SET @scSendDetailSAId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scSendDetailSAId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendDetailSAHistory WITH(NOLOCK)
				WHERE scSendDetailSAId = @scSendDetailSAId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scSendDetailSAHistory mode WITH(NOLOCK)
			INNER JOIN scSendDetailSA main WITH(NOLOCK) ON mode.scSendDetailSAId = main.scSendDetailSAId
			WHERE mode.scSendDetailSAId= @scSendDetailSAId and mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scSendDetailSA WITH(NOLOCK) WHERE scSendDetailSAId = @scSendDetailSAId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMasterSA WITH(NOLOCK)
			WHERE scSendMasterSAId = @scSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterSAHistory WITH(NOLOCK)
			WHERE scSendMasterSAId = @scSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailSA WITH(NOLOCK)
			WHERE scSendDetailSAId = @scSendDetailSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailSAHistory WITH(NOLOCK)
			WHERE scSendDetailSAId  = @scSendDetailSAId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scSendDetailSA WHERE approvedBy IS NULL AND scSendDetailSAId  = @scSendDetailSAId)			
			BEGIN				
				UPDATE scSendDetailSA SET
				 scSendMasterSAId = @scSendMasterSAId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE scSendDetailSAId = @scSendDetailSAId			
			END
			ELSE
			BEGIN
				DELETE FROM scSendDetailSAHistory WHERE scSendDetailSAId = @scSendDetailSAId AND approvedBy IS NULL
				INSERT INTO scSendDetailSAHistory(
					 scSendDetailSAId
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
					 @scSendDetailSAId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scSendDetailSAId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scSendMasterSA WITH(NOLOCK)
			WHERE scSendMasterSAId = @scSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendMasterSAHistory WITH(NOLOCK)
			WHERE scSendMasterSAId = @scSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailSA WITH(NOLOCK)
			WHERE scSendDetailSAId = @scSendDetailSAId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scSendDetailSAHistory  WITH(NOLOCK)
			WHERE scSendDetailSAId = @scSendDetailSAId AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.',  @scSendDetailSAId
			RETURN
		END
		SELECT @scSendMasterSAId = scSendMasterSAId FROM scSendDetailSA WHERE scSendDetailSAId = @scSendDetailSAId
		IF EXISTS(SELECT 'X' FROM scSendDetailSA WITH(NOLOCK) WHERE scSendDetailSAId = @scSendDetailSAId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM scSendDetailSA WHERE scSendDetailSAId = @scSendDetailSAId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @scSendMasterSAId
			RETURN
		END
		
			INSERT INTO scSendDetailSAHistory(
					 scSendDetailSAId
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
					 scSendDetailSAId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM scSendDetailSA
				WHERE scSendDetailSAId = @scSendDetailSAId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scSendMasterSAId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'scSendDetailSAId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scSendDetailSAId = ISNULL(mode.scSendDetailSAId, main.scSendDetailSAId)
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
											(mode.scSendDetailSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scSendDetailSA main WITH(NOLOCK)
					LEFT JOIN scSendDetailSAHistory mode ON main.scSendDetailSAId = mode.scSendDetailSAId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.scSendMasterSAId = ' + CAST (@scSendMasterSAId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
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
			 scSendDetailSAId
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
			SELECT 'X' FROM scSendDetailSA WITH(NOLOCK)
			WHERE scSendDetailSAId = @scSendDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scSendDetailSA WITH(NOLOCK)
			WHERE scSendDetailSAId = @scSendDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scSendDetailSAId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scSendDetailSA WHERE approvedBy IS NULL AND scSendDetailSAId = @scSendDetailSAId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scSendDetailSAId
					RETURN
				END
			DELETE FROM scSendDetailSA WHERE scSendDetailSAId =  @scSendDetailSAId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scSendDetailSAId
					RETURN
				END
				DELETE FROM scSendDetailSAHistory WHERE scSendDetailSAId = @scSendDetailSAId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scSendDetailSAId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scSendDetailSA WITH(NOLOCK)
			WHERE scSendDetailSAId = @scSendDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scSendDetailSA WITH(NOLOCK)
			WHERE scSendDetailSAId = @scSendDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scSendDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scSendDetailSA WHERE approvedBy IS NULL AND scSendDetailSAId = @scSendDetailSAId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scSendDetailSAHistory WHERE scSendDetailSAId = @scSendDetailSAId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scSendDetailSA SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scSendDetailSAId = @scSendDetailSAId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailSAId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scSendDetailSA main
				INNER JOIN scSendDetailSAHistory mode ON mode.scSendDetailSAId = main.scSendDetailSAId
				WHERE mode.scSendDetailSAId = @scSendDetailSAId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scSendDetailSA', 'scSendDetailSAId', @scSendDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scSendDetailSAId, @oldValue OUTPUT
				UPDATE scSendDetailSA SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scSendDetailSAId = @scSendDetailSAId
			END
			
			UPDATE scSendDetailSAHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scSendDetailSAId = @scSendDetailSAId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scSendDetailSAId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scSendDetailSAId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @scSendDetailSAId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scSendDetailSAId
END CATCH



GO
