SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROC [dbo].[proc_transactionView] (      
  @flag     VARCHAR(50)    
 ,@user     VARCHAR(30)  = NULL    
 ,@controlNo    VARCHAR(30)  = NULL    
 ,@tranId    BIGINT   = NULL    
 ,@message    NVARCHAR(500) = NULL    
 ,@messageComplaince  VARCHAR(500) = NULL    
 ,@messageOFAC   VARCHAR(500) = NULL    
 ,@messageCashLimitHold  VARCHAR(500) = NULL    
 ,@lockMode    CHAR(1)   = NULL    
 ,@viewType    VARCHAR(50)  = NULL    
 ,@viewMsg    VARCHAR(MAX) = NULL    
 ,@branch    INT    = NULL    
 ,@sortBy    VARCHAR(50)  = NULL    
 ,@sortOrder    VARCHAR(5)  = NULL    
 ,@pageSize    INT    = NULL    
 ,@pageNumber   INT    = NULL    
 ,@ip     VARCHAR(MAX) = NULL    
 ,@dcInfo    VARCHAR(MAX) = NULL    
 ,@holdTranId   INT   = NULL    
)     
AS    
    
DECLARE     
    @select_field_list VARCHAR(MAX)    
    ,@extra_field_list  VARCHAR(MAX)    
    ,@table             VARCHAR(MAX)    
    ,@sql_filter        VARCHAR(MAX)    
     
 DECLARE @controlNoEncrypted VARCHAR(100)    
    ,@code      VARCHAR(50)    
    ,@userName     VARCHAR(50)    
    ,@password     VARCHAR(50)     
    ,@userType     VARCHAR(10)    
    ,@tranStatus     VARCHAR(50)    
    ,@tranIdType     CHAR(1)    
    ,@voucherNo     VARCHAR(50)    
    ,@nepDate     VARCHAR(50)    
      
SET NOCOUNT ON;    
SET XACT_ABORT ON;    
     
SET  @tranIdType = DBO.FNAGetTranIdType(@tranId)    
SET @nepDate = GETDATE()    
     
IF @controlNo IS NOT NULL    
BEGIN    
 SET @controlNo = UPPER(@controlNo)    
 SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)    
 SELECT @tranId = id, @tranStatus = tranStatus,@holdTranId =holdTranId FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted     
END    
    
ELSE IF @tranId IS NOT NULL    
BEGIN    
 IF @tranIdType ='H'  --- h - remitTRanTemp , c-  remitTran    
  SELECT @controlNoEncrypted = controlNo, @tranStatus = tranStatus,@voucherNo = voucherNo,@holdTranId =holdTranId ,@controlNo = dbo.FNADecryptString(controlNo)    
  FROM vwremitTran WITH(NOLOCK) WHERE holdTranId = @tranId    
 ELSE    
  SELECT @controlNoEncrypted = controlNo, @tranStatus = tranStatus,@voucherNo = voucherNo,@holdTranId =holdTranId ,@controlNo = dbo.FNADecryptString(controlNo)    
  FROM remitTran WITH(NOLOCK) WHERE id = @tranId    
    
  SET @controlNo=dbo.decryptDb(@controlNoEncrypted)
  
  IF LEN(@controlNoEncrypted)=0    
   SET @controlNoEncrypted ='0'    

