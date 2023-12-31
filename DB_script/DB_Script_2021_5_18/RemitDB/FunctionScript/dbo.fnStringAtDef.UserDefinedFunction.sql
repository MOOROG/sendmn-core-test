USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[fnStringAtDef]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnStringAtDef]( @Start int, @StringToSearch varchar(50), 
	@Target1 varchar(50), 
	@Target2 varchar(50) = NULL,
	@Target3 varchar(50) = NULL,
	@Target4 varchar(50) = NULL,
	@Target5 varchar(50) = NULL,
	@Target6 varchar(50) = NULL )
RETURNS bit
AS
BEGIN
	IF CHARINDEX(@Target1,@StringToSearch,@Start) > 0 RETURN 1
	--2 Styles, test each optional argument for NULL, nesting further tests
	--or just take advantage of CHARINDEX behavior with a NULL arg (unless 65 compatibility - code check before CREATE FUNCTION?
	--Style 1:
	--IF @Target2 IS NOT NULL
	--BEGIN
	--	IF CHARINDEX(@Target2,@StringToSearch,@Start) > 0 RETURN 1
	-- (etc.)
	--END
	--Style 2:
	IF CHARINDEX(@Target2,@StringToSearch,@Start) > 0 RETURN 1
	IF CHARINDEX(@Target3,@StringToSearch,@Start) > 0 RETURN 1
	IF CHARINDEX(@Target4,@StringToSearch,@Start) > 0 RETURN 1
	IF CHARINDEX(@Target5,@StringToSearch,@Start) > 0 RETURN 1
	IF CHARINDEX(@Target6,@StringToSearch,@Start) > 0 RETURN 1
	RETURN 0
END

GO
