USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentOwnershipInf]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentOwnershipInf]
 	@flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@aoiId                              VARCHAR(30)    = NULL
	,@agentId                            INT            = NULL
	,@ownerName                          VARCHAR(50)    = NULL
	,@ssn                                VARCHAR(20)    = NULL
	,@idType                             INT            = NULL
	,@idNumber                           VARCHAR(50)    = NULL
	,@issuingCountry                     INT            = NULL
	,@expiryDate                         DATETIME       = NULL
	,@permanentAddress                   VARCHAR(100)   = NULL
	,@country                            INT            = NULL
	,@city                               VARCHAR(50)    = NULL
	,@state                              INT            = NULL
	,@zip                                VARCHAR(20)    = NULL
	,@phone                              VARCHAR(20)    = NULL
	,@fax                                VARCHAR(20)    = NULL
	,@mobile1                            VARCHAR(20)    = NULL
	,@mobile2                            VARCHAR(20)    = NULL
	,@email                              VARCHAR(50)    = NULL
	,@position                           VARCHAR(50)    = NULL
	,@shareHolding                       INT            = NULL
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
		 @logIdentifier = 'aoiId'
		,@logParamMain = 'agentOwnershipInf'
		,@logParamMod = 'agentOwnershipInfMod'
		,@module = '20'
		,@tableAlias = ''
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO agentOwnershipInf (
				 agentId
				,ownerName
				,ssn
				,idType
				,idNumber
				,issuingCountry
				,expiryDate
				,permanentAddress
				,country
				,city
				,[state]
				,zip
				,phone
				,fax
				,mobile1
				,mobile2
				,email
				,position
				,shareHolding
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@ownerName
				,@ssn
				,@idType
				,@idNumber
				,@issuingCountry
				,@expiryDate
				,@permanentAddress
				,@country
				,@city
				,@state
				,@zip
				,@phone
				,@fax
				,@mobile1
				,@mobile2
				,@email
				,@position
				,@shareHolding
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @aoiId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @aoiId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @aoiId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @aoiId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM agentOwnershipInf WITH(NOLOCK) WHERE aoiId = @aoiId AND agentId = @agentId
	END
	ELSE IF @flag = 'pullDefault'
	BEGIN
		SELECT top 1 * FROM agentOwnershipInf WITH(NOLOCK) WHERE agentId = @agentId
	END
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentOwnershipInf SET
				 agentId = @agentId
				,ownerName = @ownerName
				,ssn = @ssn
				,idType = @idType
				,idNumber = @idNumber
				,issuingCountry = @issuingCountry
				,expiryDate = @expiryDate
				,permanentAddress = @permanentAddress
				,country = @country
				,city = @city
				,[state] = @state
				,zip = @zip
				,phone = @phone
				,fax = @fax
				,mobile1 = @mobile1
				,mobile2 = @mobile2
				,email = @email
				,position = @position
				,shareHolding = @shareHolding
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE aoiId = @aoiId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @aoiId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @aoiId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @aoiId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @aoiId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentOwnershipInf SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE aoiId = @aoiId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @aoiId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @aoiId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @aoiId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @aoiId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'aoiId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					main.aoiId
					,main.agentId
					,main.ownerName
					,main.ssn
					,main.idType
					,main.idNumber
					,main.issuingCountry
					,main.expiryDate
					,main.permanentAddress
					,main.country
					,main.city
					,main.state
					,main.zip
					,main.phone
					,main.fax
					,main.mobile1
					,main.mobile2
					,main.email
					,main.position
					,main.shareHolding
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentOwnershipInf main WITH(NOLOCK)
					WHERE agentId = ' + CAST(@agentId AS VARCHAR) + ' AND 1 = 1 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 aoiId
			,agentId
			,ownerName
			,ssn
			,idType
			,idNumber
			,issuingCountry
			,expiryDate
			,permanentAddress
			,country
			,city
			,state
			,zip
			,phone
			,fax
			,mobile1
			,mobile2
			,email
			,position
			,shareHolding
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
     EXEC proc_errorHandler 1, @errorMessage, @aoiId
END CATCH



GO
