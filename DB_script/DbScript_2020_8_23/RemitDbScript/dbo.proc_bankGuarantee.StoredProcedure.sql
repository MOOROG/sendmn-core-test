USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_bankGuarantee]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_bankGuarantee]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@bgId								VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@guaranteeNo						VARCHAR(20)		= NULL
	,@amount							MONEY			= NULL
	,@currency                          INT				= NULL
	,@bankName							VARCHAR(50)		= NULL
	,@issuedDate                        DATETIME		= NULL
	,@expiryDate                        DATETIME        = NULL
	,@followUpDate						DATETIME		= NULL
	,@sessionId							VARCHAR(50)		= NULL
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
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20181230
		,@logIdentifier = 'bgId'
		,@logParamMain = 'bankGuarantee'
		,@logParamMod = 'bankGuaranteeHistory'
		,@module = '20'
		,@tableAlias = 'Bank Guarantee'
	
	IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 bgId = ISNULL(mode.bgId, main.bgId)
					,agentId = ISNULL(mode.agentId, main.agentId)
					,guaranteeNo = ISNULL(mode.guaranteeNo, main.guaranteeNo)
					,amount = ISNULL(mode.amount, main.amount)
					,currency = ISNULL(mode.currency, main.currency)
					,bankName = ISNULL(mode.bankName, main.bankName)
					,issuedDate = ISNULL(mode.issuedDate, main.issuedDate)
					,expiryDate = ISNULL(mode.expiryDate, main.expiryDate)
					,followUpDate = ISNULL(mode.followUpDate, main.followUpDate)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.bgId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM bankGuarantee main WITH(NOLOCK)
					LEFT JOIN bankGuaranteeHistory mode ON main.bgId = mode.bgId AND mode.approvedBy IS NULL and main.agentId = mode.agentId
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) '
			--PRINT (@table)
	
	END	
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO bankGuarantee (
				 agentId
				,guaranteeNo
				,amount
				,currency
				,bankName
				,issuedDate
				,followUpDate
				,expiryDate
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@guaranteeNo
				,@amount
				,@currency
				,@bankName
				,@issuedDate
				,@followUpDate
				,@expiryDate
				,@user
				,GETDATE()				
				
			SET @bgId = SCOPE_IDENTITY()		
			UPDATE securityDocument SET securityTypeId = @bgId,sessionId = null WHERE sessionId = @sessionId AND securityType='B'
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @bgId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM bankGuaranteeHistory WITH(NOLOCK)
				WHERE bgId = @bgId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT 
				mode.rowId,
				mode.bgId,
				mode.agentid,
				mode.guaranteeNo,
				mode.amount,
				mode.currency,
				mode.bankName,
				issuedDate = CONVERT(VARCHAR,mode.issuedDate,101),
				expiryDate = CONVERT(VARCHAR,mode.expiryDate,101),
				followUpDate = CONVERT(VARCHAR,mode.followUpDate,101)
			FROM bankGuaranteeHistory mode WITH(NOLOCK)
			INNER JOIN bankGuarantee main WITH(NOLOCK) ON mode.bgId = main.bgId
			WHERE mode.bgId= @bgId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				bgId,
				agentid,
				guaranteeNo,
				amount,
				currency,
				bankName,
				issuedDate = CONVERT(VARCHAR,issuedDate,101),
				expiryDate = CONVERT(VARCHAR,expiryDate,101),
				followUpDate = CONVERT(VARCHAR,followUpDate,101)
			FROM bankGuarantee WITH(NOLOCK) WHERE bgId = @bgId
			SELECT * FROM bankGuarantee WITH(NOLOCK) WHERE bgId = @bgId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM bankGuarantee WITH(NOLOCK)
			WHERE bgId = @bgId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @bgId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM bankGuaranteeHistory WITH(NOLOCK)
			WHERE bgId  = @bgId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @bgId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM bankGuarantee WHERE approvedBy IS NULL AND bgId  = @bgId)			
			BEGIN				
				UPDATE bankGuarantee SET
					 agentId = @agentId
					,guaranteeNo = @guaranteeNo
					,amount = @amount
					,currency = @currency
					,bankName = @bankName
					,issuedDate = @issuedDate
					,followUpDate = @followUpDate
					,expiryDate = @expiryDate
					,modifiedBy = @user
					,modifiedDate = GETDATE()
			WHERE bgId = @bgId			
			END
			ELSE
			BEGIN
				DELETE FROM bankGuaranteeHistory WHERE bgId = @bgId AND approvedBy IS NULL
				INSERT INTO bankGuaranteeHistory(
					 bgId
					,agentId
					,guaranteeNo
					,amount
					,currency
					,bankName
					,issuedDate
					,followUpDate
					,expiryDate
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @bgId
					,@agentId
					,@guaranteeNo
					,@amount
					,@currency
					,@bankName
					,@issuedDate
					,@followUpDate
					,@expiryDate
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @bgId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM bankGuarantee WITH(NOLOCK)
			WHERE bgId = @bgId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @bgId
			RETURN
		END
		
		IF EXISTS (
			SELECT 'X' FROM bankGuaranteeHistory  WITH(NOLOCK)
			WHERE bgId = @bgId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @bgId
			RETURN
		END
		
		SELECT @agentId = agentId FROM bankGuarantee WHERE bgId = @bgId
		IF EXISTS(SELECT 'X' FROM bankGuarantee WITH(NOLOCK) WHERE bgId = @bgId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM bankGuarantee WHERE bgId = @bgId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
			RETURN
		END
			INSERT INTO bankGuaranteeHistory(
					 bgId
					,agentId
					,guaranteeNo
					,amount
					,currency
					,bankName
					,issuedDate
					,followUpDate
					,expiryDate
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 bgId
					,agentId
					,guaranteeNo
					,amount
					,currency
					,bankName
					,issuedDate
					,followUpDate
					,expiryDate
					,@user
					,GETDATE()					
					,'D'
				FROM bankGuarantee
				WHERE bgId = @bgId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
	END


	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'bgId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '( 
				SELECT
					 main.bgId
					,main.agentId
					,main.guaranteeNo
					,main.amount
					,currency = cm.currencyCode
					,main.bankName
					,main.issuedDate
					,main.followUpDate
					,main.expiryDate
					,main.createdBy
					,main.createdDate
					,main.modifiedBy							
					,haschanged
				FROM ' + @table + ' main
				LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyId
				WHERE main.agentId = ' + CAST(@agentId AS VARCHAR) + '
				) x
	
				'
					
		SET @sql_filter = ''
		PRINT ('test')
		SET @select_field_list ='
			 bgId
			,agentId
			,guaranteeNo
			,amount
			,currency
			,bankName
			,issuedDate
			,followUpDate
			,expiryDate
			,createdBy
			,createdDate
			,modifiedBy
			,haschanged 
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
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM bankGuarantee WITH(NOLOCK)
			WHERE bgId = @bgId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM bankGuarantee WITH(NOLOCK)
			WHERE bgId = @bgId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @bgId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM bankGuarantee WHERE approvedBy IS NULL AND bgId = @bgId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @bgId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @bgId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @bgId
					RETURN
				END
			DELETE FROM bankGuarantee WHERE bgId =  @bgId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @bgId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @bgId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @bgId
					RETURN
				END
				DELETE FROM bankGuaranteeHistory WHERE bgId = @bgId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @bgId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM bankGuarantee WITH(NOLOCK)
			WHERE bgId = @bgId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM bankGuarantee WITH(NOLOCK)
			WHERE bgId = @bgId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @bgId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM bankGuarantee WHERE approvedBy IS NULL AND bgId = @bgId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM bankGuaranteeHistory WHERE bgId = @bgId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE bankGuarantee SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE bgId = @bgId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @bgId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @bgId, @oldValue OUTPUT
				UPDATE main SET
					 main.agentId = mode.agentId
					,main.guaranteeNo = mode.guaranteeNo
					,main.amount = mode.amount
					,main.currency = mode.currency
					,main.bankName =  mode.bankName
					,main.issuedDate =  mode.issuedDate
					,main.followUpDate =  mode.followUpDate
					,main.expiryDate =  mode.expiryDate
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM bankGuarantee main
				INNER JOIN bankGuaranteeHistory mode ON mode.bgId = main.bgId
				WHERE mode.bgId = @bgId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'bankGuarantee', 'bgId', @bgId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @bgId, @oldValue OUTPUT
				UPDATE bankGuarantee SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE bgId = @bgId
			END
			
			UPDATE bankGuaranteeHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE bgId = @bgId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @bgId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @bgId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @bgId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @bgId
END CATCH



GO
