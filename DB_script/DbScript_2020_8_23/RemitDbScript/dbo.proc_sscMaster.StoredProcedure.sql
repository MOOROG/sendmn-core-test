USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sscMaster]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	proc_sscMaster @flag = 'm', @user = 'admin'
*/

CREATE PROC [dbo].[proc_sscMaster]   
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@sscMasterId                       VARCHAR(30)		= NULL
	,@code                              VARCHAR(200)	= NULL
	,@description                       VARCHAR(200)	= NULL
	,@sCountry                          INT				= NULL
	,@ssAgent							INT				= NULL
	,@sAgent							INT				= NULL
	,@sBranch                           INT				= NULL
	,@rCountry                          INT				= NULL
	,@rsAgent							INT				= NULL
	,@rAgent							INT				= NULL
	,@rBranch                           INT				= NULL
	,@state                             INT				= NULL
	,@zip                               VARCHAR(20)		= NULL
	,@agentGroup                        INT				= NULL
	,@rState							INT				= NULL
	,@rZip								VARCHAR(20)		= NULL
	,@rAgentGroup						INT				= NULL
	,@baseCurrency                      VARCHAR(3)		= NULL
	,@tranType                          INT				= NULL
	,@veType							INT				= NULL
	,@ve                                MONEY			= NULL
	,@neType							INT				= NULL
	,@ne                                MONEY			= NULL	
	,@effectiveFrom                     DATETIME		= NULL
	,@effectiveTo						DATETIME		= NULL
	,@hasChanged						CHAR(1)			= NULL
	,@isEnable							CHAR(1)			= NULL
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
		 @ApprovedFunctionId = 30001030
		,@logIdentifier = 'sscMasterId'
		,@logParamMain = 'sscMaster'
		,@logParamMod = 'sscMasterHistory'
		,@module = '20'
		,@tableAlias = 'Service Charge'
		
	DECLARE @DetailIdList TABLE(detailId BIGINT, modType VARCHAR(10)) 
	DECLARE @detailId BIGINT
	
	/*
	IF @flag = 'scl'
	BEGIN
		SELECT 
             ccm.countryId
            ,ccm.countryName
            ,cnt = COUNT(rCountry)
        FROM countryCurrencyMaster ccm WITH(NOLOCK)
        LEFT JOIN dscMaster dscm WITH(NOLOCK) ON ccm.countryId = dscm.sCountry
        WHERE ISNULL(ccm.isDeleted, 'N') <> 'Y'
        GROUP BY ccm.countryId, ccm.countryName
        RETURN
	END
	*/
	IF @flag = 'cl'
	BEGIN
		SELECT
			 sscMasterId
			,code
		FROM sscMaster WITH(NOLOCK)
		WHERE ISNULL(isDeleted, 'N') = 'N'
		AND ISNULL(isActive, 'N') = 'Y'
		ORDER BY code ASC
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM sscMaster WHERE code = @code AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Service Charge with this code already exists', NULL
			RETURN
		END
		/*
		IF EXISTS(SELECT 'x' FROM sscMaster WHERE 
			ISNULL(ssAgent, 0) = ISNULL(@ssAgent, 0) AND
			ISNULL(rsAgent, 0) = ISNULL(@rsAgent, 0) AND
			ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND
			ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND
			ISNULL(sAgent, 0) = ISNULL(@sAgent, 0) AND
			ISNULL(rAgent, 0) = ISNULL(@rAgent, 0) AND 
			ISNULL(sBranch, 0) = ISNULL(@sBranch, 0) AND 
			ISNULL(rBranch, 0) = ISNULL(@rBranch, 0) AND 
			ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND 
			ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @sscMasterId
			RETURN
		END
		*/
		BEGIN TRANSACTION
			INSERT INTO sscMaster (
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
				,veType
				,ve                                 
				,neType
				,ne
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
				,@veType
				,@ve                                 
				,@neType
				,@ne
				,@effectiveFrom
				,@effectiveTo 
				,@isEnable
				,@user
				,GETDATE()				
				
			SET @sscMasterId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @sscMasterId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM sscMasterHistory WITH(NOLOCK)
				WHERE sscMasterId = @sscMasterId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				 mode.*
				,CONVERT(VARCHAR, mode.effectiveFrom, 101) effFrom
				,CONVERT(VARCHAR, mode.effectiveTo, 101) effTo
			FROM sscMasterHistory mode WITH(NOLOCK)
			INNER JOIN sscMaster main WITH(NOLOCK) ON mode.sscMasterId = main.sscMasterId
			WHERE mode.sscMasterId= @sscMasterId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				 * 
				,CONVERT(VARCHAR, effectiveFrom, 101) effFrom
				,CONVERT(VARCHAR, effectiveTo, 101) effTo 
			FROM sscMaster WITH(NOLOCK) WHERE sscMasterId = @sscMasterId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @sscMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM sscMasterHistory WITH(NOLOCK)
			WHERE sscMasterId  = @sscMasterId AND (createdBy<> @user OR modType = 'D') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @sscMasterId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM sscMaster WHERE code = @code AND ISNULL(isDeleted, 'N') = 'N' AND sscMasterId <> @sscMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'Service Charge with this code already exists', NULL
			RETURN
		END
		/*
		IF EXISTS(SELECT 'x' FROM sscMaster WHERE
			sscMasterId <> @sscMasterId AND 
			ISNULL(ssAgent, 0) = ISNULL(@ssAgent, 0) AND
			ISNULL(rsAgent, 0) = ISNULL(@rsAgent, 0) AND
			ISNULL(sCountry, 0) = ISNULL(@sCountry, 0) AND
			ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) AND
			ISNULL(sAgent, 0) = ISNULL(@sAgent, 0) AND
			ISNULL(rAgent, 0) = ISNULL(@rAgent, 0) AND 
			ISNULL(sBranch, 0) = ISNULL(@sBranch, 0) AND 
			ISNULL(rBranch, 0) = ISNULL(@rBranch, 0) AND 
			ISNULL(tranType, 0) = ISNULL(@tranType, 0) AND 
			ISNULL(isDeleted,'N')<>'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', @sscMasterId
			RETURN
		END
		*/
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM sscMaster WHERE approvedBy IS NULL AND sscMasterId  = @sscMasterId)			
			BEGIN				
				UPDATE sscMaster SET
					 code = @code
					,[description] = @description
					,sCountry = @sCountry
					,ssAgent= @ssAgent
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
					,veType = @veType
					,ve = @ve                                 
					,neType = @neType
					,ne = @ne
					,effectiveFrom  = @effectiveFrom 
					,effectiveTo = @effectiveTo
					,isEnable = @isEnable
					,modifiedBy = @user
					,modifiedDate = GETDATE()					
				WHERE sscMasterId = @sscMasterId				
			END
			ELSE
			BEGIN
				DELETE FROM sscMasterHistory WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL
				INSERT INTO sscMasterHistory (
					 sscMasterId
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
					,veType
					,ve                                 
					,neType
					,ne
					,effectiveFrom
					,effectiveTo
					,isEnable
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @sscMasterId
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
					,@veType
					,@ve                                 
					,@neType
					,@ne
					,@effectiveFrom
					,@effectiveTo
					,@isEnable
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @sscMasterId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @sscMasterId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM sscMasterHistory  WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @sscMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sscDetail WITH(NOLOCK) WHERE sscMasterId = @sscMasterId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Please delete details data before deleting the master data.', @sscMasterId
			RETURN
		END
			--DELETE FROM sscMasterHistory WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL
			INSERT INTO sscMasterHistory (
				 sscMasterId
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
				,veType
				,ve                                 
				,neType
				,ne
				,effectiveFrom
				,effectiveTo
				,isEnable
				,createdBy
				,createdDate
				,modType
			)
			SELECT
				 sscMasterId
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
				,veType
				,ve                                 
				,neType
				,ne
				,effectiveFrom
				,effectiveTo
				,isEnable
				,@user
				,GETDATE()
				,'D'
			FROM sscMaster WHERE sscMasterId = @sscMasterId	

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @sscMasterId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'sscMasterId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 sscMasterId = ISNULL(mode.sscMasterId, main.sscMasterId)
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
					,veType = ISNULL(mode.veType, main.veType)
					,ve = ISNULL(mode.ve, main.ve)
					,neType = ISNULL(mode.neType, main.neType)
					,ne = ISNULL(mode.ne, main.ne)
					,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
					,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)
					,main.createdBy
					,main.createdDate
					,modifiedDate = ISNULL(mode.createdDate, main.modifiedDate)
					,modifiedBy = ISNULL(mode.createdBy, main.modifiedBy)
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.sscMasterId IS NOT NULL THEN ''Y'' ELSE ''N'' END
				FROM sscMaster main WITH(NOLOCK)
					LEFT JOIN sscMasterHistory mode ON main.sscMasterId = mode.sscMasterId AND mode.approvedBy IS NULL
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
			 sscMasterId
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
			,veType
			,ve                                 
			,neType
			,ne
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
					 sscMasterId = ISNULL(mode.sscMasterId, main.sscMasterId)
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
					,veType = ISNULL(mode.veType, main.veType)
					,ve = ISNULL(mode.ve, main.ve)
					,neType = ISNULL(mode.neType, main.neType)
					,ne = ISNULL(mode.ne, main.ne)
					,effectiveFrom = ISNULL(mode.effectiveFrom, main.effectiveFrom)
					,effectiveTo = ISNULL(mode.effectiveTo, main.effectiveTo)
					,isEnable = ISNULL(mode.isEnable, main.isEnable)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END									
					,hasChanged = CASE WHEN main.approvedBy IS NULL OR mode.sscMasterId IS NOT NULL 
										THEN ''Y'' ELSE ''N'' END
				FROM sscMaster main WITH(NOLOCK)
					LEFT JOIN sscMasterHistory mode ON main.sscMasterId = mode.sscMasterId AND mode.approvedBy IS NULL
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
					 sscDetailId = main.sscDetailId
					,sscMasterId = main.sscMasterId
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,pcnt = ISNULL(mode.pcnt, main.pcnt)
					,minAmt = ISNULL(mode.minAmt, main.minAmt)
					,maxAmt = ISNULL(mode.maxAmt, main.maxAmt)	
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.sscDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM sscDetail main WITH(NOLOCK)
					LEFT JOIN sscDetailHistory mode ON main.sscDetailId = mode.sscDetailId AND mode.approvedBy IS NULL
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
							 m.sscMasterId
							,m.code
							,m.description
							,m.sCountry
							,sCountryName = sc.countryName
							,m.ssAgent
							,ssAgentName = ISNULL(ssa.agentName, ''All'')
							,m.sAgent
							,sAgentName = ISNULL(sa.agentName, ''All'')
							,m.sBranch
							,sBranchName = ISNULL(sb.agentName, ''All'')
							,m.rCountry
							,rCountryName = rc.countryName
							,m.rsAgent
							,rsAgentName = ISNULL(rsa.agentName, ''All'')
							,m.rAgent
							,rAgentName = ISNULL(ra.agentName, ''All'')
							,m.rBranch
							,rBranchName = ISNULL(rb.agentName, ''All'')							
							,[state]
							,zip
							,agentGroup
							,rState 
							,rZip
							,rAgentGroup
							,m.tranType
							,tranTypeName = ISNULL(trn.typeTitle, ''All'')
							,m.veType
							,m.ve                                 
							,m.neType
							,m.ne
							,m.effectiveFrom
							,m.effectiveTo
							,m.baseCurrency
							,m.isEnable
							,fromAmt = MIN(d.fromAmt)
							,toAmt = MAX(d.toAmt)
							,modifiedBy = MAX(ISNULL(m.modifiedBy, d.modifiedBy))
							,hasChanged = MAX(CASE WHEN m.hasChanged = ''Y'' OR d.hasChanged = ''Y'' THEN ''Y'' ELSE ''N'' END)
						FROM ' + @m + ' m
						LEFT JOIN ' + @d + ' d ON m.sscMasterId = d.sscMasterId
						
						LEFT JOIN serviceTypeMaster trn WITH(NOLOCK) ON trn.serviceTypeId = m.tranType
						LEFT JOIN countryMaster rc WITH(NOLOCK) ON m.rCountry = rc.countryId
						LEFT JOIN agentMaster ssa WITH(NOLOCK) ON ssa.agentId = m.ssAgent
						LEFT JOIN agentMaster sa WITH(NOLOCK) ON sa.agentId = m.sAgent
						LEFT JOIN agentMaster sb WITH(NOLOCK) ON sb.agentId = m.sBranch
						LEFT JOIN countryMaster sc WITH(NOLOCK) ON m.sCountry = sc.countryId
						LEFT JOIN agentMaster rsa WITH(NOLOCK) ON rsa.agentId = m.rsAgent
						LEFT JOIN agentMaster ra WITH(NOLOCK) ON ra.agentId = m.rAgent
						LEFT JOIN agentMaster rb WITH(NOLOCK) ON rb.agentId = m.rBranch
						
						GROUP BY 
							 m.sscMasterId
							,m.code
							,m.description
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
							,m.veType
							,m.ve                                 
							,m.neType
							,m.ne
							,m.effectiveFrom
							,m.effectiveTo
							,trn.typeTitle
							,m.baseCurrency
							,m.isEnable
							--,m.modifiedBy
							--,d.modifiedBy
					) x
					'
					
				--print @m
				
			SET @sql_filter = ' '

			IF @hasChanged IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND hasChanged = ''' + @hasChanged +''''
				
			IF @sCountry IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND sCountry = ' + CAST(@sCountry AS VARCHAR(50))
							
			IF @sAgent IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND sAgent = ' + CAST(@sAgent AS VARCHAR(50))
				
			IF @sBranch IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND ssAgent = ' + CAST(@ssAgent AS VARCHAR(50))
				
			IF @rCountry IS NOT NULL
				SET @sql_filter = @sql_filter + ' AND rCountry = ' + CAST(@rCountry AS VARCHAR(50))
			
			IF @rAgent IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND rAgent = ' + CAST(@rAgent AS VARCHAR(50))
				
			IF @rBranch IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND rsAgent = ' + CAST(@rsAgent AS VARCHAR(50))
							
			IF @tranType IS NOT NULL
				SET @sql_filter =  @sql_filter + ' AND tranType = ' + CAST(@tranType AS VARCHAR(50))

			
			SET @select_field_list = '
					 sscMasterId
					,code
					,description
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
					,veType
					,ve                                 
					,neType
					,ne
					,effectiveFrom
					,effectiveTo
					
					,fromAmt
					,toAmt
					,modifiedBy
					,hasChanged
					
				'
		PRINT(@table)		
		SET @extra_field_list = ''
		
		IF @sortBy IS NULL
			SET @sortBy = 'sscMasterId'
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
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @sscMasterId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM sscMaster WHERE approvedBy IS NULL AND sscMasterId = @sscMasterId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sscMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @sscMasterId
					RETURN
				END
			DELETE FROM sscMaster WHERE sscMasterId =  @sscMasterId
			
		END
		ELSE
		BEGIN
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscMasterId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sscMasterId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @sscMasterId
					RETURN
				END
				DELETE FROM sscMasterHistory WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL

		END
		
		IF @flag = 'rejectAll'
		BEGIN
		
			INSERT @DetailIdList
			SELECT 
				sscDetailId, 'I' 
			FROM sscDetail 				
			WHERE 
				sscMasterId = @sscMasterId
				AND approvedBy IS NULL
				
			INSERT @DetailIdList
			SELECT 
				sdh.sscDetailId, sdh.modType
			FROM sscDetailHistory sdh WITH(NOLOCK)
			INNER JOIN sscDetail sd WITH(NOLOCK) ON sdh.sscDetailId = sd.sscDetailId 		
			WHERE 
				sd.sscMasterId = @sscMasterId
				AND sdh.approvedBy IS NULL
			
			SELECT
				 @logIdentifier = 'sscDetailId'
				,@logParamMain = 'sscDetail'
				,@logParamMod = 'sscDetailHistory'
				,@module = '20'
				,@tableAlias = 'Special Service Charge Detail'
				
			WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
			BEGIN
				SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
				
				IF EXISTS (SELECT 'X' FROM sscDetail WHERE approvedBy IS NULL AND sscDetailId = @detailId )
					SET @modType = 'I'
				ELSE
					SELECT @modType = modType FROM sscDetailHistory WHERE sscDetailId = @detailId AND approvedBy IS NULL
				
				IF @modType = 'I'
				BEGIN --New record					
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					DELETE FROM sscDetail WHERE sscDetailId =  @detailId					
				END
				ELSE
				BEGIN
					EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, 'Reject', @tableAlias, @detailId, @user, @oldValue, @newValue
					
					DELETE FROM sscDetailHistory WHERE sscDetailId = @detailId AND approvedBy IS NULL
				END
				DELETE FROM @DetailIdList WHERE detailId = @detailId
			END	
		END
		
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
			EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @sscMasterId
			RETURN
		END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @sscMasterId			
	END

	ELSE IF @flag IN ('approve', 'approveAll')
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM sscMaster WITH(NOLOCK)
			WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @sscMasterId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM sscMaster WHERE approvedBy IS NULL AND sscMasterId = @sscMasterId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM sscMasterHistory WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE sscMaster SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE sscMasterId = @sscMasterId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscMasterId, @oldValue OUTPUT
				UPDATE main SET
					 main.code                          = mode.code
					,main.[description]                 = mode.[description]
					,main.sCountry                      = mode.sCountry
					,main.ssAgent						= mode.ssAgent
					,main.sAgent						= mode.sAgent
					,main.sBranch						= mode.sBranch
					,main.rCountry                      = mode.rCountry
					,main.rsAgent						= mode.rsAgent
					,main.rAgent						= mode.rAgent
					,main.rBranch						= mode.rBranch
					,main.[state]						= mode.[state]
					,main.zip							= mode.zip
					,main.agentGroup					= mode.agentGroup
					,main.rState						= mode.rState
					,main.rZip							= mode.rZip
					,main.rAgentGroup					= mode.rAgentGroup	
					,main.baseCurrency                  = mode.baseCurrency
					,main.tranType                      = mode.tranType
					,main.veType						= mode.veType
					,main.ve							= mode.ve                               
					,main.neType						= mode.neType
					,main.ne							= mode.ne
					,main.effectiveFrom					= mode.effectiveFrom
					,main.effectiveTo					= mode.effectiveTo					
					,main.isEnable						= mode.isEnable
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM sscMaster main
				INNER JOIN sscMasterHistory mode ON mode.sscMasterId = main.sscMasterId
				WHERE mode.sscMasterId = @sscMasterId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'sscMaster', 'sscMasterId', @sscMasterId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @sscMasterId, @oldValue OUTPUT
				UPDATE sscMaster SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE sscMasterId = @sscMasterId
			END
			
			UPDATE sscMasterHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE sscMasterId = @sscMasterId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @sscMasterId, @user, @oldValue, @newValue
			
			IF @flag = 'approveAll'
			BEGIN
				
				INSERT @DetailIdList
				SELECT 
					sscDetailId, 'I' 
				FROM sscDetail 				
				WHERE 
					sscMasterId = @sscMasterId
					AND approvedBy IS NULL
					
				INSERT @DetailIdList
				SELECT 
					sdh.sscDetailId, sdh.modType
				FROM sscDetailHistory sdh WITH(NOLOCK)
				INNER JOIN sscDetail sd WITH(NOLOCK) ON sdh.sscDetailId = sd.sscDetailId 		
				WHERE 
					sd.sscMasterId = @sscMasterId
					AND sdh.approvedBy IS NULL					
					
				SELECT
					 @logIdentifier = 'sscDetailId'
					,@logParamMain = 'sscDetail'
					,@logParamMod = 'sscDetailHistory'
					,@module = '20'
					,@tableAlias = 'Special Service Charge Detail'
					
				WHILE EXISTS(SELECT 'X' FROM @DetailIdList)
				BEGIN
					SELECT TOP 1 @detailId = detailId, @ModType = modType FROM @DetailIdList
					
					IF EXISTS (SELECT 'X' FROM sscDetail WHERE approvedBy IS NULL AND sscDetailId = @detailId )
						SET @modType = 'I'
					ELSE
						SELECT @modType = modType FROM sscDetailHistory WHERE sscDetailId = @detailId AND approvedBy IS NULL
					
					IF @modType = 'I'
					BEGIN --New record
						UPDATE sscDetail SET
							isActive = 'Y'
							,approvedBy = @user
							,approvedDate= GETDATE()
						WHERE sscDetailId = @detailId
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
						FROM sscDetail main
						INNER JOIN sscDetailHistory mode ON mode.sscDetailId = main.sscDetailId
						WHERE mode.sscDetailId = @detailId AND mode.approvedBy IS NULL

						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @newValue OUTPUT
					END
					ELSE IF @modType = 'D'
					BEGIN
						EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @detailId, @oldValue OUTPUT
						UPDATE sscDetail SET
							 isDeleted = 'Y'
							,modifiedDate = GETDATE()
							,modifiedBy = @user					
						WHERE sscDetailId = @detailId
					END
					
					UPDATE sscDetailHistory SET
						 approvedBy = @user
						,approvedDate = GETDATE()
					WHERE sscDetailId = @detailId AND approvedBy IS NULL
					
					INSERT INTO #msg(errorCode, msg, id)
					EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @detailId, @user, @oldValue, @newValue
				
					DELETE FROM @DetailIdList WHERE detailId = @detailId
				END				
			END
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @sscMasterId
				RETURN
			END
				
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'All Changes approved successfully.', @sscMasterId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @sscMasterId
END CATCH



GO
