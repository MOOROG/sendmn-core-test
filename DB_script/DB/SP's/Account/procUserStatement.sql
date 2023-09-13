/*  
Exec procUserStatement 't' ,'7','05/14/2012',null,'p','1'  
 Exec procUserStatement 't' ,'1','2009.06.28',null,'j','1'  
Exec procUserStatement 't' ,'8','05/14/2012',null,'P','1'    
*/  
ALTER PROC [dbo].[procUserStatement]  
 @flag char(1),  
 @user varchar(20),  
 @startDate varchar(20)=null,  
 @endDate varchar(20) =null,  
 @vouchertype char(1) = null,  
 @company_id varchar(20)=null,
 @searchType CHAR(1) = NULL  
   
AS  
  
set nocount on;  
  
if @flag='t'  
begin  
 SET @searchType = ISNULL(@searchType, 'v')
 set @endDate = @startDate +' 23:59:59'  
 IF @searchType = 'v'
 BEGIN
	 select * from (  
	 select t.ref_num as TRNno, convert(varchar,tran_date,102) TRNDate,acc_num,acct_name,   
	  part_tran_srl_num,tran_rmks
	  ,tran_particular = CASE WHEN t.field2 IN ('Remittance Voucher', 'Cancel Voucher') THEN 
								tran_particular + '  <span class="link" onclick="ViewTranDetailByControlNo('''+field1+''');">(View Txn. Detail)</span>'
								ELSE tran_particular
							END
	  ,t.billno
	  ,case when part_tran_type='dr' then tran_amt else 0 end  as DRTotal,  
	  case when part_tran_type='cr' then tran_amt else 0 end  as cRTotal, tran_date AS TD
	  ,entry_user_id = entry_user_id +'('+convert(varchar,t.created_date,102)+','+convert(varchar,t.created_date,108)+')'
	  ,rpt_code ,part_tran_type,d.voucher_image,t.fcy_Curr,t.usd_amt,t.usd_rate
	 from tran_master t WITH (NOLOCK) , ac_master a  WITH (NOLOCK), tran_masterDetail d with (nolock)  
	 where t.ref_num=d.ref_num   
	  and t.tran_type=d.tran_type   
	  --and t.company_id=d.company_id   
	  and acc_num=acct_num   
	  --and t.company_id=@company_id  
	  and t.tran_type=@vouchertype  
	  and t.ref_num=@user  
	  and a.gl_code <> 0
	 ) a order by TD asc,part_tran_type,acct_name
 END
 ELSE IF @searchType = 'c'
  BEGIN
	 select * from (  
	 select distinct t.ref_num as TRNno, convert(varchar,tran_date,102) TRNDate,acc_num,acct_name,   
	  part_tran_srl_num,tran_rmks
	  ,tran_particular = CASE WHEN t.field2 IN ('Remittance Voucher', 'Cancel Voucher') THEN 
								tran_particular + '  <span class="link" onclick="ViewTranDetailByControlNo('''+field1+''');">(View Txn. Detail)</span>'
								ELSE tran_particular
							END
	  ,t.billno,  
	  case when part_tran_type='dr' then tran_amt else 0 end  as DRTotal,  
	  case when part_tran_type='cr' then tran_amt else 0 end  as cRTotal, tran_date AS TD
	  ,entry_user_id = entry_user_id +'('+convert(varchar,t.created_date,102)+','+convert(varchar,t.created_date,108)+')'
	  ,rpt_code ,part_tran_type,d.voucher_image,t.fcy_Curr,t.usd_amt,t.usd_rate
	 from tran_master t WITH (NOLOCK) , ac_master a  WITH (NOLOCK), tran_masterDetail d with (nolock)  
	 where t.ref_num=d.ref_num   
	  and t.tran_type=d.tran_type   
	  --and t.company_id=d.company_id   
	  and acc_num=acct_num   
	  --and t.company_id=@company_id  
	  and t.tran_type='j'  
	  and t.field1=@user  
	  and a.gl_code <> 0
	 ) a order by TD asc,part_tran_type,acct_name
  END	
end  
  
if @flag='a'  
begin  
  
  
 set @endDate=@endDate +' 23:59:59'  
  
 select * from (  
 select distinct t.ref_num as TRNno,convert(varchar,tran_date,102) TRNDate,acc_num,acct_name,   
  tran_rmks,part_tran_srl_num,tran_particular,t.billno,  
  case when part_tran_type='dr' then tran_amt else 0 end  as DRTotal,  
  case when part_tran_type='cr' then tran_amt else 0 end  as cRTotal, tran_date AS TD,entry_user_id,rpt_code  
 from tran_master t WITH (NOLOCK), ac_master a WITH (NOLOCK) , tran_masterDetail d with (nolock)  
 where t.ref_num=d.ref_num and t.tran_type=d.tran_type and t.company_id=d.company_id  
  and acc_num=acct_num   
  and tran_date between @startDate and @endDate   
  and t.company_id=@company_id   
  and entry_user_id like @user  
  and a.gl_code <> 0
 ) a order by TD , TRNno, cast(part_tran_srl_num as int)  
   
  
end  
  
  
  
if @flag='g'  
begin  
  
 set @endDate=@startDate +' 23:59:59'  
  
 select * from (  
 select distinct t.ref_num as TRNno, convert(varchar,tran_date,102) TRNDate,acc_num,acct_name,   
  part_tran_srl_num,tran_rmks,tran_particular,t.billno,  
  case when part_tran_type='dr' then tran_amt else 0 end  as DRTotal,  
  case when part_tran_type='cr' then tran_amt else 0 end  as cRTotal, tran_date AS TD,  
  entry_user_id,rpt_code  
 from CustomerInfo t WITH (NOLOCK) , ac_master a  WITH (NOLOCK), CustomerInfoDetail d with (nolock)  
 where t.ref_num=d.ref_num and t.tran_type=d.tran_type and t.company_id=d.company_id   
  and acc_num=acct_num   
  and t.company_id=@company_id  
  and t.tran_type=@vouchertype  
  and t.ref_num=@user  
  and a.gl_code <> 0
 ) a order by TD asc,cast(part_tran_srl_num as int)  
   
end 


