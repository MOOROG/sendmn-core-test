
ALTER PROC [dbo].[Proc_AgentBalanceUpdate_INT]
	@flag			VARCHAR(50),  
	@tAmt			MONEY	= NULL,  
	@settlingAgent	BIGINT	= NULL
AS
SET NOCOUNT ON;
	-- ## Finding Settlement Agent
	DECLARE 
		@agent BIGINT,
		@agentType VARCHAR(10),
		@isSettlingAgent CHAR(1)

	SELECT @agentType = AGENTTYPE, @isSettlingAgent = ISNULL(ISSETTLINGAGENT, 'N')
	FROM AGENTMASTER (NOLOCK) 
	WHERE AGENTID = @settlingAgent

	IF @isSettlingAgent = 'N'
	BEGIN
		IF @agentType = '2904'
		BEGIN
			SELECT @agentType = A.AGENTTYPE, @isSettlingAgent = ISNULL(A.ISSETTLINGAGENT, 'N'), @agent = A.AGENTID
			FROM AGENTMASTER A(NOLOCK) 
			INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = A.PARENTID
			WHERE AM.AGENTID = @settlingAgent

			IF @isSettlingAgent = 'Y'
				SET @settlingAgent = @agent
		END
	END

	IF @flag = 's'
	BEGIN	
		UPDATE dbo.creditLimitINT SET 
			todaysSent = ISNULL(todaysSent,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent
	END 

	IF @flag = 'p'
	BEGIN	
		UPDATE dbo.creditLimitINT SET 
			todaysPaid = ISNULL(todaysPaid,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent
	END 
	IF @flag = 'c'
	BEGIN
		UPDATE dbo.creditLimitINT SET 
			todaysCancelled = ISNULL(todaysCancelled,0) + ISNULL(@tAmt,0)
		WHERE agentId = @settlingAgent
	END 
