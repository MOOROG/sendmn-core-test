USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGMTOnline]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGMTOnline](@date DATETIME, @userName VARCHAR(100))
RETURNS DATETIME
AS
BEGIN
	--DECLARE @time_zone_from AS INT
	--DECLARE @time_zone_to AS INT
	DECLARE @NEWDATE DATETIME

	--SET @time_zone_to = ISNULL(@time_zone_to, 21)	
	--SELECT @time_zone_to = CAST(CAST(gmt AS FLOAT) AS INT) 
	--FROM timezones WITH(NOLOCK) WHERE rowID = 21	
	--SELECT @newDate = DATEADD(HH, 0, GETUTCDATE())
	
	--IF @newDate IS NULL
	SELECT @newDate = GETDATE()
	
	RETURN @NEWDATE
END
GO
