USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_importLocation]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC proc_importLocation
*/

CREATE proc [dbo].[proc_importLocation]

AS
SET NOCOUNT ON

DECLARE @SPWithParams NVARCHAR(MAX)
SET @SPWithParams = 
	'
	Exec ime_plus_01.dbo.spa_SOAP_Domestic_DistrictList  ' 
	+ '''''' + 'kathmandu' + '''''' + ','
	+ '''''' + 'kathmandu' + '''''' + ','
	+ '''''' + 'kathmandu' + '''''' + ','
	+ '''''' + '1234' + '''''' + ','
	+ '''''' + 'c' + ''''''
		
PRINT(@SPWithParams)
EXEC ProcToTable @SPWithParams, '##res'

IF((SELECT TOP 1 code FROM ##res) <> 0)
BEGIN
	EXEC proc_errorHandler 1, 'Technical Error in importing data', NULL
	DROP TABLE ##res
	RETURN
END

DELETE FROM api_districtList WHERE fromAPI = 'Y'
INSERT INTO api_districtList(code, districtCode, districtName, fromAPI)
SELECT code, district_code, UPPER(district_name), 'Y' FROM ##res

EXEC proc_errorHandler 0, 'Import Successful', NULL
DROP TABLE ##res




GO
