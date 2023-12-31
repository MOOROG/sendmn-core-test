USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetGenericDate]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--This function returns the date in standard format defined in the region table
--Each user will be assigned a region and hence date format
--select dbo.FNAGetGenericDate('2003-1-31')
CREATE FUNCTION [dbo].[FNAGetGenericDate](@aDate datetime, @user_login_id varchar(50))
RETURNS Varchar(50)
AS
BEGIN

	DECLARE @format varchar(20)
	DECLARE @FNAGetGenericDate varchar(50)
	
	DECLARE @year varchar(20)
	DECLARE @month varchar(20)
	DECLARE @day varchar(20)
	DECLARE @monthI Int
	DECLARE @dayI Int
	
	
	SET @monthI = MONTH(@aDate)
	SET @dayI = DAY(@aDate)

	SET @year = CAST (YEAR(@aDate) AS VARCHAR)
	SET @month = CASE WHEN (@monthI < 10) then '0' else '' end + 
			CAST (@monthI AS VARCHAR)
	SET @day = CASE WHEN (@dayI < 10) then '0' else '' end + 
			CAST (@dayI AS VARCHAR)
	
	SET @format = 'mm/dd/yyyy'
	
	--SELECT @format = date_format from APPLICATION_USERS AU INNER JOIN 
	--	REGION r ON r.region_id = AU.region_id AND AU.user_login_id = @user_login_id
	
	--select @format
	SET @FNAGetGenericDate = REPLACE(REPLACE(REPLACE(@format, 'mm', @month), 'dd', @day), 'yyyy', @year)
	--set @FNAGetGenericDate = CASE 	
	--				WHEN (@format = 'mm/dd/yyyy') THEN
	--					@month + '/' + @day + '/' + @year
	--				WHEN (@format = 'mm-dd-yyyy') THEN
	--					@month + '-' + @day + '-' + @year
	--				WHEN (@format = 'dd/mm/yyyy') THEN
	--					@day + '/' + @month + '/' + @year
	--				WHEN (@format = 'dd.mm.yyyy') THEN
	--					@day + '.' + @month + '.' + @year
	--				WHEN (@format = 'dd-mm-yyyy') THEN
	--					@day + '-' + @month + '-' + @year
	--				ELSE
	--					@year + '-' + @month + '-' + @day
	--			END
	
	RETURN @FNAGetGenericDate

END




GO
