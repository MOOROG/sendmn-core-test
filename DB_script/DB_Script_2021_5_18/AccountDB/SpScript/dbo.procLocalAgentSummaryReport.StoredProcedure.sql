USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procLocalAgentSummaryReport]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[procLocalAgentSummaryReport]
	@flag as char(1),
	@dateform as varchar(20)=null,
	@dateto as varchar(20)=null,
	@agent as varchar(20)=null,
	@PAY_STATUS as varchar(20)=null,
	@type	VARCHAR(10) = NULL,
	@user	VARCHAR(100)
AS

DECLARE @Title varchar(100) ='TRANSACTION SEARCH - DOMESTIC - SENDING AGENT'

set nocount on;
if @flag='s'
BEGIN

	select agent_name [AGENT NAME],S_AGENT AGENTID,sum(P_AMT) NPR_AMT,--sum(USD_AMT) as USD_AMT ,
		[No of Txn.] ='<a href="Reports.aspx?reportName=domestictxn&agentId='+@agent+'&fromDate='+@dateform
		+'&toDate='+@dateto+'&DateType=d&type='+@flag+'&payment_status='+isnull(@PAY_STATUS,'')+'" >'+ cast(COUNT(TRAN_ID) as varchar) +' </a>'
	from REMIT_TRN_LOCAL r WITH(NOLOCK)
	join agentTable a WITH(NOLOCK) on a.AGENT_IME_CODE= r.S_AGENT
	where 1=1 and CONFIRM_DATE between  @dateform  and  @dateto  + ' 23:59:59'
	and agent_id like ISNULL(@agent ,'%')
	and PAY_STATUS like ISNULL(@PAY_STATUS ,'%') 
	group by agent_name ,S_AGENT 
	order by agent_name
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_id = @agent),'All') union 
	SELECT 'Pay Status' head,ISNULL(@PAY_STATUS,'All')  
	
	SELECT title = @Title+' - Confirmed'

end
ELSE if @flag='p'
begin


	select agent_name [AGENT NAME],S_AGENT AGENTID,sum(P_AMT) NPR_AMT,--sum(USD_AMT) as USD_AMT ,
		[No of Txn.] ='<a href="Reports.aspx?reportName=domestictxn&agentId='+@agent+'&fromDate='+@dateform
		+'&toDate='+@dateto+'&DateType=d&type='+@flag+'&payment_status='+isnull(@PAY_STATUS,'')+'" >'+ cast(COUNT(TRAN_ID) as varchar) +' </a>'
	from REMIT_TRN_LOCAL r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.AGENT_IME_CODE= r.S_AGENT
	where 1=1 and P_DATE between  @dateform  and  @dateto  + ' 23:59:59'
		and agent_id like ISNULL(@agent ,'%') 
		and PAY_STATUS like ISNULL(@PAY_STATUS ,'%') 
	group by agent_name ,S_AGENT 
	order by agent_name
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_id = @agent),'All') union 
	SELECT 'Pay Status' head,ISNULL(@PAY_STATUS,'All')  
	
	SELECT title = @Title+' - Paid'

end
ELSE if @flag = 'c'
begin


	select agent_name [AGENT NAME],S_AGENT AGENTID,sum(P_AMT) NPR_AMT,--sum(USD_AMT) as USD_AMT ,
		[No of Txn.] ='<a href="Reports.aspx?reportName=domestictxn&agentId='+@agent+'&fromDate='+@dateform
		+'&toDate='+@dateto+'&DateType=d&type='+@flag+'&payment_status='+isnull(@PAY_STATUS,'')+'" >'+ cast(COUNT(TRAN_ID) as varchar) +' </a>'
	from REMIT_TRN_LOCAL r WITH(NOLOCK)
		join agentTable a WITH(NOLOCK) on a.AGENT_IME_CODE= r.S_AGENT
	where 1=1 and CANCEL_DATE between  @dateform  and  @dateto  + ' 23:59:59'
		and agent_id like ISNULL(@agent ,'%') 
		and TRN_STATUS = 'cancel'
	group by agent_name ,S_AGENT 
	order by agent_name
	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_id = @agent),'All') union 
	SELECT 'Pay Status' head,ISNULL(@PAY_STATUS,'All')  
	
	SELECT title = @Title+' - Canceled'
end
ELSE IF @flag='D'
BEGIN
	
	
	DECLARE @sql varchar(max), @DATETYPE VARCHAR(20)
	SELECT @DATETYPE = CASE @type WHEN 'S' THEN 'CONFIRM_DATE' WHEN 'P' THEN 'P_DATE' WHEN 'C' THEN 'CANCEL_DATE' END
	
	SET @sql = 'select TRAN_ID, dbo.decryptDbLocal(TRN_REF_NO) as TRN_REF_NO, SENDER_NAME,RECEIVER_NAME
		,[COLLECT AMT] = S_AMT,[PAY AMT] = P_AMT,[PAY AGENT] = RIGHT(paidby, LEN(paidby) - 3) , TRN_DATE, PAY_STATUS
	from REMIT_TRN_LOCAL r with(nolock) 
	join agentTable a WITH(NOLOCK) on a.AGENT_IME_CODE= r.S_AGENT
	--left join agentTable ab WITH(NOLOCK) on ab.AGENT_IME_CODE= r.R_AGENT
	where 1=1 '
	
	SET @sql +=' and '+@DATETYPE+' between  '''+@dateform+'''  and  '''+@dateto+'''+ '' 23:59:59'''
	
	SET @sql +=' and agent_id like ISNULL('+@agent+' ,''%'') '
	SET @sql +=' and TRN_STATUS = '+ CASE @type WHEN 'C' THEN '''cancel''' ELSE 'TRN_STATUS' END +''
	SET @sql +=' and PAY_STATUS like '+ CASE @type WHEN 'C' THEN 'PAY_STATUS' ELSE ISNULL(@PAY_STATUS ,'''%''') END +''
	
	--PRINT @sql
	EXEC(@sql)

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value
	UNION ALL
	SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value union 
	SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE agent_id = @agent),'All') union 
	SELECT 'Pay Status' head,ISNULL(@PAY_STATUS,'All')  
	
	SELECT title = @Title+' - Detail'
END



GO
