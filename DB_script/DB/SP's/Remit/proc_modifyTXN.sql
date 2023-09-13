  
ALTER PROC [dbo].[proc_modifyTXN]  
		 @flag				   VARCHAR(50)		= NULL  
		,@user                 VARCHAR(30)		= NULL  
		,@tranId			   INT	    		= NULL  
		,@rowId				   INT				= NULL  
		,@fieldName			   VARCHAR(200)		= NULL  
		,@oldValue			   VARCHAR(200)		= NULL  
		,@newTxtValue		   VARCHAR(200)		= NULL  
		,@newDdlValue		   VARCHAR(200)		= NULL  
		,@firstName			   VARCHAR(200)		= NULL  
		,@middleName		   VARCHAR(200)		= NULL  
		,@lastName1			   VARCHAR(200)		= NULL  
		,@lastName2			   VARCHAR(200)		= NULL  
		,@contactNo			   VARCHAR(200)		= NULL  
		,@bankNewName		    VARCHAR(100)    = NULL  
		,@branchNewName        VARCHAR(100)		= NULL  
		,@isAPI				   CHAR(1)			= NULL  
		,@fieldValue		   VARCHAR(200)		= NULL  
		,@branchId			   VARCHAR(50)		= NULL  
		,@emailId			   VARCHAR(200)		= NULL  
		,@sessionId			   NVARCHAR(MAX)	= NULL
