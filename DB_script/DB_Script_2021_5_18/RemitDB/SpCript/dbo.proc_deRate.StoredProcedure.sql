USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_deRate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_deRate]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@deRateId                          VARCHAR(30)		= NULL
	,@hub                               INT				= NULL
	,@country                           INT				= NULL
	,@baseCurrency                      INT				= NULL
	,@localCurrency                     INT				= NULL
	,@cost                              MONEY			= NULL
	,@margin                            MONEY			= NULL
	,@ve								MONEY			= NULL
	,@ne								MONEY			= NULL
	,@spFlag                            CHAR(1)			= NULL
	,@hasChanged                        CHAR(1)			= NULL
	,@isEnable                          CHAR(1)			= NULL
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
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
		
	SELECT
		 @logIdentifier = 'deRateId'
		,@logParamMain = 'deRate'
		,@logParamMod = 'deRateHistory'
		,@module = '20'
		,@tableAlias = 'Default Ex-Rate'
		,@ApprovedFunctionId = CASE  @spFlag WHEN  'P' THEN 20111230 WHEN 'S' THEN 20111030  ELSE  0 END

	IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'deRateId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'	
		   
		DECLARE @m VARCHAR(MAX)
		SET @m = '(
					SELECT
						 deRateId = ISNULL(mode.deRateId, main.deRateId)
						,hub = ISNULL(mode.hub, main.hub)
						,country = ISNULL(mode.country, main.country)
						,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
						,localCurrency = ISNULL(mode.localCurrency, main.localCurrency)					
						,cost = ISNULL(mode.cost, main.cost)
						,margin = ISNULL(mode.margin, main.margin)	
						,ve = ISNULL(mode.ve, main.ve)
						,ne = ISNULL(mode.ne, main.ne)				
						,spFlag = ISNULL(mode.spFlag, main.spFlag)
						,isEnable = ISNULL(mode.isEnable, main.isEnable)					
						,main.createdBy
						,main.createdDate
						,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR (mode.deRateId IS NOT NULL) THEN ''Y'' ELSE ''N'' END
					FROM deRate main WITH(NOLOCK)
					LEFT JOIN deRateHistory mode ON main.deRateId = mode.deRateId AND mode.approvedBy IS NULL				
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
						AND main.spFlag = ''' + @spFlag + '''
				) '
				
					
		SET @table = '(
						SELECT
							 main.deRateId			
							,main.hub
							,hubName = am.agentName
							,main.country
							,countryName = c.countryName
							,main.baseCurrency
							,baseCurrencyName = bc.currencyCode
							,main.localCurrency
							,localCurrencyName = lc.currencyCode
							,main.cost
							,main.margin
							,main.ve
							,main.ne
							,offer = CASE WHEN main.spFlag = ''S'' THEN main.cost + main.margin ELSE
												main.cost - main.margin END
							,main.spFlag
							,main.isEnable	
							,main.modifiedBy
							,main.hasChanged				
						FROM ' + @m + ' main		
						LEFT JOIN agentMaster am WITH(NOLOCK) ON main.hub = am.agentId
						LEFT JOIN countryMaster c WITH(NOLOCK) ON main.country = c.countryId
						LEFT JOIN currencyMaster bc WITH(NOLOCK) ON main.baseCurrency = bc.currencyId
						LEFT JOIN currencyMaster lc WITH(NOLOCK) ON main.localCurrency = lc.currencyId
				) x'
			
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @hub IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hub = ' + CAST(@hub AS VARCHAR(50))
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @country IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND country = ' + CAST(@country AS VARCHAR(50))
		
		IF @baseCurrency IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND baseCurrency = ' + CAST(@baseCurrency AS VARCHAR(50))
		
		IF @localCurrency IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND localCurrency = ' + CAST(@localCurrency AS VARCHAR(50))
		
				
		SET @select_field_list = '
			 deRateId			
			,hub
			,hubName
			,country
			,countryName
			,baseCurrency
			,baseCurrencyName
			,localCurrency
			,localCurrencyName
			,cost
			,margin
			,ve
			,ne
			,offer
			,spFlag
			,isEnable
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
			
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM deRate WHERE hub = @hub AND country = @country AND spFlag = @spFlag)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', @deRateId
			RETURN
		END		
		BEGIN TRANSACTION
			INSERT INTO deRate (
				 hub
				,country
				,baseCurrency
				,localCurrency
				,cost
				,margin
				,ve
				,ne
				,spFlag
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @hub
				,@country
				,@baseCurrency
				,@localCurrency
				,@cost
				,@margin
				,@ve
				,@ne
				,@spFlag
				,@isEnable
				,@user
				,GETDATE()
				
				
			SET @deRateId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @deRateId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM deRateHistory WITH(NOLOCK)
				WHERE deRateId = @deRateId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM deRateHistory mode WITH(NOLOCK)
			INNER JOIN deRate main WITH(NOLOCK) ON mode.deRateId = main.deRateId
			WHERE mode.deRateId= @deRateId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM deRate WITH(NOLOCK) WHERE deRateId = @deRateId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM deRate WITH(NOLOCK)
			WHERE deRateId = @deRateId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @deRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM deRateHistory WITH(NOLOCK)
			WHERE deRateId  = @deRateId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @deRateId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM deRate WHERE approvedBy IS NULL AND deRateId  = @deRateId)			
			BEGIN				
				UPDATE deRate SET
					 hub = @hub
					,country = @country
					,baseCurrency = @baseCurrency
					,localCurrency = @localCurrency
					,cost = @cost
					,margin = @margin
					,ve = @ve
					,ne = @ne
					,spFlag = @spFlag
					,isEnable = @isEnable
					,modifiedBy = @user
					,modifiedDate = GETDATE()					
				WHERE deRateId = @deRateId			
			END
			ELSE
			BEGIN
				DELETE FROM deRateHistory WHERE deRateId = @deRateId AND approvedBy IS NULL
				INSERT INTO deRateHistory(						
						 deRateId 
						,hub
						,country
						,baseCurrency
						,localCurrency
						,cost
						,margin
						,ve
						,ne
						,spFlag
						,isEnable
						,createdBy
						,createdDate
						,modType
				)
				SELECT
					 @deRateId
					,@hub
					,@country
					,@baseCurrency
					,@localCurrency
					,@cost
					,@margin
					,@ve
					,@ne
					,@spFlag
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @deRateId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM deRate WITH(NOLOCK)
			WHERE deRateId = @deRateId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @deRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM deRateHistory  WITH(NOLOCK)
			WHERE deRateId = @deRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @deRateId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM deRate WITH(NOLOCK) WHERE deRateId = @deRateId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM deRate WHERE deRateId = @deRateId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @deRateId
			RETURN
		END
			INSERT INTO deRateHistory(
				 deRateId 
				,hub
				,country
				,baseCurrency
				,localCurrency
				,cost
				,margin
				,ve
				,ne		
				,spFlag
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 deRateId 
				,hub
				,country
				,baseCurrency
				,localCurrency
				,cost
				,margin	
				,ve		
				,ne
				,spFlag
				,isEnable				
				,@user
				,GETDATE()
				,'D'
			FROM deRate WHERE deRateId = @deRateId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @deRateId
	END


	
	
	ELSE IF @flag IN('reject')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM deRate WITH(NOLOCK)
			WHERE deRateId = @deRateId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM deRate WITH(NOLOCK)
			WHERE deRateId = @deRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @deRateId
			RETURN
		END
		BEGIN TRANSACTION
		IF EXISTS (SELECT 'X' FROM deRate WHERE approvedBy IS NULL AND deRateId = @deRateId)
		BEGIN --New record			
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @deRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @deRateId, @user, @oldValue, @newValue
								
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @deRateId
					RETURN
				END
			DELETE FROM deRate WHERE deRateId =  @deRateId
			
		END
		ELSE
		BEGIN
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @deRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @deRateId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @deRateId
					RETURN
				END
				DELETE FROM deRateHistory WHERE deRateId = @deRateId AND approvedBy IS NULL
			
		END		
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @deRateId
	END

	ELSE IF @flag  IN ('approve')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM deRate WITH(NOLOCK)
			WHERE deRateId = @deRateId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM deRate WITH(NOLOCK)
			WHERE deRateId = @deRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @deRateId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM deRate WHERE approvedBy IS NULL AND deRateId = @deRateId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM deRateHistory WHERE deRateId = @deRateId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE deRate SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE deRateId = @deRateId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @deRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @deRateId, @oldValue OUTPUT
				UPDATE main SET
					 main.hub = mode.hub
					,main.country = mode.country
					,main.baseCurrency = mode.baseCurrency
					,main.localCurrency = mode.localCurrency
					,main.cost = mode.cost
					,main.margin = mode.margin
					,main.ve = mode.ve
					,main.ne = mode.ne				
					,main.spFlag = mode.spFlag
					,main.isEnable = mode.isEnable
					,main.modifiedBy = @user
					,main.modifiedDate = GETDATE()
				FROM deRate main
				INNER JOIN deRateHistory mode ON mode.deRateId = main.deRateId
				WHERE mode.deRateId = @deRateId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'deRate', 'deRateId', @deRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @deRateId, @oldValue OUTPUT
				UPDATE deRate SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE deRateId = @deRateId
			END
			
			UPDATE deRateHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE deRateId = @deRateId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @deRateId, @user, @oldValue, @newValue
			
			
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @deRateId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @deRateId
END CATCH


GO
