USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentBankAccount]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentBankAccount]
 	 @flag                              VARCHAR(50)     = NULL
	,@user                              VARCHAR(30)     = NULL
	,@abaId                             VARCHAR(30)     = NULL
	,@agentId                           INT             = NULL
	,@bankName                          VARCHAR(100)    = NULL
	,@bankBranch                        VARCHAR(100)    = NULL
	,@accountNo							VARCHAR(30)		= NULL
	,@swiftCode                         VARCHAR(30)     = NULL
	,@routingNo                         VARCHAR(30)     = NULL	
	
	,@bankNameB                         VARCHAR(100)    = NULL
	,@bankBranchB                       VARCHAR(100)    = NULL
	,@accountNoB						VARCHAR(30)		= NULL
	,@swiftCodeB                        VARCHAR(30)     = NULL
	,@routingNoB                        VARCHAR(30)     = NULL	
	,@isDefault							VARCHAR(10)		= NULL
	
	,@sortBy                            VARCHAR(50)     = NULL
	,@sortOrder                         VARCHAR(5)      = NULL
	,@pageSize                          INT             = NULL
	,@pageNumber                        INT             = NULL


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
		 @logIdentifier = 'abaId'
		,@logParamMain = 'agentBankAccount'
		,@logParamMod = 'agentBankAccountMod'
		,@module = '20'
		,@tableAlias = 'Agent Bank Account'
	IF @flag = 'i'
	BEGIN
	
		--ALTER TABLE agentBankAccount ADD 
		BEGIN TRANSACTION
			INSERT INTO agentBankAccount (
				 agentId
				,bankName
				,bankBranch
				,accountNo
				,swiftCode
				,routingNo
				,bankNameB
				,bankBranchB
				,accountNoB
				,swiftCodeB
				,routingNoB
				,isDefault
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@bankName
				,@bankBranch
				,@accountNo
				,@swiftCode
				,@routingNo
				,@bankNameB
				,@bankBranchB
				,@accountNoB
				,@swiftCodeB
				,@routingNoB
				,@isDefault
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @abaId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @abaId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @abaId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @abaId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM agentBankAccount WITH(NOLOCK) WHERE abaId = @abaId
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentBankAccount SET
				 agentId = @agentId
				,bankName = @bankName
				,bankBranch = @bankBranch
				,accountNo = @accountNo
				,swiftCode = @swiftCode
				,routingNo = @routingNo
				,bankNameB = @bankNameB
				,bankBranchB = @bankBranchB
				,accountNoB = @accountNoB
				,swiftCodeB = @swiftCodeB
				,routingNoB = @routingNoB
				,isDefault =@isDefault
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE abaId = @abaId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @abaId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @abaId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @abaId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @abaId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentBankAccount SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE abaId = @abaId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @abaId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @abaId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @abaId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @abaId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'abaId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					main.abaId
					,main.agentId
					,main.bankName
					,main.bankBranch
					,main.accountNo
					,main.swiftCode
					,main.routingNo
					,main.bankNameB
					,main.bankBranchB
					,main.accountNoB
					,main.swiftCodeB
					,main.routingNoB
					,main.isDefault
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentBankAccount main WITH(NOLOCK)
					WHERE agentId = ' + CAST(@agentId AS VARCHAR) + ' 
					) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 abaId
			,agentId
			,bankName
			,bankBranch
			,accountNo
			,swiftCode
			,routingNo
			,bankNameB
			,bankBranchB
			,accountNoB
			,swiftCodeB
			,routingNoB
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
     EXEC proc_errorHandler 1, @errorMessage, @abaId
END CATCH



GO
