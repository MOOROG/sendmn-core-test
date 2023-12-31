USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACheckSlab]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNACheckSlab](@pcnt MONEY,@minAmt MONEY,@maxAmt MONEY)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @MSG VARCHAR(100) = 'Y'
	IF(ISNULL(@pcnt,0)!=0 )
	BEGIN
		IF(@minAmt IS NULL OR @maxAmt IS NULL)
		BEGIN
			SET @MSG = 'Min or Max Amt can not be null..'
		END
	END
		
	IF(@pcnt IS NULL AND @minAmt IS NULL)
	BEGIN
		SET @MSG = 'Min Amt can not be null..'
	END
	RETURN @MSG
END


GO
