USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryCurrencyMaster]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_countryCurrencyMaster]
	 @flag								VARCHAR(50)    = NULL
	,@user                              VARCHAR(30)    = NULL
	,@countryId                        VARCHAR(30)    = NULL
	,@countryName                      VARCHAR(100)   = NULL
	,@countryCode                      VARCHAR(50)    = NULL
	,@currCode                         VARCHAR(20)    = NULL
	,@currName                         VARCHAR(50)    = NULL
	,@currDesc                         VARCHAR(MAX)   = NULL
	,@currDecimalName                 VARCHAR(50)    = NULL
	,@countAfterDecimal               VARCHAR(5)     = NULL
	,@roundNoDecimal                  VARCHAR(5)     = NULL
	,@timeZone                         INT			= NULL
	,@allowedCurrId                   VARCHAR(20)    = NULL
	,@countryRuleId                   VARCHAR(20)    = NULL
	,@countryHolidayId                VARCHAR(20)    = NULL
	,@isActive                         CHAR(3)        = NULL
	,@isDeleted                        CHAR(1)        = NULL
	,@createdDate                       DATETIME       = NULL
	,@createdBy							VARCHAR(100)   = NULL
	,@modifiedDate                      DATETIME       = NULL
	,@modifiedBy                        VARCHAR(100)   = NULL
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
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)
		,@ApprovedFunctionId INT
	SELECT
		 @logIdentifier = 'countryId'
		,@logParamMain = 'countryCurrencyMaster'
		,@tableAlias = 'CountryCurrency'
		,@module = 20
		,@ApprovedFunctionId = 20101230
		
	
	IF @flag = 'cl' -- contry List
	BEGIN
		SELECT [0], [1] FROM (
			SELECT NULL [0], 'All' [1] UNION ALL
			
			SELECT
				 ccm.countryId [0]
				,ccm.countryName [1]
			FROM countryCurrencyMaster ccm WITH (NOLOCK) 
			WHERE 
				ISNULL(ccm.isDeleted, 'N')  <> 'Y' 
				AND ISNULL(ccm.isActive , 'N')  = 'Y' 
		) x ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END	
		RETURN	
	END
	
	IF @flag = 'l' -- contry List for dropdown
	BEGIN		
			
		SELECT
			 ccm.countryId 
			,ccm.countryName 
		FROM countryCurrencyMaster ccm WITH (NOLOCK) 
		WHERE 
			ISNULL(ccm.isDeleted, 'N')  <> 'Y' 
			AND ISNULL(ccm.isActive , 'N')  = 'Y' 
		
		RETURN	
	END
	ELSE IF @flag = 'cul'  -- currency List
	BEGIN
		SELECT [0], [1] FROM (
			SELECT NULL [0], 'All' [1] UNION ALL
			
			SELECT 
				 TOP 100 PERCENT
				 ccm.countryId [0]
				,ccm.currCode [1]
			FROM countryCurrencyMaster ccm WITH (NOLOCK) 
			WHERE 
				ISNULL(ccm.isDeleted, 'N')  <> 'Y' 
				AND ISNULL(ccm.isActive , 'N')  = 'Y' 
		) x ORDER BY CASE WHEN x.[0] IS NULL THEN CAST(x.[0] AS VARCHAR) ELSE x.[1] END	
		RETURN	
	END
	
	ELSE IF @flag = 'cul2'  -- currenty List
	BEGIN		
		SELECT			 
			 ccm.countryId
			,ccm.currCode
		FROM countryCurrencyMaster ccm WITH (NOLOCK) 
		WHERE 
			ISNULL(ccm.isDeleted, 'N')  <> 'Y' 
			AND ISNULL(ccm.isActive , 'N')  = 'Y' 
		ORDER BY ccm.currCode
		RETURN	
	END
	
	ELSE IF @flag IN ('s') 
	BEGIN
		SET @table = '(
					SELECT
						 countryId			= ISNULL(mode.countryId, main.countryId)
						,countryName		= ISNULL(mode.countryName,main.countryName)
						,countryCode		= ISNULL(mode.countryCode,main.countryCode)
						,currCode			= ISNULL(mode.currCode,main.currCode)
						,currName			= ISNULL(mode.currName,main.currName)
						,currDesc			= ISNULL(mode.currDesc,main.currDesc)
						,currDecimalName	= ISNULL(mode.currDecimalName,main.currDecimalName)
						,countAfterDecimal= ISNULL(mode.countAfterDecimal,main.countAfterDecimal)
						,roundNoDecimal	= ISNULL(mode.roundNoDecimal,main.roundNoDecimal)
						,timeZone			= ISNULL(mode.timeZone,main.timeZone)
						,allowedCurrId	= ISNULL(mode.allowedCurrId,main.allowedCurrId)
						,countryRuleId	= ISNULL(mode.countryRuleId,main.countryRuleId)
						,countryHolidayId	= ISNULL(mode.countryHolidayId,main.countryHolidayId)
						,isActive			= ISNULL(mode.isActive,main.isActive)
						,main.createdBy
						,main.createdDate			
						,modifiedDate		= ISNULL(mode.createdDate, main.modifiedDate)
						,modifiedBy			= ISNULL(mode.createdBy, main.modifiedBy)
						,hasChanged = CASE WHEN (main.approvedBy IS NULL AND main.createdBy <> ''' + @user + ''') OR 
												(mode.countryId IS NOT NULL AND mode.createdBy <> ''' + @user + ''') 
											THEN ''Y'' ELSE ''N'' END
					FROM countryCurrencyMaster main WITH(NOLOCK)
					LEFT JOIN countryCurrencyMasterMod mode ON main.countryId = mode.countryId 
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
						AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
				) '
	
	END	
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO countryCurrencyMaster (
				 countryName
				,countryCode
				,currCode
				,currName
				,currDesc
				,currDecimalName
				,countAfterDecimal
				,roundNoDecimal
				,timeZone
				,allowedCurrId
				,countryRuleId
				,countryHolidayId
				,isActive
				,isDeleted
				,createdDate
				,createdBy

			)
			SELECT
				 @countryName
				,@countryCode
				,@currCode
				,@currName
				,@currDesc
				,@currDecimalName
				,@countAfterDecimal
				,@roundNoDecimal
				,@timeZone
				,@allowedCurrId
				,@countryRuleId
				,@countryHolidayId
				,@isActive
				,@isDeleted
				,GETDATE()
				,@user


			SET @countryId = SCOPE_IDENTITY()
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @countryId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId = @countryId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @countryId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM countryCurrencyMasterMod WITH(NOLOCK) WHERE countryId = @countryId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @countryId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId = @countryId AND approvedBy IS NULL AND createdBy = @user)
			BEGIN

				UPDATE countryCurrencyMaster SET
					 countryName                  = @countryName
					,countryCode                  = @countryCode
					,currCode                     = @currCode
					,currName                     = @currName
					,currDesc                     = @currDesc
					,currDecimalName             = @currDecimalName
					,countAfterDecimal           = @countAfterDecimal
					,roundNoDecimal              = @roundNoDecimal
					,timeZone                     = @timeZone
					,allowedCurrId               = @allowedCurrId
					,countryRuleId               = @countryRuleId
					,countryHolidayId            = @countryHolidayId
					,isActive                     = @isActive					
				WHERE countryId = @countryId
				END 
			ELSE
			BEGIN
				DELETE FROM countryCurrencyMasterMod WHERE countryId = @countryId
					
				INSERT INTO countryCurrencyMasterMod (
					 countryId
					,countryName
					,countryCode
					,currCode
					,currName
					,currDesc
					,currDecimalName
					,countAfterDecimal
					,roundNoDecimal
					,timeZone
					,allowedCurrId
					,countryRuleId
					,countryHolidayId
					,isActive              
					,createdDate
					,createdBy
					,modType                    
				)
				SELECT
					 @countryId
					,@countryName
					,@countryCode
					,@currCode
					,@currName
					,@currDesc
					,@currDecimalName
					,@countAfterDecimal
					,@roundNoDecimal
					,@timeZone
					,@allowedCurrId
					,@countryRuleId
					,@countryHolidayId
					,@isActive 			           
					,GETDATE()
					,@user
					,'U'            
			END
        COMMIT TRANSACTION       
        EXEC proc_errorHandler 0, 'Record updated successfully', @countryId
     END
			
	
