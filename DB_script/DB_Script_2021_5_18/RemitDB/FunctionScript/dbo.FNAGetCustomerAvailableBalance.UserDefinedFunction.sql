USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCustomerAvailableBalance]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[FNAGetCustomerAvailableBalance](@CUSTOMERID BIGINT)
RETURNS MONEY
AS  
BEGIN
	DECLARE @AVAILABLEBALANCE MONEY, @PENDINGMAPPING MONEY, @PENDINGTRANSACTION MONEY

	SELECT @AVAILABLEBALANCE = AVAILABLEBALANCE 
	FROM CUSTOMERMASTER (NOLOCK)
	WHERE CUSTOMERID = @CUSTOMERID

	RETURN ISNULL(@AVAILABLEBALANCE,0) 
END







GO