END    
IF @flag = 's'    
BEGIN    
	DECLARE @partnerId INT, @isRealTime BIT,@pcountry INT
	
	SELECT @partnerId = pSuperAgent,@pcountry = CM.COUNTRYID  
	FROM REMITTRANTEMP (NOLOCK) RTT
	INNER JOIN COUNTRYMASTER CM (NOLOCK) ON CM.COUNTRYNAME = RTT.PCOUNTRY 
	WHERE  DBO.DECRYPTDB(CONTROLNO) = @controlNo

	SELECT @isRealTime = isRealTime
	FROM TblPartnerwiseCountry (NOLOCK) 
	WHERE AgentId = @partnerId
	AND COUNTRYID = @pcountry

     
 EXEC proc_tranViewHistory 'i', @user, @tranId, @controlNo, NULL,@viewType,@viewMsg    
 --Transaction Details    
 SELECT     
   tranId = ISNULL(trn.holdtranid,trn.id)  
  ,holdTranId = ISNULL(trn.holdtranid,trn.id)
  ,controlNo = dbo.FNADecryptString(trn.controlNo)    
      
  --Sender Information    
  ,sMemId = sen.membershipId    
  ,sCustomerId = sen.customerId   
  ,ISNULL(cm.membershipid,cm.customerId) uniqueId
  ,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')    
  ,sCountryName = trn.sCountry    
  ,sStateName = sen.state    
  ,sDistrict = sen.district    
  ,sCity = isnull(sen.city,'')    
  ,sAddress = sen.address    
  ,sContactNo = COALESCE(sen.mobile, sen.homephone, sen.workphone)   
  ,sDob = convert(varchar(10),sen.dob,121) 
  ,sIdType = ISNULL(sdv.detailTitle,sen.idType)    
  ,sIdNo = sen.idNumber    
  ,sValidDate = sen.validDate    
  ,sEmail = sen.email    
  ,extCustomerId = sen.extCustomerId    
    
  --Receiver Information    
  ,rMemId = rec.membershipId   
  ,rCustomerId = rec.customerId    
  ,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')    
  ,rCountryName = rec.country    
  ,rStateName = rec.state    
  ,rDistrict = rec.district    
  ,rCity = ISNULL(rec.city,'')    
  ,rAddress = rec.address    
  ,rContactNo = COALESCE(rec.mobile, rec.homephone, rec.workphone)    
  ,rIdType = CASE WHEN ISNULL(sdv1.detailTitle, rec.idType)='select' THEN '' ELSE ISNULL(sdv1.detailTitle, rec.idType) END
  ,rIdNo = ISNULL(rec.idNumber2, rec.idNumber)+ ISNULL(' ' + rec.idPlaceOfIssue2,'')    
     
      
  --Sending Agent Information    
  ,sAgentEmail = sa.agentEmail1    
  ,sAgentName = CASE WHEN trn.sAgentName = trn.sBranchName THEN '-' ELSE trn.sAgentName END    
  ,sBranchName = trn.sBranchName    
  ,sAgentCountry = sa.agentCountry    
  ,sAgentState = sa.agentState    
  ,sAgentDistrict = sa.agentDistrict    
  ,sAgentLocation = sLoc.districtName    
  ,sAgentCity = sa.agentCity    
  ,sAgentAddress = sa.agentAddress    
      
  --Payout Agent Information    
  ,pAgentName = case when trn.pAgentName is null then '[Any Where]' else CASE WHEN trn.pAgentName = trn.pBranchName THEN '-' ELSE trn.pAgentName END end    
  ,pBranchName = trn.pBranchName    
  ,pAgentCountry = trn.pCountry    
  ,pAgentState = trn.pState    
  ,pAgentDistrict = rec.district    
  ,pAgentLocation = CASE WHEN trn.pBank is not null then trn.pBankName else '' end    
  ,pAgentCity = pa.agentCity    
  ,pAgentAddress = pa.agentAddress    
      
  ,trn.tAmt    
  ,trn.serviceCharge    
  ,handlingFee = ISNULL(trn.handlingFee, 0)    
  ,sAgentComm = isnull(sAgentComm,0)    
  ,sAgentCommCurrency = ISNULL(sAgentCommCurrency,0)    
  ,pAgentComm = ISNULL(pAgentComm,0)    
  ,pAgentCommCurrency = 'MNT'--ISNULL(pAgentCommCurrency,0)    
  ,exRate = customerRate    
  ,trn.cAmt    
  ,pAmt = FLOOR(trn.pAmt)    
      
  ,relationship = CASE WHEN ISNUMERIC(trn.relWithSender)=1 THEN sdv2.detailTitle ELSE trn.relWithSender END    
    
  ,purpose = ISNULL(trn.purposeOfRemit, '-')    
  ,sourceOfFund = ISNULL(trn.sourceOfFund, '-')    
  ,collMode = trn.collMode    
  ,trn.collCurr    
  ,paymentMethod = UPPER(trn.paymentMethod)    
  ,trn.payoutCurr    
  ,BranchName = trn.pBankBranchName    
  ,accountNo = trn.accountNo    
  ,BankName = ISNULL(trn.pBankName,bb.BANK_NAME)    
  ,tranStatus = CASE when trn.payStatus = 'Post' and trn.tranType='D' then 'Post' else trn.tranStatus end            
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
  ,trn.lockedBy    
  ,trn.lockedDate    
  ,trn.payTokenId    
  ,trn.tranStatus    
  ,trn.tranType    
  ,trn.holdTranId    
  ,sTelNo = ISNULL(sen.homephone, sen.workphone)    
  ,rTelNo = ISNULL(rec.homephone, rec.workphone)    
  ,CashOrBank = ''    
  ,purposeOfRemit = ISNULL(trn.purposeOfRemit, '-')    
  ,custRate = isnull(trn.customerRate,0) +isnull(schemePremium,0)    
  ,settRate = agentCrossSettRate    
  ,nativeCountry = sen.nativeCountry    
  ,@isRealTime isRealTime
  ,CASE WHEN trn.pSuperAgent='394450' THEN 1 ELSE 0 END isPartnerRealTime				----------use for real time cancel from thirdpart api for tanglo api
  ,trn.pSuperAgent PartnerId
 FROM vwRemitTran trn WITH(NOLOCK)    
 LEFT JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId    
 LEFT JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId    
 LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId    
 LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId    
 LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode    
 LEFT JOIN apiLocationMapping ALM WITH(NOLOCK) ON pLoc.districtCode=ALM.apiDistrictCode    
 LEFT JOIN zoneDistrictMap ZDM WITH(NOLOCK) ON ZDM.districtId=ALM.districtId    
 LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode    
 LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sen.idType=CAST(sdv.valueId AS VARCHAR)    
 LEFT JOIN staticDataValue sdv1 WITH(NOLOCK) ON ISNULL(rec.idType,rec.idType2)=CAST(sdv1.valueId AS VARCHAR)    
 LEFT JOIN staticDataValue sdv2 WITH(NOLOCK) ON rec.relationType=CAST(sdv2.valueId AS VARCHAR) 
 LEFT JOIN customerMaster cm WITH(NOLOCK) ON cm.customerId = sen.customerId
 LEFT JOIN dbo.API_BANK_LIST BB WITH (NOLOCK) ON BB.BANK_ID=trn.pBank      
 WHERE trn.controlNo = @controlNoEncrypted OR isnull(trn.id,trn.holdTranId) = @tranId    
     
 --End of Transaction Details------------------------------------------------------------    
     
 --Lock Transaction----------------------------------------------------------------------    
 IF (@lockMode = 'Y')    
 BEGIN    
  UPDATE remitTran SET    
    tranStatus = 'Lock'    
   ,lockedBy = @user    
   ,lockedDate = GETDATE()    
   ,lockedDateLocal = @nepDate    
  WHERE (tranStatus = 'Payment' AND tranStatus <> 'CancelRequest')     
    AND payStatus = 'Unpaid' AND (controlNo = @controlNoEncrypted OR id = @tranId)    
    
 END    
 --End of Lock Transaction---------------------------------------------------------------    
     
 --Log Details---------------------------------------------------------------------------    
 SELECT     
   rowId    
  ,message = CASE WHEN message IS NULL THEN fieldName + ' ' + OLDVALUE+ ' Changed By '+REPLACE(REPLACE(FIELDVALUE, '<root><row ', ''), '  secondLastName = ""/></root>', '') ELSE [MESSAGE] END     
  ,trn.createdBy    
  ,trn.createdDate    
  ,isnull(trn.fileType,'')fileType    
 FROM tranModifyLog trn WITH(NOLOCK)    
 LEFT JOIN applicationUsers au WITH(NOLOCK) ON trn.createdBy = au.userName     
 WHERE trn.tranId = @tranId OR trn.controlNo = @controlNoEncrypted    
 ORDER BY trn.rowId DESC    
    
 SELECT     
   bankName = 'Cash'    
  ,collMode = 'Cash'    
  ,amt = ''    
  ,collDate = ''    
  ,voucherNo = ''    
  ,narration = 'Cash Collection'    
    
 SELECT C.PARTICULARS, C.TRANDATE, C.DEPOSITAMOUNT     
 FROM TBL_BANK_DEPOSIT_TXN_MAPPING B(NOLOCK)    
 INNER JOIN CUSTOMER_DEPOSIT_LOGS C(NOLOCK) ON C.TRANID = B.DEPOSIT_LOG_ID    
 WHERE HOLD_TRAN_ID = @holdTranId    
