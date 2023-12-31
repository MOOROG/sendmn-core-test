USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCustomerACBal]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetCustomerACBal](@user VARCHAR(150))
RETURNS MONEY
AS  
BEGIN
	DECLARE @BALANCE MONEY,@walletNo varchar(20),@BALANCEAC MONEY
	
	SELECT @BALANCE = cm.availableBalance,@walletNo = walletAccountNo
	FROM dbo.customerMaster cm WITH(NOLOCK) 
	WHERE cm.email = @user
	
	SELECT @BALANCEAC = sum(case when part_tran_type='dr' then tran_amt*-1 else tran_amt end) 
	FROM SendMnPro_Account.dbo.tran_master t(nolock) where acc_num = @walletNo
	
	IF @BALANCEAC < 0 
		SET @BALANCE = 0
	
	SET @BALANCE = CASE WHEN ISNULL(@BALANCE,0) < 0 THEN 0 ELSE @BALANCE END

	
	RETURN ISNULL(@BALANCE,0)
END

GO
