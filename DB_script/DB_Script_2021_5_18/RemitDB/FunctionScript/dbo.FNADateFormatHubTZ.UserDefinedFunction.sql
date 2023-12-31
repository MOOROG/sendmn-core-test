USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNADateFormatHubTZ]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNADateFormatHubTZ](@date DATETIME)
RETURNS DATETIME
AS
BEGIN
	DECLARE @time_zone_from AS INT
	DECLARE @time_zone_to AS INT
	DECLARE @NEWDATE DATETIME

	-- Find Out System Defined Time Zone
	SELECT 
		 @time_zone_from = dbTZ
		,@time_zone_to = hubTZ
	FROM timezoneSettings 
	WHERE ID = 1

	
	
	IF @time_zone_to IS NULL
		SET @time_zone_to=@time_zone_from

	IF @time_zone_from = @time_zone_to
		RETURN @date

	-- Check to see if the provided timezone for the source datetime is in GMT or UTC time
	-- If it is not then convert the provided datetime to UTC time
	IF NOT @time_zone_from IN (14)
	BEGIN
		SELECT @NEWDATE = dbo.FNAGetUTCTTime(@Date,@time_zone_from)
	END
	ELSE
	-- If the provided datetime is in UTC or GMT time then set the NEWTIME variable to this value
	BEGIN
		SET @NEWDATE = @Date
	END

	-- Check to see if the provided conversion timezone is GMT or UTC
	-- If it is then no conversion is needed.
	-- If it is not then convert the provided datetime to the desired timezone
	IF NOT @time_zone_to IN (14)
	BEGIN
		SELECT @NEWDATE = dbo.FNAGetLOCALTime(@NEWDATE,@time_zone_to)
	END

	-- Return the new date that has been converted from UTC time
	RETURN @NEWDATE
END




GO
