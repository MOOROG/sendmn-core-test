USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcPayMasterSA]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcPayMasterSA]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dcPayMasterSAId					VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@rCountry                          INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@commissionBase                    INT				= NULL
	,@commissionCurrency				VARCHAR(3)		= NULL
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
		 @ApprovedFunctionId = 20191230
		,@logIdentifier = 'dcPayMasterSAId'
		,@logParamMain = 'dcPayMasterSA'
		,@logParamMod = 'dcPayMasterSAHistory'
		,@module = '20'
		,@tableAlias = 'Super Agent Default Paying Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
		
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM dcPayMasterSA WHERE 
				ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
				ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
				ISNULL(tranType, 0) = ISNULL(tranType, 0) AND
				baseCurrency = @baseCurrency AND 
				commissionCurrency = @commissionCurrency AND
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcPayMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcPayMasterSA (
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
				
				
			SET @dcPayMasterSAId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcPayMasterSAId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSAHistory WITH(NOLOCK)
				WHERE dcPayMasterSAId = @dcPayMasterSAId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcPayMasterSAHistory mode WITH(NOLOCK)
			INNER JOIN dcPayMasterSA main WITH(NOLOCK) ON mode.dcPayMasterSAId = main.dcPayMasterSAId
			WHERE mode.dcPayMasterSAId= @dcPayMasterSAId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcPayMasterSA WITH(NOLOCK) WHERE dcPayMasterSAId = @dcPayMasterSAId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayMasterSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSAHistory WITH(NOLOCK)
			WHERE dcPayMasterSAId  = @dcPayMasterSAId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayMasterSAId
			RETURN
		END
		IF EXISTS(SELECT 'x' FROM dcPayMasterSA WHERE 
				dcPayMasterSAId <> @dcPayMasterSAId AND
				ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
				ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
				ISNULL(tranType, 0) = ISNULL(tranType, 0) AND
				baseCurrency = @baseCurrency AND 
				commissionCurrency = @commissionCurrency AND
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcPayMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayMasterSA WHERE approvedBy IS NULL AND dcPayMasterSAId  = @dcPayMasterSAId)			
			BEGIN				
				UPDATE dcPayMasterSA SET
					 code							= @code
					,[description]					= @description
					,sCountry						= @sCountry
					,rCountry						= @rCountry
					,baseCurrency					= @baseCurrency
					,commissionCurrency				= @commissionCurrency
					,tranType						= @tranType
					,commissionBase					= @commissionBase
					,isEnable						= @isEnable				
				WHERE dcPayMasterSAId = @dcPayMasterSAId				
			END
			ELSE
			BEGIN
				DELETE FROM dcPayMasterSAHistory WHERE dcPayMasterSAId = @dcPayMasterSAId AND approvedBy IS NULL
				INSERT INTO dcPayMasterSAHistory(
					 dcPayMasterSAId
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
					 @dcPayMasterSAId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcPayMasterSAId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcPayMasterSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcPayMasterSAHistory  WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcPayMasterSAId
			RETURN
		END
		
			INSERT INTO dcPayMasterSAHistory(
				 dcPayMasterSAId
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
				 dcPayMasterSAId
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
			FROM dcPayMasterSA WHERE dcPayMasterSAId = @dcPayMasterSAId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcPayMasterSAId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcPayMasterSAId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcPayMasterSAId = ISNULL(mode.dcPayMasterSAId, main.dcPayMasterSAId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)				
					,sCountry = ISNULL(mode.sCountry, main.sCountry)				
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,commissionCurrency = ISNULL(mode.commissionCurrency, main.commissionCurrency)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END	
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcPayMasterSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcPayMasterSA main WITH(NOLOCK)
					LEFT JOIN dcPayMasterSAHistory mode ON main.dcPayMasterSAId = mode.dcPayMasterSAId AND mode.approvedBy IS NULL
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
			 dcPayMasterSAId
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
					 dcPayMasterSAId = ISNULL(mode.dcPayMasterSAId, main.dcPayMasterSAId)
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
											(mode.dcPayMasterSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcPayMasterSA main WITH(NOLOCK)
					LEFT JOIN dcPayMasterSAHistory mode ON main.dcPayMasterSAId = mode.dcPayMasterSAId AND mode.approvedBy IS NULL
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
					 dcPayDetailSAId = main.dcPayDetailSAId
					,dcPayMasterSAId = main.dcPayMasterSAId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcPayDetailSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcPayDetailSA main WITH(NOLOCK)
					LEFT JOIN dcPayDetailSAHistory mode ON main.dcPayDetailSAId = mode.dcPayDetailSAId AND mode.approvedBy IS NULL
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
							 m.dcPayMasterSAId
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
						LEFT JOIN ' + @d + ' d ON m.dcPayMasterSAId = d.dcPayMasterSAId
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
				
						
						GROUP BY 
							 m.dcPayMasterSAId
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
					
				--print @table
				--
			SET @sql_filter = ' '

			IF @hasChanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
					
			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @sCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
			
			IF @tranType IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
			SET @select_field_list = '
					 dcPayMasterSAId
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
			SET @sortBy = 'dcPayMasterSAId'
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
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayMasterSAId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcPayMasterSA WHERE approvedBy IS NULL AND dcPayMasterSAId = @dcPayMasterSAId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayMasterSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayMasterSAId
					RETURN
				END
			DELETE FROM dcPayMasterSA WHERE dcPayMasterSAId =  @dcPayMasterSAId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayMasterSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcPayMasterSAId
					RETURN
				END
				DELETE FROM dcPayMasterSAHistory WHERE dcPayMasterSAId = @dcPayMasterSAId AND approvedBy IS NULL
		
		END
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				dcPayDetailSAId, 'I' 
			FROM dcPayDetailSA 				
			WHERE 
				dcPayMasterSAId = @dcPayMasterSAId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.dcPayDetailSAId, mode.modType
			FROM dcPayDetailSAHistory mode WITH(NOLOCK)
			INNER JOIN dcPayDetailSA main WITH(NOLOCK) ON mode.dcPayDetailSAId = main.dcPayDetailSAId 		
			WHERE 
				main.dcPayMasterSAId = @dcPayMasterSAId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'dcPayDetailSAId'
				,@logParamMain = 'dcPayDetailSA'
				,@logParamMod = 'dcPayDetailSAHistory'
				,@module = '20'
				,@tableAlias = 'Super Agent Default Pay Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM dcPayDetailSA WHERE approvedBy IS NULL AND dcPayDetailSAId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM dcPayDetailSAHistory WHERE dcPayDetailSAId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM dcPayDetailSA WHERE dcPayDetailSAId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM dcPayDetailSAHistory WHERE dcPayDetailSAId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcPayMasterSAId
	END

	ELSE IF @flag IN ('approve', 'approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcPayMasterSA WITH(NOLOCK)
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcPayMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcPayMasterSA WHERE approvedBy IS NULL AND dcPayMasterSAId = @dcPayMasterSAId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcPayMasterSAHistory WHERE dcPayMasterSAId = @dcPayMasterSAId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcPayMasterSA SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcPayMasterSAId = @dcPayMasterSAId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterSAId, @oldValue OUTPUT
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
				FROM dcPayMasterSA main
				INNER JOIN dcPayMasterSAHistory mode ON mode.dcPayMasterSAId = main.dcPayMasterSAId
				WHERE mode.dcPayMasterSAId = @dcPayMasterSAId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcPayMasterSA', 'dcPayMasterSAId', @dcPayMasterSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcPayMasterSAId, @oldValue OUTPUT
				UPDATE dcPayMasterSA SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcPayMasterSAId = @dcPayMasterSAId
			END
			
			UPDATE dcPayMasterSAHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcPayMasterSAId = @dcPayMasterSAId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcPayMasterSAId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					dcPayDetailSAId, 'I' 
				FROM dcPayDetailSA 				
				WHERE 
					dcPayMasterSAId = @dcPayMasterSAId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.dcPayDetailSAId, ddh.modType
				FROM dcPayDetailSAHistory ddh WITH(NOLOCK)
				INNER JOIN dcPayDetailSA dd WITH(NOLOCK) ON ddh.dcPayDetailSAId = dd.dcPayDetailSAId 		
				WHERE 
					dd.dcPayMasterSAId = @dcPayMasterSAId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					 @logIdentifier = 'dcPayDetailSAId'
					,@logParamMain = 'dcPayDetailSA'
					,@logParamMod = 'dcPayDetailSAHistory'
					,@module = '20'
					,@tableAlias = 'Super Agent Default Pay Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM dcPayDetailSA WHERE approvedBy IS NULL AND dcPayDetailSAId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM dcPayDetailSAHistory WHERE dcPayDetailSAId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE dcPayDetailSA SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE dcPayDetailSAId = @detailId
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
						FROM dcPayDetailSA main
						INNER JOIN dcPayDetailSAHistory mode ON mode.dcPayDetailSAId = main.dcPayDetailSAId
						WHERE mode.dcPayDetailSAId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE dcPayDetailSA SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE dcPayDetailSAId = @detailId
					END
					
					UPDATE dcPayDetailSAHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE dcPayDetailSAId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcPayMasterSAId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @dcPayMasterSAId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcPayMasterSAId
END CATCH



GO
