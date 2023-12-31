USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_crossRateDecimalMask]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_crossRateDecimalMask]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@crdmId							INT				= NULL
	,@cCurrency							VARCHAR(3)		= NULL
	,@pCurrency							VARCHAR(3)		= NULL
	,@rateMaskAd						INT				= NULL
	,@displayUnit						INT				= NULL
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
		 @logIdentifier = 'crdmId'
		,@logParamMain = 'crossRateDecimalMask'
		,@logParamMod = 'crossRateDecimalMaskMod'
		,@module = '20'
		,@tableAlias = 'Cross Rate Decimal Masking'
		
	IF @flag IN ('i')
	BEGIN	
		IF EXISTS(SELECT 'X' FROM crossRateDecimalMask WHERE ISNULL(cCurrency, ISNULL(@cCurrency, '')) = ISNULL(@cCurrency, '') AND pCurrency = @pCurrency)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
		BEGIN TRANSACTION
			--DELETE FROM rsList WHERE agentId = @agentId AND agentRole = @agentRole
			INSERT INTO crossRateDecimalMask (
				 cCurrency
				,pCurrency
				,rateMaskAd
				,displayUnit
				,createdBy
				,createdDate
			)
			SELECT
				 @cCurrency
				,@pCurrency
				,@rateMaskAd
				,@displayUnit
				,@user
				,GETDATE()
				
			SET @crdmId = SCOPE_IDENTITY()
			SET @modType = 'Insert'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crdmId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @crdmId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @crdmId
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @crdmId
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE crossRateDecimalMask SET
				 rateMaskAd			= @rateMaskAd
				,displayUnit		= @displayUnit
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
			WHERE crdmId = @crdmId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @crdmId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @crdmId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @crdmId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @crdmId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			SET @modType = 'Delete'
			
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @crdmId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @crdmId, @user, @oldValue, @newValue
			
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to delete record.', @crdmId
				RETURN
			END
			
			DELETE FROM crossRateDecimalMask WHERE crdmId = @crdmId
			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @crdmId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * FROM crossRateDecimalMask WITH(NOLOCK) WHERE crdmId = @crdmId
	END
	
	ELSE IF @flag IN ('s')
	BEGIN
		--IF @sortBy IS NULL
			SET @sortBy = 'pCurrency,cCurrency'
		--IF @sortOrder IS NULL
			--SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT
					 main.crdmId
					,cCurrency = ISNULL(main.cCurrency, ''Any'')
					,main.pCurrency
					,main.rateMaskAd
					,main.displayUnit
					,main.createdBy
					,main.createdDate
					,modifiedBy	= ISNULL(modifiedBy, createdBy)
					,modifiedDate = ISNULL(modifiedDate, createdDate)
				FROM crossRateDecimalMask main WITH(NOLOCK)
				WHERE 1 = 1
					) x'
					
		SET @sql_filter = ''
		
		IF @cCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND cCurrency = ''' + @cCurrency + ''''
		
		IF @pCurrency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND pCurrency = ''' + @pCurrency + ''''
		
		SET @select_field_list ='
			 crdmId
			,cCurrency
			,pCurrency
			,rateMaskAd
			,displayUnit
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
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
     EXEC proc_errorHandler 1, @errorMessage, @crdmId
END CATCH




GO
