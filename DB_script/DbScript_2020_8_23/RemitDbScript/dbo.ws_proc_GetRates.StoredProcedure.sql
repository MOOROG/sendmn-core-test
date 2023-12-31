USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_GetRates]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ws_proc_GetRates]
	@AGENT_CODE			VARCHAR(50),
	@USER_ID			VARCHAR(50),
	@PASSWORD			VARCHAR(50)

AS
SET NOCOUNT ON
SET XACT_ABORT ON

	IF @USER_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'USER_ID Field is Empty' MESSAGE,  NULL  ID
		RETURN
	END
	IF @AGENT_CODE IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT_CODE Field is Empty' MESSAGE,  NULL  ID
		RETURN
	END
	
	IF @PASSWORD IS NULL
	BEGIN
		SELECT '1001' CODE, 'PASSWORD Field is Empty' MESSAGE,  NULL  ID
		RETURN
	END
	
	IF NOT EXISTS(select 'A' from applicationUsers(nolock) where username=@USER_ID and userType ='i'
	AND agentCode = @AGENT_CODE AND pwd = @PASSWORD)
	BEGIN
		SELECT '1002' CODE,'Authentication Failed' MESSAGE,  NULL  ID
		RETURN
	END
	
EXEC proc_errorHandler 0, 'Succes' , NULL 
SELECT 
	 COUNTRY_CODE
	,COUNTRY_NAME
	,UNIT
	,Rates
FROM (
SELECT   
	  RowID = ROW_NUMBER() OVER (PARTITION BY cm.countryCode ORDER BY countryName ASC)
	 ,cm.countryCode COUNTRY_CODE 
	 ,cm.countryName COUNTRY_NAME
	 ,ex.cCurrency UNIT 
	 ,ROUND(ex.customerRate, 4) Rates
FROM exRateTreasury ex (NOLOCK)
INNER JOIN countryMaster cm (NOLOCK) ON ex.cCountry = cm.countryId 
WHERE cm.countryName in ('South Korea')
) X WHERE RowID = 1

GO
