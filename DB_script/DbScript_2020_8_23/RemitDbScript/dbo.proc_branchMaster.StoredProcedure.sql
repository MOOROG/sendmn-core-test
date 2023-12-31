USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_branchMaster]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[proc_branchMaster]
      @flag                               VARCHAR(50)    = NULL
     ,@user                               VARCHAR(30)    = NULL
     ,@BRANCH_ID                          VARCHAR(30)    = NULL
     ,@AGENT_ID							  INT            = NULL
     ,@BRANCH_NAME                        VARCHAR(100)   = NULL
     ,@BRANCH_PHONE1                      VARCHAR(20)    = NULL
     ,@BRANCH_PHONE2                      VARCHAR(20)    = NULL
     ,@BRANCH_FAX1                        VARCHAR(20)    = NULL
     ,@BRANCH_FAX2                        VARCHAR(20)    = NULL
     ,@BRANCH_MOBILE1                     VARCHAR(20)    = NULL
     ,@BRANCH_MOBILE2                     VARCHAR(20)    = NULL
     ,@BRANCH_EMAIL1                      VARCHAR(100)   = NULL
     ,@BRANCH_EMAIL2                      VARCHAR(100)   = NULL
     ,@BRANCH_ADDRESS                     VARCHAR(200)   = NULL
     ,@BRANCH_CITY                        VARCHAR(100)   = NULL
     ,@BRANCH_COUNTRY                     VARCHAR(100)   = NULL
     ,@CONTACT_PERSON                     VARCHAR(100)   = NULL
     ,@CONTACT_PERSON_ADDRESS             VARCHAR(200)   = NULL
     ,@CONTACT_PERSON_CITY                VARCHAR(100)   = NULL
     ,@CONTACT_PERSON_COUNTRY             VARCHAR(100)   = NULL
     ,@CONTACT_PERSON_PHONE               VARCHAR(20)    = NULL
     ,@CONTACT_PERSON_FAX                 VARCHAR(20)    = NULL
     ,@CONTACT_PERSON_MOBILE              VARCHAR(20)    = NULL
     ,@CONTACT_PERSON_EMAIL               VARCHAR(100)   = NULL
     ,@IS_ACTIVE                          CHAR(10)       = NULL
     ,@sortBy                             VARCHAR(50)    = NULL
     ,@sortOrder                          VARCHAR(5)     = NULL
     ,@pageSize                           INT            = NULL
     ,@pageNumber                         INT            = NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
     CREATE TABLE #msg(error_Code INT, msg VARCHAR(100), id INT)
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
           @gridName          = 'grid_branchMaster'
   IF @flag='a'
   BEGIN
		SELECT * FROM branchMaster WHERE BRANCH_ID=@BRANCH_ID
   END        
    
     IF @flag = 'i'
     BEGIN
          BEGIN TRANSACTION
               INSERT INTO branchMaster (
                     AGENT_ID
                    ,BRANCH_NAME
                    ,BRANCH_PHONE1
                    ,BRANCH_PHONE2
                    ,BRANCH_FAX1
                    ,BRANCH_FAX2
                    ,BRANCH_MOBILE1
                    ,BRANCH_MOBILE2
                    ,BRANCH_EMAIL1
                    ,BRANCH_EMAIL2
                    ,BRANCH_ADDRESS
                    ,BRANCH_CITY
                    ,BRANCH_COUNTRY
                    ,CONTACT_PERSON
                    ,CONTACT_PERSON_ADDRESS
                    ,CONTACT_PERSON_CITY
                    ,CONTACT_PERSON_COUNTRY
                    ,CONTACT_PERSON_PHONE
                    ,CONTACT_PERSON_FAX
                    ,CONTACT_PERSON_MOBILE
                    ,CONTACT_PERSON_EMAIL
                    ,IS_ACTIVE
                    ,CREATED_DATE
                    ,CREATED_BY
                    
               )
               SELECT
                     @AGENT_ID
                    ,@BRANCH_NAME
                    ,@BRANCH_PHONE1
                    ,@BRANCH_PHONE2
                    ,@BRANCH_FAX1
                    ,@BRANCH_FAX2
                    ,@BRANCH_MOBILE1
                    ,@BRANCH_MOBILE2
                    ,@BRANCH_EMAIL1
                    ,@BRANCH_EMAIL2
                    ,@BRANCH_ADDRESS
                    ,@BRANCH_CITY
                    ,@BRANCH_COUNTRY
                    ,@CONTACT_PERSON
                    ,@CONTACT_PERSON_ADDRESS
                    ,@CONTACT_PERSON_CITY
                    ,@CONTACT_PERSON_COUNTRY
                    ,@CONTACT_PERSON_PHONE
                    ,@CONTACT_PERSON_FAX
                    ,@CONTACT_PERSON_MOBILE
                    ,@CONTACT_PERSON_EMAIL
                    ,@IS_ACTIVE
                    ,GETDATE()
                    ,@user
               SET @BRANCH_ID = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'branchMaster', 'BRANCH_ID', @BRANCH_ID, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'branchMaster', @BRANCH_ID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @BRANCH_ID id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_Code, 'Record has been added successfully' mes, @BRANCH_ID id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'branchMaster', 'BRANCH_ID', @BRANCH_ID, @oldValue OUTPUT
               UPDATE branchMaster SET
                          AGENT_ID                      = @AGENT_ID
                         ,BRANCH_NAME                   = @BRANCH_NAME
                         ,BRANCH_PHONE1                 = @BRANCH_PHONE1
                         ,BRANCH_PHONE2                 = @BRANCH_PHONE2
                         ,BRANCH_FAX1                   = @BRANCH_FAX1
                         ,BRANCH_FAX2                   = @BRANCH_FAX2
                         ,BRANCH_MOBILE1                = @BRANCH_MOBILE1
                         ,BRANCH_MOBILE2                = @BRANCH_MOBILE2
                         ,BRANCH_EMAIL1                 = @BRANCH_EMAIL1
                         ,BRANCH_EMAIL2                 = @BRANCH_EMAIL2
                         ,BRANCH_ADDRESS                = @BRANCH_ADDRESS
                         ,BRANCH_CITY                   = @BRANCH_CITY
                         ,BRANCH_COUNTRY                = @BRANCH_COUNTRY
                         ,CONTACT_PERSON                = @CONTACT_PERSON
                         ,CONTACT_PERSON_ADDRESS        = @CONTACT_PERSON_ADDRESS
                         ,CONTACT_PERSON_CITY           = @CONTACT_PERSON_CITY
                         ,CONTACT_PERSON_COUNTRY        = @CONTACT_PERSON_COUNTRY
                         ,CONTACT_PERSON_PHONE          = @CONTACT_PERSON_PHONE
                         ,CONTACT_PERSON_FAX            = @CONTACT_PERSON_FAX
                         ,CONTACT_PERSON_MOBILE         = @CONTACT_PERSON_MOBILE
                         ,CONTACT_PERSON_EMAIL          = @CONTACT_PERSON_EMAIL
                         ,IS_ACTIVE                     = @IS_ACTIVE
                         ,MODIFY_DATE                   = GETDATE()
                         ,MODIFY_BY                     = @user
                    WHERE BRANCH_ID = @BRANCH_ID
                    EXEC [dbo].proc_GetColumnToRow  'branchMaster', 'BRANCH_ID', @BRANCH_ID, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'branchMaster', @BRANCH_ID, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @BRANCH_ID id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_Code, 'Record updated successfully.' mes, @BRANCH_ID id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE branchMaster SET
                     IS_DELETE = 'Y'
                     ,MODIFY_BY=@user
                     ,MODIFY_DATE=GETDATE()
               WHERE BRANCH_ID = @BRANCH_ID
               EXEC [dbo].proc_GetColumnToRow  'branchMaster', 'BRANCH_ID', @BRANCH_ID, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'branchMaster', @BRANCH_ID, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @BRANCH_ID id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_Code, 'Record deleted successfully.' mes, @BRANCH_ID id
     END

     ELSE IF @flag = 's'
     BEGIN
          IF @sortBy IS NULL
               SET @sortBy = 'BRANCH_ID'
          IF @sortOrder IS NULL
               SET @sortOrder = 'ASC'
          SET @table = '(
               SELECT
                     main.agentId
                    ,main.BRANCH_NAME
                    ,main.BRANCH_PHONE1
                    ,main.BRANCH_PHONE2
                    ,main.BRANCH_FAX1
                    ,main.BRANCH_FAX2
                    ,main.BRANCH_MOBILE1
                    ,main.BRANCH_MOBILE2
                    ,main.BRANCH_EMAIL1
                    ,main.BRANCH_EMAIL2
                    ,main.BRANCH_ADDRESS
                    ,main.BRANCH_CITY
                    ,main.BRANCH_COUNTRY
                    ,main.CONTACT_PERSON
                    ,main.CONTACT_PERSON_ADDRESS
                    ,main.CONTACT_PERSON_CITY
                    ,main.CONTACT_PERSON_COUNTRY
                    ,main.CONTACT_PERSON_PHONE
                    ,main.CONTACT_PERSON_FAX
                    ,main.CONTACT_PERSON_MOBILE
                    ,main.CONTACT_PERSON_EMAIL
                    ,main.IS_ACTIVE
                    ,main.IS_DELETE del
                    ,main.CREATED_DATE
                    ,main.CREATED_BY
                    ,main.MODIFY_DATE
                    ,main.MODIFY_BY
                    ,CASE WHEN ISNULL(main.approvedBy, ''N'') = ''N'' THEN ''No'' ELSE ''Yes'' END isApproved
                    FROM branchMaster main WITH(NOLOCK)
          ) x'
          SET @sql_filter = ''
          SET @sql_filter = @sql_filter + ' AND ISNULL(del, '''') <> ''Y'''
          SET @select_field_list ='
                BRANCH_ID
               ,agentId
               ,BRANCH_NAME
               ,BRANCH_PHONE1
               ,BRANCH_PHONE2
               ,BRANCH_FAX1
               ,BRANCH_FAX2
               ,BRANCH_MOBILE1
               ,BRANCH_MOBILE2
               ,BRANCH_EMAIL1
               ,BRANCH_EMAIL2
               ,BRANCH_ADDRESS
               ,BRANCH_CITY
               ,BRANCH_COUNTRY
               ,CONTACT_PERSON
               ,CONTACT_PERSON_ADDRESS
               ,CONTACT_PERSON_CITY
               ,CONTACT_PERSON_COUNTRY
               ,CONTACT_PERSON_PHONE
               ,CONTACT_PERSON_FAX
               ,CONTACT_PERSON_MOBILE
               ,CONTACT_PERSON_EMAIL
               ,IS_ACTIVE
               ,IS_DELETE del
               ,CREATED_DATE
               ,CREATED_BY
               ,MODIFY_DATE
               ,MODIFY_BY'
               SET @extra_field_list = ','''' ' 
               +   CASE dbo.FNAHasRight(@user, 10101110)
                    WHEN 'Y' THEN ' + ''<a href ="manage.aspx?BRANCH_ID='' + CAST(BRANCH_ID AS VARCHAR(50)) + ''"><img border = "0" title = "Edit Account" src="../../images/but_edit.gif" /></a>'''
                    Else ''
               End
               +   CASE dbo.FNAHasRight(@user, 10101120)
                    WHEN 'Y' THEN ' + ''&nbsp;&nbsp;<img onclick = "DeleteRow('' + CAST(BRANCH_ID AS VARCHAR(50)) + '',''''' + @gridName + ''''', null);" class = "showHand" border = "0" title = "Delete Account" src="../../images/delete.gif" />'''
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
     SELECT 1 error_Code, ERROR_MESSAGE() mes, null id
END CATCH



GO
