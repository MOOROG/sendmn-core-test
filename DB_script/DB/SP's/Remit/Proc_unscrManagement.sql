  
ALTER procEDURE [dbo].[Proc_unscrManagement]  
 @flag   VARCHAR(10)  
 ,@xmlFile  NVARCHAR(MAX)  
 ,@xmlFileName VARCHAR(100)  
 ,@user   VARCHAR(50)  
   
AS  
SET NOCOUNT ON;  
SET ANSI_NULLS ON;  
  
DECLARE @xml XML    
  
SET @xml=@xmlFile  
  
BEGIN TRY  
 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)   
 DECLARE @dataSource VARCHAR(30),@ofacDate varchar(30)  
 SET @dataSource = 'UNSCR'  
  
   
 IF @flag = 'UNSCR'  
 BEGIN  
  SELECT   
   @ofacDate = T.c.value('@dateGenerated','varchar(500)')   
  FROM @xml.nodes('CONSOLIDATED_LIST') T(c)  
    
  IF (SELECT ISNULL(MAX(ofacDate),'2100-1-1') FROM blacklistLog WHERE dataSource = 'unscr')= CAST(LEFT(@ofacDate,10) AS DATE) AND 1=2  
  BEGIN  
   SELECT 1 ERROR_CODE,'Current version of UNSCR is already updated '  mes, 0 as id  
   RETURN;  
  END  
  ELSE  
  BEGIN   
     
  
BEGIN TRANSACTION  
--####### INSERTING INDIVIDUAL DATA ON TEMP TABLE ###################################  
   
 SELECT   
  T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
    ,T.c.value('FIRST_NAME[1]','varchar(500)') AS 'FIRST_NAME'   
    ,T.c.value('SECOND_NAME[1]','varchar(500)') AS 'SECOND_NAME'   
    ,T.c.value('THIRD_NAME[1]','varchar(500)') AS 'THIRD_NAME'  
    ,T.c.value('FOURTH_NAME[1]','varchar(500)') AS 'FOURTH_NAME'  
    ,T.c.value('REFERENCE_NUMBER[1]','varchar(500)') AS 'REFERENCE_NUMBER'   
    ,T.c.value('VERSIONNUM[1]','varchar(500)') AS 'VERSIONNUM'   
    ,'UN' AS 'source'   
    ,'UN' AS 'from_file'  
    ,'I' AS 'indEnt'   
    ,'' AS 'OTHERFIELDS'    
    ,T.c.value('SORT_KEY[1]','varchar(500)') AS 'SORT_KEY'   
    ,T.c.value('SORT_KEY_LAST_MOD[1]','varchar(500)') AS 'SORT_KEY_LAST_MOD'   
  
  ,T.c.value('INDIVIDUAL_PLACE_OF_BIRTH[1]','varchar(500)') AS 'INDIVIDUAL_PLACE_OF_BIRTH'   
  ,T.c.value('INDIVIDUAL_DATE_OF_BIRTH[1]','varchar(500)') AS 'INDIVIDUAL_DATE_OF_BIRTH'   
  ,T.c.value('NATIONALITY[1]','varchar(50)') AS 'NATIONALITY'   
  
  ,T.c.value('COMMENTS1[1]','varchar(MAX)') AS 'Remarks'   
  ,T.c.value('UN_LIST_TYPE[1]','varchar(MAX)') AS 'UN_LIST_TYPE'   
  ,T.c.value('LAST_DAY_UPDATED[1]','varchar(500)') AS 'LAST_DAY_UPDATED'   
  
 INTO #TEMPUNSCRLIST  
 FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
   
