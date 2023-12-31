USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDomesticSCAmt]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetDomesticSCAmt](@masterId BIGINT, @transferAmount MONEY)
RETURNS MONEY
AS
BEGIN	
	DECLARE
		 @minAmt MONEY
		,@maxAmt MONEY
		,@pcntAmt MONEY
		
	SELECT 
		 @pcntAmt = @transferAmount * serviceChargePcnt / 100.0
		,@minAmt = serviceChargeMinAmt
		,@maxAmt = serviceChargeMaxAmt
	FROM scDetail 
	WHERE 
		ISNULL(isActive, 'N') = 'Y'
		AND ISNULL(isDeleted, 'N') = 'N'
		AND scMasterId = @masterId
		AND @transferAmount BETWEEN fromAmt and toAmt
			
	RETURN (		
	SELECT		
		CASE 
			WHEN @pcntAmt < @minAmt THEN @minAmt 
			WHEN @pcntAmt > @maxAmt THEN @maxAmt
			ELSE @pcntAmt
		END
	)
END
GO
