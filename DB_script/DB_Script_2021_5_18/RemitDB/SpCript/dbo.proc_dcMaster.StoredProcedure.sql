USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcMaster]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcMaster]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dcMasterId						VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sGroup							INT				= NULL
	,@rGroup							INT				= NULL
	,@tranType                          INT				= NULL
	,@commissionBase					INT				= NULL
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
		 @ApprovedFunctionId = 20231230
		,@logIdentifier = 'dcMasterId'
		,@logParamMain = 'dcMaster'
		,@logParamMod = 'dcMasterHistory'
		,@module = '20'
		,@tableAlias = 'Default Domestic Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
		
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM dcMaster WHERE 
					ISNULL(sGroup, 0) = ISNULL(@sGroup, 0) AND
					ISNULL(rGroup, 0) = ISNULL(@rGroup, 0) AND 
					ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND 
					ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @dcMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcMaster (
				 code
				,[description]
				,sGroup
				,rGroup
				,tranType
				,commissionBase
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @code
				,@description
				,@sGroup
				,@rGroup
				,@tranType
				,@commissionBase
				,@isEnable
				,@user
				,GETDATE()
				
			SET @dcMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcMasterHistory WITH(NOLOCK)
				WHERE dcMasterId = @dcMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcMasterHistory mode WITH(NOLOCK)
			INNER JOIN dcMaster main WITH(NOLOCK) ON mode.dcMasterId = main.dcMasterId
			WHERE mode.dcMasterId= @dcMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcMaster WITH(NOLOCK) WHERE dcMasterId = @dcMasterId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcMasterHistory WITH(NOLOCK)
			WHERE dcMasterId  = @dcMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcMaster WHERE approvedBy IS NULL AND dcMasterId  = @dcMasterId)			
			BEGIN				
				UPDATE dcMaster SET
					 code							= @code
					,[description]					= @description
					,sGroup							= @sGroup
					,rGroup							= @rGroup
					,tranType						= @tranType
					,commissionBase					= @commissionBase
					,isEnable						= @isEnable				
				WHERE dcMasterId = @dcMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM dcMasterHistory WHERE dcMasterId = @dcMasterId AND approvedBy IS NULL
				INSERT INTO dcMasterHistory(
					 dcMasterId
					,code
					,[description]
					,sGroup
					,rGroup
					,tranType
					,commissionBase
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @dcMasterId
					,@code
					,@description
					,@sGroup
					,@rGroup
					,@tranType
					,@commissionBase
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcMasterHistory  WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcMasterId
			RETURN
		END
		
			INSERT INTO dcMasterHistory(
				 dcMasterId
				,code
				,[description]
				,sGroup
				,rGroup
				,tranType
				,commissionBase
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 dcMasterId
				,code
				,[description]
				,sGroup
				,rGroup
				,tranType
				,commissionBase
				,isEnable
				,@user
				,GETDATE()
				,'D'
			FROM dcMaster WHERE dcMasterId = @dcMasterId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcMasterId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcMasterId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcMasterId = ISNULL(mode.dcMasterId, main.dcMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)				
					,sGroup = ISNULL(mode.sGroup, main.sGroup)					
					,rGroup = ISNULL(mode.rGroup, main.rGroup)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedDate = ISNULL(mode.createdDate, main.modifiedDate)
					,modifiedBy = ISNULL(mode.createdBy, main.modifiedBy)
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.dcMasterId IS NOT NULL THEN ''Y'' ELSE ''N'' END
				FROM dcMaster main WITH(NOLOCK)
					LEFT JOIN dcMasterHistory mode ON main.dcMasterId = mode.dcMasterId AND mode.approvedBy IS NULL
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
		
		IF @sGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sGroup = ' + CAST(@sGroup AS VARCHAR(50))
		
		IF @rGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rGroup = ' + CAST(@rGroup AS VARCHAR(50))
		
		IF @tranType IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
		
		IF @commissionBase IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND commissionBase = ' + CAST(@commissionBase AS VARCHAR)

		SET @select_field_list = '
			 dcMasterId
			,code
			,description
			,sGroup
			,rGroup
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
					 dcMasterId = ISNULL(mode.dcMasterId, main.dcMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sGroup = ISNULL(mode.sGroup, main.sGroup)
					,rGroup = ISNULL(mode.rGroup, main.rGroup)					
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END										
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM dcMaster main WITH(NOLOCK)
					LEFT JOIN dcMasterHistory mode ON main.dcMasterId = mode.dcMasterId AND mode.approvedBy IS NULL
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
					 dcDetailId = main.dcDetailId
					,dcMasterId = main.dcMasterId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,serviceChargePcnt = ISNULL(mode.serviceChargePcnt, main.serviceChargePcnt)
					,serviceChargeMinAmt = ISNULL(mode.serviceChargeMinAmt, main.serviceChargeMinAmt)
					,serviceChargeMaxAmt = ISNULL(mode.serviceChargeMaxAmt, main.serviceChargeMaxAmt)
					,sAgentCommPcnt = ISNULL(mode.sAgentCommPcnt, main.sAgentCommPcnt)
					,sAgentCommMinAmt = ISNULL(mode.sAgentCommMinAmt, main.sAgentCommMinAmt)
					,sAgentCommMaxAmt = ISNULL(mode.sAgentCommMaxAmt, main.sAgentCommMaxAmt)
					,ssAgentCommPcnt = ISNULL(mode.ssAgentCommPcnt, main.ssAgentCommPcnt)
					,ssAgentCommMinAmt = ISNULL(mode.ssAgentCommMinAmt, main.ssAgentCommMinAmt)
					,ssAgentCommMaxAmt = ISNULL(mode.ssAgentCommMaxAmt, main.ssAgentCommMaxAmt)
					,pAgentCommPcnt = ISNULL(mode.pAgentCommPcnt, main.pAgentCommPcnt)
					,pAgentCommMinAmt = ISNULL(mode.pAgentCommMinAmt, main.pAgentCommMinAmt)
					,pAgentCommMaxAmt = ISNULL(mode.pAgentCommMaxAmt, main.pAgentCommMaxAmt)
					,psAgentCommPcnt = ISNULL(mode.psAgentCommPcnt, main.psAgentCommPcnt)
					,psAgentCommMinAmt = ISNULL(mode.psAgentCommMinAmt, main.psAgentCommMinAmt)
					,psAgentCommMaxAmt = ISNULL(mode.psAgentCommMaxAmt, main.psAgentCommMaxAmt)
					,bankCommPcnt = ISNULL(mode.bankCommPcnt, main.bankCommPcnt)
					,bankCommMinAmt = ISNULL(mode.bankCommMinAmt, main.bankCommMinAmt)
					,bankCommMaxAmt = ISNULL(mode.bankCommMaxAmt, main.bankCommMaxAmt)
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcDetail main WITH(NOLOCK)
					LEFT JOIN dcDetailHistory mode ON main.dcDetailId = mode.dcDetailId AND mode.approvedBy IS NULL
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
							 m.dcMasterId
							,m.description
							,m.sGroup
							,sGroupName = ISNULL(sg.detailTitle, ''Any'')
							,m.rGroup
							,rGroupName = ISNULL(rg.detailTitle, ''Any'')
							,m.tranType
							,tranTypeName = ISNULL(trn.typeTitle, ''All'')
							,m.commissionBase
							,commissionBaseName = cb.detailTitle
							,m.isEnable
							,fromAmt = MIN(d.fromAmt)
							,toAmt = MAX(d.toAmt)	
							,modifiedBy = ISNULL(m.modifiedBy, d.modifiedBy)						
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.dcMasterId = d.dcMasterId
						LEFT JOIN staticDataValue sg WITH(NOLOCK) ON m.sGroup = sg.valueId
						LEFT JOIN staticDataValue rg WITH(NOLOCK) ON m.rGroup = rg.valueId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
						LEFT JOIN staticDataValue cb WITH(NOLOCK) ON m.tranType = cb.valueId
						GROUP BY 
							 m.dcMasterId
							,m.description
							,m.sGroup
							,sg.detailTitle
							,m.rGroup
							,rg.detailTitle
							,m.tranType
							,trn.typeTitle
							,m.commissionBase
							,cb.detailTitle
							,m.isEnable
							,m.modifiedBy
							,d.modifiedBy
					) x
					'
					
				--print @table
				--
			SET @sql_filter = ' '
			
			IF @sGroup IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sGroup = ' + CAST(@sGroup AS VARCHAR(50))
			
			IF @hasChanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged + ''''
			
			IF @rGroup IS NOT NULL	
				SET @sql_filter = @sql_filter + ' AND rGroup = ' + CAST(@rGroup AS VARCHAR(50))
			
			IF @tranType IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
			IF @commissionBase IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND commissionBase = ' + CAST(@commissionBase AS VARCHAR)
				
			SET @select_field_list = '
					 dcMasterId
					,description
					,sGroup
					,sGroupName
					,rGroup
					,rGroupName
					,tranType
					,tranTypeName
					,commissionBase
					,commissionBaseName
					,fromAmt
					,toAmt
					,modifiedBy
					,hasChanged
					
				'
				
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'dcMasterId'
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
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcMaster WHERE approvedBy IS NULL AND dcMasterId = @dcMasterId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcMasterId
					RETURN
				END
			DELETE FROM dcMaster WHERE dcMasterId =  @dcMasterId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcMasterId
					RETURN
				END
				DELETE FROM dcMasterHistory WHERE dcMasterId = @dcMasterId AND approvedBy IS NULL
			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				dcDetailId, 'I' 
			FROM dcDetail 				
			WHERE 
				dcMasterId = @dcMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.dcDetailId, mode.modType
			FROM dcDetailHistory mode WITH(NOLOCK)
			INNER JOIN dcDetail main WITH(NOLOCK) ON mode.dcDetailId = main.dcDetailId 		
			WHERE 
				main.dcMasterId = @dcMasterId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'dcDetailId'
				,@logParamMain = 'dcDetail'
				,@logParamMod = 'dcDetailHistory'
				,@module = '20'
				,@tableAlias = 'Default Domestic Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM dcDetail WHERE approvedBy IS NULL AND dcDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM dcDetailHistory WHERE dcDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM dcDetail WHERE dcDetailId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM dcDetailHistory WHERE dcDetailId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcMasterId
	END

	ELSE IF @flag IN ('approve','approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcMaster WHERE approvedBy IS NULL AND dcMasterId = @dcMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcMasterHistory WHERE dcMasterId = @dcMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcMaster SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcMasterId = @dcMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcMasterId, @oldValue OUTPUT
				UPDATE main SET
					 main.code                          = mode.code
					,main.[description]                 = mode.[description]
					,main.sGroup						= mode.sGroup
					,main.rGroup						= mode.rGroup
					,main.tranType                      = mode.tranType
					,main.commissionBase				= mode.commissionBase
					,main.isEnable						= mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM dcMaster main
				INNER JOIN dcMasterHistory mode ON mode.dcMasterId = main.dcMasterId
				WHERE mode.dcMasterId = @dcMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcMaster', 'dcMasterId', @dcMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcMasterId, @oldValue OUTPUT
				UPDATE dcMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcMasterId = @dcMasterId
			END
			
			UPDATE dcMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcMasterId = @dcMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					dcDetailId, 'I' 
				FROM dcDetail 				
				WHERE 
					dcMasterId = @dcMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.dcDetailId, ddh.modType
				FROM dcDetailHistory ddh WITH(NOLOCK)
				INNER JOIN dcDetail dd WITH(NOLOCK) ON ddh.dcDetailId = dd.dcDetailId 		
				WHERE 
					dd.dcMasterId = @dcMasterId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					@logIdentifier = 'dcDetailId'
					,@logParamMain = 'dcDetail'
					,@logParamMod = 'dcDetailHistory'
					,@module = '20'
					,@tableAlias = 'Default Domestic Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM dcDetail WHERE approvedBy IS NULL AND dcDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM dcDetailHistory WHERE dcDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE dcDetail SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE dcDetailId = @detailId
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'U'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE main SET
							 main.fromAmt = mode.fromAmt
							,main.toAmt =  mode.toAmt
							,main.serviceChargePcnt =  mode.serviceChargePcnt
							,main.serviceChargeMinAmt =  mode.serviceChargeMinAmt
							,main.serviceChargeMaxAmt =  mode.serviceChargeMaxAmt
							,main.sAgentCommPcnt = mode.sAgentCommPcnt
							,main.sAgentCommMinAmt = mode.sAgentCommMinAmt
							,main.sAgentCommMaxAmt = mode.sAgentCommMaxAmt
							,main.ssAgentCommPcnt = mode.ssAgentCommPcnt
							,main.ssAgentCommMinAmt = mode.ssAgentCommMinAmt
							,main.ssAgentCommMaxAmt = mode.ssAgentCommMaxAmt
							,main.pAgentCommPcnt = mode.pAgentCommPcnt
							,main.pAgentCommMinAmt = mode.pAgentCommMinAmt
							,main.pAgentCommMaxAmt = mode.pAgentCommMaxAmt
							,main.psAgentCommPcnt = mode.psAgentCommPcnt
							,main.psAgentCommMinAmt = mode.psAgentCommMinAmt
							,main.psAgentCommMaxAmt = mode.psAgentCommMaxAmt
							,main.bankCommPcnt		= mode.bankCommPcnt
							,main.bankCommMinAmt	= mode.bankCommMinAmt
							,main.bankCommMaxAmt	= mode.bankCommMaxAmt
							,main.modifiedDate = GETDATE()
							,main.modifiedBy = @user
						FROM dcDetail main
						INNER JOIN dcDetailHistory mode ON mode.dcDetailId = main.dcDetailId
						WHERE mode.dcDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE dcDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE dcDetailId = @detailId
					END
					
					UPDATE dcDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE dcDetailId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @dcMasterId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcMasterId
END CATCH


GO
