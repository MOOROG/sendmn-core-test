USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAccountNumber]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetAccountNumber](@gl_code VARCHAR(6), @randomValue VARCHAR(30))
RETURNS VARCHAR(20) AS
BEGIN
	DECLARE  @acNumber VARCHAR(20)
			,@bookedId VARCHAR(20)
			,@uniqueNum VARCHAR(2) 
	
	IF LEN(@gl_code) = 1
		SET @gl_code = @gl_code + '0'
		
	SET @gl_code = LEFT(@gl_code,2)
	
	SELECT @bookedId = 1 + IDENT_CURRENT('ac_master')
	--SET @uniqueNum = REPLACE(RIGHT((CAST(@randomValue AS FLOAT) * 5), 1), '.', '0')
	
	SELECT @acNumber = CAST(@gl_code AS VARCHAR) + CAST(@bookedId AS VARCHAR) + CAST(@uniqueNum AS VARCHAR)
	
	RETURN @acNumber
END

GO
