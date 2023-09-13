
ALTER PROC PROC_TRANSACTION_PAID_VOUCHER_ENTRY
(
	@controlNo	VARCHAR(30) 
	,@tranDate VARCHAR(20)
)
AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @refNum VARCHAR(20), @newRefNum VARCHAR(20)

	IF EXISTS(SELECT 1 FROM TRAN_MASTER (NOLOCK) WHERE FIELD1 = @controlNo AND tran_type = 'j' AND FIELD2 = 'Remittance Voucher' 
				AND ISNULL(ACCT_TYPE_CODE, 'Send') = 'Paid')
	BEGIN
		select 1 as errocode,'Voucher already generated!' as   msg,null as id
		RETURN
	END

	SELECT @refNum = ref_num FROM TRAN_MASTER (NOLOCK) WHERE FIELD1 = @controlNo AND tran_type = 'j' AND FIELD2 = 'Remittance Voucher'
	AND acct_type_code IS NULL

	IF @refNum IS NULL
	BEGIN
		select 1 as errocode,'Send voucher is not generated!' as   msg,null as id
		RETURN
	END

	SET @newRefNum = @refNum + '.01'

	IF EXISTS(SELECT TOP 1 1 FROM TRAN_MASTER (NOLOCK) WHERE ref_num = @newRefNum)
		SET @newRefNum = @refNum + '.02'

	INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
		,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
		,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,acct_type_code,SendMargin, dept_id, branch_id)
	
	SELECT 'system',acc_num,gl_sub_head_code,part_tran_type = case when part_tran_type ='dr' then 'cr' else 'dr' end
		,@newRefNum,tran_amt,@tranDate
		,billno,tran_type,company_id,part_tran_srl_num,GETDATE(),RunningBalance
		,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,'Remittance Voucher',fcy_Curr,'Paid',SendMargin, dept_id, branch_id
	FROM tran_master(NOLOCK) 
	WHERE ref_num = @refNum AND tran_type = 'j'
	AND ACC_NUM IN ('139286032', '100339261593')

	DECLARE @remarks VARCHAR(100) = 'Paid Voucher: '+@controlNo

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
	SELECT  @newRefNum,@remarks,company_id,@tranDate,tran_type
	FROM [tran_masterDetail](nolock)
	WHERE [ref_num] = @refNum AND tran_type = 'j'

	
	SELECT 0 as errocode,'Successfully Paid. Voucher No: <a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?type=trannumber&tran_num='+ cast(@refNum as VARCHAR(20)) +'&vouchertype=j'' > '  
	+ cast(@newRefNum as VARCHAR(20)) +' </a>' as   msg,@newRefNum as id  
END

