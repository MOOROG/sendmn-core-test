USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_GetOtherInfo]    Script Date: 5/18/2021 5:17:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ws_proc_GetOtherInfo]
	@AGENT_CODE			VARCHAR(50),
	@USER_ID			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID	VARCHAR(50),
	@INFO_CODE			VARCHAR(50)


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

SELECT 
	CODE = '0' 
	,MESSAGE = 'Success'
	,x.*
FROM(
	SELECT 
		 TITLE = 'Introduces Customer CARD'
		,DESCRIPTION = 'Introduces Customer CARD'
		,DESCRIPTION2 = 'Introduces Customer CARD'
		
	UNION ALL
	SELECT 
		TITLE = 'Donates for general victim'
		,DESCRIPTION = 'Donates for general victim'
		,DESCRIPTION2 = 'Donates for general victim'
) x




GO
