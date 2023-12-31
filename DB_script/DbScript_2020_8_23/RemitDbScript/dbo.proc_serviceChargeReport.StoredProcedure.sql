USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_serviceChargeReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC proc_serviceChargeReport @flag = 'master', @user = 'admin', @agent = null, @branch = null, @pCountry = null
*/
CREATE proc [dbo].[proc_serviceChargeReport]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)
	,@branch							INT				= NULL
	,@sCountry							INT				= NULL
	,@agent								INT				= NULL
	,@pCountry							INT				= NULL
	,@ruleId							INT				= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	IF @flag = 'master'				
	BEGIN
		--DECLARE @serviceChargeRuleBranchWise TABLE(ruleId INT)
		--DECLARE @serviceChargeRuleAgentWise TABLE(ruleId INT)
		--DECLARE @serviceChargeRule TABLE(ruleId INT)
		
		--INSERT @serviceChargeRuleBranchWise
		--SELECT ruleId FROM agentCommissionRule WITH(NOLOCK)
		--		WHERE ruleType = 'sc' AND agentId = @branch AND ISNULL(isActive, 'N') = 'Y'
		
		--INSERT @serviceChargeRuleAgentWise
		--SELECT ruleId FROM agentCommissionRule WITH(NOLOCK) 
		--		WHERE ruleType = 'sc' AND agentId = isnull(@agent,agentId) AND ISNULL(isActive, 'N') = 'Y'
		
		--IF EXISTS(SELECT 'X' FROM sscMaster ssm WITH(NOLOCK)
		--INNER JOIN @serviceChargeRuleBranchWise scr ON ssm.sscMasterId = scr.ruleId
		--WHERE rCountry = isnull(@pCountry,rCountry) AND ISNULL(ssm.isActive, 'N') = 'Y')
		--BEGIN
		--	INSERT @serviceChargeRule
		--	SELECT * FROM @serviceChargeRuleBranchWise			
		--END
		--ELSE
		--BEGIN
		--	INSERT @serviceChargeRule
		--	SELECT * FROM @serviceChargeRuleAgentWise
		--END
		--SELECT
		--	 ssm.sscMasterId
		--	,sCountryName = ISNULL(cm.countryName, 'All')
		--	,sAgentName = sam.agentName
		--	,paymentMethod = ISNULL(stm.typeTitle, 'All')
		--	,baseCurrency
		--FROM sscMaster ssm WITH(NOLOCK)
		--INNER JOIN @serviceChargeRule scr ON ssm.sscMasterId = scr.ruleId
		--inner join agentCommissionRule acomr with(nolock) on acomr.ruleId = ssm.sscMasterId
		--inner JOIN countryMaster cm WITH(NOLOCK) ON ssm.sCountry = cm.countryId
		--inner JOIN agentMaster sam WITH(NOLOCK) ON acomr.agentId = sam.agentId
		--LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON ssm.tranType = stm.serviceTypeId
		--WHERE rCountry = ISNULL(@pCountry,rCountry) AND ISNULL(ssm.isActive, 'N') = 'Y'
		--and acomr.ruleType = 'sc'
		----select * from agentCommissionRule 
		----select * from sscMaster

		if @sCountry is not null -->> admin panel
		begin
			select 
				 sc.sscMasterId
				,scCode = sc.code
				,sCountryName = cm.countryName
				,sAgentName = am.agentName +', Payout Agent:'+isnull(am1.agentName,'All') 
				,paymentMethod = ISNULL(stm.typeTitle, 'All')
				,baseCurrency = sc.baseCurrency
			from agentCommissionRule a with(nolock) 
			inner join sscMaster sc with(nolock) on a.ruleId = sc.sscMasterId
			inner join agentMaster am with(nolock) on a.agentId = am.agentId 
			left join serviceTypeMaster stm WITH(NOLOCK) ON sc.tranType = stm.serviceTypeId
			left join countryMaster cm with(nolock) on cm.countryId = sc.sCountry
			left join agentMaster am1 with(nolock) on sc.rAgent = am1.agentId
			where a.ruleType = 'sc' and isnull(a.isActive,'Y') = 'Y'
			and sc.sCountry = isnull(@sCountry,sc.sCountry)
			and a.agentId = isnull(@agent,a.agentId)
			order by am.agentName
		end
		else
		begin
			select 
				 sc.sscMasterId
				,scCode = sc.code
				,sCountryName = cm.countryName
				,pAgentName = ISNULL(am1.agentName,'All')
				,paymentMethod = ISNULL(stm.typeTitle, 'All')
				,baseCurrency = sc.baseCurrency
			from agentCommissionRule a with(nolock) 
			inner join sscMaster sc with(nolock) on a.ruleId = sc.sscMasterId
			inner join agentMaster am with(nolock) on a.agentId = am.agentId 
			left join serviceTypeMaster stm WITH(NOLOCK) ON sc.tranType = stm.serviceTypeId
			left join countryMaster cm with(nolock) on cm.countryId = sc.sCountry
			left join agentMaster am1 with(nolock) on sc.rAgent = am1.agentId
			where a.ruleType = 'sc' 
			and isnull(a.isActive,'Y') = 'Y'
			and isnull(sc.isActive,'Y') = 'Y'
			and a.agentId = isnull(@agent,a.agentId)			
			order by am.agentName
			
		end

	END
	
	ELSE IF @flag = 'detail'
	BEGIN
		SELECT
			 fromAmt
			,toAmt
			,serviceFee = CASE WHEN pcnt = 0 THEN minAmt ELSE pcnt END
			,feeType = CASE WHEN pcnt = 0 THEN 'Flat' ELSE 'Percent' END
		FROM sscDetail WITH(NOLOCK) WHERE sscMasterId = @ruleId AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
		ORDER BY fromAmt ASC
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, NULL
END CATCH


GO
