USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[UpdateAccountAndSave]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec UpdateAccountAndSave 's', 'admin','1','Canceled Transaction ','10/12/2010','143070038','EPD'
-- Exec UpdateAccountAndSave 's'
CREATE proc [dbo].[UpdateAccountAndSave]
	@flag char(1),
	@user varchar(20)=null,
	@company_id varchar (20)=null,
	@narration varchar(500)=null,
	@date varchar(20)=null,
	@sessionID varchar(50),
	@tran_code varchar(50)=null

AS
	set nocount on;

if @flag='s'
begin

declare @ref_num varchar(20),@tran_type varchar(2)

		 --select count(*) from temp_voucher_edit

		-- Multiple voucher check
			if (select count(distinct ref_num) from temp_voucher_edit where sessionID=@sessionID)>1 
			begin	
						select '1' error_code ,'Multiple voucher exists to edit same time' as remarks,@tran_code ID
						return
			end

			if not exists(select * from temp_voucher_edit where part_tran_type='dr' and sessionID=@sessionID)
			begin	
					select '1' error_code , 'DR set is missing' as remarks ,@tran_code ID
					return
			end
			if not exists(select * from temp_voucher_edit where part_tran_type='cr' and sessionID=@sessionID)
			begin	
					select '1' error_code ,'CR set is missing' as remarks,@tran_code ID

					return
			end
		
		-- Total DR CR equal 
			if (select sum(tran_amt) from temp_voucher_edit where part_tran_type='dr' and sessionID=@sessionID group by part_tran_type )
				<>( select sum(tran_amt) from temp_voucher_edit where part_tran_type='cr' and sessionID=@sessionID group by part_tran_type )
			begin	
						select '1' error_code , 'DR and CR amount not Equal' as remarks ,@tran_code ID

						return
			end
			
			select top 1 @ref_num=ref_num,@tran_type=tran_type
			from temp_voucher_edit where sessionID=@sessionID 


		-- Creating TEMP Table for AC Number -- Drop table #tempAccount
			create table #tempAccount(AC_num varchar(20) null )


		-- GET AC Not exists in Main set but Exist in OLD set
			insert into #tempAccount
			select distinct acc_num from tran_master 
			where ref_num=@ref_num and company_id=@company_id 
				and tran_type=@tran_type
				and acc_num not in
			(select distinct acc_num from temp_voucher_edit 
			where ref_num=@ref_num and company_id=@company_id 
				and tran_type=@tran_type and sessionID=@sessionID)
		
		-- GET All Current AC 
			insert into #tempAccount
			select distinct acc_num from temp_voucher_edit 
			where ref_num=@ref_num and company_id=@company_id 
			and tran_type=@tran_type and sessionID=@sessionID

BEGIN TRANSACTION

		-- Move TRA to Deleted Table 
			insert into tran_master_deleted
			(
			tran_id,acc_num,entry_user_id,
			gl_sub_head_code,part_tran_srl_num,part_tran_type,
			ref_num,rpt_code,tran_amt,v_type,tran_date,created_date,vfd_user_id
			)
			 select tran_id,acc_num,entry_user_id,
					gl_sub_head_code,part_tran_srl_num,part_tran_type,
					ref_num,
					case when @tran_code is null 
						then rpt_code else @tran_code end,
						tran_amt,tran_type,tran_date,GETDATE(),@user
			 from tran_master 
			where ref_num=@ref_num and company_id=@company_id 
			and tran_type=@tran_type

			IF (@@ERROR <> 0) GOTO QuitWithRollback 

		-- Delete tran_master 
        	delete from tran_master 
			where ref_num=@ref_num and company_id=@company_id 
			and tran_type=@tran_type
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback 

		-- Insert updated TRN into tran_master from temp table
			insert into tran_master (acc_num,entry_user_id,
					gl_sub_head_code,part_tran_type,
					ref_num,rpt_code,tran_amt,fl_currency,flc_rate,usd_amt,
					usd_rate,tran_date,billno,tran_type,created_date,
					company_id,part_tran_srl_num,RunningBalance)
		    select acc_num,entry_user_id,gl_code,part_tran_type,
					ref_num,@tran_code,tran_amt,fl_currency,flc_rate,v.usd_amt,
					usd_rate,@date, billno,tran_type,
					v.created_date,v.company_id,
					ROW_NUMBER() OVER(ORDER BY part_tran_type desc) AS SrNo, RunningBalance
			 from temp_voucher_edit v join ac_master a on v.acc_num=a.acct_num
			 where ref_num=@ref_num and v.company_id=@company_id 
			 and tran_type=@tran_type and sessionID=@sessionID

			IF (@@ERROR <> 0) GOTO QuitWithRollback
			
			update tran_masterDetail set tran_particular=@narration, tranDate=@date
			where ref_num=@ref_num and tran_type=@tran_type and company_id=@company_id
			
			IF (@@ERROR <> 0) GOTO QuitWithRollback		
	
		-- #### CLR BAL AMT UPDATE
				UPDATE ac_master
				SET clr_bal_amt = isnull(Total,0)
				FROM ac_master AS a
				JOIN( 
					select ac_num,isnull(sum (case when part_tran_type='dr' then tran_amt*-1 else tran_amt end),0) Total
					from tran_master t right join #tempAccount on acc_num=ac_num
					group by ac_num 
				)AS t
				ON a.acct_num = t.ac_num where a.acct_num in (select ac_num from #tempAccount)

			
				IF (@@ERROR <> 0) GOTO QuitWithRollback 

		-- #### AVAILABLE_AMT BALANCE UPDATE
			update ac_master set 
				AVAILABLE_AMT= isnull(DR_BAL_LIM,0) +  isnull(CLR_BAL_AMT,0) -  isnull(SYSTEM_RESERVED_AMT,0) -  isnull(LIEN_AMT,0)
				where acct_num in (select ac_num from #tempAccount)

				IF (@@ERROR <> 0) GOTO QuitWithRollback 

		-- Clean TEMP Voucher
			delete from temp_voucher_edit where sessionID=@sessionID
				 
				IF (@@ERROR <> 0) GOTO QuitWithRollback 

COMMIT TRANSACTION

		select 0 error_code,'Save success' as remarks,@tran_code ID

		-- Insert into JOB LOG Table
		insert into job_history(job_name,job_time,job_user,job_value,job_remarks,update_row,old_value) 
		values ('Voucher Edit',getdate(),@user,@ref_num,'Voucher update:'+ @ref_num,@ref_num,'')

GOTO  EndSave


QuitWithRollback:
ROLLBACK TRANSACTION 


EndSave: 

end



GO
