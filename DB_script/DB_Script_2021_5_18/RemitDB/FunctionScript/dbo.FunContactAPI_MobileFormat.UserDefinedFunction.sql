USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FunContactAPI_MobileFormat]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FunContactAPI_MobileFormat] (@mobileNo as Varchar(20))  
RETURNS varchar(100) AS  
BEGIN 
declare @mobile varchar(20),@firstPrefix VARCHAR(2)
	SET @mobileNo = REPLACE(@mobileNo,'+','')
	SELECT @firstPrefix = LEFT(@mobileNo,2)
	SELECT @mobile = @firstPrefix+'-'+REPLACE(LEFT(@mobileNo,4),@firstPrefix,'')+'-'+RIGHT(@mobileNo,LEN(@mobileNo)-4)

RETURN @mobile
end

---- SELECT [dbo].FunContactAPI_MobileFormat('+82101233221')

GO
