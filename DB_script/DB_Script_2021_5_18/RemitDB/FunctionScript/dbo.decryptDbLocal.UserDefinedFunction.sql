USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[decryptDbLocal]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[decryptDbLocal] (@str as Varchar(100))  
RETURNS varchar(100) AS  
BEGIN 
declare  @y varchar(100),@x as varchar(100)
set @x=''
declare  @i int
set @i=1
	while @i <= len(@str)
	begin
		set @y =  convert(varchar(10),Char(ASCII(SUBSTRING(@str, @i, 1)) - 25))
		set @x=@x+@y
		set @i=@i+1
	END
return (@x)
end



GO
