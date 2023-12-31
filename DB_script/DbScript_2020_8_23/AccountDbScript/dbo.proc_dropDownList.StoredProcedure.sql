ALTER  PROC [dbo].[proc_dropDownList]
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
	SELECT ID,REF_CODE FROM staticdatadetail WITH(NOLOCK) WHERE [TYPE_ID] = @typeId
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
	SELECT id refid,ref_code FROM StaticDataDetail WITH(NOLOCK) WHERE type_id = 3 ORDER BY ref_code
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
	SELECT functionId FROM SendMnPro_Remit.dbo.applicationFunctions(NOLOCK) WHERE parentFunctionId = '20260000'
	RETURN 
END
ELSE IF @FLAG='AgentMenu'
BEGIN
	SELECT functionId,functionName FROM SendMnPro_Remit.dbo.applicationFunctions (NOLOCK) WHERE parentFunctionId = '20261000'
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
	FROM SendMnPro_Remit.dbo.applicationFunctions (NOLOCK) 
		WHERE parentFunctionId = '20150000' AND functionName <> 'Allow Date change'
	RETURN 
END
ELSE IF @FLAG='logType'
BEGIN

	SELECT NULL 'value','ALL' 'Text' UNION ALL
	SELECT DISTINCT LOGTYPE as value, LOGTYPE as [text]
	FROM SendMnPro_Remit.dbo.LoginLogs WITH(NOLOCK) 
END	
ELSE IF @FLAG='currList'
BEGIN
	SELECT curr_code = currencyCode,curr_name = currencyCode 
	FROM SendMnPro_Remit.dbo.currencyMaster (NOLOCK) order by currencyCode
END	
ELSE IF @FLAG='BankList'
BEGIN
	select RowId,BankName from DealBankSetting(nolock) order by BankName
END
ELSE IF @FLAG='RPartner'
BEGIN
	SELECT rowId,nameOfPartner  FROM dbo.tblPayoutAgentAccount(nolock) 
	where nameOfPartner is not null
	order by nameOfPartner
END





GO
