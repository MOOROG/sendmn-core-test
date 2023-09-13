  
/*  
  
proc_sendTransactionLoadData  'b', 'admin'  
EXEC proc_sendTransactionLoadData @flag = 'sc', @agentId = '48', @deliveryMethod = '1', @amount = '1111111', @mode = 'ta', @user = 'admin'  
  
*/  
  
alter proc [dbo].[proc_UcTranView] (    
  @flag    VARCHAR(50)  
 ,@user    VARCHAR(30)  = NULL  
 ,@controlNo   VARCHAR(30)  = NULL  
 ,@tranId   BIGINT   = NULL  
 ,@message   VARCHAR(500) = NULL  
 ,@messageComplaince VARCHAR(500) = NULL  
 ,@messageOFAC  VARCHAR(500) = NULL  
 ,@lockMode   CHAR(1)   = NULL  
 ,@viewType   VARCHAR(50)  = NULL  
 ,@viewMsg   VARCHAR(MAX) = NULL  
 ,@sortBy            VARCHAR(50)  = NULL  
 ,@sortOrder         VARCHAR(5)  = NULL  
 ,@pageSize          INT    = NULL  
 ,@pageNumber        INT    = NULL  
)   
AS  
  
IF @tranId IS NULL   
 SELECT @tranId=id FROM remitTran WHERE controlNo=dbo.FNAEncryptString(@controlNo)  
DECLARE   
  @select_field_list VARCHAR(MAX)  
 ,@extra_field_list  VARCHAR(MAX)  
 ,@table             VARCHAR(MAX)  
 ,@sql_filter        VARCHAR(MAX)  
  
DECLARE @controlNoEncrypted VARCHAR(100)  
    
  ,@code      VARCHAR(50)  
  ,@userName     VARCHAR(50)  
  ,@password     VARCHAR(50)   
    
SET NOCOUNT ON  
SET XACT_ABORT ON  
  
