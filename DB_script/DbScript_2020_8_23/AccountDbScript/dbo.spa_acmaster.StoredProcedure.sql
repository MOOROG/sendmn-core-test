USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_acmaster]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[spa_acmaster]  
 @flag char(1),  
 @acct_id varchar(50) =null,  
 @acct_num varchar(16)=null ,  
 @acct_name varchar(100)=null ,  
 @gl_code varchar(10)=null ,  
 @agent_id varchar(50)=null ,  
 @branch_id varchar(50)=null ,  
 @acct_ownership varchar(1)=null ,  
 @dr_bal_lim varchar(50)=null ,  
 @lim_expiry varchar(50) =null,  
 @acct_rpt_code varchar(10) =null,  
 @acct_type_code varchar(10) =null,  
 @frez_ref_code varchar(5) =null,  
 @acct_cls_flg varchar(1) =null,  
 @clr_bal_amt varchar(50) =null,  
 @system_reserved_amt varchar(50)=null ,  
 @system_reserver_remarks varchar(80)=null ,  
 @lien_amt varchar(50) =null,  
 @lien_remarks varchar(80) =null,  
 @utilised_amt varchar(50) =null,  
 @available_amt varchar(50)=null,  
 @ac_currency varchar(10)=null,  
 @ac_group varchar(100)=null,  
 @ac_sub_group varchar(100)=null,  
 @user varchar(10)=null,  
 @company_id varchar(10)=null,  
 @bill_bybill varchar(5)=null  
As  
  
set nocount on;  
  
if @flag='a'  
begin  
 select * from ac_master with (nolock)  
end  
  
if @flag='t'  
begin  
  
  
 select * from ac_master with (nolock)  where acct_id=@acct_id  
  
end   
  
if @flag='s'  
begin  
 select A.*,  
 case   
   when dr_bal_lim=0 then 0  
   when dr_bal_lim >0 and clr_bal_amt<= 0  then system_reserved_amt + lien_amt - clr_bal_amt  
   when dr_bal_lim >0 and clr_bal_amt>0 and (clr_bal_amt-(system_reserved_amt+ lien_amt))>0 then 0  
   when dr_bal_lim >0 and clr_bal_amt>0 and (clr_bal_amt-(system_reserved_amt+ lien_amt))< 0 then system_reserved_amt + lien_amt - clr_bal_amt  
   else 0   
   end as 'UtlAmt'  
	,T.agent_name 
 from ac_master a with (nolock) 
 LEFT JOIN AGENTTABLE T (NOLOCK) ON A.AGENT_ID = T.AGENT_ID
 where acct_id=@acct_id  
  
  
  
end  
  
if @flag='i'  
begin  
 IF EXISTS(SELECT 'A' FROM ac_master(NOLOCK) WHERE acct_num = @acct_num )
 BEGIN
	SELECT '1' ERRORCODE , 'Account Number already created' MSG , NULL ID
	RETURN
 END
 IF EXISTS(SELECT 'A' FROM ac_master(NOLOCK) WHERE acct_name = @acct_name)
 BEGIN
	SELECT '1' ERRORCODE , 'Account Name already created' MSG , NULL ID
	RETURN
 END

 insert into ac_master (acct_num, acct_name,gl_code, branch_id, acct_ownership,   
 dr_bal_lim, lim_expiry, acct_rpt_code, acct_type_code, frez_ref_code, acct_opn_date,   
 clr_bal_amt, system_reserved_amt, system_reserver_remarks,   
 lien_amt, lien_remarks, utilised_amt, available_amt,created_date,created_by,  
 ac_currency,ac_group,ac_sub_group, company_id, usd_amt,flc_amt,bill_by_bill)  
 Values ( ISNULL(@acct_num,'000'),@acct_name, @gl_code, @branch_id, @acct_ownership,   
 isnull(@dr_bal_lim,0), @lim_expiry, @acct_rpt_code, @acct_type_code, @frez_ref_code, getdate(),   
 0, isnull(@system_reserved_amt,0), @system_reserver_remarks,   
 isnull(@lien_amt,0), @lien_remarks, 0, 0, getdate(),@user,@ac_currency,@ac_group, @ac_sub_group,   
 1,  
 0,0,@bill_bybill)  
  
  set @acct_id = @@identity  
  
  --EXEC [proc_GetAccNum] @accId = @acct_id

 --###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'  
  Exec JobHistoryRecord 'i','ACCOUNT ADDED',@acct_name,@gl_code,@acct_ownership ,@acct_id,@user  
  
  SELECT '0' ERRORCODE , 'SUCCESSFULLY INSERTED' MSG , NULL ID
  
end  
  
if @flag='u'  
begin  
 
 --IF EXISTS(SELECT 'A' FROM ac_master(NOLOCK) WHERE acct_name = @acct_name AND acct_id = @acct_id )
 --BEGIN
	--SELECT '1' ERRORCODE , 'Account Number already created' MSG , NULL ID
	--RETURN
 --END
 IF EXISTS(SELECT 'A' FROM ac_master(NOLOCK) WHERE acct_name = @acct_name AND acct_id = @acct_id )
 BEGIN
	SELECT '1' ERRORCODE , 'Account Name already created' MSG , NULL ID
	RETURN
 END
  
 update ac_master set  
 acct_name		=	@acct_name,  
 acct_ownership	=	@acct_ownership,  
 acct_type_code	=	@acct_type_code,  
 system_reserver_remarks=@system_reserver_remarks,  
 modified_by	=	@user,  
 ac_currency	=	@ac_currency,  
 ac_group		=	@ac_group,  
 ac_sub_group	=	@ac_sub_group,  
 modified_date	=	getdate(),  
 bill_by_bill	=	@bill_bybill
 where acct_id	=	@acct_id  
  
 --###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'  
  Exec JobHistoryRecord 'i','ACCOUNT MODIFIED',@acct_name,@gl_code,@acct_ownership ,@acct_id,@user  
  
   SELECT '0' ERRORCODE , 'SUCCESSFULLY UPDATED' MSG , NULL ID
end  
  
IF @flag = 'D'  
BEGIN  
 IF EXISTS(SELECT 'A' FROM ac_master WHERE acct_id = @acct_id HAVING SUM(available_amt)>0)  
 BEGIN  
	  SELECT 1 code, 'Account having a balance can not deleted..' msg  
	  RETURN;  
 END 

 SELECT @acct_num = acct_num FROM ac_master WHERE acct_id = @acct_id

 IF EXISTS(SELECT 'A' FROM tran_master WHERE acc_num = @acct_num)  
 BEGIN  
	  SELECT 1 code, 'Account having a balance can not deleted..' msg  
	  RETURN;  
 END  
   
 DELETE FROM ac_master WHERE acct_id = @acct_id  
 SELECT 0 code, 'Account deleted successfully' msg  
 RETURN  
END


GO
