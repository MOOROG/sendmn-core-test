USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_fixedDeposit]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_fixedDeposit]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@fdId								VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@fixedDepositNo						VARCHAR(20)	= NULL
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
		,@logIdentifier = 'fdId'
		,@logParamMain = 'fixedDeposit'
		,@logParamMod = 'fixedDepositHistory'
		,@module = '20'
		,@tableAlias = 'Fixed Deposit'
	
	IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 fdId = ISNULL(mode.fdId, main.fdId)
					,agentId = ISNULL(mode.agentId, main.agentId)
					,fixedDepositNo = ISNULL(mode.fixedDepositNo, main.fixedDepositNo)
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
											(mode.fdId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM fixedDeposit main WITH(NOLOCK)
					LEFT JOIN fixedDepositHistory mode ON main.fdId = mode.fdId AND mode.approvedBy IS NULL
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
			PRINT (@table)
	
	END	
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO fixedDeposit (
				 agentId
				,fixedDepositNo
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
				,@fixedDepositNo
				,@amount
				,ISNULL(@currency,1)
				,@bankName
				,@issuedDate
				,@followUpDate
				,@expiryDate
				,@user
				,GETDATE()
				
				
			SET @fdId = SCOPE_IDENTITY()	
			UPDATE securityDocument SET securityTypeId = @fdId, sessionId = null WHERE sessionId = @sessionId AND securityType='F'		
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @fdId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM fixedDepositHistory WITH(NOLOCK)
				WHERE fdId = @fdId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*,
				issuedDate1 = CONVERT(VARCHAR,mode.issuedDate,101),
				expiryDate1 = CONVERT(VARCHAR,mode.expiryDate,101),
				followUpDate1 = CONVERT(VARCHAR,mode.followUpDate,101)
			FROM fixedDepositHistory mode WITH(NOLOCK)
			INNER JOIN fixedDeposit main WITH(NOLOCK) ON mode.fdId = main.fdId
			WHERE mode.fdId= @fdId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT *,
				issuedDate1 = CONVERT(VARCHAR,issuedDate,101),
				expiryDate1 = CONVERT(VARCHAR,expiryDate,101),
				followUpDate1 = CONVERT(VARCHAR,followUpDate,101) FROM fixedDeposit WITH(NOLOCK) WHERE fdId = @fdId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM fixedDeposit WITH(NOLOCK)
			WHERE fdId = @fdId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @fdId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM fixedDepositHistory WITH(NOLOCK)
			WHERE fdId  = @fdId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @fdId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM fixedDeposit WHERE approvedBy IS NULL AND fdId  = @fdId)			
			BEGIN				
				UPDATE fixedDeposit SET
					 agentId = @agentId
					,fixedDepositNo = @fixedDepositNo
					,amount = @amount
					,currency = ISNULL(@currency,1)
					,bankName = @bankName
					,issuedDate = @issuedDate
					,followUpDate = @followUpDate
					,expiryDate = @expiryDate
					,modifiedBy = @user
					,modifiedDate = GETDATE()
			WHERE fdId = @fdId			
			END
			ELSE
			BEGIN
				DELETE FROM fixedDepositHistory WHERE fdId = @fdId AND approvedBy IS NULL
				INSERT INTO fixedDepositHistory(
					 fdId
					,agentId
					,fixedDepositNo
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
					 @fdId
					,@agentId
					,@fixedDepositNo
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @fdId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM fixedDeposit WITH(NOLOCK)
			WHERE fdId = @fdId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @fdId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM fixedDepositHistory  WITH(NOLOCK)
			WHERE fdId = @fdId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @fdId
			RETURN
		END
		SELECT @agentId = agentId FROM fixedDeposit WHERE fdId = @fdId
		IF EXISTS(SELECT 'X' FROM fixedDeposit WITH(NOLOCK) WHERE fdId = @fdId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM fixedDeposit WHERE fdId = @fdId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
			RETURN
		END
			INSERT INTO fixedDepositHistory(
					 fdId
					,agentId
					,fixedDepositNo
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
					 fdId
					,agentId
					,fixedDepositNo
					,amount
					,currency
					,bankName
					,issuedDate
					,followUpDate
					,expiryDate
					,@user
					,GETDATE()					
					,'D'
				FROM fixedDeposit
				WHERE fdId = @fdId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
	END
	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'fdId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '( 
				SELECT
					 main.fdId
					,main.agentId
					,main.fixedDepositNo
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
		--PRINT ('test')
		SET @select_field_list ='
			 fdId
			,agentId
			,fixedDepositNo
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
			SELECT 'X' FROM fixedDeposit WITH(NOLOCK)
			WHERE fdId = @fdId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM fixedDeposit WITH(NOLOCK)
			WHERE fdId = @fdId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @fdId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM fixedDeposit WHERE approvedBy IS NULL AND fdId = @fdId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @fdId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @fdId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @fdId
					RETURN
				END
			DELETE FROM fixedDeposit WHERE fdId =  @fdId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @fdId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @fdId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @fdId
					RETURN
				END
				DELETE FROM fixedDepositHistory WHERE fdId = @fdId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @fdId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM fixedDeposit WITH(NOLOCK)
			WHERE fdId = @fdId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM fixedDeposit WITH(NOLOCK)
			WHERE fdId = @fdId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @fdId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM fixedDeposit WHERE approvedBy IS NULL AND fdId = @fdId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM fixedDepositHistory WHERE fdId = @fdId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE fixedDeposit SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE fdId = @fdId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @fdId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @fdId, @oldValue OUTPUT
				UPDATE main SET
					 main.agentId = mode.agentId
					,main.fixedDepositNo = mode.fixedDepositNo
					,main.amount = mode.amount
					,main.currency = mode.currency
					,main.bankName =  mode.bankName
					,main.issuedDate =  mode.issuedDate
					,main.followUpDate =  mode.followUpDate
					,main.expiryDate =  mode.expiryDate
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM fixedDeposit main
				INNER JOIN fixedDepositHistory mode ON mode.fdId = main.fdId
				WHERE mode.fdId = @fdId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'fixedDeposit', 'fdId', @fdId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @fdId, @oldValue OUTPUT
				UPDATE fixedDeposit SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE fdId = @fdId
			END
			
			UPDATE fixedDepositHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE fdId = @fdId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @fdId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @fdId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @fdId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @fdId
END CATCH



GO
