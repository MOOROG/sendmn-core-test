USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ErrorLogs]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_ErrorLogs](
	 @flag VARCHAR(50) = NULL
	,@ID BIGINT = NULL
	,@errorPage VARCHAR(MAX) = NULL
	,@errorMsg VARCHAR(MAX) = NULL
	,@errorDetails VARCHAR(MAX) = NULL
	,@referer VARCHAR(MAX) = NULL
	,@dcUserName VARCHAR(200) = NULL
	,@dcIdNo VARCHAR(2000) = NULL
	,@ipAddress VARCHAR(50) = NULL
	,@user VARCHAR(50) = NULL
	,@createdDate DATETIME = NULL
	,@createdBy VARCHAR(50) = NULL
	,@sortBy VARCHAR(50) = NULL
	,@sortOrder VARCHAR(5) = NULL
	,@pageSize INT = NULL
	,@pageNumber INT = NULL
)

AS
SET NOCOUNT ON
DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
IF @flag = 'i' 
BEGIN
	IF 'Maximum request length exceeded.' = @errorMsg 
		OR 'This is an invalid script resource request.' = @errorMsg
		OR 'The file /Remit/Administration/AgentCustomerSetup/UploadVoucher/BrowseDoc.aspx does not exist.' = @errorMsg
	BEGIN
		SELECT 0 ErrorCode, 'Logs Recorded' Msg, SCOPE_IDENTITY() id
		RETURN;
	END

	INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate, referer, dcUserName, dcIdNo, ipAddress ) 
	SELECT @errorPage, @errorMsg, @errorDetails, @user, GETDATE(), @referer, @dcUserName, @dcIdNo, @ipAddress
	SELECT 0 ErrorCode, 'Logs Recorded' Msg, SCOPE_IDENTITY() id
	RETURN
END
ELSE IF @flag = 'a' 
BEGIN
	SELECT errorPage, errorMsg, errorDetails, referer, dcUserName, dcIdNo, ipAddress FROM Logs (NOLOCK) WHERE id = @id
	RETURN
END

ELSE IF @flag IN ('s')
BEGIN
	IF @sortBy IS NULL
		SET @sortBy = 'id'

	IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'

	SET @table = '(
			SELECT 
				 ID
				,errorPage
				,LEFT(errorMsg, 100) errorMsg
				,errorDetails
				,createdBy
				,createdDate 
				,referer = ISNULL(referer, errorPage)
			FROM Logs WITH(NOLOCK)
			WHERE 1 = 1 
				) x'

	SET @sql_filter = ''
	
	IF @createdDate IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND createdDate BETWEEN ''' + CONVERT(VARCHAR,@createdDate,101) + ''' AND ''' + CONVERT(VARCHAR,@createdDate,101) + ' 23:59:59'''
	
	IF @ID IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND id = ' + CAST(@ID AS VARCHAR)
	
	IF @createdBy IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND createdBy = ''' + @createdBy + ''''
		
	SET @select_field_list ='
		 ID
		,errorPage
		,errorMsg
		,errorDetails
		,createdBy
		,createdDate
		,referer'

	PRINT (@sql_filter)
	PRINT(@table)
	EXEC dbo.proc_paging
		@table
		,@sql_filter
		,@select_field_list
		,@extra_field_list
		,@sortBy
		,@sortOrder
		,@pageSize
		,@pageNumber
END





GO
