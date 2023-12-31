USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendTranLimit]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_sendTranLimit]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@stlId                             VARCHAR(30)		= NULL
	,@agentId                           INT				= NULL
	,@countryId							INT				= NULL
	,@userId                            INT				= NULL
	,@receivingCountry                  INT				= NULL
	,@receivingAgent					INT				= NULL
	,@maxLimitAmt                       MONEY			= NULL
	,@minLimitAmt                       MONEY			= NULL
	,@currency                          VARCHAR(3)		= NULL
	,@collMode                          INT				= NULL
	,@tranType 							INT				= NULL
	,@customerType                      INT				= NULL
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
		,@ApproveFunctionId1	INT
		,@ApproveFunctionId2	INT
	SELECT
		 @functionId = 30011400
		,@logIdentifier = 'stlId'
		,@logParamMain = 'sendTranLimit'
		,@logParamMod = 'sendTranLimitMod'
		,@module = '20'
		,@tableAlias = 'Send Per Transaction Limit'
		,@ApproveFunctionId1 = 30011430
		,@ApproveFunctionId2 = 30011430
	
	DECLARE  @maxLimit MONEY = 0
			,@agentCountryId INT

	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM sendTranLimit WHERE 
						ISNULL(agentId, 0) = ISNULL(@agentId, 0) AND
						ISNULL(countryId, 0) = ISNULL(@countryId, 0) AND
						ISNULL(userId, 0) = ISNULL(@userId, 0) AND
						ISNULL(receivingCountry, 0) = ISNULL(@receivingCountry, 0) AND
						currency = @currency AND
						ISNULL(collMode, 0) = ISNULL(@collMode, 0) AND
						ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
						ISNULL(customerType, 0) = ISNULL(@customerType, 0) AND
						----inExListType = @inExListType AND
						ISNULL(isDeleted, 'N') <> 'Y'
						)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', @stlId
			RETURN
		END
		IF(ISNULL(@minLimitAmt, 0) > @maxLimitAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Collection Limit exceeds Max Collection Limit', NULL
			RETURN
		END
		IF(@agentId IS NOT NULL)
		BEGIN
			SELECT @countryId = agentCountryId FROM agentMaster WHERE agentId = @agentId
			SELECT @maxLimit = ISNULL(maxLimitAmt, 0) FROM sendTranLimit WHERE 
				countryId = @countryId AND 
				currency = @currency AND
				ISNULL(receivingCountry, 0) = ISNULL(@receivingCountry, 0) AND 
				ISNULL(customerType, 0) = ISNULL(@customerType, 0) AND 
				ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
				ISNULL(collMode, 0) = ISNULL(@collMode, 0) AND
				ISNULL(isDeleted, 'N') <> 'Y' AND
				ISNULL(isActive, 'N') = 'Y'
			IF(@maxLimitAmt > @maxLimit)
			BEGIN
				EXEC proc_errorHandler 1, 'Limit exceeded more than Country Transaction Limit', @stlId
				RETURN
			END
		END
		BEGIN TRANSACTION
			INSERT INTO sendTranLimit (
				 agentId
				,countryId
				,userId
				,receivingCountry
				,receivingAgent
				,maxLimitAmt
				,minLimitAmt
				,currency
				,collMode
				,tranType
				,customerType
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@countryId
				,@userId
				,@receivingCountry
				,@receivingAgent
				,ISNULL(@maxLimitAmt,0)
				,ISNULL(@minLimitAmt,0)
				,@currency
				,@collMode
				,@tranType
				,@customerType
				,@user
				,GETDATE()
			SET @id = SCOPE_IDENTITY()
			
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @stlId
	END
	
	ELSE IF @flag = 'iall'		--Apply For all Country
	BEGIN

		--BEGIN TRANSACTION
			CREATE TABLE #tempTable(
				 agentId			INT
				,countryId			INT
				,userId				INT
				,receivingCountry	INT
				,maxLimitAmt		MONEY
				,minLimitAmt		MONEY
				,currency			VARCHAR(3)
				,collMode			INT
				,tranType			INT
				,customerType		INT
				,createdBy			VARCHAR(50)
				,createdDate		DATETIME
			)
			
			INSERT INTO #tempTable(agentId,countryId,userId,receivingCountry,maxLimitAmt,minLimitAmt,currency,collMode,tranType,customerType,createdBy,createdDate)
			SELECT
				 @agentId
				,@countryId
				,@userId
				,countryId
				,ISNULL(@maxLimitAmt,0)
				,ISNULL(@minLimitAmt,0)
				,@currency
				,@collMode
				,@tranType
				,@customerType
				,@user
				,GETDATE()
			FROM countryMaster WITH(NOLOCK)
			WHERE ISNULL(isDeleted, 'N') = 'N'
			AND operationType IN ('B','R')
			AND countryId NOT IN(
				SELECT receivingCountry FROM sendTranLimit WITH(NOLOCK)
				WHERE countryId = @countryId 
				AND ISNULL(tranType,0) = ISNULL(@tranType,0)
				AND ISNULL(collMode,0) = ISNULL(@collMode,0)
				AND ISNULL(isDeleted, 'N') = 'N'
			)
			AND countryId <> @countryId
	
		DELETE T FROM #tempTable T INNER JOIN sendTranLimit STL ON  T.countryId=STL.countryId
		AND T.receivingCountry=STL.receivingCountry
		AND ISNULL(T.tranType,'')=ISNULL(STL.tranType,'')



			INSERT INTO sendTranLimit(agentId,countryId,userId,receivingCountry,maxLimitAmt,minLimitAmt,currency,tranType,collMode,customerType,createdBy,createdDate)
			SELECT t.agentId, t.countryId,t.userId,t.receivingCountry,t.maxLimitAmt,t.minLimitAmt,t.currency,t.tranType,t.collMode,t.customerType,t.createdBy,t.createdDate FROM #tempTable t
	
/*
			 EXEC proc_sendTranLimit @flag = 'iall', @user = 'admin', @agentId = null, 
			 @countryId = 'Malaysia', @userId = null, @receivingCountry = 'Bangladesh', 
			 @minLimitAmt = '10.00', @maxLimitAmt = '50,000.00', @currency = 'MYR - Ringgit', 
			 @tranType = null, @paymentType = null, @customerType = null



 */
		--COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Setup has been applied for all receiving country', @stlId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM sendTranLimitMod WITH(NOLOCK) WHERE stlId = @stlId AND createdBy = @user)
		BEGIN
			SELECT 
				* 
			FROM sendTranLimitMod WITH(NOLOCK) WHERE stlId= @stlId
		END
		ELSE
		BEGIN
			SELECT 
				* 
			FROM sendTranLimit WITH(NOLOCK) WHERE stlId = @stlId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE stlId = @stlId AND ( createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @stlId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sendTranLimitMod WITH(NOLOCK) WHERE stlId  = @stlId AND createdBy<> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @stlId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM sendTranLimit WHERE 
						stlId <> @stlId AND
						ISNULL(agentId, 0) = ISNULL(@agentId, 0) AND
						ISNULL(countryId, 0) = ISNULL(@countryId, 0) AND
						ISNULL(userId, 0) = ISNULL(@userId, 0) AND
						ISNULL(receivingCountry, 0) = ISNULL(@receivingCountry, 0) AND
						ISNULL(receivingAgent, 0) = ISNULL(@receivingAgent, 0) AND
						currency = @currency AND
						ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
						ISNULL(collMode, 0) = ISNULL(@collMode, '') AND
						ISNULL(customerType, 0) = ISNULL(@customerType, 0) AND
						ISNULL(isDeleted, 'N') <> 'Y'
						)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', @stlId
			RETURN
		END
		IF(ISNULL(@minLimitAmt, 0) > @maxLimitAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Collection Limit exceeds Max Collection Limit', NULL
			RETURN
		END
		IF(@agentId IS NOT NULL)
		BEGIN
			SELECT @countryId = agentCountryId FROM agentMaster WHERE agentId = @agentId
			SELECT @maxLimit = ISNULL(maxLimitAmt, 0) FROM sendTranLimit WHERE 
				countryId = @countryId  AND 
				currency = @currency AND
				ISNULL(receivingCountry, 0) = ISNULL(@receivingCountry, 0) AND 
				ISNULL(customerType, 0) = ISNULL(@customerType, 0) AND 
				ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
				ISNULL(collMode, 0) = ISNULL(@collMode, 0) AND
				ISNULL(isDeleted, 'N') <> 'Y' AND
				ISNULL(isActive, 'N') = 'Y'
			IF(@maxLimitAmt > @maxLimit)
			BEGIN
				EXEC proc_errorHandler 1, 'Limit exceeded more than Country Transaction Limit', @stlId
				RETURN
			END
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM sendTranLimit WHERE approvedBy IS NULL AND stlId  = @stlId AND createdBy = @user)
			BEGIN
				UPDATE sendTranLimit SET
					 agentId						= @agentId
					,countryId						= @countryId
					,userId							= @userId
					,receivingCountry				= @receivingCountry
					,receivingAgent					= @receivingAgent
					,maxLimitAmt					= ISNULL(@maxLimitAmt,0)
					,minLimitAmt					= ISNULL(@minLimitAmt,0)
					,currency						= @currency
					,tranType						= @tranType
					,collMode						= @collMode
					,customerType					= @customerType
				WHERE stlId = @stlId
			END
			ELSE
			BEGIN
				DELETE FROM sendTranLimitMod WHERE stlId = @stlId
				
				INSERT INTO sendTranLimitMod(
					 stlId
					,agentId
					,countryId
					,userId
					,receivingCountry
					,receivingAgent
					,maxLimitAmt
				    ,minLimitAmt
					,currency
					,tranType
					,collMode
					,customerType
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @stlId
					,@agentId
					,@countryId
					,@userId
					,@receivingCountry
					,@receivingAgent
					,ISNULL(@maxLimitAmt,0)
					,ISNULL(@minLimitAmt,0)
					,@currency
					,@tranType
					,@collMode
					,@customerType
					,@user
					,GETDATE()
					,'U'
					
				SET @modType = 'update'

			END
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @stlId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE stlId = @stlId  AND (createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @stlId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sendTranLimitMod  WITH(NOLOCK) WHERE stlId = @stlId and createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.',  @stlId
			RETURN
		END
		
		BEGIN TRANSACTION
		IF EXISTS (SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE stlId = @stlId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM sendTranLimit WHERE stlId = @stlId
		END
		ELSE
		BEGIN
			INSERT INTO sendTranLimitMod(
				 stlId
				,agentId
				,countryId
				,userId
				,receivingCountry
				,receivingAgent
				,maxLimitAmt
				,minLimitAmt
				,currency
				,tranType
				,collMode
				,customerType
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 stlId
				,agentId
				,countryId
				,userId
				,receivingCountry
				,receivingAgent
				,maxLimitAmt
				,minLimitAmt
				,currency
				,tranType
				,collMode
				,customerType
				,@user
				,GETDATE()
				,'D'
			FROM sendTranLimit WHERE stlId = @stlId
			SET @modType = 'delete'

		END

		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @countryId
	END

	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'stlId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
					SELECT
						 stlId				= ISNULL(mode.stlId, main.stlId)
						,agentId			= ISNULL(mode.agentId,main.agentId)
						,countryId			= ISNULL(mode.countryId,main.countryId)
						,userId				= ISNULL(mode.userId,main.userId)
						,receivingCountry	= ISNULL(mode.receivingCountry,main.receivingCountry)
						,maxLimitAmt		= ISNULL(mode.maxLimitAmt,main.maxLimitAmt)
						,minLimitAmt		= ISNULL(mode.minLimitAmt,main.minLimitAmt)
						,currency			= ISNULL(mode.currency,main.currency)
						,tranType			= ISNULL(mode.tranType,main.tranType)
						,collMode			= ISNULL(mode.collMode,main.collMode)
						,customerType		= ISNULL(mode.customerType,main.customerType)
						,main.createdBy
						,main.createdDate			
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE main.modifiedDate END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.stlId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END
					FROM sendTranLimit main WITH(NOLOCK)
					LEFT JOIN sendTranLimitMod mode ON main.stlId = mode.stlId 
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApproveFunctionId1 AS VARCHAR) + ')
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApproveFunctionId2 AS VARCHAR) + ')
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApproveFunctionId1 AS VARCHAR) + ')
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApproveFunctionId2 AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
				) '
				--PRINT(@table)
		SET @table = '(
				SELECT
					 main.stlId
					,main.agentId
					,main.countryId
					,sCountryName = ISNULL(scm.countryName, ''All'')
					,main.userId
					,main.receivingCountry
					,rCountryName = ISNULL(rcm.countryName, ''All'')
					,main.maxLimitAmt
					,main.minLimitAmt
					,main.currency
					,currencyName = main.currency
					,tranType = main.tranType
					,tranTypeText = ISNULL(stm.typeTitle, ''Any'')
					,collMode = main.collMode
					,collModeText = ISNULL(col.detailTitle, ''Any'')
					,customerType = ISNULL(ct.detailTitle, ''Any'')
					,main.haschanged
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
				FROM ' + @table + ' main 
				LEFT JOIN countryMaster scm WITH(NOLOCK) ON main.countryId = scm.countryId
				LEFT JOIN countryMaster rcm WITH(NOLOCK) ON main.receivingCountry = rcm.countryId
				LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId
				LEFT JOIN staticDataValue col WITH(NOLOCK) ON main.collMode = col.valueId
				LEFT JOIN staticDataValue ct WITH(NOLOCK) ON main.customerType = ct.valueId
				) x'
		SET @sql_filter = ''		
		--PRINT (@table)
		
		IF @countryId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryId, '''') = ''' + CAST(@countryId AS VARCHAR) + ''' AND agentId IS NULL' 
			
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentId, '''') = ''' + CAST(@agentId AS VARCHAR) + '''' 
		
		IF @userId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userId, '''') = ''' + CAST(@userId AS VARCHAR) + '''' 
			
		IF @receivingCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(receivingCountry, '''') = ''' + CAST(@receivingCountry AS VARCHAR) + ''''
		
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(tranType, '''') = ''' + CAST(@tranType AS VARCHAR) + '%'''
		
		IF @collMode IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(collMode, '''') = ''' + CAST(@collMode AS VARCHAR) + '%''' 

		SET @select_field_list ='
				stlId
			   ,agentId
			   ,countryId               
			   ,userId
			   ,sCountryName
			   ,receivingCountry
			   ,rCountryName
			   ,maxLimitAmt 
			   ,minLimitAmt              
			   ,currency
			   ,currencyName
			   ,tranType
			   ,tranTypeText
			   ,collMode
			   ,collModeText
			   ,customerType
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
	
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE stlId = @stlId and approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM sendTranLimitMod WITH(NOLOCK) WHERE stlId = @stlId)
		BEGIN
			EXEC proc_errorHandler 1, 'Modification approval is not pending.', @stlId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sendTranLimit WHERE approvedBy IS NULL AND stlId = @stlId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @stlId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @stlId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @stlId
					RETURN
				END
			DELETE FROM sendTranLimit WHERE stlId=  @stlId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @stlId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @stlId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @stlId
					RETURN
				END
				DELETE FROM sendTranLimitMod WHERE stlId = @stlId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @stlId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM sendTranLimit WITH(NOLOCK) WHERE stlId = @stlId AND approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM sendTranLimitMod WITH(NOLOCK) WHERE stlId = @stlId)
		BEGIN
			EXEC proc_errorHandler 1, 'Modification approval is not pending.', @stlId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM sendTranLimit WHERE approvedBy IS NULL AND stlId = @stlId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM sendTranLimitMod WHERE stlId = @stlId
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE sendTranLimit SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE stlId = @stlId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @stlId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @stlId, @oldValue OUTPUT
				
				UPDATE main SET
					 main.agentId                       = mode.agentId
					,main.countryId                     = mode.countryId
					,main.userId                        = mode.userId
					,main.receivingCountry              = mode.receivingCountry
					,main.receivingAgent				= mode.receivingAgent
					,main.maxLimitAmt                   = mode.maxLimitAmt
					,main.minLimitAmt                   = mode.minLimitAmt
					,main.currency                      = mode.currency
					,main.tranType        = mode.tranType
					,main.collMode						= mode.collMode
					,main.customerType                  = mode.customerType
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM sendTranLimit main
				INNER JOIN sendTranLimitMod mode ON mode.stlId = main.stlId
				WHERE mode.stlId = @stlId

				EXEC [dbo].proc_GetColumnToRow  'sendTranLimit', 'stlId', @stlId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @stlId, @oldValue OUTPUT
				UPDATE sendTranLimit SET
					 isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
				
				WHERE stlId = @stlId
				
			END
			
			DELETE FROM sendTranLimitMod WHERE stlId = @stlId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @stlId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @stlId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @stlId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()+ CAST( ERROR_LINE() as varchar)
     EXEC proc_errorHandler 1, @errorMessage, @stlId
END CATCH

GO
