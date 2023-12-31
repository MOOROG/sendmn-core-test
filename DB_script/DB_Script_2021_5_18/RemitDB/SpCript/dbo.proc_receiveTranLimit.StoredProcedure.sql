USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_receiveTranLimit]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_receiveTranLimit]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rtlId                             VARCHAR(30)		= NULL
	,@agentId                           INT				= NULL
	,@countryId                         VARCHAR(100)	= NULL
	,@userId                            INT				= NULL
	,@sendingCountry					VARCHAR(100)	= NULL
	,@maxLimitAmt                       MONEY			= NULL
	,@agMaxLimitAmt						MONEY			= NULL
	,@currency                          VARCHAR(3)		= NULL
	,@tranType                          VARCHAR(50)		= NULL
	,@customerType                      INT				= NULL
	
	,@branchSelection					VARCHAR(50)		= NULL
    ,@benificiaryIdReq					VARCHAR(1)		= NULL
    ,@relationshipReq					VARCHAR(1)		= NULL
    ,@benificiaryContactReq				VARCHAR(1)		= NULL
    ,@acLengthFrom						VARCHAR(50)		= NULL
    ,@acLengthTo						VARCHAR(50)		= NULL
    ,@acNumberType						VARCHAR(50)		= NULL
    
	----,@inExListType						CHAR(2)			= NULL
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
		 @sql			VARCHAR(MAX)
		,@oldValue		VARCHAR(MAX)
		,@newValue		VARCHAR(MAX)
		,@module		VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table			VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@functionId		INT
		,@id			VARCHAR(10)
		,@modType		VARCHAR(6)
		,@ApproveFunctionId1	INT
		,@ApproveFunctionId2	INT
	SELECT
		 @functionId = 20181000
		,@logIdentifier = 'rtlId'
		,@logParamMain = 'receiveTranLimit'
		,@logParamMod = 'receiveTranLimitMod'
		,@module = '20'
		,@tableAlias = 'Receive Per Transaction Limit'
		,@ApproveFunctionId1 = 20181040
		,@ApproveFunctionId2 = 20181140
	
	DECLARE  @maxLimit MONEY
			,@agentCountryId VARCHAR(100)
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WHERE 
						ISNULL(agentId, '') = ISNULL(@agentId, '') AND
						ISNULL(countryId, '') = ISNULL(@countryId, '') AND
						ISNULL(userId, '') = ISNULL(@userId, '') AND
						ISNULL(sendingCountry, '') = ISNULL(@sendingCountry, '') AND
						currency = @currency AND
						ISNULL(tranType, '') = ISNULL(@tranType, '') AND
						ISNULL(customerType, '') = ISNULL(@customerType, '') AND
						----inExListType = @inExListType AND
						ISNULL(isDeleted, 'N') <> 'Y'
						)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', @rtlId
			RETURN
		END
		
		IF(ISNULL(@agMaxLimitAmt, 0) > @maxLimitAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Max Payout Limit defined for Agent exceeds Max Payout Limit defined for Country', NULL
			RETURN
		END
		
		IF(@agentId IS NOT NULL)
		BEGIN
			SELECT @countryId = agentCountryId FROM agentMaster WHERE agentId = @agentId
			
			SELECT @maxLimit = maxLimitAmt FROM receiveTranLimit WITH(NOLOCK) WHERE countryId = @countryId AND agentId IS NULL AND currency = @currency
							AND (sendingCountry = @sendingCountry) AND tranType = @tranType
							AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
			
			IF @maxLimit IS NULL
			BEGIN
				SELECT @maxLimit = maxLimitAmt FROM receiveTranLimit WITH(NOLOCK) WHERE countryId = @countryId AND agentId IS NULL AND currency = @currency
							AND (sendingCountry = @sendingCountry) AND tranType IS NULL
							AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
			END
			IF @maxLimit IS NULL
			BEGIN
				SELECT @maxLimit = maxLimitAmt FROM receiveTranLimit WITH(NOLOCK) WHERE countryId = @countryId AND agentId IS NULL AND currency = @currency
							AND (sendingCountry IS NULL) AND tranType = @tranType
							AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
			END
			IF @maxLimit IS NULL
				SELECT @maxLimit = maxLimitAmt FROM receiveTranLimit WITH(NOLOCK) WHERE countryId = @countryId AND agentId IS NULL AND currency = @currency
							AND (sendingCountry IS NULL) AND tranType IS NULL
							AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
			--select @maxLimit
			--return;
			--SELECT * FROM receiveTranLimit WHERE countryId = 105
			
			--SELECT * FROM receiveTranLimit WHERE countryId = 105
			
			--UPDATE receiveTranLimit SET branchSelection = 'Not Required', benificiaryIdReq = 'O', relationshipReq ='O', benificiaryContactReq = 'O' WHERE countryId = 105 AND agentId IS NULL
			
			IF(@maxLimitAmt > @maxLimit)
			BEGIN
				EXEC proc_errorHandler 1, 'Limit exceeded more than Country Transaction Limit', @rtlId
				RETURN
			END
		END
		BEGIN TRANSACTION
			INSERT INTO receiveTranLimit (
				 agentId
				,countryId
				,userId
				,sendingCountry
				,maxLimitAmt
				,agMaxLimitAmt
				,currency
				,tranType
				,customerType
				,branchSelection
				,benificiaryIdReq
				,relationshipReq
				,benificiaryContactReq
				,acLengthFrom
				,acLengthTo
				,acNumberType
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@countryId
				,@userId
				,@sendingCountry
				,@maxLimitAmt
				,@agMaxLimitAmt
				,@currency
				,@tranType
				,@customerType
				,@branchSelection
				,@benificiaryIdReq
				,@relationshipReq
				,@benificiaryContactReq
				,@acLengthFrom
				,@acLengthTo
				,@acNumberType
				,@user
				,GETDATE()
			SET @id = SCOPE_IDENTITY()
			
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @rtlId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (SELECT 'X' FROM receiveTranLimitMod WITH(NOLOCK) WHERE rtlId = @rtlId AND createdBy = @user)
		BEGIN
			SELECT 
				* 
			FROM receiveTranLimitMod WITH(NOLOCK) WHERE rtlId= @rtlId
		END
		ELSE
		BEGIN
			SELECT 
				* 
			FROM receiveTranLimit WITH(NOLOCK) WHERE rtlId = @rtlId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE rtlId = @rtlId AND ( createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @rtlId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM receiveTranLimitMod WITH(NOLOCK) WHERE rtlId  = @rtlId AND createdBy<> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', @rtlId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WHERE 
						rtlId <> @rtlId AND
						ISNULL(agentId, '') = ISNULL(@agentId, '') AND
						ISNULL(countryId, '') = ISNULL(@countryId, '') AND
						ISNULL(userId, '') = ISNULL(@userId, '') AND
						ISNULL(sendingCountry, '') = ISNULL(@sendingCountry, '') AND
						currency = @currency AND
						ISNULL(tranType, '') = ISNULL(@tranType, '') AND
						ISNULL(customerType, '') = ISNULL(@customerType, '') AND
						ISNULL(isDeleted, 'N') <> 'Y'
						)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', @rtlId
			RETURN
		END
		IF(ISNULL(@agMaxLimitAmt, 0) > @maxLimitAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Agent Max Payout Limit Amount exceeds Country Max Payout Limit Amount', NULL
			RETURN
		END
		IF(@agentId IS NOT NULL)
		BEGIN
			SELECT @countryId = agentCountryId FROM agentMaster WHERE agentId = @agentId
			SELECT @maxLimit = maxLimitAmt FROM receiveTranLimit WHERE 
				countryId = @countryId  AND 
				currency = @currency AND
				(sendingCountry = @sendingCountry OR @sendingCountry IS NULL) AND 
				ISNULL(customerType, '') = ISNULL(@customerType, '') AND 
				ISNULL(tranType, '') = ISNULL(@tranType, '') AND
				ISNULL(isDeleted, 'N') = 'N' AND
				ISNULL(isActive, 'N') = 'Y'
			/*	
			IF(@maxLimitAmt > @maxLimit)
			BEGIN
				EXEC proc_errorHandler 1, 'Limit exceeded more than Country Transaction Limit1', @rtlId
				RETURN
			END
			*/
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM receiveTranLimit WHERE approvedBy IS NULL AND rtlId  = @rtlId AND createdBy = @user)
			BEGIN
				UPDATE receiveTranLimit SET
					 agentId						= @agentId
					,countryId						= @countryId
					,userId							= @userId
					,sendingCountry					= @sendingCountry
					,maxLimitAmt					= @maxLimitAmt
					,agMaxLimitAmt					= @agMaxLimitAmt
					,currency						= @currency
					,tranType						= @tranType
					,customerType					= @customerType
					,branchSelection				= @branchSelection
					,benificiaryIdReq				= @benificiaryIdReq
					,relationshipReq				= @relationshipReq
					,benificiaryContactReq			= @benificiaryContactReq
					,acLengthFrom					= @acLengthFrom
					,acLengthTo						= @acLengthTo
					,acNumberType					= @acNumberType
				WHERE rtlId = @rtlId
			END
			ELSE
			BEGIN
				DELETE FROM receiveTranLimitMod WHERE rtlId = @rtlId
				
				INSERT INTO receiveTranLimitMod(
					 rtlId
					,agentId
					,countryId
					,userId
					,sendingCountry
					,maxLimitAmt
					,agMaxLimitAmt
					,currency
					,tranType
					,customerType
					,branchSelection
					,benificiaryIdReq
					,relationshipReq
					,benificiaryContactReq
					,acLengthFrom
					,acLengthTo
					,acNumberType
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @rtlId
					,@agentId
					,@countryId
					,@userId
					,@sendingCountry
					,@maxLimitAmt
					,@agMaxLimitAmt
					,@currency
					,@tranType
					,@customerType
					,@branchSelection
					,@benificiaryIdReq
					,@relationshipReq
					,@benificiaryContactReq
					,@acLengthFrom
					,@acLengthTo
					,@acNumberType
					,@user
					,GETDATE()
					,'U'
					
				SET @modType = 'update'

			END
			
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @rtlId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE rtlId = @rtlId  AND (createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.', @rtlId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM receiveTranLimitMod  WITH(NOLOCK) WHERE rtlId = @rtlId and createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous Modification has not been approved yet.',  @rtlId
			RETURN
		END
		
		BEGIN TRANSACTION
		IF EXISTS (SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE rtlId = @rtlId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM receiveTranLimit WHERE rtlId = @rtlId
		END
		ELSE
		BEGIN
			INSERT INTO receiveTranLimitMod(
				 rtlId
				,agentId
				,countryId
				,userId
				,sendingCountry
				,maxLimitAmt
				,agMaxLimitAmt
				,currency
				,tranType
				,customerType
				,branchSelection
				,benificiaryIdReq
				,relationshipReq
				,benificiaryContactReq
				,acLengthFrom
				,acLengthTo
				,acNumberType
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 @rtlId
				,@agentId
				,@countryId
				,@userId
				,@sendingCountry
				,@maxLimitAmt
				,@agMaxLimitAmt
				,@currency
				,@tranType
				,@customerType
				,@branchSelection
				,@benificiaryIdReq
				,@relationshipReq
				,@benificiaryContactReq
				,@acLengthFrom
				,@acLengthTo
				,@acNumberType
				,@user
				,GETDATE()
				,'D'
			SET @modType = 'delete'

		END

		COMMIT TRANSACTION

		EXEC proc_errorHandler 0, 'Record deleted successfully', @countryId
	END


	ELSE IF @flag = 's'
	BEGIN
		DECLARE @hasRight1 CHAR(1), @hasRight2 CHAR(1)
		SET @hasRight1 = dbo.FNAHasRight(@user, CAST(@ApproveFunctionId1 AS VARCHAR))
		SET @hasRight2 = dbo.FNAHasRight(@user, CAST(@ApproveFunctionId2 AS VARCHAR))
		IF @sortBy IS NULL
			SET @sortBy = 'rtlId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
					SELECT
						 rtlId				= ISNULL(mode.rtlId, main.rtlId)
						,agentId			= ISNULL(mode.agentId,main.agentId)
						,countryId			= ISNULL(mode.countryId,main.countryId)
						,userId				= ISNULL(mode.userId,main.userId)
						,sendingCountry		= ISNULL(mode.sendingCountry,main.sendingCountry)
						,maxLimitAmt		= ISNULL(mode.maxLimitAmt,main.maxLimitAmt)
						,agMaxLimitAmt		= ISNULL(mode.agMaxLimitAmt, main.agMaxLimitAmt)
						,currency			= ISNULL(mode.currency,main.currency)
						,tranType			= ISNULL(mode.tranType,main.tranType)
						,customerType		= ISNULL(mode.customerType,main.customerType)
						,main.createdBy
						,main.createdDate			
						,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
						,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
						,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
												(mode.rtlId IS NOT NULL) 
											THEN ''Y'' ELSE ''N'' END
					FROM receiveTranLimit main WITH(NOLOCK)
					LEFT JOIN receiveTranLimitMod mode ON main.rtlId = mode.rtlId 
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight1 + '''
								OR ''Y'' = ''' + @hasRight2 + '''
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = ''' + @hasRight1 + '''
								OR ''Y'' = ''' + @hasRight2 + '''
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
				) '
	
		SET @table = '(
				SELECT
					 main.rtlId
					,main.agentId
					,main.countryId
					,main.userId
					,main.sendingCountry
					,sCountryName = ISNULL(scm.countryName, ''Any'')
					,main.maxLimitAmt
					,main.agMaxLimitAmt
					,main.currency
					,currencyName = main.currency
					,main.tranType
					,tranTypeText = ISNULL(stm.typeTitle, ''Any'')
					,customerType = ISNULL(ct.detailTitle, ''Any'')
					,main.haschanged
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
				FROM ' + @table + ' main 
				LEFT JOIN countryMaster scm WITH(NOLOCK) ON main.sendingCountry = scm.countryId
				LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId
				LEFT JOIN staticDataValue ct WITH(NOLOCK) ON main.customerType = ct.valueId
				) x'
		SET @sql_filter = ''		
		--PRINT (@table)
		
		IF @countryId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(countryId, '''') = ''' + @countryId + ''' AND agentId IS NULL' 
			
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentId, '''') = ''' + CAST(@agentId AS VARCHAR) + '''' 
		
		IF @userId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(userId, '''') = ''' + CAST(@userId AS VARCHAR) + '''' 
			
		IF @sendingCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(sendingCountry, '''') = ''' + CAST(@sendingCountry AS VARCHAR) + ''''
		
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(tranType, '''') = ''' + CAST(@tranType AS VARCHAR) + '%'''

		SET @select_field_list ='
				rtlId
			   ,agentId
			   ,countryId               
			   ,userId
			   ,sendingCountry
			   ,sCountryName
			   ,maxLimitAmt 
			   ,agMaxLimitAmt              
			   ,currency
			   ,currencyName
			   ,tranType
			   ,tranTypeText
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
		IF NOT EXISTS (SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE rtlId = @rtlId and approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM receiveTranLimitMod WITH(NOLOCK) WHERE rtlId = @rtlId)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rtlId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM receiveTranLimit WHERE approvedBy IS NULL AND rtlId = @rtlId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rtlId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rtlId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rtlId
					RETURN
				END
			DELETE FROM receiveTranLimit WHERE rtlId=  @rtlId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rtlId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rtlId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rtlId
					RETURN
				END
				DELETE FROM receiveTranLimitMod WHERE rtlId = @rtlId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @rtlId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE rtlId = @rtlId AND approvedBy IS NULL)
		AND
		NOT EXISTS (SELECT 'X' FROM receiveTranLimitMod WITH(NOLOCK) WHERE rtlId = @rtlId)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rtlId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM receiveTranLimit WHERE approvedBy IS NULL AND rtlId = @rtlId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM receiveTranLimitMod WHERE rtlId = @rtlId
				
			IF @modType = 'I'
			BEGIN --New record
				UPDATE receiveTranLimit SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE rtlId = @rtlId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rtlId, @newValue OUTPUT
				
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rtlId, @oldValue OUTPUT
				
				UPDATE main SET
					 main.agentId                       = mode.agentId
					,main.countryId                     = mode.countryId
					,main.userId                        = mode.userId
					,main.sendingCountry                = mode.sendingCountry
					,main.maxLimitAmt                   = mode.maxLimitAmt
					,main.agMaxLimitAmt					= mode.agMaxLimitAmt
					,main.currency                      = mode.currency
					,main.tranType                      = mode.tranType
					,main.customerType                  = mode.customerType
					,main.branchSelection				= mode.branchSelection
					,main.benificiaryIdReq				= mode.benificiaryIdReq
					,main.relationshipReq				= mode.relationshipReq
					,main.benificiaryContactReq			= mode.benificiaryContactReq
					,main.acLengthFrom					= mode.acLengthFrom
					,main.acLengthTo					= mode.acLengthTo
					,main.acNumberType					= mode.acNumberType
					----,main.inExListType					= mode.inExListType
					,main.modifiedDate					= GETDATE()
					,main.modifiedBy					= @user
				FROM receiveTranLimit main
				INNER JOIN receiveTranLimitMod mode ON mode.rtlId = main.rtlId
				WHERE mode.rtlId = @rtlId

				EXEC [dbo].proc_GetColumnToRow  'receiveTranLimit', 'rtlId', @rtlId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rtlId, @oldValue OUTPUT
				UPDATE receiveTranLimit SET
					 isDeleted = 'Y'
					,isActive = 'N'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
				
				WHERE rtlId = @rtlId
				
			END
			
			DELETE FROM receiveTranLimitMod WHERE rtlId = @rtlId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rtlId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @rtlId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @rtlId
	END
	
	ELSE IF @flag = 'cml'		--Get Country Max Limit
	BEGIN

		SELECT @countryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId

		SELECT TOP 1 maxLimitAmt = ISNULL(maxLimitAmt, 0.00) FROM receiveTranLimit WITH(NOLOCK) 
		WHERE countryId = @countryId 
		AND ISNULL(isDeleted, 'N') = 'N' 
		AND ISNULL(isActive, 'N') = 'Y'

	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rtlId
END CATCH

GO
