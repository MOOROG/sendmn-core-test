USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetPayoutLimit]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
SELECT *
			FROM dbo.FNAGetPayoutLimit('181', '151', NULL, '2')
			SELECT  cm.currencyCode
	FROM countryCurrency cc INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId
	WHERE cc.countryId = 151 and 
	select * from currencyMaster

	delete from countryCurrency where isDeleted = 'Y'


	SELECT * FROM dbo.FNAGetPayoutLimit(133, 16, 1212, 1)
*/
create FUNCTION [dbo].[FNAGetPayoutLimit](
	 @sCountry INT
	,@rCountry INT
	,@rAgent INT
	,@deliveryMethod INT
)
RETURNS @list TABLE (masterId BIGINT, maxLimitAmt MONEY, currency VARCHAR(3))
AS
BEGIN
	DECLARE @pCurr VARCHAR(3), @rtlId INT
	SELECT @pCurr = cm.currencyCode 
	FROM countryCurrency cc INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId
	WHERE cc.countryId = @rCountry
	
	IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE sendingCountry = @sCountry
				AND countryId = @rCountry AND (agentId = @rAgent OR agentId IS NULL) AND currency = @pCurr
				AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
				AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
				)
	BEGIN
		SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
		WHERE sendingCountry = @sCountry AND countryId = @rCountry AND agentId = @rAgent AND currency = @pCurr 
		AND tranType = @deliveryMethod AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @rtlId IS NULL			
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
			WHERE sendingCountry = @sCountry AND countryId = @rCountry AND agentId = @rAgent AND currency = @pCurr 
			AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @rtlId IS NULL
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
			WHERE sendingCountry = @sCountry AND countryId = @rCountry AND agentId IS NULL AND currency = @pCurr 
			AND tranType = @deliveryMethod AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		
		IF @rtlId IS NULL
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
			WHERE sendingCountry = @sCountry AND countryId = @rCountry AND agentId IS NULL AND currency = @pCurr 
			AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'	
	END
	IF @rtlId IS NULL
	BEGIN
		IF EXISTS(SELECT 'X' FROM receiveTranLimit WITH(NOLOCK) WHERE sendingCountry IS NULL
					AND countryId = @rCountry AND (agentId = @rAgent OR agentId IS NULL) AND currency = @pCurr
					AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
					AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
					)
		BEGIN
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
			WHERE sendingCountry IS NULL AND countryId = @rCountry AND agentId = @rAgent AND currency = @pCurr 
			AND tranType = @deliveryMethod AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
			
			IF @rtlId IS NULL			
				SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
				WHERE sendingCountry IS NULL AND countryId = @rCountry AND agentId = @rAgent AND currency = @pCurr 
				AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
			
			IF @rtlId IS NULL
				SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
				WHERE sendingCountry IS NULL AND countryId = @rCountry AND agentId IS NULL AND currency = @pCurr 
				AND tranType = @deliveryMethod AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
			
			IF @rtlId IS NULL
				SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK)
				WHERE sendingCountry IS NULL AND countryId = @rCountry AND agentId IS NULL AND currency = @pCurr 
				AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'	
		END
	END
	INSERT INTO @list
	SELECT rtlId, maxLimitAmt, currency FROM receiveTranLimit 
	WITH(NOLOCK) WHERE rtlId = @rtlId
	
	RETURN
END
GO
