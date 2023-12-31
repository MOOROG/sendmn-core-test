USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procAccountStatementFilter]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec procAccountStatementFilter 'a' ,'24050110428921','9/1/2009','9/17/2009','tran_amt','98221.00'     
    
--Exec procAccountStatementFilter  @acnum = '111000213' ,@startDate = '02/01/2007' ,@endDate = '02/02/2016' ,@condition = 'tran_amt' ,@condition_value = '10'  
    
CREATE proc [dbo].[procAccountStatementFilter]    
 @acnum varchar(20),    
 @startDate varchar(20),    
 @endDate varchar(20),    
 @condition varchar(50),    
 @condition_value varchar(200)    
AS    
set nocount on;    
     
 Declare @sql varchar(6000)    
 set @endDate=@endDate + ' 23:59:59'    
 set @sql=''    
     
     
if @condition='ACC_NUM'    
begin    
    
 set @sql=@sql +' select acc_num as acct_num ,convert(varchar,TRNDate,102) as TRNDate,    
   tran_rmks,DRTotal,cRTotal,end_clr_balance,ref_num, TD,tran_type from     
  ( '    
    
 set @sql=@sql +'     
  select     
   acc_num,t.tran_date as TRNDate,isnull(tran_particular,'''')+'' '' +isnull(tran_rmks,'''') as tran_rmks ,    
   case when part_tran_type=''dr'' then tran_amt else 0 end as DRTotal,    
   case when part_tran_type=''cr'' then tran_amt else 0 end as cRTotal,    
   0 end_clr_balance, t.ref_num, t.tran_date as TD,t.tran_type    
  from tran_master T (nolock)  
  INNER JOIN tran_masterDetail d (nolock) on t.ref_num = d.ref_num and t.tran_type = d.tran_type  
  where 1=1 and (acc_num = '''+ @condition_value +''')    
  and t.ref_num in ( select ref_num from tran_master WITH (NOLOCK)     
  where 1=1 and (acc_num='''+ @acnum +''' )    
    and company_id=1 and tran_date between '''+ @startDate+'''  and '''+ @endDate+'''      
  )    
 )     
 a order by TD '    
    
 execute(@sql)    
     
end    
if @condition='tran_amt'    
begin    
    
 set @sql=@sql +' select acc_num as acct_num ,convert(varchar,TRNDate,102) as TRNDate,    
   tran_rmks,DRTotal,cRTotal,end_clr_balance,ref_num, TD,tran_type from     
  ( '    
    
 set @sql=@sql +'     
  select     
   acc_num,t.tran_date as TRNDate,isnull(tran_particular,'''')+'' '' +isnull(tran_rmks,'''') as tran_rmks ,    
   case when part_tran_type=''dr'' then tran_amt else 0 end as DRTotal,    
   case when part_tran_type=''cr'' then tran_amt else 0 end as cRTotal,    
   0 end_clr_balance, t.ref_num, t.tran_date as TD,t.tran_type    
 from tran_master T (nolock)  
  INNER JOIN tran_masterDetail d (nolock) on t.ref_num = d.ref_num and t.tran_type = d.tran_type   
  where 1=1  and (acc_num='''+ @acnum +''')    
  and tran_amt='''+ @condition_value +'''     
  and t.tran_date between '''+ @startDate+'''  and '''+ @endDate+'''      
 )     
 a order by TD '    
    
 execute(@sql)    
     
end    
    
if @condition='CHEQUE_NO' or @condition='tran_particular'    
begin    
    
 set @sql=@sql +' select acc_num as acct_num ,convert(varchar,TRNDate,102) as TRNDate,    
   tran_rmks,DRTotal,cRTotal,end_clr_balance,ref_num, TD,tran_type from     
  ( '    
    
 set @sql=@sql +'     
  select     
   acc_num,t.tran_date as TRNDate,isnull(tran_particular,'''')+'' '' +isnull(tran_rmks,'''') as tran_rmks ,    
   case when part_tran_type=''dr'' then tran_amt else 0 end as DRTotal,    
   case when part_tran_type=''cr'' then tran_amt else 0 end as cRTotal,    
   0 end_clr_balance, t.ref_num, t.tran_date as TD,t.tran_type    
  from tran_master T (nolock)  
  INNER JOIN tran_masterDetail d (nolock) on t.ref_num = d.ref_num and t.tran_type = d.tran_type   
  where 1=1  and (acc_num='''+ @acnum +''')    
  and '+ @condition +' like ''%'+ @condition_value +'%''     
    and t.tran_date between '''+ @startDate+'''  and '''+ @endDate+'''      
 )     
 a order by TD '    
    
    
 execute(@sql)    
     
end    
  
GO
