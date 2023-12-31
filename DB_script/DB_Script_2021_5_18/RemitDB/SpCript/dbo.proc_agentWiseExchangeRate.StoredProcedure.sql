USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentWiseExchangeRate]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

proc_agentWiseExchangeRate @flag = 's', @user ='admin'
*/

CREATE proc [dbo].[proc_agentWiseExchangeRate]
 	 @flag                               VARCHAR(50)    = NULL
	,@user                               VARCHAR(30)    = NULL
	,@agentWiseExchangeRateId            VARCHAR(30)    = NULL
	,@baseCurrency                       INT            = NULL
	,@agentId                            INT            = NULL
	,@purchaseRate                       FLOAT          = NULL
	,@margin                             FLOAT          = NULL
	,@countryId							 INT			= NULL
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
		 @logIdentifier = 'agentWiseExchangeRateId'
		,@logParamMain = 'agentWiseExchangeRate'
		,@logParamMod = 'agentWiseExchangeRateMod'
		,@module = '10'
		,@tableAlias = 'Exchange Rate - Agent'
	
	IF @flag IN ('approve', 'reject')
	BEGIN
		SET @agentWiseExchangeRateId = NULL
		SELECT @agentWiseExchangeRateId = agentWiseExchangeRateId FROM agentWiseExchangeRateHistory WHERE rowId = @rowId AND approvedBy IS NULL
	END
	
	SELECT @purchaseRate = purchaseRate FROM countryWiseExchangeRate WITH(NOLOCK) WHERE countryId IN (SELECT agentCountry FROM agentMaster WITH(NOLOCK) WHERE agentId = @agentId)
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO agentWiseExchangeRate (
				 baseCurrency
				,agentId				
				,margin
				,createdBy
				,createdDate
			)
			SELECT
				 @baseCurrency
				,@agentId				
				,@margin
				,@user
				,GETDATE()
			
			SET @agentWiseExchangeRateId = SCOPE_IDENTITY()
			
			
			INSERT INTO agentWiseExchangeRateHistory (
				 agentWiseExchangeRateId
				,baseCurrency
				,agentId
				,purchaseRate
				,margin
				,createdBy
				,createdDate
			)
			SELECT
				 @agentWiseExchangeRateId
				,@baseCurrency
				,@agentId
				,@purchaseRate
				,@margin
				,@user
				,GETDATE()
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @agentWiseExchangeRateId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentWiseExchangeRateHistory WITH(NOLOCK)
				WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM agentWiseExchangeRateHistory mode WITH(NOLOCK)
			INNER JOIN agentWiseExchangeRate main WITH(NOLOCK) ON mode.agentWiseExchangeRateId = main.agentWiseExchangeRateId
			WHERE mode.agentWiseExchangeRateId= @agentWiseExchangeRateId
		END
		ELSE
		BEGIN
			SELECT * FROM agentWiseExchangeRate WITH(NOLOCK) WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentWiseExchangeRateHistory WITH(NOLOCK)
			WHERE agentWiseExchangeRateId  = @agentWiseExchangeRateId AND approvedBy IS NULL AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @agentWiseExchangeRateId
			RETURN
		END
	
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM agentWiseExchangeRate WHERE approvedBy IS NULL AND agentWiseExchangeRateId  = @agentWiseExchangeRateId)				
			BEGIN				
				
				SET @modType = 'Insert'		
				UPDATE agentWiseExchangeRate SET
					 baseCurrency = @baseCurrency
					,agentId = @agentId
					,margin = @margin					
				WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
				
				DELETE FROM agentWiseExchangeRateHistory 
				WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
				AND approvedBy IS NULL
				
				INSERT INTO agentWiseExchangeRateHistory(
					 agentWiseExchangeRateId
					,baseCurrency
					,agentId
					,purchaseRate
					,margin
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @agentWiseExchangeRateId
					,@baseCurrency
					,@agentId
					,@purchaseRate
					,@margin
					,@user
					,GETDATE()
					,'update'				
				
			END
			ELSE
			BEGIN
				DELETE FROM agentWiseExchangeRateHistory 
				WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
				AND approvedBy IS NULL
				
				INSERT INTO agentWiseExchangeRateHistory(
					 agentWiseExchangeRateId
					,baseCurrency
					,agentId
					,purchaseRate
					,margin
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @agentWiseExchangeRateId
					,@baseCurrency
					,@agentId
					,@purchaseRate
					,@margin
					,@user
					,GETDATE()
					,'update'
				SET @modType = 'update'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @agentWiseExchangeRateId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM agentWiseExchangeRate WITH(NOLOCK)
			WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @agentWiseExchangeRateId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM agentWiseExchangeRateHistory  WITH(NOLOCK)
			WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @agentWiseExchangeRateId
			RETURN
		END
	
			INSERT INTO agentWiseExchangeRateHistory(
					 agentWiseExchangeRateId
					,baseCurrency
					,agentId
					,purchaseRate
					,margin
					,createdBy
					,createdDate
					,modType
				)
				SELECT TOP 1
					 awer.agentWiseExchangeRateId
					,awer.baseCurrency
					,awer.agentId
					,cwer.purchaseRate
					,awer.margin
					,user
					,GETDATE()
					,'delete'
				FROM agentWiseExchangeRate awer WITH(NOLOCK)
				INNER JOIN agentMaster am WITH(NOLOCK) ON awer.agentId = am.agentId
				INNER JOIN countryWiseExchangeRate cwer WITH(NOLOCK) ON cwer.countryId = am.agentCountry
				WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId	
		
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentWiseExchangeRateId
	END
	ELSE IF @flag = 'reject'
	BEGIN
		IF 	NOT EXISTS (
			SELECT 'X' FROM agentWiseExchangeRateHistory WITH(NOLOCK)
			WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentWiseExchangeRateId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM agentWiseExchangeRate WHERE approvedBy IS NULL AND agentWiseExchangeRateId = @agentWiseExchangeRateId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseExchangeRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentWiseExchangeRateId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentWiseExchangeRateId
					RETURN
				END
			DELETE FROM agentWiseExchangeRate WHERE agentWiseExchangeRateId=  @agentWiseExchangeRateId AND approvedBy IS NULL
			DELETE FROM agentWiseExchangeRateHistory WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseExchangeRateId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentWiseExchangeRateId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @agentWiseExchangeRateId
					RETURN
				END
				DELETE FROM agentWiseExchangeRateHistory WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId AND approvedBy IS NULL			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @agentWiseExchangeRateId
	END
	ELSE IF @flag = 'approve'
	BEGIN
		IF 	NOT EXISTS (
			SELECT 'X' FROM agentWiseExchangeRateHistory WITH(NOLOCK)
			WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @agentWiseExchangeRateId
			RETURN
		END
		
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM agentWiseExchangeRate WHERE approvedBy IS NULL AND agentWiseExchangeRateId = @agentWiseExchangeRateId )
				SET @modType = 'insert'
			ELSE
				SELECT @modType = modType FROM agentWiseExchangeRateHistory WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
			IF @modType = 'insert'
			BEGIN --New record
				UPDATE agentWiseExchangeRate SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate = GETDATE()
				WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
				
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseExchangeRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'update'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseExchangeRateId, @oldValue OUTPUT
				UPDATE main SET
					 main.baseCurrency = mode.baseCurrency
					,main.agentId = mode.agentId					
					,main.margin = mode.margin
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				FROM agentWiseExchangeRate main
				INNER JOIN agentWiseExchangeRateHistory mode ON mode.agentWiseExchangeRateId = main.agentWiseExchangeRateId
				WHERE mode.agentWiseExchangeRateId = @agentWiseExchangeRateId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseExchangeRateId, @newValue OUTPUT
			END
			ELSE IF @modType = 'delete'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @agentWiseExchangeRateId, @oldValue OUTPUT
				UPDATE agentWiseExchangeRate SET
					isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user
					,updateCount = ISNULL(updateCount, 0) + 1
				WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
			END
			UPDATE agentWiseExchangeRateHistory SET 
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE agentWiseExchangeRateId = @agentWiseExchangeRateId
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @agentWiseExchangeRateId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @agentWiseExchangeRateId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @agentWiseExchangeRateId
	END	
	
	ELSE IF @flag IN ('s')
	BEGIN
		SET @table = '(
						SELECT
							 x.agentWiseExchangeRateId
							,ccm.countryId
							,am.agentId
							,am.agentName
							,baseCurrency = ISNULL(base.currCode, ''USD'')
							,ccm.currCode 
							,ccm.countryName
							,purchaseRate = ISNULL(cwer.purchaseRate, 0)
							,margin = ISNULL(x.margin, 0)
							,salesRate = ISNULL(cwer.purchaseRate, 0) + ISNULL(x.margin, 0)		
							,modifiedBy = x.modifiedBy 
							,modifiedDate = x.modifiedDate
						FROM agentMaster am WITH(NOLOCK)
						INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON am.agentCountry = ccm.countryId					 
						LEFT JOIN countryWiseExchangeRate cwer WITH(NOLOCK) ON am.agentCountry = cwer.countryId
						LEFT JOIN (
									SELECT
										 awerh.agentWiseExchangeRateId
										,awerh.baseCurrency
										,awerh.agentId			
										,awerh.margin
										,awer.modifiedBy
										,awer.modifiedDate 
									FROM agentWiseExchangeRateHistory awerh
									INNER JOIN agentWiseExchangeRate awer ON awer.agentWiseExchangeRateId = awerh.agentWiseExchangeRateId 
										WHERE awerh.createdBy =''' + @user +''' AND awer.approvedBy IS NULL
									UNION ALL
									SELECT
										 awer.agentWiseExchangeRateId
										,awer.baseCurrency
										,awer.agentId			
										,awer.margin
										,awer.modifiedBy
										,awer.modifiedDate 
									FROM agentWiseExchangeRate awer
										WHERE createdBy =''' + @user +''' AND approvedBy IS NOT NULL
										AND agentId 
											NOT IN (SELECT agentId FROM agentWiseExchangeRateHistory WHERE createdBy =''' + @user +''' AND approvedBy IS NULL)								
						) x ON x.agentId = am.agentId
						LEFT JOIN countryCurrencyMaster base ON base.countryId = x.baseCurrency
						WHERE am.agentCountry = ' + CAST(@countryId AS VARCHAR) + '
					) x ' 	
		
		SET @sql = 'SELECT * FROM ' + @table + ' ORDER BY agentName ASC '
		PRINT @sql
		EXEC(@sql)		
		
	END
	ELSE IF @flag IN ('sh')--Hisotry
	BEGIN
		SELECT
			 awer.agentWiseExchangeRateId
			,am.agentId
			,baseCurrency = 'USD'
			,ccm.currCode
			,am.agentName 
			,purchaseRate = ISNULL(awer.purchaseRate, 0)
			,margin = ISNULL(awer.margin, 0)
			,salesRate = ISNULL(awer.purchaseRate, 0) + ISNULL(awer.margin, 0)		
			,awer.createdBy modifiedBy
			,awer.createdDate modifiedDate
		FROM agentWiseExchangeRateHistory awer WITH(NOLOCK) 		
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = awer.agentId
		LEFT JOIN countryWiseExchangeRate cwer WITH(NOLOCK) ON am.agentCountry = cwer.countryId	
		INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON ccm.countryId = am.agentCountry		
		WHERE awer.agentId = @agentId
		ORDER BY awer.createdDate DESC
	END
	ELSE IF @flag IN ('p') --change approval pedning
	BEGIN
		SELECT
			 awer.rowId
			,awer.agentWiseExchangeRateId
			,am.agentId
			,baseCurrency = 'USD'
			,ccm.currCode
			,am.agentName 
			,purchaseRate = ISNULL(awer.purchaseRate, 0)
			,margin = ISNULL(awer.margin, 0)
			,salesRate = ISNULL(awer.purchaseRate, 0) + ISNULL(awer.margin, 0)		
			,awer.createdBy modifiedBy
			,awer.createdDate modifiedDate
		FROM agentWiseExchangeRateHistory awer WITH(NOLOCK) 		
		INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = awer.agentId
		LEFT JOIN countryWiseExchangeRate cwer WITH(NOLOCK) ON am.agentCountry = cwer.countryId	
		INNER JOIN countryCurrencyMaster ccm WITH(NOLOCK) ON ccm.countryId = am.agentCountry		
		WHERE awer.approvedBy IS NULL
		AND am.agentCountry = ISNULL(NULLIF(@countryId, 0), agentCountry)
		ORDER BY am.agentName 
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @agentWiseExchangeRateId
END CATCH


GO