AS  
SET NOCOUNT ON  
SET XACT_ABORT ON  
BEGIN TRY  
   
 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)    
 DECLARE    
   @xml    XML  
  ,@pDistrict   VARCHAR(100)  
  ,@pDistrictId  INT  
  ,@pState   VARCHAR(100)  
  ,@pStateId   INT  
  ,@controlNo   VARCHAR(30)  
  ,@message   VARCHAR(500)  
  ,@agentRefId  VARCHAR(15)  
  ,@controlNoEncrypted VARCHAR(30)  
  ,@tranNo   BIGINT  
  ,@deliveryMethodId INT  
  ,@deliveryMethod VARCHAR(50)  
  ,@sBranch   INT  
  ,@pSuperAgent  INT  
  ,@sCountryId  INT  
  ,@sCountry   VARCHAR(100)  
  ,@pCountryId  INT  
  ,@pCountry   VARCHAR(100)  
  ,@pLocation   INT  
  ,@agentId   INT  
  ,@amount   MONEY  
  ,@oldSc    MONEY  
  ,@newSc    MONEY  
  ,@collCurr   VARCHAR(3)  
  ,@senderName  VARCHAR(200)  
  ,@receiverName  VARCHAR(200)  
  ,@senderOfacRes  VARCHAR(MAX)  
  ,@receiverOfacRes VARCHAR(MAX)  
  ,@ofacRes   VARCHAR(MAX)  
  ,@ofacReason  VARCHAR(200)  
  ,@nepDate   VARCHAR(50)  
     
 DECLARE   
  @parentId INT  
  ,@branchName VARCHAR(200)  
  ,@agentName VARCHAR(200)  
  ,@locationCode INT  
  ,@locationName VARCHAR(200)  
  ,@oldLocation VARCHAR(200)  
  ,@oldAgentId INT  
  ,@oldAgentName VARCHAR(200)  
  ,@supAgentId INT  
  ,@supAgentName VARCHAR(200)  
  ,@payStatus VARCHAR(50)  
  ,@MAXID INT  
  ,@MINID INT  
  ,@modifyId INT  
  ,@tranType CHAR(1)  
  ,@receiverId INT
  ,@customerId INT
  ,@pBankType CHAR(1)
       
 SET @agentRefId = '1' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '000000000', 8)  
 SET @nepDate = dbo.FNAGetDateInNepalTZ()  
 
 SELECT @tranId =  id from remittran where holdtranid = @tranId  

 SELECT   
   @controlNo = dbo.FNADecryptString(controlNo)  
  ,@pCountry = pCountry  
  ,@controlNoEncrypted = controlNo   
  ,@payStatus = payStatus  
  ,@receiverId = trt.customerid
  ,@customerId = tst.customerid
 FROM remitTran  rtt 
 INNER JOIN tranreceivers trt on trt.tranid = rtt.id
 INNER JOIN transenders tst on tst.tranid = rtt.id
 WHERE rtt.id = @tranId  
   
 -- ## Direct Modification  
 IF @flag='u'  
 BEGIN    
  DECLARE @memId VARCHAR(50)  
  --IF @payStatus = 'Post'  
  --BEGIN  
  -- SET @message = 'Transaction not authorised for modification; Status:'+@payStatus;  
  -- EXEC proc_errorHandler 1, @message, @tranId  
  -- RETURN;  
  --END  
  
  SELECT @memId = membershipId FROM tranSenders (NOLOCK) WHERE tranId = @tranId  
  IF @fieldName='senderName'   
  BEGIN  
   IF @firstName IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid first name!', @tranId  
    RETURN  
   END   
  
   IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId = @memId)  
   BEGIN  
    EXEC proc_errorHandler 1, 'You can not modify this transaction made by membered customer.', @tranId  
    RETURN  
   END  
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @senderName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' +@lastName2, '')  
     
     
   SELECT @tranType = tranType FROM remitTran (NOLOCK) WHERE id = @tranId  
  
   BEGIN TRANSACTION  
   UPDATE tranSenders SET  
     firstName  = @firstName  
    ,middleName  = @middleName  
    ,lastName1  = @lastName1  
    ,lastName2  = @lastName2  
    ,fullName  = @senderName  
   WHERE tranId = @tranId  
  
   UPDATE remitTran SET senderName = @senderName WHERE id = @tranId  
   UPDATE customerTxnHistory SET senderName = @senderName WHERE refNo = dbo.encryptdb(@controlNo)  
  
   SET @message = 'Sender Name:'+ ISNULL(@oldValue, '') + ' has been changed to ' + @senderName  
   INSERT INTO  tranModifyLog (tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user,@nepDate,'MODIFY'  
  
   --## update accounting db  
   UPDATE FastMoneyPro_account.dbo.remit_trn_master SET SENDER_NAME = @senderName WHERE trn_ref_no = dbo.encryptdb(@controlNo)  
        
  
   COMMIT TRANSACTION  
   EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @senderOfacRes OUTPUT  
  END  
    
  ELSE IF @fieldName = 'sIdType'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    RETURN  
   END    
   IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId = @memId)  
   BEGIN  
    EXEC proc_errorHandler 1, 'You can not modify this transaction made by membered customer.', @tranId  
    RETURN  
   END  
      
   BEGIN TRAN  
   UPDATE tranSenders SET  
     idType = @newDdlValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Id Type:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@newDdlValue, '')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName = 'sIdNo'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId = @memId)  
   BEGIN  
    EXEC proc_errorHandler 1, 'You can not modify this transaction made by membered customer.', @tranId  
    RETURN  
   END  
     
   BEGIN TRAN  
   UPDATE tranSenders SET  
     idNumber = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender ID No:' + isnull(@oldValue, '') + ' has been changed to ' + ISNULL(@newTxtValue, '')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
   COMMIT TRAN  
  
  END  
    
  ELSE IF @fieldName = 'sAddress'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId = @memId)  
   BEGIN  
    EXEC proc_errorHandler 1, 'You can not modify this transaction made by membered customer.', @tranId  
    RETURN  
   END  
   BEGIN TRAN  
   UPDATE tranSenders SET  
     address = @newTxtValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Address:' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(@newTxtValue, '')   
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName = 'sContactNo'  
  BEGIN  
   IF @contactNo IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId  
    RETURN  
   END  
   IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId = @memId)  
   BEGIN  
    EXEC proc_errorHandler 1, 'You can not modify this transaction made by membered customer.', @tranId  
    RETURN  
   END  
   BEGIN TRAN  
   UPDATE tranSenders SET  
     mobile = @contactNo  
   WHERE tranId = @tranId   
  
   SET @message = 'Sender Contact No:' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(@contactNo,'')  
   INSERT INTO tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName = 'receiverName'  
  BEGIN  
   IF @firstName IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid first name!' , @tranId  
    RETURN  
   END  
     
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @receiverName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
   SELECT @tranType = tranType FROM remitTran (NOLOCK) WHERE id = @tranId  

     EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
										,@user = @user
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@tranId			= @tranId
										,@firstName			= @firstName
										,@middleName		= @middleName
										,@lastName1			= @lastName1
										,@lastName2			= @lastName2
										,@nameChanged		= 1
										,@isNotXmlData		= 1
										,@sessionId			= @sessionId
  
   BEGIN TRAN  
   --alerdy done in PROC_RECEIVERMODIFYLOGS
   --UPDATE tranReceivers SET  firstName	 = @firstName  
			--				,middleName  = @middleName  
			--				,lastName1	 = @lastName1  
			--				,lastName2	 = @lastName2  
			--				,fullName	 = @receiverName  
   --WHERE tranId = @tranId  
     
   UPDATE remitTran SET receiverName = @receiverName WHERE id = @tranId  
   UPDATE customerTxnHistory SET receiverName = @receiverName WHERE tranNo = @tranId  
  
   SET @message = 'Receiver Name:' + ISNULL(@oldValue, '') + ' has been changed to ' + @receiverName  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
  
   UPDATE FastMoneyPro_account.dbo.remit_trn_master SET Receiver_Name = @receiverName WHERE trn_ref_no = dbo.encryptdb(@controlNo)  
         
   --## update accounting db  
  
   COMMIT TRAN  
  
   EXEC proc_ofacTracker @flag = 't', @name = @receiverName, @Result = @receiverOfacRes OUTPUT  
    
  END  
  
  ELSE IF @fieldName = 'rAddress'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    RETURN  
   END   
   EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
										,@user = @user
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@address			= @newTxtValue
										,@tranId			= @tranId
										,@sessionId			= @sessionId
   BEGIN TRAN  
		UPDATE tranReceivers SET  address = @newTxtValue  WHERE tranId = @tranId  
		UPDATE receiverInformation SET address = @newTxtValue WHERE receiverId = @receiverId  
     
   SET @message = 'Receiver Address:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user, @nepDate, 'MODIFY'  
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName = 'rIdType'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    RETURN  
   END   
     EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
										,@user = @user
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@idType			= @newDdlValue
										,@tranId			= @tranId
										,@sessionId			= @sessionId
   BEGIN TRAN  
   UPDATE tranReceivers SET  idType = @newDdlValue  WHERE tranId = @tranId 
   UPDATE receiverInformation SET idType = @newDdlValue WHERE receiverId = @receiverId  
     
   SET @message = 'Receiver Id Type:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@newDdlValue, '')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName = 'rTelNo'  
  BEGIN  
   IF @contactNo IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid telephone number!', @tranId  
    RETURN  
   END   
     
   BEGIN TRAN  
   UPDATE tranSenders SET  
     homephone = @contactNo  
   WHERE tranId = @tranId   
  
   SET @message = 'Sender telephone number:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
   COMMIT TRAN  
  END  
      
  ELSE IF @fieldName = 'rContactNo'   
  BEGIN  
   IF @contactNo is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId  
    RETURN  
   END  
     EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
										,@user = @user
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@mobile			= @contactNo
										,@tranId			= @tranId
										,@sessionId			= @sessionId
   BEGIN TRAN  
      UPDATE tranReceivers SET  mobile = @contactNo  WHERE tranId = @tranId   
	  UPDATE receiverInformation SET mobile = @contactNo WHERE receiverId = @receiverId 
     
   SET @message = 'Receiver Contact No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName = 'relationship'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid Receiver relationship with sender!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE remitTran SET  
     relWithSender = @newDdlValue  
   WHERE id = @tranId  
        
   SET @message = 'Receiver relationship with sender :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newDdlValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName = 'rIdNo'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END   
     EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
										,@user = @user
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@idNumber			= @newTxtValue
										,@tranId			= @tranId
										,@sessionId			= @sessionId

   BEGIN TRAN  
   UPDATE tranReceivers SET  idNumber = @newTxtValue  WHERE tranId = @tranId   
   UPDATE receiverInformation SET idNumber = @newTxtValue WHERE receiverId = @receiverId 
     
   SET @message = 'Receiver ID No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END   
     
  ----###SMS for Trouble Ticket----  
    
   DECLARE   
     @msg VARCHAR(MAX)  
    ,@mobileNo VARCHAR(100)  
    ,@country VARCHAr(100)  
       
    IF @message IS NOT NULL AND @mobileNo IS NOT NULL  
    BEGIN  
     SET @msg= 'Dear Customer, '+@message+' '+'Please confirm the detail and visit sending agent,if modification required.'  
     --mobile no check   
     SELECT @mobileNo=ts.mobile,@country=ts.country    
     FROM RemitTran rt   
     INNER JOIN tranSenders ts on rt.controlNo=dbo.FNAEncryptString(@controlNo)   
     WHERE ts.mobile IS NOT NULL  
       
     EXEC sp_InsertIntoSMSQueue 'sms' ,@user ,@msg,@country,NULL,@agentId ,@branchId ,@mobileNo ,@controlNo ,@tranId  
    END   
    
  ELSE IF @fieldName = 'txnTestQuestion'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END  
  
   BEGIN TRAN  
   UPDATE tranSenders SET  
     txnTestQuestion = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Question:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName = 'txnTestAnswer'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END  
   BEGIN TRAN  
   UPDATE tranSenders SET  
     txnTestAnswer = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Answer:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName = 'accountNo'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid account number!', @tranId  
    RETURN  
   END   
   SELECT @tranType = tranType FROM remitTran (NOLOCK) WHERE id = @tranId  
   EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
										,@user = @user
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@receiverAccountNo = @newDdlValue
										,@tranId			= @tranId
										,@sessionId			= @sessionId
  
   BEGIN TRAN  
      UPDATE remitTran SET  accountNo = @newDdlValue  WHERE id = @tranId   
	  UPDATE receiverInformation SET receiverAccountNo = @newDdlValue WHERE receiverId = @receiverId 
     
   SET @message = 'Account Number:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newDdlValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
        
   IF @tranType = 'I'  
    UPDATE FastMoneyPro_account.dbo.remit_trn_master SET customerId = @newDdlValue WHERE trn_ref_no = dbo.encryptdb(@controlNo)  
  
   COMMIT TRAN  
  END  
    
  --ELSE IF @fieldName = 'BankName'  
  --BEGIN  
  -- IF @bankNewName is null  
  -- BEGIN  
  --  EXEC proc_errorHandler 1, 'Please enter valid bank name!', @tranId  
  --  RETURN  
  -- END   
  -- IF @branchNewName is null  
  -- BEGIN  
  --  EXEC proc_errorHandler 1, 'Please enter valid bank name!', @tranId  
  --  RETURN  
  -- END   
  -- --EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
		--	--							,@user = @user
		--	--							,@receiverId		= @receiverId
		--	--							,@customerId		= @customerId
		--	--							,@payOutPartner		= @newDdlValue
		--	--							,@tranId			= @tranId
		--	--							,@sessionId			= @sessionId
  -- BEGIN TRAN  
  --    UPDATE remitTran SET  pBank = @bankNewName,       
		--					pBankName=dbo.GetAgentNameFromId(@bankNewName)
		--				   ,pBankBranch = @branchNewName
		--				   ,pBankBranchName=dbo.GetAgentNameFromId(@branchNewName)  
		--	WHERE id = @tranId

	 --UPDATE RECEIVERINFORMATION SET  payoutpartner = dbo.GetAgentNameFromId(@bankNewName)
		--						,banklocation = dbo.GetAgentNameFromId(@branchNewName)  
		--	WHERE receiverId = @receiverId 
     
  -- SET @message = 'Bank Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@bankNewName),'')  
  -- INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
  -- SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
     
  -- DECLARE @message2 VARCHAR(200) = NULL  
  -- SET @message2 = 'Branch name has been changed to '+isnull(dbo.GetAgentNameFromId(@branchNewName),'')  
  -- INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
  -- SELECT @tranId,@message2,@user,@nepDate,'MODIFY'  
  -- COMMIT TRAN  
  --END  
    
  --ELSE IF @fieldName = 'BranchName'  
  --BEGIN  
  -- EXEC proc_errorHandler 1, 'Feature not available at the moment', @tranId  
  -- RETURN  
  -- IF @newDdlValue is null  
  -- BEGIN  
  --  EXEC proc_errorHandler 1, 'Please enter valid branch name!', @tranId  
  --  RETURN  
  -- END  
  --  EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
		--								,@user = @user
		--								,@receiverId		= @receiverId
		--								,@customerId		= @customerId
		--								,@bankLocation		= @newDdlValue
		--								,@tranId			= @tranId
		--								,@sessionId			= @sessionId

  -- BEGIN TRAN  
  --    UPDATE remitTran SET  pBankBranch = @newDdlValue
		--				   ,pBankBranchName=dbo.GetAgentNameFromId(@newDdlValue)  
		--	 WHERE id = @tranId   
	 -- UPDATE RECEIVERINFORMATION SET bankLocation = dbo.GetAgentNameFromId(@newDdlValue) 
		--	 WHERE receiverId = @receiverId
     
  -- SET @message = 'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@newDdlValue),'')  
  -- INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
  -- SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
  -- COMMIT TRAN  
  
  -- SELECT @pBankType = pBankType FROM remitTran WITH(NOLOCK) WHERE id = @tranId  
  
  --END  
    
    
  ELSE IF @fieldName = 'pBranchName'  
  BEGIN  
   IF @newDdlValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid branch name!', @tranId  
    RETURN  
   END   
     
   SELECT @locationCode=agentLocation FROM agentMaster (NOLOCK) WHERE agentId=@newDdlValue  
   SELECT @locationName=districtName FROM api_districtList (NOLOCK) WHERE districtCode=@locationCode  
     
   SELECT @oldAgentId= CASE WHEN ISNULL(pAgent,0)=ISNULL(pBranch,0) THEN pSuperAgent ELSE pAgent END  
   FROM remitTran (NOLOCK) WHERE id=@tranId  
     
   SELECT @oldAgentName=agentName FROM agentMaster (NOLOCK) WHERE agentId=@oldAgentId     
       
   IF EXISTS(SELECT actAsBranch from agentMaster (NOLOCK) WHERE agentId=@newDdlValue AND actAsBranch='y')  
   BEGIN  
      
    -- ## branch name  
    SELECT @branchName=agentName  
    FROM agentMaster (NOLOCK)  
    WHERE agentId=@newDdlValue  
      
    -- ## super agent  
    SELECT @supAgentId=parentId  
    FROM agentMaster (NOLOCK) WHERE agentId=@newDdlValue  
      
    SELECT @supAgentName=agentName  
    FROM agentMaster (NOLOCK) WHERE agentId=@supAgentId  
      
    BEGIN TRAN  
    -- ## update if agent act as a branch   
    UPDATE remitTran SET  
      pAgent = @newDdlValue,  
      pBranch=@newDdlValue,  
      pAgentName=@branchName,  
      pBranchName=@branchName,  
      pSuperAgent=@supAgentId,  
      pSuperAgentName=@supAgentName  
    WHERE id = @tranId   
      
    -- ## update transaction log      
    INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    SELECT @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,@nepDate,'MODIFY'  
      
    INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    SELECT @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@supAgentName,''),@user,@nepDate,'MODIFY'  
    COMMIT TRAN  
   END  
   ELSE  
   BEGIN      
    -- ## branch name & agent name  
    SELECT @parentId=parentId, @branchName=agentName   
    FROM agentMaster (NOLOCK)  
    WHERE agentId=@newDdlValue   
      
    SELECT @agentName=agentName   
    FROM agentMaster (NOLOCK)  
    WHERE agentId=@parentId   
      
    -- ## super agent  
    SELECT @supAgentId=parentId  
    FROM agentMaster (NOLOCK) WHERE agentId=@parentId  
      
    SELECT @supAgentName=agentName  
    FROM agentMaster (NOLOCK) WHERE agentId=@supAgentId  
      
    BEGIN TRAN  
    -- ## update remitTran  
    UPDATE remitTran SET  
      pAgent = @parentId,  
      pBranch=@newDdlValue,  
      pAgentName=@agentName,  
      pBranchName=@branchName,  
      pSuperAgent=@supAgentId,  
      pSuperAgentName=@supAgentName  
    WHERE id = @tranId   
      
    -- ## update transaction log          
    INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    SELECT @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,@nepDate,'MODIFY'  
      
    INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    SELECT @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@agentName,''),@user,@nepDate,'MODIFY'  
    COMMIT TRAN  
   END       
  END  
  
  ELSE IF @fieldName = 'rCity'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid receiver city!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
      UPDATE tranreceivers SET  
     city = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver City :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName = 'sCity'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid Sender City!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
      UPDATE transenders SET  
     city = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender City :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName = 'pAgentLocation'  
  BEGIN  
   IF @newDdlValue IS NULL   
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid agent payout location!', @tranId  
    RETURN  
   END  
     
   SELECT  
     @deliveryMethod = paymentMethod  
    ,@sBranch   = sBranch  
    ,@pSuperAgent  = pSuperAgent  
    ,@sCountry   = sCountry  
    ,@pCountry   = pCountry  
    ,@agentId   = pBranch  
    ,@amount   = tAmt  
    ,@oldSc    = serviceCharge   
    ,@collCurr   = collCurr  
    ,@controlNo   = dbo.FNADecryptString(controlNo)  
    ,@pLocation   = pLocation  
   FROM remitTran WITH(NOLOCK)  
   WHERE id = @tranId  
  /*  
   IF (@pLocation = 137 AND @newDdlValue <> 137)  
   BEGIN  
    EXEC proc_errorHandler 1, 'Service Charge or Commission for this location varies. Cannot modify Location.', @tranId  
    RETURN  
   END  
   IF (@newDdlValue = 137 AND @pLocation <> 137)  
   BEGIN  
    EXEC proc_errorHandler 1, 'Service Charge or Commission for this location varies. Cannot modify Location.', @tranId  
    RETURN  
   END  
  */  
   SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'  
   SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry  
   SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry  
   IF(@sCountry = 'Nepal')  
    SELECT @newSc = ISNULL(serviceCharge, 0) FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @newDdlValue, @deliveryMethodId, @amount)  
   ELSE  
    SELECT @newSc = ISNULL(amount, -1) FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountryId, @newDdlValue, @agentId , @deliveryMethodId, @amount, @collCurr)  
     
   SELECT @pDistrictId = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @newDdlValue  
   SELECT @pDistrict = districtName, @pStateId = zone FROM zoneDistrictMap WITH(NOLOCK) WHERE districtId = @pDistrictId  
   SELECT @pState = stateName FROM countryStateMaster WITH(NOLOCK) WHERE stateId = @pStateId  
     
   BEGIN TRAN  
   UPDATE remitTran SET  
      pLocation = @newDdlValue  
     ,pDistrict = @pDistrict  
     ,pState = @pState  
   WHERE id = @tranId  
     
   SELECT @message = 'Agent Payout Location :' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(districtName, '') FROM api_districtList WHERE districtCode = @newDdlValue  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'  
   COMMIT TRAN  
  END  
    
  select '0' errorCode,'Record has been updated successfully.' msg,@tranId id,@controlNo Extra
  --EXEC proc_errorHandler 0, 'Record has been updated successfully.', @tranId  
 END   
   
 --## Direct HOLD TXN modification   
 IF @flag='uHoldtxn'    
 BEGIN      
  IF @fieldName='senderName'   
  BEGIN  
   SET @xml =  @fieldValue  
   SELECT  
    @firstName  = p.value('@firstName','VARCHAR(50)')    
    ,@middleName = p.value('@middleName','VARCHAR(50)')   
    ,@lastName1  = p.value('@firstLastName','VARCHAR(50)')   
    ,@lastName2  = p.value('@secondLastName','VARCHAR(50)')   
   FROM @xml.nodes('/root/row') AS tmp(p)    
     
   IF @firstName IS NULL   
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid first name!', @tranId  
    RETURN  
   END   
  
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @senderName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
   BEGIN TRAN  
   UPDATE tranSendersTemp SET  
     firstName = @senderName  
    ,middleName = null  
    ,lastName1 = null  
    ,lastName2 = null  
   WHERE tranId = @tranId  
     
   UPDATE remitTranTemp SET  
     senderName = UPPER(@senderName)  
   WHERE id = @tranId  
  
   SET @message = 'Sender Name:'+ ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' +@lastName2, '')  
   INSERT INTO  tranModifyLog (tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='receiverName'  
  BEGIN  
   SET @xml  = @fieldValue  
   SELECT  
    @firstName  = p.value('@firstName','VARCHAR(50)')    
    ,@middleName = p.value('@middleName','VARCHAR(50)')   
    ,@lastName1  = p.value('@firstLastName','VARCHAR(50)')   
    ,@lastName2  = p.value ('@secondLastName','VARCHAR(50)')   
   FROM @xml.nodes('/root/row') AS tmp(p)  
  
   IF @firstName is null   
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid first name!' , @tranId  
    RETURN  
   END  
  
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @receiverName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
  
   BEGIN TRAN  
   UPDATE tranReceiversTemp SET  
     firstName = @receiverName  
    ,middleName = null  
    ,lastName1 = null  
    ,lastName2 = null  
   WHERE tranId = @tranId  
     
   UPDATE remitTranTemp SET  
     receiverName = upper(@receiverName)  
   WHERE id = @tranId  
  
   SET @message = 'Receiver Name:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
   INSERT INTO  tranModifyLog   (tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='sIdType'  
  BEGIN  
   IF @newDdlValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    RETURN  
   END     
     
   BEGIN TRAN  
   UPDATE tranSendersTemp SET  
     idType = @newDdlValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Id Type:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@newDdlValue, '')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='rIdType'  
  BEGIN  
   IF @newDdlValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE tranReceiversTemp SET  
     idType = @newDdlValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Receiver Id Type:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newDdlValue,'')  
   INSERT INTO  tranModifyLog   (tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName='relationship'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid Receiver relationship with sender!', @tranId  
    RETURN  
   END   
    
   BEGIN TRAN  
   UPDATE remitTranTemp SET  
     relWithSender = @newDdlValue  
   WHERE id = @tranId  
        
   SET @message = 'Receiver relationship with sender :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newDdlValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
  
  ELSE IF @fieldName='rAddress'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE tranReceiversTemp SET  
     address = @newTxtValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Receiver Address:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user, @nepDate, 'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='sAddress'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    RETURN  
   END   
   UPDATE tranSendersTemp SET  
     address = @newTxtValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Address:' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(@newTxtValue, '')   
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
  END  
    
  ELSE IF @fieldName='sContactNo'  
  BEGIN  
   IF @contactNo IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId  
    RETURN  
   END   
   UPDATE tranSendersTemp SET  
     mobile = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender Contact No:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@contactNo,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
  END  
    
  ELSE IF @fieldName='rTelNo'  
  BEGIN  
   IF @contactNo IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid telephone number!', @tranId  
    RETURN  
   END  
   BEGIN TRAN  
   UPDATE tranReceiversTemp SET  
     homephone = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver telephone number:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='sTelNo'  
  BEGIN  
   IF @contactNo is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid telephone number!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE tranSendersTemp SET  
     homephone = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender telephone number:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='rContactNo'  
  BEGIN  
   IF @contactNo is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE tranReceiversTemp SET  
     mobile = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver Contact No:'+ ISNULL(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='sIdNo'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE tranSendersTemp SET  
     idNumber = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender ID No:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'   
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='rIdNo'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END  
   BEGIN TRAN   
   UPDATE tranReceiversTemp SET  
     idNumber = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver ID No:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END    
    
  ELSE IF @fieldName='txnTestQuestion'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE tranSendersTemp SET  
     txnTestQuestion = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Question:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='txnTestAnswer'  
  BEGIN  
   IF @newTxtValue is null  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    RETURN  
   END   
   BEGIN TRAN  
   UPDATE tranSendersTemp SET  
     txnTestAnswer = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Answer:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='accountNo'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid account number!', @tranId  
    RETURN  
   END  
   BEGIN TRAN  
      UPDATE remitTranTemp SET  
     accountNo = @newTxtValue  
   WHERE id = @tranId   
     
   SET @message = 'Account Number:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,@nepDate,'MODIFY'  
   COMMIT TRAN  
  END  
    
  ELSE IF @fieldName='BankName'  
  BEGIN  
   if @bankNewName is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid bank name!', @tranId  
    return  
   end   
   if @branchNewName is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid bank name!', @tranId  
    return  
   end   
     
      update remitTranTemp SET  
     pBank = @bankNewName,       
     pBankName=dbo.GetAgentNameFromId(@bankNewName),  
     pBankBranch = @branchNewName,  
     pBankBranchName=dbo.GetAgentNameFromId(@branchNewName)  
   WHERE id = @tranId   
     
   SET @message = 'Bank Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@bankNewName),'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,@nepDate,'MODIFY'  
     
   ----DECLARE @message3 VARCHAR(200) = NULL  
   SET @message = 'Branch name has been changed to '+isnull(dbo.GetAgentNameFromId(@branchNewName),'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,@nepDate,'MODIFY'  
  
  END  
    
  ELSE IF @fieldName='BranchName'  
  BEGIN  
   if @newDdlValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid branch name!', @tranId  
    return  
   end   
      update remitTranTemp SET  
     pBankBranch = @newDdlValue,  
     pBankBranchName=dbo.GetAgentNameFromId(@newDdlValue)  
   WHERE id = @tranId   
     
   SET @message = 'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@newDdlValue),'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,@nepDate,'MODIFY'  
  END  
    
  ELSE IF @fieldName='pBranchName'  
  BEGIN  
   if @newDdlValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid branch name!', @tranId  
    return  
   end   
  
   select @locationCode=agentLocation from agentMaster where agentId=@newDdlValue  
   select @locationName=districtName from api_districtList where districtCode=@locationCode  
     
   select @oldAgentId= case when isnull(pAgent,0)=isnull(pBranch,0) then pSuperAgent else pAgent end  
   from remitTranTemp where id=@tranId  
     
   select @oldAgentName=agentName from agentMaster where agentId=@oldAgentId     
       
   if exists(select actAsBranch from agentMaster where agentId=@newDdlValue and actAsBranch='y')  
   begin  
      
    -- ## branch name  
    select @branchName=agentName  
    from agentMaster   
    where agentId=@newDdlValue  
      
    -- ## super agent  
    select @supAgentId=parentId  
    from agentMaster where agentId=@newDdlValue  
      
    select @supAgentName=agentName  
    from agentMaster where agentId=@supAgentId  
      
    -- ## update if agent act as a branch   
    update remitTranTemp SET  
      pAgent = @newDdlValue,  
      pBranch=@newDdlValue,  
      pAgentName=@branchName,  
      pBranchName=@branchName,  
      pSuperAgent=@supAgentId,  
      pSuperAgentName=@supAgentName  
    WHERE id = @tranId   
      
    -- ## update transaction log      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,@nepDate,'MODIFY'  
      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@supAgentName,''),@user,@nepDate,'MODIFY'  
      
   end  
   else  
   begin  
      
    -- ## branch name & agent name  
    select @parentId=parentId,@branchName=agentName   
    from agentMaster   
    where agentId=@newDdlValue   
      
    select @agentName=agentName   
    from agentMaster   
    where agentId=@parentId   
      
    -- ## super agent  
    select @supAgentId=parentId  
    from agentMaster where agentId=@parentId  
      
    select @supAgentName=agentName  
    from agentMaster where agentId=@supAgentId  
      
    -- ## update remitTran  
    update remitTranTemp SET  
      pAgent = @parentId,  
      pBranch=@newDdlValue,  
      pAgentName=@agentName,  
      pBranchName=@branchName,  
      pSuperAgent=@supAgentId,  
      pSuperAgentName=@supAgentName  
    WHERE id = @tranId   
      
    -- ## update transaction log          
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,@nepDate,'MODIFY'  
      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@agentName,''),@user,@nepDate,'MODIFY'  
   end    
     
  END    
  EXEC proc_errorHandler 0, 'Record has been updated successfully.', @tranId  
 END    
   
 IF @flag='sa'  
 BEGIN  
  SELECT pBank FROM remitTran with(nolock) WHERE id=@tranId   
 END   
   
 --## Approve Modification   
 IF @flag = 'approveAll'  
 BEGIN  
  SELECT   
   @controlNoEncrypted = controlNo,   
   @pCountry = pCountry,  
   @controlNo = dbo.fnadecryptstring(controlNo)     
  FROM remitTran WITH(NOLOCK) WHERE id = @tranId  
   
  IF OBJECT_ID('tempdb..#TEMPTABLE') IS NOT NULL  
  DROP TABLE #TEMPTABLE   
  
  CREATE TABLE #TEMPTABLE  
  (  
   tranId  INT    NULL,  
   modifyId INT    NULL,  
   fieldName   VARCHAR(100) NULL,  
   fieldValue VARCHAR(MAX) NULL,  
   oldValue VARCHAR(500) NULL,  
   MSG   VARCHAR(MAX) NULL  
  )  
  INSERT INTO #TEMPTABLE(tranId,modifyId,fieldName,fieldValue,oldValue,MSG)  
  SELECT @tranId,rowId,fieldName,fieldValue,oldValue,message  
  FROM tranModifyLog with(nolock) WHERE tranId = @tranId AND STATUS = 'Request'    
    
  ALTER TABLE #TEMPTABLE ADD rowId INT IDENTITY(1,1)  
  SELECT @tranType = tranType FROM remitTran (NOLOCK) WHERE id = @tranId  
  
  SELECT @MAXID =MAX(rowId) FROM #TEMPTABLE  
    
  SET @MINID = 1  
  WHILE @MAXID >= @MINID  
  BEGIN  
    SELECT @modifyId  = modifyId,  
      @fieldName  = fieldName,  
      @fieldValue  = fieldValue,  
      @oldValue  = oldValue  
    FROM #TEMPTABLE WITH(NOLOCK)  
    WHERE rowId = @MINID   
   
    BEGIN TRAN  
    IF @fieldName='senderName'   
    BEGIN  
     SET @xml =  @fieldValue  
     SELECT  
       @firstName  = p.value('@firstName','VARCHAR(50)')    
      ,@middleName = p.value('@middleName','VARCHAR(50)')   
      ,@lastName1  = p.value('@firstLastName','VARCHAR(50)')   
      ,@lastName2  = p.value('@secondLastName','VARCHAR(50)')   
     FROM @xml.nodes('/root/row') AS tmp(p)         
       
     SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
     SET @senderName = @firstName + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
       
       
     UPDATE tranSenders SET  
       firstName  = @firstName  
      ,middleName  = @middleName  
      ,lastName1  = @lastName1  
      ,lastName2  = @lastName2  
      ,fullName  = @senderName  
     WHERE tranId = @tranId  
       
     UPDATE remitTran SET senderName = @senderName WHERE id = @tranId  
     UPDATE customerTxnHistory SET senderName = @senderName WHERE refNo = dbo.encryptdb(@controlNo)  
       
     --## update accounting db  
      UPDATE FastMoneyPro_account.dbo.remit_trn_master SET Sender_Name = @senderName WHERE trn_ref_no = dbo.encryptdb(@controlNo)  
  
     SET @message = 'Sender Name [<b>'+@oldValue+'</b>] has been replaced to [<b>' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' +@lastName2, '')+'</b>]'  
       
     EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @senderOfacRes OUTPUT  
    END  
    
    ELSE IF @fieldName='receiverName'   
    BEGIN  
     SET @xml  = @fieldValue  
     SELECT  
       @firstName  = p.value('@firstName','VARCHAR(50)')    
      ,@middleName = p.value('@middleName','VARCHAR(50)')   
      ,@lastName1  = p.value('@firstLastName','VARCHAR(50)')   
      ,@lastName2  = p.value ('@secondLastName','VARCHAR(50)')   
     FROM @xml.nodes('/root/row') AS tmp(p)  
       
     SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
     SET @receiverName = @firstName + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
       
     UPDATE tranReceivers SET  
       firstName = @firstName  
      ,middleName = @middleName  
      ,lastName1 = @lastName1  
      ,lastName2 = @lastName2  
      ,fullName = @receiverName  
     WHERE tranId = @tranId  
       
     UPDATE remitTran SET receiverName = @receiverName WHERE id = @tranId  
     UPDATE customerTxnHistory SET receiverName = @receiverName WHERE refNo = dbo.encryptdb(@controlNo)  
     --## update accounting db  
      UPDATE FastMoneyPro_account.dbo.remit_trn_master SET Receiver_Name = @receiverName WHERE trn_ref_no = dbo.encryptdb(@controlNo)   
            
       
     SET @message = 'Receiver Name [<b>'+@oldValue+'</b>] has been replaced to [<b>' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')+'</b>]'  
       
     EXEC proc_ofacTracker @flag = 't', @name = @receiverName, @Result = @receiverOfacRes OUTPUT  
    END    
   
    ELSE IF @fieldName='rIdType'  
    BEGIN  
     UPDATE tranReceivers SET idType = @fieldValue WHERE tranId = @tranId            
     SET @message = 'Receiver Id Type [<b>'+ISNULL(@oldValue, '') +'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END  
    
    ELSE IF @fieldName='rAddress'  
    BEGIN       
     UPDATE tranReceivers SET address = @fieldValue WHERE tranId = @tranId  
     SET @message = 'Receiver Address [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END  
    
    ELSE IF @fieldName='rContactNo'  
    BEGIN        
     UPDATE tranReceivers SET mobile = @fieldValue WHERE tranId = @tranId             
     SET @message = 'Receiver Contact No [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'       
    END  
      
    ELSE IF @fieldName='rIdNo'  
    BEGIN       
     UPDATE tranReceivers SET idNumber = @fieldValue WHERE tranId = @tranId            
     SET @message = 'Receiver ID No [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END  
      
    ELSE IF @fieldName='accountNo'  
    BEGIN       
     UPDATE remitTran SET accountNo = @fieldValue WHERE id = @tranId  
     IF @tranType = 'I'  
     UPDATE FastMoneyPro_account.dbo.remit_trn_master SET customerId = @fieldValue WHERE trn_ref_no = dbo.encryptdb(@controlNo)  
     SET @message = 'Receiver Bank Ac No [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END   
      
    UPDATE tranModifyLog SET   
      MESSAGE  = @message  
     ,MsgType  = 'MODIFY'  
     ,resolvedBy  = @user  
     ,resolvedDate = @nepDate  
     ,status   = 'approved'  
    WHERE rowId = @modifyId  
  
    COMMIT TRAN  
    SET @MINID = @MINID + 1  
  END  
    
  SELECT @branchId= sBranch,@user = createdBy FROM remitTran WITH(NOLOCK) WHERE id = @tranId  
  SELECT @emailId= dbo.FNAGetBranchEmail(@branchId,@user)   
    
  UPDATE remitTran SET tranStatus = 'Payment' WHERE id = @tranId  
    
  IF ISNULL(@senderOfacRes, '') <> ''  
  BEGIN  
   SET @ofacReason = 'Matched by sender name during transaction ammendment'  
   SET @ofacRes = @senderOfacRes  
  END  
  IF ISNULL(@receiverOfacRes, '') <> ''  
  BEGIN  
   SET @ofacReason = 'Matched by receiver name during transaction ammendment'  
   SET @ofacRes = @receiverOfacRes  
  END  
    
  IF ISNULL(@senderOfacRes, '') <> '' AND ISNULL(@receiverOfacRes, '') <> ''  
  BEGIN  
   SET @ofacReason = 'Matched by both sender name and receiver name during transaction ammendment'  
   SET @ofacRes = @senderOfacRes + ',' + @receiverOfacRes  
  END  
    
  IF ISNULL(@ofacRes, '') <> ''  
  BEGIN     
   INSERT INTO remitTranOfac(TranId, blackListId, reason)  
   SELECT @tranId, @ofacRes, @ofacReason  
     
   UPDATE remitTran SET  
     tranStatus = 'OFAC'  
   WHERE id = @tranId  
        
   IF @pCountry = 'Nepal'  
   BEGIN  
    INSERT INTO rs_remitTranStatusUpdate(  
      controlNo, tranStatus, updatedBy, updatedDate  
    )  
    SELECT @controlNoEncrypted, 'OFAC', @user, @nepDate  
   END  
   RETURN  
  END  
    
  EXEC proc_errorHandler 0,'Modification Request Approved successfully',@emailId  
    
  SET @user = 'S:' + @user  
 END   
  
 --## Reject Modification  
 IF @flag = 'reject'  
 BEGIN  
  SELECT @controlNoEncrypted = controlNo, @pCountry = pCountry FROM remitTran WITH(NOLOCK) WHERE id = @tranId  
  BEGIN TRAN  
  INSERT INTO tranModifyRejectLog(tranId, controlNo, message, createdBy, createdDate, rejectedBy, rejectedDate, fieldName, fieldValue)  
  SELECT tranId, controlNo, message, createdBy, createdDate, @user, getdate(), fieldName, fieldValue FROM tranModifyLog WHERE tranId = @tranId AND STATUS = 'Request'   
    
  DELETE FROM tranModifyLog WHERE tranId = @tranId AND STATUS = 'Request'       
  UPDATE remitTran SET tranStatus = 'Payment' WHERE id = @tranId  
    
  COMMIT TRAN  
  EXEC proc_errorHandler 0,'Modification request rejected successfully',@controlNoEncrypted  
  
 END  
  
 IF @flag ='branchByTranId'  
 BEGIN  
  DECLARE @pBank INT  
  SELECT @pBank = pBank, @pBankType = pBankType FROM vwRemitTran WITH(NOLOCK) WHERE id = @tranId  
  IF @pBankType = 'I'  
  BEGIN  
   SELECT   
     agentId  
    ,agentName  
   FROM agentMaster WITH(NOLOCK) WHERE parentId = @pBank order by agentName  
  END  
  ELSE IF @pBankType = 'E'  
  BEGIN  
   SELECT  
     agentId = extBankId  
    ,agentName = branchName  
   FROM externalBankBranch WITH(NOLOCK) WHERE extBankId = @pBank order by branchName  
  END  
 END  
  
  
END TRY  
BEGIN CATCH  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE()  
     EXEC proc_errorHandler 1, @errorMessage, @tranId  
END CATCH  
  
  