USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAccName]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select dbo.[FNAGetAccName]('201000242')
CREATE FUNCTION [dbo].[FNAGetAccName](@str varchar(50))
RETURNS VARCHAR(50)
AS
BEGIN

	DECLARE @Result VARCHAR(50)
	
	SELECT @Result=acct_name FROM ac_master WHERE acct_num=@str
	RETURN @Result;

END

GO
