USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FNALastCharInDomTxn]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNALastCharInDomTxn]()
RETURNS CHAR(1)
BEGIN
 RETURN 'B'
END
GO
