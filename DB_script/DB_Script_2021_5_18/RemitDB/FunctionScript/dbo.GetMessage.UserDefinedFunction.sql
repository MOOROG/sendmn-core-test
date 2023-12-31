USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMessage]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetMessage]
(
	@language VARCHAR(100),@code VARCHAR(100)
)
RETURNS NVARCHAR(1000)
AS
BEGIN
	DECLARE @msg NVARCHAR(1000)
	SELECT @msg=Msg FROM tbl_Message(nolock) WHERE Code=@code AND Language=@language
	RETURN @msg

END
GO
