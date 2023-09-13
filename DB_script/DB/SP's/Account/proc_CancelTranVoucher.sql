
--EXEC proc_CancelTranVoucher @flag = 'REVERSE',@refNum='112664',@vType='J',@refund='N',@user='system',@remarks=''
ALTER PROC proc_CancelTranVoucher
(
	 @flag		VARCHAR(10)
	,@refNum	VARCHAR(20)		= NULL
	,@refund	CHAR(1)			= NULL
	,@vType		CHAR(1)			= NULL
	,@user		VARCHAR(50)		= NULL
	,@remarks	VARCHAR(500)	= NULL
	,@tranDate  VARCHAR(30)		= NULL
)
AS

IF @flag = 'REVERSE'
BEGIN
	DECLARE @CONTROLNO VARCHAR(30)

	SELECT TOP 1 @CONTROLNO = FIELD1 FROM TRAN_MASTER (NOLOCK) WHERE REF_NUM = @refNum

	IF EXISTS(SELECT * FROM TRAN_MASTER (NOLOCK) WHERE FIELD1 = @CONTROLNO AND ISNULL(ACCT_TYPE_CODE, '') = 'Reverse')
	BEGIN
		EXEC proc_errorHandler 1,'Voucher already reversed',NULL  
		RETURN
	END

	IF NOT EXISTS(SELECT 'A' FROM tran_master(NOLOCK) WHERE ref_num = @refNum AND tran_type = @vType and field2='Remittance Voucher')
	BEGIN
		EXEC proc_errorHandler 1,'Voucher not found',NULL  
		RETURN
	END	

	DECLARE @newRefNo varchar(20)
	IF EXISTS(SELECT 'A' FROM tran_master(NOLOCK) WHERE ref_num = @refNum+'.01' AND tran_type = @vType and field2='Remittance Voucher' AND ACCT_TYPE_CODE IS NOT NULL)
	BEGIN
		EXEC proc_errorHandler 1,'Voucher already reversed',NULL  
		RETURN
	END
	
	BEGIN TRANSACTION

	set @newRefNo = @refNum+'.01'

	DECLARE @TRAN_ID BIGINT, @NEW_ACC_NUM VARCHAR(30)

	

	SELECT @tranDate = CANCELAPPROVEDDATE 
	FROM FASTMONEYPRO_REMIT.DBO.REMITTRAN (NOLOCK)
	WHERE CONTROLNO = DBO.FNAENCRYPTSTRING(@CONTROLNO)

	IF @tranDate IS NULL
		SET @tranDate = CAST(GETDATE() AS DATE)

	BEGIN
		INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
			,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
			,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,acct_type_code,SendMargin, dept_id, branch_id)
	
		SELECT @user,acc_num,gl_sub_head_code,part_tran_type = case when part_tran_type ='dr' then 'cr' else 'dr' end
			,@newRefNo,tran_amt,@tranDate
			,billno,tran_type,company_id,part_tran_srl_num,GETDATE(),RunningBalance
			,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,'Remittance Voucher',fcy_Curr,'Reverse',SendMargin, dept_id, branch_id
		FROM tran_master(NOLOCK) 
		WHERE ref_num = @refNum AND tran_type = @vType
	END

	--IF NOT EXISTS(SELECT 1 FROM FASTMONEYPRO_REMIT.DBO.REMITTRAN (NOLOCK) 
	--			WHERE CAST(CREATEDDATE AS DATE) = CAST(@tranDate AS DATE) 
	--			AND CONTROLNO = FASTMONEYPRO_REMIT.DBO.FNAENCRYPTSTRING(@CONTROLNO))
	--BEGIN
	--	UPDATE T SET T.ACC_NUM = '139260268'
	--	FROM tran_master T(NOLOCK)
	--	INNER JOIN AC_MASTER A (NOLOCK) ON A.ACCT_NUM = T.ACC_NUM
	--	WHERE REF_NUM = @newRefNo
	--	AND (A.ACCT_RPT_CODE IN ('TCA', 'BVA') OR A.ACCT_NUM = '100139282179')
	--END

	SET @remarks = 'Reverse entry of voucher no : '+cast(@refNum as varchar) +ISNULL(@remarks,'')

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
	SELECT  @newRefNo,@remarks,company_id,@tranDate,tran_type
	FROM [tran_masterDetail](nolock)
	WHERE [ref_num] = @refNum AND tran_type = @vType

	COMMIT TRANSACTION

	SELECT 0 as errocode,'Successfully Reversed. Voucher No: <a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?type=trannumber&tran_num='+ cast(@newRefNo as VARCHAR(20)) +'&vouchertype='+@vtype+''' > '  
	+ cast(@newRefNo as VARCHAR(20)) +' </a>' as   msg,@newRefNo as id  


	UPDATE AC_MASTER 
		SET CLR_BAL_AMT = AMT,available_amt = AMT
	FROM ac_master A,(
	SELECT ACC_NUM
		, SUM (CASE WHEN PART_TRAN_TYPE = 'Dr' THEN ISNULL(TRAN_AMT,0)*-1 ELSE ISNULL(TRAN_AMT,0) END) AMT 
	FROM TRAN_MASTER WITH (NOLOCK) GROUP BY ACC_NUM) X
	WHERE A.acct_num = X.acc_num
	AND isnull(A.clr_bal_amt,0) <> isnull(X.AMT,0)

	UPDATE AC_MASTER 
		SET usd_amt = X.USDAMT
	FROM ac_master A,(
	SELECT ACC_NUM
		, SUM (CASE WHEN PART_TRAN_TYPE = 'Dr' THEN ISNULL(usd_amt,0)*-1 ELSE ISNULL(usd_amt,0) END) USDAMT 
	FROM TRAN_MASTER WITH (NOLOCK) GROUP BY ACC_NUM) X
	WHERE A.acct_num = X.acc_num
	AND isnull(A.usd_amt,0) <> isnull(X.USDAMT,0)

	RETURN
END


