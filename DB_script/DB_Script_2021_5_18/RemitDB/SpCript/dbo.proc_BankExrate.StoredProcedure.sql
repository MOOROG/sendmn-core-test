USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_BankExrate]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_BankExrate]
(
	@flag CHAR(1) 
	,@custRate MONEY = NULL
	,@serviceCharge MONEY = NULL
	,@user VARCHAR(50) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
    IF @flag = 's'
	BEGIN
	    SELECT serviceCharge, customerRate FROM bankTransferSettings
	END
	ELSE IF @flag = 'u'
	BEGIN
		UPDATE dbo.bankTransferSettings SET serviceCharge = @serviceCharge, customerRate = @custRate

		EXEC dbo.proc_errorHandler '0', 'Record updated successfully!', NULL
		
	END
END
GO
