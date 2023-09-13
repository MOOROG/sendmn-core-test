

ALTER PROC ProcTempVoucherUploadFCY
    @xml		XML = NULL ,
    @user		NVARCHAR(35) ,
    @flag		VARCHAR(10),
	@sessionId	varchar(60)
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
BEGIN
IF @flag = 'i'

	DELETE FROM temp_tran WHERE sessionId=@sessionId
	
	INSERT INTO temp_tran(sessionId,entry_user_id,acct_num,dept_id,branch_id,emp_name,field1,field2,part_tran_type,tran_amt,trn_currency,usd_amt,ex_rate,tran_date,rpt_code)
	SELECT  @sessionId,@user,
			Ledger = p.value('@LEDGER', 'varchar(35)') ,
			Department = p.value('@DEPARTMENT', 'varchar(35)') ,
			Branch = p.value('@BRANCH', 'varchar(35)') ,
			EmployeeName = p.value('@EMPNAME', 'varchar(35)') ,
			Field1 = p.value('@FIELD1', 'varchar(35)') ,
			Field2 = p.value('@FIELD2', 'varchar(35)') ,
            tranType = p.value('@DRCR', 'varchar(35)') ,
			krwAmount = p.value('@JPYAMOUNT', 'varchar(35)') ,
			fcy = p.value('@FCY', 'varchar(35)') ,
			fcyAmount = p.value('@FCYAMOUNT', 'varchar(35)') ,
			rate = p.value('@RATE', 'varchar(35)') 
			,tran_date = p.value('@DATE', 'varchar(35)') 
			,'USDVOUCHER'
    FROM    @xml.nodes('/root/row') AS tmp ( p );


	EXEC proc_errorHandler 0,'Record Inserted successfully!',null
RETURN
END   
	


