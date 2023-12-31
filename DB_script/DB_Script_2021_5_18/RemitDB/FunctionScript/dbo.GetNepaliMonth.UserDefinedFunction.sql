USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[GetNepaliMonth]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[GetNepaliMonth](@eng_date datetime)
RETURNS int AS  
BEGIN 
	declare @ret varchar(20)
	declare @nepali_month varchar(20)
	select @ret=nep_date from tbl_calendar
	where eng_date = @eng_date
	
	select @nepali_month=left(@ret,2)
	return @nepali_month
END

GO
