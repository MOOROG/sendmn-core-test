USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNA_GetMNTAmount]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNA_GetMNTAmount]
(
@baseCurrency	VARCHAR(3) = NULL,
@serviceCharge  float = NULL,
@sCurrCostRate float = NULL,
@sCurrHoMargin float = NULL,
@tpExRate	   float
)
RETURNS float
AS
BEGIN
	IF @baseCurrency = 'USD'
	BEGIN
		SET @serviceCharge = ROUND(@serviceCharge* (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0)),0)
	END
	ELSE 
	BEGIN
		SET @serviceCharge = ROUND(@serviceCharge /(@tpExRate / (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0))),0)--CEILING(@serviceCharge/@tpExRate)
	END

	RETURN ISNULL(@serviceCharge,0)
END







GO
