USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcSendMasterSA]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcSendMasterSA]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dcSendMasterSAId                  VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@rCountry                          INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@commissionBase                    INT				= NULL
	,@hasChanged	                    CHAR(1)			= NULL
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
		 @ApprovedFunctionId = 20191030
		,@logIdentifier = 'dcSendMasterSAId'
		,@logParamMain = 'dcSendMasterSA'
		,@logParamMod = 'dcSendMasterSAHistory'
		,@module = '20'
		,@tableAlias = 'Default Super Agent Sending Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
		
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM dcSendMasterSA WHERE 
					ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
					ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
					ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
					baseCurrency = @baseCurrency AND 
					ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcSendMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcSendMasterSA (
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
				
				
			SET @dcSendMasterSAId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcSendMasterSAId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSAHistory WITH(NOLOCK)
				WHERE dcSendMasterSAId = @dcSendMasterSAId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcSendMasterSAHistory mode WITH(NOLOCK)
			INNER JOIN dcSendMasterSA main WITH(NOLOCK) ON mode.dcSendMasterSAId = main.dcSendMasterSAId
			WHERE mode.dcSendMasterSAId= @dcSendMasterSAId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcSendMasterSA WITH(NOLOCK) WHERE dcSendMasterSAId = @dcSendMasterSAId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSAHistory WITH(NOLOCK)
			WHERE dcSendMasterSAId  = @dcSendMasterSAId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterSAId
			RETURN
		END
		IF EXISTS(SELECT 'x' FROM dcSendMasterSA WHERE 
					dcSendMasterSAId <> @dcSendMasterSAId AND
					ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND 
					ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND 
					ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND
					baseCurrency = @baseCurrency AND 
					ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcSendMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendMasterSA WHERE approvedBy IS NULL AND dcSendMasterSAId  = @dcSendMasterSAId)			
			BEGIN				
				UPDATE dcSendMasterSA SET
					 code							= @code
					,[description]					= @description
					,sCountry						= @sCountry
					,rCountry						= @rCountry
					,baseCurrency					= @baseCurrency
					,tranType						= @tranType
					,commissionBase					= @commissionBase
					,isEnable						= @isEnable				
				WHERE dcSendMasterSAId = @dcSendMasterSAId				
			END
			ELSE
			BEGIN
				DELETE FROM dcSendMasterSAHistory WHERE dcSendMasterSAId = @dcSendMasterSAId AND approvedBy IS NULL
				INSERT INTO dcSendMasterSAHistory(
					 dcSendMasterSAId
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
					 @dcSendMasterSAId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcSendMasterSAId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcSendMasterSAId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcSendMasterSAHistory  WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcSendMasterSAId
			RETURN
		END
		
			INSERT INTO dcSendMasterSAHistory(
				 dcSendMasterSAId
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
				 dcSendMasterSAId
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
			FROM dcSendMasterSA WHERE dcSendMasterSAId = @dcSendMasterSAId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcSendMasterSAId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcSendMasterSAId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcSendMasterSAId = ISNULL(mode.dcSendMasterSAId, main.dcSendMasterSAId)
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
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.dcSendMasterSAId IS NOT NULL THEN ''Y'' ELSE ''N'' END
				FROM dcSendMasterSA main WITH(NOLOCK)
					LEFT JOIN dcSendMasterSAHistory mode ON main.dcSendMasterSAId = mode.dcSendMasterSAId AND mode.approvedBy IS NULL
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
			 dcSendMasterSAId
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
					 dcSendMasterSAId = ISNULL(mode.dcSendMasterSAId, main.dcSendMasterSAId)
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
											(mode.dcSendMasterSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcSendMasterSA main WITH(NOLOCK)
					LEFT JOIN dcSendMasterSAHistory mode ON main.dcSendMasterSAId = mode.dcSendMasterSAId AND mode.approvedBy IS NULL
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
					 dcSendDetailSAId = main.dcSendDetailSAId
					,dcSendMasterSAId = main.dcSendMasterSAId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcSendDetailSAId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcSendDetailSA main WITH(NOLOCK)
					LEFT JOIN dcSendDetailSAHistory mode ON main.dcSendDetailSAId = mode.dcSendDetailSAId AND mode.approvedBy IS NULL
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
							 m.dcSendMasterSAId
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
						LEFT JOIN ' + @d + ' d ON m.dcSendMasterSAId = d.dcSendMasterSAId
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
				
						
						GROUP BY 
							 m.dcSendMasterSAId
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
				SET @sql_filter  = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
	
			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @sCountry IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
			
			IF @tranType IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
			SET @select_field_list = '
					 dcSendMasterSAId
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
			SET @sortBy = 'dcSendMasterSAId'
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
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendMasterSAId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcSendMasterSA WHERE approvedBy IS NULL AND dcSendMasterSAId = @dcSendMasterSAId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendMasterSAId
					RETURN
				END
			DELETE FROM dcSendMasterSA WHERE dcSendMasterSAId =  @dcSendMasterSAId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterSAId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterSAId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcSendMasterSAId
					RETURN
				END
				DELETE FROM dcSendMasterSAHistory WHERE dcSendMasterSAId = @dcSendMasterSAId AND approvedBy IS NULL
			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				dcSendDetailSAId, 'I' 
			FROM dcSendDetailSA 				
			WHERE 
				dcSendMasterSAId = @dcSendMasterSAId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.dcSendDetailSAId, mode.modType
			FROM dcSendDetailSAHistory mode WITH(NOLOCK)
			INNER JOIN dcSendDetailSA main WITH(NOLOCK) ON mode.dcSendDetailSAId = main.dcSendDetailSAId 		
			WHERE 
				main.dcSendMasterSAId = @dcSendMasterSAId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'dcSendDetailSAId'
				,@logParamMain = 'dcSendDetailSA'
				,@logParamMod = 'dcSendDetailSAHistory'
				,@module = '20'
				,@tableAlias = 'Super Agent Default Send Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM dcSendDetailSA WHERE approvedBy IS NULL AND dcSendDetailSAId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM dcSendDetailSAHistory WHERE dcSendDetailSAId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM dcSendDetailSA WHERE dcSendDetailSAId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM dcSendDetailSAHistory WHERE dcSendDetailSAId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcSendMasterSAId
	END

	ELSE IF @flag IN ('approve','approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcSendMasterSA WITH(NOLOCK)
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcSendMasterSAId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcSendMasterSA WHERE approvedBy IS NULL AND dcSendMasterSAId = @dcSendMasterSAId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcSendMasterSAHistory WHERE dcSendMasterSAId = @dcSendMasterSAId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcSendMasterSA SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcSendMasterSAId = @dcSendMasterSAId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterSAId, @oldValue OUTPUT
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
				FROM dcSendMasterSA main
				INNER JOIN dcSendMasterSAHistory mode ON mode.dcSendMasterSAId = main.dcSendMasterSAId
				WHERE mode.dcSendMasterSAId = @dcSendMasterSAId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcSendMasterSA', 'dcSendMasterSAId', @dcSendMasterSAId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcSendMasterSAId, @oldValue OUTPUT
				UPDATE dcSendMasterSA SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcSendMasterSAId = @dcSendMasterSAId
			END
			
			UPDATE dcSendMasterSAHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcSendMasterSAId = @dcSendMasterSAId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcSendMasterSAId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					dcSendDetailSAId, 'I' 
				FROM dcSendDetailSA 				
				WHERE 
					dcSendMasterSAId = @dcSendMasterSAId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.dcSendDetailSAId, ddh.modType
				FROM dcSendDetailSAHistory ddh WITH(NOLOCK)
				INNER JOIN dcSendDetailSA dd WITH(NOLOCK) ON ddh.dcSendDetailSAId = dd.dcSendDetailSAId 		
				WHERE 
					dd.dcSendMasterSAId = @dcSendMasterSAId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					@logIdentifier = 'dcSendDetailSAId'
					,@logParamMain = 'dcSendDetailSA'
					,@logParamMod = 'dcSendDetailSAHistory'
					,@module = '20'
					,@tableAlias = 'Super Agent Default Send Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM dcSendDetailSA WHERE approvedBy IS NULL AND dcSendDetailSAId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM dcSendDetailSAHistory WHERE dcSendDetailSAId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE dcSendDetailSA SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE dcSendDetailSAId = @detailId
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
						FROM dcSendDetailSA main
						INNER JOIN dcSendDetailSAHistory mode ON mode.dcSendDetailSAId = main.dcSendDetailSAId
						WHERE mode.dcSendDetailSAId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE dcSendDetailSA SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE dcSendDetailSAId = @detailId
					END
					
					UPDATE dcSendDetailSAHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE dcSendDetailSAId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcSendMasterSAId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @dcSendMasterSAId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcSendMasterSAId
END CATCH


GO
