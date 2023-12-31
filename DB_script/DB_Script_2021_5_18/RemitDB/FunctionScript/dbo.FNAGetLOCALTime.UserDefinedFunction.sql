USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetLOCALTime]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetLOCALTime] 
	(@Date AS DATETIME, 
	 @Timezone AS INT)
RETURNS DATETIME
AS
BEGIN
-- DECLARE VARIABLES
	DECLARE @NEWDT AS DATETIME
	DECLARE @OFFSETHR AS INT
	DECLARE @OFFSETMI AS INT
	DECLARE @DSTOFFSETHR AS INT
	DECLARE @DSTOFFSETMI AS INT
	DECLARE @DSTDT AS VARCHAR(10)
	DECLARE @DSTEFFDT AS VARCHAR(10)
	DECLARE @DSTENDDT AS VARCHAR(10)
	
-- GET THE DST parameter from the provided datetime
	-- This gets the month of the datetime provided (2 char value)
	SELECT @DSTDT = CASE LEN(DATEPART(month, @Date)) WHEN 1 then '0' + CONVERT(VARCHAR(2),DATEPART(month, @Date)) ELSE CONVERT(VARCHAR(2),DATEPART(month, @Date)) END
	-- This gets the occurance of the day of the week within the month (i.e. first sunday, or second sunday...) (1 char value)
	SELECT @DSTDT = @DSTDT + CONVERT(VARCHAR(1),(DATEPART(day,@Date) + 6) / 7)
	-- This gets the day of the week for the provided datetime (1 char value)
	SELECT @DSTDT = @DSTDT + CONVERT(VARCHAR(1),DATEPART(dw, @Date))
	-- This gets the hour for the provided datetime (2 char value)
	SELECT @DSTDT = @DSTDT + CASE LEN(DATEPART(hh, @Date)) WHEN 1 then '0' + CONVERT(VARCHAR(2),DATEPART(hh, @Date)) ELSE CONVERT(VARCHAR(2),DATEPART(hh, @Date)) END
	-- This gets the minutes for the provided datetime (2 char value)
	SELECT @DSTDT = @DSTDT + CASE LEN(DATEPART(mi, @Date)) WHEN 1 then '0' + CONVERT(VARCHAR(2),DATEPART(mi, @Date)) ELSE CONVERT(VARCHAR(2),DATEPART(mi, @Date)) END
	
	-- This query gets the timezone information from the TIME_ZONES table for the provided timezone
	SELECT
		@OFFSETHR=offset_hr,
		@OFFSETMI=offset_mi,
		@DSTOFFSETHR=dst_offset_hr,
		@DSTOFFSETMI=dst_offset_mi,
		@DSTEFFDT=dst_eff_dt,
		@DSTENDDT=dst_END_dt
	FROM time_zones
	WHERE timezone_id = @Timezone AND
		@Date BETWEEN eff_dt AND end_dt
	
	-- Checks to see if the DST parameter for the datetime provided is within the DST parameter for the timezone
	IF @DSTDT BETWEEN @DSTEFFDT AND @DSTENDDT
	BEGIN
		-- Increase the datetime by the hours and minutes assigned to the timezone
		SET @NEWDT = DATEADD(hh,@DSTOFFSETHR,@Date)
		SET @NEWDT = DATEADD(mi,@DSTOFFSETMI,@NEWDT)
	END
	-- If the DST parameter for the provided datetime is not within the defined
	-- DST eff and end dates for the timezone then use the standard time offset
	ELSE
	BEGIN
		-- Increase the datetime by the hours and minutes assigned to the timezone
		SET @NEWDT = DATEADD(hh,@OFFSETHR,@Date)
		SET @NEWDT = DATEADD(mi,@OFFSETMI,@NEWDT)
	END

	-- Return the new date that has been converted from UTC time
	RETURN @NEWDT
END


GO
