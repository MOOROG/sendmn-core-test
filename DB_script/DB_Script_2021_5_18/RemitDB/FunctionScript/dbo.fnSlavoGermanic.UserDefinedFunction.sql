USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[fnSlavoGermanic]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnSlavoGermanic]( @Word char(50) )
RETURNS bit
AS
BEGIN
	--Catch NULL also...
	IF (CHARINDEX('W',@Word) > 0) OR (CHARINDEX('K',@Word) > 0) OR 
(CHARINDEX('CZ',@Word) > 0)

	--'WITZ' test is in original Lawrence Philips C++ code, but appears to be a subset of the first test for 'W'
	-- OR (CHARINDEX('WITZ',@Word) > 0)

	BEGIN
		RETURN 1
	END
	--ELSE
		RETURN 0
END

GO
