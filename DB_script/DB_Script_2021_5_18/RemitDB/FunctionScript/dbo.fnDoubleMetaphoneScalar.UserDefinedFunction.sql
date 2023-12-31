USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[fnDoubleMetaphoneScalar]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnDoubleMetaphoneScalar]( @MetaphoneType int, @Word varchar(50) )
RETURNS char(4)
AS
BEGIN
		RETURN (SELECT CASE @MetaphoneType WHEN 1 THEN Metaphone1 
WHEN 2 THEN Metaphone2 END FROM fnDoubleMetaphoneTable( @Word ))
END


GO
