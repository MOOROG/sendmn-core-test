  
ALTER PROC PROC_AMENDMENTLIST    
		@FLAG				VARCHAR(50)    
		,@customerId       VARCHAR(10)    
		,@USER				VARCHAR(50)    
		,@receiverId       VARCHAR(10)		= NULL    
		,@fromDate			VARCHAR(10)		= NULL    
		,@toDate			VARCHAR(50)		= NULL    
		,@sortBy			VARCHAR(50)		= NULL        
		,@sortOrder		VARCHAR(5)		= NULL        
		,@pageSize			INT				= NULL        
		,@pageNumber		INT				= NULL        
		,@modifiedDate		VARCHAR(50)		= NULL    
		,@amendmentId		VARCHAR(MAX)    = NULL    
		,@rowId			VARCHAR(MAX)    = NULL    
		,@changeType		VARCHAR(20)     = NULL    
AS    
BEGIN TRY    
IF @FLAG = 'S'    
BEGIN    
 DECLARE     
   @select_field_list VARCHAR(MAX)    
  ,@extra_field_list  VARCHAR(MAX)    
  ,@table             VARCHAR(MAX)    
  ,@sql_filter        VARCHAR(MAX)    
  ,@sAgent   INT    
    
  --Declare @temp TABLE (id INT)    
  --INSERT INTO @temp    
  --SELECT DISTINCT ri.receiverid from receiverinformation ri    
  -- INNER JOIN TBLRECEIVERMODIFYLOGS rml on rml.customerid = ri.receiverid    
  -- WHERE ri.customerid = @customerId    
    
  SET @toDate = @toDate + ' 23:59:59'    
    
          IF @sortBy = 'SN'    
              SET @sortBy = NULL;    
          IF @sortBy IS NULL    
              SET @sortBy = 'firstName';    
          IF @sortOrder IS NULL    
              SET @sortOrder = 'ASC';    
     --for data edited during transaction amendment    
   SET @table = '    
    (    
    select ri.receiverId,cm.customerId,cm.fullName,ri.firstname,RowId = cast(rml.AMENDMENTID as varchar(100)),changeType = ''transaction'',convert(varchar(10),rml.modifiedDate,121) modifiedDate from TBLRECEIVERMODIFYLOGS rml (nolock)    
    inner join receiverInformation ri on ri.receiverid = rml.customerId    
    inner join customerMaster cm on cm.customerId = ri.customerid    
    where tranId is  not null    
    and rml.modifiedDate between ''' + @fromDate + ''' and '''+@toDate+'''    
    ';     
          --SET @sql_filter = '';     
    IF @customerId IS NOT NULL and @customerId <> ''    
              SET @table = @table + ' and ri.customerId = '''+@customerId+'''';     
    SET @table = @table + ' group by ri.receiverId,RML.AMENDMENTID,rml.tranId,cm.fullName,ri.firstname,cm.customerId,convert(varchar(10),rml.modifiedDate,121)'    
    --for data edited from receiver edit    
    SET @table = @table + '    
     UNION ALL    
     '    
    SET @table = @table + ' select ri.receiverId,cm.customerId,cm.fullName,ri.firstname,RowId = rml.amendmentId,changeType = ''receiver'',convert(varchar(10),rml.modifiedDate,121) modifiedDate from TBLRECEIVERMODIFYLOGS rml (nolock)    
    inner join receiverInformation ri on ri.receiverid = rml.customerId    
    inner join customerMaster cm on cm.customerId = ri.customerid    
    where tranId is null     
    and rml.modifiedDate between ''' + @fromDate + ''' and '''+@toDate+''''    
    IF @customerId IS NOT NULL and @customerId <> ''    
              SET @table = @table + ' and ri.customerId = '''+@customerId+'''';    
 SET @table = @table + 'AND rml.columnName IN (''fullname'',''address'',''mobile'',''payoutpartner'',''bankLocation'',''receiverAccountNo'',''relationship'')';   
    SET @table = @table + ' group by ri.receiverId,rml.amendmentId,cm.fullName,ri.firstname,cm.customerId,convert(varchar(10),rml.modifiedDate,121)'    
    
  --for customerData edit    
    SET @table = @table + '    
     UNION ALL    
     '    
    SET @table = @table + 'select 1,cm.customerId,cm.fullName,cm.firstname,RowId = cml.amendmentId,changeType = ''customer'',convert(varchar(10),cml.modifiedDate,121) modifiedDate from TBLCUSTOMERMODIFYLOGS cml (nolock)    
    inner join customerMaster cm on cm.customerId = cml.customerid    
    and cml.modifiedDate between ''' + @fromDate + ''' and '''+@toDate+''''    
    IF @customerId IS NOT NULL and @customerId <> ''    
              SET @table = @table + ' and cml.customerId = '''+@customerId+'''';     
 SET @table = @table + 'AND CML.columnName IN (''fullname'',''address'',''zipcode'',''idType'',''idNumber'',''ssno'',''mobile'',''occupation'')';  
    SET @table = @table + ' group by cml.amendmentId,cml.customerId,cm.fullName,cm.firstname,cm.customerId,convert(varchar(10),cml.modifiedDate,121)'    
    
    SET @table = @table + ' )x';    
    PRINT @table;    
    SET @select_field_list = 'receiverId,fullName,firstname,RowId,changeType,customerId,modifiedDate';    
    
    EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,@extra_field_list, @sortBy, @sortOrder, @pageSize,@pageNumber;    
END    
ELSE IF @FLAG = 'NEW-CHANGE'  
BEGIN  
 IF @changeType = 'customer'  
 BEGIN  
  SELECT 'fullName_Name', 'address_Address', 'zipCode_ZIP Code', 'idType_Identity Card  Type', 'idNumber_Identity  Card  Number', 'SSNNO_MY Number', 'mobile_Mobile Number', 'occupation_Profession'  
  
  SELECT customerName = CM.FULLNAME, CM.customerId, fullName = CM.FULLNAME   
   , CM.zipCode, CM.SSNNO, occupation = SD.detailTitle, idType = SDD.detailTitle, CM.idNumber  
   , address = CSM.stateName+ISNULL(', ' + CM.CITY, '')+ISNULL(', '+CM.STREET, ''), mobile = CM.MOBILE  
   , relationship = SD.DETAILTITLE, RL.NEWVALUE, RL.OLDVALUE,RL.COLUMNNAME  
  INTO #CUSTOMER_UPDATE_INFO  
  FROM TBLCUSTOMERMODIFYLOGS RL(NOLOCK)  
  INNER JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.CUSTOMERID = RL.CUSTOMERID  
  LEFT JOIN STATICDATAVALUE SD(NOLOCK) ON SD.VALUEID = CM.occupation  
  LEFT JOIN STATICDATAVALUE SDD(NOLOCK) ON SDD.VALUEID = CM.idType  
  LEFT JOIN countryStateMaster CSM(NOLOCK) ON CSM.stateId = CM.STATE  
  WHERE AMENDMENTID = @rowId  
  
  ALTER TABLE #CUSTOMER_UPDATE_INFO ALTER COLUMN OLDVALUE NVARCHAR(300)  
  ALTER TABLE #CUSTOMER_UPDATE_INFO ALTER COLUMN NEWVALUE NVARCHAR(300)  
   
  UPDATE R SET R.OLDVALUE = CASE WHEN SD.DETAILTITLE IS NULL THEN R.OLDVALUE ELSE SD.DETAILTITLE END, R.NEWVALUE = CASE WHEN SDNEW.DETAILTITLE IS NULL THEN R.NEWVALUE ELSE SDNEW.DETAILTITLE END  
  --SELECT *  
  FROM #CUSTOMER_UPDATE_INFO R  
  LEFT JOIN STATICDATAVALUE SD(NOLOCK) ON CAST(SD.VALUEID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'idType'  
  LEFT JOIN STATICDATAVALUE SDNEW(NOLOCK) ON CAST(SDNEW.VALUEID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'idType'  
  
  
  UPDATE R SET R.OLDVALUE = CASE WHEN SD.DETAILTITLE IS NULL THEN R.OLDVALUE ELSE SD.DETAILTITLE END, R.NEWVALUE = CASE WHEN SDNEW.DETAILTITLE IS NULL THEN R.NEWVALUE ELSE SDNEW.DETAILTITLE END  
  --SELECT *  
  FROM #CUSTOMER_UPDATE_INFO R  
  LEFT JOIN STATICDATAVALUE SD(NOLOCK) ON CAST(SD.VALUEID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'occupation'  
  LEFT JOIN STATICDATAVALUE SDNEW(NOLOCK) ON CAST(SDNEW.VALUEID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'occupation'  
  
  select * from #CUSTOMER_UPDATE_INFO  
  
  RETURN;  
 END  
 ELSE IF @changeType = 'receiver'  
 BEGIN  
  SELECT 'fullName_Name', 'address_Address', 'mobile_Mobile Number', 'payOutPartner_Bank', 'bankLocation_Bank Branch', 'receiverAccountNo_Bank Acccount', 'relationship_Relationship with Sender'  
  
  SELECT customerName = CM.FULLNAME, CM.customerId, fullName = RI.FIRSTNAME + ISNULL(' ' + RI.MIDDLENAME,'') + ISNULL(' ' + RI.LASTNAME1,'') + ISNULL(' ' + RI.LASTNAME2,'')    
    , address = RI.ADDRESS, mobile = RI.MOBILE,payOutPartner = AP.BANK_NAME,bankLocation = AB.BRANCH_NAME ,receiverAccountNo = RI.RECEIVERACCOUNTNO  
    , relationship = SD.DETAILTITLE, RL.NEWVALUE, RL.OLDVALUE,RL.COLUMNNAME  
  INTO #RECEIVER_UPDATE_INFO  
  FROM TBLRECEIVERMODIFYLOGS RL(NOLOCK)  
  INNER JOIN RECEIVERINFORMATION RI(NOLOCK) ON RI.RECEIVERID = RL.CUSTOMERID  
  LEFT JOIN API_BANK_LIST AP(NOLOCK) ON AP.BANK_ID = RI.PAYOUTPARTNER  
  LEFT JOIN API_BANK_BRANCH_LIST AB(NOLOCK) ON AB.BRANCH_ID = RI.BANKLOCATION  
  LEFT JOIN STATICDATAVALUE SD(NOLOCK) ON SD.VALUEID = RI.RELATIONSHIP  
  INNER JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.CUSTOMERID = RI.CUSTOMERID  
  WHERE AMENDMENTID = @rowId  
    
  ALTER TABLE #RECEIVER_UPDATE_INFO ALTER COLUMN OLDVALUE NVARCHAR(300)  
  ALTER TABLE #RECEIVER_UPDATE_INFO ALTER COLUMN NEWVALUE NVARCHAR(300)    
  UPDATE R SET R.OLDVALUE = CASE WHEN SD.DETAILTITLE IS NULL THEN R.OLDVALUE ELSE SD.DETAILTITLE END, R.NEWVALUE = CASE WHEN SDNEW.DETAILTITLE IS NULL THEN R.NEWVALUE ELSE SDNEW.DETAILTITLE END  
  --SELECT *  
  FROM #RECEIVER_UPDATE_INFO R  
  LEFT JOIN STATICDATAVALUE SD(NOLOCK) ON CAST(SD.VALUEID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'relationship'  
  LEFT JOIN STATICDATAVALUE SDNEW(NOLOCK) ON CAST(SDNEW.VALUEID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'relationship'  
    
  UPDATE R SET R.OLDVALUE = CASE WHEN AP.BANK_ID IS NULL THEN R.OLDVALUE WHEN R.COLUMNNAME = 'payOutPartner' AND AP.BANK_ID IS NOT NULL THEN AP.BANK_NAME END  
    , R.NEWVALUE = CASE WHEN  APNEW.BANK_ID IS NULL THEN R.NEWVALUE WHEN R.COLUMNNAME = 'payOutPartner' AND APNEW.BANK_ID IS NOT NULL THEN APNEW.BANK_NAME END  
  --SELECT *  
  FROM #RECEIVER_UPDATE_INFO R  
  LEFT JOIN API_BANK_LIST AP(NOLOCK) ON CAST(AP.BANK_ID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'payOutPartner'  
  LEFT JOIN API_BANK_LIST APNEW(NOLOCK) ON CAST(APNEW.BANK_ID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'payOutPartner'  
    
  UPDATE R SET R.OLDVALUE = CASE WHEN AB.BRANCH_ID IS NULL THEN R.OLDVALUE ELSE AB.BRANCH_NAME END, R.NEWVALUE = CASE WHEN ABNEW.BRANCH_ID IS NULL THEN R.NEWVALUE ELSE ABNEW.BRANCH_NAME END  
  --SELECT *  
  FROM #RECEIVER_UPDATE_INFO R  
  LEFT JOIN API_BANK_BRANCH_LIST AB(NOLOCK) ON CAST(AB.BRANCH_ID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'bankLocation'  
  LEFT JOIN API_BANK_BRANCH_LIST ABNEW(NOLOCK) ON CAST(ABNEW.BRANCH_ID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'bankLocation'   
  
  SELECT * FROM #RECEIVER_UPDATE_INFO  
  RETURN;  
 END  
 ELSE   
 BEGIN  
  SELECT 'fullName_Name', 'address_Address', 'mobile_Mobile Number', 'payOutPartner_Bank', 'bankLocation_Bank Branch', 'receiverAccountNo_Bank Acccount', 'relationship_Relationship with Sender'  
  
  SELECT customerName = CM.FULLNAME, CM.customerId, fullName = RI.FIRSTNAME + ISNULL(' ' + RI.MIDDLENAME,'') + ISNULL(' ' + RI.LASTNAME1,'') + ISNULL(' ' + RI.LASTNAME2,'')    
    , address = RI.ADDRESS, mobile = RI.MOBILE,payOutPartner = AP.BANK_NAME,bankLocation = AB.BRANCH_NAME ,receiverAccountNo = RI.RECEIVERACCOUNTNO  
    , relationship = SD.DETAILTITLE, RL.NEWVALUE, RL.OLDVALUE,RL.COLUMNNAME,DBO.FNADecryptString(RT.controlNo) CONTROLNUMBER  
  INTO #RECEIVER_UPDATE_INFO_DURING_TRANSACTION  
  FROM TBLRECEIVERMODIFYLOGS RL(NOLOCK)  
  INNER JOIN RECEIVERINFORMATION RI(NOLOCK) ON RI.RECEIVERID = RL.CUSTOMERID  
  LEFT JOIN API_BANK_LIST AP(NOLOCK) ON AP.BANK_ID = RI.PAYOUTPARTNER  
  LEFT JOIN API_BANK_BRANCH_LIST AB(NOLOCK) ON AB.BRANCH_ID = RI.BANKLOCATION  
  LEFT JOIN STATICDATAVALUE SD(NOLOCK) ON SD.VALUEID = RI.RELATIONSHIP  
  INNER JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.CUSTOMERID = RI.CUSTOMERID  
  LEFT JOIN DBO.REMITTRAN RT(NOLOCK) ON RT.ID = RL.tranId  
  WHERE RL.AMENDMENTID = @rowId  
  
    
  ALTER TABLE #RECEIVER_UPDATE_INFO_DURING_TRANSACTION ALTER COLUMN OLDVALUE NVARCHAR(300)  
  ALTER TABLE #RECEIVER_UPDATE_INFO_DURING_TRANSACTION ALTER COLUMN NEWVALUE NVARCHAR(300)  
  
  UPDATE R SET R.OLDVALUE = CASE WHEN SD.DETAILTITLE IS NULL THEN R.OLDVALUE ELSE SD.DETAILTITLE END, R.NEWVALUE = CASE WHEN SDNEW.DETAILTITLE IS NULL THEN R.NEWVALUE ELSE SDNEW.DETAILTITLE END  
  --SELECT *  
  FROM #RECEIVER_UPDATE_INFO_DURING_TRANSACTION R  
  LEFT JOIN STATICDATAVALUE SD(NOLOCK) ON CAST(SD.VALUEID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'relationship'  
  LEFT JOIN STATICDATAVALUE SDNEW(NOLOCK) ON CAST(SDNEW.VALUEID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'relationship'  
  
  UPDATE R SET R.OLDVALUE = CASE WHEN AP.BANK_ID IS NULL THEN R.OLDVALUE ELSE AP.BANK_NAME END, R.NEWVALUE = CASE WHEN APNEW.BANK_ID IS NULL THEN R.NEWVALUE ELSE APNEW.BANK_NAME END  
  --SELECT *  
  FROM #RECEIVER_UPDATE_INFO_DURING_TRANSACTION R  
  LEFT JOIN API_BANK_LIST AP(NOLOCK) ON CAST(AP.BANK_ID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'payOutPartner'  
  LEFT JOIN API_BANK_LIST APNEW(NOLOCK) ON CAST(APNEW.BANK_ID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'payOutPartner'  
  
  UPDATE R SET R.OLDVALUE = CASE WHEN AB.BRANCH_ID IS NULL THEN R.OLDVALUE ELSE AB.BRANCH_NAME END, R.NEWVALUE = CASE WHEN ABNEW.BRANCH_ID IS NULL THEN R.NEWVALUE ELSE ABNEW.BRANCH_NAME END  
  --SELECT *  
  FROM #RECEIVER_UPDATE_INFO_DURING_TRANSACTION R  
  LEFT JOIN API_BANK_BRANCH_LIST AB(NOLOCK) ON CAST(AB.BRANCH_ID AS VARCHAR) = R.OLDVALUE AND R.COLUMNNAME = 'bankLocation'  
  LEFT JOIN API_BANK_BRANCH_LIST ABNEW(NOLOCK) ON CAST(ABNEW.BRANCH_ID AS VARCHAR) = R.NEWVALUE AND R.COLUMNNAME = 'bankLocation'   
  
  SELECT * FROM #RECEIVER_UPDATE_INFO_DURING_TRANSACTION  
  RETURN  
 END  
END  
ELSE IF @FLAG = 'changeList'    
BEGIN    
  IF @changeType = 'transaction'    
  BEGIN    
   declare @tranApproved bit,@CONTROLNO VARCHAR(20)    
   IF EXISTS(SELECT 1 FROM REMITTRANTEMP WHERE ID = @rowId)    
    SET @tranApproved = 0    
   IF @tranApproved = 0    
    SELECT @CONTROLNO = DBO.FNADECRYPTSTRING(CONTROLNO) FROM REMITTRANTEMP WHERE ID = @rowId     
   ELSE    
    SELECT @CONTROLNO = DBO.FNADECRYPTSTRING(CONTROLNO) FROM REMITTRAN WHERE ID = @rowId     
       
   SELECT RML.COLUMNNAME,RML.OLDVALUE,RML.NEWVALUE,CM.FULLNAME,@CONTROLNO CONTROLNUMBER FROM TBLRECEIVERMODIFYLOGS RML (NOLOCK)    
   INNER JOIN  RECEIVERINFORMATION  RI ON RI.RECEIVERID = RML.CUSTOMERID    
   INNER JOIN CUSTOMERMASTER CM ON CM.CUSTOMERID = RI.CUSTOMERID    
   WHERE RI.CUSTOMERID = @customerId    
   AND RML.TRANID = @rowId    
  END    
  ELSE IF @changeType = 'receiver'    
  BEGIN    
   SET @table = '';    
     
   IF EXISTS(select 1 from TBLRECEIVERMODIFYLOGS where columnname = 'fullName' AND customerId = @receiverId AND amendmentId = @rowId)    
   BEGIN    
    SET @table = @table + ' SELECT ''Name'' [COLUMNNAME],ISNULL(RML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(RML.NEWVALUE,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML    
          WHERE CUSTOMERID = '+@receiverId+' AND RML.COLUMNNAME = ''FULLNAME''    
          AND RML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDFULLNAME VARCHAR(100)    
    SELECT @OLDFULLNAME = FIRSTNAME + ISNULL(' ' + MIDDLENAME,'') + ISNULL(' ' + LASTNAME1,'')    
          + ISNULL(' ' + LASTNAME2,'')    
    FROM RECEIVERINFORMATION     
    WHERE RECEIVERID = @receiverId    
    SET @table = @table + ' SELECT ''Name'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDFULLNAME,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
     
   SET @table = @table + '    
   UNION ALL';    
   --//more TO do    
   IF EXISTS(select 1 from TBLRECEIVERMODIFYLOGS where columnname = 'address' AND customerId = @receiverId AND amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Address'' [COLUMNNAME],ISNULL(RML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(RML.NEWVALUE,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML    
          WHERE CUSTOMERID = '+@receiverId+' AND RML.COLUMNNAME = ''address''    
          AND RML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDADDRESS VARCHAR(100)    
    SELECT @OLDADDRESS = ADDRESS    
    FROM RECEIVERINFORMATION     
    WHERE RECEIVERID = @receiverId    
    SET @table = @table + ' SELECT ''Address'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDADDRESS,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
     
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLRECEIVERMODIFYLOGS where columnname = 'mobile' AND customerId = @receiverId AND amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Mobile Number'' [COLUMNNAME],ISNULL(RML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(RML.NEWVALUE,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML    
          WHERE CUSTOMERID = '+@receiverId+' AND RML.COLUMNNAME = ''mobile''    
          AND RML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDMOBILE VARCHAR(100)    
SELECT @OLDMOBILE = ISNULL(MOBILE,'-')    
    FROM RECEIVERINFORMATION     
    WHERE RECEIVERID = @receiverId    
    SET @table = @table + ' SELECT ''Mobile Number'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDMOBILE,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
      
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLRECEIVERMODIFYLOGS where columnname = 'payOutPartner' AND customerId = @receiverId AND amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Bank'' [COLUMNNAME],ISNULL(ABL.BANK_NAME,''-'')    
           OLDVALUE,ISNULL(ABL1.BANK_NAME,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML    
            LEFT JOIN API_BANK_LIST ABL ON ABL.BANK_ID = RML.OLDVALUE    
           LEFT JOIN API_BANK_LIST ABL1 ON ABL1.BANK_ID = RML.NEWVALUE    
          WHERE CUSTOMERID = '+@receiverId+' AND RML.COLUMNNAME = ''payOutPartner''    
          AND RML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDPAYOUTPARTNER VARCHAR(100)    
    SELECT @OLDPAYOUTPARTNER = ISNULL(BANK_NAME,'-')    
    FROM RECEIVERINFORMATION RI    
    INNER JOIN API_BANK_LIST ABL ON ABL.BANK_ID = RI.payOutPartner    
    WHERE RECEIVERID = @receiverId    
    SET @table = @table + ' SELECT ''Bank'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDPAYOUTPARTNER,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLRECEIVERMODIFYLOGS where columnname = 'bankLocation' AND customerId = @receiverId AND amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Bank Branch'' [COLUMNNAME],ISNULL(ABL.BRANCH_NAME,''-'')    
           OLDVALUE,ISNULL(ABL1.BRANCH_NAME,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML    
           LEFT JOIN API_BANK_BRANCH_LIST ABL ON CAST(ABL.BRANCH_ID AS NVARCHAR) = RML.OLDVALUE    
           LEFT JOIN API_BANK_BRANCH_LIST ABL1 ON CAST(ABL1.BRANCH_ID AS NVARCHAR) = RML.NEWVALUE    
          WHERE CUSTOMERID = '+@receiverId+' AND RML.COLUMNNAME = ''bankLocation''    
          AND RML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDBANKLOCATION VARCHAR(100)    
    SELECT @OLDBANKLOCATION = ISNULL(ABL.BRANCH_NAME,'')    
    FROM RECEIVERINFORMATION RI    
    INNER JOIN API_BANK_BRANCH_LIST ABL ON ABL.BRANCH_ID = RI.bankLocation    
    WHERE RECEIVERID = @receiverId    
    set @OLDBANKLOCATION = ISNULL(@OLDBANKLOCATION,'')    
    
    SET @table = @table + ' SELECT ''Bank Branch'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDBANKLOCATION,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
    
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLRECEIVERMODIFYLOGS where columnname = 'receiverAccountNo' AND customerId = @receiverId AND amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Bank Account'' [COLUMNNAME],ISNULL(RML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(RML.NEWVALUE,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML    
          WHERE CUSTOMERID = '+@receiverId+' AND RML.COLUMNNAME = ''receiverAccountNo''    
          AND RML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDRECEIVERACCOUNTNO VARCHAR(100)    
    SELECT @OLDRECEIVERACCOUNTNO = ISNULL(receiverAccountNo,'-')    
    FROM RECEIVERINFORMATION     
    WHERE RECEIVERID = @receiverId    
        
    SET @table = @table + ' SELECT ''Bank Account'' [COLUMNNAME],ISNULL('''+@OLDRECEIVERACCOUNTNO+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
     
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLRECEIVERMODIFYLOGS where columnname = 'relationship' AND customerId = @receiverId AND amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Relationship with Sender'' [COLUMNNAME],ISNULL(SDV.DETAILDESC,''-'')    
           OLDVALUE,ISNULL(SDV1.DETAILDESC,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML    
      LEFT JOIN STATICDATAVALUE SDV ON  CAST(SDV.VALUEID  AS NVARCHAR) = RML.OLDVALUE    
           LEFT JOIN STATICDATAVALUE SDV1 ON CAST(SDV1.VALUEID AS NVARCHAR) = RML.NEWVALUE    
          WHERE CUSTOMERID = '+@receiverId +' AND RML.COLUMNNAME = ''relationship''    
          AND RML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDRELATIONSHIP VARCHAR(100)    
    SELECT @OLDRELATIONSHIP = ISNULL(SDV.DETAILDESC,'-')    
    FROM RECEIVERINFORMATION RI    
    INNER JOIN STATICDATAVALUE SDV ON CAST(SDV.VALUEID AS VARCHAR) = CAST(RI.relationship AS VARCHAR)    
    WHERE RECEIVERID = @receiverId    
    SET @table = @table + ' SELECT ''Relationship with Sender'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDRELATIONSHIP,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
   SET @table = @table + '    
   UNION ALL';    
   SET @table = @table + ' SELECT RML.COLUMNNAME,ISNULL(RML.OLDVALUE, ''-'') OLDVALUE,ISNULL(RML.NEWVALUE,''-'') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML (NOLOCK)    
   INNER JOIN  RECEIVERINFORMATION  RI ON RI.RECEIVERID = RML.CUSTOMERID    
   INNER JOIN CUSTOMERMASTER CM ON CM.CUSTOMERID = RI.CUSTOMERID    
   WHERE RI.CUSTOMERID = '''+@receiverId+'''    
   AND RML.AMENDMENTID = '''+@rowId+'''    
   AND columnName not in (''fullname'',''firstname'',''middlename'',''lastname1'',''lastname2'',''address'',''zipcode'',''idType'',''idNumber'',''mobile'',''payOutPartner'',''bankLocation'',''receiverAccountNo'',''relationship'')'    
    
    
   print @table    
   exec(@table)    
    
  -- SELECT RML.COLUMNNAME,ISNULL(RML.OLDVALUE, '-') OLDVALUE,ISNULL(RML.NEWVALUE, '-') NEWVALUE FROM TBLRECEIVERMODIFYLOGS RML (NOLOCK)    
  -- INNER JOIN  RECEIVERINFORMATION  RI ON RI.RECEIVERID = RML.CUSTOMERID    
  -- INNER JOIN CUSTOMERMASTER CM ON CM.CUSTOMERID = RI.CUSTOMERID    
  -- WHERE RI.CUSTOMERID = @customerId    
  -- AND RML.AMENDMENTID = @rowId    
  -- AND columnName not in ('fullname','firstname','middlename','lastname1','lastname2','address','zipcode','idType','idNumber','mobile')    
  END    
  ELSE    
  BEGIN    
  SET @table = '';    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'fullName' AND customerId = @customerId and amendmentId = @rowId)    
   BEGIN    
    SET @table = @table + ' SELECT ''Name'' [COLUMNNAME],ISNULL(CML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(CML.NEWVALUE,''-'') NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML    
          WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''FULLNAME''    
          AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    SELECT @OLDFULLNAME = FIRSTNAME + ISNULL(' ' + MIDDLENAME,'') + ISNULL(' ' + LASTNAME1,'')    
          + ISNULL(' ' + LASTNAME2,'')    
    FROM customerMaster     
    WHERE customerId = @customerId    
    SET @table = @table + ' SELECT ''Name'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDFULLNAME,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
    
   SET @table = @table + '    
   UNION ALL';    
     DECLARE @stateName VARCHAR(50),@cityname VARCHAR(20)    
     SELECT @stateName= csm.stateName    
        ,@cityname =city    
     FROM dbo.customerMaster cm    
     INNER JOIN dbo.countryStateMaster csm ON csm.stateId = cm.state     
     WHERE customerId = @customerId    
    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'street' AND customerId = @customerId and amendmentId = @rowId)    
   BEGIN    
  
     SET @table = @table + ' SELECT ''Address'' [COLUMNNAME],'''  
       + ISNULL(@stateName,'')+ISNULL(', ' + @cityname,'')+   
       '''+ISNULL('', '' + CML.OLDVALUE,''-'') OLDVALUE,'''  
       +ISNULL(@stateName,'')+ISNULL(', ' + @cityname,'')+  
       '''+ISNULL('', '' + CML.NEWVALUE,''-'') NEWVALUE   
      FROM TBLCUSTOMERMODIFYLOGS CML    
      WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''street''    
      AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    SELECT @OLDADDRESS = ISNULL(street,'-')    
    FROM customerMaster     
    WHERE customerId = @customerId    
    SET @table = @table + ' SELECT ''Address'' [COLUMNNAME],'''  
         + ISNULL(@stateName,'') + ISNULL(', '+@cityname,'') +  
      '''+ISNULL('''+ISNULL(@OLDADDRESS,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'zipcode' AND customerId =  @customerId and amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Zip Code'' [COLUMNNAME],ISNULL(CML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(CML.NEWVALUE,''-'') NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML    
        WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''zipcode''    
          AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDZIPCODE VARCHAR(100)    
    SELECT @OLDZIPCODE = ISNULL(ZIPCODE,'-')    
     FROM customerMaster     
    WHERE customerId = @customerId    
    SET @table = @table + ' SELECT ''Zip Code'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDZIPCODE,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
    
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'idType' AND customerId =  @customerId and amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Identity Card Type'' [COLUMNNAME],ISNULL(SDV.DETAILDESC,''-'')    
           OLDVALUE,ISNULL(SDV1.DETAILDESC,''-'') NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML    
           LEFT JOIN STATICDATAVALUE SDV ON SDV.VALUEID = CML.OLDVALUE    
           LEFT JOIN STATICDATAVALUE SDV1 ON SDV1.VALUEID = CML.NEWVALUE    
          WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''idType''    
          AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDIDTYPE VARCHAR(100)    
    SELECT @OLDIDTYPE = ISNULL(SDV.DETAILDESC,'-')    
    FROM customerMaster CI    
    INNER JOIN STATICDATAVALUE SDV ON SDV.VALUEID = CI.IDTYPE    
    WHERE customerId = @customerId    
    print @OLDIDTYPE    
    SET @table = @table + ' SELECT ''Identity Card Type'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDIDTYPE,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
    
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'idNumber' AND customerId =  @customerId and amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Identity Card Number'' [COLUMNNAME],ISNULL(CML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(CML.NEWVALUE,''-'') NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML    
          WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''idNumber''    
          AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDIDNUMBER VARCHAR(100)    
    SELECT @OLDIDNUMBER = ISNULL(IDNUMBER,'-')    
    FROM customerMaster     
    WHERE customerId = @customerId    
    SET @table = @table + ' SELECT ''Identity Card Number'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDIDNUMBER,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'SSNNO' AND customerId =  @customerId and amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''My Number'' [COLUMNNAME],ISNULL(CML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(CML.NEWVALUE,''-'') NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML    
          WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''SSNNO''    
          AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDSSNNO VARCHAR(100)    
    SELECT @OLDSSNNO = ISNULL(SSNNO,'-')    
    FROM customerMaster     
    WHERE customerId = @customerId    
    SET @table = @table + ' SELECT ''My Number'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDSSNNO,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
    
    SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'mobile' AND customerId =  @customerId and amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Mobile Number'' [COLUMNNAME],ISNULL(CML.OLDVALUE,''-'')    
           OLDVALUE,ISNULL(CML.NEWVALUE,''-'') NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML    
          WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''mobile''    
          AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDMOBILE1 VARCHAR(100)    
    SELECT @OLDMOBILE1 = ISNULL(MOBILE,'-')    
    FROM customerMaster     
    WHERE customerId = @customerId    
    SET @table = @table + ' SELECT ''Mobile Number'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDMOBILE1,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
    
   SET @table = @table + '    
   UNION ALL';    
   IF EXISTS(select 1 from TBLCUSTOMERMODIFYLOGS where columnname = 'occupation' AND customerId =  @customerId and amendmentId = @rowId)    
   BEGIN    
     SET @table = @table + ' SELECT ''Profession'' [COLUMNNAME],ISNULL(SDV.DETAILDESC,''-'')    
           OLDVALUE,ISNULL(SDV1.DETAILDESC,''-'') NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML    
            LEFT JOIN STATICDATAVALUE SDV ON SDV.VALUEID = CML.OLDVALUE    
           LEFT JOIN STATICDATAVALUE SDV1 ON SDV1.VALUEID = CML.NEWVALUE    
          WHERE CUSTOMERID = '+@customerId+' AND CML.COLUMNNAME = ''occupation''    
          AND CML.AMENDMENTID = '''+@rowId+''' '    
   END    
   ELSE    
   BEGIN    
    DECLARE @OLDOCCUPATION VARCHAR(100)    
    SELECT @OLDOCCUPATION = ISNULL(SDV.DETAILDESC,'-')    
    FROM customerMaster CI    
    INNER JOIN STATICDATAVALUE SDV ON SDV.VALUEID = CI.IDTYPE    
    WHERE customerId = @customerId    
    SET @table = @table + ' SELECT ''Profession'' [COLUMNNAME],ISNULL('''+ISNULL(@OLDOCCUPATION,'')+''',''-'') [OLDVALUE]    
          ,''-''  [NEWVALUE]'    
   END    
    
    
   PRINT(@table)    
   EXEC(@table)    
    
   --SELECT CML.COLUMNNAME,COALESCE(SDV.detailDesc,CML.OLDVALUE) OLDVALUE,COALESCE(SDV1.detailDesc,CML.NEWVALUE) NEWVALUE FROM TBLCUSTOMERMODIFYLOGS CML (NOLOCK)    
   --INNER JOIN CUSTOMERMASTER CM ON CM.CUSTOMERID = CML.CUSTOMERID    
   --LEFT JOIN STATICDATAVALUE SDV ON CAST(SDV.VALUEID AS NVARCHAR(10)) = CML.OLDVALUE    
   --LEFT JOIN STATICDATAVALUE SDV1 ON CAST(SDV1.VALUEID AS NVARCHAR(10)) = CML.NEWVALUE    
   --WHERE CML.CUSTOMERID = @customerId    
   --AND CML.AMENDMENTID = @rowId    
  END    
    
  SELECT CUSTOMERID,FULLNAME FROM DBO.CUSTOMERMASTER WHERE CUSTOMERID = @CUSTOMERID    
     
END    
END TRY    
BEGIN CATCH   
 DECLARE @MSG VARCHAR(1000) = ERROR_MESSAGE()   
 SELECT '1' Errorcode,@MSG Msg,NULL id     
END CATCH  
  