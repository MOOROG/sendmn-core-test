USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procUserStatement]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[procUserStatement]
	@flag char(1),
	@user varchar(20),
	@startDate varchar(20)=null,
	@endDate varchar(20) =null,
	@vouchertype char(5) = null,
	@company_id varchar(20)=null
	
AS

set nocount on;

if @flag='t'
begin

	set @endDate=@startDate +' 23:59:59'

	select * from (
	Select distinct part_tran_srl_num [SN], acc_num [Ac No], acct_name [Ac Name],
                 case when part_tran_type='dr' then convert(decimal(9,2),tran_amt,102) else 0 end  as [DR Amount],
				 case when part_tran_type='cr' then convert(decimal(9,2),tran_amt,102) else 0 end  as [CR Amount],
				 t.ref_num as TRNno, convert(varchar,tran_date,102) TRNDate, tran_particular, entry_user_id, t.billno
	from tran_master t WITH (NOLOCK) , ac_master a  WITH (NOLOCK), tran_masterDetail d with (nolock)
	where t.ref_num=d.ref_num and t.tran_type=d.tran_type and t.company_id=d.company_id 
		and acc_num=acct_num	
		and t.company_id=@company_id
		and t.tran_type=@vouchertype
		and t.ref_num=@user
	) a order by SN asc,cast(SN as int)
	
end

if @flag='a'
begin


	set @endDate=@endDate +' 23:59:59'

	select * from (
	select distinct t.ref_num as TRNno,convert(varchar,tran_date,102) TRNDate,acc_num,acct_name, 
		tran_rmks,part_tran_srl_num,tran_particular,t.billno,
		case when part_tran_type='dr' then tran_amt else 0 end  as DRTotal,
		case when part_tran_type='cr' then tran_amt else 0 end  as cRTotal, tran_date AS TD,entry_user_id,rpt_code
	from tran_master t WITH (NOLOCK), ac_master WITH (NOLOCK) , tran_masterDetail d with (nolock)
	where t.ref_num=d.ref_num and t.tran_type=d.tran_type and t.company_id=d.company_id
		and acc_num=acct_num 
		and tran_date between @startDate and @endDate 
		and t.company_id=@company_id 
		and entry_user_id like @user
	) a order by TD , TRNno, cast(part_tran_srl_num as int)
	

end








GO
