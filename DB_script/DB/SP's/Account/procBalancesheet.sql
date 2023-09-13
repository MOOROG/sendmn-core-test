USE FastMoneyPro_Account
GO
-- Exec procBalancesheet 'b','2018-09-30','1'  
-- Exec procBalancesheet @flag = 'b' ,@company_id = '1' ,@date1 = '2019-10-01'
ALTER proc [dbo].[procBalancesheet]  
 @flag char(1),  
 @date1 varchar(20),  
 @company_id varchar(20)=null,  
 @date2 varchar(20)=null  
  
as  
 set nocount on;  
 -- set @date1=@date1 +' 23:59:59'  
  
if @flag='b'	
begin  
  declare @pfdate varchar(10),@ptDate varchar(20)
  SET @date2 = '2017-01-01'
-- ########## Create Balance Table  

 select x.gl_Name, x.gl_code,x.tree_sape,x.p_id
	,'THISYEAR' = CAST(sum(case when t.tran_date between @date2 and @date1+' 23:59:59' then 
					case when t.part_tran_type='cr' then t.tran_amt*-1 else t.tran_amt end 
		else 0 end) AS DECIMAL(17,2))
	,'PREYEAR' = CAST(sum(case when t.tran_date between @pfdate and @ptDate+' 23:59:59' then 
					case when t.part_tran_type='cr' then t.tran_amt*-1 else t.tran_amt end 
		else 0 end) AS DECIMAL(17,2))
from (
select g.gl_Name,g.gl_code,g.tree_sape,g.p_id
from gl_group g(nolock) 
where g.p_id in ('1','4','6','7','r12','r13','r14','21')
GROUP BY g.gl_Name,g.gl_code,g.tree_sape,g.p_id
union all
select g.gl_Name,g.gl_code,g.tree_sape,g.p_id
from gl_group g(nolock) 
where g.GL_CODE in ('2','3','5')
GROUP BY g.gl_Name,g.gl_code,g.tree_sape,g.p_id
)x
inner join gl_group g(nolock) on left(g.tree_sape,len(x.tree_sape)) = x.tree_sape
LEFT JOIN tran_master t(nolock) on t.gl_sub_head_code = g.gl_code
group by x.gl_Name, x.gl_code,x.tree_sape,x.p_id



end  
  
if @flag='p'  
begin  
  
--select g.gl_Name,g.gl_code,g.tree_sape,g.p_id
--	,'THISMONTH' = (sum(case when a.tran_date between @date1 and @date2+' 23:59:59' then 
--					isnull((CASE WHEN A.part_tran_type='DR' THEN a.tran_amt*-1 ELSE a.tran_amt END),0)
--					else 0 end))
--	,'YEARTODATE' = isnull((sum(CASE WHEN A.part_tran_type='DR' THEN a.tran_amt*-1 ELSE a.tran_amt END)),0)
--from gl_group g(nolock) 
--left join tran_master a(nolock) on g.gl_code = a.gl_sub_head_code
--where g.p_id in ('48', '60', '44', '45', '46', '47') 
--GROUP BY g.gl_Name,g.gl_code,g.tree_sape,g.p_id


	select * into #gl_group from gl_group where p_id in ('48', '60', '44', '45', '46', '47', '64', 'r14') 

	select g1.*, g.gl_code parent_gl_code, g.gl_name parent_gl_name, g.tree_sape parent_tree_sape, g.p_id parent_p_id into #tree from #gl_group g
	inner join #gl_group g1 on g1.p_id = CAST(g.gl_code AS VARCHAR)


	select gl_Name, gl_code, tree_sape, p_id, SUM(THISMONTH) THISMONTH, SUM(YEARTODATE) YEARTODATE from(
	select gl_Name = g.parent_gl_name,gl_code = g.parent_gl_code,tree_sape = g.parent_tree_sape,p_id = g.parent_p_id
		,'THISMONTH' = (sum(case when a.tran_date between @date1 and @date2 + ' 23:59:59' then 
						isnull((CASE WHEN A.part_tran_type='DR' THEN a.tran_amt*-1 ELSE a.tran_amt END),0)
						else 0 end))
		,'YEARTODATE' = isnull((sum(CASE WHEN A.part_tran_type='DR' THEN a.tran_amt*-1 ELSE a.tran_amt END)),0)
	from #tree g(nolock) 
	left join tran_master a(nolock) on g.gl_code = a.gl_sub_head_code
	GROUP BY g.parent_gl_name,g.parent_gl_code,g.parent_tree_sape,g.parent_p_id
	union all
	select g.gl_Name,g.gl_code,g.tree_sape,g.p_id
		,'THISMONTH' = (sum(case when a.tran_date between @date1 and @date2 + ' 23:59:59' then 
						isnull((CASE WHEN A.part_tran_type='DR' THEN a.tran_amt*-1 ELSE a.tran_amt END),0)
						else 0 end))
		,'YEARTODATE' = isnull((sum(CASE WHEN A.part_tran_type='DR' THEN a.tran_amt*-1 ELSE a.tran_amt END)),0)
	from #gl_group g(nolock) 
	left join tran_master a(nolock) on g.gl_code = a.gl_sub_head_code
	where g.p_id in ('48', '60', '44', '45', '46', '47', 'r14') 
	GROUP BY g.gl_Name,g.gl_code,g.tree_sape,g.p_id)x
	GROUP BY gl_Name, gl_code, tree_sape, p_id


end  
