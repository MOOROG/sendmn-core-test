USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACurrentBalByAgentCode]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNACurrentBalByAgentCode]
(
	@StrAgentCode as varchar(20)
)
RETURNS @list TABLE (clr_bal_amt MONEY, todaysSend MONEY, todaysPaid MONEY, todaysCancel MONEY, todaysEPI MONEY, todaysPOI MONEY)
AS  
BEGIN 
	DECLARE @clr_bal_amt MONEY, @todaysSend MONEY, @todaysPaid MONEY, @todaysCancel MONEY, @mapCode VARCHAR(8)
	
	INSERT @list
	SELECT clr_bal_amt,todaysSend,todaysPaid,todaysCancel,todaysEPI,todaysPOI 
	FROM vWAgentClrBal WHERE map_code = @strAgentCode
	RETURN
END



GO
