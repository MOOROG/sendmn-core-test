USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetACBal]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select [dbo].FNAGetACBal('23456-23456-00000017')

*/	
        
CREATE FUNCTION [dbo].[FNAGetACBal](@acctNum VARCHAR(30))
RETURNS MONEY
AS  
BEGIN
	RETURN ISNULL((	
		SELECT
			SUM(CASE WHEN part_tran_type = 'dr' THEN ISNULL(tran_amt, 0) * -1 ELSE ISNULL(tran_amt, 0) END)		
		FROM tran_master tmd WITH(NOLOCK) 
		WHERE tmd.acc_num = @acctNum 
	), 0)
END

GO
