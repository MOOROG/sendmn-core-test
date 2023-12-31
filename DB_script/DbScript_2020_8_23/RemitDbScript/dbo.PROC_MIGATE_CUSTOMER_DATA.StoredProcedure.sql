USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MIGATE_CUSTOMER_DATA]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[PROC_MIGATE_CUSTOMER_DATA]
(
    @flag						VARCHAR(10)
   ,@user						VARCHAR(30)
   ,@customerId					BIGINT			=	NULL
   ,@membershipId				VARCHAR(50)		=	NULL
   ,@firstName					VARCHAR(100)	=	NULL
   ,@middleName					VARCHAR(100)	=	NULL
   ,@lastName1					VARCHAR(100)	=	NULL
   ,@lastName2					VARCHAR(100)	=	NULL
   ,@fullName					VARCHAR(500)	=	NULL
   ,@mobile						VARCHAR(100)	=	NULL
   --,@country					INT				=	NULL
   ,@state						VARCHAR(100)	=	NULL
   ,@zipCode					VARCHAR(50)		=	NULL
   ,@city						VARCHAR(100)	=	NULL
   ,@email						VARCHAR(150)	=	NULL
   ,@homePhone					VARCHAR(100)	=	NULL
   ,@nativeCountry				VARCHAR(100)	=	NULL
   ,@dob						DATETIME		=	NULL
   ,@customerType				VARCHAR(100)	=	NULL
   ,@occupation					VARCHAR(100)	=	NULL
   ,@createdBy					VARCHAR(50)		=	NULL
   ,@createdDate				DATETIME		=	NULL
   ,@modifiedBy					VARCHAR(30)		=	NULL
   ,@modifiedDate				VARCHAR(30)		=	NULL
   ,@approvedBy					VARCHAR(30)		=	NULL
   ,@approvedDate				VARCHAR(30)		=	NULL
   ,@idExpiryDate				DATETIME		=	NULL
   ,@idType						VARCHAR(100)	=	NULL
   ,@idNumber					VARCHAR(50)		=	NULL
   ,@telNo						VARCHAR(20)		=	NULL
   ,@gender						VARCHAR(10)		=	NULL
   ,@idIssueDate				DATETIME		=	NULL
   ,@onlineUser					CHAR(1)			=	NULL
   ,@customerPassword			VARCHAR(100)	=	NULL
   ,@isActive					CHAR(1)			=	NULL
   ,@sourceOfFund				VARCHAR(100)	=	NULL
   ,@street						VARCHAR(80)		=	NULL
   ,@streetUnicode				NVARCHAR(100)	=	NULL
   ,@cityUnicode				NVARCHAR(100)	=	NULL
   ,@visaStatus					VARCHAR(100)	=	NULL
   ,@employeeBusinessType		VARCHAR(100)	=	NULL
   ,@nameOfEmployeer			VARCHAR(80)		=	NULL
   ,@SSNNO						VARCHAR(20)		=	NULL
   ,@remittanceAllowed			CHAR(1)			=	NULL
   ,@remarks					VARCHAR(800)	=	NULL
   ,@registrationNo				VARCHAR(30)		=	NULL
   ,@organizationType			VARCHAR(100)	=	NULL
   ,@natureOfCompany			VARCHAR(100)	=	NULL
   ,@monthlyIncome				VARCHAR(50)		=	NULL
   ,@dateofIncorporation		DATETIME		=	NULL 
   ,@position					VARCHAR(100)	=	NULL
   ,@nameOfAuthorizedPerson		VARCHAR(80)		=	NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY 
	IF @FLAG = 'I'
		DECLARE @nativeCountryId INT=NULL,
				@customerTypeId INT=NULL,
				@occupationId INT =NULL,
				@sourceOfFundId INT =NULL,
				@idTypeId INT =NULL,
				@visaStatusId INT =NULL,
				@stateId INT =NULL,
				@employeeBusinessTypeId INT =NULL,
				@organizationTypeId INT =NULL,
				@natureOfCompanyId INT=NULL,
				@positionId INT =NULL,
				@newCustomerId BIGINT =NULL

		BEGIN
			
			IF EXISTS(SELECT 1 FROM dbo.customerMaster WHERE obpId=@customerId)
			BEGIN
				EXEC dbo.proc_errorHandler 1, 'Customer Information Already Exists On System.', @customerId 
				RETURN;
			END

			SELECT @nativeCountryId= countryId FROM dbo.countryMaster WHERE countryName=@nativeCountry;
			
			IF @nativeCountryId IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'Native country Name Not Match',@id = @customerId ;
				RETURN;
			END

			IF @customerType IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'Customer Type Is Required',@id = @customerId ;
				RETURN;
			END

			SELECT @customerTypeId = CASE @customerType 
									 WHEN 'Individual' THEN '4700'
									 WHEN 'Organizational' THEN '4701'
									 WHEN 'Business Visa' THEN '11146'
									 WHEN 'student' THEN '11147'
									 WHEN 'Company Employee' THEN '11148'
									 WHEN 'Designated Activities' THEN '11149'
									 WHEN 'Resident' THEN '11150'
									 WHEN 'Dependent' THEN '11151'
									 WHEN 'Dependent of Japanese' THEN '11152'
									 WHEN 'Other' THEN '11153'
									 WHEN 'Permanent Resident, Non-Resident' THEN '11154'									 
									 WHEN 'Non-Resident' THEN '11155'
									 WHEN 'Sole Proprietor' THEN '11156'
									 WHEN 'Dependent, Non-Resident' THEN '11157'
									 WHEN 'Permanent Resident' THEN '11158'
									 WHEN 'Training' THEN '11159'
									 WHEN 'Japanese Citizen' THEN '11160'
									 WHEN 'Designated Activities, Non-Resident' THEN '11161'
									 WHEN 'Other, Non-Resident' THEN '11162'
									 WHEN 'Company Employee, Non-Resident' THEN '11163'
									 WHEN 'Skilled Labour' THEN '11164'
									 WHEN 'student, Non-Resident' THEN '11165'
									 WHEN 'Long Term resident' THEN '11166'
									 ELSE NULL END;
			
			SELECT @occupationId = CASE @occupation
								   WHEN 'BUSINESS OWNER' THEN '8080'
								   WHEN 'STUDENT' THEN '8084'
								   WHEN 'DEPENDENT' THEN '4701'
								   WHEN 'COMPANY EMPLOYEE' THEN '4701'
								   WHEN 'UNEMPLOYED' THEN '4701'
								   WHEN 'TRAINEE' THEN '8083'
								   WHEN 'Others (please specific in remark)' THEN '2012'
								   WHEN 'Part Time Job Holder' THEN '4701'
								   WHEN 'HOUSE WIFE' THEN '8085'
								   ELSE NULL END;
						
			IF @idType IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'Customer Id Type Is Required',@id = @customerId ;
				RETURN;
			END
									
			SELECT @idTypeId =	CASE @idType
								WHEN 'Passport' THEN '10997'
								WHEN 'Insurance Card' THEN '11078'
								WHEN 'Driver License' THEN '11079'
								WHEN 'Residence Card' THEN '8008'
								WHEN 'Tohon' THEN '11080'
								WHEN 'Company Registration No' THEN '10988'
								ELSE NULL END;

			IF @sourceOfFund IS NOT NULL
			BEGIN
				SELECT @sourceOfFundId = CASE @sourceOfFund
										 WHEN 'Salary' THEN '3901'
										 WHEN 'Business Income' THEN '3902'
										 WHEN 'Return from Investment' THEN '11167'
										 WHEN 'Borrow from others-Loan' THEN '8076'
										 WHEN 'Others (please specific in remark)' THEN '11070'
										 WHEN 'Accumulated Salary' THEN '8073'
										 ELSE NULL END;
			END
			IF @visaStatus IS NOT NULL
			BEGIN
				SELECT @visaStatusId =	CASE @visaStatus
										WHEN 'Student Visa' THEN '11034'
										WHEN 'Company Employee' THEN '11021'
										WHEN 'Business Visa' THEN '11019'
										WHEN 'Permanent Resident' THEN '11033'
										WHEN 'Dependent' THEN '11022'
										WHEN 'Training' THEN '11035'
										WHEN 'Designated Activities' THEN '11024'
										WHEN 'Other' THEN '11032'
										WHEN 'Japanese Citizen' THEN '11030'
										WHEN 'Long Term Resident' THEN '11031'
										WHEN 'Dependent of Japanese' THEN '11023'
										ELSE NULL END;
			END
			
			SELECT @stateId= stateId FROM dbo.countryStateMaster WHERE countryId=113 and stateName=@state;
			IF @stateId IS NULL
			BEGIN
				EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'State Name Not Match',@id = @customerId ;
				RETURN;
			END

			IF @employeeBusinessType IS NOT NULL
			BEGIN
				SELECT @employeeBusinessTypeId = CASE @employeeBusinessType
												 WHEN 'Emplyeed' THEN '11007'
												 WHEN 'Self-Employee' THEN '11008'
												 WHEN 'Unemployee' THEN '11009'
												 ELSE NULL END;
			END

			IF @organizationType IS NOT NULL
			BEGIN
				SELECT @organizationTypeId = CASE @organizationType
											 WHEN 'Manufacturer' THEN '11010'
											 WHEN 'Trade Business' THEN '11011'
											 WHEN 'Service Provider' THEN '11012'
											 WHEN 'Other' THEN '11013'
											 ELSE NULL END;
			END

			IF @natureOfCompany IS NOT NULL
			BEGIN
				SELECT @natureOfCompanyId =	CASE @natureOfCompany
											WHEN 'Sole Proprietor' THEN '11017'
											WHEN 'Partnership' THEN '11018'
											ELSE NULL END;
			END
			---not map
			IF @position IS NOT NULL
			BEGIN
				SELECT @positionId = CASE @position
									 WHEN 'BUSINESS OWNER' THEN '8080'
									 WHEN 'HOUSE WIFE' THEN '8085'
									 ELSE NULL END;
			END
			SET @customerPassword = DBO.FNAENCRYPTSTRING('jme@123')
		    SET @fullName=@firstName+ISNULL(' '+@middleName,'')+ISNULL(' '+@lastName1,'')+ISNULL(' '+@lastName2,'');
			INSERT  INTO customerMaster(
							firstName,middleName,lastName1,lastName2,country,zipCode,city,email,homePhone,mobile,nativeCountry,dob,occupation,gender,
							fullName,
							createdBy,createdDate,idIssueDate,idExpiryDate,idType,idNumber,telNo,onlineUser,customerPassword,
							customerType,isActive,verifiedBy,verifiedDate,isForcedPwdChange,membershipId,[state],sourceOfFund,street,streetUnicode,cityUnicode,
							visaStatus,employeeBusinessType,nameOfEmployeer,SSNNO,remittanceAllowed,remarks,registerationNo,organizationType,
							dateofIncorporation,natureOfCompany,position,nameOfAuthorizedPerson,monthlyIncome,obpId,isDeleted
						)
                        VALUES (
							@firstName,@middleName,@lastName1,@lastName2,113,@zipCode,@city,@email,@homePhone,@mobile,@nativeCountryId,@dob,@occupationId ,case @gender when 'Male' then 97 
																																										when 'Female' then 98 else 99 end,
							ISNULL(@firstName, '') + ISNULL(' '+ @middleName,'') + ISNULL(' '+ @lastName1, '')+ ISNULL(' ' + @lastName2, ''),
                            @user, @createdDate,@idIssueDate,@idExpiryDate,@idTypeId,@idNumber,@telNo,@onlineUser,@customerPassword,
							@customerTypeId,@isActive,@user,GETDATE(),1,NULL,@stateId,@sourceOfFundId,@street,@streetUnicode,@cityUnicode,
							@visaStatusId,@employeeBusinessTypeId,@nameOfEmployeer,@SSNNO,CASE WHEN @remittanceAllowed='y' THEN 1 ELSE 0 end,@remarks,@registrationNo,@organizationTypeId,
							@dateofIncorporation,@natureOfCompanyId,@positionId,@nameOfAuthorizedPerson,@monthlyIncome,@customerId,'Y' 
						)

			SET @newCustomerId = SCOPE_IDENTITY(); 
            
			EXEC PROC_GENERATE_MEMBERSHIP_ID @USER = @user,
                    @CUSTOMERID = @newCustomerId, @MEMBESHIP_ID = @membershipId OUT;
               
            UPDATE  dbo.customerMaster
            SET     membershipId = @membershipId
            WHERE   customerId = @newCustomerId;
			SELECT  '0' errorCode ,'Customer Successfully added.' msg ,id = @customerId;
            RETURN; 
		END
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  
    DECLARE @errorMessage VARCHAR(MAX);  
    SET @errorMessage = ERROR_MESSAGE();  
    EXEC proc_errorHandler 1, @errorMessage, null;  
END CATCH; 


GO
