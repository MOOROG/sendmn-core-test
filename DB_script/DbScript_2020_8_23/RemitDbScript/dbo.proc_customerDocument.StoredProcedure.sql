USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerDocument]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[proc_customerDocument]
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
		,@MSG				VARCHAR(MAX)
	SELECT
		 @logIdentifier = 'cdId'
		,@logParamMain = 'customerDocument'
		,@logParamMod = 'customerDocumentMod'
		,@module = '20'
		,@tableAlias = ''
	
	IF @flag = 'id'
	BEGIN
		SELECT @customerId = customerId FROM customers WITH(NOLOCK) WHERE idNumber = @customerId
		SELECT TOP 1
			fileName
		FROM customerDocument
		WHERE 
		customerId = @customerId 
		--AND fileDescription = 'ID'
		ORDER BY createdDate DESC
		RETURN
	END
	IF @flag = 'idm'
	BEGIN
		SELECT 
			fileName,fileDescription,createdBy
		FROM customerDocument WITH(NOLOCK)
		WHERE 
		customerId = @customerId AND ISNULL(isDeleted,'N')<>'Y'
		ORDER BY createdDate DESC
		RETURN
	END
	
	IF @flag = 'idh'
	BEGIN
			
		SELECT TOP 1
			fileName
		FROM customerDocument
		WHERE cdId = @cdId 
		RETURN
	END
	IF @flag = 'i'
	BEGIN

		IF EXISTS (SELECT 'X' FROM customerDocument with(nolock)
			 WHERE customerId = @customerId and fileDescription = @fileDescription)
		  BEGIN
				EXEC proc_errorHandler 1, 'Document already uploaded, Please check.', @customerId
				RETURN;
		  END

		IF @isHoUser = 'Y'
		BEGIN
			SET @agentID = '1001';
			SET @branchId = '1001';
		END

		BEGIN TRANSACTION
			SELECT @fileName = REPLACE(NEWID(), '-', '_') + '.' + @fileType
			INSERT INTO customerDocument (
				 customerId
				,agentId
				,branchId
				,[fileName]
				,fileDescription
				,fileType
				,createdBy
				,createdDate
			)
			SELECT
				 @customerId
				,@agentId
				,@branchId
				,@fileName
				,@fileDescription
				,@fileType
				,@user
				,GETDATE()
			
			IF EXISTS(SELECT 'X' FROM customerMaster cm WITH(NOLOCK) WHERE customerId = @customerId AND customerStatus = 'Complain')
			BEGIN
				UPDATE customerMaster SET customerStatus ='Updated' WHERE customerId = @customerId
			END
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
		SET @string = case when @fileDescription ='IdCard' then 'ID Card' else 'Enrollment Form' end +' Uploaded Successfully.'
		EXEC proc_errorHandler 0, @string, @fileName
	END

	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM customerDocument WITH(NOLOCK) WHERE cdId = @cdId
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (SELECT 'X' FROM customerDocument WITH(NOLOCK)
			 WHERE customerId = @customerId 
			 AND fileDescription = @fileDescription)
		  BEGIN
				SET @MSG = @fileDescription+' has been uploaded already.'
				EXEC proc_errorHandler 1, @MSG, @customerId
				RETURN;
		  END

		  IF EXISTS (SELECT 'X' FROM customers 
			 WHERE customerId = @customerId 
			 AND approvedBy IS NOT NULL)
		  BEGIN
				EXEC proc_errorHandler 1, 'Approved Record Can not updated!', @customerId
				RETURN;
		  END

		IF @isHoUser = 'Y'
			BEGIN
				SET @agentID = '1001';
				SET @branchId = '1001';
		END
		BEGIN TRANSACTION
			UPDATE customerDocument SET
				 agentId=@agentId
				,branchId=@branchId
				,fileDescription = @fileDescription
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE cdId = @cdId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cdId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cdId, @user, @oldValue, @newValue
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

		IF EXISTS (SELECT 'X' FROM customers 
		  WHERE customerId IN (SELECT customerId FROM customerDocument WHERE cdId IN( @cdIds ) )
		  AND approvedBy IS NOT NULL
		  )
		BEGIN
				EXEC proc_errorHandler 1, 'Approved Record Can not Delete!', @customerId
				RETURN;
		END

		BEGIN TRANSACTION

			--SELECT CAST(cdId AS VARCHAR) + '.' + fileType AS [fileName] from customerDocument WHERE cdId IN (@cdIds)
			SET @sql='SELECT fileName FROM customerDocument WHERE cdId IN (' + @cdIds + ')'
			EXEC(@sql)

			SET @sql='DELETE FROM customerDocument where cdId in (' + @cdIds + ')'
			EXEC(@sql)

			SET @modType = 'Delete'

			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @cdId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @cdId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					RETURN
			END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
	END

	ELSE IF @flag = 's'
	BEGIN
		SELECT 
			 cdId
			,customerId
			,[fileName]
			,fileDescription = CASE WHEN fileDescription ='IdCard' THEN 'ID Card -1' WHEN fileDescription ='IdCard_2' THEN 'ID Card -2' WHEN fileDescription ='Photo' THEN 'Photo' ELSE ISNULL(fileDescription,'Enrollment Form') END
			,fileType
			,createdBy
			,createdDate
			,isDeleted
		FROM customerDocument WITH(NOLOCK)
		WHERE customerId = @customerId
		AND isKycDoc IS null
	END

	ELSE IF @flag='idImgDelete'
	BEGIN
		UPDATE customerDocument SET isDeleted='Y' 
		WHERE fileName = @fileName AND customerId = @customerId
		
		EXEC proc_errorHandler 0, 'Image Deleted Successfully', @customerId
		RETURN;
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
