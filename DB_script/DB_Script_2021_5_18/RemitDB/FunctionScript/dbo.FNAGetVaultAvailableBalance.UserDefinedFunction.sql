USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetVaultAvailableBalance]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT [dbo].[FNAGetCustomerAvailableBalance](1)

CREATE FUNCTION [dbo].[FNAGetVaultAvailableBalance](@BRANCH_ID INT)
RETURNS MONEY
AS  
BEGIN
	DECLARE @AVAILABLEBALANCE MONEY

	SELECT  @AVAILABLEBALANCE = ISNULL(SUM(inAmount) - SUM(outAmount), 0)
	FROM BRANCH_CASH_IN_OUT (NOLOCK)
	WHERE BRANCHID = @BRANCH_ID
	AND USERID = 0
	AND APPROVEDDATE IS NOT NULL

	RETURN ISNULL(@AVAILABLEBALANCE, 0)
END




GO
