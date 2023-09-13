-- Exec balancesheetDrilldown2 '3' , '43','5/23/2010','1','0012.06.03.02','02/03/2010'   
-- Exec balancesheetDrilldown2 '1' , '24','5/25/2010',Null   
  
 
ALTER proc [dbo].[balancesheetDrilldown2]  
 @flag varchar(20),  
 @user varchar(50) = NULL,  
 @mapcode varchar(20)=null,  
 @date2 varchar(20)=null,  
 @company_id varchar(20)=null,  
 @tree_sape varchar(20)=null,  
 @date varchar(20)=null,
 @type varchar(20) = null,
 @agentId INT = NULL
   
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
  if ISNULL(@date, '') = ''
	set @date = '2000-1-1';  
    
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
       from CustomerInfo e  with(nolock) ,ac_master a  with(nolock)    
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
  
if @flag='m2'  
begin  
  
  select acct_num,acct_name,  
   sum(total)as Total,  
   ABS(sum(case when a.Total<0 then isnull(a.Total,0) else 0 end)) as dr_closing,  
   ABS(sum(case when a.Total>0 then isnull(a.Total,0) else 0 end)) as cr_closing   
  from(  
   select acct_num,acct_name,gl_code,sum(total)as Total from(   
       select a.acct_num,a.acct_name,a.gl_code,  
       sum(case when part_tran_type='dr' then tran_amt*(-1) else tran_amt end) Total  
       from CustomerInfo e  with(nolock) ,ac_master a  with(nolock)    
       where a.acct_num=e.acc_num  
       and tran_date between cast(@date as datetime) and @date2 + ' 23:59:59'   
       and gl_code=@mapcode  
      group by a.acct_num,a.acct_name,a.gl_code  
    ) a group by acct_num,acct_name,a.gl_code  
  ) a group by acct_num,acct_name    
  order by acct_name  
    
end 

if @flag = 'acc'
begin
	declare @acc_num varchar(30), @acc_name varchar(100)
	if @type = 't'
	begin
		select @acc_num = acct_num, @acc_name = acct_name
		from ac_master a(nolock)
		inner join fastmoneypro_remit.dbo.applicationusers au(nolock) on au.userid = a.agent_id 
		where au.username = @user
		and a.acct_rpt_code = 'TCA'
	end
	else if @type = 'v'
	begin
		select @acc_num = acct_num, @acc_name = acct_name
		from ac_master a(nolock)
		--inner join fastmoneypro_remit.dbo.applicationusers au(nolock) on au.agentid = a.agent_id 
		where a.agent_id = @agentId
		and a.acct_rpt_code = 'BVA'
	end

	SELECT @acc_num acc_num, @acc_name acc_name
end

--Exec balancesheetDrilldown2 @flag = 'acc'  ,@type = 'v' ,@user = 'shikshya' ,@company_id = '1'

