

ALTER PROC [dbo].[proc_modifyTranRequest]    
  @flag					VARCHAR(50)		= NULL    
 ,@controlNo			VARCHAR(20)		= NULL    
 ,@rowId				INT				= NULL    
 ,@newValue				VARCHAR(500)	= NULL    
 ,@oldValue				VARCHAR(500)	= NULL    
 ,@changeType		    VARCHAR(200)	= NULL    
 ,@user					VARCHAR(100)	= NULL    
 ,@ScChargeMod			MONEY			= NULL    
 ,@createdBy			VARCHAR(100)	= NULL    
 ,@fieldValue		    VARCHAR(MAX)	= NULL    
 ,@fieldName		    VARCHAR(MAX)	= NULL     
 ,@sortBy				VARCHAR(50)		= NULL    
 ,@sortOrder			VARCHAR(5)		= NULL    
 ,@pageSize				INT				= NULL    
 ,@pageNumber			INT				= NULL    
 ,@branchId				INT				= NULL    
 ,@tranId				BIGINT			= NULL  
AS    
BEGIN TRY    
    
 DECLARE     
   @table VARCHAR(MAX)    
  ,@sql_filter VARCHAR(200)    
  ,@select_field_list VARCHAR(MAX)    
  ,@encryptedControlNo VARCHAR(100)    
    
 IF @controlNo IS NOT NULL    
  SELECT @encryptedControlNo = dbo.FNAEncryptString(@controlNo)    
      
 IF @flag='i' -->> TXN modification Rquest part    
 BEGIN      
  
  IF (@fieldName ='accountNo' AND LEN(@newValue) > 30)    
  BEGIN    
   EXEC proc_errorHandler 0,'Account number field is out of range. Max Size 20 characters.',NULL    
   RETURN    
  END    
  IF (@fieldName ='senderName' AND LEN(@newValue) > 100)    
  BEGIN    
   EXEC proc_errorHandler 0,'Sender name field is out of range. Max Size 100 characters.',NULL    
   RETURN    
  END    
  IF (@fieldName ='receiverName' AND LEN(@newValue) > 100)    
  BEGIN    
   EXEC proc_errorHandler 0,'Receiver name field is out of range. Max Size 100 characters.',NULL    
   RETURN    
  END    
  IF (@fieldName ='rAddress' AND LEN(@newValue) > 100)    
  BEGIN    
   EXEC proc_errorHandler 0,'Receiver address field is out of range. Max Size 100 characters.',NULL    
   RETURN    
  END    
  IF (@fieldName ='rContactNo' AND LEN(@newValue) > 20)    
  BEGIN    
   EXEC proc_errorHandler 0,'Receiver contact field is out of range. Max Size 20 characters.',NULL    
   RETURN    
  END    
  IF (@fieldName ='rIdNo' AND LEN(@newValue) > 50)    
  BEGIN    
   EXEC proc_errorHandler 0,'Receiver id number field is out of range. Max Size 50 characters.',NULL    
   RETURN    
  END    
  IF EXISTS(    
   SELECT 'X' FROM tranModifyLog    
    WHERE fieldName = @fieldName     
     AND [status] = 'Request'     
     AND controlNo=dbo.FNAEncryptString(@controlNo)    
  )    
  BEGIN    
   EXEC proc_errorHandler 0,'Cannot Insert Duplicate Request',NULL    
   RETURN    
  END    
     --GET receiverid AND customerid
	DECLARE @receiverId INT,@customerId INT
	SELECT  @receiverId = trt.customerid,@customerId = tst.customerid,@tranId = rtt.id from remittrantemp rtt 
	INNER JOIN tranreceiverstemp trt on trt.tranid = rtt.id
	INNER JOIN transenderstemp tst on tst.tranid = rtt.id
	WHERE rtt.controlNo = @encryptedControlNo
  ----## direct update the temp transactions modification details    
  IF EXISTS(SELECT 'A' FROM remitTranTemp(nolock) where controlNo=dbo.FNAEncryptString(@controlNo))    
  BEGIN    
    SELECT @tranId = rt.id, @oldValue = CASE     
    WHEN @fieldName ='rIdType' THEN ISNULL(c.idType, c.idType2)     
    WHEN @fieldName ='rAddress' THEN c.address    
    WHEN @fieldName ='rContactNo' THEN c.mobile    
    WHEN @fieldName ='rIdNo' THEN c.idNumber    
    WHEN @fieldName ='accountNo' THEN rt.accountNo    
    WHEN @fieldName ='senderName' THEN b.firstName + ISNULL(' ' + b.middleName, '') + ISNULL(' ' + b.lastName1, '') + ISNULL(' ' + b.lastName2, '')    
    WHEN @fieldName ='receiverName' THEN c.firstName + ISNULL(' ' + c.middleName, '') + ISNULL(' ' + c.lastName1, '') + ISNULL(' ' + c.lastName2, '')    
   END    
   FROM remitTranTemp rt WITH(NOLOCK)     
   INNER JOIN tranSendersTemp b WITH(NOLOCK) ON rt.id=b.tranId    
   INNER JOIN tranReceiversTemp c WITH(NOLOCK) ON rt.id=c.tranId     
   WHERE rt.controlNo=dbo.FNAEncryptString(@controlNo)    
   --log information
   
   --EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModification'
			--							,@user = @user
			--							,@receiverId		= @receiverId
			--							,@customerId		= @customerId
			--							,@fieldValue		= @fieldValue
			--							,@tranId			= @tranId
			--							,@fieldName			= @fieldName
    
   IF @fieldName = 'rIdType'  
   BEGIN
		UPDATE tranReceiversTemp SET IdType = @fieldValue WHERE tranId = @tranId   
		UPDATE receiverInformation SET IdType = @fieldValue WHERE receiverid = @receiverId  
   END
   ELSE IF @fieldName = 'rAddress' 
   BEGIN
		 UPDATE tranReceiversTemp SET [address] = @fieldValue WHERE tranId = @tranId 
		 UPDATE receiverInformation SET [address] = @fieldValue WHERE receiverid = @receiverId      
	END
   ELSE IF @fieldName = 'rContactNo'  
   BEGIN  
    UPDATE tranReceiversTemp SET mobile = @fieldValue,homePhone = CASE WHEN homePhone IS NULL THEN @fieldValue ELSE homePhone END  WHERE tranId = @tranId    
	UPDATE receiverInformation SET mobile = @fieldValue,homePhone = CASE WHEN homePhone IS NULL THEN @fieldValue ELSE homePhone END  WHERE  receiverid = @receiverId      
	END
   ELSE IF @fieldName = 'rIdNo'  
   BEGIN  
    UPDATE tranReceiversTemp SET idNumber = @fieldValue WHERE tranId = @tranId    
	UPDATE receiverInformation SET idNumber = @fieldValue  WHERE receiverid = @receiverId  
	END
   ELSE IF @fieldName = 'receiverName'
	BEGIN	
		IF OBJECT_ID('tempdb..#nameTable') IS NOT NULL 
		
		DROP TABLE #nameTable
		DECLARE @XMLDATA XML = CONVERT(xml, replace(@fieldValue,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('@firstName','VARCHAR(100)') AS 'firstName'
					,p.value('@middleName','VARCHAR(100)') AS 'middleName'
					--,p.value('@BANKNAME', 'varchar(50)') AS 'BankName'
					,p.value('@firstLastName','varchar(100)') AS 'firstLastName'
					,p.value('@secondLastName','varchar(10)') AS 'secondLastName'
		INTO #nameTable
		FROM @XMLDATA.nodes('/root/row') AS apiStates(p)
		DECLARE @fname VARCHAR(100),@mname VARCHAR(100),@lname1 VARCHAR(100),@lanme2 VARCHAR(100)
	    SELECT @fname = firstName
			,@mname = middleName
			,@lname1 = firstLastName
			,@lanme2 = secondLastName
		 FROM #nameTable

		 UPDATE tranReceiversTemp SET firstName = @fname
								,middlename = @mname
								,lastname1 = @lname1
								,lastname2 = @lanme2
								,fullname = @newValue
								 WHERE tranId = @tranId  

		UPDATE dbo.receiverInformation SET firstName = @fname
										   ,middlename = @mname
										   ,lastname1 = @lname1
										   ,lastname2 = @lanme2
								 WHERE receiverId = @receiverId 
	END
   ELSE IF @fieldName = 'accountNo'   
	BEGIN
		UPDATE remitTranTemp SET accountNo = @fieldValue WHERE id = @tranId  
		UPDATE RECEIVERINFORMATION SET receiverAccountNo = @fieldValue WHERE receiverid = @receiverId
	END
   ELSE IF @fieldName = 'senderName'  
   	BEGIN	
		IF OBJECT_ID('tempdb..#nameTableSender') IS NOT NULL 
		
		DROP TABLE #nameTableSender
		DECLARE @XMLDATA1 XML = CONVERT(xml, replace(@fieldValue,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('@firstName','VARCHAR(20)') AS 'firstName'
					,p.value('@middleName','VARCHAR(100)') AS 'middleName'
					--,p.value('@BANKNAME', 'varchar(50)') AS 'BankName'
					,p.value('@firstLastName','varchar(10)') AS 'firstLastName'
					,p.value('@secondLastName','varchar(10)') AS 'secondLastName'
		INTO #nameTableSender
		FROM @XMLDATA1.nodes('/root/row') AS apiStates(p)

	    SELECT @fname = firstName
			,@mname = middleName
			,@lname1 = firstLastName
			,@lanme2 = secondLastName
		 FROM #nameTableSender

		 UPDATE tranSendersTemp SET firstName = @fname
								,middlename = @mname
								,lastname1 = @lname1
								,lastname2 = @lanme2
								,fullname = @newValue
								 WHERE tranId = @tranId  
	END
  
   INSERT INTO tranModifyLog(tranId,controlNo, MESSAGE, createdBy, createdDate,status ,fieldName , fieldValue,msgType,oldValue    
    ,resolvedBy,resolvedDate)    
   SELECT @tranId,dbo.FNAEncryptString(@controlNo),ISNULL(@changeType, 'NULL')+' [<b>'+isnull(@oldValue,'')+'</b>] has been requested to change by [<b>' + ISNULL(@newValue, 'NULL')+'</b>]', @user, GETDATE(),'approved',@fieldName,@fieldValue,'MODIFY',@oldValue,@user,getdate()    
      
   -->> ## SELECTING REQUESTED LIST           
   SELECT message,ScChargeMod,rowId FROM tranModifyLog     
   WHERE [status]='approved' AND controlNo = dbo.FNAEncryptString(@controlNo)    
    
  END    
  ELSE    
  BEGIN    
   SELECT @tranId = rt.id, @oldValue = CASE     
    WHEN @fieldName ='rIdType' THEN ISNULL(c.idType, c.idType2)     
    WHEN @fieldName ='rAddress' THEN c.address    
    WHEN @fieldName ='rContactNo' THEN c.mobile    
    WHEN @fieldName ='rIdNo' THEN c.idNumber    
    WHEN @fieldName ='accountNo' THEN rt.accountNo    
    WHEN @fieldName ='senderName' THEN b.firstName + ISNULL(' ' + b.middleName, '') + ISNULL(' ' + b.lastName1, '') + ISNULL(' ' + b.lastName2, '')    
    WHEN @fieldName ='receiverName' THEN c.firstName + ISNULL(' ' + c.middleName, '') + ISNULL(' ' + c.lastName1, '') + ISNULL(' ' + c.lastName2, '')    
   END    
   FROM remitTran rt WITH(NOLOCK)     
   INNER JOIN tranSenders b WITH(NOLOCK) ON rt.id=b.tranId    
   INNER JOIN tranReceivers c WITH(NOLOCK) ON rt.id=c.tranId     
   WHERE rt.controlNo=dbo.FNAEncryptString(@controlNo)     
      
   -->> ## INSERTING REQUESTED LIST           
   INSERT INTO tranModifyLog(tranId,controlNo, MESSAGE, createdBy, createdDate,status ,fieldName , fieldValue,msgType,oldValue)    
   SELECT @tranId,dbo.FNAEncryptString(@controlNo),ISNULL(@changeType, 'NULL')+' [<b>'+isnull(@oldValue,'')+'</b>] has been requested to change by [<b>' + ISNULL(@newValue, 'NULL')+'</b>]', @user, GETDATE(),'Request',@fieldName,@fieldValue,'MODIFY',@oldValue    
    -->> ## SELECTING REQUESTED LIST           
   SELECT message,ScChargeMod,rowId FROM tranModifyLog     
   WHERE [status]='Request' AND controlNo = dbo.FNAEncryptString(@controlNo)    
        
  END    
 END    
     
 IF @flag='showModifiedLog'    
 BEGIN      
    
   set @controlNo = dbo.FNAEncryptString(@controlNo)      
   SELECT     
    ROW_NUMBER() OVER(ORDER BY ROWID) [SN],    
    message [Message - New Modification],    
    oldValue [Old Data]    
   FROM tranModifyLog WITH(NOLOCK)    
   WHERE [status] ='Request'     
   AND controlNo = @controlNo     
 END    
     
 ELSE IF @flag = 'getApprovedModificationLog'    
 BEGIN    
  SET @controlNo = dbo.FNAEncryptString(@controlNo)    
  SELECT     
    ROW_NUMBER() OVER(ORDER BY ROWID) [SN],    
    message [Message - New Modification],    
    oldValue [Old Data]    
   FROM tranModifyLog WITH(NOLOCK)    
   WHERE [status]='Approved' AND MsgType = 'MODIFY'    
   AND controlNo = @controlNo     
 END    
     
 ELSE IF @flag='uSC' -- change SC charge    
 BEGIN    
  IF NOT EXISTS(SELECT 'X' FROM tranModifyLog WHERE [status]='Request'     
  AND controlNo = dbo.FNAEncryptString(@controlNo) AND createdBy = @user)    
  BEGIN    
   EXEC proc_errorHandler 1,'Please add the modification detail!',@controlNo    
   RETURN;    
  END    
      
  -->> UPDATE LOCAL DB STATUS AS  ModificationRequest    
  UPDATE remitTran    
   SET tranStatus ='ModificationRequest'    
  WHERE controlNo=@encryptedControlNo    
      
  EXEC proc_errorHandler 0,'Transaction Modification Requested successfully',@controlNo    
 END    
     
 ELSE IF @flag='refundSC' -- SC CHARGE REFUND for main table    
 BEGIN    
      
  UPDATE  TL SET TL.status='Approve'    
    ,TL.resolvedBy=@user    
    ,TL.resolvedDate=GETDATE()    
  FROM remitTran RT     
  INNER JOIN tranModifyLog TL ON RT.controlNo=TL.controlNo    
  WHERE TL.[status]='Request' AND TL.controlNo = dbo.FNAEncryptString(@controlNo)    
      
  EXEC proc_errorHandler 0,'Transaction Modification Approved successfully',@controlNo    
 END    
     
 ELSE IF @flag='Reqtxn' --== TXN modification Rquest part    
 BEGIN    
  SELECT * FROM tranModifyLog     
   WHERE [status]='Request' AND controlNo = dbo.FNAEncryptString(@controlNo)    
 END    
     
 ELSE IF @flag='d'    
 BEGIN    
  DELETE FROM tranModifyLog WHERE rowId= @rowId    
      
  SELECT message,ScChargeMod,rowId FROM tranModifyLog (NOLOCK)    
   WHERE [status]='Request' AND controlNo = dbo.FNAEncryptString(@controlNo)    
   AND createdBy=@user    
 END    
     
 ELSE IF @flag='a'    
 BEGIN          
  SELECT * FROM tranModifyLog     
   WHERE [status]='Request' AND controlNo = dbo.FNAEncryptString(@controlNo)    
   --AND createdBy=@user    
 END    
     
 ELSE IF @flag='reqUser' --- TXN MODIFICATION REQUESTED USER LIST FOR FILTER    
 BEGIN    
  SELECT null [value],'ALL' [text] UNION ALL    
  SELECT DISTINCT createdBy,createdBy FROM tranModifyLog    
  WHERE [status]='Request'    
 END    
     
 ELSE IF @flag='s'    
 BEGIN         
    
  SET @sortBy = 'createdDate'    
  SET @sortOrder = 'DESC'    
    
  SET @table = '(    
    SELECT     
     DISTINCT     
      RT.sCountry    
     ,RT.sAgentName    
     ,RT.sBranchName    
     ,TL.createdBy    
     ,controlNo = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'AgentPanel/Utilities/ModifyRequest/TxnDetail.aspx?searchBy=controlNo&searchValue='' + dbo.FNADecryptString(TL.controlNo)  + '''''')">'' + dbo.FNADecryptString(TL.controlNo) + 
  
''</a>''    
     ,RT.cAmt           
     ,CONVERT(VARCHAR(10),TL.createdDate,121) requestedDate  
     ,CONVERT(VARCHAR(10),TL.createdDate,121)  createdDate
     ,sBranch    
     ,filterControlNo = dbo.FNADecryptString(TL.controlNo)    
     ,pCountry    
     ,pAgentName    
     ,RT.payStatus    
    FROM tranModifyLog TL WITH (NOLOCK)    
    INNER JOIN remitTran RT WITH (NOLOCK) ON TL.controlNo=RT.controlNo    
    WHERE TL.status=''Request''    
   ) x'    
  SET @sql_filter = ''    
  IF @controlNo IS NOT NULL    
   SET @sql_filter = @sql_filter+ ' AND  filterControlNo ='''+@controlNo+''''    
       
  IF @branchId IS NOT NULL    
   SET @sql_filter = @sql_filter+ ' AND  sBranch ='''+CAST(@branchId AS VARCHAR)+''''    
       
  IF @createdBy IS  NOT NULL    
   SET @sql_filter= @sql_filter + ' AND createdBy='''+@createdBy+''''    
       PRINT(@table)
  SET @select_field_list ='    
   sCountry    
   ,sAgentName    
   ,sBranchName    
   ,createdBy    
   ,controlNo    
   ,cAmt    
   ,createdDate    
   ,filterControlNo    
   ,requestedDate    
   ,pCountry    
   ,pAgentName    
   ,payStatus    
   '    
            
  EXEC dbo.proc_paging    
      @table    
        ,@sql_filter    
        ,@select_field_list    
        ,''    
        ,@sortBy    
        ,@sortOrder    
        ,@pageSize    
  END     
      
 --## TXN modification Rquest END    
END TRY    
BEGIN CATCH    
    
     IF @@TRANCOUNT > 0    
     ROLLBACK TRANSACTION    
    
     DECLARE @errorMessage VARCHAR(MAX)    
     SET @errorMessage = ERROR_MESSAGE()    
     EXEC proc_errorHandler 1, @errorMessage, @rowId    
    
END CATCH    
    
    
    