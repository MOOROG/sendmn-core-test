USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procAgentSummaryReportReceiving]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[procAgentSummaryReportReceiving]
	@flag		VARCHAR(2),
	@dateform	AS VARCHAR(20)=NULL,
	@dateto		AS VARCHAR(20)=NULL,
	@agent		AS VARCHAR(20)=NULL,
	@pay_status AS VARCHAR(20)=NULL,
	@req_type   AS VARCHAR(2) =NULL
AS
SET NOCOUNT ON;

DECLARE @SQL VARCHAR(5000)
SET @SQL=''

if @flag='s'
begin

	
	set  @SQL= 'select agent_name AGENT,map_code AGENTID,sum(P_AMT) NPR_AMT,sum(isnull(USD_AMT,''0'')) as USD_AMT ,
		COUNT(ROWID)NoOfTransaction from REMIT_TRN_MASTER r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.map_code= r.P_BRANCH
		where 1=1	'
	
	
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
		
	if @pay_status='Un-Paid' 
		set  @SQL= @SQL + ' and TRN_STATUS<>''Cancel'''	
		
	set  @SQL= @SQL + ' group by agent_name ,map_code order by agent_name'
	
	
	execute (@SQL)


end

if @flag='p'
begin
	
	declare @SqlCondt as varchar(2000)
	
	set @SqlCondt=''
	
	if @pay_status is not null
		set  @SqlCondt= @SqlCondt + 'and pay_status = '''+ @pay_status+''''
		
	if @agent is not null
		set  @SqlCondt= @SqlCondt + 'and agent_id = '''+ @agent +''''
		
	if @pay_status='Un-Paid' 
		set  @SqlCondt= @SqlCondt + ' and TRN_STATUS<>''Cancel'''	
	
	if @flag='p'
	set  @SqlCondt= @SqlCondt + 'and PAID_DATE between  '''+ @dateform +'''  and  '''+ @dateto +' 23:59:59'''
	
	--set  @SqlCondt= @SqlCondt + ' group by agent_name ,map_code order by agent_name'
	
	
	
	set  @SQL= 'select * from(
		select agent_name AGENT,P_BRANCH AGENTID,sum(P_AMT) NPR_AMT,sum(isnull(USD_AMT,''0'')) as USD_AMT ,TRN_TYPE,
		COUNT(ROWID)NoOfTransaction from REMIT_TRN_MASTER r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.map_code= r.P_BRANCH
		where 1=1 and TRN_TYPE=''Cash Pay'' 
		'
		
		
	set @SQL=@SQL + @SqlCondt + ' group by agent_name ,P_BRANCH,TRN_TYPE

	UNION all
	
	select agent_name AGENT,P_AGENT AGENTID,sum(P_AMT) NPR_AMT,sum(isnull(USD_AMT,''0'')) as USD_AMT ,TRN_TYPE,
			COUNT(ROWID)NoOfTransaction   
		from REMIT_TRN_MASTER r WITH(NOLOCK)
			join agentTable a WITH(NOLOCK) on a.map_code= r.P_AGENT
		where 1=1 and TRN_TYPE=''Bank Transfer''
	'
	
	set @SQL=@SQL + @SqlCondt + 'group by agent_name ,P_AGENT,TRN_TYPE )a order by AGENT '
	
     execute (@SQL)
	
end
if @flag='c'
begin

	select agent_name AGENT,P_BRANCH AGENTID,sum(P_AMT) NPR_AMT,sum(isnull(USD_AMT,'0')) as USD_AMT ,
		COUNT(ROWID)NoOfTransaction   
	from REMIT_TRN_MASTER r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.map_code= r.P_BRANCH
	where 1=1 and CANCEL_DATE between  @dateform  and  @dateto  + ' 23:59:59'
		and agent_id like ISNULL(@agent ,'%') 
		and pay_status like ISNULL( @pay_status,'%')
	group by agent_name ,P_BRANCH 
	order by agent_name

end

IF @flag =('DR')
BEGIN
	SELECT agent_name+'('+ref_no+')' AGENT,EP_BranchCode AGENTID,SUM(Amount) NPR_AMT,0 USD_AMT,COUNT(rowid) NoOfTransaction
	FROM ErroneouslyPaymentNew EP WITH (NOLOCK)
	LEFT JOIN agentTable A WITH (NOLOCK) 
	   ON CASE WHEN ISNULL(a.central_sett,'n')='y' THEN eP.EP_AgentCode ELSE eP.EP_BranchCode END = map_code
	WHERE EP.EP_date BETWEEN @dateform AND @dateto +' 23:59:59'
	AND agent_id = ISNULL(@agent ,agent_id) 
	GROUP BY agent_name,EP_BranchCode,ref_no
	ORDER BY agent_name
END

IF @flag =('CR')
BEGIN
	SELECT agent_name+'('+ref_no+')' AGENT,PO_BranchCode AGENTID,SUM(Amount) NPR_AMT,0 USD_AMT,COUNT(rowid) NoOfTransaction
	FROM ErroneouslyPaymentNew EP WITH (NOLOCK)
	LEFT JOIN agentTable A WITH (NOLOCK) 
	   ON CASE WHEN ISNULL(a.central_sett,'n')='y' THEN eP.PO_AgentCode ELSE eP.PO_BranchCode END = map_code
	WHERE EP.PO_date BETWEEN @dateform AND @dateto +' 23:59:59'
	AND agent_id = ISNULL(@agent ,agent_id) 
	GROUP BY agent_name,PO_BranchCode,ref_no
	ORDER BY agent_name
END
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

  SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value UNION
  SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value UNION 
  SELECT 'Pay Status' head, @pay_status value UNION
  SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_Id = @agent),'All')  
  
  SELECT title = 'Remit Transaction Report - Receiving Agent'  
	
	
	



GO
