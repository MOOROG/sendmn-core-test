USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procTrialBalanceReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procTrialBalanceReport]
@flag char(1),
@date varchar(20),
@company_id varchar(20)=null,
@date2 varchar(20)=null

AS
set nocount on;

if @flag='a'
begin
	set @date= @date +' 23:59:59'

	select a.gl,g.gl_name,
			ABS(case when a.opening_amt<0 then isnull(a.opening_amt,0) else 0 end) as dr_opening,
			ABS(case when a.opening_amt>0 then isnull(a.opening_amt,0) else 0 end) as cr_opening,
		ABS(isnull(dr_turnover,0)) as dr_turnover,
		ABS(isnull(cr_turnover,0)) as cr_turnover,
		ABS(case when a.closing_amt<0 then isnull(a.closing_amt,0) else 0 end) as dr_closing,
		ABS(case when a.closing_amt>0 then isnull(a.closing_amt,0) else 0 end) as cr_closing,g.tree_sape 
			from(
		select  gl_sub_head_code as gl,
			sum (case
			when part_tran_type='dr'  and tran_date <@date then tran_amt*(-1) 
			when part_tran_type='Cr'  and tran_date < @date then tran_amt
			end) as opening_amt,
				sum (case when part_tran_type='dr'  and tran_date between cast( @date as datetime) and cast( @date2 +' 23:59:59' as datetime)then tran_amt*(-1) end) as dr_turnover,
				sum (case when part_tran_type='cr'  and tran_date between cast( @date as datetime) and cast( @date2 +' 23:59:59' as datetime)then tran_amt end) as cr_turnover,
			sum (case
			when part_tran_type='dr'  and tran_date <= @date2 +' 23:59:59'  then tran_amt*(-1) 
			when part_tran_type='Cr'  and tran_date <= @date2 +' 23:59:59'  then tran_amt
			end) as closing_amt
		from tran_master t with (nolock), ac_master c  with (nolock)
		where t.acc_num=c.acct_num
			and t.company_id =1
		group by gl_sub_head_code
		) a , GL_GROUP g 
	where a.gl=g.gl_code
	order by g.gl_name

end

if @flag='d'
begin

	select a.gl,g.gl_name, a.acct_name,
			ABS(case when a.opening_amt<0 then isnull(a.opening_amt,0) else 0 end) as dr_opening,
			ABS(case when a.opening_amt>0 then isnull(a.opening_amt,0) else 0 end) as cr_opening,
		ABS(isnull(dr_turnover,0)) as dr_turnover,
		ABS(isnull(cr_turnover,0)) as cr_turnover,
		ABS(case when a.closing_amt<0 then isnull(a.closing_amt,0) else 0 end) as dr_closing,
		ABS(case when a.closing_amt>0 then isnull(a.closing_amt,0) else 0 end) as cr_closing ,a.acc_num,g.tree_sape
			from(
		select  gl_sub_head_code as gl,acc_num, c.acct_name,
			sum (case
			when part_tran_type='dr'  and tran_date <@date then tran_amt*(-1) 
			when part_tran_type='Cr'  and tran_date < @date then tran_amt
			end) as opening_amt,
				sum (case when part_tran_type='dr'  and tran_date between cast( @date as datetime) and cast( @date2 +' 23:59:59' as datetime)then tran_amt*(-1) end) as dr_turnover,
				sum (case when part_tran_type='cr'  and tran_date between cast( @date as datetime) and cast( @date2 +' 23:59:59' as datetime)then tran_amt end) as cr_turnover,
			sum (case
			when part_tran_type='dr'  and tran_date <= @date2 +' 23:59:59'  then tran_amt*(-1) 
			when part_tran_type='Cr'  and tran_date <= @date2 +' 23:59:59'  then tran_amt
			end) as closing_amt
		from tran_master t with (nolock), ac_master c  with (nolock)
		where t.acc_num=c.acct_num
			and t.company_id =1
		group by gl_sub_head_code,acc_num,c.acct_name
		) a , GL_GROUP g 
where a.gl=g.gl_code
order by g.gl_name, a.acct_name

end








GO
