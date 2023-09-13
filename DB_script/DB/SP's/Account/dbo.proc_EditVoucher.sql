SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROC proc_EditVoucher
(
	 @flag		VARCHAR(10)
	,@refNum	VARCHAR(20)		= NULL
	,@tranId	VARCHAR(20)		= NULL
	,@tranType	CHAR(2)			= NULL
	,@sessionID VARCHAR(50)		= NULL
	,@vType		CHAR(1)			= NULL
	,@accNum	VARCHAR(50)		= NULL
	,@amount    MONEY			= NULL
	,@user		VARCHAR(50)		= NULL
	,@remarks	VARCHAR(500)	= NULL
	,@date		VARCHAR(10)		= NULL
	,@usd_amt	MONEY			= NULL
	,@ex_rate	MONEY			= NULL
	,@field1	VARCHAR(500)	= NULL
	,@field2	VARCHAR(500)	= null
	,@branch_id	INT				= NULL
	,@dept_id	INT				= NULL
	,@emp_name	VARCHAR(100)	= NULL
	,@trn_currency	VARCHAR(5)	= NULL
	,@chequeNo	VARCHAR(50)		= NULL
)
AS
BEGIN
IF @flag = 'i'
BEGIN
	--IF EXISTS(SELECT 1 FROM AC_MASTER (NOLOCK) WHERE ACCT_RPT_CODE = 'CTA' AND ACCT_NUM = @accNum)
	--BEGIN
	--	exec proc_errorHandler 1,'Entry to transit account can not be done manually!',null
	--	RETURN
	--END

	INSERT INTO dbo.Temp_Tran (sessionID ,entry_user_id ,acct_num ,part_tran_type ,ref_num ,tran_amt ,v_type,RunningBalance,rpt_code
	,usd_amt,ex_rate,field1,field2,branch_id,dept_id,emp_name,trn_currency)
	SELECT  @sessionID,@user,@accNum,@tranType,@refNum,@amount,@vType,available_amt ,acct_rpt_code
	,@usd_amt,@ex_rate,@field1,@field2,@branch_id,@dept_id,@emp_name,@trn_currency
	FROM dbo.ac_master (nolock)	WHERE acct_num = @accNum
			
	EXEC proc_errorHandler 0,'Record inserted successfully!',NULL  

END
ELSE IF @flag = 'FCYI'
BEGIN
	--IF EXISTS(SELECT 1 FROM AC_MASTER (NOLOCK) WHERE ACCT_RPT_CODE = 'CTA' AND ACCT_NUM = @accNum)
	--BEGIN
	--	exec proc_errorHandler 1,'Entry to transit account can not be done manually!',null
	--	RETURN
	--END
	IF EXISTS(
		SELECT 'A' FROM ac_master a(nolock)
		where a.acct_num = @accNum
		AND isnull(A.ac_currency,'JPY')<>'JPY'
		AND a.clr_bal_amt*-1 < @usd_amt
		AND ISNULL(ACCT_TYPE_CODE,'') = 'INTERNALAC'
		) AND @tranType = 'CR'
	BEGIN
		exec proc_errorHandler 1,'Balance not available',null
		return
	END	
	INSERT INTO dbo.Temp_Tran (sessionID ,entry_user_id ,acct_num ,part_tran_type ,ref_num ,tran_amt ,v_type,RunningBalance,rpt_code
	,usd_amt,ex_rate,field1,field2,branch_id,dept_id,emp_name,trn_currency)
	SELECT  @sessionID,@user,@accNum,@tranType,@refNum,@amount,@vType,available_amt ,'USDVOUCHER'
	,@usd_amt,@ex_rate,@field1,@field2,@branch_id,@dept_id,@emp_name,ISNULL(@trn_currency,'JPY')
	FROM dbo.ac_master (nolock)	WHERE acct_num = @accNum
			
	EXEC proc_errorHandler 0,'Record inserted successfully!',NULL  

