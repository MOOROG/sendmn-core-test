USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAPIStatus]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetAPIStatus](@provider INT)
RETURNS INT 
AS

BEGIN
	DECLARE @status INT	
	SET @status = 0
	IF @provider = '37402'				--Global IME Bank
		SET @status = 0
	
	RETURN @status
END

GO
