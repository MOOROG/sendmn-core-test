USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetHOAgentId]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetHOAgentId]()
RETURNS INT
AS
BEGIN
	DECLARE @Result INT
	SELECT @Result = 1001
	RETURN @Result
END
GO