END    
ELSE IF @flag = 'voucher'    
BEGIN    
 IF EXISTS(SELECT * FROM dbo.bankCollectionVoucherDetail (NOLOCK) WHERE tempTranId = @tranId)    
 BEGIN    
     SELECT b.voucherAmt, b.voucherDate, b.voucherNo, v.bankName FROM dbo.bankCollectionVoucherDetail b (NOLOCK)    
  INNER JOIN vwBankLists v (NOLOCK) ON b.bankId = v.rowId WHERE b.tempTranId = @tranId    
 END    
    ELSE    
 BEGIN    
     SELECT b.voucherAmt, b.voucherDate, b.voucherNo, v.bankName FROM dbo.bankCollectionVoucherDetail b (NOLOCK)    
  INNER JOIN vwBankLists v (NOLOCK) ON b.bankId = v.rowId WHERE b.mainTranId = @tranId    
 END    
END    
ELSE IF @flag = 'ac'  --Add Comment    
BEGIN    
BEGIN TRY    
 IF @message IS NULL    
 BEGIN    
  EXEC proc_errorHandler 1, 'Message can not be blank.', @tranId    
  RETURN    
 END    
 IF @user IS NULL    
 BEGIN    
  EXEC proc_errorHandler 1, 'Your session has expired. Cannot add complain.', NULL    
  RETURN    
 END    
 IF @tranId IS NULL    
 BEGIN    
  EXEC proc_errorHandler 1, 'Transaction No can not be blank.', @tranId    
  RETURN    
 END    
     
 DECLARE @ttId VARCHAR(10)=NULL,@OrderNo VARCHAR(50)=NULL    
    
 SELECT     
  @OrderNo = NULLIF(LTRIM(RTRIM(voucherNo)), '')    
 FROM remitTran (NOLOCK) WHERE id = @tranId AND sRouteId = 'RIA'    
 BEGIN TRAN    
    
  INSERT INTO tranModifyLog(    
    tranId    
   ,controlNo    
   ,message    
   ,createdBy    
   ,createdDate    
   ,MsgType    
   ,status    
   ,needToSync    
  )    
  SELECT    
    @tranId    
   ,@controlNoEncrypted    
   ,@message    
   ,@user    
   ,@nepDate    
   ,'C'    
   ,'Not Resolved'    
   ,CASE WHEN @OrderNo IS NOT NULL THEN 1 ELSE 0 END    
    
  --SET @ttId=@@IDENTITY    
    
  --IF @OrderNo IS NOT NULL    
  --BEGIN    
  -- UPDATE tranModifyLog SET needToSync=1 WHERE rowId=@ttId    
  --END        
     
  IF ISNUMERIC(@controlNo) = 1 and right(@controlNo,1) <> 'D'    
  BEGIN    
   INSERT INTO dbo.rs_remitTranTroubleTicket(RefNo,Comments,DatePosted,PostedBy,uploadBy,status,noteType,tranno,category)    
   SELECT @controlNoEncrypted, @message, GETDATE(), @user, @user, NULL, 2, NULL, 'push'      
  END    
 COMMIT TRAN    
 ---EXEC proc_errorHandler 0, 'Comments has been added successfully.', @tranId    
 SELECT '0' AS errorCode,'Comments has been added successfully.' AS Msg,@ttId AS Id,'RIA' AS Extra ,@OrderNo AS Extra2    
    
