USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_GetEduPay]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_proc_GetEduPay]
	@AGENT_CODE			varchar(50),
	@USER_ID			varchar(50),
	@PASSWORD			varchar(50),
	@AGENT_SESSION_ID	varchar(50),
	@ZONE				varchar(50),
	@DISTRICT			varchar(50),
	@SEARCH_TEXT		varchar(50)

AS
SET NOCOUNT ON
SET XACT_ABORT ON

IF @USER_ID IS NULL
BEGIN
	SELECT '1001' CODE, 'USER_ID Field is Empty' MESSAGE, NULL id
	RETURN
END
IF @AGENT_CODE IS NULL
BEGIN
	SELECT '1001' CODE, 'AGENT_CODE Field is Empty' MESSAGE, NULL id
	RETURN
END
	
IF @PASSWORD IS NULL
BEGIN
	SELECT '1001' CODE, 'PASSWORD Field is Empty' MESSAGE, NULL id
	RETURN
END
	
IF @USER_ID <> 'n3p@lU$er' OR @AGENT_CODE <> '1001' OR @PASSWORD <> '36928c11f93d6b0cbf573d0e1ac350f7'
BEGIN
	SELECT '1002' CODE,'Authentication Failed' MESSAGE, NULL id
	RETURN
END


IF NOT EXISTS(
	SELECT 'x' FROM dbo.agentMaster WITH(NOLOCK)
	WHERE (agentType = 2904 OR (agentType = 2903 and actAsBranch = 'Y') )
		AND ISNULL(isDeleted,'N')='N' 
		AND ISNULL(isActive,'Y')='Y'
		AND ISNULL(agentBlock,'U')='U'
		AND parentId <>5576
		AND agentCountry = 'Nepal'
		AND ISNULL(agentRole ,'B') <> 'R'
		AND agentDistrict LIKE ISNULL(@DISTRICT, '') + '%'
		AND agentState LIKE ISNULL(@ZONE, '') + '%'
		AND (agentName LIKE ISNULL(@SEARCH_TEXT, '') + '%' OR agentAddress LIKE ISNULL(@SEARCH_TEXT, '') + '%')
) 
BEGIN
	SELECT CODE = '1',MESSAGE = 'No Record found'	
	RETURN
END

SELECT TOP 50
	CODE = '0' 
	,MESSAGE = 'Success'
	,AGENT_NAME = agentName
	,ADDRESS = agentAddress
	,CITY = agentCity
	,PHONE =  COALESCE(agentPhone1, agentPhone2, agentMobile1)
	,LAT = ''
	,LAN = ''
	,GMAP_URL = ''
	,AGENT_TYPE = CASE WHEN agentgrp = '4300' THEN 'IC' ELSE '' END
FROM dbo.agentMaster WITH(NOLOCK)
WHERE (agentType = 2904 OR (agentType = 2903 and actAsBranch = 'Y') )
	AND ISNULL(isDeleted,'N')='N' 
	AND ISNULL(isActive,'Y')='Y'
	AND ISNULL(agentBlock,'U')='U'
	AND parentId <>5576
	AND agentCountry = 'Nepal'
	AND ISNULL(agentRole ,'B') <> 'R'
	AND agentDistrict LIKE ISNULL(@DISTRICT, '') + '%'
	AND agentState LIKE ISNULL(@ZONE, '') + '%'
	AND (agentName LIKE ISNULL(@SEARCH_TEXT, '') + '%' OR agentAddress LIKE ISNULL(@SEARCH_TEXT, '') + '%')
	ORDER BY CASE WHEN agentgrp = '4300' THEN 0 ELSE 1 END,AGENT_NAME





GO
