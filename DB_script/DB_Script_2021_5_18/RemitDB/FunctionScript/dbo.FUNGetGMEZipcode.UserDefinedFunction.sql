USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNGetGMEZipcode]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FUNGetGMEZipcode] (@AgentId BIGINT)  
RETURNS varchar(100) AS  
BEGIN 
declare  @ZipCode varchar(100)
	SELECT @ZipCode = 'A' + RIGHT('000000'+CAST(swiftCode AS VARCHAR(6)),6) FROM agentMaster(NOLOCK) WHERE agentId = @AgentId
return (@ZipCode)
end






GO
