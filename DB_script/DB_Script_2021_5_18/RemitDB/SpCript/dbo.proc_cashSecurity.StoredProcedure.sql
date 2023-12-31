USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cashSecurity]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_cashSecurity]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@csId								VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@depositAcNo						VARCHAR(30)		= NULL
	,@cashDeposit						MONEY			= NULL
	,@currency                          INT				= NULL
	,@depositedDate                     DATETIME		= NULL
	,@bankName							VARCHAR(200)	= NULL
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
		 @ApprovedFunctionId = 20181432
		,@logIdentifier = 'csId'
		,@logParamMain = 'cashSecurity'
		,@logParamMod = 'cashSecurityHistory'
		,@module = '20'
		,@tableAlias = 'Cash Security'
	
	IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 csId = ISNULL(mode.csId, main.csId)
					,agentId = ISNULL(mode.agentId, main.agentId)
					,bankName = isnull(mode.bankName,main.bankName)
					,depositAcNo = ISNULL(mode.depositAcNo, main.depositAcNo)
					,cashDeposit = ISNULL(mode.cashDeposit, main.cashDeposit)
					,currency = ISNULL(mode.currency, main.currency)
					,depositedDate = ISNULL(mode.depositedDate, main.depositedDate)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.csId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM cashSecurity main WITH(NOLOCK)
					LEFT JOIN cashSecurityHistory mode ON main.csId = mode.csId AND mode.approvedBy IS NULL
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
		--ALTER TABLE cashSecurity ADD bankName VARCHAR(200)
		--ALTER TABLE cashSecurityHistory ADD bankName VARCHAR(200)
		BEGIN TRANSACTION
			INSERT INTO cashSecurity (
				 agentId
				,depositAcNo
				,cashDeposit
				,currency
				,depositedDate
				,createdBy
				,createdDate
				,bankName
			)
			SELECT
				 @agentId
				,@depositAcNo 
				,@cashDeposit
				,ISNULL(@currency,1)
				,@depositedDate
				,@user
				,GETDATE()
				,@bankName
				
				
			SET @csId = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @csId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cashSecurityHistory WITH(NOLOCK)
				WHERE csId = @csId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*,depositedDate1 =CONVERT(VARCHAR,mode.depositedDate,101)
			FROM cashSecurityHistory mode WITH(NOLOCK)
			INNER JOIN cashSecurity main WITH(NOLOCK) ON mode.csId = main.csId
			WHERE mode.csId= @csId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT *,depositedDate1 =CONVERT(VARCHAR,depositedDate,101) FROM cashSecurity WITH(NOLOCK) WHERE csId = @csId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cashSecurity WITH(NOLOCK)
			WHERE csId = @csId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @csId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM cashSecurityHistory WITH(NOLOCK)
			WHERE csId  = @csId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @csId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM cashSecurity WHERE approvedBy IS NULL AND csId  = @csId)			
			BEGIN				
				UPDATE cashSecurity SET
					 agentId = @agentId
					,depositAcNo = @depositAcNo
					,cashDeposit = @cashDeposit
					,currency = ISNULL(@currency,1)
					,depositedDate = @depositedDate
					,modifiedBy = @user
					,modifiedDate = GETDATE()
					,bankName = @bankName
			WHERE csId = @csId			
			END
			ELSE
			BEGIN
				DELETE FROM cashSecurityHistory WHERE csId = @csId AND approvedBy IS NULL
				INSERT INTO cashSecurityHistory(
					 csId
					,agentId
					,depositAcNo
					,cashDeposit
					,currency
					,depositedDate
					,createdBy
					,createdDate
					,modType
					,bankName
				)
				SELECT
					 @csId
					,@agentId
					,@depositAcNo
					,@cashDeposit
					,@currency
					,@depositedDate
					,@user
					,GETDATE()
					,'U'
					,@bankName

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @csId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM cashSecurity WITH(NOLOCK)
			WHERE csId = @csId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @csId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM cashSecurityHistory  WITH(NOLOCK)
			WHERE csId = @csId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @csId
			RETURN
		END
		SELECT @agentId = agentId FROM cashSecurity WHERE csId = @csId
		IF EXISTS(SELECT 'X' FROM cashSecurity WITH(NOLOCK) WHERE csId = @csId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			DELETE FROM cashSecurity WHERE csId = @csId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
			RETURN
		END
			INSERT INTO cashSecurityHistory(
					 csId
					,agentId
					,depositAcNo
					,cashDeposit
					,currency
					,depositedDate
					,createdBy
					,createdDate
					,modType
					,bankName
				)
				SELECT
					 csId
					,agentId
					,depositAcNo
					,cashDeposit
					,currency
					,depositedDate
					,@user
					,GETDATE()					
					,'D'
					,@bankName
				FROM cashSecurity
				WHERE csId = @csId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @agentId
	END


	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'csId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '( 
				SELECT
					 main.csId
					,main.agentId
					,main.depositAcNo
					,main.cashDeposit
					,currency = cm.currencyCode
					,main.depositedDate
					,main.createdBy
					,main.createdDate	
					,main.modifiedBy						
					,haschanged
					,bankName
				FROM ' + @table + ' main
				LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currency = cm.currencyId
				WHERE main.agentId = ' + CAST(@agentId AS VARCHAR) + '
				) x
	
				'
					
		SET @sql_filter = ''
		PRINT ('test')
		SET @select_field_list ='
			 csId
			,agentId
			,depositAcNo
			,cashDeposit
			,currency
			,depositedDate
			,createdBy
			,createdDate
			,modifiedBy
			,haschanged 
			,bankName
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
			SELECT 'X' FROM cashSecurity WITH(NOLOCK)
			WHERE csId = @csId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM cashSecurity WITH(NOLOCK)
			WHERE csId = @csId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @csId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM cashSecurity WHERE approvedBy IS NULL AND csId = @csId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @csId
					RETURN
				END
			DELETE FROM cashSecurity WHERE csId =  @csId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @csId
					RETURN
				END
				DELETE FROM cashSecurityHistory WHERE csId = @csId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @csId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM cashSecurity WITH(NOLOCK)
			WHERE csId = @csId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM cashSecurity WITH(NOLOCK)
			WHERE csId = @csId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @csId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM cashSecurity WHERE approvedBy IS NULL AND csId = @csId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM cashSecurityHistory WHERE csId = @csId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE cashSecurity SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE csId = @csId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csId, @oldValue OUTPUT
				UPDATE main SET
					 main.agentId = mode.agentId
					,main.depositAcNo = mode.depositAcNo
					,main.cashDeposit = mode.cashDeposit
					,main.currency = mode.currency
					,main.depositedDate =  mode.depositedDate
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
					,main.bankName = mode.bankName
				FROM cashSecurity main
				INNER JOIN cashSecurityHistory mode ON mode.csId = main.csId
				WHERE mode.csId = @csId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'cashSecurity', 'csId', @csId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @csId, @oldValue OUTPUT
				UPDATE cashSecurity SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE csId = @csId
			END
			
			UPDATE cashSecurityHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE csId = @csId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @csId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @csId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @csId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @csId
END CATCH


GO
