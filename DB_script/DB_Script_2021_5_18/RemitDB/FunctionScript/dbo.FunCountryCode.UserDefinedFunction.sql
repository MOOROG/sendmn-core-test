USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FunCountryCode]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FunCountryCode] (@mobileNo as Varchar(20))  
RETURNS varchar(100) AS  
BEGIN 
declare @Code varchar(2)

	SELECT @Code = CountryCode FROM COUNTRYMASTER(NOLOCK) where countryName = @mobileNo

RETURN @Code
end

---- SELECT [dbo].FunContactAPI_MobileFormat('82101233221')




GO
