USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnCountAgent]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_txnCountAgent] @agentId INT
AS
SET NOCOUNT ON;
BEGIN
	DECLARE @date DATE = GETDATE()
	DECLARE @iSend INT, @iPaid INT = 0, @iUnpaid INT, @iCancel INT, @pCountry VARCHAR(25), @parentId INT
	
	SELECT @pCountry = agentCountry, @parentId = parentId FROM dbo.agentMaster WHERE agentId = @agentId

	SELECT @iPaid = COUNT(tranStatus) 
	FROM dbo.remitTran WITH(NOLOCK)
	WHERE paidDate BETWEEN @date AND GETDATE() AND (tranType = 'I' OR tranType = 'O')  AND pCountry = @pCountry
	AND PAGENT IN (@agentId, @parentId)

    SELECT @iSend = COUNT('A') 
	FROM dbo.remitTran 
	WHERE approvedDate BETWEEN @date AND GETDATE()
	AND sAgent IN (@agentId, @parentId) AND ( tranType = 'I' OR tranType = 'O' )
	
	SELECT @iUnpaid = COUNT('A') 
	FROM dbo.remitTran 
	WHERE paidDate BETWEEN @date AND GETDATE()
	AND pCountry = @pCountry AND ( tranType = 'I' OR tranType = 'O' ) AND tranStatus = 'Payment' AND payStatus = 'Unpaid'

	SELECT @iCancel = COUNT('A') 
	FROM dbo.remitTran 
	WHERE cancelApprovedDate BETWEEN @date AND GETDATE()
	AND sAgent IN (@agentId, @parentId) AND (tranType = 'I' OR tranType = 'O')
	
	SELECT @iSend iSend, @iPaid iPaid, @iUnpaid iUnpaid, @iCancel iCancel
END





GO