--SELECT * FROM #TEMPUNSCRLIST  
  
 SELECT * INTO #TEMPINDVALIASNAME FROM (  
  SELECT   
     T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[1]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME'   
     ,T.c.value('INDIVIDUAL_ALIAS[1]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
       
   ,T.c.value('INDIVIDUAL_ADDRESS[1]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[1]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[1]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[1]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[1]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[2]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[2]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[2]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[2]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[2]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[2]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[2]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[3]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[3]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[3]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[3]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[3]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[3]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[3]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
    T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[4]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'  
     ,T.c.value('INDIVIDUAL_ALIAS[4]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
  
   ,T.c.value('INDIVIDUAL_ADDRESS[4]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[4]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[4]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[4]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[4]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[5]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[5]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
  ,T.c.value('INDIVIDUAL_ADDRESS[1]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[5]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[5]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[5]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[5]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[6]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[6]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
    
   ,T.c.value('INDIVIDUAL_ADDRESS[6]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[6]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[6]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[6]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[6]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
    T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[7]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[7]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[7]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[7]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[7]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[7]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[7]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[8]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[8]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[8]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[8]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[8]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[8]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[8]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[9]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[9]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[9]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[9]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[9]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[9]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[9]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
    T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[10]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[10]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[10]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[10]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[10]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[10]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[10]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[11]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[11]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[11]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[11]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[11]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[11]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[11]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[12]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[12]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[12]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[12]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[12]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[12]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[12]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
    T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[13]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[13]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[13]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[13]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[13]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[13]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[13]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[14]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[14]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[14]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[14]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[14]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[14]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[14]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[15]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[15]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[15]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[15]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[15]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[15]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[15]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
    T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[16]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[16]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[16]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[16]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[16]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[16]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[16]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[17]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[17]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[17]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[17]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[17]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[17]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[17]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[18]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[18]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[18]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[18]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[18]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[18]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[18]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  
  UNION ALL  
  SELECT   
    T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[19]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[19]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[19]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[19]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[19]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[19]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[19]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
     ,T.c.value('INDIVIDUAL_ALIAS[20]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME2'   
     ,T.c.value('INDIVIDUAL_ALIAS[20]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'  
  
   ,T.c.value('INDIVIDUAL_ADDRESS[20]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('INDIVIDUAL_ADDRESS[20]/zip[1]','varchar(500)') AS 'zip'   
   ,T.c.value('INDIVIDUAL_ADDRESS[20]/city[1]','varchar(500)') AS 'city'  
   ,T.c.value('INDIVIDUAL_ADDRESS[20]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('INDIVIDUAL_ADDRESS[20]/NOTE[1]','varchar(500)') AS 'ADDRESS'  
  FROM @xml.nodes('CONSOLIDATED_LIST/INDIVIDUALS/INDIVIDUAL') T(c)   
 )X  
  
 --SELECT * FROM #TEMPINDVALIASNAME  
  
 --RETURN  
  
  
--######################END OF  INDIVIDUAL LIST-- ###################################  
  
-- ENTITY  
--########## BEGINING OF ENTITY ###############################################  
 SELECT   
  T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
    ,T.c.value('FIRST_NAME[1]','varchar(500)') AS 'FIRST_NAME'   
    ,T.c.value('REFERENCE_NUMBER[1]','varchar(500)') AS 'REFERENCE_NUMBER'   
    ,T.c.value('VERSIONNUM[1]','varchar(500)') AS 'VERSIONNUM'   
    ,T.c.value('UN_LIST_TYPE[1]','varchar(500)') AS 'UN_LIST_TYPE'   
    ,T.c.value('LISTED_ON[1]','varchar(500)') AS 'LISTED_ON'   
    ,'UN' AS 'source'   
    ,'UN' AS 'from_file'   
  ,'I' AS 'indEnt'   
  ,'' AS 'OTHERFIELDS'  
    
    ,T.c.value('LIST_TYPE[1]','varchar(500)') AS 'LIST_TYPE'   
    ,T.c.value('LAST_DAY_UPDATED[1]','varchar(500)') AS 'LAST_DAY_UPDATED'   
  
  ,T.c.value('COMMENTS1[1]','varchar(MAX)') AS 'Remarks'   
  ,T.c.value('SORT_KEY[1]','varchar(MAX)') AS 'SORT_KEY'   
  ,T.c.value('SORT_KEY_LAST_MOD[1]','varchar(MAX)') AS 'SORT_KEY_LAST_MOD'   
 INTO #TEMPENTITYLIST  
 FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  
  
--SELECT * FROM #TEMPENTITYLIST  
  
  
  
 SELECT * INTO #TEMPENTITYNAME FROM (  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
    ,T.c.value('ENTITY_ALIAS[1]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
    ,T.c.value('ENTITY_ALIAS[1]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'  
      
    ,T.c.value('ENTITY_ADDRESS[1]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
    ,T.c.value('ENTITY_ADDRESS[1]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
    ,T.c.value('ENTITY_ADDRESS[1]/STREET[1]','varchar(500)') AS 'STREET'   
    ,T.c.value('ENTITY_ADDRESS[1]/CITY[1]','varchar(500)') AS 'CITY'   
    ,T.c.value('ENTITY_ADDRESS[1]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
    , T.c.value('ENTITY_ALIAS[2]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
    ,T.c.value('ENTITY_ALIAS[2]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
      
    ,T.c.value('ENTITY_ADDRESS[2]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
    ,T.c.value('ENTITY_ADDRESS[2]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
    ,T.c.value('ENTITY_ADDRESS[2]/STREET[1]','varchar(500)') AS 'STREET'   
    ,T.c.value('ENTITY_ADDRESS[2]/CITY[1]','varchar(500)') AS 'CITY'  
    ,T.c.value('ENTITY_ADDRESS[2]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
    ,T.c.value('ENTITY_ALIAS[3]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
    ,T.c.value('ENTITY_ALIAS[3]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
      
    ,T.c.value('ENTITY_ADDRESS[3]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
    ,T.c.value('ENTITY_ADDRESS[3]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
    ,T.c.value('ENTITY_ADDRESS[3]/STREET[1]','varchar(500)') AS 'STREET'   
    ,T.c.value('ENTITY_ADDRESS[3]/CITY[1]','varchar(500)') AS 'CITY'   
    ,T.c.value('ENTITY_ADDRESS[3]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID'   
    ,T.c.value('ENTITY_ALIAS[4]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[4]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
    ,T.c.value('ENTITY_ADDRESS[4]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
    ,T.c.value('ENTITY_ADDRESS[4]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
    ,T.c.value('ENTITY_ADDRESS[4]/STREET[1]','varchar(500)') AS 'STREET'   
    ,T.c.value('ENTITY_ADDRESS[4]/CITY[1]','varchar(500)') AS 'CITY'   
    ,T.c.value('ENTITY_ADDRESS[4]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
  T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[5]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
    ,T.c.value('ENTITY_ALIAS[5]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
      
    ,T.c.value('ENTITY_ADDRESS[5]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
    ,T.c.value('ENTITY_ADDRESS[5]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
    ,T.c.value('ENTITY_ADDRESS[5]/STREET[1]','varchar(500)') AS 'STREET'   
    ,T.c.value('ENTITY_ADDRESS[5]/CITY[1]','varchar(500)') AS 'CITY'   
    ,T.c.value('ENTITY_ADDRESS[5]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[6]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[6]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[6]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[6]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[6]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[6]/CITY[1]','varchar(500)') AS 'CITY'   
   ,T.c.value('ENTITY_ADDRESS[6]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[7]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[7]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[7]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[7]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[7]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[7]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[7]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[8]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[8]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[8]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[8]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[8]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[8]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[8]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[9]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[9]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[9]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[9]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[9]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[9]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[9]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[10]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[10]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[10]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[10]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[10]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[10]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[10]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[11]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[11]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[11]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[11]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[11]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[11]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[11]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[12]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[12]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'  
     
   ,T.c.value('ENTITY_ADDRESS[12]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[12]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[12]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[12]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[12]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[13]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[13]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[13]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[13]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[13]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[13]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[13]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[14]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[14]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[14]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[14]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[14]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[14]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[14]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[15]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[15]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[15]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[15]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[15]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[15]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[15]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[16]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[16]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[16]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[16]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[16]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[16]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[16]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)   
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[17]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[17]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'  
     
   ,T.c.value('ENTITY_ADDRESS[17]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[17]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[17]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[17]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[17]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[18]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[18]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[18]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[18]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[18]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[18]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[18]/ZIP[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[19]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[19]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[19]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[19]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[19]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[19]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[19]/ZIP[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
  UNION ALL  
  SELECT   
   T.c.value('DATAID[1]','varchar(500)') AS 'DATAID' ,  
   T.c.value('ENTITY_ALIAS[20]/QUALITY[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_QUALITY1'   
   ,T.c.value('ENTITY_ALIAS[20]/ALIAS_NAME[1]','varchar(500)') AS 'INDIVIDUAL_ALIAS1_NAME1'   
     
   ,T.c.value('ENTITY_ADDRESS[20]/COUNTRY[1]','varchar(500)') AS 'COUNTRY'   
   ,T.c.value('ENTITY_ADDRESS[20]/NOTE[1]','varchar(500)') AS 'ADDRESS'   
   ,T.c.value('ENTITY_ADDRESS[20]/STREET[1]','varchar(500)') AS 'STREET'   
   ,T.c.value('ENTITY_ADDRESS[20]/CITY[1]','varchar(500)') AS 'CITY'  
   ,T.c.value('ENTITY_ADDRESS[20]/zip[1]','varchar(500)') AS 'ZIP'   
  FROM @xml.nodes('CONSOLIDATED_LIST/ENTITIES/ENTITY') T(c)    
 )x  
  
--SELECT * FROM #TEMPENTITYNAME  
  
--select * from blacklist where dataSource='UNSCR'  
  
  
--############# INSERTING DATA ON BLACK LIST ############################################  
  
	DELETE FROM blacklist
	WHERE ENTNUM IN (SELECT DATAID FROM #TEMPUNSCRLIST)
	AND dataSource='UNSCR'  
	
	DELETE FROM blacklistHISTORY
	WHERE ENTNUM IN (SELECT DATAID FROM #TEMPUNSCRLIST)
	AND dataSource='UNSCR' 

   
 INSERT INTO blacklist (ofacKey,entNum,name,vesselType,address,city,zip,country,remarks,sortOrder,fromFile,dataSource,indEnt)  
 SELECT dataSource+''+CAST(entNum AS VARCHAR),entNum,[NAME],[vesselType],address,city,zip,country,remarks,[sortOrder],fromFile,[dataSource],indEnt  
 FROM  
 (  
  SELECT   
    entNum = DATAID  
   ,[NAME] = FIRST_NAME+' '+ISNULL(SECOND_NAME,'') +' '+ISNULL(THIRD_NAME,'') +' '+ISNULL(FOURTH_NAME,'')   
   ,[vesselType]= 'sdn'   
   ,address = NULL  
   ,city= NULL  
   ,zip = NULL  
   ,country = NULL  
   ,remarks = ISNULL(SORT_KEY,'')+'/'+' last mod: '+ISNULL(REPLACE(SORT_KEY_LAST_MOD,'T00:00:00',','),'')+' Place Of Birth: '+ISNULL(REPLACE(INDIVIDUAL_PLACE_OF_BIRTH,'T00:00:00',','),'')  
    +' Date of birth: '+ISNULL(REPLACE(INDIVIDUAL_DATE_OF_BIRTH,'T00:00:00',','),'')+' Nationality: '+ISNULL(NATIONALITY,'')+' Remarks: '+ISNULL(REMARKS,'')+' UNList Type: '+ISNULL(UN_LIST_TYPE,'')  
    +' Last Update date: '+ISNULL(REPLACE(LAST_DAY_UPDATED,'T00:00:00',','),'')+' Reference No: '+ISNULL(REFERENCE_NUMBER,'')+' Version No: '+ISNULL(VERSIONNUM,'')   
   ,[sortOrder] = 1   
   ,fromFile = @xmlFileName   
   ,[dataSource] = @dataSource   
   ,indEnt = INDENT  
  FROM #TEMPUNSCRLIST  WITH (NOLOCK)  
  
  UNION ALL  
  
  SELECT   
   DATAID,  
   REPLACE(REPLACE(INDIVIDUAL_ALIAS1_NAME,'? ',''),'?',''),  
   'alt',  
   NULL,  
   NULL,  
   NULL,  
   NULL,  
   NULL   
   ,2,  
   @xmlFileName [fromFile],  
   @dataSource [dataSource],  
   'I'  
  FROM #TEMPINDVALIASNAME WHERE INDIVIDUAL_ALIAS1_NAME IS NOT NULL  
  AND ISNULL(REPLACE(REPLACE(INDIVIDUAL_ALIAS1_NAME,'? ',''),'?',''),'B')<>'B'  
   UNION ALL  
  
  SELECT   
   DATAID,  
   NULL,  
   'add',  
   ADDRESS,  
   CITY,  
   ZIP,  
   COUNTRY,  
   NULL,  
   3,  
   @xmlFileName [fromFile],  
   @dataSource [dataSource],  
   'I'  
  FROM #TEMPINDVALIASNAME   
  WHERE ( ADDRESS IS NOT NULL OR CITY IS NOT NULL OR ZIP IS NOT NULL OR COUNTRY IS NOT NULL)  
  
  UNION ALL   
   
  SELECT   
   DATAID,  
   FIRST_NAME,  
   'sdn' [vesselType],  
   NULL,  
   NULL,  
   NULL,  
   NULL  
   ,ISNULL(SORT_KEY,'')+' last mod: '+ISNULL(REPLACE(SORT_KEY_LAST_MOD,'T00:00:00',','),'')  
    +' UNList Type: '+ISNULL(UN_LIST_TYPE,'') +' Comments: '+ISNULL(Remarks,'') +' List Type: '+ISNULL(LIST_TYPE,'')+' Last updated date: '+ISNULL(REPLACE(LAST_DAY_UPDATED,'T00:00:00',','),'')  
    +' Listed on: '+ISNULL(LISTED_ON,'')+' Reference No: '+ISNULL(REFERENCE_NUMBER,'')+' Version No: '+ISNULL(VERSIONNUM,'') [remarks]  
   ,1 [sortOrder],  
   @xmlFileName [fromFile],  
   @dataSource [dataSource],  
   INDENT  
  FROM #TEMPENTITYLIST  WITH (NOLOCK)  
  
  UNION ALL  
  
  SELECT   
   DATAID,  
   INDIVIDUAL_ALIAS1_NAME1,  
   'alt',  
   NULL,  
   NULL,  
   NULL,  
   NULL,  
   NULL   
   ,2,  
   @xmlFileName [fromFile],  
   @dataSource [dataSource],  
   'E'  
  FROM #TEMPENTITYNAME WHERE INDIVIDUAL_ALIAS1_NAME1 IS NOT NULL  
    
  UNION ALL  
  
  SELECT   
   DATAID,  
   NULL,  
   'add',  
   ADDRESS,  
   CITY,  
   NULL,  
   COUNTRY,  
   NULL,  
   3,  
   @xmlFileName [fromFile],  
   @dataSource [dataSource],  
   'E'  
  FROM #TEMPENTITYNAME   
  WHERE ( ADDRESS IS NOT NULL OR CITY IS NOT NULL OR COUNTRY IS NOT NULL)  
 )x   
 DECLARE @sdnCount INT  
 SELECT @sdnCount = COUNT(*) FROM #TEMPUNSCRLIST  
 SELECT @sdnCount = @sdnCount + COUNT(*) FROM #TEMPENTITYNAME  
   
 INSERT INTO blacklistLog (totalRecord, dataSource, createdBy, createdDate,ofacDate)  
 SELECT @sdnCount, @dataSource, @user, GETDATE(),CAST(LEFT(@ofacDate,10) AS DATE)  
   
   
 DROP TABLE #TEMPUNSCRLIST  
 DROP TABLE #TEMPINDVALIASNAME  
 DROP TABLE #TEMPENTITYNAME  
 DROP TABLE #TEMPENTITYLIST  
  
  
 MERGE blackListHistory AS blh  
 USING (SELECT rowId, ofacKey, entNum, name, vesselType, address, city, state, zip, country, remarks, sortOrder, fromFile, dataSource, indEnt FROM blacklist WITH(NOLOCK) WHERE dataSource ='UNSCR' /* @dataSource*/ ) AS bl  
  ON ISNULL(blh.ofacKey, '')    = ISNULL(bl.ofacKey, '') AND   ISNULL(blh.entNum, '')  = ISNULL(bl.entNum, '')   
   AND ISNULL(blh.name, '')   = ISNULL(bl.name, '') AND    ISNULL(blh.vesselType, '') = ISNULL(bl.vesselType, '')   
   AND ISNULL(blh.address, '')   = ISNULL(bl.address, '') AND   ISNULL(blh.city, '')  = ISNULL(bl.city, '')   
   AND ISNULL(blh.state, '')   = ISNULL(bl.state, '') AND    ISNULL(blh.zip, '')   = ISNULL(bl.zip, '')   
   AND ISNULL(blh.country, '')   = ISNULL(bl.country, '') AND   ISNULL(blh.remarks, '')  = ISNULL(bl.remarks, '')   
   AND ISNULL(blh.sortOrder, '')  = ISNULL(bl.sortOrder, '') AND   ISNULL(blh.fromFile, '') = ISNULL(bl.fromFile, '')   
   AND ISNULL(blh.dataSource, '')  = ISNULL(bl.dataSource, '') AND   ISNULL(blh.indEnt, '')  = ISNULL(bl.indEnt, '')  
   AND bl.dataSource = 'UNSCR' --@dataSource   
 WHEN NOT MATCHED THEN  
 INSERT(blackListId, ofacKey, entNum, name, vesselType, address, city, state, zip, country, remarks, sortOrder, fromFile, dataSource, indEnt)  
 VALUES(bl.rowId, bl.ofacKey, bl.entNum, bl.name, bl.vesselType, bl.address, bl.city, bl.state, bl.zip, bl.country, bl.remarks, bl.sortOrder, bl.fromFile, bl.dataSource, bl.indEnt);  
  
  
 --INSERT INTO blacklistHistory (blackListId,entNum,name,vesselType,address,city,zip,country,remarks,sortOrder,fromFile,dataSource,indEnt)  
 --SELECT rowId,entNum,name,vesselType,address,city,zip,country,remarks,sortOrder,fromFile,dataSource,indEnt   
 --FROM blacklist WITH(NOLOCK) WHERE dataSource='UNSCR'  
   
 IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION  
  
  SELECT   
    0 error_code  
   ,'UNSCR Data imported successfully' mes  
   ,NULL as id  
     
  EXEC PROC_UPDATE_METAPHONE  
 END  
END  
  
--- ENTITY CLOSE  
END TRY  
BEGIN CATCH  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SELECT 1 error_code, ERROR_MESSAGE() mes, null as id  
END CATCH  
  
  
  
  
  