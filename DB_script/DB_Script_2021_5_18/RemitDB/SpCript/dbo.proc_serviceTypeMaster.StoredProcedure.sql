USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_serviceTypeMaster]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_serviceTypeMaster]
      @flag									VARCHAR(50)		= NULL
     ,@user									VARCHAR(30)		= NULL
     ,@serviceTypeId                        VARCHAR(30)		= NULL
     ,@serviceCode                          VARCHAR(10)		= NULL
     ,@typeTitle							VARCHAR(30)		= NULL
     ,@typeDesc								VARCHAR(MAX)	= NULL
     ,@isActive								CHAR(1)			= NULL
     ,@sortBy								VARCHAR(50)		= NULL
     ,@sortOrder							VARCHAR(5)		= NULL
     ,@pageSize								INT				= NULL
     ,@pageNumber							INT				= NULL


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
           @gridName          = 'grid_serviceTypeMaster'
          
	
	IF @flag = 'l' --  List
	BEGIN
	
		SELECT value, [text] FROM (
			SELECT NULL value, 'All' [text] UNION ALL			
			SELECT 
				 TOP 100 PERCENT
				 stm.serviceTypeId value
				,stm.typeTitle [text]
			FROM serviceTypeMaster stm WITH (NOLOCK) 
			WHERE 
			ISNULL(stm.isDeleted, 'N')  <> 'Y' 
			AND ISNULL(stm.isActive, 'N') = 'Y'
		) x ORDER BY CASE WHEN x.[value] IS NULL THEN CAST(x.value AS VARCHAR) ELSE x.[text] END
		RETURN	
	END          
    
    ELSE IF @flag = 'l2'
    BEGIN
		SELECT 			
			 stm.serviceTypeId 
			,stm.typeTitle
		FROM serviceTypeMaster stm WITH (NOLOCK) 
		WHERE ISNULL(stm.isDeleted, 'N')  <> 'Y' 
		AND ISNULL(stm.isActive, 'N') = 'Y'
    END
	ELSE IF @flag = 'l3' -->> send page ddl
    BEGIN
		SELECT 			
			 stm.serviceTypeId 
			,stm.typeTitle
		FROM serviceTypeMaster stm WITH (NOLOCK) 
		WHERE ISNULL(stm.isDeleted, 'N')  <> 'Y' 
		AND ISNULL(stm.isActive, 'N') = 'Y'
		AND stm.serviceTypeId IN (1,2)
    END
 
     ELSE IF @flag='a'
     BEGIN
			SELECT * FROM serviceTypeMaster WHERE (isDeleted is null or isDeleted = '')
			AND serviceTypeId = @serviceTypeId
     END      
     IF @flag = 'i'
     BEGIN

	   
	   if EXISTS(Select 'X' from serviceTypeMaster WITH (NOLOCK) where 
			 ISNULL(isDeleted, 'N')  <> 'Y' and serviceCode=@serviceCode)
	   BEGIN
		  
		  SELECT 1 error_code, 'Already Exists Service Code !' mes, '1'
		  RETURN;

	   END 

        BEGIN TRANSACTION
               INSERT INTO serviceTypeMaster (
                     serviceCode
                    ,typeTitle
                    ,typeDesc
                    ,isActive
                    ,createdDate
                    ,createdBy
               )
               SELECT
                     @serviceCode
                    ,@typeTitle
                    ,@typeDesc
                    ,@isActive
                    ,GETDATE()
                    ,@user
               SET @serviceTypeId = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'serviceTypeMaster', 'serviceTypeId', @serviceTypeId, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'serviceTypeMaster', @serviceTypeId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @serviceTypeId id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @serviceTypeId id
          END

     ELSE IF @flag = 'u'
     BEGIN
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'serviceTypeMaster', 'serviceTypeId', @serviceTypeId, @oldValue OUTPUT
               UPDATE serviceTypeMaster SET
                          serviceCode               = @serviceCode
                         ,typeTitle                 = @typeTitle
                         ,typeDesc                  = @typeDesc
                         ,isActive					= @isActive
                         ,modifiedDate              = GETDATE()
                         ,modifiedBy                = @user
                    WHERE serviceTypeId = @serviceTypeId
                    EXEC [dbo].proc_GetColumnToRow  'serviceTypeMaster', 'serviceTypeId', @serviceTypeId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'serviceTypeMaster', @serviceTypeId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @serviceTypeId id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @serviceTypeId id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE serviceTypeMaster SET
                     isDeleted = 'Y'
                    ,modifiedBy = @user
                    ,modifiedDate=GETDATE()
               WHERE serviceTypeId = @serviceTypeId
               EXEC [dbo].proc_GetColumnToRow  'serviceTypeMaster', 'serviceTypeId', @serviceTypeId, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'serviceTypeMaster', @serviceTypeId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @serviceTypeId id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @serviceTypeId id
     END
ELSE IF @flag = 'l33' -->> send page ddl
    BEGIN
		SELECT 			
			 stm.serviceTypeId 
			,stm.typeTitle
		FROM serviceTypeMaster stm WITH (NOLOCK) 
		WHERE ISNULL(stm.isDeleted, 'N')  <> 'Y' 
		AND ISNULL(stm.isActive, 'N') = 'Y'
		AND stm.serviceTypeId IN (1,2,5)
    END

 
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
