USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetSendCommSchoolFee]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	SELECT * FROM [dbo].FNAGetSendCommSchoolFee(9, NULL, 137, 1, 10000)
*/
CREATE FUNCTION [dbo].[FNAGetSendCommSchoolFee](@sBranch INT, @rBranch INT, @pLocation INT, @tranType INT, @transferAmount MONEY)
RETURNS @list TABLE (masterId BIGINT, serviceCharge MONEY, sAgentComm MONEY, ssAgentComm MONEY, bankComm MONEY)
AS
BEGIN	
	
	INSERT INTO @list
	SELECT NULL, 100, 50, NULL, NULL
	RETURN
END
GO
