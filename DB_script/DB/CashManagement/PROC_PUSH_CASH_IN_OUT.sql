--EXEC PROC_PUSH_CASH_IN_OUT @flag='IN', @user='admin',@amount=20000,@tranDate='2019-01-01',@head='test',@remarks='test',@branchId='123',@isAutoApprove=0,@referenceId=1213

ALTER  PROC PROC_PUSH_CASH_IN_OUT
(
	@flag	VARCHAR(20)
	,@user	VARCHAR(50)
	,@amount	MONEY
	,@tranDate	DATETIME
	,@head	VARCHAR(100)
	,@remarks	NVARCHAR(250)
	,@branchId	INT
	,@isAutoApprove	BIT
	,@referenceId	BIGINT
	,@userId	INT
	,@userName	VARCHAR(20) = NULL
	,@mode	CHAR(2) = NULL
	,@fromAcc	VARCHAR(30) = NULL
	,@toAcc	VARCHAR(30) = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @rowId BIGINT
	IF @flag = 'IN'
	BEGIN
		IF ISNULL(@isAutoApprove, 0) = 1
		BEGIN
			INSERT INTO BRANCH_CASH_IN_OUT (inAmount, outAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, approvedBy, approvedDate, referenceId, mode, fromAcc, toAcc)
			SELECT @amount, 0, @branchId, @userId, @tranDate, @head, @remarks, @user, GETDATE(), 'system', GETDATE(), @referenceId, @mode, @fromAcc, @toAcc
		END
		ELSE
		BEGIN
			INSERT INTO BRANCH_CASH_IN_OUT (inAmount, outAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, referenceId, mode, fromAcc, toAcc)
			SELECT @amount, 0, @branchId, @userId, @tranDate, @head, @remarks, @user, GETDATE(), @referenceId, @mode, @fromAcc, @toAcc
		END
	END
	ELSE IF @flag = 'OUT'
	BEGIN
		IF ISNULL(@isAutoApprove, 0) = 1
		BEGIN
			INSERT INTO BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, approvedBy, approvedDate, referenceId, mode, fromAcc, toAcc)
			SELECT @amount, 0, @branchId, @userId, @tranDate, @head, @remarks, @user, GETDATE(), 'system', GETDATE(), @referenceId, @mode, @fromAcc, @toAcc
		END
		ELSE
		BEGIN
			INSERT INTO BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, referenceId, mode, fromAcc, toAcc)
			SELECT @amount, 0, @branchId, @userId, @tranDate, @head, @remarks, @user, GETDATE(), @referenceId, @mode, @fromAcc, @toAcc
		END
	END
	ELSE IF @flag = 'OUT-TRANS'
	BEGIN
	
		IF ISNULL(@isAutoApprove, 0) = 1
		BEGIN
			INSERT INTO BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, approvedBy, approvedDate, referenceId, mode, fromAcc, toAcc)
			SELECT @amount, 0, @branchId, 0, @tranDate, @head, @remarks, @user, GETDATE(), 'system', GETDATE(), @referenceId, @mode, @fromAcc, @toAcc
		END 
		ELSE
		BEGIN
			INSERT INTO BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, referenceId, mode, fromAcc, toAcc)
			SELECT @amount, 0, @branchId, 0, @tranDate, @head, @remarks, @user, GETDATE(), @referenceId, @mode, @fromAcc, @toAcc
		END
		
		SET @rowId = @@IDENTITY
		IF ISNULL(@mode, '') NOT IN ('cv')
		BEGIN
			--UPDATE BALANCE
			IF ISNULL(@mode, '') IN ('b')
			BEGIN
				EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG = 'TRANSFER_TO_BANK',@S_AGENT = @branchId,@C_AMT = @amount
			END
			EXEC FASTMONEYPRO_ACCOUNT.DBO.PROC_VAULT_TRANSFER_ACC @USER = @user, @ROW_ID = @rowId
		END
	END
	IF ISNULL(@mode, '') IN ('ct', 'cv')
	BEGIN
		SET @rowId = @@IDENTITY
		DECLARE @branchIdNew INT, @userIdNew INT

		IF @mode = 'ct'
		BEGIN
			SELECT @userIdNew = userId, @branchIdNew = agentId
			FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK)
			INNER JOIN APPLICATIONUSERS AU(NOLOCK) ON AU.USERID = AC.AGENT_ID
			WHERE ACCT_RPT_CODE = 'TCA' 
			AND ACCT_NUM = @toAcc

			SET @remarks = 'Auto entry in adjustment of cash transfer to teller user'
			INSERT INTO BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, approvedBy, approvedDate, referenceId, mode, fromAcc, toAcc)
			SELECT 0, @amount, @branchIdNew, @userIdNew, @tranDate, 'TELLER TRANSFER AUTO ADJUST', @remarks, @user, GETDATE(), 'system', GETDATE(), @rowId, @mode, @toAcc, @fromAcc
			--UPDATE BALANCE
			select @userId = agent_id from FastMoneyPro_Account.dbo.ac_master where acct_num = @toAcc
			--SELECT @branchId,@userId,@amount
			EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG = 'TRANSFER_TO_TELLER',@S_AGENT = @branchId,@S_USER=@userId,@C_AMT = @amount
		END
	END
END

