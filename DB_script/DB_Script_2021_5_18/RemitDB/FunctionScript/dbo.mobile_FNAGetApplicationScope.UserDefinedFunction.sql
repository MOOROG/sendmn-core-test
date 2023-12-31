USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[mobile_FNAGetApplicationScope]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[mobile_FNAGetApplicationScope]
(
	@clientId VARCHAR(100)
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @applicationScope VARCHAR(50);

	SELECT @applicationScope=scope FROM mobile_GmeApiClientRegistration(NOLOCK) WHERE clientId=@clientId
	RETURN @applicationScope	
END

GO
