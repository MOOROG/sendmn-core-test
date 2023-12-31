USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[balancesheetDrilldown2]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[balancesheetDrilldown2]  
 @flag varchar(2),  
 @mapcode varchar(20)=null,  
 @date2 varchar(20)=null,  
 @company_id varchar(20)=null,  
 @tree_sape varchar(20)=null,  
 @date varchar(20)=null  
   
AS  
 set nocount on;  
   
 set @mapcode= cast(cast(@mapcode as float)as int)  
   
 if @date is null or @date=''  
 begin  
   
  set @date = '2000-1-1';  
   
 end  
   
 --set @date = cast(YEAR(@date2)as varchar) + '/'+  cast(month(@date2)as varchar) + '/1'  
  
if @flag='1'  
begin  
  
 -- select gl_code from GL_GROUP where bal_grp = '24' and tree_sape=left(tree_sape,7)  
  
 select gl_name as acct_name,gl_code as acct_num,x.TREE_SAPE,  
  (sum(Total)) as Total,  
  (sum(case when Total < 0 then Total else 0 end)) as DR,   
  (sum(case when Total > 0 then Total else 0 end)) as CR   
 from(  
 select (a.Total) as Total, left(b.tree_sape,7) TREE_SAPE from (  
   select acct_num,acct_name,gl_code,sum(total)as Total from(   
      select a.acct_num,a.acct_name,a.gl_code,  
       sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
       from tran_master e  with(nolock) 
	   INNER JOIN ac_master a  with(nolock) ON a.acct_num=e.acc_num     
       where E.gl_sub_head_code = A.gl_code
       and tran_date between cast( @date as datetime) and @date2 +' 23:59:59'   
       and a.company_id =1  
      group by a.acct_num,a.acct_name,a.gl_code  
    ) a group by acct_num,acct_name,a.gl_code  
  )a ,(select * from GL_GROUP with (nolock) where bal_grp=@mapcode)b  
 where a.gl_code=b.gl_code   
 ) x, GL_GROUP g where x.TREE_SAPE=g.TREE_SAPE  
 group by gl_name, gl_code,x.TREE_SAPE    
 order by gl_name  
  
end  
  
if @flag='2'  
begin  
  
    
 select gl_name as acct_name ,gl_code as acct_num, (sum(Total)) as Total ,x.TREE_SAPE,  
  ABS(SUM(CASE WHEN isnull(Total,0) < 0 then Total else 0 end)) as DR,   
  ABS(SUM(CASE WHEN isnull(Total,0) > 0 then Total else 0 end)) as CR   
 from(  
 select a.Total, left(b.tree_sape,LEN(@tree_sape)+3) TREE_SAPE from (  
      
    select acct_num,acct_name,gl_code,sum(total)as Total from(   
       select a.acct_num,a.acct_name,a.gl_code,  
       SUM(CASE WHEN part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
       from tran_master e  with(nolock) 
	   INNER JOIN ac_master a  with(nolock) ON a.acct_num=e.acc_num   
       where  E.gl_sub_head_code = A.gl_code
       and tran_date between cast( @date as datetime) and @date2 +' 23:59:59'   
       and a.company_id =1  
       --and gl_code=@mapcode  
      group by a.acct_num,a.acct_name,a.gl_code  
    ) a group by acct_num,acct_name,a.gl_code  
      HAVING sum(total) <> 0
  )a ,(select * from GL_GROUP with (nolock))b  
    
 where a.gl_code=b.gl_code   
 and left(b.tree_sape,LEN(@tree_sape))=@tree_sape  
 ) x, GL_GROUP g where x.TREE_SAPE=g.TREE_SAPE  
 group by gl_name, gl_code,x.TREE_SAPE    
  --left(x.tree_sape,LEN('0024.05.04')+3)  
order by gl_name  
   
   
   
end  
  
if @flag='a'  
begin  
    
  select acct_num,acct_name,ABS(sum(total))as Total from(   
    select a.acct_num,a.acct_name,  
     ABS(sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end)) Total  
     from tran_master e  with(nolock) ,ac_master a  with(nolock)    
     where a.acct_num=e.acc_num  
     and left(gl_sub_head_code,2) =@mapcode  
     and tran_date between cast( @date as datetime) and @date2 +' 23:59:59'   
      and a.company_id =1  
    group by a.acct_num,a.acct_name  
  ) a group by acct_num,acct_name  
  order by acct_name  
  
