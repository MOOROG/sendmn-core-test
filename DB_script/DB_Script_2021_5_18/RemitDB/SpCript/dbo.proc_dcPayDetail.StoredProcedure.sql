USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcPayDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcPayDetail]
	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@dcPayDetailId                        VARCHAR(30)    = NULL
	,@dcPayMasterId                        INT            = NULL
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
	SELECT
		 @ApprovedFunctionId = 20131230
		,@logIdentifier = 'dcPayDetailId'
		,@logParamMain = 'dcPayDetail'
		,@logParamMod = 'dcPayDetailHistory'
		,@module = '20'
		,@tableAlias = 'Default Pay Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dcPayDetail
				WHERE dcPayMasterId = '+ CAST(ISNULL(@dcPayMasterId, 0) AS VARCHAR) + '					
				AND dcPayDetailId <> ' + CAST(ISNULL(@dcPayDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dcPayDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcPayDetailId
			RETURN	
		END
	END	
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHistory WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcPayDetail (
				 dcPayMasterId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dcPayMasterId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @dcPayDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcPayDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHistory WITH(NOLOCK)
				WHERE dcPayDetailId = @dcPayDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcPayDetailHistory mode WITH(NOLOCK)
			INNER JOIN dcPayDetail main WITH(NOLOCK) ON mode.dcPayDetailId = main.dcPayDetailId
			WHERE mode.dcPayDetailId= @dcPayDetailId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcPayDetail WITH(NOLOCK) WHERE dcPayDetailId = @dcPayDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHistory WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetail WITH(NOLOCK)
			WHERE dcPayDetailId = @dcPayDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHistory WITH(NOLOCK)
			WHERE dcPayDetailId  = @dcPayDetailId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayDetail WHERE approvedBy IS NULL AND dcPayDetailId  = @dcPayDetailId)			
			BEGIN				
				UPDATE dcPayDetail SET
				 dcPayMasterId = @dcPayMasterId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE dcPayDetailId = @dcPayDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM dcPayDetailHistory WHERE dcPayDetailId = @dcPayDetailId AND approvedBy IS NULL
				INSERT INTO dcPayDetailHistory(
					 dcPayDetailId
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
					 @dcPayDetailId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcPayDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHistory WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetail WITH(NOLOCK)
			WHERE dcPayDetailId = @dcPayDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHistory  WITH(NOLOCK)
			WHERE dcPayDetailId = @dcPayDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcPayDetailId
			RETURN
		END
		SELECT @dcPayMasterId = dcPayMasterId FROM dcPayDetail WHERE dcPayDetailId = @dcPayDetailId
		IF EXISTS(SELECT 'X' FROM dcPayDetail WITH(NOLOCK) WHERE dcPayDetailId = @dcPayDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM dcPayDetail WHERE dcPayDetailId = @dcPayDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterId
			RETURN
		END
			INSERT INTO dcPayDetailHistory(
					 dcPayDetailId
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
					 dcPayDetailId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dcPayDetail
				WHERE dcPayDetailId = @dcPayDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcPayDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcPayDetailId = ISNULL(mode.dcPayDetailId, main.dcPayDetailId)
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
											(mode.dcPayDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcPayDetail main WITH(NOLOCK)
					LEFT JOIN dcPayDetailHistory mode ON main.dcPayDetailId = mode.dcPayDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dcPayMasterId = ' + CAST (@dcPayMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dcPayDetailId
			,fromAmt
			,toAmt
			,pcnt
			,minAmt
			,maxAmt
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
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
			SELECT 'X' FROM dcPayDetail WITH(NOLOCK)
			WHERE dcPayDetailId = @dcPayDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayDetail WITH(NOLOCK)
			WHERE dcPayDetailId = @dcPayDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcPayDetail WHERE approvedBy IS NULL AND dcPayDetailId = @dcPayDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayDetailId
					RETURN
				END
			DELETE FROM dcPayDetail WHERE dcPayDetailId =  @dcPayDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayDetailId
					RETURN
				END
				DELETE FROM dcPayDetailHistory WHERE dcPayDetailId = @dcPayDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcPayDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcPayDetail WITH(NOLOCK)
			WHERE dcPayDetailId = @dcPayDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayDetail WITH(NOLOCK)
			WHERE dcPayDetailId = @dcPayDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayDetail WHERE approvedBy IS NULL AND dcPayDetailId = @dcPayDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcPayDetailHistory WHERE dcPayDetailId = @dcPayDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcPayDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcPayDetailId = @dcPayDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcPayDetail main
				INNER JOIN dcPayDetailHistory mode ON mode.dcPayDetailId = main.dcPayDetailId
				WHERE mode.dcPayDetailId = @dcPayDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcPayDetail', 'dcPayDetailId', @dcPayDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailId, @oldValue OUTPUT
				UPDATE dcPayDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcPayDetailId = @dcPayDetailId
			END
			
			UPDATE dcPayDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcPayDetailId = @dcPayDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcPayDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dcPayDetailId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcPayDetailId
END CATCH


GO
