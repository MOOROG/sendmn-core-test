USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_TempTrnToApprove]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_TempTrnToApprove @flag='a',@v_type,@narration,@date,@amount,@accDR,@accCR,@user
create proc [dbo].[spa_TempTrnToApprove]
	@flag char(1),
	@sessionID varchar(50)=null,
	@date varchar(20)=null,
	@narration varchar(500)=null,	
	@tran_ref_code varchar(50)=null,
	@user varchar(50)=null,
	@amount money=null,
	@tranrate money=null,
	@v_type char(5)=null,
	@accDR varchar(20)=null,
	@accCR varchar(20)=null
AS

set nocount on;

declare @rowid int

if @flag='d'
begin

	DELETE FROM TempTrnTOApprove WHERE TempId=@sessionID
	DELETE FROM temp_tran where sessionID = @sessionID
	
end

if @flag='i'
begin

	if not exists(select top 1 * from temp_tran where sessionID=@sessionID and part_tran_type='cr')
	begin
		exec proc_errorHandler 1,'CR Transaction is missing',null
		return;	
	end
				
	if not exists(select top 1 * from temp_tran where sessionID=@sessionID and part_tran_type='dr')
	begin
		exec proc_errorHandler 1,'DR Transaction is missing',null
		return;	
	end
				

			-- conditions 1 for Total DR CR equal 
			if (select sum(tran_amt) from temp_tran where part_tran_type='dr' and sessionID=@sessionID  group by part_tran_type)
				<>
			 (select sum(tran_amt) from temp_tran  where part_tran_type='cr' and sessionID=@sessionID  group by part_tran_type)
			
					begin	
					
					exec proc_errorHandler 1,'DR and CR amount not Equal',null
						return
			end

			insert into TempTrnTOApprove
			(v_type,Remarks,TranCode,TranDate,Amount,TransitRate,CreatedBy,CreatedDate)
			values(@v_type,@narration,@tran_ref_code,@date,@amount,@tranrate,@user,GETDATE())
			
			select @rowid=@@IDENTITY from TempTrnTOApprove
			
			update temp_tran
			set sessionID=@rowid
			where sessionID = @sessionID
			
			select 0 as errorcode,' Temp Voucher No : <font color=''blue''>'+ cast(@rowid as varchar(20))+'</font><br>'  as msg, @rowid as id

end

if @flag='a'
begin

			insert into TempTrnTOApprove
			(v_type,Remarks,TranDate,Amount,DrAcc,CrAcc,CreatedBy,CreatedDate)
			values(@v_type,@narration,@date,@amount,@accDR,@accCR,@user,GETDATE())
			
			
			select @rowid=@@IDENTITY from TempTrnTOApprove
			
			
			insert into temp_tran(acct_num,part_tran_type,gl_sub_head_code,
				tran_amt,tran_date,sessionID)
			select @accDR, 'dr',@accDR +'|'+ dbo.FunGetACName(@accDR),@amount, @date,@rowid
			union all
			select @accCR, 'cr',@accCR +'|'+ dbo.FunGetACName(@accCR) ,@amount, @date,@rowid
		
		
			select ' Temp Voucher No : <font color=''blue''>'+ cast(@rowid as varchar(20))+'</font><br>'  as Success
end

GO
