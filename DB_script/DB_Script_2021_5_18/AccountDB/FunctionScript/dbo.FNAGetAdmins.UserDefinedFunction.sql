USE [SendMnPro_Account]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAdmins]    Script Date: 5/18/2021 6:37:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetAdmins]()
RETURNS TABLE
AS
RETURN(
	SELECT 'test' admin,		'test user'  Name			UNION ALL
	SELECT 'admin' admin,		'admin' Name					UNION ALL
	SELECT 'exadmin',			'IME Admin'
) 
GO
