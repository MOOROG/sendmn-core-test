USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_unlockTxnSchedule]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_unlockTxnSchedule]

AS

SET NOCOUNT ON

UPDATE remitTran SET tranStatus = 'Payment' WHERE tranStatus = 'Lock' AND DATEDIFF(MI, lockedDate, GETDATE()) >= 5


GO
