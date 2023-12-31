USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcBillByBillOutstanding]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ProcBillByBillOutstanding '261045421 ', '2011-04-26'

CREATE proc [dbo].[ProcBillByBillOutstanding]
	@ac_num varchar(20),
	@date varchar(30)

AS
begin


	select ROW_NUMBER()over(order by billno) [SN], [Booking Date],billno [Bill No],[Dr Amount],[Cr Amount],
	 convert(decimal(9,2),ABS(closing),102) [Closing],case when closing<0 then 'Dr' else 'Cr' end 'Dr/Cr'
	from ( select MIN(trandate)[Booking Date],billno , 
		convert(varchar,SUM(Dr),102) [Dr Amount],
		convert(varchar,SUM(cr),102) [Cr Amount], 
		SUM(cr)-SUM(dr) closing 
		from ( select CONVERT(varchar, tran_date,102)trandate,acc_num, billno, 
		case when part_tran_type='dr' then convert(decimal(9,2),tran_amt,102) else 0 end 'Dr', 
		case when part_tran_type='cr' then convert(decimal(9,2),tran_amt,102) else 0 end 'Cr' 
		from tran_master 
		where acc_num =@ac_num 
		and tran_date<= @date + ' 23:59:59' )xy 
	group by billno)zy where closing<>0 


end


GO
