USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACountryLink]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNACountryLink](
	 @linkText	VARCHAR(100)
	,@s_country INT
	,@p_country INT
)
RETURNS VARCHAR(1000)
AS
BEGIN
	DECLARE @agentLinkText VARCHAR(1000)
	SET @agentLinkText = '<a class = "link" href = "../country-agent/List.aspx?s_countryId=@S_COUNTRY_ID&p_countryId=@P_COUNTRY_ID">' + @linkText + '</a>'
	
	SET @agentLinkText = REPLACE(@agentLinkText, '@S_COUNTRY_ID', CAST(@s_country AS VARCHAR(50)))
	SET @agentLinkText = REPLACE(@agentLinkText, '@P_COUNTRY_ID', CAST(@p_country AS VARCHAR(50)))
	RETURN @agentLinkText
END


GO
