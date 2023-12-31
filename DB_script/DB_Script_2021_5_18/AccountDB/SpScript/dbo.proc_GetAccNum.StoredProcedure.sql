USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetAccNum]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_GetAccNum](@accId int)
AS
BEGIN
	DECLARE @AccNum VARCHAR(12),@prefix int,@iso varchar(5)

	SELECT @prefix = gl_code,@iso = ac_currency FROM AC_MASTER(nolock) WHERE ACCT_ID = @accId
	
	SELECT @prefix = acc_Prefix FROM gl_group(nolock) where gl_code = @prefix
	SELECT @iso = isoNumeric FROM SendMnPro_Remit.dbo.currencymaster(nolock) where currencyCode = @iso

	SELECT @AccNum = CAST(@prefix AS VARCHAR)+CAST(@iso AS VARCHAR) + CAST(right(CHECKSUM(NEWID()),5) AS VARCHAR)
	IF EXISTS(select 'a' from ac_master(nolock) where acct_num = @AccNum)
		SELECT @AccNum = CAST(@prefix AS VARCHAR)+CAST(@iso AS VARCHAR) + CAST(right(CHECKSUM(NEWID()),5) AS VARCHAR)
	
	UPDATE AC_MASTER SET acct_num = @AccNum WHERE ACCT_ID = @accId

END


GO
