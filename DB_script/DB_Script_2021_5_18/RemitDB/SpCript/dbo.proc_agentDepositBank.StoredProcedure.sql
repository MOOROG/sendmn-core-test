USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentDepositBank]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_agentDepositBank]
      @flag                             VARCHAR(50)		= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@agentDepositBankId				INT				= NULL
     ,@agentId                          INT				= NULL
     ,@bankName                         INT				= NULL
     ,@bankAcctNum                      VARCHAR(30)		= NULL
     ,@Description						VARCHAR(100)	= NULL
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
     CREATE TABLE #msg(error_code INT, msg VARCHAR(100), id INT)
     DECLARE
           @sql           VARCHAR(MAX)
          ,@oldValue      VARCHAR(MAX)
          ,@newValue      VARCHAR(MAX)
          ,@tableName     VARCHAR(50)
     DECLARE
           @select_field_list VARCHAR(MAX)
          ,@extra_field_list  VARCHAR(MAX)
          ,@table             VARCHAR(MAX)
          ,@sql_filter        VARCHAR(MAX)
     DECLARE
           @gridName              VARCHAR(50)
          ,@modType               VARCHAR(6)
     SELECT
           @gridName          = 'grid_agentDepositBank'
           
     IF @flag='a'
     BEGIN
			SELECT * FROM agentDepositBank WHERE (isDeleted IS NULL OR isDeleted = '')
			AND agentDepositBankId = @agentDepositBankId
     END      
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO agentDepositBank (
					 agentId
                    ,bankName
                    ,bankAcctNum
                    ,[description]
                    ,createdDate
                    ,createdBy
               )
               SELECT
					 @agentId
                    ,@bankName
                    ,@bankAcctNum
                    ,@description
                    ,GETDATE()
                    ,@user
               SET @agentDepositBankId = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'agentDepositBank', 'agentDepositBankId', @agentDepositBankId, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'agentDepositBank', @agentDepositBankId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @agentDepositBankId id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @agentDepositBankId id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'agentDepositBank', 'agentDepositBankId', @agentDepositBankId, @oldValue OUTPUT
               UPDATE agentDepositBank SET
                          bankName                     = @bankName
                         ,bankAcctNum                  = @bankAcctNum
                         ,[description]                = @description
                         ,modifiedDate                 = GETDATE()
                         ,modifiedBy                   = @user
                    WHERE agentDepositBankId = @agentDepositBankId
                    EXEC [dbo].proc_GetColumnToRow  'agentDepositBank', 'agentDepositBankId', @agentDepositBankId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'agentDepositBank', @agentDepositBankId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @agentDepositBankId id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @agentDepositBankId id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE agentDepositBank SET
                     isDeleted = 'Y'
                    ,modifiedBy = @user
                    ,modifiedDate=GETDATE()
               WHERE agentDepositBankId = @agentDepositBankId
               EXEC [dbo].proc_GetColumnToRow  'agentDepositBank', 'agentDepositBankId', @agentDepositBankId, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'agentDepositBank', @agentDepositBankId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @agentDepositBankId id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @agentDepositBankId id
     END

 
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH


GO
