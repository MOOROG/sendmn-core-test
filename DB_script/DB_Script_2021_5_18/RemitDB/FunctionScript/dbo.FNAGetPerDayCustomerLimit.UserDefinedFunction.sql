USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetPerDayCustomerLimit]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetPerDayCustomerLimit](@agentId VARCHAR(30))
RETURNS MONEY
AS  
BEGIN
		DECLARE @countryId INT, @collCurr VARCHAR(5), @amount AS MONEY
		SELECT @countryId = countryId,
			   @collCurr  = b.currencyCode 
		FROM countryCurrency a WITH(NOLOCK) 
		INNER JOIN currencyMaster b WITH( NOLOCK) ON a.currencyId = b.currencyId 
		INNER JOIN agentMaster c with(nolock) on a.countryId= c.agentCountryId
		WHERE c.agentId=@agentId
		and ISNULL(a.isActive,'Y')='Y'
		AND ISNULL(a.isDeleted,'N') = 'N'
		AND ISNULL(a.isDefault, 'N') = 'Y'

		SELECT @amount = dbo.FNAGetExchangeAmount('JPY', @countryId, @agentId, '1500000') 

		RETURN @amount
END







GO
