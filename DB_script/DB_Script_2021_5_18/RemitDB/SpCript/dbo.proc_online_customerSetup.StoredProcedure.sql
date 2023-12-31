USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_customerSetup]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[proc_online_customerSetup]  
  @flag						 VARCHAR(50)  = NULL  
 ,@user						 VARCHAR(30)  = NULL  
 ,@ImageId					 VARCHAR(10)  = NULL
 ,@ImagePath				 VARCHAR(150) = NULL
 ,@columnName				 VARCHAR(50)  = NULL
 ,@value					 VARCHAR(150) = NULL
 ,@gender					 VARCHAR(10)  = NULL  
 ,@customerId				 VARCHAR(30)  = NULL  
 ,@fullName					 VARCHAR(200) = NULL  
 ,@passportNo                VARCHAR(30)  = NULL  
 ,@mobile					 VARCHAR(15)  = NULL  
 ,@firstName				 VARCHAR(100) = NULL  
 ,@middleName				 VARCHAR(100) = NULL  
 ,@lastName1				 VARCHAR(100) = NULL  
 ,@lastName2				 VARCHAR(100) = NULL  
 ,@customerIdType			 VARCHAR(30)  = NULL  
 ,@customerIdNo				 VARCHAR(50)  = NULL  
 ,@custIdissueDate			 VARCHAR(30)  = NULL  
 ,@custIdValidDate			 VARCHAR(30)  = NULL  
 ,@custDOB					 VARCHAR(30)  = NULL  
 ,@custTelNo				 VARCHAR(30)  = NULL  
 ,@custMobile				 VARCHAR(30)  = NULL  
 ,@custCity					 VARCHAR(100) = NULL  
 ,@custPostal				 VARCHAR(30)  = NULL  
 ,@companyName				 VARCHAR(100) = NULL  
 ,@custAdd1					 VARCHAR(100) = NULL  
 ,@custAdd2					 VARCHAR(100) = NULL  
 ,@country					 VARCHAR(30)  = NULL  
 ,@custNativecountry		 VARCHAR(30)  = NULL  
 ,@custEmail				 VARCHAR(50)  = NULL  
 ,@custGender				 VARCHAR(30)  = NULL  
 ,@custSalary				 VARCHAR(30)  = NULL  
 ,@memberId					 VARCHAR(30)  = NULL  
 ,@occupation				 VARCHAR(30)  = NULL  
 ,@state					 VARCHAR(30)  = NULL  
 ,@zipCode					 VARCHAR(30)  = NULL  
 ,@district					 VARCHAR(30)  = NULL  
 ,@homePhone				 VARCHAR(30)  = NULL  
 ,@workPhone				 VARCHAR(30)  = NULL  
 ,@placeOfIssue				 VARCHAR(30)  = NULL  
 ,@customerType				 VARCHAR(30)  = NULL  
 ,@isBlackListed			 VARCHAR(30)  = NULL  
 ,@relativeName				 VARCHAR(30)  = NULL  
 ,@relationId				 VARCHAR(30)  = NULL   
 ,@lastTranId				 VARCHAR(30)  = NULL  
 ,@receiverName				 VARCHAR(100) = NULL  
 ,@tranId					 VARCHAR(20)  = NULL  
 ,@ICN						 VARCHAR(50)  = NULL  
 ,@bankName				     VARCHAR(100) = NULL  
 ,@bankAccountNo		     VARCHAR(20) =  NULL  
 ,@mapCodeInt				 VARCHAR(10)  = NULL  
 ,@sortBy					 VARCHAR(50)  = NULL  
 ,@sortOrder				 VARCHAR(5)   = NULL  
 ,@pageSize					 INT		  = NULL  
 ,@pageNumber				 INT		  = NULL  
 ,@isMemberIssued			 CHAR(1)	  = NULL  
 ,@agent					 VARCHAR(50)  = NULL  
 ,@branch					 VARCHAR(50)  = NULL  
 ,@branchId					 VARCHAR(50)  = NULL  
 ,@onlineUser				 VARCHAR(50)  = NULL  
 ,@ipAddress				 VARCHAR(30)  = NULL  
 ,@howDidYouHear			 VARCHAR(200) = NULL  
 ,@ansText					 VARCHAR(200) = NULL  
 ,@isActive					 CHAR(1)      = NULL  
 ,@email					 VARCHAR(150) = NULL
 ,@createdDate				 DATETIME	  = NULL
 ,@createdBy				 VARCHAR(50)  = NULL
 ,@verifyDoc1				 VARCHAR(150) = NULL 
 ,@verifyDoc2				 VARCHAR(150) = NULL
 ,@verifyDoc3				 VARCHAR(150) = NULL
 ,@SelfieDoc				 VARCHAR(150) = NULL
 ,@custPassword				VARCHAR(150) = NULL
 ,@referralCode				VARCHAR(50) = NULL
 ,@verCode			         VARCHAR(40) = NULL
   
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
  

