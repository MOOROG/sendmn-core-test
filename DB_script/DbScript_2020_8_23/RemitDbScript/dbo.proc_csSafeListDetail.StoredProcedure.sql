USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_csSafeListDetail]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_csSafeListDetail]
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

	------------- parameters need for safelist rule details ----------------------
	,@csSafeListDetailID                VARCHAR(30)		= NULL
	,@condition                         INT				= NULL
	,@collMode                          INT				= NULL
	,@paymentMode                       INT				= NULL	
	,@tranCount                         INT				= NULL
	,@amount                            MONEY			= NULL
	,@period							INT				= NULL
	,@nextAction                        CHAR(1)			= NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
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
		 @ApprovedFunctionId = 20602030

	IF @flag = 'i' --safelist rule insert
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
				--,isSafeList
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
				--,'Y'
				
			SET @csMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @csMasterId
	END

	ELSE IF @flag = 'm' --safelist rule in grid
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
					,CASE WHEN main.approvedBy IS NULL THEN '''' ELSE ''none'' END as isApproved
				FROM csMaster main WITH(NOLOCK)
				LEFT JOIN csMasterHistory mode ON main.csMasterId = mode.csMasterId AND mode.approvedBy IS NULL
					AND (
							mode.createdBy = ''' +  @user + ''' 
							OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
						)
					
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						--AND ISNULL(main.isSafeList,''N'')=''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
			) '
			
			
		SET @d = '(
				SELECT
					 csSafeListDetailID = main.csSafeListDetailID
					,csMasterId = main.csMasterId					
					,tranCount = ISNULL(mode.tranCount, main.tranCount)
					,amount = ISNULL(mode.amount, main.amount)
					,nextAction = ISNULL(mode.nextAction, main.nextAction)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END								
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.csSafeListDetailID IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM csSafeListRuleDetail main WITH(NOLOCK)
					LEFT JOIN csSafeListRuleDetailHistory mode ON main.csSafeListDetailID = mode.csSafeListDetailID AND mode.approvedBy IS NULL
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
							,m.isApproved
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
							,ruleScope
							,isApproved
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
					,isApproved				
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

	ELSE IF @flag = 'u' --update safelist rule
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

	ELSE IF @flag = 'u_v2' --update safelist rule
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csSafelistRuleDetail WITH(NOLOCK)
			WHERE csSafeListDetailID = @csSafeListDetailID AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csSafeListDetailID
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM csSafelistRuleDetail WITH(NOLOCK)
			WHERE csSafeListDetailID = @csSafeListDetailID  AND (createdBy<> @user OR ISNULL(isDeleted,'N') <> 'N') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csSafeListDetailID
			RETURN
		END
		IF EXISTS(
			SELECT 'x' FROM csSafelistRuleDetail (NOLOCK)
				WHERE ISNULL(condition, 0) = ISNULL(@condition, 0)
					AND ISNULL(tranCount, 0) = ISNULL(@tranCount, 0)
					AND ISNULL(period, 0) = ISNULL(@period, 0)
					AND ISNULL(nextAction, 0) = ISNULL(@nextAction, 0)
					AND ISNULL(ruleScope, 0) = ISNULL(@ruleScope, 0)
					AND csSafeListDetailID <> @csSafeListDetailID)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', NULL
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM csSafelistRuleDetail (NOLOCK) WHERE approvedBy IS NULL AND csSafeListDetailID = @csSafeListDetailID)			
			BEGIN				
				UPDATE csSafelistRuleDetail SET
					 condition		= @condition
					,tranCount		= @tranCount
					,amount			= @amount
					,period			= @period
					,nextAction		= @nextAction
					,createdBy		= @user
					,createdDate	= GETDATE()
					,isEnable		= 'Y'
					,ruleScope		= @ruleScope
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()		
				WHERE csSafeListDetailID = @csSafeListDetailID				
			END
			ELSE
			BEGIN
				INSERT INTO 
					csSafelistRuleDetailHistory
					(
						csSafeListDetailID
						,condition
						,tranCount
						,amount
						,period
						,nextAction
						,isActive
						,isDeleted
						,approvedBy
						,approvedDate
						,createdBy
						,createdDate
						,modifiedBy
						,modifiedDate
						,isEnable
					)
				SELECT csSafeListDetailID
						,condition
						,tranCount
						,amount
						,period
						,nextAction
						,isActive
						,isDeleted
						,approvedBy
						,approvedDate
						,createdBy
						,createdDate
						,modifiedBy
						,modifiedDate
						,isEnable 
				FROM csSafelistRuleDetail
				WHERE csSafeListDetailID = @csSafeListDetailID	

				UPDATE csSafelistRuleDetail SET
					 condition		= @condition
					,tranCount		= @tranCount
					,amount			= @amount
					,period			= @period
					,nextAction		= @nextAction
					,createdBy		= @user
					,createdDate	= GETDATE()
					,isEnable		= 'Y'
					,ruleScope		= @ruleScope
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()		
				WHERE csSafeListDetailID = @csSafeListDetailID	
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @csMasterId
	END

	ELSE IF @flag = 'disable' --enable/disable safelist rule
	BEGIN
			--N--disable
			--Y --enable
		IF (SELECT isnull(isEnable,'N') FROM csMaster WHERE csMasterId = @csMasterId)='N'
		BEGIN
			UPDATE csMaster SET isEnable='Y' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @csMasterId
			--return;
		END
		ELSE
		BEGIN		
			UPDATE csMaster SET isEnable='N' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @csMasterId
			--RETURN;
		END
		IF (SELECT isnull(isEnable,'N') FROM csMasterHistory WHERE csMasterId = @csMasterId)='N'
		BEGIN
			UPDATE csMasterHistory SET isEnable='Y' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @csMasterId
			--RETURN;
		END
		ELSE
		BEGIN		
			UPDATE csMasterHistory SET isEnable='N' WHERE csMasterId = @csMasterId	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @csMasterId
			--RETURN;
		END
	END

	ELSE IF @flag = 'ruleDetail'
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

	ELSE IF @flag = 'ird'--insert rule detail (done)
	BEGIN
		IF @condition ='4601' AND ISNULL(@tranCount,'0')=0
		BEGIN
			EXEC proc_errorHandler 0, 'Sorry, Tran count can not be 0!', @csSafeListDetailID
			return;
		END
		IF @condition  IN ('4600','4602','4603') AND ISNULL(@period,'0')=0
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry, Period(In days) can not be 0!', @csSafeListDetailID
			return;
		END
		IF EXISTS(
			SELECT 'x' FROM csSafeListRuleDetail 
				WHERE ISNULL(csMasterId, 0) = ISNULL(@csMasterId, 0) 
					AND ISNULL(condition, 0) = ISNULL(@condition, 0)
					AND ISNULL(collMode, 0) = ISNULL(@collMode, 0)
					AND ISNULL(paymentMode, 0) = ISNULL(@paymentMode, 0)
					AND ISNULL(tranCount, 0) = ISNULL(@tranCount, 0)
					AND ISNULL(amount, 0) = ISNULL(@amount, 0)
					AND ISNULL(period, 0) = ISNULL(@period, 0))
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @csMasterId
			RETURN
		END
		BEGIN TRANSACTION

			INSERT INTO csSafeListRuleDetail (
				 csMasterId
				,condition
				,collMode
				,paymentMode
				,tranCount
				,amount
				,period
				,nextAction
				,createdBy
				,createdDate
				,isEnable
			)
			SELECT
				 @csMasterId
				,@condition
				,@collMode
				,@paymentMode
				,@tranCount
				,@amount
				,@period
				,@nextAction
				,@user
				,GETDATE()
				,'Y'
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @csSafeListDetailID
	END

	ELSE IF @flag = 'ird_v2' --insert rule detail (done)
	BEGIN
		IF EXISTS(
			SELECT 'x' FROM csSafelistRuleDetail 
				WHERE ISNULL(condition, 0) = ISNULL(@condition, 0)
					AND ISNULL(tranCount, 0) = ISNULL(@tranCount, 0)
					AND ISNULL(period, 0) = ISNULL(@period, 0)
					AND ISNULL(nextAction, 0) = ISNULL(@nextAction, 0)
					AND ISNULL(ruleScope, 0) = ISNULL(@ruleScope, 0))
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO csSafelistRuleDetail (
				 condition
				,tranCount
				,amount
				,period
				,nextAction
				,createdBy
				,createdDate
				,isEnable	
				,ruleScope
			)
			SELECT
				 @condition
				,@tranCount
				,@amount
				,@period
				,@nextAction
				,@user
				,GETDATE()
				,'Y'
				,@ruleScope
				
			SET @csSafeListDetailID = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @csSafeListDetailID
	END

	ELSE IF @flag = 'urd' --update rule detail (done)
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csSafeListRuleDetail WITH(NOLOCK)
			WHERE csSafeListDetailID = @csSafeListDetailID AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csSafeListDetailID
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM csSafeListRuleDetail WHERE createdBy = @user AND approvedBy IS NULL AND csSafeListDetailID  = @csSafeListDetailID)			
			BEGIN				
				UPDATE csSafeListRuleDetail SET
				csMasterId = @csMasterId
				,condition = @condition
				,collMode = @collMode
				,paymentMode = @paymentMode
				,tranCount = @tranCount
				,amount = @amount
				,period = @period
				,nextAction = @nextAction
				WHERE csSafeListDetailID = @csSafeListDetailID	
			
			END
			ELSE
			BEGIN
				INSERT INTO csSafeListRuleDetailHistory(
					[csSafeListDetailID],
					[csMasterId],
					[condition],
					[collMode],
					[paymentMode],
					[tranCount],
					[amount],
					[period],
					[nextAction],
					[isActive],
					[isDeleted],
					[approvedBy],
					[approvedDate],
					[createdBy],
					[createdDate],
					[modifiedBy],
					[modifiedDate],
					[isEnable] 
				)
				
				SELECT
					@csSafeListDetailID,
					[csMasterId],
					[condition],
					[collMode],
					[paymentMode],
					[tranCount],
					[amount],
					[period],
					[nextAction],
					[isActive],
					[isDeleted],
					[approvedBy],
					[approvedDate],
					[createdBy],
					GETDATE(),
					[modifiedBy],
					[modifiedDate],
					[isEnable]
				FROM csSafeListRuleDetail WHERE [csSafeListDetailID]=@csSafeListDetailID

				UPDATE csSafeListRuleDetail SET
				csMasterId = @csMasterId
				,condition = @condition
				,collMode = @collMode
				,paymentMode = @paymentMode
				,tranCount = @tranCount
				,amount = @amount
				,period = @period
				,nextAction = @nextAction
				,[modifiedBy] =@user
				,[modifiedDate]=GETDATE()
				WHERE csSafeListDetailID = @csSafeListDetailID	
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @csSafeListDetailID
	END

	ELSE IF @flag = 'urd_v2' --update rule detail (done)
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csSafelistRuleDetail WITH(NOLOCK)
			WHERE csSafeListDetailID = @csSafeListDetailID AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csSafeListDetailID
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM csSafelistRuleDetail WITH(NOLOCK)
			WHERE csSafeListDetailID = @csSafeListDetailID  AND (createdBy<> @user OR ISNULL(isDeleted,'N') <> 'N') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @csSafeListDetailID
			RETURN
		END
		IF EXISTS(
			SELECT 'x' FROM csSafelistRuleDetail (NOLOCK)
				WHERE ISNULL(condition, 0) = ISNULL(@condition, 0)
					AND ISNULL(tranCount, 0) = ISNULL(@tranCount, 0)
					AND ISNULL(period, 0) = ISNULL(@period, 0)
					AND ISNULL(nextAction, 0) = ISNULL(@nextAction, 0)
					AND ISNULL(ruleScope, 0) = ISNULL(@ruleScope, 0)
					AND csSafeListDetailID <> @csSafeListDetailID)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', NULL
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM csSafelistRuleDetail (NOLOCK) WHERE approvedBy IS NULL AND csSafeListDetailID = @csSafeListDetailID)			
			BEGIN				
				UPDATE csSafelistRuleDetail SET
					 condition		= @condition
					,tranCount		= @tranCount
					,amount			= @amount
					,period			= @period
					,nextAction		= @nextAction
					,createdBy		= @user
					,createdDate	= GETDATE()
					,isEnable		= 'Y'
					,ruleScope		= @ruleScope
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()		
				WHERE csSafeListDetailID = @csSafeListDetailID				
			END
			ELSE
			BEGIN
				INSERT INTO 
					csSafelistRuleDetailHistory
					(
						csSafeListDetailID
						,condition
						,tranCount
						,amount
						,period
						,nextAction
						,isActive
						,isDeleted
						,approvedBy
						,approvedDate
						,createdBy
						,createdDate
						,modifiedBy
						,modifiedDate
						,isEnable
						,ruleScope
					)
				SELECT csSafeListDetailID
						,condition
						,tranCount
						,amount
						,period
						,nextAction
						,isActive
						,isDeleted
						,approvedBy
						,approvedDate
						,createdBy
						,createdDate
						,modifiedBy
						,modifiedDate
						,isEnable 
						,ruleScope
				FROM csSafelistRuleDetail
				WHERE csSafeListDetailID = @csSafeListDetailID	

				UPDATE csSafelistRuleDetail SET
					 condition		= @condition
					,tranCount		= @tranCount
					,amount			= @amount
					,period			= @period
					,nextAction		= @nextAction
					,createdBy		= @user
					,createdDate	= GETDATE()
					,isEnable		= 'Y'
					,ruleScope		= @ruleScope
					,modifiedBy		= @user
					,modifiedDate	= GETDATE()		
				WHERE csSafeListDetailID = @csSafeListDetailID	
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @csMasterId
	END
	ELSE IF @flag ='rdGrid'--rule detail in grid (done)
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'condition'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @pageNumber = 1
		SET @pageSize = 10000
		
		
		SET @table = '(
				SELECT
					 main.csSafeListDetailID
					,condition=ISNULL(con.detailTitle,''All'')	
					,condition1	=condition		
					,collMode=ISNULL(cm.detailTitle, ''All'')
					,collMode1=collMode
					,paymentMode= ISNULL(pm.typeTitle, ''All'')		
					,paymentMode1 =paymentMode			
					,main.tranCount
					,main.amount
					,main.period
					,main.nextAction
					,isDisabled=CASE WHEN ISNULL(main.isEnable,''n'')=''y'' then ''Enabled'' else ''Disabled'' END
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
					,main.modifiedDate
					,CASE WHEN main.approvedBy IS NULL THEN '''' ELSE ''none'' END as isApproved

				FROM csSafeListRuleDetail main WITH(NOLOCK)
				LEFT JOIN staticDataValue con WITH(NOLOCK) ON main.condition = con.valueId
				LEFT JOIN staticDataValue cm WITH(NOLOCK) ON main.collMode = cm.valueId
				LEFT JOIN serviceTypeMaster pm WITH(NOLOCK) ON main.paymentMode = pm.serviceTypeId						
					WHERE main.csMasterId = ''' + CAST (@csMasterId AS VARCHAR) + ''' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						--AND (
						--		main.approvedBy IS NOT NULL 
						--		OR main.createdBy = ''' +  ISNULL(@user,'') + '''
						--	)
			)x'
			
		SET @sql_filter = ''
		IF @condition IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND x.condition1 = ' + CAST(@condition AS VARCHAR(50))
			
		IF @collMode IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND x.collMode1 = ' + CAST(@collMode AS VARCHAR(50))
		
		IF @paymentMode IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND x.paymentMode1 = ' + CAST(@paymentMode AS VARCHAR(50))
	
		IF @nextAction IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND x.nextAction = ''' + CAST(@nextAction AS VARCHAR(50))+''''

		--IF @condition IS NOT NULL
		--	SET @sql_filter =  @sql_filter + ' AND condition = ' + CAST(ISNULL(@condition,'') AS VARCHAR(50))
			
		--IF @collMode IS NOT NULL
		--	SET @sql_filter =  @sql_filter + ' AND collMode = ' + CAST(ISNULL(@collMode,'') AS VARCHAR(50))
		
		--IF @paymentMode IS NOT NULL
		--	SET @sql_filter =  @sql_filter + ' AND paymentMode = ' + CAST(ISNULL(@paymentMode,'') AS VARCHAR(50))
	
		--IF @nextAction IS NOT NULL
		--	SET @sql_filter =  @sql_filter + ' AND nextAction = '+ CAST(ISNULL(@nextAction,'') AS VARCHAR(50))
	
		--PRINT (@table+@sql_filter)
		SET @select_field_list ='
			 csSafeListDetailID
			,condition
			,collMode
			,paymentMode
			,tranCount
			,amount
			,period
			,nextAction
			,isDisabled
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
			,isApproved
			'
			
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

	ELSE IF @flag ='rdGrid_v2'--rule detail in grid (done)
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'condition'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @pageNumber = 1
		SET @pageSize = 10000
		
		
		SET @table = '(
				SELECT
					 main.csSafeListDetailID
					,condition=ISNULL(con.detailTitle,''All'')	
					,condition1	=condition				
					,main.tranCount
					,main.amount
					,main.period
					,CASE WHEN main.nextAction=''H'' THEN ''Hold''
						  WHEN main.nextAction=''B'' THEN ''Block''
						  WHEN main.nextAction=''M'' THEN ''Mark''
						  ELSE ''''
					 END nextAction
					,main.ruleScope
					,isDisabled=CASE WHEN ISNULL(main.isEnable,''n'')=''y'' then ''Enabled'' else ''Disabled'' END
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
					,main.modifiedDate
					,CASE WHEN main.approvedBy IS NULL THEN '''' ELSE ''none'' END as isApproved

				FROM csSafeListRuleDetail main WITH(NOLOCK)
				LEFT JOIN staticDataValue con WITH(NOLOCK) ON main.condition = con.valueId			
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						
			)x'


			
		SET @sql_filter = ''
		IF @condition IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND x.condition1 = ' + CAST(@condition AS VARCHAR(50))
	
		IF @nextAction IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND x.nextAction = ''' + CAST(@nextAction AS VARCHAR(50))+''''

		IF @ruleScope IS NOT NULL
		SET @sql_filter =  @sql_filter + ' AND x.ruleScope = ''' + CAST(@ruleScope AS VARCHAR(50))+''''
		
		IF @tranCount IS NOT NULL AND @tranCount<>0
		SET @sql_filter =  @sql_filter + ' AND x.tranCount = ''' + CAST(@tranCount AS VARCHAR(50))+''''
		
		IF @amount IS NOT NULL AND @amount<>0
		SET @sql_filter =  @sql_filter + ' AND x.amount = ''' + CAST(@amount AS VARCHAR(50))+''''
		
		IF @period IS NOT NULL AND @period<>0
		SET @sql_filter =  @sql_filter + ' AND x.period = ''' + CAST(@period AS VARCHAR(50))+''''

		SET @select_field_list ='
			 csSafeListDetailID
			,condition
			,tranCount
			,amount
			,period
			,nextAction
			,ruleScope
			,isDisabled
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
			,isApproved
			'
			
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

	ELSE IF @flag = 'rDisable' --rule detail disable (done)
	BEGIN
		IF (SELECT isnull(isEnable,'N') FROM csSafeListRuleDetail WHERE csSafeListDetailID = @csSafeListDetailID)='N'
		begin
			UPDATE csSafeListRuleDetail SET isEnable='Y' WHERE csSafeListDetailID = @csSafeListDetailID	
			EXEC proc_errorHandler 0, 'Record enabled successfully.', @csSafeListDetailID
			return;
		end
		else
		begin		
			UPDATE csSafeListRuleDetail SET isEnable='N' WHERE csSafeListDetailID = @csSafeListDetailID	
			EXEC proc_errorHandler 0, 'Record disabled successfully.', @csSafeListDetailID
			return;
		end
		
		
	END

	ELSE IF @flag = 'rEdit' --rule detail edit(done)
	BEGIN
			SELECT 
				*
				,amount1 = CAST(amount AS DECIMAL(38, 2))
			FROM csSafeListRuleDetail WITH(NOLOCK) WHERE csSafeListDetailID = @csSafeListDetailID
	END

	ELSE IF @flag = 'a_rule' --approve rule detail (done)
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csSafeListRuleDetail WITH(NOLOCK)
				WHERE csSafeListDetailID = @csSafeListDetailID AND approvedBy IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already approved.', @csSafeListDetailID
			RETURN
		END
			
		IF EXISTS (
			SELECT 'X' FROM csSafeListRuleDetail WITH(NOLOCK)
				WHERE csSafeListDetailID = @csSafeListDetailID AND createdBy = @user AND approvedBy IS NULL
		)	
		BEGIN
			EXEC proc_errorHandler 1, 'You cannot approve this record.', @csSafeListDetailID
			RETURN
		END	
		
		BEGIN TRANSACTION
			UPDATE csSafeListRuleDetail SET approvedBy=@user, approvedDate=GETDATE() WHERE csSafeListDetailID = @csSafeListDetailID	
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Approved successfully.', @csSafeListDetailID
	END

	ELSE IF @flag = 'ar' --approve safe list rule
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csMaster WITH(NOLOCK)
				WHERE csMasterId = @csMasterId AND approvedBy IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already approved.', @csMasterId
			RETURN
		END
			
		IF EXISTS (
			SELECT 'X' FROM csMaster WITH(NOLOCK)
				WHERE csMasterId = @csMasterId AND createdBy = @user AND approvedBy IS NULL
		)	
		BEGIN
			EXEC proc_errorHandler 1, 'You cannot approve this record.', @csMasterId
			RETURN
		END	
		
		BEGIN TRANSACTION
			UPDATE csMaster SET approvedBy=@user, approvedDate=GETDATE() WHERE csMasterId = @csMasterId	
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Approved successfully.', @csMasterId
	END
	END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @csMasterId
END CATCH
END


GO
