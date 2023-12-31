USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcPayMaster]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcPayMaster]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dcPayMasterId						VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@rCountry                          INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@commissionBase                    INT				= NULL
	,@commissionCurrency				VARCHAR(3)		= NULL
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
		 @ApprovedFunctionId = 20131230
		,@logIdentifier = 'dcPayMasterId'
		,@logParamMain = 'dcPayMaster'
		,@logParamMod = 'dcPayMasterHistory'
		,@module = '20'
		,@tableAlias = 'Default Paying Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
		
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM dcPayMaster WHERE 
				ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
				ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
				ISNULL(tranType, 0) = ISNULL(tranType, 0) AND
				baseCurrency = @baseCurrency AND 
				commissionCurrency = @commissionCurrency AND
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcPayMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcPayMaster (
				 code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,commissionBase
				,commissionCurrency
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
				,@commissionCurrency
				,@isEnable
				,@user
				,GETDATE()
				
				
			SET @dcPayMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcPayMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHistory WITH(NOLOCK)
				WHERE dcPayMasterId = @dcPayMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcPayMasterHistory mode WITH(NOLOCK)
			INNER JOIN dcPayMaster main WITH(NOLOCK) ON mode.dcPayMasterId = main.dcPayMasterId
			WHERE mode.dcPayMasterId= @dcPayMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcPayMaster WITH(NOLOCK) WHERE dcPayMasterId = @dcPayMasterId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHistory WITH(NOLOCK)
			WHERE dcPayMasterId  = @dcPayMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayMasterId
			RETURN
		END
		IF EXISTS(SELECT 'x' FROM dcPayMaster WHERE
				dcPayMasterId <> @dcPayMasterId AND 
				ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
				ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
				ISNULL(tranType, 0) = ISNULL(tranType, 0) AND
				baseCurrency = @baseCurrency AND 
				commissionCurrency = @commissionCurrency AND
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcPayMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayMaster WHERE approvedBy IS NULL AND dcPayMasterId  = @dcPayMasterId)			
			BEGIN				
				UPDATE dcPayMaster SET
					 code							= @code
					,[description]					= @description
					,sCountry						= @sCountry
					,rCountry						= @rCountry
					,baseCurrency					= @baseCurrency
					,tranType						= @tranType
					,commissionBase					= @commissionBase
					,commissionCurrency				= @commissionCurrency
					,isEnable						= @isEnable				
				WHERE dcPayMasterId = @dcPayMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM dcPayMasterHistory WHERE dcPayMasterId = @dcPayMasterId AND approvedBy IS NULL
				INSERT INTO dcPayMasterHistory(
					 dcPayMasterId
					,code
					,[description]
					,sCountry
					,rCountry
					,baseCurrency
					,tranType
					,commissionBase
					,commissionCurrency
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @dcPayMasterId
					,@code
					,@description
					,@sCountry
					,@rCountry
					,@baseCurrency
					,@tranType
					,@commissionBase
					,@commissionCurrency
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcPayMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterHistory  WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcPayMasterId
			RETURN
		END
		
			INSERT INTO dcPayMasterHistory(
				 dcPayMasterId
				,code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,commissionBase
				,commissionCurrency
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 dcPayMasterId
				,code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,commissionBase
				,commissionCurrency
				,isEnable
				,@user
				,GETDATE()
				,'D'
			FROM dcPayMaster WHERE dcPayMasterId = @dcPayMasterId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcPayMasterId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcPayMasterId = ISNULL(mode.dcPayMasterId, main.dcPayMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)				
					,sCountry = ISNULL(mode.sCountry, main.sCountry)				
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,commissionCurrency = ISNULL(mode.commissionCurrency,main.commissionCurrency)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcPayMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcPayMaster main WITH(NOLOCK)
					LEFT JOIN dcPayMasterHistory mode ON main.dcPayMasterId = mode.dcPayMasterId AND mode.approvedBy IS NULL
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
			 dcPayMasterId
			,code
			,description
			,sCountry
			,rCountry
			,baseCurrency
			,tranType
			,commissionBase
			,commissionCurrency
			,isEnable
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
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
					 dcPayMasterId = ISNULL(mode.dcPayMasterId, main.dcPayMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sCountry = ISNULL(mode.sCountry, main.sCountry)				
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,commissionCurrency = ISNULL(mode.commissionCurrency,main.commissionCurrency)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END										
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcPayMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcPayMaster main WITH(NOLOCK)
					LEFT JOIN dcPayMasterHistory mode ON main.dcPayMasterId = mode.dcPayMasterId AND mode.approvedBy IS NULL
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
						AND ISNULL(main.isDeleted, '''') <> ''Y''
			) '
			
			
		SET @d = '(
				SELECT
					 dcPayDetailId = main.dcPayDetailId
					,dcPayMasterId = main.dcPayMasterId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END				
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcPayDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcPayDetail main WITH(NOLOCK)
					LEFT JOIN dcPayDetailHistory mode ON main.dcPayDetailId = mode.dcPayDetailId AND mode.approvedBy IS NULL
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
						AND ISNULL(main.isDeleted, '''') <> ''Y''
			) '
	
			SET @table = ' 
					(
						SELECT
							 m.dcPayMasterId
							,m.description
							,m.sCountry
							,sCountryName = sc.countryName
							,m.rCountry
							,rCountryName = rc.countryName
							,m.tranType
							,tranTypeName = ISNULL(trn.typeTitle, ''All'')
							,m.baseCurrency
							,m.commissionCurrency
							,m.isEnable
							,fromAmt = MIN(d.fromAmt)
							,toAmt = MAX(d.toAmt)	
							,modifiedBy = MAX(ISNULL(m.modifiedBy, d.modifiedBy))						
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.dcPayMasterId = d.dcPayMasterId
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
				
						
						GROUP BY 
							 m.dcPayMasterId
							,m.description
							,m.sCountry
							,sc.countryName
							,m.rCountry
							,rc.countryName
							,m.tranType
							,trn.typeTitle
							,m.baseCurrency
							,m.commissionCurrency
							,m.isEnable
							--,m.modifiedBy
							--,d.modifiedBy
					) x
					'
					
				print @table
				--
			SET @sql_filter = ' '
			IF @hasChanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged + ''''

			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @sCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
			
			IF @tranType IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
			SET @select_field_list = '
					 dcPayMasterId
					,description
					,sCountry
					,sCountryName
					,rCountry
					,rCountryName
					,tranType
					,tranTypeName
					,baseCurrency
					,commissionCurrency
					,fromAmt
					,toAmt
					,modifiedBy
					,hasChanged
					
				'
				
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'dcPayMasterId'
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
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcPayMaster WHERE approvedBy IS NULL AND dcPayMasterId = @dcPayMasterId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayMasterId
					RETURN
				END
			DELETE FROM dcPayMaster WHERE dcPayMasterId =  @dcPayMasterId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayMasterId
					RETURN
				END
				DELETE FROM dcPayMasterHistory WHERE dcPayMasterId = @dcPayMasterId AND approvedBy IS NULL
		
		END
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				dcPayDetailId, 'I' 
			FROM dcPayDetail 				
			WHERE 
				dcPayMasterId = @dcPayMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.dcPayDetailId, mode.modType
			FROM dcPayDetailHistory mode WITH(NOLOCK)
			INNER JOIN dcPayDetail main WITH(NOLOCK) ON mode.dcPayDetailId = main.dcPayDetailId 		
			WHERE 
				main.dcPayMasterId = @dcPayMasterId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'dcPayDetailId'
				,@logParamMain = 'dcPayDetail'
				,@logParamMod = 'dcPayDetailHistory'
				,@module = '20'
				,@tableAlias = 'Default Pay Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM dcPayDetail WHERE approvedBy IS NULL AND dcPayDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM dcPayDetailHistory WHERE dcPayDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM dcPayDetail WHERE dcPayDetailId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM dcPayDetailHistory WHERE dcPayDetailId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcPayMasterId
	END

	ELSE IF @flag IN ('approve', 'approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayMaster WITH(NOLOCK)
			WHERE dcPayMasterId = @dcPayMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayMaster WHERE approvedBy IS NULL AND dcPayMasterId = @dcPayMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcPayMasterHistory WHERE dcPayMasterId = @dcPayMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcPayMaster SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcPayMasterId = @dcPayMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterId, @oldValue OUTPUT
				UPDATE main SET
					 main.code                          = mode.code
					,main.[description]                 = mode.[description]
					,main.sCountry                      = mode.sCountry
					,main.rCountry                      = mode.rCountry
					,main.baseCurrency                  = mode.baseCurrency
					,main.tranType                      = mode.tranType
					,main.commissionBase				= mode.commissionBase
					,main.commissionCurrency			= mode.commissionCurrency
					,main.isEnable						= mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcPayMaster main
				INNER JOIN dcPayMasterHistory mode ON mode.dcPayMasterId = main.dcPayMasterId
				WHERE mode.dcPayMasterId = @dcPayMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcPayMaster', 'dcPayMasterId', @dcPayMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterId, @oldValue OUTPUT
				UPDATE dcPayMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcPayMasterId = @dcPayMasterId
			END
			
			UPDATE dcPayMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcPayMasterId = @dcPayMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					dcPayDetailId, 'I' 
				FROM dcPayDetail 				
				WHERE 
					dcPayMasterId = @dcPayMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.dcPayDetailId, ddh.modType
				FROM dcPayDetailHistory ddh WITH(NOLOCK)
				INNER JOIN dcPayDetail dd WITH(NOLOCK) ON ddh.dcPayDetailId = dd.dcPayDetailId 		
				WHERE 
					dd.dcPayMasterId = @dcPayMasterId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					 @logIdentifier = 'dcPayDetailId'
					,@logParamMain = 'dcPayDetail'
					,@logParamMod = 'dcPayDetailHistory'
					,@module = '20'
					,@tableAlias = 'Default Pay Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM dcPayDetail WHERE approvedBy IS NULL AND dcPayDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM dcPayDetailHistory WHERE dcPayDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE dcPayDetail SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE dcPayDetailId = @detailId
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
						FROM dcPayDetail main
						INNER JOIN dcPayDetailHistory mode ON mode.dcPayDetailId = main.dcPayDetailId
						WHERE mode.dcPayDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE dcPayDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE dcPayDetailId = @detailId
					END
					
					UPDATE dcPayDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE dcPayDetailId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcPayMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @dcPayMasterId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcPayMasterId
END CATCH


GO
