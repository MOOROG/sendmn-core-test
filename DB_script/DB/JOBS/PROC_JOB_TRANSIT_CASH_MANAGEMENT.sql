
ALTER PROC PROC_JOB_TRANSIT_CASH_MANAGEMENT
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN	
	DECLARE @REFERRAL_CODE VARCHAR(50) ,@RECEIVING_MODE CHAR(2),@RECEIVER_ACC_NUM VARCHAR(30),
	@AMOUNT MONEY, @TRAN_DATE VARCHAR(30), @ROW_ID INT
	
	WHILE EXISTS(SELECT TOP 1 1 FROM VOUCHER_TRANSIT_CASH_MANAGE WHERE IS_GEN IS NULL)
	BEGIN
		SELECT @REFERRAL_CODE = REFERRAL_CODE, @RECEIVING_MODE = 'CV', @RECEIVER_ACC_NUM = RECEIVER_ACC_NUM,
			@AMOUNT = AMOUNT, @TRAN_DATE = DT, @ROW_ID = ROW_ID
		FROM VOUCHER_TRANSIT_CASH_MANAGE WHERE IS_GEN IS NULL
		
		IF EXISTS(SELECT TOP 1 1 FROM FastMoneyPro_Remit.DBO.REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @REFERRAL_CODE AND AGENT_ID <> 0)
		BEGIN
			UPDATE VOUCHER_TRANSIT_CASH_MANAGE SET IS_GEN = 2 WHERE ROW_ID = @ROW_ID 
		END 
		ELSE
		BEGIN
			EXEC PROC_TRANSIT_CASH_MANAGEMENT @FLAG ='I',@USER ='system',
			@REFERRAL_CODE =@REFERRAL_CODE,@RECEIVING_MODE =@RECEIVING_MODE,@RECEIVER_ACC_NUM =@RECEIVER_ACC_NUM,
			@AMOUNT =@AMOUNT,@TRAN_DATE =@TRAN_DATE

			UPDATE VOUCHER_TRANSIT_CASH_MANAGE SET IS_GEN = 3 WHERE ROW_ID = @ROW_ID
		END
	END
END

--UPDATE C SET C.IS_GEN = 2 FROM VOUCHER_TRANSIT_CASH_MANAGE C
--INNER JOIN FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE A ON A.REFERRAL_CODE = C.REFERRAL_CODE
--WHERE A.AGENT_ID <> 0
--106988051.00
-- VERIFY DATA
--SELECT * FROM TRANSIT_CASH_SETTLEMENT M
--INNER JOIN TRAN_MASTER T ON CAST(M.ROW_ID AS VARCHAR) = T.FIELD1 
--WHERE ROW_ID BETWEEN 59212 AND 59410
--ORDER BY ROW_ID DESC

--SELECT * FROM TRANSIT_CASH_SETTLEMENT M
--INNER JOIN FASTMONEYPRO_REMIT.DBO.BRANCH_CASH_IN_OUT T ON M.ROW_ID = T.REFERENCEID
--WHERE M.ROW_ID BETWEEN 59212 AND 59410
--AND T.FIELD1 = 'Transit Cash Settle'
--ORDER BY ROW_ID DESC

