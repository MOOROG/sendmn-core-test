USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FunGetGLCode]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[FunGetGLCode](@str varchar(50))
returns varchar(50)
as
begin

	declare @Result varchar(50)
	
	select @Result=gl_code from ac_master where acct_num=@str
	return @Result;
	
end

GO
