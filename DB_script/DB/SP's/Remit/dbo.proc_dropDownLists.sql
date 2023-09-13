SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[proc_dropDownLists2]  
@flag			VARCHAR(200)  
,@param			VARCHAR(200)  = NULL  
,@searchBy		VARCHAR(50)   = NULL  
,@sCountryId	VARCHAR(20)   = NULL  
,@rCountryId	VARCHAR(20)   = NULL   
,@user			VARCHAR(30)   = NULL  
,@userType		VARCHAR(5)   = NULL  
,@agentId		VARCHAR(10)	= NULL
      
AS  
  
SET NOCOUNT ON;  
   DECLARE @KoreaAgentId VARCHAR(20), @RiaAgentId VARCHAR(20)

IF @flag = 'loadUser'       --@author:Dhan; Populate Agent according to country  
BEGIN  
	SELECT value=userId,text=userName FROM ApplicationUsers(NOLOCK) WHERE agentId = @agentId
RETURN;  
END 

IF @flag = 'idType'       --@author:Dhan; Populate Agent according to country  
BEGIN  
   SELECT detailTitle, valueId FROM staticDataValue WITH(NOLOCK) WHERE typeId = 1300  
    RETURN;  
END  
  
IF @flag = 'idTypeCountryWise'       --@author:Dhan ; Populate id type according to country  
BEGIN  
  
 IF @sCountryId IS NOT NULL AND @searchBy = 'sender'  
 begin  
  SELECT distinct valueId,detailTitle FROM countryIdType CID WITH(NOLOCK)   
  INNER JOIN staticDataValue SDV WITH(NOLOCK) ON CID.IdTypeId=SDV.valueId   
  WHERE countryId=@sCountryId AND ISNULL(CID.isDeleted,'N')='N' AND ISNULL(CID.isActive,'Y')='Y'  
  RETURN;  
 end  
   
 IF @rCountryId IS NOT NULL AND @searchBy = 'receiver'  
 begin  
  SELECT distinct valueId,detailTitle FROM countryIdType CID WITH(NOLOCK)   
  INNER JOIN staticDataValue SDV WITH(NOLOCK) ON CID.IdTypeId=SDV.valueId   
  WHERE countryId=@rCountryId  
  AND ISNULL(CID.isDeleted,'N')='N' AND ISNULL(CID.isActive,'Y')='Y'  
  RETURN;  
 end  
    
 SELECT distinct valueId,detailTitle FROM countryIdType CID WITH(NOLOCK)   
 INNER JOIN staticDataValue SDV WITH(NOLOCK) ON CID.IdTypeId=SDV.valueId   
 WHERE ISNULL(CID.isDeleted,'N')='N' AND ISNULL(CID.isActive,'Y')='Y'  
 RETURN;  
END  
  
IF @flag ='recAgent'  --@author:dhan; Populate receiving agent according to country  
BEGIN  
       SELECT  
    agentId  
   ,agentName  
  FROM agentMaster WITH(NOLOCK)  
  WHERE agentType = '2903'  
  AND agentCountryId = @param  
  AND ISNULL(isDeleted, 'N') = 'N'  
  AND ISNULL(isActive, 'N') = 'Y'  
  AND (ISNULL(agentRole,'N') = 'B' or ISNULL(agentRole,'N') = 'R')  
  ORDER BY agentName  
  RETURN;  
END  
  
IF @flag='sCountryWiseCurr'  
BEGIN  
 SELECT agentSettCurr currencyCode
 FROM agentmaster WITH(NOLOCK) WHERE agentId=@param  
END  
  
IF @flag = 'countrySend'  
BEGIN  
 SELECT  
  countryId,  
  countryName  
 FROM countryMaster   
 WHERE ISNULL(isOperativeCountry,'') = 'Y'  
 AND ISNULL(operationType,'B') IN ('B','S')   
 ORDER BY countryName ASC   
 RETURN  
END  
  
IF @flag = 'agentSend'  
BEGIN  
 SELECT  
  agentId,  
  agentName agentName  
 FROM agentMaster am WITH(NOLOCK)   
 WHERE ISNULL(am.agentrole,'B') IN ('B','S')   
 AND agentCountryId = @param  
 AND isSettlingAgent = 'Y'  
 AND ISNULL(am.isActive,'Y') ='Y'  
 AND ISNULL(am.isDeleted,'N') = 'N'  
 ORDER BY agentName ASC   
 RETURN  
