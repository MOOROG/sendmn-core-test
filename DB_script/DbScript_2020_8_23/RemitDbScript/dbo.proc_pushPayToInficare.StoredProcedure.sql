USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_pushPayToInficare]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_pushPayToInficare]

AS

DECLARE @SQL VARCHAR(MAX)

SET @SQL = ''

IF EXISTS(SELECT TOP 1 'X' FROM domesticPayQueueList WITH(NOLOCK))
BEGIN
	SELECT TOP 100
	@SQL = COALESCE(@SQL + ' EXEC sp_pushPay ', '') + '''' + ISNULL(controlNo, '') + '''' FROM domesticPayQueueList WITH(NOLOCK)

	PRINT @SQL
	EXEC (@SQL)

	DELETE FROM domesticPayQueueList
	FROM domesticPayQueueList ql
	INNER JOIN hremit.dbo.moneySend ms ON ql.controlNoInficareEnc = ms.refno
	WHERE ms.[status] = 'Paid'
END




GO