END TRY    
BEGIN CATCH    
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id    
END CATCH    
END    
    
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
SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)    
 IF @controlNoEncrypted IS NOT NULL    
  SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted    
     
 IF OBJECT_ID('tempdb..#tempMaster') IS NOT NULL     
 DROP TABLE #tempMaster    
     
 IF OBJECT_ID('tempdb..#tempDataTable') IS NOT NULL     
 DROP TABLE #tempDataTable    
      
    
 CREATE TABLE #tempDataTable    
 (    
  DATA VARCHAR(MAX) NULL    
 )    
     
 DECLARE @ofacKeyIds VARCHAR(MAX)    
 SELECT @ofacKeyIds=blackListId FROM dbo.remitTranOfac     
 WHERE TranId = ISNULL(@holdTranId, @tranId)    
    
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
   ,@REMARKS AS VARCHAR(MAX)=''    
   ,@ALT AS VARCHAR(MAX)=''    
   ,@DATA AS VARCHAR(MAX)=''    
   ,@DATA_SOURCE AS VARCHAR(200)=''    
     
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
        
  SELECT @REMARKS=ISNULL(remarks,'')+isnull('<br/> ID Type:'+idType,'')+isnull(':'+idNumber,'')+isnull('|DOB:'+dob,'')+isnull(' |Father Name: '+FatherName,'')    
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
   SET @DATA=@DATA+'<BR><b>Other Info :</b>'+@REMARKS    
    
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
    