END  
IF @flag = 'agentSend1'  
BEGIN  
 SELECT  
  agentId,  
  agentName  
 FROM agentMaster am WITH(NOLOCK)   
 WHERE ISNULL(am.agentrole,'B') IN ('B','S')   
 AND agentCountry = @param  
 AND isSettlingAgent = 'Y'  
 AND ISNULL(am.isActive,'Y') ='Y'  
 AND ISNULL(am.isDeleted,'N') = 'N'  
 ORDER BY agentName ASC   
 RETURN  
END  
  
IF @flag = 'countryPay'  
BEGIN  
 SELECT  
  countryId,  
  countryName  
 FROM countryMaster   
 WHERE ISNULL(isOperativeCountry,'') = 'Y'  
 AND ISNULL(operationType,'B') IN ('B','R')   
 ORDER BY countryName ASC   
 RETURN  
END  
  
IF @flag = 'agentPay'  
BEGIN  
 SELECT  
  agentId,  
  agentName agentName  
 FROM agentMaster am WITH(NOLOCK)   
 WHERE ISNULL(am.agentrole,'B') IN ('B','R')   
 AND agentCountryId = @param  
 AND isSettlingAgent = 'Y'  
 AND ISNULL(am.isActive,'Y') ='Y'  
 AND ISNULL(am.isDeleted,'N') = 'N'  
 ORDER BY agentName ASC   
 RETURN  
END  

IF @flag = 'branchMapcode'  
BEGIN 
   
 IF @userType = 'RH'  
 BEGIN  
  SELECT   
   branch.mapCodeInt agentId, branch.agentName agentName  
  FROM (  
   SELECT  
    am.mapCodeInt   
    ,am.agentName  
   FROM agentMaster am WITH(NOLOCK)  
   INNER JOIN regionalBranchAccessSetup rba ON am.agentId = rba.memberAgentId  
   WHERE rba.agentId = @param   
   AND ISNULL(rba.isDeleted, 'N') = 'N'  
   AND ISNULL(rba.isActive, 'N') = 'Y'  
     
   UNION ALL  
   SELECT mapCodeInt, agentName  
   FROM agentMaster WITH(NOLOCK) WHERE agentId = @param  
  ) branch ORDER BY agentName ASC   
  RETURN  
 END  
   
 IF @userType = 'AH'  
 BEGIN  
  SELECT DISTINCT A.mapCodeInt agentId,A.agentName   
  FROM agentMaster A WITH(NOLOCK)  
  INNER JOIN applicationUsers U WITH (NOLOCK) ON A.agentId = U.agentId  
  WHERE parentId = (SELECT parentId FROM agentMaster WITH (NOLOCK) WHERE agentId =@param )  
  RETURN  
 END  
 IF @userType = 'AB'  
 BEGIN  
  SELECT DISTINCT A.mapCodeInt agentId,A.agentName   
  FROM agentMaster A WITH(NOLOCK)  
  INNER JOIN applicationUsers U WITH (NOLOCK) ON A.agentId = U.agentId  
  WHERE parentId = (SELECT parentId FROM agentMaster WITH (NOLOCK) WHERE agentId =@param )  
  RETURN  
 END  
  
 SELECT mapCodeInt agentId, agentName  
 FROM agentMaster WITH(NOLOCK) WHERE agentId = @param  
 RETURN  
END  
  
IF @flag = 'agentNewsFeed'  
BEGIN  
 SELECT   
  agentId,  
  agentName   
  ,mapCodeInt  
 FROM agentMaster am WITH(NOLOCK)  
 WHERE ISNULL(am.isDeleted, 'N') <> 'Y'  
 AND am.agentType  = '2903'  
 AND am.agentCountryId = @param AND isActive = 'Y'  
 ORDER BY agentName ASC  
 RETURN   
END  
  
IF @flag = 'branchNewsFeed'  
BEGIN  
 SELECT   
  agentId,  
  agentName   
  ,mapCodeInt  
 FROM agentMaster am WITH(NOLOCK)  
 WHERE ISNULL(am.isDeleted, 'N') <> 'Y'  
 AND am.agentType = '2904'  
 AND am.parentId = @param AND isActive = 'Y'  
 ORDER BY agentName ASC  
 RETURN   
