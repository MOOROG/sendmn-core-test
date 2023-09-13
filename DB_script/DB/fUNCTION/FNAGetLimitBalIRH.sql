
ALTER FUNCTION [dbo].[FNAGetLimitBalIRH](@agentId BIGINT)
RETURNS MONEY
AS  
BEGIN
	DECLARE
		 @acBal					MONEY
		,@acctNum				VARCHAR(30)
		,@drLimit				MONEY
		,@topUpToday			MONEY
		,@topUpTillYesterday	MONEY
		,@topUpYesterdayCalc	MONEY
		,@todaysSent			MONEY
		,@todaysPaid			MONEY
		,@todaysCancelled		MONEY
		,@lianAmt				MONEY
		,@errPaidAmt			MONEY
		,@currentDate			VARCHAR(30)
		,@availableLimit		MONEY
		,@accountBal			MONEY
		,@todaysEPI				MONEY
		,@todaysPOI				MONEY
		,@yesterdaysBalance		MONEY
		,@countryId				INT
		,@collCurr				VARCHAR(3)
		,@mapCode				VARCHAR(20)
		,@USDAMOUNT				MONEY
		,@collCurrAmount		MONEY
		,@settCurr				VARCHAR(3)
	


	SELECT @mapCode = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId


	--COMMENTED BY ARJUN
	SELECT --A.AGENTNAME, L.CURRENCY LIMITCURRENCY,L.LIMITAMT,
		  @acBal = ISNULL(CASE WHEN  L.CURRENCY = 'JPY' THEN AM.CLR_BAL_AMT ELSE AM.USD_AMT END ,0)
    FROM dbo.creditLimitInt L WITH (NOLOCK)
    INNER JOIN dbo.agentMaster A WITH (NOLOCK) ON A.AGENTID=L.AGENTID
    INNER JOIN FastMoneyPro_account.DBO.AGENTTABLE AT WITH (NOLOCK) ON A.agentId=AT.MAP_CODE
    INNER JOIN FastMoneyPro_account.DBO.AC_MASTER AM WITH (NOLOCK) ON AT.agent_id=AM.agent_id
    AND AM.ACCT_RPT_CODE = '20'
    AND AT.map_code = @mapCode

	SET @acBal = 0

	SELECT 
		 @drLimit				= ISNULL(limitAmt, 0)
		,@topUpTillYesterday	= ISNULL(topUpTillYesterday, 0)
		,@topUpToday			= ISNULL(topUpToday, 0)
		,@acBal					= ISNULL(@acBal,0)						--
		,@todaysSent			= ISNULL(todaysSent, 0) --
		,@todaysPaid			= ISNULL(todaysPaid, 0)	--
		,@todaysCancelled		= ISNULL(todaysCancelled, 0) --
		,@todaysEPI				= 0
		,@todaysPOI				= 0					
		,@lianAmt				= ISNULL(lienAmt, 0)
		,@yesterdaysBalance		= ISNULL(yesterdaysBalance, 0)
		,@settCurr				= currency
	FROM creditLimitInt WITH(NOLOCK)
	WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y'
	
	
	SELECT @countryId = countryId,
		   @collCurr = b.currencyCode 
	FROM countryCurrency a WITH(NOLOCK) 
	INNER JOIN currencyMaster b WITH( NOLOCK) ON a.currencyId = b.currencyId 
	INNER JOIN agentMaster c with(nolock) on a.countryId= c.agentCountryId
	WHERE c.agentId=@agentId
	and ISNULL(a.isActive,'Y')='Y'
	AND ISNULL(a.isDeleted,'N') = 'N'
	AND ISNULL(a.isDefault, 'N') = 'Y'
	--AND b.currencyCode = 'KRW'	--this condition added by arjun
	
	if @settCurr = @collCurr
	BEGIN
		SELECT @availableLimit = @drLimit + @acBal + @topUpToday - @todaysSent + @todaysPaid + @todaysCancelled
	END
	ELSE
	BEGIN
		SET @USDAMOUNT = @drLimit + @acBal + @topUpToday
		SET @USDAMOUNT = @USDAMOUNT - @todaysSent + @todaysPaid + @todaysCancelled
		SELECT @collCurrAmount = dbo.FNAGetExchangeAmount(@collCurr, @countryId, @agentId, @USDAMOUNT)
		SET @availableLimit = @collCurrAmount
		--SELECT @availableLimit = @collCurrAmount - @todaysSent + @todaysPaid + @todaysCancelled
	END
	IF ISNULL(@availableLimit,0) < 0
		RETURN 0
	RETURN ISNULL(@availableLimit,0)
END

/*
		SELECT [dbo].FNAGetLimitBalIRH('4672')
		SELECT [dbo].FNAGetLimitBalIRH('1073')
		SELECT [dbo].FNAGetLimitBalIRH('1101')
		
		select * from agentMaster where agentName like '%al dar%'
*/	


