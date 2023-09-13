USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAcNoFromKJLog]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetAcNoFromKJLog] (@str as Varchar(MAX))  
RETURNS varchar(100) AS  
BEGIN 
declare @x as varchar(100)

select @x = replace(replace(value,'"no":"',''),'"','') from dbo.split(',',@str)
where id=2

return (@x)
end


GO
