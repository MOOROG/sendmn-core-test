USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_userMaster]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_userMaster]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@USER_ID                            VARCHAR(30)    = NULL
     ,@AGENT_ID	                          INT            = NULL
     ,@BRANCH_ID	                      INT            = NULL
     ,@USER_NAME                          VARCHAR(100)   = NULL
     ,@USER_CODE                          VARCHAR(50)    = NULL
     ,@USER_PHONE1                        VARCHAR(20)    = NULL
     ,@USER_PHONE2                        VARCHAR(20)    = NULL
     ,@USER_MOBILE1                       VARCHAR(20)    = NULL
     ,@USER_MOILE2                        VARCHAR(20)    = NULL
     ,@USER_FAX1                          VARCHAR(20)    = NULL
     ,@USER_FAX2                          VARCHAR(20)    = NULL
     ,@USER_EMAIL1                        VARCHAR(100)   = NULL
     ,@USER_EMAIL2                        VARCHAR(100)   = NULL
     ,@USER_ADDRESS_PERMANENT             VARCHAR(200)   = NULL
     ,@PERMA_CITY                         VARCHAR(100)   = NULL
     ,@PEMA_COUNTRY                       VARCHAR(100)   = NULL
     ,@USER_ADDRESS_TEMP                  VARCHAR(200)   = NULL
     ,@TEMP_CITY                          VARCHAR(100)   = NULL
     ,@TEMP_COUNTRY                       VARCHAR(100)   = NULL
     ,@CONTACT_PERSON                     VARCHAR(100)   = NULL
     ,@CONTACT_PERSON_ADDRESS             VARCHAR(200)   = NULL
     ,@CONTACT_PERSON_PHONE               VARCHAR(20)    = NULL
     ,@CONTACT_PERSON_FAX                 VARCHAR(20)    = NULL
     ,@CONTACT_PERSON_MOBILE              VARCHAR(20)    = NULL
     ,@CONTACT_PERSON_EMAIL               VARCHAR(100)   = NULL
     ,@IS_ACTIVE                          CHAR(1)        = NULL
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
           @gridName          = 'grid_userMaster'
      IF @flag='a'
      BEGIN
			SELECT * FROM  userMaster WHERE USER_ID=@USER_ID
      END     
      
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO userMaster (
                     AGENT_ID
                    ,BRANCH_ID
                    ,USER_NAME
                    ,USER_CODE
                    ,USER_PHONE1
                    ,USER_PHONE2
                    ,USER_MOBILE1
                    ,USER_MOILE2
                    ,USER_FAX1
                    ,USER_FAX2
                    ,USER_EMAIL1
                    ,USER_EMAIL2
                    ,USER_ADDRESS_PERMANENT
                    ,PERMA_CITY
                    ,PEMA_COUNTRY
                    ,USER_ADDRESS_TEMP
                    ,TEMP_CITY
                    ,TEMP_COUNTRY
                    ,CONTACT_PERSON
                    ,CONTACT_PERSON_ADDRESS
                    ,CONTACT_PERSON_PHONE
                    ,CONTACT_PERSON_FAX
                    ,CONTACT_PERSON_MOBILE
                    ,CONTACT_PERSON_EMAIL
                    ,IS_ACTIVE
                    ,CREATE_DATE
                    ,CREATED_BY
               )
               SELECT
                     @AGENT_ID
                    ,@BRANCH_ID
                    ,@USER_NAME
                    ,@USER_CODE
                    ,@USER_PHONE1
                    ,@USER_PHONE2
                    ,@USER_MOBILE1
                    ,@USER_MOILE2
                    ,@USER_FAX1
                    ,@USER_FAX2
                    ,@USER_EMAIL1
                    ,@USER_EMAIL2
                    ,@USER_ADDRESS_PERMANENT
                    ,@PERMA_CITY
                    ,@PEMA_COUNTRY
                    ,@USER_ADDRESS_TEMP
                    ,@TEMP_CITY
                    ,@TEMP_COUNTRY
                    ,@CONTACT_PERSON
                    ,@CONTACT_PERSON_ADDRESS
                    ,@CONTACT_PERSON_PHONE
                    ,@CONTACT_PERSON_FAX
                    ,@CONTACT_PERSON_MOBILE
                    ,@CONTACT_PERSON_EMAIL
                    ,@IS_ACTIVE
                    ,GETDATE()
                    ,@user
               SET @USER_ID = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'userMaster', 'USER_ID', @USER_ID, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'userMaster', @USER_ID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @USER_ID id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @USER_ID id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'userMaster', 'USER_ID', @USER_ID, @oldValue OUTPUT
               UPDATE userMaster SET
                          AGENT_ID                     = @AGENT_ID
                         ,BRANCH_ID						=@BRANCH_ID
                         ,USER_NAME                     = @USER_NAME
                         ,USER_CODE                     = @USER_CODE
                         ,USER_PHONE1                   = @USER_PHONE1
                         ,USER_PHONE2                   = @USER_PHONE2
                         ,USER_MOBILE1                  = @USER_MOBILE1
                         ,USER_MOILE2                   = @USER_MOILE2
                         ,USER_FAX1                     = @USER_FAX1
                         ,USER_FAX2                     = @USER_FAX2
                         ,USER_EMAIL1                   = @USER_EMAIL1
                         ,USER_EMAIL2                   = @USER_EMAIL2
                         ,USER_ADDRESS_PERMANENT        = @USER_ADDRESS_PERMANENT
                         ,PERMA_CITY                    = @PERMA_CITY
                         ,PEMA_COUNTRY                  = @PEMA_COUNTRY
                         ,USER_ADDRESS_TEMP             = @USER_ADDRESS_TEMP
                         ,TEMP_CITY                     = @TEMP_CITY
                         ,TEMP_COUNTRY                  = @TEMP_COUNTRY
                         ,CONTACT_PERSON                = @CONTACT_PERSON
                         ,CONTACT_PERSON_ADDRESS        = @CONTACT_PERSON_ADDRESS
                         ,CONTACT_PERSON_PHONE          = @CONTACT_PERSON_PHONE
                         ,CONTACT_PERSON_FAX            = @CONTACT_PERSON_FAX
                         ,CONTACT_PERSON_MOBILE         = @CONTACT_PERSON_MOBILE
                         ,CONTACT_PERSON_EMAIL          = @CONTACT_PERSON_EMAIL
                         ,IS_ACTIVE                     = @IS_ACTIVE
                         ,MODIFY_DATE                   = GETDATE()
                         ,MODIFY_BY                     = @user
                    WHERE USER_ID = @USER_ID
                    EXEC [dbo].proc_GetColumnToRow  'userMaster', 'USER_ID', @USER_ID, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'userMaster', @USER_ID, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @USER_ID id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @USER_ID id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE userMaster SET
                     IS_DELETE = 'Y'
                    ,MODIFY_BY = @user
                    ,MODIFY_DATE=GETDATE()
               WHERE USER_ID = @USER_ID
               EXEC [dbo].proc_GetColumnToRow  'userMaster', 'USER_ID', @USER_ID, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'userMaster', @USER_ID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @USER_ID id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @USER_ID id
     END

     ELSE IF @flag = 's'
     BEGIN
          IF @sortBy IS NULL
               SET @sortBy = 'USER_ID'
          IF @sortOrder IS NULL
               SET @sortOrder = 'ASC'
          SET @table = '(
               SELECT
                     main.BRANCH_ID
                    ,main.USER_NAME
                    ,main.USER_CODE
                    ,main.USER_PHONE1
                    ,main.USER_PHONE2
                    ,main.USER_MOBILE1
                    ,main.USER_MOILE2
                    ,main.USER_FAX1
                    ,main.USER_FAX2
                    ,main.USER_EMAIL1
                    ,main.USER_EMAIL2
                    ,main.USER_ADDRESS_PERMANENT
                    ,main.PERMA_CITY
                    ,main.PEMA_COUNTRY
                    ,main.USER_ADDRESS_TEMP
                    ,main.TEMP_CITY
                    ,main.TEMP_COUNTRY
                    ,main.CONTACT_PERSON
                    ,main.CONTACT_PERSON_ADDRESS
                    ,main.CONTACT_PERSON_PHONE
                    ,main.CONTACT_PERSON_FAX
                    ,main.CONTACT_PERSON_MOBILE
                    ,main.CONTACT_PERSON_EMAIL
                    ,main.IS_ACTIVE
                    ,main.IS_DELETE del
                    ,main.CREATE_DATE
                    ,main.CREATED_BY
                    ,main.MODIFY_DATE
                    ,main.MODIFY_BY
                    ,CASE WHEN ISNULL(main.approvedBy, ''N'') = ''N'' THEN ''No'' ELSE ''Yes'' END isApproved
                    FROM userMaster main WITH(NOLOCK)
          ) x'
          SET @sql_filter = ''
          SET @sql_filter = @sql_filter + ' AND ISNULL(del, '''') <> ''Y'''
          SET @select_field_list ='
                USER_ID
               ,BRANCH_ID
               ,USER_NAME
               ,USER_CODE
               ,USER_PHONE1
               ,USER_PHONE2
               ,USER_MOBILE1
               ,USER_MOILE2
               ,USER_FAX1
               ,USER_FAX2
               ,USER_EMAIL1
               ,USER_EMAIL2
               ,USER_ADDRESS_PERMANENT
               ,PERMA_CITY
               ,PEMA_COUNTRY
               ,USER_ADDRESS_TEMP
               ,TEMP_CITY
               ,TEMP_COUNTRY
               ,CONTACT_PERSON
               ,CONTACT_PERSON_ADDRESS
               ,CONTACT_PERSON_PHONE
               ,CONTACT_PERSON_FAX
               ,CONTACT_PERSON_MOBILE
               ,CONTACT_PERSON_EMAIL
               ,IS_ACTIVE
               ,IS_DELETE del
               ,CREATE_DATE
               ,CREATED_BY
               ,MODIFY_DATE
               ,MODIFY_BY'
               SET @extra_field_list = ','''' ' 
               +   CASE dbo.FNAHasRight(@user, 10101210)
                    WHEN 'Y' THEN ' + ''<a href ="manage.aspx?USER_ID='' + CAST(USER_ID AS VARCHAR(50)) + ''"><img border = "0" title = "Edit Account" src="../../images/but_edit.gif" /></a>'''
                    Else ''
               End
               +   CASE dbo.FNAHasRight(@user, 10101220)
                    WHEN 'Y' THEN ' + ''&nbsp;&nbsp;<img onclick = "DeleteRow('' + CAST(USER_ID AS VARCHAR(50)) + '',''''' + @gridName + ''''', null);" class = "showHand" border = "0" title = "Delete Account" src="../../images/delete.gif" />'''
                    Else ''
                End
               + ' [edit]'
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
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
