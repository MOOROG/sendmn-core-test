USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_PUSH_TO_MONEYSEND]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PROC_PUSH_TO_MONEYSEND]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @controlNoEnc VARCHAR(20)
    DECLARE @SQL VARCHAR(MAX)
	
    SET @SQL =''

    SELECT TOP 100
     @SQL = COALESCE(ISNULL(@SQL + ' ', ''), '') + ' EXEC proc_INFICARE_sendTxn ' 
    + ''''+ ISNULL(ICN, '') +''', ''SI'''
    FROM PinQueueList with (nolock)

    --PRINT @SQL

    EXEC (@SQL)
    DELETE FROM PinQueueList WHERE ISNULL(icn, '') = ''

END

GO
