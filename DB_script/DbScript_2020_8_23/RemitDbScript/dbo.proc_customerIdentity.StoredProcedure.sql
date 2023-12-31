USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerIdentity]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_customerIdentity]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@cIdentityId                       VARCHAR(30)		= NULL
	,@idType                            INT				= NULL
	,@idNumber                          VARCHAR(50)		= NULL
	,@customerId                        INT				= NULL
	,@issueCountry						INT				= NULL
	,@placeOfIssue                      VARCHAR(50)		= NULL
	,@issuedDate                        DATETIME		= NULL
	,@validDate                         DATETIME		= NULL
	,@expiryType						CHAR(1)			= NULL
	,@isPrimary							CHAR(1)			= NULL
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
		 @logIdentifier = 'cIdentityId'
		,@logParamMain = 'customerIdentity'
		,@logParamMod = 'customerIdentityMod'
		,@module = '20'
		,@tableAlias = 'Customer Identity'


	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM customerIdentity WITH(NOLOCK) 
					WHERE customerId = @customerId AND idType = @idType AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Identity Type already exists', @customerId
			RETURN
		END
		IF (EXISTS(SELECT 'X' FROM customerIdentity WITH(NOLOCK) 
					WHERE customerId = @customerId AND isPrimary = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y') AND @isPrimary = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Primary Identity Already Exists', @customerId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO customerIdentity (
				 idType
				,idNumber
				,customerId
				,issueCountry
				,placeOfIssue
				,issuedDate
				,validDate
				,expiryType
				,isPrimary
				,createdBy
				,createdDate
			)
			SELECT
				 @idType
				,@idNumber
				,@customerId
				,@issueCountry
				,@placeOfIssue
				,@issuedDate
				,@validDate
				,@expiryType
				,@isPrimary
				,@user
				,GETDATE()
			
			SET @cIdentityId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cIdentityId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cIdentityId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @cIdentityId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @cIdentityId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
			 i.customerId
			,idNumber
			,idType
			,expiryType
			,i.issueCountry
			,i.placeOfIssue
			,isActive = ISNULL(isActive, 'N') 
			,CONVERT(VARCHAR,validDate,101)validDate1
			,CONVERT(VARCHAR,issuedDate,101)issuedDate1
			,isPrimary = ISNULL(isPrimary, 'N')
			,createdBy = c.createdBy
			,approvedBy = c.approvedBy

		FROM customerIdentity i WITH(NOLOCK) 
			JOIN customers c WITH(NOLOCK) ON i.customerId = c.customerId
		WHERE cIdentityId = @cIdentityId

	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'X' FROM customerIdentity WITH(NOLOCK) 
					WHERE cIdentityId <> @cIdentityId AND customerId = @customerId AND idType = @idType AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Identity Type already exists', @customerId
			RETURN
		END
		IF (EXISTS(SELECT 'X' FROM customerIdentity WITH(NOLOCK) 
					WHERE cIdentityId <> @cIdentityId AND customerId = @customerId AND isPrimary = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y') AND @isPrimary = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Primary Identity Already Exists', @customerId
			RETURN
		END
		
		BEGIN TRANSACTION

			UPDATE customerIdentity SET
				 idType = @idType
				,idNumber = @idNumber
				,customerId = @customerId
				,issueCountry = @issueCountry
				,placeOfIssue = @placeOfIssue
				,issuedDate = @issuedDate
				,validDate = @validDate
				,expiryType = @expiryType
				,isPrimary = @isPrimary
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE cIdentityId = @cIdentityId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @cIdentityId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @cIdentityId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @cIdentityId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @cIdentityId
	END
	ELSE IF @flag = 'd'
	BEGIN

		IF NOT EXISTS (SELECT 'x' FROM customers WHERE customerId = @customerId 
				 and approvedBy is null)
		BEGIN
				EXEC proc_errorHandler 1, 'Approved Record Can not Delete!', @customerId
				RETURN
		END

		BEGIN TRANSACTION


			UPDATE customerIdentity SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE cIdentityId = @cIdentityId


			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @cIdentityId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @cIdentityId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @cIdentityId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @cIdentityId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'cIdentityId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT 
					 ci.cIdentityId
					,ci.idNumber 
					,placeOfIssue = CASE WHEN ci.isPrimary = ''Y'' THEN ''<b>'' + ci.placeOfIssue + ''</b>'' ELSE ci.placeOfIssue END 
					,validDate = CASE WHEN ci.isPrimary = ''Y'' THEN ''<b>'' + CONVERT(VARCHAR,ci.validDate,101) + ''</b>'' ELSE CONVERT(VARCHAR,ci.validDate,101) END 
					,issuedDate = CASE WHEN ci.isPrimary = ''Y'' THEN ''<b>'' + CONVERT(VARCHAR,ci.issuedDate,101) + ''</b>'' ELSE CONVERT(VARCHAR,ci.issuedDate,101) END 
					,detailTitle = CASE WHEN ci.isPrimary = ''Y'' THEN ''<b>'' + sdv.detailTitle + ''</b>'' + ''<img src="../../../../Images/primary.png" title="Primary Id" />'' ELSE sdv.detailTitle END 
					,ci.isDeleted
					,expiryType = CASE WHEN expiryType = ''N'' THEN ''Never expires'' ELSE ''Specify'' END 
				FROM customerIdentity ci 
				LEFT JOIN staticDataValue sdv ON ci.idType = sdv.valueId
				WHERE ci.customerId = ' + CAST(@customerId AS VARCHAR) + '
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		
		IF @idNumber IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND idNumber = ' + CAST(@idNumber AS VARCHAR(50))
			
		SET @select_field_list ='
			 cIdentityId
			,idNumber
			,placeOfIssue
			,issuedDate
			,validDate
			,expiryType
			,detailTitle
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
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @cIdentityId
END CATCH

GO