END  
  
IF @flag = 'agentCooperative'  
BEGIN  
 SELECT   
  agentId,  
  agentName   
  ,mapCodeInt  
 FROM agentMaster am WITH(NOLOCK)  
 WHERE agentGrp = 8026   
 AND agentType = 2903   
 --AND ISNULL(isActive,'Y') = 'Y'  
 AND ISNULL(am.isDeleted, 'N') <> 'Y'  
 AND ISNULL(agentBlock,'U') <> 'B'  
 ORDER BY agentName ASC  
 RETURN   
END  
  
IF @flag = 'branchCooperative'  
BEGIN  
 SELECT   
  agentId,  
  agentName   
  ,mapCodeInt  
 FROM agentMaster am WITH(NOLOCK)  
 WHERE ISNULL(am.isDeleted, 'N') <> 'Y'  
 AND am.agentType = '2904'  
 AND am.parentId = @param   
 --AND ISNULL(isActive,'Y') = 'Y'  
 AND ISNULL(agentBlock,'U') <> 'B'  
 ORDER BY agentName ASC  
 RETURN   
END  
IF @flag = 'custFilter'         
BEGIN  
 SELECT '' [value], 'Select' [text] UNION ALL  
 SELECT 'name' [value], 'Customer Name' [text] UNION ALL  
 SELECT 'membershipId' [value], 'Membership Id' [text] UNION ALL  
 SELECT 'mobile' [value], 'Mobile' [text]   
    RETURN;  
END  
IF @flag = 'cust-filter-1'         
BEGIN  
 SELECT '' [0], 'Select' [1] UNION ALL  
 SELECT 'name' [0], 'Customer Name' [1] UNION ALL  
 SELECT 'membershipId' [0], 'Membership Id' [1] UNION ALL  
 SELECT 'mobile' [0], 'Mobile' [1] UNION ALL  
 SELECT 'PassportNo' [0], 'Passport No.' [1] UNION ALL   
 SELECT 'NRIC' [0], 'NRIC' [1]   
    RETURN;  
END  
IF @flag = 'YNFilter'         
BEGIN  
 SELECT '' [value], 'Select' [text] UNION ALL  
 SELECT 'Y' [value], 'Yes' [text] UNION ALL  
 SELECT 'N' [value], 'No' [text]   
    RETURN;  
END  
  
IF @flag = 'recon-vou-type'         
BEGIN  
 SELECT 'sd' vouValue, 'Send Domestic' vouText UNION ALL  
 SELECT 'pd' , 'Pay Domestic' UNION ALL  
 SELECT 'pi' , 'Pay International'   
    RETURN;  
END  

IF @flag = 'provider'         
BEGIN  
	SELECT @KoreaAgentId = agentId FROM Vw_GetAgentID WHERE SearchText = 'koreaAgent'
	SELECT @RiaAgentId = agentId FROM Vw_GetAgentID WHERE SearchText = 'riaAgent'

 	SELECT '' value, 'ALL' text	 UNION ALL
	SELECT 'IME-I' value, 'Mongolia Remit' text	 UNION ALL
	SELECT @KoreaAgentId value, 'GME Korea Remit' text	 UNION ALL
	SELECT @RiaAgentId value, 'RIA Money Transfer' text	
    RETURN;  
END 
IF @flag = 'reconcile' 
BEGIN 
	SELECT @KoreaAgentId = agentId FROM dbo.Vw_GetAgentID WHERE SearchText = 'koreaAgent'

	SELECT @KoreaAgentId value, 'GME Remittance korea' text 
    RETURN;  
END 
 
IF @flag = 'recon-vou-type2'         
BEGIN  
 SELECT NULL [0],'All' [1] UNION ALL  
 SELECT 'sd', 'Send Domestic'  UNION ALL  
 SELECT 'pd' , 'Pay Domestic' UNION ALL  
 SELECT 'pi' , 'Pay International'   
    RETURN;  
END  
IF @flag = 'cust-status'         
BEGIN  
 --SELECT '' [0], 'Select' [1] UNION ALL  
 SELECT 'Complain' [0], 'Complain' [1] UNION ALL  
 SELECT 'Pending' [0], 'Pending' [1] UNION ALL  
   
 SELECT 'Updated' [0], 'Updated' [1] UNION ALL  
 SELECT 'Approved' [0], 'Approved' [1]   
    RETURN;  
