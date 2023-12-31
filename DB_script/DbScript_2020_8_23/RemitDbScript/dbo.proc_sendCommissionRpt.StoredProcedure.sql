USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendCommissionRpt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC proc_sendCommissionRpt @flag = 'master', @user = 'admin', 
@sCountryId = '181', @sAgent = null, @rCountryId = '151', @rAgent = null
*/
CREATE proc [dbo].[proc_sendCommissionRpt]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@sCountryId						INT				= NULL
	,@sAgent							INT				= NULL
	,@rCountryId						INT				= NULL
	,@rAgent							INT				= NULL
	,@ruleId							INT				= NULL
	

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	IF @flag = 'master'				
	BEGIN
		--DECLARE @serviceChargeRule TABLE(ruleId INT)
		
		--INSERT @serviceChargeRule
		--SELECT ruleId FROM agentCommissionRule WITH(NOLOCK) 
		--WHERE ruleType = 'cs' 
		--			AND agentId = @sAgent 
		--			AND ISNULL(isActive, 'N') = 'Y'
		
		----select * from @serviceChargeRule
		--SELECT
		--	 ssm.scSendMasterId
		--	,pCountryName = ISNULL(cm.countryName, 'All')
		--	,pAgentName = ISNULL(pam.agentName, 'All')+'<span style="color:Red;"> ('+ssm.code+') </span>'
		--	,paymentMethod = ISNULL(stm.typeTitle, 'All')
		--	,baseCurrency
		--FROM scSendMaster ssm WITH(NOLOCK)
		--INNER JOIN @serviceChargeRule scr ON ssm.scSendMasterId = scr.ruleId
		--LEFT JOIN countryMaster cm WITH(NOLOCK) ON ssm.rCountry = cm.countryId
		--LEFT JOIN agentMaster pam WITH(NOLOCK) ON ssm.rAgent = pam.agentId
		--LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON ssm.tranType = stm.serviceTypeId
		--WHERE isnull(rCountry,'') = ISNULL(@rCountryId,isnull(rCountry,''))
		--		 AND ISNULL(ssm.isActive, 'N') = 'Y'
		--		 AND isnull(rAgent,'')	= ISNULL(@rAgent,isnull(rAgent,''))

			SELECT scs.scSendMasterId
				,pCountryName = ISNULL(cm.countryName, 'All')+' | Sending Country: '+isnull(cm1.countryName,'All')
				,pAgentName = isnull(am.agentName,'All')+' | Sending Agent:'+ isnull(am1.agentName,'All')
				,paymentMethod = ISNULL(stm.typeTitle, 'All')
				,baseCurrency =baseCurrency
			FROM agentCommissionRule acr WITH(NOLOCK) 
			inner join scSendMaster scs with(nolock) on acr.ruleId = scs.scSendMasterId
			inner join countryMaster cm with(nolock) on cm.countryId = scs.rCountry
			inner join countryMaster cm1 with(nolock) on cm1.countryId = scs.sCountry
			left join agentMaster am with(nolock) on am.agentId = scs.rAgent 
			left join agentMaster am1 with(nolock) on am1.agentId = acr.agentId 
			left join serviceTypeMaster stm WITH(NOLOCK) ON scs.tranType = stm.serviceTypeId
			WHERE ruleType = 'cs' 
			and	isnull(scs.rCountry,'') = ISNULL(@rCountryId,isnull(scs.rCountry,''))
			and	isnull(scs.sCountry,'') = ISNULL(@sCountryId,isnull(scs.sCountry,''))
			AND ISNULL(scs.isActive, 'N') = 'Y'
			AND ISNULL(acr.isActive, 'N') = 'Y'
			AND isnull(scs.rAgent,'')	= ISNULL(@rAgent,isnull(scs.rAgent,''))

 	END
	
	ELSE IF @flag = 'detail'
	BEGIN
		SELECT
		     country = isnull(cm.countryName,'All')
			,fromAmt
			,toAmt
			,commission = CASE WHEN pcnt = 0 THEN minAmt ELSE pcnt END
			,feeType = CASE WHEN pcnt = 0 THEN 'Flat' ELSE 'Percent' END
		FROM scSenddetail d WITH(NOLOCK) inner join scSendMaster m with(nolock) on d.scSendMasterId = m.scSendMasterId
		left join countryMaster cm with(nolock) on cm.countryId = m.rCountry
		WHERE d.scSendMasterId = @ruleId AND ISNULL(d.isDeleted, 'N') = 'N' AND ISNULL(d.isActive, 'N') = 'Y'
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
