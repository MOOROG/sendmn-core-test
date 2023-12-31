USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAChkMobileFormat]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAChkMobileFormat] (@country INT, @mobileNo VARCHAR(15))
RETURNS CHAR(1)
AS
BEGIN
	DECLARE @MSG CHAR(1)
	DECLARE @prefix VARCHAR(10)
	DECLARE @prefixTable TABLE(rowId INT IDENTITY(1,1), prefix VARCHAR(10), prefixLen INT, countryId INT)
	
	INSERT @prefixTable(prefix, prefixLen, countryId)
	SELECT prefix, prefixLen = LEN(prefix), countryId FROM mobileOperator WHERE countryId = @country AND ISNULL(isDeleted, 'N') = 'N'
	
	IF NOT EXISTS(SELECT 'X' FROM @prefixTable)
	BEGIN
		SET @MSG = 'Y'
		RETURN @MSG
	END
	IF EXISTS(
				SELECT 'X' FROM mobileOperator mo INNER JOIN @prefixTable pt ON mo.countryId = pt.countryId 
				WHERE mo.countryId = @country AND mo.prefix = LEFT(@mobileNo,pt.prefixLen) AND mo.mobileLen = LEN(@mobileNo)
			)
	--IF EXISTS(SELECT 'X' FROM mobileOperator WHERE countryId = @country AND prefix = LEFT(@mobileNo,3) AND mobileLen=LEN(@mobileNo))
	BEGIN
		SET @MSG = 'Y'
	END
	ELSE	
		SET @MSG = 'N'
		
	RETURN @MSG
END	


GO
