USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procDayBook]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec daybook '1/4/2009','6/5/2009','p',1
-- Exec [procDayBook] '2010-7-1','2010-7-1',null,1

CREATE procEDURE [dbo].[procDayBook] 
	@startdt varchar(10),
	@enddt varchar(10),
	@vouchertype varchar(1)=null,
	@company_id int
AS

if @vouchertype = '0'
set @vouchertype = null;
begin

	SET NOCOUNT ON;

	select ROW_NUMBER() over (order by b.ref_num)[SN] , b.ref_num [V No],case isnull(b.tran_type,'0') when '0' then b.tran_type else b.tran_type END [Voucher Type], a.acct_num  [Ac Number],a.acct_name [Ac Name],
	convert(varchar,c.tran_date,102)[Date] ,
	CONVERT(decimal(9,2),(isnull(b.amount,0)),102) [Amount]
	from 
	(select 
				ref_num,sum(tran_amt)/2 as Amount,tran_type,
				MIN(cast(part_tran_srl_num as int)) as part_tran_srl_num
			from tran_master with(nolock)
			where company_id = @company_id
			and tran_date between @startdt  and  @enddt +' 23:59:59'
			and tran_type like isnull(@vouchertype,'%')
			group by ref_num,tran_type
	) b , ac_master a with(nolock), tran_master c with(nolock)
	where c.acc_num=a.acct_num
	and b.ref_num=c.ref_num
	and b.tran_type=c.tran_type
	and b.part_tran_srl_num=c.part_tran_srl_num
	order by b.tran_type,cast(b.ref_num as float)

end

--SN V No Voucher Acc Number  Name Date Amount 










GO
