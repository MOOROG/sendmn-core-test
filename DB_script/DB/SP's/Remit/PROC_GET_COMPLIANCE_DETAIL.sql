USE FastMoneyPro_Remit
GO

ALTER PROC PROC_GET_COMPLIANCE_DETAIL
(
	@period INT = NULL
	,@condition INT = NULL
	,@pCountryId INT = NULL
	,@deliveryMethod INT = NULL
	,@professionId INT = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	CREATE TABLE #COMPLIANCE_TBL(COMM_RULE_ID INT, LIMIT_AMT MONEY, RULE_TYPE CHAR(1))

	IF EXISTS(SELECT 1   
				FROM csMaster CM(NOLOCK)   
				INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
				WHERE CM.rCountry = @pCountryId AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
				AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = @period AND condition = @condition
				AND ISNULL(PROFESSION, -1) = ISNULL(@professionId, -1))  
	BEGIN  
		INSERT INTO #COMPLIANCE_TBL
		SELECT comRuleId = comRuleId, limitAmt = limitAmt, ruleType = nextAction  
		FROM (  
			SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
					hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
			FROM dbo.csDetail CD(NOLOCK)  
			INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
			WHERE CD.period = @period  
			AND CM.rCountry = @pCountryId  
			AND CD.condition = @condition  
			AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
			AND ISNULL(CD.isActive, 'Y') = 'Y'   
			AND ISNULL(CD.isDeleted, 'N') = 'N'  
			AND ISNULL(CD.isEnable, 'Y') = 'Y'  
			AND ISNULL(CM.isActive, 'Y') = 'Y'  
			AND ISNULL(CM.isDeleted, 'N') = 'N' 
			AND ISNULL(PROFESSION, -1) = ISNULL(@professionId, -1)
		)X   
		ORDER BY X.hasDeliveryMethod DESC  
	END  
	--if not countrywise then then the rule defined for all countries  
	ELSE IF EXISTS (SELECT 1   
					FROM csMaster CM(NOLOCK)   
					INNER JOIN csDetail CD(NOLOCK) ON CD.csMasterId = CM.csMasterId  
					WHERE CM.rCountry IS NULL AND ISNULL(CM.isActive, 'Y') = 'Y' AND ISNULL(CM.isDeleted, 'N') = 'N' AND ISNULL(CM.isEnable, 'Y') = 'Y'  
					AND ISNULL(CD.isActive, 'Y') = 'Y' AND ISNULL(CD.isDeleted, 'N') = 'N' AND ISNULL(CD.isEnable, 'Y') = 'Y' AND CD.period = @period AND condition = @condition
					AND ISNULL(PROFESSION, -1) = ISNULL(@professionId, -1)) 
	BEGIN  
		INSERT INTO #COMPLIANCE_TBL
		SELECT comRuleId = comRuleId, limitAmt = limitAmt, ruleType = nextAction  
		FROM (  
			SELECT comRuleId = csDetailId, limitAmt = amount, CD.nextAction,  
				hasDeliveryMethod = CASE WHEN CD.paymentMode IS NULL THEN 0 ELSE 1 END  
			FROM dbo.csDetail CD(NOLOCK)  
			INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
			WHERE CD.period = @period  
			AND CM.rCountry IS NULL  
			AND CD.condition = @condition  
			AND ISNULL(CD.paymentMode, @deliveryMethod) = @deliveryMethod   
			AND ISNULL(CD.isActive, 'Y') = 'Y'   
			AND ISNULL(CD.isDeleted, 'N') = 'N'  
			AND ISNULL(CD.isEnable, 'Y') = 'Y'  
			AND ISNULL(CM.isActive, 'Y') = 'Y'  
			AND ISNULL(CM.isDeleted, 'N') = 'N'
			AND ISNULL(PROFESSION, -1) = ISNULL(@professionId, -1)
		)X   
		ORDER BY X.hasDeliveryMethod DESC  
	END  

	SELECT * FROM #COMPLIANCE_TBL
END