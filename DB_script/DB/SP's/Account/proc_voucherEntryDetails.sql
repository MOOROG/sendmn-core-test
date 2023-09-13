

ALTER PROCEDURE proc_voucherEntryDetails
(
	@flag			CHAR(1),
	@sessionID		VARCHAR(50) = null,
	@entry_user_id VARCHAR(50) = null,
	@acct_num		VARCHAR(20) = null,
	@part_tran_type VARCHAR(5) = null,
	@tran_amt		MONEY = null,
	@tran_date		DATE = null,
	@tran_id		int = NULL,
	@dept_id		VARCHAR(100) = NULL,
	@branch_id		int = NULL,
	@emp_name		VARCHAR(100) = NULL,
	@field1			VARCHAR(100) = NULL,
	@field2		    VARCHAR(100) = NULL
    
)
AS
Set nocount on
IF @flag = 'i'
BEGIN 
	IF EXISTS(SELECT 1 FROM AC_MASTER (NOLOCK) WHERE ACCT_RPT_CODE = 'CTA' AND ACCT_NUM = @acct_num)
	BEGIN
		exec proc_errorHandler 1,'Entry to transit account can not be done manually!',null
		RETURN
	END

	INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,part_tran_type,tran_amt,tran_date,dept_id,branch_id,emp_name,field1,field2)
	SELECT @sessionID,@entry_user_id,@acct_num,@part_tran_type,@tran_amt,GETDATE(),@dept_id,@branch_id,@emp_name,@field1,@field2 
	
	exec proc_errorHandler 0,'Record Inserted successfully!',null
	return
END

else IF @flag = 's'
BEGIN
	SELECT t.tran_id,t.part_tran_type, t.tran_amt,t.acct_num+' | '+a.acct_name as acct_num, d.DepartmentName,am.agentName,t.emp_name
	FROM temp_tran t(nolock)
	INNER JOIN ac_master a(nolock) on t.acct_num= a.acct_num
	left JOIN dbo.Department d(NOLOCK) ON t.dept_id=d.RowId
	left JOIN FastMoneyPro_Remit.dbo.agentMaster am(NOLOCK) ON t.branch_id=am.agentId
	WHERE sessionID=@sessionID
	return
END
else if @flag='d'
BEGIN
	Delete from temp_tran where tran_id = @tran_id
	exec proc_errorHandler 0,'Record Deleted successfully!',null
	return
END


--truncate table temp_tran




