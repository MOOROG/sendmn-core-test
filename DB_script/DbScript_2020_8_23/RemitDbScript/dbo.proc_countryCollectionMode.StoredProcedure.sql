USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryCollectionMode]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_countryCollectionMode]
	 @flag			VARCHAR(50)
	,@user			VARCHAR(50)		= NULL
	,@ccmId			INT				= NULL
	,@countryId		INT				= NULL
	,@collModes		VARCHAR(MAX)	= NULL
	,@sortBy        VARCHAR(50)		= NULL
	,@sortOrder     VARCHAR(5)		= NULL
	,@pageSize		INT				= NULL
	,@pageNumber    INT				= NULL

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
		 @logIdentifier = 'ccmId'
		,@logParamMain = 'countryCollectionMode'
		,@logParamMod = 'countryCollectionModeMod'
		,@module = '20'
		,@tableAlias = 'Country Collection Mode'
		
	IF @flag IN ('i', 'u')
	BEGIN	
		BEGIN TRANSACTION
			--DELETE FROM rsList WHERE agentId = @agentId AND agentRole = @agentRole
			INSERT INTO countryCollectionMode (
				 countryId
				,collMode
				,createdBy
				,createdDate
			)
			SELECT @countryId,value,@user,GETDATE() FROM dbo.Split(',', @collModes)
			EXEC (@sql)
				
			SET @modType = CASE WHEN @flag = 'i' THEN 'Insert' ELSE 'Update' END
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @ccmId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @ccmId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @ccmId
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @ccmId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			DELETE FROM countryCollectionMode WHERE ccmId = @ccmId
			
			SET @modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @ccmId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @ccmId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @ccmId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @ccmId
	END

	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'ccmId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.ccmId
					,main.countryId
					,collMode = sdv.detailTitle
					,collModeDesc = sdv.detailDesc
					,main.createdBy
					,main.createdDate
				FROM countryCollectionMode main WITH(NOLOCK)
				LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.collMode = sdv.valueId
					WHERE 1 = 1 AND main.countryId = ' + CAST(@countryId AS VARCHAR) + '
					) x'
					
		SET @sql_filter = ''
		
		SET @select_field_list ='
			 ccmId
			,countryId
			,collMode
			,collModeDesc
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
		IF @sortBy IS NULL
			SET @sortBy = 'detailTitle'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 valueId
					,detailTitle
					,detailDesc
				FROM staticDataValue sdv WITH(NOLOCK)
				WHERE typeID = 2200 AND valueId NOT IN (SELECT collMode FROM countryCollectionMode WHERE countryId = ' + CAST(@countryId AS VARCHAR) +')
					) x'
					
		SET @sql_filter = ''
		
		SET @select_field_list ='
			 valueId
			,detailTitle
			,detailDesc
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
     EXEC proc_errorHandler 1, @errorMessage, @ccmId
END CATCH


GO
