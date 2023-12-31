USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_PrintLog]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_PrintLog]
 @p1 VARCHAR(500)
,@p2 VARCHAR(500) = NULL
AS
return
DECLARE @message VARCHAR(500)
SET @message = CONVERT(VARCHAR, GETDATE(), 109) + ' << ' + @p1
RAISERROR (@message, 10, 1) WITH NOWAIT

if @p2 IS NOT NULL
BEGIN
	SET @message = CONVERT(VARCHAR, GETDATE(), 109) + ' >> ' + @p2
	RAISERROR (@message, 10, 1) WITH NOWAIT	
END


GO
