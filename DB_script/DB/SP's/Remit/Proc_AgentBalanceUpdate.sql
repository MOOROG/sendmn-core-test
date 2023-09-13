
ALTER proc [dbo].[Proc_AgentBalanceUpdate]
	@flag			VARCHAR(50),  
	@tAmt			MONEY	= NULL,  
	@settlingAgent	BIGINT	= NULL
AS
SET NOCOUNT ON;

	IF @flag = 's'
	BEGIN	
		UPDATE dbo.creditLimit SET 
			todaysSent = ISNULL(todaysSent,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent
	END 
	-- ## Finding Settlement Agent
	DECLARE 
		@sBranch BIGINT,
		@sAgent BIGINT, 
		@agentType INT,
		@sSuperAgent INT,
		@settlingAgent1 INT

	SET @sBranch = @settlingAgent
	SELECT @sAgent = parentId, @agentType = agentType 
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	IF @agentType = 2903
		SET @sAgent = @sBranch
		
	SELECT @sSuperAgent = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
		
	SELECT @settlingAgent1 = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch AND isSettlingAgent = 'Y'
	IF @settlingAgent1 IS NULL
		SELECT @settlingAgent1 = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent AND isSettlingAgent = 'Y'
	IF @settlingAgent1 IS NULL
		SELECT @settlingAgent1 = agentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent AND isSettlingAgent = 'Y'


	IF @flag = 'p'
	BEGIN	
		UPDATE dbo.creditLimit SET 
			todaysPaid = ISNULL(todaysPaid,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent1
	END 
	IF @flag = 'c'
	BEGIN
		UPDATE dbo.creditLimit SET 
			todaysCancelled = ISNULL(todaysCancelled,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent1
	END 
	IF @flag = 'ep'
	BEGIN	
		UPDATE dbo.creditLimit SET 
			todaysEPI = ISNULL(todaysEPI,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent1
	END 
	IF @flag = 'po'
	BEGIN	
		UPDATE dbo.creditLimit SET 
			todaysPOI = ISNULL(todaysPOI,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent1
	END 
