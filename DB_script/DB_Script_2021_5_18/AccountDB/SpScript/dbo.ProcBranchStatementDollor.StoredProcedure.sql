USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcBranchStatementDollor]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- Exec ProcBranchstatementDollor 'a' ,'10011045733','2009-6-1','2009-6-16',1  
  
CREATE proc [dbo].[ProcBranchStatementDollor]  
 @flag char(1),  
 @acnum varchar(20),  
 @startDate varchar(20),  
 @endDate varchar(20),  
 @company_id varchar(20)  
AS  
set nocount on;  
  
if @flag='a'  
begin  
  
 Declare @sql varchar(6000)  
  
 set @endDate=@endDate +' 23:59:59'  
 set @sql=''  
  
 set @sql=@sql +' select acc_num as acct_num ,convert(varchar,TRNDate,102) as TRNDate,tran_rmks,isnull(DRTotal,0)DRTotal ,isnull(cRTotal,0)cRTotal ,end_clr_balance,ref_num, TD,tran_type from ( '  
   
 set @sql= @sql + 'select acc_num,'''' TRNDate, ''Balance Brought Forward'' tran_rmks, 0 DRTotal,0 cRTotal, isnull(end_clr_balance,0) end_clr_balance, 0 ref_num, '''' TD,'''' tran_type  
 from (  
  
 select acc_num, sum (case when part_tran_type=''dr'' then fcy_amt*-1 else fcy_amt end) end_clr_balance  
 from tran_master  WITH (NOLOCK) where acc_num='''+@acnum +''' and  
 tran_date < '''+ @startDate+'''  
 group by acc_num  
 ) ca    
 union all'  
  
 set @sql=@sql +'   
 select acc_num,tran_date as TRNDate,isnull(tran_particular,'''')+'' '' +isnull(tran_rmks,'''') as tran_rmks ,  
  case when part_tran_type=''dr'' then fcy_amt else 0 end as DRTotal,  
  case when part_tran_type=''cr'' then fcy_amt else 0 end as cRTotal,  
  0 Balance, t.ref_num, tran_date as TD,t.tran_type  
 from tran_master t WITH (NOLOCK), tran_masterDetail d with (nolock)  
 where t.ref_num=d.ref_num and t.tran_type=d.tran_type and t.company_id=d.company_id  
 and acc_num='''+@acnum +''' and  
 t.company_id='+@company_id +' and  
 tran_date between '''+@startDate +''' and '''+@endDate +'''   
 )   
 a order by TD '  
   
 --print(@sql)  
 execute(@sql)  
   
end  
  
GO
