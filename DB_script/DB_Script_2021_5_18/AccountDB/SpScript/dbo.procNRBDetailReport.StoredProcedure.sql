USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procNRBDetailReport]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[procNRBDetailReport]
@flag as char(1),
@dateform as varchar(20)=null,
@dateto as varchar(20)=null,
@agent as varchar(20)=null,
@Title as varchar(50)=null
AS

set @dateto=@dateto +' 23:59:59'
set nocount on;

declare @total_paid money, @sql2 varchar(2000)
declare @SQL varchar(2000)
set @SQL=''


IF @flag='s'
BEGIN

	SET @sql='
	SELECT CURR_NAME , SUM(ISNULL(NPR_AMT,0)) NPR_AMT, SUM(ISNULL(USD_AMT,0)) USD_AMT FROM
		 (SELECT S_AGENT, NPR_AMT,  F.USD_AMT
		FROM FundTransactionSummary F WITH (NOLOCK)
		LEFT JOIN agentTable A WITH (NOLOCK) ON F.S_AGENT=A.map_code
		INNER JOIN ac_master AC WITH (NOLOCK) ON F.R_BANK=AC.acct_num
		WHERE R_BANK IS NOT NULL AND vtype=''R'' AND AC.ac_currency IN (''USD'',''GBP'')
		AND tran_date BETWEEN '''+ @dateform +''' AND '''+ @dateto +'''
		)X
		RIGHT JOIN agentTable AT ON X.S_AGENT=AT.map_code
		INNER JOIN currency_setup C WITH (NOLOCK) ON AT.agent_address=C.ROWID
		AND AT.AGENT_TYPE=''SENDING'' AND AT.agent_status=''Y'' AND AT.map_code NOT IN (''31700000'')
		--- XPRESS GBP
		'


	IF @agent IS NOT NULL
	SET @sql= @sql + ' and map_code='''+ @agent +''''

	SET @sql= @sql + ' GROUP BY CURR_NAME ORDER BY CURR_NAME'
	
	

	EXEC (@SQL)
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	  SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value UNION
	  SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value union 
	  SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @agent),'All')  
 
	  SELECT title = @Title

END


IF @flag='d'
BEGIN

SET @sql='
		SELECT AT.AGENT_NAME PARTICULAR, CURR_NAME, SUM(ISNULL(USD_AMT,0)) USD_AMT, SUM(ISNULL(NPR_AMT,0))  NPR_AMT FROM 
		 (SELECT S_AGENT, NPR_AMT,  F.USD_AMT
		FROM FundTransactionSummary F WITH (NOLOCK)
		LEFT JOIN agentTable A WITH (NOLOCK) ON F.S_AGENT=A.map_code
		INNER JOIN ac_master AC WITH (NOLOCK) ON F.R_BANK=AC.acct_num
		WHERE R_BANK IS NOT NULL AND vtype=''R'' AND AC.ac_currency IN (''USD'',''GBP'')
		AND tran_date BETWEEN '''+ @dateform +''' AND '''+ @dateto +'''
		)X
		RIGHT JOIN agentTable AT ON X.S_AGENT=AT.map_code
		INNER JOIN currency_setup C WITH (NOLOCK) ON AT.agent_address=C.ROWID
		AND AT.AGENT_TYPE=''SENDING'' AND AT.agent_status=''Y'' AND AT.map_code NOT IN (''31700000'')
		--- XPRESS GBP
		'

IF @agent IS NOT NULL
SET @sql= @sql + ' and map_code='''+ @agent +''''

SET @sql= @sql + ' GROUP BY AGENT_NAME,CURR_NAME ORDER BY CURR_NAME'

EXEC (@SQL)
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

  SELECT 'From Date' head, CONVERT(VARCHAR(10), @dateform, 101) value UNION
  SELECT 'To Date' head, CONVERT(VARCHAR(10), @dateto, 101) value union 
  SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable WHERE map_code = @agent),'All')  
 
  SELECT title = @Title

END






GO
