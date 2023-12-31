USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[fnIsVowel]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnIsVowel]( @c char(1) )
RETURNS bit
AS
BEGIN
	IF (@c = 'A') OR (@c = 'E') OR (@c = 'I') OR (@c = 'O') OR (@c = 'U') OR (@c = 'Y') 
	BEGIN
		RETURN 1
	END
	--'ELSE' would worry SQL Server, it wants RETURN last in a scalar function
	RETURN 0
END

GO
