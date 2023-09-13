  
alter procEDURE [dbo].[proc_payOfacCompliance](  
   @flag    VARCHAR(20)     
  ,@user       VARCHAR(50)  = NULL     
     ,@id    INT    = NULL  
  ,@remarks   VARCHAR(MAX) = NULL  
  ,@controlNo   VARCHAR(50)  = NULL  
  ,@sortBy            VARCHAR(50)  = NULL  
  ,@sortOrder         VARCHAR(5)  = NULL  
  ,@pageSize          INT    = NULL  
  ,@pageNumber        INT    = NULL  
)  
AS  
  
IF @flag = 's_summary'  
BEGIN  
  
  SELECT   
   [Head] = 'OFAC/Compliance/Cash Limit Hold : International',   
   [Count] = CASE WHEN COUNT('x') > 0 THEN '<a href="List.aspx">'+CAST(COUNT('x') AS VARCHAR) +'</a>' ELSE '-' END      
  FROM remitTranTemp b WITH(NOLOCK)  
  WHERE B.tranStatus IN ('Compliance Hold', 'OFAC Hold', 'OFAC/Compliance Hold', 'Cash Limit Hold', 'Cash Limit/OFAC/Compliance Hold', 'Cash Limit/OFAC', 'Cash Limit/Compliance Hold')  
  --AND B.PCOUNTRY IN ('VIETNAM','NEPAL')  
  --UNION ALL  
    
  --SELECT [HEAD],   
  --[Count]  = CASE WHEN SUM(CAST([Count] AS INT)) > 0  THEN '<a href="ComplianceDom/List.aspx">'+ CAST(SUM(CAST([Count] AS INT)) AS VARCHAR) +'</a>' ELSE '-' END  
  --FROM (  
  --SELECT    
  -- [Head] = 'OFAC/Compliance Hold : Domestic'  ,   
  -- [Count] = CASE WHEN COUNT('x') > 0 THEN COUNT('x') ELSE '0' END  
  --FROM remitTran rt WITH(NOLOCK)  
  --INNER JOIN remitTranOfac ofac with(nolock) on rt.id = ofac.tranId  
  --WHERE (rt.tranStatus = 'Hold' OR rt.tranStatus = 'OFAC Hold' OR rt.tranStatus = 'Compliance Hold' OR rt.tranStatus = 'OFAC/Compliance Hold')  
  --AND rt.tranType = 'D' and ofac.approvedDate is null  
  --UNION ALL  
  --SELECT    
  -- [Head] = 'OFAC/Compliance Hold : Domestic'  ,   
  -- [Count] = CASE WHEN COUNT(DISTINCT tranId) > 0 THEN COUNT(DISTINCT tranId) ELSE '0' END  
  --FROM remitTran rt WITH(NOLOCK)  
  --INNER JOIN remitTranCompliance comp with(nolock) on rt.id = comp.tranId  
  --WHERE (rt.tranStatus = 'Hold' OR rt.tranStatus = 'OFAC Hold' OR rt.tranStatus = 'Compliance Hold' OR rt.tranStatus = 'OFAC/Compliance Hold')  
  --AND rt.tranType = 'D' and comp.approvedDate is null  
  --) x group by [Head]  
  
  UNION ALL  
  SELECT     
   [Head] = 'OFAC Pay',   
   [Count] = CASE WHEN COUNT('x') > 0 THEN '<a href="PayTranOfacList.aspx">'+CAST(COUNT('x') AS VARCHAR) +'</a>' ELSE '-' END  
  FROM tranPayOfac rto WITH(NOLOCK)  
  LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON rto.pBranch = am.agentId  
  WHERE rto.approvedDate IS NULL  
  
  UNION ALL  
  SELECT     
   [Head] = 'Compliance Pay',   
   [Count] = CASE WHEN COUNT('x') > 0 THEN '<a href="PayTranComplianceList.aspx">'+CAST(COUNT('x') AS VARCHAR) +'</a>' ELSE '-' END  
  FROM tranPayCompliance rtc WITH(NOLOCK)  
  LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON rtc.pBranch = am.agentId  
  WHERE rtc.approvedDate IS NULL  
   
END  
  
