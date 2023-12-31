USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDobFromNRICNo]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetDobFromNRICNo](@NRICNo VARCHAR(50))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @yyyy VARCHAR(4), @mm VARCHAR(2), @dd VARCHAR(2), @dob VARCHAR(20)
	SET @yyyy = LEFT(@NRICNo, 2)
	IF CAST(@yyyy AS INT) BETWEEN 0 AND 25
		SET @yyyy = '20' + @yyyy
	ELSE
		SET @yyyy = '19' + @yyyy
	SET @mm = SUBSTRING(@NRICNo, 3, 2)
	SET @dd = SUBSTRING(@NRICNo, 5, 2)

	SET @dob = (@mm + '/' + @dd + '/' + @yyyy)
	IF ISDATE(@dob) <> 1
	BEGIN
		SET @dob = NULL
	END
	RETURN @dob
END
--SELECT dbo.FNAGetDobFromNRICNo('751216145779')
GO
