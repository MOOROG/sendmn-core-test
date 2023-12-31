USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dscMaster]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dscMaster]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dscMasterId                       VARCHAR(30)		= NULL
	,@code                              VARCHAR(10)		= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@rCountry                          INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@isEnable							CHAR(1)			= NULL
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
		 @ApprovedFunctionId = 20141030
		,@logIdentifier = 'dscMasterId'
		,@logParamMain = 'dscMaster'
		,@logParamMod = 'dscMasterHistory'
		,@module = '20'
		,@tableAlias = 'Default Service Charge'
		
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
	
	
	IF @flag = 'scl'
	BEGIN
		SELECT 
             ccm.countryId
            ,ccm.countryName
            ,cnt = COUNT(rCountry)
        FROM countryMaster ccm WITH(NOLOCK)
        LEFT JOIN dscMaster dscm WITH(NOLOCK) ON ccm.countryId = dscm.sCountry
        WHERE ISNULL(ccm.isDeleted, 'N') <> 'Y'
        GROUP BY ccm.countryId, ccm.countryName
        RETURN
	END
	ELSE IF @flag = 'rcl'
	BEGIN
		SELECT
			 dscMasterId = MAX(dscm.dscMasterId)			
			,rCountryId =  ccm.countryId
			,rCountryName = ccm.countryName
			,tranTypeName = stm.typeTitle
			,tranType = dscm.tranType
			,fromAmt = MIN(dscd.fromAmt)
			,toAmt = MAX(dscd.toAmt)
		INTO #tmpRcl
		FROM dscMaster dscm WITH(NOLOCK)
		INNER JOIN countryMaster ccm WITH(NOLOCK) ON dscm.rCountry = ccm.countryId 
		LEFT JOIN dscDetail dscd WITH(NOLOCK) ON dscm.dscMasterId = dscd.dscMasterId
		
		LEFT JOIN serviceTypeMaster stm ON dscm.tranType = stm.serviceTypeId

		WHERE dscm.sCountry = @sCountry
		GROUP BY ccm.countryId, ccm.countryName,stm.typeTitle, dscm.tranType
		
		ORDER BY ccm.countryName, stm.typeTitle
		
	END
	
	
	ELSE IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM dscMaster WHERE 
					sCountry = @sCountry 
				AND rCountry = @rCountry 
				AND ISNULL(tranType, 0) = ISNULL(@tranType, 0)
				AND baseCurrency = @baseCurrency 
				AND ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dscMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dscMaster (
				 code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
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
				,@isEnable
				,@user
				,GETDATE()
				
				
			SET @dscMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dscMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dscMasterHistory WITH(NOLOCK)
				WHERE dscMasterId = @dscMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dscMasterHistory mode WITH(NOLOCK)
			INNER JOIN dscMaster main WITH(NOLOCK) ON mode.dscMasterId = main.dscMasterId
			WHERE mode.dscMasterId= @dscMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dscMaster WITH(NOLOCK) WHERE dscMasterId = @dscMasterId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dscMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dscMasterHistory WITH(NOLOCK)
			WHERE dscMasterId  = @dscMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dscMasterId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM dscMaster WHERE 
						dscMasterId <> @dscMasterId 
					AND sCountry = @sCountry 
					AND rCountry = @rCountry 
					AND ISNULL(tranType, 0) = ISNULL(@tranType, 0)
					AND baseCurrency = @baseCurrency  
					AND ISNULL(isDeleted,'N')<>'Y'
					)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dscMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dscMaster WHERE approvedBy IS NULL AND dscMasterId  = @dscMasterId)			
			BEGIN				
				UPDATE dscMaster SET
					 code							= @code
					,[description]					= @description
					,sCountry						= @sCountry
					,rCountry						= @rCountry
					,baseCurrency					= @baseCurrency
					,tranType						= @tranType
					,isEnable						= @isEnable				
				WHERE dscMasterId = @dscMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM dscMasterHistory WHERE dscMasterId = @dscMasterId AND approvedBy IS NULL
				INSERT INTO dscMasterHistory(
					 dscMasterId
					,code
					,[description]
					,sCountry
					,rCountry
					,baseCurrency
					,tranType
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @dscMasterId
					,@code
					,@description
					,@sCountry
					,@rCountry
					,@baseCurrency
					,@tranType
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dscMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (SELECT 'X' FROM dscMaster WITH(NOLOCK) WHERE dscMasterId = @dscMasterId  AND (createdBy <> @user AND approvedBy IS NULL))
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. You are trying to perform an illegal operation.', @dscMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dscMasterHistory  WITH(NOLOCK) WHERE dscMasterId = @dscMasterId AND approvedBy IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @dscMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dscDetail WITH(NOLOCK) WHERE dscMasterId = @dscMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Please delete details data before deleting the master data.', @dscMasterId
			RETURN
		END
		
			INSERT INTO dscMasterHistory(
				 dscMasterId
				,code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 dscMasterId
				,code
				,[description]
				,sCountry
				,rCountry
				,baseCurrency
				,tranType
				,isEnable
				,@user
				,GETDATE()
				,'D'
			FROM dscMaster WHERE dscMasterId = @dscMasterId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dscMasterId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dscMasterId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dscMasterId = ISNULL(mode.dscMasterId, main.dscMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sCountry = ISNULL(mode.sCountry, main.sCountry)				
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedDate = ISNULL(mode.createdDate, main.modifiedDate)
					,modifiedBy = ISNULL(mode.createdBy, main.modifiedBy)
					,hasChanged = CASE WHEN (main.approvedBy IS NULL AND main.createdBy <> ''' + @user + ''') OR 
											(mode.dscMasterId IS NOT NULL AND mode.createdBy <> ''' + @user + ''') 
										THEN ''Y'' ELSE ''N'' END
				FROM dscMaster main WITH(NOLOCK)
					LEFT JOIN dscMasterHistory mode ON main.dscMasterId = mode.dscMasterId AND mode.approvedBy IS NULL
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
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
			
			
			
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
	
		IF @rCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
		
		IF @sCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
		
		IF @tranType IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
		
		SET @select_field_list = '
			 dscMasterId
			,code
			,description
			,sCountry
			,rCountry
			,baseCurrency
			,tranType
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
					 dscMasterId = ISNULL(mode.dscMasterId, main.dscMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sCountry = ISNULL(mode.sCountry, main.sCountry)				
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END											
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dscMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dscMaster main WITH(NOLOCK)
					LEFT JOIN dscMasterHistory mode ON main.dscMasterId = mode.dscMasterId AND mode.approvedBy IS NULL
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
					 dscDetailId = main.dscDetailId
					,dscMasterId = main.dscMasterId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dscDetailId IS NOT NULL) THEN ''Y'' ELSE ''N'' END

				FROM dscDetail main WITH(NOLOCK)
					LEFT JOIN dscDetailHistory mode ON main.dscDetailId = mode.dscDetailId AND mode.approvedBy IS NULL
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
							 m.dscMasterId
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
						LEFT JOIN ' + @d + ' d ON m.dscMasterId = d.dscMasterId
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
						
						GROUP BY 
							 m.dscMasterId
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
			
			IF @haschanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND haschanged = ''' + CAST(@haschanged AS VARCHAR) + ''''

			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @sCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
			
			IF @tranType IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))

			
			SET @select_field_list = '
					 dscMasterId
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
			SET @sortBy = 'dscMasterId'
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
	
	ELSE IF @flag IN('reject', 'rejectAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dscMasterId
			RETURN
		END
		
		BEGIN TRANSACTION
		IF EXISTS (SELECT 'X' FROM dscMaster WHERE approvedBy IS NULL AND dscMasterId = @dscMasterId)
		BEGIN --New record			
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dscMasterId, @user, @oldValue, @newValue
								
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dscMasterId
					RETURN
				END
			DELETE FROM dscMaster WHERE dscMasterId =  @dscMasterId
			
		END
		ELSE
		BEGIN
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dscMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dscMasterId
					RETURN
				END
				DELETE FROM dscMasterHistory WHERE dscMasterId = @dscMasterId AND approvedBy IS NULL
			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				dscDetailId, 'I' 
			FROM dscDetail 				
			WHERE 
				dscMasterId = @dscMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				ddh.dscDetailId, ddh.modType
			FROM dscDetailHistory ddh WITH(NOLOCK)
			INNER JOIN dscDetail dd WITH(NOLOCK) ON ddh.dscDetailId = dd.dscDetailId 		
			WHERE 
				dd.dscMasterId = @dscMasterId
				AND ddh.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'dscDetailId'
				,@logParamMain = 'dscDetail'
				,@logParamMod = 'dscDetailHistory'
				,@module = '20'
				,@tableAlias = 'Default Service Charge Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM dscDetail WHERE approvedBy IS NULL AND dscDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM dscDetailHistory WHERE dscDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM dscDetail WHERE dscDetailId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM dscDetailHistory WHERE dscDetailId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dscMasterId
	END

	ELSE IF @flag  IN ('approve', 'approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dscMaster WITH(NOLOCK)
			WHERE dscMasterId = @dscMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dscMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dscMaster WHERE approvedBy IS NULL AND dscMasterId = @dscMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dscMasterHistory WHERE dscMasterId = @dscMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dscMaster SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dscMasterId = @dscMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscMasterId, @oldValue OUTPUT
				UPDATE main SET
					 main.code                          = mode.code
					,main.[description]                 = mode.[description]
					,main.sCountry                      = mode.sCountry
					,main.rCountry                      = mode.rCountry
					,main.baseCurrency                  = mode.baseCurrency
					,main.tranType                      = mode.tranType
					,main.isEnable						= mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dscMaster main
				INNER JOIN dscMasterHistory mode ON mode.dscMasterId = main.dscMasterId
				WHERE mode.dscMasterId = @dscMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dscMaster', 'dscMasterId', @dscMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dscMasterId, @oldValue OUTPUT
				UPDATE dscMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dscMasterId = @dscMasterId
			END
			
			UPDATE dscMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dscMasterId = @dscMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dscMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					dscDetailId, 'I' 
				FROM dscDetail 				
				WHERE 
					dscMasterId = @dscMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.dscDetailId, ddh.modType
				FROM dscDetailHistory ddh WITH(NOLOCK)
				INNER JOIN dscDetail dd WITH(NOLOCK) ON ddh.dscDetailId = dd.dscDetailId 		
				WHERE 
					dd.dscMasterId = @dscMasterId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					@logIdentifier = 'dscDetailId'
					,@logParamMain = 'dscDetail'
					,@logParamMod = 'dscDetailHistory'
					,@module = '20'
					,@tableAlias = 'Default Service Charge Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM dscDetail WHERE approvedBy IS NULL AND dscDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM dscDetailHistory WHERE dscDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE dscDetail SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE dscDetailId = @detailId
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
						FROM dscDetail main
						INNER JOIN dscDetailHistory mode ON mode.dscDetailId = main.dscDetailId
						WHERE mode.dscDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE dscDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE dscDetailId = @detailId
					END
					
					UPDATE dscDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE dscDetailId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dscMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @dscMasterId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dscMasterId
END CATCH



GO
