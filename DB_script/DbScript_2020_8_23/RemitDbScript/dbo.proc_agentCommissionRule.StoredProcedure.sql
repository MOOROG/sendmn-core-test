USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentCommissionRule]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_agentCommissionRule]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@id								INT				= NULL
	,@agentId							INT				= NULL	
	,@ruleId							INT				= NULL
	,@groupId							INT				= NULL
	,@packageName						VARCHAR(200)	= NULL
	,@ruleName							VARCHAR(200)	= NULL
	,@ruleType							VARCHAR(200)	= NULL
	,@groupName							VARCHAR(200)	= NULL
	,@scMasterId						INT				= NULL
	,@agentCountry						VARCHAR(200)	= NULL
	,@agentName							VARCHAR(200)	= NULL
	,@isSettlingAgent					VARCHAR(10)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


BEGIN TRY

	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE @table AS VARCHAR(MAX),@sql_filter VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)

	DECLARE @commissionRule TABLE(ruleId INT)
	DECLARE @commissionRuleNew TABLE(ruleId INT)
	DECLARE @found INT = 0
	DECLARE @ssAgent INT, @rsAgent INT,@sCountry INT, @rCountry INT, 
			@sAgent INT, @sBranch INT, @sState INT,	@sGroup INT, @rAgent INT, @rBranch INT, 
			@rState INT, @rGroup INT, @tranType INT
			
		
			
	-- ### START COMMISSION PACKAGE ### ---
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM agentCommissionRule WHERE agentId = @agentId AND ruleId = @ruleId)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Added!', @user
			RETURN;
		END
	
		INSERT @commissionRule
		SELECT ruleId FROM agentCommissionRule WHERE agentId = @agentId
		SELECT 
			 @sAgent	= sAgent
			,@sBranch	= sBranch
			,@sState	= sState
			,@sGroup	= sGroup
			,@rAgent	= rAgent
			,@rBranch	= rBranch
			,@rState	= rState
			,@rGroup	= rGroup
			,@tranType	= tranType
		FROM scMaster WITH(NOLOCK) WHERE scMasterId = @ruleId
		
		IF EXISTS(SELECT 'X' FROM scMaster WHERE
					ISNULL(sAgent, 0)	= ISNULL(@sAgent, 0)
				AND	ISNULL(sBranch, 0)	= ISNULL(@sBranch, 0)
				AND ISNULL(sState, 0)	= ISNULL(@sState, 0)
				AND ISNULL(sGroup, 0)	= ISNULL(@sGroup, 0)
				AND ISNULL(rAgent, 0)	= ISNULL(@rAgent, 0)
				AND ISNULL(rBranch, 0)	= ISNULL(@rBranch, 0)
				AND ISNULL(rState, 0)	= ISNULL(@rState, 0)
				AND ISNULL(rGroup, 0)	= ISNULL(@rGroup, 0)
				AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) 
				AND ISNULL(isDeleted, 'N') = 'N'
				AND scMasterId IN (SELECT ruleId FROM @commissionRule))
		BEGIN
			EXEC proc_errorHandler 1, 'Commission Rule with this criteria has already been added', NULL
			RETURN
		END
		INSERT INTO agentCommissionRule(
			 agentId
			,ruleId
			,isActive
			,createdBy
			,createdDate
		)
		SELECT 
			 @agentId
			,@ruleId
			,'Y'
			,@user
			,GETDATE()
		
		EXEC proc_errorHandler 0, 'Successfully Added!', @user
	
	END
	
	IF @flag='packList'
	BEGIN
			select distinct agentId,case when ruleType='ds' then rtrim(ltrim(dbo.FNAGetDataValue(agentId)))+' -Domestic' 
			else rtrim(ltrim(dbo.FNAGetDataValue(agentId)))+' -International' end as packageName  from agentCommissionRule
			where isActive='Y'
	END	
		
	IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'X' FROM agentCommissionRule WHERE agentId = @agentId AND ruleId = @ruleId and id <> @id)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Added!', @user
			RETURN
		END
		
		UPDATE agentCommissionRule SET 
			 agentId		= @agentId
			,ruleId			= @ruleId
		WHERE ID = @ID
		
		EXEC proc_errorHandler 0, 'Successfully Updated!', @user
	END
	
	IF @flag = 'a'
	BEGIN
		SELECT * FROM agentCommissionRule WHERE id = @id
	END
	
	IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentCommissionRule WITH(NOLOCK)
			WHERE id = @id  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @id
		END
		IF EXISTS (
			SELECT 'X' FROM agentCommissionRuleHistory  WITH(NOLOCK)
			WHERE id = @id AND (approvedBy IS NULL AND createdBy <> @user)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @id
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM agentCommissionRule WITH(NOLOCK) WHERE id = @id AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM agentCommissionRule WHERE id = @id AND approvedBy IS NULL
			DELETE FROM agentCommissionRuleHistory WHERE id = @id AND approvedBy IS NULL
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
			RETURN
		END
		ELSE
		BEGIN
			DELETE FROM agentCommissionRuleHistory WHERE id = @id AND approvedBy IS NULL
			INSERT INTO agentCommissionRuleHistory(
					 id
					,agentId
					,ruleId
					,ruleType
					,modType
					,createdBy
					,createdDate
				)
				SELECT
					 id
					,agentId
					,ruleId
					,ruleType
					,'D'
					,@user
					,GETDATE()
				FROM agentCommissionRule
				WHERE id = @id	
		END
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @user
	END
	
	IF @flag = 'ic'
	BEGIN
		--International Service Charge List
		SELECT  
			 A.ID
			,A.ruleId
			,A.agentId
			,ROW_NUMBER() OVER(order by A.ID) [S.N.]
			,[Agent Name] = '<a href="CommissionView.aspx?agentId=' + CAST(A.agentId as varchar) + '&agentName=' + B.agentName + '&ruleType=sc">' + B.agentName + '</a>'
			,[Rule Name] = '<a href="CommissionView.aspx?agentId=' + CAST(A.agentId as varchar) + '&agentName=' + B.agentName + '&ruleId=' + CAST(A.ruleId AS VARCHAR) + '&ruleType=sc">' + C.code+ '</a>'
			,A.createdBy [Created By]
			,CONVERT(VARCHAR,A.createdDate,101)  [Created Date]
		FROM agentCommissionRule A WITH(NOLOCK) 
		INNER JOIN agentMaster B WITH(NOLOCK) ON A.agentId = B.agentId 
		INNER JOIN sscMaster C WITH(NOLOCK) ON C.sscMasterId = A.ruleId
		WHERE A.ruleType='sc'
		AND A.agentId = @agentId
		
		--International Pay Commission List
		SELECT  
			 A.ID
			,A.ruleId
			,A.agentId
			,ROW_NUMBER() OVER(order by A.ID) [S.N.]
			,[Agent Name] = '<a href="CommissionView.aspx?agentId=' + cast(A.agentId as varchar) + '&agentName=' + B.agentName + '&ruleType=cp">' + B.agentName + '</a>'
			,[Rule Name] = '<a href="CommissionView.aspx?agentId=' + cast(A.agentId as varchar) + '&agentName=' + B.agentName + '&ruleId=' + CAST(A.ruleId AS VARCHAR) + '&ruleType=cp">' + C.code + '</a>'
			,A.createdBy [Created By]
			,CONVERT(VARCHAR,A.createdDate,101)  [Created Date]
		FROM agentCommissionRule A WITH(NOLOCK) 
		INNER JOIN agentMaster B WITH(NOLOCK) ON A.agentId = B.agentId 
		INNER JOIN scPayMaster C WITH(NOLOCK) ON C.scPayMasterId = A.ruleId
		WHERE A.ruleType='cp'
		AND A.agentId = @agentId
		
		--International Send Commission List
		SELECT  
			 A.ID
			,A.ruleId
			,A.agentId
			,ROW_NUMBER() OVER(order by A.ID) [S.N.]
			,[Agent Name] = '<a href="CommissionView.aspx?agentId=' + cast(A.agentId as varchar) + '&agentName=' + B.agentName + '&ruleType=cs">' + B.agentName + '</a>'
			,[Rule Name] = '<a href="CommissionView.aspx?agentId=' + cast(A.agentId as varchar) + '&agentName=' + B.agentName + '&ruleId=' + cast(A.ruleId as varchar) + '&ruleType=cs">' +C.code+ '</a>'
			,A.createdBy [Created By]
			,CONVERT(VARCHAR,A.createdDate,101)  [Created Date]
		FROM agentCommissionRule A WITH(NOLOCK) 
		INNER JOIN agentMaster B WITH(NOLOCK) ON A.agentId = B.agentId 
		INNER JOIN scSendMaster C WITH(NOLOCK) ON C.scSendMasterId = A.ruleId
		WHERE A.ruleType='cs'
		AND A.agentId = @agentId
	END
	
	ELSE IF @flag = 'vc'				--View Changes(Maker/Checker)
	BEGIN
		SELECT 
			 main.ruleId
			,hasChanged = 'N'
			,modType = ''
		FROM agentCommissionRule main
		LEFT JOIN agentCommissionRuleHistory mode ON main.ruleId = mode.ruleId AND main.agentId = mode.agentId
		WHERE main.agentId = @agentId AND main.ruleType = 'sc' AND main.approvedBy IS NOT NULL AND mode.approvedBy IS NULL AND ISNULL(mode.modType, '') <> 'D'
		UNION ALL
		SELECT
			 ruleId
			,hasChanged = 'Y'
			,modType
		FROM agentCommissionRuleHistory WHERE agentId = @agentId AND ruleType = 'sc' AND approvedBy IS NULL
		
		SELECT 
			 main.ruleId
			,hasChanged = 'N'
			,modType = ''
		FROM agentCommissionRule main
		LEFT JOIN agentCommissionRuleHistory mode ON main.ruleId = mode.ruleId AND main.agentId = mode.agentId
		WHERE main.agentId = @agentId AND main.ruleType = 'cp' AND main.approvedBy IS NOT NULL AND mode.approvedBy IS NULL AND ISNULL(mode.modType, '') <> 'D'
		UNION ALL
		SELECT
			 ruleId
			,hasChanged = 'Y'
			,modType
		FROM agentCommissionRuleHistory WHERE agentId = @agentId AND ruleType = 'cp' AND approvedBy IS NULL
		
		SELECT 
			 main.ruleId
			,hasChanged = 'N'
			,modType = ''
		FROM agentCommissionRule main
		LEFT JOIN agentCommissionRuleHistory mode ON main.ruleId = mode.ruleId AND main.agentId = mode.agentId
		WHERE main.agentId = @agentId AND main.ruleType = 'cs' AND main.approvedBy IS NOT NULL AND mode.approvedBy IS NULL AND ISNULL(mode.modType, '') <> 'D'
		UNION ALL
		SELECT
			 ruleId
			,hasChanged = 'Y'
			,modType
		FROM agentCommissionRuleHistory WHERE agentId = @agentId AND ruleType = 'cs' AND approvedBy IS NULL
	END	
	
	ELSE IF @flag = 'pal'			--Package Audit Log
	BEGIN
		SELECT DISTINCT
			 createdBy
			,createdDate
			,agentId
		FROM agentCommissionRuleHistory WITH(NOLOCK) WHERE agentId = @agentId AND approvedBy IS NULL
	END
	
	IF @flag='V'
	BEGIN
		if @ruleType='sc'
		begin
			SELECT 
			DISTINCT
				 code [Code]
				,description [Desc]
				,CM.countryName sCountry	
				,dbo.GetAgentNameFromId(ssAgent) ssAgent			
				,dbo.GetAgentNameFromId(sAgent) sAgent
				,dbo.GetAgentNameFromId(sBranch) sBranch
				,isnull(stTbl.stateCode,'Any') sState
				,main.zip sZip
				,isnull(dbo.[FNAGetDataValue](main.agentGroup),'Any') sGroup
				,CM1.countryName rCountry	
				,dbo.GetAgentNameFromId(rsAgent) rsAgent
				,dbo.GetAgentNameFromId(rAgent) rAgent
				,dbo.GetAgentNameFromId(rBranch) rBranch
				,isnull(stTbl1.stateCode,'Any') rState
				,rZip
				,isnull(dbo.[FNAGetDataValue](rAgentGroup),'Any') rGroup
				,effectiveFrom = main.approvedDate
				,effectiveTo
				,baseCurrency baseCurrency				
				,tranType = isnull(scM.typeTitle ,'All')
				,ve positiveDisc
				,dbo.FNAGetDataValue(veType)  positiveDiscType
				,ne negativeDisc
				,dbo.FNAGetDataValue(neType)  negativeDiscType
				,main.createdBy
				,main.createdDate
			FROM sscMaster main WITH(NOLOCK) 
			INNER JOIN agentCommissionRule comPck with(nolock) on main.sscMasterId=comPck.ruleId 
			INNER JOIN countryMaster CM with(nolock) on CM.countryId=main.sCountry
			INNER JOIN countryMaster CM1 WITH(NOLOCK) ON CM1.countryId=main.rCountry
			LEFT JOIN countryStateMaster stTbl with(nolock) on stTbl.stateId=main.State
			LEFT JOIN countryStateMaster stTbl1 with(nolock) on stTbl1.stateId=main.rState
			LEFT JOIN serviceTypeMaster scM on scM.serviceTypeId = main.tranType
			WHERE main.sscMasterId = @scMasterId			
		end
		IF @ruleType='cp'
		BEGIN
			  SELECT 
					distinct
					code [Code]
					,description [Desc]
					,dbo.GetAgentNameFromId(ssAgent) ssAgent
					,dbo.GetAgentNameFromId(sAgent) sAgent
					,dbo.GetAgentNameFromId(sBranch) sBranch
					,isnull(stTbl.stateCode,'All State') sState
					,ISNULL(cm.countryName,'All Coutry') sCountry
					,ISNULL(main.zip,'') sZip
					,isnull(dbo.[FNAGetDataValue](agentGroup),'Any') sGroup
					,ISNULL(rcm.countryName,'All Coutry') rCountry
					,dbo.GetAgentNameFromId(rsAgent) rsAgent
					,dbo.GetAgentNameFromId(rAgent) rAgent
					,dbo.GetAgentNameFromId(rBranch) rBranch
					,isnull(stTbl1.stateCode,'All State') rState
					,ISNULL(main.rZip,'') rZip
					,isnull(dbo.[FNAGetDataValue](ragentGroup),'Any') rGroup
					,tranType = isnull(scM.typeTitle ,'All')
					,main.baseCurrency baseCurrency
					,main.commissionCurrency commCurrency
					,dbo.[FNAGetDataValue](commissionBase) commBase
					,effectiveFrom = main.approvedDate
					,main.effectiveTo
					from scPayMaster main with(nolock) 
				inner join agentCommissionRule comPck with(nolock) on main.scPayMasterId=comPck.ruleId 
				left join countryStateMaster stTbl with(nolock) on stTbl.stateId= main.[state]
				left join countryStateMaster stTbl1 with(nolock) on stTbl1.stateId= main.rState
				left join serviceTypeMaster scM on scM.serviceTypeId=main.tranType
				left join countryMaster cm with (nolock) on cm.countryId = main.sCountry
				left join countryMaster rcm with (nolock) on rcm.countryId = main.rCountry
				where main.scPayMasterId=@scMasterId
		end
		if @ruleType='cs'
		begin
			select 
					distinct
					 code [Code]
					,description [Desc]
					,dbo.GetAgentNameFromId(ssAgent) ssAgent
					,dbo.GetAgentNameFromId(sAgent) sAgent
					,dbo.GetAgentNameFromId(sBranch) sBranch
					,isnull(stTbl.stateCode,'All State') sState
					,ISNULL(cm.countryName,'All Coutry') sCountry
					,ISNULL(main.zip,'') sZip
					,isnull(dbo.[FNAGetDataValue](agentGroup),'Any') sGroup
					,ISNULL(rcm.countryName,'All Coutry') rCountry
					,dbo.GetAgentNameFromId(rsAgent) rsAgent
					,dbo.GetAgentNameFromId(rAgent) rAgent
					,dbo.GetAgentNameFromId(rBranch) rBranch
					,isnull(stTbl1.stateCode,'All State') rState
					,ISNULL(main.rZip,'') rZip
					,isnull(dbo.[FNAGetDataValue](ragentGroup),'Any') rGroup
					,tranType = isnull(scM.typeTitle ,'All')
					,main.baseCurrency  baseCurrency
					,dbo.[FNAGetDataValue](commissionBase) commBase
					,effectiveFrom = main.approvedDate
					,main.effectiveTo
			from scSendMaster main with(nolock) 
			inner join agentCommissionRule comPck with(nolock) on main.scSendMasterId=comPck.ruleId 
			left join countryStateMaster stTbl with(nolock) on stTbl.stateId=main.[State]
			left join countryStateMaster stTbl1 with(nolock) on stTbl1.stateId=main.rState
			left join serviceTypeMaster scM on scM.serviceTypeId=main.tranType
			left join countryMaster cm with (nolock) on cm.countryId = sCountry
			left join countryMaster rcm with (nolock) on rcm.countryId = rCountry
			where main.scSendMasterId=@scMasterId
		end

	END

	IF @flag='V1'
	BEGIN
		if @ruleType='ds'
		begin
			SELECT
				 scDetailId =  main.scDetailId
				,fromAmt = main.fromAmt
				,toAmt = main.toAmt
				,serviceChargePcnt =  main.serviceChargePcnt
				,serviceChargeMinAmt =  main.serviceChargeMinAmt
				,serviceChargeMaxAmt =  main.serviceChargeMaxAmt
				,sAgentCommPcnt = main.sAgentCommPcnt
				,sAgentCommMinAmt = main.sAgentCommMinAmt
				,sAgentCommMaxAmt =  main.sAgentCommMinAmt
				,ssAgentCommPcnt = main.ssAgentCommPcnt
				,ssAgentCommMinAmt =  main.ssAgentCommMinAmt
				,ssAgentCommMaxAmt =  main.ssAgentCommMinAmt
				,pAgentCommPcnt =  main.pAgentCommPcnt
				,pAgentCommMinAmt =  main.pAgentCommMinAmt
				,pAgentCommMaxAmt = main.pAgentCommMaxAmt
				,psAgentCommPcnt =  main.psAgentCommPcnt
				,psAgentCommMinAmt =  main.psAgentCommMinAmt
				,psAgentCommMaxAmt = main.psAgentCommMaxAmt
				,bankCommPcnt =  main.bankCommPcnt
				,bankCommMinAmt =  main.bankCommMinAmt
				,bankCommMaxAmt =  main.bankCommMaxAmt
				,main.createdBy
				,main.createdDate
			FROM scDetail main WITH(NOLOCK)
			WHERE main.scMasterId = @scMasterId AND ISNULL(main.isDeleted, 'N')  <> 'Y'
			ORDER BY fromAmt
		end
		if @ruleType='sc'
		begin
							
			SELECT [From Amount] = ISNULL(mode.fromAmt, main.fromAmt)
					,[To Amount] = ISNULL(mode.toAmt, main.toAmt)
					,Percentage = ISNULL(mode.pcnt, main.pcnt)
					,[Min Amount] = ISNULL(mode.minAmt, main.minAmt)
					,[Max Amount] = ISNULL(mode.maxAmt, main.maxAmt)
			FROM sscDetail main WITH(NOLOCK)
				LEFT JOIN sscDetailHistory mode ON main.sscDetailId = mode.sscDetailId AND mode.approvedBy IS NULL						
				WHERE main.sscMasterId = @scMasterId AND ISNULL(main.isDeleted, 'N')  <> 'Y'
			ORDER BY [From Amount]
		end
		if @ruleType='cp'
		begin
			SELECT
				 
				 [From Amount] = main.fromAmt
				,[To Amount] = main.toAmt
				,[Percentage] =  main.pcnt
				,[Min Amount] =  main.minAmt
				,[Max Amount] =  main.maxAmt
			FROM scPayDetail main WITH(NOLOCK)
			WHERE main.scPayMasterId = @scMasterId 
				  AND ISNULL(main.isDeleted, 'N')  <> 'Y'
			ORDER BY [From Amount]
		end
		if @ruleType='cs'
		begin
			SELECT
				 [From Amount] = main.fromAmt
				,[To Amount] = main.toAmt
				,[Percentage] =  main.pcnt
				,[Min Amount] =  main.minAmt
				,[Max Amount] =  main.maxAmt
			FROM scSendDetail main WITH(NOLOCK)
			WHERE main.scSendMasterId = @scMasterId 
				  AND ISNULL(main.isDeleted, 'N')  <> 'Y'
			ORDER BY [From Amount]
		end
	END

	IF @flag='s'
	BEGIN

		SET @table = '
				(
					SELECT
						 parentId =  am.parentId
						,agentId = am.agentId
						,agentCode = am.agentCode
						,mapCodeInt = am.mapCodeInt
						,agentName = am.agentName
						,agentAddress = am.agentAddress
						,agentCity = am.agentCity
						,agentCountry = am.agentCountry						
						,isSettlingAgent = am.isSettlingAgent
					FROM agentMaster am WITH(NOLOCK)
					WHERE ISNULL(am.isDeleted, ''N'')  <> ''Y'' 
					AND isnull(am.isActive,''Y'')  = ''Y'' 
					AND am.agentType NOT IN (2905,2906)
					
				)x'
		

		IF @sortBy IS NULL
		   SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'

		SET @sql_filter = ''		
			
		--IF @agentId IS NOT NULL
		--	SET @sql_filter = @sql_filter + ' AND ISNULL(parentId, '''') = ''' + CAST(@agentId AS VARCHAR) + ''''

		IF @agentCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentCountry, '''') = ''' + CAST(@agentCountry AS VARCHAR) + ''''
			
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentName, '''') LIKE ''%' + @agentName + '%'''		
		
		IF @isSettlingAgent IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(isSettlingAgent, ''N'') = ''' + @isSettlingAgent + ''''
				
		SET @select_field_list ='
				parentId
               ,agentId
               ,agentCode
               ,mapCodeInt
               ,agentName               
               ,agentAddress
               ,agentCity                
               ,agentCountry
			   ,isSettlingAgent
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
	
		
	-- ### END COMMISSION VIEW ### ---
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH





GO
