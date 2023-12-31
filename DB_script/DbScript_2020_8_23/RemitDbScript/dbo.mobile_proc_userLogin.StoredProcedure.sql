USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_userLogin]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[mobile_proc_userLogin]
  @flag    		VARCHAR(30)  
 ,@userName   	VARCHAR(100) = NULL     
 ,@Password   	VARCHAR(100) = NULL   
 ,@Imei    		VARCHAR(256) = NULL --Imei Number of Mobile  
 ,@accessCode  	VARCHAR(MAX) = NULL -- access token used in every request  
 ,@scope    	VARCHAR(50)  = NULL --for mobile applicatin, @scope='mobile_app'  
 ,@clientId     VARCHAR(200) = NULL  
 ,@customerId  	VARCHAR(100) = NULL  
  
AS  
BEGIN TRY   
	SET NOCOUNT ON;  
	SET XACT_ABORT ON;  
	DECLARE  
		@UserData    		VARCHAR(200)  
		,@UserInfoDetail  	VARCHAR(MAX)   
		,@AccessCodeExpiresAfter INT = 5 --Minutes  
		,@email     		VARCHAR(100)  
		,@mobile    		VARCHAR(100)  
		,@customerPwd   	VARCHAR(50)  
		,@isActive    		CHAR(1)    
		,@isEmailVerified   BIT   
		,@approvedDate      DATETIME  
  ----------------------- Local variables declaration ###STARTS------------------------  
	DECLARE   
		@_imei    			VARCHAR(256)  
		,@_otpUsed   		BIT  
		,@_scope   			VARCHAR(50)  
		,@_isDeleted  		CHAR(1)  
		,@_errorMsg   		VARCHAR(MAX)  
		,@_isExists   		BIT=0  
		,@_Otp    			VARCHAR(50)  
		,@_accessCode  VARCHAR(MAX)  
		,@_accessCodeExpiry DATETIME  
		,@_errorCode  VARCHAR(20)  
		,@_lastLoggedInDevice VARCHAR(200)  
		,@previousAccessCode VARCHAR(MAX)  
   
 ----------------------- Local variables declaration ###ENDS------------------------  
 -- Check This Customer Infoagree State 
	IF @flag = 'check-agree'  
	BEGIN  
		IF EXISTS(SELECT TOP 1 'X' FROM CustomerMasterTemp(NOLOCK) WHERE username = @userName AND ISNULL(agreeYn, '0') = '0' )  
		BEGIN   
			SELECT 0 ErrorCode,'Get PDF List Success About Agree infomation' Msg, NULL Id, rowId, PdfName, AgreePdfPath     
			FROM customerAgreeDocumentTbl (NOLOCK)       
			WHERE targetObj = 'STAGING'
			
			RETURN
		END
		ELSE IF EXISTS(SELECT TOP 1 'X' FROM CustomerMaster(NOLOCK) WHERE email = @userName AND ISNULL(agreeYn, '0') = '0' )  
		BEGIN   
			SELECT 0 ErrorCode,'Get PDF List Success About Agree infomation' Msg, NULL Id, rowId, PdfName, AgreePdfPath      
			FROM customerAgreeDocumentTbl(NOLOCK)       
			WHERE targetObj = 'STAGING'	  
			
			RETURN
		END  
		ELSE
		BEGIN
			SELECT 1 ErrorCode,'Invaild user.. Check user value ' Msg, NULL Id
		END
	END
	ELSE IF @flag='l' -- login to system(done)  
	BEGIN  
		IF ISNULL(@username,'')=''  
	BEGIN  
		SELECT '1' ErrorCode, 'User Id not defined.' Msg ,NULL ID  
		RETURN  
	END  
    
	SELECT @scope=dbo.mobile_FNAGetApplicationScope(@clientId)  
  
	IF ISNULL(@scope,'')<>'mobile_app'  
	BEGIN  
		SELECT '1' ErrorCode, 'Application scope is not valid for this user.' Msg ,NULL ID  
		RETURN  
	END  
  
	SET @UserData ='User: '+ @username + ' ,Password: ' + @Password + ' ,User Type:Mobile User' +' ,Device Info:'+@imei  
    
	DECLARE @isReferred BIT=0  
	IF EXISTS(SELECT TOP 1 'x' FROM referralmaster(NOLOCK) WHERE email = @userName OR mobile = @userName)  
		SET @isReferred=1  
    
	SELECT   
		@_lastLoggedInDevice=lastLoggedInDevice  
		,@_accessCodeExpiry=accessCodeExpiry  
		,@_accessCode=accessCode  
	FROM 	dbo.mobile_userRegistration(NOLOCK)  
	WHERE	username = @userName  
  
	IF ISNULL(@accessCode,'') = ''  
	BEGIN  
		SELECT '1' ErrorCode, 'Invalid Access code found!' Msg ,NULL ID  
		RETURN  
	END  
  
  --IF @_lastLoggedInDevice = @Imei AND @_accessCodeExpiry > GETDATE()  
  --BEGIN  
  -- SET @accessCode=@_accessCode      
  -- UPDATE mobile_userRegistration SET   
  --  accessCodeExpiry = DATEADD(MINUTE,@AccessCodeExpiresAfter,GETDATE()) --adding validity of access token for 20 minutes.  
  -- FROM dbo.mobile_userRegistration(NOLOCK) ur  
  -- WHERE ur.username = @userName  
  --END  
  --ELSE  
  
	DECLARE  @GmeclientId VARCHAR(50)  
    
	SELECT  @GmeclientId = DBO.DECRYPTDB(clientId) FROM  KFTC_GME_MASTER (NOLOCK)   
	BEGIN  
		BEGIN TRANSACTION      
		UPDATE 	mobile_userRegistration 
		SET		accessCode = @accessCode  
				,accessCodeExpiry = DATEADD(MINUTE,@AccessCodeExpiresAfter,GETDATE()) --adding validity of access token for 20 minutes.  
				,lastLoggedInDevice = @Imei       
		FROM 	dbo.mobile_userRegistration(nolock)  
		WHERE 	username = @userName  

		IF @@TRANCOUNT>0  
			COMMIT TRANSACTION   
		END  
  
		DELETE T FROM customerMaster(NOLOCK)c  
		INNER JOIN CustomerMasterTemp t ON c.email=t.email  
		AND C.email = @userName  

		DECLARE @redirectTo VARCHAR(100) = ''  

		IF EXISTS(SELECT TOP 1 'X' FROM customerMasterTemp cm(NOLOCK) WHERE cm.username=@userName AND cm.customerPassword = dbo.FNAEncryptString(@Password))  
		BEGIN    
			SELECT   
				'0' ErrorCode  
				,@scope scope  
				,@userName userId  
				,cust.customerId SenderId  
				,ISNULL(cust.firstName,'') firstName  
			-- ,ISNULL(cust.middleName,'') middleName  
			-- ,ISNULL(cust.lastName1,'') lastName  
			-- ,ISNULL(cust.nickName,'') nickName  
				,ISNULL(cust.email,'') email  
				,ISNULL(cust.customerEmail,'') customerEmail  
				,ISNULL(cust.mobile,'') phone  
			-- ,cust.idType AS idType  
				--,cust.idNumber AS idNumber  
				,cm.countryCode AS countryCode  
			-- ,CAST(ISNULL(cust.bonusPoint,0) AS DECIMAL) rewardPoint  
				,CASE WHEN ISNULL(cust.isActive,'Y')='Y' THEN 1 ELSE 0 END active  
				,kyc = 0  
				,CASE WHEN ISNULL(cust.verifiedDate,'')<>'' THEN 1 ELSE 0 END verified  
				,ISNULL(cust.walletAccountNo,'') walletNumber  
				,0 availableBalance  
				,'Fast Remit Bank' primaryBankName  
			-- ,'' primaryBankAccount  
				,@accessCode accessCode  
				,DATEDIFF(SS,GETDATE(),ur.accessCodeExpiry) expiresIn  
				-- ,ISNULL(dpUrl,'') dpUrl  
				-- ,ISNULL(ur.cmRegistrationId,'') cmRegistrationId  
				,'' country  
				,ISNULL(cust.city,'') city  
				,ISNULL(cust.[address],'') [address]  
				-- ,ISNULL(cust.state2,'') [province]  
				,'' [provinceId]  
				-- ,@isReferred isReferred  
				,'' sourceId  
				,yearlyLimit=0  
				,'0' AS pennyTestStatus  
				,gmeClientId = @GmeclientId  
				,redirectTo = @redirectTo  
				,customerType
			FROM (SELECT TOP 1 * FROM customerMasterTemp(NOLOCK) cust WHERE cust.username = @userName)cust
			LEFT JOIN mobile_userRegistration(NOLOCK) ur ON cust.customerId=ur.customerId   
			LEFT JOIN dbo.countryMaster(NOLOCK) AS CM ON cm.countryId=cust.nativeCountry  
			--WHERE cust.username=@userName  

			EXEC proc_applicationLogs @flag='login',@logType='Login Success', @createdBy = @username, @Reason='Login',@UserData = @UserData,@fieldValue = @UserInfoDetail   
 
			RETURN  
		END  
  
		SELECT   
		   @email   = email,  
		   @mobile   = cm.mobile,  
		   @customerPwd = customerPassword,  
		   @isActive  = isactive,   
		   @customerId  = cm.customerId,  
		   @approvedDate = cm.approvedDate,  
		   @customerId  = cm.customerId  
		FROM customerMaster (NOLOCK)cm  
		WHERE cm.email = @userName   
		--OR cm.mobile=@userName ## NOT MOBILE LOGIN NOT APPLICABLE  
		AND cm.customerPassword = dbo.FNAEncryptString(@Password)   
		AND cm.onlineUser='Y'   

		IF @email IS NULL   
		BEGIN  
			SELECT 1 errorCode, 'The username/password do not match.' msg, @username id   
			SET @UserInfoDetail = 'Reason = Incorrect username.'  
			EXEC dbo.proc_applicationLogs   
				@flag='login',  
				@logType='Login fails',   
				@createdBy = @username,   
				@Reason='Invalid Username',  
				@UserData = @UserData,  
				@fieldValue = @UserInfoDetail  
			RETURN  
		END  
  
		BEGIN TRANSACTION   
		IF NOT EXISTS(SELECT TOP 1 'X' FROM mobile_userRegistration ur(NOLOCK) WHERE ur.username = @userName)  
		BEGIN  
			INSERT INTO mobile_userRegistration (customerId,username, OTP,OTP_Used,createdDate,IMEI,clientId)  
			SELECT @customerId,@userName,0,0,GETDATE(),@Imei,@clientId  

			UPDATE cm SET cm.isEmailVerified=1  
			FROM dbo.customerMaster cm WHERE cm.customerId=@customerId  
		END 
	
		IF @@TRANCOUNT>0  
			COMMIT TRANSACTION   
	
		DECLARE @attemptsCount INT  
		SELECT TOP 1 @attemptsCount = loginAttemptCount FROM passwordFormat WITH(NOLOCK)  

		IF  (ISNULL(@isActive, 'Y') = 'N')  
		BEGIN  
			SELECT 1 errorCode, 'Your account is Inactive. Please, contact GME Support Team.' msg, @userName id  
			SET @UserInfoDetail = 'Reason = Login fails, Your account is Inactive. Please, contact your administrator.'  
			EXEC proc_applicationLogs   
				@flag='login',  
				@logType='Login fails',   
				@createdBy = @userName,   
				@Reason='User is not active ',  
				@UserData = @UserData,  
				@fieldValue = @UserInfoDetail  
			RETURN    
		END  
  
		UPDATE customerMaster 
		SET    lastLoginTs = GETDATE()  
		WHERE  customerId=@customerId  
		
		DECLARE @yearlyLimit VARCHAR(100)=''  
		DECLARE @totalSend MONEY, @totalSendText VARCHAR(200), @YearStart DATE, @YearEnd DATETIME  
	  
		SELECT 	@YearStart = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)  
				,@YearEnd = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)+' 23:59:59'  
  
		SELECT @totalSend = SUM(ROUND(R.cAmt/(R.sCurrCostRate + ISNULL(R.sCurrHoMargin, 0)), 2, 0))  
		FROM REMITTRAN R(NOLOCK)   
		INNER JOIN TRANSENDERS T(NOLOCK) ON T.TRANID = R.ID  
		AND T.CUSTOMERID = @customerId   
		AND R.TRANSTATUS <> 'Cancel'  
		AND R.approvedDate BETWEEN @YearStart AND @YearEnd  

		SELECT @yearlyLimit = amount  
		FROM dbo.csDetail CD(NOLOCK)  
		INNER JOIN csMaster CM(NOLOCK) ON CM.csMasterId = CD.csMasterId   
		AND CD.period = 365  
		AND CD.condition = 4600  
		AND ISNULL(CD.isActive, 'Y') = 'Y'   
		AND ISNULL(CD.isDeleted, 'N') = 'N'  
		AND ISNULL(CD.isEnable, 'Y') = 'Y'  
		AND ISNULL(CM.isActive, 'Y') = 'Y'  
		AND ISNULL(CM.isDeleted, 'N') = 'N'  
	  
		SET @yearlyLimit = (@yearlyLimit - ISNULL(@totalSend, 0))  

		DECLARE @hasPennyTestDone VARCHAR(1)='1'  
		
		IF EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(NOLOCK) WHERE approvedDate < '2018-12-19' AND customerId = @customerId)  
		BEGIN  
			SET @hasPennyTestDone = '2'  
		END    
		
		IF NOT EXISTS(SELECT TOP 1 'x' FROM dbo.KFTC_CUSTOMER_MASTER(NOLOCK) WHERE customerId = @customerId)   
		AND EXISTS(SELECT TOP 1 'x' FROM customerMaster(nolock) WHERE @customerId=@customerId AND ISNULL(IsKftcOnly,'N') = 'Y')  
		BEGIN  
			SET @redirectTo = 'autodebit'  
		END  
    
		SELECT   
		'0' ErrorCode  
		,@scope scope  
		,@userName userId  
		,cust.customerId SenderId  
		,ISNULL(cust.firstName,'') firstName  
		-- ,ISNULL(cust.middleName,'') middleName  
		-- ,ISNULL(cust.lastName1,'') lastName  
		-- ,'' nickName  
		,ISNULL(cust.email,'') email  
		,ISNULL(cust.customerEmail,'') customerEmail  
		,ISNULL(cust.mobile,'') phone  
		-- ,cust.idType AS idType  
		--,cust.idNumber AS idNumber  
		,cm1.countryCode AS countryCode  
		,CAST(ISNULL(cust.bonusPoint,0) AS DECIMAL) rewardPoint  
		,CASE WHEN ISNULL(cust.isActive,'Y')='Y' THEN 1 ELSE 0 END active  
		,CASE WHEN ISNULL(cust.createdDate,'')<>'' THEN 1 ELSE 0 END kyc  
		,CASE WHEN ISNULL(cust.verifiedDate,'')<>'' THEN 1 ELSE 0 END verified  
		,ISNULL(cust.walletAccountNo,'') walletNumber  
		,CAST([dbo].FNAGetCustomerACBal(@email) AS DECIMAL) availableBalance  
		--,ISNULL(bl.BankName,'') primaryBankName  
		,primaryBankName='Fast Remit Bank'--CASE WHEN cust.customerType='11048' THEN 'Mutual savings bank' ELSE 'Kwangju Bank (034)' END  
		-- ,'' AS primaryBankAccount  
		,@accessCode accessCode  
		,DATEDIFF(SS,GETDATE(),ur.accessCodeExpiry) expiresIn  
		-- ,'' dpUrl  
		-- ,ISNULL(ur.cmRegistrationId,'') cmRegistrationId  
		,ISNULL(co.countryName,'') country  
		,ISNULL(cust.city,'') city  
		,ISNULL(cust.[address],'') [address]  
		-- ,ISNULL(cust.state2,'') [province]  
		,ISNULL(cm.cityId,'') [provinceId]  
		-- ,@isReferred isReferred  
		,ISNULL(sdv.valueId,'') sourceId  
		,yearlyLimit=@yearlyLimit  
		,PennyTestStatus=@hasPennyTestDone-----0 not started, 1 requested , 2 completed  
		, gmeClientId = @GmeclientId  
		,redirectTo = @redirectTo  
		,customerType
		FROM (SELECT TOP 1 * FROM customerMaster(NOLOCK) cust   WHERE cust.customerId=@customerId)cust  
		INNER JOIN dbo.countryMaster AS CM1 ON cm1.countryId=cust.nativeCountry
		LEFT JOIN mobile_userRegistration(NOLOCK) ur ON cust.customerId=ur.customerId   
		LEFT JOIN dbo.vwBankLists (NOLOCK) bl ON cust.bankName=bl.bankCode  
		LEFT JOIN countryMaster co(NOLOCK) ON cust.country=co.countryId  
		LEFT JOIN staticDatavalue sdv(NOLOCK) ON cust.sourceOfFund=sdv.detailTitle AND ISNULL(sdv.IS_DELETE,'N')='N'
		LEFT JOIN dbo.CityMaster cm(NOLOCK) ON cust.state2 = cm.cityName
		--WHERE cust.customerId=@customerId AND ISNULL(sdv.IS_DELETE,'N')='N'  

		EXEC proc_applicationLogs   
			@flag='login',  
			@logType='Login Success',   
			@createdBy = @username,   
			@Reason='Login',  
			@UserData = @UserData,  
			@fieldValue = @UserInfoDetail  

		RETURN  
	END  
	ELSE IF @flag='chk-access-code' --validating access code(done)  
	BEGIN  
		--SELECT   
		--  @_accessCodeExpiry=l.accessCodeExpiry  
		-- ,@username=ISNULL(l.username,cust.email)  
		-- ,@_scope=ISNULL(a.scope,'')  
		-- ,@_lastLoggedInDevice=ISNULL(cust.lastLoggedInDevice,'')  
		-- ,@_imei =ISNULL(cust.lastLoggedInDevice,'')  
		--FROM customermasterTemp(NOLOCK) cust  
		--INNER JOIN customermaster(NOLOCK) main ON main.customerId=cust.customerMasterId  
		--LEFT JOIN mobile_userRegistration(NOLOCK) l ON cust.customerId=l.customerId   
		--INNER JOIN mobile_GmeApiClientRegistration a(NOLOCK) ON a.clientId=l.clientId  
		--WHERE l.accessCode=@accessCode   
    
		SELECT   
			@_accessCodeExpiry=MUR.accessCodeExpiry  
			,@username= mur.username  
			,@_scope=ISNULL(a.scope,'')  
			,@_lastLoggedInDevice=mur.lastLoggedInDevice  
			,@_imei = mur.IMEI  
			,@customerId = mur.rowId  
		FROM dbo.mobile_userRegistration AS MUR(NOLOCK)  
		INNER JOIN mobile_GmeApiClientRegistration a(NOLOCK) ON a.clientId=MUR.clientId  
		AND MUR.accessCode = @accessCode   
		AND (mur.IMEI = @Imei OR mur.lastLoggedInDevice=@Imei)  
  
  
		--PRINT @_accessCodeExpiry  

		--IF NOT EXISTS(SELECT 'x' FROM dbo.mobile_userRegistration AS MUR WHERE MUR.accessCode=@accessCode AND MUR.IMEI=@Imei)  
		--BEGIN  
		-- SELECT '2' errorCode, 'Access code expired..' Msg ,NULL ID  
		-- RETURN  
		--END  

		--IF NOT EXISTS(SELECT 'x' FROM dbo.mobile_userRegistration AS MUR WHERE MUR.accessCode=@accessCode AND MUR.lastLoggedInDevice=@Imei)  
		--BEGIN  
		-- SELECT '2' errorCode, 'Access code expired..' Msg ,NULL ID  
		-- RETURN  
		--END  
  
		IF ISNULL(@username,'')='' AND ISNULL(@_lastLoggedInDevice,'') = @imei  
		BEGIN  
		   SELECT '2' errorCode, 'Access code expired..' Msg ,NULL ID  
		   RETURN  
		END  
  
		IF ISNULL(@username,'')='' AND ISNULL(@_lastLoggedInDevice,'') <> @imei  
		BEGIN  
			SELECT '1' errorCode, 'Access code expired..' Msg ,NULL ID  
			RETURN  
		END  
  
		IF (@_accessCodeExpiry < GETDATE())  
		BEGIN  
			SELECT '2' errorCode, 'It seems like you are using old access code. Please use newly generated access code.' Msg ,NULL ID  
			RETURN   
		END   

  ------------- ### Check if the user trying to validate access-code exists or not ###STARTS------------  
  
		IF @username IS NULL   
		BEGIN  
			SELECT @_errorMsg = 'User with contact Info ' + @username + ' doesnot exists. If you are a new user, then sign up and proceed further.'   
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID  
			RETURN    
		END  
  
  ------------- ### Check if the user trying to validate access-code exists or not ###ENDS------------  
		IF @_lastLoggedInDevice <> @Imei  
		BEGIN  
			SELECT '1' errorCode, 'You are logged in from another device.' Msg ,NULL ID  
			RETURN  
		END  

		ELSE IF ISNULL(@_scope,'')<>'mobile_app'  
		BEGIN  
			SELECT '1' ErrorCode, 'Application scope is not valid for this user.' Msg ,NULL ID  
			RETURN  
		END  

		UPDATE mobile_userRegistration 
		SET    accessCodeExpiry = DATEADD(MINUTE,@AccessCodeExpiresAfter,GETDATE()) --expiry time for access code(token) increased to 20 minutes.  
		WHERE  rowId = @customerId  

		SELECT '0' ErrorCode, 'Success' Msg ,@_scope ID  
		RETURN  
	END  
	ELSE IF @flag='s-accesscode' --validating accessCode for "Get user by access code"  
	BEGIN  
		IF @scope<>'social_comp'  
		BEGIN  
			SELECT '1' ErrorCode, 'Application scope is not valid for this user.' Msg ,NULL ID  
			RETURN  
		END  
  
		DECLARE @user VARCHAR(100);  
		SELECT   
			@email=cm.email,  
			@mobile=cm.mobile,  
			@isEmailVerified=cm.isEmailVerified,  
			@customerId=cm.customerId  
		FROM dbo.customerMaster(NOLOCK) cm  
		INNER JOIN dbo.mobile_userRegistration(NOLOCK) ur  
		ON cm.customerId=ur.customerId  
		AND ur.accessCode=@accessCode  
  
		IF @email IS NOT NULL AND @isEmailVerified=1  
		BEGIN  
			SET @user=@email  
		END  
		ELSE  
		BEGIN   
			SET @user=@mobile  
		END  
  
		SELECT   
			@_imei=l.imei  
			,@_accessCodeExpiry=l.accessCodeExpiry  
			,@username= @user  
		FROM customermaster cust (NOLOCK)    
		INNER JOIN mobile_userRegistration l(NOLOCK) ON cust.customerId=l.customerId   
		AND l.accessCode=@accessCode   

		IF DATEDIFF(MINUTE, GETDATE() ,@_accessCodeExpiry)>0  
		BEGIN  
			SELECT   
			'0' ErrorCode  
			,@userName userId  
			,ISNULL(cust.firstName,'') firstName  
			,ISNULL(cust.middleName,'') middleName  
			,ISNULL(cust.lastName1,'') lastName  
			,ISNULL(cm.countryName,'') nativeCountry  
			,'' nickName  
			,userRoles=''  
			,'' dpUrl  
			,ISNULL(ur.cmRegistrationId,'') cmRegistrationId  
			,ISNULL(ur.IMEI,'') uuid  
			FROM (SELECT TOP 1 * FROM customerMaster(NOLOCK) cust WHERE cust.customerId=@customerId)cust
			LEFT JOIN mobile_userRegistration ur(NOLOCK) ON cust.customerId=ur.customerId   
			LEFT JOIN dbo.countryMaster cm(NOLOCK) ON cust.nativeCountry=cm.countryId  
			--WHERE cust.customerId=@customerId  
			--WHERE cust.email=@userName OR cust.mobile=@userName  
			
			RETURN  
        END  
		ELSE IF DATEDIFF(MINUTE, GETDATE() ,@_accessCodeExpiry)<=0  
		BEGIN  
			SELECT '1' ErrorCode, 'Access code expired.' Msg ,NULL ID  
			RETURN  
		END  
		ELSE  
		BEGIN  
			SELECT '1' ErrorCode, 'Access code does not match.' Msg ,NULL ID  
			RETURN  
		END  
	END   
	ELSE IF @flag='ckeck-guid'  
	BEGIN  
		IF EXISTS(SELECT TOP 1 'A' FROM dbo.mobile_userRegistration(NOLOCK) WHERE accessCode IS NULL AND username = @userName )  
		BEGIN  
			UPDATE dbo.mobile_userRegistration SET accessCode = @accessCode WHERE accessCode IS NULL AND username = @userName  
		END  
  
		IF EXISTS(SELECT TOP 1 'A' FROM dbo.mobile_userRegistration(NOLOCK) WHERE accessCode = @accessCode AND username = @userName )  
		BEGIN  
			SELECT '0' ErrorCode, 'The access code is valid and is from trusted customer.' Msg, NULL Id  
			RETURN  
		END  
		
		BEGIN  
		SELECT '1' ErrorCode, 'No such access code found in system. Invalid username and customer is not trusted.' Msg, NULL Id  
		RETURN  
		END  
	END  
	ELSE IF @flag='get-device'  
	BEGIN  
		SELECT deviceId FROM mobile_userRegistration(NOLOCK) WHERE customerId = @customerId  
		RETURN  
	END  
	ELSE IF @flag='agentDetail'  
	BEGIN  
		SELECT  agentId,
				agentName,
				agentState,
				agentCity,
				agentAddress,
				agentZip,
				agentPhone1
		FROM AGENTMASTER (NOLOCK)
		WHERE PARENTID = 394399
		AND ACTASBRANCH = 'Y'
		RETURN  
	END  
END TRY  
BEGIN CATCH  
	IF @@TRANCOUNT > 0    
		ROLLBACK TRANSACTION    
	DECLARE @errorMessage VARCHAR(MAX)    
	SET @errorMessage = ERROR_MESSAGE()   
	SELECT '1' ErrorCode, @errorMessage Msg ,NULL ID  
END CATCH  
  
  
  
GO
