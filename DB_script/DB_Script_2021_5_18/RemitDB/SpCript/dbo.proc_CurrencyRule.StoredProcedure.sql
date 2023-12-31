USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_CurrencyRule]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_CurrencyRule]
      @flag					VARCHAR(50)  = NULL
     ,@user					VARCHAR(30)  = NULL
     ,@ROWID				Int			 = NULL
     ,@ruleId				VARCHAR(20)	 = NULL
     ,@ruleName			VARCHAR(30)	 = NULL	
     ,@currCode			VARCHAR(30)	 = NULL
     ,@countryId           INT          = NULL     
     ,@isActive            CHAR(1)      = NULL
    

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
          @modType               VARCHAR(6)
     
     IF @flag = 'i'
     IF  EXISTS(SELECT 'A' FROM CurrencyRule WHERE countryId=@countryId AND ruleId=@ruleId AND (isDeleted IS NULL OR isDeleted=''))
     BEGIN
			IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record Already Added.' mes, @ruleId ruleId
                         RETURN
     END
     ELSE
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO CurrencyRule (
                     ruleId
                    ,ruleName
                    ,countryId
                    ,currCode
                    ,createdDate
                    ,createdBy                    
                    ,isActive
                    
               )
               SELECT
                     @ruleId
                    ,@ruleName
                    ,@countryId
                    ,@currCode
                    ,GETDATE()
                    ,@user
                    ,@isActive
               SET @ROWID = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'CurrencyRule', 'ROWID', @ROWID, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'CurrencyRule', @ROWID, @user, @oldValue, @newValue
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

    

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE CurrencyRule SET
                     isDeleted = 'Y'
                    ,modifiedBy = @user
                    ,modifiedDate=GETDATE()
               WHERE ROWID = @ROWID
               EXEC [dbo].proc_GetColumnToRow  'CurrencyRule', 'ROWID', @ROWID, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'CurrencyRule', @ROWID, @user, @oldValue, @newValue
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
