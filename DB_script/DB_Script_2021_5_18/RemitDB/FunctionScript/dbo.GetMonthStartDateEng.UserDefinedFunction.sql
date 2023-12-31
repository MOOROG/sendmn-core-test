USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMonthStartDateEng]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetMonthStartDateEng]
(
	@year AS varchar(20), 
	@Month AS varchar(20) 
)

RETURNS NVARCHAR(4000)
AS
BEGIN

	declare @values date
	if len(@Month)=1
		set @Month='0'+ @Month
	
	select @values= MIN(eng_date) from tbl_calendar
	where eng_date between (SELECT EN_YEAR_START_DATE from FiscalYear where FISCAL_YEAR_NEPALI=@year)
	and (SELECT EN_YEAR_end_DATE from FiscalYear where FISCAL_YEAR_NEPALI=@year)
	and substring(nep_date,1,2)=@Month
	RETURN (@values)
END
GO
