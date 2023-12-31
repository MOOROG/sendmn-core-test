USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcPayDetailSA]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcPayDetailSA]
	 @flag                              VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@dcPayDetailSAId                   VARCHAR(30)    = NULL
	,@dcPayMasterSAId                   INT            = NULL
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
		 @ApprovedFunctionId = 20191230
		,@logIdentifier = 'dcPayDetailSAId'
		,@logParamMain = 'dcPayDetailSA'
		,@logParamMod = 'dcPayDetailSAHistory'
		,@module = '20'
		,@tableAlias = 'Super Agent Default Pay Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dcPayDetailSA
				WHERE dcPayMasterSAId = '+ CAST(ISNULL(@dcPayMasterSAId, 0) AS VARCHAR) + '					
				AND dcPayDetailSAId <> ' + CAST(ISNULL(@dcPayDetailSAId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dcPayDetailSAId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcPayDetailSAId
			RETURN	
		END
	END	
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSAHistory WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcPayDetailSA (
				 dcPayMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dcPayMasterSAId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @dcPayDetailSAId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcPayDetailSAId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailSAHistory WITH(NOLOCK)
				WHERE dcPayDetailSAId = @dcPayDetailSAId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcPayDetailSAHistory mode WITH(NOLOCK)
			INNER JOIN dcPayDetailSA main WITH(NOLOCK) ON mode.dcPayDetailSAId = main.dcPayDetailSAId
			WHERE mode.dcPayDetailSAId= @dcPayDetailSAId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcPayDetailSA WITH(NOLOCK) WHERE dcPayDetailSAId = @dcPayDetailSAId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSAHistory WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailSA WITH(NOLOCK)
			WHERE dcPayDetailSAId = @dcPayDetailSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailSAHistory WITH(NOLOCK)
			WHERE dcPayDetailSAId  = @dcPayDetailSAId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayDetailSA WHERE approvedBy IS NULL AND dcPayDetailSAId  = @dcPayDetailSAId)			
			BEGIN				
				UPDATE dcPayDetailSA SET
				 dcPayMasterSAId = @dcPayMasterSAId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE dcPayDetailSAId = @dcPayDetailSAId			
			END
			ELSE
			BEGIN
				DELETE FROM dcPayDetailSAHistory WHERE dcPayDetailSAId = @dcPayDetailSAId AND approvedBy IS NULL
				INSERT INTO dcPayDetailSAHistory(
					 dcPayDetailSAId
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
					 @dcPayDetailSAId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcPayDetailSAId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSAHistory WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailSA WITH(NOLOCK)
			WHERE dcPayDetailSAId = @dcPayDetailSAId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayDetailSAHistory  WITH(NOLOCK)
			WHERE dcPayDetailSAId = @dcPayDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcPayDetailSAId
			RETURN
		END
		SELECT @dcPayMasterSAId = dcPayMasterSAId FROM dcPayDetailSA WHERE dcPayDetailSAId = @dcPayDetailSAId
		IF EXISTS(SELECT 'X' FROM dcPayDetailSA WITH(NOLOCK) WHERE dcPayDetailSAId = @dcPayDetailSAId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM dcPayDetailSA WHERE dcPayDetailSAId = @dcPayDetailSAId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterSAId
			RETURN
		END
			INSERT INTO dcPayDetailSAHistory(
					 dcPayDetailSAId
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
					 dcPayDetailSAId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dcPayDetailSA
				WHERE dcPayDetailSAId = @dcPayDetailSAId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterSAId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcPayDetailSAId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcPayDetailSAId = ISNULL(mode.dcPayDetailSAId, main.dcPayDetailSAId)
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
											(mode.dcPayDetailSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcPayDetailSA main WITH(NOLOCK)
					LEFT JOIN dcPayDetailSAHistory mode ON main.dcPayDetailSAId = mode.dcPayDetailSAId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dcPayMasterSAId = ' + CAST (@dcPayMasterSAId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dcPayDetailSAId
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
			SELECT 'X' FROM dcPayDetailSA WITH(NOLOCK)
			WHERE dcPayDetailSAId = @dcPayDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayDetailSA WITH(NOLOCK)
			WHERE dcPayDetailSAId = @dcPayDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayDetailSAId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcPayDetailSA WHERE approvedBy IS NULL AND dcPayDetailSAId = @dcPayDetailSAId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayDetailSAId
					RETURN
				END
			DELETE FROM dcPayDetailSA WHERE dcPayDetailSAId =  @dcPayDetailSAId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayDetailSAId
					RETURN
				END
				DELETE FROM dcPayDetailSAHistory WHERE dcPayDetailSAId = @dcPayDetailSAId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcPayDetailSAId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcPayDetailSA WITH(NOLOCK)
			WHERE dcPayDetailSAId = @dcPayDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayDetailSA WITH(NOLOCK)
			WHERE dcPayDetailSAId = @dcPayDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayDetailSA WHERE approvedBy IS NULL AND dcPayDetailSAId = @dcPayDetailSAId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcPayDetailSAHistory WHERE dcPayDetailSAId = @dcPayDetailSAId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcPayDetailSA SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcPayDetailSAId = @dcPayDetailSAId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailSAId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcPayDetailSA main
				INNER JOIN dcPayDetailSAHistory mode ON mode.dcPayDetailSAId = main.dcPayDetailSAId
				WHERE mode.dcPayDetailSAId = @dcPayDetailSAId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcPayDetailSA', 'dcPayDetailSAId', @dcPayDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayDetailSAId, @oldValue OUTPUT
				UPDATE dcPayDetailSA SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcPayDetailSAId = @dcPayDetailSAId
			END
			
			UPDATE dcPayDetailSAHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcPayDetailSAId = @dcPayDetailSAId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayDetailSAId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcPayDetailSAId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dcPayDetailSAId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcPayDetailSAId
END CATCH


GO
