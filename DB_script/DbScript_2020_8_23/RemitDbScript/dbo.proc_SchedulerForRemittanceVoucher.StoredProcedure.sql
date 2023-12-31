ALTER  proc [dbo].[proc_SchedulerForRemittanceVoucher]
as
set nocount on


select field1,ref_num,acct_type_code into #acc 
from SendMnPro_Account.dbo.tran_master(nolock) where field2='remittance voucher' ----and acc_num='771345592'
and acct_type_code is  null and tran_date >=DATEADD(DAY,-2,cast(getdate() as date))
and acc_num in (
select acc_num from SendMnPro_Account.dbo.ac_master(nolock) where agent_id in (
select agentId from agentmaster(nolock) where isApiPartner=1 and agenttype=2903
 union 
 select 1056 union 
 select 1036
) and acct_rpt_code='TC'
)

--select * from ac_master(nolock) where acct_name like '%tranglo%'


select  controlNo=dbo.FNADecryptString(controlNo),pagent,pagentName,approveddate,pcountry,pagentcomm into #temp 
from remittran(nolock) where 
approveddate BETWEEN DATEADD(DAY,-2,cast(getdate() as date)) AND DATEADD(MINUTE,-5,GETDATE()) and pagent in (
 select agentId from agentmaster(nolock) where isApiPartner=1 and agenttype=2903
 union 
 select 1056 union 
 select 1036
)

--select 'exec proc_transactionVoucherEntry '''+controlNo+'''' from #temp t  where pcountry <> 'Cambodia'


--select * from #temp t 
--inner join #acc c on c.field1 = t.controlNo


delete t from #temp t
inner join #acc c on c.field1 = t.controlNo

select TOP 10 * into #RemainforVoucher from #temp

alter table #RemainforVoucher add id int IDENTITY(1,1)

declare @tRow int,@controlno varchar(20)
select @tRow = count(1) from #RemainforVoucher
--select * from #RemainforVoucher
--return

while @tRow>0
begin

	select @controlno = controlNo from #RemainforVoucher where id = @tRow

	EXEC SendMnPro_Account.dbo.proc_transactionVoucherEntry @controlno
	WAITFOR DELAY '000:00:01'
	set @tRow = @tRow -1 

end





GO
