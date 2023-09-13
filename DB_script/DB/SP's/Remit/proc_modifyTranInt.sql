use fastmoneypro_remit
go

alter PROC [dbo].[proc_modifyTranInt]  
   @flag        VARCHAR(50)  = NULL  
 ,@user                              VARCHAR(30)  = NULL  
 ,@tranId       INT    = NULL  
 ,@rowId        INT    = NULL  
 ,@fieldName       VARCHAR(200) = NULL  
 ,@oldValue       VARCHAR(200) = NULL  
 ,@newTxtValue      VARCHAR(200) = NULL  
 ,@newDdlValue      VARCHAR(200) = NULL  
 ,@firstName       VARCHAR(200) = NULL  
 ,@middleName      VARCHAR(200) = NULL  
 ,@lastName1       VARCHAR(200) = NULL  
 ,@lastName2       VARCHAR(200) = NULL  
 ,@contactNo       VARCHAR(200) = NULL  
 ,@bankNewName      VARCHAR(100)    = NULL  
 ,@branchNewName      VARCHAR(100) = NULL  
 ,@isAPI        CHAR(1)   = NULL  
 ,@fieldValue      VARCHAR(200) = NULL  
 ,@branchId       VARCHAR(50)  = NULL  
 ,@emailId       VARCHAR(200) = NULL  
 ,@sendSmsEmail      VARCHAR(20)  = NULL  
  
  
AS  
  
/*  
  EXEC [proc_modifyTXN]  @flag = 'u', @user = 'admin', @tranId = '2',   
@fieldName = 'senderName', @oldValue = 'Shiva Khanal', @newTxtValue = null,   
@newDdlValue = null, @firstName = 'Bijay', @middleName = null, @lastName1 = 'Shahi', @lastName2 = null  
  
*/  
  
