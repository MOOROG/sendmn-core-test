USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAReturnCurrentFiscalYear]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[FNAReturnCurrentFiscalYear](@eng_date datetime)
RETURNS varchar(20) AS  
BEGIN 

	declare @ret varchar(20)
	
	SELECT @ret= FISCAL_YEAR_NEPALI  from FiscalYear  with(nolock)
	where @eng_date between EN_YEAR_START_DATE and EN_YEAR_END_DATE

	return @ret
END
GO