ELSE IF @flag='Compliance'    
BEGIN    
 SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo)    
     
 SELECT    
  rowId    
  ,csDetailRecId = CASE WHEN CSDETAILTRANID <> 0 THEN  CL.id ELSE 0 END    
  ,[S.N.]  = ROW_NUMBER() OVER(ORDER BY ROWID)     
  ,[Remarks] = CASE WHEN RTC.CSDETAILTRANID = 0 THEN RTC.REASON     
       WHEN RTC.CSDETAILTRANID <> 0 THEN CL.COMPLAINCEDETAILMESSAGE    
      END    
  ,[Matched TRAN ID] = ISNULL(rtc.matchTranId, '-')
  ,[Matched ControlNo] = ISNULL(CASE when dbo.fnadecryptstring(rtt.controlno) = '' THEN  dbo.fnadecryptstring(rt.controlno) ELSE dbo.fnadecryptstring(rtt.controlno) END,'-')
  ,[Doc. Required] = CASE WHEN isDocumentRequired = 1 THEN 'Yes' ELSE 'No' END  
  ,[Approved Remarks] = rtc.approvedby + ': ' + rtc.approvedremarks  
 FROM remitTranCompliance rtc WITH(NOLOCK)    
 LEFT JOIN ComplianceLog CL WITH(NOLOCK) ON CL.TRANID = RTC.TRANID AND RTC.CSDETAILTRANID = CL.complianceId     
 LEFT JOIN CSDETAIL CD(NOLOCK) ON CD.csDetailId = CL.complianceId    
  LEFT JOIN vwremittran rtt (NOLOCK) on rtt.id = rtc.matchTranId
 LEFT JOIN cancelTranHistory rt (nolock) on rt.tranid = rtc.matchTranId
 WHERE rtc.TranId = ISNULL(@holdTranId, @tranId)    
 --AND CD.nextAction = 'H'    

    
 --UNION ALL     
     
 --SELECT    
 --  rowId    
 -- ,csDetailRecId     
 -- ,[S.N.]  = ROW_NUMBER()OVER(ORDER BY ROWID)     
 -- ,[Remarks] = ISNULL( RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' +     
 --     CASE WHEN checkType = 'Sum' THEN 'Transaction Amount'     
 --       WHEN checkType = 'Count' THEN 'Transaction Count' END    
 --     + ' exceeds ' + CAST(PARAMETER AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)       
 --     ,reason)    
 -- ,[Matched TRAN ID] = ISNULL(rtc.matchTranId,rtc.TranId)    
 --FROM remitTranCompliancePay rtc WITH(NOLOCK)    
 --LEFT JOIN csDetailRec cdr WITH(NOLOCK) ON rtc.csDetailTranId = cdr.csDetailRecId     
 --WHERE rtc.TranId = ISNULL(@holdTranId, @tranId)    
    
