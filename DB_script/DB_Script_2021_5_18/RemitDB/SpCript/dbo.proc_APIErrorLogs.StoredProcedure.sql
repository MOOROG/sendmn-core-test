USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_APIErrorLogs]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_APIErrorLogs](
	 @flag				VARCHAR(50)		= NULL
	,@ID				BIGINT			= NULL
	,@methodName		VARCHAR(MAX)	= NULL
	,@errorMsg			VARCHAR(MAX)	= NULL
	,@errorDetails		VARCHAR(MAX)	= NULL
	,@ip				VARCHAR(500)	= NULL
	,@user				VARCHAR(50)		= NULL
	,@createdDate		DATETIME		= NULL
	,@createdBy			VARCHAR(50)		= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
)
AS
SET NOCOUNT ON
BEGIN TRY
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
IF @flag = 'i' BEGIN
	INSERT INTO RemittanceLogData.dbo.apiErrorLogs (methodName, errorMsg, errorDetails, createdBy, createdDate ) 
	SELECT @methodName, @errorMsg, @errorDetails, @user, GETDATE()
	SELECT 0 ErrorCode, 'Logs Recorded' Msg, SCOPE_IDENTITY() id
	RETURN
END
ELSE IF @flag = 'a' BEGIN
	SELECT methodName, errorMsg, errorDetails FROM RemittanceLogData.dbo.apiErrorLogs WHERE id = @id
	RETURN
END

ELSE IF @flag = 's'
BEGIN
	IF @sortBy IS NULL
		SET @sortBy = 'id'

	IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'

	SET @table = '(
			SELECT 
				 ID
				,methodName
				,LEFT(errorMsg, 100) errorMsg
				,errorDetails
				,createdBy
				,createdDate 
			FROM RemittanceLogData.dbo.apiErrorLogs WITH(NOLOCK)
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
		,methodName
		,errorMsg
		,errorDetails
		,createdBy
		,createdDate'

	--PRINT (@sql_filter)
	--PRINT(@table)
	EXEC dbo.proc_paging
		@table
		,@sql_filter
		,@select_field_list
		,@extra_field_list
		,@sortBy
		,@sortOrder
		,@pageSize
		,@pageNumber
		RETURN
END
END TRY
BEGIN CATCH
	SELECT 1 ErrorCode, 'Internal Error. Try again later.' Msg, SCOPE_IDENTITY() id
END CATCH


GO
