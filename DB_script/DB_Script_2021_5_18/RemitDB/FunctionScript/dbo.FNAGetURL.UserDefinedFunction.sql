USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetURL]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetURL]()  
RETURNS varchar(100) AS  
BEGIN 
	DECLARE  @URL varchar(100)

	--SET @URL='/'
	SET @URL='/'
	RETURN (@URL)
end

GO
