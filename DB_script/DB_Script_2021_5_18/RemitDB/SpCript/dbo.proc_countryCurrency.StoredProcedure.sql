USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryCurrency]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_countryCurrency]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@countryCurrencyId                 VARCHAR(30)		= NULL
	,@countryId                         INT				= NULL
	,@currencyId                        INT				= NULL
    ,@countryName						VARCHAR(100)	= NULL
    ,@applyToAgent						CHAR(1)			= NULL
	,@spFlag                            CHAR(1)			= NULL
	,@isDefault							CHAR(1)			= NULL
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
		 @logIdentifier = 'countryCurrencyId'
		,@logParamMain = 'countryCurrency'
		,@logParamMod = 'countryCurrencyMod'
		,@module = '20'
		,@tableAlias = 'Country Master'
	
	--EXEC proc_countryCurrency @flag = 'l', @countryId = '133'
	IF @flag = 'l'		--Populate Currency according to Country(Include USD)
	BEGIN
		SELECT DISTINCT * FROM(
		SELECT 
			 currencyId = currencyCode
			,currencyCode = ISNULL(curr.currencyCode, '') + ISNULL(' - ' + curr.currencyName, '')
		FROM countryCurrency cc WITH(NOLOCK) 
		INNER JOIN currencyMaster curr WITH(NOLOCK) ON cc.currencyId = curr.currencyId
		WHERE ISNULL(cc.isDeleted, 'N') = 'N'
		AND cc.countryId in ( @countryId,'142')
		)x
	END
	ELSE IF @flag = 'cl'
	BEGIN
		SELECT
			 currencyId = currencyCode
			,currencyCode = currencyCode
		FROM countryCurrency cc WITH(NOLOCK)
		INNER JOIN currencyMaster curr WITH(NOLOCK) ON cc.currencyId = curr.currencyId
		WHERE ISNULL(cc.isDeleted, 'N') = 'N'
		AND cc.countryId = @countryId	
	END
	
	ELSE IF @flag = 'l2'		--Populate Currency according to Country
	BEGIN
		SELECT 
			 currencyId = currencyCode
			,currencyCode = ISNULL(curr.currencyCode, '') + ISNULL(' - ' + curr.currencyName, '')
		FROM countryCurrency cc 
		INNER JOIN currencyMaster curr ON cc.currencyId = curr.currencyId
		WHERE ISNULL(cc.isDeleted, 'N') = 'N'
		AND cc.countryId = @countryId
	END
	
	ELSE IF @flag = 'lbyname'		--Populate Currency according to Country
	BEGIN
		--EXEC proc_countryCurrency @flag = 'lbyname', @countryName = 'United Kingdom'
		SELECT 
			 currencyId = currencyCode
			,currencyCode = ISNULL(curr.currencyCode, '') + ISNULL(' - ' + curr.currencyName, '')
		FROM countryCurrency cc 
		INNER JOIN currencyMaster curr ON cc.currencyId = curr.currencyId
		WHERE ISNULL(cc.isDeleted, 'N') = 'N'
		AND cc.countryId = (SELECT TOP 1 countryId 
					   FROM countryMaster WHERE countryName=@countryName)
		ORDER BY cc.isDefault DESC, currencyId ASC

	END

	ELSE IF @flag = 'lAll'
	BEGIN
		SELECT DISTINCT
			 cc.currencyId
			,currencyCode = ISNULL(curr.currencyCode, '') + ISNULL(' - ' + curr.currencyName, '')
		FROM countryCurrency cc
		INNER JOIN currencyMaster curr ON cc.currencyId = curr.currencyId
		INNER JOIN countryMaster cm ON cc.countryId = cm.countryId AND ISNULL(cm.isOperativeCountry, 'N') = 'Y'
		WHERE ISNULL(cc.isDeleted, 'N') = 'N'
	END
	
	ELSE IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM countryCurrency WITH(NOLOCK) WHERE countryId = @countryId AND isDefault = 'Y' AND @isDefault = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Default Currency already exists. Cannot add more than one default currency', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO countryCurrency (
				 countryId
				,currencyId
				,spFlag
				,applyToAgent
				,isDefault
				,createdBy
				,createdDate
			)
			SELECT
				 @countryId
				,@currencyId
				,@spFlag
				,@applyToAgent
				,@isDefault
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryCurrencyId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryCurrencyId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @countryCurrencyId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @countryCurrencyId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT
			 countryCurrencyId 
			,countryId
			,currencyId
			,spFlag
			,isDefault = ISNULL(isDefault, 'N')
			,isActive
			,createdBy
			,createdDate
		FROM countryCurrency WITH(NOLOCK) WHERE countryCurrencyId = @countryCurrencyId
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'X' FROM countryCurrency WITH(NOLOCK) WHERE countryCurrencyId <> @countryCurrencyId AND countryId = @countryId AND isDefault = 'Y' AND @isDefault = 'Y' AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			EXEC proc_errorHandler 1, 'Default Currency already exists. Cannot add more than one default currency', NULL
			RETURN
		END
		
		BEGIN TRANSACTION
			UPDATE countryCurrency SET
				 currencyId			= @currencyId
				,spFlag				= @spFlag
				,applyToAgent		= @applyToAgent
				,isDefault			= @isDefault
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			WHERE countryCurrencyId = @countryCurrencyId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryCurrencyId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryCurrencyId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @countryCurrencyId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @countryCurrencyId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE countryCurrency SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE countryCurrencyId = @countryCurrencyId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @countryCurrencyId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @countryCurrencyId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @countryCurrencyId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @countryCurrencyId
	END

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'countryCurrencyId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.countryCurrencyId
					,main.countryId
					,main.currencyId
					,curr.currencyCode
					,curr.currencyName
					,spFlag = CASE WHEN main.spFlag = ''B'' THEN ''Both'' 
									WHEN main.spFlag = ''S'' THEN ''Send''
									WHEN main.spFlag = ''R'' THEN ''Receive'' END
					,applyToAgent = CASE WHEN main.applyToAgent = ''N'' THEN ''No'' ELSE ''Yes'' END
					,isDefault = CASE WHEN main.isDefault = ''Y'' THEN ''Yes'' ELSE ''No'' END
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM countryCurrency main WITH(NOLOCK)
				LEFT JOIN currencyMaster curr ON main.currencyId = curr.currencyId
				--LEFT JOIN staticDataValue sdv ON main.spFlag = sdv.valueId
					WHERE main.countryId = ' + CAST(@countryId AS VARCHAR) + '
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 countryCurrencyId
			,countryId
			,currencyId
			,currencyCode
			,currencyName
			,spFlag
			,applyToAgent
			,isDefault
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
     EXEC proc_errorHandler 1, @errorMessage, @countryCurrencyId
END CATCH



GO