end  
  
if @flag='3'  
begin  
    
  select acct_num,acct_name,  
   (sum(total)) as Total,  
   ABS(sum(case when a.Total<0 then isnull(a.Total,0) else 0 end)) as dr_closing,  
   ABS(sum(case when a.Total>0 then isnull(a.Total,0) else 0 end)) as cr_closing   
  from(  
	   select acct_num,acct_name,gl_code,sum(total)as Total from(   
		   select a.acct_num,a.acct_name,a.gl_code,  
		   sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
		   from tran_master e  with(nolock) 
		   INNER JOIN ac_master a  with(nolock) ON a.acct_num=e.acc_num   
		   where E.gl_sub_head_code = A.gl_code
		   and tran_date between cast(@date as datetime) and @date2 + ' 23:59:59'   
		   and gl_code=@mapcode  
		  group by a.acct_num,a.acct_name,a.gl_code  
		) a group by acct_num,acct_name,a.gl_code  
		--HAVING sum(total) <> 0
  ) a group by acct_num,acct_name    
  order by acct_name  
  
  
end  
  
if @flag='d'  
begin  
  
 set @mapcode= cast(cast(@mapcode as float)as int)  
  
 select acc_num,acct_name,  
 isnull(sum(case when part_tran_type='dr' then tran_amt end),0) DRTotal,  
 isnull(sum(case when part_tran_type='cr' then tran_amt end),0) cRTotal  
 from tran_history  t with(nolock) ,ac_master a with(nolock)     
 where acc_num=acct_num and left(gl_sub_head_code,2) =@mapcode  
 and t.company_id =1   
 group by acc_num,acct_name  
 order by acct_name  
  
end  
  
if @flag='g'  
begin  
  
 select acct_num,acct_name,sum(total)as Total from(  
  select a.acct_num,a.acct_name,  
    sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
    from tran_master e  with(nolock) ,ac_master a  with(nolock)    
    where a.acct_num=e.acc_num  
    and left(gl_sub_head_code,2) =@mapcode   
    and tran_date between cast( @date as datetime) and @date2 +' 23:59:59'   
    and a.company_id =1  
    group by a.acct_num,a.acct_name  
  ) a group by acct_num,acct_name  
 order by acct_name  
  
end  
  
if @flag='m'  
begin  
  
   
 select gl_name as acct_name ,gl_code as acct_num, sum(Total) as Total ,x.TREE_SAPE,  
  sum(case when isnull(Total,0) < 0 then Total else 0 end) as DR,   
  sum(case when isnull(Total,0) > 0 then Total else 0 end) as CR   
 from(  
 select a.Total, left(b.tree_sape,LEN(@tree_sape)+3) TREE_SAPE from (  
      
    select acct_num,acct_name,gl_code,sum(total)as Total from(   
       select a.acct_num,a.acct_name,a.gl_code,  
       sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
       from tran_master e  with(nolock) ,ac_master a  with(nolock)    
       where a.acct_num=e.acc_num  
       and tran_date between cast( @date as datetime) and @date2 +' 23:59:59'   
       and a.company_id =1  
       --and gl_code=@mapcode  
      group by a.acct_num,a.acct_name,a.gl_code  
    ) a group by acct_num,acct_name,a.gl_code  
      
  )a ,(select * from GL_GROUP with (nolock))b  
    
 where a.gl_code=b.gl_code   
 and left(b.tree_sape,LEN(@tree_sape))=@tree_sape  
 ) x, GL_GROUP g where x.TREE_SAPE=g.TREE_SAPE  
 group by gl_name, gl_code,x.TREE_SAPE    
  --left(x.tree_sape,LEN('0024.05.04')+3)  
order by gl_name  
   
   
end  


GO
