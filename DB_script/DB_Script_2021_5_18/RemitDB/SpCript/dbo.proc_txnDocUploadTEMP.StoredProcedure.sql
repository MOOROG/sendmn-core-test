USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnDocUploadTEMP]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procEDURE [dbo].[proc_txnDocUploadTEMP]
				 
		@flag				VARCHAR(1)		
		,@user				VARCHAR(50)		= NULL		
		,@batchId			VARCHAR(200)	= NULL
		,@rowId				VARCHAR(50)     = NULL			
		,@fileName			VARCHAR(200)	= NULL
		,@fileType			VARCHAR(50)		= NULL
		,@fileDescription	VARCHAR(200)	= NULL		
			
AS
SET NOCOUNT ON;
BEGIN
			
	IF @flag='i'
	BEGIN
		IF EXISTS(SELECT 'X' from txnDocUploadTEMP WHERE batchId = @batchId AND fileType = @fileType AND [fileName] = @fileName)
		BEGIN
			UPDATE txnDocUploadTEMP SET 				
				[fileName]		= @fileName
				,fileDescription = @fileDescription
			WHERE batchId = @batchId and fileType = @fileType

			EXEC proc_errorHandler 0, 'Image updated successfully.', @fileName
		END
		ELSE
		BEGIN 
			INSERT INTO txnDocUploadTEMP (
				 batchId
				,[fileName]
				,fileType
				,fileDescription
				,createdBy
				,createdDate
			)
			SELECT
				 @batchId
				,@fileName
				,@fileType
				,@fileDescription
				,@user
				,GetDATE()

			SET @rowId = SCOPE_IDENTITY()

			EXEC proc_errorHandler 0, 'Transaction document has been added successfully.', @fileName
		END
	END
	ELSE IF @flag='s'
	BEGIN
		SELECT rowId,[fileName],fileType,fileDescription,createdBy, createddate = CONVERT(varchar,createddate,103)				
			FROM txnDocUploadTEMP txn WITH(NOLOCK)
			WHERE batchId = @batchId 
			ORDER BY createdDate DESC
		RETURN
	END	
	ELSE IF @flag = 'd' 
	BEGIN
		SELECT @fileName = [fileName] FROM txnDocUploadTEMP WHERE batchId = @batchId AND rowId = @rowId
		DELETE FROM txnDocUploadTEMP WHERE batchId = @batchId AND rowId = @rowId
		EXEC proc_errorHandler 0, 'Image deleted successfully.', @fileName
	END
END






GO
