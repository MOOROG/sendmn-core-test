USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_importLocationAPI]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC proc_importLocationAPI
*/

CREATE proc [dbo].[proc_importLocationAPI]
	@user VARCHAR(10)	= NULL

AS
SET NOCOUNT ON

--DECLARE @SPWithParams NVARCHAR(MAX)
--SET @SPWithParams = 
--	'
--	Exec ime_plus_01.dbo.spa_SOAP_Domestic_DistrictList  ' 
--	+ '''''' + 'kathmandu' + '''''' + ','
--	+ '''''' + 'kathmandu' + '''''' + ','
--	+ '''''' + 'kathmandu' + '''''' + ','
--	+ '''''' + '1234' + '''''' + ','
--	+ '''''' + 'c' + ''''''
		
--PRINT(@SPWithParams)
--EXEC ProcToTable @SPWithParams, '##res'
DECLARE @code						VARCHAR(50)
		,@userName					VARCHAR(50)
		,@password					VARCHAR(50)
EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT

create table ##DistList
(
    code varchar(20),
    district_code varchar(20),
    district_name varchar(300)
)

INSERT INTO ##DistList(code,district_code,district_name)
Exec ime_plus_01.dbo.spa_SOAP_Domestic_DistrictList_V2 
@code,@userName,@password,'1234','c'


IF((SELECT TOP 1 code FROM ##DistList) <> 0)
BEGIN
	EXEC proc_errorHandler 1, 'Technical Error in importing data', NULL
	DROP TABLE ##DistList
	RETURN;
END


DELETE FROM api_districtList WHERE ISNULL(fromAPI, 'Y') = 'Y'

INSERT INTO api_districtList(code, districtCode, districtName, fromAPI, createdBy, createdDate)
SELECT code, district_code, UPPER(district_name), 'Y', @user, GETDATE() FROM ##DistList

EXEC proc_errorHandler 0, 'Import Successful', NULL
DROP TABLE ##DistList




GO
