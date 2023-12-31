USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_topUpLimitInt]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_topUpLimitInt]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@tulId                             VARCHAR(30)		= NULL
	,@userId                            INT				= NULL
	,@currency                          INT				= NULL
	,@limitPerDay                       MONEY			= NULL
	,@perTopUpLimit						MONEY           = NULL
	,@userName							VARCHAR(50)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@haschanged						VARCHAR(20)		= NULL
	,@hasLimit							VARCHAR(20)		= NULL


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
		 @functionId = 20221300
		,@logIdentifier = 'tulId'
		,@logParamMain = 'topUpLimitInt'
		,@logParamMod = 'topUpLimitIntMod'
		,@module = '20'
		,@tableAlias = 'User Top-Up Limit'
		,@ApprovedFunctionId = 20221330
	
	DECLARE  @maxLimit MONEY = 0
			,@agentCountry INT
	
	IF @flag = 'cla'			--Credit Limit Authority
	BEGIN
		SELECT @userId = userId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user AND ISNULL(isDeleted, 'N') = 'N'
		SELECT 
			 limitPerDay = ISNULL(limitPerDay, 0)
			,perTopUpLimit = ISNULL(perTopUpLimit, 0)
			,currency = cm.currencyCode
		FROM topUpLimitInt tul WITH(NOLOCK)
		INNER JOIN currencyMaster cm WITH(NOLOCK) ON tul.currency = cm.currencyId
		WHERE userId = @userId
		AND tul.currency = 1
		AND ISNULL(tul.isDeleted, 'N') = 'N'
		
		SELECT 
			 limitPerDay = ISNULL(limitPerDay, 0)
			,perTopUpLimit = ISNULL(perTopUpLimit, 0)
			,currency = cm.currencyCode
		FROM topUpLimitInt tul WITH(NOLOCK)
		INNER JOIN currencyMaster cm WITH(NOLOCK) ON tul.currency = cm.currencyId
		WHERE userId = @userId
		AND tul.currency = 2
		AND ISNULL(tul.isDeleted, 'N') = 'N'
	END	

	IF @flag IN ('s')
	BEGIN
		SET @table = '(
					SELECT
						 tulId				= ISNULL(mode.tulId, main.tulId)
						,userId				= ISNULL(mode.userId,main.userId)
						,limitPerDay			= ISNULL(mode.limitPerDay,main.limitPerDay)
						,currency			= ISNULL(mode.currency,main.currency)
						,perTopUpLimit			= ISNULL(mode.perTopUpLimit,main.perTopUpLimit)
						,main.createdBy
						,main.createdDate			
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.tulId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END

						,hasLimit = CASE WHEN main.userId IS not NULL
											THEN ''Y'' ELSE ''N'' END
					FROM topUpLimitInt main WITH(NOLOCK)
					LEFT JOIN topUpLimitIntMod mode ON main.tulId = mode.tulId 
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
				) '
	
	END	
	
	IF @flag = 'i'
	BEGIN
		IF(@perTopUpLimit > @limitPerDay)
		BEGIN
			EXEC proc_errorHandler 1, 'Per Top Up Limit exceeded the Total Limit Amount Per day', @id
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM topUpLimitInt WHERE userId = @userId AND currency = @currency AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO topUpLimitInt (
				 userId
				,limitPerDay
				,currency
				,perTopUpLimit
				,createdBy
				,createdDate
			)
			SELECT
				 @userId
				,@limitPerDay
				,@currency
				,@perTopUpLimit
				,@user
				,GETDATE()
			SET @id = SCOPE_IDENTITY()
			
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @tulId
	END

	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM topUpLimitIntMod WITH(NOLOCK) WHERE tulId = @tulId AND createdBy = @user)
		BEGIN
			SELECT 
				* 
			FROM topUpLimitIntMod WITH(NOLOCK) WHERE tulId= @tulId
		END
		ELSE
		BEGIN
			SELECT 
				* 
			FROM topUpLimitInt WITH(NOLOCK) WHERE tulId = @tulId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM topUpLimitInt WITH(NOLOCK) WHERE tulId = @tulId AND ( createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @tulId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM topUpLimitIntMod WITH(NOLOCK) WHERE tulId  = @tulId AND createdBy<> @user)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @tulId
			RETURN
		END
		IF(@perTopUpLimit > @limitPerDay)
		BEGIN
			EXEC proc_errorHandler 1, 'Per Top Up Limit exceeded the Total Limit Amount Per day', @id
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM topUpLimitInt WHERE approvedBy IS NULL AND tulId  = @tulId AND createdBy = @user)
			BEGIN
				UPDATE topUpLimitInt SET
					 userId                         = @userId
					,limitPerDay                    = @limitPerDay
					,currency                       = @currency
					,perTopUpLimit                  = @perTopUpLimit
				WHERE tulId = @tulId
			END
			ELSE
			BEGIN

				DELETE FROM topUpLimitIntMod WHERE tulId = @tulId				
				INSERT INTO topUpLimitIntMod(
					 tulId
					,userId
					,limitPerDay
					,currency
					,perTopUpLimit
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @tulId
					,@userId
					,@limitPerDay
					,@currency
					,@perTopUpLimit
					,@user
					,GETDATE()
					,'U'					
				SET @modType = 'update'

			END
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @tulId
	END

	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (SELECT 'X' FROM topUpLimitInt WITH(NOLOCK) WHERE tulId = @tulId  AND (createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @tulId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM topUpLimitIntMod  WITH(NOLOCK) WHERE tulId = @tulId and createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.',  @tulId
			RETURN
		END
		
		BEGIN TRANSACTION
		IF EXISTS (SELECT 'X' FROM topUpLimitInt WITH(NOLOCK) WHERE tulId = @tulId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM topUpLimitInt WHERE tulId = @tulId
		END
		ELSE
		BEGIN
			INSERT INTO topUpLimitIntMod(
				 tulId
				,userId
				,limitPerDay
				,currency
				,perTopUpLimit
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 @tulId
				,@userId
				,@limitPerDay
				,@currency
				,@perTopUpLimit
				,@user
				,GETDATE()
				,'D'
			SET @modType = 'delete'

		END

		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @tulId
	END


	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'tulId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.tulId
					,au.userId
					,name = ISNULL(au.firstName, '''') + ISNULL( '' '' + au.middleName, '''')+ ISNULL( '' '' + au.lastName, '''')
					,au.userName
					,limitPerDay = ISNULL(CAST(main.limitPerDay AS VARCHAR), ''N/A'')
					,main.currency
					,currencyName = ISNULL(curr.currencyCode, ''N/A'')
					,perTopUpLimit = ISNULL(CAST(main.perTopUpLimit AS VARCHAR), ''N/A'')
					,main.haschanged
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
					,hasLimit =  isnull(main.hasLimit,''N'')
				FROM applicationUsers au
				LEFT JOIN ' + @table + ' main ON au.userId = main.userId 
				LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId
				WHERE au.agentId = dbo.FNAGetHOAgentId()
				) x'
		SET @sql_filter = ''		
		PRINT (@table)
		
		IF @userName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND  ISNULL(userName, '''') LIKE ''%' + @userName + '%'''
			
		IF @userId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userId, '''') = ''' + CAST(@userId AS VARCHAR) + '''' 
		
		IF @haschanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''

		IF @hasLimit IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasLimit = ''' + CAST(@hasLimit AS VARCHAR) + ''''

		SET @select_field_list ='
				tulId              
			   ,userId
			   ,name
			   ,userName
			   ,limitPerDay               
			   ,currency
			   ,currencyName
			   ,perTopUpLimit
			   ,haschanged
			   ,createdBy
			   ,createdDate
			   ,modifiedBy
			   ,hasLimit
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
		IF NOT EXISTS (SELECT 'X' FROM topUpLimitInt WITH(NOLOCK) WHERE tulId = @tulId and approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM topUpLimitIntMod WITH(NOLOCK) WHERE tulId = @tulId)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @tulId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM topUpLimitInt WHERE approvedBy IS NULL AND tulId = @tulId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @tulId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @tulId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @tulId
					RETURN
				END
			DELETE FROM topUpLimitInt WHERE tulId=  @tulId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @tulId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @tulId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @tulId
					RETURN
				END
				DELETE FROM topUpLimitIntMod WHERE tulId = @tulId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @tulId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM topUpLimitInt WITH(NOLOCK) WHERE tulId = @tulId AND approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM topUpLimitIntMod WITH(NOLOCK) WHERE tulId = @tulId)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @tulId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM topUpLimitInt WHERE approvedBy IS NULL AND tulId = @tulId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM topUpLimitIntMod WHERE tulId = @tulId
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE topUpLimitInt SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE tulId = @tulId
				
				UPDATE au SET
					au.balance = main.limitPerDay
				FROM applicationUsers au
				INNER JOIN topUpLimitInt main ON au.userId = main.userId
				WHERE main.tulId = @tulId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @tulId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @tulId, @oldValue OUTPUT
				
				UPDATE main SET
					 main.userId                        = mode.userId
					,main.limitPerDay                   = mode.limitPerDay
					,main.currency                      = mode.currency
					,main.perTopUpLimit                 = mode.perTopUpLimit
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM topUpLimitInt main
				INNER JOIN topUpLimitIntMod mode ON mode.tulId = main.tulId
				WHERE mode.tulId = @tulId
				
				UPDATE au SET
					au.balance = mode.limitPerDay
				FROM applicationUsers au
				INNER JOIN topUpLimitIntMod mode ON au.userId = mode.userId
				WHERE mode.tulId = @tulId
				
				EXEC [dbo].proc_GetColumnToRow  'topUpLimit', 'tulId', @tulId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @tulId, @oldValue OUTPUT
				UPDATE topUpLimitInt SET
					 isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
				
				WHERE tulId = @tulId
				
				UPDATE au SET
					 au.balance = NULL
				FROM applicationUsers au 
				INNER JOIN topUpLimitInt main ON au.userId = main.userId
				WHERE main.tulId = @tulId
			END
			
			DELETE FROM topUpLimitIntMod WHERE tulId = @tulId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @tulId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @tulId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @tulId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @tulId
END CATCH


GO
