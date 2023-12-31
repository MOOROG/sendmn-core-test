USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentCurrency]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentCurrency]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@agentCurrencyId					VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@currencyId                        INT				= NULL
	,@spFlag                            CHAR(1)			= NULL
	,@isDefault							CHAR(1)			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


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
		 @logIdentifier = 'agentCurrencyId'
		,@logParamMain = 'agentCurrency'
		,@logParamMod = 'agentCurrencyMod'
		,@module = '20'
		,@tableAlias = 'Agent Currency Master'
		
	IF @flag = 'acl'				--Load Currency according to agent country
	BEGIN

		SELECT 
			 cm.currencyId
			,cm.currencyCode
			,am.agentCountry
			,am.agentId
		FROM countryCurrency cc WITH(NOLOCK)
		INNER JOIN countryMaster ctrM WITH(NOLOCK) ON ctrM.countryId = cc.countryId
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentCountry = ctrM.countryName
		LEFT JOIN currencyMaster cm WITH(NOLOCK) ON cm.currencyId = cc.currencyId
		WHERE
			am.agentId = 1010 AND
			ISNULL(cc.applyToAgent, 'N') = 'N' AND
			ISNULL(cm.isDeleted, 'N') <> 'Y' AND
			ISNULL(cc.isDeleted, 'N') <> 'Y'
		ORDER BY cm.currencyCode
		
		RETURN;
	END
	
	ELSE IF @flag = 'ucl'		--Load Currency according to user
	BEGIN
		/*EXEC proc_sendTransactionLoadData @flag = 'c_curr', @user = 'brijan'*/
		DECLARE @agentCountryId INT
		
		SELECT @agentId = agentId FROM applicationUsers WHERE userName = @user
		SELECT @agentCountryId = agentCountryId FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId 
			
		SELECT DISTINCT currencyId, currencyCode, currencyName FROM
		(
			SELECT 
				 currencyId = cm.currencyId
				,cm.currencyCode
				,currencyName = cm.currencyCode + ' - ' + cm.currencyName
			FROM countryCurrency cc WITH(NOLOCK)
			INNER JOIN currencyMaster cm WITH(NOLOCK) ON cc.currencyId = cm.currencyId
			WHERE countryId = @agentCountryId AND applyToAgent = 'Y' 
			UNION ALL
			SELECT
				 currencyId = cm.currencyCode
				,cm.currencyCode
				,currencyName = cm.currencyCode + ' - ' + cm.currencyName		
			FROM agentCurrency ac WITH(NOLOCK)
			INNER JOIN (
				SELECT 
					parentId
				FROM agentMaster WHERE agentId =  @agentId
			) agent ON agent.parentId = ac.agentId
			INNER JOIN currencyMaster cm WITH(NOLOCK) ON ac.currencyId = cm.currencyId 
		)x
		ORDER BY currencyCode ASC
	
	END

	ELSE IF @flag = 'i'
	BEGIN
		IF (@isDefault = 'Y' AND EXISTS(SELECT 'X' FROM agentCurrency WITH(NOLOCK) WHERE agentId = @agentId AND isDefault = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y'))
		BEGIN
			EXEC proc_errorHandler 1, 'Default Currency already been defined', @agentCurrencyId
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM agentCurrency WITH(NOLOCK) WHERE agentId = @agentId AND currencyId = @currencyId)
		BEGIN
			EXEC proc_errorHandler 1, 'Currency already been added', @agentCurrencyId
			RETURN
		END
		DECLARE @parentSPFlag CHAR(5)
		SELECT @parentSPFlag = spFlag FROM countryCurrency 
			WHERE 
				countryId = (SELECT agentCountryId FROM agentMaster WHERE agentId = @agentId) AND 
				currencyId = @currencyId
		IF(@spFlag <> @parentSPFlag AND @parentSPFlag IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'You donot have permission to set currency with this send/pay flag', @agentCurrencyId
			RETURN
		END
		BEGIN TRANSACTION
			IF(@isDefault = 'Y')
			BEGIN
				UPDATE agentMaster SET
					 localCurrency = @currencyId
				WHERE agentId = @agentId
			END
			
			INSERT INTO agentCurrency (
				 agentId
				,currencyId
				,spFlag
				,isDefault
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@currencyId
				,@spFlag
				,@isDefault
				,@user
				,GETDATE()
			SET @modType = 'Insert'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentCurrencyId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentCurrencyId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @agentCurrencyId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentCurrencyId
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM agentCurrency WITH(NOLOCK) WHERE agentCurrencyId = @agentCurrencyId
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF (@isDefault = 'Y' AND EXISTS(SELECT 'X' FROM agentCurrency WITH(NOLOCK) 
		WHERE agentId = @agentId AND isDefault = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y'))
		BEGIN
			EXEC proc_errorHandler 1, 'Default Currency already been defined', @agentCurrencyId
			RETURN
		END
		BEGIN TRANSACTION
			IF(@isDefault = 'Y')
			BEGIN
				UPDATE agentMaster SET
					 localCurrency = @currencyId
				WHERE agentId = @agentId
			END
			UPDATE agentCurrency SET
				 currencyId = @currencyId
				,spFlag = @spFlag
				,isDefault = @isDefault
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE agentCurrencyId = @agentCurrencyId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentCurrencyId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentCurrencyId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @agentCurrencyId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @agentCurrencyId
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE agentCurrency SET
				isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE agentCurrencyId = @agentCurrencyId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @agentCurrencyId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @agentCurrencyId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @agentCurrencyId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentCurrencyId
	END


	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'agentCurrencyId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.agentCurrencyId
					,main.agentId
					,main.currencyId
					,curr.currencyCode
					,curr.currencyName
					,spFlag = CASE WHEN main.spFlag = ''B'' THEN ''Both'' 
									WHEN main.spFlag = ''S'' THEN ''Send''
									WHEN main.spFlag = ''P'' THEN ''Pay'' END
					,isDefault = CASE WHEN main.isDefault = ''Y'' THEN ''Yes'' ELSE ''No'' END
					,main.createdBy
					,main.createdDate
					,main.isDeleted
				FROM agentCurrency main WITH(NOLOCK)
				   LEFT JOIN currencyMaster curr ON main.currencyId = curr.currencyId
				    LEFT JOIN staticDataValue sdv ON main.spFlag = sdv.detailTitle

			    WHERE agentId = ' + CAST(@agentId AS VARCHAR) + '
			) x'
		SET @sql_filter = ''
		SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''
		SET @select_field_list ='
			 agentCurrencyId
			,agentId
			,currencyId
			,currencyCode
			,currencyName
			,spFlag
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
     EXEC proc_errorHandler 1, @errorMessage, @agentCurrencyId
END CATCH







GO
