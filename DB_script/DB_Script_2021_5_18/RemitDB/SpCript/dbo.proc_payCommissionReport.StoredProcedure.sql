USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payCommissionReport]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	proc_payCommissionReport @flag = 's', @user = 'admin', @sortBy = 'exRateTreasuryId', @sortOrder = 'ASC', @pageSize = '10', @pageNumber = '1'
*/
CREATE proc [dbo].[proc_payCommissionReport]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	
	,@sCountry							INT				= NULL
	,@sAgent							INT				= NULL
	,@sBranch							INT				= NULL
	
	,@rCountry							INT				= NULL
	,@rAgent							INT				= NULL
	,@rBranch							INT				= NULL
	
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
		DECLARE @serviceChargeRuleBranchWise TABLE(ruleId INT)
		DECLARE @serviceChargeRuleAgentWise TABLE(ruleId INT)
		DECLARE @serviceChargeRule TABLE(ruleId INT)
		
		INSERT @serviceChargeRuleBranchWise
		SELECT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE ruleType = 'cp' AND agentId = @rBranch AND ISNULL(isActive, 'N') = 'Y'
		
		INSERT @serviceChargeRuleAgentWise
		SELECT ruleId FROM agentCommissionRule WITH(NOLOCK) WHERE ruleType = 'cp' AND agentId = @rAgent AND ISNULL(isActive, 'N') = 'Y'
		
		IF EXISTS(SELECT 'X' FROM scPayMaster ssm WITH(NOLOCK)
		INNER JOIN @serviceChargeRuleBranchWise scr ON ssm.scPayMasterId = scr.ruleId
		WHERE rCountry = @rCountry AND ISNULL(ssm.isActive, 'N') = 'Y')
		BEGIN
			INSERT @serviceChargeRule
			SELECT * FROM @serviceChargeRuleBranchWise			
		END
		ELSE
		BEGIN
			INSERT @serviceChargeRule
			SELECT * FROM @serviceChargeRuleAgentWise
		END
		SELECT
			 ssm.scPayMasterId
			,pCountryName = ISNULL(cm.countryName, 'All')
			,pAgentName = ISNULL(pam.agentName, 'All')
			,paymentMethod = ISNULL(stm.typeTitle, 'All')
			,baseCurrency
		FROM scPayMaster ssm WITH(NOLOCK)
		INNER JOIN @serviceChargeRule scr ON ssm.scPayMasterId = scr.ruleId
		LEFT JOIN countryMaster cm WITH(NOLOCK) ON ssm.rCountry = cm.countryId
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON ssm.rAgent = pam.agentId
		LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON ssm.tranType = stm.serviceTypeId
		WHERE rCountry = @rCountry AND ISNULL(ssm.isActive, 'N') = 'Y'

	END
	
	ELSE IF @flag = 'detail'
	BEGIN
		SELECT
			 fromAmt
			,toAmt
			,serviceFee = CASE WHEN pcnt = 0 THEN minAmt ELSE pcnt END
			,feeType = CASE WHEN pcnt = 0 THEN 'Flat' ELSE 'Percent' END
		FROM scPayDetail WITH(NOLOCK) WHERE scPayMasterId = @ruleId AND ISNULL(isDeleted, 'N') = 'N' AND ISNULL(isActive, 'N') = 'Y'
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
