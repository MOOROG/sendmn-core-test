USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetTranIdType]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT DBO.FNAGetTranIdType(10000000)
*/
CREATE FUNCTION [dbo].[FNAGetTranIdType](@tranId BIGINT)  
RETURNS VARCHAR(1) AS  
BEGIN 
	DECLARE  @LEN INT,@TRAN_ID_TYPE AS VARCHAR(1)

	SET @LEN = LEN(@tranId)
	IF @LEN = 8
		SET @TRAN_ID_TYPE = 'H'
	ELSE 
		SET @TRAN_ID_TYPE = 'C'
		
	RETURN @TRAN_ID_TYPE
END

GO
