USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FunGetWalletName]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[FunGetWalletName](@WalletNo varchar(30))
returns varchar(100)
as
begin

	declare @Result varchar(50)

	select @Result = firstName from CustomerMaster(nolock) where WalletAccountNo = @WalletNo
	return @Result;
	
end

--select dbo.FunGetWalletName('9424010020104')
GO
