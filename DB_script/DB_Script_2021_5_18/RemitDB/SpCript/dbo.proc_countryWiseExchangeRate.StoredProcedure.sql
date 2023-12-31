USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_countryWiseExchangeRate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	proc_countryWiseExchangeRate 's', 'admin'
	EXEC proc_countryWiseExchangeRate @flag = 'approve', @user = 'admin', @rowId = '3'
*/

CREATE proc [dbo].[proc_countryWiseExchangeRate]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@countryWiseExchangeRateId          VARCHAR(30)    = NULL
	,@baseCurrency                       INT            = NULL
	,@countryId                          INT            = NULL
	,@purchaseRate                       FLOAT          = NULL
	,@margin                             FLOAT          = NULL
	,@rowId								 INT			= NULL	

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
		 @logIdentifier = 'countryWiseExchangeRateId'
		,@logParamMain = 'countryWiseExchangeRate'
		,@logParamMod = 'countryWiseExchangeRateMod'
		,@module = '10'
		,@tableAlias = 'Exchange Rate - Country'
		
	IF @flag IN ('approve', 'reject')
	BEGIN
		SET @countryWiseExchangeRateId = NULL
		SELECT @countryWiseExchangeRateId = countryWiseExchangeRateId FROM countryWiseExchangeRateHistory WHERE rowId = @rowId AND approvedBy IS NULL
	END
	
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO countryWiseExchangeRate (
				 baseCurrency
				,countryId
				,purchaseRate
				,margin
				,createdBy
				,createdDate
			)
			SELECT
				 @baseCurrency
				,@countryId
				,@purchaseRate
				,@margin
				,@user
				,GETDATE()
			SET @countryWiseExchangeRateId = SCOPE_IDENTITY()
			
			INSERT INTO countryWiseExchangeRateHistory(
					 countryWiseExchangeRateId
					,baseCurrency
					,countryId
					,purchaseRate
					,margin
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @countryWiseExchangeRateId
					,@baseCurrency
					,@countryId
					,@purchaseRate
					,@margin
					,@user
					,GETDATE()
					,'insert'
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @countryWiseExchangeRateId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM countryWiseExchangeRateHistory WITH(NOLOCK)
				WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId AND createdBy = @user
		)		
		BEGIN
			SELECT
				mode.*
			FROM countryWiseExchangeRateHistory mode WITH(NOLOCK)
			INNER JOIN countryWiseExchangeRate main WITH(NOLOCK) ON mode.countryWiseExchangeRateId = main.countryWiseExchangeRateId
			WHERE mode.countryWiseExchangeRateId= @countryWiseExchangeRateId
		END
		ELSE
		BEGIN
			SELECT * FROM countryWiseExchangeRate WITH(NOLOCK) WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN	
		IF EXISTS (
			SELECT 'X' FROM countryWiseExchangeRateHistory WITH(NOLOCK)
			WHERE countryWiseExchangeRateId  = @countryWiseExchangeRateId AND approvedBy IS NULL AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @countryWiseExchangeRateId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM countryWiseExchangeRate WHERE approvedBy IS NULL AND countryWiseExchangeRateId  = @countryWiseExchangeRateId)				
			BEGIN
				SET @modType = 'Insert'	
				UPDATE countryWiseExchangeRate SET
					 baseCurrency                  = @baseCurrency
					,countryId                     = @countryId
					,purchaseRate                  = @purchaseRate
					,margin                        = @margin					
					--,updateCount = ISNULL(updateCount, 0) + 1
				WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
				
				DELETE FROM countryWiseExchangeRateHistory 
				WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
				AND approvedBy IS NULL
				
				INSERT INTO countryWiseExchangeRateHistory(
					 countryWiseExchangeRateId
					,baseCurrency
					,countryId
					,purchaseRate
					,margin
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @countryWiseExchangeRateId
					,@baseCurrency
					,@countryId
					,@purchaseRate
					,@margin
					,@user
					,GETDATE()
					,'insert'
				
			END
			ELSE
			BEGIN
				DELETE FROM countryWiseExchangeRateHistory 
				WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
				AND approvedBy IS NULL
							
				INSERT INTO countryWiseExchangeRateHistory(
					 countryWiseExchangeRateId
					,baseCurrency
					,countryId
					,purchaseRate
					,margin
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @countryWiseExchangeRateId
					,@baseCurrency
					,@countryId
					,@purchaseRate
					,@margin
					,@user
					,GETDATE()
					,'update'
				SET @modType = 'update'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @countryWiseExchangeRateId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM countryWiseExchangeRate WITH(NOLOCK)
			WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @countryWiseExchangeRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM countryWiseExchangeRateHistory  WITH(NOLOCK)
			WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @countryWiseExchangeRateId
			RETURN
		END
		
		
		INSERT INTO countryWiseExchangeRateHistory(
			 countryWiseExchangeRateId
			,baseCurrency
			,countryId
			,purchaseRate
			,margin
			,createdBy
			,createdDate
			,modType
		)
		SELECT
			 countryWiseExchangeRateId
			,baseCurrency
			,countryId
			,purchaseRate
			,margin
			,@user
			,GETDATE()
			,'delete'
		FROM countryWiseExchangeRate WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId


		EXEC proc_errorHandler 0, 'Record deleted successfully.', @countryWiseExchangeRateId
	END
	ELSE IF @flag = 'reject'
	BEGIN
		IF 	NOT EXISTS (
			SELECT 'X' FROM countryWiseExchangeRateHistory WITH(NOLOCK)
			WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @countryWiseExchangeRateId
			RETURN
		END
		SET @modType = 'Reject'
		IF EXISTS (SELECT 'X' FROM countryWiseExchangeRate WHERE approvedBy IS NULL AND countryWiseExchangeRateId = @countryWiseExchangeRateId)
		BEGIN --New record
			BEGIN TRANSACTION
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryWiseExchangeRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryWiseExchangeRateId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @countryWiseExchangeRateId
					RETURN
				END
				DELETE FROM countryWiseExchangeRate WHERE countryWiseExchangeRateId=  @countryWiseExchangeRateId AND approvedBy IS NULL			
				DELETE FROM countryWiseExchangeRateHistory WHERE countryWiseExchangeRateId=  @countryWiseExchangeRateId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION			
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryWiseExchangeRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryWiseExchangeRateId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @countryWiseExchangeRateId
					RETURN
				END				
				DELETE FROM countryWiseExchangeRateHistory WHERE countryWiseExchangeRateId=  @countryWiseExchangeRateId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @countryWiseExchangeRateId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM countryWiseExchangeRate WITH(NOLOCK)
			WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM countryWiseExchangeRate WITH(NOLOCK)
			WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @countryWiseExchangeRateId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM countryWiseExchangeRate WHERE approvedBy IS NULL AND countryWiseExchangeRateId = @countryWiseExchangeRateId )
				SET @modType = 'insert'
			ELSE
				SELECT @modType = modType FROM countryWiseExchangeRateHistory WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
			IF @modType = 'insert'
			BEGIN --New record
				UPDATE countryWiseExchangeRate SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryWiseExchangeRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'update'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryWiseExchangeRateId, @oldValue OUTPUT
				UPDATE main SET
					 main.baseCurrency                  = mode.baseCurrency
					,main.countryId                     = mode.countryId
					,main.purchaseRate                  = mode.purchaseRate
					,main.margin                        = mode.margin
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				FROM countryWiseExchangeRate main
				INNER JOIN countryWiseExchangeRateHistory mode ON mode.countryWiseExchangeRateId = main.countryWiseExchangeRateId
				WHERE mode.countryWiseExchangeRateId = @countryWiseExchangeRateId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryWiseExchangeRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'delete'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryWiseExchangeRateId, @oldValue OUTPUT
				UPDATE countryWiseExchangeRate SET
					isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
			END
			UPDATE countryWiseExchangeRateHistory SET 
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE countryWiseExchangeRateId = @countryWiseExchangeRateId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryWiseExchangeRateId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @countryWiseExchangeRateId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @countryWiseExchangeRateId
	END	

	ELSE IF @flag IN ('s')
	BEGIN
		SET @table = '(
						SELECT
							 x.countryWiseExchangeRateId
							,ccm.countryId
							,baseCurrency = ISNULL(base.currCode, ''USD'')
							,ccm.currCode 
							,ccm.countryName
							,purchaseRate = ISNULL(x.purchaseRate, 0)
							,margin = ISNULL(x.margin, 0)
							,salesRate = ISNULL(x.purchaseRate, 0) + ISNULL(x.margin, 0)		
							,modifiedBy = x.modifiedBy 
							,modifiedDate = x.modifiedDate
						FROM countryCurrencyMaster ccm WITH(NOLOCK)
						LEFT JOIN (
								SELECT
									 cwerh.countryWiseExchangeRateId
									,cwerh.baseCurrency
									,cwerh.countryId
									,cwerh.purchaseRate
									,cwerh.margin
									,cwer.modifiedBy
									,cwer.modifiedDate 
								FROM countryWiseExchangeRateHistory cwerh
								INNER JOIN countryWiseExchangeRate cwer ON cwer.countryWiseExchangeRateId = cwerh.countryWiseExchangeRateId 
									WHERE cwerh.createdBy =''' + @user +''' AND cwerh.approvedBy IS NULL
								
								UNION ALL
								SELECT
									 cwer.countryWiseExchangeRateId 
									,cwer.baseCurrency
									,cwer.countryId
									,cwer.purchaseRate
									,cwer.margin
									,cwer.modifiedBy
									,cwer.modifiedDate 
								FROM countryWiseExchangeRate cwer
									WHERE createdBy =''' + @user +''' AND approvedBy IS NOT NULL
									AND countryId 
										NOT IN (SELECT countryId FROM countryWiseExchangeRateHistory WHERE createdBy =''' + @user +''' AND approvedBy IS NULL)								
						) x ON ccm.countryId = x.countryId 
						LEFT JOIN countryCurrencyMaster base ON base.countryId = x.baseCurrency 															
					) x'
					
		SET @sql = 'SELECT * FROM ' + @table + ' ORDER BY countryName ASC '
		PRINT @sql
		EXEC(@sql)	
		
	END
	ELSE IF @flag IN ('sh')--history
	BEGIN
		SELECT
			 cwer.countryWiseExchangeRateId
			,ccm.countryId
			,baseCurrency = 'USD'
			,ccm.currCode 
			,ccm.countryName
			,purchaseRate = ISNULL(cwer.purchaseRate, 0)
			,margin = ISNULL(cwer.margin, 0)
			,salesRate = ISNULL(cwer.purchaseRate, 0) + ISNULL(cwer.margin, 0)		
			,modifiedBy = cwer.createdBy
			,modifiedDate = cwer.createdDate
		FROM countryWiseExchangeRateHistory cwer WITH(NOLOCK)
		INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON ccm.countryId = cwer.countryId
		WHERE cwer.countryId = @countryId
		AND cwer.approvedBy IS NOT NULL
		ORDER BY cwer.createdDate DESC
	END
	ELSE IF @flag IN ('p') --change approval pedning
	BEGIN
		SELECT
			 cwer.rowId
			,cwer.countryWiseExchangeRateId
			,ccm.countryId
			,baseCurrency = 'USD'
			,ccm.currCode 
			,ccm.countryName
			,purchaseRate = ISNULL(cwer.purchaseRate, 0)
			,margin = ISNULL(cwer.margin, 0)
			,salesRate = ISNULL(cwer.purchaseRate, 0) + ISNULL(cwer.margin, 0)		
			--,modifiedBy = cwer.createdBy
			--,modifiedDate = cwer.createdDate
		FROM countryWiseExchangeRateHistory cwer WITH(NOLOCK)
		INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON ccm.countryId = cwer.countryId
		WHERE cwer.approvedBy IS NULL
		ORDER BY cwer.createdDate DESC
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @countryWiseExchangeRateId
END CATCH


GO
