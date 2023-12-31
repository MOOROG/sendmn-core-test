USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_fundDepositRequest]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select * from fundDeposit
*/

CREATE proc [dbo].[proc_fundDepositRequest]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(200)	= NULL
	,@rowId								VARCHAR(50)		= NULL
	,@agentId							VARCHAR(50)		= NULL
	,@bankId							VARCHAR(50)		= NULL
	,@branchId							VARCHAR(50)		= NULL
	,@amount							MONEY			= NULL
	,@depositedDate						varchar(50)		= NULL
	,@remarks							VARCHAR(MAX)	= NULL
	,@sessionAgentId					VARCHAR(50)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@Msg								VARCHAR(20)		= NULL

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
		,@tranAmount		MONEY
	SELECT
		 @ApprovedFunctionId = 20122330
		,@logIdentifier = 'rowId'
		,@logParamMain = 'fundDeposit'
		,@logParamMod = 'fundDepositMod'
		,@module = '20'
		,@tableAlias = 'Fund Deposit Request'
	
	IF @flag IN ('s')
	BEGIN
	
		SET @table = '(
				SELECT
					 rowId = ISNULL(mode.rowId, main.rowId)
					,agentId =dbo.GetAgentNameFromId(ISNULL(mode.agentId, main.agentId)) 
					,bankId =dbo.GetAgentNameFromId(ISNULL(mode.bankId, main.bankId))
					,branchId = dbo.GetAgentNameFromId(ISNULL(mode.branchId, main.branchId))
					,amount = ISNULL(mode.amount, main.amount)
					,depositedDate=convert(varchar,ISNULL(mode.depositedDate, main.depositedDate),107)
					,remarks = ISNULL(mode.remarks, main.remarks)
					,main.createdBy
					,main.createdDate
					,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
					,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.rowId IS NOT NULL) 
										THEN ''Y'' ELSE '''' END

				FROM fundDeposit main WITH(NOLOCK)
					LEFT JOIN fundDepositMod mode ON main.rowId = mode.rowId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE 
						main.approvedDate is null
						AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
							
						
						
			) '

	
	END	
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRANSACTION
			--alter table fundDeposit add depositedDate datetime
			--alter table fundDepositMod add depositedDate datetime
			INSERT INTO fundDeposit (
				 agentId
				,bankId
				,branchId
				,amount
				,depositedDate
				,remarks 
				,createdBy
				,createdDate
			)
			SELECT
				 @agentId
				,@bankId
				,@branchId
				,@amount
				,@depositedDate
				,@remarks
				,@user
				,GETDATE()	
				
			SET @rowId = SCOPE_IDENTITY()		
			DECLARE @MESSAGE AS VARCHAR(MAX)
			SET @MESSAGE='Fund Deposit has been requested!'
			EXEC proc_transactionLogs 'i', @user, @rowId, @message
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM fundDepositMod WITH(NOLOCK)
				WHERE rowId = @rowId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN

			SELECT mode.rowId,mode.bankId,mode.agentId,dbo.ShowDecimalExceptComma(mode.amount) amount,mode.remarks,
			convert(varchar,depositedDate,101) depositedDate,agent.agentName,mode.createdBy,convert(varchar,mode.createdDate,107) createdDate
			FROM fundDepositMod mode WITH(NOLOCK)
				INNER JOIN agentMaster bank WITH(NOLOCK) ON mode.bankId = bank.agentId
				INNER JOIN agentMaster agent WITH (NOLOCK) ON mode.agentId = agent.agentId
			WHERE mode.rowId= @rowId AND mode.approvedBy IS NULL

		END
		ELSE
		BEGIN
			SELECT main.rowId,main.bankId,main.agentId,dbo.ShowDecimalExceptComma(main.amount) amount,main.remarks,
			convert(varchar,depositedDate,101) depositedDate,agent.agentName,main.createdBy,convert(varchar,main.createdDate,107) createdDate
			FROM fundDeposit main WITH(NOLOCK) 
				INNER JOIN agentMaster bank WITH (NOLOCK) ON main.bankId = bank.agentId
				INNER JOIN agentMaster agent WITH (NOLOCK) ON main.agentId = agent.agentId
			WHERE rowId = @rowId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM fundDeposit WITH(NOLOCK)
			WHERE rowId = @rowId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @rowId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM fundDepositMod WITH(NOLOCK)
			WHERE rowId = @rowId AND (createdBy<> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous modification has not been approved yet.', @rowId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM fundDeposit WHERE approvedBy IS NULL AND rowId  = @rowId)			
			BEGIN
				
				--select * from fundDeposit
				UPDATE fundDeposit SET
						 bankId = @bankId
						,branchId = @branchId
						,amount = @amount
						,depositedDate= @depositedDate
						,remarks=@remarks
						,modifiedBy = @user
						,modifiedDate = GETDATE()
				WHERE rowId = @rowId	
			
		
			END
			ELSE
			BEGIN
				DELETE FROM fundDepositMod WHERE rowId=@rowId AND approvedBy IS NULL

				INSERT INTO fundDepositMod
				(
						 rowId
						,agentId 
						,bankId 
						,branchId 
						,amount 
						,depositedDate
						,remarks
						,modifiedBy 
						,modifiedDate
						,modType
				)
				SELECT
					 @rowId
					,@agentId
					,@bankId
					,@branchId
					,@amount
					,@depositedDate
					,@remarks					
					,@user
					,GETDATE()
					,'U'				


			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @rowId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM fundDeposit WITH(NOLOCK)
			WHERE rowId = @rowId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.', @rowId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM fundDepositMod  WITH(NOLOCK)
			WHERE rowId = @rowId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Previous modification has not been approved yet.',  @rowId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM fundDeposit WITH(NOLOCK)
			WHERE rowId = @rowId  AND approvedDate is not null
			)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not delete this record. Record has been already approved.', @rowId
			RETURN
		END

		IF EXISTS(SELECT 'X' FROM fundDeposit WITH(NOLOCK) WHERE rowId = @rowId AND approvedBy IS NULL AND createdBy = @user)
		BEGIN
			UPDATE   fundDeposit SET
					 isDeleted = 'Y'
					,modifiedBy = @user
					,modifiedDate = GETDATE()
			WHERE rowId = @rowId

			EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
			RETURN
		END
			INSERT INTO fundDepositMod(
					 rowid
					,agentId
					,bankId
					,branchId
					,amount
					,depositedDate
					,remarks
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 rowId
					,agentId
					,bankId
					,branchId
					,amount
					,depositedDate
					,remarks
					,@user
					,GETDATE()					
					,'D'	
				FROM fundDeposit
				WHERE rowid = @rowId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
	END
			
	ELSE IF @flag = 's'
	BEGIN

		IF @sortBy IS NULL
			SET @sortBy = 'rowId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		--print @table
		--return;
		SET @table = '( 
				SELECT
					 main.rowId
					,main.agentId
					,main.bankId
					,main.branchId
					,main.amount
					,main.depositedDate
					,main.remarks
					,main.createdBy
					,main.createdDate
					,main.modifiedBy							
					,haschanged					
				FROM ' + @table + ' main
				) x
	
				'
					
		SET @sql_filter = ''
		
		IF @bankId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(bankId, '''') LIKE ''%' + @bankId + '%'''
		
		
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentId, '''') LIKE ''%' + @agentId + '%'''
			
		SET @select_field_list ='
					 rowId
					,agentId
					,bankId
					,branchId
					,amount
					,depositedDate
					,remarks
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
			SELECT 'X' FROM fundDeposit WITH(NOLOCK)
			WHERE rowId = @rowId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM fundDeposit WITH(NOLOCK)
			WHERE rowId = @rowId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rowId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM fundDeposit WHERE approvedBy IS NULL AND rowId = @rowId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rowId
					RETURN
				END
			DELETE FROM fundDeposit WHERE rowId =  @rowId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @rowId
					RETURN
				END
				DELETE FROM fundDepositMod WHERE rowId = @rowId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @rowId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM fundDeposit WITH(NOLOCK)
			WHERE rowId = @rowId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM fundDeposit WITH(NOLOCK)
			WHERE rowId = @rowId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @rowId
			RETURN
		END
		BEGIN TRANSACTION
			
			IF EXISTS (SELECT 'X' FROM fundDeposit WHERE approvedBy IS NULL AND rowId = @rowId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM fundDepositMod WHERE rowId = @rowId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE fundDeposit SET
					 isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE rowId = @rowId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT

			--END
			
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT
				UPDATE main SET
					 main.agentId = mode.agentid
					,main.bankId = mode.bankId
					,main.branchId =  mode.branchId
					,main.amount =  mode.amount
					,main.depositedDate =  mode.depositedDate
					,main.remarks= mode.remarks
					,main.modifiedDate = GETDATE()
					,main.modifiedBy = @user
				FROM fundDeposit main
				INNER JOIN fundDepositMod mode ON mode.rowId = main.rowId
				WHERE mode.rowId = @rowId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'errPaidTran', 'trnId', @rowId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @oldValue OUTPUT
				UPDATE fundDeposit SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE rowId = @rowId
			END
			
			UPDATE fundDepositMod SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE rowId = @rowId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @rowId
	END
	
	ELSE IF @flag='sA'
	BEGIN
		SELECT agentName FROM agentMaster WHERE agentId=@agentId
	END
	ELSE IF @flag='bank'
	BEGIN
		SELECT agentId,agentName FROM agentMaster WHERE agentType=2905
		
		--select distinct agentType from agentMaster
		--select * from staticDataValue where valueId=2905
	END
	
	ELSE IF @flag ='agentGrid'
	BEGIN
	
		SET @table = '(
				SELECT
					 rowId = ISNULL(mode.rowId, main.rowId)
					,agentId =dbo.GetAgentNameFromId(ISNULL(mode.agentId, main.agentId)) 
					,bankId =dbo.GetAgentNameFromId(ISNULL(mode.bankId, main.bankId))
					,branchId = dbo.GetAgentNameFromId(ISNULL(mode.branchId, main.branchId))
					,amount = ISNULL(mode.amount, main.amount)
					,depositedDate=convert(varchar,ISNULL(mode.depositedDate, main.depositedDate),107)
					,remarks = ISNULL(mode.remarks, main.remarks)
					,main.createdBy
					,main.createdDate
					,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
					,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.rowId IS NOT NULL) 
										THEN ''Y'' ELSE '''' END

				FROM fundDeposit main WITH(NOLOCK)
					LEFT JOIN fundDepositMod mode ON main.rowId = mode.rowId WHERE main.approvedDate IS NULL
					AND main.agentId='''+@sessionAgentId+'''
						
					
						
			) '
		IF @sortBy IS NULL
			SET @sortBy = 'rowId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		--print @table
		--return;
		SET @table = '( 
				SELECT
					 main.rowId
					,main.agentId
					,main.bankId
					,main.branchId
					,main.amount
					,main.depositedDate
					,main.remarks
					,main.createdBy
					,main.createdDate
					,main.modifiedBy							
					,haschanged					
				FROM ' + @table + ' main
				) x
	
				'
					
		SET @sql_filter = ''
		
		IF @bankId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(bankId, '''') LIKE ''%' + @bankId + '%'''
		
		
		IF @agentId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(agentId, '''') LIKE ''%' + @agentId + '%'''
			
		SET @select_field_list ='
					 rowId
					,agentId
					,bankId
					,branchId
					,amount
					,depositedDate
					,remarks
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

END TRY
BEGIN CATCH

     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowId

END CATCH


GO
