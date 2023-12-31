USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_paymentModeMaster]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_paymentModeMaster]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@paymentModeId                              VARCHAR(30)    = NULL
     ,@paymentCode                          VARCHAR(10)    = NULL
     ,@modeTitle                       VARCHAR(30)    = NULL
     ,@modeDesc                          VARCHAR(MAX)   = NULL
     ,@sortBy                             VARCHAR(50)    = NULL
     ,@sortOrder                          VARCHAR(5)     = NULL
     ,@pageSize                           INT            = NULL
     ,@pageNumber                         INT            = NULL


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
           @gridName          = 'grid_paymentModeMaster'
           
     IF @flag='a'
     BEGIN
			SELECT * FROM paymentModeMaster WHERE (isDeleted is null or isDeleted = '')
     END      
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO paymentModeMaster (
                     paymentCode
                    ,modeTitle
                    ,modeDesc
                    ,createdDate
                    ,createdBy
               )
               SELECT
                     @paymentCode
                    ,@modeTitle
                    ,@modeDesc
                    ,GETDATE()
                    ,@user
               SET @paymentModeId = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'paymentModeMaster', 'paymentModeId', @paymentModeId, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'paymentModeMaster', @paymentModeId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @paymentModeId id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @paymentModeId id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'paymentModeMaster', 'paymentModeId', @paymentModeId, @oldValue OUTPUT
               UPDATE paymentModeMaster SET
                          paymentCode                     = @paymentCode
                         ,modeTitle                  = @modeTitle
                         ,modeDesc                     = @modeDesc
                         ,modifiedDate                   = GETDATE()
                         ,modifiedBy                     = @user
                    WHERE paymentModeId = @paymentModeId
                    EXEC [dbo].proc_GetColumnToRow  'paymentModeMaster', 'paymentModeId', @paymentModeId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'paymentModeMaster', @paymentModeId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @paymentModeId id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @paymentModeId id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE paymentModeMaster SET
                     isDeleted = 'Y'
                    ,modifiedBy = @user
                    ,modifiedDate=GETDATE()
               WHERE paymentModeId = @paymentModeId
               EXEC [dbo].proc_GetColumnToRow  'paymentModeMaster', 'paymentModeId', @paymentModeId, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'paymentModeMaster', @paymentModeId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @paymentModeId id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @paymentModeId id
     END

 
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
