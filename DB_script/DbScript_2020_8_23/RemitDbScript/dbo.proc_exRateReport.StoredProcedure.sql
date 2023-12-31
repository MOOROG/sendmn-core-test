USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_exRateReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_exRateTreasury]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_exRateTreasury
GO
*/
/*
	proc_spExRate @flag = 's', @user = 'admin', @sortBy = 'exRateTreasuryId', @sortOrder = 'ASC', @pageSize = '10', @pageNumber = '1'
*/
CREATE proc [dbo].[proc_exRateReport]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@exRateTreasuryId					VARCHAR(30)		= NULL
	,@hasChanged                        CHAR(1)			= NULL
	,@currency							VARCHAR(3)		= NULL
	,@country							INT				= NULL
	,@agent								INT				= NULL
	,@rateType							CHAR(1)			= NULL
	,@cCurrency							VARCHAR(3)		= NULL
	,@cAgent							INT				= NULL
	,@cBranch							INT				= NULL
	,@cCountry							INT				= NULL
	,@cCountryName						VARCHAR(100)	= NULL
	,@cAgentName						VARCHAR(100)	= NULL
	,@pCurrency							VARCHAR(3)		= NULL
	,@pAgent							INT				= NULL
	,@pCountry							INT				= NULL
	,@pCountryName						VARCHAR(100)	= NULL
	,@pAgentName						VARCHAR(100)	= NULL
	,@tranType							INT				= NULL
	,@isActive							CHAR(1)			= NULL
	,@isUpdated							CHAR(1)			= NULL
	,@filterByPCountryOnly				CHAR(1)			= NULL
	,@fromDate							VARCHAR(50)		= NULL
	,@toDate							VARCHAR(50)		= NULL
	,@sortBy                            VARCHAR(100)	= NULL
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
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	
	
	DECLARE @exRateHistoryId BIGINT, @date DATETIME = GETDATE()
	DECLARE @rateIdList TABLE(rowId INT IDENTITY(1,1), exRateTreasuryId INT)	
	DECLARE @crossRateDecimalMask INT, @colMaskAd INT
	SELECT
		 @logIdentifier = 'exRateTreasuryId'
		,@logParamMain = 'exRateTreasury'
		,@logParamMod = 'exRateTreasuryHistory'
		,@module = '20'
		,@tableAlias = 'Treasury Exchange Rate'
	
	IF @flag = 'r'					--Get Report
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cCountryName,cAgentName,pCountryName,cBranchName,pAgentName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'pCountryName,cBranchName,pAgentName,cCountryName,cAgentName'
		SET @sortOrder = ''
		
		IF @cBranch IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..##tmpXRate') IS NOT NULL
				DROP TABLE ##tmpXRate
	
			SELECT
				 main.exRateTreasuryId	
				,tranType = ISNULL(tt.typeTitle, 'Any')
				,main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,main.cAgent
				,cAgentName = ISNULL(cam.agentName, '[All]')
				,cBranch = @cBranch
				,cBranchName = (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch)
				,main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,main.pAgent
				,pAgentName = ISNULL(pam.agentName, '[All]')
				,main.cCurrency
				,main.pCurrency
				,main.cRateFactor
				,main.pRateFactor
				,main.cRate
				,cMargin = ISNULL(main.cMargin, 0)
				,cHoMargin = ISNULL(main.cHoMargin, 0)
				,cAgentMargin = ISNULL(cAgentMargin, 0)
				,main.pRate
				,pMargin = ISNULL(main.pMargin, 0)
				,pHoMargin = ISNULL(main.pHoMargin, 0)
				,pAgentMargin = ISNULL(main.pAgentMargin, 0)
				,sharingType
				,sharingValue = ISNULL(main.sharingValue, 0)
				,toleranceOn
				,agentTolMin = ISNULL(main.agentTolMin, 0)
				,agentTolMax = ISNULL(main.agentTolMax, 0)
				,customerTolMin = ISNULL(main.customerTolMin, 0)
				,customerTolMax = ISNULL(main.customerTolMax, 0)
				,main.maxCrossRate
				,main.crossRate
				,customerRate = ISNULL(main.crossRateOperation, main.customerRate)
				,main.tolerance
				,premium = main.premium
				,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
				,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
				,main.crossRateFactor
				,main.isUpdated		
				,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedByOperation ELSE
									ISNULL(main.modifiedBy,main.createdBy) END
				,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedDateOperation ELSE
									ISNULL(main.modifiedDate,main.createdDate) END
				,main.approvedBy
				,main.approvedDate
			INTO ##tmpXRate
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
			WHERE cCountry = 133 AND cAgent = @cAgent AND main.approvedBy IS NOT NULL AND ISNULL(main.isActive, 'N') = 'Y'
			ORDER BY pCountryName, pAgentName
			
			UPDATE tmp SET
				 tmp.premium = erbw.premium
				,tmp.modifiedBy = erbw.modifiedBy
				,tmp.modifiedDate = erbw.modifiedDate
				,tmp.approvedBy = erbw.modifiedBy
				,tmp.approvedDate = erbw.modifiedDate
			FROM ##tmpXRate tmp
			INNER JOIN exRateBranchWise erbw ON tmp.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @cBranch AND ISNULL(erbw.isActive, 'N') = 'Y'
			
			SET @table = '(
						SELECT * FROM ##tmpXRate
						)x
					'
		END
		ELSE
		BEGIN
		--SELECT * FROM exRateBranchWise
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = NULL
							,cBranchName = ''[All]''
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,main.maxCrossRate
							,main.crossRate
							,main.customerRate
							,main.tolerance
							,premium = main.premium
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedByOperation ELSE
												ISNULL(main.modifiedBy,main.createdBy) END
							,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedDateOperation ELSE
												ISNULL(main.modifiedDate,main.createdDate) END
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE ISNULL(main.isActive, ''N'') = ''Y''
						'
		/*	
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,main.maxCrossRate
							,main.crossRate
							,main.customerRate
							,main.tolerance
							,main.premium
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = ISNULL(main.modifiedBy,main.createdBy)
							,modifiedDate = ISNULL(main.modifiedDate,main.createdDate)
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE 1 = 1
						
						'
		*/		
		
		SET @table =  @table + ') x'
		END	
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,cMargin
			,cHoMargin
			,cAgentMargin
			,pRate
			,pMargin
			,pHoMargin
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,maxCrossRate
			,crossRate
			,customerRate
			,tolerance
			,premium
			,cost
			,margin
			,crossRateFactor
			,isUpdated
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
			'
		--PRINT @table	
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
		
		IF OBJECT_ID('tempdb..##tmpXRate') IS NOT NULL
			DROP TABLE ##tmpXRate
	END
	
	ELSE IF @flag = 'or'			--Get Operation Report
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cBranchName,pCountryName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'cBranchName,pCountryName'
		SET @sortOrder = ''
		
		IF @cBranch IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..##tmpRate') IS NOT NULL
				DROP TABLE ##tmpRate
	
			SELECT
				 main.exRateTreasuryId	
				,tranType = ISNULL(tt.typeTitle, 'Any')
				,main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,main.cAgent
				,cAgentName = ISNULL(cam.agentName, '[All]')
				,cBranch = @cBranch
				,cBranchName = (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch)
				,main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,main.pAgent
				,pAgentName = ISNULL(pam.agentName, '[All]')
				,main.cCurrency
				,main.pCurrency
				,main.cRateFactor
				,main.pRateFactor
				,main.cRate
				,cMargin = ISNULL(main.cMargin, 0)
				,cHoMargin = ISNULL(main.cHoMargin, 0)
				,cAgentMargin = ISNULL(cAgentMargin, 0)
				,main.pRate
				,pMargin = ISNULL(main.pMargin, 0)
				,pHoMargin = ISNULL(main.pHoMargin, 0)
				,pAgentMargin = ISNULL(main.pAgentMargin, 0)
				,sharingType
				,sharingValue = ISNULL(main.sharingValue, 0)
				,toleranceOn
				,agentTolMin = ISNULL(main.agentTolMin, 0)
				,agentTolMax = ISNULL(main.agentTolMax, 0)
				,customerTolMin = ISNULL(main.customerTolMin, 0)
				,customerTolMax = ISNULL(main.customerTolMax, 0)
				,main.maxCrossRate
				,main.crossRate
				,customerRate = ISNULL(main.crossRateOperation, main.customerRate)
				,tolerance = ISNULL(main.toleranceOperation, main.tolerance)
				,premium = main.premium
				,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
				,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
				,main.crossRateFactor
				,main.isUpdated		
				,modifiedBy = ISNULL(main.modifiedByOperation, main.approvedBy)
				,modifiedDate = ISNULL(main.modifiedDateOperation, main.approvedDate)
				,approvedBy = main.modifiedByOperation
				,approvedDate = main.modifiedDateOperation
			INTO ##tmpRate
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
			WHERE cCountry = 133 AND cAgent = dbo.FNAGetIMEAgentId() AND main.approvedBy IS NOT NULL AND ISNULL(main.isActive, 'N') = 'Y'
			ORDER BY pCountryName, pAgentName
			
			UPDATE tmp SET
				 tmp.premium = erbw.premium
				,tmp.modifiedBy = erbw.modifiedBy
				,tmp.modifiedDate = erbw.modifiedDate
				,tmp.approvedBy = erbw.modifiedBy
				,tmp.approvedDate = erbw.modifiedDate
			FROM ##tmpRate tmp
			INNER JOIN exRateBranchWise erbw ON tmp.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @cBranch AND ISNULL(erbw.isActive, 'N') = 'Y'
			
			SET @table = '(
						SELECT * FROM ##tmpRate
						)x
					'
		END
		ELSE
		BEGIN		
		--SELECT * FROM exRateBranchWise
			SET @table = '(
							SELECT
								 main.exRateTreasuryId	
								,tranType = ISNULL(tt.typeTitle, ''Any'')
								,main.cCountry
								,cCountryName = cc.countryName
								,cCountryCode = cc.countryCode
								,main.cAgent
								,cAgentName = ISNULL(cam.agentName, ''[All]'')
								,cBranch = NULL
								,cBranchName = ''[All]''
								,main.pCountry
								,pCountryName = pc.countryName
								,pCountryCode = pc.countryCode
								,main.pAgent
								,pAgentName = ISNULL(pam.agentName, ''[All]'')
								,main.cCurrency
								,main.pCurrency
								,main.cRateFactor
								,main.pRateFactor
								,main.cRate
								,cMargin = ISNULL(main.cMargin, 0)
								,cHoMargin = ISNULL(main.cHoMargin, 0)
								,cAgentMargin = ISNULL(cAgentMargin, 0)
								,main.pRate
								,pMargin = ISNULL(main.pMargin, 0)
								,pHoMargin = ISNULL(main.pHoMargin, 0)
								,pAgentMargin = ISNULL(main.pAgentMargin, 0)
								,sharingType
								,sharingValue = ISNULL(main.sharingValue, 0)
								,toleranceOn
								,agentTolMin = ISNULL(main.agentTolMin, 0)
								,agentTolMax = ISNULL(main.agentTolMax, 0)
								,customerTolMin = ISNULL(main.customerTolMin, 0)
								,customerTolMax = ISNULL(main.customerTolMax, 0)
								,main.maxCrossRate
								,main.crossRate
								,main.customerRate
								,main.tolerance
								,premium = main.premium
								,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
								,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
								,main.crossRateFactor
								,main.isUpdated		
								,modifiedBy = ISNULL(main.modifiedByOperation, main.approvedBy)
								,modifiedDate = ISNULL(main.modifiedDateOperation, main.approvedDate)
								,approvedBy = main.modifiedByOperation
								,approvedDate = main.modifiedDateOperation
							FROM exRateTreasury main WITH(NOLOCK)
							LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
							LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
							LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
							LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
							LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
							LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
							WHERE ISNULL(main.isActive, ''N'') = ''Y''
							'
			/*	
			SET @table = '(
							SELECT
								 main.exRateTreasuryId	
								,tranType = ISNULL(tt.typeTitle, ''Any'')
								,main.cCountry
								,cCountryName = cc.countryName
								,cCountryCode = cc.countryCode
								,main.cAgent
								,cAgentName = ISNULL(cam.agentName, ''[All]'')
								,main.pCountry
								,pCountryName = pc.countryName
								,pCountryCode = pc.countryCode
								,main.pAgent
								,pAgentName = ISNULL(pam.agentName, ''[All]'')
								,main.cCurrency
								,main.pCurrency
								,main.cRateFactor
								,main.pRateFactor
								,main.cRate
								,cMargin = ISNULL(main.cMargin, 0)
								,cHoMargin = ISNULL(main.cHoMargin, 0)
								,cAgentMargin = ISNULL(cAgentMargin, 0)
								,main.pRate
								,pMargin = ISNULL(main.pMargin, 0)
								,pHoMargin = ISNULL(main.pHoMargin, 0)
								,pAgentMargin = ISNULL(main.pAgentMargin, 0)
								,sharingType
								,sharingValue = ISNULL(main.sharingValue, 0)
								,toleranceOn
								,agentTolMin = ISNULL(main.agentTolMin, 0)
								,agentTolMax = ISNULL(main.agentTolMax, 0)
								,customerTolMin = ISNULL(main.customerTolMin, 0)
								,customerTolMax = ISNULL(main.customerTolMax, 0)
								,main.maxCrossRate
								,main.crossRate
								,main.customerRate
								,main.tolerance
								,main.premium
								,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
								,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)		
								,main.crossRateFactor
								,main.isUpdated		
								,modifiedBy = ISNULL(main.modifiedBy,main.createdBy)
								,modifiedDate = ISNULL(main.modifiedDate,main.createdDate)
								,main.approvedBy
								,main.approvedDate
							FROM exRateTreasury main WITH(NOLOCK)
							LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
							LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
							LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
							LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
							LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
							LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
							WHERE 1 = 1
							
							'
			*/
							
			SET @table =  @table + ') x'
		END
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,cMargin
			,cHoMargin
			,cAgentMargin
			,pRate
			,pMargin
			,pHoMargin
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,maxCrossRate
			,crossRate
			,customerRate
			,tolerance
			,premium
			,cost
			,margin
			,crossRateFactor
			,isUpdated
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
			'
		--PRINT @table	
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
		
		IF OBJECT_ID('tempdb..##tmpRate') IS NOT NULL
			DROP TABLE ##tmpRate
	END
	
	ELSE IF @flag = 'forex'			--Get FOREX Report
	BEGIN
		--IF @sortBy = 'sendingCountry'
			SET @sortBy = 'pCountryName,cBranchName,pAgentName'
		--ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'pCountryName,cBranchName,pAgentName'
		SET @sortOrder = ''
		
		IF @cBranch IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..##tmpForexRate') IS NOT NULL
				DROP TABLE ##tmpForexRate
	
			SELECT
				 main.exRateTreasuryId	
				,tranType = ISNULL(tt.typeTitle, 'Any')
				,main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,main.cAgent
				,cAgentName = ISNULL(cam.agentName, '[All]')
				,cBranch = @cBranch
				,cBranchName = (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch)
				,main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,main.pAgent
				,pAgentName = ISNULL(pam.agentName, '[All]')
				,main.cCurrency
				,main.pCurrency
				,main.cRateFactor
				,main.pRateFactor
				,main.cRate
				,cOffer = main.cRate + ISNULL(main.cMargin, 0) + ISNULL(main.cHoMargin, 0)
				,cMargin = ISNULL(main.cMargin, 0)
				,cHoMargin = ISNULL(main.cHoMargin, 0)
				,cAgentMargin = ISNULL(cAgentMargin, 0)
				,main.pRate
				,pOffer = main.pRate - ISNULL(main.pMargin, 0) - ISNULL(main.pAgentMargin, 0)
				,pMargin = ISNULL(main.pMargin, 0)
				,pHoMargin = ISNULL(main.pHoMargin, 0)
				,pAgentMargin = ISNULL(main.pAgentMargin, 0)
				,sharingType
				,sharingValue = ISNULL(main.sharingValue, 0)
				,toleranceOn
				,agentTolMin = ISNULL(main.agentTolMin, 0)
				,agentTolMax = ISNULL(main.agentTolMax, 0)
				,customerTolMin = ISNULL(main.customerTolMin, 0)
				,customerTolMax = ISNULL(main.customerTolMax, 0)
				,main.maxCrossRate
				,crossRate = main.maxCrossRate
				,main.crossRateOperation
				,customerRate = ISNULL(main.crossRateOperation, main.customerRate) + main.premium
				,main.tolerance
				,premium = main.premium
				,cost = ISNULL(ROUND(pRate/(ISNULL(main.crossRateOperation, main.customerRate) + ISNULL(premium, 0)), crm.rateMaskMulAd), 0)
				,margin = ISNULL(ROUND(pRate/(ISNULL(main.crossRateOperation, main.customerRate) + ISNULL(premium, 0)) - cRate, crm.rateMaskMulAd), 0)		
				,main.crossRateFactor
				,main.isUpdated		
				,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedByOperation ELSE
									ISNULL(main.modifiedBy,main.createdBy) END
				,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedDateOperation ELSE
									ISNULL(main.modifiedDate,main.createdDate) END
				,main.approvedBy
				,main.approvedDate
				,rateMaskMulAd
			INTO ##tmpForexRate
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
			WHERE cCountry = 133 AND cAgent = @cAgent AND main.approvedBy IS NOT NULL AND ISNULL(main.isActive, 'N') = 'Y'
			ORDER BY pCountryName, pAgentName
			
			UPDATE tmp SET
				 tmp.premium		= erbw.premium
				,tmp.customerRate	= tmp.crossRateOperation + erbw.premium
				,tmp.cost			= ROUND(tmp.pRate/(tmp.crossRateOperation + ISNULL(erbw.premium, 0)), tmp.rateMaskMulAd)
				,tmp.margin			= ROUND(tmp.pRate/(tmp.crossRateOperation + ISNULL(erbw.premium, 0)) - tmp.cRate, tmp.rateMaskMulAd)	
				,tmp.modifiedBy		= erbw.modifiedBy
				,tmp.modifiedDate	= erbw.modifiedDate
				,tmp.approvedBy		= erbw.modifiedBy
				,tmp.approvedDate	= erbw.modifiedDate
			FROM ##tmpForexRate tmp
			INNER JOIN exRateBranchWise erbw ON tmp.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @cBranch AND ISNULL(erbw.isActive, 'N') = 'Y'
			
			SET @table = '(
						SELECT * FROM ##tmpForexRate
						)x
					'
		END
		ELSE
		BEGIN
		--SELECT * FROM exRateBranchWise
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = NULL
							,cBranchName = ''[All]''
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cOffer = main.cRate + ISNULL(main.cMargin, 0) + ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pOffer = main.pRate - ISNULL(main.pMargin, 0) - ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,crossRate = main.maxCrossRate
							,main.tolerance
							,premium = ISNULL(main.premium, 0)
							,customerRate = ROUND(main.crossRateOperation + main.premium, 10)
							,cost = ISNULL(ROUND(pRate/(crossRateOperation + ISNULL(main.premium, 0)), crm.rateMaskMulAd), 0)
							,margin = ISNULL(ROUND(pRate/(crossRateOperation + ISNULL(main.premium, 0)) - cRate, crm.rateMaskMulAd), 0)		
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedByOperation ELSE
												ISNULL(main.modifiedBy,main.createdBy) END
							,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedDateOperation ELSE
												ISNULL(main.modifiedDate,main.createdDate) END
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE ISNULL(main.isActive, ''N'') = ''Y''
						
						UNION ALL
						
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = erbw.cBranch
							,cBranchName = bm.agentName
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cOffer = main.cRate + ISNULL(main.cMargin, 0) + ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pOffer = main.pRate - ISNULL(main.pMargin, 0) - ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,crossRate = main.maxCrossRate
							,main.tolerance
							,premium = ISNULL(erbw.premium, 0)
							,customerRate = ROUND(main.crossRateOperation + ISNULL(erbw.premium, 0), 10)
							,cost = ROUND(pRate/(crossRateOperation + ISNULL(erbw.premium, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRateOperation + ISNULL(erbw.premium, 0)) - cRate, crm.rateMaskMulAd)
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedByOperation ELSE
												ISNULL(main.modifiedBy,main.createdBy) END
							,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedDateOperation ELSE
												ISNULL(main.modifiedDate,main.createdDate) END
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						INNER JOIN exRateBranchWise erbw WITH(NOLOCK) ON main.exRateTreasuryId = erbw.exRateTreasuryId AND ISNULL(erbw.isActive, ''N'') = ''Y''
						INNER JOIN agentMaster bm WITH(NOLOCK) ON erbw.cBranch = bm.agentId
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE ISNULL(main.isActive, ''N'') = ''Y''
						'
		SET @table =  @table + ') x'
		END	
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''

		IF @pCountry IS NOT NULL
		BEGIN
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
			IF ISNULL(@filterByPCountryOnly, 'N') = 'Y'
				SET @sql_filter = @sql_filter + ' AND pAgent = 0'
		END
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,cOffer
			,cAgentMargin
			,pRate
			,pOffer
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,crossRate
			,customerRate
			,tolerance
			,premium
			,cost
			,margin
			,crossRateFactor
			,isUpdated
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
			'
		--PRINT @table	
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
		
		IF OBJECT_ID('tempdb..##tmpForexRate') IS NOT NULL
			DROP TABLE ##tmpForexRate
	END
	
	ELSE IF @flag = 'forexIrh'
	BEGIN
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'cCountryName,cAgentName,pCountryName,pAgentName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'pCountryName,pAgentName,cCountryName,cAgentName'
		SET @sortOrder = ''
		
		--SELECT * FROM exRateBranchWise
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,cAgent = ISNULL(main.cAgent, 0)
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = NULL
							,cBranchName = ''[All]''
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,pAgent = ISNULL(main.pAgent, 0)
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,main.maxCrossRate
							,main.crossRate
							,main.customerRate
							,main.tolerance
							,premium = ISNULL(main.premium, 0)
							,hoGain = CAST(ROUND(((pRate/(cRate + cMargin + cHoMargin)) - crossRate), 8) AS DECIMAL(14, 6))
							,agentGain = CAST(ROUND(((pRate - pMargin - pHoMargin)/(cRate + cMargin + cHoMargin)) - customerRate, 8) AS DECIMAL(14, 6))
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)
							,main.crossRateFactor	
							,status = CASE WHEN ISNULL(main.isActive, ''N'') = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,modifiedBy = main.createdBy
							,modifiedDate = main.createdDate
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE 1 = 1
						'	
		SET @table =  @table + ') x'
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
		BEGIN
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
			IF ISNULL(@filterByPCountryOnly, 'N') = 'Y'
				SET @sql_filter = @sql_filter + ' AND pAgent = 0'
		END
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,cMargin
			,cHoMargin
			,cAgentMargin
			,pRate
			,pMargin
			,pHoMargin
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,maxCrossRate
			,crossRate
			,customerRate
			,tolerance
			,premium
			,hoGain
			,agentGain
			,cost
			,margin
			,crossRateFactor
			,status
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
			'
		--PRINT @table	
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
	
	ELSE IF @flag = 'historyIRH'
	BEGIN
		
		IF @sortBy = 'sendingCountry'
			SET @sortBy = 'modifiedDate DESC,cCountryName,cAgentName,pCountryName,cBranchName,pAgentName'
		ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'modifiedDate DESC,pCountryName,cBranchName,pAgentName,cCountryName,cAgentName'
		SET @sortOrder = ''
		
		if @fromDate is null
		begin
			set @fromDate = '2013-10-23'
			set @toDate = '2013-10-23'
		end
		SET @toDate = @toDate + ' 23:59:59:998'
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,cAgent = ISNULL(main.cAgent, 0)
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = NULL
							,cBranchName = ''[All]''
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,pAgent = ISNULL(main.pAgent, 0)
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cMargin = ISNULL(main.cMargin, 0)
							,cHoMargin = ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pMargin = ISNULL(main.pMargin, 0)
							,pHoMargin = ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,maxCrossRate = ISNULL(main.maxCrossRate, 0)
							,crossRate = ISNULL(main.crossRate, 0)
							,customerRate = ISNULL(main.customerRate, 0)
							,tolerance = ISNULL(main.tolerance, 0)
							,premium = ISNULL(main.premium, 0)
							,cost = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRate + ISNULL(tolerance, 0)) - cRate, crm.rateMaskMulAd)
							,main.crossRateFactor	
							,status = CASE WHEN ISNULL(main.isActive, ''N'') = ''Y'' THEN ''Active'' ELSE ''Inactive'' END
							,modifiedBy = main.createdBy
							,modifiedDate = main.createdDate
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasuryHistory main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE 1 = 1 AND main.createdDate BETWEEN ''' + @fromDate + ''' AND ''' + @toDate + '''
						'	
		SET @table =  @table + ') x'
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''			

		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
			
		IF @pCountry IS NOT NULL
		BEGIN
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
			IF ISNULL(@filterByPCountryOnly, 'N') = 'Y'
				SET @sql_filter = @sql_filter + ' AND pAgent = 0'
		END
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,cMargin
			,cHoMargin
			,cAgentMargin
			,pRate
			,pMargin
			,pHoMargin
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,maxCrossRate
			,crossRate
			,customerRate
			,tolerance
			,premium
			,cost
			,margin
			,crossRateFactor
			,status
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
			'
		--PRINT @table	
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
	
	ELSE IF @flag = 'exRateRegional'
	BEGIN
		--IF @sortBy = 'sendingCountry'
			SET @sortBy = 'pCountryName,cBranchName,pAgentName'
		--ELSE IF @sortBy = 'receivingCountry'
			SET @sortBy = 'cBranchName,pCountryName,pAgentName,cCountryName,cAgentName'
		SET @sortOrder = ''
		
		IF @cBranch IS NOT NULL
		BEGIN
			IF OBJECT_ID('tempdb..##tmpExRateRegional') IS NOT NULL
				DROP TABLE ##tmpExRateRegional
	
			SELECT
				 main.exRateTreasuryId	
				,tranType = ISNULL(tt.typeTitle, 'Any')
				,main.cCountry
				,cCountryName = cc.countryName
				,cCountryCode = cc.countryCode
				,main.cAgent
				,cAgentName = ISNULL(cam.agentName, '[All]')
				,cBranch = @cBranch
				,cBranchName = (SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @cBranch)
				,main.pCountry
				,pCountryName = pc.countryName
				,pCountryCode = pc.countryCode
				,main.pAgent
				,pAgentName = ISNULL(pam.agentName, '[All]')
				,main.cCurrency
				,main.pCurrency
				,main.cRateFactor
				,main.pRateFactor
				,main.cRate
				,cOffer = main.cRate + ISNULL(main.cMargin, 0) + ISNULL(main.cHoMargin, 0)
				,cMargin = ISNULL(main.cMargin, 0)
				,cHoMargin = ISNULL(main.cHoMargin, 0)
				,cAgentMargin = ISNULL(cAgentMargin, 0)
				,main.pRate
				,pOffer = main.pRate - ISNULL(main.pMargin, 0) - ISNULL(main.pAgentMargin, 0)
				,pMargin = ISNULL(main.pMargin, 0)
				,pHoMargin = ISNULL(main.pHoMargin, 0)
				,pAgentMargin = ISNULL(main.pAgentMargin, 0)
				,sharingType
				,sharingValue = ISNULL(main.sharingValue, 0)
				,toleranceOn
				,agentTolMin = ISNULL(main.agentTolMin, 0)
				,agentTolMax = ISNULL(main.agentTolMax, 0)
				,customerTolMin = ISNULL(main.customerTolMin, 0)
				,customerTolMax = ISNULL(main.customerTolMax, 0)
				,main.maxCrossRate
				,crossRate = main.maxCrossRate
				,main.crossRateOperation
				,customerRate = ISNULL(main.crossRateOperation, main.customerRate) + main.premium
				,main.tolerance
				,premium = main.premium
				,cost = ISNULL(ROUND(pRate/(ISNULL(main.crossRateOperation, main.customerRate) + ISNULL(premium, 0)), crm.rateMaskMulAd), 0)
				,margin = ISNULL(ROUND(pRate/(ISNULL(main.crossRateOperation, main.customerRate) + ISNULL(premium, 0)) - cRate, crm.rateMaskMulAd), 0)		
				,main.crossRateFactor
				,main.isUpdated		
				,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedByOperation ELSE
									ISNULL(main.modifiedBy,main.createdBy) END
				,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, '1900-01-01') THEN main.modifiedDateOperation ELSE
									ISNULL(main.modifiedDate,main.createdDate) END
				,main.approvedBy
				,main.approvedDate
				,rateMaskMulAd
			INTO ##tmpExRateRegional
			FROM exRateTreasury main WITH(NOLOCK)
			LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
			LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
			LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
			LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
			LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, 'N') = 'Y'
			WHERE cCountry = 133 AND cAgent = @cAgent AND main.approvedBy IS NOT NULL AND ISNULL(main.isActive, 'N') = 'Y'
			ORDER BY pCountryName, pAgentName
			
			UPDATE tmp SET
				 tmp.premium		= erbw.premium
				,tmp.customerRate	= tmp.crossRateOperation + erbw.premium
				,tmp.cost			= ROUND(tmp.pRate/(tmp.crossRateOperation + ISNULL(erbw.premium, 0)), tmp.rateMaskMulAd)
				,tmp.margin			= ROUND(tmp.pRate/(tmp.crossRateOperation + ISNULL(erbw.premium, 0)) - tmp.cRate, tmp.rateMaskMulAd)	
				,tmp.modifiedBy		= erbw.modifiedBy
				,tmp.modifiedDate	= erbw.modifiedDate
				,tmp.approvedBy		= erbw.modifiedBy
				,tmp.approvedDate	= erbw.modifiedDate
			FROM ##tmpExRateRegional tmp
			INNER JOIN exRateBranchWise erbw ON tmp.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @cBranch AND ISNULL(erbw.isActive, 'N') = 'Y'
			
			SET @table = '(
						SELECT * FROM ##tmpExRateRegional
						)x
					'
		END
		ELSE
		BEGIN
		--SELECT * FROM exRateBranchWise
		SET @table = '(
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = NULL
							,cBranchName = ''[All]''
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cOffer = main.cRate + ISNULL(main.cMargin, 0) + ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pOffer = main.pRate - ISNULL(main.pMargin, 0) - ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,crossRate = main.maxCrossRate
							,main.tolerance
							,premium = ISNULL(main.premium, 0)
							,customerRate = ROUND(ISNULL(main.crossRateOperation + ISNULL(main.premium, 0), main.customerRate) , 10)
							,cost = ISNULL(ROUND(pRate/(crossRateOperation + ISNULL(main.premium, 0)), crm.rateMaskMulAd), 0)
							,margin = ISNULL(ROUND(pRate/(crossRateOperation + ISNULL(main.premium, 0)) - cRate, crm.rateMaskMulAd), 0)		
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedByOperation ELSE
												ISNULL(main.modifiedBy,main.createdBy) END
							,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedDateOperation ELSE
												ISNULL(main.modifiedDate,main.createdDate) END
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId	
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId	
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE ISNULL(main.isActive, ''N'') = ''Y''
						
						UNION ALL
						
						SELECT
							 main.exRateTreasuryId	
							,tranType = ISNULL(tt.typeTitle, ''Any'')
							,main.cCountry
							,cCountryName = cc.countryName
							,cCountryCode = cc.countryCode
							,main.cAgent
							,cAgentName = ISNULL(cam.agentName, ''[All]'')
							,cBranch = erbw.cBranch
							,cBranchName = bm.agentName
							,main.pCountry
							,pCountryName = pc.countryName
							,pCountryCode = pc.countryCode
							,main.pAgent
							,pAgentName = ISNULL(pam.agentName, ''[All]'')
							,main.cCurrency
							,main.pCurrency
							,main.cRateFactor
							,main.pRateFactor
							,main.cRate
							,cOffer = main.cRate + ISNULL(main.cMargin, 0) + ISNULL(main.cHoMargin, 0)
							,cAgentMargin = ISNULL(cAgentMargin, 0)
							,main.pRate
							,pOffer = main.pRate - ISNULL(main.pMargin, 0) - ISNULL(main.pHoMargin, 0)
							,pAgentMargin = ISNULL(main.pAgentMargin, 0)
							,sharingType
							,sharingValue = ISNULL(main.sharingValue, 0)
							,toleranceOn
							,agentTolMin = ISNULL(main.agentTolMin, 0)
							,agentTolMax = ISNULL(main.agentTolMax, 0)
							,customerTolMin = ISNULL(main.customerTolMin, 0)
							,customerTolMax = ISNULL(main.customerTolMax, 0)
							,crossRate = main.maxCrossRate
							,main.tolerance
							,premium = ISNULL(erbw.premium, 0)
							,customerRate = ROUND(main.crossRateOperation + ISNULL(erbw.premium, 0), 10)
							,cost = ROUND(pRate/(crossRateOperation + ISNULL(erbw.premium, 0)), crm.rateMaskMulAd)
							,margin = ROUND(pRate/(crossRateOperation + ISNULL(erbw.premium, 0)) - cRate, crm.rateMaskMulAd)
							,main.crossRateFactor
							,main.isUpdated		
							,modifiedBy = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedByOperation ELSE
												ISNULL(main.modifiedBy,main.createdBy) END
							,modifiedDate = CASE WHEN ISNULL(main.modifiedDate,main.createdDate) < ISNULL(main.modifiedDateOperation, ''1900-01-01'') THEN main.modifiedDateOperation ELSE
												ISNULL(main.modifiedDate,main.createdDate) END
							,main.approvedBy
							,main.approvedDate
						FROM exRateTreasury main WITH(NOLOCK)
						INNER JOIN exRateBranchWise erbw WITH(NOLOCK) ON main.exRateTreasuryId = erbw.exRateTreasuryId AND ISNULL(erbw.isActive, ''N'') = ''Y''
						INNER JOIN agentMaster bm WITH(NOLOCK) ON erbw.cBranch = bm.agentId
						LEFT JOIN serviceTypeMaster tt WITH(NOLOCK) ON main.tranType = tt.serviceTypeId
						LEFT JOIN countryMaster cc WITH(NOLOCK) ON main.cCountry = cc.countryId
						LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId
						LEFT JOIN countryMaster pc WITH(NOLOCK) ON main.pCountry = pc.countryId
						LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId
						LEFT JOIN rateMask crm WITH(NOLOCK) ON main.cCurrency = crm.currency AND ISNULL(crm.isActive, ''N'') = ''Y''
						WHERE ISNULL(main.isActive, ''N'') = ''Y''
						'
		SET @table =  @table + ') x'
		END	
		
		--PRINT (@table)
		--RETURN
		SET @sql_filter = ''
		--SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
			
		IF @hasChanged IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
		
		IF @isUpdated IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isUpdated, ''N'') = ''' + @isUpdated + ''''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
			
		IF @cCountry IS NOT NULL
			SET @sql_filter =  @sql_filter + ' AND cCountry = ' + CAST(@cCountry AS VARCHAR(50))
		
		IF @cCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCountryName LIKE ''%' + @cCountryName + '%'''
		
		IF @cAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgent = ' + CAST(@cAgent AS VARCHAR(50))
		
		IF @cAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cAgentName LIKE ''%' + @cAgentName + '%'''
		
		IF @cBranch IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cBranch = ' + CAST(@cBranch AS VARCHAR)
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''

		IF @pCountry IS NOT NULL
		BEGIN
			SET @sql_filter =  @sql_filter + ' AND pCountry = ' + CAST(@pCountry AS VARCHAR(50))
			IF ISNULL(@filterByPCountryOnly, 'N') = 'Y'
				SET @sql_filter = @sql_filter + ' AND pAgent = 0'
		END
		
		IF @pCountryName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCountryName = ''%' + @pCountryName + '%'''
			
		IF @pAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgent = ' + CAST(@pAgent AS VARCHAR(50))
		
		IF @pAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pAgentName = ''%' + @pAgentName + '%'''
			
		IF @tranType IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))
				
		SET @select_field_list = '
			 exRateTreasuryId
			,tranType			
			,cCountry
			,cCountryName
			,cCountryCode
			,cAgent
			,cAgentName
			,cBranchName
			,pCountry
			,pCountryName
			,pCountryCode
			,pAgent
			,pAgentName
			,cCurrency
			,pCurrency
			,cRateFactor
			,pRateFactor
			,cRate
			,cOffer
			,cAgentMargin
			,pRate
			,pOffer
			,pAgentMargin
			,sharingType
			,sharingValue
			,toleranceOn
			,agentTolMin
			,agentTolMax
			,customerTolMin
			,customerTolMax
			,crossRate
			,customerRate
			,tolerance
			,premium
			,cost
			,margin
			,crossRateFactor
			,isUpdated
			,modifiedBy
			,modifiedDate
			,approvedBy
			,approvedDate
			'
		--PRINT @table	
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
		
		IF OBJECT_ID('tempdb..##tmpExRateRegional') IS NOT NULL
			DROP TABLE ##tmpExRateRegional
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @exRateTreasuryId
END CATCH


GO
