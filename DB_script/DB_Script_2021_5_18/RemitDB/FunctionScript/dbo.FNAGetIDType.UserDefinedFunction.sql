USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetIDType]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetIDType](@IdType VARCHAR(25),@countryId INT)  
RETURNS VARCHAR(25) AS  
BEGIN
	DECLARE @custIdType VARCHAR(25)
	IF CHARINDEX('|',@IdType) > 0
	BEGIN
		SET @custIdType = SUBSTRING(@IdType,1,LEN(@IdType)-2)
	END
	ELSE
	BEGIN
		SET @custIdType = @IdType
	END

	SET @custIdType = (SELECT valueId FROM staticDataValue WHERE typeId='1300' AND (CAST(valueId AS VARCHAR)=@custIdType OR detailTitle = @custIdType))	

	RETURN @custIdType
END



GO
