use fastmoneypro_remit
select * from branch_cash_in_out
where rowid in (82979,82980)

select * from remittrantemp
	
select * from fastmoneypro_account.dbo.tran_master where field1 = '82979'

INSERT INTO send_voucher 
SELECT DBO.DECRYPTDB(CONTROLNO) CONTROLNO, ID, cancelApproveddate, 0 voucher_gen, 
		is_cancel = 0, paidDate 
FROM REMITTRANTEMP (NOLOCK) 

update s set s.voucher_gen = 0 from send_voucher s
inner join REMITTRANTEMP r on r.controlno = dbo.fnaencryptstring(s.controlno)

--SELECT * INTO BRANCH_CASH_IN_OUT_BAK FROM BRANCH_CASH_IN_OUT
--EXEC PROC_BALANCE_SETTLE_AND_EOD @FLAG = 'EOD'
return
SELECT * FROM AGENTMASTER WHERE PARENTID = 393877
--transfer to vault
SELECT * FROM BRANCH_CASH_IN_OUT WHERE ROWID BETWEEN 14322 AND 14327

declare @tranDate DATE = '2020-05-08'
DECLARE @AMOUNT MONEY, @USERID INT, @TRANID INT, @FROM_ACC VARCHAR(30), @TO_ACC VARCHAR(30), @AGENT_ID INT

WHILE EXISTS(SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT (NOLOCK) 
				WHERE tranDate between CAST(@tranDate AS VARCHAR) and CAST(@tranDate AS VARCHAR) + ' 23:59:59' AND USERID <> 0 AND BRANCHID NOT IN (394394, 394393))
BEGIN
	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL DROP TABLE #TEMP

	SELECT SUM(INAMOUNT)-SUM(OUTAMOUNT) BALANCE, USERID INTO #TEMP FROM BRANCH_CASH_IN_OUT WHERE 1=1
	AND tranDate BETWEEN CAST(@tranDate AS VARCHAR) and CAST(@tranDate AS VARCHAR) + ' 23:59:59'
	AND BRANCHID NOT IN (394394, 394393)
	AND USERID <> 0
	GROUP BY USERID

	WHILE EXISTS(SELECT * FROM #TEMP)
	BEGIN
		SELECT @AMOUNT = BALANCE, @USERID = USERID FROM #TEMP

		SELECT @FROM_ACC = ACCT_NUM
		FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK) 
		WHERE AGENT_ID = @USERID
		AND ACCT_RPT_CODE = 'TCA'

		SELECT @AGENT_ID = AGENTID FROM APPLICATIONUSERS (NOLOCK) WHERE USERID = @USERID

		SELECT @TO_ACC = ACCT_NUM
		FROM FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER (NOLOCK) 
		WHERE AGENT_ID = @AGENT_ID
		AND ACCT_RPT_CODE = 'BVA'

		IF @TO_ACC IS NULL
			SET @TO_ACC = '100139292573'

		INSERT INTO BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, referenceId, mode, fromAcc, toAcc)
		SELECT @AMOUNT, 0, @AGENT_ID, @USERID, @tranDate, 'Transfer To Vault', 'Transfer To Vault by user: system', 'system', GETDATE(), 0, 'C', @FROM_ACC, @TO_ACC

		SET @TRANID = @@IDENTITY

		EXEC PROC_VAULTTRANSFER @flag = 'approve', @rowId = @TRANID, @user = 'system'

		DELETE FROM #TEMP WHERE BALANCE = @AMOUNT AND USERID = @USERID
	END
	SET @tranDate = DATEADD(DAY, 1, @tranDate)
END


select * from TEMP_TRAN (NOLOCK)
where RefNo = 'Value was either too'

SELECT * FROM BRANCH_CASH_IN_OUT_HISTORY WHERE BRANCHID = 394396


SELECT * FROM AGENTMASTER WHERE PARENTID=393877


SELECT rowId, inAmount, outAmount, branchId, userId, referenceId, tranDate, head, 
				remarks, createdBy, createdDate, approvedBy, approvedDate, mode, fromAcc, toAcc
INTO #TEMP
FROM BRANCH_CASH_IN_OUT_HISTORY (NOLOCK) WHERE BRANCHID = 394396
--WHERE createdDate BETWEEN @DATE AND @DATE + ' 23:59:59'

INSERT INTO BRANCH_CASH_IN_OUT (inAmount, outAmount, branchId, userId, referenceId, tranDate, head, 
				remarks, createdBy, createdDate, approvedBy, approvedDate, mode, fromAcc, toAcc)
SELECT inAmount, outAmount, branchId, userId, referenceId, tranDate, head, 
				remarks, createdBy, createdDate, approvedBy, approvedDate, mode, fromAcc, toAcc
FROM #TEMP (NOLOCK)
		
select * from fastmoneypro_account.dbo.tran_master where ref_num in ('194429', '194432', '194435', '194438', '194441')
select * from fastmoneypro_account.dbo.tran_masterdetail where ref_num in ('194429', '194432', '194435', '194438', '194441')

select * from branch_cash_in_out where head in( 'Transfer To Vault', 'TRANSFER TO VAULT AUTO ADJUST')

SELECT * FROM TXN_SYNC_STATUS (NOLOCK) WHERE voucher_gen = 0 AND (CANCELAPPROVEDDATE IS NOT NULL OR PAIDDATE IS NOT NULL) AND ISNULL(NO_VOUCHER, 0) = 0
and transtatus = 'cancel'

order by count(0) desc

delete from TXN_SYNC_STATUS  where controlno is null

select * from branch_cash_in_out_history where cast(trandate as date) = '2020-05-08' and userid=52766
select * from branch_cash_in_out where cast(trandate as date) = '2020-05-08' and outamount=21000
select * from branch_cash_in_out where rowid=107365
select * from branch_cash_in_out where inamount=21000

select * from applicationusers where userid=52766



select createdby, createddate, sagentname, sbranchname,* from remittran where id=100401186

select * from branch_cash_in_out_history where main_table_row_id=107365

select * from fastmoneypro_account.dbo.tran_master where ref_num = '286937'

select createdby, createddate, sagentname, sbranchname,dbo.decryptdb(controlno),* from remittran where id in(100401294
,100401295
,100401296)

SELECT createdby, createddate, sagentname, sbranchname,dbo.decryptdb(controlno),* 
FROM REMITTRAN (NOLOCK)
WHERE CAST(CREATEDDATE AS DATE) = '2020-05-07' AND CREATEDBY = 'SHIKSHYA'



