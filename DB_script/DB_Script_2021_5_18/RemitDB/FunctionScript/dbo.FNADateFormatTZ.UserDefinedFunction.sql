USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNADateFormatTZ]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNADateFormatTZ](@date DATETIME, @userName VARCHAR(30))
RETURNS DATETIME
AS
BEGIN
	RETURN GETDATE()
END






GO
