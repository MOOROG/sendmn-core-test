USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_autoUnlok_domestic_txn]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec proc_autoUnlok_domestic_txn

CREATE proc [dbo].[proc_autoUnlok_domestic_txn]
as
begin

    SET NOCOUNT ON;

    --select lockedDate, lockedBy, * from remitTran where tranStatus ='Lock' and payStatus='unPaid'
    --and datediff(MINUTE,lockedDate,GETDATE())>=7 -- 'Payment'

    update remitTran 
		set tranStatus='Payment' 
    where 
		tranStatus='Lock' 
		and datediff(MINUTE,lockedDate,GETDATE())>=7
		and payStatus='Unpaid'
	
	update remitTran 
		set tranStatus = 'Paid' 
	where paidDate is not null
	and payStatus = 'Paid' and tranStatus ='Payment'

end

GO
