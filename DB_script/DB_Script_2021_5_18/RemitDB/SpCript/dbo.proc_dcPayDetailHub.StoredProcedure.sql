USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcPayDetailHub]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcPayDetailHub]
	 @flag                              VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@dcPayDetailHubId                  VARCHAR(30)    = NULL
	,@dcPayMasterHubId                  INT            = NULL
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
		 @ApprovedFunctionId = 20201230
		,@logIdentifier = 'dcPayDetailHubId'
		,@logParamMain = 'dcPayDetailHub'
		,@logParamMod = 'dcPayDetailHubHistory'
		,@module = '20'
		,@tableAlias = 'Hub Default Pay Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dcPayDetailHub
				WHERE dcPayMasterHubId = '+ CAST(ISNULL(@dcPayMasterHubId, 0) AS VARCHAR) + '					
				AND dcPayDetailHubId <> ' + CAST(ISNULL(@dcPayDetailHubId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dcPayDetailHubId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcPayDetailHubId
			RETURN	
		END
	END	
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHub WITH(NOLOCK)
			WHERE dcPayMasterHubId = @dcPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHubHistory WITH(NOLOCK)
			WHERE dcPayMasterHubId = @dcPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcPayDetailHub (
				 dcPayMasterHubId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dcPayMasterHubId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @dcPayDetailHubId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcPayDetailHubId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHubHistory WITH(NOLOCK)
				WHERE dcPayDetailHubId = @dcPayDetailHubId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcPayDetailHubHistory mode WITH(NOLOCK)
			INNER JOIN dcPayDetailHub main WITH(NOLOCK) ON mode.dcPayDetailHubId = main.dcPayDetailHubId
			WHERE mode.dcPayDetailHubId= @dcPayDetailHubId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcPayDetailHub WITH(NOLOCK) WHERE dcPayDetailHubId = @dcPayDetailHubId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHub WITH(NOLOCK)
			WHERE dcPayMasterHubId = @dcPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHubHistory WITH(NOLOCK)
			WHERE dcPayMasterHubId = @dcPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHub WITH(NOLOCK)
			WHERE dcPayDetailHubId = @dcPayDetailHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHubHistory WITH(NOLOCK)
			WHERE dcPayDetailHubId  = @dcPayDetailHubId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayDetailHub WHERE approvedBy IS NULL AND dcPayDetailHubId  = @dcPayDetailHubId)			
			BEGIN				
				UPDATE dcPayDetailHub SET
				 dcPayMasterHubId = @dcPayMasterHubId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE dcPayDetailHubId = @dcPayDetailHubId			
			END
			ELSE
			BEGIN
				DELETE FROM dcPayDetailHubHistory WHERE dcPayDetailHubId = @dcPayDetailHubId AND approvedBy IS NULL
				INSERT INTO dcPayDetailHubHistory(
					 dcPayDetailHubId
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
					 @dcPayDetailHubId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcPayDetailHubId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHub WITH(NOLOCK)
			WHERE dcPayMasterHubId = @dcPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHubHistory WITH(NOLOCK)
			WHERE dcPayMasterHubId = @dcPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHub WITH(NOLOCK)
			WHERE dcPayDetailHubId = @dcPayDetailHubId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailHubHistory  WITH(NOLOCK)
			WHERE dcPayDetailHubId = @dcPayDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcPayDetailHubId
			RETURN
		END
		SELECT @dcPayMasterHubId = dcPayMasterHubId FROM dcPayDetailHub WHERE dcPayDetailHubId = @dcPayDetailHubId
		IF EXISTS(SELECT 'X' FROM dcPayDetailHub WITH(NOLOCK) WHERE dcPayDetailHubId = @dcPayDetailHubId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM dcPayDetailHub WHERE dcPayDetailHubId = @dcPayDetailHubId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterHubId
			RETURN
		END
			INSERT INTO dcPayDetailHubHistory(
					 dcPayDetailHubId
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
					 dcPayDetailHubId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dcPayDetailHub
				WHERE dcPayDetailHubId = @dcPayDetailHubId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterHubId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcPayDetailHubId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcPayDetailHubId = ISNULL(mode.dcPayDetailHubId, main.dcPayDetailHubId)
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
											(mode.dcPayDetailHubId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcPayDetailHub main WITH(NOLOCK)
					LEFT JOIN dcPayDetailHubHistory mode ON main.dcPayDetailHubId = mode.dcPayDetailHubId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dcPayMasterHubId = ' + CAST (@dcPayMasterHubId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dcPayDetailHubId
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
			SELECT 'X' FROM dcPayDetailHub WITH(NOLOCK)
			WHERE dcPayDetailHubId = @dcPayDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayDetailHub WITH(NOLOCK)
			WHERE dcPayDetailHubId = @dcPayDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayDetailHubId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcPayDetailHub WHERE approvedBy IS NULL AND dcPayDetailHubId = @dcPayDetailHubId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayDetailHubId
					RETURN
				END
			DELETE FROM dcPayDetailHub WHERE dcPayDetailHubId =  @dcPayDetailHubId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayDetailHubId
					RETURN
				END
				DELETE FROM dcPayDetailHubHistory WHERE dcPayDetailHubId = @dcPayDetailHubId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcPayDetailHubId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcPayDetailHub WITH(NOLOCK)
			WHERE dcPayDetailHubId = @dcPayDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayDetailHub WITH(NOLOCK)
			WHERE dcPayDetailHubId = @dcPayDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayDetailHub WHERE approvedBy IS NULL AND dcPayDetailHubId = @dcPayDetailHubId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcPayDetailHubHistory WHERE dcPayDetailHubId = @dcPayDetailHubId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcPayDetailHub SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcPayDetailHubId = @dcPayDetailHubId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailHubId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcPayDetailHub main
				INNER JOIN dcPayDetailHubHistory mode ON mode.dcPayDetailHubId = main.dcPayDetailHubId
				WHERE mode.dcPayDetailHubId = @dcPayDetailHubId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcPayDetailHub', 'dcPayDetailHubId', @dcPayDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailHubId, @oldValue OUTPUT
				UPDATE dcPayDetailHub SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcPayDetailHubId = @dcPayDetailHubId
			END
			
			UPDATE dcPayDetailHubHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcPayDetailHubId = @dcPayDetailHubId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailHubId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcPayDetailHubId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dcPayDetailHubId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcPayDetailHubId
END CATCH


GO
