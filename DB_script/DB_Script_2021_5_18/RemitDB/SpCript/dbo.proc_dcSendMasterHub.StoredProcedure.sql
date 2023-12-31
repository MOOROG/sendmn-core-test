USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcSendMasterHub]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcSendMasterHub]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dcSendMasterHubId                 VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@rCountry                          INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@commissionBase                    INT				= NULL
	,@isEnable                          CHAR(1)			= NULL
	,@hasChanged                        CHAR(1)			= NULL
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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20131030
		,@logIdentifier = 'dcSendMasterHubId'
		,@logParamMain = 'dcSendMasterHub'
		,@logParamMod = 'dcSendMasterHubHistory'
		,@module = '20'
		,@tableAlias = 'Hub Default Sending Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
		
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM dcSendMasterHub WHERE 
					sCountry = ISNULL(@sCountry, sCountry) AND 
					rCountry = ISNULL(@rCountry, rCountry) AND 
					tranType = ISNULL(@tranType, tranType) AND 
					ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcSendMasterHubId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcSendMasterHub (
				 code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,commissionBase
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @code
				,@description
				,@sCountry
				,@rCountry
				,@baseCurrency
				,@tranType
				,@commissionBase
				,@isEnable
				,@user
				,GETDATE()
				
				
			SET @dcSendMasterHubId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcSendMasterHubId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHubHistory WITH(NOLOCK)
				WHERE dcSendMasterHubId = @dcSendMasterHubId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcSendMasterHubHistory mode WITH(NOLOCK)
			INNER JOIN dcSendMasterHub main WITH(NOLOCK) ON mode.dcSendMasterHubId = main.dcSendMasterHubId
			WHERE mode.dcSendMasterHubId= @dcSendMasterHubId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcSendMasterHub WITH(NOLOCK) WHERE dcSendMasterHubId = @dcSendMasterHubId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHubHistory WITH(NOLOCK)
			WHERE dcSendMasterHubId  = @dcSendMasterHubId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterHubId
			RETURN
		END
		IF EXISTS(SELECT 'x' FROM dcSendMasterHub WHERE 
					dcSendMasterHubId <> @dcSendMasterHubId AND
					sCountry = ISNULL(@sCountry, sCountry) AND 
					rCountry = ISNULL(@rCountry, rCountry) AND 
					tranType = ISNULL(@tranType, tranType) AND 
					ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcSendMasterHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendMasterHub WHERE approvedBy IS NULL AND dcSendMasterHubId  = @dcSendMasterHubId)			
			BEGIN				
				UPDATE dcSendMasterHub SET
					 code							= @code
					,[description]					= @description
					,sCountry						= @sCountry
					,rCountry						= @rCountry
					,baseCurrency					= @baseCurrency
					,tranType						= @tranType
					,commissionBase					= @commissionBase
					,isEnable						= @isEnable				
				WHERE dcSendMasterHubId = @dcSendMasterHubId				
			END
			ELSE
			BEGIN
				DELETE FROM dcSendMasterHubHistory WHERE dcSendMasterHubId = @dcSendMasterHubId AND approvedBy IS NULL
				INSERT INTO dcSendMasterHubHistory(
					 dcSendMasterHubId
					,code
					,[description]
					,sCountry
					,rCountry
					,baseCurrency
					,tranType
					,commissionBase
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @dcSendMasterHubId
					,@code
					,@description
					,@sCountry
					,@rCountry
					,@baseCurrency
					,@tranType
					,@commissionBase
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcSendMasterHubId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHubHistory  WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcSendMasterHubId
			RETURN
		END
		
			INSERT INTO dcSendMasterHubHistory(
				 dcSendMasterHubId
				,code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,commissionBase
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 dcSendMasterHubId
				,code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,commissionBase
				,isEnable
				,@user
				,GETDATE()
				,'D'
			FROM dcSendMasterHub WHERE dcSendMasterHubId = @dcSendMasterHubId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterHubId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendMasterHubId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcSendMasterHubId = ISNULL(mode.dcSendMasterHubId, main.dcSendMasterHubId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)				
					,sCountry = ISNULL(mode.sCountry, main.sCountry)			
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedDate = ISNULL(mode.createdDate, main.modifiedDate)
					,modifiedBy = ISNULL(mode.createdBy, main.modifiedBy)
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.dcSendMasterHubId IS NOT NULL THEN ''Y'' ELSE ''N'' END
				FROM dcSendMasterHub main WITH(NOLOCK)
					LEFT JOIN dcSendMasterHubHistory mode ON main.dcSendMasterHubId = mode.dcSendMasterHubId AND mode.approvedBy IS NULL
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
			) x'
			
			
			
		--@sAgent
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''

		IF @rCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
		
		IF @sCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
		
		IF @tranType IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))

		SET @select_field_list = '
			 dcSendMasterHubId
			,code
			,description
			,sCountry
			,rCountry
			,baseCurrency
			,tranType
			,commissionBase
			,isEnable
			,createdBy
			,createdDate
			,isDeleted '
			
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
	
	ELSE IF @flag = 'm'
	BEGIN
		DECLARE 
			 @m VARCHAR(MAX)
			,@d VARCHAR(MAX)
		
		SET @m = '(
				SELECT
					 dcSendMasterHubId = ISNULL(mode.dcSendMasterHubId, main.dcSendMasterHubId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sCountry = ISNULL(mode.sCountry, main.sCountry)					
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END											
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcSendMasterHubId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcSendMasterHub main WITH(NOLOCK)
					LEFT JOIN dcSendMasterHubHistory mode ON main.dcSendMasterHubId = mode.dcSendMasterHubId AND mode.approvedBy IS NULL
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
			
			
		SET @d = '(
				SELECT
					 dcSendDetailHubId = main.dcSendDetailHubId
					,dcSendMasterHubId = main.dcSendMasterHubId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
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
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
			) '
	
			SET @table = ' 
					(
						SELECT
							 m.dcSendMasterHubId
							,m.description
							,m.sCountry
							,sCountryName = sc.countryName
							,m.rCountry
							,rCountryName = rc.countryName
							,m.tranType
							,tranTypeName = ISNULL(trn.typeTitle, ''All'')
							,m.baseCurrency
							,m.isEnable
							,fromAmt = MIN(d.fromAmt)
							,toAmt = MAX(d.toAmt)	
							,modifiedBy = MAX(ISNULL(m.modifiedBy, d.modifiedBy))						
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.dcSendMasterHubId = d.dcSendMasterHubId
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
				
						
						GROUP BY 
							 m.dcSendMasterHubId
							,m.description
							,m.sCountry
							,sc.countryName
							,m.rCountry
							,rc.countryName
							,m.tranType
							,trn.typeTitle
							,m.baseCurrency
							,m.isEnable
							--,m.modifiedBy
							--,d.modifiedBy
					) x
					'
					
				--print @table
				--
			SET @sql_filter = ' '
			
			IF @hasChanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasChanged = '''+ @hasChanged +''''

			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @sCountry IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
			
			IF @tranType IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
			SET @select_field_list = '
					 dcSendMasterHubId
					,description
					,sCountry
					,sCountryName
					,rCountry
					,rCountryName
					,tranType
					,tranTypeName
					,baseCurrency
					,baseCurrencyName
					,fromAmt
					,toAmt
					,modifiedBy
					,hasChanged
					
				'
				
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendMasterHubId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
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
	
	ELSE IF @flag IN ('reject', 'rejectAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendMasterHubId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcSendMasterHub WHERE approvedBy IS NULL AND dcSendMasterHubId = @dcSendMasterHubId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendMasterHubId
					RETURN
				END
			DELETE FROM dcSendMasterHub WHERE dcSendMasterHubId =  @dcSendMasterHubId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendMasterHubId
					RETURN
				END
				DELETE FROM dcSendMasterHubHistory WHERE dcSendMasterHubId = @dcSendMasterHubId AND approvedBy IS NULL
			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				dcSendDetailHubId, 'I' 
			FROM dcSendDetailHub 				
			WHERE 
				dcSendMasterHubId = @dcSendMasterHubId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.dcSendDetailHubId, mode.modType
			FROM dcSendDetailHubHistory mode WITH(NOLOCK)
			INNER JOIN dcSendDetailHub main WITH(NOLOCK) ON mode.dcSendDetailHubId = main.dcSendDetailHubId 		
			WHERE 
				main.dcSendMasterHubId = @dcSendMasterHubId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'dcSendDetailHubId'
				,@logParamMain = 'dcSendDetailHub'
				,@logParamMod = 'dcSendDetailHubHistory'
				,@module = '20'
				,@tableAlias = 'Hub Default Send Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM dcSendDetailHub WHERE approvedBy IS NULL AND dcSendDetailHubId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM dcSendDetailHubHistory WHERE dcSendDetailHubId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM dcSendDetailHub WHERE dcSendDetailHubId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM dcSendDetailHubHistory WHERE dcSendDetailHubId = @detailId AND approvedBy IS NULL
				END
				DELETE FROM @DetailIdList WHERE detailId = @detailId
			END				
		END
		
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @detailId
			RETURN
		END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcSendMasterHubId
	END

	ELSE IF @flag IN ('approve','approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendMasterHub WITH(NOLOCK)
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendMasterHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendMasterHub WHERE approvedBy IS NULL AND dcSendMasterHubId = @dcSendMasterHubId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcSendMasterHubHistory WHERE dcSendMasterHubId = @dcSendMasterHubId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcSendMasterHub SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcSendMasterHubId = @dcSendMasterHubId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterHubId, @oldValue OUTPUT
				UPDATE main SET
					 main.code                          = mode.code
					,main.[description]                 = mode.[description]
					,main.sCountry                      = mode.sCountry
					,main.rCountry                      = mode.rCountry
					,main.baseCurrency                  = mode.baseCurrency
					,main.tranType                      = mode.tranType
					,main.commissionBase				= mode.commissionBase
					,main.isEnable						= mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcSendMasterHub main
				INNER JOIN dcSendMasterHubHistory mode ON mode.dcSendMasterHubId = main.dcSendMasterHubId
				WHERE mode.dcSendMasterHubId = @dcSendMasterHubId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcSendMasterHub', 'dcSendMasterHubId', @dcSendMasterHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterHubId, @oldValue OUTPUT
				UPDATE dcSendMasterHub SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcSendMasterHubId = @dcSendMasterHubId
			END
			
			UPDATE dcSendMasterHubHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcSendMasterHubId = @dcSendMasterHubId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterHubId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					dcSendDetailHubId, 'I' 
				FROM dcSendDetailHub 				
				WHERE 
					dcSendMasterHubId = @dcSendMasterHubId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.dcSendDetailHubId, ddh.modType
				FROM dcSendDetailHubHistory ddh WITH(NOLOCK)
				INNER JOIN dcSendDetailHub dd WITH(NOLOCK) ON ddh.dcSendDetailHubId = dd.dcSendDetailHubId 		
				WHERE 
					dd.dcSendMasterHubId = @dcSendMasterHubId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					@logIdentifier = 'dcSendDetailHubId'
					,@logParamMain = 'dcSendDetailHub'
					,@logParamMod = 'dcSendDetailHubHistory'
					,@module = '20'
					,@tableAlias = 'Hub Default Send Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM dcSendDetailHub WHERE approvedBy IS NULL AND dcSendDetailHubId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM dcSendDetailHubHistory WHERE dcSendDetailHubId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE dcSendDetailHub SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE dcSendDetailHubId = @detailId
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'U'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
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
						WHERE mode.dcSendDetailHubId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE dcSendDetailHub SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE dcSendDetailHubId = @detailId
					END
					
					UPDATE dcSendDetailHubHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE dcSendDetailHubId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcSendMasterHubId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @dcSendMasterHubId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcSendMasterHubId
END CATCH


GO
