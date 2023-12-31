USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cisMaster]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	proc_cisMaster @flag = 'm', @user = 'admin'
*/

CREATE proc [dbo].[proc_cisMaster]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@cisMasterId                        VARCHAR(30)    = NULL	
	,@sCountry                           INT            = NULL
	,@sAgent                             INT            = NULL
	,@sState                             INT            = NULL
	,@sZip                               INT            = NULL
	,@sGroup                             INT            = NULL
	,@sCustType                          INT            = NULL
	,@rCountry                           INT            = NULL
	,@rAgent                             INT            = NULL
	,@rState                             INT            = NULL
	,@rZip                               INT            = NULL
	,@rGroup                             INT            = NULL
	,@rCustType                          INT            = NULL	
	,@isEnable                           CHAR(1)        = NULL
	,@sortBy                             VARCHAR(50)    = NULL
	,@sortOrder                          VARCHAR(5)     = NULL
	,@pageSize                           INT            = NULL
	,@pageNumber                         INT            = NULL

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
		 @ApprovedFunctionId = 20601130
		,@logIdentifier = 'cisMasterId'
		,@logParamMain = 'cisMaster'
		,@logParamMod = 'cisMasterHistory'
		,@module = '20'
		,@tableAlias = 'Compliance ID Setup'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT

	IF @flag = 'i'
	BEGIN
		IF EXISTS(
			SELECT 'x' FROM cisMaster 
				WHERE sCountry = @sCountry 
					AND sAgent = @sAgent
					AND sState = @sState
					AND sZip = @sZip
					AND sGroup = @sGroup
					AND sCustType = @sCustType
					AND rCountry = @sCountry 
					AND rAgent = @sAgent
					AND rState = @sState
					AND rZip = @sZip
					AND rGroup = @sGroup
					AND rCustType = @sCustType
					AND ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @cisMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO cisMaster (
				 sCountry
				,sAgent
				,sState
				,sZip
				,sGroup
				,sCustType
				,rCountry
				,rAgent
				,rState
				,rZip
				,rGroup
				,rCustType				
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @sCountry
				,@sAgent
				,@sState
				,@sZip
				,@sGroup
				,@sCustType
				,@rCountry
				,@rAgent
				,@rState
				,@rZip
				,@rGroup
				,@rCustType				
				,'Y'
				,@user
				,GETDATE()
				
				
			SET @cisMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @cisMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cisMasterHistory WITH(NOLOCK)
				WHERE cisMasterId = @cisMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM cisMasterHistory mode WITH(NOLOCK)
			INNER JOIN cisMaster main WITH(NOLOCK) ON mode.cisMasterId = main.cisMasterId
			WHERE mode.cisMasterId= @cisMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM cisMaster WITH(NOLOCK) WHERE cisMasterId = @cisMasterId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cisMaster WITH(NOLOCK)
			WHERE cisMasterId = @cisMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @cisMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM cisMasterHistory WITH(NOLOCK)
			WHERE cisMasterId  = @cisMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @cisMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM cisMaster WHERE approvedBy IS NULL AND cisMasterId  = @cisMasterId)			
			BEGIN				
				UPDATE cisMaster SET
					 sCountry = @sCountry
					,sAgent = @sAgent
					,sState = @sState
					,sZip = @sZip
					,sGroup = @sGroup
					,sCustType = @sCustType
					,rCountry = @rCountry
					,rAgent = @rAgent
					,rState = @rState
					,rZip = @rZip
					,rGroup = @rGroup
					,rCustType = @rCustType					
					,isEnable = @isEnable
					,modifiedBy = @user
					,modifiedDate = GETDATE()			
				WHERE cisMasterId = @cisMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM cisMasterHistory WHERE cisMasterId = @cisMasterId AND approvedBy IS NULL
				INSERT INTO cisMasterHistory(
					 cisMasterId
					,sCountry
					,sAgent
					,sState
					,sZip
					,sGroup
					,sCustType
					,rCountry
					,rAgent
					,rState
					,rZip
					,rGroup
					,rCustType					
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				
				SELECT
					 @cisMasterId
					,@sCountry
					,@sAgent
					,@sState
					,@sZip
					,@sGroup
					,@sCustType
					,@rCountry
					,@rAgent
					,@rState
					,@rZip
					,@rGroup
					,@rCustType					
					,@isEnable
					,@user
					,GETDATE()
					,'U'
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @cisMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cisMaster WITH(NOLOCK)
			WHERE cisMasterId = @cisMasterId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @cisMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM cisMasterHistory  WITH(NOLOCK)
			WHERE cisMasterId = @cisMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @cisMasterId
			RETURN
		END
		
			INSERT INTO cisMasterHistory(
				 cisMasterId
				,sCountry
				,sAgent
				,sState
				,sZip
				,sGroup
				,sCustType
				,rCountry
				,rAgent
				,rState
				,rZip
				,rGroup
				,rCustType				
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 cisMasterId
				,sCountry
				,sAgent
				,sState
				,sZip
				,sGroup
				,sCustType
				,rCountry
				,rAgent
				,rState
				,rZip
				,rGroup
				,rCustType				
				,isEnable					
				,@user
				,GETDATE()
				,'D'
			FROM cisMaster WHERE cisMasterId = @cisMasterId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @cisMasterId
	END
	
	ELSE IF @flag = 'm'
	BEGIN
		DECLARE 
			 @m VARCHAR(MAX)
			,@d VARCHAR(MAX)
		
		SET @m = '(
				SELECT
					 cisMasterId = ISNULL(mode.cisMasterId, main.cisMasterId)	
					,sCountry = ISNULL(mode.sCountry, main.sCountry)					
					,sAgent = ISNULL(mode.sAgent, main.sAgent)					
					,sState = ISNULL(mode.sState, main.sState)
					,sZip = ISNULL(mode.sZip, main.sZip)
					,sGroup = ISNULL(mode.sGroup, main.sGroup)
					,sCustType = ISNULL(mode.sCustType, main.sCustType)
									
					,rCountry = ISNULL(mode.rCountry, main.rCountry)					
					,rAgent = ISNULL(mode.rAgent, main.rAgent)					
					,rState = ISNULL(mode.rState, main.rState)
					,rZip = ISNULL(mode.rZip, main.rZip)
					,rGroup = ISNULL(mode.rGroup, main.rGroup)
					,rCustType = ISNULL(mode.rCustType, main.rCustType)										
					
					,isDisabled=CASE WHEN ISNULL(ISNULL(mode.isEnable, main.isEnable),''N'')=''Y'' then ''Enabled'' else ''Disabled'' END
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END								
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.cisMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM cisMaster main WITH(NOLOCK)
				LEFT JOIN cisMasterHistory mode ON main.cisMasterId = mode.cisMasterId AND mode.approvedBy IS NULL
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
					 cisDetailId = main.cisDetailId
					,cisMasterId = main.cisMasterId					
					,collMode = ISNULL(mode.collMode, main.collMode)
					,paymentMode = ISNULL(mode.paymentMode, main.paymentMode)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END							
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.cisDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM cisDetail main WITH(NOLOCK)
					LEFT JOIN cisDetailHistory mode ON main.cisDetailId = mode.cisDetailId AND mode.approvedBy IS NULL
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
							 m.cisMasterId						
							,m.sCountry
							,sCountryName = ISNULL(sc.countryName, ''All'')
							,m.sAgent
							,sAgentName = ISNULL(sa.agentName, ''All'')
							,m.sState
							,sStateName = ISNULL(ss.stateName, ''All'')
							,m.sZip
							,m.sGroup
							,m.sCustType	
							,m.rCountry
							,rCountryName = ISNULL(rc.countryName, ''All'')
							,m.rAgent
							,rAgentName = ISNULL(ra.agentName, ''All'')
							,m.rState
							,rStateName = ISNULL(rs.stateName, ''All'')
							,m.rZip 
							,m.rGroup
							,m.rCustType
							
							,m.isDisabled
							,modifiedBy = MAX(ISNULL(m.modifiedBy, d.modifiedBy))					
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.cisMasterId = d.cisMasterId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN agentMaster sa WITH(NOLOCK) ON m.sAgent = sa.agentId
						LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON m.sState = ss.stateId
						LEFT JOIN staticDataValue sct WITH(NOLOCK) ON m.rCustType = sct.valueId				
						
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN agentMaster ra WITH(NOLOCK) ON m.rAgent = ra.agentId
						LEFT JOIN countryStateMaster rs WITH(NOLOCK) ON m.rState = rs.stateId
						LEFT JOIN staticDataValue rct WITH(NOLOCK) ON m.rCustType = rct.valueId						
						
						GROUP BY
							 m.cisMasterId
							,sCountry
							,sc.countryName
							,sAgent
							,sa.agentName
							,sState
							,ss.stateName
							,sZip
							,sGroup
							,sCustType
							,rCountry
							,rc.countryName
							,rAgent
							,ra.agentName
							,rState
							,rs.stateName
							,rZip
							,rGroup
							,rCustType
							
							,isDisabled
							--,m.modifiedBy
							--,d.modifiedBy
					) x
					'
					
				--print @table
				--
			SET @sql_filter = ' '
			
			IF @sCountry IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
			
			IF @sAgent IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sAgent = ' + CAST(@sAgent AS VARCHAR(50))
		
			IF @sState IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sState = ' + CAST(@sState AS VARCHAR(50))
		
			IF @sZip IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sZip = ' + CAST(@sZip AS VARCHAR(50))
				
			IF @sGroup IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sGroup = ' + CAST(@sGroup AS VARCHAR(50))
				
			IF @sCustType IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sCustType = ' + CAST(@sCustType AS VARCHAR(50))				

			IF @rCountry IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @rAgent IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rAgent = ' + CAST(@rAgent AS VARCHAR(50))
		
			IF @rState IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rState = ' + CAST(@rState AS VARCHAR(50))
		
			IF @rZip IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rZip = ' + CAST(@rZip AS VARCHAR(50))
				
			IF @rGroup IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rGroup = ' + CAST(@rGroup AS VARCHAR(50))
				
			IF @rCustType IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCustType = ' + CAST(@rCustType AS VARCHAR(50))
					
			SET @select_field_list = '
					 cisMasterId
					,sCountry
					,sCountryName
					,sAgent
					,sAgentName
					,sState
					,sStateName
					,sZip
					,sGroup
					,sCustType
					,rCountry
					,rCountryName
					,rAgent
					,rAgentName
					,rState
					,rStateName
					,rZip 
					,rGroup
					,rCustType					
					,isDisabled
					,modifiedBy
					,hasChanged					
				'
				
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'cisMasterId'
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
			SELECT 'X' FROM cisMaster WITH(NOLOCK)
			WHERE cisMasterId = @cisMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM cisMaster WITH(NOLOCK)
			WHERE cisMasterId = @cisMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @cisMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM cisMaster WHERE approvedBy IS NULL AND cisMasterId = @cisMasterId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cisMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @cisMasterId
					RETURN
				END
			DELETE FROM cisMaster WHERE cisMasterId =  @cisMasterId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cisMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @cisMasterId
					RETURN
				END
				DELETE FROM cisMasterHistory WHERE cisMasterId = @cisMasterId AND approvedBy IS NULL			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
			INSERT @DetailIdList
			SELECT 
				cisDetailId, 'I' 
			FROM cisDetail 				
			WHERE 
				cisMasterId = @cisMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.cisDetailId, mode.modType
			FROM cisDetailHistory mode WITH(NOLOCK)
			INNER JOIN cisDetail main WITH(NOLOCK) ON mode.cisDetailId = main.cisDetailId 		
			WHERE 
				main.cisMasterId = @cisMasterId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'cisDetailId'
				,@logParamMain = 'cisDetail'
				,@logParamMod = 'cisDetailHistory'
				,@module = '20'
				,@tableAlias = 'Compliance ID Setup Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM cisDetail WHERE approvedBy IS NULL AND cisDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM cisDetailHistory WHERE cisDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM cisDetail WHERE cisDetailId =  @detailId		
					DELETE FROM cisCriteriaHistory WHERE cisDetailId = @detailId AND approvedBy IS NULL			
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM cisDetailHistory WHERE cisDetailId = @detailId AND approvedBy IS NULL
					DELETE FROM cisCriteriaHistory WHERE cisDetailId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @cisMasterId
	END

	ELSE IF @flag IN ('approve','approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM cisMaster WITH(NOLOCK)
			WHERE cisMasterId = @cisMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM cisMaster WITH(NOLOCK)
			WHERE cisMasterId = @cisMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @cisMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM cisMaster WHERE approvedBy IS NULL AND cisMasterId = @cisMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM cisMasterHistory WHERE cisMasterId = @cisMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE cisMaster SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE cisMasterId = @cisMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisMasterId, @oldValue OUTPUT
				UPDATE main SET
					 main.sCountry = mode.sCountry
					,main.sAgent = mode.sAgent
					,main.sState = mode.sState
					,main.sZip = mode.sZip
					,main.sGroup = mode.sGroup
					,main.sCustType = mode.sCustType
					,main.rCountry = mode.rCountry
					,main.rAgent = mode.rAgent
					,main.rState = mode.rState
					,main.rZip = mode.rZip
					,main.rGroup = mode.rGroup
					,main.rCustType = mode.rCustType					
					,main.isEnable = mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM cisMaster main
				INNER JOIN cisMasterHistory mode ON mode.cisMasterId = main.cisMasterId
				WHERE mode.cisMasterId = @cisMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'cisMaster', 'cisMasterId', @cisMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cisMasterId, @oldValue OUTPUT
				UPDATE cisMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE cisMasterId = @cisMasterId
			END
			
			UPDATE cisMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE cisMasterId = @cisMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cisMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN		
				INSERT @DetailIdList
				SELECT 
					cisDetailId, 'I' 
				FROM cisDetail 				
				WHERE 
					cisMasterId = @cisMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					mode.cisDetailId, mode.modType
				FROM cisDetailHistory mode WITH(NOLOCK)
				INNER JOIN cisDetail main WITH(NOLOCK) ON mode.cisDetailId = main.cisDetailId 		
				WHERE 
					main.cisMasterId = @cisMasterId
					AND mode.approvedBy IS NULL					
					
				SELECT
					 @logIdentifier = 'cisDetailId'
					,@logParamMain = 'cisDetail'
					,@logParamMod = 'cisDetailHistory'
					,@module = '20'
					,@tableAlias = 'Compliance ID Setup Detail'
				
				DECLARE @newCriteriaValue VARCHAR(MAX) 	
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM cisDetail WHERE approvedBy IS NULL AND cisDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM cisDetailHistory WHERE cisDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE cisDetail SET
							 isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE cisDetailId = @detailId
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
						
						SELECT 
							@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
						FROM cisCriteriaHistory 
						WHERE cisDetailId = @detailId AND approvedBy IS NULL
						
						EXEC [dbo].proc_GetColumnToRow  'cisCriteria', 'cisDetailId', @detailId, @oldValue OUTPUT
						
						DELETE FROM cisCriteria WHERE cisDetailId = @detailId
						INSERT cisCriteria(criteriaId, idTypeId, cisDetailId, createdBy, createdDate)
						SELECT criteriaId, idTypeId, @detailId, @user, GETDATE() FROM cisCriteriaHistory WHERE cisDetailId = @detailId AND approvedBy IS NULL
						
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance ID Criteria', @detailId, @user, @oldValue, @newCriteriaValue	
					END
					ELSE IF @modType = 'U'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE main SET
							 main.condition = mode.condition
							,main.collMode = mode.collMode
							,main.paymentMode = mode.paymentMode
							,main.tranCount = mode.tranCount
							,main.amount = mode.amount
							,main.period = mode.period
							,main.isEnable = mode.isEnable
							,main.modifiedDate = GETDATE()
							,main.modifiedBy = @user
						FROM cisDetail main
						INNER JOIN cisDetailHistory mode ON mode.cisDetailId = main.cisDetailId
						WHERE mode.cisDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
						
						SELECT 
							@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
						FROM cisCriteriaHistory 
						WHERE cisDetailId = @detailId
						
						EXEC [dbo].proc_GetColumnToRow  'cisCriteria', 'cisDetailId', @detailId, @oldValue OUTPUT
						
						DELETE FROM cisCriteria WHERE cisDetailId = @detailId
						INSERT cisCriteria(criteriaId, idTypeId, cisDetailId, createdBy, createdDate)
						SELECT criteriaId, idTypeId, @detailId, @user, GETDATE() FROM cisCriteriaHistory WHERE cisDetailId = @detailId AND approvedBy IS NULL
						
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance ID Criteria', @detailId, @user, @oldValue, @newCriteriaValue
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE cisDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE cisDetailId = @detailId
						
						DELETE FROM cisCriteria WHERE cisDetailId = @detailId
					END
					
					UPDATE cisDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE cisDetailId = @detailId AND approvedBy IS NULL
					
					UPDATE cisCriteriaHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE cisDetailId = @detailId AND approvedBy IS NULL 
			
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @cisMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @cisMasterId
	END
	
	ELSE IF @flag = 'disable'
	BEGIN
			--n--enable
			--y --disable
		IF (SELECT ISNULL(isEnable,'N') FROM cisMaster WHERE cisMasterId = @cisMasterId) = 'N'
		BEGIN
			UPDATE cisMaster SET isEnable='Y' WHERE cisMasterId = @cisMasterId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @cisMasterId
			RETURN
		END
		ELSE
		BEGIN		
			UPDATE cisMaster SET isEnable='N' WHERE cisMasterId = @cisMasterId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @cisMasterId
			RETURN
		END
		IF (SELECT isnull(isEnable,'N') FROM cisMasterHistory WHERE cisMasterId = @cisMasterId)='N'
		BEGIN
			UPDATE cisMasterHistory SET isEnable='Y' WHERE cisMasterId = @cisMasterId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @cisMasterId
			RETURN
		END
		ELSE
		BEGIN		
			UPDATE cisMasterHistory SET isEnable='N' WHERE cisMasterId = @cisMasterId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @cisMasterId
			RETURN
		END
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @cisMasterId
END CATCH


GO
