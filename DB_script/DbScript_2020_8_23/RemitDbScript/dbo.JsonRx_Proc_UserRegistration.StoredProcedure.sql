USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[JsonRx_Proc_UserRegistration]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
CREATE PROCEDURE [dbo].[JsonRx_Proc_UserRegistration](      
  @language  VARCHAR(100) = 'en'      
 ,@customerId VARCHAR(100) = NULL      
 ,@username  VARCHAR(100) = NULL      
 ,@flag   VARCHAR(100) = NULL      
 ,@password  VARCHAR(100) = NULL      
 ,@clientId  VARCHAR(100) = NULL      
 ,@IMEI   VARCHAR(100) = NULL      
 ,@appVersion VARCHAR(100) = NULL      
 ,@phoneBrand VARCHAR(100) = NULL      
 ,@phoneOs  VARCHAR(100) = NULL      
 ,@osVersion  VARCHAR(100) = NULL      
 ,@deviceId  VARCHAR(100) = NULL      
 ,@dob   VARCHAR(100) = NULL      
 ,@mobile  VARCHAR(100) = NULL        
 ,@nativeCountry VARCHAR(5)  = NULL  
 ,@referenceId BIGINT = NULL      
)AS      
BEGIN TRY      
 DECLARE @dobDB VARCHAR(200),@code VARCHAR(100),@_errorMsg VARCHAR(300),@verifiedDate DATETIME, @customerIdNo VARCHAR(50)      
 IF @flag='sign-up'      
 BEGIN      
  --user already registered      
  IF EXISTS(SELECT 'x' FROM dbo.customerMaster AS CM(NOLOCK) WHERE CM.email = @username )      
  BEGIN      
   SELECT 1 ErrorCode,dbo.GetMessage(@language,'1002') Msg, NULL Id      
   RETURN      
  END      
      
  --user already registered      
  IF EXISTS(SELECT 'x' FROM dbo.customerMasterTemp AS CM(NOLOCK) WHERE username=@username)      
  BEGIN      
   SELECT 1 ErrorCode,dbo.GetMessage(@language,'1002') Msg, NULL Id      
   RETURN      
  END      
      
  --Username already taken      
  IF EXISTS(SELECT 'x' FROM dbo.mobile_userRegistration(NOLOCK) AS MUR WHERE username=@username)      
  BEGIN      
   SELECT 1 ErrorCode,dbo.GetMessage(@language,'1001') Msg, NULL Id      
   RETURN      
  END      
      
  BEGIN TRAN         
      
   INSERT INTO dbo.CustomerMasterTemp(      
    username,customerPassword,createdBy,createdDate,dob,email,mobile,isActive      
   )      
   SELECT      
    @username,dbo.FNAEncryptString(@password),@username,GETDATE(),@dob,@username,CASE WHEN ISNUMERIC(@username) = 1 THEN @username ELSE '' END,'Y'      
         
   SET @customerId=SCOPE_IDENTITY()      
      
   INSERT INTO dbo.mobile_userRegistration(      
    clientId,username,createdDate,IMEI,appVersion,phoneBrand,phoneOs,osVersion,deviceId,customerId      
   )      
   SELECT      
    @clientId,@username,GETDATE(),@IMEI,@appVersion,@phoneBrand,@phoneOs,@osVersion,@deviceId,@customerId      
  COMMIT TRAN      
  IF @@TRANCOUNT=0      
  BEGIN      
   --successful registered      
   SELECT 0 ErrorCode,dbo.GetMessage(@language,'1000') Msg, NULL Id, rowId, PdfName, AgreePdfPath       
   FROM customerAgreeDocumentTbl        
   WHERE targetObj = 'UAT'      
   RETURN      
  END      
 END      
 ELSE IF @flag = 'sign-up-V2'      
 BEGIN      
  --user already registered      
  IF EXISTS(SELECT 'x' FROM dbo.customerMaster AS CM(NOLOCK) WHERE CM.email=@username)      
  BEGIN      
   SELECT 1 ErrorCode,dbo.GetMessage(@language,'1002') Msg, NULL Id      
   RETURN      
  END      
      
	DECLARE @MOBILE_OTP VARCHAR(30) = NULL
	SELECT @MOBILE_OTP = MOBILE_NUMBER
	FROM TBL_MOBILE_OTP_REQUEST (NOLOCK)
	WHERE ROW_ID = @referenceId

	IF @MOBILE_OTP IS NULL
	BEGIN
		SELECT 1 ErrorCode,dbo.GetMessage(@language,'1003') Msg, NULL Id      
		RETURN   
	END

	IF @MOBILE_OTP <> @mobile
	BEGIN
		SELECT 1 ErrorCode,dbo.GetMessage(@language,'1004') Msg, NULL Id      
		RETURN   
	END

  --user already registered      
  IF EXISTS(SELECT 'x' FROM dbo.customerMasterTemp AS CM(NOLOCK) WHERE username=@username)      
  BEGIN      
   SELECT 1 ErrorCode,dbo.GetMessage(@language,'1002') Msg, NULL Id      
   RETURN      
  END      
      
  --Username already taken      
  IF EXISTS(SELECT 'x' FROM dbo.mobile_userRegistration(NOLOCK) AS MUR WHERE username=@username)      
  BEGIN      
   SELECT 1 ErrorCode,dbo.GetMessage(@language,'1001') Msg, NULL Id      
   RETURN      
  END       
      
  BEGIN TRAN         
   INSERT INTO dbo.CustomerMasterTemp(username,customerPassword,createdBy,createdDate,email,      
   mobile,nativeCountry,isActive)        
           
   SELECT  @username,dbo.FNAEncryptString(@password),@username,GETDATE(),@username,@mobile,      
   @nativeCountry,'Y'       
         
   SET @customerId=SCOPE_IDENTITY()      
      
   INSERT INTO dbo.mobile_userRegistration(clientId,username,createdDate,IMEI,appVersion,phoneBrand,      
   phoneOs,osVersion,deviceId,customerId      
   )      
   SELECT @clientId,@username,GETDATE(),@IMEI,@appVersion,@phoneBrand,@phoneOs,@osVersion,      
   @deviceId,@customerId      
      
  COMMIT TRAN        
  IF @@TRANCOUNT=0      
  BEGIN      
   --successful registered      
   SELECT 0 ErrorCode,dbo.GetMessage(@language,'1000') Msg, NULL Id, rowId, PdfName, AgreePdfPath       
   FROM customerAgreeDocumentTbl        
   WHERE targetObj = 'STAGING'      
   RETURN      
  END      
 END      
 ELSE If @flag='pwd-reset'      
 BEGIN      
  DECLARE @isExist BIT=0      
  IF EXISTS(SELECT 'x' FROM dbo.CustomerMasterTemp (NOLOCK) cm WHERE (cm.username=@userName) AND ISNULL(cm.isDeleted,'N')='N')      
  BEGIN      
   SET @isExist=1;       
  END       
          
  IF EXISTS(SELECT 'x' FROM dbo.customerMaster(NOLOCK) cm WHERE cm.email=@userName AND ISNULL(cm.isDeleted,'N')='N')      
  BEGIN      
   SET @isExist=1;      
          
  END      
      
  IF @isExist=0      
  BEGIN      
   SELECT @_errorMsg = 'User with contact Info ' + @username + ' does not exists. If you are a new user, then sign up and proceed further.'       
   SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID      
   RETURN       
  END      
      
         
  SELECT       
    @dobDB   = dob      
   ,@mobile  = mobile      
   ,@customerId = customerId       
   ,@verifiedDate = verifiedDate      
   ,@customerIdNo = idNumber      
   ,@mobile  = mobile      
  FROM customerMaster WITH (NOLOCK)       
  WHERE email = @userName       
  --or mobile = @userName --## RIGHT NOW ONLY EMAIL USER CAN LOGIN       
      
  --If @dobDB is null      
  --BEGIN      
  -- SET @dobDB = CAST(dbo.FNAGETDOB_FROM_ALIENCARD(LEFT(@customerIdNo,6),RIGHT(LEFT(@customerIdNo,8),1)) AS DATE);      
  --END      
      
  --IF(ISDATE(@dob) = 0)      
  --BEGIN      
  -- SELECT '1' ErrorCode,'Invalid DOB found' Msg,@customerId Id      
  -- RETURN;      
  --END      
      
  --IF CAST(@dobDB AS DATE)<>CAST(@dob AS DATE)      
  --BEGIN      
  -- EXEC proc_errorHandler 1, 'Your Date of Birth does not matches with your saved details, Please try again!', @customerId      
  -- RETURN;      
  --END      
      
  SET @code = UPPER(LEFT(@userName,1))+LEFT(NEWID(), 5) --remaining TO implement      
  BEGIN TRAN      
   UPDATE dbo.customerMaster SET customerPassword = dbo.FNAEncryptString(@code) WHERE email = @username      
      
   DECLARE @smsMsg VARCHAR(100) = 'Your new password is '+ @code      
   --IF ISNUMERIC(@username) = 1      
   --BEGIN      
   -- PRINT 'a'      
   -- --exec proc_CallToSendSMS @FLAG = 'I',@SMSBody=@smsMsg,@MobileNo=@mobile      
   --END      
  COMMIT TRAN      
  IF @@TRANCOUNT=0      
  BEGIN      
   SELECT '0' ErrorCode, 'Sucess' Msg ,NULL Id, @code Extra      
   RETURN      
  END      
  ELSE      
  BEGIN      
      SELECT '1' ErrorCode,'Could not reset the password. Please contact GME head office.',NULL      
   RETURN      
  END      
 END      
END TRY      
BEGIN CATCH      
 IF @@TRANCOUNT<>0      
  ROLLBACK TRAN      
 --Execption      
 SELECT 1 ErrorCode,dbo.GetMessage(@language,'9999')+CONVERT(VARCHAR,ERROR_LINE())+ERROR_MESSAGE() Msg, NULL Id      
 RETURN      
END CATCH      
-- 이용자 정보 동의 확인 값 추가 Info Agree Insert       
IF @flag = 'agree'      
BEGIN  
IF EXISTS(SELECT 'X' FROM CustomerMasterTemp WHERE username = @username)  
 BEGIN  
 UPDATE customerMasterTemp      
 SET agreeYn = '1'      
 WHERE username = @username      
      
 SELECT 0 ErrorCode,'Success' Msg, NULL Id        
 RETURN  
 END  
 ELSE  
 BEGIN  
 SELECT 1 ErrorCode, 'Failed' Msg, NULL Id  
 END  
 END

GO
