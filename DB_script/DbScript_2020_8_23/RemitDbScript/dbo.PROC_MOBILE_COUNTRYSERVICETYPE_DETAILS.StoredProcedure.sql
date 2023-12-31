USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MOBILE_COUNTRYSERVICETYPE_DETAILS]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC PROC_MOBILE_COUNTRYSERVICETYPE_DETAILS @flag='ss'

CREATE PROC [dbo].[PROC_MOBILE_COUNTRYSERVICETYPE_DETAILS]
(
	@flag				VARCHAR(20)
)
AS 
 SET NOCOUNT ON


 IF @flag='cs'
 BEGIN
 SELECT  distinct
			cm.countryId AS countryId	
			,cm.countryName AS countryName		
						
		FROM dbo.countryReceivingMode(NOLOCK) AS CRM
		INNER JOIN dbo.serviceTypeMaster(NOLOCK) AS STM ON CRM.receivingMode = STM.serviceTypeId
		INNER JOIN dbo.countryMaster (NOLOCK) cm  ON cm.countryId=crm.countryId
		WHERE STM.isActive = 'Y'  

SELECT 
			cm.countryId AS countryId	
			,stm.typeTitle						
		FROM dbo.countryReceivingMode(NOLOCK) AS CRM
		INNER JOIN dbo.serviceTypeMaster(NOLOCK) AS STM ON CRM.receivingMode = STM.serviceTypeId
		INNER JOIN dbo.countryMaster (NOLOCK) cm  ON cm.countryId=crm.countryId
		WHERE STM.isActive = 'Y' 
	RETURN 
 END
 IF @flag='ss'
 BEGIN
	SELECT cm.countryId,cm.countryName,countryCode, *
	FROM dbo.countryMaster cm(NOLOCK)
	WHERE cm.isOperativeCountry='Y' AND cm.countryName <> 'Mongolia'
	AND CM.operationType IN ('B', 'R')
	ORDER BY cm.countryName			

	SELECT c.countryId,c.receivingMode AS payoutmethodId,m.typeTitle AS payoutName,m.typeTitle AS bussinessDescription,
	PayCurrency = dbo.GetAllowCurrency(c.countryId,c.receivingMode,null) 
	FROM countryReceivingMode c(nolock)
	INNER join serviceTypeMaster m(nolock) on m.serviceTypeId = c.receivingMode
	LEFT JOIN dbo.countryMaster (NOLOCK) cm ON cm.countryId=c.countryId AND cm.operationType='Y'AND cm.countryName <> 'Mongolia'
	AND CM.isOperativeCountry = 'Y'
	ORDER by payoutmethodId 

	SELECT '0' errorCode, 'Success' Msg ,NULL ID
	
 END
GO
