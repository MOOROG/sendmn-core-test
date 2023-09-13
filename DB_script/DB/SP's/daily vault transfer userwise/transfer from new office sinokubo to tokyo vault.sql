select count(0) from send_voucher where voucher_gen = 0

SELECT * FROM TXN_SYNC_STATUS (NOLOCK) 
WHERE controlno in ('33JP212766337', '33JP212737029', '33JP212779042', '33JP212686483', '21678688')

select * from fastmoneypro_account.dbo.tran_master where ref_num='195370.01'
select * from fastmoneypro_account.dbo.tran_masterdetail where ref_num='195370.01'


select * from referral_agent_wise where referral_name like '%funa%'
use fastmoneypro_remit
select * from BRANCH_CASH_IN_OUT

select sagent,sagentname, createdby,* from remittrantemp where controlno = dbo.fnaencryptstring('21505888')

SELECT * FROM 

declare @tranDate DATE = '2020-05-08'
DECLARE @AMOUNT MONEY, @USERID INT, @TRANID INT, @FROM_ACC VARCHAR(30), @TO_ACC VARCHAR(30), @AGENT_ID INT

WHILE EXISTS(SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT (NOLOCK) 
				WHERE tranDate between CAST(@tranDate AS VARCHAR) and CAST(@tranDate AS VARCHAR) + ' 23:59:59'
				AND BRANCHID = 394396)
BEGIN
	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL DROP TABLE #TEMP

	SELECT SUM(INAMOUNT)-SUM(OUTAMOUNT) BALANCE, @tranDate tranDate INTO #TEMP FROM BRANCH_CASH_IN_OUT WHERE 1=1
	AND tranDate BETWEEN CAST(@tranDate AS VARCHAR) and CAST(@tranDate AS VARCHAR) + ' 23:59:59'
	and branchid = 394396


	SELECT @AMOUNT = BALANCE FROM #TEMP

	-- NEW SHIN OKUBO OFFICE
	SELECT @FROM_ACC = '121901598'

	--TOKYO MAIN BRANCH
	SELECT @TO_ACC = '100139292573'


	INSERT INTO BRANCH_CASH_IN_OUT (outAmount, inAmount, branchId, userId, tranDate, head, remarks, createdBy, createdDate, referenceId, mode, fromAcc, toAcc)
	SELECT @AMOUNT, 0, 394396, 0, @tranDate, 'Transfer To Vault(From Vault)', 'Transfer To Vault by user: system', 'system', GETDATE(), 0, 'C', @FROM_ACC, @TO_ACC

	SET @TRANID = @@IDENTITY

	EXEC PROC_VAULTTRANSFER @flag = 'approve', @rowId = @TRANID, @user = 'system'

	SET @tranDate = DATEADD(DAY, 1, @tranDate)
END

select * from remittran (nolock) where createddate >= '2019-01-02' 
and sagent is null



update t set t.sagentname = am.agentname, t.sagent = am.agentId, 
			t.sbranchname = am.agentname, t.sbranch = am.agentId
from remittran t(NOLOCK)
inner join applicationusers a(NOLOCK) on a.username = t.createdby
inner join agentmaster am(NOLOCK) on am.agentid = a.agentid
where (t.sagent not in (select agentid from agentmaster) or t.sagent is null)
and t.createddate >= '2019-01-02' 


select * from remittran (nolock) where createddate between '2019-10-02' and '2019-10-02 23:59:59'
and transtatus = 'cancel'


select sagent,sagentname,createdby,* from remittrantemp

select * from branch_cash_in_out_history where cast(trandate as date) = '2019-10-31'
and branchid = 394392

select * from applicationusers where userid=52786

select * from remittran where createdby = 'jme2'
and cast(createddate as date) = '2019-10-31'
and camt = 51056.00


select * from fastmoneypro_account.dbo.tran_master where ref_num = '196350'

select * from REFERRAL_HISTORY

select createdby,* from remittran where id=100348863

select * from remittran where controlno = dbo.fnaencryptstring('33JP212926829')
select * from branch_cash_in_out_history where referenceid=100349585


