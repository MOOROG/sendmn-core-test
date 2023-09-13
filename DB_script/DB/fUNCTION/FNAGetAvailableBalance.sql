
ALTER FUNCTION [dbo].[FNAGetAvailableBalance](@sBranch BIGINT)
RETURNS MONEY
AS  
BEGIN
		DECLARE @sAgent INT,
			@agentType INT,
			@sSuperAgent INT,
			@settlingAgent INT,
			@currentBal MONEY

		SELECT @sAgent = parentId, @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
		IF @agentType = 2903
			SET @sAgent = @sBranch
		
		SELECT @sSuperAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		
		SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
		IF @settlingAgent IS NULL
			SELECT @settlingAgent = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'
		
		SELECT 
			@currentBal = V.clr_bal_amt - V.todaysSend + V.todaysPaid + V.todaysCancel - V.todaysEPI + V.todaysPOI										
			FROM vWAgentClrBal V with(nolock) 
			INNER JOIN agentMaster am with(nolock) on V.map_code = am.mapCodeInt
			WHERE am.agentId = @settlingAgent 

		RETURN @currentBal
END

