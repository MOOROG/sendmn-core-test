USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAAutoApprove]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAAutoApprove](@functionId INT, @changeType CHAR(1))
RETURNS CHAR(1)
AS
BEGIN
	RETURN ISNULL((
			SELECT 
				CASE @changeType
					 WHEN 'I' THEN ISNULL(insertion, 'N')
					 WHEN 'U' THEN ISNULL(modification, 'N')
					 WHEN 'D' THEN ISNULL(deletion, 'N')
					 ELSE 'N'
				END
			FROM verificationSetup WHERE functionId = @functionId
		), 'N')
END
GO
