USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCountryName]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetCountryName](@countryCode VARCHAR(2))
RETURNS VARCHAR(100)
AS

BEGIN
	DECLARE @countryName VARCHAR(100)
	SET @countryCode= CASE @countryCode WHEN 'UK' THEN 'GB' ELSE @countryCode END
	SELECT TOP 1 @countryName = countryName FROM dbo.countryMaster WITH(NOLOCK) WHERE countryCode = @countryCode
	
	RETURN (@countryName)
END

--SELECT dbo.FNAGetCountryName('UK')

GO