END    
ELSE IF @flag='CashLimitHold'    
BEGIN    
 SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo)    
 SELECT    
   rowId    
  ,[S.N.]  = ROW_NUMBER()OVER(ORDER BY ROWID)     
  ,[TRAN ID] = rtclh.tranId    
  ,[Remarks] =   ' Transaction is in Cash Limit Hold beacase send amount is greater than available cash hold limit'    
      
 FROM remitTranCashLimitHold rtclh WITH(NOLOCK)    
 WHERE rtclh.TranId = ISNULL(@holdTranId, @tranId)    
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
 DECLARE @tranIds AS VARCHAR(MAX), @criteria AS INT, @totalTran AS INT, @criteriaValue AS VARCHAR(500), @id AS INT,@reason VARCHAR(500)    
 SELECT     
  @tranIds = matchTranId,     
  @id = TranId     
 FROM remitTranCompliance with(nolock)     
 WHERE rowId = @controlNo --(ROWID) --id of remitTranCompliance    
    
 SELECT @criteria = criteria FROM csDetailRec with(nolock) WHERE csDetailRecId = @tranId--id of csDetailRec    
 SELECT @totalTran = COUNT(*) FROM dbo.Split(',', @tranIds)    
      
 IF @criteria='5000'    
  SELECT @criteriaValue = B.membershipId    
    FROM tranSenders B with(nolock) WHERE B.tranId = @id        
        
 IF @criteria='5001'    
  SELECT @criteriaValue = senderName FROM remitTran with(nolock) WHERE Id = @id     
  --SELECT @criteriaValue = SNULL(B.firstName, '') + ISNULL(' ' + B.middleName, '') + ISNULL(' ' + B.lastName1, '') + ISNULL(' ' + B.lastName2, '')  FROM tranSenders B with(nolock) WHERE B.tranId = @id    
        
 IF @criteria='5002'    
  SELECT @criteriaValue = B.mobile    
    FROM tranSenders B with(nolock) WHERE B.tranId = @id     
        
 IF @criteria='5003'    
  SELECT @criteriaValue = B.membershipId    
    FROM tranReceivers B with(nolock) WHERE B.tranId = @id     
        
 IF @criteria='5004'    
  SELECT @criteriaValue = B.membershipId    
    FROM tranReceivers B with(nolock) WHERE B.tranId = @id    
        
 IF @criteria='5005'    
  SELECT @criteriaValue = receiverName FROM remitTran with(nolock) WHERE Id = @id     
  --SELECT @criteriaValue = ISNULL(B.firstName, '') + ISNULL(' ' + B.middleName, '') + ISNULL(' ' + B.lastName1, '') + ISNULL(' ' + B.lastName2, '') FROM tranReceivers B with(nolock) WHERE B.tranId = @id    
     
 IF @criteria='5006'    
  SELECT @criteriaValue = B.mobile    
    FROM tranReceivers B with(nolock) WHERE B.tranId = @id      
     
 IF @criteria='5007'    
  SELECT @criteriaValue = A.accountNo    
    FROM remitTran A with(nolock) WHERE A.id = @id     
        
 -- @tranId=0 LOGIC IS ONLY FOR Suspected duplicate transaction  WHERE THERE IS csDetailRecId ALWAYS 0    
        
 SELECT    
   REMARKS = CASE WHEN @tranId = 0 THEN @reason ELSE    
      RTRIM(LTRIM(dbo.FNAGetDataValue(condition))) + ' ' +     
      CASE WHEN checkType = 'Sum' THEN 'Transaction Amount'     
        WHEN checkType = 'Count' THEN 'Transaction Count' END    
      + ' exceeds ' + CAST(parameter AS VARCHAR) + ' limit within ' + CAST(period AS VARCHAR)+ ' days ' + dbo.FNAGetDataValue(criteria)+': <font size=''2px''>'+ISNULL(@criteriaValue,'')+'</font>'    
      END    
  ,totTran = 'Total Count: <b>'+ CASE WHEN @tranId = 0 THEN '1' ELSE  CAST(@totalTran AS VARCHAR) END +'</b>'    
 FROM csDetailRec with(nolock)    
 WHERE csDetailRecId= CASE WHEN @tranId=0 THEN 1 ELSE @tranId END    
    
 SELECT     
   [S.N.]   = ROW_NUMBER() OVER(ORDER BY @controlNo)    
  ,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)    
  ,[TRAN AMOUNT] = dbo.ShowDecimal(trn.cAmt)     
  ,[CURRENCY]  = trn.collCurr     
  ,[TRAN DATE] = CONVERT(VARCHAR,trn.createdDate,101)        
 FROM VWremitTran trn with(nolock) INNER JOIN     
 (    
  SELECT * FROM dbo.Split(',', @tranIds)    
 )B ON trn.holdTranId = B.value    
     
 UNION ALL    
 ---- RECORD DISPLAY FROM CANCEL TRANSACTION TABLE    
 SELECT     
   [S.N.]   = ROW_NUMBER() OVER(ORDER BY @controlNo)    
  ,[CONTROL NO.]  = dbo.FNADecryptString(trn.controlNo)    
  ,[TRAN AMOUNT] = dbo.ShowDecimal(trn.cAmt)     
  ,[CURRENCY]  = trn.collCurr     
  ,[TRAN DATE] = CONVERT(VARCHAR,trn.createdDate,101)        
 FROM cancelTranHistory trn with(nolock) INNER JOIN     
 (    
  SELECT * FROM dbo.Split(',', @tranIds)    
 )B ON trn.tranId = B.value    
END    
    
ELSE IF @flag = 'saveComplainceRmks'  --Add Approve Remarks    
BEGIN TRY    
      
  IF EXISTS(SELECT 'X' FROM remitTranOfac WITH(NOLOCK) WHERE TranId = @holdTranId)    
  BEGIN    
  IF EXISTS(SELECT 'X' FROM remitTranCompliance WITH(NOLOCK) WHERE TranId = @holdTranId)    
  BEGIN    
   IF @messageOFAC IS NULL    
   BEGIN      
    EXEC proc_errorHandler 1, 'OFAC remarks can not be blank.', @holdTranId    
    RETURN;      
   END     
   IF @messageComplaince IS NULL    
   BEGIN      
    EXEC proc_errorHandler 1, 'Complaince remarks can not be blank.', @holdTranId    
    RETURN;      
   END     
  END    
  ELSE    
  BEGIN    
   IF @messageOFAC IS NULL    
   BEGIN      
    EXEC proc_errorHandler 1, 'OFAC remarks can not be blank.', @holdTranId    
    RETURN;      
   END      
  END    
 END    
     
 IF EXISTS(SELECT 'X' FROM remitTranCompliance WITH(NOLOCK) WHERE TranId=@holdTranId)    
 BEGIN    
  IF @messageComplaince IS NULL    
  BEGIN      
   EXEC proc_errorHandler 1, 'Complaince remarks can not be blank.', @holdTranId    
   RETURN;      
  END     
 END    
    
     BEGIN TRANSACTION    
     UPDATE remitTranOfac SET     
   approvedRemarks  = @messageOFAC    
      ,approvedBy   = @user    
      ,approvedDate  = @nepDate     
     WHERE TranId = ISNULL(@holdTranId, @tranId) AND approvedBy IS NULL    
         
     UPDATE remitTranCompliance SET     
   approvedRemarks  = @messageComplaince    
      ,approvedBy   = @user    
      ,approvedDate  = @nepDate    
     WHERE TranId = ISNULL(@holdTranId, @tranId) AND approvedBy IS NULL    
           
     UPDATE remitTranTemp SET     
   tranStatus = CASE tranStatus    
        WHEN 'Cash Limit/Compliance Hold' THEN 'Cash Limit'    
        WHEN 'Cash Limit/OFAC Hold' THEN 'Cash Limit'    
        WHEN 'Cash Limit/OFAC/Compliance Hold' THEN 'Cash Limit'    
        ELSE 'Hold'    
       END    
     WHERE id = @tranId    
    
    COMMIT TRANSACTION    
    
 EXEC proc_errorHandler 0, 'Release remarks has been saved successfully.', @tranId     
     
