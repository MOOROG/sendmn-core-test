USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FunGetPayoutPartner]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---- SELECT DBO.[FunGetPayoutPartner](151,1)

create FUNCTION [dbo].[FunGetPayoutPartner] (@CountryId INT,@PaymentMethodId INT)  
RETURNS INT AS  
BEGIN 

DECLARE @PayPartnerId INT

	SELECT @PayPartnerId = AgentId FROM TblPartnerwiseCountry(nolock) 
	WHERE CountryId = @CountryId AND ISNULL(PaymentMethod,@PaymentMethodId) = @PaymentMethodId AND IsActive = 1

return (@PayPartnerId)
end







GO
