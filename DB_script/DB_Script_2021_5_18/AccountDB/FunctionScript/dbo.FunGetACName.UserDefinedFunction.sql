USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FunGetACName]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FunGetACName](@str varchar(50))
returns varchar(50)
as
begin

	declare @Result varchar(50)

	select @Result = acct_name from ac_master(nolock) where acct_num = @str
	return @Result;
	
end




GO
