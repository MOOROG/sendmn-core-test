USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcBalanceCheckReport]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ProcBalanceCheckReport]
	@flag char(1)

as

set nocount on;


if @flag='a'
begin

	select c.acct_name, acc_num,R_AMT_EXCHANGE,STATEMENT_BALANCE  from 
	(
		select  t.acc_num,
			sum(case when part_tran_type='dr' then t.usd_amt*-1 else t.usd_amt end) as STATEMENT_BALANCE
			from tran_master t WITH (NOLOCK) where gl_sub_head_code='8'
		group by t.acc_num
	) t,		 
	(
		select R_BANK, sum (REMAIN_AMT_EXCHANGE) as R_AMT_EXCHANGE 
			from dbo.FundTransactionSummary WITH (NOLOCK)
		where R_BANK <> ''
		group by R_BANK
	)a, 
	
	ac_master c with (nolock)
	where t.acc_num=a.R_BANK and a.R_BANK = c.acct_num


end

if @flag='s'
begin
		
		Select x.acct_name as Agent_name,x.map_code,
			isnull(x.AC_Balance,0) AC_Balance,
			isnull(y.Receivable_amt,0) Receivable_amt,
			isnull(z.Received_amt,0) Received_amt, 
			isnull(x.AC_Balance,0)+isnull(y.Receivable_amt,0)-isnull(z.Received_amt,0) as diff 
		From 
		(select acct_num,acct_name,map_code, 
		Isnull(Round(SUM ( case when c.part_tran_type='dr' then isnull(c.usd_amt,0)*-1 else isnull(c.usd_amt,0) end),2),0) as AC_Balance 
		from ac_master A with (nolock) 
		inner join agentTable B with (nolock) on a.agent_id=b.agent_id 
		inner join tran_master C with (nolock) on a.acct_num=c.acc_num 
		where acct_rpt_code='3' 
		and ac_currency='USD' 
		group by acct_num,acct_name,map_code) x 
		left join 
		( 
		 select s_agent, round(SUM(isnull(remain_amt,0)),2) as Receivable_amt 
		 from SendTransactionSummary with (nolock) 
		 group by s_agent) y on x.map_code=y.S_AGENT 
		left join 
		( 
		 select s_agent, 
		 round(SUM(isnull(remain_amt,0)),2) as Received_amt 
		 from FundTransactionSummary with (nolock) 
		 group by s_agent)z on x.map_code=z.S_AGENT 
 
end


if @flag='c'
begin
 
		Select a.acct_num,a.acct_name,a.clr_bal_amt, b.tran_amt
		from
		(
			select acct_num,acct_name,clr_bal_amt from ac_master with(nolock) )
		 a left join 
		(
			select acc_num, 
			sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) as tran_amt
		FROM
		(
			select acc_num,part_tran_type,tran_amt
			from tran_master with(nolock) )a 
			group by acc_num
		) b
		on a.acct_num =b.acc_num
		where a.clr_bal_amt<>isnull (b.tran_amt,0)

end



GO
