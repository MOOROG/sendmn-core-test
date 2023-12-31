USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procBalancesheet]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procBalancesheet]  
 @flag char(1),  
 @date1 varchar(20),  
 @company_id varchar(20)=null,  
 @date2 varchar(20)=null  
  
as  

set nocount on;  
 -- set @date1=@date1 +' 23:59:59'  
  
if @flag='b'	
begin  
  
-- ########## Create Balance Table  
  
select b.gl_code,Total,CR ,DR ,bal_grp   
into #TempBalnce   
from (  
select a.gl_code,Total,CR,DR    
 from(  
    
  select gl_sub_head_code as gl_code,sum(Total) as Total,  
   sum(case when Total < 0 then Total else 0 end) as DR,   
   sum(case when Total > 0 then Total else 0 end) as CR  
 from (  
 select gl_sub_head_code,acc_num,  
    sum (case when part_tran_type='DR' then tran_amt*-1 else tran_amt end) Total  
    from tran_master m with(nolock)  
    where tran_date  < = @date1 +' 23:59:59'  
    group by gl_sub_head_code,acc_num  
  )a group by gl_sub_head_code  
 ) a  
)b, GL_GROUP g with(nolock) where g.gl_code=b.gl_code  
  
--select * from #TempBalnce where  bal_grp = '24' return 
  
select * from (  
  
 select lable as head,sum (isnull(b.total,0)) as Total,  
  reportid,'a' as typ, grp_main,grp,b.bal_grp  
  from report_format h left join #TempBalnce b on h.reportid=b.bal_grp  
 where [type]='a' group by lable,reportid,grp_main,grp,b.bal_grp  
    
 union all  
   
 select lable as head,sum (isnull(b.total,0)) as Total,  
  reportid,'l' as typ, grp_main,grp,b.bal_grp  
  from report_format h left join #TempBalnce b on h.reportid=b.bal_grp  
 where [type]='l' group by lable,reportid,grp_main,grp,b.bal_grp  
    
) a order by reportid,grp_main,grp  
  
  
end  
  
if @flag='p'  
begin  
  
 -- Exec procBalancesheet 'p','04/1/2010',Null,'4/30/2010'   
   
 select gl_name as GL_DESC,gl_code ,isnull(sum(YTotal),0) YEARTODATE,  
  isnull(sum(MTotal),0) THISMONTH,  
 tree_sape, LEFT(tree_sape, 10) AS FILTER  
 from(  
  
   select x.Total as MTotal,0 as YTotal, x.tree_sape,gl_code, gl_name   
   from(  
   select sum(a.Total) as Total, left(b.tree_sape,LEN('0013.02')+6) TREE_SAPE from (  
      select acct_num,acct_name,gl_code,sum(total)as Total from(   
         select a.acct_num,a.acct_name,a.gl_code,  
         sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
         from tran_master e  with(nolock) ,ac_master a  with(nolock)    
         where a.acct_num=e.acc_num  
         and tran_date between @date1 and cast( @date2 +' 23:59:59' as datetime)  
        group by a.acct_num,a.acct_name,a.gl_code  
      ) a group by acct_num,acct_name,a.gl_code  
    )a ,(select * from GL_GROUP with (nolock))b  
   where a.gl_code=b.gl_code   
   and left(b.tree_sape,LEN('0013.02'))='0013.02'  
   group by left(b.tree_sape,LEN('0013.02')+6)  
     
   ) x, GL_GROUP g where x.TREE_SAPE=g.TREE_SAPE  
     
  UNION ALL  
    
  select 0 as MTotal,x.Total  as YTotal, x.tree_sape ,gl_code, gl_name   
  from(  
  select sum(a.Total) as Total, left(b.tree_sape,LEN('0013.02')+6) TREE_SAPE from (  
     select acct_num,acct_name,gl_code,sum(total)as Total from(   
        select a.acct_num,a.acct_name,a.gl_code,  
        sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
        from tran_master e  with(nolock) ,ac_master a  with(nolock)    
        where a.acct_num=e.acc_num  
        and tran_date <= cast( @date2 +' 23:59:59' as datetime)  
       group by a.acct_num,a.acct_name,a.gl_code  
     ) a group by acct_num,acct_name,a.gl_code  
   )a ,(select * from GL_GROUP with (nolock))b  
  where a.gl_code=b.gl_code   
  and left(b.tree_sape,LEN('0013.02'))='0013.02'  
  group by left(b.tree_sape,LEN('0013.02')+6)  
  ) x, GL_GROUP g where x.TREE_SAPE=g.TREE_SAPE  
 )a  
 group by a.gl_code, a.gl_name, a.TREE_SAPE  
 order by a.gl_name  
   
end  
GO
