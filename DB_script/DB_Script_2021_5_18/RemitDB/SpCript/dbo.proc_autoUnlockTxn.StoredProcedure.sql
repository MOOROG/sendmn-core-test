USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_autoUnlockTxn]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_autoUnlockTxn]
AS

SET NOCOUNT OFF;

UPDATE remitTran SET lockStatus = 'unlocked' WHERE lockStatus = 'locked' AND DATEDIFF(MI, lockedDate, GETDATE()) > = 10
AND payStatus = 'Unpaid' AND tranStatus = 'Payment'

--EXEC proc_autoUnlockTxn

GO
