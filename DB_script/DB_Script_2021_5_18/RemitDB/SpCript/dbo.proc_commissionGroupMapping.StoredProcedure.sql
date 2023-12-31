USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_commissionGroupMapping]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC proc_commissionGroupMapping @flag = 's',@packageId=0
*/
CREATE proc [dbo].[proc_commissionGroupMapping]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@id								INT				= NULL
	,@packageId							INT				= NULL	
	,@ruleId							INT				= NULL
	,@groupId							INT				= NULL
	,@packageName						VARCHAR(200)	= NULL
	,@ruleName							VARCHAR(200)	= NULL
	,@ruleType							VARCHAR(200)	= NULL
	,@groupName							VARCHAR(200)	= NULL
	,@scMasterId						INT				= NULL
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
		IF EXISTS(SELECT 'X' FROM commissionPackage WHERE packageId = @packageId AND ruleId = @ruleId AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Already Added!', @user
			RETURN;
		END
	
		INSERT @commissionRule
		SELECT ruleId FROM commissionPackage WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
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
		INSERT INTO commissionPackage(
			 packageId
			,ruleId
			,isActive
			,createdBy
			,createdDate
		)
		SELECT 
			 @packageId
			,@ruleId
			,'Y'
			,@user
			,GETDATE()
		
		EXEC proc_errorHandler 0, 'Successfully Added!', @user
	
	END
	
	IF @flag='packList'
	BEGIN
			select distinct packageId,case when ruleType='ds' then rtrim(ltrim(dbo.FNAGetDataValue(packageId)))+' -Domestic' 
			else rtrim(ltrim(dbo.FNAGetDataValue(packageId)))+' -International' end as packageName  from commissionPackage
			where isActive='Y' and isDeleted is null
	END	
		
	IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT * FROM commissionPackage WHERE packageId=@packageId AND ruleId=@ruleId and id<>@id AND isDeleted IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Added!', @user
			RETURN;
		END
		UPDATE commissionPackage SET packageId=@packageId,ruleId=@ruleId,modifiedBy=@user,modifiedDate=getdate()
		WHERE ID=@ID
		
		EXEC proc_errorHandler 0, 'Successfully Updated!', @user
	
	END
	
	IF @flag = 'a'
	BEGIN
		
		SELECT * FROM commissionPackage WHERE id=@id
	
	END
	
	IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM commissionPackage WITH(NOLOCK)
			WHERE id = @id  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @id
		END
		IF EXISTS (
			SELECT 'X' FROM commissionPackageHistory  WITH(NOLOCK)
			WHERE id = @id AND (approvedBy IS NULL AND createdBy <> @user)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @id
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM commissionPackage WITH(NOLOCK) WHERE id = @id AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM commissionPackage WHERE id = @id AND approvedBy IS NULL
			DELETE FROM commissionPackageHistory WHERE id = @id AND approvedBy IS NULL
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
			RETURN
		END
		ELSE
		BEGIN
			DELETE FROM commissionPackageHistory WHERE id = @id AND approvedBy IS NULL
			INSERT INTO commissionPackageHistory(
					 id
					,packageId
					,ruleId
					,ruleType
					,modType
					,createdBy
					,createdDate
				)
				SELECT
					 id
					,packageId
					,ruleId
					,ruleType
					,'D'
					,@user
					,GETDATE()
				FROM commissionPackage
				WHERE id = @id	
		END
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @user
	END
	IF @flag = 'ds' -- ### domestic commission List
	BEGIN		

		SELECT  A.ID
				,A.ruleId
				,A.packageId
				,ROW_NUMBER() OVER(order by A.ID) [S.N.]
				,[Package Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleType=ds">' + B.detailTitle + '</a>'
				,[Rule Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleId=' + cast(A.ruleId as varchar) + '&ruleType=ds">' +C.code+ '</a>'
				,A.createdBy [Created By]
				,CONVERT(VARCHAR,A.createdDate,101)  [Created Date]
		FROM commissionPackage A WITH(NOLOCK) INNER JOIN 
		staticDataValue B WITH(NOLOCK) ON A.packageId=B.valueId 
		INNER JOIN scMaster C WITH(NOLOCK) ON C.scMasterId=A.ruleId
		WHERE ISNULL(A.ISDELETED,'N') = 'N' and A.ruleType ='ds'
		AND A.packageId = @packageId
		
	END
	IF @flag = 'ic'
	BEGIN
		--International Service Charge List
		SELECT  A.ID
				,A.ruleId
				,A.packageId
				,ROW_NUMBER() OVER(order by A.ID) [S.N.]
				,[Package Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleType=sc">' + B.detailTitle + '</a>'
				,[Rule Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleId=' + cast(A.ruleId as varchar) + '&ruleType=sc">' +C.code+ '</a>'
				,A.createdBy [Created By]
				,CONVERT(VARCHAR,A.createdDate,101)  [Created Date]
		FROM commissionPackage A WITH(NOLOCK) INNER JOIN 
		staticDataValue B WITH(NOLOCK) ON A.packageId=B.valueId 
		INNER JOIN sscMaster C WITH(NOLOCK) ON C.sscMasterId=A.ruleId
		WHERE ISNULL(A.isDeleted,'N') = 'N' and A.ruleType='sc'
		AND A.packageId = @packageId
		
		--International Pay Commission List
		SELECT  A.ID
				,A.ruleId
				,A.packageId
				,ROW_NUMBER() OVER(order by A.ID) [S.N.]
				,[Package Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleType=cp">' + B.detailTitle + '</a>'
				,[Rule Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleId=' + cast(A.ruleId as varchar) + '&ruleType=cp">' +C.code+ '</a>'
				,A.createdBy [Created By]
				,CONVERT(VARCHAR,A.createdDate,101)  [Created Date]
		FROM commissionPackage A WITH(NOLOCK) INNER JOIN 
		staticDataValue B WITH(NOLOCK) ON A.packageId=B.valueId 
		INNER JOIN scPayMaster C WITH(NOLOCK) ON C.scPayMasterId=A.ruleId
		WHERE ISNULL(A.ISDELETED,'N') = 'N' and A.ruleType='cp' and A.packageId=@packageId
		AND A.packageId = @packageId
		
		--International Send Commission List
		SELECT  A.ID
				,A.ruleId
				,A.packageId
				,ROW_NUMBER() OVER(order by A.ID) [S.N.]
				,[Package Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleType=cs">' + B.detailTitle + '</a>'
				,[Rule Name] = '<a href="CommissionView.aspx?packageId=' + cast(A.packageId as varchar) + '&ruleId=' + cast(A.ruleId as varchar) + '&ruleType=cs">' +C.code+ '</a>'
				,A.createdBy [Created By]
				,CONVERT(VARCHAR,A.createdDate,101)  [Created Date]
		FROM commissionPackage A WITH(NOLOCK) INNER JOIN 
		staticDataValue B WITH(NOLOCK) ON A.packageId=B.valueId 
		INNER JOIN scSendMaster C WITH(NOLOCK) ON C.scSendMasterId=A.ruleId
		WHERE ISNULL(A.ISDELETED,'N') = 'N' and A.ruleType='cs' and A.packageId=@packageId
		AND A.packageId = @packageId
	END
	
	ELSE IF @flag = 'vc'				--View Changes(Maker/Checker)
	BEGIN
		SELECT 
			 main.ruleId
			,hasChanged = 'N'
			,modType = ''
		FROM commissionPackage main
		LEFT JOIN commissionPackageHistory mode ON main.ruleId = mode.ruleId AND main.packageId = mode.packageId
		WHERE main.packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N' AND main.ruleType = 'sc' AND main.approvedBy IS NOT NULL AND mode.approvedBy IS NULL AND ISNULL(mode.modType, '') <> 'D'
		UNION ALL
		SELECT
			 ruleId
			,hasChanged = 'Y'
			,modType
		FROM commissionPackageHistory WHERE packageId = @packageId AND ruleType = 'sc' AND approvedBy IS NULL
		
		SELECT 
			 main.ruleId
			,hasChanged = 'N'
			,modType = ''
		FROM commissionPackage main
		LEFT JOIN commissionPackageHistory mode ON main.ruleId = mode.ruleId AND main.packageId = mode.packageId
		WHERE main.packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N' AND main.ruleType = 'cp' AND main.approvedBy IS NOT NULL AND mode.approvedBy IS NULL AND ISNULL(mode.modType, '') <> 'D'
		UNION ALL
		SELECT
			 ruleId
			,hasChanged = 'Y'
			,modType
		FROM commissionPackageHistory WHERE packageId = @packageId AND ruleType = 'cp' AND approvedBy IS NULL
		
		SELECT 
			 main.ruleId
			,hasChanged = 'N'
			,modType = ''
		FROM commissionPackage main
		LEFT JOIN commissionPackageHistory mode ON main.ruleId = mode.ruleId AND main.packageId = mode.packageId
		WHERE main.packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N' AND main.ruleType = 'cs' AND main.approvedBy IS NOT NULL AND mode.approvedBy IS NULL AND ISNULL(mode.modType, '') <> 'D'
		UNION ALL
		SELECT
			 ruleId
			,hasChanged = 'Y'
			,modType
		FROM commissionPackageHistory WHERE packageId = @packageId AND ruleType = 'cs' AND approvedBy IS NULL
	END	
	
	ELSE IF @flag = 'pal'			--Package Audit Log
	BEGIN
		SELECT DISTINCT
			 createdBy
			,createdDate
			,packageId
		FROM commissionPackageHistory WHERE packageId = @packageId AND approvedBy IS NULL
	END
	-- ### END COMMISSION PACKAGE ### ---
	
	-- ### START COMMISSION GROUP ### ---
	--Package Display
	IF @flag = 'pd'
	BEGIN
		SELECT
			 id
			,cg.packageId
			,cg.groupId
			,[S.N.] = ROW_NUMBER() OVER(ORDER BY cg.id)
			,[Package Name] = '<a href="CommissionView.aspx?packageId=' + CAST(cg.packageId AS VARCHAR) + '&ruleType=ds">' + sdv.detailTitle + '</a>'
			,[Created By]	= cg.createdBy
			,[Created Date]	= CONVERT(VARCHAR, cg.createdDate, 101)
		FROM commissionGroup cg WITH(NOLOCK) 
		INNER JOIN staticDataValue sdv WITH(NOLOCK) ON cg.packageId = sdv.valueId
		WHERE cg.groupId = @groupId 
		AND sdv.typeID = 6400
		AND ISNULL(cg.isDeleted, 'N') = 'N'  
		
		SELECT
			 id
			,cg.packageId
			,cg.groupId
			,[S.N.] = ROW_NUMBER() OVER(ORDER BY cg.id)
			,[Package Name] = '<a href="CommissionView.aspx?packageId=' + CAST(cg.packageId AS VARCHAR) + '&ruleType=cp">' + sdv.detailTitle + '</a>'
			,[Created By]	= cg.createdBy
			,[Created Date]	= CONVERT(VARCHAR, cg.createdDate, 101)
		FROM commissionGroup cg WITH(NOLOCK) 
		INNER JOIN staticDataValue sdv WITH(NOLOCK) ON cg.packageId = sdv.valueId
		WHERE cg.groupId = @groupId 
		AND sdv.typeID = 6500
		AND ISNULL(cg.isDeleted, 'N') = 'N' 
	END
	
	IF @flag = 'ig'
	BEGIN
		
		
		IF EXISTS(SELECT 'X' FROM commissionGroup WHERE packageId = @packageId AND groupId = @groupId AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Already Added!', @user
			RETURN
		END
		DECLARE @RULE_TYPE VARCHAR(10)
		
		SELECT @RULE_TYPE=ruleType FROM commissionPackage WHERE packageId=@packageId
		
		IF @RULE_TYPE='ds'
		BEGIN
				--New Commission Rule Table From New PackageId
				INSERT @commissionRuleNew
				SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) 
				WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
						AND ruleType='ds'
				
				--Old Commission Rule Table From Old PackageId assigned to Group
				INSERT @commissionRule
				SELECT DISTINCT cp.ruleId
				FROM commissionGroup cg WITH(NOLOCK) 
				INNER JOIN commissionPackage cp WITH(NOLOCK) ON cg.packageId = cp.packageId AND ISNULL(cp.isDeleted, 'N') = 'N'
				WHERE cg.groupId = @groupId
					AND cp.ruleType='ds'
					
				WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
				BEGIN
					SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
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
						SET @found = 1
					END
					DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
				END
				IF @found = 1
				BEGIN
					EXEC proc_errorHandler 1, 'This commission package consist of commission rule criteria which has already been defined in this group', NULL
					RETURN
				END
		END
		
		IF @RULE_TYPE='sc'
		BEGIN
				--New Commission Rule Table From New PackageId
				INSERT @commissionRuleNew
				SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
										AND ruleType='sc'
				
				--Old Commission Rule Table From Old PackageId assigned to Group
				INSERT @commissionRule
				SELECT DISTINCT cp.ruleId
				FROM commissionGroup cg WITH(NOLOCK) 
				INNER JOIN commissionPackage cp WITH(NOLOCK) ON cg.packageId = cp.packageId AND ISNULL(cp.isDeleted, 'N') = 'N'
				WHERE cg.groupId = @groupId AND cp.ruleType='sc'
					
				WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
				BEGIN
					SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
					SELECT 
						 @sCountry  = sCountry
						,@rCountry	= rCountry
						,@ssAgent	= ssAgent
						,@rsAgent	= rsAgent
						,@sAgent	= sAgent
						,@sBranch	= sBranch
						,@sState	= State
						,@sGroup	= agentGroup
						,@rAgent	= rAgent
						,@rBranch	= rBranch
						,@rState	= rState
						,@rGroup	= rAgentGroup
						,@tranType	= tranType
					FROM sscMaster WITH(NOLOCK) WHERE sscMasterId = @ruleId
					
					IF EXISTS(SELECT 'X' FROM sscMaster WHERE
								ISNULL(sAgent, 0)	= ISNULL(@sAgent, 0)
							AND	ISNULL(sBranch, 0)	= ISNULL(@sBranch, 0)
							AND ISNULL(State, 0)	= ISNULL(@sState, 0)
							AND ISNULL(agentGroup, 0)	= ISNULL(@sGroup, 0)
							AND ISNULL(rAgent, 0)	= ISNULL(@rAgent, 0)
							AND ISNULL(rBranch, 0)	= ISNULL(@rBranch, 0)
							AND ISNULL(rState, 0)	= ISNULL(@rState, 0)
							AND ISNULL(rAgentGroup, 0)	= ISNULL(@rGroup, 0)
							AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) 
							
							AND ISNULL(sCountry, 0)	= ISNULL(@sCountry, 0)
							AND ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) 
							
							AND ISNULL(ssAgent, 0)	= ISNULL(@ssAgent, 0)
							AND ISNULL(rsAgent, 0) = ISNULL(@rsAgent, 0) 
							
							AND ISNULL(isDeleted, 'N') = 'N'
							AND sscMasterId IN (SELECT ruleId FROM @commissionRule))
					BEGIN
						SET @found = 1
					END
					DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
				END
				IF @found = 1
				BEGIN
					EXEC proc_errorHandler 1, 'This commission package consist of commission rule criteria which has already been defined in this group', NULL
					RETURN
				END
		END
		
		IF @RULE_TYPE='cp'
		BEGIN
				--New Commission Rule Table From New PackageId
				INSERT @commissionRuleNew
				SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
				 AND ruleType='cp'
				
				--Old Commission Rule Table From Old PackageId assigned to Group
				INSERT @commissionRule
				SELECT DISTINCT cp.ruleId
				FROM commissionGroup cg WITH(NOLOCK) 
				INNER JOIN commissionPackage cp WITH(NOLOCK) ON cg.packageId = cp.packageId AND ISNULL(cp.isDeleted, 'N') = 'N'
				WHERE cg.groupId = @groupId
				AND cp.ruleType='cp'
					
				WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
				BEGIN
					SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
					SELECT 
						 @sCountry  = sCountry
						,@rCountry	= rCountry
						,@ssAgent	= ssAgent
						,@rsAgent	= rsAgent
						,@sAgent	= sAgent
						,@sBranch	= sBranch
						,@sState	= State
						,@sGroup	= agentGroup
						,@rAgent	= rAgent
						,@rBranch	= rBranch
						,@rState	= rState
						,@rGroup	= rAgentGroup
						,@tranType	= tranType
					FROM scPayMaster WITH(NOLOCK) WHERE scPayMasterId = @ruleId

					IF EXISTS(SELECT 'X' FROM scPayMaster WHERE
								ISNULL(sAgent, 0)	= ISNULL(@sAgent, 0)
							AND	ISNULL(sBranch, 0)	= ISNULL(@sBranch, 0)
							AND ISNULL(State, 0)	= ISNULL(@sState, 0)
							AND ISNULL(agentGroup, 0)	= ISNULL(@sGroup, 0)
							AND ISNULL(rAgent, 0)	= ISNULL(@rAgent, 0)
							AND ISNULL(rBranch, 0)	= ISNULL(@rBranch, 0)
							AND ISNULL(rState, 0)	= ISNULL(@rState, 0)
							AND ISNULL(rAgentGroup, 0)	= ISNULL(@rGroup, 0)
							AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) 							
							AND ISNULL(sCountry, 0)	= ISNULL(@sCountry, 0)
							AND ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) 							
							AND ISNULL(ssAgent, 0)	= ISNULL(@ssAgent, 0)
							AND ISNULL(rsAgent, 0) = ISNULL(@rsAgent, 0) 							
							AND ISNULL(isDeleted, 'N') = 'N'
							AND scPayMasterId IN (SELECT ruleId FROM @commissionRule))
					BEGIN
						SET @found = 1
					END
					DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
				END
				IF @found = 1
				BEGIN
					EXEC proc_errorHandler 1, 'This commission package consist of commission rule criteria which has already been defined in this group', NULL
					RETURN
				END
		END
		
		IF @RULE_TYPE='cs'
		BEGIN
				--New Commission Rule Table From New PackageId
				INSERT @commissionRuleNew
				SELECT DISTINCT ruleId FROM commissionPackage WITH(NOLOCK) WHERE packageId = @packageId AND ISNULL(isDeleted, 'N') = 'N'
							 AND ruleType='cs'
				
				--Old Commission Rule Table From Old PackageId assigned to Group
				INSERT @commissionRule
				SELECT DISTINCT cp.ruleId
				FROM commissionGroup cg WITH(NOLOCK) 
				INNER JOIN commissionPackage cp WITH(NOLOCK) ON cg.packageId = cp.packageId AND ISNULL(cp.isDeleted, 'N') = 'N'
				WHERE cg.groupId = @groupId
							 AND cp.ruleType='cs'
					
				WHILE EXISTS(SELECT 'X' FROM @commissionRuleNew)
				BEGIN
					SELECT TOP 1 @ruleId = ruleId FROM @commissionRuleNew
					SELECT 
						 @sCountry  = sCountry
						,@rCountry	= rCountry
						,@ssAgent	= ssAgent
						,@rsAgent	= rsAgent
						,@sAgent	= sAgent
						,@sBranch	= sBranch
						,@sState	= State
						,@sGroup	= agentGroup
						,@rAgent	= rAgent
						,@rBranch	= rBranch
						,@rState	= rState
						,@rGroup	= rAgentGroup
						,@tranType	= tranType
					FROM scSendMaster WITH(NOLOCK) WHERE scSendMasterId = @ruleId

					IF EXISTS(SELECT 'X' FROM scSendMaster WHERE
								ISNULL(sAgent, 0)	= ISNULL(@sAgent, 0)
							AND	ISNULL(sBranch, 0)	= ISNULL(@sBranch, 0)
							AND ISNULL(State, 0)	= ISNULL(@sState, 0)
							AND ISNULL(agentGroup, 0)	= ISNULL(@sGroup, 0)
							AND ISNULL(rAgent, 0)	= ISNULL(@rAgent, 0)
							AND ISNULL(rBranch, 0)	= ISNULL(@rBranch, 0)
							AND ISNULL(rState, 0)	= ISNULL(@rState, 0)
							AND ISNULL(rAgentGroup, 0)	= ISNULL(@rGroup, 0)
							AND ISNULL(tranType, 0) = ISNULL(@tranType, 0) 							
							AND ISNULL(sCountry, 0)	= ISNULL(@sCountry, 0)
							AND ISNULL(rCountry, 0) = ISNULL(@rCountry, 0) 							
							AND ISNULL(ssAgent, 0)	= ISNULL(@ssAgent, 0)
							AND ISNULL(rsAgent, 0) = ISNULL(@rsAgent, 0) 							
							AND ISNULL(isDeleted, 'N') = 'N'
							AND scSendMasterId IN (SELECT ruleId FROM @commissionRule))
					BEGIN
						SET @found = 1
					END
					DELETE FROM @commissionRuleNew WHERE ruleId = @ruleId
				END
				IF @found = 1
				BEGIN
					EXEC proc_errorHandler 1, 'This commission package consist of commission rule criteria which has already been defined in this group', NULL
					RETURN
				END
		END	
		
		INSERT INTO commissionGroup(
			 packageId
			,groupId
			,isActive
			,createdBy
			,createdDate
		)
		SELECT 
			 @packageId
			,@groupId
			,'Y'
			,@user
			,GETDATE()
		
		EXEC proc_errorHandler 0, 'Successfully Added!', @user
	
	END
	
			
	IF @flag = 'ug'
	BEGIN
		
		IF EXISTS(SELECT * FROM commissionGroup WHERE packageId=@packageId AND groupId=@groupId and id<>@id AND isDeleted IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Added!', @user
			RETURN;
		END
		UPDATE commissionGroup SET packageId=@packageId,groupId=@groupId,modifiedBy=@user,modifiedDate=getdate()
		WHERE ID=@ID
		
		EXEC proc_errorHandler 0, 'Successfully Updated!', @user
	
	END
	
	IF @flag = 'ag'
	BEGIN
		
		SELECT * FROM commissionGroup WHERE id=@id
	
	END
	
	IF @flag = 'dg'
	BEGIN
		
		UPDATE commissionGroup SET isDeleted='Y' WHERE id=@id
		EXEC proc_errorHandler 0, 'Successfully Deleted!', @user
	
	END
	
	IF @flag = 'sg'
	BEGIN
		
		IF @sortBy IS NULL
		SET @sortBy = 'id'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '(
						select 
							distinct
							a.id
							,a.groupId
							,a.packageId
							,[groupName]=''<a href="ruleCommView.aspx?groupId='' + cast(a.groupId as varchar) + ''">'' + dbo.FNAGetDataValue(a.groupId) + ''</a>''
							,[packageName]=''<a href="ruleCommView.aspx?packageId='' + cast(a.packageId as varchar) + ''">'' + dbo.FNAGetDataValue(a.packageId) + ''</a>''
							,a.createdBy
							,a.createdDate
						from commissionGroup a with(nolock) 
						inner join commissionPackage b with(nolock) on a.packageId=b.packageId 
						where a.isDeleted is null		
					) x'

		SET @sql_filter = ''

		IF @groupName IS NOT NULL		
			SET @sql_filter = @sql_filter+' AND groupName LIKE ''%' + @groupName + '%'''
 		
		IF @packageName IS NOT NULL 
			SET @sql_filter = @sql_filter+' AND packageName LIKE ''%' + @packageName + '%''' 
			
		SET @select_field_list ='
			id
			,groupId
			,packageId
			,groupName
			,packageName
			,createdBy
			,createdDate'

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
	
	-- ### END COMMISSION GROUP ### ---
	
	
	-- ### START COMMISSION VIEW ### ---
	
	IF @flag='V'
	BEGIN
		if @ruleType='ds'
		begin
			select 
			distinct
				 code [Code]
				,description [Desc]
				,dbo.GetAgentNameFromId(sAgent) sAgent
				,dbo.GetAgentNameFromId(sBranch) sBranch
				,isnull(stTbl.stateCode,'All State') sState
				,isnull(dbo.[FNAGetDataValue](sGroup),'All Group') sGroup
				,dbo.GetAgentNameFromId(rAgent) rAgent
				,dbo.GetAgentNameFromId(rBranch) rBranch
				,isnull(stTbl1.stateCode,'All State') rState
				,isnull(dbo.[FNAGetDataValue](rGroup),'All Group') rGroup
				,scM.typeTitle tranType
				,dbo.[FNAGetDataValue](commissionBase) CommBase
				,main.createdBy
				,main.createdDate
				,main.effectiveFrom
				,main.effectiveTo
				 from scMaster main with(nolock) 
				 inner join commissionPackage comPck with(nolock) on main.scMasterId=comPck.ruleId 
				 left join countryStateMaster stTbl with(nolock) on stTbl.stateId=main.sState
				 left join countryStateMaster stTbl1 with(nolock) on stTbl1.stateId=main.rState
				 left join serviceTypeMaster scM on scM.serviceTypeId=main.tranType
			where main.scMasterId=@scMasterId
		end
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
				,effectiveFrom
				,effectiveTo
				,baseCurrency baseCurrency				
				,scM.typeTitle tranType
				,ve positiveDisc
				,dbo.FNAGetDataValue(veType)  positiveDiscType
				,ne negativeDisc
				,dbo.FNAGetDataValue(neType)  negativeDiscType
				,main.createdBy
				,main.createdDate
				,main.effectiveFrom
				,main.effectiveTo
			FROM sscMaster main WITH(NOLOCK) 
			INNER JOIN commissionPackage comPck with(nolock) on main.sscMasterId=comPck.ruleId 
			INNER JOIN countryMaster CM with(nolock) on CM.countryId=main.sCountry
			INNER JOIN countryMaster CM1 WITH(NOLOCK) ON CM1.countryId=main.rCountry
			LEFT JOIN countryStateMaster stTbl with(nolock) on stTbl.stateId=main.State
			LEFT JOIN countryStateMaster stTbl1 with(nolock) on stTbl1.stateId=main.rState
			LEFT JOIN serviceTypeMaster scM on scM.serviceTypeId=main.tranType
			WHERE main.sscMasterId = @scMasterId AND ISNULL(comPck.isDeleted, 'N') = 'N'			
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
					,scM.typeTitle tranType
					,main.baseCurrency baseCurrency
					,main.commissionCurrency commCurrency
					,dbo.[FNAGetDataValue](commissionBase) commBase
					,main.effectiveFrom
					,main.effectiveTo
					from scPayMaster main with(nolock) 
				inner join commissionPackage comPck with(nolock) on main.scPayMasterId=comPck.ruleId 
				left join countryStateMaster stTbl with(nolock) on stTbl.stateId= main.[state]
				left join countryStateMaster stTbl1 with(nolock) on stTbl1.stateId= main.rState
				left join serviceTypeMaster scM on scM.serviceTypeId=main.tranType
				left join countryMaster cm with (nolock) on cm.countryId = main.sCountry
				left join countryMaster rcm with (nolock) on rcm.countryId = main.rCountry
				where main.scPayMasterId=@scMasterId AND ISNULL(comPck.isDeleted, 'N') = 'N'
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
					,scM.typeTitle tranType
					,main.baseCurrency  baseCurrency
					,dbo.[FNAGetDataValue](commissionBase) commBase
					,main.effectiveFrom
					,main.effectiveTo
			from scSendMaster main with(nolock) 
			inner join commissionPackage comPck with(nolock) on main.scSendMasterId=comPck.ruleId 
			left join countryStateMaster stTbl with(nolock) on stTbl.stateId=main.[State]
			left join countryStateMaster stTbl1 with(nolock) on stTbl1.stateId=main.rState
			left join serviceTypeMaster scM on scM.serviceTypeId=main.tranType
			left join countryMaster cm with (nolock) on cm.countryId = sCountry
			left join countryMaster rcm with (nolock) on rcm.countryId = rCountry
			where main.scSendMasterId=@scMasterId AND ISNULL(comPck.isDeleted, 'N') = 'N'
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
