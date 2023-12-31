USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scPayMasterHub]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

proc_scPayMasterHub @flag = 'm', @user = 'admin'

*/

CREATE proc [dbo].[proc_scPayMasterHub]   
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@scPayMasterHubId					VARCHAR(30)		= NULL
	,@code                              VARCHAR(100)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@ssAgent                           INT				= NULL
	,@sAgent                            INT				= NULL
	,@sBranch                           INT				= NULL
	,@rCountry                          INT				= NULL
	,@rsAgent                           INT				= NULL
	,@rAgent                            INT				= NULL
	,@rBranch                           INT				= NULL
	,@state                             INT				= NULL
	,@zip                               VARCHAR(20)		= NULL
	,@agentGroup                        INT				= NULL
	,@rState							INT				= NULL
	,@rZip								VARCHAR(20)		= NULL
	,@rAgentGroup						INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@commissionBase                    INT				= NULL
	,@commissionCurrency				VARCHAR(3)		= NULL
	,@effectiveFrom                     DATETIME		= NULL
	,@effectiveTo                       DATETIME		= NULL
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
		,@functionId		INT
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
		
	SELECT
		 @ApprovedFunctionId = 20201330
		,@logIdentifier = 'scPayMasterHubId'
		,@logParamMain = 'scPayMasterHub'
		,@logParamMod = 'scPayMasterHubHistory'
		,@module = '20'
		,@tableAlias = 'Hub Special Pay Commission'
	
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'x' FROM scPayMasterHub WHERE 
				ssAgent = ISNULL(@ssAgent, ssAgent) AND
				rsAgent = ISNULL(@rsAgent, @rsAgent) AND
				sCountry = ISNULL(@sCountry, sCountry) AND 
				rCountry = ISNULL(@rCountry, rCountry) AND
				sAgent = ISNULL(@sAgent, sAgent) AND
				rAgent = ISNULL(@rAgent, rAgent) AND
				sBranch = ISNULL(@sBranch, sBranch) AND
				rBranch = ISNULL(@rBranch, rBranch) AND 
				tranType = ISNULL(@tranType, tranType) AND 
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @scPayMasterHubId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scPayMasterHub (
				 code
				,[description]
				,sCountry
				,ssAgent
				,sAgent
				,sBranch
				,rCountry
				,rsAgent
				,rAgent
				,rBranch
				,[state]
				,zip
				,agentGroup
				,rState
				,rZip
				,rAgentGroup
				,baseCurrency
				,tranType
				,commissionBase
				,commissionCurrency
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @code
				,@description
				,@sCountry
				,@ssAgent
				,@sAgent
				,@sBranch
				,@rCountry
				,@rsAgent
				,@rAgent
				,@rBranch
				,@state
				,@zip
				,@agentGroup
				,@rState
				,@rZip
				,@rAgentGroup
				,@baseCurrency
				,@tranType
				,@commissionBase
				,@commissionCurrency
				,@effectiveFrom
				,@effectiveTo
				,@isEnable
				,@user
				,GETDATE()			
				
			SET @scPayMasterHubId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scPayMasterHubId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHubHistory WITH(NOLOCK)
				WHERE scPayMasterHubId = @scPayMasterHubId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				 mode.*
				,CONVERT(VARCHAR, mode.effectiveFrom, 101) effFrom
				,CONVERT(VARCHAR, mode.effectiveTo, 101) effTo
			FROM scPayMasterHubHistory mode WITH(NOLOCK)
			INNER JOIN scPayMasterHub main WITH(NOLOCK) ON mode.scPayMasterHubId = main.scPayMasterHubId
			WHERE mode.scPayMasterHubId= @scPayMasterHubId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				 *
				,CONVERT(VARCHAR, effectiveFrom, 101) effFrom
				,CONVERT(VARCHAR, effectiveTo, 101) effTo 
			FROM scPayMasterHub WITH(NOLOCK) WHERE scPayMasterHubId = @scPayMasterHubId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scPayMasterHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHubHistory WITH(NOLOCK)
			WHERE scPayMasterHubId  = @scPayMasterHubId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scPayMasterHubId
			RETURN
		END
		IF EXISTS(SELECT 'x' FROM scPayMasterHub WHERE 
				scPayMasterHubId <> @scPayMasterHubId AND
				ssAgent = ISNULL(@ssAgent, ssAgent) AND
				rsAgent = ISNULL(@rsAgent, @rsAgent) AND
				sCountry = ISNULL(@sCountry, sCountry) AND 
				rCountry = ISNULL(@rCountry, rCountry) AND
				sAgent = ISNULL(@sAgent, sAgent) AND
				rAgent = ISNULL(@rAgent, rAgent) AND
				sBranch = ISNULL(@sBranch, sBranch) AND
				rBranch = ISNULL(@rBranch, rBranch) AND 
				tranType = ISNULL(@tranType, tranType) AND 
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @scPayMasterHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayMasterHub WHERE approvedBy IS NULL AND scPayMasterHubId  = @scPayMasterHubId)			
			BEGIN				
				UPDATE scPayMasterHub SET
					 code = @code
					,[description] = @description
					,sCountry = @sCountry
					,ssAgent = @ssAgent
					,sAgent = @sAgent
					,sBranch = @sBranch
					,rCountry = @rCountry
					,rsAgent = @rsAgent
					,rAgent = @rAgent
					,rBranch = @rBranch
					,[state] = @state
					,zip = @zip
					,agentGroup = @agentGroup
					,rState = @rState
					,rZip = @rZip
					,rAgentGroup = @rAgentGroup
					,baseCurrency = @baseCurrency
					,tranType = @tranType
					,commissionBase = @commissionBase
					,commissionCurrency = @commissionCurrency
					,effectiveFrom = @effectiveFrom
					,effectiveTo = @effectiveTo
					,isEnable = @isEnable
					,modifiedBy = @user
					,modifiedDate = GETDATE()					
				WHERE scPayMasterHubId = @scPayMasterHubId				
			END
			ELSE
			BEGIN
				DELETE FROM scPayMasterHubHistory WHERE scPayMasterHubId = @scPayMasterHubId AND approvedBy IS NULL
				INSERT INTO scPayMasterHubHistory (
					 scPayMasterHubId
					,code
					,[description]
					,sCountry
					,ssAgent
					,sAgent
					,sBranch
					,rCountry
					,rsAgent
					,rAgent
					,rBranch
					,[state]
					,zip
					,agentGroup
					,rState
					,rZip
					,rAgentGroup
					,baseCurrency
					,tranType
					,commissionBase
					,commissionCurrency
					,effectiveFrom
					,effectiveTo
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @scPayMasterHubId
					,@code
					,@description
					,@sCountry
					,@ssAgent
					,@sAgent
					,@sBranch
					,@rCountry
					,@rsAgent
					,@rAgent
					,@rBranch
					,@state
					,@zip
					,@agentGroup
					,@rState
					,@rZip
					,@rAgentGroup
					,@baseCurrency
					,@tranType
					,@commissionBase
					,@commissionCurrency
					,@effectiveFrom
					,@effectiveTo
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scPayMasterHubId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @scPayMasterHubId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scPayMasterHubHistory  WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @scPayMasterHubId
			RETURN
		END
		
			--DELETE FROM scPayMasterHubHistory WHERE scPayMasterHubId = @scPayMasterHubId AND approvedBy IS NULL
			INSERT INTO scPayMasterHubHistory (
				 scPayMasterHubId
				,code
				,[description]
				,sCountry
				,ssAgent
				,sAgent
				,sBranch
				,rCountry
				,rsAgent
				,rAgent
				,rBranch
				,[state]
				,zip
				,agentGroup
				,rState
				,rZip
				,rAgentGroup
				,baseCurrency
				,tranType
				,commissionBase
				,commissionCurrency
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 scPayMasterHubId
				,code
				,[description]
				,sCountry
				,ssAgent
				,sAgent
				,sBranch
				,rCountry
				,rsAgent
				,rAgent
				,rBranch
				,[state]
				,zip
				,agentGroup
				,rState
				,rZip
				,rAgentGroup
				,baseCurrency
				,tranType
				,commissionBase
				,commissionCurrency
				,effectiveFrom
				,effectiveTo
				,isEnable
				,@user
				,GETDATE()
				,'D'
			FROM scPayMasterHub WHERE scPayMasterHubId = @scPayMasterHubId	

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scPayMasterHubId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'scPayMasterHubId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 scPayMasterHubId = ISNULL(mode.scPayMasterHubId, main.scPayMasterHubId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sCountry = ISNULL(mode.sCountry, main.sCountry)
					,ssAgent= ISNULL(mode.ssAgent, main.ssAgent)
					,sAgent = ISNULL(mode.sAgent, main.sAgent)
					,sBranch = ISNULL(mode.sBranch, main.sBranch)
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,rsAgent = ISNULL(mode.rsAgent, main.rsAgent)
					,rAgent = ISNULL(mode.rAgent, main.rAgent)
					,rBranch = ISNULL(mode.rBranch, main.rBranch)
					,state = ISNULL(mode.state, main.state)
					,zip = ISNULL(mode.zip, main.zip)
					,agentGroup = ISNULL(mode.agentGroup, main.agentGroup)
					,rState = ISNULL(mode.rState, main.rState)
					,rZip = ISNULL(mode.rZip, main.rZip)
					,rAgentGroup = ISNULL(mode.rAgentGroup, main.rAgentGroup)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,commissionCurrency = ISNULL(mode.commissionCurrency,main.commissionCurrency)
					,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
					,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					
					,main.createdBy
					,main.createdDate
					,modifiedDate = ISNULL(mode.createdDate, main.modifiedDate)
					,modifiedBy = ISNULL(mode.createdBy, main.modifiedBy)
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.scPayMasterHubId IS NOT NULL THEN ''Y'' ELSE ''N'' END
				FROM scPayMasterHub main WITH(NOLOCK)
					LEFT JOIN scPayMasterHubHistory mode ON main.scPayMasterHubId = mode.scPayMasterHubId AND mode.approvedBy IS NULL
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
			
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 scPayMasterHubId
			,code
			,description
			,sCountry
			,ssAgent
			,sAgent
			,sBranch
			,rCountry
			,rsAgent
			,rAgent
			,rBranch
			,state
			,zip
			,agentGroup
			,rState
			,rZip
			,rAgentGroup
			,baseCurrency
			,tranType
			,commissionBase
			,commissionCurrency
			,effectiveFrom
			,effectiveTo
			,isEnable
			,createdBy
			,createdDate
			,isDeleted 
			,hasChanged'
			
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
					 scPayMasterHubId = ISNULL(mode.scPayMasterHubId, main.scPayMasterHubId)
					,code = ISNULL(mode.code, main.code)
					,description = ISNULL(mode.description, main.description)
					,sCountry = ISNULL(mode.sCountry, main.sCountry)
					,ssAgent = ISNULL(mode.ssAgent, main.ssAgent)
					,sAgent = ISNULL(mode.sAgent, main.sAgent)
					,sBranch = ISNULL(mode.sBranch, main.sBranch)
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,rsAgent = ISNULL(mode.rsAgent, main.rsAgent)
					,rAgent = ISNULL(mode.rAgent, main.rAgent)
					,rBranch = ISNULL(mode.rBranch, main.rBranch)
					,state = ISNULL(mode.state, main.state)
					,zip = ISNULL(mode.zip, main.zip)
					,agentGroup = ISNULL(mode.agentGroup, main.agentGroup)
					,rState = ISNULL(mode.rState, main.rState)
					,rZip = ISNULL(mode.rZip, main.rZip)
					,rAgentGroup = ISNULL(mode.rAgentGroup, main.rAgentGroup)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,tranType = ISNULL(mode.tranType, main.tranType)
					,commissionBase = ISNULL(mode.commissionBase, main.commissionBase)
					,commissionCurrency = ISNULL(mode.commissionCurrency,main.commissionCurrency)
					,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
					,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END													
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.scPayMasterHubId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM scPayMasterHub main WITH(NOLOCK)
					LEFT JOIN scPayMasterHubHistory mode ON main.scPayMasterHubId = mode.scPayMasterHubId AND mode.approvedBy IS NULL
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
					 scPayDetailHubId = main.scPayDetailHubId
					,scPayMasterHubId = main.scPayMasterHubId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END				
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.scPayDetailHubId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scPayDetailHub main WITH(NOLOCK)
					LEFT JOIN scPayDetailHubHistory mode ON main.scPayDetailHubId = mode.scPayDetailHubId AND mode.approvedBy IS NULL
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
							 m.scPayMasterHubId
							,m.description
							,m.code
							,m.sCountry
							,sCountryName = ISNULL(sc.countryName, ''All'')
							,m.ssAgent
							,ssAgentName = ISNULL(ssa.agentName, ''All'')
							,m.sAgent
							,sAgentName = ISNULL(sa.agentName, ''All'')
							,m.sBranch
							,sBranchName = ISNULL(sb.agentName, ''All'')
							,m.rCountry
							,rCountryName = rc.countryName
							,m.rsAgent
							,rsAgentName = rsa.agentName
							,m.rAgent
							,rAgentName = ISNULL(ra.agentName, ''All'')
							,m.rBranch
							,rBranchName = ISNULL(rb.agentName, ''All'')							
							,[state]
							,m.zip
							,m.agentGroup
							,m.rState
							,m.rZip
							,m.rAgentGroup
							,m.tranType
							,tranTypeName = ISNULL(trn.typeTitle, ''All'')
							,m.baseCurrency
							,m.commissionBase
							,m.commissionCurrency
							,m.effectiveFrom
							,m.effectiveTo
							,m.isEnable							
							,fromAmt = MIN(d.fromAmt)
							,toAmt = MAX(d.toAmt)
							,modifiedBy = MAX(ISNULL(m.modifiedBy, d.modifiedBy))
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.scPayMasterHubId = d.scPayMasterHubId
						
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN agentMaster ssa WITH(NOLOCK) ON ssa.agentId = m.ssAgent
						LEFT JOIN agentMaster sa WITH(NOLOCK) ON sa.agentId = m.sAgent
						LEFT JOIN agentMaster sb WITH(NOLOCK) ON sb.agentId = m.sBranch
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN agentMaster rsa WITH(NOLOCK) ON rsa.agentId = m.rsAgent
						LEFT JOIN agentMaster ra WITH(NOLOCK) ON ra.agentId = m.rAgent
						LEFT JOIN agentMaster rb WITH(NOLOCK) ON rb.agentId = m.rBranch
						
						GROUP BY 
							 m.scPayMasterHubId
							,m.description
							,m.code
							,m.sCountry
							,sc.countryName
							,m.ssAgent
							,ssa.agentName
							,m.sAgent
							,sa.agentName
							,m.sBranch
							,sb.agentName
							,m.rCountry
							,rc.countryName
							,m.rsAgent
							,rsa.agentName
							,m.rAgent
							,ra.agentName
							,m.rBranch
							,rb.agentName
							,[state]
							,zip
							,agentGroup
							,rState
							,rZip
							,rAgentGroup
							,m.tranType
							,trn.typeTitle							
							,m.baseCurrency
							,m.commissionBase
							,m.commissionCurrency
							,m.effectiveFrom
							,m.effectiveTo
							,m.isEnable	
							--,m.modifiedBy
							--,d.modifiedBy
					) x
					'
					
				--print @m
				--
			SET @sql_filter = ' '
			
			IF @hasChanged IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''

			IF @sCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
							
			IF @sAgent IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND sAgent = ' + CAST(@sAgent AS VARCHAR(50))
				
			IF @sBranch IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND ssAgent = ' + CAST(@ssAgent AS VARCHAR(50))
		
			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @rAgent IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rAgent = ' + CAST(@rAgent AS VARCHAR(50))
				
			IF @rBranch IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rsAgent = ' + CAST(@rsAgent AS VARCHAR(50))
							
			IF @tranType IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))

			IF @agentGroup IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND agentGroup = ' + CAST(@agentGroup AS VARCHAR(50))
							
			SET @select_field_list = '
					 scPayMasterHubId
					,code
					,[description]
					,sCountry
					,sCountryName
					,ssAgent
					,ssAgentName
					,sAgent
					,sAgentName
					,sBranch
					,sBranchName
					
					,rCountry
					,rCountryName
					,rsAgent
					,rsAgentName
					,rAgent
					,rAgentName
					,rBranch
					,rBranchName
								
					,[state]
					,zip
					,agentGroup
					
					,rState
					,rZip
					,rAgentGroup
			
					,baseCurrency
					,tranType
					,tranTypeName
					,commissionBase
					,commissionCurrency
					,effectiveFrom
					,effectiveTo
					,isEnable	
					,fromAmt
					,toAmt
					,hasChanged
					,modifiedBy
					
				'
				
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'scPayMasterHubId'
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
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayMasterHubId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scPayMasterHub WHERE approvedBy IS NULL AND scPayMasterHubId = @scPayMasterHubId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayMasterHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayMasterHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayMasterHubId
					RETURN
				END
			DELETE FROM scPayMasterHub WHERE scPayMasterHubId =  @scPayMasterHubId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayMasterHubId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayMasterHubId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scPayMasterHubId
					RETURN
				END
				DELETE FROM scPayMasterHubHistory WHERE scPayMasterHubId = @scPayMasterHubId AND approvedBy IS NULL

		END
		IF @flag = 'rejectAll'
		BEGIN
				
			INSERT @DetailIdList
			SELECT 
				scPayDetailHubId, 'I' 
			FROM scPayDetailHub 				
			WHERE 
				scPayMasterHubId = @scPayMasterHubId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				mode.scPayDetailHubId, mode.modType
			FROM scPayDetailHubHistory mode WITH(NOLOCK)
			INNER JOIN scPayDetailHub main WITH(NOLOCK) ON mode.scPayDetailHubId = main.scPayDetailHubId 		
			WHERE 
				main.scPayMasterHubId = @scPayMasterHubId
				AND mode.approvedBy IS NULL			
				
			SELECT
				@logIdentifier = 'scPayDetailHubId'
				,@logParamMain = 'scPayDetailHub'
				,@logParamMod = 'scPayDetailHubHistory'
				,@module = '20'
				,@tableAlias = 'Hub Special Pay Commission Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM scPayDetailHub WHERE approvedBy IS NULL AND scPayDetailHubId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM scPayDetailHubHistory WHERE scPayDetailHubId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM scPayDetailHub WHERE scPayDetailHubId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM scPayDetailHubHistory WHERE scPayDetailHubId = @detailId AND approvedBy IS NULL
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
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scPayMasterHubId
	END

	ELSE IF @flag IN ('approve', 'approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scPayMasterHub WITH(NOLOCK)
			WHERE scPayMasterHubId = @scPayMasterHubId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scPayMasterHubId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scPayMasterHub WHERE approvedBy IS NULL AND scPayMasterHubId = @scPayMasterHubId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scPayMasterHubHistory WHERE scPayMasterHubId = @scPayMasterHubId
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scPayMasterHub SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scPayMasterHubId = @scPayMasterHubId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayMasterHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayMasterHubId, @oldValue OUTPUT
				UPDATE main SET
					 main.code = mode.code
					,main.[description] = mode.[description]
					,main.sCountry = mode.sCountry
					,main.ssAgent = mode.ssAgent
					,main.sAgent = mode.sAgent
					,main.sBranch = mode.sBranch
					,main.rCountry = mode.rCountry
					,main.rsAgent = mode.rsAgent
					,main.rAgent = mode.rAgent
					,main.rBranch = mode.rBranch
					,main.[state] = mode.[state]
					,main.zip = mode.zip
					,main.agentGroup = mode.agentGroup
					,main.rState = mode.rState
					,main.rZip = mode.rZip
					,main.rAgentGroup = mode.rAgentGroup
					,main.baseCurrency = mode.baseCurrency
					,main.tranType = mode.tranType
					,main.commissionBase = mode.commissionBase
					,main.commissionCurrency = mode.commissionCurrency
					,main.effectiveFrom = mode.effectiveFrom
					,main.effectiveTo = mode.effectiveTo
					,main.isEnable = mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM scPayMasterHub main
				INNER JOIN scPayMasterHubHistory mode ON mode.scPayMasterHubId = main.scPayMasterHubId
				WHERE mode.scPayMasterHubId = @scPayMasterHubId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scPayMasterHub', 'scPayMasterHubId', @scPayMasterHubId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scPayMasterHubId, @oldValue OUTPUT
				UPDATE scPayMasterHub SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scPayMasterHubId = @scPayMasterHubId
			END
			
			UPDATE scPayMasterHubHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scPayMasterHubId = @scPayMasterHubId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scPayMasterHubId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					scPayDetailHubId, 'I' 
				FROM scPayDetailHub 				
				WHERE 
					scPayMasterHubId = @scPayMasterHubId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					ddh.scPayDetailHubId, ddh.modType
				FROM scPayDetailHubHistory ddh WITH(NOLOCK)
				INNER JOIN scPayDetailHub dd WITH(NOLOCK) ON ddh.scPayDetailHubId = dd.scPayDetailHubId 		
				WHERE 
					dd.scPayMasterHubId = @scPayMasterHubId
					AND ddh.approvedBy IS NULL					
					
				SELECT
					 @logIdentifier = 'scPayDetailHubId'
					,@logParamMain = 'scPayDetailHub'
					,@logParamMod = 'scPayDetailHubHistory'
					,@module = '20'
					,@tableAlias = 'Hub Special Pay Commission Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM scPayDetailHub WHERE approvedBy IS NULL AND scPayDetailHubId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM scPayDetailHubHistory WHERE scPayDetailHubId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE scPayDetailHub SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE scPayDetailHubId = @detailId
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
						FROM scPayDetailHub main
						INNER JOIN scPayDetailHubHistory mode ON mode.scPayDetailHubId = main.scPayDetailHubId
						WHERE mode.scPayDetailHubId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE scPayDetailHub SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE scPayDetailHubId = @detailId
					END
					
					UPDATE scPayDetailHubHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE scPayDetailHubId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scPayMasterHubId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @scPayMasterHubId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scPayMasterHubId
END CATCH



GO
