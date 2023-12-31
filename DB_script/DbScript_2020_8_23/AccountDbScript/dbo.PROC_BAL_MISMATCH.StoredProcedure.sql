USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_BAL_MISMATCH]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PROC_BAL_MISMATCH]
AS

SET NOCOUNT ON;

begin
 --   Select a.acct_num,a.acct_name,a.clr_bal_amt, b.tran_amt
 --   from
 --   (
 --   select acct_num,acct_name,clr_bal_amt from ac_master)
	--a left join 
 --   (
 --   select acc_num, 
 --   sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) as tran_amt
 --   FROM
 --   (
 --   select acc_num,part_tran_type,tran_amt
 --   from tran_master)a 
 --   group by acc_num
 --   ) b
 --   on a.acct_num =b.acc_num
 --   where a.clr_bal_amt<>isnull (b.tran_amt,0)
 --   GO
    ------------------

    UPDATE ac_master set  clr_bal_amt=0, available_amt=0

    UPDATE ac_master
				    SET clr_bal_amt = isnull(Total,0)
				    FROM ac_master AS a
				    left JOIN( 
					    select 
					    t.acc_num,isnull(sum (case when part_tran_type='dr' then tran_amt*-1 else tran_amt end),0) Total
					    from tran_master t 
					    group by t.acc_num 
				    )AS t
				    ON a.acct_num = t.acc_num
    --GO
    update ac_master set available_amt = clr_bal_amt
    
	update ac_master set available_amt = clr_bal_amt + dr_bal_lim - system_reserved_amt
    select SUM(clr_bal_amt) from ac_master
End



GO
