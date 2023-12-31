USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_RoleStaticDataValue]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_RoleStaticDataValue]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@valueId                            VARCHAR(30)    = NULL
     ,@typeID                             INT            = NULL
     ,@detailTitle                        VARCHAR(MAX)   = NULL
     ,@detailDesc                         VARCHAR(MAX)   = NULL
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
     
     
     IF @flag='a'
     BEGIN
			SELECT * FROM staticDataValue WHERE valueId=@valueId
     END
           
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO staticDataValue (
                     typeID
                    ,detailTitle
                    ,detailDesc                   
                    ,createdBy
                    ,createdDate
               )
               SELECT
                     @typeID
                    ,@detailTitle
                    ,@detailDesc                  
                    ,@user
                    ,GETDATE()
                    
               SET @valueId = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'staticDataValue', 'valueId', @valueId, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'staticDataValue', @valueId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @valueId id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @valueId id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'staticDataValue', 'valueId', @valueId, @oldValue OUTPUT
               UPDATE staticDataValue SET
                          typeID                        = @typeID
                         ,detailTitle                   = @detailTitle
                         ,detailDesc                    = @detailDesc
                         ,modifiedBy     = @user
                         ,modifiedDate   = GETDATE()
                    WHERE valueId = @valueId
                    
                    EXEC [dbo].proc_GetColumnToRow  'staticDataValue', 'valueId', @valueId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'staticDataValue', @valueId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @valueId id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @valueId id 
     END


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
