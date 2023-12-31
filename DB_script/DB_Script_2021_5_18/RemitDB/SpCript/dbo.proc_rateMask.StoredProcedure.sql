USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_rateMask]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_rateMask]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_rateMask
GO
*/
--select * from rateMask
--EXEC proc_rateMask @flag = 's',@user = 'admin'
CREATE proc [dbo].[proc_rateMask]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rmID								INT				= NULL
	,@baseCurrency						VARCHAR(3)		= NULL
	,@currency							VARCHAR(3)		= NULL
	,@rateMaskMulBd                     INT				= NULL
	,@rateMaskMulAd						INT				= NULL
	,@rateMaskDivBd                     INT				= NULL
	,@rateMaskDivAd                     INT				= NULL
	,@cMin								FLOAT			= NULL
	,@cMax								FLOAT			= NULL
	,@pMin								FLOAT			= NULL
	,@pMax								FLOAT			= NULL
	--,@factor                            CHAR(1)         = NULL
	,@isEnable                          CHAR(1)         = NULL
	,@isActive                          CHAR(1)         = NULL
	
	,@sortBy                            VARCHAR(50)    = NULL
	,@sortOrder                         VARCHAR(5)     = NULL
	,@pageSize                          INT            = NULL
	,@pageNumber                        INT            = NULL


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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20111030
		,@logIdentifier = 'rmId'
		,@logParamMain = 'rateMask'
		,@logParamMod = 'rateMaskHistory'
		,@module = '20'
		,@tableAlias = 'Rate Mask Detail'
	
	
	IF @currency is null
		select @currency=currency from rateMask WITH(NOLOCK) where rmId=@rmID
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM rateMask WITH(NOLOCK)
			WHERE rmId = @rmId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @rmID
			RETURN
		END
		
		IF EXISTS (
			SELECT 'X' FROM rateMask WITH(NOLOCK)
			WHERE currency = @currency AND baseCurrency = @baseCurrency
		)
		BEGIN
			EXEC proc_errorHandler 1, 'Sorry this currency is already added.', @rmID
			RETURN
		END
		
		IF EXISTS (
			SELECT 'X' FROM rateMaskHistory WITH(NOLOCK)
			WHERE rmId = @rmID AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @rmID
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO rateMask (
				baseCurrency,currency,rateMaskMulBd,rateMaskMulAd,rateMaskDivBd,rateMaskDivAd,cMin
				,cMax,pMin,pMax,isActive,createdBy,createdDate
			)
			SELECT
				@baseCurrency,@currency,@rateMaskMulBd,@rateMaskMulAd,@rateMaskDivBd,@rateMaskDivAd,@cMin
				,@cMax,@pMin,@pMax,'Y',@user,GETDATE()
				
			SET @rmID = SCOPE_IDENTITY()

			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rmID , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rmID, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rmID
				RETURN
			END
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rmID
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM rateMaskHistory WITH(NOLOCK)
				WHERE rmId = @rmID AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM rateMaskHistory mode WITH(NOLOCK)
			INNER JOIN rateMask main WITH(NOLOCK) ON mode.rmId = main.rmId	
			WHERE mode.rmId= @rmID AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM rateMask WITH(NOLOCK) WHERE rmId = @rmID
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRANSACTION
			UPDATE rateMask SET
				 rateMaskMulBd	= @rateMaskMulBd
				,rateMaskMulAd	= @rateMaskMulAd
				,rateMaskDivBd	= @rateMaskDivBd
				,rateMaskDivAd	= @rateMaskDivAd
				,cMin			= @cMin
				,cMax			= @cMax
				,pMin			= @pMin
				,pMax			= @pMax
				,modifiedBy		= @user
				,modifiedDate	= GETDATE()
			WHERE rmId = @rmID	
			
			INSERT INTO rateMaskHistory(
				baseCurrency,currency,rateMaskMulBd,rateMaskMulAd,rateMaskDivBd,rateMaskDivAd
				,cMin,cMax,pMin,pMax,createdBy,createdDate,approvedBy,approvedDate,modType
			)
			SELECT
				baseCurrency,currency,@rateMaskMulBd,@rateMaskMulAd,@rateMaskDivBd,@rateMaskDivAd
				,@cMin,@cMax,@pMin,@pMax,@user,GETDATE(),@user,GETDATE(),'U'
			FROM rateMask WITH(NOLOCK) WHERE rmId = @rmID
			
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rmID, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rmID, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rmID
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @rmID
	END
	
	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'currency'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
		SELECT
					 rmID				= main.rmId
					,baseCurrency		= main.baseCurrency
					,currency			= cM.currencyCode
					,currencyName		= cM.currencyName
					,rateMaskMulBd		= main.rateMaskMulBd
					,rateMaskMulAd		= main.rateMaskMulAd
					,rateMaskDivBd		= main.rateMaskDivBd
					,rateMaskDivAd		= main.rateMaskDivAd
					,cMin				= main.cMin
					,cMax				= main.cMax
					,pMin				= main.pMin
					,pMax				= main.pMax
					,main.createdBy
					,main.createdDate
					,modifiedBy			= ISNULL(main.modifiedBy, main.createdBy)
					,modifiedDate		= ISNULL(main.modifiedDate, main.createdDate)
					,hasChanged			= ''N''

				FROM rateMask main WITH(NOLOCK)
				INNER JOIN currencyMaster cM ON cM.currencyCode = main.currency 
				WHERE 1 = 1
			) x'
			
		
		SET @sql_filter = ''
		
		IF @currency IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND currency = ''' + @currency + ''''
		
		SET @select_field_list ='
			 rmID
			,baseCurrency
			,currency
			,currencyName
			,rateMaskMulBd
			,rateMaskMulAd
			,rateMaskDivBd
			,rateMaskDivAd
			,cMin
			,cMax
			,pMin
			,pMax
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
			,hasChanged 
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
		
		PRINT(@table)
	END
	
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM rateMask WITH(NOLOCK)
			WHERE rmId = @rmID
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM rateMask WITH(NOLOCK)
			WHERE rmId = @rmID AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rmID
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM rateMask WHERE approvedBy IS NULL AND rmId = @rmID)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rmID, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rmId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rmID
					RETURN
				END
			DELETE FROM rateMask WHERE rmId	 =  @rmID
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rmID, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rmId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rmID
					RETURN
				END
				DELETE FROM rateMaskHistory WHERE rmId = @rmID AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @rmID
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM rateMask WITH(NOLOCK)
			WHERE rmId = @rmID
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM rateMask WITH(NOLOCK)
			WHERE rmId = @rmID AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rmID
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM rateMask WHERE approvedBy IS NULL AND rmId = @rmID )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM rateMaskHistory WHERE rmId = @rmID AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE rateMask SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE rmId = @rmID
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rmID, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rmID, @oldValue OUTPUT
				UPDATE main SET
					 main.rateMaskMulBd = mode.rateMaskMulBd
					,main.rateMaskMulAd = mode.rateMaskMulAd
					,main.rateMaskDivBd = mode.rateMaskDivBd
					,main.rateMaskDivAd = mode.rateMaskDivAd
					,main.cMin			= mode.cMin
					,main.cMax			= mode.cMax
					,main.pMin			= mode.pMin
					,main.pMax			= mode.pMax
					--,main.factor =  mode.factor
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM rateMask main
				INNER JOIN rateMaskHistory mode ON mode.rmId = main.rmId
				WHERE mode.rmId = @rmID AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'rateMask', 'rmId', @rmID, @newValue OUTPUT
				DELETE FROM rateMaskHistory WHERE rmId = @rmID AND approvedBy IS NULL
			END
			--ELSE IF @modType = 'D'
			--BEGIN
			--	EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rmID, @oldValue OUTPUT
			--	UPDATE dscDetail SET
			--		 isDeleted = 'Y'
			--		,modifiedDate = GETDATE()
			--		,modifiedBy = @user					
			--	WHERE dscDetailId = @dscDetailId
			--END
			
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rmId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @rmID
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @rmID
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rmID
END CATCH



GO
