USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentContactPerson]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentContactPerson]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@acpId                             VARCHAR(30)		= NULL
	,@agentId                           INT				= NULL
	,@name                              VARCHAR(50)		= NULL
	,@country                           INT				= NULL
	,@state                             INT				= NULL
	,@city                              VARCHAR(30)		= NULL
	,@zip                               VARCHAR(10)		= NULL
	,@address                           VARCHAR(100)	= NULL
	,@phone                             VARCHAR(20)		= NULL
	,@mobile1							VARCHAR(20)		= NULL
	,@mobile2							VARCHAR(20)		= NULL
	,@fax                               VARCHAR(20)		= NULL
	,@email                             VARCHAR(50)		= NULL
	,@post                              VARCHAR(50)		= NULL
	,@contactPersonType                 INT				= NULL
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
		 @logIdentifier = 'acpId'
		,@logParamMain = 'agentContactPerson'
		,@logParamMod = 'agentContactPersonMod'
		,@module = '20'
		,@tableAlias = 'Agent Contact Person'
	IF @flag = 'i'
	BEGIN
		IF (@isPrimary = 'Y')
		BEGIN
			IF EXISTS(SELECT 'X' FROM agentContactPerson WHERE agentId = @agentId AND contactPersonType = @contactPersonType AND isPrimary = 'Y')
			BEGIN
				EXEC proc_errorHandler 1, 'Cannot insert record. Primary Contact Person has already been set', @agentId
				RETURN
			END
		END
		BEGIN TRANSACTION
			INSERT INTO agentContactPerson (
				 agentId
				,name
				,country
				,state
				,city
				,zip
				,address
				,phone
				,mobile1
				,mobile2
				,fax
				,email
				,post
				,contactPersonType
				,isPrimary
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@name
				,@country
				,@state
				,@city
				,@zip
				,@address
				,@phone
				,@mobile1
				,@mobile2
				,@fax
				,@email
				,@post
				,@contactPersonType
				,@isPrimary
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @acpId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @acpId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @acpId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @acpId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT *, isPrimary1 = ISNULL(isPrimary, 'N') FROM agentContactPerson WITH(NOLOCK) WHERE acpId = @acpId
	END
	ELSE IF @flag = 'pullDefault'
	BEGIN
		--SELECT top 1 *, isPrimary1 = ISNULL(isPrimary, 'N') FROM agentContactPerson WITH(NOLOCK) WHERE agentId = @agentId
		SELECT TOP 1 
			 city = agentCity
			,countryId = agentCountryId
			,[state] = agentState
			,[district] = agentDistrict
			,zip = agentZip
			,[address] = agentAddress
			,phone1 = agentPhone1
			,phone2 = agentPhone2
			,mobile1 = agentMobile1
			,mobile2 = agentMobile2
			,email = agentEmail1
		FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId
	END
	ELSE IF @flag = 'u'
	BEGIN
		IF (@isPrimary = 'Y')
		BEGIN
			IF EXISTS(SELECT 'X' FROM agentContactPerson WHERE acpId <> @acpId AND agentId = @agentId AND contactPersonType = @contactPersonType AND isPrimary = 'Y')
			BEGIN
				EXEC proc_errorHandler 1, 'Cannot update record. Primary Contact Person has already been set', @agentId
				RETURN
			END
		END
		BEGIN TRANSACTION
			UPDATE agentContactPerson SET
				 agentId			= @agentId
				,name				= @name
				,country			= @country
				,state				= @state
				,city				= @city
				,zip				= @zip
				,address			= @address
				,phone				= @phone
				,mobile1			= @mobile1
				,mobile2			= @mobile2
				,fax				= @fax
				,email				= @email
				,post				= @post
				,contactPersonType	= @contactPersonType
				,isPrimary			= @isPrimary
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			WHERE acpId = @acpId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @acpId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @acpId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @acpId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @acpId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentContactPerson SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE acpId = @acpId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @acpId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @acpId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @acpId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @acpId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'acpId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					main.acpId
					,main.agentId
					,name = CASE WHEN main.isPrimary = ''Y'' THEN ''<b>'' + main.name + ''</b>'' + ''<img src="../../../../Images/primary.png" title="Primary Id" />'' ELSE main.name END
					,country = cm.countryName
					,main.state
					,main.city
					,main.zip
					,main.address
					,main.phone
					,main.mobile1
					,main.mobile2
					,main.fax
					,main.email
					,main.post
					,contactPersonType = sdv.detailTitle
					,main.isPrimary
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentContactPerson main WITH(NOLOCK)
				LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.country = cm.countryId
				LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.contactPersonType = sdv.valueId
					WHERE agentId = ' + CAST(@agentId AS VARCHAR) + '
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 acpId
			,agentId
			,name
			,country
			,state
			,city
			,zip
			,address
			,phone
			,mobile1
			,mobile2
			,fax
			,email
			,post
			,contactPersonType
			,isPrimary
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
     EXEC proc_errorHandler 1, @errorMessage, @acpId
END CATCH


GO
