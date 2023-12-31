USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACalcBonusPoint]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNACalcBonusPoint]
(
	 @amt		    MONEY
	,@serviceCharge MONEY
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @bonuPoint  FLOAT 
	SELECT @bonuPoint = (@amt/500) + @serviceCharge
	RETURN ROUND(@bonuPoint/100,0)
END




GO
