USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryReceivingMode]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_countryReceivingMode]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(50)		= NULL
	,@crmId				INT				= NULL
	,@countryId			INT				= NULL
	,@receivingMode		INT				= NULL
	,@applicableFor		CHAR(1)			= NULL			--A - All, S -  Specify
	,@agentSelection	CHAR(1)			= NULL			--D - Define, U - Undefine, O - Optional
	,@receivingModes	VARCHAR(MAX)	= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL

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
		 @logIdentifier = 'crmId'
		,@logParamMain = 'countryReceivingMode'
		,@logParamMod = 'countryReceivingModeMod'
		,@module = '20'
		,@tableAlias = 'Country Receiving Mode'
		
	IF @flag IN ('i')
	BEGIN	
		BEGIN TRANSACTION
			--DELETE FROM rsList WHERE agentId = @agentId AND agentRole = @agentRole
			INSERT INTO countryReceivingMode (
				 countryId
				,receivingMode
				,applicableFor
				,agentSelection
				,createdBy
				,createdDate
			)
			SELECT
				 @countryId
				,@receivingMode
				,@applicableFor
				,@agentSelection
				,@user
				,GETDATE()
				
			SET @crmId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crmId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @crmId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @crmId
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @crmId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE countryReceivingMode SET
				 receivingMode		= @receivingMode
				,applicableFor		= @applicableFor
				,agentSelection		= @agentSelection
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			WHERE crmId = @crmId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crmId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @crmId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @crmId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @crmId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			SET @modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @crmId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @crmId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @crmId
				RETURN
			END
			
			DELETE FROM countryReceivingMode WHERE crmId = @crmId
			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @crmId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM countryReceivingMode WITH(NOLOCK) WHERE crmId = @crmId
	END
	
	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'crmId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.crmId
					,main.countryId
					,stm.serviceCode
					,receivingMode = stm.typeTitle
					,receivingModeDesc = stm.typeDesc
					,applicableFor = CASE WHEN main.applicableFor = ''A'' THEN ''All'' WHEN main.applicableFor = ''S'' THEN ''Specify'' END
					,agentSelection = CASE WHEN main.agentSelection = ''M'' THEN ''Mandatory'' 
											WHEN main.agentSelection = ''N'' THEN ''No Selection''
											WHEN main.agentSelection = ''O'' THEN ''Optional'' END
					,main.createdBy
					,main.createdDate
				FROM countryReceivingMode main WITH(NOLOCK)
				LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.receivingMode = stm.serviceTypeId
					WHERE main.countryId = ' + CAST(@countryId AS VARCHAR) + '
					) x'
					
		SET @sql_filter = ''
		
		SET @select_field_list ='
			 crmId
			,countryId
			,serviceCode
			,receivingMode
			,receivingModeDesc
			,applicableFor
			,agentSelection
			,createdBy
			,createdDate
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
	
	ELSE IF @flag IN ('fl')				--filter list
	BEGIN
		--SELECT * FROM serviceTypeMaster
		IF @sortBy IS NULL
			SET @sortBy = 'detailTitle'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 serviceTypeId
					,serviceCode
					,typeTitle
					,typeDesc
					,isDeleted
					,isActive
				FROM serviceTypeMaster stm WITH(NOLOCK)
				WHERE serviceTypeId NOT IN (SELECT receivingMode FROM countryReceivingMode WHERE countryId = ' + CAST(@countryId AS VARCHAR) +')
					) x'
					
		SET @sql_filter = ''
		SET @sql_filter = ' AND ISNULL(isDeleted, ''N'') = ''N'' AND ISNULL(isActive,''N'') = ''Y'''
		
		SET @select_field_list ='
			 serviceTypeId
			,serviceCode
			,typeTitle
			,typeDesc
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
     EXEC proc_errorHandler 1, @errorMessage, @crmId
END CATCH

GO
