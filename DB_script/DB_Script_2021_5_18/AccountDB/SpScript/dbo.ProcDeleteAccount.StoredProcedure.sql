USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcDeleteAccount]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ProcDeleteAccount]
@flag char(1),
@rowid varchar(20),
@user varchar(20)=null

AS

set nocount on;

if @flag='d'
begin
	
	IF EXISTS(select TOP 1 'A' from tran_master with(nolock) 
		WHERE acc_num =(select acct_num from ac_master(NOLOCK) where acct_id = @rowid)
	)
	begin
		EXEC proc_errorHandler 0, 'SORRY, ACCOUNT ALREADY EXISTS IN VOUCHER!',null
		Exec JobHistoryRecord 'i','ACCOUNT DELETED','FAIL',@rowid,@user ,'',@user
		RETURN
	end

	IF (select ISNULL(clr_bal_amt,0) from ac_master with(nolock)  where acct_id=@rowid)= 0
	begin
		EXEC proc_errorHandler 0, 'SORRY, ACCOUNT ALREADY EXISTS IN VOUCHER!',null
		Exec JobHistoryRecord 'i','ACCOUNT DELETED','FAIL',@rowid,@user ,'',@user
		RETURN
	end

	delete from ac_master where acct_id=@rowid
	Exec JobHistoryRecord 'i','ACCOUNT DELETED','SUCCESS',@rowid,@user ,'',@user
	EXEC proc_errorHandler 0, 'DELETE COMPLETED!',null

	--if not exists( select * from tran_master with(nolock)
	--where acc_num =(select acct_num from ac_master where acct_id=@rowid)) 
	--and (select clr_bal_amt from ac_master with(nolock)  where acct_id=@rowid)= 0
	--begin
	
	--	delete from ac_master where acct_id=@rowid
	--	Exec JobHistoryRecord 'i','ACCOUNT DELETED','SUCCESS',@rowid,@user ,'',@user
	--	EXEC proc_errorHandler 0, 'DELETE COMPLETED!',null
		
	--end 
	--else
	--begin
	
	--	EXEC proc_errorHandler 0, 'SORRY, ACCOUNT ALREADY EXISTS IN VOUCHER!',null
	--	Exec JobHistoryRecord 'i','ACCOUNT DELETED','FAIL',@rowid,@user ,'',@user
	
	--end
	
end


GO