END
ELSE IF @flag = 'REVERSE'
BEGIN
	IF NOT EXISTS(SELECT 'A' FROM tran_master(NOLOCK) WHERE ref_num = @refNum AND tran_type = @vType )
	BEGIN
		EXEC proc_errorHandler 1,'Voucher not found',NULL  
		RETURN
	END	
	IF EXISTS(SELECT TOP 1 'A' FROM AC_MASTER(NOLOCK) WHERE ac_currency<>'krw')
	BEGIN
		SET @date = CAST(GETDATE() AS DATE)
	END	
	DECLARE @newRefNo varchar(20)
	IF EXISTS(SELECT 'A' FROM tran_master(NOLOCK) WHERE ref_num = @refNum+'.01' AND tran_type = @vType )
	BEGIN
		EXEC proc_errorHandler 1,'Voucher already reversed',NULL  
		RETURN
	END
	
	IF @date IS NULL
		SET @date = CAST(GETDATE() AS DATE)
	
	BEGIN TRANSACTION

	if @vType ='j'
	BEGIN
		set @newRefNo = @refNum+'.01'
	END
	if @vType ='r'
	BEGIN
		set @newRefNo = @refNum+'.01'
	END
	if @vType ='c'
	BEGIN
		set @newRefNo = @refNum+'.01'
	END
	if @vType ='y'
	BEGIN
		set @newRefNo = @refNum+'.01'
	END

	----### CANCEL REVERSAL FOR CAMBODIA & TRANGLO ----
	IF EXISTS(SELECT 'A' FROM tran_master(NOLOCK)WHERE ref_num = @refNum AND tran_type = @vType AND acc_num IN ('771155503','771345592' ))
	BEGIN
		DECLARE @CHARGE MONEY
		SELECT @CHARGE = tran_amt FROM tran_master(NOLOCK)WHERE ref_num = @refNum AND tran_type = @vType AND acc_num = '900141035109'

		INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
			,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
			,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,acct_type_code,SendMargin)
		
		SELECT @user,acc_num,gl_sub_head_code,part_tran_type = case when part_tran_type ='dr' then 'cr' else 'dr' end
			,@newRefNo,CASE WHEN ACC_NUM='910141036526' THEN @CHARGE WHEN gl_sub_head_code IN('79','72') THEN (tran_amt -@CHARGE ) ELSE tran_amt END
			,@date,billno,tran_type,company_id,part_tran_srl_num,GETDATE(),RunningBalance
			,usd_amt = CASE WHEN ACC_NUM='910141036526' THEN @CHARGE WHEN gl_sub_head_code IN('79','72') THEN (tran_amt -@CHARGE ) ELSE usd_amt END
			,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,'Reverse',SendMargin
		FROM tran_master(NOLOCK) 
		WHERE ref_num = @refNum AND tran_type = @vType AND gl_sub_head_code <> '78'

		----Bank Charge By Foreign Settlement Bank then made reverse entry in Tranglo - Comm Payable USD
		IF EXISTS(SELECT 'A' FROM tran_master(NOLOCK)WHERE ref_num = @refNum AND tran_type = @vType AND acc_num ='910141036095' )
		BEGIN
			SELECT @CHARGE = tran_amt FROM tran_master(NOLOCK)WHERE ref_num = @refNum AND tran_type = @vType AND acc_num = '910141036095'
			INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
				,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
				,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,acct_type_code,SendMargin)
		
			SELECT top 1 @user,acc_num,gl_sub_head_code,part_tran_type = case when part_tran_type ='dr' then 'cr' else 'dr' end
				,@newRefNo,@CHARGE
				,@date,billno,tran_type,company_id,part_tran_srl_num,GETDATE(),RunningBalance
				,usd_amt = @CHARGE/usd_rate
				,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,'Reverse',SendMargin
			FROM tran_master(NOLOCK) 
			WHERE ref_num = @refNum AND tran_type = @vType AND acc_num ='781345605'
		END

	END
	ELSE
	BEGIN
		INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
			,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
			,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,acct_type_code,SendMargin)
	
		SELECT @user,acc_num,gl_sub_head_code,part_tran_type = case when part_tran_type ='dr' then 'cr' else 'dr' end
			,@newRefNo,tran_amt,@date
			,billno,tran_type,company_id,part_tran_srl_num,GETDATE(),RunningBalance
			,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,'Reverse',SendMargin
		FROM tran_master(NOLOCK) 
		WHERE ref_num = @refNum AND tran_type = @vType
	END

	SET @remarks = 'Reverse entry of voucher no :'+cast(@refNum as varchar) +ISNULL(@remarks,'')

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],company_id,tranDate,tran_type )
	SELECT  @newRefNo,@remarks,company_id,@date,tran_type
	FROM [tran_masterDetail] WHERE [ref_num] = @refNum AND tran_type = @vType

	COMMIT TRANSACTION

	SELECT 0 as errocode,'Successfully Reversed. Voucher No: <a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?type=trannumber&tran_num='+ cast(@newRefNo as VARCHAR(20)) +'&vouchertype='+@vtype+''' > '  
	+ cast(@newRefNo as VARCHAR(20)) +' </a>' as   msg,NULL as id  


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

ELSE IF @flag='sv'  -- search voucher for edit
BEGIN
	DELETE FROM temp_tran WHERE ref_num = @refNum AND v_type = @tranType
	DELETE FROM temp_tran  WHERE sessionID = @sessionID
	
	--IF EXISTS(SELECT 1 FROM TRAN_MASTER M(NOLOCK)
	--			INNER JOIN AC_MASTER A(NOLOCK) ON A.ACCT_NUM = M.ACC_NUM 
	--		WHERE ACCT_RPT_CODE = 'CTA' AND ref_num = @refNum AND tran_type = @tranType)
	--BEGIN
	--	exec proc_errorHandler 1,'Entry with transit account can not be modified manually!',null
	--	RETURN
	--END
	--if exists(select 'a' from tran_master(nolock) where ref_num = @refNum and tran_type = @tranType and entry_user_id = 'system')	
	--begin
	--	EXEC proc_errorHandler 1,'System generated voucher can not be edited',NULL  
	--	return
	--end
	--if exists(select 'a' from tran_master(nolock) where ref_num = @refNum and tran_type = @tranType and fcy_Curr <>'KRW'	)	
	--begin
	--	EXEC proc_errorHandler 1,'FCY voucher can not be edited!',NULL  
	--	return
	--end
	IF NOT EXISTS(SELECT 'A' FROM Temp_Tran WHERE ref_num=@refNum AND v_type=@tranType and sessionID=@sessionID)
	BEGIN			
		INSERT INTO dbo.Temp_Tran
				( sessionID ,entry_user_id ,acct_num ,gl_sub_head_code ,part_tran_srl_num ,
				part_tran_type ,ref_num ,rpt_code ,tran_amt ,tran_date ,tran_particular ,tran_rmks ,billdate ,billno 
				,party,otherinfo,v_type,RunningBalance,usd_amt,usd_rate,ex_rate,field1,field2,refrence,branch_id
				,dept_id,emp_name,trn_currency
				)
		SELECT  @sessionID,a.entry_user_id, a.acc_num,a.gl_sub_head_code,a.part_tran_srl_num,
				a.part_tran_type,a.ref_num,a.rpt_code,a.tran_amt,a.tran_date,b.tran_particular,b.tran_rmks,b.billdate,a.billno
				,b.party,b.otherinfo,a.tran_type,ISNULL(a.RunningBalance,0),a.usd_amt,a.usd_rate,a.usd_rate,a.field1,a.field2
				,a.acct_type_code,a.branchId,a.departmentId,a.employeeName,A.fcy_Curr
		FROM dbo.tran_master a WITH(NOLOCK)
		INNER JOIN tran_masterDetail b WITH(NOLOCK) ON a.ref_num = b.ref_num AND b.tran_type = a.tran_type
		WHERE a.ref_num = @refNum AND a.tran_type = @tranType
	END

	SELECT t.tran_id,t.part_tran_type, t.tran_amt,t.acct_num+' | '+a.acct_name as acct_num, t.usd_rate, t.lc_amt_cr
	,d.DepartmentName,am.agentName,t.emp_name,t.trn_currency,t.usd_amt,t.ex_rate
	,tran_date = convert(varchar,t.tran_date,101),t.tran_particular
	FROM temp_tran t(nolock)
	INNER JOIN ac_master a(nolock) on t.acct_num= a.acct_num
	LEFT JOIN dbo.Department d(NOLOCK) ON t.dept_id=d.RowId
	LEFT JOIN FastMoneyPro_Remit.dbo.agentMaster am(NOLOCK) ON t.branch_id=am.agentId
	WHERE t.sessionID = @sessionID
	AND ref_num = @refNum AND v_type = @tranType	
			
END
	
ELSE IF @flag='s'
BEGIN
	SELECT t.tran_id,t.part_tran_type, t.tran_amt,t.acct_num+' | '+a.acct_name as acct_num, t.usd_rate, t.lc_amt_cr
	,d.DepartmentName,am.agentName,t.emp_name,t.trn_currency,t.usd_amt,t.ex_rate
	,tran_date = convert(varchar,t.tran_date,101),t.tran_particular
	FROM temp_tran t(nolock)
	INNER JOIN ac_master a(nolock) on t.acct_num= a.acct_num
	LEFT JOIN dbo.Department d(NOLOCK) ON t.dept_id=d.RowId
	LEFT JOIN FastMoneyPro_Remit.dbo.agentMaster am(NOLOCK) ON t.branch_id=am.agentId
	WHERE t.sessionID = @sessionID
	AND ref_num = @refNum AND v_type = @tranType	
END
	
ELSE IF @flag='d'
BEGIN
	DELETE FROM dbo.Temp_Tran WHERE sessionID=@sessionID AND tran_id = @tranId
	    
	EXEC proc_errorHandler 0,'Record deleted successfully!',NULL  
	    
END

	----## FOR FINAL SAVE 
ELSE IF @flag = 'final'
BEGIN  
	  
	IF NOT EXISTS(SELECT tran_id FROM Temp_Tran(NOLOCK) WHERE sessionID = @sessionID )  
	BEGIN   
		EXEC proc_errorHandler 1,'No Transaction to save!',NULL  
		RETURN  
	END  
	  
	IF (ISDATE(@date)) = 0  
	BEGIN  
		EXEC proc_errorHandler 1,'Invalid Date',NULL  
		RETURN  
	END  

	--IF EXISTS(SELECT TOP 1 'A' FROM AC_MASTER(NOLOCK)a
	--	INNER JOIN temp_tran T (NOLOCK) ON T.acct_num = A.acct_num
	--	WHERE ISNULL(ac_currency,'JPY')<>'JPY' AND sessionID = @sessionID)
	--BEGIN
	--	IF @date < CAST(GETDATE() AS DATE)
	--	BEGIN  
	--		EXEC proc_errorHandler 1,'Back date voucher entry not allow for Settlement account',NULL  
	--		RETURN  
	--	END  
	--END	

	DECLARE @totalRows INT  
	DECLARE @Part_Id INT  
	DECLARE @ac_num  VARCHAR(20)  
	DECLARE @TotalAmt NUMERIC(20,2)  
	DECLARE @trntype VARCHAR(2)  
	DECLARE @totalDR NUMERIC(20,2)  
	DECLARE @totalCR NUMERIC(20,2)  
	  
	-- Temp Voucher values
	SELECT ACCT_NUM INTO #IGNORE_ACCOUNTS
	FROM ac_master AC(NOLOCK)
	WHERE ACCT_RPT_CODE = 'RA' 
	AND GL_CODE = 0
	  
	CREATE TABLE #tempsumTrn (Part_Id INT IDENTITY,acct_num VARCHAR(20),TotalAmt NUMERIC(20,2), part_tran_type VARCHAR(2))  
	  
	INSERT INTO #tempsumTrn(acct_num,TotalAmt,part_tran_type)  
	SELECT t.acct_num,t.tran_amt,t.part_tran_type 
	FROM temp_tran T(NOLOCK)
	LEFT JOIN #IGNORE_ACCOUNTS I ON I.ACCT_NUM = T.acct_num
	WHERE  t.sessionID = @sessionID AND t.ref_num  = @refNum AND v_type = @vType
	AND I.ACCT_NUM IS NULL
	  
	SELECT @Part_Id = max(Part_Id) FROM #tempsumTrn  
	  
	IF NOT EXISTS(SELECT * FROM #tempsumTrn WHERE part_tran_type = 'cr')  
	BEGIN  
		EXEC proc_errorHandler 1,'CR Transaction is missing',NULL  
		RETURN;   
	END  
	      
	IF NOT EXISTS(SELECT * FROM #tempsumTrn WHERE part_tran_type = 'dr')  
	BEGIN  
		EXEC proc_errorHandler 1,'DR Transaction is missing',NULL  
		RETURN;   
	END  
	      
	SELECT @totalDR = sum(TotalAmt) FROM #tempsumTrn  WHERE part_tran_type = 'dr'
	      
	SELECT @totalCR = sum(TotalAmt) FROM #tempsumTrn WHERE part_tran_type = 'cr'
	  
	IF @totalDR <> @totalCR  
	BEGIN   
		EXEC proc_errorHandler 1,'DR and CR amount not Equal',NULL  
		RETURN  
	END  
	  
BEGIN TRANSACTION  
	   
-- Start loop count  
SET @totalRows = 1  
WHILE @Part_Id >=  @totalRows  
BEGIN  
	     
	-- row wise trn values  
	SELECT @ac_num = acct_num,@TotalAmt = TotalAmt,@trntype = part_tran_type 
	FROM #tempsumTrn WHERE Part_Id = @totalRows  
	     
	EXEC ProcDrCrUPDATEFinal @trntype ,@ac_num, @TotalAmt,0  
	     
	-- UPDATE BILL BY BILLL   
	EXEC procEntryBillByBill @sessionID,@date,  
	@ac_num,@refNum,NULL,NULL,@trntype,@vType,@TotalAmt  
	  
SET @totalRows = @totalRows+1  
END  
	
	INSERT INTO tran_master_deleted(tran_id,acc_num,del_flg,entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type
		,ref_num,rpt_code,tran_amt,tran_date,tran_particular,tran_rmks,billno,billdate,party,otherinfo,tran_type,created_date
		,v_type,vfd_user_id,vfd_date,usd_amt,usd_rate,field1,field2,dept_id,branch_id,emp_name,trn_currency)
	SELECT tran_id,acc_num,'D',entry_user_id,gl_sub_head_code,part_tran_srl_num,part_tran_type
	,T.ref_num,rpt_code,tran_amt,tran_date,tran_particular,tran_rmks,billno,billdate,D.party,D.otherinfo,T.tran_type,created_date
	,T.tran_type, @user, GETDATE(),t.usd_amt,t.usd_rate,t.field1,t.field2,t.departmentId,t.branchId,t.employeeName,t.fcy_Curr
	from tran_master T(NOLOCK)
	INNER JOIN tran_masterDetail D(NOLOCK) ON T.ref_num = D.ref_num AND T.tran_type=D.tran_type
	WHERE T.ref_num  = @refNum AND T.tran_type = @vType

	DELETE FROM tran_master WHERE ref_num  = @refNum AND tran_type = @vType 
	   
	INSERT INTO tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,rpt_code,tran_amt,tran_date,  
			billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
			,usd_amt,usd_rate,field1,field2,dept_id,branch_id,emp_name,fcy_Curr,CHEQUE_NO)  
	SELECT @user,c.acct_num,a.gl_code,part_tran_type,@refnum,rpt_code,tran_amt,@date,  
			billno,@vType,1,ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo,GETDATE()
			, dbo.[FNAGetRunningBalance](c.acct_num,tran_amt,part_tran_type)
			,c.usd_amt,c.ex_rate,c.field1,c.field2,c.dept_id,c.branch_id,c.emp_name,c.trn_currency,@chequeNo
	FROM temp_tran c (NOLOCK), ac_master a (NOLOCK)   
	WHERE c.acct_num = a.acct_num 
	and C.sessionID = @sessionID  AND C.ref_num  = @refNum AND C.v_type = @vType
	 
	UPDATE [tran_masterDetail] SET [tran_particular] = @remarks,tranDate = @DATE
	WHERE ref_num  = @refNum AND tran_type = @vType 
	   
	DELETE FROM temp_tran WHERE sessionID = @sessionID  
	  
COMMIT TRANSACTION  
	
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
	   
	SELECT 0 as errocode,'Successfully saved. Voucher No:   
	<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+cast(@date as VARCHAR(15))   
	+'&type=trannumber&tran_num='+ cast(@refnum as VARCHAR(50)) +'&vouchertype='+@vtype+''' > '  
	+ cast(@refnum as VARCHAR(50)) +' </a>' as   msg,NULL as id  
	  
	DROP TABLE #tempsumTrn  
	  
	END  
END

GO

