
ALTER PROCEDURE PROC_VAULT_TRANSFER_ACC
(
	@USER VARCHAR(50) 
	,@ROW_ID INT 
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @SESSION_ID	VARCHAR(50)	= NEWID()
			,@AGENT_ID INT
			,@AMOUNT MONEY
			,@MODE CHAR(2)
			,@USER_NAME VARCHAR(80)
			,@BRANCH_ID INT
			,@TxnDate DATETIME
			,@FROM_ACC VARCHAR(30)
			,@TO_ACC VARCHAR(30)

	SELECT @AGENT_ID = BC.ID, @MODE = BC.MODE, @AMOUNT = BC.OUTAMOUNT
			, @USER_NAME = AU.USERNAME, @BRANCH_ID = BC.BRANCHID, @TxnDate = BC.tranDate
			, @FROM_ACC = BC.FROMACC, @TO_ACC = BC.TOACC
	FROM FASTMONEYPRO_REMIT.DBO.BRANCH_CASH_IN_OUT BC(NOLOCK) 
	LEFT JOIN FASTMONEYPRO_REMIT.DBO.APPLICATIONUSERS AU(NOLOCK) ON AU.USERID = BC.USERID
	WHERE rowId = @ROW_ID
	
	IF ISNULL(@MODE, '') IN ('CV', 'C')
	BEGIN	
		DECLARE @branchIdNew INT

		SELECT @branchIdNew = agentId
		FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AC(NOLOCK)
		INNER JOIN FASTMONEYPRO_REMIT.DBO.AGENTMASTER AM(NOLOCK) ON AM.AGENTID = AC.AGENT_ID
		WHERE ACCT_RPT_CODE = 'BVA'
		AND ACCT_NUM = @TO_ACC
		
		INSERT INTO FASTMONEYPRO_REMIT.DBO.BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, approvedBy, approvedDate, referenceId, mode, fromAcc, toAcc)
		SELECT inAmount, outAmount, @branchIdNew, 0, tranDate, CASE WHEN @MODE = 'C' THEN 'TRANSFER TO VAULT AUTO ADJUST' 
																						ELSE 'TRANSFER FROM VAULT AUTO ADJUST' END
															,CASE WHEN @MODE = 'C' THEN 'Auto entry in adjustment of cash transferred to vault' 
																						ELSE 'Auto entry in adjustment of cash transfer from vault' END, createdBy, createdDate, 'system', GETDATE(), rowId, mode, toAcc, fromAcc
		FROM FASTMONEYPRO_REMIT.DBO.BRANCH_CASH_IN_OUT
		WHERE rowId = @ROW_ID
	END
	
	--voucher entry for BRANCH ACCOUNT
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,field1,field2)	
	SELECT @SESSION_ID,'system',@FROM_ACC,'j','cr',@AMOUNT,@AMOUNT,1,@TxnDate
		,'USDVOUCHER','JPY',@ROW_ID,'Vault Transfer'

	--voucher entry for HQ OR BANK ACC
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,field1,field2)	
	SELECT @SESSION_ID,'system',@TO_ACC,'j','dr',@AMOUNT,@AMOUNT,1,@TxnDate
		,'USDVOUCHER','JPY',@ROW_ID,'Vault Transfer'
	
	DECLARE @narration VARCHAR(150) = 'Vault transfer by user: ' + ISNULL(@USER_NAME, 'Vault')
	EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID=@SESSION_ID,@date=@TxnDate,@narration=@narration,@company_id=1,@v_type='j',@user='system'
END


