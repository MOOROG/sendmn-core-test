USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcAuditTrailReport]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec [ProcAuditTrailReport] 'a','2010-6-21','2011-6-21','0',1

CREATE procEDURE [dbo].[ProcAuditTrailReport] 
	@flag varchar(2),
	@startdt varchar(10)=null,
	@enddt varchar(10)=null,
	@vouchertype varchar(1)=null,
	@ref_num varchar(20)=null,
	@user varchar(200)=null
	
AS

	SET NOCOUNT ON;
	
if @vouchertype='0'
set @vouchertype = null;

if @flag='i'
begin
		
	insert into AuditTrailDetail(ref_num, tran_type, approved_date , approved_by)
	values (@ref_num,@vouchertype, GETDATE(), @user)
	

	SELECT 'APPROVE SUCCESS: '+ @ref_num as MSG
	
end

if @flag='a'
begin



	select b.ref_num [V No],case isnull(b.tran_type,'0') when '0' then b.tran_type else b.tran_type END   [Voucher Type],a.acct_num [Ac No],a.acct_name [Ac Name],convert(varchar,c.tran_date,102) [Date] ,
	isnull(b.amount,0)as amount, d.approved_date
	from 
	(
		select 
			ref_num,sum(tran_amt)/2 as Amount,tran_type,MIN(cast(part_tran_srl_num as int)) 
			as part_tran_srl_num		
		from tran_master with(nolock
	)
	where tran_date between @startdt and  @enddt +' 23:59:59'
		and tran_type like isnull(@vouchertype,'%')
	group by ref_num,tran_type
	) b 
	join tran_master c with(nolock) on b.ref_num=c.ref_num 
			and b.part_tran_srl_num=c.part_tran_srl_num and c.tran_type= b.tran_type
	join ac_master a with(nolock) on c.acc_num=a.acct_num
	left join AuditTrailDetail d with(nolock) on d.ref_num=b.ref_num
		and d.tran_type=b.tran_type 
	where 1=1
		and d.approved_date is null
	order by b.tran_type,cast(b.ref_num as float)

end










GO
