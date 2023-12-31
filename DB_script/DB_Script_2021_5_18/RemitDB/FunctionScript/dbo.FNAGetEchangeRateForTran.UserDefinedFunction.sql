USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetEchangeRateForTran]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetEchangeRateForTran](@ssAgent BIGINT, @sending BIGINT, @rsAgent BIGINT, @receiving BIGINT, @collCurr INT, @payCurr INT, @isAnywhere CHAR(1), @isTranMode CHAR(1), @user VARCHAR(30))
RETURNS MONEY

BEGIN
	DECLARE 
		 @exRate MONEY
		,@rType CHAR(1)		
		
	SET @rType = CASE WHEN @isAnywhere = 'Y' THEN 'c' ELSE 'a' END
	
	SELECT 
		@exRate = crossRate
	FROM [dbo].FNAGetEchangeRate(@ssAgent, @sending, @rsAgent, @receiving, @collCurr, @payCurr, 'a', @rType, @isTranMode, @user)
	
	RETURN @exRate
END
GO
