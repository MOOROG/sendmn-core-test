
--SELECT [dbo].[FNAGetCustomerAvailableBalance](1)

ALTER FUNCTION [dbo].[FNAGetCustomerAvailableBalance_Refund](@CUSTOMERID BIGINT)
RETURNS MONEY
AS  
BEGIN
	DECLARE @AVAILABLEBALANCE MONEY, @PENDINGMAPPING MONEY, @PENDINGTRANSACTION MONEY

	SELECT @AVAILABLEBALANCE = AVAILABLEBALANCE 
	FROM CUSTOMERMASTER (NOLOCK)
	WHERE CUSTOMERID = @CUSTOMERID

	RETURN ISNULL(@AVAILABLEBALANCE,0) 
END





