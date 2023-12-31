USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[ShowDecimalExceptComma]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[ShowDecimalExceptComma](@Amt money)
returns varchar(50)
as 
begin

	return CONVERT(VARCHAR,CAST(ISNULL(@Amt,0) AS MONEY),0)
	
end
GO
