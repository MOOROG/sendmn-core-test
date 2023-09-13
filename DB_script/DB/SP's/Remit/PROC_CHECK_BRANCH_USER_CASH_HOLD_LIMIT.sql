

ALTER PROC PROC_CHECK_BRANCH_USER_CASH_HOLD_LIMIT
(
	@USER VARCHAR(50)
	,@CAMT MONEY = NULL
	,@INTRODUCER VARCHAR(30) = NULL
	,@ERRORCODE INT = NULL OUT
	,@ERRORMSG VARCHAR(250) = NULL OUT
	,@RULETYPE CHAR(1) = NULL OUT
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @AVAILABLE_LIMIT MONEY, @RULE_TYPE_MAIN CHAR(1),
	@BRANCH_ID VARCHAR(30)

	IF ISNULL(@INTRODUCER, '') <> ''
		SET @USER = NULL
	ELSE
		SET @INTRODUCER = NULL

	SELECT @AVAILABLE_LIMIT = availableLimit, @RULE_TYPE_MAIN = ruleType FROM [dbo].[FNAGetUserCashLimitDetails](@USER, @INTRODUCER)
	
	IF @CAMT <= ISNULL(@AVAILABLE_LIMIT, 0)
		SELECT @ERRORCODE = 0, @ERRORMSG = 'Success', @RULETYPE = @RULE_TYPE_MAIN
	ELSE 
		SELECT @ERRORCODE = 1, @ERRORMSG = 'Your cash hold limit exceeded!', @RULETYPE = @RULE_TYPE_MAIN
END;
