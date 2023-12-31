USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetNepaliDate]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select [dbo].[FNAGetEnglishDate]('01-01-2068')
select [dbo].[FNAGetNepaliDate]('04/14/2011')

select * from tblcalendar
*/

CREATE FUNCTION  [dbo].[FNAGetNepaliDate](@eng_date DATETIME)
RETURNS VARCHAR(20) AS  
BEGIN 
	DECLARE @ret VARCHAR(20)
	SELECT @ret=nep_date FROM tblCalendar
	WHERE eng_date = @eng_date

	RETURN @ret
END
GO