set @bankAccountNo = replace(@bankAccountNo,'-','')

IF ISNUMERIC(@country) <> '1'  
	SET @country = (select top 1 countryId from countrymaster with (nolock) where countryName=@country)  
  
BEGIN TRY 
	 CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)	
	 DECLARE  
	   @sql    VARCHAR(MAX)  
	  ,@oldValue   VARCHAR(MAX)  
	  ,@newValue   VARCHAR(MAX)  
	  ,@module   VARCHAR(10)  
	  ,@tableAlias  VARCHAR(100)  
	  ,@logIdentifier  VARCHAR(50)  
	  ,@logParamMod  VARCHAR(100)  
	  ,@logParamMain  VARCHAR(100)  
	  ,@table    VARCHAR(MAX)  
	  ,@select_field_list VARCHAR(MAX)  
	  ,@extra_field_list VARCHAR(MAX)  
	  ,@sql_filter  VARCHAR(MAX)  
	  ,@modType   VARCHAR(6)  
	  ,@errorMsg   VARCHAR(MAX)  
    
	 SELECT  
	   @logIdentifier = 'customerId'  
	  ,@logParamMain = 'customerMaster'    
	  ,@module = '20'  
	  ,@tableAlias = 'CustomerMaster'  
     



IF @flag = 'checkEmail'  
BEGIN  
 IF EXISTS(SELECT 'X' FROM customerMaster WHERE email = @CustEmail AND ISNULL(isDeleted, 'N') <> 'Y' and ISNULL(onlineUser, 'N')='Y' )  
 BEGIN    
		SELECT '1' AS ErrorCode, 'It looks like your email('+ @CustEmail +') is already registered with us.
		If you have forgotten your password  
		<a href="forgotpassword" style="color:blue;"><u> Click here</u> </a> to reset your password ' AS Msg  , '' Id 
		RETURN  
  END    
  SELECT '0' AS ErrorCode, 'Valid E-Mail ID to register !' AS Msg  , '' Id
  
  INSERT INTO registrationEmailLogs(email,createdDate)  
	SELECT @CustEmail, GETDATE()  
  RETURN
END

IF @flag = 'checkMobile'  
BEGIN  
 IF EXISTS(SELECT 'X' FROM customerMaster WHERE mobile = @custMobile AND ISNULL(isDeleted, 'N') <> 'Y' and ISNULL(onlineUser, 'N')='Y' )  
 BEGIN    
		SELECT '1' AS ErrorCode, 'It looks like your mobile number('+ @custMobile +') is already registered with us.
		If you have forgotten your password  
		<a href="forgotpassword" style="color:blue;"><u> Click here</u> </a> to reset your password ' AS Msg  , '' Id 
		RETURN  
  END    
  SELECT '0' AS ErrorCode, 'Valid Mobile Number to register !' AS Msg  , '' Id
  
  INSERT INTO registrationEmailLogs(email,createdDate)  
	SELECT @CustEmail, GETDATE()  
  RETURN
