SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROCEDURE MOBILE_PROC_CUSTOMERMASTER_V4
	@flag					VARCHAR(30)
	,@userId				VARCHAR(100)	= NULL	
	,@type					INT				= NULL
	,@firstName				VARCHAR(100)	= NULL
	,@lastName				VARCHAR(100)	= NULL
	,@gender				VARCHAR(15)		= NULL
	,@dob					VARCHAR(10)		= NULL		
	,@email					VARCHAR(100)	= NULL
	,@province			    NVARCHAR(100)	= NULL			
	,@city					NVARCHAR(50)	= NULL	
	,@address				VARCHAR(150)	= NULL
	,@nativeCountry			VARCHAR(20)		= NULL	
	,@bankId				VARCHAR(200)	= NULL
	,@bankAccount			VARCHAR(100)	= NULL
	,@passportNumber		VARCHAR(100)	= NULL 
	,@passportIssueDate		DATETIME		= NULL
	,@passportExpiryDate	DATETIME		= NULL
	,@nationalIdNumber		VARCHAR(30)		= NULL
	,@nationalIdIssueDate	DATETIME		= NULL
	,@nationalIdExpiryDate	DATETIME		= NULL
	,@branch				VARCHAR(20)		= NULL
	,@referralCode			VARCHAR(100)	= NULL
	,@passportPicture		VARCHAR(200)	= NULL
	,@nationalIdFront		VARCHAR(200)	= NULL
	,@nationalIdBack		VARCHAR(200)	= NULL
	,@Occupation			VARCHAR(100)	= NULL			
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @errorMsg		VARCHAR(MAX)
			,@customerId	BIGINT
			,@cust			BIGINT = NULL
			,@vAction 		VARCHAR(10)
			,@Custdob		VARCHAR(10)
			,@IdType		VARCHAR(100)
			,@country		INT
			,@idFront		VARCHAR(200)
			,@idBack		VARCHAR(200)

	SET @Custdob =@dob
	SET @country=142

	DECLARE @fullName VARCHAR(200) = UPPER(@firstName) + UPPER(ISNULL(' '+@lastName, ''))

	SET @fullName=UPPER(@fullName)
