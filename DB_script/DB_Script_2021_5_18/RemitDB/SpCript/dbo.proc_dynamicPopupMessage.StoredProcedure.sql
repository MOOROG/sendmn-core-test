USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dynamicPopupMessage]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dynamicPopupMessage]
	 @flag					VARCHAR(50)
	,@rowId					BIGINT		= NULL
	,@scope					VARCHAR(50)	= NULL		
	,@fileName				VARCHAR(50)	= NULL
	,@description			VARCHAR(50)	= NULL	
	,@fileType				VARCHAR(50)	= NULL	
	,@isEnable				VARCHAR(5)	= NULL
	,@fromDate				VARCHAR(50)	= NULL
	,@toDate				VARCHAR(50)	= NULL
	,@createdDate			VARCHAR(50)	= NULL      
	,@createdBy				VARCHAR(50)	= NULL
	,@modifiedDate			VARCHAR(50)	= NULL	
	,@modifiedBy			VARCHAR(50)	= NULL
	,@sortBy				VARCHAR(50)	= NULL
	,@sortOrder				VARCHAR(50)	= NULL
	,@pageSize				INT			= NULL
	,@pageNumber			INT			= NULL
	,@user					VARCHAR(50)	= NULL
	,@imageLink				VARCHAR(MAX)= NULL
AS
SET NOCOUNT ON;

DECLARE
	@table				VARCHAR(MAX)
	,@select_field_list	VARCHAR(MAX)
	,@extra_field_list	VARCHAR(MAX)
	,@sql_filter		VARCHAR(MAX)
IF @flag='s'
BEGIN		
	SELECT  
		 @sortBy='rowId'
		,@sortOrder='ASC'

	SET @table='
	(	
		SELECT 
				ROW_NUMBER() OVER (ORDER BY rowId ASC) as SNo
				,rowId				 		
				,scope				  		
				,fileDescription	
				,isEnable											
		FROM dynamicPopup dp WITH(NOLOCK) 	
		WHERE ISNULL(isDeleted,'''') <>''Y''	
			
	)x'
						
	SET @sql_filter = ''
					
	IF @scope IS NOT NULL  
		SET @sql_filter=@sql_filter + ' AND scope = ''' +@scope+''''				
	IF @description IS NOT NULL  
		SET @sql_filter=@sql_filter + ' AND fileDescription LIKE ''' +@description+'%'''		
	IF @isEnable IS NOT NULL  
		SET @sql_filter=@sql_filter + ' AND isEnable = ''' +@isEnable+''''
	SET @select_field_list = '
								rowId			
								,scope			
								,fileDescription	
								,isEnable
							'
							
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
ELSE IF @flag = 'a'
BEGIN
	SELECT 
		scope
		,fileDescription
		,imageLink
		,isEnable
		,fromDate= CONVERT(VARCHAR, fromDate, 101)
		,toDate=CONVERT(VARCHAR, toDate, 101)
		,fileName
			FROM dynamicPopup WITH (NOLOCK)
	WHERE rowId = @rowId AND ISNULL(isDeleted,'N')<>'Y'
END
ELSE IF @flag = 'sa'
BEGIN
	IF @scope='agent'
	BEGIN
		SELECT TOP 1 * FROM dynamicPopup WITH (NOLOCK)
		WHERE (isDeleted = 'N' OR isDeleted IS NULL)
			AND isEnable='Y' 
			AND GETDATE() BETWEEN fromDate AND toDate			
			AND scope IN('agent','adminAgent','agentAgentIntl','all') 
		ORDER BY rowId DESC
		RETURN
	END
	ELSE IF @scope='admin'
	BEGIN
		SELECT TOP 1 * FROM dynamicPopup WITH (NOLOCK)
		WHERE (isDeleted = 'N' OR isDeleted IS NULL)
			AND isEnable='Y' 
			AND GETDATE() BETWEEN fromDate AND toDate		
			AND	scope IN('admin','adminAgent','agentIntl','all') 
		ORDER BY rowId DESC
		RETURN
	END
	ELSE IF @scope='agentIntl'
	BEGIN
		SELECT TOP 1 * FROM dynamicPopup WITH (NOLOCK)
		WHERE (isDeleted = 'N' OR isDeleted IS NULL)
			AND isEnable='Y'
			AND GETDATE() BETWEEN fromDate AND toDate				
			AND	scope IN('agentIntl','adminAgentIntl','agentAgentIntl','all') 
		ORDER BY rowId DESC
		RETURN
	END
END
ELSE IF @flag = 'i'
BEGIN	
	SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType	
	INSERT INTO dynamicPopup (
		scope, fileName, fileDescription, fileType, isEnable, imageLink
		,fromDate, toDate, createdDate, createdBy, modifiedDate, modifiedBy
	)
	SELECT
		 @scope, @fileName, @description, @fileType, @isEnable, @imageLink
		 ,@fromDate, @toDate, GETDATE(), @user, GETDATE(), @user
	SET @rowId = SCOPE_IDENTITY()			
	EXEC proc_errorHandler 0, 'File Uploaded Successfully', @fileName
	RETURN
END
ELSE IF @flag = 'u'
BEGIN	
	IF @fileType IS NULL
	BEGIN
		SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType	
		UPDATE dynamicPopup SET
				scope	= @scope
			-- ,fileName=@fileName				
			,fileDescription=@description						
			,isEnable=@isEnable	
			,imageLink=@imageLink
			,fromDate=@fromDate 
			,toDate=@toDate 
			,modifiedDate = GETDATE()
			,modifiedBy = @user
		WHERE rowId = @rowId
		EXEC proc_errorHandler 0, 'Data Updated Successfully', @fileName
	END
	ELSE IF @fileType IS NOT NULL
		BEGIN
		SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType			 
		UPDATE dynamicPopup SET
				scope	= @scope
				,fileName=@fileName				
			,fileDescription=@description
			,fileType=@fileType
			,isEnable=@isEnable	
			,imageLink=@imageLink
			,fromDate=@fromDate
			,toDate=@toDate	
			,modifiedDate = GETDATE()
			,modifiedBy = @user									
			WHERE rowId = @rowId
			EXEC proc_errorHandler 0, 'Data Updated Successfully', @fileName				
	END 
	RETURN
END
ELSE IF @flag = 'deleteDoc'
BEGIN
	SELECT 	@rowId = rowId	FROM dynamicPopup WITH(NOLOCK) WHERE rowid = @rowId
				
	UPDATE dynamicPopup SET isDeleted='Y' WHERE rowid = @rowId

	SELECT '0' errorCode,'Document Delete Successfully' msg,@rowId	
	RETURN;
END
IF @flag='displayDoc'
BEGIN
	IF @rowId IS NULL
	BEGIN
		SELECT 
			rowid
			,scope	
			,fileName 
			,fileDescription
			,createdBy
			,createdDate 
		FROM dynamicPopup WITH(NOLOCK)
		WHERE ISNULL(isDeleted,'N')<>'Y' 				
	END
	ELSE
	BEGIN
		SELECT 
			rowid
			,scope	
			,fileName 
			,fileDescription
			,createdBy
			,createdDate 
		FROM dynamicPopup WITH(NOLOCK)
		WHERE rowId=@rowId 
			AND ISNULL(isDeleted,'N')<>'Y' 				
	END 	
END



GO
