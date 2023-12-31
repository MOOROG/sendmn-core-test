USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_dropdown_remit]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[Proc_dropdown_remit]
	@flag VARCHAR(20),
	@typeId INT = NULL,
	@countryId INT = NULL ,
	@zone INT = NULL
AS
SET NOCOUNT ON;
IF @flag = 'static'
BEGIN
	IF @typeId = 5
		SET @typeId = 1700
	IF @typeId  ='1'
		select countryId valueId, countryName detailTitle from countryMaster
	ELSE IF @typeId  ='2'
		select stateId valueId,stateName detailTitle from countryStateMaster (nolock)
	ELSE IF @typeId  ='3'
		select districtCode valueId,districtName detailTitle from api_districtList(nolock)
	ELSE
		SELECT valueId,detailTitle FROM dbo.staticDataValue WHERE typeID = @typeId
END
ELSE IF @FLAG='AdminName'
BEGIN
	SELECT DISTINCT userId ,(UserName)as name FROM dbo.applicationUsers WITH(NOLOCK) ORDER BY UserName
	RETURN
END
ELSE IF @FLAG='voucherDDL'
BEGIN
	SELECT functionName 
	,value = case functionName when 'Journal Voucher' THEN 'J' when 'Contra Voucher' THEN 'C'
	WHEN 'Payment Voucher' THEN 'Y' when 'Receipt Voucher' THEN 'R' END
	FROM applicationFunctions(nolock) WHERE parentFunctionId = '20150000'
	AND functionId <> '20150040'
	RETURN 
END
ELSE IF @FLAG = 'isActive'
BEGIN
	SELECT NULL 'value','ALL' 'text' UNION ALL
	SELECT 'Y','Yes' UNION ALL
	SELECT 'N','No'
	RETURN
END
ELSE IF @FLAG = 'AGroup'
BEGIN
	SELECT  detailTitle, valueId FROM staticDataValue WHERE typeID = 4300
	RETURN
END
ELSE IF @FLAG = 'country'
BEGIN
	SELECT  countryId, countryName FROM dbo.countryMaster  WHERE ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isOperativeCountry, 'N') = 'Y' ORDER BY countryName
	RETURN
END
ELSE IF @FLAG = 'filterState'
BEGIN
	SELECT  stateId, stateName FROM dbo.countryStateMaster WHERE countryId = @countryId AND ISNULL(isDeleted, 'N') <> 'Y' ORDER BY stateName
	RETURN
END
ELSE IF @FLAG = 'filterDist'
BEGIN
	SELECT  districtId,districtName FROM dbo.zoneDistrictMap WHERE zone = @zone ORDER BY districtName
	RETURN
END
ELSE IF @FLAG='Department'
BEGIN
	select DepartmentName,RowId from SendMnPro_Account.dbo.Department(nolock)
END	
ELSE IF @FLAG='Branch'
BEGIN
	select agentId = 0,agentName ='Head Office' UNION ALL
	select agentId,agentName from agentMaster(nolock) 
	where parentId = 1008 and agentCountryId = 118
END	
ELSE IF @FLAG='Currency'
BEGIN
	select val = currencyCode,Name = currencyCode from currencyMaster(nolock) order by currencyCode
END	
ELSE IF @FLAG='SettlingAgent'
BEGIN
	
	select distinct a.agentId,a.AgentName from AgentBankMapping p(nolock) 
	inner join agentmaster a(nolock) on a.agentId = p.bankpartnerId

END	
GO
