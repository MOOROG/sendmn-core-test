USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_transactionLogs]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_transactionLogs]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(50)	= NULL
	,@tranId			BIGINT			= NULL
	,@message			VARCHAR(MAX)	= NULL
	,@msgType			VARCHAR(20)		= NULL
	,@rowId				BIGINT			= NULL
	,@createdBy			VARCHAR(30)		= NULL
	,@createdDate		DATETIME        = NULL
	,@controlNo			VARCHAR(50)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL

AS

SET NOCOUNT ON;

    --select * from tranModifyLog
	DECLARE
		 @sql			VARCHAR(MAX)
		,@oldValue		VARCHAR(MAX)
		,@newValue		VARCHAR(MAX)
		,@module		VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table			VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType		VARCHAR(6)


IF @flag = 'i'
BEGIN
	INSERT INTO tranModifyLog (	
		 tranId
		,message
		,createdBy
		,createdDate
		,MsgType
	)
	SELECT 
		 @tranId
		,@message
		,@user
		,GETDATE()
		,@msgType
		
	SET @rowId = SCOPE_IDENTITY()

END
ELSE IF @flag IN ('s')
BEGIN


		IF @sortBy IS NULL
			SET @sortBy = 'tranId'
		IF @sortOrder IS NULL
			SET @sortOrder = ' ASC'

		SET @table = '(
				SELECT
					 dbo.FNADecryptString(RT.controlNo) controlNo
				    ,main.rowid
					,main.tranId
					,main.message
					,main.createdBy
					,main.createdDate
				
				FROM tranModifyLog main WITH(NOLOCK)
				INNER JOIN remitTran RT WITH(NOLOCK) ON main.controlNo=RT.controlNo
					WHERE 1 = 1 
					) x'
		SET @sql_filter = ''

		IF(@controlNo IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND controlNo =  (''' + @controlNo + ''')'
		
		IF(@tranId IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND tranId = ''' + CAST(@tranId AS VARCHAR) + ''''
		
		IF(@message IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND ISNULL(message, '''') LIKE ''%' + @message + '%'''
		
	    IF(@createdBy IS NOT NULL)
			SET @sql_filter = @sql_filter + ' AND createdBy = ''' + CAST(@createdBy AS VARCHAR) + ''''
		
		IF @sql_filter ='' 
		   set @sql_filter = @sql_filter + ' AND 1=2 '


		SET @select_field_list ='
			 controlNo
			,rowid
			,tranId
			,message
			,createdBy
			,createdDate '


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