IF @flag = 'i-V4'
	BEGIN 				  
		SELECT TOP 1 @customerId = customerId FROM customerMasterTemp WITH  (NOLOCK) WHERE username = @userId  
		
		 DECLARE @verificationCode varchar(40)  
		 SET @verificationCode = LEFT(NEWID(), 7);
		 SET @IdType='10997' 

	IF @nativeCountry='MN'
	BEGIN
		SET @passportNumber		=	@nationalIdNumber
		SET @passportIssueDate	=	@nationalIdIssueDate
		SET @idFront = @nationalIdFront
		SET @idBack = @nationalIdBack
		SET @passportExpiryDate	=	@nationalIdExpiryDate
	END
	ELSE
	BEGIN
		SET @idFront = @passportPicture
	END

	IF @passportNumber IS NOT NULL 
	BEGIN
			IF EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(NOLOCK) WHERE idNumber = @passportNumber AND email<>@userId ) 
			OR 
			EXISTS(SELECT  TOP 1 'x' FROM dbo.customerMasterTemp(NOLOCK) WHERE idNumber = @passportNumber AND username <> @userId)
			BEGIN
				SELECT  '1' ErrorCode, 'Passport Id number already exist. Please contact GME HO.' Msg, NULL Id, NULL Extra, NULL Extra2
				RETURN
			END
	END
	IF @nationalIdNumber IS NOT NULL 
	BEGIN
			IF EXISTS(SELECT TOP 1 'x' FROM dbo.customerMaster(NOLOCK) WHERE idNumber = @nationalIdNumber AND email<>@userId ) 
			OR 
			EXISTS(SELECT  TOP 1 'x' FROM dbo.customerMasterTemp(NOLOCK) WHERE idNumber = @nationalIdNumber AND username <> @userId)
			BEGIN
				SELECT  '1' ErrorCode, 'National Id number already exist. Please contact GME HO.' Msg, NULL Id, NULL Extra, NULL Extra2
				RETURN
			END
	END
  
   IF(ISDATE(@Custdob)=0) or @Custdob IS NULL
    BEGIN
		EXEC dbo.proc_errorHandler 1,'Invalid DOB found ',@customerId
	    RETURN;
    END
 

	IF @customerId IS NULL  
	BEGIN  
		IF NOT EXISTS (SELECT TOP 1 'A' FROM dbo.customerMaster(NOLOCK) WHERE EMAIL = @userId)
		BEGIN 
			EXEC proc_errorHandler 1, 'Customer doesnot exist in system', @userId  
			RETURN 
		END
		IF EXISTS(SELECT TOP 1 'A' FROM customerMaster(NOLOCK) WHERE EMAIL = @userId)  
			BEGIN  
			
				UPDATE dbo.customerMaster SET   
						fullName		=	@fullName, 
						firstName		=	UPPER(@firstName),
						middleName		=	'',
						lastName1		=	UPPER(@lastName),
						gender			=	CASE WHEN UPPER(@gender) = 'M' THEN '97' WHEN UPPER(@gender) = 'F' THEN '98' ELSE '99' END , 
						dob				=	@Custdob, 
						customerEmail	=	ISNULL(@email,customeremail),  
						homePhone		=	ISNULL(@passportNumber,homePhone), 				 
						DISTRICT		=	ISNULL(@province,DISTRICT),
						city			=	ISNULL(@city,city),
						[address]		=	ISNULL(@address,address),
						occupation		=	ISNULL(@Occupation,occupation),
						bankName		=	ISNULL(@bankId,bankName),  
						bankAccountNo	=	ISNULL(@bankAccount,bankAccountNo),  
						idNumber		=	ISNULL(@passportNumber,idNumber),  
						idType			=	CASE WHEN @nativeCountry='MN' THEN 8008 ELSE 10997 END,  
						idIssueDate		=	ISNULL(@passportIssueDate,idIssueDate),  
						idExpiryDate	=	ISNULL(@passportExpiryDate,idExpiryDate),
						branchId		=	ISNULL(@branch,branchId),
						referelCode		=	ISNULL(@referralCode,referelCode) ,					  
						verifyDoc1		=	ISNULL(@idFront, verifyDoc1),
						verifyDoc2		=   ISNULL(@idBack, verifyDoc2),
						agreeYn			=	agreeYn,
						country			=	@country,
						modifiedBy		=	@userId,
						modifiedDate	=	GETDATE()
				WHERE EMAIL = @userId				  
			END  
	   END 
	   ELSE
	   BEGIN  
			UPDATE dbo.customerMasterTemp SET   
				fullName		=	@fullName, 
				firstName		=	UPPER(@firstName),
				middleName		=	'',
				lastName1		=	UPPER(@lastName),
				gender			=	CASE WHEN UPPER(@gender) = 'M' THEN '97' WHEN UPPER(@gender) = 'F' THEN '98' ELSE '99' END , 
				dob				=	@Custdob,								 											 
				customerEmail	=	ISNULL(@email,customeremail),  
				homePhone		=	ISNULL(@passportNumber,homePhone), 				 
				DISTRICT		=	ISNULL(@province,DISTRICT),
				city			=	ISNULL(@city,city),
				[address]		=	ISNULL(@address,address),
				occupation		=	ISNULL(@Occupation,occupation),
				bankName		=	ISNULL(@bankId,bankName),  
				bankAccountNo	=	ISNULL(@bankAccount,bankAccountNo),  
				idNumber		=	ISNULL(@passportNumber,idNumber),  
				idType			=	CASE WHEN @nativeCountry='MN' THEN 8008 ELSE 10997 END,    
				idIssueDate		=	ISNULL(@passportIssueDate,idIssueDate),  
				idExpiryDate	=	ISNULL(@passportExpiryDate,idExpiryDate),
				branchId		=	ISNULL(@branch,branchId),
				referelCode		=	ISNULL(@referralCode,referelCode) ,					  
				verifyDoc1		=	ISNULL(@idFront, verifyDoc1),
				verifyDoc2		=   ISNULL(@idBack, verifyDoc2),
				modifiedBy		=	@userId,
				modifiedDate	=	GETDATE(),
				agreeYn			=	agreeYn,
				country			=	@country
			WHERE customerId = @customerId  
	
		IF @type IN(1,2)
		 BEGIN
			IF EXISTS(SELECT TOP 1 'X' FROM customerMaster with (nolock) WHERE email = @userId  and ISNULL(onlineUser, 'N')='Y' and isnull(isDeleted,'N')='N' )  
			BEGIN  
				SELECT @errorMsg = 'Customer with same ID ' + @userId + ' already exist.'  
				EXEC proc_errorHandler 1, @errorMsg, @customerId 
				RETURN  
			END  
			
			IF EXISTS(SELECT TOP 1 'X' FROM customerMaster with (nolock) WHERE replace(idNumber,'-','') = replace(@passportNumber, '-', '') )  
			BEGIN  
				SELECT @errorMsg = 'Customer with idnumber ' + @passportNumber + ' already exist.'  
				EXEC proc_errorHandler 1, @errorMsg, @customerId 
				RETURN  
			END
			 -- check for customer with same Name and same DOB
		  IF EXISTS(SELECT TOP 1 'X' FROM customerMaster WITH(NOLOCK)  WHERE fullName =@fullName AND dob=@dob  AND 
					ISNULL(onlineUser, 'N')='Y' and isnull(isDeleted,'N')='N')
			BEGIN
				SELECT @errorMsg = 'It looks like you have already registered with GME. <br>
				Please contact us  on +02-3673-5559 or e-mail us at support@gmeremit.com for any assistance.'
				EXEC proc_errorHandler 1, @errorMsg, @customerId
				RETURN
			END
			INSERT INTO dbo.customerMaster  
			   (  
				fullName,firstName,middleName,lastName1,lastname2,mobile,email,customerEmail,gender,dob,nativeCountry,city,[address],country,bankName,bankAccountNo,idType,idNumber,homePhone,idIssueDate  
				,idExpiryDate,sourceOfFund,verifyDoc1,verifyDoc2,referelCode,createdBy,createdDate,isActive,onlineUser,customerPassword  
				,customerType  ,verificationCode,anotherIDType,anotherIDNumber,anotherIDIssueDate,anotherIDExpiryDate, agreeYn,occupation, DISTRICT
			   )  
			   SELECT fullName,CMT.firstName,CMT.middleName,CMT.lastName1,lastname2,mobile,email,customerEmail,gender,dob,nativeCountry,CMT.city,CMT.address,118,bankName,bankAccountNo,idType,idNumber,CMT.homePhone,  
					CMT.idIssueDate,idExpiryDate,sourceOfFund,verifyDoc1,verifyDoc2,CMT.referelCode,CMT.createdBy,GETDATE(),'Y','Y',customerPassword  
					,4701  ,@verificationCode ,anotherIDType,anotherIDNumber,anotherIDIssueDate,anotherIDExpiryDate, agreeYn,CMT.occupation, DISTRICT
			   FROM dbo.CustomerMasterTemp AS CMT(NOLOCK)  
			   WHERE CMT.customerId = @customerId  
  
			   SET @cust = @@IDENTITY      
			   UPDATE dbo.mobile_userRegistration SET customerId=@cust WHERE username=@userId  
			     
			   DELETE FROM customerMasterTemp WHERE username=@userId 			 		  

		END
	 END	
	 
		SELECT  0 as ERRORCODE, 'KYC Submitted successfully' AS MSG, @userId AS ID,@cust AS EXTRA  
		RETURN  		 
    END
      
   EXEC proc_errorHandler 1, 'Failed to Submit KYC', @userId  
   RETURN  

END TRY
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE() 
	 SELECT '1' ErrorCode, @errorMessage Msg ,NULL ID
END CATCH
GO