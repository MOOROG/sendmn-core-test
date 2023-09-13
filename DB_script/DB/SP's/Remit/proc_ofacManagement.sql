  
--IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_ofacManagement]') AND TYPE IN (N'P', N'PC'))  
--      DROP PROCEDURE [dbo].proc_ofacManagement  
--GO  
  
/*  
 EXEC proc_ofacManagement   
  @flag = 'sdn'  
 ,@user = 'admin'  
 ,@sdnFilePath = 'D:\dev_work\E-Pay\REMITTANCE\APP\Swift.web\doc\SDN.pip'  
 ,@altFilePath = 'D:\dev_work\E-Pay\REMITTANCE\APP\Swift.web\doc\ALT.pip'  
 ,@addFilePath = 'D:\dev_work\E-Pay\REMITTANCE\APP\Swift.web\doc\ADD.pip'  
   
 EXEC proc_ofacManagement @flag = 'sdn'  
 , @user = 'admin'  
 , @sdnFilePath = 'D:\doc\SDN.pip'  
 , @altFilePath = 'D:\doc\ALT.pip'  
 , @addFilePath = 'D:\doc\ADD.pip'  
*/  
alter proc [dbo].[proc_ofacManagement]  
  @flag   CHAR(10)  = NULL  
 ,@sdnXML  XML    = NULL  
 ,@altXML  XML    = NULL  
 ,@addXML  XML    = NULL    
 ,@user   VARCHAR(50)  = NULL  
AS  
  
SET NOCOUNT ON;  
  
