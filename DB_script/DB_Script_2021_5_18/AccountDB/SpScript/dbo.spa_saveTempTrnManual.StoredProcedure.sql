USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_saveTempTrnManual]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_saveTempTrnManual]
	@flag char(1),
	@sessionID varchar(50),
	@date varchar(20),
	@narration varchar(500),
	@company_id varchar(20),
	@v_type varchar(20),
	@voucherNumber varchar(20),
	@tran_ref_code VARCHAR(50)
AS
set nocount on;
set xact_abort on;


if @voucherNumber='' or ISNULL(@voucherNumber,'0') ='0'
begin
	
	exec proc_errorHandler 1,'No Voucher number to save!',null
	return

end


if @company_id='' or @company_id is null
BEGIN
	EXEC proc_errorHandler 1,'No company ID to save!',null
	return
end

if @flag='i'
	begin
		if not exists(select tran_id from temp_tran(NOLOCK) where sessionID=@sessionID )
		begin	
			EXEC proc_errorHandler 1,'No Transaction to save!',null
			return
		end

		if (isdate(@date))=0
		BEGIN
			EXEC proc_errorHandler 1,'Invalid Date!',null
			return
		end
		IF EXISTS(SELECT TOP 1 'A' FROM AC_MASTER(NOLOCK) WHERE ac_currency<>'krw')
		BEGIN
			IF @date < CAST(GETDATE() AS DATE)
			BEGIN  
				EXEC proc_errorHandler 1,'Back date voucher entry not allow for Settlement account',NULL  
				RETURN  
			END  
		END	
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
		declare @acct_ownership varchar(2)

		-- AC Masters values
		-- Temp Voucher values

		create table #tempsumTrn (Part_Id int identity,acct_num varchar(20), 
		TotalAmt numeric(20,2), part_tran_type varchar(2))

		insert into #tempsumTrn(acct_num,TotalAmt,part_tran_type)
		select acct_num,sum(tran_amt) TotalAmt,part_tran_type from temp_tran (NOLOCK)
		where  sessionID=@sessionID 
		group by acct_num,part_tran_type

		select @Part_Id=max(Part_Id) from #tempsumTrn

		if not exists(select * from #tempsumTrn where part_tran_type='cr')
			BEGIN
				EXEC proc_errorHandler 1,'CR Transaction is missing!',null
				return;	
			end
			
		if not exists(select * from #tempsumTrn where part_tran_type='dr')
			BEGIN
					EXEC proc_errorHandler 1,'DR Transaction is missing!',null
					return;	
			end
					
		select @totalDR=sum(TotalAmt) from #tempsumTrn where part_tran_type='dr'group by part_tran_type
		select @totalCR=sum(TotalAmt) from #tempsumTrn  where part_tran_type='cr'group by part_tran_type

		 -- conditions 1 for Total DR CR equal 
		if @totalDR<>@totalCR
			begin	
				EXEC proc_errorHandler 1,'DR and CR amount not Equal!',null
				return
			end
					
			
		if exists(select * from [tran_masterDetail] with (nolock) 
		where [ref_num] = @voucherNumber and tran_type=@v_type)
		BEGIN
				EXEC proc_errorHandler 1,'Duplicate Voucher number!',null
				select '' as Error
				return
		end

set @ref_num=@voucherNumber	


BEGIN TRANSACTION	
			-- Start loop count
			set @totalRows=1
			while @Part_Id >=  @totalRows
			begin				
				-- row wise trn values
				select @ac_num=acct_num,@TotalAmt=TotalAmt,@trntype=part_tran_type 
				from #tempsumTrn where Part_Id=@totalRows
				
				IF (@@ERROR <> 0) GOTO QuitWithRollback 		
				
				Exec ProcDrCrUpdateFinal @trntype ,@ac_num, @TotalAmt,0
				
					IF (@@ERROR <> 0) GOTO QuitWithRollback 
				
				-- UPDATE BILL BY BILLL	
			
				set @totalRows=@totalRows+1
			end
			
			insert into tran_master (entry_user_id,acc_num,gl_sub_head_code
				,part_tran_type,ref_num,rpt_code,tran_amt,tran_date,
				billno,tran_type,company_id,part_tran_srl_num,created_date,RunningBalance, CHEQUE_NO)
			select entry_user_id,c.acct_num,a.gl_code,
				part_tran_type,@ref_num,rpt_code,tran_amt,@date,
				refrence,@v_type,@company_id,
			ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo,GETDATE()
			, dbo.[FNAGetRunningBalance](c.acct_num,tran_amt,part_tran_type),@tran_ref_code
			from temp_tran c(NOLOCK), ac_master a (NOLOCK)
			where c.acct_num=a.acct_num and sessionID=@sessionID
			

			
			IF (@@ERROR <> 0) GOTO QuitWithRollback

			INSERT INTO [tran_masterDetail]([ref_num] ,[tran_particular],[tran_rmks],[billdate],
				[party],[otherinfo],company_id,tranDate,tran_type )
			select top 1 @ref_num,@narration,tran_rmks,billdate,party,otherinfo,@company_id,@date,@v_type
			from temp_tran(NOLOCK) where sessionID=@sessionID

			IF (@@ERROR <> 0) GOTO QuitWithRollback 
			
			delete from temp_tran where sessionID=@sessionID
			IF (@@ERROR <> 0) GOTO QuitWithRollback 		

COMMIT TRANSACTION
		 
		select 0 as errocode, 'Save Success voucher No: 
		<a target=''_blank'' href=''../../AccountReport/AccountStatement/userreportResultSingle.aspx?trn_date='+ cast(@date as varchar) +'&type=trannumber&tran_num='+ cast(@ref_num as varchar) +'&vouchertype='+@v_type+''' > '+ cast(@ref_num as varchar) +' </a>'
 AS msg,
		null as id

		drop table #tempsumTrn
		GOTO  EndSave

QuitWithRollback:
		
ROLLBACK TRANSACTION 

		EndSave: 
end
GO