END
 
 
 
 
 ELSE IF @flag = 'i'  
 BEGIN  
  IF @customerIdType IS NOT NULL  
   SELECT @customerIdType = VALUE FROM dbo.Split('|', @customerIdType) WHERE id = 1  
  
   

  IF EXISTS(SELECT 'X' FROM customerMaster with (nolock) WHERE email = @custEmail )  
  BEGIN  
   SELECT @errorMsg = 'Customer with email ' + @custEmail + ' already exist.'  
   EXEC proc_errorHandler 1, @errorMsg, @customerId 
   RETURN  
  END  

  IF EXISTS(SELECT 'X' FROM customerMaster with (nolock) WHERE replace(idNumber,'-','') = replace(@customerIdNo, '-', '') )  
  BEGIN  
   SELECT @errorMsg = 'Customer with idnumber ' + @customerIdNo + ' already exist.'  
   EXEC proc_errorHandler 1, @errorMsg, @customerId 
   RETURN  
  END

  IF EXISTS(SELECT 'X' FROM customerMaster with (nolock)  WHERE email = @custEmail and ISNULL(onlineUser, 'N')='Y' and isnull(isDeleted,'N')='N')  
  BEGIN  
   SELECT @errorMsg = 'Customer with email ' + @custEmail + ' already exist.'  
   EXEC proc_errorHandler 1, @errorMsg, @customerId  
   RETURN  
  END  
  
  -- check for customer with same Name and same DOB
  IF EXISTS(SELECT 'X' FROM customerMaster with (nolock)  
  WHERE fullName =ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '') 
  AND dob=@custDOB
  AND ISNULL(onlineUser, 'N')='Y' and isnull(isDeleted,'N')='N')
	BEGIN
		SELECT @errorMsg = 'It looks like you have already registered with GME. <br>
		Please contact us  on +02-3673-5559 or e-mail us at support@gmeremit.com for any assistance.'
		EXEC proc_errorHandler 1, @errorMsg, @customerId
		RETURN
	END
	
   DECLARE @verificationCode varchar(40)  
   SET @verificationCode = LEFT(NEWID(), 7);
	
   DECLARE @dob VARCHAR(30)
   SET @dob=dbo.FNAGETDOB_FROM_ALIENCARD(LEFT(@customerIdNo,6),RIGHT(LEFT(@customerIdNo,8),1));

   IF (SELECT detailTitle FROM staticDataValue(nolock) where valueId = @customerIdType) = 'passport'
   begin
		set @dob = @custDOB
   end
   else
   begin
		IF RIGHT(LEFT(@customerIdNo, 7), 1) <> '-'
		BEGIN  
			SELECT @errorMsg = 'Invalid Id number ' + @customerIdNo + ', your id number must be similar to XXXXXX-XXXXXXX(Include ''-'' also).'  
			EXEC proc_errorHandler 1, @errorMsg, @customerId 
			RETURN  
		END 
  end
   IF(ISDATE(@dob)=0) or @dob IS NULL
   BEGIN
		EXEC dbo.proc_errorHandler 1,'Invalid DOB found ',@customerId
	    RETURN;
   END
 
  IF @bankName IN(4,23)
  BEGIN
		SELECT @bankName = CASE WHEN LEFT(@bankAccountNo,3) IN ('351','352','356','355', '354','360','384','394','398', '398') THEN '23' ELSE '4' END
  END

  BEGIN TRANSACTION  
   INSERT INTO customerMaster (firstName,middleName  ,lastName1,lastName2  ,country  ,[address],state2,zipCode  ,district  
		,city  ,email  ,homePhone ,workPhone ,mobile ,nativeCountry,bankName  ,bankAccountNo,dob  ,placeOfIssue  ,occupation  
		,isBlackListed ,lastTranId  ,relationId  ,relativeName  ,gender  ,companyName  ,salaryRange  ,address2  ,fullName 
		,createdBy  ,createdDate  ,postalCode   ,idIssueDate  ,idExpiryDate  ,idType  ,idNumber  ,telNo  ,memberIDissuedDate  
		,memberIDissuedByUser,memberIDissuedAgentId,memberIDissuedBranchId,agentId,branchId,onlineUser,ipAddress,customerPassword  
		,customerType,howDidYouHear,ansText,isActive,marketingSubscription,isForcedPwdChange,verifyDoc1,verifyDoc2,verifyDoc3
		,SelfieDoc,referelCode,verificationCode,isEmailVerified
   )  
   SELECT  @firstName ,@middleName,@lastName1,@lastName2 ,118 ,@custAdd1 ,@state,ISNULL(@zipCode,@custPostal),@district  
		,@custCity,@custEmail,@customerIdNo,@workPhone,replace(@custMobile,'+',''),@custNativecountry,@bankName,@bankAccountNo,@dob  
		,@placeOfIssue,@occupation,@isBlackListed ,@lastTranId ,@relationId ,@relativeName ,@custGender,@companyName  
		,@custSalary,@custAdd2,ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')
		,ISNULL(@createdBy,@user),GETDATE(),@custPostal,@custIdissueDate,@custIdValidDate,@customerIdType  
		,@customerIdNo,@custTelNo  
		,CASE WHEN @isMemberIssued ='Y' THEN GETDATE() ELSE NULL END  
		,CASE WHEN @isMemberIssued ='Y' THEN @user ELSE NULL END  
		,CASE WHEN @isMemberIssued ='Y' THEN @agent  ELSE NULL END  
		,CASE WHEN @isMemberIssued ='Y' THEN @branch  ELSE NULL END  
		,@agent,@branch,'Y',@ipAddress,dbo.FNAEncryptString(@custPassword),'4700' ,@howDidYouHear,@ansText,@isActive,'Y' 
		, 0,@verifyDoc1,@verifyDoc2,@verifyDoc3,@SelfieDoc,@referralCode,@verificationCode,0
	
   SET @customerId = SCOPE_IDENTITY()  
  IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION  
  SELECT '0' ErrorCode , 'Record has been added successfully.' Msg , @verificationCode id, @customerId Extra  
 END  
 ELSE IF @flag = 'a'  
 BEGIN  
	--SELECT @mobile = CASE WHEN MOBILE LIKE '82%' THEN STUFF(MOBILE, 1, 2, '0') 
	--						WHEN MOBILE LIKE '+82%' THEN REPLACE(MOBILE,'+82','0')
	--						WHEN MOBILE NOT LIKE '0%' THEN '0' + MOBILE
	--						ELSE MOBILE
	--					END 
	--FROM customerMaster (NOLOCK) WHERE customerId = @customerId

	--IF LEN(@mobile) = 11
	--BEGIN
	--	SET @mobile = LEFT(@MOBILE, 3) + '-' + LEFT(RIGHT('01021641432', 8), 4) + '-' + RIGHT('01021641432', 4)
	--	SELECT @mobile = STUFF(@mobile, 5, 4, '****')
	--END
	--ELSE
	--BEGIN
	--	SELECT @mobile = STUFF(@mobile, 4, 4, '****')
	--END

  SELECT   
       [customerId]  
      ,isnull([membershipId],'') as [membershipId]  
      ,[firstName] = STUFF(firstName, 5, LEN(firstName) - 4, DBO.FNA_GET_ASTERISK(LEN(RIGHT(firstName, LEN(firstName)-4))))
      ,[middleName]  
      ,[lastName1]  
      ,CM2.countryName countryName
	  ,cm.country
      ,[address]  
      ,[state]  
      ,[district]  
      ,[city]  
      ,[email] = STUFF((SELECT value FROM DBO.Split('@', email) WHERE ID = 1), LEN((SELECT value FROM DBO.Split('@', email) WHERE ID = 1))-1, 2, '**') +'@'+ (SELECT value FROM DBO.Split('@', email) WHERE ID = 2) 
      ,[mobile]
	  ,CM3.countryName AS nativeCountryName
	  ,cm.nativeCountry 
	  ,cm.bankName AS bankId
	  ,bankAccountNo =  STUFF(bankAccountNo, LEN(bankAccountNo)-2, 3, '***') 
      ,[dob] = '**/**/****'
      ,[placeOfIssue]  
	  ,(SELECT svd.detailTitle FROM dbo.staticDataValue svd(nolock) WHERE svd.valueId=cm.occupation) AS [occupation] 
	  ,cm.occupation AS occupationId
      ,[relationId]  
      ,[relativeName]  
      ,[fullName]  
      ,(SELECT sd.detailTitle FROM dbo.staticDataValue sd(nolock) WHERE sd.valueId=cm.idType) AS [idType]  
	  ,cm.idType AS idTypeId
      ,idNumber = STUFF(idNumber, LEN(idNumber)-5, 6, '******') 
      ,(SELECT dv.detailTitle FROM dbo.staticDataValue dv(nolock) WHERE dv.valueId=cm.gender) AS gender  
	  ,gender AS genderId
      , CASE WHEN [onlineUser] = 'Y' THEN 'true' ELSE 'false' END [onlineUser]
      ,[lastLoginTs] = CONVERT(VARCHAR(10),[lastLoginTs], 101)  
      ,[idIssueDate] = CONVERT(VARCHAR(10),[idIssueDate], 101)
	  ,[idExpiryDate] = CONVERT(VARCHAR(10),[idExpiryDate], 101)
	  ,[verifyDoc1]
	  ,[verifyDoc2]
	  ,[verifyDoc3]
 FROM dbo.customerMaster cm (NOLOCK) 
 INNER JOIN dbo.countryMaster CM2 (NOLOCK) ON CM2.countryId = cm.country 
 INNER JOIN dbo.countryMaster CM3 (NOLOCK) ON CM3.countryId = cm.nativeCountry
 WHERE customerId=@customerId  
 AND isnull(onlineUser,'N')='Y'   
 AND isnull(islocked,'N')='N'  

 UNION ALL

 SELECT   
       [customerId] = '1'  
      ,[membershipId]   = '1'
      ,[firstName]   = '1'
      ,[middleName]   = '1'
      ,[lastName'1']   = '1'
      ,countryName = '1'
	  ,country = '1'
      ,[address] = '1'  
      ,[state]  = '1' 
      ,[district]   = '1'
      ,[city]   = '1'
      ,[email]  = '0' 
      ,[mobile] = '1'
	  ,nativeCountryName = '1'
	  ,nativeCountry  = '1'
	  ,bankId = '0'
	  ,[bankAccountNo]  = '0' 
      ,[dob] = '0'
      ,[placeOfIssue] = '1' 
	  ,[occupation]  = '1'
	  ,occupationId = '1'
      ,[relationId]  = '1' 
      ,[relativeName]  = '1' 
      ,[fullName]   = '1'
      ,[idType]   = '0'
	  ,idTypeId = '0'
      ,[idNumber] = '0'  
      ,gender   = '1'
	  ,genderId = '1'
      ,[onlineUser]   = 'true'
      ,[lastLoginTs]   = '1'
      ,[idIssueDate] = '0'
	  ,[idExpiryDate] = '0'
	  ,[verifyDoc1] = '0'
	  ,[verifyDoc2] = '0'
	  ,[verifyDoc3] = '0'
 END   

 ELSE IF @flag = 'getData'
 BEGIN
     SELECT varificationDoc = CASE WHEN @ImageId = '0' THEN CM.verifyDoc1 WHEN @ImageId = '1' THEN CM.verifyDoc2 ELSE CM.verifyDoc3 END
			,CM.idNumber 
	 FROM dbo.customerMaster CM (NOLOCK) 
	 WHERE CM.customerId = @customerId
	 return;
 END

 IF @flag='checkVerificationCode'
