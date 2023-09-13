

ALTER PROC PRO_UPDATE_VAULT_TRANSFER_REFERRAL_CHANGE
(
	@TRAN_ID BIGINT
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @ROWID VARCHAR(20), @TRAN_DATE VARCHAR(20), @BRANCH_ID INT, @USER_ID INT, @TRANSFER_AMT MONEY

	SELECT @BRANCH_ID = BRANCHID, @USER_ID = USERID, @TRAN_DATE = CAST(TRANDATE AS DATE), @TRANSFER_AMT = INAMOUNT
	FROM BRANCH_CASH_IN_OUT_HISTORY(NOLOCK) 
	WHERE REFERENCEID = @TRAN_ID
	AND INAMOUNT <> 0

	IF @BRANCH_ID <> 394396
	BEGIN
		SELECT @ROWID = MAIN_TABLE_ROW_ID
		FROM BRANCH_CASH_IN_OUT_HISTORY(NOLOCK) 
		WHERE BRANCHID = @BRANCH_ID
		AND USERID = @USER_ID
		AND CAST(TRANDATE AS DATE) = @TRAN_DATE
		AND HEAD = 'Transfer To Vault'

		UPDATE B SET B.OUTAMOUNT = B.OUTAMOUNT -  @TRANSFER_AMT
		FROM BRANCH_CASH_IN_OUT_HISTORY B(NOLOCK) 
		WHERE MAIN_TABLE_ROW_ID = @ROWID
		AND HEAD = 'Transfer To Vault'

		UPDATE B SET B.INAMOUNT = B.INAMOUNT -  @TRANSFER_AMT
		FROM BRANCH_CASH_IN_OUT_HISTORY B(NOLOCK) 
		WHERE REFERENCEID = @ROWID
		AND HEAD = 'TRANSFER TO VAULT AUTO ADJUST'

		UPDATE T SET T.TRAN_AMT = T.TRAN_AMT - @TRANSFER_AMT, T.USD_AMT = T.USD_AMT - @TRANSFER_AMT
		FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER T(NOLOCK)
		WHERE FIELD1 = @ROWID 
		AND FIELD2 = 'Vault Transfer'
	END
	ELSE
	BEGIN
		SELECT @ROWID = MAIN_TABLE_ROW_ID
		FROM BRANCH_CASH_IN_OUT_HISTORY(NOLOCK) 
		WHERE BRANCHID = @BRANCH_ID
		AND USERID = 0
		AND CAST(TRANDATE AS DATE) = @TRAN_DATE
		AND HEAD = 'Transfer To Vault(From Vault)'

		UPDATE B SET B.OUTAMOUNT = B.OUTAMOUNT -  @TRANSFER_AMT
		FROM BRANCH_CASH_IN_OUT_HISTORY B(NOLOCK) 
		WHERE MAIN_TABLE_ROW_ID = @ROWID
		AND HEAD = 'Transfer To Vault'

		UPDATE B SET B.INAMOUNT = B.INAMOUNT -  @TRANSFER_AMT
		FROM BRANCH_CASH_IN_OUT_HISTORY B(NOLOCK) 
		WHERE REFERENCEID = @ROWID
		AND HEAD = 'TRANSFER TO VAULT AUTO ADJUST'

		UPDATE T SET T.TRAN_AMT = T.TRAN_AMT - @TRANSFER_AMT, T.USD_AMT = T.USD_AMT - @TRANSFER_AMT
		FROM FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER T(NOLOCK)
		WHERE FIELD1 = @ROWID 
		AND FIELD2 = 'Vault Transfer'
	END
END

