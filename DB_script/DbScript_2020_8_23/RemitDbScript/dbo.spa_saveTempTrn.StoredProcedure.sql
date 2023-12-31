USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[spa_saveTempTrn]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*


Exec [spa_saveTempTrn] @flag='i',@sessionID='3', @date='5/19/2011',@narration='testpayment', @company_id='1'

*/

CREATE proc [dbo].[spa_saveTempTrn]
	 @flag				CHAR(1)
	,@sessionID			VARCHAR(50)
	,@date				VARCHAR(20)
	,@narration			VARCHAR(500)
	,@company_id		VARCHAR(20)		= NULL
	,@v_type			VARCHAR(20)		= NULL
	,@tran_ref_code		VARCHAR(50)		= NULL
	,@deltemp			CHAR(1)			= NULL
	,@tran_rate			VARCHAR(20)		= NULL
AS

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF @company_id='' OR @company_id IS NULL
	BEGIN
				SELECT 'No company ID to save' AS Error
				RETURN
	END

	IF @v_type IS NULL 
		SET @v_type='j'


if @flag='i'
begin



	if not exists(select tran_id from temp_tran where sessionID=@sessionID )
	begin	
			select 'No Transaction to save' as Error
			return
	end
 
	if (isdate(@date))=0
	begin
			select 'Invalid Date' as remarks
			return
	end
	
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
	select acct_num,(tran_amt) TotalAmt,part_tran_type,refrence, isnew from temp_tran 
	where  sessionID=@sessionID 

	select @Part_Id=max(Part_Id) from #tempsumTrn


			if not exists(select * from #tempsumTrn where part_tran_type='cr')
				begin
					Select  'CR Transaction is missing' as remarks
					return;	
				end
				
				if not exists(select * from #tempsumTrn where part_tran_type='dr')
				begin
					Select  'DR Transaction is missing' as remarks
						return;	
				end
				
			select @totalDR=sum(TotalAmt) from #tempsumTrn 
				where part_tran_type='dr'group by part_tran_type
				
			select @totalCR=sum(TotalAmt) from #tempsumTrn  
				where part_tran_type='cr'group by part_tran_type


			if @totalDR<>@totalCR
			begin	
						select 'DR and CR amount not Equal' as Error
						return
			end


BEGIN TRANSACTION
	
	if @v_type='j'
	begin

		select @ref_num=journal_voucher from billSetting where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set journal_voucher=cast(journal_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	if @v_type='y'
	begin

		select @ref_num=payment_voucher from billSetting where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set payment_voucher=cast(payment_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	
	if @v_type='c'
	begin

		select @ref_num=contra_voucher from billSetting where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set contra_voucher=cast(contra_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	
	if @v_type='r'
	begin

		select @ref_num=receipt_voucher from billSetting where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set receipt_voucher=cast(receipt_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	
	
	if @v_type='m'
	begin

		select @ref_num=manual_voucher from billSetting where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
		
		update billSetting set manual_voucher=cast(manual_voucher as float)+1 where company_id=@company_id
		IF (@@ERROR <> 0) GOTO QuitWithRollback 
	end
	

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
	
	insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
		,part_tran_type,ref_num,rpt_code,tran_amt,tran_date,
		billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance)
	select entry_user_id,c.acct_num,a.gl_code,
		part_tran_type,@ref_num,@tran_ref_code,tran_amt,@date,
		refrence,@v_type,@company_id,
	ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo,GETDATE()
	 , dbo.[FNAGetRunningBalance](c.acct_num,tran_amt,part_tran_type)
	from temp_tran c, ac_master a 
	where c.acct_num=a.acct_num and sessionID=@sessionID


	IF (@@ERROR <> 0) GOTO QuitWithRollback

	INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],[tran_rate],[tran_rmks],[billdate],
		[party],[otherinfo],company_id,tranDate,tran_type )
	select top 1 @ref_num,@narration,@tran_rate,tran_rmks,billdate,party,otherinfo,@company_id,@date,@v_type
	from temp_tran where sessionID=@sessionID


	IF (@@ERROR <> 0) GOTO QuitWithRollback 
update TempTrnTOApprove set Status='y' where TempId = @sessionID
delete from temp_tran where sessionID=@sessionID
IF (@@ERROR <> 0) GOTO QuitWithRollback 

COMMIT TRANSACTION
 
select '<font color="green">Save Success voucher No:</font> 
<a href=''#'' OnClick = VoucherDisplay('''+CAST(@date AS VARCHAR(15))+''','''+ CAST(@ref_num AS VARCHAR(5)) +''','''+@v_type+''') > '+ CAST(@ref_num AS VARCHAR(5)) +'</a>' as   Success

--/Reports/ListVoucherReport.aspx?voucherNo=37&voucherType=j

if @deltemp= 'y'
	delete from temptrntoapprove where tempid =@sessionID



drop table #tempsumTrn



GOTO  EndSave

QUITWITHROLLBACK:
ROLLBACK TRANSACTION 



ENDSAVE: 

end


GO
