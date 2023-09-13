
ALTER PROCEDURE proc_voucherEntryUSD
(
	@flag			CHAR(10),
	@sessionID		VARCHAR(50) = null,
	@entry_user_id VARCHAR(50) = null,
	@acct_num		VARCHAR(20) = null,
	@part_tran_type VARCHAR(5) = null,
	@ex_rate		MONEY = null,
	@lc_amt			MONEY = null,
	@usd_amt		MONEY = null,
	@tran_date		DATE = null,
	@tran_id		int = NULL,
    @dept_id		VARCHAR(100) = NULL,
	@branch_id		int = NULL,
	@emp_name		VARCHAR(100) = NULL,
	@field1			VARCHAR(100) = NULL,
	@field2		    VARCHAR(100) = NULL,
	@trn_currency   VARCHAR(5)	 =NULL
    
)
AS
Set nocount on
IF @flag = 'i'
BEGIN 
	IF EXISTS(
		SELECT 'A' FROM ac_master a(nolock)
		where a.acct_num = @acct_num
		AND isnull(A.ac_currency,'KRW')<>'KRW'
		AND a.clr_bal_amt*-1 < @usd_amt
		and a.acct_name  not like '%comm%'
		) AND @part_tran_type = 'CR'
	BEGIN
		exec proc_errorHandler 1,'Balance not available',null
		return
	END
	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,part_tran_type,usd_amt,ex_rate,tran_amt,tran_date,rpt_code,dept_id,branch_id,field1,field2,trn_currency,emp_name)	--tran_amt = usd_amt
	SELECT @sessionID,@entry_user_id,@acct_num,@part_tran_type,@usd_amt,@ex_rate,@lc_amt,GETDATE(),'USDVOUCHER',@dept_id,@branch_id,@field1,@field2,@trn_currency,@emp_name
	
	exec proc_errorHandler 0,'Record Inserted successfully!',null
	return
END

else IF @flag = 's'
BEGIN
	SELECT t.tran_id,t.part_tran_type, t.tran_amt,t.acct_num+' | '+a.acct_name as acct_num, t.usd_rate, t.lc_amt_cr
	,d.DepartmentName,am.agentName,t.emp_name,t.trn_currency,t.usd_amt,t.ex_rate, t.tran_date
	FROM temp_tran t(nolock)
	INNER JOIN ac_master a(nolock) on t.acct_num= a.acct_num
	LEFT JOIN dbo.Department d(NOLOCK) ON t.dept_id=d.RowId
	LEFT JOIN FastMoneyPro_Remit.dbo.agentMaster am(NOLOCK) ON t.branch_id=am.agentId
	WHERE sessionID = @sessionID
	ORDER BY tran_date
	return
END
else if @flag='d'
BEGIN
	Delete from temp_tran where tran_id = @tran_id
	exec proc_errorHandler 0,'Record Deleted successfully!',null
	return
END
