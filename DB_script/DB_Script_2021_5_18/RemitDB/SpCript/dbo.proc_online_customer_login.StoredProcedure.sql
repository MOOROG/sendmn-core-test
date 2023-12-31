USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_customer_login]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_online_customer_login]
	  @flag                 VARCHAR(50)		
     ,@customerEmail        VARCHAR(100)	= NULL
     ,@customerPassword     VARCHAR(255)	= NULL
     ,@country     		    VARCHAR(50) 	= NULL
     ,@ipAddress			VARCHAR(100)	= NULL
	 ,@lockReason			VARCHAR(500)	= NULL	
	 ,@UserInfoDetail		VARCHAR(MAX)	= NULL
	 ,@sessionId			VARCHAR(60)		= NULL
	 ,@checkCountry			VARCHAR(50)		= NULL
	 ,@password				VARCHAR(50)		= NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	DECLARE
		 @UserData				VARCHAR(200)
		,@lastPwdChangedOn		DATETIME
		,@forceChangePwd		CHAR(1)
		,@pwdChangeDays			VARCHAR(20)
		,@msg					VARCHAR(2000) 
		,@pwdChangeWarningDays	VARCHAR(5)
		,@lastLoginDate         DATETIME
		
	DECLARE  @email VARCHAR(100)
			,@customerPwd VARCHAR(50)
			,@isActive CHAR(1)
			,@onlineUser CHAR(1)
			,@isLocked VARCHAR(1)
			,@ccountry VARCHAR(50)
			,@customerStatus CHAR(1)
			,@loginAttempt	INT

	IF @flag = 'checkIp'
	BEGIN	
		IF NOT EXISTS( SELECT  COUNTRYNAME FROM COUNTRYMASTER WITH (NOLOCK) 
			WHERE ISNULL(allowOnlineCustomer,'N')='Y' AND  upper(COUNTRYNAME)=upper(@checkCountry))
		BEGIN
				SELECT 1 ERRORCODE,'NOT AVAILABLE' MSG,NULL
			RETURN
		END 
		ELSE
		BEGIN
			SELECT 0 ERRORCODE,'AVAILABLE' MSG,NULL
		END
	END

	IF @flag = 'l'
	BEGIN 
		IF NOT EXISTS(SELECT 'x' FROM customerMaster WITH(NOLOCK) WHERE email=@customerEmail)
		BEGIN
			SELECT 1 errorCode, 'Login Failed - Invalid username or password!' mes, @customerEmail id
			RETURN
		END
		SELECT @email=email,
				@customerPwd=customerPassword,
				@isActive=isactive, 
				@onlineUser=onlineuser,
				@isLocked=isLocked,
				@ccountry=country,
				@customerStatus=customerStatus,
				@lastLoginDate=lastLoginTs,
				@loginAttempt = ISNULL(invalidAttemptCount, 0)
		FROM customerMaster WITH (NOLOCK)
		WHERE email=@customerEmail and ISNULL(onlineUser, 'N')='Y'
			
		SET @UserData ='User: '+ @customerEmail +' User Type:Online User'
		DECLARE @attemptsCount INT, @InvalidReason VARCHAR(80), @InvalidMsg VARCHAR(100)
		SELECT TOP 1 @attemptsCount = loginAttemptCount FROM passwordFormat WITH(NOLOCK)

		IF (ISNULL(@isLocked, 'N') IN ('B', 'Y')) OR ((@loginAttempt - @attemptsCount) = -1)
		BEGIN
			SET @UserInfoDetail = 'Reason = Too many wrong attempts .-:::-' + @UserInfoDetail
			
			SELECT 1 errorCode, 'Login Failed - Too many wrong attempts, please contact GME Support!' mes, @customerEmail id, @attemptsCount ac	
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @customerEmail, 
				@Reason= 'Reason = Too many wrong attempts.',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@IP = @ipAddress	
			RETURN
		END

		IF (@customerPwd <> dbo.FNAEncryptString(@customerPassword))
		BEGIN	
			SET @UserInfoDetail = 'Reason = Incorrect password .-:::-' + @UserInfoDetail

			SET @loginAttempt = @loginAttempt + 1
			
			UPDATE customerMaster SET invalidAttemptCount = @loginAttempt--, isLocked = CASE WHEN @loginAttempt > @attemptsCount THEN 'B' ELSE 'N' END 
			WHERE email = @customerEmail and ISNULL(onlineUser, 'N')='Y'
			
			SET @InvalidReason = CASE WHEN @loginAttempt > @attemptsCount THEN 'Number of invalid password attempts exceeded!' ELSE 'Invalid Password' END
			SET @InvalidMsg = 'Login Failed - you have ' + CAST((@attemptsCount - @loginAttempt) AS VARCHAR) + ' Attempts Left'

			SELECT 1 errorCode, @InvalidMsg mes, @customerEmail id, @attemptsCount ac	
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @customerEmail, 
				@Reason= @InvalidReason,
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@IP = @ipAddress	
			RETURN
		END

		IF (ISNULL(@onlineUser, 'N') = 'N')
		BEGIN
				SELECT 2 errorCode, 'User is not  an Online User' mes, @customerEmail id, @attemptsCount ac
				SET @UserInfoDetail = 'Reason = Login fails, Invalid password.-:::-'+@UserInfoDetail
				EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @customerEmail, 
				@Reason='Not online User',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@IP = @ipAddress	
			RETURN
		END

		DECLARE @vPenny CHAR(1),@vCustomerId BIGINT

		SELECT 	@vCustomerId=CM.customerId , @vPenny = CASE WHEN CM.createdDate < '2018-12-19 11:00:00' THEN 'N' WHEN ISNULL(CC.action,'REQ') = 'REQ' THEN 'Y' ELSE 'N' END
		from customerMaster CM (nolock)
		LEFT JOIN TblCustomerBankVerification CC (nolock) ON CM.customerId = CC.customerId
		WHERE 	CM.email = @customerEmail

		IF @vPenny = 'Y'
		BEGIN
			SELECT 1000 errorCode, 'User redirect to penny test verification' mes, @vCustomerId id
			SET @UserInfoDetail = 'Reason = Login fails, User redirect to penny test verification.-:::-'+@UserInfoDetail
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @customerEmail, 
				@Reason='Penny test verification',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@IP = @ipAddress
			RETURN	
		END
		IF  (ISNULL(@isActive, 'Y') = 'N')
		BEGIN
			SELECT 1 errorCode, 'Your account is Inactive. Please, contact GME Support Team.' mes, @customerEmail id
			SET @UserInfoDetail = 'Reason = Login fails, Your account is Inactive. Please, contact your administrator.-:::-'+@UserInfoDetail
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Login fails', 
				@createdBy = @customerEmail, 
				@Reason='User is not active ',
				@UserData = @UserData,
				@fieldValue = @UserInfoDetail,
				@IP = @ipAddress
			RETURN		
		END

		IF EXISTS (SELECT 'x' FROM customerMaster (NOLOCK) WHERE  email=@customerEmail  AND approvedBy IS NULL AND approvedDate IS NULL)
		BEGIN 
			SELECT 1 errorCode, 'Login Failed - Customer registration verification pending please visit nearest GME branch to get verified!' mes, @customerEmail id
			RETURN
		END

		UPDATE customerMaster SET 
				sessionId=@sessionId
				,lastLoginTs = GETDATE()
				,invalidAttemptCount = 0
		WHERE email = @customerEmail and ISNULL(onlineUser, 'N')='Y'		

		DECLARE @mobileNo VARCHAR(16)

		SET @mobileNo = REPLACE(@mobileNo,' ','')
		SET @mobileNo = REPLACE(@mobileNo,'-','')
		SET @mobileNo = REPLACE(@mobileNo,'+','')
		SET @mobileNo = LEFT(@mobileNo,16)

		DECLARE @clientUseCode VARCHAR(10), @clientId VARCHAR(50), @clientSecret VARCHAR(50), @accessToken VARCHAR(400), @gmeBankCode VARCHAR(3), @gmeAccountNo VARCHAR(20)
		
		SELECT @clientUseCode = DBO.DECRYPTDB(clientUseCode), @clientId = DBO.DECRYPTDB(clientId), @clientSecret = DBO.DECRYPTDB(clientSecret)
		, @accessToken = accessToken, @gmeAccountNo = accountNum, @gmeBankCode = bankCodeStd
		FROM  KFTC_GME_MASTER (NOLOCK) 


		SELECT 
			TOP 1
				0 errorCode
			,'Login success.' mes
			,cu.customerId Id
			,username = cu.email
			,fullName = cu.fullName
			,country = cm.countryName
			,agent_branch_code=cu.branchId
			,agentcode=cu.agentId
			,date_format=NULL
			,limitPerTran=0
			,GMT_value=NULL
			,currencyType=NULL
			,extra_rate_bank=NULL
			,cash_ledger_id=NULL
			,@attemptsCount [ac]
			,sessionTimeOutPeriod=NULL
			,lastLoginTs=GETDATE()
			,cm.countryId 
			,[address]	= cu.city +'-Provience,South Korea'
			,[address2]=cu.[address2] 
			,homePhone=cu.homePhone
			,mobile=cu.mobile
			,cm.countryCode
			,utcTime=8
			,mobile= @mobileNo
			,city=cu.city
			,postalCode=cu.postalCode
			,membershipId=membershipId
			,sdv.detailTitle idType
			,cu.idNumber
			,isForcedPwdChange = ISNULL(isForcedPwdChange,0)
			,customerStatus
			,cu.walletAccountNo
			,primaryBankName=CASE WHEN cu.customerType='11048' THEN 'Mutual savings bank(050)' ELSE 'Kwangju Bank (034)' END
			,nativeCountry = cm1.countryName
			,nativeCountryId = cm1.countryId
			,nativeCountryCode = cm1.countryCode
			,occupation = sd.detailTitle
			,idExpiryDate = CASE WHEN cu.idType='8008' THEN '2059-12-12' ELSE FORMAT(cu.idExpiryDate,'MM/dd/yyyy') END 
			,birthDate = FORMAT(cu.dob,'MM/dd/yyyy')
			,accessToken = KFTC.accessToken
			,clientUseCode = @clientUseCode
			,clientId = @clientId
			,clientSecret = @clientSecret
			,gmeAccessToken = @accessToken
			,gmeBankCode = @gmeBankCode
			,gmeAccountNum = @gmeAccountNo
		FROM customerMaster cu WITH(NOLOCK)
		LEFT JOIN countryMaster cm  WITH (NOLOCK) ON cm.countryId=cu.country 
		LEFT JOIN countryMaster cm1 with(nolock) on cm1.countryId = cu.nativeCountry
		left join staticDataValue sdv with (nolock) on sdv.valueId=cu.idType
		left join staticDataValue sd with(nolock) on sd.valueId = cu.occupation
		LEFT JOIN dbo.vwBankLists vwbank WITH (NOLOCK) ON cu.bankName=vwbank.rowid
		LEFT JOIN KFTC_CUSTOMER_MASTER KFTC(NOLOCK) ON KFTC.customerId = CU.customerId
		WHERE cu.email= @customerEmail 
		and ISNULL(cu.onlineUser, 'N')='Y'
		

		EXEC proc_applicationLogs 
			@flag='login',
			@logType='Login', 
			@createdBy = @customerEmail, 
			@Reason='Login',
			@UserData = @UserData,
			@fieldValue = @UserInfoDetail,
			@IP = @ipAddress				
		END

	ELSE IF @flag = 'loc'
	BEGIN
		UPDATE customerMaster SET
			 isLocked = 'Y'			
		WHERE  email= @customerEmail and ISNULL(onlineUser, 'N')='Y'	
		INSERT INTO userLockHistory(userName, lockReason, createdBy, createdDate)
		SELECT @customerEmail, @lockReason, 'system',GETDATE()
		SELECT 0 errorCode, 'Your account has been locked. Please, contact your administrator.' mes, @customerEmail id
	END	

	ELSE IF @flag='availbal'
	BEGIN
		SELECT ISNULL(availableBalance, 0.00) AS availableBalance FROM dbo.customerMaster(nolock)
		WHERE email=@customerEmail

		--SELECT 0 errorCode,ISNULL(a.clr_bal_amt, 0.00) AS availableBalance 
		--FROM dbo.customerMaster c(nolock)
		--INNER JOIN FastMoneyPro_account.dbo.ac_master a(nolock) ON A.acct_num = c.walletAccountNo
		--WHERE c.email = @customerEmail
	END

	ELSE IF @flag='checkpass'
	BEGIN
	 
	 IF NOT EXISTS(SELECT 'X' FROM customerMaster WITH (NOLOCK)
		WHERE email=@customerEmail and ISNULL(onlineUser, 'N')='Y')
		BEGIN
			SELECT @email=email,
					@customerPwd=customerPassword,
					@isActive=isactive, 
					@onlineUser=onlineuser,
					@isLocked=isLocked,
					@ccountry=country,
					@customerStatus=customerStatus,
					@lastLoginDate=lastLoginTs,
					@loginAttempt = ISNULL(invalidAttemptCount, 0)
			FROM customerMaster WITH (NOLOCK)
			WHERE username=@customerEmail and ISNULL(onlineUser, 'N')='Y'
		END
		ELSE
		BEGIN
			SELECT @email=email,
					@customerPwd=customerPassword,
					@isActive=isactive, 
					@onlineUser=onlineuser,
					@isLocked=isLocked,
					@ccountry=country,
					@customerStatus=customerStatus,
					@lastLoginDate=lastLoginTs,
					@loginAttempt = ISNULL(invalidAttemptCount, 0)
			FROM customerMaster WITH (NOLOCK)
			WHERE username=@customerEmail and ISNULL(onlineUser, 'N')='Y'
		END
		IF @customerPwd = dbo.FNAEncryptString(@password)
		BEGIN
			UPDATE customerMaster SET 
				invalidAttemptCount = 0
			WHERE username = @customerEmail and ISNULL(onlineUser, 'N')='Y'

			SELECT 0 errorCode, 'Success' msg, @customerEmail id
			RETURN;
		END

		SELECT TOP 1 @attemptsCount = loginAttemptCount FROM passwordFormat WITH(NOLOCK)

		IF (ISNULL(@isLocked, 'N') IN ('B', 'Y')) OR ((@loginAttempt - @attemptsCount) = -1)
		BEGIN
			SELECT 9 errorCode, 'Too many wrong attempts, please contact GME Support!' mes, @customerEmail id	
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Send Transaction', 
				@createdBy = @customerEmail, 
				@Reason= 'Reason = Too many wrong attempts sending transaaction.'
			RETURN
		END

		IF (@customerPwd <> dbo.FNAEncryptString(@password))
		BEGIN	
			SET @UserInfoDetail = 'Reason = Incorrect password .-:::-' + @UserInfoDetail

			SET @loginAttempt = @loginAttempt + 1
			
			UPDATE customerMaster SET invalidAttemptCount = @loginAttempt, isLocked = CASE WHEN @loginAttempt > @attemptsCount THEN 'B' ELSE 'N' END 
			WHERE email = @customerEmail and ISNULL(onlineUser, 'N')='Y'
			
			SET @InvalidReason = CASE WHEN @loginAttempt > @attemptsCount THEN 'Number of invalid password attempts exceeded!' ELSE 'Invalid Password' END
			SET @InvalidMsg = 'Login Failed - Invalid Password, you have ' + CAST((@attemptsCount - @loginAttempt) AS VARCHAR) + ' Attempts Left'

			SELECT 1 errorCode, @InvalidMsg mes, @customerEmail id
			EXEC proc_applicationLogs 
				@flag='login',
				@logType='Send Transaction', 
				@createdBy = @customerEmail, 
				@Reason= 'Reason = wrong transaction password.'
			RETURN
		END
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage,NULL
END CATCH
GO
