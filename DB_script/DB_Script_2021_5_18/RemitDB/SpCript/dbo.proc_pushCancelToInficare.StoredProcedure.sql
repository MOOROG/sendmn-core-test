USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_pushCancelToInficare]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_pushCancelToInficare]

AS

DECLARE @SQL VARCHAR(MAX)

SET @SQL = ''

IF EXISTS(SELECT TOP 1 'X' FROM domesticCancelQueueList WITH(NOLOCK))
BEGIN
	SELECT TOP 50
	@SQL = COALESCE(@SQL + ' EXEC sp_pushCancel ', '') + '''' + ISNULL(controlNo, '') + '''' FROM domesticCancelQueueList WITH(NOLOCK)

	PRINT @SQL
	EXEC (@SQL)

	DELETE FROM domesticCancelQueueList
	FROM domesticCancelQueueList ql
	INNER JOIN hremit.dbo.cancelmoneySend cms ON ql.controlNoInficareEnc = cms.refno
END

GO
