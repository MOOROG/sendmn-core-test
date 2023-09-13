
--exec [spa_saveTempTrn] @flag='i',@sessionID='12300000000312',@date='',@narration='',@company_id=1,@v_type='j',@user='kjBank'

ALTER proc [dbo].[spa_saveTempTrn]
	@flag			CHAR(1),
	@sessionID		VARCHAR(50),
	@date			VARCHAR(20),
	@narration		VARCHAR(500),
	@company_id		VARCHAR(20),
	@v_type			VARCHAR(20),
	@tran_ref_code	VARCHAR(50)=NULL,
	@user			VARCHAR(50),
	@voucherimg     VARCHAR(100)=NULL
AS

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	if @company_id='' or @company_id is null
		set @company_id= '1'
		
	if @v_type is null 
		set @v_type='j'


if @flag='i'
begin

	if not exists(select tran_id from temp_tran(nolock) where sessionID=@sessionID )
	begin	
			exec proc_errorHandler 1,'No Transaction to save!',null
			return
	end

	if (isdate(@date))=0
	begin
		exec proc_errorHandler 1,'Invalid Date',null
		return
	end
	IF EXISTS(SELECT TOP 1 'A' FROM AC_MASTER(NOLOCK)a
		INNER JOIN temp_tran T (NOLOCK) ON T.acct_num = A.acct_num
		WHERE ISNULL(ac_currency,'JPY')<>'JPY' AND sessionID = @sessionID)
	BEGIN
		IF @date < CAST(GETDATE() AS DATE)
		BEGIN  
			EXEC proc_errorHandler 1,'Back date voucher entry not allow for Settlement account',NULL  
			RETURN  
		END  
	END	
	--if exists(select 'n' from dbo.VOUCHER_SETTING where V_CODE = @v_type and approval_mode = 'y')
	--BEGIN
	--Exec spa_tempTrnToApprove @flag='i', @sessionid=@sessionid,@narration=@narration,@tran_ref_code=@tran_ref_code,@user=@user,@date=@date,@v_type=@v_type
	--	return 
	--END
	
	
	declare @CLR_BAL_AMT float
	declare @SYSTEM_RESERVED_AMT float
	declare @LIEN_AMT float
	declare @UTILISED_AMT float
	declare @AVAILABLE_AMT float
	declare @DR_BAL_LIM float
	declare @totalRows int
	declare @Part_Id int
	declare @ac_num  varchar(20)
	declare @TotalAmt numeric(20,2)
	declare @trntype varchar(2)
	declare @totalDR numeric(20,2)
	declare @totalCR numeric(20,2)
	declare @ref_num varchar(20)
	declare @acct_ownership varchar(2), @billref varchar(50),@isnew varchar(2)

	-- AC Masters values
	-- Temp Voucher values

	create table #tempsumTrn (Part_Id int identity,acct_num varchar(20), 
	TotalAmt numeric(20,2), part_tran_type varchar(2), billref varchar(50), isnew varchar(2))

	insert into #tempsumTrn(acct_num,TotalAmt,part_tran_type, billref, isnew)
	select acct_num,(tran_amt) TotalAmt,part_tran_type,refrence, isnew from temp_tran (NOLOCK)
	where  sessionID = @sessionID 

	select @Part_Id = max(Part_Id) from #tempsumTrn


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
				
		select @totalDR=sum(TotalAmt) from #tempsumTrn 
			where part_tran_type='dr'group by part_tran_type
				
		select @totalCR=sum(TotalAmt) from #tempsumTrn  
			where part_tran_type='cr'group by part_tran_type


		if ISNULL(@totalDR,0)<>ISNULL(@totalCR,0.1)
		begin	
			exec proc_errorHandler 1,'DR and CR amount not Equal',null
			return
		end


BEGIN TRANSACTION
	
	if @v_type='j'
	begin

		select @ref_num = journal_voucher from billSetting(NOLOCK) where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set journal_voucher=cast(journal_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	if @v_type='y'
	begin

		select @ref_num=payment_voucher from billSetting(NOLOCK) where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set payment_voucher=cast(payment_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	
	if @v_type='c'
	begin

		select @ref_num=contra_voucher from billSetting(NOLOCK) where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set contra_voucher=cast(contra_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	
	if @v_type='r'
	begin

		select @ref_num=receipt_voucher from billSetting(NOLOCK) where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set receipt_voucher=cast(receipt_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	
	
	if @v_type='m'
	begin

		select @ref_num=manual_voucher from billSetting(NOLOCK) where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set manual_voucher=cast(manual_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	
	IF EXISTS(SELECT 'A' FROM tran_masterDetail(NOLOCK) WHERE ref_num = @ref_num AND tran_type='J')
	BEGIN
		select @ref_num = journal_voucher from billSetting(NOLOCK) where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set journal_voucher=cast(journal_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	END
-- Start loop count
set @totalRows=1
while @Part_Id >=  @totalRows
begin
			
			-- row wise trn values
			select @ac_num=acct_num,@TotalAmt=TotalAmt,
				@trntype=part_tran_type,
				@billref=billref, 
				@isnew=isnew
				
			from #tempsumTrn where Part_Id=@totalRows
			
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			
			Exec ProcDrCrUpdateFinal @trntype ,@ac_num, @TotalAmt,0
			
				IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
		-- UPDATE BILL BY BILLL	
		Exec procEntryBillByBill @sessionID,@date,
			@ac_num,@ref_num,@billref,@isnew,@trntype,@v_type,@TotalAmt
		

set @totalRows=@totalRows+1
end
	
	insert into tran_master (entry_user_id,acc_num,gl_sub_head_code,part_tran_type,ref_num,rpt_code,tran_amt,tran_date,
		billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance
		,branchId,departmentId,employeeName,field1,field2,fcy_Curr,usd_amt,usd_rate)
	select entry_user_id,c.acct_num,a.gl_code,part_tran_type,@ref_num,@tran_ref_code,tran_amt,@date,
		refrence,@v_type,@company_id,ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo,GETDATE()
	 , dbo.[FNAGetRunningBalance](c.acct_num,tran_amt,part_tran_type)
	 ,c.branch_id,dept_id,emp_name,field1,field2,'JPY',tran_amt,1
	from temp_tran c(nolock), ac_master a (nolock)
	where c.acct_num = a.acct_num and sessionID = @sessionID

	IF (@@ERROR <> 0) GOTO QuitWithRollback

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],[tran_rmks],[billdate],
		[party],[otherinfo],company_id,tranDate,tran_type,voucher_image )
	select top 1 @ref_num,@narration,tran_rmks,billdate,party,otherinfo,@company_id,@date,@v_type,@voucherimg
	from temp_tran(nolock) where sessionID=@sessionID


	IF (@@ERROR <> 0) GOTO QuitWithRollback 
	
	
delete from temp_tran where sessionID=@sessionID
IF (@@ERROR <> 0) GOTO QuitWithRollback 

COMMIT TRANSACTION
 
select 0 as errocode,'Save Success voucher No: 
<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+cast(@date as varchar(15)) 
+'&type=trannumber&tran_num='+ cast(@ref_num as varchar(50)) +'&vouchertype='+@v_type+''' > '
+ cast(@ref_num as varchar(50)) +' </a>' as   msg,null as id

drop table #tempsumTrn

GOTO  EndSave

QUITWITHROLLBACK:
ROLLBACK TRANSACTION 

ENDSAVE: 

end

