USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_seRate]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

	EXEC proc_seRate @flag = 's', @user = 'admin'

*/

CREATE proc [dbo].[proc_seRate]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@seRateId                          VARCHAR(30)		= NULL
	,@baseCurrency                      INT				= NULL
	,@localCurrency                     INT				= NULL
	,@sHub                              INT				= NULL
	,@sCountry                          INT				= NULL
	,@ssAgent							INT				= NULL
	,@sAgent                            INT				= NULL
	,@sBranch                           INT				= NULL
	,@rHub								INT				= NULL
	,@rCountry                          INT				= NULL
	,@rsAgent							INT				= NULL
	,@rAgent                            INT				= NULL
	,@rBranch                           INT				= NULL
	,@state                             INT				= NULL
	,@zip                               VARCHAR(20)		= NULL
	,@agentGroup                        INT				= NULL
	,@cost                              MONEY			= NULL
	,@margin                            DECIMAL(26, 16)	= NULL
	,@agentMargin                       MONEY			= NULL
	,@ve                                MONEY			= NULL
	,@ne                                MONEY			= NULL
	,@spFlag							CHAR(1)			= NULL
	,@effectiveFrom                     DATETIME		= NULL
	,@effectiveTo                       DATETIME		= NULL
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
		 @sql					VARCHAR(MAX)
		,@oldValue				VARCHAR(MAX)
		,@newValue				VARCHAR(MAX)
		,@module				VARCHAR(10)
		,@tableAlias			VARCHAR(100)
		,@logIdentifier			VARCHAR(50)
		,@logParamMod			VARCHAR(100)
		,@logParamMain			VARCHAR(100)
		,@table					VARCHAR(MAX)
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@modType				VARCHAR(6)
		,@ApprovedFunctionId	INT
		
	SELECT
		 @logIdentifier = 'seRateId'
		,@logParamMain = 'seRate'
		,@logParamMod = 'seRateHistory'
		,@module = '20'
		,@tableAlias = 'Special Ex-Rate'
		,@ApprovedFunctionId = CASE  @spFlag WHEN  'P' THEN 20111130 WHEN 'S' THEN 20111330  ELSE  0 END
	
	

	
	IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'seRateId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
			
		DECLARE @m VARCHAR(MAX)		

		SET @m = '(
				SELECT
					 seRateId = ISNULL(mode.seRateId, main.seRateId)
					,baseCurrency = ISNULL(mode.baseCurrency, main.baseCurrency)
					,localCurrency = ISNULL(mode.localCurrency, main.localCurrency)
					,sHub = ISNULL(mode.sHub, main.sHub)					
					,sCountry = ISNULL(mode.sCountry, main.sCountry)
					,ssAgent = ISNULL(mode.ssAgent, main.ssAgent)
					,sAgent = ISNULL(mode.sAgent, main.sAgent)
					,sBranch = ISNULL(mode.sBranch, main.sBranch)
					,rHub = ISNULL(mode.rHub, main.rHub)					
					,rCountry = ISNULL(mode.rCountry, main.rCountry)
					,rsAgent = ISNULL(mode.rsAgent, main.rsAgent)
					,rAgent = ISNULL(mode.rAgent, main.rAgent)
					,rBranch = ISNULL(mode.rBranch, main.rBranch)
					,state = ISNULL(mode.state, main.state)
					,zip = ISNULL(mode.zip, main.zip)
					,agentGroup = ISNULL(mode.agentGroup, main.agentGroup)
					,cost = ISNULL(mode.cost, main.cost)
					,margin = ISNULL(mode.margin, main.margin)
					,agentMargin = ISNULL(mode.agentMargin, main.agentMargin)
					,ve = ISNULL(mode.ve, main.ve)
					,ne = ISNULL(mode.ne, main.ne)
					,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
					,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)
					,spFlag = ISNULL(mode.spFlag, main.spFlag)		
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.seRateId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END
				FROM seRate main WITH(NOLOCK)
				LEFT JOIN seRateHistory mode ON main.seRateId = mode.seRateId AND mode.approvedBy IS NULL				
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
					AND main.spFlag = ''' + @spFlag + '''
			) '
				
		SET @table = '(
					SELECT
						 main.seRateId
						,main.baseCurrency
						,baseCurrencyName = bc.currencyCode
						,main.localCurrency
						,localCurrencyName = lc.currencyCode
						,main.sHub
						,sHubName = sh.agentName
						,main.sCountry
						,sCountryName = sc.countryName
						,main.ssAgent
						,ssAgentName = ssa.agentName
						,main.sAgent
						,sAgentName = ISNULL(sa.agentName, ''Any'')
						,main.sBranch
						,sBranchName = ISNULL(sb.agentName, ''Any'')
						,main.rHub
						,rHubName = rh.agentName
						,main.rCountry
						,rCountryName = rc.countryName
						,main.rsAgent
						,rsAgentName = rsa.agentName
						,main.rAgent
						,rAgentName = ISNULL(ra.agentName, ''Any'')
						,main.rBranch
						,rBranchName = ISNULL(rb.agentName, ''Any'')
						,main.state
						,main.zip
						,main.agentGroup
						,main.cost
						,main.margin
						,offer = CASE WHEN main.spFlag = ''S'' THEN CAST(main.cost AS DECIMAL(26, 16)) + CAST(main.margin AS DECIMAL(26, 16)) ELSE
											CAST(main.cost AS DECIMAL(26,16)) - CAST(main.margin AS DECIMAL(26, 16)) END
						,main.agentMargin
						,main.ve
						,main.ne
						,main.effectiveFrom
						,main.effectiveTo
						,main.isEnable
						,main.modifiedBy
						,main.hasChanged					
					FROM ' + @m + ' main		
					LEFT JOIN agentMaster sh WITH(NOLOCK) ON sh.agentId = main.sHub
					LEFT JOIN countryMaster sc WITH(NOLOCK) ON main.sCountry = sc.countryId
					LEFT JOIN agentMaster ssa WITH(NOLOCK) ON ssa.agentId = main.ssAgent
					LEFT JOIN agentMaster sa WITH(NOLOCK) ON sa.agentId = main.sAgent
					LEFT JOIN agentMaster sb WITH(NOLOCK) ON sb.agentId = main.sBranch
					LEFT JOIN agentMaster rh WITH(NOLOCK) ON rh.agentId = main.rHub
					LEFT JOIN countryMaster rc WITH(NOLOCK) ON main.rCountry = rc.countryId
					LEFT JOIN agentMaster rsa WITH(NOLOCK) ON rsa.agentId = main.rsAgent
					LEFT JOIN agentMaster ra WITH(NOLOCK) ON ra.agentId = main.rAgent
					LEFT JOIN agentMaster rb WITH(NOLOCK) ON rb.agentId = main.rBranch					
					LEFT JOIN currencyMaster bc WITH(NOLOCK) ON main.baseCurrency = bc.currencyId
					LEFT JOIN currencyMaster lc WITH(NOLOCK) ON main.localCurrency = lc.currencyId
				) x
			'
		
		--print @table
					
		SET @sql_filter = ''
				
		IF @sHub IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sHub = ' + CAST(@sHub AS VARCHAR(50))
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged + ''''
		
		IF @rHub IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND rHub = ' + CAST(@rHub AS VARCHAR(50))
			
		IF @sCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
		
		IF @ssAgent IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND ssAgent = ' + CAST(@ssAgent AS VARCHAR(50))
				
		IF @sAgent IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND sAgent = ' + CAST(@sAgent AS VARCHAR(50))
			
		IF @sBranch IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND sBranch = ' + CAST(@sBranch AS VARCHAR(50))
			
		IF @rCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
		
		IF @rsAgent IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND rsAgent = ' + CAST(@rsAgent AS VARCHAR(50))
			
		IF @rAgent IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND rAgent = ' + CAST(@rAgent AS VARCHAR(50))
			
		IF @rBranch IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND rBranch = ' + CAST(@rBranch AS VARCHAR(50))
		
		IF @baseCurrency IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND baseCurrency = ' + CAST(@baseCurrency AS VARCHAR(50))
		
		IF @localCurrency IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND localCurrency = ' + CAST(@localCurrency AS VARCHAR(50))
			
		IF @state IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND state = ' + CAST(@state AS VARCHAR(50))
		
		IF @zip IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND zip = ' + CAST(@zip AS VARCHAR(50))
			
		IF @agentGroup IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND agentGroup = ' + CAST(@agentGroup AS VARCHAR(50))
			
		/*
			,@hub                                INT            = NULL
			,@baseCurrency                       INT            = NULL
			,@localCurrency                      INT            = NULL
			,@sCountry                           INT            = NULL
			,@sAgent                             INT            = NULL
			,@sBranch                            INT            = NULL
			,@rCountry                           INT            = NULL
			,@rAgent                             INT            = NULL
			,@rBranch                            INT            = NULL
			,@state                              INT            = NULL
			,@zip                                VARCHAR(20)    = NULL
			,@agentGroup                         INT            = NULL		
		*/
				
		SET @select_field_list = '
				 seRateId
				,baseCurrency
				,baseCurrencyName
				,localCurrency
				,localCurrencyName
				,sHub
				,sHubName
				,sCountry
				,sCountryName
				,ssAgent
				,ssAgentName
				,sAgent
				,sAgentName
				,sBranch
				,sBranchName
				,rHub
				,rHubName
				,rCountry
				,rCountryName
				,rsAgent
				,rsAgentName
				,rAgent
				,rAgentName
				,rBranch
				,rBranchName
				,state
				,zip
				,agentGroup
				,cost
				,margin
				,offer
				,agentMargin
				,ve
				,ne
				,effectiveFrom
				,effectiveTo
				,isEnable
				,modifiedBy
				,hasChanged
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
	ELSE IF @flag = 'i'
	BEGIN	
		IF EXISTS(SELECT 'x' FROM seRate WHERE 
				sHub = @sHub AND
				ssAgent = @ssAgent AND
				sCountry = @sCountry AND 
				ISNULL(sAgent, 0) = ISNULL(@sAgent, 0) AND
				ISNULL(sBranch, 0) = ISNULL(@sBranch, 0) AND
				rHub =@rHub AND
				rsAgent = @rsAgent AND
				rCountry = @rCountry AND
				ISNULL(rAgent, 0) = ISNULL(@rAgent, 0) AND
				ISNULL(rBranch, 0) = ISNULL(@rBranch, 0) AND
				baseCurrency = @baseCurrency AND
				localCurrency = @localCurrency AND
				spFlag = @spFlag AND 
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @seRateId
			RETURN
		END	
		BEGIN TRANSACTION
			INSERT INTO seRate (
				 baseCurrency
				,localCurrency
				,sHub
				,sCountry
				,ssAgent
				,sAgent
				,sBranch
				,rHub
				,rCountry
				,rsAgent
				,rAgent
				,rBranch
				,[state]
				,zip
				,agentGroup
				,cost
				,margin
				,agentMargin
				,ve
				,ne
				,spFlag
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
			)
			SELECT
				 @baseCurrency
				,@localCurrency
				,@sHub
				,@sCountry
				,@ssAgent
				,@sAgent
				,@sBranch
				,@rHub
				,@rCountry
				,@rsAgent
				,@rAgent
				,@rBranch
				,@state
				,@zip
				,@agentGroup
				,@cost
				,@margin
				,@agentMargin
				,@ve
				,@ne
				,@spFlag
				,@effectiveFrom
				,@effectiveTo
				,@isEnable
				,@user
				,GETDATE()
				
				
			SET @seRateId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @seRateId
	END
	
	ELSE IF @flag = 'ci'
	BEGIN
		SELECT @ssAgent = parentId FROM agentMaster WHERE agentId = @sAgent
		SELECT @sHub = parentId FROM agentMaster WHERE agentId = @ssAgent
		SELECT @rsAgent = parentId FROM agentMaster WHERE agentId = @rAgent
		SELECT @rHub = parentId FROM agentMaster WHERE agentId = @rsAgent
		
		IF EXISTS(SELECT 'x' FROM seRate WHERE 
				sHub = @sHub AND
				ssAgent = @ssAgent AND
				sCountry = @sCountry AND 
				ISNULL(sAgent, 0) = ISNULL(@sAgent, 0) AND
				ISNULL(sBranch, 0) = ISNULL(@sBranch, 0) AND
				rHub =@rHub AND
				rsAgent = @rsAgent AND
				rCountry = @rCountry AND
				ISNULL(rAgent, 0) = ISNULL(@rAgent, 0) AND
				ISNULL(rBranch, 0) = ISNULL(@rBranch, 0) AND
				spFlag = @spFlag AND 
				ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			SELECT @seRateId = seRateId FROM seRate WHERE
				sHub = @sHub AND
				ssAgent = @ssAgent AND
				sCountry = @sCountry AND 
				ISNULL(sAgent, 0) = ISNULL(@sAgent, 0) AND
				ISNULL(sBranch, 0) = ISNULL(@sBranch, 0) AND
				rHub =@rHub AND
				rsAgent = @rsAgent AND
				rCountry = @rCountry AND
				ISNULL(rAgent, 0) = ISNULL(@rAgent, 0) AND
				ISNULL(rBranch, 0) = ISNULL(@rBranch, 0) AND
				spFlag = @spFlag AND 
				ISNULL(isDeleted,'N')<>'Y'
				
				INSERT INTO seRateHistory(						
						 seRateId
						,baseCurrency
						,localCurrency
						,sHub
						,sCountry
						,ssAgent
						,sAgent
						,sBranch
						,rHub
						,rCountry
						,rsAgent
						,rAgent
						,rBranch
						,[state]
						,zip
						,agentGroup
						,cost
						,margin
						,agentMargin
						,ve
						,ne
						,spFlag
						,effectiveFrom
						,effectiveTo
						,isEnable
						,createdBy
						,createdDate
						,modType
				)
				SELECT
						 @seRateId		
						,@baseCurrency
						,@localCurrency
						,@sHub
						,@sCountry
						,@ssAgent
						,@sAgent
						,@sBranch
						,@rHub
						,@rCountry
						,@rsAgent
						,@rAgent
						,@rBranch
						,@state
						,@zip
						,@agentGroup
						,@cost
						,@margin
						,@agentMargin
						,@ve
						,@ne
						,@spFlag
						,@effectiveFrom
						,@effectiveTo
						,@isEnable
						,@user
						,GETDATE()
						,'U'

			--UPDATE seRate SET
			--		 sHub = @sHub
			--		,sCountry = @sCountry
			--		,ssAgent = @ssAgent
			--		,sAgent = @sAgent
			--		,sBranch = @sBranch
			--		,rHub = @rHub
			--		,rCountry = @rCountry
			--		,rsAgent = @rsAgent
			--		,rAgent = @rAgent
			--		,rBranch = @rBranch
			--		,cost = @cost
			--		,margin = @margin
			--		,agentMargin = @agentMargin
			--		,spFlag = @spFlag
			--		,modifiedBy = @user
			--		,modifiedDate = GETDATE()				
			--	WHERE sHub = @sHub AND 
			--		sCountry = @sCountry AND
			--		ssAgent = @ssAgent AND
			--		ISNULL(sAgent, 0) = ISNULL(@sAgent, 0) AND
			--		ISNULL(sBranch, 0) = ISNULL(@sBranch, 0) AND
			--		rHub = @rHub AND
			--		rCountry = @rCountry AND
			--		rsAgent = @rsAgent AND
			--		ISNULL(rAgent, 0) = ISNULL(@rAgent, 0) AND
			--		ISNULL(rBranch, 0) = ISNULL(@rBranch, 0) AND
			--		spFlag = @spFlag	
					
			EXEC proc_errorHandler 0, 'Record has been updated successfully.', @seRateId
		END	
		ELSE
		BEGIN
			BEGIN TRANSACTION
				INSERT INTO seRate (
					 baseCurrency
					,localCurrency
					,sHub
					,sCountry
					,ssAgent
					,sAgent
					,sBranch
					,rHub
					,rCountry
					,rsAgent
					,rAgent
					,rBranch
					,[state]
					,zip
					,agentGroup
					,cost
					,margin
					,agentMargin
					,ve
					,ne
					,spFlag
					,effectiveFrom
					,effectiveTo
					,isEnable
					,createdBy
					,createdDate
				)
				SELECT
					 @baseCurrency
					,@localCurrency
					,@sHub
					,@sCountry
					,@ssAgent
					,@sAgent
					,@sBranch
					,@rHub
					,@rCountry
					,@rsAgent
					,@rAgent
					,@rBranch
					,@state
					,@zip
					,@agentGroup
					,@cost
					,@margin
					,@agentMargin
					,@ve
					,@ne
					,@spFlag
					,@effectiveFrom
					,@effectiveTo
					,@isEnable
					,@user
					,GETDATE()
					
					
				SET @seRateId = SCOPE_IDENTITY()
				
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been updated successfully.', @seRateId
		END
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM seRateHistory WITH(NOLOCK)
				WHERE seRateId = @seRateId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				 mode.*
				,CONVERT(VARCHAR, mode.effectiveFrom, 101) effFrom
				,CONVERT(VARCHAR, mode.effectiveTo, 101) effTo
			FROM seRateHistory mode WITH(NOLOCK)
			INNER JOIN seRate main WITH(NOLOCK) ON mode.seRateId = main.seRateId
			WHERE mode.seRateId= @seRateId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				 * 
				,CONVERT(VARCHAR, effectiveFrom, 101) effFrom
				,CONVERT(VARCHAR, effectiveTo, 101) effTo
			FROM seRate WITH(NOLOCK) WHERE seRateId = @seRateId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM seRate WITH(NOLOCK)
			WHERE seRateId = @seRateId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @seRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM seRateHistory WITH(NOLOCK)
			WHERE seRateId  = @seRateId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @seRateId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM seRate WHERE approvedBy IS NULL AND seRateId  = @seRateId)			
			BEGIN				
				UPDATE seRate SET
					 baseCurrency = @baseCurrency
					,localCurrency = @localCurrency
					,sHub = @sHub
					,sCountry = @sCountry
					,ssAgent = @ssAgent
					,sAgent = @sAgent
					,sBranch = @sBranch
					,rHub = @rHub
					,rCountry = @rCountry
					,rsAgent = @rsAgent
					,rAgent = @rAgent
					,rBranch = @rBranch
					,[state] = @state
					,zip = @zip
					,agentGroup = @agentGroup
					,cost = @cost
					,margin = @margin
					,agentMargin = @agentMargin
					,ve = @ve
					,ne = @ne
					,spFlag = @spFlag
					,effectiveFrom = @effectiveFrom
					,effectiveTo = @effectiveTo
					,isEnable = @isEnable
					,modifiedBy = @user
					,modifiedDate = GETDATE()				
				WHERE seRateId = @seRateId			
			END
			ELSE
			BEGIN
				DELETE FROM seRateHistory WHERE seRateId = @seRateId AND approvedBy IS NULL
				INSERT INTO seRateHistory(						
						 seRateId
						,baseCurrency
						,localCurrency
						,sHub
						,sCountry
						,ssAgent
						,sAgent
						,sBranch
						,rHub
						,rCountry
						,rsAgent
						,rAgent
						,rBranch
						,[state]
						,zip
						,agentGroup
						,cost
						,margin
						,agentMargin
						,ve
						,ne
						,spFlag
						,effectiveFrom
						,effectiveTo
						,isEnable
						,createdBy
						,createdDate
						,modType
				)
				SELECT
						 @seRateId		
						,@baseCurrency
						,@localCurrency
						,@sHub
						,@sCountry
						,@ssAgent
						,@sAgent
						,@sBranch
						,@rHub
						,@rCountry
						,@rsAgent
						,@rAgent
						,@rBranch
						,@state
						,@zip
						,@agentGroup
						,@cost
						,@margin
						,@agentMargin
						,@ve
						,@ne
						,@spFlag
						,@effectiveFrom
						,@effectiveTo
						,@isEnable
						,@user
						,GETDATE()
						,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @seRateId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM seRate WITH(NOLOCK)
			WHERE seRateId = @seRateId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @seRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM seRateHistory  WITH(NOLOCK)
			WHERE seRateId = @seRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @seRateId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM seRate WITH(NOLOCK) WHERE seRateId = @seRateId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM seRate WHERE seRateId = @seRateId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @seRateId
			RETURN
		END
			INSERT INTO seRateHistory(
				 seRateId
				,baseCurrency
				,localCurrency
				,sHub
				,sCountry
				,ssAgent
				,sAgent
				,sBranch
				,rHub
				,rCountry
				,rsAgent
				,rAgent
				,rBranch
				,[state]
				,zip
				,agentGroup
				,cost
				,margin
				,agentMargin
				,ve
				,ne
				,spFlag
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 seRateId
				,baseCurrency
				,localCurrency
				,sHub
				,sCountry
				,ssAgent
				,sAgent
				,sBranch
				,rHub
				,rCountry
				,rsAgent
				,rAgent
				,rBranch
				,[state]
				,zip
				,agentGroup
				,cost
				,margin
				,agentMargin
				,ve
				,ne
				,spFlag
				,effectiveFrom
				,effectiveTo
				,isEnable				
				,@user
				,GETDATE()
				,'D'
			FROM seRate WHERE seRateId = @seRateId			

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @seRateId
	END
	
	ELSE IF @flag IN('reject')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM seRate WITH(NOLOCK)
			WHERE seRateId = @seRateId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM seRate WITH(NOLOCK)
			WHERE seRateId = @seRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @seRateId
			RETURN
		END
		BEGIN TRANSACTION
		IF EXISTS (SELECT 'X' FROM seRate WHERE approvedBy IS NULL AND seRateId = @seRateId)
		BEGIN --New record			
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @seRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @seRateId, @user, @oldValue, @newValue
								
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @seRateId
					RETURN
				END
			DELETE FROM seRate WHERE seRateId =  @seRateId
			
		END
		ELSE
		BEGIN
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @seRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @seRateId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @seRateId
					RETURN
				END
				DELETE FROM seRateHistory WHERE seRateId = @seRateId AND approvedBy IS NULL
			
		END		
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @seRateId
	END

	ELSE IF @flag  IN ('approve')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM seRate WITH(NOLOCK)
			WHERE seRateId = @seRateId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM seRate WITH(NOLOCK)
			WHERE seRateId = @seRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @seRateId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM seRate WHERE approvedBy IS NULL AND seRateId = @seRateId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM seRateHistory WHERE seRateId = @seRateId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE seRate SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE seRateId = @seRateId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @seRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @seRateId, @oldValue OUTPUT
				UPDATE main SET
					 main.baseCurrency = mode.baseCurrency
					,main.localCurrency = mode.localCurrency
					,main.sHub = mode.sHub
					,main.sCountry = mode.sCountry
					,main.ssAgent = mode.ssAgent
					,main.sAgent = mode.sAgent
					,main.sBranch = mode.sBranch
					,main.rHub = mode.rHub
					,main.rCountry = mode.rCountry
					,main.rsAgent = mode.rsAgent
					,main.rAgent = mode.rAgent
					,main.rBranch = mode.rBranch
					,main.[state] = mode.[state]
					,main.zip = mode.zip
					,main.agentGroup = mode.agentGroup
					,main.cost = mode.cost
					,main.margin = mode.margin
					,main.agentMargin = mode.agentMargin
					,main.ve = mode.ve
					,main.ne = mode.ne
					,main.effectiveFrom = mode.effectiveFrom
					,main.effectiveTo = mode.effectiveTo
					,main.isEnable = mode.isEnable
					,main.modifiedBy = @user
					,main.modifiedDate = GETDATE()
				FROM seRate main
				INNER JOIN seRateHistory mode ON mode.seRateId = main.seRateId
				WHERE mode.seRateId = @seRateId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'seRate', 'seRateId', @seRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @seRateId, @oldValue OUTPUT
				UPDATE seRate SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE seRateId = @seRateId
			END
			
			UPDATE seRateHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE seRateId = @seRateId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @seRateId, @user, @oldValue, @newValue
			
			
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @seRateId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @seRateId
END CATCH



GO
