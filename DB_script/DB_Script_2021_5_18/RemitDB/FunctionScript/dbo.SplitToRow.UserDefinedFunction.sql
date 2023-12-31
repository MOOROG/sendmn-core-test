USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitToRow]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[SplitToRow] (@delimeter CHAR(1), @list VARCHAR(8000))
RETURNS @Recordlist TABLE (fname VARCHAR(50), MNAME VARCHAR(50), LNAME VARCHAR(50),SLNAME VARCHAR(50))
AS
BEGIN
DECLARE @FVAL INT ,@SVAL INT ,@TVAL INT ,@FOVAL INT
----------
	SET @FVAL=(SELECT SUM(CASE WHEN ID=1 THEN LEN(value) END) FROM Split(@delimeter,@list))
	SET @SVAL=(SELECT SUM(CASE WHEN ID=2 THEN LEN(value) END) FROM Split(@delimeter,@list))
	SET @TVAL=(SELECT SUM(CASE WHEN ID=3 THEN LEN(value) END) FROM Split(@delimeter,@list))
	SET @FOVAL=(SELECT SUM(CASE WHEN ID>=4 THEN LEN(value) END) FROM Split(@delimeter,@list))
------------
    ----SELECT SUBSTRING(@list,0,charindex(@delimeter,@list)) [fname]
    ----,SUBSTRING(@list,charindex(@delimeter,@list)+1,charindex(@delimeter,@list,charindex(' ',@list)+1-charindex(@delimeter,@list))) [mname]
    ----,SUBSTRING(@list,charindex(@delimeter,@list,charindex(@delimeter,@list)+1)+1,LEN(@list))[lname]
    INSERT INTO @Recordlist
    SELECT SUBSTRING(@list,0,charindex(@delimeter,@list)) [fname]
    ,SUBSTRING(@list,@FVAL+2,@SVAL) [mname]
	,SUBSTRING(@list,@FVAL+@SVAL+3,@TVAL) [lname]
	,SUBSTRING(@list,@FVAL+@SVAL+@TVAL+4,LEN(@list)) [Slname]

	RETURN 
END

GO
