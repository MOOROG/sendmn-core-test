USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitXML]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[SplitXML] (@sep VARCHAR(32), @s VARCHAR(MAX))

RETURNS @t TABLE
    (
        val VARCHAR(MAX)
    )   
AS
    BEGIN

        DECLARE @xml XML
        SET @XML = N'<root><r>' + REPLACE(@s, @sep, '</r><r>') + '</r></root>'

        INSERT INTO @t(val)
        SELECT r.value('.','VARCHAR(20)') as Item
        FROM @xml.nodes('//root/r') AS RECORDS(r)

        RETURN
    END


GO
