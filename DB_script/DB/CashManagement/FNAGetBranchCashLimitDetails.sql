
--select * from dbo.FNAGetBranchCashLimitDetails(394394, 'U')
USE FastMoneyPro_Remit
GO


ALTER FUNCTION [dbo].[FNAGetBranchCashLimitDetails](@bId VARCHAR(20),@bType CHAR(1))
RETURNS @list TABLE (totalLimit MONEY, availableLimit MONEY, availableCash MONEY
						,ruleType CHAR(1))
AS  
BEGIN
	DECLARE @branchId INT,
			@totalLimit MONEY,
			@ruleType CHAR(1),
			@availabaleBalance MONEY,
			@availableCash MONEY,
			@totalLimitBranch MONEY,
			@totalLimitUser MONEY,
			@cashAtBranch MONEY,
			@branchRuleType CHAR(1),
			@userRuleType CHAR(1),
			@otherLimitUser MONEY,
			@cashAtOtherUserOfSameBranch MONEY,
			@cashAtUsersOfBranch MONEY,
			@limitBranchId INT,
			@cashAtUser MONEY,
			@cashAtOtherUser MONEY
		
		IF @bType IN ('B', 'A')
		BEGIN
			SELECT @totalLimit = cashHoldLimit, @ruleType = ruleType
			FROM CASH_HOLD_LIMIT_BRANCH_WISE (NOLOCK)
			WHERE isActive = 1
			AND agentId = @bId
			AND approvedBy IS NOT NULL

			SELECT @availableCash = SUM(ISNULL(TODAY_SEND, 0)) - SUM(ISNULL(TODAY_CANCEL, 0)) 
			FROM dbo.AGENT_BRANCH_RUNNING_BALANCE (NOLOCK)
			WHERE B_ID = @bId 
			AND B_TYPE IN ('B', 'A')
			
			SET @availabaleBalance = ISNULL(@totalLimit,0) - ISNULL(@availableCash,0)
		END
		ELSE IF @bType IN ('R')
		BEGIN
			SELECT @totalLimit = REFERRAL_LIMIT,@ruleType = RULE_TYPE,@limitBranchId = ROW_ID
			FROM dbo.REFERRAL_AGENT_WISE
			WHERE REFERRAL_CODE = @bId

			SELECT @bId =ROW_ID from REFERRAL_AGENT_WISE  where REFERRAL_CODE = @bId

			SELECT @availableCash = SUM(ISNULL(TODAY_SEND, 0)) - SUM(ISNULL(TODAY_CANCEL, 0))
			FROM AGENT_BRANCH_RUNNING_BALANCE (NOLOCK)
			WHERE B_ID = @bId
			AND B_TYPE = @bType

			SET @availabaleBalance = ISNULL(@totalLimit,0) - ISNULL(@availableCash,0)
		END
		ELSE IF @bType IN ('U')
		BEGIN 
			SELECT  @branchId = agentId FROM dbo.applicationUsers WHERE userId = @bId 

			SELECT @totalLimit = cashHoldLimit, @branchRuleType = ruleType, @limitBranchId = cashHoldLimitId
			FROM CASH_HOLD_LIMIT_BRANCH_WISE (NOLOCK)
			WHERE isActive = 1
			AND agentId = @branchId
			AND approvedBy IS NOT NULL

			SELECT @totalLimitUser = cashHoldLimit, @userRuleType = ruleType
			FROM CASH_HOLD_LIMIT_USER_WISE (NOLOCK) 
			WHERE isActive = 1
			AND userId = @bId
			AND approvedBy IS NOT NULL

			SELECT @availableCash = SUM(ISNULL(TODAY_SEND, 0)) - SUM(ISNULL(TODAY_CANCEL, 0))
			FROM dbo.AGENT_BRANCH_RUNNING_BALANCE (NOLOCK)
			WHERE B_ID = @bId
			AND B_TYPE = @bType

			IF ISNULL(@totalLimitUser, 0) = 0
			BEGIN
				--LIMIT FOR OTHER USERS
				SELECT @otherLimitUser = SUM(cashHoldLimit)
				FROM CASH_HOLD_LIMIT_USER_WISE (NOLOCK) 
				WHERE isActive = 1
				AND userId <> @bId
				AND cashHoldLimitBranchId = @limitBranchId
				AND approvedBy IS NOT NULL

				--SELECT @cashAtOtherUserOfSameBranch = SUM(ISNULL(TODAY_SEND,0) - ISNULL(TODAY_CANCEL,0))
				--FROM dbo.applicationUsers (NOLOCK) AU
				--INNER JOIN dbo.AGENT_BRANCH_RUNNING_BALANCE AB ON AB.B_ID = AU.userId
				--WHERE agentId = @branchId
				--and userId <> @bId
				--AND AB.B_TYPE = 'U'
				SELECT @cashAtUsersOfBranch = SUM(ISNULL(TODAY_SEND,0) - ISNULL(TODAY_CANCEL,0))
				FROM dbo.applicationUsers (NOLOCK) AU
				INNER JOIN dbo.AGENT_BRANCH_RUNNING_BALANCE AB ON AB.B_ID = AU.userId
				WHERE agentId = @branchId
				AND AB.B_TYPE = 'U'

				SELECT @cashAtBranch = SUM(ISNULL(TODAY_SEND, 0)) - SUM(ISNULL(TODAY_CANCEL, 0)) 
				FROM dbo.AGENT_BRANCH_RUNNING_BALANCE (NOLOCK)
				WHERE B_ID = @branchId 
				AND B_TYPE IN ('B', 'A')

				--SELECT @cashAtUser = SUM(ISNULL(TODAY_SEND, 0)) - SUM(ISNULL(TODAY_CANCEL, 0)) 
				--FROM dbo.AGENT_BRANCH_RUNNING_BALANCE L
				--INNER JOIN applicationUsers U ON U.userId = L.B_ID AND L.B_TYPE = 'U'
				--AND U.USERID = @bId

				SET @ruleType = @branchRuleType
				--SET @availabaleBalance = ISNULL(@totalLimit,0) - ISNULL(@otherLimitUser, 0) - (ISNULL(@cashAtBranch,0) + ISNULL(@cashAtUser,0))
				SET @availabaleBalance = ISNULL(@totalLimit,0) - ISNULL(@otherLimitUser, 0) - (ISNULL(@cashAtBranch,0) + ISNULL(@cashAtUsersOfBranch,0))
			END
			ELSE 
			BEGIN
				SET @ruleType = @userRuleType

				SET @availabaleBalance = ISNULL(@totalLimitUser,0) - ISNULL(@availableCash,0)
			END
		END


		INSERT INTO @list
		SELECT ISNULL(@totalLimit, 0), ISNULL(@availabaleBalance, 0), ISNULL(@availableCash, 0), ISNULL(@ruleType, 'B')
		RETURN
END

