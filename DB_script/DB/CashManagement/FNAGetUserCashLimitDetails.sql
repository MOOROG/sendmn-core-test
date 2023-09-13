--SELECT * FROM DBO.FNAGetUserCashLimitDetails('madhab')

ALTER FUNCTION [dbo].[FNAGetUserCashLimitDetails](@user VARCHAR(50), @branchId VARCHAR(20))
RETURNS @list TABLE (availableLimit MONEY, ruleType CHAR(1))
BEGIN
	DECLARE @totalLimit MONEY,
			@availableLimit MONEY,
			@cashAtBranch MONEY,
			@cashAtCounterUser MONEY,
			@ruleTypeUser CHAR(1),
			@ruleTypeBranch CHAR(1),
			@ruleType CHAR(1),
			@bId INT,
			@bType CHAR (1),
			@userId INT

	IF @user IS NOT NULL 
	BEGIN
		SET @bType = 'U'
		SELECT @userId = userId from applicationUsers where userName = @user
		SELECT @totalLimit = totalLimit, 
				@availableLimit = availableLimit,
				@ruleType = ruleType
		FROM DBO.FNAGetBranchCashLimitDetails(@userId, @bType)
    END 
	ELSE
    BEGIN
		IF @branchId LIKE 'JME%'
		BEGIN
		--for referral
			SELECT  @totalLimit = totalLimit, 
					@availableLimit = availableLimit,
					@ruleType = ruleType
			FROM DBO.FNAGetBranchCashLimitDetails(@branchId, 'R')
			
		END
		ELSE
		BEGIN
			SELECT @bType = B_TYPE  FROM dbo.AGENT_BRANCH_RUNNING_BALANCE WHERE B_ID = @branchId
			SELECT  @totalLimit = totalLimit, 
					@availableLimit = availableLimit,
					@ruleType = ruleType
			FROM DBO.FNAGetBranchCashLimitDetails(@branchId, @bType)
		END
		
	
	END 
	INSERT INTO @list
	SELECT @availableLimit, @ruleType
	RETURN
END



