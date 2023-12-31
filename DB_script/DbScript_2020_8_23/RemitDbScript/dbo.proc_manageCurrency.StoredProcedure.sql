USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_manageCurrency]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_manageCurrency]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@ROWID							  int			 = NULL
     ,@currCode                          VARCHAR(20)    = NULL
     ,@currName                          VARCHAR(100)   = NULL
     ,@countryId                         INT            = NULL     
     ,@isActive                          CHAR(1)        = NULL
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
          @modType               VARCHAR(6)
     
     IF @flag = 'i'
     IF EXISTS(SELECT 'A' FROM manageCurrency WHERE countryId=@countryId AND currCode=@currCode AND currName=@currName AND (isDeleted IS NULL OR isDeleted=''))
     BEGIN
			IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record Already Added.' mes, @currName currName
                         RETURN
     END
     ELSE
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO manageCurrency (
                     currCode
                    ,currName
                    ,countryId
                    ,createdDate
                    ,createdBy                    
                    ,isActive
                    
               )
               SELECT
                     @currCode
                    ,@currName
                    ,@countryId
                    ,GETDATE()
                    ,@user
                    ,@isActive
               SET @ROWID = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'manageCurrency', 'ROWID', @ROWID, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'manageCurrency', @ROWID, @user, @oldValue, @newValue
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
               EXEC [dbo].proc_GetColumnToRow  'manageCurrency', 'ROWID', @ROWID, @oldValue OUTPUT
               UPDATE manageCurrency SET
                          currCode                     = @currCode
                         ,currName                     = @currName
                         ,countryId                    = @countryId                         
                         ,modifiedDate                   = GETDATE()
                         ,modifiedBy                     = @user
                         ,isActive                     = @isActive
                        
                    WHERE ROWID = @ROWID
                    EXEC [dbo].proc_GetColumnToRow  'manageCurrency', 'ROWID', @ROWID, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'manageCurrency', @ROWID, @user, @oldValue, @newValue
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
               UPDATE manageCurrency SET
                     isDeleted = 'Y'
                    ,modifiedBy = @user
                    ,modifiedDate=GETDATE()
               WHERE ROWID = @ROWID
               EXEC [dbo].proc_GetColumnToRow  'manageCurrency', 'ROWID', @ROWID, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'manageCurrency', @ROWID, @user, @oldValue, @newValue
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
