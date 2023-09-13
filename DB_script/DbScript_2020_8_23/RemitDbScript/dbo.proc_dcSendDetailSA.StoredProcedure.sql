USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcSendDetailSA]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcSendDetailSA]
	 @flag                              VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@dcSendDetailSAId                  VARCHAR(30)    = NULL
	,@dcSendMasterSAId                  INT            = NULL
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
		 @ApprovedFunctionId = 20191030
		,@logIdentifier = 'dcSendDetailSAId'
		,@logParamMain = 'dcSendDetailSA'
		,@logParamMod = 'dcSendDetailSAHistory'
		,@module = '20'
		,@tableAlias = 'Default Super Agent Send Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dcSendDetailSA
				WHERE dcSendMasterSAId = '+ CAST(ISNULL(@dcSendMasterSAId, 0) AS VARCHAR) + '					
				AND dcSendDetailSAId <> ' + CAST(ISNULL(@dcSendDetailSAId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dcSendDetailSAId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@maxAmt < @minAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcSendDetailSAId
			RETURN	
		END
	END	
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSAHistory WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcSendDetailSA (
				 dcSendMasterSAId
				,fromAmt
				,toAmt
				,pcnt
				,minAmt
				,maxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dcSendMasterSAId
				,@fromAmt
				,@toAmt
				,@pcnt
				,@minAmt
				,@maxAmt
				,@user
				,GETDATE()
				
				
			SET @dcSendDetailSAId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcSendDetailSAId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailSAHistory WITH(NOLOCK)
				WHERE dcSendDetailSAId = @dcSendDetailSAId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcSendDetailSAHistory mode WITH(NOLOCK)
			INNER JOIN dcSendDetailSA main WITH(NOLOCK) ON mode.dcSendDetailSAId = main.dcSendDetailSAId
			WHERE mode.dcSendDetailSAId= @dcSendDetailSAId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcSendDetailSA WITH(NOLOCK) WHERE dcSendDetailSAId = @dcSendDetailSAId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSAHistory WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailSA WITH(NOLOCK)
			WHERE dcSendDetailSAId = @dcSendDetailSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailSAHistory WITH(NOLOCK)
			WHERE dcSendDetailSAId  = @dcSendDetailSAId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendDetailSA WHERE approvedBy IS NULL AND dcSendDetailSAId  = @dcSendDetailSAId)			
			BEGIN				
				UPDATE dcSendDetailSA SET
				 dcSendMasterSAId = @dcSendMasterSAId
				,fromAmt = @fromAmt
				,toAmt = @toAmt
				,pcnt = @pcnt
				,minAmt = @minAmt
				,maxAmt = @maxAmt
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE dcSendDetailSAId = @dcSendDetailSAId			
			END
			ELSE
			BEGIN
				DELETE FROM dcSendDetailSAHistory WHERE dcSendDetailSAId = @dcSendDetailSAId AND approvedBy IS NULL
				INSERT INTO dcSendDetailSAHistory(
					 dcSendDetailSAId
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
					 @dcSendDetailSAId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcSendDetailSAId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSAHistory WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailSA WITH(NOLOCK)
			WHERE dcSendDetailSAId = @dcSendDetailSAId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendDetailSAHistory  WITH(NOLOCK)
			WHERE dcSendDetailSAId = @dcSendDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcSendDetailSAId
			RETURN
		END
		SELECT @dcSendMasterSAId = dcSendMasterSAId FROM dcSendDetailSA WHERE dcSendDetailSAId = @dcSendDetailSAId
		IF EXISTS(SELECT 'X' FROM dcSendDetailSA WITH(NOLOCK) WHERE dcSendDetailSAId = @dcSendDetailSAId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM dcSendDetailSA WHERE dcSendDetailSAId = @dcSendDetailSAId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterSAId
			RETURN
		END
			INSERT INTO dcSendDetailSAHistory(
					 dcSendDetailSAId
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
					 dcSendDetailSAId
					,fromAmt
					,toAmt
					,pcnt
					,minAmt
					,maxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dcSendDetailSA
				WHERE dcSendDetailSAId = @dcSendDetailSAId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterSAId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendDetailSAId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcSendDetailSAId = ISNULL(mode.dcSendDetailSAId, main.dcSendDetailSAId)
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
											(mode.dcSendDetailSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcSendDetailSA main WITH(NOLOCK)
					LEFT JOIN dcSendDetailSAHistory mode ON main.dcSendDetailSAId = mode.dcSendDetailSAId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dcSendMasterSAId = ' + CAST (@dcSendMasterSAId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dcSendDetailSAId
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
			SELECT 'X' FROM dcSendDetailSA WITH(NOLOCK)
			WHERE dcSendDetailSAId = @dcSendDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendDetailSA WITH(NOLOCK)
			WHERE dcSendDetailSAId = @dcSendDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendDetailSAId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcSendDetailSA WHERE approvedBy IS NULL AND dcSendDetailSAId = @dcSendDetailSAId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendDetailSAId
					RETURN
				END
			DELETE FROM dcSendDetailSA WHERE dcSendDetailSAId =  @dcSendDetailSAId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendDetailSAId
					RETURN
				END
				DELETE FROM dcSendDetailSAHistory WHERE dcSendDetailSAId = @dcSendDetailSAId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcSendDetailSAId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcSendDetailSA WITH(NOLOCK)
			WHERE dcSendDetailSAId = @dcSendDetailSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendDetailSA WITH(NOLOCK)
			WHERE dcSendDetailSAId = @dcSendDetailSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendDetailSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendDetailSA WHERE approvedBy IS NULL AND dcSendDetailSAId = @dcSendDetailSAId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcSendDetailSAHistory WHERE dcSendDetailSAId = @dcSendDetailSAId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcSendDetailSA SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcSendDetailSAId = @dcSendDetailSAId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailSAId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt = mode.fromAmt
					,main.toAmt =  mode.toAmt
					,main.pcnt =  mode.pcnt
					,main.minAmt =  mode.minAmt
					,main.maxAmt =  mode.maxAmt
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcSendDetailSA main
				INNER JOIN dcSendDetailSAHistory mode ON mode.dcSendDetailSAId = main.dcSendDetailSAId
				WHERE mode.dcSendDetailSAId = @dcSendDetailSAId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcSendDetailSA', 'dcSendDetailSAId', @dcSendDetailSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendDetailSAId, @oldValue OUTPUT
				UPDATE dcSendDetailSA SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcSendDetailSAId = @dcSendDetailSAId
			END
			
			UPDATE dcSendDetailSAHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcSendDetailSAId = @dcSendDetailSAId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendDetailSAId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcSendDetailSAId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dcSendDetailSAId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcSendDetailSAId
END CATCH



GO
