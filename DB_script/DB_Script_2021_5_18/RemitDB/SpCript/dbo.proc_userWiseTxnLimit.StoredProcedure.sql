USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userWiseTxnLimit]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_userWiseTxnLimit]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@limitId							INT				= NULL
	,@userId                            INT				= NULL
	,@sendPerDay                        MONEY			= NULL
	,@sendPerTxn						MONEY			= NULL
	,@payPerDay							MONEY           = NULL
	,@payPerTxn							MONEY			= NULL
	,@sendTodays						MONEY			= NULL
	,@payTodays							MONEY			= NULL
	,@cancelPerDay						MONEY			= NULL
	,@cancelPerTxn						MONEY			= NULL
	,@cancelTodays						MONEY			= NULL
	,@userName							VARCHAR(200)	= NULL
	,@agentName							VARCHAR(200)	= NULL
	,@createdBy							VARCHAR(100)	= NULL
	,@approvedBy						VARCHAR(100)	= NULL
	,@haschanged						CHAR(1)			= NULL
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
		 @sql					VARCHAR(MAX)
		,@oldValue				VARCHAR(MAX)
		,@newValue				VARCHAR(MAX)
		,@module				VARCHAR(10)
		,@tableAlias			VARCHAR(100)
		,@logIdentifier			VARCHAR(50)
		,@logParamMod			VARCHAR(100)
		,@logParamMain			VARCHAR(100)
		,@table					VARCHAR(MAX)
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@functionId			INT
		,@id					VARCHAR(10)
		,@modType				VARCHAR(6)
		,@ApprovedFunctionId	INT
	SELECT
		 @functionId = 20231200
		,@logIdentifier = 'limitId'
		,@logParamMain = 'userWiseTxnLimit'
		,@logParamMod = 'userWiseTxnLimitHistory'
		,@module = '20'
		,@tableAlias = 'User Wise Transaction Limit'
		,@ApprovedFunctionId = 20231230

	
	IF @flag IN ('s')
	BEGIN
		SET @table = '(
		
				SELECT
						 limitId				= ISNULL(mode.limitId, main.limitId)
						,userId					= ISNULL(mode.userId,main.userId)
						,sendPerDay				= ISNULL(mode.sendPerDay,main.sendPerDay)
						,sendPerTxn				= ISNULL(mode.sendPerTxn,main.sendPerTxn)
						,sendTodays				= ISNULL(mode.sendTodays,main.sendTodays)
						,payPerDay				= ISNULL(mode.payPerDay,main.payPerDay)
						,payPerTxn				= ISNULL(mode.payPerTxn,main.payPerTxn)
						,payTodays				= ISNULL(mode.payTodays,main.payTodays)
						,cancelPerDay			= ISNULL(mode.cancelPerDay,main.cancelPerDay)
						,cancelPerTxn			= ISNULL(mode.cancelPerTxn,main.cancelPerTxn)
						,cancelTodays			= ISNULL(mode.cancelTodays,main.cancelTodays)
						,main.createdBy
						,main.createdDate			
						,modifiedDate			= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,modifiedBy				= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,hasChanged				= CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.limitId IS NOT NULL and mode.approvedBy is null) THEN ''Y'' ELSE ''N'' END
					FROM userWiseTxnLimit main WITH(NOLOCK)
					LEFT JOIN userWiseTxnLimitHistory mode ON main.limitId = mode.limitId AND mode.approvedBy IS NULL
						AND ( mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
								
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
				) '
	
	END	
	
	IF @flag = 'i'
	BEGIN

		IF EXISTS(SELECT 'X' FROM userWiseTxnLimit WHERE userId = @userId AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			--SELECT * FROM userWiseTxnLimit
			INSERT INTO userWiseTxnLimit(
				 userId
				,sendPerDay
				,sendPerTxn
				,payPerDay
				,payPerTxn
				,cancelPerDay
				,cancelPerTxn
				,createdBy
				,createdDate
			)
			SELECT
				 @userId
				,@sendPerDay
				,@sendPerTxn
				,@payPerDay
				,@payPerTxn
				,@cancelPerDay
				,@cancelPerTxn
				,@user
				,GETDATE()
				
			SET @limitId = SCOPE_IDENTITY()
			
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @limitId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM userWiseTxnLimitHistory WITH(NOLOCK) WHERE limitId = @limitId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			SELECT * FROM userWiseTxnLimitHistory WITH(NOLOCK) WHERE limitId= @limitId
		END
		ELSE
		BEGIN
			SELECT  limitId,
					userId,
					isnull(sendPerDay,0) sendPerDay,
					isnull(sendPerTxn,0) sendPerTxn,
					ISNULL(sendTodays,0) sendTodays,
					ISNULL(payPerDay,0) payPerDay,
					ISNULL(payPerTxn,0) payPerTxn,
					ISNULL(payTodays,0) payTodays,
					ISNULL(cancelPerDay,0) cancelPerDay,
					ISNULL(cancelPerTxn,0) cancelPerTxn,
					ISNULL(cancelTodays,0) cancelTodays 
		FROM userWiseTxnLimit WITH(NOLOCK) WHERE limitId = @limitId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM userWiseTxnLimit WITH(NOLOCK) WHERE limitId = @limitId AND ( createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @limitId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM userWiseTxnLimitHistory WITH(NOLOCK) WHERE limitId  = @limitId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @limitId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM userWiseTxnLimit WHERE approvedBy IS NULL AND limitId  = @limitId AND createdBy = @user)
			BEGIN
				--SELECT * FROM userWiseTxnLimit
				UPDATE userWiseTxnLimit SET
					 userId								= @userId
					,sendPerDay							= @sendPerDay
					,sendPerTxn							= @sendPerTxn
					,payPerDay							= @payPerDay
					,payPerTxn							= @payPerTxn
					,cancelPerDay						= @cancelPerDay
					,cancelPerTxn						= @cancelPerTxn
				WHERE limitId = @limitId
			END
			ELSE
			BEGIN
				--DELETE FROM userWiseTxnLimitHistory WHERE limitId = @limitId
				--select * from userWiseTxnLimitHistory
				INSERT INTO userWiseTxnLimitHistory(
					 limitId
					,userId
					,sendPerDay
					,sendPerTxn
					,payPerDay
					,payPerTxn
					,cancelPerDay
					,cancelPerTxn
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @limitId
					,@userId
					,@sendPerDay
					,@sendPerTxn
					,@payPerDay
					,@payPerTxn					
					,@cancelPerDay
					,@cancelPerTxn
					,@user
					,GETDATE()
					,'U'
					
				SET @modType = 'update'

			END
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @limitId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (SELECT 'X' FROM userWiseTxnLimit WITH(NOLOCK) WHERE limitId = @limitId  AND (createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @limitId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM userWiseTxnLimitHistory  WITH(NOLOCK) WHERE limitId = @limitId AND approvedBy IS NULL and createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.',  @limitId
			RETURN
		END
		
		BEGIN TRANSACTION
		IF EXISTS (SELECT 'X' FROM userWiseTxnLimit WITH(NOLOCK) WHERE limitId = @limitId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM userWiseTxnLimit WHERE limitId = @limitId
		END
		ELSE
		BEGIN
			INSERT INTO userWiseTxnLimitHistory(
				 limitId
				,userId
				,sendPerDay
				,sendPerTxn
				,payPerDay
				,payPerTxn
				,cancelPerDay
				,cancelPerTxn
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 @limitId
				,@userId
				,@sendPerDay
				,@sendPerTxn
				,@payPerDay
				,@payPerTxn
				,@cancelPerDay
				,@cancelPerTxn
				,@user
				,GETDATE()
				,'D'
			SET @modType = 'delete'

		END

		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @limitId
	END

	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'limitId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
			

		SET @table = '(
				SELECT
					 main.limitId
					,au.userId
					,name = ISNULL(au.firstName, '''') + ISNULL( '' '' + au.middleName, '''')+ ISNULL( '' '' + au.lastName, '''')
					,au.userName
					,sendPerDay = ISNULL(CAST(main.sendPerDay AS VARCHAR), ''0'')
					,sendPerTxn = ISNULL(CAST(main.sendPerTxn AS VARCHAR), ''0'')
					,sendTodays	= ISNULL(CAST(main.sendTodays AS VARCHAR), ''0'')
					,payPerDay	= ISNULL(CAST(main.payPerDay AS VARCHAR), ''0'')
					,payPerTxn	= ISNULL(CAST(main.payPerTxn AS VARCHAR), ''0'')
					,payTodays	= ISNULL(CAST(main.payTodays AS VARCHAR), ''0'')
					,cancelPerDay	= ISNULL(CAST(main.cancelPerDay AS VARCHAR), ''0'')
					,cancelPerTxn	= ISNULL(CAST(main.cancelPerTxn AS VARCHAR), ''0'')
					,cancelTodays	= ISNULL(CAST(main.cancelTodays AS VARCHAR), ''0'')
					,haschanged = ISNULL(main.hasChanged, ''N'')
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
				FROM applicationUsers au
				LEFT JOIN ' + @table + ' main ON au.userId = main.userId 
				WHERE au.agentId = dbo.FNAGetHOAgentId()
				) x'
			
		--PRINT (@table)
		SET @sql_filter = ''
		
		IF (@haschanged is null and @userName is null and @userId is null)
		BEGIN
			SET @sql_filter = @sql_filter + ' AND 1=2'
		END		
		ELSE
		BEGIN
			IF @userName IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND  ISNULL(userName, '''') LIKE ''%' + @userName + '%'''
				
			IF @userId IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ISNULL(userId, '''') = ''' + CAST(@userId AS VARCHAR) + '''' 
				
			IF @haschanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + CAST(@haschanged AS VARCHAR) + ''''
		END
		
		SET @select_field_list ='
				limitId              
			   ,userId
			   ,name
			   ,userName
			   ,sendPerDay               
			   ,sendPerTxn
			   ,sendTodays
			   ,payPerDay
			   ,payPerTxn
			   ,payTodays
			   ,cancelPerDay
			   ,cancelPerTxn
			   ,cancelTodays
			   ,haschanged
			   ,createdBy
			   ,createdDate
			   ,modifiedBy
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
	
	ELSE IF @flag = 's1'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'rowid'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
			

		SET @table = '
					(
		SELECT		
					rowid,	
					isnull(sendPerDay,0) sendPerDay,
					isnull(sendPerTxn,0) sendPerTxn,
					ISNULL(payPerDay,0) payPerDay,
					ISNULL(payPerTxn,0) payPerTxn,
					ISNULL(cancelPerDay,0) cancelPerDay,
					ISNULL(cancelPerTxn,0) cancelPerTxn,
					createdBy,
					createdDate,
					approvedBy,
					approveddate,
					hasChanged=''N'',
					modifiedBy=''''
		FROM userWiseTxnLimitHistory WITH(NOLOCK) 
		WHERE userId = '+CAST(@userId AS VARCHAR)+' and approvedDate is not null)x'

			
		SET @sql_filter = ''		
		IF @createdBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND  createdBy LIKE ''%' + @createdBy + '%'''
			
		IF @approvedBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND approvedBy LIKE ''%' + @approvedBy + '%'''
			
		SET @select_field_list ='
				rowid              
			   ,sendPerDay
			   ,sendPerTxn
			   ,payPerDay
			   ,payPerTxn               
			   ,cancelPerDay
			   ,cancelPerTxn
			   ,createdBy
			   ,createdDate
			   ,approvedBy
			   ,approveddate
			   ,hasChanged
			   ,modifiedBy
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
		IF NOT EXISTS (SELECT 'X' FROM userWiseTxnLimit WITH(NOLOCK) WHERE limitId = @limitId and approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM userWiseTxnLimitHistory WITH(NOLOCK) WHERE limitId = @limitId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @limitId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM userWiseTxnLimit WHERE approvedBy IS NULL AND limitId = @limitId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @limitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @limitId
					RETURN
				END
			DELETE FROM userWiseTxnLimit WHERE limitId=  @limitId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @limitId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @limitId
					RETURN
				END
				DELETE FROM userWiseTxnLimitHistory WHERE limitId = @limitId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @limitId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM userWiseTxnLimit WITH(NOLOCK) WHERE limitId = @limitId AND approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM userWiseTxnLimitHistory WITH(NOLOCK) WHERE limitId = @limitId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @limitId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM userWiseTxnLimit WHERE approvedBy IS NULL AND limitId = @limitId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM userWiseTxnLimitHistory WHERE limitId = @limitId AND approvedBy IS NULL
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE userWiseTxnLimit SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE limitId = @limitId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				
				UPDATE main SET
					 main.userId                        = mode.userId
					,main.sendPerDay					= mode.sendPerDay
					,main.sendPerTxn                    = mode.sendPerTxn
					,main.payPerDay						= mode.payPerDay
					,main.payPerTxn						= mode.payPerTxn
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM userWiseTxnLimit main
				INNER JOIN userWiseTxnLimitHistory mode ON mode.limitId = main.limitId
				WHERE mode.limitId = @limitId AND mode.approvedBy IS NULL
				
			
				EXEC [dbo].proc_GetColumnToRow  'userWiseTxnLimit', 'limitId', @limitId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @limitId, @oldValue OUTPUT
				UPDATE userWiseTxnLimit SET
					 isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
				
				WHERE limitId = @limitId
				
				UPDATE au SET
					 au.balance = NULL
				FROM applicationUsers au 
				INNER JOIN userWiseTxnLimit main ON au.userId = main.userId
				WHERE main.limitId = @limitId
			END
			
			UPDATE userWiseTxnLimitHistory SET
				 approvedBy			= @user
				,approvedDate		= GETDATE()
			WHERE limitId = @limitId AND approvedBy IS NULL
			
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @limitId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @limitId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @limitId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @limitId
END CATCH


GO
