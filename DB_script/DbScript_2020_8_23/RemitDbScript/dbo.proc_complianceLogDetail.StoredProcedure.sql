USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_complianceLogDetail]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_complianceLogDetail]
	@flag			VARCHAR(10)
	,@user			VARCHAR(50)
	,@rowId			BIGINT

AS
SET NOCOUNT ON;
BEGIN
    IF @flag = 's'
	BEGIN
		SELECT senderName, senderCountry, senderIdType, senderIdNumber, senderMobile, receiverName, receiverCountry, payOutAmt,
				complianceId, complianceReason, maxAmt = cs.amount, [message] = complainceDetailMessage
				FROM ComplianceLog cl (NOLOCK)
				INNER JOIN dbo.csDetail cs (NOLOCK) ON cs.csDetailId = cl.complianceId 
				WHERE id = @rowId
	END
END

GO
