USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procAgentSummaryReportMonthly]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE	 proc [dbo].[procAgentSummaryReportMonthly]
	@flag as char(1),
	@dateform as varchar(20)=null,
	@dateto as varchar(20)=null,
	@agent as varchar(20)=null,
	@ragent as varchar(20)=null,
	@pay_status as varchar(20)=null,
	@reportType as varchar(2)=null
AS

set nocount on;
declare @SQL varchar(5000)
set @SQL=''

if @reportType='s'
begin
	
	set  @SQL= 'SELECT agent_name as AGENT, 
	
			sum(case when month(TRN_DATE)=1 then 1 else 0 end) [JAN],
	sum(case when month(TRN_DATE)=1 then P_AMT else 0 end) [JANAMT],
	
	sum(case when month(TRN_DATE)=2 then 1 else 0 end) [FEB],
	sum(case when month(TRN_DATE)=2 then P_AMT else 0 end) [FEBAMT],
	
	sum(case when month(TRN_DATE)=3 then 1 else 0 end) [MAR],
	sum(case when month(TRN_DATE)=3 then P_AMT else 0 end) [MARAMT],
	
	sum(case when month(TRN_DATE)=4 then 1 else 0 end) [APR],
	sum(case when month(TRN_DATE)=4 then P_AMT else 0 end) [APRAMT],
	
	sum(case when month(TRN_DATE)=5 then 1 else 0 end) [MAY],
	sum(case when month(TRN_DATE)=5 then P_AMT else 0 end) [MAYAMT],
	
	sum(case when month(TRN_DATE)=6 then 1 else 0 end) [JUN],
	sum(case when month(TRN_DATE)=6 then P_AMT else 0 end) [JUNAMT],
	
	sum(case when month(TRN_DATE)=7 then 1 else 0 end) [JUL],
	sum(case when month(TRN_DATE)=7 then P_AMT else 0 end) [JULAMT],
	
	sum(case when month(TRN_DATE)=8 then 1 else 0 end) [AUG],
	sum(case when month(TRN_DATE)=8 then P_AMT else 0 end) [AUGAMT],
	
	sum(case when month(TRN_DATE)=9 then 1 else 0 end) [SEP],
	sum(case when month(TRN_DATE)=9 then P_AMT else 0 end) [SEPAMT],
	
	sum(case when month(TRN_DATE)=10 then 1 else 0 end) [OCT],
	sum(case when month(TRN_DATE)=10 then P_AMT else 0 end) [OCTAMT],
	
	sum(case when month(TRN_DATE)=11 then 1 else 0 end) [NOV],
	sum(case when month(TRN_DATE)=11 then P_AMT else 0 end) [NOVAMT],
	
	sum(case when month(TRN_DATE)=12 then 1 else 0 end) [DEC],
	sum(case when month(TRN_DATE)=12 then P_AMT else 0 end) [DECAMT]
			
		from REMIT_TRN_MASTER r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.map_code= r.S_AGENT
		
	where 1=1 	'
	
	if @flag='s'
	set  @SQL= @SQL + 'and TRN_DATE between  '''+ @dateform +'''  and  '''+ @dateto +' 23:59:59'''
		
	if @flag='p'
	set  @SQL= @SQL + 'and PAID_DATE between  '''+ @dateform +'''  and  '''+ @dateto +' 23:59:59'''
	
	if @flag='c'
	set  @SQL= @SQL + 'and CANCEL_DATE between  '''+ @dateform +'''  and  '''+ @dateto +' 23:59:59'''
	
	if @pay_status is not null
		set  @SQL= @SQL + 'and pay_status = '''+ @pay_status+''''
		
	if @agent is not null
		set  @SQL= @SQL + 'and agent_id = '''+ @agent +''''
		
	if @flag<>'c'
		set  @SQL= @SQL + ' and TRN_STATUS<>''Cancel'''	
		
	if @ragent is not null
	set @SQL=@SQL +' and P_BRANCH='''+ @ragent +''''
		
	set  @SQL= @SQL + ' group by agent_name order by agent_name'

	print @SQL
	execute (@SQL)

end

if @reportType='p'
begin
	
	declare @SqlCondt as varchar(2000)
	
	set @SqlCondt=''
		
	if @agent is not null
		set  @SqlCondt= @SqlCondt + 'and agent_id = '''+ @agent +''''

	set  @SqlCondt= @SqlCondt + 'and PAID_DATE between  '''+ @dateform +'''  
					and  '''+ @dateto +' 23:59:59'''
	
	set  @SQL= '
	
	SELECT * FROM (
		SELECT agent_name as AGENT, map_code, 
		
		sum(case when month(PAID_DATE)=1 then 1 else 0 end) [JAN],
		sum(case when month(PAID_DATE)=1 then P_AMT else 0 end) [JANAMT],
		
		sum(case when month(PAID_DATE)=2 then 1 else 0 end) [FEB],
		sum(case when month(PAID_DATE)=2 then P_AMT else 0 end) [FEBAMT],
		
		sum(case when month(PAID_DATE)=3 then 1 else 0 end) [MAR],
		sum(case when month(PAID_DATE)=3 then P_AMT else 0 end) [MARAMT],
		
		sum(case when month(PAID_DATE)=4 then 1 else 0 end) [APR],
		sum(case when month(PAID_DATE)=4 then P_AMT else 0 end) [APRAMT],
		
		sum(case when month(PAID_DATE)=5 then 1 else 0 end) [MAY],
		sum(case when month(PAID_DATE)=5 then P_AMT else 0 end) [MAYAMT],
		
		sum(case when month(PAID_DATE)=6 then 1 else 0 end) [JUN],
		sum(case when month(PAID_DATE)=6 then P_AMT else 0 end) [JUNAMT],
		
		sum(case when month(PAID_DATE)=7 then 1 else 0 end) [JUL],
		sum(case when month(PAID_DATE)=7 then P_AMT else 0 end) [JULAMT],
		
		sum(case when month(PAID_DATE)=8 then 1 else 0 end) [AUG],
		sum(case when month(PAID_DATE)=8 then P_AMT else 0 end) [AUGAMT],
		
		sum(case when month(PAID_DATE)=9 then 1 else 0 end) [SEP],
		sum(case when month(PAID_DATE)=9 then P_AMT else 0 end) [SEPAMT],
		
		sum(case when month(PAID_DATE)=10 then 1 else 0 end) [OCT],
		sum(case when month(PAID_DATE)=10 then P_AMT else 0 end) [OCTAMT],
		
		sum(case when month(PAID_DATE)=11 then 1 else 0 end) [NOV],
		sum(case when month(PAID_DATE)=11 then P_AMT else 0 end) [NOVAMT],
		
		sum(case when month(PAID_DATE)=12 then 1 else 0 end) [DEC],
		sum(case when month(PAID_DATE)=12 then P_AMT else 0 end) [DECAMT]
	
		from REMIT_TRN_MASTER r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.map_code= r.P_BRANCH
	where 1=1 and TRN_TYPE=''Cash Pay'' '
	
	set @SQL=@SQL + @SqlCondt + ' group by agent_name,map_code

	UNION all
	
	SELECT agent_name as AGENT, map_code,  
	
	sum(case when month(PAID_DATE)=1 then 1 else 0 end) [JAN],
	sum(case when month(PAID_DATE)=1 then P_AMT else 0 end) [JANAMT],
	
	sum(case when month(PAID_DATE)=2 then 1 else 0 end) [FEB],
	sum(case when month(PAID_DATE)=2 then P_AMT else 0 end) [FEBAMT],
	
	sum(case when month(PAID_DATE)=3 then 1 else 0 end) [MAR],
	sum(case when month(PAID_DATE)=3 then P_AMT else 0 end) [MARAMT],
	
	sum(case when month(PAID_DATE)=4 then 1 else 0 end) [APR],
	sum(case when month(PAID_DATE)=4 then P_AMT else 0 end) [APRAMT],
	
	sum(case when month(PAID_DATE)=5 then 1 else 0 end) [MAY],
	sum(case when month(PAID_DATE)=5 then P_AMT else 0 end) [MAYAMT],
	
	sum(case when month(PAID_DATE)=6 then 1 else 0 end) [JUN],
	sum(case when month(PAID_DATE)=6 then P_AMT else 0 end) [JUNAMT],
	
	sum(case when month(PAID_DATE)=7 then 1 else 0 end) [JUL],
	sum(case when month(PAID_DATE)=7 then P_AMT else 0 end) [JULAMT],
	
	sum(case when month(PAID_DATE)=8 then 1 else 0 end) [AUG],
	sum(case when month(PAID_DATE)=8 then P_AMT else 0 end) [AUGAMT],
	
	sum(case when month(PAID_DATE)=9 then 1 else 0 end) [SEP],
	sum(case when month(PAID_DATE)=9 then P_AMT else 0 end) [SEPAMT],
	
	sum(case when month(PAID_DATE)=10 then 1 else 0 end) [OCT],
	sum(case when month(PAID_DATE)=10 then P_AMT else 0 end) [OCTAMT],
	
	sum(case when month(PAID_DATE)=11 then 1 else 0 end) [NOV],
	sum(case when month(PAID_DATE)=11 then P_AMT else 0 end) [NOVAMT],
	
	sum(case when month(PAID_DATE)=12 then 1 else 0 end) [DEC],
	sum(case when month(PAID_DATE)=12 then P_AMT else 0 end) [DECAMT]
	
		from REMIT_TRN_MASTER r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.map_code= r.P_AGENT
		where 1=1 and TRN_TYPE=''Bank Transfer'''
		
	set  @SQL= @SQL + @SqlCondt + ' group by agent_name, map_code

	)a	where 1=1 '
	
	if @ragent is not null
	set @SQL=@SQL +' and map_code='''+ @ragent +''''
	
	-- print @SQL
	
	execute (@SQL)
end

 EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

  SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value UNION
  SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value UNION 
  SELECT 'Pay Status' head, @pay_status value UNION
  SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_Id=  case when @reportType = 's' then @agent else  @ragent  end),'All')   UNION
  SELECT 'Report Type' head, @reportType value 
  
 SELECT title = case when @reportType='s' then ' Monthly Report - Sending Agentwise ' else ' Monthly Report - Receiving  Agentwise ' end


GO