BEGIN
	DECLARE @isEmailVerified BIT 
	
	SELECT @isEmailVerified = isEmailVerified
	FROM dbo.customerMaster (NOLOCK) 
	WHERE customerId = @customerId 
	AND verificationCode = @verCode
	AND ISNULL(isDeleted, 'N') = 'N'
	
	IF @isEmailVerified IS NULL
	BEGIN
	    EXEC dbo.proc_errorHandler 1, 'Invalid data!', NULL
		RETURN;
	END
	ELSE
	BEGIN
	    IF @isEmailVerified = 1
		BEGIN
			EXEC dbo.proc_errorHandler 1, 'Already verified!', NULL
            RETURN
		END

		UPDATE dbo.customerMaster SET isEmailVerified=1 WHERE customerId=@customerId and verificationCode=@verCode
		EXEC dbo.proc_errorHandler 0, 'Verification successful!', NULL
		RETURN;
	END	
END


 ELSE IF @flag = 'u'  
 BEGIN  
  IF @customerIdType IS NOT NULL  
   SELECT @customerIdType = VALUE FROM dbo.Split('|', @customerIdType) WHERE id = 1 
  IF (YEAR(GETDATE()) - YEAR(@custDOB) < 16)   
  BEGIN  
 EXEC proc_errorHandler 1, 'Customer Not Eligible', @customerId  
   RETURN  
  END  

  IF EXISTS(SELECT 'X' FROM customerMaster WHERE customerId <> @customerId AND membershipId = @memberId AND ISNULL(isDeleted, 'N') <> 'Y')  
  BEGIN  
   EXEC proc_errorHandler 1, 'Membership Id already in use', @customerId  
   RETURN  
  END  
  
  IF EXISTS(SELECT 'X' FROM customerMaster WHERE customerId <> @customerId AND mobile = @mobile AND ISNULL(isDeleted, 'N') <> 'Y')  
  BEGIN  
   SELECT @errorMsg = 'Customer with mobile number ' + @mobile + ' already exist'  
   EXEC proc_errorHandler 1, @errorMsg, @customerId  
   RETURN  
  END    

