USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDataValue]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[FNAGetDataValue](@valueId int)
returns char(100)
as 
begin

	declare @DetailTitle as varchar(100)
	set @DetailTitle = (select detailTitle  from staticDataValue WHERE valueId = @valueId)
	return @DetailTitle
end



GO
