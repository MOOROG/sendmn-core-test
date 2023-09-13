USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[ShowDecimal]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[ShowDecimal](@Amt money)
returns varchar(50)
as 
begin

	return CONVERT(VARCHAR,CAST(ISNULL(@Amt,0) AS MONEY),1)
	
end

GO
