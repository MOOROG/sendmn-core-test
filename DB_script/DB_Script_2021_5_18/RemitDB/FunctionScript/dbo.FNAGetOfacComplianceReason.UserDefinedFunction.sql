USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetOfacComplianceReason]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetOfacComplianceReason](@tranId BIGINT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @remarks VARCHAR(MAX)
	DECLARE @remarkTable TABLE(remarks VARCHAR(MAX))
	INSERT INTO @remarkTable(remarks)
	SELECT DISTINCT 'OFAC' FROM dbo.remitTranOfac WITH(NOLOCK)
	WHERE approvedBy IS NULL AND tranId = @tranId
	
	UNION ALL
	
	SELECT DISTINCT 'Compliance' FROM dbo.remitTranCompliance  WITH(NOLOCK)
	WHERE approvedBy IS NULL AND tranId = @tranId
	
	SELECT @remarks = COALESCE(ISNULL(@remarks + '/', ''), '') + ISNULL(remarks, '')
	FROM @remarkTable
	
	RETURN @remarks
END

GO