SET NOCOUNT ON  
SET XACT_ABORT ON  
BEGIN TRY  
   
 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)  
 DECLARE @controlNo varchar(30), @message VARCHAR(100), @agentRefId VARCHAR(15), @controlNoEncrypted VARCHAR(30), @tranNo BIGINT  
 DECLARE @xml XML  
 DECLARE @pDistrict VARCHAR(100), @pDistrictId INT, @pState VARCHAR(100), @pStateId INT     
 DECLARE   
    @deliveryMethodId INT  
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
     
 DECLARE @parentId as int,  
   @branchName as varchar(200),  
   @agentName as varchar(200),  
   @locationCode as int,  
   @locationName as varchar(200),  
   @oldLocation as varchar(200),  
   @oldAgentId as int,  
   @oldAgentName as varchar(200),  
   @supAgentId as int,  
   @supAgentName as varchar(200)  
 DECLARE @MAXID INT,@MAXIDNEW INT,@MINID INT,@MINIDNEW INT,@modifyId INT  
       
 SET @agentRefId = '1' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '000000000', 8)  
   
 SELECT @controlNo = dbo.FNADecryptString(controlNo)  
   ,@pCountry = pCountry  
   ,@controlNoEncrypted = controlNo   
 FROM remitTran WITH(NOLOCK) WHERE id = @tranId  
   
 -- >> direct modification from admin panel  
 IF @flag='u'  
 BEGIN     
  -->> updated inficare as well  
  IF @fieldName='senderName'   
  BEGIN  
   IF @firstName IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid first name!', @tranId  
    RETURN  
   END     
     
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @senderName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' +@lastName2, '')  
     
   BEGIN TRAN  
   UPDATE tranSenders SET  
     firstName = UPPER(@firstName)  
    ,middleName = UPPER(@middleName)  
    ,lastName1 = UPPER(@lastName1)  
    ,lastName2 = UPPER(@lastName2)  
   WHERE tranId = @tranId  
  
   UPDATE remitTran SET senderName = upper(@senderName) WHERE id = @tranId  
   UPDATE customerTxnHistory SET senderName = @senderName WHERE refNo = dbo.encryptdb(@controlNo)  
     
   SET @message = 'Sender Name:'+ ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' +@lastName2, '')  
   INSERT INTO  tranModifyLog (tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user,GETDATE(),'MODIFY'  
   COMMIT TRAN  
  
   EXEC proc_ofacTracker @flag = 't', @name = @senderName, @Result = @senderOfacRes OUTPUT  
      
  END  
    
  -->> updated inficare as well  
  ELSE IF @fieldName='receiverName'  
  BEGIN  
   if @firstName is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid first name!' , @tranId  
    return  
   end  
     
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @receiverName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
     
   BEGIN TRAN  
   update tranReceivers SET  
     firstName = @firstName  
    ,middleName = @middleName  
    ,lastName1 = @lastName1  
    ,lastName2 = @lastName2  
   WHERE tranId = @tranId  
     
   UPDATE remitTran SET receiverName = upper(@receiverName) WHERE id = @tranId  
  
   SET @message = 'Receiver Name:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
   insert into  tranModifyLog   (tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
   COMMIT TRAN  
       
   EXEC proc_ofacTracker @flag = 't', @name = @receiverName, @Result = @receiverOfacRes OUTPUT  
       
  end  
  
  -->> updated inficare as well  
  ELSE IF @fieldName='rAddress'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    return  
   end   
  
      UPDATE tranReceivers SET  
     address = @newTxtValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Receiver Address:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user, GETDATE(), 'MODIFY'  
  END  
  
  -->> updated inficare as well   
  ELSE IF @fieldName='rIdType'  
  BEGIN  
   if @newDdlValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    return  
   end   
   update tranReceivers SET  
     idType = @newDdlValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Receiver Id Type:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newDdlValue,'')  
   insert into  tranModifyLog   (tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  
  END  
    
  ELSE IF @fieldName='rTelNo'  
  BEGIN  
   if @contactNo is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid telephone number!', @tranId  
    return  
   end   
      update tranSenders SET  
     homephone = @contactNo  
   WHERE tranId = @tranId      
  
  
   SET @message = 'Sender telephone number:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'   
  END  
  
  -->> updated inficare as well   
  ELSE IF @fieldName='sIdType'  
  BEGIN  
   if @newDdlValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    return  
   end     
   update tranSenders SET  
     idType = @newDdlValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Id Type:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@newDdlValue, '')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  
  end  
  
  -->> updated inficare as well    
  ELSE IF @fieldName='sAddress'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    return  
   end   
     update tranSenders SET  
     address = @newTxtValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Address:' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(@newTxtValue, '')   
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'   
  END  
  
  -->> updated inficare as well  
  ELSE IF @fieldName='sContactNo'  
  BEGIN  
   IF @contactNo IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId  
    RETURN  
   END   
     UPDATE tranSenders SET  
     mobile = @contactNo  
   WHERE tranId = @tranId   
  
   SET @message = 'Sender Contact No:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@contactNo,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'   
  END  
      
  -->> updated inficare as well: mobile number  
  ELSE IF @fieldName='rContactNo'   
  BEGIN  
   if @contactNo is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId  
    return  
   end   
     update tranReceivers SET  
     mobile = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver Contact No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  
  END  
  
  -->> updated inficare as well    
  ELSE IF @fieldName='sIdNo'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranSenders SET  
     idNumber = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender ID No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'   
  end  
  
  ELSE IF @fieldName='relationship'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid Receiver relationship with sender!', @tranId  
    RETURN  
   END   
   UPDATE remitTran SET  
     relWithSender = @newDdlValue  
   WHERE id = @tranId  
        
   SET @message = 'Receiver relationship with sender :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newDdlValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
  
  -->> updated inficare as well  
  ELSE IF @fieldName='rIdNo'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranReceivers SET  
     idNumber = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver ID No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end    
    
  ELSE IF @fieldName='txnTestQuestion'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranSenders SET  
     txnTestQuestion = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Question:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
    
  ELSE IF @fieldName='txnTestAnswer'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranSenders SET  
     txnTestAnswer = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Answer:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
    
  ELSE IF @fieldName='accountNo'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid account number!', @tranId  
    RETURN  
   END   
      UPDATE remitTran SET  
     accountNo = @newDdlValue  
   WHERE id = @tranId   
     
   SET @message = 'Account Number:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newDdlValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'  
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
     
      update remitTran SET  
     pBank = @bankNewName,       
     pBankName=dbo.GetAgentNameFromId(@bankNewName),  
     pBankBranch = @branchNewName,  
     pBankBranchName=dbo.GetAgentNameFromId(@branchNewName)  
   WHERE id = @tranId   
     
   SET @message = 'Bank Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@bankNewName),'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
     
   DECLARE @message2 VARCHAR(200) = NULL  
   SET @message2 = 'Branch name has been changed to '+isnull(dbo.GetAgentNameFromId(@branchNewName),'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message2,@user,GETDATE(),'MODIFY'  
  
  END  
    
  ELSE IF @fieldName='BranchName'  
  BEGIN  
   EXEC proc_errorHandler 1, 'Feature not available at the moment', @tranId  
   RETURN  
   if @newDdlValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid branch name!', @tranId  
    return  
   end   
      update remitTran SET  
     pBankBranch = @newDdlValue,  
     pBankBranchName=dbo.GetAgentNameFromId(@newDdlValue)  
   WHERE id = @tranId   
     
   SET @message = 'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@newDdlValue),'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  
   DECLARE @pBankType CHAR(1)  
   SELECT @pBankType = pBankType FROM remitTran WITH(NOLOCK) WHERE id = @tranId  
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
   from remitTran where id=@tranId  
     
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
    update remitTran SET  
      pAgent = @newDdlValue,  
      pBranch=@newDdlValue,  
      pAgentName=@branchName,  
      pBranchName=@branchName,  
      pSuperAgent=@supAgentId,  
      pSuperAgentName=@supAgentName  
    WHERE id = @tranId   
      
    -- ## update transaction log      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,GETDATE(),'MODIFY'  
      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@supAgentName,''),@user,GETDATE(),'MODIFY'  
      
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
    update remitTran SET  
      pAgent = @parentId,  
      pBranch=@newDdlValue,  
      pAgentName=@agentName,  
      pBranchName=@branchName,  
      pSuperAgent=@supAgentId,  
      pSuperAgentName=@supAgentName  
    WHERE id = @tranId   
      
    -- ## update transaction log          
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,GETDATE(),'MODIFY'  
      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@agentName,''),@user,GETDATE(),'MODIFY'  
   end    
     
  END  
  
  ELSE IF @fieldName = 'rCity'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid receiver city!', @tranId  
    RETURN  
   END   
      UPDATE tranreceivers SET  
     city = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver City :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'  
  END  
  
  ELSE IF @fieldName = 'sCity'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid Sender City!', @tranId  
    RETURN  
   END   
      UPDATE transenders SET  
     city = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender City :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'  
  END  
  EXEC proc_errorHandler 0, 'Record has been updated successfully.', @tranId  
    
  IF (ISNULL(@isAPI, 'N') = 'Y')  
  BEGIN  
   IF(@fieldName = 'pAgentLocation')  
   BEGIN  
    EXEC proc_modifyTxnAPI @flag = 'mpl', @controlNo = @controlNo, @user = @user, @newPLocation = @newDdlValue, @agentRefId = NULL  
   END  
   ELSE  
   BEGIN  
    EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @message, @agentRefId = NULL, @updateInSwift = 'N'  
   END  
  END  
 END   
   
 -->> transaction modification : hold only (from agent panel)  
 IF @flag='uHoldtxn'    
 BEGIN      
  IF @fieldName='senderName'   
  BEGIN  
   IF @firstName IS NULL   
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid first name!', @tranId  
    RETURN  
   END     
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @senderName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
   UPDATE tranSendersTemp SET  
     firstName = @firstName  
    ,middleName = @middleName  
    ,lastName1 = @lastName1  
    ,lastName2 = @lastName2  
   WHERE tranId = @tranId  
     
   UPDATE remitTranTemp SET  
     senderName = upper(@senderName)  
   WHERE id = @tranId  
  
   SET @message = 'Sender Name:'+ ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' +@lastName2, '')  
   INSERT INTO  tranModifyLog (tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user,GETDATE(),'MODIFY'  
  END  
    
  ELSE IF @fieldName='receiverName'  
  BEGIN  
   if @firstName is null   
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid first name!' , @tranId  
    return  
   end  
   SELECT @firstName = UPPER(@firstName), @middleName = UPPER(@middleName), @lastName1 = UPPER(@lastName1), @lastName2 = UPPER(@lastName2)  
   SET @receiverName = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
  
   update tranReceiversTemp SET  
     firstName = @firstName  
    ,middleName = @middleName  
    ,lastName1 = @lastName1  
    ,lastName2 = @lastName2  
   WHERE tranId = @tranId  
     
   UPDATE remitTranTemp SET  
     receiverName = upper(@receiverName)  
   WHERE id = @tranId  
  
   SET @message = 'Receiver Name:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')  
   insert into  tranModifyLog   (tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
    
  ELSE IF @fieldName='sIdType'  
  BEGIN  
   if @newDdlValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    return  
   end     
   update tranSendersTemp SET  
     idType = @newDdlValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Id Type:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@newDdlValue, '')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
    
  ELSE IF @fieldName='rIdType'  
  BEGIN  
   if @newDdlValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId  
    return  
   end   
   update tranReceiversTemp SET  
     idType = @newDdlValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Receiver Id Type:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newDdlValue,'')  
   insert into  tranModifyLog   (tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
  
  ELSE IF @fieldName='relationship'  
  BEGIN  
   IF @newDdlValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid Receiver relationship with sender!', @tranId  
    RETURN  
   END   
   UPDATE remitTranTemp SET  
     relWithSender = @newDdlValue  
   WHERE id = @tranId  
        
   SET @message = 'Receiver relationship with sender :'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newDdlValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
  
  ELSE IF @fieldName='rAddress'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    return  
   end   
     update tranReceiversTemp SET  
     address = @newTxtValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Receiver Address:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   SELECT @tranId, @message, @user, GETDATE(), 'MODIFY'  
  END  
    
  ELSE IF @fieldName='sAddress'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId  
    return  
   end   
     update tranSendersTemp SET  
     address = @newTxtValue  
   WHERE tranId = @tranId  
     
   SET @message = 'Sender Address:' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(@newTxtValue, '')   
   INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'   
  end  
    
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
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'   
  END  
    
  ELSE IF @fieldName='rTelNo'  
  BEGIN  
   if @contactNo is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid telephone number!', @tranId  
    return  
   end   
     update tranReceiversTemp SET  
     homephone = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver telephone number:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'   
  end  
    
  ELSE IF @fieldName='sTelNo'  
  BEGIN  
   if @contactNo is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid telephone number!', @tranId  
    return  
   end   
     update tranSendersTemp SET  
     homephone = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender telephone number:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'   
  end  
    
  ELSE IF @fieldName='rContactNo'  
  BEGIN  
   if @contactNo is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId  
    return  
   end   
     update tranReceiversTemp SET  
     mobile = @contactNo  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver Contact No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
    
  ELSE IF @fieldName='sIdNo'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranSendersTemp SET  
     idNumber = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Sender ID No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'   
  end  
    
  ELSE IF @fieldName='rIdNo'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranReceiversTemp SET  
     idNumber = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Receiver ID No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end    
    
  ELSE IF @fieldName='txnTestQuestion'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranSendersTemp SET  
     txnTestQuestion = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Question:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
    
  ELSE IF @fieldName='txnTestAnswer'  
  BEGIN  
   if @newTxtValue is null  
   begin  
    EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId  
    return  
   end   
     update tranSendersTemp SET  
     txnTestAnswer = @newTxtValue  
   WHERE tranId = @tranId   
     
   SET @message = 'Test Answer:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  end  
    
  ELSE IF @fieldName='accountNo'  
  BEGIN  
   IF @newTxtValue IS NULL  
   BEGIN  
    EXEC proc_errorHandler 1, 'Please enter valid account number!', @tranId  
    RETURN  
   END   
      UPDATE remitTranTemp SET  
     accountNo = @newTxtValue  
   WHERE id = @tranId   
     
   SET @message = 'Account Number:'+ ISNULL(@oldValue,'')+' has been changed to '+ISNULL(@newTxtValue,'')  
   INSERT INTO  tranModifyLog(tranId,MESSAGE,createdBy,createdDate,MsgType)  
   SELECT @tranId,@message,@user,GETDATE(),'MODIFY'  
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
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
     
   ----DECLARE @message3 VARCHAR(200) = NULL  
   SET @message = 'Branch name has been changed to '+isnull(dbo.GetAgentNameFromId(@branchNewName),'')  
   insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
  
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
   select @tranId,@message,@user,GETDATE(),'MODIFY'  
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
    select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,GETDATE(),'MODIFY'  
      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@supAgentName,''),@user,GETDATE(),'MODIFY'  
      
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
    select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,GETDATE(),'MODIFY'  
      
    insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)  
    select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@agentName,''),@user,GETDATE(),'MODIFY'  
   end    
     
  END  
    
  EXEC proc_errorHandler 0, 'Record has been updated successfully.', @tranId  
    
  IF (ISNULL(@isAPI, 'N') = 'Y')  
  BEGIN  
   IF(@fieldName = 'pAgentLocation')  
   BEGIN  
    EXEC proc_modifyTxnAPI @flag = 'mpl', @controlNo = @controlNo, @user = @user, @newPLocation = @newDdlValue, @agentRefId = NULL  
   END  
   ELSE  
   BEGIN  
    EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @message, @agentRefId = NULL  
   END  
  END  
 END    
   
 IF @flag='sa'  
 BEGIN  
  SELECT pBank FROM remitTran WHERE id=@tranId   
 END   
   
 -->> transaction modification approve requested by branches  
 IF @flag = 'approveAll'  
 BEGIN  
  DECLARE @tranType CHAR(1)
   
     --GET receiverid AND customerid
	DECLARE @receiverId INT,@customerId INT
	SELECT  @receiverId = trt.customerid,@customerId = tst.customerid, @tranType = tranType, @pCountry = pCountry, @controlNoEncrypted = controlNo
    FROM remittran rtt 
	INNER JOIN tranreceivers trt on trt.tranid = rtt.id
	INNER JOIN transenders tst on tst.tranid = rtt.id
	WHERE rtt.id = @tranId

	DECLARE  @roldaddress			 VARCHAR(100)	= NULL
			,@roldreceiverAccountNo	 VARCHAR(100)	= NULL
			,@roldmobile			 VARCHAR(100)	= NULL
			,@oldidType			   	INT				= NULL
			,@roldidNumber			VARCHAR(25)		= NULL
			,@roldidType			VARCHAR(25)		= NULL
			,@roldfullName			VARCHAR(100)	= NULL
			,@nameChanged			BIT				= 0
			,@roldNameXml			VARCHAR(MAX)	= NULL

	SELECT  @roldaddress				= address	
		   ,@roldreceiverAccountNo	    = receiverAccountNo
		   ,@roldmobile				    =mobile
		   ,@roldidType					= idType 	
		   ,@roldidNumber		    	= idNumber		
		   ,@roldfullName			    = firstName + ISNULL(' ' + middleName,'') + ISNULL(' ' + lastName1,'') + ISNULL(' ' + lastName2 ,'')	
		   				
		 FROM dbo.receiverInformation
		 WHERE receiverId = @receiverId

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
FROM tranModifyLog WHERE tranId = @tranId AND STATUS = 'Request'  

  ALTER TABLE #TEMPTABLE ADD rowId INT IDENTITY(1,1)  

  SELECT @MAXIDNEW =MAX(rowId) FROM #TEMPTABLE  
  SET @MINIDNEW = 1
  WHILE @MAXIDNEW >=  @MINIDNEW  
  BEGIN  
  --SET LOG info
    SELECT @modifyId  = modifyId,  
      @fieldName  = fieldName,  
      @fieldValue  = fieldValue,  
      @oldValue  = oldValue  
    FROM #TEMPTABLE WITH(NOLOCK)  
    WHERE rowId = @MINIDNEW   
	
	IF @fieldName = 'rAddress'
		SET @roldaddress = @fieldValue
	IF @fieldName = 'accountNo'
		SET @roldreceiverAccountNo = @fieldValue
	IF @fieldName = 'rContactNo'
		SET @roldmobile = @fieldValue
	IF @fieldName = 'rIdNo'
		SET @roldidNumber = @fieldValue
	IF @fieldName = 'rIdType'
		SET @roldidType = @fieldValue
	IF @fieldName = 'receiverName'
	BEGIN
		SET @roldNameXml = @fieldValue
		SET @nameChanged  = 1
	END
	SET @MINIDNEW = @MINIDNEW + 1  
	END
		   DECLARE @CREATEDBY VARCHAR(50)
		   SELECT @CREATEDBY = createdby from receiverinformation where receiverid =  @receiverId

	  EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i-fromModificationNew'
										,@user = @CREATEDBY
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@address			= @roldaddress
										,@receiverAccountNo = @roldreceiverAccountNo
										,@mobile			= @roldmobile
										,@idType			= @roldidType
										,@idNumber			= @roldidNumber
										,@tranId			= @tranId
										,@nameChanged		= @nameChanged
										,@roldNameXml		= @roldNameXml
  
  SELECT @MAXID = MAX(rowId) FROM #TEMPTABLE  
  SET @MINID = 1  
  WHILE @MAXID >=  @MINID  
  BEGIN  
    SELECT @modifyId  = modifyId,  
      @fieldName  = fieldName,  
      @fieldValue  = fieldValue,  
      @oldValue  = oldValue  
    FROM #TEMPTABLE WITH(NOLOCK)  
    WHERE rowId = @MINID      
 
    IF @fieldName='rIdType'  
    BEGIN  
     UPDATE tranReceivers SET idType = @fieldValue WHERE tranId = @tranId  
	 IF @nameChanged = 0
		UPDATE receiverInformation SET IDTYPE = @fieldValue WHERE RECEIVERID = @receiverId
            
     SET @message = 'Receiver Id Type [<b>'+ISNULL(@oldValue, '') +'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END  
    
    ELSE IF @fieldName='rAddress'  
    BEGIN     
     UPDATE tranReceivers SET address = @fieldValue WHERE tranId = @tranId 
	 IF @nameChanged = 0
		UPDATE receiverInformation SET ADDRESS = @fieldValue WHERE RECEIVERID = @receiverId 

     SET @message = 'Receiver Address [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END  
    
    ELSE IF @fieldName='rContactNo'  
    BEGIN        
	
     UPDATE tranReceivers SET mobile = @fieldValue WHERE tranId = @tranId 
	 IF @nameChanged = 0
		UPDATE receiverInformation SET MOBILE = @fieldValue WHERE RECEIVERID = @receiverId    
           
     SET @message = 'Receiver Contact No [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END  
      
    ELSE IF @fieldName='rIdNo'  
    BEGIN       

     UPDATE tranReceivers SET idNumber = @fieldValue WHERE tranId = @tranId  
	 IF @nameChanged = 0 
		UPDATE receiverInformation SET IDNUMBER = @fieldValue WHERE RECEIVERID = @receiverId  
            
     SET @message = 'Receiver ID No [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END  
    
    ELSE IF @fieldName='accountNo'  
    BEGIN    
     UPDATE remitTran SET accountNo = @fieldValue WHERE id = @tranId   
	 UPDATE tranReceivers SET accountNo = @fieldValue WHERE TRANID = @tranId  
	 IF @nameChanged = 0
		UPDATE receiverInformation SET RECEIVERACCOUNTNO = @fieldValue WHERE RECEIVERID = @receiverId 
        
     SET @message = 'Receiver Bank Ac No [<b>'+ISNULL(@oldValue, '')+'</b>] has been replaced to [<b>'+isnull(@fieldValue,'')+'</b>]'  
    END   

    UPDATE tranModifyLog SET   
      MESSAGE = @message  
     ,MsgType = 'MODIFY'  
     ,resolvedBy = @user  
     ,resolvedDate = GETDATE()  
     ,status = 'approved'  
    WHERE rowId = @modifyId  
    SET @MINID = @MINID + 1  
      
    DECLARE @newId VARCHAR(50) = NEWID()  
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
     
   RETURN  
  END  

  ------TROUBLE TICKET  
  DECLARE @msg VARCHAR(MAX)  
  ,@mobileNo  VARCHAR(100)  
  ,@country  VARCHAR(100)  
  ,@email      VARCHAR(100)  
  ,@subject    VARCHAR(100)  
  ,@mm  VARCHAR(MAX)  
  ,@cn  VARCHAR(MAX)  
  ,@emailContent VARCHAR(MAX)  
     
  SET @cn=dbo.fnaEncryptString(@controlNo)  
  IF @cn IS NOT NULL   
  BEGIN    
   SET @mm=(SELECT top 1 message FROM tranModifyLog (NOLOCK) WHERE ISNULL(status,'1')='Request' AND controlNo=@cn)    
   IF @mm IS NOT NULL  
   BEGIN  
    SET @msg= 'Dear Customer, '+ isnull(@mm,'') +'Please confirm the detail and visit sending agent,if modification required.'  
            
    SELECT   
     @mobileNo=ts.mobile,@country=ts.country    
    FROM RemitTran rt (NOLOCK)  
    INNER JOIN tranSenders ts (NOLOCK) on rt.id = ts.tranId  
    WHERE rt.controlNo=dbo.FNAEncryptString(@controlNo) AND ts.mobile IS NOT NULL  
    
    SET @subject='Trouble Ticket'     
   
    SELECT   
      @agentId=rt.sAgent  
     ,@agentName=am.agentName  
     ,@branchId=rt.sBranch    
    FROM remitTran rt   
    INNER JOIn tranSenders ts (NOLOCK) on ts.tranId=rt.id  
    INNER JOIn agentMaster am (NOLOCK) on am.agentId=rt.sAgent   
    WHERE rt.id=@tranId  
  
    SELECT   
     @branchName= am.agentName   
    FROM remitTran rt (NOLOCK)  
    INNER JOIn tranSenders ts (NOLOCK) on ts.tranId=rt.id    
    INNER JOIN agentMaster am (NOLOCK) on am.agentId=rt.sBranch  
    WHERE rt.id=@tranId AND agentType = '2904'   
    
     
    SET @emailContent='Dear<strong>' +' ' + @agentName  +' - ' + @branchName +'</strong>, <br/><br/>Following message has been raised from IME.<br/>" '+@msg +'"<br/><br/>' +'ICN:'+' '+@controlNo+'  
    <br/>Please email to <a href="javascript:void(0);"> support@imeremit.com.np </a>  for any queries.<br/><br/>Thank you, <br/>IME Support Team <br/><br/><br/><br/>'  
  
            
    SET @email=  
      (  
         SELECT am.agentEmail1   
         FROM remitTran rt  (NOLOCK)  
         INNER JOIN agentMaster am  (NOLOCK) ON rt.sAgent=am.agentId  
         WHERE rt.id=@tranId and am.agentEmail1 IS NOT NULL  
      )  
   END  
  END  
        
  IF @sendSmsEmail iS NOT NULL  
  BEGIN  
   IF (@sendSmsEmail='sms' OR @sendSmsEmail='both')  AND @mobileNo IS NOT NULL  
   BEGIN  
    EXEC sp_InsertIntoSMSQueue 'sms' ,@user ,@msg,@country,NULL,@agentId ,@branchId ,@mobileNo ,@controlNo,NULL,@tranId  
    EXEC proc_errorHandler 0,' ',@emailId  
    RETURN       
   END  
     
   IF (@sendSmsEmail='email' OR @sendSmsEmail='both') AND @email IS NOT NULL  
   BEGIN      
    EXEC sp_InsertIntoSMSQueue 'email' ,@user,@emailContent, @country,@email,@agentId ,@branchId ,NULL,@controlNo , @subject,@tranId   
    EXEC proc_errorHandler 0,' ',@emailId  
    RETURN       
   END  
  END  
    
  EXEC proc_errorHandler 0,'Modification Request Approved successfully',@emailId  
  RETURN  
 END   
  
 -->> transaction modification reject requested by branches  
 if @flag = 'reject'  
 begin  
  SELECT @controlNoEncrypted = controlNo, @pCountry = pCountry FROM remitTran WITH(NOLOCK) WHERE id = @tranId  
   
  INSERT INTO tranModifyRejectLog(tranId, controlNo, message, createdBy, createdDate, rejectedBy, rejectedDate, fieldName, fieldValue)  
  SELECT tranId, controlNo, message, createdBy, createdDate, @user, GETDATE(), fieldName, fieldValue FROM tranModifyLog WHERE tranId = @tranId AND STATUS = 'Request'   
    
  DELETE   
  FROM tranModifyLog WHERE tranId = @tranId AND STATUS = 'Request'     
    
  UPDATE remitTran SET tranStatus = 'Payment' WHERE id = @tranId  
   
  EXEC proc_errorHandler 0,'Modification request rejected successfully',@controlNoEncrypted  
  RETURN  
 end  
  
 if @flag ='branchByTranId'  
 BEGIN  
  DECLARE @pBank INT  
  SELECT @pBank = pBank, @pBankType = pBankType FROM vwRemitTran with(nolock) where id = @tranId  
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
  RETURN  
 END  
  
  
END TRY  
BEGIN CATCH  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE()  
     EXEC proc_errorHandler 1, @errorMessage, @tranId  
END CATCH  
  
  