IF @Flag='s'  
BEGIN  
 DECLARE   
     @agentGrp INT,  
  @partnerId BIGINT,   
  @branchName VARCHAR(200),  
  @rowId BIGINT  
  
 SELECT  @partnerId = provider,  
   @rowId = tranId  
 FROM tranPayOfac WITH(NOLOCK)   
  WHERE rowId = @id  
  
 IF @partnerId IS NULL  
 BEGIN  
  EXEC proc_errorHandler 1, 'Invalid Transaction.', @rowId  
  RETURN;  
 END  
   
 DECLARE   
  @mapCodeDom VARCHAR(50)  
    ,@tranStatus VARCHAR(50)  
    ,@tranId INT  
    ,@payStatus VARCHAR(50)  
    ,@controlNoEncrypted VARCHAR(50)  
    ,@agentType VARCHAR(50)  
    ,@pTxnLocation VARCHAR(50)  
    ,@pAgentLocation VARCHAR(50)  
    ,@pAgent VARCHAR(50)  
    ,@paymentMethod VARCHAR(50)  
    ,@sBranchId VARCHAR(50)     
    ,@mapCodeInt VARCHAR(50)  
    ,@lockStatus VARCHAR(50)    
    ,@payTokenId VARCHAR(50)    
   
 BEGIN  
  EXEC proc_errorHandler 0, 'Transaction varification successfully.', @rowId  
  SELECT TOP 1  
     rowId      =trn.id  
    ,securityNo     =dbo.FNADecryptString(trn.controlNo)   
    ,transactionDate      =trn.createdDateLocal  
    ,senderName     =sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')  
    ,senderAddress    =sen.address  
    ,senderCity     =sen.city  
    ,senderMobile    =sen.mobile  
    ,senderTel     =sen.homephone  
    ,senderIdType    =sen.idType  
    ,senderIdNo     =sen.idNumber  
    ,recName     =rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')  
    ,recAddress     =rec.address  
    ,recMobile     =rec.mobile  
    ,recTelePhone    =rec.homephone  
    ,recIdType     =rec.idType  
    ,recIdNo     =rec.idNumber  
    ,recCity     =rec.city  
    ,recCountry     =rec.country  
    ,pAmount     =trn.pAmt  
    ,rCurrency     =trn.collCurr  
    ,pCurrency     =trn.payoutCurr  
    ,remarks     =pMessage  
    ,paymentMethod    =trn.paymentMethod  
    ,tokenId     =trn.payTokenId  
    ,amt      =trn.pAmt  
    ,pBranch        =trn.pBranch  
    ,sendingCountry    =trn.sCountry  
    ,sendingAgent    =trn.sAgentName  
    ,branchName     =am.agentName  
    ,providerName    ='IME International'  
    ,orderNo     = ''  
    ,agentGrp     = @agentGrp    
    ,rIdType     = tpo.rIdType  
                ,rIdNumber     = tpo.rIdNumber  
                ,rPlaceOfIssue    = tpo.rPlaceOfIssue  
                ,rRelativeName    = tpo.rRelativeName  
                ,rRelationType    = tpo.rRelationType  
                ,rContactNo     = tpo.rContactNo  
  FROM remitTran trn WITH(NOLOCK)  
  INNER JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId  
  INNER JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId  
  INNER JOIN dbo.tranPayOfac tpo WITH(NOLOCK) ON tpo.tranId = trn.id  
  INNER JOIN agentMaster am WITH(NOLOCK) ON am.agentId = tpo.pBranch  
  WHERE trn.id = @rowId   
  
  -- ## Transaction Log Details  
  SELECT @controlNoEncrypted = controlNo   
   FROM remitTran rt WITH(NOLOCK) WHERE id = @rowId  
  SELECT   
    rowId  
   ,message  
   ,trn.createdBy  
   ,trn.createdDate  
  FROM tranModifyLog trn WITH(NOLOCK)  
  LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName   
  WHERE trn.tranId = @tranId OR trn.controlNo = @controlNoEncrypted  
  ORDER BY trn.rowId DESC   
 END  
