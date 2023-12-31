USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_AGENT_FUNCTION]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_AGENT_FUNCTION]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@FUN_ID                             VARCHAR(30)    = NULL
     ,@AGENT_ID                           INT            = NULL
     ,@SERVICE_TYPE                       INT            = NULL
     ,@TRANSACTION_FEES                   MONEY          = NULL
     ,@DEFAULT_DEPOSIT_MODE               VARCHAR(30)    = NULL
     ,@INVOICE_PRINT_MODE                 INT            = NULL
     ,@CURRENCY                           INT            = NULL
     ,@COMM_SCHEME_CODE                   VARCHAR(10)    = NULL
     ,@RECEIVING_AGENTS                   INT            = NULL
     ,@RECEIVING_COUNTRY                  INT            = NULL
     ,@GLOBAL_TRN                         CHAR(1)        = NULL
     ,@TRANSACTION_MODE                   INT            = NULL
     ,@SEND_TO_RECEIVER                   CHAR(10)       = NULL
     ,@SEND_TO_SENDER                     CHAR(10)       = NULL
     ,@TRN_QUESTION                       INT            = NULL
     ,@MOBILE_FORMAT                      VARCHAR(15)    = NULL
     ,@TIME_ZONE                          INT            = NULL
     ,@ENABLE_WISHES                      VARCHAR(20)    = NULL
     

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
          
     IF	@flag='a'
     BEGIN
			SELECT * FROM AGENT_FUNCTION WHERE (IS_DELETE IS NULL OR IS_DELETE ='') AND FUN_ID=@FUN_ID
     END
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO AGENT_FUNCTION (
                     AGENT_ID
                    ,SERVICE_TYPE
                    ,TRANSACTION_FEES
                    ,DEFAULT_DEPOSIT_MODE
                    ,INVOICE_PRINT_MODE
                    ,CURRENCY
                    ,COMM_SCHEME_CODE
                    ,RECEIVING_AGENTS
                    ,RECEIVING_COUNTRY
                    ,GLOBAL_TRN
                    ,TRANSACTION_MODE
                    ,SEND_TO_RECEIVER
                    ,SEND_TO_SENDER
                    ,TRN_QUESTION
                    ,MOBILE_FORMAT
                    ,TIME_ZONE
                    ,ENABLE_WISHES
                    ,CREATED_DATE
                    ,CREATED_BY
                    
               )
               SELECT
                     @AGENT_ID
                    ,@SERVICE_TYPE
                    ,@TRANSACTION_FEES
                    ,@DEFAULT_DEPOSIT_MODE
                    ,@INVOICE_PRINT_MODE
                    ,@CURRENCY
                    ,@COMM_SCHEME_CODE
                    ,@RECEIVING_AGENTS
                    ,@RECEIVING_COUNTRY
                    ,@GLOBAL_TRN
                    ,@TRANSACTION_MODE
                    ,@SEND_TO_RECEIVER
                    ,@SEND_TO_SENDER
                    ,@TRN_QUESTION
                    ,@MOBILE_FORMAT
                    ,@TIME_ZONE
                    ,@ENABLE_WISHES
                    ,GETDATE()
                    ,@user
                   
               SET @FUN_ID = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'AGENT_FUNCTION', 'FUN_ID', @FUN_ID, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'AGENT_FUNCTION', @FUN_ID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @FUN_ID id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @FUN_ID id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'AGENT_FUNCTION', 'FUN_ID', @FUN_ID, @oldValue OUTPUT
               UPDATE AGENT_FUNCTION SET
                          AGENT_ID                      = @AGENT_ID
                         ,SERVICE_TYPE                  = @SERVICE_TYPE
                         ,TRANSACTION_FEES              = @TRANSACTION_FEES
                         ,DEFAULT_DEPOSIT_MODE          = @DEFAULT_DEPOSIT_MODE
                         ,INVOICE_PRINT_MODE            = @INVOICE_PRINT_MODE
                         ,CURRENCY                      = @CURRENCY
                         ,COMM_SCHEME_CODE              = @COMM_SCHEME_CODE
                         ,RECEIVING_AGENTS              = @RECEIVING_AGENTS
                         ,RECEIVING_COUNTRY             = @RECEIVING_COUNTRY
                         ,GLOBAL_TRN                    = @GLOBAL_TRN
                         ,TRANSACTION_MODE              = @TRANSACTION_MODE
                         ,SEND_TO_RECEIVER              = @SEND_TO_RECEIVER
                         ,SEND_TO_SENDER                = @SEND_TO_SENDER
                         ,TRN_QUESTION                  = @TRN_QUESTION
                         ,MOBILE_FORMAT                 = @MOBILE_FORMAT
                         ,TIME_ZONE                     = @TIME_ZONE
                         ,ENABLE_WISHES                 = @ENABLE_WISHES                         
                         ,MODIFY_DATE                   = GETDATE()
                         ,MODIFY_BY                     = @user
                        
                    WHERE FUN_ID = @FUN_ID
                    EXEC [dbo].proc_GetColumnToRow  'AGENT_FUNCTION', 'FUN_ID', @FUN_ID, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'AGENT_FUNCTION', @FUN_ID, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @FUN_ID id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @FUN_ID id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE AGENT_FUNCTION SET
                     IS_DELETE		= 'Y'
                    ,MODIFY_BY		= @user
                    ,MODIFY_DATE	= GETDATE()
               WHERE FUN_ID = @FUN_ID
               EXEC [dbo].proc_GetColumnToRow  'AGENT_FUNCTION', 'FUN_ID', @FUN_ID, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'AGENT_FUNCTION', @FUN_ID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @FUN_ID id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @FUN_ID id
     END

 
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH


GO