IF @flag = 's'  
BEGIN  
 DECLARE @tranStatus VARCHAR(20)  
 SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)  
 --Transaction View History--------------------------------------------------------------------------------------  
   
  EXEC proc_tranViewHistory 'i', @user, @tranId, @controlNo, NULL,@viewType,@viewMsg  
   
 --End-----------------------------------------------------------------------------------------------------------  
 --Transaction Details------------------------------------------------------------  
 SELECT   
   tranId = trn.id  
  ,controlNo = dbo.FNADecryptString(trn.controlNo)  
    
  --Sender Information  
  ,sMemId = sen.membershipId  
  ,sCustomerId = sen.customerId  
  ,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')  
  ,sCountryName = sen.country  
  ,sStateName = sen.state  
  ,sDistrict = sen.district  
  ,sCity = sen.city  
  ,sAddress = sen.address  
  ,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)  
  ,sIdType = sen.idType  
  ,sIdNo = sen.idNumber  
  ,sValidDate = sen.validDate  
  ,sEmail = sen.email  
    
  --Receiver Information  
  ,rMemId = rec.membershipId  
  ,rCustomerId = rec.customerId  
  ,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')  
  ,rCountryName = rec.country  
  ,rStateName = rec.state  
  ,rDistrict = rec.district  
  ,rCity = rec.city  
  ,rAddress = rec.address  
  ,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)  
  ,rIdType = rec.idType  
  ,rIdNo = rec.idNumber  
    
  --Sending Agent Information  
  ,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN trn.sSuperAgentName ELSE trn.sAgentName END  
  ,sBranchName = trn.sBranchName  
  ,sAgentCountry = sa.agentCountry  
  ,sAgentState = sa.agentState  
  ,sAgentDistrict = sa.agentDistrict  
  ,sAgentLocation = sLoc.districtName  
  ,sAgentCity = sa.agentCity  
  ,sAgentAddress = sa.agentAddress  
    
  --Payout Agent Information  
  ,pAgentName = CASE WHEN trn.pAgentName = trn.pBranchName THEN trn.pSuperAgentName ELSE trn.pAgentName END  
  ,pBranchName = trn.pBranchName  
  ,pAgentCountry = trn.pCountry  
  ,pAgentState = trn.pState  
  ,pAgentDistrict = trn.pDistrict  
  ,pAgentLocation = pLoc.districtName + ISNULL(' (' + ZDM.districtName + ')','')  
  ,pAgentCity = pa.agentCity  
  ,pAgentAddress = pa.agentAddress  
    
  ,trn.tAmt  
  ,trn.serviceCharge  
  ,handlingFee = ISNULL(trn.handlingFee, 0)  
  ,exRate = (ISNULL(trn.pCurrCostRate,0) - ISNULL(trn.pCurrHoMargin,0) - ISNULL(trn.pCurrSuperAgentMargin,0) - ISNULL(trn.pCurrAgentMargin,0))/  
    CASE WHEN (ISNULL(trn.sCurrCostRate,0) + ISNULL(trn.sCurrHoMargin,0) + ISNULL(trn.sCurrSuperAgentMargin,0) + ISNULL(trn.sCurrAgentMargin,0)) = 0 THEN 1   
    ELSE (ISNULL(trn.sCurrCostRate,0) + ISNULL(trn.sCurrHoMargin,0) + ISNULL(trn.sCurrSuperAgentMargin,0) + ISNULL(trn.sCurrAgentMargin,0)) END  
  ,trn.cAmt  
  ,trn.pAmt  
    
  ,relationship = ISNULL(trn.relWithSender, '-')  
  ,purpose = ISNULL(trn.purposeOfRemit, '-')  
  ,sourceOfFund = ISNULL(trn.sourceOfFund, '-')  
  ,collMode = trn.collMode  
  ,trn.collCurr  
  ,paymentMethod = trn.paymentMethod  
  ,trn.payoutCurr  
  ,BranchName = trn.pBankBranchName  
  ,trn.accountNo  
  ,BankName = trn.pBankName  
  ,trn.tranStatus  
  ,trn.payStatus  
    
  ,payoutMsg = ISNULL(trn.pMessage, '-')  
  ,trn.createdBy  
  ,trn.createdDate  
  ,trn.approvedBy  
  ,trn.approvedDate  
  ,trn.paidBy  
  ,trn.paidDate  
  ,trn.cancelRequestBy  
  ,trn.cancelRequestDate  
  ,trn.cancelApprovedBy  
  ,trn.cancelApprovedDate  
  ,trn.payTokenId  
  ,trn.tranStatus  
  ,trn.tranType  
 FROM vwremitTran trn WITH(NOLOCK)  
 LEFT JOIN vwtranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId  
 LEFT JOIN vwtranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId  
 LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId  
 LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId  
 LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode  
 LEFT JOIN apiLocationMapping ALM WITH(NOLOCK) ON pLoc.districtCode=ALM.apiDistrictCode  
 LEFT JOIN zoneDistrictMap ZDM WITH(NOLOCK) ON ZDM.districtId=ALM.districtId  
 LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode  
 WHERE trn.controlNo = @controlNoEncrypted OR trn.id = @tranId  
   
 --End of Transaction Details------------------------------------------------------------  
   
 --Lock Transaction----------------------------------------------------------------------  
 IF (@lockMode = 'Y')  
 BEGIN  
  UPDATE remitTran SET  
    tranStatus = 'Lock'  
   ,lockedBy = @user  
   ,lockedDate = GETDATE()  
   ,lockedDateLocal = dbo.FNADateFormatTZ(GETDATE(), @user)  
  WHERE (tranStatus = 'Payment' OR tranStatus = 'CancelRequest')   
    AND payStatus = 'Unpaid' AND (controlNo = @controlNoEncrypted OR id = @tranId)  
  
 END  
 --End of Lock Transaction---------------------------------------------------------------  
   
 --Log Details---------------------------------------------------------------------------  
 SELECT   
   rowId  
  ,message  
  ,trn.createdBy  
  ,trn.createdDate  
  ,isnull(trn.fileType,'')fileType  
 FROM tranModifyLog trn WITH(NOLOCK)  
 LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName   
 WHERE trn.tranId = @tranId --OR trn.controlNo = @controlNoEncrypted  
 ORDER BY trn.createdDate DESC  
  
END  
  
