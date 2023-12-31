USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcBillByBillExReport]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Proc [dbo].[ProcBillByBillExReport]
AS
begin

set nocount on;


	select 
		a.acct_name,a.acct_num,a.amt As_per_txn,
		b.closing As_per_bill_by_bill
	from (
		select acct_name,acct_num, clr_bal_amt as amt
		from ac_master with (nolock)
		where isnull(bill_by_bill,0)='Y'
	)a,
	(
		select ACC_NUM,SUM(case when part_trn_type='Dr' then remain_amt*-1 else remain_amt end) closing
		from BILL_BY_BILL with (nolock) 
		where REMAIN_AMT<>0 group by ACC_NUM
	) b
	where a.acct_num=b.ACC_NUM
	and a.amt<>b.closing

end


GO
