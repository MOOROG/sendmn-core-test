USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCustomerRate]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetCustomerRate]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].FNAGetCustomerRate
GO
*/
/*
	SELECT dbo.FNAGetCustomerRate(133,13345,NULL,'MYR',16,NULL,'BDT',NULL)
*/
CREATE FUNCTION [dbo].[FNAGetCustomerRate](@cCountry INT, @cAgent INT, @cBranch INT, @cCurrency VARCHAR(3), @pCountry INT, @pAgent INT, @pCurrency VARCHAR(3), @tranType INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @customerRate FLOAT
	
	SELECT @customerRate = customerRate FROM dbo.FNAGetExRate(@cCountry, @cAgent, @cBranch, @cCurrency, @pCountry, @pAgent, @pCurrency, @tranType)
	
	RETURN @customerRate
END
GO
