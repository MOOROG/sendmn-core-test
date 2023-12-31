USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_creditLimitReset]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_creditLimitReset]
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
	DECLARE 
		@today		DATETIME = DATEADD(DAY,7,CONVERT(VARCHAR, GETDATE(), 101)),
		@lastBgId	BIGINT

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
	DROP TABLE #temp

	SELECT cr.agentId INTO #temp
	FROM dbo.creditLimit cr WITH(NOLOCK) 
	INNER JOIN dbo.bankGuarantee bg WITH(NOLOCK) ON cr.agentId = bg.agentId
	WHERE bg.expiryDate < @today
	AND ISNULL(bg.isDeleted,'N') <>'Y'
	AND ISNULL(bg.isActive,'Y')<>'N'
	AND ISNULL(cr.limitAmt,0) > 0

	UPDATE dbo.creditLimit SET 
	limitAmt = '0',
	topUpToday = 0
	FROM creditLimit cr,
	(
		SELECT DISTINCT agentId FROM #temp
	)t WHERE cr.agentId = t.agentId
END


GO