IF (@firstName IS NOT NULL AND @firstName != '')
BEGIN
	SET @columnName = 'firstName'
	SET @value = @firstName
END
IF (@gender IS NOT NULL AND @gender != '')
BEGIN
	SET @columnName = 'gender'
	SET @value = @gender
END
IF (@occupation IS NOT NULL AND @occupation != '')
BEGIN
	SET @columnName = 'occupation'
	SET @value = @occupation
END
ELSE IF (@custDOB IS NOT NULL AND @custDOB != '')
BEGIN
	SET @columnName = 'dob'
	SET @value =@custDOB
END
ELSE IF (@custAdd1 IS NOT NULL AND @custAdd1 != '')
BEGIN
	SET @columnName = '[address]'
	SET @value =@custAdd1
END
ELSE IF (@custCity IS NOT NULL AND @custCity != '')
BEGIN
	SET @columnName = 'city'
	SET @value =@custCity
END
ELSE IF (@country IS NOT NULL AND @country != '')
BEGIN
	SET @columnName = 'country'
	SET @value =@country
END
ELSE IF (@custNativecountry IS NOT NULL AND @custNativecountry != '')
BEGIN
	SET @columnName = 'nativeCountry'
	SET @value =@custNativecountry
END
ELSE IF (@bankName IS NOT NULL AND @bankName != '')
BEGIN
	SET @columnName = 'bankName'
	SET @value =@bankName
