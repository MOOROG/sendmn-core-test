USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAIsAdmin]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAIsAdmin](@userName VARCHAR(30))
RETURNS CHAR(1)
AS
BEGIN
	--RETURN 'Y'
	IF (
		 EXISTS(SELECT 'X' FROM dbo.FNAGetAdmins() WHERE admin = @userName)
	) 
		RETURN 'Y'
		
	RETURN 'N'

	
END


GO
