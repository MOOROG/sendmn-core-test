USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetSCAmt]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetSCAmt](@masterId BIGINT, @masterType CHAR(1), @transferAmount MONEY)
RETURNS MONEY
AS
BEGIN	
	DECLARE
		 @minAmt MONEY
		,@maxAmt MONEY
		,@pcntAmt MONEY
		
	IF @masterType = 'S'
	BEGIN
		SELECT 
			 @pcntAmt = @transferAmount * pcnt / 100.0
			,@minAmt = minAmt
			,@maxAmt = maxAmt
		FROM sscDetail 
		WHERE 
			ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') = 'N'
			AND sscMasterId = @masterId
			AND @transferAmount BETWEEN fromAmt and toAmt
			
	END
	ELSE
	BEGIN
		SELECT 
			 @pcntAmt = @transferAmount * pcnt / 100.0
			,@minAmt = minAmt
			,@maxAmt = maxAmt
		FROM dscDetail 
		WHERE
			ISNULL(isActive, 'N') = 'Y'
			AND ISNULL(isDeleted, 'N') = 'N' 
			AND dscMasterId = @masterId
			AND @transferAmount BETWEEN fromAmt and toAmt
	END
	
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
