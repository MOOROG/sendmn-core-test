USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetGLCode]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetGLCode](@str varchar(50))
RETURNS VARCHAR(50)
AS
BEGIN

	DECLARE @Result VARCHAR(50)
	
	SELECT @Result=gl_code FROM ac_master WHERE acct_num=@str
	RETURN @Result;
	
END

GO
