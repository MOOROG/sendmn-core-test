USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetLimitBal]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetLimitBal](@agentId BIGINT)
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

	SELECT 
		 @acBal = clr_bal_amt
	FROM dbo.FNACurrentBalByAgentCode(@agentId)

	SELECT 
		 @drLimit				= ISNULL(limitAmt, 0)
		,@topUpTillYesterday	= ISNULL(topUpTillYesterday, 0)
		,@topUpToday			= ISNULL(topUpToday, 0)
		,@lianAmt				= ISNULL(lienAmt, 0)
		,@yesterdaysBalance		= ISNULL(yesterdaysBalance, 0)
		,@todaysSent			= ISNULL(todaysSent,0)
		,@todaysPaid			= ISNULL(todaysPaid ,0)
		,@todaysCancelled		= ISNULL(todaysCancelled,0)
		,@todaysEPI				= ISNULL(todaysEPI ,0)
		,@todaysPOI				= ISNULL(todaysPOI,0)
	FROM creditLimit WITH(NOLOCK)
	WHERE agentId = @agentId AND ISNULL(isActive, 'N') = 'Y'
	
	SELECT @todaysSent = CASE WHEN @todaysSent < 0 THEN 0 ELSE @todaysSent END
			,@todaysPaid = CASE WHEN @todaysPaid < 0 THEN 0 ELSE @todaysPaid END
			,@todaysCancelled = CASE WHEN @todaysCancelled < 0 THEN 0 ELSE @todaysCancelled END

	SELECT @accountBal = @acBal - @todaysSent + @todaysPaid + @todaysCancelled
	
	SELECT @topUpYesterdayCalc = CASE WHEN @topUpTillYesterday - (CASE WHEN (@acBal - @yesterdaysBalance) < 0 THEN 0 ELSE (@acBal - @yesterdaysBalance) END) - @todaysPaid - @todaysCancelled + @todaysEPI - @todaysPOI <= 0 THEN 0 
									ELSE @topUpTillYesterday - (CASE WHEN (@acBal - @yesterdaysBalance) < 0 THEN 0 ELSE (@acBal - @yesterdaysBalance) END) - @todaysPaid - @todaysCancelled + @todaysEPI - @todaysPOI END
	SELECT @availableLimit = @drLimit + @topUpYesterdayCalc + @topUpToday + @accountBal
	
	IF @availableLimit < 0
		RETURN 0
	RETURN ISNULL(@availableLimit,0)
END




GO
