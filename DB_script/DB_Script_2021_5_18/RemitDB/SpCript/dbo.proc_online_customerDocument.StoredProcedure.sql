USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_customerDocument]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_online_customerDocument]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@isHoUser                          VARCHAR(30)		= NULL
	,@cdId                              VARCHAR(30)		= NULL
	,@cdIds								VARCHAR(MAX)	= NULL
	,@customerId                        VARCHAR(50)		= NULL
	,@agentId	                        VARCHAR(50)		= NULL
	,@branchId		                    VARCHAR(50)		= NULL
	,@fileName							VARCHAR(50)		= NULL	
	,@fileDescription                   VARCHAR(100)	= NULL
	,@fileType                          VARCHAR(10)		= NULL
	,@cusdocFolder						VARCHAR(100)	= NULL
	,@sessionId							VARCHAR(60)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)	
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
	SELECT
		 @logIdentifier = 'cdId'
		,@logParamMain = 'customerDocument'
		,@logParamMod = 'customerDocumentMod'
		,@module = '20'
		,@tableAlias = ''
	
	IF @customerId = '0'
		SET @customerId = NULL

	IF @flag = 's'
	BEGIN
		SELECT 
			 CdId
			,CustomerId
			,[FileName]
			,FileDescription
			,FileType
			,CreatedBy
			,CreatedDate
			,IsDeleted
			,IsOnlineDoc 
			,DocFolder = CASE WHEN cd.documentFolder IS NULL THEN dbo.FNAGetDocPath('df',cd.customerId,cd.sessionId,cd.createdDate)
						 ELSE cd.documentFolder
						 END
		FROM customerDocument cd WITH(NOLOCK)
		WHERE customerId = @customerId
		AND  ISNULL(isDeleted,'N')<>'Y'
	END

	IF @flag = 'i'
	BEGIN
	
		SET @agentID = '1040';
		SET @branchId = '30231';

		BEGIN TRANSACTION
			SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType
			
			INSERT INTO customerDocument (
				 customerId
				,agentId
				,branchId
				,[fileName]
				,fileDescription
				,fileType
				,sessionId
				,createdBy
				,createdDate
				,isOnlineDoc
				,documentFolder
			)
			SELECT
				 @customerId
				,@agentId
				,@branchId
				,@fileName
				,@fileDescription
				,@fileType
				,@sessionId
				,@user
				,GETDATE()
				,'Y'
				,@cusdocFolder
			
			SET @cdId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cdId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cdId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @cdId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		DECLARE @string VARCHAR(100)
		SET @string = 'File Uploaded as ' + @fileName
		EXEC proc_errorHandler 0, @string, @fileName
	END
	

	ELSE IF @flag = 'u'
	BEGIN
			SET @agentID = '1040';
			SET @branchId = '30231';

		BEGIN TRANSACTION
			UPDATE customerDocument SET
				 agentId=@agentId
				,branchId=@branchId
				,fileDescription = @fileDescription
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE cdId = @cdId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cdId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cdId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @cdId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @cdId
	END

	ELSE IF @flag = 'd'
	BEGIN
		UPDATE customerDocument set isDeleted = 'Y'
			WHERE customerId=@customerId and  [fileName]=@fileName
			
		SELECT 0 ErrorCode, 'Deleted Successfully' Msg, NULL Id
	END
		
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @cdId
END CATCH

GO