END  
  
  
ELSE IF @flag = 'sCountry-LuckyDraw'  
BEGIN   
 SELECT   
  countryId  
  ,countryName  
 FROM countryMaster WITH(NOLOCK)  
 ORDER BY countryName ASC  
 RETURN  
END  

ELSE IF @flag = 'pay-bank-list'

BEGIN	

	--SELECT 

	--	 extBankId
	--	,bankName 
	--FROM dbo.externalBank WITH(NOLOCK) 
	--WHERE extBankId not in(90145)
	SELECT
		 AGENTID	= AM.agentId
		,AGENTNAME  = UPPER(AM.agentName)
		,ADDRESS	= AM.agentAddress
	FROM dbo.agentMaster AM WITH (NOLOCK)
	WHERE AM.agentType='2903' AND ISNULL(AM.IsIntl, 0) = 1 AND AM.agentCountryId = 151
	AND ISNULL(AM.isActive,'Y') = 'Y'

	RETURN;

END

ELSE IF @flag = 'FY'
BEGIN	
	SELECT FISCAL_YEAR_NEPALI FROM dbo.FiscalYear WITH(NOLOCK) 
	WHERE GETDATE() BETWEEN EN_YEAR_START_DATE AND EN_YEAR_END_DATE
	RETURN;
END

ELSE IF @flag = 'zone-regional'
BEGIN	
	SELECT TOP 20
			stateId
		,stateName 
	FROM countryStateMaster a WITH(NOLOCK) 
	inner join countryMaster b with(nolock) on a.countryId=b.countryId
	inner JOIN dbo.userZoneMapping zm WITH(nolock) ON a.stateName = zm.zoneName
	WHERE ISNULL(A.isDeleted, 'N') <> 'Y'
		AND zm.userName = @user
		AND zm.isDeleted IS null
	ORDER BY stateName
	RETURN
END
ELSE IF @flag='corpAgentGrp'
BEGIN
	SELECT 
		valueId AS [value],detailTitle AS [text]
	FROM  dbo.staticDataValue 
	WHERE typeID='4300'
	RETURN
END
ELSE IF @flag = 'agtCooperative'
BEGIN
	SELECT	
		agentId,
		agentName 
		,mapCodeInt
	FROM agentMaster am WITH(NOLOCK)
	WHERE businessType = 6204 AND agentType = 2903 
	AND ISNULL(isActive,'Y') = 'Y'
	AND ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentGrp=@param
	ORDER BY agentName ASC
	RETURN	
END
ELSE IF @flag='agtCoopByAgentGrp'
BEGIN
	
	DECLARE @agentGrp VARCHAR(30)=NULL

	SELECT @agentGrp=am.agentGrp FROM dbo.applicationUsers u WITH(NOLOCK) 
	INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON u.agentId=am.agentId WHERE u.userName=@param

	SELECT	
		agentId,
		agentName 
	FROM agentMaster am WITH(NOLOCK)
	WHERE businessType = 6204 AND agentType = 2903 
	AND ISNULL(isActive,'Y') = 'Y'
	AND ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentGrp=@agentGrp
	ORDER BY agentName ASC
	RETURN	
END
ELSE IF @flag = 'getAPIBank'
BEGIN
	SELECT	
		agentId,
		agentName 
		,mapCodeInt
	FROM agentMaster am WITH(NOLOCK)
	WHERE  agentType = 2903 
	AND agentApiType='Parent'
	AND ISNULL(isActive,'Y') = 'Y'
	AND ISNULL(am.isDeleted, 'N') <> 'Y'
END
ELSE IF @flag = 'recNationality'  
BEGIN  
 SELECT CAST(countryId AS VARCHAR) + '|' + countryCode AS countryId, countryName  
 FROM countryMaster (NOLOCK)  
 WHERE ISNULL(isActive, 'Y') = 'Y'  
 ORDER BY countryId DESC  
END

ELSE IF @flag='idIssuedCountry'
BEGIN
    SELECT CAST(countryId AS VARCHAR) + '|' + countryCode AS countryId,countryName 
	FROM dbo.countryMaster (NOLOCK)
	WHERE ISNULL(isActive,'Y')='Y'
END
GO

