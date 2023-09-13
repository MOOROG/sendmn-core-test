USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCustomerRateTP]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create FUNCTION [dbo].[FNAGetCustomerRateTP](@cCountry INT, @cAgent INT, @cBranch INT, @cCurrency VARCHAR(3), @pCountry INT, @pAgent INT, @pCurrency VARCHAR(3), @tranType INT, @payoutPartner INT)
RETURNS @EX_RATE TABLE(customerRate FLOAT, sCurrCostRate FLOAT, pCurrCostRate FLOAT, sCurrHOMargin FLOAT, pCurrHOMargin FLOAT, sCurrAgentMargin FLOAT, pCurrAgentMargin FLOAT)
AS
BEGIN
	INSERT INTO @EX_RATE
	SELECT customerRate = CASE WHEN ISNULL(OVERRIDE_CUSTOMER_RATE, 0) = 0 THEN PARTNER_CUSTOMER_RATE ELSE OVERRIDE_CUSTOMER_RATE END,
			sCurrCostRate = 1,
			pCurrCostRate = CASE WHEN ISNULL(OVERRIDE_CUSTOMER_RATE, 0) = 0 THEN PARTNER_SETTLEMENT_RATE ELSE 0 END,
			sCurrMargin = 0,
			pCurrMargin = CASE WHEN ISNULL(OVERRIDE_CUSTOMER_RATE, 0) = 0 THEN -1 * RATE_MARGIN_OVER_PARTNER_RATE ELSE 0 END,
			sCurrAgentMargin = 0,
			pCurrAgentMargin = 0
	FROM TP_API_RATE_SETUP 
	WHERE SENDING_COUNTRY = @cCountry
	AND PAYOUT_COUNTRY = @pCountry
	AND SENDING_CURRENCY = @cCurrency
	AND PAYOUT_CURRENCY = @pCurrency
	AND PAYOUT_PARTNER = @payoutPartner
	AND IS_ACTIVE = 1

	RETURN
END


GO
