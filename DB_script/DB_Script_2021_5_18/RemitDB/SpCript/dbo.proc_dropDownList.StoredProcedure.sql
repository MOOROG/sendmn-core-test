USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dropDownList]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_dropDownList]
	@FLAG		VARCHAR(20),
	@USER		VARCHAR(50) = NULL,
	@typeId		INT			= NULL,
	@BRANCH_ID	INT			= NULL,
	@CTYPE		VARCHAR(30) = NULL,
	@SEARCHVALUE VARCHAR(30)= NULL,
	@SEARCHTYPE	VARCHAR(30) = NULL
	
AS
SET NOCOUNT ON;
IF @FLAG = 'staticDdl'
BEGIN
	SELECT ID,REF_CODE FROM SendMnPro_Account.dbo.staticdatadetail WITH(NOLOCK) WHERE [TYPE_ID] = @typeId
	RETURN
END	
IF @FLAG = 'transferType'
BEGIN
	SELECT detailTitle,detailTitle FROM staticDataValue WITH(NOLOCK) where typeID=1400
	RETURN
END	
ELSE IF @FLAG = 'roleType'
BEGIN
	SELECT NULL 'value','ALL' 'text' UNION ALL
	SELECT 'H','HO/Admin' UNION ALL
	SELECT 'A','Agent'
	RETURN
END
ELSE IF @FLAG ='gender'
BEGIN
	SELECT id refid,ref_code FROM SendMnPro_Account.dbo.StaticDataDetail WITH(NOLOCK) WHERE type_id = 3 ORDER BY ref_code
	RETURN
END
----## DRILLDOWN FOR GRID
ELSE IF @FLAG = 'haschange_Grid'  --## CHECK CUSTOMER HAS APPROVED FOR GRID
BEGIN
	SELECT NULL 'value','ALL' 'Text' UNION ALL
	SELECT 'Yes','Yes' UNION ALL
	SELECT 'No','No'
	RETURN
END

ELSE IF @FLAG ='gl_group'
BEGIN
	SELECT gl_code,gl_name FROM GL_Group WITH(NOLOCK)
	RETURN
END
ELSE IF @FLAG='ledgerMove'
BEGIN
	SELECT gl_code,gl_name = CONVERT(VARCHAR,gl_code)+'|'+CONVERT(VARCHAR,gl_name) FROM GL_GROUP with (nolock) order by gl_code
	RETURN 
END
ELSE IF @FLAG = 'isActive'
BEGIN
	SELECT NULL 'value','ALL' 'text' UNION ALL
	SELECT 'Y','Yes' UNION ALL
	SELECT 'N','No'
	RETURN
END
ELSE IF @FLAG='AdminMenu'
BEGIN
	SELECT functionId FROM applicationFunctions(NOLOCK) WHERE parentFunctionId = '20260000'
	RETURN 
END
ELSE IF @FLAG='AgentMenu'
BEGIN
	SELECT functionId,functionName FROM applicationFunctions (NOLOCK) WHERE parentFunctionId = '20261000'
	RETURN 
END
ELSE IF @FLAG='voucherDDL'
BEGIN
	SELECT 
		functionName 
		,value = CASE functionName 
					WHEN 'Journal Voucher' THEN 'J' 
					WHEN 'Contra Voucher' THEN 'C'
					WHEN 'Payment Voucher' THEN 'Y' 
					WHEN 'Receipt Voucher' THEN 'R' 
				END
	FROM applicationFunctions (NOLOCK) 
		WHERE parentFunctionId = '20102000'
	RETURN 
END
ELSE IF @FLAG='logType'
BEGIN

	SELECT NULL 'value','ALL' 'Text' UNION ALL
	SELECT DISTINCT LOGTYPE as value, LOGTYPE as [text]
	FROM LoginLogs WITH(NOLOCK) 
END	
ELSE IF @FLAG='payPartner'
BEGIN
	SELECT agentId,agentName 
	FROM agentMaster (NOLOCK)
	WHERE agentId  IN (1176)
END	
ELSE IF @FLAG='banklist'
BEGIN
	SELECT value=rowId, [text]=bankName+' - '+bankCode,bankCode FROM koreanBankList(nolock) order by bankName
END	
GO