BEGIN TRY  
 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)   
 DECLARE @dataSource VARCHAR(30)  
 SET @dataSource = 'OFAC'  
  
 IF @flag = 'sdn'  
 BEGIN         
    SELECT  
      sdnId = row.c.value('@f1', 'INT')  
     ,name = row.c.value('@f2', 'VARCHAR(300)')  
     ,sdnType = row.c.value('@f3', 'VARCHAR(50)')  
     ,program = row.c.value('@f4', 'VARCHAR(50)')  
     ,title = row.c.value('@f5', 'VARCHAR(200)')  
     ,callSign = row.c.value('@f6', 'VARCHAR(20)')  
     ,vesselType = row.c.value('@f7', 'VARCHAR(50)')  
     ,tonnage = row.c.value('@f8', 'VARCHAR(20)')  
     ,grossRegisteredTonnage = row.c.value('@f9', 'VARCHAR(20)')  
     ,vesselFlag = row.c.value('@f10', 'VARCHAR(50)')  
     ,vesselOwner = row.c.value('@f11', 'VARCHAR(200)')  
     ,remarks = row.c.value('@f12', 'VARCHAR(MAX)')  
     INTO #tempSDNList  
    FROM @sdnXML.nodes('/root/row') row (c)  
      
         
    SELECT  
      sdnId = row.c.value('@f1', 'INT')  
     ,altId = row.c.value('@f2', 'INT')  
     ,altType = row.c.value('@f3', 'VARCHAR(50)')  
     ,name = row.c.value('@f4', 'VARCHAR(200)')  
     ,category = row.c.value('@f5', 'VARCHAR(20)')  
     INTO #tempALTList       
    FROM @altXML.nodes('/root/row') row (c)    
  
         
      
    SELECT  
      sdnId = row.c.value('@f1', 'INT')  
     ,addId = row.c.value('@f2', 'INT')  
     ,[address] = row.c.value('@f3', 'VARCHAR(500)')  
     ,city = row.c.value('@f4', 'VARCHAR(500)')  
     ,country = row.c.value('@f5', 'VARCHAR(50)')  
     ,remark = row.c.value('@f5', 'VARCHAR(200)')  
     INTO #tempADDList       
    FROM @addXML.nodes('/root/row') row (c)      

    ---------------------------------------------------------------------------------------------  
    BEGIN TRANSACTION  
   	
	DELETE FROM blackList
	WHERE entNum IN (
	SELECT sdnId FROM #tempSDNList)
	AND DATASOURCE = 'OFAC'   
	
	DELETE FROM blacklistHistory
	WHERE entNum IN (
	SELECT sdnId FROM #tempSDNList)
	AND DATASOURCE = 'OFAC'   
   
    INSERT INTO blackList(  
      ofacKey  
     ,entNum  
     ,name  
     ,vesselType  
     ,address  
     ,city  
     ,state  
     ,zip  
     ,country  
     ,remarks  
     ,sortOrder  
     ,fromFile  
     ,dataSource  
     ,indEnt  
     ,sourceEntNum  
    )  
    SELECT x.dataSource+''+CAST(x.entNum AS VARCHAR), x.entNum, x.name, x.vesselType, x.address, x.city, x.state, x.zip, x.country,   
      x.remarks, x.sortOrder, x.fromFile, x.dataSource, x.indEnt, x.sourceEntNum   
    FROM  
    (  
    SELECT  
      ofacKey = sdn.sdnId  
     ,entNum = sdn.sdnId  
     ,name = REPLACE(sdn.name, '"', '')  
     ,vesselType = 'sdn'   
     ,address = ''  
     ,city = ''  
     ,state = ''  
     ,zip = ''  
     ,country = ''  
     ,remarks = REPLACE(sdn.remarks, '"', '')  
     ,sortOrder = 1  
     ,fromFile = 'SDN.PIP'  
     ,dataSource = @dataSource  
     ,indEnt = CASE WHEN sdn.sdnType = '"individual"' THEN 'I' ELSE 'E' END  
     ,sourceEntNum = @dataSource + CAST(sdn.sdnId AS VARCHAR)  
    FROM #tempSDNList sdn  
    UNION ALL  
    SELECT  
      ofacKey = sdn.sdnId  
     ,entNum = sdn.sdnId  
     ,name = REPLACE(alt.name, '"', '')  
     ,vesselType = 'alt'  
     ,address = ''  
     ,city = ''  
     ,state = ''  
     ,zip = ''  
     ,country = ''  
     ,remarks = ''  
     ,sortOrder = 2  
     ,fromFile = 'ALT.PIP'  
     ,dataSource = @dataSource  
     ,indEnt = CASE WHEN sdn.sdnType = '"individual"' THEN 'I' ELSE 'E' END  
     ,sourceEntNum = @dataSource + CAST(sdn.sdnId AS VARCHAR)  
    FROM #tempSDNList sdn  
    INNER JOIN #tempALTList alt WITH(NOLOCK) ON sdn.sdnId = alt.sdnId  
    UNION ALL  
    SELECT  
      ofacKey = sdn.sdnId  
     ,entNum = sdn.sdnId  
     ,name = ''  
     ,vesselType = 'add'  
     ,address = REPLACE(adr.address, '"', '')  
     ,city = REPLACE(adr.city, '"', '')  
     ,state = ''  
     ,zip = ''  
     ,country = REPLACE(adr.country, '"', '')  
     ,remarks = REPLACE(adr.remark, '"', '')  
     ,sortOrder = 3  
     ,fromFile = 'ADD.PIP'  
     ,dataSource = @dataSource  
     ,indEnt = CASE WHEN sdn.sdnType = '"individual"' THEN 'I' ELSE 'E' END  
     ,sourceEntNum = @dataSource + CAST(sdn.sdnId AS VARCHAR)  
    FROM #tempSDNList sdn  
    INNER JOIN #tempADDList adr WITH(NOLOCK) ON sdn.sdnId = adr.sdnId  
    )x  
    ORDER BY x.entNum, x.sortOrder  
      
    DECLARE   
      @sdnCount INT  
     ,@altCount INT  
     ,@addCount INT  
      
    SELECT @sdnCount = COUNT(DISTINCT entNum) FROM blackList   
    where dataSource = @dataSource  
      
    INSERT INTO blacklistLog (totalRecord, dataSource, createdBy, createdDate)  
    SELECT @sdnCount, @dataSource, @user, GETDATE()  
      
    MERGE blackListHistory AS blh  
    USING (SELECT rowId, ofacKey, entNum, name, vesselType, address, city, state, zip, country, remarks, sortOrder, fromFile, dataSource, indEnt, sourceEntNum FROM blacklist WITH(NOLOCK) WHERE dataSource = @dataSource ) AS bl  
     ON ISNULL(blh.ofacKey, '')    = ISNULL(bl.ofacKey, '') AND   ISNULL(blh.entNum, '')  = ISNULL(bl.entNum, '')   
      AND ISNULL(blh.name, '')   = ISNULL(bl.name, '') AND    ISNULL(blh.vesselType, '') = ISNULL(bl.vesselType, '')   
      AND ISNULL(blh.address, '')   = ISNULL(bl.address, '') AND   ISNULL(blh.city, '')  = ISNULL(bl.city, '')   
      AND ISNULL(blh.state, '')   = ISNULL(bl.state, '') AND    ISNULL(blh.zip, '')   = ISNULL(bl.zip, '')   
      AND ISNULL(blh.country, '')   = ISNULL(bl.country, '') AND   ISNULL(blh.remarks, '')  = ISNULL(bl.remarks, '')   
      AND ISNULL(blh.sortOrder, '')  = ISNULL(bl.sortOrder, '') AND   ISNULL(blh.fromFile, '') = ISNULL(bl.fromFile, '')   
      AND ISNULL(blh.dataSource, '')  = ISNULL(bl.dataSource, '') AND   ISNULL(blh.indEnt, '')  = ISNULL(bl.indEnt, '')  
      AND ISNULL(blh.sourceEntNum, '') = ISNULL(bl.sourceEntNum, '') AND bl.dataSource = @dataSource   
    WHEN NOT MATCHED THEN  
    INSERT(blackListId, ofacKey, entNum, name, vesselType, address, city, state, zip, country, remarks, sortOrder, fromFile, dataSource, indEnt, sourceEntNum)  
    VALUES(bl.rowId, bl.ofacKey, bl.entNum, bl.name, bl.vesselType, bl.address, bl.city, bl.state, bl.zip, bl.country, bl.remarks, bl.sortOrder, bl.fromFile, bl.dataSource, bl.indEnt, bl.sourceEntNum);  
  
  
    ------>> MAINTAINING BLACK LIST HISTORY LOG  
    --INSERT INTO blackListHistory(  
    --  blackListId  
    -- ,ofacKey  
    -- ,entNum  
    -- ,name  
    -- ,vesselType  
    -- ,address  
    -- ,city  
    -- ,state  
    -- ,zip  
    -- ,country  
    -- ,remarks  
    -- ,sortOrder  
    -- ,fromFile  
    -- ,dataSource  
    -- ,indEnt  
    -- ,sourceEntNum  
    --)  
    --SELECT    
    --     rowId  
    -- ,ofacKey  
    -- ,entNum  
    -- ,name  
    -- ,vesselType  
    -- ,address  
    -- ,city  
    -- ,state  
    -- ,zip  
    -- ,country  
    -- ,remarks  
    -- ,sortOrder  
    -- ,fromFile  
    -- ,dataSource  
    -- ,indEnt  
    -- ,sourceEntNum   
    --FROM blacklist WITH(NOLOCK) WHERE dataSource=@dataSource  
      
   IF @@TRANCOUNT > 0  
   COMMIT TRANSACTION  
  
   SELECT   
     0 error_code  
    ,'OFAC Data imported successfully' mes  
    ,NULL  
  END  
   
 ELSE IF @flag = 's'  
 BEGIN  
  SELECT   
    [ID] = rowid  
   --,[Total Records]  = totalRecord  
   ,[Source]    = dataSource  
   ,[Last Updated By]  = createdBy  
   ,[Last Updated Date] = createdDate  
  FROM blacklistLog   
      ORDER BY rowid DESC    
 END  
   
 ELSE IF @flag = 'swLog' /*Source Wise Data Log*/  
 BEGIN  
  
    SELECT   
    dataSource [Data Source], count( distinct entNum) [Total Records] from blacklist with(nolock)   
    WHERE dataSource ='UNSCR' OR dataSource ='OFAC'  
    GROUP BY dataSource  
    UNION ALL  
    SELECT   
    dataSource [Data Source], count(*) Total from blacklist with(nolock)  
    WHERE dataSource <>'UNSCR' and dataSource <>'OFAC'  
    GROUP BY dataSource  
  
 END  
END TRY  
  
BEGIN CATCH  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id  
END CATCH  
  
  
  