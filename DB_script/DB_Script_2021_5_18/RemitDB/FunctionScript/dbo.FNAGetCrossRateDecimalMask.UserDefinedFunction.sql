USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCrossRateDecimalMask]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	SELECT [dbo].FNAGetCrossRateDecimalMask('MYR','BDT')
*/	
        
CREATE FUNCTION [dbo].[FNAGetCrossRateDecimalMask](@cCurrency VARCHAR(3), @pCurrency VARCHAR(3))
RETURNS INT
AS  
BEGIN
	DECLARE @afterDecimalValue INT
	
	SELECT @afterDecimalValue = rateMaskAd FROM crossRateDecimalMask WITH(NOLOCK) WHERE cCurrency = @cCurrency AND pCurrency = @pCurrency
	IF @afterDecimalValue IS NULL
		SELECT @afterDecimalValue = ISNULL(rateMaskAd, 10) FROM crossRateDecimalMask WITH(NOLOCK) WHERE cCurrency IS NULL AND pCurrency = @pCurrency
	
	RETURN ISNULL(@afterDecimalValue, 10)
END
GO
