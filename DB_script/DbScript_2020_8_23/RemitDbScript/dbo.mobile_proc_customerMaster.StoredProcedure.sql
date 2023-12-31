USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_customerMaster]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[mobile_proc_customerMaster]
	@flag					VARCHAR(30)
	,@userName				VARCHAR(100)	= NULL			
	,@firstName				VARCHAR(50)		= NULL	
	,@middleName			VARCHAR(50)		= NULL
	,@lastName				VARCHAR(50)		= NULL
	,@nickName				VARCHAR(100)	= NULL
	,@mobileNumber			VARCHAR(30)		= NULL
	,@email					VARCHAR(100)	= NULL
	,@gender				VARCHAR(15)		= NULL
	,@dateOfBirth			DATETIME		= NULL
	,@nativeCountry			VARCHAR(100)	= NULL
	,@country				VARCHAR(100)	= NULL
	,@address				VARCHAR(150)	= NULL
	,@city					VARCHAR(50)		= NULL
	,@province              VARCHAR(50)     = NULL
	,@occupation			VARCHAR(100)	= NULL
	,@primaryBankName		VARCHAR(200)	= NULL
	,@primaryAccountNumber	VARCHAR(100)	= NULL
	,@verificationIdType	VARCHAR(50)		= NULL
	,@verificationIdNumber	VARCHAR(50)		= NULL
	,@issueDate				DATETIME		= NULL
	,@expiryDate			DATETIME		= NULL
	,@regIdcardFrontUrl		VARCHAR(200)	= NULL
	,@regIdcardBackUrl		VARCHAR(200)	= NULL
	,@passbookUrl			VARCHAR(200)	= NULL
	,@passportUrl			VARCHAR(200)	= NULL
	,@selfieUrl             VARCHAR(300)    = NULL
	-- CDD parameters
	,@cddCode				VARCHAR(100)	= NULL
	,@sourceOfFund			VARCHAR(500)	= NULL
	,@referralCode			VARCHAR(100)	= NULL


	,@appVersion			VARCHAR(100)	= NULL
	,@phoneBrand			VARCHAR(100)	= NULL
	,@phoneOS 				VARCHAR(100)	= NULL
	,@fcmId 				VARCHAR(MAX)	= NULL
	,@osVersion 			VARCHAR(100)	= NULL

	,@fullName				VARCHAR(200)	= NULL
	,@passportNumber		VARCHAR(100)	= NULL  
	,@anotherIDType			VARCHAR(20)		= NULL
	,@anotherIDNumber		VARCHAR(20)		= NULL
	,@branch				VARCHAR(20)		= NULL
	,@type					INT				= NULL
	

			
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @errorMsg   VARCHAR(MAX),@customerId BIGINT,@yearlyLimit MONEY,@totalSend MONEY,
	 @totalSendText VARCHAR(200), @YearStart DATE, @YearEnd DATETIME,@cust BIGINT = NULL;
	DECLARE @IsActive CHAR(1)
	DECLARE @redirectTo VARCHAR(100) = ''
		SET @country = '142';

		SET @firstName	= UPPER(@firstName)				
		SET @middleName	= UPPER(@middleName)		
		SET @lastName	= UPPER(@lastName)	
		SET @fullName = @firstName + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName, '')

	IF @flag='i'
	BEGIN
		--SELECT @customerId = customerId FROM customerMasterTemp with (nolock)  
		--WHERE email = @username OR mobile = @username

		--CHECK FOR customer IN temp table
		SELECT @customerId = customerId FROM customerMasterTemp with (nolock)  
		WHERE username = @userName

		IF @customerId IS NULL
		BEGIN
			IF EXISTS(SELECT TOP 1 'A' FROM customerMaster(NOLOCK) WHERE EMAIL = @userName)
			BEGIN
				SELECT @errorMsg = 'It looks like you are already registered in GME system!'
				EXEC proc_errorHandler 1, @errorMsg, @userName
				RETURN
			END
		END

		SELECT @email = @userName 

		BEGIN TRANSACTION
			UPDATE dbo.customerMasterTemp SET 
				firstName	=	@fullName,
				fullName	=	@fullName,
				nickName	=	@nickName,
				mobile		=	@mobileNumber,
				homePhone	=	@verificationIdNumber,
				--email=@email,
				gender		=	CASE WHEN UPPER(@gender) = 'M' THEN '97' WHEN UPPER(@gender) = 'F' THEN '98' ELSE '99' END ,
				--dob=@dateOfBirth,
				nativeCountry=	@nativeCountry,
				country		=	@country,
				[address]	=	@address,
				city		=	@province,
				state2		=	@province,
				occupation	=	@occupation,
				bankName	=	@primaryBankName,
				bankAccountNo=	@primaryAccountNumber,
				idNumber	=	@verificationIdNumber,
				idType		=	@verificationIdType,
				idIssueDate	=	@issueDate,
				createdDate	=	GETDATE(),
				sourceOfFund=CASE WHEN @sourceOfFund IS NOT NULL 
								  THEN (SELECT sd.detailTitle FROM dbo.staticDataValue sd(NOLOCK) WHERE sd.valueId=@sourceOfFund)
								  ELSE sourceOfFund
								  END,
				idExpiryDate=	@expiryDate,
				verifyDoc1	=	@regIdcardFrontUrl,
				verifyDoc2	=	@regIdcardBackUrl,
				verifyDoc3	=	@passbookUrl,
				verifyDoc4	=	@passportUrl,
				selfie		=	@selfieUrl,
				referelCode	=	@referralCode
			WHERE customerId=	@customerId

			INSERT INTO dbo.customerMaster
			(
				fullName,firstName,mobile,email,gender,dob,occupation,nativeCountry,country,bankName,bankAccountNo,idType,idNumber,homePhone,idIssueDate
				,idExpiryDate,sourceOfFund,verifyDoc1,verifyDoc2,verifyDoc3,SelfieDoc,referelCode,createdBy,createdDate,isActive,onlineUser,customerPassword,[address]
				,city,state2,customerType,agreeYn
			)
			SELECT fullName,CMT.firstName,mobile,email,gender,dob,CMT.occupation,nativeCountry,country,bankName,bankAccountNo,idType,idNumber,CMT.homePhone,
				CMT.idIssueDate,idExpiryDate,sourceOfFund,verifyDoc1,verifyDoc2,verifyDoc3,CMT.selfie,CMT.referelCode,CMT.createdBy,GETDATE(),'Y','Y',customerPassword,[address]
				,state2,state2,4701,CMT.agreeYn
			FROM dbo.CustomerMasterTemp AS CMT(NOLOCK)
			WHERE CMT.customerId = @customerId

			SET @cust = @@IDENTITY				
			UPDATE dbo.mobile_userRegistration SET customerId = @cust WHERE username = @username

			DELETE FROM customerMasterTemp WHERE username = @username

			COMMIT TRANSACTION 
			IF @@TRANCOUNT=0
			BEGIN
				SELECT  0 as ERRORCODE, 'KYC Submitted successfully' AS MSG, @userName AS ID,@cust AS EXTRA
				--SELECT 
				--	 errorCode='0'
				--	,userId=@userName
				--	,firstName=ISNULL(cm.firstName, '')
				--	,middleName=ISNULL(cm.middleName, '')
				--	,lastName=ISNULL(cm.lastName1,'')
				--	,fullname=ISNULL(cm.firstName, '') + ISNULL(' ' + cm.middleName, '') + ISNULL(' ' + cm.lastName1, '') 
				--	,mobileNumber=ISNULL(mobile,'') 
				--	,email=ISNULL(email,'') 
				--	,gender=ISNULL(sv.detailTitle,'')  
				--	,dateOfBirth=CONVERT(VARCHAR(10),dob,120)
				--	,nativeCountry=ISNULL(com1.countryName,'') 
				--	,country=ISNULL(com.countryName,'') 
				--	,address=ISNULL(address,'') 
				--	,city=ISNULL(city,'') 
				--	,province=ISNULL(cm.state2,'')
				--	,provinceId= cm.state2
				--	,occupation=ISNULL(sdv.detailTitle,'') 
				--	,primaryBankName=ISNULL(bl.BankName,'')
				--	,primaryAccountNumber=ISNULL(cm.bankAccountNo,'') 
				--	,verificationIdType=ISNULL(dv.detailTitle,'') 
				--	,verificationIdNumber=ISNULL(cm.idNumber,'') 
				--	,issueDate=CONVERT(VARCHAR(10),cm.idIssueDate,120) 
				--	,expiryDate=CONVERT(VARCHAR(10),cm.idExpiryDate,120) 
				--	,sourceOfFund=ISNULL(cm.sourceOfFund,'')
				--	,regIdcardFrontUrl=ISNULL(cm.verifyDoc1,'') 
				--	,regIdcardBackUrl=ISNULL(cm.verifyDoc2,'') 
				--	,passbookUrl=ISNULL(cm.verifyDoc3,'') 
				--	,selfieUrl=ISNULL(cm.SelfieDoc,'')
				--	,passportUrl=''
				--FROM dbo.customerMaster cm WITH(NOLOCK)
				--LEFT JOIN dbo.vwBankLists bl WITH(NOLOCK)ON cm.bankName=bl.rowId
				--LEFT JOIN dbo.staticDataValue sdv WITH(NOLOCK)ON cm.occupation=sdv.valueId
				--LEFT JOIN dbo.staticDataValue sv WITH(NOLOCK)ON cm.gender=sv.valueId
				--LEFT JOIN dbo.countryMaster com WITH(NOLOCK)ON cm.country=com.countryId
				--LEFT JOIN dbo.countryMaster com1 WITH(NOLOCK)ON cm.nativeCountry=com1.countryId
				--LEFT JOIN dbo.staticDataValue dv WITH(NOLOCK)ON cm.idType=dv.valueId
				--WHERE customerId=@cust
				RETURN
			END
			 
				EXEC proc_errorHandler 1, 'Failed to Submit KYC', @userName
					-- SELECT errorCode='1'
					--,userId=''
					--,firstName=''
					--,middleName=''
					--,lastName=''
					--,fullname=''
					--,mobileNumber=''
					--,email=''
					--,gender=''
					--,dateOfBirth=''
					--,nativeCountry=''
					--,country=''
					--,address=''
					--,city=''
					--,province=''
					--,provinceId=''
					--,occupation=''
					--,primaryBankName=''
					--,primaryAccountNumber=''
					--,verificationIdType='' 
					--,verificationIdNumber='' 
					--,issueDate=''
					--,expiryDate=''
					--,sourceOfFund=''
					--,regIdcardFrontUrl='' 
					--,regIdcardBackUrl=''
					--,passbookUrl=''
					--,passportUrl=''
					--,selfieUrl=''
				RETURN
			 
	END
	IF @flag = 'i-V2'
	BEGIN  
				--CHECK FOR customer IN temp table  
		SELECT @customerId = customerId FROM customerMasterTemp with (nolock) WHERE username = @userName  
  
  --PRINT @userName
  --PRINT @customerId
		IF @customerId IS NULL  
		BEGIN  
			IF EXISTS(SELECT TOP 1 'A' FROM customerMaster(NOLOCK) WHERE EMAIL = @userName)  
		    BEGIN  
				SELECT @errorMsg = 'It looks like you are already registered in GME system!'  
				EXEC proc_errorHandler 1, @errorMsg, @userName  
				RETURN  
		    END  
	   END  
	   
  
		BEGIN TRANSACTION  
			UPDATE dbo.customerMasterTemp SET   
				firstName	=	@fullName,  
				fullName	=	@fullName,  
				nickName	=	@nickName, 
				homePhone	=	@verificationIdNumber,  
				email		=	@userName,  
				customerEmail = @email,
				gender		=	CASE WHEN UPPER(@gender) = 'M' THEN '97' WHEN UPPER(@gender) = 'F' THEN '98' ELSE '99' END ,  
				dob			=	@dateOfBirth,  
				country		=	@country,  
				[address]	=	@address,  
				city		=	@city,  
				state2		=	@province,  
				occupation	=	@occupation,  
				bankName	=	@primaryBankName,  
				bankAccountNo=	@primaryAccountNumber,  
				idNumber	=	@verificationIdNumber,  
				idType		=	@verificationIdType,  
				idIssueDate	=	@issueDate,  
				createdDate	=	GETDATE(),  
				sourceOfFund=CASE WHEN @sourceOfFund IS NOT NULL   
				      THEN (SELECT TOP 1 sd.detailTitle FROM dbo.staticDataValue sd(NOLOCK) WHERE sd.valueId=@sourceOfFund)  
				      ELSE sourceOfFund  
				      END,  
				idExpiryDate=	@expiryDate,  
				verifyDoc1	=	@regIdcardFrontUrl,  
				verifyDoc2	=	@regIdcardBackUrl,  
				verifyDoc3	=	@passbookUrl,  
				verifyDoc4	=	@passportUrl,  
				selfie		=	@selfieUrl,  
				referelCode	=	@referralCode  
		 WHERE customerId = @customerId  
  
   INSERT INTO dbo.customerMaster  
   (  
    fullName,firstName,mobile,email,customerEmail,gender,dob,occupation,nativeCountry,country,bankName,bankAccountNo,idType,idNumber,homePhone,idIssueDate  
    ,idExpiryDate,sourceOfFund,verifyDoc1,verifyDoc2,verifyDoc3,SelfieDoc,referelCode,createdBy,createdDate,isActive,onlineUser,customerPassword,[address]  
    ,city,state2,customerType  
   )  
   SELECT fullName,CMT.firstName,mobile,email,customerEmail,gender,dob,CMT.occupation,nativeCountry,country,bankName,bankAccountNo,idType,idNumber,CMT.homePhone,  
    CMT.idIssueDate,idExpiryDate,sourceOfFund,verifyDoc1,verifyDoc2,verifyDoc3,CMT.selfie,CMT.referelCode,CMT.createdBy,GETDATE(),'Y','Y',customerPassword,[address]  
    ,city,state2,4701  
   FROM dbo.CustomerMasterTemp AS CMT(NOLOCK)  
   WHERE CMT.customerId = @customerId  
  
   SET @cust = @@IDENTITY      
   UPDATE dbo.mobile_userRegistration SET customerId = @cust WHERE username = @username  
  
   DELETE FROM customerMasterTemp WHERE username = @username 
  
   COMMIT TRANSACTION   
   IF @@TRANCOUNT=0  
   BEGIN  
		SELECT  0 as ERRORCODE, 'KYC Submitted successfully' AS MSG, @userName AS ID,@cust AS EXTRA  
		RETURN  
   END  
      
   EXEC proc_errorHandler 1, 'Failed to Submit KYC', @userName  
   RETURN  
      
 END  
	IF @flag='u'
	BEGIN
		IF (YEAR(GETDATE()) - YEAR(@dateOfBirth) < 16)   
        BEGIN  
			EXEC proc_errorHandler 1, 'Customer Not Eligible', @userName  
			RETURN  
		END
		
		----OR cm.mobile=@userName not aplicable 
		IF NOT EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(NOLOCK) cm WHERE cm.email = @userName )
		BEGIN
			SELECT @errorMsg = 'Customer with userId ' + @userName + ' does not exists.'  
			EXEC proc_errorHandler 1, @errorMsg, @userName 
			RETURN
		END

		SELECT 
			@customerId=cm.customerId
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email = @userName 
		--OR cm.mobile=@userName

		BEGIN TRANSACTION
			UPDATE dbo.customerMaster SET 
				firstName	=	ISNULL(@fullName,fullName),
				fullName	=	ISNULL(@fullName,fullName),
				----nickName=ISNULL(@nickName,nickName),
				mobile		=	ISNULL(@mobileNumber,mobile),
				email		=	ISNULL(@email,email),
				gender		=	ISNULL(@gender,gender),
				dob			=	ISNULL(@dateOfBirth,dob),
				nativeCountry=	ISNULL(@nativeCountry,nativeCountry),
				country		=	ISNULL(@country,country),
				[address]	=	ISNULL(@address,[address]),
				city		=	ISNULL(@city,city),
				state2		=	CASE WHEN @province IS NOT NULL 
									THEN (SELECT TOP 1  cim.cityName FROM dbo.CityMaster cim(NOLOCK) WHERE cim.cityId=@province)
								ELSE state2
								END,
				occupation	=	ISNULL(@occupation,occupation),
				bankName	=	ISNULL(@primaryBankName,bankName),
				bankAccountNo=	ISNULL(@primaryAccountNumber,bankAccountNo),
				idNumber	=	ISNULL(@verificationIdNumber,idNumber),
				idType		=	ISNULL(@verificationIdType,idType),
				idIssueDate	=	ISNULL(@issueDate,idIssueDate),
				sourceOfFund=	CASE WHEN @sourceOfFund IS NOT NULL 
								  THEN (SELECT TOP 1 sd.detailTitle FROM dbo.staticDataValue sd(NOLOCK) WHERE sd.valueId=@sourceOfFund)
							      ELSE sourceOfFund
							 END,
				idExpiryDate=	ISNULL(@expiryDate,idExpiryDate),
				verifyDoc1	=	ISNULL(@regIdcardFrontUrl,verifyDoc1),
				verifyDoc2	=	ISNULL(@regIdcardBackUrl,verifyDoc2),
				verifyDoc3	=	ISNULL(@passbookUrl,verifyDoc3),
				SelfieDoc	=	ISNULL(@selfieUrl,SelfieDoc)
			FROM customermaster(NOLOCK) cust
			WHERE cust.customerId=@customerId

		IF @@TRANCOUNT>0
			COMMIT TRANSACTION
			SELECT  errorCode	='0'
					,userId		=@userName
					,firstName=ISNULL(cm.firstName, '')
					,middleName=ISNULL(cm.middleName, '')
					,lastName=ISNULL(cm.lastName1,'')
					,fullname	=ISNULL(cm.firstName, '') + ISNULL(' ' + cm.middleName, '') + ISNULL(' ' + cm.lastName1, '') 
					,nickName	= ''
					,mobileNumber=ISNULL(mobile,'') 
					,email=ISNULL(email,'') 
					,gender=ISNULL(sv.detailTitle,'') 
					,dateOfBirth=CONVERT(VARCHAR(10),dob,120) 
					,nativeCountry=ISNULL(com1.countryName,'') 
					,country=ISNULL(com.countryName,'') 
					,[address]=ISNULL([address],'') 
					,city=ISNULL(city,'') 
					,province=ISNULL(cm.state2,'')
					,provinceId=ISNULL(cim.cityId,'')
					,occupation=ISNULL(sdv.detailTitle,'') 
					,primaryBankName='Fast Remit Bank'--bl.BankName
					,primaryAccountNumber=ISNULL(cm.bankAccountNo,'') 
					,verificationIdType=ISNULL(dv.detailTitle,'') 
					,verificationIdNumber=ISNULL(cm.idNumber,'') 
					,issueDate=CONVERT(VARCHAR(10),cm.idIssueDate,120) 
					,expiryDate=CONVERT(VARCHAR(10),cm.idExpiryDate,120) 
					,sourceOfFund=ISNULL(cm.sourceOfFund,'')
					,regIdcardFrontUrl=ISNULL(cm.verifyDoc1,'') 
					,regIdcardBackUrl=ISNULL(cm.verifyDoc2,'') 
					,passbookUrl=ISNULL(cm.verifyDoc3,'') 
					,passportUrl=''
					,selfieUrl=ISNULL(cm.SelfieDoc,'')
			FROM (SELECT TOP 1 * FROM dbo.customerMaster(NOLOCK) cm WHERE cm.customerId = @customerId)cm
			LEFT JOIN dbo.vwBankLists(NOLOCK) bl ON cm.bankName=bl.bankCode
			LEFT JOIN mobile_userRegistration(NOLOCK) v  ON cm.customerId=v.customerId  
			LEFT JOIN dbo.staticDataValue(NOLOCK) sdv ON cm.occupation=sdv.valueId
			LEFT JOIN dbo.staticDataValue(NOLOCK) sv ON cm.gender=sv.valueId
			LEFT JOIN dbo.countryMaster(NOLOCK) com ON cm.country=com.countryId
			LEFT JOIN dbo.staticDataValue(NOLOCK) dv ON cm.idType=dv.valueId
			LEFT JOIN dbo.countryMaster(NOLOCK) com1 ON cm.nativeCountry=com1.countryId
			LEFT JOIN dbo.CityMaster cim(NOLOCK) ON LTRIM(RTRIM(cim.cityName))=LTRIM(RTRIM(cm.state2))
			--WHERE cm.customerId = @customerId
			RETURN
	END

	IF @flag='s'
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(NOLOCK) cm WHERE cm.email=@userName OR cm.mobile=@userName)
		BEGIN  
			SELECT @errorMsg = 'Customer with userId ' + @userName + ' does not exists.'  
			EXEC proc_errorHandler 1, @errorMsg, @userName 
			RETURN  
		END

		SELECT 
			@customerId=cm.customerId
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email = @userName OR cm.mobile = @userName

		SELECT 
			errorCode='0'
			,userId		=	@userName
			,firstName	=	ISNULL(cm.firstName, '')
			,middleName	=	''
			,lastName	=	''
			,fullname	=	ISNULL(cm.fullName, '')
			,nickName	=	''
			,mobileNumber=	ISNULL(mobile,'') 
			,email		=	ISNULL(email,'') 
			,gender		=	ISNULL(sv.detailTitle,'') 
			,dateOfBirth=	CONVERT(VARCHAR(10),dob,120) 
			,nativeCountry=	ISNULL(com1.countryName,'') 
			,country	=	'South Korea' 
			,address	=	ISNULL(address,'') 
			,city		=	ISNULL(city,'') 
			,province	=	ISNULL(cm.state2,'')
			,provinceId	=	ISNULL(cim.cityId,'')
			,occupation	=	ISNULL(sdv.detailTitle,'') 
			,primaryBankName='Fast Remit Bank'--ISNULL(bl.BankName,'')
			,primaryAccountNumber=ISNULL(cm.bankAccountNo,'') 
			,verificationIdType=ISNULL(dv.detailTitle,'') 
			,verificationIdNumber=ISNULL(cm.idNumber,'') 
			,issueDate	=	CONVERT(VARCHAR(10),cm.idIssueDate,120) 
			,expiryDate	=	CONVERT(VARCHAR(10),cm.idExpiryDate,120) 
			,sourceOfFund=	ISNULL(cm.sourceOfFund,'')
			,regIdcardFrontUrl=ISNULL(cm.verifyDoc1,'') 
			,regIdcardBackUrl=ISNULL(cm.verifyDoc2,'') 
			,passbookUrl=	ISNULL(cm.verifyDoc3,'') 
			,selfieUrl	=	ISNULL(cm.SelfieDoc,'')
        FROM (SELECT TOP 1 * FROM dbo.customerMaster cm WITH(NOLOCK) WHERE customerId = @customerId)cm
		LEFT JOIN dbo.vwBankLists bl WITH(NOLOCK) ON cm.bankName = bl.bankCode
		LEFT JOIN dbo.staticDataValue sdv WITH(NOLOCK) ON cm.occupation = sdv.valueId
		LEFT JOIN dbo.staticDataValue sv WITH(NOLOCK) ON cm.gender = sv.valueId
		LEFT JOIN dbo.countryMaster com1 WITH(NOLOCK) ON cm.nativeCountry = com1.countryId
		LEFT JOIN dbo.staticDataValue dv WITH(NOLOCK) ON cm.idType = dv.valueId
		LEFT JOIN dbo.CityMaster cim(NOLOCK) ON cim.cityName = cm.state2
        --WHERE customerId=@customerId
		RETURN
	END
	
	IF @flag='getUser' --customer due deligience(static data values)
	BEGIN
		-- OR cm.mobile=@userName USE IN FUTURE
		IF EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(NOLOCK) cm WHERE cm.email=@userName)
		BEGIN	

			--DECLARE @yearlyLimit VARCHAR(100)=''
			--DECLARE @YearStart DATE, @YearEnd DATETIME

			SELECT @YearStart	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
					,@YearEnd	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)+' 23:59:59'
				
			--deCLARE @CUSTID BIGINT
			SELECT @customerId = customerId FROM dbo.customerMaster(NOLOCK) cm WHERE cm.email = @userName 
			--OR cm.mobile=@userName  USE IN FUTURE
					
			SELECT @totalSend = SUM(ROUND(R.tAmt/(R.sCurrCostRate+R.sCurrHoMargin), 2, 0))
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

			SELECT 
				@customerId=cm.customerId
			FROM dbo.customerMaster(NOLOCK) cm WHERE cm.email = @userName 
			--OR cm.mobile=@userName ## not applicable 

			SELECT 
				 errorCode		=	'0'
				,userId			=	@userName
				,firstName		=	ISNULL(cm.firstName, '')
				,middleName		=	ISNULL(cm.middleName, '')
				,lastName		=	ISNULL(cm.lastName1,'')
				,nickName		=	''
				,email			=	ISNULL(cm.email,'')
				,mobileNumber	=	ISNULL(cm.mobile,'')
				,verificationCode=	ISNULL(ur.OTP,'')
				,VerificationCodeExpiryDate=''
				,createdDate	=	CONVERT(VARCHAR(10),ur.createdDate,120)
				,userRoles		=	''
				,rewardPoint	=	CAST(ISNULL(cm.bonusPoint,0) AS DECIMAL)
				,isActive		=	CASE WHEN ISNULL(cm.isActive,'Y')='Y' THEN 1 ELSE 0 END
				,hasKYC			=	CASE WHEN ISNULL(cm.createdDate,'')<>'' THEN 1 ELSE 0 END
				,isVerified		=	CASE WHEN cm.approvedDate IS NOT NULL THEN 1 ELSE 0 END
				,forgetCode		=	ISNULL(ur.passRecoveryCode,'')
				,ForgetCodeExpiryDate=''
				,primaryBankName=	'Fast Remit Bank'--CASE WHEN cm.customerType='11048' THEN N'WSB (050)' ELSE 'Kwangju Bank (034)' END
				,walletNumber	=	ISNULL(cm.walletAccountNo,'')
				,availableBalance=	@yearlyLimit  --   CAST([dbo].FNAGetCustomerACBal(@userName) AS DECIMAL) --change this with yearly limit after fix in mobile
				,dpUrl			=	''
				,ISNULL(ur.cmRegistrationId,'') cmRegistrationId
				,yearlyLimit	=	FORMAT(@yearlyLimit,'0,00') --@yearlyLimit
			FROM (SELECT TOP 1 * FROM dbo.customerMaster cm WITH(NOLOCK) WHERE customerId = @customerId)cm
			LEFT JOIN dbo.mobile_userRegistration(NOLOCK) ur ON ur.customerId=cm.customerId
			LEFT JOIN dbo.vwBankLists bl WITH(NOLOCK) ON bl.bankCode=cm.bankName
			--WHERE cm.customerId=@customerId
			RETURN
		END 
		ELSE
        BEGIN
			SELECT @errorMsg = 'Customer with userId ' + @userName + ' does not exists.'  
			EXEC proc_errorHandler 1, @errorMsg, @userName 
			RETURN 	
		END
	END

	IF @flag='refresh-customer-info'
	BEGIN
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


			DELETE T FROM customerMaster(NOLOCK)c
			INNER JOIN CustomerMasterTemp t ON c.email=t.email
			AND C.email = @userName

		IF EXISTS(SELECT TOP 1 'A' from CustomerMasterTemp(nolock) where email = @userName AND isActive = 'Y')
		BEGIN

			UPDATE mobile_userRegistration SET 
			appVersion	  = @appVersion
			,phoneBrand	  = @phoneBrand
			,phoneOS 	  = @phoneOS 	
			,deviceId 	  = @fcmId 	
			,osVersion 	  = @osVersion
			WHERE customerId=(SELECT TOP 1 customerId from CustomerMasterTemp(nolock) where email = @userName AND isActive = 'Y')
			SELECT 
				'0'				ErrorCode
				,@userName		userId
				,cust.customerId SenderId
				,@userName		firstName
				,ISNULL(cust.middleName,'') middleName
				,ISNULL(cust.lastName1,'') lastName
				--,ISNULL(cust.nickName,'') nickName
				,ISNULL(cust.email,'') email
				,ISNULL(cust.customerEmail,'')	 AS customerEmail
				,ISNULL(cust.mobile,'') phone
				,CONVERT(VARCHAR(10),cust.dob,120) dob
				--,cust.idType AS idType
				--,cust.idNumber AS idNumber
				,'' AS countryCode
				,CAST(ISNULL(cust.bonusPoint,0) AS DECIMAL) rewardPoint
				,CASE WHEN ISNULL(cust.isActive,'N')='Y' THEN 1 ELSE 0 END active
				,kyc = 0
				,verified = 0
				,'' walletNumber
				,0 availableBalance
				,primaryBankName = VWB.BankName
				,ISNULL(dpUrl,'') dpUrl
				,ISNULL(ur.cmRegistrationId,'') cmRegistrationId
				,ISNULL(co.countryName,'') country
				,'' city
				,'' [address]
				,'' [province]
				,'' [provinceId]
				,CASE WHEN cust.referelCode IS NOT NULL THEN 1 ELSE 0 END isReferred
				,'' sourceId
				,yearlyLimit=FORMAT(@yearlyLimit,'0,00')
				,PennyTestStatus = '2'
				,'' accessTokenRegTime ,'' accessTokenExpTime 
				,redirectTo = @redirectTo
				,cust.referelCode
				,cust.agreeYn
				,primaryBankAccount = CUST.bankAccountNo
			FROM (SELECT TOP 1 * FROM CustomerMasterTemp(NOLOCK) cust WHERE cust.email = @userName)cust
			LEFT JOIN mobile_userRegistration(NOLOCK) ur ON cust.customerId=ur.customerId 
			LEFT JOIN vwBankLists VWB (NOLOCK) ON VWB.rowId = CUST.bankName
			LEFT JOIN countryMaster co(NOLOCK) ON cust.country=co.countryId
			LEFT JOIN dbo.CityMaster cm(NOLOCK) ON cust.state2 = cm.cityName
			--WHERE cust.email = @userName

			RETURN
		END
	    SELECT 
			@customerId=cm.customerId,@IsActive = isActive
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email = @userName

		
		--OR cm.mobile=@userName future use

		DECLARE @hasPennyTestDone VARCHAR(1)='0'
		SELECT @hasPennyTestDone = '1'
		
		IF @customerId IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Unauthorized access found, Please contact GME support', @userName 
			RETURN
		END

		IF EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(NOLOCK) WHERE approvedDate < '2018-12-19' AND customerId = @customerId)
		BEGIN
			SET @hasPennyTestDone = '2'
		END

		SET @hasPennyTestDone = '2'
		IF ISNULL(@IsActive,'N') <> 'Y'
		BEGIN
			EXEC proc_errorHandler 1, 'Your account has blocked, Please contact GME support', @userName 
			RETURN
		END
			SELECT @YearStart	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
					,@YearEnd	= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)+' 23:59:59'
				
			SELECT @totalSend = SUM(ROUND(R.tAmt/(R.sCurrCostRate+R.sCurrHoMargin), 2, 0))
			FROM REMITTRAN R(NOLOCK) 
			INNER JOIN TRANSENDERS T(NOLOCK) ON T.TRANID = R.ID
			AND T.CUSTOMERID = @customerId 
			AND R.TRANSTATUS <> 'Cancel'
			AND R.approvedDate BETWEEN @YearStart AND @YearEnd

			SET @yearlyLimit = (@yearlyLimit - ISNULL(@totalSend, 0))


			UPDATE mobile_userRegistration SET 
			 appVersion	  = @appVersion
			,phoneBrand	  = @phoneBrand
			,phoneOS 	  = @phoneOS 	
			,deviceId 	  = @fcmId 	
			,osVersion 	  = @osVersion
			WHERE customerId=@customerId

		IF NOT EXISTS(SELECT TOP 1 'x' FROM dbo.KFTC_CUSTOMER_MASTER(NOLOCK) WHERE customerId = @customerId) AND 
		EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(nolock) WHERE bankName IN ('3','10') AND idType IN ('10997') AND customerId =  @customerId AND isNULL(IsKftcOnly,'N')='Y') 
		BEGIN
			SET @redirectTo = 'autodebit'
		END

		SELECT 
			'0' ErrorCode
			,@userName userId
			,cust.customerId SenderId
			,ISNULL(cust.firstName,'') firstName
			,ISNULL(cust.middleName,'') middleName
			,ISNULL(cust.lastName1,'') lastName
			--,'' nickName
			,ISNULL(cust.email,'') email
			,ISNULL(cust.customerEmail,'') AS customerEmail
			,ISNULL(cust.mobile,'') phone
			,CONVERT(VARCHAR(10),cust.dob,120) dob
			--,cust.idType AS idType
			--,cust.idNumber AS idNumber
			,cm1.countryCode AS countryCode
			,CAST(ISNULL(cust.bonusPoint,0) AS DECIMAL) rewardPoint
			,CASE WHEN ISNULL(cust.isActive,'N')='Y' THEN 1 ELSE 0 END active
			,CASE WHEN cust.createdDate IS NOT NULL AND (cust.verifyDoc1 IS NOT NULL OR cust.approvedBy IS NOT NULL) THEN 1 ELSE 0 END kyc
			,CASE WHEN cust.ApprovedDate IS NOT NULL THEN 1 ELSE 0 END verified
			,ISNULL(cust.walletAccountNo,'') walletNumber
			,FORMAT([dbo].FNAGetCustomerACBal(cust.email) ,'0,00') availableBalance
			--,ISNULL(bl.BankName,'') primaryBankName
			,primaryBankName=BL.BankName
			,'' dpUrl
			,ISNULL(ur.cmRegistrationId,'') cmRegistrationId
			,ISNULL(co.countryName,'') country
			,ISNULL(cust.city,'') city
			,ISNULL(cust.[address],'') [address]
			,ISNULL(cust.state2,'') [province]
			,ISNULL(cm.cityId,'') [provinceId]
			,CASE WHEN cust.referelCode IS NOT NULL THEN 1 ELSE 0 END isReferred
			,ISNULL(sdv.valueId,'') sourceId
			,yearlyLimit= FORMAT(@yearlyLimit,'0,00')
			,PennyTestStatus = @hasPennyTestDone-----0 not started, 1 requested , 2 completed
			,kcm.accessTokenRegTime 
			,kcm.accessTokenExpTime 
			,redirectTo = @redirectTo
			,cust.referelCode
			,cust.agreeYn  
			,primaryBankAccount = CUST.bankAccountNo
		FROM (SELECT TOP 1 * FROM customerMaster(NOLOCK) cust WHERE cust.customerId = @customerId)cust
		INNER JOIN dbo.countryMaster AS CM1 ON cm1.countryId=cust.nativeCountry
		LEFT JOIN mobile_userRegistration(NOLOCK) ur ON cust.customerId=ur.customerId 
		LEFT JOIN dbo.vwBankLists (NOLOCK) bl ON cust.bankName=bl.rowId
		LEFT JOIN countryMaster co(NOLOCK) ON cust.country=co.countryId
		LEFT JOIN staticDatavalue sdv(NOLOCK) ON cust.sourceOfFund = sdv.detailTitle AND sdv.typeID = '3900' AND ISNULL(sdv.IS_DELETE,'N')='N'
		LEFT JOIN dbo.CityMaster cm(NOLOCK) ON cust.state2 = cm.cityName
		LEFT JOIN dbo.KFTC_CUSTOMER_MASTER(NOLOCK) kcm  ON cust.customerId = kcm.customerId
		--WHERE cust.customerId = @customerId AND ISNULL(sdv.IS_DELETE,'N')='N'	
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
