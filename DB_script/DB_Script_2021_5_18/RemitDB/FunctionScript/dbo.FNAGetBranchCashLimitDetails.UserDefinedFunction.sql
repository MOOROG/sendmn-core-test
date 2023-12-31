USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetBranchCashLimitDetails]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetBranchCashLimitDetails](@bId VARCHAR(20),@bType CHAR(1))
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
			@cashAtOtherUser MONEY,

			@pAcc VARCHAR(20),
			@cAcc VARCHAR(20),
			@sAmt Money,
			@S_P_Amt   Money

		
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

		SELECT @cashAtUsersOfBranch = SUM(ISNULL(TODAY_SEND,0) - ISNULL(TODAY_CANCEL,0))
		FROM dbo.applicationUsers (NOLOCK) AU
		INNER JOIN dbo.AGENT_BRANCH_RUNNING_BALANCE AB ON AB.B_ID = AU.userId
		WHERE agentId = @branchId
		AND AB.B_TYPE = 'U'

		SELECT @cashAtBranch = SUM(ISNULL(TODAY_SEND, 0)) - SUM(ISNULL(TODAY_CANCEL, 0)) 
		FROM dbo.AGENT_BRANCH_RUNNING_BALANCE (NOLOCK)
		WHERE B_ID = @branchId 
		AND B_TYPE IN ('B', 'A')


		SET @ruleType = @branchRuleType
		SET @availabaleBalance = ISNULL(@totalLimit,0) - ISNULL(@otherLimitUser, 0) - (ISNULL(@cashAtBranch,0) + ISNULL(@cashAtUsersOfBranch,0))
	END
	ELSE 
		BEGIN
		SET @ruleType = @userRuleType
	

		SELECT @sAmt = SUM(cAmt) FROM remitTranTemp (NOLOCK)  Tm
		INNER JOIN  dbo.applicationUsers (NOLOCK) AU ON Tm.createdBy = AU.userName
		WHERE AU.UserId= @bId
	
		SELECT @S_P_Amt = SUM(CASE WHEN part_tran_type = 'DR' THEN (-1* tm.tran_Amt) ELSE tm.tran_amt end)
		 FROM SendMnPro_Account.dbo.ac_master(NOLOCK) ac
		INNER JOIN  SendMnPro_Account.dbo.Tran_Master(NOLOCK)tm ON tm.acc_num = ac.acct_num
		WHERE ac.agent_id = @bId  --and ac.acct_rpt_code = 'VAC' --only principle (pay ko  case ma payComm not added)

		SET @availabaleBalance = ISNULL(@totalLimitUser,0) - ISNULL(@availableCash,0)- ISNULL(@sAmt,0) +  ISNULL(@S_P_Amt,0)
	END
END


INSERT INTO @list
SELECT ISNULL(@totalLimit, 0), ISNULL(@availabaleBalance, 0), ISNULL(@availableCash, 0), ISNULL(@ruleType, 'B')
RETURN
END



GO