ELSE IF @flag = 'ac'  --Add Comment  
BEGIN TRY  
 IF @message IS NULL  
 BEGIN  
  EXEC proc_errorHandler 1, 'Message can not be blank.', @tranId  
  RETURN  
 END  
   
 IF @tranId IS NULL  
 BEGIN  
  EXEC proc_errorHandler 1, 'Transaction No can not be blank.', @tranId  
  RETURN  
 END  
  
 INSERT INTO tranModifyLog(  
   tranId  
  ,message  
  ,createdBy  
  ,createdDate  
  ,MsgType  
 )  
 SELECT  
   @tranId  
  ,@message  
  ,@user  
  ,GETDATE()  
  ,'C'  
 EXEC proc_errorHandler 0, 'Comments has been added successfully.', @tranId  
   
   
   
   
END TRY  
BEGIN CATCH  
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id  
END CATCH  
  
IF @flag = 'showLog'  --Add Comment  
BEGIN   
  
 --Log Details---------------------------------------------------------------------------  
 SELECT   
   rowId  
  ,message  
  ,trn.createdBy  
  ,trn.createdDate  
  ,isnull(trn.fileType,'') fileType  
 FROM tranModifyLog trn WITH(NOLOCK)  
 LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName   
 WHERE trn.tranId = @tranId  
 ORDER BY trn.createdDate DESC  
   
END   
  
