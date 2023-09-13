USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_daybook]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec proc_daybook '1/4/2009','6/5/2009','p',1  
-- Exec daybook '2010-7-1','2010-7-1',null,1  
  
CREATE PROCEDURE [dbo].[proc_daybook]  
 @startdt varchar(10),  
 @enddt varchar(10),  
 @vouchertype varchar(1)=null,  
 @company_id int ,
 @showType varchar(30) = null
AS  
begin  
  
 SET NOCOUNT ON;  
 if @showType is null
	set @showType = 'all'

 IF @showType = 'all'
 BEGIN
	select a.acct_num as acc_num,a.acct_name,b.ref_num as Voucher,b.tran_type ,  
	 convert(varchar,c.tran_date,102) tran_date ,isnull(F_PRINT,0) as F_PRINT,  
	 isnull(b.amount,0)as amount  
	 from   
	 (select   
		ref_num,sum(tran_amt)/2 as Amount,tran_type,  
		MIN(cast(part_tran_srl_num as int)) as part_tran_srl_num  
	   from tran_master with(nolock)  
	   where company_id = @company_id  
	   and tran_date between @startdt  and  @enddt +' 23:59:59'  
	   and tran_type like isnull(@vouchertype,'%')  
	   group by ref_num,tran_type  
	 ) b , ac_master a with(nolock), tran_master c with(nolock)  
	 where c.acc_num=a.acct_num  
	 and b.ref_num=c.ref_num  
	 and b.tran_type=c.tran_type  
	 and b.part_tran_srl_num=c.part_tran_srl_num  
	 order by b.tran_type,cast(b.ref_num as float)  
 END
  ELSE IF @showType = 'manual'
  BEGIN
	select a.acct_num as acc_num,a.acct_name,b.ref_num as Voucher,b.tran_type ,  
	 convert(varchar,c.tran_date,102) tran_date ,isnull(F_PRINT,0) as F_PRINT,  
	 isnull(b.amount,0)as amount  
	 from   
	 (select   
		ref_num,sum(tran_amt)/2 as Amount,tran_type,  
		MIN(cast(part_tran_srl_num as int)) as part_tran_srl_num  
	   from tran_master with(nolock)  
	   where company_id = @company_id  
	   and tran_date between @startdt  and  @enddt +' 23:59:59'  
	   and tran_type like isnull(@vouchertype,'%')  
	   and isnull(entry_user_id, '') <> 'system' and isnull(field2, '') <> 'Customer Deposit(Untransacted)'
	   group by ref_num,tran_type  
	 ) b , ac_master a with(nolock), tran_master c with(nolock)  
	 where c.acc_num=a.acct_num  
	 and b.ref_num=c.ref_num  
	 and b.tran_type=c.tran_type  
	 and b.part_tran_srl_num=c.part_tran_srl_num  
	 order by b.tran_type,cast(b.ref_num as float) 
  END
 ELSE IF @showType = 'system'
  BEGIN
	select a.acct_num as acc_num,a.acct_name,b.ref_num as Voucher,b.tran_type ,  
	 convert(varchar,c.tran_date,102) tran_date ,isnull(F_PRINT,0) as F_PRINT,  
	 isnull(b.amount,0)as amount  
	 from   
	 (select   
		ref_num,sum(tran_amt)/2 as Amount,tran_type,  
		MIN(cast(part_tran_srl_num as int)) as part_tran_srl_num  
	   from tran_master with(nolock)  
	   where company_id = @company_id  
	   and tran_date between @startdt  and  @enddt +' 23:59:59'  
	   and tran_type like isnull(@vouchertype,'%')  
	   and (isnull(entry_user_id, '') = 'system' or isnull(field2, '') = 'Customer Deposit(Untransacted)')
	   group by ref_num,tran_type  
	 ) b , ac_master a with(nolock), tran_master c with(nolock)  
	 where c.acc_num=a.acct_num  
	 and b.ref_num=c.ref_num  
	 and b.tran_type=c.tran_type  
	 and b.part_tran_srl_num=c.part_tran_srl_num  
	 order by b.tran_type,cast(b.ref_num as float) 
  END
 
  
end 




GO
