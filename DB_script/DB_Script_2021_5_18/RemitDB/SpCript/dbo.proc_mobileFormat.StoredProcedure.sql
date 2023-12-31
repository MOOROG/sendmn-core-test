USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_mobileFormat]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_mobileFormat]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@mobileFormatId                     VARCHAR(30)    = NULL
	,@countryId                          INT            = NULL
	,@ISDCountryCode                     INT            = NULL
	,@mobileLen                          INT            = NULL
	,@sortBy                             VARCHAR(50)    = NULL
	,@sortOrder                          VARCHAR(5)     = NULL
	,@pageSize                           INT            = NULL
	,@pageNumber                         INT            = NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
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
		 @logIdentifier = 'mobileFormatId'
		,@logParamMain = 'mobileFormat'
		,@logParamMod = 'mobileFormatMod'
		,@module = '20'
		,@tableAlias = 'Mobile Format'
	IF @flag = 'i'
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM mobileFormat WHERE countryId = @countryId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			BEGIN TRANSACTION
				INSERT INTO mobileFormat (
					 countryId
					,ISDCountryCode
					,mobileLen
					,createdBy
					,createdDate
				)
				SELECT
					 @countryId
					,@ISDCountryCode
					,@mobileLen
					,@user
					,GETDATE()
				
				SET @mobileFormatId = SCOPE_IDENTITY()
				SET @modType = 'Insert'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mobileFormatId , @newValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mobileFormatId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to add new record.', @mobileFormatId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @mobileFormatId
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				UPDATE mobileFormat SET
					 ISDCountryCode = @ISDCountryCode
					,mobileLen = @mobileLen
					,modifiedBy = @user
					,modifiedDate = GETDATE()
				WHERE countryId = @countryId
				
				SELECT @mobileFormatId = mobileFormatId FROM mobileFormat WHERE countryId = @countryId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mobileFormatId, @newValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)			
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mobileFormatId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to update record.', @mobileFormatId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record updated successfully.', @mobileFormatId		
		END
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM mobileFormat WITH(NOLOCK) WHERE countryId = @countryId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE mobileFormat SET
				 countryId = @countryId
				,ISDCountryCode = @ISDCountryCode
				,mobileLen = @mobileLen
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE mobileFormatId = @mobileFormatId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @mobileFormatId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @mobileFormatId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @mobileFormatId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @mobileFormatId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE mobileFormat SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE mobileFormatId = @mobileFormatId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @mobileFormatId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @mobileFormatId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @mobileFormatId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @mobileFormatId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'mobileFormatId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					main.mobileFormatId
					,main.countryId
					,main.ISDCountryCode
					,main.mobileLen
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM mobileFormat main WITH(NOLOCK)
					WHERE 1 = 1 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 mobileFormatId
			,countryId
			,ISDCountryCode
			,mobileLen
			,createdBy
			,createdDate
			,isDeleted '
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
     EXEC proc_errorHandler 1, @errorMessage, @mobileFormatId
END CATCH


GO
