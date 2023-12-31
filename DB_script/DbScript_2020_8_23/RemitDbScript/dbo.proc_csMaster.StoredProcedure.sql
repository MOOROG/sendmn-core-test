USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_csMaster]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_csMaster]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@csMasterId                        VARCHAR(30)		= NULL	
	,@sCountry                          INT				= NULL
	,@sAgent                            INT				= NULL
	,@sState                            INT				= NULL
	,@sZip                              INT				= NULL
	,@sGroup                            INT				= NULL
	,@sCustType                         INT				= NULL
	,@rCountry                          INT				= NULL
	,@rAgent                            INT				= NULL
	,@rState                            INT				= NULL
	,@rZip                              INT				= NULL
	,@rGroup                            INT				= NULL
	,@rCustType                         INT				= NULL
	,@currency							INT				= NULL
	,@ruleScope							VARCHAR(5)		= NULL	
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
		 @ApprovedFunctionId = 2019025
		,@logIdentifier = 'csMasterId'
		,@logParamMain = 'csMaster'
		,@logParamMod = 'csMasterHistory'
		,@module = '20'
		,@tableAlias = 'Compliance Setup'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT

	IF @flag = 'i'
	BEGIN
		IF EXISTS(
			SELECT 'x' FROM csMaster 
				WHERE ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) 
					AND ISNULL(sAgent, 0) = ISNULL(@sAgent, 0)
					AND ISNULL(sState, 0) = ISNULL(@sState, 0)
					AND ISNULL(sZip, 0) = ISNULL(@sZip, 0)
					AND ISNULL(sGroup, 0) = ISNULL(@sGroup, 0)
					AND ISNULL(sCustType, 0) = ISNULL(@sCustType, 0)
					AND ISNULL(rCountry, 0) = ISNULL(@sCountry, 0) 
					AND ISNULL(rAgent, 0) = ISNULL(@sAgent, 0)
					AND ISNULL(rState, 0) = ISNULL(@sState, 0)
					AND ISNULL(rZip, 0) = ISNULL(@sZip, 0)
					AND ISNULL(rGroup, 0) = ISNULL(@sGroup, 0)
					AND ISNULL(rCustType, 0) = ISNULL(@sCustType, 0)
					AND ISNULL(ruleScope,0) = ISNULL(@ruleScope,0)
					AND ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @csMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO csMaster (
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
				,currency
				,isEnable				
				,createdBy
				,createdDate
				,ruleScope
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
				,@currency
				,'Y'			
				,@user
				,GETDATE()
				,@ruleScope
				
			SET @csMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @csMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csMasterHistory WITH(NOLOCK)
				WHERE csMasterId = @csMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM csMasterHistory mode WITH(NOLOCK)
			INNER JOIN csMaster main WITH(NOLOCK) ON mode.csMasterId = main.csMasterId
			WHERE mode.csMasterId= @csMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM csMaster WITH(NOLOCK) WHERE csMasterId = @csMasterId
		END
	END
	
	ELSE IF @flag = 'rd'
	BEGIN
		SELECT  
			 sCountry = ISNULL(scm.countryName, 'All')
			,sAgent = ISNULL(sam.agentName, 'All')
			,sState = ISNULL(ss.stateName, 'All')
			,sZip
			,sGroup = ISNULL(sg.detailTitle, 'All')
			,sCustType = ISNULL(sct.detailTitle, 'All')
			,rCountry = ISNULL(rcm.countryName, 'All')
			,rAgent = ISNULL(ram.agentName, 'All')
			,rState = ISNULL(rs.stateName, 'All')
			,rZip
			,rGroup = ISNULL(rg.detailTitle, 'All')
			,rCustType = ISNULL(rct.detailTitle, 'All')
			,currency = currency
			,ruleScope = ISNULL(ruleScope,'send')
		FROM csMaster cm WITH(NOLOCK)
		LEFT JOIN countryMaster scm WITH(NOLOCK) ON cm.sCountry = scm.countryId
		LEFT JOIN agentMaster sam WITH(NOLOCK) ON cm.sAgent = sam.agentId
		LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON cm.sState = ss.stateId
		LEFT JOIN staticDataValue sg WITH(NOLOCK) ON cm.sGroup = sg.valueId
		LEFT JOIN staticDataValue sct WITH(NOLOCK) ON cm.sCustType = sct.valueId
		LEFT JOIN countryMaster rcm WITH(NOLOCK) ON cm.rCountry = rcm.countryId
		LEFT JOIN agentMaster ram WITH(NOLOCK) ON cm.rAgent = ram.agentId
		LEFT JOIN countryStateMaster rs WITH(NOLOCK) ON cm.rState = rs.stateId
		LEFT JOIN staticDataValue rg WITH(NOLOCK) ON cm.rGroup = rg.valueId
		LEFT JOIN staticDataValue rct WITH(NOLOCK) ON cm.rCustType = rct.valueId
		WHERE csMasterId = @csMasterId
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csMaster WITH(NOLOCK)
			WHERE csMasterId = @csMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM csMasterHistory WITH(NOLOCK)
			WHERE csMasterId  = @csMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csMasterId
			RETURN
		END
		IF EXISTS(
			SELECT 'x' FROM csMaster 
				WHERE ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) 
					AND ISNULL(sAgent, 0) = ISNULL(@sAgent, 0)
					AND ISNULL(sState, 0) = ISNULL(@sState, 0)
					AND ISNULL(sZip, 0) = ISNULL(@sZip, 0)
					AND ISNULL(sGroup, 0) = ISNULL(@sGroup, 0)
					AND ISNULL(sCustType, 0) = ISNULL(@sCustType, 0)
					AND ISNULL(rCountry, 0) = ISNULL(@sCountry, 0) 
					AND ISNULL(rAgent, 0) = ISNULL(@sAgent, 0)
					AND ISNULL(rState, 0) = ISNULL(@sState, 0)
					AND ISNULL(rZip, 0) = ISNULL(@sZip, 0)
					AND ISNULL(rGroup, 0) = ISNULL(@sGroup, 0)
					AND ISNULL(rCustType, 0) = ISNULL(@sCustType, 0)
					AND ISNULL(isDeleted,'N')<>'Y'
					AND ISNULL(ruleScope,0) = ISNULL(@ruleScope,0)
					AND csMasterId <> @csMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @csMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM csMaster WHERE approvedBy IS NULL AND csMasterId  = @csMasterId)			
			BEGIN				
				UPDATE csMaster SET
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
					,currency = @currency				
					,modifiedBy = @user
					,modifiedDate = GETDATE()
					,ruleScope = @ruleScope			
				WHERE csMasterId = @csMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM csMasterHistory WHERE csMasterId = @csMasterId AND approvedBy IS NULL
				INSERT INTO csMasterHistory(
					 csMasterId
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
					,currency					
					,isEnable
					,createdBy
					,createdDate
					,modType
					,ruleScope
				)
				
				SELECT
					 @csMasterId
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
					,@currency					
					,@isEnable
					,@user
					,GETDATE()
					,'U'
					,@ruleScope
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @csMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csMaster WITH(NOLOCK)
			WHERE csMasterId = @csMasterId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @csMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM csMasterHistory  WITH(NOLOCK)
			WHERE csMasterId = @csMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @csMasterId
			RETURN
		END
		
			INSERT INTO csMasterHistory(
				 csMasterId
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
				,currency				
				,isEnable
				,createdBy
				,createdDate
				,modType
				,ruleScope
			)
			SELECT
				 csMasterId
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
				,currency				
				,isEnable					
				,@user
				,GETDATE()
				,'D'
				,ruleScope
			FROM csMaster WHERE csMasterId = @csMasterId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @csMasterId
	END
	
	ELSE IF @flag = 'm'
	BEGIN
		DECLARE 
			 @m VARCHAR(MAX)
			,@d VARCHAR(MAX)
		
		SET @m = '(
				SELECT
					 csMasterId = ISNULL(mode.csMasterId, main.csMasterId)	
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
					,currency = ISNULL(mode.currency, main.currency)	
					,isDisabled=CASE WHEN ISNULL(ISNULL(mode.isEnable, main.isEnable),''n'')=''y'' then ''Enabled'' else ''Disabled'' END	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END								
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.csMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
					,ruleScope	=	ISNULL(mode.ruleScope,main.ruleScope)
				FROM csMaster main WITH(NOLOCK)
				LEFT JOIN csMasterHistory mode ON main.csMasterId = mode.csMasterId AND mode.approvedBy IS NULL
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
					 csDetailId = main.csDetailId
					,csMasterId = main.csMasterId					
					,tranCount = ISNULL(mode.tranCount, main.tranCount)
					,amount = ISNULL(mode.amount, main.amount)
					,nextAction = ISNULL(mode.nextAction, main.nextAction)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END								
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.csDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM csDetail main WITH(NOLOCK)
					LEFT JOIN csDetailHistory mode ON main.csDetailId = mode.csDetailId AND mode.approvedBy IS NULL
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
							 m.csMasterId							
							,m.sCountry
							,sCountryName = ISNULL(sc.countryName, ''All'')
							,m.sAgent
							,sAgentName = ISNULL(sa.agentName, ''All'')
							,m.sState
							,sStateName = ISNULL(ss.stateName, ''All'')
							,m.sZip
							,sGroup = sg.detailTitle
							,m.sCustType
							,m.rCountry
							,rCountryName = ISNULL(rc.countryName, ''All'')
							,m.rAgent
							,rAgentName = ISNULL(ra.agentName, ''All'')
							,m.rState
							,rStateName = ISNULL(rs.stateName, ''All'')
							,m.rZip 
							,rGroup = rg.detailTitle
							,m.rCustType
							,m.currency							
							,m.isDisabled	
							,modifiedBy = MAX(ISNULL(m.modifiedBy, d.modifiedBy))				
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
							,m.ruleScope
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.csMasterId = d.csMasterId
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN agentMaster sa WITH(NOLOCK) ON m.sAgent = sa.agentId
						LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON m.sState = ss.stateId
						LEFT JOIN staticDataValue sct WITH(NOLOCK) ON m.rCustType = sct.valueId	
						LEFT JOIN staticDataValue sg WITH(NOLOCK) ON m.sGroup = sg.valueId			
						
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN agentMaster ra WITH(NOLOCK) ON m.rAgent = ra.agentId
						LEFT JOIN countryStateMaster rs WITH(NOLOCK) ON m.rState = rs.stateId
						LEFT JOIN staticDataValue rct WITH(NOLOCK) ON m.rCustType = rct.valueId
						LEFT JOIN staticDataValue rg WITH(NOLOCK) ON m.rGroup = rg.valueId						
						
						GROUP BY
							 m.csMasterId							
							,sCountry
							,sc.countryName
							,sAgent
							,sa.agentName
							,sState
							,ss.stateName
							,sZip
							,m.sGroup
							,sg.detailTitle
							,sCustType
							,rCountry
							,rc.countryName
							,rAgent
							,ra.agentName
							,rState
							,rs.stateName
							,rZip
							,m.rGroup
							,rg.detailTitle
							,rCustType
							,currency							
							,isDisabled
							--,m.modifiedBy
							--,d.modifiedBy
							,ruleScope
					) x
					'
					
				print @table
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
			
			IF @currency IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND currency = ' + CAST(@currency AS VARCHAR(50))
			/*
			
			sHub = @sHub 
			AND sCountry = @sCountry 
			AND sAgent = @sAgent
			AND sState = @sState
			AND sZip = @sZip
			AND sGroup = @sGroup
			AND sCustType = @sCustType
			AND rHub = @rHub 
			AND rCountry = @sCountry 
			AND rAgent = @sAgent
			AND rState = @sState
			AND rZip = @sZip
			AND rGroup = @sGroup
			AND rCustType = @sCustType
			AND currency = @currency
			*/
			
			
		
			SET @select_field_list = '
					 csMasterId
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
					,currency					
					,isDisabled
					,modifiedBy
					,hasChanged
					,ruleScope					
				'
				
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'csMasterId'
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
			SELECT 'X' FROM csMaster WITH(NOLOCK)
			WHERE csMasterId = @csMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM csMaster WITH(NOLOCK)
			WHERE csMasterId = @csMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @csMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM csMaster WHERE approvedBy IS NULL AND csMasterId = @csMasterId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @csMasterId
					RETURN
				END
			DELETE FROM csMaster WHERE csMasterId =  @csMasterId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @csMasterId
					RETURN
				END
				DELETE FROM csMasterHistory WHERE csMasterId = @csMasterId AND approvedBy IS NULL			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
			INSERT @DetailIdList
			SELECT 
				csDetailId, 'I' 
			FROM csDetail 				
			WHERE 
				csMasterId = @csMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.csDetailId, mode.modType
			FROM csDetailHistory mode WITH(NOLOCK)
			INNER JOIN csDetail main WITH(NOLOCK) ON mode.csDetailId = main.csDetailId 		
			WHERE 
				main.csMasterId = @csMasterId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'csDetailId'
				,@logParamMain = 'csDetail'
				,@logParamMod = 'csDetailHistory'
				,@module = '20'
				,@tableAlias = 'Compliance Rule Setup Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM csDetail WHERE approvedBy IS NULL AND csDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM csDetailHistory WHERE csDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM csDetail WHERE csDetailId =  @detailId		
					DELETE FROM csCriteriaHistory WHERE csDetailId = @detailId AND approvedBy IS NULL			
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM csDetailHistory WHERE csDetailId = @detailId AND approvedBy IS NULL
					DELETE FROM csCriteriaHistory WHERE csDetailId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @csMasterId
	END

	ELSE IF @flag IN ('approve','approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM csMaster WITH(NOLOCK)
			WHERE csMasterId = @csMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM csMaster WITH(NOLOCK)
			WHERE csMasterId = @csMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @csMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM csMaster WHERE approvedBy IS NULL AND csMasterId = @csMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM csMasterHistory WHERE csMasterId = @csMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE csMaster SET
					 isActive = 'Y'
					,isEnable = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE csMasterId = @csMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csMasterId, @oldValue OUTPUT
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
					,main.currency = mode.currency					
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,main.ruleScope = mode.ruleScope
				FROM csMaster main
				INNER JOIN csMasterHistory mode ON mode.csMasterId = main.csMasterId
				WHERE mode.csMasterId = @csMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'csMaster', 'csMasterId', @csMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csMasterId, @oldValue OUTPUT
				UPDATE csMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE csMasterId = @csMasterId
			END
			
			UPDATE csMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE csMasterId = @csMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					csDetailId, 'I' 
				FROM csDetail 				
				WHERE 
					csMasterId = @csMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.csDetailId, ddh.modType
				FROM csDetailHistory ddh WITH(NOLOCK)
				INNER JOIN csDetail dd WITH(NOLOCK) ON ddh.csDetailId = dd.csDetailId 		
				WHERE 
					dd.csMasterId = @csMasterId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					@logIdentifier = 'csDetailId'
					,@logParamMain = 'csDetail'
					,@logParamMod = 'csDetailHistory'
					,@module = '20'
					,@tableAlias = 'Compliance Rule Setup Detail'
				
				DECLARE @newCriteriaValue VARCHAR(MAX) 	
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM csDetail WHERE approvedBy IS NULL AND csDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM csDetailHistory WHERE csDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE csDetail SET
							 isActive = 'Y'
							,isEnable = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE csDetailId = @detailId
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
						
						SELECT 
							@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
						FROM csCriteriaHistory 
						WHERE csDetailId = @detailId AND approvedBy IS NULL
						
						EXEC [dbo].proc_GetColumnToRow  'csCriteria', 'csDetailId', @detailId, @oldValue OUTPUT
				
						DELETE FROM csCriteria WHERE csDetailId = @detailId
						INSERT csCriteria(criteriaId, csDetailId, createdBy, createdDate)
						SELECT criteriaId, @detailId, @user, GETDATE() FROM csCriteriaHistory WHERE csDetailId = @detailId AND approvedBy IS NULL
						
						DECLARE @tranCount INT, @amount MONEY
						SELECT @tranCount = ISNULL(tranCount, 0), @amount = ISNULL(amount, 0) FROM csDetail cd WITH(NOLOCK)
							LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
							WHERE cd.csDetailId = @detailId
						IF ISNULL(@amount, 0) <> 0 
						BEGIN
							INSERT INTO csDetailRec(
								 csMasterId
								,csDetailId
								,condition
								,collMode
								,paymentMode
								,checkType
								,parameter
								,period
								,criteria
								,nextAction
								,isEnable
								,createdBy
								,createdDate
							)
							SELECT
								 csMasterId
								,cd.csDetailId  
								,condition
								,collMode
								,paymentMode
								,'Sum'
								,amount
								,period
								,cch.criteriaId
								,cd.nextAction
								,'Y'
								,@user
								,GETDATE()	
							FROM csDetail cd WITH(NOLOCK)
							LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
							WHERE cd.csDetailId = @detailId
						END
						IF ISNULL(@tranCount, 0) <> 0 
						BEGIN
							INSERT INTO csDetailRec(
								 csMasterId
								,csDetailId
								,condition
								,collMode
								,paymentMode
								,checkType
								,parameter
								,period
								,criteria
								,nextAction
								,isEnable
								,createdBy
								,createdDate
							)
							SELECT
								 csMasterId
								,cd.csDetailId  
								,condition
								,collMode
								,paymentMode
								,'Count'
								,tranCount
								,period
								,cch.criteriaId
								,cd.nextAction
								,'Y'
								,@user
								,GETDATE()	
							FROM csDetail cd WITH(NOLOCK)
							LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
							WHERE cd.csDetailId = @detailId
						END
				
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance Rule Criteria', @detailId, @user, @oldValue, @newCriteriaValue	
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
							,main.nextAction = mode.nextAction
							,main.modifiedDate = GETDATE()
							,main.modifiedBy = @user
						FROM csDetail main
						INNER JOIN csDetailHistory mode ON mode.csDetailId = main.csDetailId
						WHERE mode.csDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
						
						SELECT 
							@newCriteriaValue = ISNULL(@newValue + ',', '') + CAST(criteriaId AS VARCHAR(50))
						FROM csCriteriaHistory 
						WHERE csDetailId = @detailId AND approvedBy IS NULL
						
						EXEC [dbo].proc_GetColumnToRow  'csCriteria', 'csDetailId', @detailId, @oldValue OUTPUT
						
						DELETE FROM csCriteria WHERE csDetailId = @detailId
						INSERT csCriteria(criteriaId, csDetailId, createdBy, createdDate)
						SELECT criteriaId, @detailId, @user, GETDATE() FROM csCriteriaHistory WHERE csDetailId = @detailId AND approvedBy IS NULL
						
						SELECT @tranCount = ISNULL(tranCount, 0), @amount = ISNULL(amount, 0) FROM csDetail cd WITH(NOLOCK)
							LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
							WHERE cd.csDetailId = @detailId
							
						UPDATE csDetailRec SET
							 isEnable = 'N'
						WHERE csDetailId = @detailId
						
						IF ISNULL(@amount, 0) <> 0 
						BEGIN
							INSERT INTO csDetailRec(
								 csMasterId
								,csDetailId
								,condition
								,collMode
								,paymentMode
								,checkType
								,parameter
								,period
								,criteria
								,isEnable
								,createdBy
								,createdDate
							)
							SELECT
								 csMasterId
								,cd.csDetailId  
								,condition
								,collMode
								,paymentMode
								,'Sum'
								,amount
								,period
								,cch.criteriaId
								,'Y'
								,@user
								,GETDATE()	
							FROM csDetail cd WITH(NOLOCK)
							LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
							WHERE cd.csDetailId = @detailId
						END
						IF ISNULL(@tranCount, 0) <> 0 
						BEGIN
							INSERT INTO csDetailRec(
								 csMasterId
								,csDetailId
								,condition
								,collMode
								,paymentMode
								,checkType
								,parameter
								,period
								,criteria
								,isEnable
								,createdBy
								,createdDate
							)
							SELECT
								 csMasterId
								,cd.csDetailId  
								,condition
								,collMode
								,paymentMode
								,'Count'
								,tranCount
								,period
								,cch.criteriaId
								,'Y'
								,@user
								,GETDATE()	
							FROM csDetail cd WITH(NOLOCK)
							LEFT JOIN csCriteriaHistory cch WITH(NOLOCK) ON cd.csDetailId = cch.csDetailId AND cch.approvedBy IS NULL
							WHERE cd.csDetailId = @detailId
						END
						
						INSERT INTO #msg(errorCode, msg, id)
						EXEC proc_applicationLogs 'i', NULL, 'update', 'Compliance Rule Criteria', @detailId, @user, @oldValue, @newCriteriaValue
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE csDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE csDetailId = @detailId
						
						DELETE FROM csCriteria WHERE csDetailId = @detailId
					END
					
					UPDATE csDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE csDetailId = @detailId AND approvedBy IS NULL
					
					UPDATE csCriteriaHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE csDetailId = @detailId AND approvedBy IS NULL 
			
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @csMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @csMasterId
	END
	
	ELSE IF @flag = 'disable'
	BEGIN
			--n--enable
			--y --disable
		IF (SELECT isnull(isEnable,'n') FROM csMaster WHERE csMasterId = @csMasterId)='n'
		BEGIN
			UPDATE csMaster SET isEnable='y' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @csMasterId
			return;
		END
		ELSE
		BEGIN		
			UPDATE csMaster SET isEnable='n' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @csMasterId
			RETURN;
		END
		IF (SELECT isnull(isEnable,'n') FROM csMasterHistory WHERE csMasterId = @csMasterId)='n'
		BEGIN
			UPDATE csMasterHistory SET isEnable='y' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @csMasterId
			RETURN;
		END
		ELSE
		BEGIN		
			UPDATE csMasterHistory SET isEnable='n' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @csMasterId
			RETURN;
		END
	END

	ELSE IF @flag = 'ruleScope'
	BEGIN
		--SELECT NULL [0], 'Select' [1] UNION ALL
		
		SELECT 
		 [0]		= 'Send'
		,[1]		= 'Send'
		UNION ALL
		SELECT 
		 [0]		= 'Pay'
		,[1]		= 'Pay'
		
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @csMasterId
END CATCH



GO
