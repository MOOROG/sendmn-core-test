USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Split] (@delimeter CHAR(1), @list VARCHAR(MAX))
RETURNS @t TABLE
    (
		id INT IDENTITY(1,1)
       ,value VARCHAR(MAX)
    )   
AS
BEGIN
	INSERT INTO @t(value)
	SELECT val FROM dbo.SplitXML(@delimeter, @list)
	RETURN
END

--SELECT * FROM dbo.Split(',', '1,2,3,607,99,78')

GO
