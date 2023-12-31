USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnDocumentUpload]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[proc_txnDocumentUpload]
	 @flag                  VARCHAR(20)
	 ,@user					VARCHAR(50)     = NULL
	 ,@rowId				BIGINT			= NULL
	 ,@fileDescription		VARCHAR(100)	= NULL
	 ,@fileType				VARCHAR(100)	= NULL
	 ,@createdBy			VARCHAR(100)	= NULL	 

AS 
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
 IF @flag='displayDoc'
  BEGIN
	  SELECT 
		rowid
		,tdId	
		,fileName = fileDescription
		,createdBy
		,createdDate 
		FROM txnDocumentUpload WITH(NOLOCK) WHERE tdId=@rowId
		AND  ISNULL(isDeleted,'N')<>'Y'
 END
 ELSE IF @flag = 'deleteDoc'
	BEGIN
		SELECT 
			@rowId =  rowid
			FROM txnDocumentUpload WITH(NOLOCK) WHERE rowid = @rowId	
		
		UPDATE txnDocumentUpload SET isDeleted='Y' WHERE rowid = @rowId

		SELECT '0' errorCode,'Document Delete Successfully' msg,@rowId	
		RETURN;
	END
 ELSE IF @flag = 'file-type'
	BEGIN		
		SELECT
		  VALUE
		 ,TEXTVALUE
		  FROM 
			(
				SELECT 'VOUCHER' value,'VOUCHER' TEXTVALUE UNION ALL			
				SELECT 'ID CARD' value,'ID CARD' textVaue 
			)X
			WHERE VALUE NOT IN (SELECT ISNULL(fileDescription,'') FROM txnDocumentUpload 
			WITH(NOLOCK) WHERE tdId = @rowId AND ISNULL(isDeleted,'N') = 'N')		
		
	END	
 ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM txnDocumentUpload WITH(NOLOCK) WHERE rowId = @rowId 
	END

 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
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
	SELECT
		 @logIdentifier = 'rowId'
		,@logParamMain = 'TXNDocument'
		,@logParamMod = 'TXNDocumentMod'
		,@module = '20'
		,@tableAlias = ''		

 IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
		   DECLARE @fileName VARCHAR(250)
		      SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType
			INSERT INTO txnDocumentUpload 
				(
				    tdId				
					,[fileName]
					,fileDescription
					,fileType
					,createdBy
					,createdDate
				  )
				  SELECT
				   @rowId		
					,@fileName
					,@fileDescription
					,@fileType
					,@user
					,GETDATE()
			
			SET @rowId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @rowId, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION 

				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'File Uploaded Successfully', @fileName
  END


 IF @flag='image-display'
		BEGIN
			SELECT 
				[fileName] = fileName
				,fileDescription
				FROM txnDocumentUpload a WITH(NOLOCK)
				WHERE tdid=@rowId AND isDeleted IS NULL			
		END		
END	



GO