END
ELSE IF (@bankAccountNo IS NOT NULL AND @bankAccountNo != '')
BEGIN
	SET @columnName = 'bankAccountNo'
	SET @value =@bankAccountNo
END
ELSE IF (@customerIdType IS NOT NULL AND @customerIdType != '')
BEGIN
	SET @columnName = 'idType'
	SET @value =@customerIdType
END
ELSE IF (@customerIdNo IS NOT NULL AND @customerIdNo != '')
BEGIN
	SET @columnName = 'idNumber'
	SET @value =@customerIdNo
END
ELSE IF (@custIdissueDate IS NOT NULL AND @custIdissueDate != '')
BEGIN
	SET @columnName = 'idIssueDate'
	SET @value =@custIdissueDate
END
ELSE IF (@custIdValidDate IS NOT NULL AND @custIdValidDate != '')
BEGIN
	SET @columnName = 'idExpiryDate'
	SET @value =@custIdValidDate
END
ELSE IF (@ImageId='0')
BEGIN
	SET @columnName = 'verifyDoc1'
	SET @value =@ImagePath
END
ELSE IF (@ImageId='1')
BEGIN
	SET @columnName = 'verifyDoc2'
	SET @value =@ImagePath
END
ELSE IF (@ImageId='2')
BEGIN
	SET @columnName = 'verifyDoc3'
	SET @value =@ImagePath
