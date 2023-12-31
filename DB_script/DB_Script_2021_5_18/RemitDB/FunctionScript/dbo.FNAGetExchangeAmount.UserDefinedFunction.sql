USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetExchangeAmount]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT dbo.FNAGetExchangeAmount('QAR', 181, 100, 10000)
CREATE FUNCTION [dbo].[FNAGetExchangeAmount](@currency VARCHAR(3), @country INT, @agent INT, @amount MONEY)
RETURNS MONEY
AS
BEGIN
	DECLARE 
		 @masterId		INT
		,@costToAgent	FLOAT
		,@xAmount		MONEY

		SELECT @masterId = defExRateId, @costToAgent = cRate + ISNULL(cMargin, 0) FROM defExRate WITH(NOLOCK) 
			WHERE ISNULL(isActive, 'N') = 'Y' AND currency = @currency AND country = @country AND agent = @agent
		
		IF @masterId IS NULL
			SELECT @masterId = defExRateId, @costToAgent = cRate + ISNULL(cMargin, 0) 
				FROM defExRate WITH(NOLOCK) WHERE ISNULL(isActive, 'N') = 'Y' AND currency = @currency AND country = @country AND agent IS NULL
	
	SELECT @xAmount = @amount * @costToAgent
	RETURN @xAmount
END
GO
