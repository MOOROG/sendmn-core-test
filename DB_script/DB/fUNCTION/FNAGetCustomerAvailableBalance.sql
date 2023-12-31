
--SELECT [dbo].[FNAGetCustomerAvailableBalance_Refund](34384)

ALTER FUNCTION [dbo].[FNAGetCustomerAvailableBalance](@CUSTOMERID BIGINT)
RETURNS MONEY
AS  
BEGIN
	DECLARE @AVAILABLEBALANCE MONEY, @PENDINGMAPPING MONEY, @PENDINGTRANSACTION MONEY

	SELECT @AVAILABLEBALANCE = AVAILABLEBALANCE 
	FROM CUSTOMERMASTER (NOLOCK)
	WHERE CUSTOMERID = @CUSTOMERID

	SELECT @PENDINGMAPPING = SUM(DEPOSITAMOUNT) FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK)
	WHERE CUSTOMERID = @CUSTOMERID
	AND ISSKIPPED = 0
	AND APPROVEDBY IS NULL

	SELECT @PENDINGTRANSACTION = SUM(CAMT) FROM remittrantemp RT (NOLOCK)
	INNER JOIN TRANSENDERSTEMP TS (NOLOCK) ON TS.TRANID = RT.ID
	WHERE TS.CUSTOMERID = @CUSTOMERID
	AND RT.COLLMODE = 'Bank Deposit'

	RETURN ISNULL(@AVAILABLEBALANCE,0) + ISNULL(@PENDINGMAPPING,0) - ISNULL(@PENDINGTRANSACTION,0)
END