END  
IF @flag='txn_list'  
BEGIN  
  DECLARE  
    @sql    VARCHAR(MAX)  
   ,@table    VARCHAR(MAX)  
   ,@select_field_list VARCHAR(MAX)  
   ,@extra_field_list VARCHAR(MAX)  
   ,@sql_filter  VARCHAR(MAX)   
  
  SET @table = '  
   (  
   SELECT  TOP 10  
      provider  = CASE  WHEN rto.provider =''4734'' THEN ''Global Remit''  
           WHEN  rto.provider =''4670'' THEN ''Cash Express''  
           WHEN  rto.provider =''4726'' THEN ''EZ Remit''  
           WHEN  rto.provider =''4869'' THEN ''RIA Remit''  
           WHEN  rto.provider =''4854'' THEN ''MoneyGram''  
             
           WHEN  rto.provider =''4909'' THEN ''Xpress Mone''  
           WHEN  rto.provider =''4816'' THEN ''Instant Cash''  
           WHEN  rto.provider =''4812'' THEN ''IME-I''  
           ELSE ''-'' END   
             
      ,tranId  = rto.TranId     
     ,controlNo  = ''<a href="'+dbo.FNAGetURL()+'Remit/Transaction/ApproveOFAC/PayTranOfac/Manage.aspx?rowId='' + cast(rto.rowId as varchar) + ''">'' +dbo.fnadecryptstring(rto.controlNo)+ ''</a>''  
     ,pBranchName = am.agentName  
     ,receiverName = receiverName  
     ,senderName  = senderName  
     ,pAmt   = rto.pAmt  
     ,type   = ''OFAC''  
     ,createdBy  = rto.createdBy  
     ,createdDate = rto.createdDate  
     ,txnDate  = rto.txnDate  
     ,hasChanged = ''''  
   FROM tranPayOfac rto WITH(NOLOCK)  
   LEFT JOIN dbo.agentMaster am WITH(NOLOCK) ON rto.pBranch = am.agentId  
   WHERE rto.approvedDate IS NULL  '  
  
  IF @controlNo IS NOT NULL  
   SET @table = @table + ' AND dbo.fnadecryptstring(rto.controlNo) LIKE ''%' + @controlNo + '%'''  
  
  SET @table = @table + ' )x'  
  SET @sortBy = 'createdDate'  
  IF @sortOrder IS NULL  
   SET @sortOrder = 'ASC'  
        
  SET @sql_filter = ''  
       
  SET @select_field_list ='      
    controlNo  
   ,pBranchName  
   ,type  
   ,receiverName  
   ,senderName  
   ,hasChanged  
   ,createdBy  
   ,createdDate  
   ,pAmt  
   ,tranId  
   ,provider  
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
IF @flag='ofac'  
BEGIN  
   
 IF OBJECT_ID('tempdb..#tempMaster') IS NOT NULL   
 DROP TABLE #tempMaster  
   
 IF OBJECT_ID('tempdb..#tempDataTable') IS NOT NULL   
 DROP TABLE #tempDataTable    
  
 CREATE TABLE #tempDataTable  
 (  
  DATA VARCHAR(MAX) NULL  
 )  
   
 DECLARE @ofacKeyIds VARCHAR(MAX)  
 SELECT @ofacKeyIds = blackListId FROM dbo.tranPayOfac WITH(NOLOCK)  
 WHERE rowId = @id  
  
 SELECT distinct A.val ofacKeyId  
 INTO #tempMaster  
 FROM  
 (  
  SELECT * FROM dbo.SplitXML(',',@ofacKeyIds)  
 )A  
 INNER JOIN  
 (  
  SELECT ofacKey FROM blacklistHistory WITH(NOLOCK)  
 )B ON A.val=B.ofacKey  
   
 ALTER TABLE #tempMaster ADD ROWID INT IDENTITY(1,1)  
  
 DECLARE @TNA_ID AS INT  
   ,@MAX_ROW_ID AS INT  
   ,@ROW_ID AS INT=1  
   ,@ofacKeyId VARCHAR(100)  
   ,@SDN VARCHAR(MAX)=''  
   ,@ADDRESS VARCHAR(MAX)=''  
   ,@ALT AS VARCHAR(MAX)=''  
   ,@DATA AS VARCHAR(MAX)=''  
   ,@DATA_SOURCE AS VARCHAR(200)=''  
   ,@membershipId AS VARCHAR(50) = ''   
   ,@district AS VARCHAR(100) = ''   
   ,@idType AS VARCHAR(50) = ''   
   ,@idNumber AS VARCHAR(100) = ''   
   ,@dob AS VARCHAR(20) = ''  
   ,@fatherName AS VARCHAR(200) = ''  
   
 SELECT @MAX_ROW_ID=MAX(ROWID) FROM #tempMaster   
 WHILE @MAX_ROW_ID >=  @ROW_ID  
 BEGIN   
    
  SELECT @ofacKeyId=ofacKeyId FROM #tempMaster WHERE ROWID=@ROW_ID    
  
  SELECT @SDN='<b>'+ISNULL(entNum,'')+'</b>,  <b>Name:</b> '+ ISNULL(name,''),@DATA_SOURCE='<b>Data Source:</b> '+ISNULL(dataSource,'')  
  FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'    
    
  SELECT @ADDRESS=ISNULL(address,'')+', '+ISNULL(city,'')+', '+ISNULL(STATE,'')+', '+ISNULL(zip,'')+', '+ISNULL(country,'')  
  FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='add'  
    
  SELECT @ALT = COALESCE(@ALT + ', ', '') +CAST(ISNULL(NAME,'') AS VARCHAR(MAX))  
  FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType IN ('alt','aka')     
      
  SELECT  @REMARKS=ISNULL(remarks,''),   
    @membershipId = 'MembershipId: '+membershipId,   
    @district = 'District: '+district,   
    @idType = 'Id Type: '+idType,  
    @idNumber  = 'Id Number: '+idNumber,  
    @dob = 'DOB: '+dob,  
    @fatherName = 'Father Name: '+FatherName  
  FROM blacklistHistory with(nolock) WHERE ofacKey = @ofacKeyId AND vesselType='sdn'  
  
  SET @SDN=RTRIM(LTRIM(@SDN))  
  SET @ADDRESS=RTRIM(LTRIM(@ADDRESS))  
  SET @ALT=RTRIM(LTRIM(@ALT))  
  SET @REMARKS=RTRIM(LTRIM(@REMARKS))   
    
  SET @SDN=REPLACE(@SDN,', ,','')  
  SET @ADDRESS=REPLACE(@ADDRESS,', ,','')  
  SET @ALT=REPLACE(@ALT,', ,','')  
  SET @REMARKS=REPLACE(@REMARKS,', ,','')  
    
  SET @SDN=REPLACE(@SDN,'-0-','')  
  SET @ADDRESS=REPLACE(@ADDRESS,'-0-','')  
  SET @ALT=REPLACE(@ALT,'-0-','')  
  SET @REMARKS=REPLACE(@REMARKS,'-0-','')  
    
  SET @SDN=REPLACE(@SDN,',,','')  
  SET @ADDRESS=REPLACE(@ADDRESS,',,','')  
  SET @ALT=REPLACE(@ALT,',,','')  
  SET @REMARKS=REPLACE(@REMARKS,',,','')  
    
  IF @DATA_SOURCE IS NOT NULL AND @DATA_SOURCE<>''   
   SET @DATA=@DATA_SOURCE  
     
  IF @SDN IS NOT NULL AND @SDN<>''   
   SET @DATA=@DATA+'<BR>'+@SDN  
     
  IF @ADDRESS IS NOT NULL AND @ADDRESS<>''   
   SET @DATA=@DATA+'<BR><b>Address: </b>'+@ADDRESS  
     
  IF @ALT IS NOT NULL AND @ALT<>'' AND @ALT<>' '  
   SET @DATA=@DATA+'<BR>'+'<b>a.k.a :</b>'+@ALT+''  
  
  IF @REMARKS IS NOT NULL AND @REMARKS<>''   
   SET @DATA=@DATA+'<BR><b>Other Info :-</b> Remarks: '+@REMARKS  
  
  SET @DATA = @DATA   
      + ISNULL( ' ' + @membershipId, '')   
      + ISNULL( ' ' + @district, '')   
      + ISNULL( ' ' + @idType, '')  
      + ISNULL( ' ' + @idNumber, '')  
      + ISNULL( ' ' + @dob, '')  
      + ISNULL( ' ' + @fatherName, '')  
  
  IF @DATA IS NOT NULL OR @DATA <>''  
  BEGIN  
   INSERT INTO #tempDataTable    
   SELECT REPLACE(@DATA,'<BR><BR>','')  
  END  
    
  SET @ROW_ID=@ROW_ID+1  
 END    
 ALTER TABLE #tempDataTable ADD ROWID INT IDENTITY(1,1)  
 SELECT ROWID [S.N.],DATA [Remarks] FROM #tempDataTable   
END  
IF @flag = 'release'  
BEGIN   
 IF EXISTS(SELECT 'X' FROM tranPayOfac WITH(NOLOCK) WHERE rowId = @id)  
 BEGIN    
  IF @remarks IS NULL  
  BEGIN    
   EXEC proc_errorHandler 1, 'OFAC remarks can not be blank.', @id  
   RETURN;    
  END    
  
  UPDATE tranPayOfac SET   
    approvedRemarks = @remarks  
   ,approvedBy   = @user  
   ,approvedDate  = GETDATE()   
  WHERE rowId = @id AND approvedDate IS NULL  
  
  EXEC proc_errorHandler 0, 'Release remarks has been saved successfully.', @tranId  
 END  
 EXEC proc_errorHandler 1, 'Transaction not found.', @tranId  
END  
  