END


BEGIN TRANSACTION  
DECLARE @sqlQuery VARCHAR(100) = 'UPDATE dbo.customerMaster SET '+@columnName+' = '''+@value+''' WHERE customerId = '+@customerId
--PRINT @sqlQuery
EXEC(@sqlQuery)
  -- UPDATE dbo.customerMaster SET
  --    firstName  = @firstName  
  --   ,middleName  = @middleName  
  --   ,lastName1  = @lastName1  
  --   ,lastName2  = @lastName2  
  --   ,country  = @country  
  --   ,[address]  = @custAdd1  
  --   ,[STATE2]  = @state  
  --   ,zipCode  = @zipCode  
  --   ,district  = @district  
  --   ,city   = @custCity  
  --   ,homePhone  = CASE WHEN @homePhone like '%XXX%' THEN homePhone ELSE @homePhone END   
  --   ,workPhone  = CASE WHEN @workPhone like '%XXX%' THEN workPhone ELSE @workPhone END   
  --   ,mobile   = CASE WHEN @custMobile like '%XXX%' THEN mobile ELSE @custMobile END   
  --  ,nativeCountry = @custNativecountry  
	 --,idType=@customerIdType
	 --,idNumber=@customerIdNo
	 --,bankName=@bankName
	 --,bankAccountNo=@bankAccountNo
  --   ,dob   = @custDOB  
  --   ,placeOfIssue = @placeOfIssue  
  --   ,occupation  = @occupation  
  --   ,isBlackListed = @isBlackListed     
  --   ,lastTranId  = @lastTranId  
  --   ,relationId  = @relationId  
  --   ,relativeName = @relativeName  
  --   ,gender   = @custGender  
  --   ,companyName = @companyName  
  --   ,salaryRange = @custSalary  
	 --,address2  = @custAdd2  
  --   ,fullName  = ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')     
  --   ,modifiedBy  = @user  
  --   ,modifiedDate = Dateadd(HH,0,Getutcdate())--GETDATE()  
  --   ,postalCode  = @custPostal  
  --   ,idIssueDate = @custIdissueDate  
  --   ,idExpiryDate = @custIdValidDate  
  --   ,telNo   = CASE WHEN @custTelNo like '%XXX%' THEN telNo ELSE @custTelNo END  
  --   ,membershipId  =  @memberId  
  --   ,memberIDissuedDate  = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedDate IS NULL THEN GETDATE() ELSE memberIDissuedDate END  
  --   ,memberIDissuedByUser = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedByUser IS NULL THEN @user ELSE memberIDissuedByUser END  
  --   ,memberIDissuedAgentId = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedAgentId IS NULL THEN @agent ELSE memberIDissuedAgentId END  
  --   ,memberIDissuedBranchId = CASE WHEN @isMemberIssued ='Y' AND memberIDissuedBranchId IS NULL THEN @branch ELSE memberIDissuedAgentId END 
	 --,verifyDoc1 = @verifyDoc1
	 --,verifyDoc2 = @verifyDoc2
	 --,verifyDoc3=@verifyDoc3
  -- WHERE customerId = @customerId  


   --EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @customerId, @newValue OUTPUT  
   INSERT INTO #msg(errorCode, msg, id)     
   EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @customerId, @user, @oldValue, @newValue  
   IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')  
   BEGIN  
    IF @@TRANCOUNT > 0  
    ROLLBACK TRANSACTION  
    EXEC proc_errorHandler 1, 'Failed to update record.', @customerId   
    RETURN  
   END  
  IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION  
  SELECT '0' errCode , 'Record updated successfully.' msg , @customerId id  
 END 
 

END TRY  
BEGIN CATCH  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE() 
     EXEC proc_errorHandler 1, @errorMessage, @customerId  
END CATCH




GO
