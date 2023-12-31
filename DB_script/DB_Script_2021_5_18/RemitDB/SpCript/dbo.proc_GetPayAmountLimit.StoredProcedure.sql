USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetPayAmountLimit]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_GetPayAmountLimit]
	 @user VARCHAR(30) = NULL
	,@agentGroup VARCHAR(20) = NULL
	,@controlNo VARCHAR(20) = NULL

AS
SET NOCOUNT ON;
DECLARE @tranType VARCHAR(50)
SELECT @tranType = tranType FROM remitTran (NOLOCK) WHERE controlNo = dbo.encryptDb(@controlNo)
IF ISNULL(@tranType, 'I') = 'I'
	SELECT 200000 amt
ELSE
	SELECT 900000 amt



GO
