USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dropDownListAML]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_dropDownListAML]
     @flag			VARCHAR(200)
    ,@param			VARCHAR(200)		= NULL
    ,@searchBy		VARCHAR(50)			= NULL
	,@country		varchar(100)		= NULL
    ,@sCountry		VARCHAR(100)		= NULL
    ,@rCountry		VARCHAR(100)		= NULL	
	,@agentId		VARCHAR(50)			= NULL
    ,@user			VARCHAR(30)			= NULL
    ,@userType		VARCHAR(5)			= NULL
    
AS

SET NOCOUNT ON;

IF @flag = 'AMLsCountry'						-->> @author:dipesh; Sending CountryName List with third party country (AML Dropdonwn)
BEGIN
	SELECT * FROM 
	(
		SELECT 
			countryId,
			countryName
		FROM countryMaster WITH(NOLOCK)
		WHERE ISNULL(isOperativeCountry,'') ='Y' 
		AND (operationType ='S' OR operationType ='B')	
		UNION ALL
		SELECT '151','Nepal' 
	)X ORDER BY countryName

	RETURN
END

IF @flag = 'AMLpCountry'						-->> @author:dipesh; Receiving CountryName List with third party country (AML Dropdonwn)
BEGIN
	SELECT countryId,countryName FROM 
	(
		SELECT 
			countryId,
			countryName
		FROM countryMaster WHERE countryId <>250  
			AND ISNULL(isOperativeCountry,'') ='Y' AND (operationType ='R' OR operationType ='B')
	)A ORDER BY countryName ASC
	RETURN
END

IF @flag = 'AMLagent'						   --@author:dipesh; Select agentName List According to CountryName
BEGIN
	SELECT	
		agentId,
		agentName 
		,mapCodeInt
	FROM agentMaster am WITH(NOLOCK)
	WHERE ISNULL(am.isDeleted, 'N') <> 'Y'
	AND am.agentType = '2903'
	AND am.agentCountry = @country 
	AND ISNULL(agentBlock,'U') <>'B'
	ORDER BY agentName ASC
	RETURN	
END

IF @flag = 'AMLr-currency' --@author:dipesh;
BEGIN
	SELECT DISTINCT 
		cm.currencyCode 
		,cm.currencyDesc
	FROM countryCurrency  cc
	INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId
	INNER JOIN countryMaster ccms on cc.countryId = ccms.countryId
	WHERE ccms.countryName = @country
	AND applyToAgent = 'Y'
	AND (spFlag = 'B' OR spFlag = 'P')  
	AND  ISNULL(cm.isDeleted , 'N')= 'N' 
	RETURN

	--SELECT * FROM countryCurrency
	--select * from countryMaster
END

IF @flag = 'AMLs-currency' --@author:dipesh;
BEGIN
	SELECT  DISTINCT 
		cm.currencyCode 
		,cm.currencyDesc
	FROM countryCurrency  cc
	INNER JOIN currencyMaster cm ON cc.currencyId = cm.currencyId
	INNER JOIN countryMaster ccms on cc.countryId = ccms.countryId
	WHERE ccms.countryName = @country
	AND applyToAgent = 'Y'
	AND (spFlag = 'B' OR spFlag = 'S')  
	AND  ISNULL(cm.isDeleted , 'N')= 'N' 
	RETURN
END

IF @flag = 'AMLrecModeByCountry'			--@author:dipesh;
BEGIN
	SELECT
		 serviceTypeId
		,typeTitle
	FROM countryReceivingMode crm WITH(NOLOCK)
	INNER JOIN serviceTypeMaster stm WITH(NOLOCK) ON crm.receivingMode = stm.serviceTypeId
	INNER JOIN countryMaster ccms on crm.countryId = ccms.countryId
	WHERE ccms.countryName = @country
END


IF @flag='AMLrMode'
BEGIN
	SELECT 			
			 stm.serviceTypeId 
			,stm.typeTitle
		FROM serviceTypeMaster stm WITH (NOLOCK) 
		WHERE ISNULL(stm.isDeleted, 'N')  <> 'Y' 
		AND ISNULL(stm.isActive, 'N') = 'Y'
END


IF @flag='IdNoFor'
BEGIN
	Select value='',[text]='Select' UNION ALL
	Select value='1302',[text]='Passport' 
	--UNION ALL
	--Select value='1304',[text]='Driving License' UNION ALL
	--Select value='6208',[text]='Valid Goverment ID' UNION ALL
	--Select value='8006',[text]='Employment Authorization'
END


GO
