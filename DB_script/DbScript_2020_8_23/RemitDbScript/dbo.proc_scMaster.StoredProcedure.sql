USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scMaster]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_scMaster]
	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@scMasterId						VARCHAR(30)		= NULL
	,@oldScMasterId						VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sAgent							INT				= NULL
	,@sBranch							INT				= NULL
	,@sState							INT				= NULL
	,@sGroup							INT				= NULL
	,@rAgent							INT				= NULL
	,@rBranch							INT				= NULL
	,@rState							INT				= NULL
	,@rGroup							INT				= NULL
	,@tranType                          INT				= NULL
	,@commissionBase					INT				= NULL
	,@effectiveFrom						DATETIME		= NULL
	,@effectiveTo						DATETIME		= NULL
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
		 @ApprovedFunctionId = 20131330
		,@logIdentifier = 'scMasterId'
		,@logParamMain = 'scMaster'
		,@logParamMod = 'scMasterHistory'
		,@module = '20'
		,@tableAlias = 'Domestic Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
	
	IF @flag = 'cl'					--Commission Code List
	BEGIN
		SELECT 
			 scMasterId
			,code 
		FROM scMaster WITH(NOLOCK) 
		WHERE ISNULL(isDeleted,'N') = 'N'
		AND ISNULL(isActive, 'N') = 'Y'
		ORDER BY code ASC
	END
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM scMaster WHERE code = @code AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Commission with this code already exists', NULL
			RETURN
		END
		/*
		IF EXISTS(SELECT 'x' FROM scMaster WHERE 
					ISNULL(sAgent, 0) = ISNULL(@sAgent, 0) AND
					ISNULL(sBranch, 0) = ISNULL(@sBranch, 0) AND
					ISNULL(sState, 0) = ISNULL(@sState, 0) AND
					ISNULL(sGroup, 0) = ISNULL(@sGroup, 0) AND
					ISNULL(rAgent, 0) = ISNULL(@rAgent, 0) AND
					ISNULL(rBranch, 0) = ISNULL(@rBranch, 0) AND
					ISNULL(rState, 0) = ISNULL(@rState, 0) AND
					ISNULL(rGroup, 0) = ISNULL(@rGroup, 0) AND
					ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND 
					ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @scMasterId
			RETURN
		END*/
		BEGIN TRANSACTION
			INSERT INTO scMaster (
				 code
				,[description]
				,sAgent
				,sBranch
				,sState
				,sGroup
				,rAgent
				,rBranch
				,rState
				,rGroup
				,tranType
				,commissionBase
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @code
				,@description
				,@sAgent
				,@sBranch
				,@sState
				,@sGroup
				,@rAgent
				,@rBranch
				,@rState
				,@rGroup
				,@tranType
				,@commissionBase
				,@effectiveFrom
				,@effectiveTo
				,@isEnable
				,@user
				,GETDATE()
				
			SET @scMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scMasterHistory WITH(NOLOCK)
				WHERE scMasterId = @scMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scMasterHistory mode WITH(NOLOCK)
			INNER JOIN scMaster main WITH(NOLOCK) ON mode.scMasterId = main.scMasterId
			WHERE mode.scMasterId= @scMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scMaster WITH(NOLOCK) WHERE scMasterId = @scMasterId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scMasterHistory WITH(NOLOCK)
			WHERE scMasterId  = @scMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scMasterId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM scMaster WHERE code = @code AND ISNULL(isDeleted, 'N') = 'N' AND scMasterId <> @scMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'Commission with this code already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scMaster WHERE approvedBy IS NULL AND scMasterId  = @scMasterId)			
			BEGIN				
				UPDATE scMaster SET
					 code							= @code
					,[description]					= @description
					,sAgent							= @sAgent
					,sBranch						= @sBranch
					,sState							= @sState
					,sGroup							= @sGroup
					,rAgent							= @rAgent
					,rBranch						= @rBranch
					,rState							= @rState
					,rGroup							= @rGroup
					,tranType						= @tranType
					,commissionBase					= @commissionBase
					,effectiveFrom					= @effectiveFrom
					,effectiveTo					= @effectiveTo
					,isEnable						= @isEnable				
				WHERE scMasterId = @scMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM scMasterHistory WHERE scMasterId = @scMasterId AND approvedBy IS NULL
				INSERT INTO scMasterHistory(
					 scMasterId
					,code
					,[description]
					,sAgent
					,sBranch
					,sState
					,sGroup
					,rAgent
					,rBranch
					,rState
					,rGroup
					,tranType
					,commissionBase
					,effectiveFrom
					,effectiveTo
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @scMasterId
					,@code
					,@description
					,@sAgent
					,@sBranch
					,@sState
					,@sGroup
					,@rAgent
					,@rBranch
					,@rState
					,@rGroup
					,@tranType
					,@commissionBase
					,@effectiveFrom
					,@effectiveTo
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @scMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scMasterHistory  WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @scMasterId
			RETURN
		END
		
			INSERT INTO scMasterHistory(
				 scMasterId
				,code
				,[description]
				,sAgent
				,sBranch
				,sState
				,sGroup
				,rAgent
				,rBranch
				,rState
				,rGroup
				,tranType
				,commissionBase
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 scMasterId
				,code
				,[description]
				,sAgent
				,sBranch
				,sState
				,sGroup
				,rAgent
				,rBranch
				,rState
				,rGroup
				,tranType
				,commissionBase
				,effectiveFrom
				,effectiveTo
				,isEnable
				,@user
				,GETDATE()
				,'D'
			FROM scMaster WHERE scMasterId = @scMasterId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scMasterId
	END

	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'scMasterId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scMasterId = ISNULL(mode.scMasterId, main.scMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sAgent = ISNULL(mode.sAgent, main.sAgent)
					,sBranch = ISNULL(mode.sBranch, main.sBranch)
					,sState = ISNULL(mode.sState, main.sState)				
					,sGroup = ISNULL(mode.sGroup, main.sGroup)
					,rAgent = ISNULL(mode.rAgent, main.rAgent)
					,rBranch = ISNULL(mode.rBranch, main.rBranch)
					,rState = ISNULL(mode.rState, main.rState)					
					,rGroup = ISNULL(mode.rGroup, main.rGroup)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
					,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedDate = ISNULL(mode.createdDate, main.modifiedDate)
					,modifiedBy = ISNULL(mode.createdBy, main.modifiedBy)
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.scMasterId IS NOT NULL THEN ''Y'' ELSE ''N'' END
				FROM scMaster main WITH(NOLOCK)
					LEFT JOIN scMasterHistory mode ON main.scMasterId = mode.scMasterId AND mode.approvedBy IS NULL
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
		
		IF @sAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sAgent = ' + CAST(@sAgent AS VARCHAR)
		
		IF @sBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sAgent = ' + CAST(@sBranch AS VARCHAR)
		
		IF @sState IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sState = ' + CAST(@sState AS VARCHAR)
			
		IF @sGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sGroup = ' + CAST(@sGroup AS VARCHAR)
		
		IF @rAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rAgent = ' + CAST(@rAgent AS VARCHAR)
		
		IF @rBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rAgent = ' + CAST(@rBranch AS VARCHAR)
		
		IF @rState IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rState = ' + CAST(@rState AS VARCHAR)
			
		IF @rGroup IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rGroup = ' + CAST(@rGroup AS VARCHAR)
		
		IF @tranType IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
		
		IF @commissionBase IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND commissionBase = ' + CAST(@commissionBase AS VARCHAR)

		SET @select_field_list = '
			 scMasterId
			,code
			,description
			,sAgent
			,sBranch
			,sState
			,sGroup
			,rAgent
			,rBranch
			,rState
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
					 scMasterId = ISNULL(mode.scMasterId, main.scMasterId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sAgent = ISNULL(mode.sAgent, main.sAgent)
					,sBranch = ISNULL(mode.sBranch, main.sBranch)
					,sState = ISNULL(mode.sState, main.sState)
					,sGroup = ISNULL(mode.sGroup, main.sGroup)
					,rAgent = ISNULL(mode.rAgent, main.rAgent)
					,rBranch = ISNULL(mode.rBranch, main.rBranch)
					,rState = ISNULL(mode.rState, main.rState)
					,rGroup = ISNULL(mode.rGroup, main.rGroup)					
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
					,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)	
					,modifiedBy = CASE WHEN (main.approvedBy IS NULL) OR (mode.scMasterId IS NULL) THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN (main.approvedBy IS NULL) OR (mode.scMasterId IS NULL) THEN main.createdDate ELSE mode.createdDate END										
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.scMasterId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM scMaster main WITH(NOLOCK)
					LEFT JOIN scMasterHistory mode ON main.scMasterId = mode.scMasterId AND mode.approvedBy IS NULL
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
					 scDetailId = main.scDetailId
					,scMasterId = main.scMasterId
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
					,modifiedBy = CASE WHEN (main.approvedBy IS NULL) OR (mode.scDetailId IS NULL) THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN (main.approvedBy IS NULL) OR (mode.scDetailId IS NULL) THEN main.createdDate ELSE mode.createdDate END					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.scDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scDetail main WITH(NOLOCK)
					LEFT JOIN scDetailHistory mode ON main.scDetailId = mode.scDetailId AND mode.approvedBy IS NULL
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
							 m.scMasterId
							,m.code
							,m.description
							,m.sAgent
							,sAgentName = ISNULL(sa.agentName, ''All'')
							,m.sBranch
							,sBranchName = ISNULL(sb.agentName, ''All'')
							,m.sState
							,sStateName = ISNULL(ss.stateName, ''All'')
							,m.sGroup
							,sGroupName = ISNULL(sg.detailTitle, ''Any'')
							,m.rAgent
							,rAgentName = ISNULL(ra.agentName, ''All'')
							,m.rBranch
							,rBranchName = ISNULL(rb.agentName, ''All'')
							,m.rState
							,rStateName = ISNULL(rs.stateName, ''All'')
							,m.rGroup
							,rGroupName = ISNULL(rg.detailTitle, ''Any'')
							,m.tranType
							,tranTypeName = ISNULL(trn.typeTitle, ''All'')
							,m.commissionBase
							,commissionBaseName = cb.detailTitle
							,m.isEnable
							,fromAmt = MIN(d.fromAmt)
							,toAmt = MAX(d.toAmt)	
							,modifiedBy = MAX(ISNULL(m.modifiedBy, d.modifiedBy))						
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.scMasterId = d.scMasterId
						LEFT JOIN agentMaster sa WITH(NOLOCK) ON m.sAgent = sa.agentId
						LEFT JOIN agentMaster sb WITH(NOLOCK) ON m.sBranch = sb.agentId
						LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON m.sState = ss.stateId
						LEFT JOIN staticDataValue sg WITH(NOLOCK) ON m.sGroup = sg.valueId
						LEFT JOIN agentMaster ra WITH(NOLOCK) ON m.rAgent = ra.agentId
						LEFT JOIN agentMaster rb WITH(NOLOCK) ON m.rBranch = rb.agentId
						LEFT JOIN countryStateMaster rs WITH(NOLOCK) ON m.rState = rs.stateId
						LEFT JOIN staticDataValue rg WITH(NOLOCK) ON m.rGroup = rg.valueId
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
						LEFT JOIN staticDataValue cb WITH(NOLOCK) ON m.tranType = cb.valueId
						GROUP BY 
							 m.scMasterId
							,m.code
							,m.description
							,m.sAgent
							,sa.agentName
							,m.sBranch
							,sb.agentName
							,m.sState
							,ss.stateName
							,m.sGroup
							,sg.detailTitle
							,m.rAgent
							,ra.agentName
							,m.rBranch
							,rb.agentName
							,m.rState
							,rs.stateName
							,m.rGroup
							,rg.detailTitle
							,m.tranType
							,trn.typeTitle
							,m.commissionBase
							,cb.detailTitle
							,m.isEnable
							--,m.modifiedBy
							--,d.modifiedBy
					) x
					'
					
				--print @table
				--
			SET @sql_filter = ' '
			
			IF @sGroup IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sGroup = ' + CAST(@sGroup AS VARCHAR(50))
			
			IF @hasChanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged + ''''
			
			IF @sAgent IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sAgent = ' + CAST(@sAgent AS VARCHAR)
			
			IF @sBranch IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sAgent = ' + CAST(@sBranch AS VARCHAR)
			
			IF @sState IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sState = ' + CAST(@sState AS VARCHAR)
				
			IF @sGroup IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sGroup = ' + CAST(@sGroup AS VARCHAR)
			
			IF @rAgent IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rAgent = ' + CAST(@rAgent AS VARCHAR)
			
			IF @rBranch IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rAgent = ' + CAST(@rBranch AS VARCHAR)
			
			IF @rState IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rState = ' + CAST(@rState AS VARCHAR)
				
			IF @rGroup IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rGroup = ' + CAST(@rGroup AS VARCHAR)
			
			IF @tranType IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
			IF @commissionBase IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND commissionBase = ' + CAST(@commissionBase AS VARCHAR)
				
			SET @select_field_list = '
					 scMasterId
					,code
					,description
					,sAgent
					,sAgentName
					,sBranch
					,sBranchName
					,sState
					,sStateName
					,sGroup
					,sGroupName
					,rAgent
					,rAgentName
					,rBranch
					,rBranchName
					,rState
					,rStateName
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
			SET @sortBy = 'scMasterId'
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
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scMaster WHERE approvedBy IS NULL AND scMasterId = @scMasterId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scMasterId
					RETURN
				END
			DELETE FROM scMaster WHERE scMasterId =  @scMasterId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scMasterId
					RETURN
				END
				DELETE FROM scMasterHistory WHERE scMasterId = @scMasterId AND approvedBy IS NULL
			
		END
		
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				scDetailId, 'I' 
			FROM scDetail 				
			WHERE 
				scMasterId = @scMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.scDetailId, mode.modType
			FROM scDetailHistory mode WITH(NOLOCK)
			INNER JOIN scDetail main WITH(NOLOCK) ON mode.scDetailId = main.scDetailId 		
			WHERE 
				main.scMasterId = @scMasterId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'scDetailId'
				,@logParamMain = 'scDetail'
				,@logParamMod = 'scDetailHistory'
				,@module = '20'
				,@tableAlias = 'Custom Domestic Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM scDetail WHERE approvedBy IS NULL AND scDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM scDetailHistory WHERE scDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM scDetail WHERE scDetailId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM scDetailHistory WHERE scDetailId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scMasterId
	END

	ELSE IF @flag IN ('approve','approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scMaster WHERE approvedBy IS NULL AND scMasterId = @scMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scMasterHistory WHERE scMasterId = @scMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scMaster SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scMasterId = @scMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scMasterId, @oldValue OUTPUT
				UPDATE main SET
					 main.code                          = mode.code
					,main.[description]                 = mode.[description]
					,main.sAgent						= mode.sAgent
					,main.sBranch						= mode.sBranch
					,main.sState						= mode.sState
					,main.sGroup						= mode.sGroup
					,main.rAgent						= mode.rAgent
					,main.rBranch						= mode.rBranch
					,main.rState						= mode.rState
					,main.rGroup						= mode.rGroup
					,main.tranType                      = mode.tranType
					,main.commissionBase				= mode.commissionBase
					,main.effectiveFrom					= mode.effectiveFrom
					,main.effectiveTo					= mode.effectiveTo
					,main.isEnable						= mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scMaster main
				INNER JOIN scMasterHistory mode ON mode.scMasterId = main.scMasterId
				WHERE mode.scMasterId = @scMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scMaster', 'scMasterId', @scMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scMasterId, @oldValue OUTPUT
				UPDATE scMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scMasterId = @scMasterId
			END
			
			UPDATE scMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scMasterId = @scMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					scDetailId, 'I' 
				FROM scDetail 				
				WHERE 
					scMasterId = @scMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.scDetailId, ddh.modType
				FROM scDetailHistory ddh WITH(NOLOCK)
				INNER JOIN scDetail dd WITH(NOLOCK) ON ddh.scDetailId = dd.scDetailId 		
				WHERE 
					dd.scMasterId = @scMasterId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					@logIdentifier = 'scDetailId'
					,@logParamMain = 'scDetail'
					,@logParamMod = 'scDetailHistory'
					,@module = '20'
					,@tableAlias = 'Custom Domestic Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM scDetail WHERE approvedBy IS NULL AND scDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM scDetailHistory WHERE scDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE scDetail SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE scDetailId = @detailId
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
						FROM scDetail main
						INNER JOIN scDetailHistory mode ON mode.scDetailId = main.scDetailId
						WHERE mode.scDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE scDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE scDetailId = @detailId
					END
					
					UPDATE scDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE scDetailId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @scMasterId
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scMasterId
END CATCH



GO
