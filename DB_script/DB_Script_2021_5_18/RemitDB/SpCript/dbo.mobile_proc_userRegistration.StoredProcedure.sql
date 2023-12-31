USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_userRegistration]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[mobile_proc_userRegistration]	
	@flag				VARCHAR(30)
	,@MSISDN			VARCHAR(20)			= NULL	--Mobile Number 
	,@email				VARCHAR(100)	= NULL
	,@code				VARCHAR(50)		= NULL	--one time password
	,@codeType			VARCHAR(30)		= NULL	--one time password
	,@userName			VARCHAR(100)	= NULL			
	,@Password			VARCHAR(100)	= NULL			
	,@newPassword		VARCHAR(100)	= NULL	
	,@Imei				VARCHAR(256)	= NULL	--Imei Number of Mobile	
	,@appVersion		VARCHAR(100)	= NULL 
	,@deviceId			VARCHAR(100)	= NULL 
	,@osVersion			VARCHAR(100)	= NULL 
	,@phoneBrand		VARCHAR(100)	= NULL 
	,@phoneOs			VARCHAR(100)	= NULL
	,@scope				VARCHAR(50)		= NULL
	,@clientId			VARCHAR(100)	= NULL
	,@answer			DATE			= NULL --password secutiry question applies for the dob
	,@refWalletAccNo    VARCHAR(50)		= NULL
	,@cmRegistrationId  VARCHAR(MAX)    = NULL
	,@dpUrl             VARCHAR(300)    = NULL

AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;
BEGIN TRY
	IF ISNULL(@username,'')=''
	BEGIN
		SELECT '1' ErrorCode, 'User Id not defined.' Msg ,NULL ID
		RETURN
	END

	IF ISNULL(@scope,'')<>'mobile_app'
	BEGIN
		SELECT '1' ErrorCode, 'Application scope is not valid for this user.' Msg ,NULL ID
		RETURN
	END

	----------------------- Local variables declaration ###STARTS------------------------

	DECLARE @_customerId			BIGINT
			,@_imei					VARCHAR(256)
			,@_otpUsed				BIT
			,@_scope				VARCHAR(50)
			,@_isDeleted			CHAR(1)
			,@_errorMsg				VARCHAR(MAX)
			,@_isExists				BIT=0
			,@_Otp					VARCHAR(50)
			,@_pwdRecoveryCode		VARCHAR(50)
			,@_dob					DATE
			,@_errorCode			VARCHAR(50)
			,@_isVerified			BIT=0
			,@_password				VARCHAR(50)
			,@_createdDate			DATETIME
			,@_count				INT
			,@_onlineUser           CHAR(1)
			,@_createdBy            VARCHAR(100)
	
	----------------------- Local variables declaration ###ENDS------------------------

	
	IF @flag='signup' --first time user create(DONE)
	BEGIN
		------------- ### Check if the user trying to signup is already exists ###STARTS------------

		IF EXISTS(
			SELECT 'x' FROM dbo.customerMaster(NOLOCK) cm
			WHERE cm.email=@userName OR cm.mobile=@userName
		)
		BEGIN	
			SELECT '1' ErrorCode , @userName +' already exists' Msg ,@userName ID  	
			RETURN;	
		END 

		IF EXISTS(
			SELECT 'x' FROM dbo.customerMasterTemp(NOLOCK) cm
			WHERE cm.email=@userName OR cm.mobile=@userName
		)
		BEGIN	
			SELECT '1' ErrorCode , @userName +' already exists' Msg ,@userName ID  	
			RETURN;	
		END 

		------------- ### Check if the user trying to signup is already exists ###ENDS------------

		------------- ### Check device registration limit ###STARTS------------

		--IF EXISTS(SELECT 'x' FROM mobile_userRegistration(NOLOCK) WHERE imei=@imei GROUP BY imei HAVING COUNT(imei)>5)
		--BEGIN
		--	SELECT @_errorMsg = 'This device has exceeded the app registration limit.' 
		--	SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
		--	RETURN  
		--END

		------------- ###  Check device registration limit ###ENDS------------

		BEGIN TRANSACTION
			INSERT INTO customerMasterTemp(mobile,email,customerpassword,createdBy)
			SELECT @MSISDN,@email,dbo.FNAEncryptString(@Password),@scope

			SET @_customerId=SCOPE_IDENTITY()

			INSERT INTO mobile_userRegistration (customerId,username, OTP,OTP_Used,createdDate,IMEI,clientId)
			SELECT @_customerId,@userName,@code,0,GETDATE(),@Imei,@clientId

			INSERT INTO OTPHistory(username,OTP,OTP_Used,createdDate,codeType,customerId)
			SELECT @userName,@code,0,GETDATE(),'dvc',@_customerId

		 IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION  

		 SELECT '0' ErrorCode , 'Registration Success' Msg ,@userName ID  
		 RETURN
		-------## if record already exists ##ENDS---------------
	END
	ELSE IF @flag='v-otp' --validate otp (DONE)
	BEGIN
		--SELECT '1' ErrorCode, 'Invalid device verification code.' Msg ,NULL ID
		--RETURN

		IF ISNULL(@code,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'Device verification code is required.' Msg ,NULL ID
			RETURN
		END

		IF ISNULL(@phoneOs,'') NOT IN('android','ios')
		BEGIN
			SELECT '1' ErrorCode, 'Invalid Device type(PhoneOs).' Msg ,NULL ID
			RETURN
		END
		------------- ### Check if the user trying to validate is already exists ###STARTS------------

		IF NOT EXISTS(
			SELECT 'x' FROM dbo.customerMasterTemp(NOLOCK) cm
			WHERE (cm.email=@userName OR cm.mobile=@userName) AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT @_errorMsg = 'User with contact Info ' + @username + ' does not exists. If you are a new user, then sign up and proceed further.' 
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
			RETURN  
		END

		------------- ### Check if the user trying to validate is already exists ###ENDS------------

		SELECT 
			@_customerId=cm.customerId
		FROM dbo.customerMasterTemp(NOLOCK) cm
		WHERE cm.email=@userName OR cm.mobile=@userName

		SELECT TOP 1
			 @_imei=v.imei
			,@_Otp=otp.OTP
			,@_otpUsed=otp.OTP_Used
			,@_isDeleted=ISNULL(cust.isDeleted,'N')
			,@_createdDate=DATEADD(MINUTE,20,otp.createdDate)
		FROM customermasterTemp(NOLOCK) cust 
		LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		INNER JOIN dbo.OTPHistory(NOLOCK) otp ON cust.customerId=otp.customerId
		WHERE cust.customerId=@_customerId AND otp.codeType='dvc'
		ORDER BY otp.rowId DESC

		--INNER JOIN OTPHistory otp(NOLOCK) ON v.username=otp.username
		--WHERE cust.customerId=@_customerId AND otp.codeType='dvc'
		--ORDER BY otp.rowId DESC

		--SELECT TOP 1
		--	 @_imei=v.imei
		--	,@_Otp=otp.OTP
		--	,@_otpUsed=otp.OTP_Used
		--	,@_isDeleted=ISNULL(cust.isDeleted,'N')
		--	,@_createdDate=DATEADD(MINUTE,20,otp.createdDate)
		--FROM customermaster(NOLOCK) cust 
		--LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		--INNER JOIN OTPHistory otp(NOLOCK) ON v.username=otp.username
		--WHERE cust.customerId=@_customerId AND otp.codeType='dvc'
		--ORDER BY otp.rowId DESC

		IF @_Otp=@code AND DATEDIFF(MINUTE, GETDATE() ,@_createdDate)>0 
				AND @_imei=@Imei AND @_otpUsed=0
		BEGIN
			BEGIN TRANSACTION

			UPDATE mobile_userRegistration
			SET OTP_Used = 1
				,appVersion=@appVersion
				,phoneBrand=@phoneBrand
				,phoneOs=@phoneOs
				,osVersion=@osVersion
				,deviceId=@deviceId
			WHERE imei=@Imei AND otp=@code

			--UPDATE OTPHistory
			--	SET OTP_Used = 1
			--WHERE username=@userName AND otp=@code

			UPDATE OTPHistory
				SET OTP_Used = 1
			WHERE customerId=@_customerId AND otp=@code

			IF EXISTS(SELECT 'x' FROM dbo.customerMasterTemp(NOLOCK)cm WHERE cm.email=@userName)
			BEGIN
				UPDATE cm 
				SET cm.isEmailVerified=1,
					cm.isMobileVerified=0
				FROM dbo.customerMasterTemp(NOLOCK) cm WHERE cm.email=@userName
			END
			ELSE 
			BEGIN
				UPDATE cm 
				SET cm.isMobileVerified=1,
					cm.isEmailVerified=0
				FROM dbo.customerMasterTemp(NOLOCK) cm WHERE cm.mobile=@userName	
			END

			COMMIT TRANSACTION
			SELECT '0' ErrorCode, 'Success' Msg, NULL ID
			RETURN
		END
		ELSE IF ISNULL(@_Otp,'')<>@code
		BEGIN
			SELECT '1' ErrorCode, 'Please enter valid verification code sent to your ' + @userName Msg ,NULL ID
			RETURN
		END
		ELSE IF DATEDIFF(MINUTE, GETDATE() ,@_createdDate)<=0
		BEGIN
			SELECT '1' ErrorCode, 'Device verification code expired. Please re-send code and try again.' Msg ,NULL ID
			RETURN
		END
		ELSE IF @_imei=@Imei AND @_otpUsed=1
		BEGIN
			SELECT '1' ErrorCode, 'User already verified.' Msg ,NULL ID
			RETURN
		END
		ELSE IF @_imei<>@Imei
		BEGIN
			SELECT '1' ErrorCode, 'User does not belongs to this device for verification.' Msg ,NULL ID
			RETURN
		END
		ELSE
		BEGIN
			SELECT '1' ErrorCode, 'Invalid device verification code.' Msg ,NULL ID
			RETURN
		END
		
	END
	ELSE IF @flag='re-code' --resend OTP(DONE)
	BEGIN
		IF ISNULL(@scope,'')<>'mobile_app'
		BEGIN
			SELECT '1' ErrorCode, 'Application scope is not valid for this user.' Msg ,NULL ID
			RETURN
		END

		IF ISNULL(@codeType,'') NOT IN('dvc','prc')
		BEGIN
			SELECT '1' ErrorCode, 'Requested code type is not valid.' Msg ,NULL ID
			RETURN
		END

		DECLARE @today VARCHAR(15)=CONVERT(DATE, GETDATE(),101)
	
		------------- ### Check if the user trying to re-send code is exists or not ###STARTS------------

		IF EXISTS(
			SELECT 'x' FROM dbo.CustomerMasterTemp(NOLOCK) cm
			WHERE (cm.email=@userName OR cm.mobile=@userName) AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT 
			@_customerId=cm.customerId
		FROM dbo.customerMasterTemp(NOLOCK) cm
		WHERE cm.email=@userName OR cm.mobile=@userName	

		SELECT TOP 1
			 @_imei=v.imei
			,@_Otp=otp.OTP
			,@_otpUsed=otp.OTP_Used
		FROM dbo.CustomerMasterTemp(NOLOCK) cust 
		LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		INNER JOIN OTPHistory otp(NOLOCK) ON cust.customerId=otp.customerId
		WHERE cust.customerId=@_customerId AND otp.codeType=@codeType
		ORDER BY otp.rowId DESC

		IF @_otpUsed=1 AND @codeType='dvc' --for device verification code
		BEGIN
			SELECT '1' ErrorCode, 'User already verified. You cannot re-send code for the user who is already verified.' Msg ,NULL ID
			RETURN
		END

		SELECT @_count=COUNT('x')
		FROM dbo.CustomerMasterTemp(NOLOCK) cust 
		LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		INNER JOIN OTPHistory otp(NOLOCK) ON cust.customerId=otp.customerId
		WHERE cust.customerId=@_customerId
		AND otp.codeType=@codeType 
		AND v.imei=@imei 
		AND otp.createdDate BETWEEN @today AND @today+ ' 23:59:59'

		IF ISNULL(@_count,0)>10
		BEGIN
			SELECT '1' ErrorCode, 'Your device has been blocked. Re-send code attempts exceeded from same device.' Msg ,NULL ID
			RETURN
		END

		INSERT INTO OTPHistory(username,OTP,OTP_Used,createdDate,codeType,customerId)
		SELECT @userName,@code,0,GETDATE(),@codeType,@_customerId

		SELECT '0' ErrorCode, 'Success' Msg ,@code ID
		RETURN
		END


		IF NOT EXISTS(
			SELECT 'x' FROM dbo.customerMaster(NOLOCK) cm
			WHERE (cm.email=@userName OR cm.mobile=@userName) AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT @_errorMsg = 'Invalid UserId.' 
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
			RETURN  
		END
		------------- ### Check if the user trying to re-send code is exists or not ###ENDS------------

		SELECT 
			@_customerId=cm.customerId
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email=@userName OR cm.mobile=@userName



		--SELECT TOP 1
		--	 @_imei=v.imei
		--	,@_Otp=otp.OTP
		--	,@_otpUsed=otp.OTP_Used
		--FROM mobile_userRegistration(NOLOCK) v 
		--LEFT JOIN OTPHistory otp(NOLOCK) ON v.username=otp.username
		--WHERE otp.username=@userName AND otp.codeType=@codeType
		--ORDER BY otp.rowId DESC


		SELECT TOP 1
			 @_imei=v.imei
			,@_Otp=otp.OTP
			,@_otpUsed=otp.OTP_Used
		FROM customermaster(NOLOCK) cust 
		LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		INNER JOIN OTPHistory otp(NOLOCK) ON cust.customerId=otp.customerId
		WHERE cust.customerId=@_customerId AND otp.codeType=@codeType
		ORDER BY otp.rowId DESC

		------------- ### Check if the user trying to re-send code is already verified or not ###STARTS------------

		IF @_otpUsed=1 AND @codeType='dvc' --for device verification code
		BEGIN
			SELECT '1' ErrorCode, 'User already verified. You cannot re-send code for the user who is already verified.' Msg ,NULL ID
			RETURN
		END

		------------- ### Check if the user trying to re-send code is already verified or not ###ENDS------------

		------------- ### Check attempts of re-send code from same device ###STARTS------------
		
		

		SELECT @_count=COUNT('x')
		FROM customermaster(NOLOCK) cust 
		LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		INNER JOIN OTPHistory otp(NOLOCK) ON cust.customerId=otp.customerId
		WHERE cust.customerId=@_customerId
		AND otp.codeType=@codeType 
		AND v.imei=@imei 
		AND otp.createdDate BETWEEN @today AND @today+ ' 23:59:59'

		IF ISNULL(@_count,0)>10
		BEGIN
			SELECT '1' ErrorCode, 'Your device has been blocked. Re-send code attempts exceeded from same device.' Msg ,NULL ID
			RETURN
		END

		------------- ### Check attempts of re-send code ###ENDS------------

		INSERT INTO OTPHistory(username,OTP,OTP_Used,createdDate,codeType,customerId)
		SELECT @userName,@code,0,GETDATE(),@codeType,@_customerId

		SELECT '0' ErrorCode, 'Success' Msg ,@code ID
		RETURN
	END
	ELSE IF @flag='pwd-reset-rq' --password reset request(DONE)
	BEGIN

		------------- ### Check if the user trying to re-send code is exists or not ###STARTS------------

		IF EXISTS(
			SELECT 'x' FROM dbo.CustomerMasterTemp(NOLOCK) cm
			WHERE (cm.email=@userName OR cm.mobile=@userName) AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT 
			@_customerId=cm.customerId
			FROM dbo.CustomerMasterTemp(NOLOCK) cm
			WHERE cm.email=@userName OR cm.mobile=@userName

			INSERT INTO OTPHistory(username,OTP,OTP_Used,createdDate,codeType,customerId)
			SELECT @userName,@code,0,GETDATE(),'prc',@_customerId

			SELECT ErrorCode= '0'
				,userId=@userName
				,isVerified='false'
			RETURN	
		END

		IF NOT EXISTS(
			SELECT 'x' FROM dbo.customerMaster(NOLOCK) cm
			WHERE (cm.email=@userName OR cm.mobile=@userName) AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT @_errorMsg = 'User with contact Info ' + @username + ' does not exists. If you are a new user, then sign up and proceed further.' 
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
			RETURN  
		END

		------------- ### Check if the user trying to re-send code is exists or not ###ENDS------------

		SELECT 
			@_customerId=cm.customerId
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email=@userName OR cm.mobile=@userName

		IF EXISTS(SELECT 'x'
			FROM customermaster(NOLOCK) cust 
			WHERE cust.customerId=@_customerId AND ISNULL(cust.verifiedDate,'')<>''
		)
		BEGIN
			SELECT ErrorCode= '0'
				,userId=@userName
				,isVerified='true'
			RETURN
		END
		ELSE
		BEGIN
			INSERT INTO OTPHistory(username,OTP,OTP_Used,createdDate,codeType,customerId)
			SELECT @userName,@code,0,GETDATE(),'prc',@_customerId

			SELECT ErrorCode= '0'
				,userId=@userName
				,isVerified='false'
			RETURN
		END
	END
	ELSE IF @flag='qstn_validate' --reset password question validation(DONE)
	BEGIN
		IF ISNULL(@answer,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'The answer field is required.' Msg ,NULL ID
			RETURN
		END

		------------- ### Check if the user trying to validate is already exists ###STARTS------------

		IF NOT EXISTS(
			SELECT 'x' FROM dbo.customerMaster(NOLOCK) cm
			WHERE cm.email=@userName OR cm.mobile=@userName AND  ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT @_errorMsg = 'User with contact Info ' + @username + ' does not exists. If you are a new user, then sign up and proceed further.' 
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
			RETURN  
		END

		------------- ### Check if the user trying to validate is already exists ###ENDS------------

		SELECT 
			@_customerId=cm.customerId
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email=@userName OR cm.mobile=@userName

		IF NOT EXISTS(
			SELECT 'x' FROM dbo.customerMaster(NOLOCK) cm
			WHERE cm.customerId=@_customerId AND ISNULL(cm.dob,'')=@answer
		)
		BEGIN
			SELECT '1' ErrorCode, 'Your Date of Birth does not matches with your saved details' Msg ,NULL ID
			RETURN
		END

		INSERT INTO OTPHistory(username,OTP,OTP_Used,createdDate,codeType,customerId)
		SELECT @userName,@code,0,GETDATE(),'prc',@_customerId

		SELECT '0' ErrorCode, 'Correct answer.' Msg ,@userName ID
		RETURN
	END
	ELSE IF @flag='prc-validate' --password recovery validation(DONE)
	BEGIN
		IF ISNULL(@code,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'Password Recovery code is required.' Msg ,NULL ID
			RETURN
		END

		------------- ### Check if the user trying to validate is already exists ###STARTS------------

		IF EXISTS(
			SELECT 'x' FROM dbo.CustomerMasterTemp(NOLOCK) cm
			WHERE cm.email=@userName OR cm.mobile=@userName AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT 
				@_customerId=cm.customerId
			FROM dbo.customerMasterTemp(NOLOCK) cm
			WHERE cm.email=@userName OR cm.mobile=@userName	

			SELECT TOP 1
				 @_Otp=otp.OTP
				,@_otpUsed=otp.OTP_Used
				,@_createdDate=DATEADD(MINUTE,20,otp.createdDate)
			FROM dbo.OTPHistory(NOLOCK) otp
			WHERE otp.customerId=@_customerId AND otp.codeType='prc' /* AND otp.OTP=@code */
			ORDER BY otp.rowId DESC

		   IF @_Otp=@code AND DATEDIFF(MINUTE, GETDATE() ,@_createdDate)>0 
						AND @_otpUsed=0
			BEGIN
			--UPDATE OTPHistory
			--	SET OTP_Used = 1
			--WHERE username=@userName AND otp=@code

				UPDATE OTPHistory
					SET OTP_Used = 1
				WHERE customerId=@_customerId AND otp=@code

				SELECT '0' ErrorCode, 'Success' Msg, @userName ID
				RETURN
			END
			IF @_otpUsed=1
			BEGIN
				SELECT '1' ErrorCode, 'Password recovery code already used.' Msg ,NULL ID
				RETURN
			END
			ELSE IF ISNULL(@_Otp,'') <> @code
			BEGIN
				SELECT '1' ErrorCode, 'Invalid Password recovery code..' Msg ,NULL ID
				RETURN
			END
			ELSE IF DATEDIFF(MINUTE, GETDATE() ,@_createdDate)<=0
			BEGIN
				SELECT '1' ErrorCode, 'Password recovery code expired. Please re-send code and try again.' Msg ,NULL ID
				RETURN
			END
			ELSE
			BEGIN
				SELECT '1' ErrorCode, 'Invalid Password recovery code.' Msg ,NULL ID
				RETURN
			END
		END

		IF NOT EXISTS(
			SELECT 'x' FROM dbo.customerMaster(NOLOCK) cm
			WHERE cm.email=@username OR cm.mobile=@userName AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT @_errorMsg = 'User with contact Info ' + @username + ' does not exists. If you are a new user, then sign up and proceed further.' 
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
			RETURN  
		END

		------------- ### Check if the user trying to validate is already exists ###ENDS------------

		SELECT 
			@_customerId=cm.customerId
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email=@userName OR cm.mobile=@userName

		--SELECT TOP 1
		--	 @_Otp=otp.OTP
		--	,@_otpUsed=otp.OTP_Used
		--	,@_createdDate=DATEADD(MINUTE,20,otp.createdDate)
		--FROM dbo.OTPHistory(NOLOCK) otp
		--WHERE otp.username=@userName AND otp.codeType='prc' AND otp.OTP=@code
		--ORDER BY otp.rowId DESC

		SELECT TOP 1
			 @_Otp=otp.OTP
			,@_otpUsed=otp.OTP_Used
			,@_createdDate=DATEADD(MINUTE,20,otp.createdDate)
		FROM dbo.OTPHistory(NOLOCK) otp
		WHERE otp.customerId=@_customerId AND otp.codeType='prc' /* AND otp.OTP=@code */
		ORDER BY otp.rowId DESC

		IF @_Otp=@code AND DATEDIFF(MINUTE, GETDATE() ,@_createdDate)>0 
						AND @_otpUsed=0
		BEGIN
			--UPDATE OTPHistory
			--	SET OTP_Used = 1
			--WHERE username=@userName AND otp=@code

			UPDATE OTPHistory
				SET OTP_Used = 1
			WHERE customerId=@_customerId AND otp=@code

			SELECT '0' ErrorCode, 'Success' Msg, @userName ID
			RETURN
		END
		IF @_otpUsed=1
		BEGIN
			SELECT '1' ErrorCode, 'Password recovery code already used.' Msg ,NULL ID
			RETURN
		END
		ELSE IF ISNULL(@_Otp,'') <> @code
		BEGIN
			SELECT '1' ErrorCode, 'Invalid Password recovery code..' Msg ,NULL ID
			RETURN
		END
		ELSE IF DATEDIFF(MINUTE, GETDATE() ,@_createdDate)<=0
		BEGIN
			SELECT '1' ErrorCode, 'Password recovery code expired. Please re-send code and try again.' Msg ,NULL ID
			RETURN
		END
		ELSE
		BEGIN
			SELECT '1' ErrorCode, 'Invalid Password recovery code.' Msg ,NULL ID
			RETURN
		END

		
	END
	ELSE IF @flag='u-pwd' --used to update user fields before login(DONE)
	BEGIN
		--SELECT TOP 1
		--	@_customerId=cust.customerId
		--	,@_otpUsed=otp.OTP_Used
		--	,@_onlineUser=cust.onlineUser
		--FROM customermaster(NOLOCK) cust 
		--LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		--INNER JOIN OTPHistory otp(NOLOCK) ON v.username=otp.username
		--WHERE cust.email=@userName OR cust.mobile=@userName AND ISNULL(cust.createdBy, '')=@scope
		--ORDER BY otp.rowId DESC

		IF EXISTS(
			SELECT 'x' FROM dbo.CustomerMasterTemp(NOLOCK) cm
			WHERE cm.email=@userName OR cm.mobile=@userName AND ISNULL(cm.isDeleted,'N')='N'
		)
		BEGIN
			SELECT TOP 1
				@_customerId=cust.customerId
				,@_otpUsed=otp.OTP_Used
				,@_onlineUser=cust.onlineUser
				,@_createdBy=cust.createdBy
			FROM customermasterTemp(NOLOCK) cust 
			LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
			LEFT JOIN OTPHistory(NOLOCK) otp ON cust.customerId=otp.customerId
			WHERE cust.email=@userName OR cust.mobile=@userName AND ISNULL(cust.createdBy, '')=@scope
			ORDER BY otp.rowId DESC	

		IF ISNULL(@_customerId,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'Invalid username.' Msg ,@userName ID
			RETURN
		END

		IF ISNULL(@Password,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'The password field is Required.' Msg ,@userName ID
			RETURN	
		END

		IF @_otpUsed<>1 AND @_createdBy IN ('mobile','mobile_app')
		BEGIN
			SELECT '1' ErrorCode, 'To update your password, please verify your account first with the verification code sent to your ' + @userName Msg ,@userName ID
			RETURN
		END
				
		UPDATE customermasterTemp  SET 
			customerpassword=ISNULL(dbo.FNAEncryptString(@Password),customerPassword)
		WHERE customerId=@_customerId

		SELECT	
			 errorCode='0'
			,userId=@userName
			,firstName=cm.firstName
			,middleName=cm.middleName
			,lastName=cm.lastName1
			,nickName=cm.nickName
			,email=ISNULL(cm.email,'')
			,phone=ISNULL(cm.mobile,'')
			,rewardPoint=CAST(ISNULL(cm.bonusPoint,0) AS DECIMAL)
			,verificationCode=ISNULL(ur.OTP,'')
			,VerificationCodeExpiryDate=''
			,createdDate=ISNULL(ur.createdDate,'')
			,userRoles=''
			,active=CASE WHEN ISNULL(cm.isActive,'Y')='Y' THEN 1 ELSE 0 END
			,kyc=CASE WHEN ISNULL(cm.createdDate,'') <> '' THEN 1 ELSE 0 END
			,verified=CASE WHEN ISNULL(cm.verifiedDate,'') <> '' THEN 1 ELSE 0 END
			,forgetCode=ISNULL(ur.passRecoveryCode,'')
			,ForgetCodeExpiryDate=''
			,primaryBankName=ISNULL(bl.BankName,'')
			,walletNumber=ISNULL(cm.walletAccountNo,'')
			,availableBalance=CAST([dbo].FNAGetCustomerACBal(@userName) AS DECIMAL) 
			,dpUrl=ISNULL(cm.dpUrl,'')
			,cmRegistrationId=ISNULL(ur.cmRegistrationId,'')
		FROM dbo.customerMasterTemp(NOLOCK) cm
		LEFT JOIN dbo.mobile_userRegistration(NOLOCK) ur
		ON ur.customerId=cm.customerId
		LEFT JOIN dbo.vwBankLists bl WITH(NOLOCK)
		ON bl.bankCode=cm.bankName
		WHERE cm.customerId=@_customerId
		RETURN   

		END

		SELECT TOP 1
			@_customerId=cust.customerId
			,@_otpUsed=otp.OTP_Used
			,@_onlineUser=cust.onlineUser
		FROM customermaster(NOLOCK) cust 
		LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		LEFT JOIN OTPHistory(NOLOCK) otp ON cust.customerId=otp.customerId
		WHERE cust.email=@userName OR cust.mobile=@userName AND ISNULL(cust.createdBy, '')=@scope
		ORDER BY otp.rowId DESC

		IF ISNULL(@_customerId,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'Invalid username.' Msg ,@userName ID
			RETURN
		END

		IF ISNULL(@Password,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'The password field is Required.' Msg ,@userName ID
			RETURN	
		END

		IF @_otpUsed<>1 AND @_createdBy IN ('mobile','mobile_app')
		BEGIN
			SELECT '1' ErrorCode, 'To update your password, please verify your account first with the verification code sent to your ' + @userName Msg ,@userName ID
			RETURN
		END
				
		UPDATE customermaster  SET 
			customerpassword=ISNULL(dbo.FNAEncryptString(@Password),customerPassword)
		WHERE customerId=@_customerId

		SELECT	
			 errorCode='0'
			,userId=@userName
			,firstName=cm.firstName
			,middleName=cm.middleName
			,lastName=cm.lastName1
			,nickName=''
			,email=ISNULL(cm.email,'')
			,phone=ISNULL(cm.mobile,'')
			,rewardPoint=CAST(ISNULL(cm.bonusPoint,0) AS DECIMAL)
			,verificationCode=ISNULL(ur.OTP,'')
			,VerificationCodeExpiryDate=''
			,createdDate=ISNULL(ur.createdDate,'')
			,userRoles=''
			,active=CASE WHEN ISNULL(cm.isActive,'Y')='Y' THEN 1 ELSE 0 END
			,kyc=CASE WHEN ISNULL(cm.createdDate,'') <> '' THEN 1 ELSE 0 END
			,verified=CASE WHEN ISNULL(cm.verifiedDate,'') <> '' THEN 1 ELSE 0 END
			,forgetCode=ISNULL(ur.passRecoveryCode,'')
			,ForgetCodeExpiryDate=''
			,primaryBankName=ISNULL(bl.BankName,'')
			,walletNumber=ISNULL(cm.walletAccountNo,'')
			,availableBalance=CAST([dbo].FNAGetCustomerACBal(@userName) AS DECIMAL) 
			,dpUrl=''
			,cmRegistrationId=ISNULL(ur.cmRegistrationId,'')
		FROM dbo.customerMaster(NOLOCK) cm
		LEFT JOIN dbo.mobile_userRegistration(NOLOCK) ur
		ON ur.customerId=cm.customerId
		LEFT JOIN dbo.vwBankLists bl WITH(NOLOCK)
		ON bl.bankCode=cm.bankName
		WHERE cm.customerId=@_customerId
		RETURN   
	END
	ELSE IF @flag='u-user'
	BEGIN
		--SELECT TOP 1
		--	@_customerId=cust.customerId
		--	,@_otpUsed=otp.OTP_Used
		--	,@email=cust.email
		--	,@MSISDN=cust.mobile
		--FROM customermaster(NOLOCK) cust 
		--LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		--INNER JOIN OTPHistory otp(NOLOCK) ON v.username=otp.username
		--WHERE cust.email=@userName OR cust.mobile=@userName AND ISNULL(cust.createdBy, '')=@scope
		--ORDER BY otp.rowId DESC

		SELECT TOP 1
			@_customerId=cust.customerId
			--,@_otpUsed=otp.OTP_Used
			,@email=cust.email
			,@MSISDN=cust.mobile
		FROM customermaster(NOLOCK) cust 
		--LEFT JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		INNER JOIN mobile_userRegistration(NOLOCK) v ON cust.customerId=v.customerId  
		--LEFT JOIN OTPHistory(NOLOCK) otp ON cust.customerId=otp.customerId
		WHERE (cust.email=@userName OR cust.mobile=@userName) 
		--AND ISNULL(cust.createdBy, '')=@scope
		--WHERE ((cust.email=@userName AND cust.isEmailVerified=1) OR (cust.mobile=@userName AND cust.isMobileVerified=1)) AND ISNULL(cust.createdBy, '')=@scope
		--ORDER BY otp.rowId DESC

		IF ISNULL(@_customerId,'')=''
		BEGIN
			SELECT '1' ErrorCode, 'Invalid username.' Msg ,@userName ID
			RETURN
		END
		IF ISNULL(@cmRegistrationId,'') <> ''
		BEGIN
			UPDATE mobile_userRegistration SET
					cmRegistrationId=ISNULL(@cmRegistrationId,cmRegistrationId)
			WHERE customerId=@_customerId
		END
		--IF ISNULL(@dpUrl,'') <> ''
		--BEGIN
		--	UPDATE cm SET dpUrl=ISNULL(@dpUrl,dpUrl)
		--	FROM dbo.customerMaster cm
		--	WHERE cm.customerId=@_customerId
		--END
		SELECT	errorCode='0'
				,userId=@userName
				,firstName=cm.firstName
				,middleName=cm.middleName
				,lastName=cm.lastName1
				,nickName=''
				,email=ISNULL(cm.email,'')
				,phone=ISNULL(cm.mobile,'')
				,rewardPoint=CAST(ISNULL(cm.bonusPoint,0) AS DECIMAL)
				,verificationCode=ISNULL(ur.OTP,'')
				,VerificationCodeExpiryDate=''
				,createdDate=ISNULL(ur.createdDate,'')
				,userRoles=''
				,active=CASE WHEN ISNULL(cm.isActive,'Y')='Y' THEN 1 ELSE 0 END
				,kyc=CASE WHEN ISNULL(cm.createdDate,'') <> '' THEN 1 ELSE 0 END
				,verified=CASE WHEN ISNULL(cm.verifiedDate,'') <> '' THEN 1 ELSE 0 END
				,forgetCode=ISNULL(ur.passRecoveryCode,'')
				,ForgetCodeExpiryDate=''
				,primaryBankName=ISNULL(bl.BankName,'')
				,walletNumber=ISNULL(cm.walletAccountNo,'')
				,availableBalance=CAST([dbo].FNAGetCustomerACBal(@userName) AS DECIMAL)
				,dpUrl=''
				,cmRegistrationId=ISNULL(ur.cmRegistrationId,'')
			FROM dbo.mobile_userRegistration(NOLOCK) ur
			INNER JOIN dbo.customerMaster(NOLOCK) cm
			ON ur.customerId=cm.customerId
			LEFT JOIN dbo.vwBankLists(NOLOCK) bl
			ON bl.bankCode=cm.bankName
			WHERE cm.customerId=@_customerId
			RETURN   
	END
	ELSE IF @flag='pwd-change' --password changed after successful login(DONE)
	BEGIN
		------------- ### Check if the user trying to change password exists or not ###STARTS------------

		IF NOT EXISTS(SELECT 'x' FROM dbo.customerMaster(NOLOCK) cust
			WHERE cust.email=@userName OR cust.mobile=@userName AND ISNULL(cust.isDeleted,'N')='N'
		)
		BEGIN
			SELECT @_errorMsg = 'User with contact Info ' + @username + ' does not exists. If you are a new user, then sign up and proceed further.' 
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
			RETURN  
		END

		------------- ### Check if the user trying to change password exists or not ###ENDS------------

		SELECT 
			@_customerId=cust.customerId
			,@_password=cust.customerpassword
		FROM customermaster(NOLOCK) cust 
		WHERE cust.email=@userName OR cust.mobile=@userName

		IF @_password <> dbo.FNAEncryptString(@Password)
		BEGIN
		EXEC proc_errorHandler 1, 'Incorrect existing password.. Please try again!', @userName
		RETURN;
		END

		IF @_password = dbo.FNAEncryptString(@newPassword)
		BEGIN
		EXEC proc_errorHandler 1, 'Please enter a new password.Old passwords are not accepted.', @userName
		RETURN;
		END

		IF ISNULL(@_customerId,'') = ''
		BEGIN
			SELECT @_errorMsg = 'User with contact Info ' + @username + ' does not exists. If you are a new user, then sign up and proceed further.' 
			SELECT '1' ErrorCode, @_errorMsg Msg ,NULL ID
			RETURN  
		END

		BEGIN TRANSACTION
			UPDATE customermaster SET 
						customerpassword=dbo.FNAEncryptString(@newPassword)
			WHERE customerId=@_customerId

		IF @@TRANCOUNT > 0  
			COMMIT TRANSACTION
				   
		SELECT '0' ErrorCode, 'Password changed successfully.' Msg ,@userName ID
		RETURN
	END

	ELSE IF @flag='chk-referred'
	BEGIN
		IF EXISTS(SELECT 'x' FROM referralmaster(NOLOCK) WHERE email = @email OR mobile = @MSISDN)
		BEGIN
			SELECT @userName=userId FROM dbo.referralMaster(NOLOCK) WHERE email=@email OR mobile=@MSISDN
			SELECT errorCode = '0' ,
				   referredBy=@userName,
				   isReferred=1
			RETURN
		END
		ELSE
		BEGIN
			SELECT errorCode = '1', 
				   referredBy='',
				   isReferred=0
			RETURN
		END
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
