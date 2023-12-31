ALTER  proc [dbo].[proc_AutoDebitCustomerLiability_Update]
@ref_num varchar(20)
AS

declare @tranId int,@email varchar(200) ,@accNum varchar(20)

select @tranId = tran_id,@email = employeeName from tran_master(nolock) where ref_num= @ref_num and acc_num='100241027580'

select @accNum = walletaccountno from SendMnPro_Remit.dbo.customermaster(nolock) where email= @email
if @accNum is null
	return

IF EXISTS(SELECT 'A' FROM tran_master(NOLOCK) WHERE ref_num= @ref_num AND ACC_NUM=@accNum)
	RETURN

INSERT INTO tran_master(entry_user_id,acc_num,gl_sub_head_code,part_tran_srl_num,part_tran_type,ref_num,tran_amt,tran_date,tran_type,created_date,company_id,usd_amt,usd_rate
	,employeeName,field1,field2,fcy_curr,sendmargin)	
SELECT 'system',@accNum,79,6,'cr',ref_num,tran_amt,tran_date,tran_type,created_date,company_id,usd_amt,usd_rate
	,employeeName,field1,field2,fcy_curr,sendmargin 
from tran_master (nolock) where tran_id = @tranId
UNION ALL 
SELECT 'system',@accNum,79,7,'dr',ref_num,tran_amt,tran_date,tran_type,created_date,company_id,usd_amt,usd_rate
	,employeeName,field1,field2,fcy_curr,sendmargin 
from tran_master (nolock) where tran_id = @tranId


GO
