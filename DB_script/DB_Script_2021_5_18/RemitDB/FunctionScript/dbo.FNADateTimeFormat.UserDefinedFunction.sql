USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNADateTimeFormat]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- This function converst a datatime to ADIHA DateTime format 
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
-- type = 1  Jan 2, 1967 hh:mm:ss
-- type = 2  1/2/1967 hh:mm:ss

CREATE FUNCTION [dbo].[FNADateTimeFormat](
	 @DATE DATETIME
	,@user VARCHAR(50)
)

RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FNADateTimeFormat AS VARCHAR(50)
	DECLARE @hh INT
	DECLARE @mm INT
	DECLARE @ss INT

	SET @DATE = dbo.FNADateFormatTZ(@DATE, @user)
	SET @hh = DATEPART(hh, @DATE)
	SET @mm = DATEPART(mi, @DATE)
	SET @ss = DATEPART(ss, @DATE)
	
	SET @FNADateTimeFormat =  dbo.FNAGetGenericDate(@DATE, @user) + ' ' + 
		CASE WHEN @hh<10 THEN '0' ELSE '' END + CAST(@hh AS VARCHAR) +':'+ 
		CASE WHEN @mm<10 THEN '0' ELSE '' END + CAST(@mm AS VARCHAR) +':'+
		CASE WHEN @ss<10 THEN '0' ELSE '' END + CAST(@ss AS VARCHAR) 

	RETURN(@FNADateTimeFormat)
END











GO
