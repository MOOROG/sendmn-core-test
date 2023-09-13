USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARemitRoundForNPR]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARemitRoundForNPR](@number MONEY)
RETURNS MONEY
AS
BEGIN
	RETURN ROUND(@number - 0.01, 0)
END


GO