END TRY    
BEGIN CATCH    
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id    
END CATCH    
    
ELSE IF @flag = 'saveCashHoldRmks'  --Add Approve Remarks    
BEGIN TRY    
 IF EXISTS(SELECT 'X' FROM dbo.remitTranCashLimitHold WITH(NOLOCK) WHERE TranId = @holdTranId)    
 BEGIN    
  IF @messageCashLimitHold IS NULL    
  BEGIN      
   EXEC proc_errorHandler 1, 'Cash Limit Hold remarks can not be blank.', @holdTranId    
   RETURN;      
  END     
 END    
     
 BEGIN TRANSACTION    
     --select * from remitTranCashLimitHold    
  --EXEC proc_transactionView @flag = 'saveCashHoldRmks', @user = 'admin', @controlNo = '212048659', @tranId = '100353262', @messageComplaince = null, @messageOFAC = null, @messageCashLimitHold = 'approve cash hold limit'    
  IF EXISTS(SELECT 'X' FROM dbo.remitTranTemp (NOLOCK) WHERE id=@tranId)
  BEGIN
      UPDATE H SET H.approvedRemarks = @messageCashLimitHold, H.approvedBy = @user, H.approvedDate = GETDATE()    
  FROM dbo.remitTranTemp R(NOLOCK)    
  INNER JOIN remitTranCashLimitHold H(NOLOCK) ON R.id = H.TRANID    
  AND R.id = @tranId  AND H.approvedBy IS NULL    
    
     UPDATE dbo.remitTranTemp SET     
   tranStatus = CASE tranStatus    
        WHEN 'Cash Limit Hold' THEN 'Hold'    
        WHEN 'Cash Limit/Compliance Hold' THEN 'Compliance Hold'    
        WHEN 'Cash Limit/OFAC Hold' THEN 'OFAC Hold'    
        WHEN 'Cash Limit/OFAC/Compliance Hold' THEN 'OFAC/Compliance Hold'    
        ELSE 'Payment'    
       END    
     WHERE id = @tranId    
  END
  IF EXISTS ( SELECT 'X' FROM dbo.remitTran (NOLOCK) WHERE id=@tranId)
  BEGIN
  UPDATE H SET H.approvedRemarks = @messageCashLimitHold, H.approvedBy = @user, H.approvedDate = GETDATE()    
  FROM REMITTRAN R(NOLOCK)    
  INNER JOIN remitTranCashLimitHold H(NOLOCK) ON R.HOLDTRANID = H.TRANID    
  AND R.id = @tranId  AND H.approvedBy IS NULL    
    
     UPDATE remitTran SET     
   tranStatus = CASE tranStatus    
        WHEN 'Cash Limit Hold' THEN 'Hold'    
        WHEN 'Cash Limit/Compliance Hold' THEN 'Compliance Hold'    
        WHEN 'Cash Limit/OFAC Hold' THEN 'OFAC Hold'    
        WHEN 'Cash Limit/OFAC/Compliance Hold' THEN 'OFAC/Compliance Hold'    
        ELSE 'Payment'    
       END    
     WHERE id = @tranId    
      
  END
    
 COMMIT TRANSACTION    
    
 EXEC proc_errorHandler 0, 'Release remarks has been saved successfully.', @tranId     
     
