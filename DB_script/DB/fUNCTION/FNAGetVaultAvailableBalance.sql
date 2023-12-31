
--SELECT [dbo].[FNAGetCustomerAvailableBalance](1)

ALTER FUNCTION [dbo].[FNAGetVaultAvailableBalance](@BRANCH_ID INT)
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




