USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetBillNo]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetBillNo](@branchId INT,@type VARCHAR(5)) 
RETURNS VARCHAR(30)
AS
BEGIN
	DECLARE @BILLNO VARCHAR(30)
	
	SELECT @BILLNO = BRANCH_SHORT_NAME+CASE WHEN @type ='P' THEN CAST(s.buyBill AS VARCHAR) WHEN @type='S' THEN CAST(s.sellBill AS VARCHAR) END+@type 
	FROM BRANCHES B
	INNER JOIN billSetting_branch S ON B.branch_id = S.branchId
	WHERE BRANCH_ID = @branchId
	
 RETURN @BILLNO
END

GO
