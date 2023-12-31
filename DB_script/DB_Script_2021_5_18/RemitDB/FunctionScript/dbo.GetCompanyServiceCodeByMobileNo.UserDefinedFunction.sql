USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[GetCompanyServiceCodeByMobileNo]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[GetCompanyServiceCodeByMobileNo](@mobileNo varchar(15))
RETURNS @mobileDetail TABLE(mobileNo varchar(15),company VARCHAR(10),product VARCHAR(20),serviceCode INT)
AS
BEGIN
	DECLARE @company VARCHAR(10),@product VARCHAR(20),@serviceCode INT

	IF LEN(@mobileNo) = 10
	BEGIN
		SELECT @company = CASE	WHEN LEFT(@mobileNo,3) IN ('980','981','982') THEN 'NCELL' 
								WHEN LEFT(@mobileNo,3) IN ('984','985','986') THEN 'NTC'
								ELSE 'INVALID' END 
			,@product = CASE	WHEN LEFT(@mobileNo,3) IN ('980','981','982') THEN 'NCELL' 
								WHEN LEFT(@mobileNo,3) IN ('984','986') THEN 'Prepaid'
								WHEN LEFT(@mobileNo,3) IN ('985') THEN 'Postpaid'
								ELSE 'INVALID' END 

		SELECT @serviceCode = CASE	WHEN @product = 'Postpaid' THEN '1' 
								WHEN @product IN('Prepaid','NCELL' ) THEN '0'
								ELSE NULL END 
			,@mobileNo		= CASE WHEN @company ='NTC' THEN '977'+@mobileNo ELSE @mobileNo END
		
		
		INSERT INTO @mobileDetail
		SELECT @mobileNo,@company,@product,@serviceCode
	END
	RETURN
END
GO
