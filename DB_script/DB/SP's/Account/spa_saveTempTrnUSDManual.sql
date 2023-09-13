
ALTER PROC [dbo].[spa_saveTempTrnUSDManual]
	@flag			CHAR(1),
	@sessionID		VARCHAR(50),
	@date			VARCHAR(20),
	@narration		NVARCHAR(500),
	@company_id		VARCHAR(20) = 1,
	@v_type			VARCHAR(20),
	@user			VARCHAR(50),
	@voucherPath	varchar(100) = null,
	@ref_num varchar(20) = null
AS

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	if @company_id='' or @company_id is null
		set @company_id= '1'
		
	if @v_type is null 
		set @v_type='j'


if @flag='i'
begin

	IF NOT EXISTS(SELECT tran_id FROM temp_tran(NOLOCK) WHERE sessionID = @sessionID AND rpt_code = 'USDVOUCHER')
	BEGIN	
		EXEC Proc_errorHandler 1,'No Transaction to save!',null
		RETURN
	END

	IF (ISDATE(@DATE))=0
	BEGIN
		EXEC proc_errorHandler 1,'Invalid Date',null
		RETURN
	END
	--IF EXISTS(SELECT TOP 1 'A' FROM AC_MASTER(NOLOCK)a
	--	INNER JOIN temp_tran T (NOLOCK) ON T.acct_num = A.acct_num
	--	WHERE ISNULL(ac_currency,'JPY')<>'JPY' AND sessionID = @sessionID
	--	AND @user <>'SYSTEM')
	--BEGIN
	--	IF @date < CAST(GETDATE() AS DATE)
	--	BEGIN  
	--		EXEC proc_errorHandler 1,'Back date voucher entry not allow for Settlement account',NULL  
	--		RETURN  
	--	END  
	--END	
	
	DECLARE @CLR_BAL_AMT float
	DECLARE @SYSTEM_RESERVED_AMT float
	DECLARE @LIEN_AMT float
	DECLARE @UTILISED_AMT float
	DECLARE @AVAILABLE_AMT float
	DECLARE @DR_BAL_LIM float
	DECLARE @totalRows int
	DECLARE @Part_Id int
	DECLARE @ac_num  varchar(20)
	DECLARE @TotalAmt numeric(20,2),@usdamt money
	DECLARE @trntype varchar(2)
	DECLARE @totalDR numeric(20,2)
	DECLARE @totalCR numeric(20,2)
	DECLARE @acct_ownership varchar(2), @billref varchar(50),@isnew varchar(2)

	-- AC Masters values
	-- Temp Voucher values
	SELECT ACCT_NUM INTO #IGNORE_ACCOUNTS
	FROM ac_master AC(NOLOCK)
	WHERE ACCT_RPT_CODE = 'RA' 
	AND GL_CODE = 0
	
	CREATE TABLE #tempsumTrn (Part_Id INT IDENTITY,acct_num VARCHAR(20), 
	TotalAmt NUMERIC(20,2), part_tran_type VARCHAR(2), billref VARCHAR(50), isnew VARCHAR(2),UsdAmt money)

	INSERT INTO #tempsumTrn(acct_num,TotalAmt,part_tran_type, billref, isnew,UsdAmt)
	SELECT T.acct_num,(tran_amt) TotalAmt,part_tran_type,refrence, isnew ,usd_amt
	FROM temp_tran T(NOLOCK)
	LEFT JOIN #IGNORE_ACCOUNTS I ON I.ACCT_NUM = T.acct_num
	WHERE  sessionID = @sessionID AND rpt_code = 'USDVOUCHER'
	AND I.ACCT_NUM IS NULL
	
	SELECT @Part_Id = max(Part_Id) FROM #tempsumTrn

	IF EXISTS(SELECT * FROM #tempsumTrn WHERE ISNULL(acct_num, '') = '')
	BEGIN
		exec proc_errorHandler 1,'One or more invalid/missing account''s found!',null
		return;	
	END

	if not exists(select * from #tempsumTrn where part_tran_type='cr')
	begin
		exec proc_errorHandler 1,'CR Transaction is missing',null
		return;	
	end
				
	if not exists(select * from #tempsumTrn where part_tran_type='dr')
	begin
		exec proc_errorHandler 1,'DR Transaction is missing',null
			return;	
	end
				
	SELECT @totalDR = SUM(TotalAmt) FROM #tempsumTrn WHERE part_tran_type = 'dr' 
				
	SELECT @totalCR = SUM(TotalAmt) FROM #tempsumTrn WHERE part_tran_type = 'cr'

	IF ISNULL(@totalDR,0) <> ISNULL(@totalCR,0.1)
	begin	
		DECLARE @DIFF MONEY = @totalDR -  @totalCR
		IF @totalDR > @totalCR AND ABS(@DIFF) < 1
			UPDATE TOP (1) #tempsumTrn SET TotalAmt = TotalAmt - ABS(@DIFF) WHERE part_tran_type = 'dr' 
		ELSE IF @totalCR > @totalDR AND ABS(@DIFF) < 1
			UPDATE TOP (1) #tempsumTrn SET TotalAmt = TotalAmt - ABS(@DIFF) WHERE part_tran_type = 'CR' 
	end
	
	SELECT @totalDR = SUM(TotalAmt) FROM #tempsumTrn WHERE part_tran_type = 'dr' 
				
	SELECT @totalCR = SUM(TotalAmt) FROM #tempsumTrn WHERE part_tran_type = 'cr'
		--PRINT @totalDR
		--PRINT @totalCR
	IF ISNULL(@totalDR,0) <> ISNULL(@totalCR,0.1)
	begin	
		exec proc_errorHandler 1,'DR and CR amount not Equal',null
		return
	end
	IF EXISTS(
		SELECT 'A' FROM temp_tran(NOLOCK) T
		INNER JOIN ac_master a(nolock) on a.acct_num = t.acct_num
		where t.sessionID = @sessionID AND t.rpt_code = 'USDVOUCHER'
		AND isnull(A.ac_currency,'JPY')<>'JPY'
		AND a.clr_bal_amt*-1 < T.usd_amt AND T.part_tran_type = 'CR'
		AND ISNULL(A.ACCT_TYPE_CODE,'') = 'INTERNALAC' AND T.entry_user_id <> 'system'
		)
	BEGIN
		exec proc_errorHandler 1,'Balance not available',null
		return
	END

--SELECT * FROM #tempsumTrn
--RETURN

BEGIN TRANSACTION
	
-- Start loop count
set @totalRows=1
while @Part_Id >=  @totalRows
begin
			
			-- row wise trn values
			select @ac_num = acct_num,@TotalAmt = TotalAmt,@trntype = part_tran_type,@billref = billref,@isnew = isnew
				,@usdamt = UsdAmt
			from #tempsumTrn where Part_Id = @totalRows
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			Exec ProcDrCrUpdateFinal @trntype ,@ac_num, @TotalAmt,@usdamt
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
		-- UPDATE BILL BY BILLL	
		Exec procEntryBillByBill @sessionID,@date,
			@ac_num,@ref_num,@billref,@isnew,@trntype,@v_type,@TotalAmt
		

set @totalRows=@totalRows+1
end
	
	INSERT INTO tran_master (
		entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,tran_amt,tran_date
		,billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
		,usd_amt,usd_rate,branchId,departmentId,employeeName,field1,field2,fcy_Curr,dept_id,branch_id,CHEQUE_NO)
	SELECT 
		entry_user_id,c.acct_num,a.gl_code,part_tran_type,@ref_num,tran_amt,@date
		,refrence,@v_type,@company_id,
		ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo,GETDATE()
		 , dbo.[FNAGetRunningBalance](c.acct_num,tran_amt,part_tran_type)
		 ,C.usd_amt,ISNULL(C.ex_rate,C.usd_rate),c.branch_id,dept_id,emp_name,field1,field2,ISNULL(trn_currency,'JPY'),c.dept_id,c.branch_id,c.CHEQUE_NO
	FROM temp_tran c(NOLOCK), ac_master a (NOLOCK)
	WHERE c.acct_num = a.acct_num and sessionID = @sessionID
	AND rpt_code = 'USDVOUCHER'

	IF (@@ERROR <> 0) GOTO QuitWithRollback

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],[tran_rmks],[billdate],
		[party],[otherinfo],company_id,tranDate,tran_type,voucher_image )
	select top 1 @ref_num,@narration,tran_rmks,billdate,party,otherinfo,@company_id,@date,@v_type,@voucherPath
	from temp_tran(NOLOCK) where sessionID = @sessionID AND rpt_code = 'USDVOUCHER'


	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
	DELETE FROM temp_tran WHERE sessionID = @sessionID
IF (@@ERROR <> 0) GOTO QuitWithRollback 

COMMIT TRANSACTION
 
select 0 as errocode,'Save Success voucher No: 
<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+cast(@date as varchar(15)) 
+'&type=trannumber&tran_num='+ cast(@ref_num as varchar(50)) +'&vouchertype='+@v_type+''' > '
+ cast(@ref_num as varchar(50)) +' </a>' as   msg,@ref_num as id

DROP TABLE #tempsumTrn

GOTO  EndSave

QUITWITHROLLBACK:
ROLLBACK TRANSACTION 

ENDSAVE: 
END


