USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitDenos]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUnction [dbo].[SplitDenos](@denos VARCHAR(100)) 
RETURNS @TEMP TABLE (deno VARCHAR(10), PCS INT,rAmt int)
AS
BEGIN

DECLARE @rAmt MONEY 
	IF CHARINDEX('|',@denos) = 0
		SET @rAmt = 0
	ELSE
	BEGIN
		SET @rAmt = RIGHT(@denos,LEN(@denos)-CHARINDEX('|',@denos))
		SET @denos = LEFT(@denos,CHARINDEX('|',@denos)-1)
	END

INSERT INTO @TEMP(deno)
SELECT *  FROM dbo.SplitXML(',',@denos)

UPDATE @TEMP SET deno = LEFT(deno,CHARINDEX(':',deno)-1),PCS = RIGHT(deno,LEN(deno)-CHARINDEX(':',deno)),rAmt = @rAmt

RETURN
----SELECT LEFT(@A,CHARINDEX(':',@A)-1),RIGHT(@A,LEN(@A)-CHARINDEX(':',@A)),CHARINDEX(':',@A)
END


GO
