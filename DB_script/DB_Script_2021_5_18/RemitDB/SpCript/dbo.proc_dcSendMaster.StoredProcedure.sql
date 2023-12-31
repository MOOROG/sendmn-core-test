USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcSendMaster]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcSendMaster]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dcSendMasterId                    VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@rCountry                          INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@commissionBase                    INT				= NULL
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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20131030
		,@logIdentifier = 'dcSendMasterId'
		,@logParamMain = 'dcSendMaster'
		,@logParamMod = 'dcSendMasterHistory'
		,@module = '20'
		,@tableAlias = 'Default Sending Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
		
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM dcSendMaster WHERE 
					ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
					ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
					ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
					baseCurrency = @baseCurrency AND 
					ISNULL(isDeleted,'N')<>'Y'
					)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcSendMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcSendMaster (
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
				
				
			SET @dcSendMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcSendMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHistory WITH(NOLOCK)
				WHERE dcSendMasterId = @dcSendMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcSendMasterHistory mode WITH(NOLOCK)
			INNER JOIN dcSendMaster main WITH(NOLOCK) ON mode.dcSendMasterId = main.dcSendMasterId
			WHERE mode.dcSendMasterId= @dcSendMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcSendMaster WITH(NOLOCK) WHERE dcSendMasterId = @dcSendMasterId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHistory WITH(NOLOCK)
			WHERE dcSendMasterId  = @dcSendMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterId
			RETURN
		END
		IF EXISTS(SELECT 'x' FROM dcSendMaster WHERE 
					dcSendMasterId = @dcSendMasterId AND
					ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
					ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
					ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
					baseCurrency = @baseCurrency AND 
					ISNULL(isDeleted,'N')<>'Y'
					)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcSendMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendMaster WHERE approvedBy IS NULL AND dcSendMasterId  = @dcSendMasterId)			
			BEGIN				
				UPDATE dcSendMaster SET
					 code							= @code
					,[description]					= @description
					,sCountry						= @sCountry
					,rCountry						= @rCountry
					,baseCurrency					= @baseCurrency
					,tranType						= @tranType
					,commissionBase					= @commissionBase
					,isEnable						= @isEnable				
				WHERE dcSendMasterId = @dcSendMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM dcSendMasterHistory WHERE dcSendMasterId = @dcSendMasterId AND approvedBy IS NULL
				INSERT INTO dcSendMasterHistory(
					 dcSendMasterId
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
					 @dcSendMasterId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcSendMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterHistory  WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcSendMasterId
			RETURN
		END
		
			INSERT INTO dcSendMasterHistory(
				 dcSendMasterId
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
				 dcSendMasterId
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
			FROM dcSendMaster WHERE dcSendMasterId = @dcSendMasterId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendMasterId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcSendMasterId = ISNULL(mode.dcSendMasterId, main.dcSendMasterId)
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
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.dcSendMasterId IS NOT NULL THEN ''Y'' ELSE ''N'' END
				FROM dcSendMaster main WITH(NOLOCK)
					LEFT JOIN dcSendMasterHistory mode ON main.dcSendMasterId = mode.dcSendMasterId AND mode.approvedBy IS NULL
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
			 dcSendMasterId
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
					 dcSendMasterId = ISNULL(mode.dcSendMasterId, main.dcSendMasterId)
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
											(mode.dcSendMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcSendMaster main WITH(NOLOCK)
					LEFT JOIN dcSendMasterHistory mode ON main.dcSendMasterId = mode.dcSendMasterId AND mode.approvedBy IS NULL
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
					 dcSendDetailId = main.dcSendDetailId
					,dcSendMasterId = main.dcSendMasterId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcSendDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcSendDetail main WITH(NOLOCK)
					LEFT JOIN dcSendDetailHistory mode ON main.dcSendDetailId = mode.dcSendDetailId AND mode.approvedBy IS NULL
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
							 m.dcSendMasterId
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
						LEFT JOIN ' + @d + ' d ON m.dcSendMasterId = d.dcSendMasterId
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
				
						
						GROUP BY 
							 m.dcSendMasterId
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
				SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged + ''''
				
			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @sCountry IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
			
			IF @tranType IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
			SET @select_field_list = '
					 dcSendMasterId
					,description
					,sCountry
					,sCountryName
					,rCountry
					,rCountryName
					,tranType
					,tranTypeName
					,baseCurrency
					,fromAmt
					,toAmt
					,modifiedBy
					,hasChanged
					
				'
				
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendMasterId'
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
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcSendMaster WHERE approvedBy IS NULL AND dcSendMasterId = @dcSendMasterId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendMasterId
					RETURN
				END
			DELETE FROM dcSendMaster WHERE dcSendMasterId =  @dcSendMasterId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendMasterId
					RETURN
				END
				DELETE FROM dcSendMasterHistory WHERE dcSendMasterId = @dcSendMasterId AND approvedBy IS NULL
			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				dcSendDetailId, 'I' 
			FROM dcSendDetail 				
			WHERE 
				dcSendMasterId = @dcSendMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.dcSendDetailId, mode.modType
			FROM dcSendDetailHistory mode WITH(NOLOCK)
			INNER JOIN dcSendDetail main WITH(NOLOCK) ON mode.dcSendDetailId = main.dcSendDetailId 		
			WHERE 
				main.dcSendMasterId = @dcSendMasterId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'dcSendDetailId'
				,@logParamMain = 'dcSendDetail'
				,@logParamMod = 'dcSendDetailHistory'
				,@module = '20'
				,@tableAlias = 'Default Send Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM dcSendDetail WHERE approvedBy IS NULL AND dcSendDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM dcSendDetailHistory WHERE dcSendDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM dcSendDetail WHERE dcSendDetailId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM dcSendDetailHistory WHERE dcSendDetailId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcSendMasterId
	END

	ELSE IF @flag IN ('approve','approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendMaster WITH(NOLOCK)
			WHERE dcSendMasterId = @dcSendMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendMaster WHERE approvedBy IS NULL AND dcSendMasterId = @dcSendMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcSendMasterHistory WHERE dcSendMasterId = @dcSendMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcSendMaster SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcSendMasterId = @dcSendMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterId, @oldValue OUTPUT
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
				FROM dcSendMaster main
				INNER JOIN dcSendMasterHistory mode ON mode.dcSendMasterId = main.dcSendMasterId
				WHERE mode.dcSendMasterId = @dcSendMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcSendMaster', 'dcSendMasterId', @dcSendMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterId, @oldValue OUTPUT
				UPDATE dcSendMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcSendMasterId = @dcSendMasterId
			END
			
			UPDATE dcSendMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcSendMasterId = @dcSendMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					dcSendDetailId, 'I' 
				FROM dcSendDetail 				
				WHERE 
					dcSendMasterId = @dcSendMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.dcSendDetailId, ddh.modType
				FROM dcSendDetailHistory ddh WITH(NOLOCK)
				INNER JOIN dcSendDetail dd WITH(NOLOCK) ON ddh.dcSendDetailId = dd.dcSendDetailId 		
				WHERE 
					dd.dcSendMasterId = @dcSendMasterId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					@logIdentifier = 'dcSendDetailId'
					,@logParamMain = 'dcSendDetail'
					,@logParamMod = 'dcSendDetailHistory'
					,@module = '20'
					,@tableAlias = 'Default Send Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM dcSendDetail WHERE approvedBy IS NULL AND dcSendDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM dcSendDetailHistory WHERE dcSendDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE dcSendDetail SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE dcSendDetailId = @detailId
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
						FROM dcSendDetail main
						INNER JOIN dcSendDetailHistory mode ON mode.dcSendDetailId = main.dcSendDetailId
						WHERE mode.dcSendDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE dcSendDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE dcSendDetailId = @detailId
					END
					
					UPDATE dcSendDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE dcSendDetailId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcSendMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @dcSendMasterId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcSendMasterId
END CATCH


GO
