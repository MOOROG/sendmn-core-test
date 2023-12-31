USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_dropDownList]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_online_dropDownList]  
 @Flag			 VARCHAR(50),
 @user			 VARCHAR(40) = NULL,
 @Extra			 VARCHAR(50)    = NULL,
 @customerId     INT            = NULL ,
 @countryId		 INT =			NULL,
 @provinceId		 INT =			NULL,
 @zipCode NVARCHAR(25)=NULL,
 @parentId INT =NULL
AS  
SET NOCOUNT ON;

IF @Flag ='onlineCountrylist'  
BEGIN  
	SELECT countryId, countryName   
	FROM countryMaster WITH (NOLOCK)   
	WHERE ISNULL(allowOnlineCustomer,'N') = 'Y'
	AND countryName = 'Mongolia'
END  

ELSE IF @Flag ='allCountrylist'  
BEGIN
	SELECT '' countryId,'SELECT NATIVECOUNTRY..' countryName
	UNION ALL
	select countryId,countryName = UPPER(countryName)
	FROM dbo.countryMaster (nolock) 
END  

ELSE IF @Flag ='allCountrylistWithCode'  
BEGIN
	select countryId,
	countryName = UPPER(countryName)+'('+countryCode+')'
	FROM dbo.countryMaster (nolock) 
	order by ISNULL(isOperativeCountry,'N') DESC,countryName
END  

ELSE IF @flag='occupationList'  
BEGIN  
   SELECT valueId,detailTitle 
  FROM staticdatavalue WITH (NOLOCK)
  WHERE typeid=2000  AND ISNULL(ISActive,'Y')='Y'
  AND ISNULL(IS_DELETE,'N')='N'
  ORDER BY detailTitle
END

ELSE IF @flag='countryStates'  
BEGIN  
  SELECT stateId as valueId,stateName as detailTitle 
  FROM countryStateMaster WITH (NOLOCK)
  WHERE countryId=@Extra  AND ISNULL(isDeleted,'N')<>'Y'
END

ELSE IF @flag='RecieverList'  
BEGIN  
  SELECT receiverid, firstName+isnull(' '+ middleName,' ')+isnull(' '+lastName1,'') +isnull(' ' +lastName2,'') [receiverName]  
  from receiverInformation 
  where customerId=@customerId  
  AND country = @Extra
END

ELSE IF @flag='OccupationList'  
BEGIN  
  SELECT valueId,detailTitle  from staticdatavalue where typeid=2000  AND ISNULL(ISActive,'Y')='Y'
END

ELSE IF @flag='GenderList'  
BEGIN  
  SELECT valueId,detailTitle  from staticdatavalue where typeid=4  AND ISNULL(ISActive,'Y')='Y'
END

ELSE IF @flag='IdType'  
BEGIN  
  SELECT valueId,detailTitle  from staticdatavalue where typeid = 1300 AND valueId IN (8008,10997)  AND ISNULL(ISActive,'Y')='Y' 
END
ELSE IF @flag='IdTypeWithDetails'  
BEGIN  
	SELECT 
		 valueId		= CAST(SV.valueId AS VARCHAR)+'|'+SV.detailDesc + '|' + ISNULL(CID.expiryType, 'E')
		,detailTitle	= SV.detailTitle
	FROM countryIdType CID WITH(NOLOCK)
	INNER JOIN staticDataValue SV WITH(NOLOCK) ON CID.IdTypeId = SV.valueId
	WHERE countryId = @countryId 
	AND ISNULL(isDeleted,'N') <> 'Y'
    AND (spFlag IS NULL OR ISNULL(spFlag, 0) = 5200)
	and valueId !='11079'
END
ELSE IF @flag='city'  
BEGIN
	
	SELECT c.ROW_ID AS id, CITY_NAME=C.CITY_NAME
	FROM TBL_PROVINCE_LIST P(NOLOCK)
	INNER JOIN TBL_CITY_LIST C(NOLOCK) ON C.PROVINCE_ID = P.ROW_ID
	WHERE c.IS_ACTIVE = '1' AND c.PROVINCE_ID =@provinceId-- ISNULL(@provinceId,1)

END

--GET ALL Customer TYPE FOR Dropdown
ELSE IF @Flag='dropdownList'
BEGIN
    SELECT valueId,detailTitle  from staticdatavalue(NOLOCK) where typeid=@parentId  AND ISNULL(ISActive,'Y')='Y'
END

ELSE IF @Flag='kycStatusByAgent'
BEGIN
    SELECT valueId,detailTitle  from staticdatavalue(NOLOCK) where typeid=@parentId AND valueId!= 11050 AND ISNULL(ISActive,'Y')='Y'
END

--- Get Dropdown for Grid 
ELSE IF @Flag='dropdownGridList'
BEGIN
	SELECT NULL [value],'ALL' [text] UNION ALL
    SELECT valueId [value],detailTitle [text]  from staticdatavalue(NOLOCK) where typeid=@parentId  AND ISNULL(ISActive,'Y')='Y'
END

--GET ALL State FOR Dropdown
ELSE IF @Flag='state'
BEGIN
 --   SELECT DISTINCT stateId ,stateName = stateName + ' - ' + TJ.STATE_JAPANESE 
	--from dbo.countryStateMaster cs(NOLOCK)
	--INNER JOIN tbl_japan_address_detail TJ(NOLOCK) ON TJ.STATE_ID = CS.STATEID 
	--where countryId=@countryId 
	--AND ISNULL(isDeleted,'N')='N'

	SELECT DISTINCT stateId ,stateName = stateName  
	from dbo.countryStateMaster cs(NOLOCK)
	where countryId=@countryId 
	AND ISNULL(isDeleted,'N')='N'
END
--GET ALL receiver list, sender wise
ELSE IF @Flag='receiver-list'
BEGIN
    SELECT firstName + ISNULL(' '+middleName, '') + ISNULL(' '+lastName1, '') fullName , receiverId  
	from dbo.receiverInformation(NOLOCK) 
	WHERE customerId = @customerId
	AND ISNULL(isDeleted,'N')='N'
	--AND ISNULL(ISDELETED,0) <> 1
	--where countryId=@countryId 
	--AND stateCode=@zipCode  
	--AND ISNULL(isDeleted,'N')='N'
END
ELSE IF @Flag='bank-list'
BEGIN
	SELECT BankName, rowId
	FROM KOREANBANKLIST (NOLOCK) 
	WHERE IsActive = 1
END
ELSE IF @Flag='ofacSource'
BEGIN
	SELECT detailTitle [valueId] ,detailTitle from staticDataValue where typeid = 7020
END

ELSE IF @Flag='province'
BEGIN

SELECT ROW_ID AS id, PROVINCE_NAME=P.PROVINCE_NAME FROM TBL_PROVINCE_LIST P(NOLOCK)
WHERE P.IS_ACTIVE = 1 and countryId = ISNULL(@countryId,'142')  

END
ELSE IF @Flag='bank'
BEGIN

SELECT bl.rowId AS id, BankName=bl.BankName FROM vwBankLists bl(NOLOCK)
WHERE bl.IsActive = 1  

END





GO