ELSE IF @flag='a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM countryCurrencyMasterMod WITH(NOLOCK) WHERE countryId = @countryId AND createdBy = @user)
		BEGIN
			SELECT 
				*
			FROM countryCurrencyMasterMod WHERE countryId = @countryId	
		END
		ELSE
		BEGIN
			SELECT 
				*
			FROM countryCurrencyMaster where countryId = @countryId		
		END
	END
		
ELSE IF @flag = 'd'
     BEGIN
		IF EXISTS (SELECT 'X' FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId = @countryId AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @countryId
			RETURN
		END 
		IF EXISTS (SELECT 'X' FROM countryCurrencyMasterMod WITH(NOLOCK) WHERE countryId = @countryId AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @countryId
			RETURN
		END
		
		BEGIN TRANSACTION	
		IF EXISTS (SELECT 'X' FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId = @countryId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM countryCurrencyMaster WHERE countryId = @countryId
		END
		ELSE
		BEGIN
			INSERT INTO countryCurrencyMasterMod (
				 countryId
				,countryName
				,countryCode
				,currCode
				,currName
				,currDesc
				,currDecimalName
				,countAfterDecimal
				,roundNoDecimal
				,timeZone
				,allowedCurrId
				,countryRuleId
				,countryHolidayId
				,isActive        		                 
				,createdDate
				,createdBy
				,modType                  
			)
			SELECT
				 countryId
				,countryName
				,countryCode
				,currCode
				,currName
				,currDesc
				,currDecimalName
				,countAfterDecimal
				,roundNoDecimal
				,timeZone
				,allowedCurrId
				,countryRuleId
				,countryHolidayId
				,isActive           		                 				           
				,GETDATE()
				,@user
				,'D'
			FROM countryCurrencyMaster WHERE countryId = @countryId
		END
		
		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @countryId
	END	
	
	ELSE IF @flag = 's'
    BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'countryId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		SET @table = '(
						SELECT
							 main.countryId
							,main.countryCode
							,main.countryName
							,main.currCode
							,main.currName
							,main.currDesc                                     
							,main.haschanged				
						FROM ' + @table + ' main 
					) x'
					
		SET @sql_filter = ''		
		
		IF @countryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryName, '''') LIKE ''%' + @countryName + '%'''
		
		IF @countryCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryCode, '''') LIKE ''%' + @countryCode + '%'''
			
		IF @currCode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(currCode, '''') LIKE ''%' + @currCode + '%'''
		
		IF @currName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(currName, '''') LIKE ''%' + @currName + '%'''
		
		SET @select_field_list ='
				countryId
			   ,countryCode
			   ,countryName               
			   ,currCode
			   ,currName
			   ,currDesc               
			   ,haschanged
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
		IF NOT EXISTS (SELECT 'X' FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId = @countryId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM countryCurrencyMasterMod WITH(NOLOCK) WHERE countryId = @countryId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @countryId
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM countryCurrencyMaster WHERE countryId = @countryId AND approvedBy IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @countryId
					RETURN
				END
				DELETE FROM countryCurrencyMaster WHERE countryId = @countryId				
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @countryId
					RETURN
				END
				DELETE FROM countryCurrencyMasterMod WHERE @countryId = @countryId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @countryId
	END
	
	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM countryCurrencyMaster WITH(NOLOCK) WHERE countryId = @countryId AND approvedBy IS NULL)
		AND
		NOT EXISTS(SELECT 'X' FROM countryCurrencyMasterMod WITH(NOLOCK) WHERE countryId = @countryId )
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @countryId
			RETURN
		END
		BEGIN TRANSACTION		
			IF EXISTS (SELECT 'X' FROM countryCurrencyMaster WHERE approvedBy IS NULL AND countryId = @countryId)
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM countryCurrencyMasterMod WHERE countryId = @countryId
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE countryCurrencyMaster SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE countryId = @countryId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId, @oldValue OUTPUT				
				
				UPDATE main SET
					  main.countryName					= mode.countryName
					 ,main.countryCode                 = mode.countryCode
					 ,main.currCode                    = mode.currCode
					 ,main.currName					= mode.currName
					 ,main.currDesc                    = mode.currDesc
					 ,main.currDecimalName            = mode.currDecimalName
					 ,main.countAfterDecimal			= mode.countAfterDecimal
					 ,main.roundNoDecimal				= mode.roundNoDecimal
					 ,main.timeZone					= mode.timeZone
					 ,main.allowedCurrId				= mode.allowedCurrId
					 ,main.countryRuleId				= mode.countryRuleId
					 ,main.countryHolidayId			= mode.countryHolidayId
					 ,main.isActive                    = mode.isActive	            
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM countryCurrencyMaster main
				INNER JOIN countryCurrencyMasterMod mode ON mode.countryId= main.countryId
					WHERE mode.countryId = @countryId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryId, @oldValue OUTPUT
				UPDATE countryCurrencyMaster SET
					 isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user

				WHERE countryId = @countryId
				
			END
			
			DELETE FROM countryCurrencyMasterMod WHERE countryId = @countryId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @countryId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @countryId
	END	
				
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @countryId
END CATCH



GO
