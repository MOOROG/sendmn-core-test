    
ALTER PROCEDURE [dbo].[proc_ApiLogs](    
  @flag    VARCHAR(10) =  NULL    
 ,@user    VARCHAR(30) =  NULL    
 ,@REQUESTEDBY  VARCHAR(100) = NULL    
 ,@rowId   INT   =  NULL    
 ,@pageSize   INT   = NULL    
 ,@pageNumber  INT   = NULL    
 ,@sortBy   VARCHAR(50)  = NULL    
 ,@sortOrder  VARCHAR(50)  = NULL   
 ,@agentId   varchar(10) = NULL    
 ,@logType   VARCHAR(20) = NULL  
 ,@date    VARCHAR(10) = NULL  
 ,@logby   VARCHAR(20) = NULL  
 ,@controlno  VARCHAR(30) = NULL  
)AS    
SET NOCOUNT ON    
SET XACT_ABORT ON    
BEGIN    
 DECLARE    
   @table    VARCHAR(MAX)    
  ,@select_field_list VARCHAR(MAX)    
  ,@extra_field_list VARCHAR(MAX)    
  ,@sql_filter  VARCHAR(MAX)    
 IF @flag='s'    
 BEGIN      
  SET @sortBy='rowId'    
  SET @sortOrder='DESC'    
  SET @table='    
  (     
   SELECT rowId  
   ,processid  
   ,date  
   ,message  
   ,logby  
   ,provider  
   ,controlno  
   FROM logDb.DBO.tblThirdParty_ApiDetailLog (NOLOCK)    
   WHERE 1=1    
  )x'    
          
  SET @sql_filter = ''    
  IF @agentId IS NOT NULL      
  SET @sql_filter=@sql_filter + ' AND provider = ''' +@agentId+''''    
  
  IF @logby IS NOT NULL      
  SET @sql_filter=@sql_filter + ' AND logby = ''' +@logby+''''   
     
  IF @date IS NOT NULL      
   SET @sql_filter=@sql_filter + ' AND CONVERT(varchar(10),date,121) = ''' +@date+''''    
  
  IF @logType IS NOT NULL      
   SET @sql_filter=@sql_filter + ' AND right(processId,7) = '''+@logType+''''    
  
  IF @controlno IS NOT NULL      
   SET @sql_filter=@sql_filter + ' AND controlno = ''' +@controlno+''''      
     
       
  SET @select_field_list = '    
         rowId  
   ,processid  
   ,date  
   ,message  
   ,logby  
   ,provider  
   ,controlno   
       '    
           
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
 IF @flag='a'    
 BEGIN    
    SELECT rowId    
       ,providerName    
       ,methodName    
       ,controlNo    
       ,requestXml    
       ,responseXml    
       ,requestedBy    
       ,requestedDate    
       ,responseDate    
       ,errorCode    
       ,errorMessage    
     FROM Application_Log.DBO.vwTpApilogs (NOLOCK)    
     WHERE rowId=@rowId    
 END    
END    