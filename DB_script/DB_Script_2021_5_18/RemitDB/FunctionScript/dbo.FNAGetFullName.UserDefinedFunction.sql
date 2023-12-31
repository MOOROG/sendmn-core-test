USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetFullName]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetFullName](@firstName VARCHAR(50), @middleName VARCHAR(50), @lastName1 VARCHAR(50), @lastName2 VARCHAR(50))
RETURNS VARCHAR(200)
AS
BEGIN
	RETURN @firstName + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')
END

GO
