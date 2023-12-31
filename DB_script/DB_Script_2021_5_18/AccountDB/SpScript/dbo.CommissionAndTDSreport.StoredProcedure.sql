USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[CommissionAndTDSreport]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec [CommissionAndTDSreport] '2012-8-16',null

CREATE proc [dbo].[CommissionAndTDSreport]
	@date1 as varchar(20),
	@agentid as varchar(20)=null
AS
begin

	SET NOCOUNT ON;

	select g.PANNUMBER [PAN NO.],g.agent_name [AGENT NAME],
		sum(case when part_tran_type ='CR' then tran_amt else 0 end) [COMM AMT]	,
		sum(case when part_tran_type ='DR' then tran_amt else 0 end) [TDS AMT]
		,@date1 as [DATE],'AD' [DATE TYPE],g.CONSTITUTION [TDS TYPE]
		--,g.map_code
	from tran_master t with(nolock) , ac_master a with(nolock), agentTable g with(nolock)
	where t.acc_num=a.acct_num and a.agent_id=g.agent_id 
    and CHEQUE_NO = 'TDS'
	and tran_date between @date1 and @date1+ ' 23:59'
	and rpt_code is null
	and a.acct_rpt_code = '20'
	and g.agent_id like isnull(@agentid,g.agent_id)
	group by g.agent_name,g.map_code, g.PANNUMBER,g.CONSTITUTION
	order by g.agent_name

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

  SELECT 'TDS Calculated  Date' head, CONVERT(VARCHAR(10), @date1, 101) value UNION
  SELECT 'Agent Name' head,ISNULL((SELECT agent_name FROM agentTable(NOLOCK) WHERE agent_Id = @agentid),'All')  
  
  SELECT title = 'COMMISSION AND TDS REPORT'  
	

end






GO
