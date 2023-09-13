USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAFormatNumber]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create FUNCTION [dbo].[FNAFormatNumber](@x int)
RETURNS varchar(5) AS  
BEGIN 
	declare @ret varchar(5)
	if @x < 10
		set @ret='0'+cast(@x as varchar)
	else
		set @ret=cast(@x as varchar)
	return @ret
END



GO
