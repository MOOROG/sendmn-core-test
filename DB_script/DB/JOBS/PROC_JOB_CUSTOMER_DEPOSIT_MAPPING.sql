
ALTER PROC PROC_JOB_CUSTOMER_DEPOSIT_MAPPING
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @tranId INT, @customerId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM CUSTOMER_DEPOSIT_QUEUE WHERE IS_UPDATED IS NULL)
	BEGIN
		select @customerId = CUSTOMER, @tranId = tranid 
		FROM CUSTOMER_DEPOSIT_QUEUE 
		WHERE IS_UPDATED IS NULL
 
		EXEC PROC_CUSTOMER_DEPOSITS @flag = 'i', @user = 'system', @tranId = @tranId, @customerId = @customerId

		UPDATE CUSTOMER_DEPOSIT_QUEUE SET IS_UPDATED = 1 WHERE tranId = @tranId
	END
END

--verify customer deposits mapped data in accounting system
--SELECT COUNT(0) FROM CUSTOMER_DEPOSIT_QUEUE WHERE IS_UPDATED IS NULL

--SELECT COUNT(0) FROM FastMoneyPro_Account.DBO.tran_master 
--WHERE FIELD2 = 'Deposit Voucher'
--AND CAST(CREATED_DATE AS DATE) = '2019-09-11'
