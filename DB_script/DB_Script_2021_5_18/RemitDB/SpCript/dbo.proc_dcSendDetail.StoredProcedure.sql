USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcSendDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcSendDetail]
	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@dcSendDetailId                        VARCHAR(30)    = NULL
	,@dcSendMasterId                        INT            = NULL
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
		 @ApprovedFunctionId = 20131030
		,@logIdentifier = 'dcSendDetailId'
		,@logParamMain = 'dcSendDetail'
		,@logParamMod = 'dcSendDetailHistory'
		,@module = '20'
		,@tableAlias = 'Default Send Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dcSendDetail
				WHERE dcSendMasterId = '+ CAST(ISNULL(@dcSendMasterId, 0) AS VARCHAR) + '					
				AND dcSendDetailId <> ' + CAST(ISNULL(@dcSendDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dcSendDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcSendDetailId
			RETURN	
		END
	END	
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHistory WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @dcSendDetailId
			RETURN
		END
		
		BEGIN TRANSACTION
			INSERT INTO dcSendDetail (
				 dcSendMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dcSendMasterId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @dcSendDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcSendDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHistory WITH(NOLOCK)
				WHERE dcSendDetailId = @dcSendDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcSendDetailHistory mode WITH(NOLOCK)
			INNER JOIN dcSendDetail main WITH(NOLOCK) ON mode.dcSendDetailId = main.dcSendDetailId
			WHERE mode.dcSendDetailId= @dcSendDetailId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcSendDetail WITH(NOLOCK) WHERE dcSendDetailId = @dcSendDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHistory WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetail WITH(NOLOCK)
			WHERE dcSendDetailId = @dcSendDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHistory WITH(NOLOCK)
			WHERE dcSendDetailId  = @dcSendDetailId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailId
			RETURN
		END
		
		IF (dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)!= 'Y')
		BEGIN
			SET @MSG = dbo.FNACheckSlab(@pcnt,@minAmt,@maxAmt)
			EXEC proc_errorHandler 1,@MSG, @dcSendDetailId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendDetail WHERE approvedBy IS NULL AND dcSendDetailId  = @dcSendDetailId)			
			BEGIN				
				UPDATE dcSendDetail SET
				 dcSendMasterId = @dcSendMasterId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE dcSendDetailId = @dcSendDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM dcSendDetailHistory WHERE dcSendDetailId = @dcSendDetailId AND approvedBy IS NULL
				INSERT INTO dcSendDetailHistory(
					 dcSendDetailId
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
					 @dcSendDetailId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcSendDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHistory WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetail WITH(NOLOCK)
			WHERE dcSendDetailId = @dcSendDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHistory  WITH(NOLOCK)
			WHERE dcSendDetailId = @dcSendDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcSendDetailId
			RETURN
		END
		SELECT @dcSendMasterId = dcSendMasterId FROM dcSendDetail WHERE dcSendDetailId = @dcSendDetailId
		IF EXISTS(SELECT 'X' FROM dcSendDetail WITH(NOLOCK) WHERE dcSendDetailId = @dcSendDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM dcSendDetail WHERE dcSendDetailId = @dcSendDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterId
			RETURN
		END
			INSERT INTO dcSendDetailHistory(
					 dcSendDetailId
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
					 dcSendDetailId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dcSendDetail
				WHERE dcSendDetailId = @dcSendDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcSendDetailId = ISNULL(mode.dcSendDetailId, main.dcSendDetailId)
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
											(mode.dcSendDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcSendDetail main WITH(NOLOCK)
					LEFT JOIN dcSendDetailHistory mode ON main.dcSendDetailId = mode.dcSendDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dcSendMasterId = ' + CAST (@dcSendMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dcSendDetailId
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
			SELECT 'X' FROM dcSendDetail WITH(NOLOCK)
			WHERE dcSendDetailId = @dcSendDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendDetail WITH(NOLOCK)
			WHERE dcSendDetailId = @dcSendDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcSendDetail WHERE approvedBy IS NULL AND dcSendDetailId = @dcSendDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendDetailId
					RETURN
				END
			DELETE FROM dcSendDetail WHERE dcSendDetailId =  @dcSendDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendDetailId
					RETURN
				END
				DELETE FROM dcSendDetailHistory WHERE dcSendDetailId = @dcSendDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcSendDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcSendDetail WITH(NOLOCK)
			WHERE dcSendDetailId = @dcSendDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendDetail WITH(NOLOCK)
			WHERE dcSendDetailId = @dcSendDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendDetail WHERE approvedBy IS NULL AND dcSendDetailId = @dcSendDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcSendDetailHistory WHERE dcSendDetailId = @dcSendDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcSendDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcSendDetailId = @dcSendDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcSendDetail main
				INNER JOIN dcSendDetailHistory mode ON mode.dcSendDetailId = main.dcSendDetailId
				WHERE mode.dcSendDetailId = @dcSendDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcSendDetail', 'dcSendDetailId', @dcSendDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailId, @oldValue OUTPUT
				UPDATE dcSendDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcSendDetailId = @dcSendDetailId
			END
			
			UPDATE dcSendDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcSendDetailId = @dcSendDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcSendDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dcSendDetailId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcSendDetailId
END CATCH


GO