ELSE IF @flag='OFAC'  
BEGIN  
/*  
EXEC proc_transactionView @flag = 'OFAC', @tranId = '79'  
select * from dbo.remitTranOfac  
select * from remitTranCompliance  
select * from blackList where entNum=10009  
select * from blackList where rowId=12822  
*/  
 IF OBJECT_ID('tempdb..#tempMaster') IS NOT NULL   
 DROP TABLE #tempMaster  
    IF OBJECT_ID('tempdb..#tempDataTable') IS NOT NULL   
 DROP TABLE #tempDataTable  
    
  
 CREATE TABLE #tempDataTable  
 (    
    
  DATA VARCHAR(MAX) NULL  
 )  
 DECLARE @BLACK_LIST_ID VARCHAR(MAX)  
 SELECT @BLACK_LIST_ID=blackListId FROM dbo.remitTranOfac   
 WHERE TranId=@tranId  

 SELECT A.value BLACK_LIST_ID,B.entNum ENT_NUM   
 INTO #tempMaster  
 FROM  
 (  
  SELECT * FROM dbo.Split(',',@BLACK_LIST_ID)  
 )A  
 INNER JOIN  
 (  
  SELECT * FROM blacklist   
 )B ON A.value=cast(B.rowId  as varchar)

   
 ALTER TABLE #tempMaster ADD ROWID INT IDENTITY(1,1)  
   
 --SELECT * FROM #tempMaster  
 --SELECT @BLACK_LIST_ID  
 --RETURN;  
  
 DECLARE @TNA_ID AS INT,@MAX_ROW_ID AS INT,@ROW_ID AS INT=1,@ENT_NUM VARCHAR(200),  
 @SDN VARCHAR(MAX)='',@ADDRESS VARCHAR(MAX)='',@REMARKS AS VARCHAR(MAX)='',  
 @ALT AS VARCHAR(MAX)='',@DATA AS VARCHAR(MAX)='',@DATA_SOURCE AS VARCHAR(200)=''  
   
   
 SELECT @MAX_ROW_ID=MAX(ROWID) FROM #tempMaster  
   
 WHILE @MAX_ROW_ID >=  @ROW_ID  
 BEGIN  
    
    
  SELECT @ENT_NUM=ENT_NUM FROM #tempMaster WHERE ROWID=@ROW_ID    
  
  SELECT @SDN='<b>'+entNum+'</b>,  <b>Name:</b> '+name,@DATA_SOURCE='<b>Data Source:</b> '+dataSource  
  FROM blacklist WHERE entNum=@ENT_NUM AND vesselType='sdn'  
    
    
  SELECT @ADDRESS=ISNULL(address,'')+', '+isnull(city,'')+', '+ISNULL(state,'')+', '+ISNULL(zip,'')+', '+ISNULL(country,'')  
  FROM blacklist WHERE entNum=@ENT_NUM AND vesselType='add'  
    
  SELECT @ALT = COALESCE(@ALT + ', ', '') +  
    CAST(ISNULL(NAME,'') AS VARCHAR(MAX))  
    FROM  blacklist WHERE entNum=@ENT_NUM AND vesselType='alt'  
     
      
  SELECT @REMARKS=ISNULL(remarks,'')  
  FROM blacklist WHERE entNum=@ENT_NUM AND vesselType='sdn'  
  
  SET @SDN=rtrim(ltrim(@SDN))  
  SET @ADDRESS=rtrim(ltrim(@ADDRESS))  
  SET @ALT=rtrim(ltrim(@ALT))  
  SET @REMARKS=rtrim(ltrim(@REMARKS))   
    
  SET @SDN=REPLACE(@SDN,', ,','')  
  SET @ADDRESS=REPLACE(@ADDRESS,', ,','')  
  SET @ALT=REPLACE(@ALT,', ,','')  
  SET @REMARKS=REPLACE(@REMARKS,', ,','')  
    
  --SET @SDN=REPLACE(@SDN,'  ','')  
  --SET @ADDRESS=REPLACE(@ADDRESS,'  ','')  
  --SET @ALT=REPLACE(@ALT,'  ','')  
  --SET @REMARKS=REPLACE(@REMARKS,'  ','')  
    
  SET @SDN=REPLACE(@SDN,'-0-','')  
  SET @ADDRESS=REPLACE(@ADDRESS,'-0-','')  
  SET @ALT=REPLACE(@ALT,'-0-','')  
  SET @REMARKS=REPLACE(@REMARKS,'-0-','')  
    
  SET @SDN=REPLACE(@SDN,',,','')  
  SET @ADDRESS=REPLACE(@ADDRESS,',,','')  
  SET @ALT=REPLACE(@ALT,',,','')  
  SET @REMARKS=REPLACE(@REMARKS,',,','')  
  
  --SELECT @ADDRESS  
    
  --EXEC proc_transactionView @flag = 'OFAC', @tranId = '79'  
  
  IF @DATA_SOURCE IS NOT NULL AND @DATA_SOURCE<>''   
   SET @DATA=@DATA_SOURCE  
     
  IF @SDN IS NOT NULL AND @SDN<>''   
   SET @DATA=@DATA+'<BR>'+@SDN  
     
  IF @ADDRESS IS NOT NULL AND @ADDRESS<>''   
   SET @DATA=@DATA+'<BR><b>Address: </b>'+@ADDRESS  
     
  IF @ALT IS NOT NULL AND @ALT<>'' AND @ALT<>' '  
   SET @DATA=@DATA+'<BR>'+'<b>a.k.a :</b>'+@ALT+''  
  
  IF @REMARKS IS NOT NULL AND @REMARKS<>''   
   SET @DATA=@DATA+'<BR><b>Other Info :</b>'+@REMARKS  
  
  INSERT INTO #tempDataTable    
  SELECT REPLACE(@DATA,'<BR><BR>','')  
    
  SET @ROW_ID=@ROW_ID+1  
 END  
    
 ALTER TABLE #tempDataTable ADD ROWID INT IDENTITY(1,1)  
 SELECT ROWID [S.N.],DATA [Remarks] FROM #tempDataTable  
   
END  
  
ELSE IF @flag='Compliance'  
BEGIN  
 --EXEC proc_transactionView @flag = 'Compliance', @tranId = '26'  
 /*  
  select * from remitTranCompliance  
  SELECT * FROM csDetailRec   
  select * from csDetail  
  select * from csMaster  
 */  
