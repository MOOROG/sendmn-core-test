USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcSendDetailHub]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcSendDetailHub]
	 @flag                              VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@dcSendDetailHubId                 VARCHAR(30)    = NULL
	,@dcSendMasterHubId					INT            = NULL
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
		 @ApprovedFunctionId = 20201030
		,@logIdentifier = 'dcSendDetailHubId'
		,@logParamMain = 'dcSendDetailHub'
		,@logParamMod = 'dcSendDetailHubHistory'
		,@module = '20'
		,@tableAlias = 'Hub Default Send Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dcSendDetailHub
				WHERE dcSendMasterHubId = '+ CAST(ISNULL(@dcSendMasterHubId, 0) AS VARCHAR) + '					
				AND dcSendDetailHubId <> ' + CAST(ISNULL(@dcSendDetailHubId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dcSendDetailHubId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcSendDetailHubId
			RETURN	
		END
	END	
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHubHistory WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcSendDetailHub (
				 dcSendMasterHubId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dcSendMasterHubId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @dcSendDetailHubId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcSendDetailHubId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHubHistory WITH(NOLOCK)
				WHERE dcSendDetailHubId = @dcSendDetailHubId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcSendDetailHubHistory mode WITH(NOLOCK)
			INNER JOIN dcSendDetailHub main WITH(NOLOCK) ON mode.dcSendDetailHubId = main.dcSendDetailHubId
			WHERE mode.dcSendDetailHubId= @dcSendDetailHubId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcSendDetailHub WITH(NOLOCK) WHERE dcSendDetailHubId = @dcSendDetailHubId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHubHistory WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHub WITH(NOLOCK)
			WHERE dcSendDetailHubId = @dcSendDetailHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHubHistory WITH(NOLOCK)
			WHERE dcSendDetailHubId  = @dcSendDetailHubId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendDetailHub WHERE approvedBy IS NULL AND dcSendDetailHubId  = @dcSendDetailHubId)			
			BEGIN				
				UPDATE dcSendDetailHub SET
				 dcSendMasterHubId = @dcSendMasterHubId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE dcSendDetailHubId = @dcSendDetailHubId			
			END
			ELSE
			BEGIN
				DELETE FROM dcSendDetailHubHistory WHERE dcSendDetailHubId = @dcSendDetailHubId AND approvedBy IS NULL
				INSERT INTO dcSendDetailHubHistory(
					 dcSendDetailHubId
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
					 @dcSendDetailHubId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcSendDetailHubId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHubHistory WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHub WITH(NOLOCK)
			WHERE dcSendDetailHubId = @dcSendDetailHubId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailHubHistory  WITH(NOLOCK)
			WHERE dcSendDetailHubId = @dcSendDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcSendDetailHubId
			RETURN
		END
		SELECT @dcSendMasterHubId = dcSendMasterHubId FROM dcSendDetailHub WHERE dcSendDetailHubId = @dcSendDetailHubId
		IF EXISTS(SELECT 'X' FROM dcSendDetailHub WITH(NOLOCK) WHERE dcSendDetailHubId = @dcSendDetailHubId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM dcSendDetailHub WHERE dcSendDetailHubId = @dcSendDetailHubId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterHubId
			RETURN
		END
			INSERT INTO dcSendDetailHubHistory(
					 dcSendDetailHubId
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
					 dcSendDetailHubId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dcSendDetailHub
				WHERE dcSendDetailHubId = @dcSendDetailHubId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterHubId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendDetailHubId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcSendDetailHubId = ISNULL(mode.dcSendDetailHubId, main.dcSendDetailHubId)
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
											(mode.dcSendDetailHubId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcSendDetailHub main WITH(NOLOCK)
					LEFT JOIN dcSendDetailHubHistory mode ON main.dcSendDetailHubId = mode.dcSendDetailHubId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dcSendMasterHubId = ' + CAST (@dcSendMasterHubId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dcSendDetailHubId
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
			SELECT 'X' FROM dcSendDetailHub WITH(NOLOCK)
			WHERE dcSendDetailHubId = @dcSendDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendDetailHub WITH(NOLOCK)
			WHERE dcSendDetailHubId = @dcSendDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendDetailHubId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcSendDetailHub WHERE approvedBy IS NULL AND dcSendDetailHubId = @dcSendDetailHubId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendDetailHubId
					RETURN
				END
			DELETE FROM dcSendDetailHub WHERE dcSendDetailHubId =  @dcSendDetailHubId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendDetailHubId
					RETURN
				END
				DELETE FROM dcSendDetailHubHistory WHERE dcSendDetailHubId = @dcSendDetailHubId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcSendDetailHubId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcSendDetailHub WITH(NOLOCK)
			WHERE dcSendDetailHubId = @dcSendDetailHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendDetailHub WITH(NOLOCK)
			WHERE dcSendDetailHubId = @dcSendDetailHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendDetailHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendDetailHub WHERE approvedBy IS NULL AND dcSendDetailHubId = @dcSendDetailHubId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcSendDetailHubHistory WHERE dcSendDetailHubId = @dcSendDetailHubId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcSendDetailHub SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcSendDetailHubId = @dcSendDetailHubId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailHubId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcSendDetailHub main
				INNER JOIN dcSendDetailHubHistory mode ON mode.dcSendDetailHubId = main.dcSendDetailHubId
				WHERE mode.dcSendDetailHubId = @dcSendDetailHubId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcSendDetailHub', 'dcSendDetailHubId', @dcSendDetailHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailHubId, @oldValue OUTPUT
				UPDATE dcSendDetailHub SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcSendDetailHubId = @dcSendDetailHubId
			END
			
			UPDATE dcSendDetailHubHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcSendDetailHubId = @dcSendDetailHubId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailHubId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcSendDetailHubId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dcSendDetailHubId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcSendDetailHubId
END CATCH



GO
