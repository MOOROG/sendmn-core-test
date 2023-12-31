USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_AGENT_BAL_MASTER]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_AGENT_BAL_MASTER]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@ROWID                              VARCHAR(30)    = NULL
     ,@AGENT_ID                           INT            = NULL
     ,@MAX_LIMIT_AMT                      MONEY          = NULL
     ,@BASE_LIMIT_AMT                     MONEY          = NULL
     ,@TEMP_LIMIT_AMT                     MONEY          = NULL
     ,@TODAY_SENT_AMT                     MONEY          = NULL
     ,@TODAY_PAID_AMT                     MONEY          = NULL
     ,@TODAY_CANCLE_AMT                   MONEY          = NULL
     ,@AC_BAL_AMT                         MONEY          = NULL
     ,@HELD_AMT                           MONEY          = NULL
     ,@SYSTEM_RES_AMT                     MONEY          = NULL
     

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
          
    IF @flag='a'
    BEGIN
			SELECT * FROM AGENT_BAL_MASTER WHERE (IS_DELETE IS NULL OR IS_DELETE ='')
	END
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO AGENT_BAL_MASTER (
					 AGENT_ID
                    ,MAX_LIMIT_AMT
                    ,BASE_LIMIT_AMT
                    ,TEMP_LIMIT_AMT
                    ,TODAY_SENT_AMT
                    ,TODAY_PAID_AMT
                    ,TODAY_CANCLE_AMT
                    ,AC_BAL_AMT
                    ,HELD_AMT
                    ,SYSTEM_RES_AMT
                    ,CREATED_DATE
                    ,CREATED_BY
                    
               )
               SELECT
                     @AGENT_ID
                    ,@MAX_LIMIT_AMT
                    ,@BASE_LIMIT_AMT
                    ,@TEMP_LIMIT_AMT
                    ,@TODAY_SENT_AMT
                    ,@TODAY_PAID_AMT
                    ,@TODAY_CANCLE_AMT
                    ,@AC_BAL_AMT
                    ,@HELD_AMT
                    ,@SYSTEM_RES_AMT
                    ,GETDATE()
                    ,@user
                    
               SET @ROWID = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'AGENT_BAL_MASTER', 'ROWID', @ROWID, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'AGENT_BAL_MASTER', @ROWID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @ROWID id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @ROWID id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'AGENT_BAL_MASTER', 'ROWID', @ROWID, @oldValue OUTPUT
               UPDATE AGENT_BAL_MASTER SET
                          AGENT_ID						= @AGENT_ID
                         ,MAX_LIMIT_AMT                 = @MAX_LIMIT_AMT
                         ,BASE_LIMIT_AMT                = @BASE_LIMIT_AMT
                         ,TEMP_LIMIT_AMT                = @TEMP_LIMIT_AMT
                         ,TODAY_SENT_AMT                = @TODAY_SENT_AMT
                         ,TODAY_PAID_AMT                = @TODAY_PAID_AMT
                         ,TODAY_CANCLE_AMT              = @TODAY_CANCLE_AMT
                         ,AC_BAL_AMT                    = @AC_BAL_AMT
                         ,HELD_AMT                      = @HELD_AMT
                         ,SYSTEM_RES_AMT                = @SYSTEM_RES_AMT                        
                         ,MODIFY_DATE                   = GETDATE()
                         ,MODIFY_BY                     = @user
                         
                    WHERE ROWID = @ROWID
                    EXEC [dbo].proc_GetColumnToRow  'AGENT_BAL_MASTER', 'ROWID', @ROWID, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'AGENT_BAL_MASTER', @ROWID, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @ROWID id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @ROWID id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE AGENT_BAL_MASTER SET
                     IS_DELETE		= 'Y'
                    ,MODIFY_BY		= @user
                    ,MODIFY_DATE	=GETDATE()
               WHERE ROWID = @ROWID
               EXEC [dbo].proc_GetColumnToRow  'AGENT_BAL_MASTER', 'ROWID', @ROWID, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'AGENT_BAL_MASTER', @ROWID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @ROWID id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @ROWID id
     END

 
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH


GO