/*  
 DECLARE @COMP_IDS VARCHAR(MAX),@tranIds as varchar(max)  
   
 SELECT @COMP_IDS=csDetailTranId,@tranIds=matchTranId  
 FROM dbo.remitTranCompliance WHERE TranId=@tranId  
   
 SELECT   
   B.tranId [TranId]  
  ,D.controlNo [Control No.]  
  ,rtrim(ltrim(dbo.FNAGetDataValue(condition)))+' '+checkType+' exceeds '+ cast(parameter as varchar)+' limit within '+cast(period as varchar)+' '+dbo.FNAGetDataValue(criteria) [Remarks]     
    
  --[Condition][CheckType] exceeds [Parameter] limit within [Period] [Criteria]  
 FROM  
 (  
  SELECT id,value as compId FROM dbo.Split(',',@COMP_IDS)  
 )A  
 INNER JOIN  
 (  
  SELECT id,value,right(value,len(value)-(CHARINDEX('|',value,1))) tranId ,  
  left(value,len(value)-(len(value)-(CHARINDEX('|',value,1)-1)))  compId  
  FROM dbo.Split(',',@tranIds)  
 )B ON A.compId=B.compId  
 INNER JOIN  
 (  
  SELECT * FROM csDetailRec    
 )C ON A.compId=C.csDetailRecId  
 INNER JOIN  
 (  
  SELECT id,dbo.FNADecryptString(controlNo) controlNo FROM remitTran  
 )D ON D.ID=B.tranId  
 */  
   
 SELECT  
   rowId  
  ,csDetailRecId   
  ,[S.N.]  = ROW_NUMBER()OVER(ORDER BY ROWID)   
  ,[Remarks] = RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' +   
      CASE WHEN checkType = 'Sum' THEN 'Transaction Amount'   
        WHEN checkType = 'Count' THEN 'Transaction Count' END  
      + ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)     
  ,[Matched Tran ID] = rtc.matchTranId  
 FROM remitTranCompliance rtc   
 INNER JOIN csDetailRec cdr ON rtc.csDetailTranId = cdr.csDetailRecId   
 WHERE rtc.TranId = @tranId  
END  
  
--EXEC proc_transactionView @FLAG='COMPL_DETAIL',@controlNo='1',@tranId='1'  
IF @flag='COMPL_DETAIL'  
BEGIN  
/*  
5000 By Sender ID  
5001 By Sender Name  
5002 By Sender Mobile  
5003 By Beneficiary ID  
5004 By Beneficiary ID(System)  
5005 By Beneficiary Name  
5006 By Beneficiary Mobile  
5007 By Beneficiary A/C Number  
*/  
 DECLARE @tranIds AS VARCHAR(MAX), @criteria AS INT, @totalTran AS INT, @criteriaValue AS VARCHAR(500), @id AS INT  
 SELECT @tranIds = matchTranId, @id = TranId FROM remitTranCompliance WHERE rowId = @controlNo--(ROWID) --id of remitTranCompliance  
 SELECT @criteria = criteria FROM csDetailRec WHERE csDetailRecId = @tranId--id of csDetailRec  
 SELECT @totalTran = COUNT(*) FROM dbo.Split(',', @tranIds)  
    
 IF @criteria='5000'  
  SELECT @criteriaValue = B.membershipId  
    FROM tranSenders B WHERE B.tranId = @id      
      
 IF @criteria='5001'  
  SELECT @criteriaValue = ISNULL(B.firstName, '') + ISNULL(' ' + B.middleName, '') + ISNULL(' ' + B.lastName1, '') + ISNULL(' ' + B.lastName2, '')  
    FROM tranSenders B WHERE B.tranId = @id   
      
 IF @criteria='5002'  
  SELECT @criteriaValue = B.mobile  
    FROM tranSenders B WHERE B.tranId = @id   
      
 IF @criteria='5003'  
  SELECT @criteriaValue = B.membershipId  
    FROM tranReceivers B WHERE B.tranId = @id   
      
 IF @criteria='5004'  
  SELECT @criteriaValue = B.membershipId  
    FROM tranReceivers B WHERE B.tranId = @id  
      
 IF @criteria='5005'  
  SELECT @criteriaValue = ISNULL(B.firstName, '') + ISNULL(' ' + B.middleName, '') + ISNULL(' ' + B.lastName1, '') + ISNULL(' ' + B.lastName2, '')  
    FROM tranReceivers B WHERE B.tranId = @id  
   
 IF @criteria='5006'  
  SELECT @criteriaValue = B.mobile  
    FROM tranReceivers B WHERE B.tranId = @id    
   
 IF @criteria='5007'  
  SELECT @criteriaValue = A.accountNo  
    FROM remitTran A WHERE A.id = @id   
      
 SELECT  
   REMARKS = RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' +   
      CASE WHEN checkType = 'Sum' THEN 'Transaction Amount'   
        WHEN checkType = 'Count' THEN 'Transaction Count' END  
      + ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)+': <font size=''2px''>'+@criteriaValue+'</font>'  
        
  ,totTran = 'Total Count: <b>'+CAST(@totalTran AS VARCHAR)+'</b>'      
 FROM csDetailRec   
 WHERE csDetailRecId=@tranId  
  
 SELECT   
   [S.N.]   = ROW_NUMBER() OVER(ORDER BY @controlNo)  
  ,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)  
  ,[TRAN AMOUNT] = dbo.ShowDecimal(trn.cAmt)   
  ,[CURRENCY]  = trn.collCurr   
  ,[TRAN DATE] = CONVERT(VARCHAR,trn.createdDate,101)    
 FROM remitTran trn INNER JOIN   
 (  
  SELECT * FROM dbo.Split(',', @tranIds)  
 )B ON trn.id = B.value  
  
 --SELECT * FROM remitTranCompliance  
 --SELECT * FROM csDetailRec WHERE csDetailRecId IN (  
 --SELECT csDetailTranId FROM remitTranCompliance WHERE TranId='297454')  
