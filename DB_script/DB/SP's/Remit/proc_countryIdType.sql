

ALTER PROC [dbo].[proc_countryIdType]  
   @flag        VARCHAR(50)  = NULL  
 ,@user                              VARCHAR(30)  = NULL  
 ,@countryIdtypeId           VARCHAR(30)  = NULL  
 ,@countryId                         INT    = NULL  
 ,@IdtypeId                         INT    = NULL  
 ,@spFlag                            INT    = NULL  
 ,@expiryType      CHAR(1)   = NULL  
 ,@sortBy                            VARCHAR(50)  = NULL  
 ,@sortOrder                         VARCHAR(5)  = NULL  
 ,@pageSize                          INT    = NULL  
 ,@pageNumber                        INT    = NULL  
  
  
AS  
SET NOCOUNT ON  
SET XACT_ABORT ON  
BEGIN TRY  
 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)  
 DECLARE  
   @sql    VARCHAR(MAX)  
  ,@oldValue   VARCHAR(MAX)  
  ,@newValue   VARCHAR(MAX)  
  ,@module   VARCHAR(10)  
  ,@tableAlias  VARCHAR(100)  
  ,@logIdentifier  VARCHAR(50)  
  ,@logParamMod  VARCHAR(100)  
  ,@logParamMain  VARCHAR(100)  
  ,@table    VARCHAR(MAX)  
  ,@select_field_list VARCHAR(MAX)  
  ,@extra_field_list VARCHAR(MAX)  
  ,@sql_filter  VARCHAR(MAX)  
  ,@modType   VARCHAR(6)  
 SELECT  
   @logIdentifier = 'countryIdtypeId'  
  ,@logParamMain = 'countryIdType'  
  ,@logParamMod = 'countryIdTypeMod'  
  ,@module = '20'  
  ,@tableAlias = 'Country Master'  
   
 IF @flag = 'il'     --Identity List  
 BEGIN  
  SELECT   
    sdv.valueId  
   ,sdv.detailTitle  
  FROM countryIdType cit WITH(NOLOCK)  
  INNER JOIN staticDataValue sdv WITH(NOLOCK) ON cit.IdTypeId = sdv.valueId  
  WHERE cit.countryId = @countryId   
   AND (cit.spFlag = @spFlag OR cit.spFlag IS NULL)   
   AND ISNULL(isDeleted, 'N') <> 'Y'  
   ORDER BY sdv.detailTitle  
   RETURN;  
 END   
   
  
  
 ELSE IF @flag = 'il-with-et'  --Identity List With Expiry Type  
 BEGIN  
  SELECT   
    valueId = CAST(sdv.valueId AS VARCHAR) + '|' + ISNULL(cit.expiryType, 'E')  
   ,detailTitle = sdv.detailTitle  
   ,expiryType = ISNULL(cit.expiryType, 'E')  
  FROM countryIdType cit WITH(NOLOCK)  
  INNER JOIN staticDataValue sdv WITH(NOLOCK) ON cit.IdTypeId = sdv.valueId  
  WHERE cit.countryId = @countryId   
   AND (cit.spFlag = @spFlag OR cit.spFlag IS NULL)   
   AND ISNULL(isDeleted, 'N') <> 'Y'  
  RETURN  
 END  
   
 ELSE IF @flag = 'i'  
 BEGIN  
 IF EXISTS(SELECT 'A' FROM countryIdType WHERE IdtypeId = @IdtypeId AND countryId= @countryId   
  AND ISNULL(spFlag,'') = ISNULL(@spFlag,'') AND ISNULL(isDeleted,'N')<>'Y' )  
 BEGIN  
  EXEC proc_errorHandler 1, 'Identity type already added.', @countryIdtypeId  
  RETURN  
 END  
 IF @spFlag IS NULL  
 BEGIN  
  IF EXISTS(SELECT 'A' FROM countryIdType WHERE IdtypeId = @IdtypeId AND countryId= @countryId AND spFlag IS NOT NULL  AND ISNULL(isDeleted,'N')<>'Y')  
  BEGIN  
   EXEC proc_errorHandler 1, 'Pay/send already added.', @countryIdtypeId  
   RETURN  
  END  
 END  
 IF EXISTS(SELECT 'A' FROM countryIdType WHERE IdtypeId = @IdtypeId AND countryId= @countryId AND spFlag IS NULL  AND ISNULL(isDeleted,'N')<>'Y')  
 BEGIN  
  EXEC proc_errorHandler 1, 'Identity type applies Both.', @countryIdtypeId  
  RETURN  
 END  
   
  BEGIN TRANSACTION  
   INSERT INTO countryIdType (  
     countryId  
    ,IdtypeId  
    ,spFlag  
    ,expiryType  
    ,createdBy  
    ,createdDate  
   )  
   SELECT  
     @countryId  
    ,@IdtypeId  
    ,@spFlag  
    ,@expiryType  
    ,@user  
    ,GETDATE()  
      
   SET @countryIdtypeId = SCOPE_IDENTITY()  
   SET @modType = 'Insert'  
   EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryIdtypeId , @newValue OUTPUT  
   INSERT INTO #msg(errorCode, msg, id)  
   EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryIdtypeId, @user, @oldValue, @newValue  
   IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')  
   BEGIN  
    IF @@TRANCOUNT > 0  
    ROLLBACK TRANSACTION  
    EXEC proc_errorHandler 1, 'Failed to add new record.', @countryIdtypeId  
    RETURN  
   END  
  IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION  
  EXEC proc_errorHandler 0, 'Record has been added successfully.', @countryIdtypeId  
 END  
 ELSE IF @flag = 'a'  
 BEGIN  
  SELECT * FROM countryIdType WITH(NOLOCK) WHERE countryIdtypeId = @countryIdtypeId  
 END  
  
 ELSE IF @flag = 'u'  
 BEGIN  
 IF EXISTS(SELECT 'A' FROM countryIdType WHERE IdtypeId = @IdtypeId AND countryId= @countryId AND ISNULL(spFlag,'') = ISNULL(@spFlag,'')  
  AND countryIdtypeId <> @countryIdtypeId  AND ISNULL(isDeleted,'N')<>'Y')  
 BEGIN  
  EXEC proc_errorHandler 1, 'Identity type already added.', @countryIdtypeId  
  RETURN  
 END  
 IF @spFlag IS NULL  
 BEGIN  
  IF EXISTS(SELECT 'A' FROM countryIdType WHERE IdtypeId = @IdtypeId AND countryId= @countryId AND spFlag IS NOT NULL AND   
    countryIdtypeId <> @countryIdtypeId  AND ISNULL(isDeleted,'N')<>'Y')  
  BEGIN  
   EXEC proc_errorHandler 1, 'Pay/send already added.', @countryIdtypeId  
   RETURN  
  END  
 END  
 IF EXISTS(SELECT 'A' FROM countryIdType WHERE IdtypeId = @IdtypeId AND countryId= @countryId AND spFlag IS NULL  
   AND countryIdtypeId <> @countryIdtypeId  AND ISNULL(isDeleted,'N')<>'Y')  
 BEGIN  
  EXEC proc_errorHandler 1, 'Identity type applies Both.', @countryIdtypeId  
  RETURN  
 END  
  BEGIN TRANSACTION  
   UPDATE countryIdType SET  
     IdtypeId = @IdtypeId  
    ,spFlag = @spFlag  
    ,expiryType = @expiryType  
    ,modifiedBy = @user  
    ,modifiedDate = GETDATE()  
   WHERE countryIdtypeId = @countryIdtypeId  
   EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @countryIdtypeId, @newValue OUTPUT  
   INSERT INTO #msg(errorCode, msg, id)     
   EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @countryIdtypeId, @user, @oldValue, @newValue  
   IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')  
   BEGIN  
    IF @@TRANCOUNT > 0  
    ROLLBACK TRANSACTION  
    EXEC proc_errorHandler 1, 'Failed to update record.', @countryIdtypeId  
    RETURN  
   END  
  IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION  
  EXEC proc_errorHandler 0, 'Record updated successfully.', @countryIdtypeId  
 END  
 ELSE IF @flag = 'd'  
 BEGIN  
  BEGIN TRANSACTION  
   UPDATE countryIdType SET  
    isDeleted = 'Y'  
    ,modifiedDate  = GETDATE()  
    ,modifiedBy = @user  
   WHERE countryIdtypeId = @countryIdtypeId  
   SET @modType = 'Delete'  
   EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @countryIdtypeId, @oldValue OUTPUT  
   INSERT INTO #msg(errorCode, msg, id)  
   EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @countryIdtypeId, @user, @oldValue, @newValue  
   IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')  
   BEGIN  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     EXEC proc_errorHandler 1, 'Failed to delete record.', @countryIdtypeId  
     RETURN  
    END  
   IF @@TRANCOUNT > 0  
   COMMIT TRANSACTION  
  EXEC proc_errorHandler 0, 'Record deleted successfully.', @countryIdtypeId  
 END  
  
  
 ELSE IF @flag IN ('s')  
 BEGIN  
  IF @sortBy IS NULL  
   SET @sortBy = '@countryIdtypeId'  
  IF @sortOrder IS NULL  
   SET @sortOrder = 'ASC'  
  SET @table = '(  
    SELECT  
      main.countryIdtypeId  
     ,main.countryId  
     ,main.IdtypeId  
     ,IdType = ISNULL(cm.detailTitle, ''Both'')  
     ,spFlag = ISNULL(sdv.detailTitle, ''Both'')  
     ,expiryType = CASE WHEN main.expiryType =''E'' THEN ''Expire'' WHEN main.expiryType =''N'' THEN ''Never Expire'' END  
     ,main.createdBy  
     ,main.createdDate  
     ,main.isDeleted  
    FROM countryIdType main WITH(NOLOCK)  
    LEFT JOIN staticDataValue cm ON main.IdtypeId = cm.valueId  
    LEFT JOIN staticDataValue sdv ON main.spFlag = sdv.valueId  
     WHERE main.countryId = ' + CAST(@countryId AS VARCHAR) + '  
     ) x'  
  SET @sql_filter = ''  
  SET @sql_filter = @sql_filter + ' AND ISNULL(isDeleted, '''') <> ''Y'''  
  SET @select_field_list ='  
    countryIdtypeId  
   ,countryId  
   ,IdtypeId  
   ,IdType  
   ,spFlag  
   ,expiryType  
   ,createdBy  
   ,createdDate  
   ,isDeleted '  
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
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE()  
     EXEC proc_errorHandler 1, @errorMessage, @countryIdtypeId  
END CATCH  
  
  
  
  