END TRY    
BEGIN CATCH    
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id   
END CATCH    
--EXEC proc_transactionView @FLAG='chkFlag',@tranId='26'    
ELSE IF @flag = 'chkFlagOFAC'      
BEGIN     
 SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)    
 IF @controlNoEncrypted IS NOT NULL    
  SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted    
    
 SELECT CASE WHEN approvedDate is null then 'N' else 'Y'  end AS Compliance_FLAG    
 FROM remitTranOfac O(NOLOCK)    
 WHERE TranId=@holdTranId    
END    
    
ELSE IF @flag = 'chkFlagCOMPLAINCE'      
BEGIN     
 SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)    
 IF @controlNoEncrypted IS NOT NULL    
  SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted    
    
 SELECT CASE WHEN approvedDate is null then 'N' else 'Y'  end AS Compliance_FLAG    
 FROM remitTranCompliance (NOLOCK) WHERE TranId=@holdTranId    
END    
ELSE IF @flag = 'chkFlagCashLimitHold'      
BEGIN     
 SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)    
 IF @controlNoEncrypted IS NOT NULL    
  SELECT @holdTranId = holdTranId, @tranId = id FROM vwRemitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted    
    
 SELECT CASE WHEN H.approvedDate is null then 'N' else 'Y'  end AS Compliance_FLAG    
 FROM remitTranCashLimitHold H(NOLOCK)    
 WHERE TRANID = @holdTranId      
END    
    
ELSE IF @flag = 'va'   --Verify Agent For Tran Modification    
BEGIN    
 --Necessary paremeter: @user, @branch, @controlNo    
 IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = dbo.FNAEncryptString(@controlNo) AND sBranch = @branch)    
 BEGIN    
  EXEC proc_errorHandler 1, 'Transaction not found', NULL    
  RETURN    
 END    
 EXEC proc_errorHandler 0, 'Success', NULL    
END    
IF @flag = 's-QuestionaireAnswer'    
BEGIN     
    
   SET @table = '      
    (      
  --SELECT QUES_ID,QSN,ANSWER_TEXT FROM dbo.TBL_TXN_COMPLIANCE_CDDI A     
  SELECT QUES_ID,Question_TEXT as QSN,ANSWER_TEXT FROM dbo.TBL_TXN_COMPLIANCE_CDDI A     
  INNER JOIN dbo.TBL_COMPLIANCE_QUESTION B ON CAST(B.Row_ID AS VARCHAR) = A.QUES_ID  WHERE CAST(A.TRAN_ID AS VARCHAR) = '''+CAST(ISNULL(@tranId,@holdTranId) AS VARCHAR)+'''';     
 -- INNER JOIN dbo.VIEW_COMPLIANCE_QUESTION_SET B ON CAST(B.ID AS VARCHAR) = A.QUES_ID  WHERE CAST(A.TRAN_ID AS VARCHAR) = '''+CAST(ISNULL(@holdTranId, 0) AS VARCHAR)+'''';     
 SET @table = @table + ' )x';      
    
    set @pageSize =  50    
    --SET @select_field_list = 'QUES_ID,QSN,ANSWER_TEXT';      
    SET @select_field_list = 'QUES_ID,QSN,ANSWER_TEXT';      
    EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,@extra_field_list, @sortBy, @sortOrder, @pageSize,@pageNumber;      
END      
IF @flag = 'questionaire-available'    
BEGIN     
   SELECT * FROM TBL_TXN_COMPLIANCE_CDDI WHERE TRAN_ID = @holdTranId    
END      
IF @flag = 'checkTran'    
BEGIN     
     
 SELECT @holdTranId =  holdtranid from remittran where id = @TranId    
 --contain n ofac and cash hold    
 IF EXISTS(SELECT 'x' from remittranofac rto (nolock)    
     INNER JOIN  remitTranCashLimitHold rtch (nolock) on rto.tranid = rtch.tranid    
     WHERE rto.tranid = @holdTranId)    
 BEGIN    
  SELECT 1 'ErrorCode','Contains in both Ofac and Cash limit' Msg,null Id    
  RETURN    
 END    
 IF EXISTS(SELECT 'x' from remittrancompliance rto (nolock)    
     INNER JOIN  remitTranCashLimitHold rtch (nolock) on rto.tranid = rtch.tranid    
     WHERE rto.tranid = @holdTranId)    
 BEGIN    
  SELECT 1 'ErrorCode','Contains in both Compliance and Cash limit' Msg,null Id    
  RETURN    
 END    
    
   select 0 'ErrorCode','Not Found in both' Msg,NULL Id    
END

GO