END  
  
ELSE IF @flag = 'saveComplainceRmks'  --Add Approve Remarks  
BEGIN TRY  
   
 --EXEC proc_transactionView @flag = 'approveRemarks', @user = 'admin', @controlNo = '91841743453', @tranId = '26', @message = 'This is tested'  
 IF EXISTS(SELECT 'X' FROM remitTranOfac WHERE TranId=@tranId)  
 BEGIN  
  IF EXISTS(SELECT 'X' FROM remitTranCompliance WHERE TranId=@tranId)  
  BEGIN  
   IF @messageOFAC IS NULL  
   BEGIN    
    EXEC proc_errorHandler 1, 'OFAC remarks can not be blank.', @tranId  
    RETURN;    
   END   
   IF @messageComplaince IS NULL  
   BEGIN    
    EXEC proc_errorHandler 1, 'Complaince remarks can not be blank.', @tranId  
    RETURN;    
   END   
  END  
  ELSE  
  BEGIN  
   IF @messageOFAC IS NULL  
   BEGIN    
    EXEC proc_errorHandler 1, 'OFAC remarks can not be blank.', @tranId  
    RETURN;    
   END     
  END  
 END  
 IF EXISTS(SELECT 'X' FROM remitTranCompliance WHERE TranId=@tranId)  
 BEGIN  
  IF @messageComplaince IS NULL  
  BEGIN    
   EXEC proc_errorHandler 1, 'Complaince remarks can not be blank.', @tranId  
   RETURN;    
  END   
 END  
   
 UPDATE remitTranOfac SET   
   approvedRemarks = @messageOFAC  
  ,approvedBy   = @user  
  ,approvedDate  = GETDATE()   
 WHERE TranId = @tranId AND approvedBy IS NULL  
   
 UPDATE remitTranCompliance SET   
   approvedRemarks = @messageComplaince  
  ,approvedBy   = @user  
  ,approvedDate  = GETDATE()   
 WHERE TranId = @tranId AND approvedBy IS NULL  
     
 UPDATE remitTran SET   
   tranStatus   = 'Payment'  
  ,approvedBy   = @user  
  ,approvedDate  = GETDATE()  
  ,approvedDateLocal = dbo.FNADateFormatTZ(GETDATE(),@user)   
 WHERE id=@tranId  
   
 EXEC proc_errorHandler 0, 'Release remarks has been saved successfully.', @tranId  
   
END TRY  
BEGIN CATCH  
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id  
END CATCH  
  
--EXEC proc_transactionView @FLAG='chkFlag',@tranId='26'  
ELSE IF @flag = 'chkFlagOFAC'    
BEGIN   
 SELECT CASE WHEN approvedDate is null then 'N' else 'Y'  end AS Compliance_FLAG  
 FROM remitTranOfac WHERE TranId=@tranId  
END  
  
ELSE IF @flag = 'chkFlagCOMPLAINCE'    
BEGIN   
 SELECT CASE WHEN approvedDate is null then 'N' else 'Y'  end AS Compliance_FLAG  
 FROM remitTranCompliance WHERE TranId=@tranId  
END  
  