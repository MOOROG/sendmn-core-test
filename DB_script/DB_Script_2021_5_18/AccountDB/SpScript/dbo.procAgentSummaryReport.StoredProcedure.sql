USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procAgentSummaryReport]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[procAgentSummaryReport]
	@flag as char(1),
	@dateform as varchar(20)=null,
	@dateto as varchar(20)=null,
	@agent as varchar(20)=null,
	@pay_status as varchar(20)=null
AS

set nocount ON;



declare @SQL varchar(5000)

set @SQL=''
begin
-- <a href="remittance_trn_display_drildown.asp?Send_agent_id=<%=rst("AGENTID")%>&start_date=<%=request("start_date")%>
--&TODATE=<%=request("TODATE")%>&payment_status=<%=request("payment_status")%>&DateType=<%=request("DateType")%>">	
-- No of Transaction Field Maa you link attach garnu parchaa...
	set  @SQL= 'SELECT AGENT,AGENTID,SUM(NPR_AMT) NPR_AMT,SUM(USD_AMT) USD_AMT,count(*) NoOfTransaction FROM (
		select agent_name AGENT,S_AGENT AGENTID,P_AMT NPR_AMT
		,CASE WHEN S_AGENT = ''20300000'' AND r.NPR_USD_RATE IS NULL THEN USD_AMT 
			  WHEN ISNULL(r.NPR_USD_RATE,1) = 1 AND S_AGENT <> ''20300000'' THEN 0 
			  ELSE USD_AMT END as USD_AMT 
		from REMIT_TRN_MASTER r WITH(NOLOCK)
			join agentTable a WITH(NOLOCK) on a.map_code= r.S_AGENT
		where 1=1 '
	
	
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
		
	----set  @SQL= @SQL + ' group by agent_name ,S_AGENT,EX_FLC '

	SET @SQL = @SQL+')X GROUP BY AGENT,AGENTID order by AGENT'

	execute (@SQL)
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

  SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value UNION
  SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value UNION 
  SELECT 'Pay Status' head, @pay_status value UNION
  SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_Id = @agent),'All')  
  
  SELECT title = 'Remit Transaction Report - Sending Agent'  
	
	
	

end



GO
