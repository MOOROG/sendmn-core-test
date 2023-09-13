
ALTER PROC PROC_CHECK_CUSTOMER_REGISTRATION
(
	@flag					VARCHAR(20)
	,@customerName			VARCHAR(150)= NULL
	,@customerIdNo			VARCHAR(20)	= NULL
	,@nativeCountryId		VARCHAR(30)	= NULL
	,@custAdd				VARCHAR(500)= NULL
	,@district				VARCHAR(150)= NULL
	,@custCity				VARCHAR(150)= NULL
	,@custEmail				VARCHAR(150)= NULL
	,@custMobile			VARCHAR(20) = NULL
	,@custDOB				DATETIME    = NULL
	,@placeOfIssue			VARCHAR(80) = NULL
	,@occupation			VARCHAR(150)= NULL
	,@relationId			VARCHAR(50) = NULL
	,@relativeName			VARCHAR(100)= NULL
	,@custGender			VARCHAR(30) = NULL
	,@user					VARCHAR(70) = NULL
	,@custIdissueDate		VARCHAR(15) = NULL
	,@custIdValidDate		DATETIME    = NULL
	,@customerIdType		VARCHAR(40) = NULL
	,@ipAddress				VARCHAR(50) = NULL
	,@customerId			VARCHAR(20)	= NULL	OUT
	,@sCustStreet			VARCHAR(80)	= NULL
	,@sCustLocation			INT			= NULL
	,@sCustomerType			INT			= NULL
	,@sCustBusinessType		INT			= NULL
	,@sCustIdIssuedCountry	INT			= NULL
	,@sCustIdIssuedDate		VARCHAR(25)	= NULL
	,@sfName				VARCHAR(100)	= NULL
	,@smName				VARCHAR(100)	= NULL
	,@slName				VARCHAR(100)	= NULL
	,@zipCode				VARCHAR(30)		= NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN
		IF @flag = 'i'
		BEGIN
			IF ISNULL(@custMobile, '') = ''
			BEGIN
				SET @customerId = '0000'
				RETURN;
			END

			IF EXISTS(SELECT 1 FROM CUSTOMERMASTER (NOLOCK) WHERE REPLACE(idNumber,'-','') = REPLACE(@customerIdNo, '-', ''))
			BEGIN
				SELECT @customerId = customerId FROM customerMaster (NOLOCK) WHERE REPLACE(idNumber,'-','') = REPLACE(@customerIdNo, '-', '')
				RETURN;
			END
			IF EXISTS(SELECT 1 FROM CUSTOMERMASTER (NOLOCK) WHERE email = @custEmail)
			BEGIN
				SELECT @customerId = customerId FROM customerMaster (NOLOCK) WHERE email = @custEmail
				RETURN;
			END
			IF EXISTS(SELECT 1 FROM CUSTOMERMASTER (NOLOCK) WHERE ISNULL(fullName, firstName) = @customerName AND dob = @custDOB)
			BEGIN
				SELECT @customerId = customerId FROM customerMaster (NOLOCK) WHERE ISNULL(fullName, firstName) = @customerName AND dob = @custDOB
				RETURN;
			END

			DECLARE @newMobileNumber VARCHAR(20) = REPLACE(@custMobile, '+', '')
			SET @newMobileNumber = CASE WHEN @newMobileNumber LIKE '81%' THEN STUFF(@newMobileNumber, 1, 2, '') ELSE @newMobileNumber END
			
			SET @newMobileNumber = '%' + @newMobileNumber

			IF EXISTS(SELECT 1 FROM customerMaster (NOLOCK) WHERE mobile LIKE @newMobileNumber)
			BEGIN
				SELECT @customerId = customerId FROM customerMaster (NOLOCK) WHERE mobile LIKE @newMobileNumber
				RETURN;
			END

			DECLARE @newPassword  VARCHAR(10) = RIGHT('0000000' + CAST(CHECKSUM(NEWID()) AS VARCHAR), 7)

			INSERT INTO customerMaster (  
				 firstName, middleName, lastName1, country, [address], district, city, email, homePhone, mobile  
				 ,nativeCountry, dob, placeOfIssue, occupation, relationId, relativeName, gender
				 , fullName, createdBy, createdDate, idIssueDate, idExpiryDate, idType, idNumber ,onlineUser  
				 ,ipAddress ,customerPassword ,customerType	 ,isActive , isForcedPwdChange
				 ,street,[STATE],employeeBusinessType,approvedBy, approvedDate, verifiedBy, verifiedDate, zipCode
			)  
			SELECT    
				@sfName, @smName, @slName, '113', @custAdd, @district, @custCity, @custEmail, @customerIdNo, @custMobile  
				,@nativeCountryId, @custDOB, @sCustIdIssuedCountry, @occupation, @relationId ,@relativeName  ,@custGender 
				,@customerName, @user, GETDATE(), @sCustIdIssuedDate, @custIdValidDate, @customerIdType, @customerIdNo, 'Y'
				,@ipAddress, dbo.FNAEncryptString(@newPassword), @sCustomerType, 'Y', '1'
				,@sCustStreet,@sCustLocation,@sCustBusinessType, @user, GETDATE(), @user, GETDATE(), @zipCode
			
			DECLARE @membershipId VARCHAR(15);

			SET @customerId = SCOPE_IDENTITY();  

            EXEC PROC_GENERATE_MEMBERSHIP_ID @USER = @user,
                @CUSTOMERID = @customerId, @MEMBESHIP_ID = @membershipId OUT;
               
            UPDATE  dbo.customerMaster
            SET     membershipId = @membershipId
            WHERE   customerId = @customerId;

			SET @customerId = SCOPE_IDENTITY()  
		END
	END
END TRY
    BEGIN CATCH
        IF @@TRANCOUNT <> 0
            ROLLBACK TRANSACTION;
		
        DECLARE @errorMessage VARCHAR(MAX);
        SET @errorMessage = ERROR_MESSAGE();
		SET @customerId = '0000'

        EXEC proc_errorHandler 1, @errorMessage, @user;
END CATCH;




