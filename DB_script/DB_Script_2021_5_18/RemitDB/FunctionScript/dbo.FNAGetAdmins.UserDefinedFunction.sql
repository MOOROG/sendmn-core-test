USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAdmins]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetAdmins]()
RETURNS TABLE
AS
RETURN(
	SELECT 'admin' admin,'HO admin' Name UNION ALL
	SELECT 'admin1', 'HO Admin' UNION ALL
	--SELECT 'swifttech', 'Swift Test User' UNION ALL
	SELECT 'atit',	'Atit Pandey' 
) 

GO
