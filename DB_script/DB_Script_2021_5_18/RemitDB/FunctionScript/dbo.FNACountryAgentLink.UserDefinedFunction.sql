USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACountryAgentLink]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNACountryAgentLink](
	 @linkText	VARCHAR(100)
	,@agentId INT
	,@s_country INT
	,@p_country INT
)
RETURNS VARCHAR(1000)
AS
BEGIN
	DECLARE @agentLinkText VARCHAR(1000)
	SET @agentLinkText = '<a class = "link" href = "../agent-agent/List.aspx?agentId=@AGENT_ID&s_countryId=@S_COUNTRY_ID&p_countryId=@P_COUNTRY_ID">' + @linkText + '</a>'
	SET @agentLinkText = REPLACE(@agentLinkText, '@AGENT_ID', CAST(@agentId AS VARCHAR(50)))
	SET @agentLinkText = REPLACE(@agentLinkText, '@S_COUNTRY_ID', CAST(@s_country AS VARCHAR(50)))
	SET @agentLinkText = REPLACE(@agentLinkText, '@P_COUNTRY_ID', CAST(@p_country AS VARCHAR(50)))
	RETURN @agentLinkText
END


GO
