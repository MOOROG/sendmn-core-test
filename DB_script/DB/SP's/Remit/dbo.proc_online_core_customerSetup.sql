SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC [dbo].[proc_online_core_customerSetup]
    @flag						VARCHAR(50)			=	NULL,
    @user						VARCHAR(30)			=	NULL,
    @customerId					VARCHAR(30)			=	NULL,
    @fullName					NVARCHAR(200)		=	NULL,
    @passportNo					VARCHAR(30)			=	NULL,
    @mobile						VARCHAR(15)			=	NULL,
    @firstName					VARCHAR(100)		=	NULL,
    @middleName					VARCHAR(100)		=	NULL,
    @lastName1					VARCHAR(100)		=	NULL,
    @lastName2					VARCHAR(100)		=	NULL,
    @customerIdType				VARCHAR(30)			=	NULL,
    @customerIdNo				VARCHAR(50)			=	NULL,
    @custIdissueDate			VARCHAR(30)			=	NULL,
    @custIdValidDate			VARCHAR(30)			=	NULL,
    @custDOB					VARCHAR(30)			=	NULL,
    @custTelNo					VARCHAR(30)			=	NULL,
    @custMobile					VARCHAR(30)			=	NULL,
    @custCity					VARCHAR(100)		=	NULL,
    @custPostal					VARCHAR(30)			=	NULL,
    @companyName				VARCHAR(100)		=	NULL,
    @custAdd1					VARCHAR(100)		=	NULL,
    @custAdd2					VARCHAR(100)		=	NULL,
    @country					VARCHAR(30)			=	NULL,
    @custNativecountry			VARCHAR(30)			=	NULL,
    @custEmail					VARCHAR(50)			=	NULL,
    @custGender					VARCHAR(30)			=	NULL,
    @custSalary					VARCHAR(30)			=	NULL,
    @memberId					VARCHAR(30)			=	NULL,
    @occupation					VARCHAR(30)			=	NULL,
    @state						VARCHAR(30)			=	NULL,
    @zipCode					VARCHAR(30)			=	NULL,
    @district					VARCHAR(30)			=	NULL,
    @homePhone					VARCHAR(30)			=	NULL,
    @workPhone					VARCHAR(30)			=	NULL,
    @placeOfIssue				VARCHAR(30)			=	NULL,
    @customerType				VARCHAR(30)			=	NULL,
    @isBlackListed				VARCHAR(30)			=	NULL,
    @relativeName				VARCHAR(30)			=	NULL,
    @relationId					VARCHAR(30)			=	NULL,
    @lastTranId					VARCHAR(30)			=	NULL,
    @receiverName				VARCHAR(100)		=	NULL,
    @tranId						VARCHAR(20)			=	NULL,
    @ICN						VARCHAR(50)			=	NULL,
    @bank						VARCHAR(100)		=	NULL,
    @bankId						VARCHAR(100)		=	NULL,
    @accountNumber				VARCHAR(100)		=	NULL,
    @mapCodeInt					VARCHAR(10)			=	NULL,
    @sortBy						VARCHAR(50)			=	NULL,
    @sortOrder					VARCHAR(5)			=	NULL,
    @pageSize					INT					=	NULL,
    @pageNumber					INT					=	NULL,
    @HasDeclare					INT					=	NULL,
    @agent						VARCHAR(50)			=	NULL,
    @branch						VARCHAR(50)			=	NULL,
    @branchId					VARCHAR(50)			=	NULL,
    @onlineUser					VARCHAR(50)			=	NULL,
    @ipAddress					VARCHAR(30)			=	NULL,
    @howDidYouHear				VARCHAR(200)		=	NULL,
    @ansText					VARCHAR(200)		=	NULL,
    @isActive					CHAR(1)				=	NULL,
    @email						VARCHAR(150)		=	NULL,
    @searchCriteria				VARCHAR(30)			=	NULL,
    @searchValue				VARCHAR(50)			=	NULL,
    @newPassword				VARCHAR(20)			=	NULL,
    @createdDate				DATETIME			=	NULL,
    @createdBy					VARCHAR(50)			=	NULL,
    @verifyDoc1					VARCHAR(255)		=	NULL,
    @verifyDoc2					VARCHAR(255)		=	NULL,
    @verifyDoc3					VARCHAR(255)		=	NULL,
    @verifyDoc4					VARCHAR(255)		=	NULL,
    @membershipId				VARCHAR(50)			=	NULL,
    @sourceOfFound				VARCHAR(100)		=	NULL,
    @street						VARCHAR(80)			=	NULL,
    @streetUnicode				NVARCHAR(100)		=	NULL,
    @cityUnicode				NVARCHAR(100)		=	NULL,
    @visaStatus					INT					=	NULL,
    @employeeBusinessType		INT					=	NULL,
    @nameOfEmployeer			VARCHAR(80)			=	NULL,
    @SSNNO						VARCHAR(20)			=	NULL,
    @remittanceAllowed			BIT					=	NULL,
    @remarks					VARCHAR(1000)		=	NULL,
    @registerationNo			VARCHAR(30)			=	NULL,
    @organizationType			INT					=	NULL,
    @dateofIncorporation		DATETIME			=	NULL,
    @natureOfCompany			INT					=	NULL,
    @position					INT					=	NULL,
    @nameOfAuthorizedPerson		VARCHAR(80)			=	NULL,
    @fromDate					NVARCHAR(20)		=	NULL,
    @toDate						NVARCHAR(20)		=	NULL,
	@monthlyIncome				VARCHAR(50)			=	NULL,
	@isCounterVisited			CHAR(1)				=	NULL,
	@additionalAddress			VARCHAR(50)			=	NULL,
	@loginBranchId				BIGINT				=	NULL,
	@rowid						BIGINT				=	NULL,
	@docType					INT					=	NULL
AS
    SET NOCOUNT ON;  
    SET XACT_ABORT ON;  
    IF @sortBy = 'SN'
        SET @sortBy = NULL;
    SELECT  @homePhone = @customerIdNo ,
            @accountNumber = REPLACE(@accountNumber, '-', '');

    IF ISNUMERIC(@country) <> '1'
        SET @country = ( SELECT TOP 1
                                countryId
                         FROM   countryMaster WITH ( NOLOCK )
                         WHERE  countryName = @country
                       );  
  
    BEGIN TRY 
        CREATE TABLE #msg
            (
              errorCode INT ,
              msg VARCHAR(100) ,
              id INT
            );	
        DECLARE @sql VARCHAR(MAX) ,
            @oldValue VARCHAR(MAX) ,
            @newValue VARCHAR(MAX) ,
            @module VARCHAR(10) ,
            @tableAlias VARCHAR(100) ,
            @logIdentifier VARCHAR(50) ,
            @logParamMod VARCHAR(100) ,
            @logParamMain VARCHAR(100) ,
            @table VARCHAR(MAX) ,
            @select_field_list VARCHAR(MAX) ,
            @extra_field_list VARCHAR(MAX) ,
            @sql_filter VARCHAR(MAX) ,
            @modType VARCHAR(6) ,
            @errorMsg VARCHAR(MAX) ,
            @bankName VARCHAR(100);  

    
        SELECT  @logIdentifier = 'customerId' ,
                @logParamMain = 'customerMaster' ,
                @module = '20' ,
                @tableAlias = 'CustomerMaster';  
         
 
			SET @fullName = UPPER(@fullName)				
			SET @passportNo = UPPER(@passportNo)					
			SET @firstName = UPPER(@firstName)					
			SET @middleName = UPPER(@middleName)					
			SET @lastName1 = UPPER(@lastName1)					
			SET @lastName2 = UPPER(@lastName2)		
  /***************************************GME Online Core************************************************/
        IF @flag = 'customer-list'
            BEGIN
                IF @sortBy IS NULL
                    SET @sortBy = 'createdDate';
                IF @sortOrder IS NULL
                    SET @sortOrder = 'DESC';
                SET @table = '(
		SELECT
			customerId as Id
			,fullName = ISNULL(firstName, '''') + ISNULL('' '' + middleName, '''') + ISNULL('' '' + lastName1, '''') + ISNULL('' '' + lastName2, '''') 
			,sd.detailTitle as idType
			,ISNULL(cm.idNumber,'''') as idNumber
			,com.countryName
			,cm.city
			,ISNULL(cm.email,'''') as email
			,ISNULL(cm.mobile,'''') as mobile
			,cm.createdDate
			,accountName =cm.bankAccountNo
			,bankName = bl.bankName
		FROM dbo.customerMaster cm(nolock)
		LEFT JOIN dbo.staticDataValue sd(nolock) ON sd.valueId=cm.idType
		INNER JOIN dbo.countryMaster com(nolock) ON com.countryId = cm.nativeCountry
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE 1=1 and cm.approvedDate is null 
		';
		
                IF @createdDate IS NOT NULL
                    SET @table = @table + '  AND cm.createdDate between '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ''' AND '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ' 23:59:59''';
                SET @table = @table + ')x';
                SET @sql_filter = '';
                IF @mobile IS NOT NULL
                    SET @sql_filter = @sql_filter
                        + '  AND REPLACE(idNumber, ''-'', '''') ='''
                        + REPLACE(@mobile, '-', '') + '''';
                --SET @sql_filter = @sql_filter + '  AND mobile ='''+ @mobile + '''';
		
                IF @email IS NOT NULL
                    SET @sql_filter += ' AND  email like ''' + @email + '%''';
                IF @custNativecountry IS NOT NULL
                    SET @sql_filter += ' AND  countryName = '''
                        + @custNativecountry + '''';
                SET @select_field_list = 'id,fullName,idType,idNumber,countryName,city,email,mobile,createdDate,accountName,bankName';
			   
                EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,
     @extra_field_list, @sortBy, @sortOrder, @pageSize,
                    @pageNumber;

                RETURN;
            END;

        IF @flag = 'customer-list-approved'
            BEGIN
                IF @sortBy IS NULL
                    SET @sortBy = 'createdDate';
                IF @sortOrder IS NULL
                    SET @sortOrder = 'DESC';
                SET @table = '(
		SELECT
			customerId as Id
			,fullName = ISNULL(firstName, '''') + ISNULL('' '' + middleName, '''') + ISNULL('' '' + lastName1, '''') + ISNULL('' '' + lastName2, '''') 
			,sd.detailTitle as idType
			,ISNULL(cm.idNumber,'''') as idNumber
			,com.countryName
			,cm.city
			,ISNULL(cm.email,'''') as email
			,ISNULL(cm.mobile,'''') as mobile
			,cm.createdDate
			,accountName =cm.bankAccountNo
			,bankName = bl.bankName
		FROM dbo.customerMaster cm(nolock)
		LEFT JOIN dbo.staticDataValue sd(nolock) ON sd.valueId=cm.idType
		INNER JOIN dbo.countryMaster com(nolock) ON com.countryId = cm.nativeCountry
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE 1=1 and cm.approvedDate is not null 
		';
		
                IF @createdDate IS NOT NULL
                    SET @table = @table + '  AND cm.createdDate between '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ''' AND '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ' 23:59:59''';
                SET @table = @table + ')x';
                SET @sql_filter = '';
                IF @mobile IS NOT NULL
                    SET @sql_filter = @sql_filter
                        + '  AND REPLACE(idNumber, ''-'', '''') ='''
                        + REPLACE(@mobile, '-', '') + '''';
                --SET @sql_filter = @sql_filter + '  AND mobile ='''+ @mobile + '''';
		
                IF @email IS NOT NULL
                    SET @sql_filter += ' AND  email like ''' + @email + '%''';
                IF @custNativecountry IS NOT NULL
                    SET @sql_filter += ' AND  countryName = '''
                        + @custNativecountry + '''';
                SET @select_field_list = 'id,fullName,idType,idNumber,countryName,city,email,mobile,createdDate,accountName,bankName';
			   
                EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,
                    @extra_field_list, @sortBy, @sortOrder, @pageSize,
                    @pageNumber;

                RETURN;
            END;


        IF @flag = 'resetpwd'
            BEGIN
                UPDATE  dbo.customerMaster
                SET     customerPassword = dbo.FNAEncryptString(@newPassword) ,
                        isForcedPwdChange = 1 ,
                        invalidAttemptCount = 0
                WHERE   customerId = @customerId;		
		
                EXEC dbo.proc_errorHandler '0', 'Success!', NULL;
		
                RETURN;
            END;
        IF @flag = 'autosetpwd'
            BEGIN
                SELECT  @mobile = mobile ,
                        @firstName = firstName
                FROM    customerMaster(NOLOCK)
                WHERE   customerId = @customerId;

                SELECT  @newPassword = LOWER(LEFT(@firstName, 1))
                        + LOWER(RIGHT(NEWID(), 6)) + '@G';
                SET @newPassword = REPLACE(@newPassword, 'o', 'z');
                SET @newPassword = REPLACE(@newPassword, '0', '9');
                SET @newPassword = REPLACE(@newPassword, 'i', 'L');

                UPDATE  dbo.customerMaster
                SET     customerPassword = dbo.FNAEncryptString(@newPassword) ,
                        isForcedPwdChange = 0 ,
                        invalidAttemptCount = 0 ,
                        modifiedBy = @user ,
                        modifiedDate = GETDATE()
                WHERE   customerId = @customerId;

                SET @errorMsg = 'Your JME login password is ' + @newPassword;

                EXEC proc_CallToSendSMS @FLAG = 'I', @SMSBody = @errorMsg,
                    @MobileNo = @mobile;

                EXEC dbo.proc_errorHandler '0', 'Success!', @mobile;
		
                RETURN;
            END;
        IF @flag = 'sEmail'
            BEGIN
                SELECT  email
                FROM    dbo.customerMaster (NOLOCK)
                WHERE   customerId = @customerId;
                RETURN;
            END;

        IF @flag = 'modify-list'
            BEGIN
                IF @sortBy IS NULL
                    SET @sortBy = 'createdDate';
                IF @sortOrder IS NULL
                    SET @sortOrder = 'DESC';
                SET @table = '(
	SELECT 
		cm.customerId
		,fullName = cm.firstName
		,sd.detailTitle as idType
		,ISNULL(cm.idNumber,'''') as idNumber
		,ISNULL(cm.email,'''') as email
		,ISNULL(cm.mobile,'''') as mobile
		,cm.createdDate
		,cm.bankAccountNo
		,bankName = bl.bankName
		,cm.walletAccountNo
	FROM dbo.customerMaster cm(nolock)
	LEFT JOIN dbo.staticDataValue sd(nolock) ON sd.valueId=cm.idType
	LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
	WHERE cm.approvedDate is not null and 1=1 
	';
		
                IF @createdDate IS NOT NULL
                    SET @table = @table + '  AND cm.verifiedDate between '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ''' AND '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ' 23:59:59''';
                SET @table = @table + ')x';
                SET @sql_filter = '';
     
                IF ISNULL(@searchCriteria, '') <> ''
                    AND ISNULL(@searchValue, '') <> ''
                    BEGIN 
                        IF @searchCriteria = 'idNumber'
                            BEGIN
                                IF ISNUMERIC(@searchValue) <> 1
                                    SET @searchValue = '-1';	--to ignore string value for datatype integer/customerID
                                SET @sql_filter = @sql_filter
                                    + ' AND customerId = ''' + @searchValue
                                    + '''';
                            END;
                        ELSE
                            IF @searchCriteria = 'emailId'
                                SET @sql_filter = @sql_filter
                                    + ' AND email like ''' + @searchValue
                                    + '%''';
                            ELSE
                                IF @searchCriteria = 'customerName'
                                    SET @sql_filter = @sql_filter
                                        + ' AND fullName like '''
                                        + @searchValue + '%''';
                                ELSE
                                    IF @searchCriteria = 'mobile'
                                        SET @sql_filter = @sql_filter
                                            + ' AND mobile = '''
                                            + @searchValue + '''';
                    END;

                SET @select_field_list = 'customerId,fullName,idType,idNumber,email,mobile,createdDate,bankAccountNo,bankName,walletAccountNo';
			   
                EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,
                    @extra_field_list, @sortBy, @sortOrder, @pageSize,
                    @pageNumber;

                RETURN;
            END;

        IF @flag = 's'
            BEGIN
               
                IF @sortBy IS NULL
                    SET @sortBy = 'createdDate';
                IF @sortOrder IS NULL
                    SET @sortOrder = 'DESC';
                SET @table = '(
		SELECT 
			customerId,
			membershipId
			,fullName =fullName
			,sd.detailTitle as idType
			,ISNULL(cm.idNumber,'''') as idNumber
			,com.countryName,cm.dob,cm.address
			,cm.city
			,ISNULL(cm.email,'''') as email
			,ISNULL(cm.mobile,'''') as mobile
			,cm.createdDate
			,cm.bankAccountNo
			,bankName = bl.bankName
		FROM dbo.customerMaster cm(nolock)
		LEFT JOIN dbo.staticDataValue sd(nolock) ON sd.valueId=cm.idType
		INNER JOIN dbo.countryMaster com(nolock) ON com.countryId = cm.nativeCountry
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE 1=1 ) x';
		
                SET @sql_filter = '';
				 IF ISNULL(@fromDate, '') <> '' AND ISNULL(@toDate, '') <> ''
					SET @sql_filter +=  ' AND createdDate BETWEEN ''' +@fromDate+''' AND ''' +@toDate +' 23:59:59'''
                IF ISNULL(@searchCriteria, '') <> ''
                    AND ISNULL(@searchValue, '') <> ''
                    BEGIN 
                        IF @searchCriteria = 'idNumber'
                            BEGIN
                                SET @sql_filter = @sql_filter
                                    + ' AND REPLACE(idNumber, ''-'', '''') = '''
                                    + REPLACE(@searchValue, '-', '') + '''';
                            END;
                        ELSE
                            IF @searchCriteria = 'emailId'
                                SET @sql_filter = @sql_filter
                                    + ' AND email like ''' + @searchValue
                                    + '%''';
                            ELSE
                                IF @searchCriteria = 'customerName'
                                    SET @sql_filter = @sql_filter
                                        + ' AND fullName like '''
                                        + @searchValue + '%''';
                                ELSE
                                    IF @searchCriteria = 'mobile'
                                        SET @sql_filter = @sql_filter
                                            + ' AND mobile = '''
                                            + @searchValue + '''';
                                    ELSE
                                        IF @searchCriteria = 'bankAccountNo'
                                            SET @sql_filter = @sql_filter
                                                + ' AND bankAccountNo = '''
                                                + @searchValue + '''';
                                        ELSE
                                            IF @searchCriteria = 'nativeCountry'
                                                SET @sql_filter = @sql_filter
                                                    + ' AND countryName = '''
                                                    + @searchValue + '''';
                    END;

		--IF @createdDate IS NOT NULL
  --           SET @table = @table + '  AND cm.createdDate between '''+ CONVERT(VARCHAR,@createdDate,101) + ''' AND '''+ CONVERT(VARCHAR,@createdDate,101) + ' 23:59:59''';
		--	 SET @table=@table+')x'
		--	SET @sql_filter = ''
  --          IF @mobile IS NOT NULL
  --              SET @sql_filter = @sql_filter + '  AND mobile ='''+ @mobile + '''';
		
  --          IF @email IS NOT NULL
  --              SET @sql_filter += ' AND  email=''' + @email+ '''';
		
                SET @select_field_list = 'customerId,membershipId,dob,address,fullName,idType,idNumber,countryName,city,email,mobile,createdDate,bankAccountNo,bankName';
			   
                EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,
                    @extra_field_list, @sortBy, @sortOrder, @pageSize,
                    @pageNumber;

                RETURN;
            END;

        IF @flag = 'customer-register-core'
            BEGIN
			SET @onlineUser = CASE WHEN @onlineUser='true'THEN 'Y' ELSE 'N' END
		  --IF RIGHT(LEFT(@customerIdNo, 7), 1) <> '-'
		  --BEGIN  
		  -- SELECT @errorMsg = 'Invalid Id number ' + @customerIdNo + ', your id number must be similar to XXXXXX-XXXXXXX(Include ''-'' also).'  
		  -- EXEC proc_errorHandler 1, @errorMsg, @customerId 
		  -- RETURN  
		  --END  
			DECLARE @OBP_ID INT = null
			--SELECT @OBP_ID = MAX(CAST(OBPID AS INT)) FROM CUSTOMERMASTER (NOLOCK) 
			--SET @OBP_ID = @OBP_ID + 1
			--postalcode

			
                IF EXISTS (SELECT  'X' FROM customerMaster WITH (NOLOCK)WHERE   email = @custEmail)
                    BEGIN  
                        SELECT  @errorMsg = 'Customer with email '+ @custEmail + ' already exist.';  
                        EXEC proc_errorHandler 1, @errorMsg, @customerId; 
                        RETURN;  
                    END;  
					
                IF EXISTS ( SELECT  'X' FROM   customerMaster WITH (NOLOCK)
									WHERE   email = @custEmail
                                    AND ISNULL(onlineUser, 'N') = 'Y'
                                    AND ISNULL(isDeleted, 'N') = 'N' )
                    BEGIN  
                        SELECT  @errorMsg = 'Customer with email '+ @custEmail + ' already exist.';  
                        EXEC proc_errorHandler 1, @errorMsg, @customerId;  
                        RETURN;  
                    END; 

                IF EXISTS ( SELECT  'x' FROM customerMaster (NOLOCK)
										WHERE   REPLACE(idNumber, '-', '') = REPLACE(@customerIdNo,'-', '') )
                    BEGIN  
                        SELECT  @errorMsg = 'Customer with idnumber '+ @customerIdNo + ' already exist.';  
                        EXEC proc_errorHandler 1, @errorMsg, @customerId;  
                        RETURN;  
                    END; 

				DECLARE @newMobileNumber VARCHAR(20) = REPLACE(@custMobile, '+', '')
				SET @newMobileNumber = CASE WHEN @newMobileNumber LIKE '81%' THEN STUFF(@newMobileNumber, 1, 2, '') ELSE @newMobileNumber END
			
				--SET @newMobileNumber = '%' + @newMobileNumber

    --            IF EXISTS ( SELECT  'X' FROM customerMaster WITH (NOLOCK)
				--					 WHERE   mobile LIKE @newMobileNumber)
    --                BEGIN  
    --                    SELECT  @errorMsg = 'Customer with mobile number '+ @custMobile + ' already exist.';  
    --                    EXEC proc_errorHandler 1, @errorMsg, @customerId;  
    --                    RETURN;  
    --                END; 

                --IF @customerIdType IN (1302,8008)
                --    AND LEN(@customerIdNo) <> 14
                --    BEGIN  
                --        SELECT  @errorMsg = 'Invalid Id number '+ @customerIdNo + ', your id number must be similar to XXXXXX-XXXXXXX(Include ''-'' also).';    
                --        EXEC proc_errorHandler 1, @errorMsg, @customerId;  
                --        RETURN;  
                --    END;

				SELECT @firstName = LTRIM(RTRIM(@firstName))
				       ,@middleName = LTRIM(RTRIM(@middleName))
					   ,@lastName1 = LTRIM(RTRIM(@lastName1))
					   ,@fullName = ISNULL(@firstName, '')
                                    + ISNULL(' ' + @middleName, '')
                                    + ISNULL(' ' + @lastName1, '')
									+ ISNULL(' ' + @lastName2, '')
			
                --IF EXISTS ( SELECT  'X'
                --            FROM    customerMaster WITH ( NOLOCK )
                --            WHERE   fullName = @fullName
                --                    AND dob = @custDOB
                --                    AND ISNULL(onlineUser, 'N') = 'Y'
                --                    AND ISNULL(isDeleted, 'N') = 'N' )
                --    BEGIN
                --        SELECT  @errorMsg = 'It looks like you have already registered with JME with fullname: '+@fullName+' and DOB:  '+@custDOB+'.\nPlease contact us  on +44(0)20 8861 2264 or e-mail us at support@jmeremit.com for any assistance.';
			
                --        EXEC proc_errorHandler 1, @errorMsg, @customerId;
                --        RETURN;
                --    END; 

				IF @newPassword IS NULL
					BEGIN
						SET @newPassword = RIGHT('0000000'
					                         + CAST(CHECKSUM(NEWID()) AS VARCHAR),
					                      7);
					END

                IF @streetUnicode = 'Nnull'
                    BEGIN
                        SET @streetUnicode = NULL;
                    END;

                IF @cityUnicode = 'Nnull'
                    BEGIN
                        SET @cityUnicode = NULL;
                    END;
				IF @customerType = '4701'
					BEGIN
						SET @employeeBusinessType = NULL;
					END
					
				--IF ISNULL(@street, '') IS NOT NULL
				--BEGIN
				--	SET @district = @street
				--	SELECT @custCity = CITY_NAME, @street = STREET_NAME 
				--	FROM TBL_JAPAN_ADDRESS_DETAIL(NOLOCK)
				--	WHERE ROW_ID = @district
				--END
			BEGIN TRANSACTION;  
                INSERT  INTO customerMaster(
							firstName,middleName,lastName1,lastName2,country,[address],zipCode,district,city,email,homePhone,workPhone,mobile,
							nativeCountry,dob,placeOfIssue,occupation,isBlackListed,lastTranId,relationId,relativeName,gender,salaryRange,address2,
							fullName,
							createdBy,createdDate,postalCode,idIssueDate,idExpiryDate,idType,idNumber,telNo,agentId,branchId,onlineUser,
							ipAddress,customerPassword,customerType,isActive,verifiedBy,verifiedDate,isForcedPwdChange,bankName,bankAccountNo,HasDeclare,
							membershipId,[state],sourceOfFund,street,streetUnicode,cityUnicode,visaStatus,employeeBusinessType,nameOfEmployeer,SSNNO,
							remittanceAllowed,remarks,registerationNo,organizationType,dateofIncorporation,natureOfCompany,position
							,nameOfAuthorizedPerson,monthlyIncome,OBPID,ADDITIONALADDRESS,documentType
						)
                        VALUES (
							@firstName,@middleName,@lastName1,@lastName2,@country,@custAdd1,ISNULL(@zipCode, @custPostal),@district,@custCity,@custEmail,null,@workPhone,@custMobile,
							@custNativecountry,@custDOB,@placeOfIssue,@occupation,@isBlackListed,@lastTranId,@relationId,@relativeName,@custGender,@custSalary,@custAdd2,
							@fullName,
                            @user,DATEADD(HH, 0, GETUTCDATE()),@custPostal,@custIdissueDate,@custIdValidDate,@customerIdType,@customerIdNo,@custTelNo,@loginBranchId,@branch,@onlineUser,
							@ipAddress,dbo.FNAEncryptString(@newPassword),@customerType,'Y',@user,NULL,'1',@bankId,@accountNumber,@HasDeclare,---- New Added Values
							@membershipId,@state,@sourceOfFound,@street,@streetUnicode,@cityUnicode,@visaStatus,@employeeBusinessType,@nameOfEmployeer,@SSNNO,
							@remittanceAllowed,@remarks,@registerationNo,@organizationType,@dateofIncorporation,@natureOfCompany,@position
							,@nameOfAuthorizedPerson,@monthlyIncome,null,@additionalAddress,@docType
						)
                SET @customerId = SCOPE_IDENTITY();
			
                EXEC PROC_GENERATE_MEMBERSHIP_ID @USER = @user,
                    @CUSTOMERID = @customerId,@loginBranchId = @loginBranchId, @MEMBESHIP_ID = @membershipId OUT;
             
                UPDATE  dbo.customerMaster
                SET     membershipId = @membershipId,
						approvedBy=CASE @user WHEN 'admin' THEN @user ELSE NULL END,
						approvedDate =CASE @user WHEN 'admin' THEN GETDATE() ELSE NULL END
                WHERE   customerId = @customerId; 

				IF @isCounterVisited ='Y'
				BEGIN
				    INSERT INTO dbo.TBL_CUSTOMER_KYC
									(	customerId,kycMethod,kycStatus,createdBy,createdDate,isDeleted
									)
							VALUES  ( 
										@customerId,11048,11044,@user,GETDATE(),0
									)
				END

                IF @@TRANCOUNT > 0
                    COMMIT TRANSACTION;  

                SELECT  '0' ErrorCode ,
                        'Customer has been registered successfully with membershipId: '+CAST(@membershipId AS VARCHAR) Msg ,
                        @customerId id;
            END;
		
        IF @flag = 'customer-details'
            BEGIN
                DECLARE @isTxnMade CHAR(1);

                SELECT  customerId ,
                        isTxnMade = 'N' ,
                        firstName ,
                        middleName ,
                        lastName1 ,
                        lastName2 ,
                        country ,
						[address],
                        zipCode ,
						city ,
                        email ,
						mobile =CASE WHEN SUBSTRING(cu.mobile,0,5)='+976' THEN cu.mobile ELSE '+976'+cu.mobile END,
                        nativeCountry =(SELECT countryName FROM dbo.countryMaster WHERE countryId = cu.nativeCountry) ,
						cu.nativeCountry nativeCountryId,
                        homePhone ,
                        occupation ,
                        address2 ,
                        fullName ,
                        postalCode ,
                       CONVERT(VARCHAR, idType)+'|'+CONVERT(VARCHAR, sv.detailDesc)+'|'+CONVERT(VARCHAR, ISNULL(CID.expiryType, 'N')) idType,
                        idNumber ,
                        telNo ,
                        --companyName ,
                        gender ,
                        ipAddress ,
                        verifyDoc1 ,
                        verifyDoc2 ,
                        verifyDoc3 ,
                        verifyDoc4 = SelfieDoc ,
                        verifiedBy ,
                        verifiedDate ,
                        bankAccountNo ,
                        bankName = vb.rowId ,
                        isApproved = CASE WHEN cu.approvedBy IS NULL THEN 'N'
                                          ELSE 'Y'
                                     END ,
                        CONVERT(VARCHAR(10), dob, 121) AS dob ,
                        CONVERT(VARCHAR(10), idIssueDate, 121) AS idIssueDate ,
                        CONVERT(VARCHAR(10), idExpiryDate, 121) AS idExpiryDate ,
						
						---added value field on 2018-12-28 by anoj
                        membershipId ,
                        [state] ,
                        sourceOfFund ,
                        street ,
						cu.address additionalAddress,
                        streetUnicode ,
                        cityUnicode ,
                        visaStatus ,
                        employeeBusinessType ,
                        nameOfEmployeer ,
                        SSNNO ,
                        remittanceAllowed ,
                        remarks ,
                        registerationNo ,
                        organizationType ,
						CONVERT(VARCHAR(10), dateofIncorporation, 121) AS dateofIncorporation ,
                        natureOfCompany ,
                        position ,
                        onlineUser ,
                        customerType ,
                        nameOfAuthorizedPerson,
						sv.detailTitle IdTypeName,
						cu.idNumber,
						cu.monthlyIncome,
						documentType,
						cu.district,
						CONVERT(VARCHAR(10), cu.createdDate, 121) createdDate
                FROM    customerMaster cu WITH ( NOLOCK )
                        LEFT JOIN vwBankLists vb WITH ( NOLOCK ) ON cu.bankName = vb.rowId
						LEFT JOIN dbo.staticDataValue sv(NOLOCK) ON sv.valueId=cu.idType
						INNER JOIN dbo.countryMaster CM (NOLOCK)ON CM.countryId = CU.country
						LEFT JOIN countryIdType CID WITH(NOLOCK) ON CID.IdTypeId=cu.idType
                WHERE   customerId = @customerId;
            END;
	
        IF @flag = 'customer-update-new'
            BEGIN
			IF ISNULL(@customerType,'')=''
			BEGIN
			    SET @customerType='4700'
			END
			SET @mobile = LTRIM(RTRIM(@mobile))
		--LOG FOR CUSTOMER UPDATE
				SET @fullName=ISNULL(@firstName, '') + ISNULL(' '
                                                              + @middleName,
                                                              '') + ISNULL(' '
                                                              + @lastName1, '');
				SET @onlineUser = CASE WHEN @onlineUser='true'THEN 'Y' ELSE 'N' END
                EXEC PROC_CUSTOMERMODIFYLOG 
					@flag						=	'i',
					@user						=	@user,
                    @customerId					=	@customerId,
					@customerType				=	@customerType,
					@firstName					=	@firstName,
					@middleName					=	@middleName,
					@lastName1					=	@lastName1,
					@fullName					=	@fullName,
					@country					=	@country,
					@zipCode					=	@zipCode,
					@state						=	@state,
					@street						=	@street,
					@custCity					=	@custCity,
					@district					=	@district,
					@cityUnicode				=	@cityUnicode,	
					@streetUnicode				=	@streetUnicode,
					@custGender					=	@custGender,	
					@custNativecountry			=	@custNativecountry,
					@dob						=	@custDOB,
					@email						=	@custEmail,
					@custTelNo					=	@custTelNo,	
					@mobileNumber				=	@custMobile,
					@visaStatus					=	@visaStatus,	
					@employeeBusinessType		=	@employeeBusinessType,	
					@nameOfEmployeer			=	@nameOfEmployeer,
					@SSNNO						=	@SSNNO,
					@occupation					=	@occupation,
					@placeOfIssue				=	@placeOfIssue,
					@sourceOfFound				=	@sourceOfFound,
					@monthlyIncome				=	@monthlyIncome,
					@idType						=	@customerIdType,
					@idNumber					=	@customerIdNo,	
					@issueDate					=	@custIdissueDate,	
					@expiryDate					=	@custIdValidDate,	
					@remittanceAllowed			=	@remittanceAllowed,
					--@onlineUser					=	@onlineUser,	
					@remarks					=	@remarks,

					--used for customer type organisation
					@companyName				=	@companyName,	
					@registerationNo			=	@registerationNo,
					@organizationType			=	@organizationType,
					@dateofIncorporation		=	@dateofIncorporation,
					@natureOfCompany			=	@natureOfCompany,
					@nameOfAuthorizedPerson		=	@nameOfAuthorizedPerson,	
					@position					=	@position,	
					
					-- old Data
					@bank						=	@bankId,
					@accNumber					=	@accountNumber,
					@additionalAddress			=	@custAdd1

                UPDATE  dbo.customerMaster
                SET     firstName = @firstName ,
                        middleName = CASE WHEN @customerType = '4700'
                                          THEN @middleName
                                          ELSE NULL
                                     END ,
                        lastName1 = CASE WHEN @customerType = '4700'
                                         THEN @lastName1
                                         ELSE NULL
                                    END ,
                        lastName2 = CASE WHEN @customerType = '4700'
                                         THEN @lastName2
                                         ELSE NULL
                                    END ,
                        country = @country ,
                        [address] = @custAdd1 ,
                        district = @district ,
                        city = @custCity ,
                        email = @custEmail ,
                        mobile = @custMobile ,
                        nativeCountry = @custNativecountry ,
                        occupation = CASE WHEN @customerType = '4700'
                                          THEN @occupation
                                          ELSE NULL
                                     END ,

                        gender = CASE WHEN @customerType = '4700'
                                      THEN @custGender
                                      ELSE NULL
                                 END ,
                        fullName = ISNULL(@firstName, '') + ISNULL(' '
                                                              + @middleName,
                                                              '') + ISNULL(' '
                                                              + @lastName1, '')
                        + ISNULL(' ' + @lastName2, '') ,
                        telNo = @custTelNo ,
                        agentId = @agent ,
                        branchId = @branch ,
                        dob = CASE WHEN @custDOB IS NOT NULL THEN @custDOB
                                   ELSE dob
                              END ,
                        onlineUser = @onlineUser,
                        customerType = @customerType ,
                        isActive = 'Y' ,
                        modifiedBy = @user ,
                        modifiedDate = GETDATE() ,
                        idIssueDate = ISNULL(@custIdissueDate, idIssueDate) --new added by dhan
                        ,
                        idExpiryDate = ISNULL(@custIdValidDate, idExpiryDate) ,
                        idType = ISNULL(@customerIdType, idType) ,
                        idNumber = ISNULL(@customerIdNo, idNumber) ,
                        zipCode = @zipCode ,
	          --added New Field Value on 2018-12-28 --added by anoj
                        [state] = @state ,
                        sourceOfFund =@sourceOfFound,
                        street = @street ,

                        streetUnicode =@streetUnicode,
                        cityUnicode = @cityUnicode,

                        visaStatus = CASE WHEN @customerType = '4700'
                                          THEN @visaStatus
                                          ELSE NULL
                                     END ,
                        employeeBusinessType = CASE WHEN @customerType = '4700'
                                                    THEN @employeeBusinessType
                                                    ELSE NULL
                                               END ,
                        nameOfEmployeer = CASE WHEN @customerType = '4700'
                                               THEN @nameOfEmployeer
                                               ELSE NULL
                                          END ,
                        SSNNO = CASE WHEN @customerType = '4700' THEN @SSNNO
                                     ELSE NULL
                                END ,
                        remittanceAllowed = CASE WHEN @customerType = '4700'
                                                 THEN @remittanceAllowed
                                                 ELSE NULL
                                            END ,
                        remarks = CASE WHEN @customerType = '4700'
                                       THEN @remarks
                                       ELSE NULL
                                  END ,
                        registerationNo = CASE WHEN @customerType = '4700'
                                               THEN NULL
                                               ELSE @registerationNo
                                          END ,
                        organizationType = CASE WHEN @customerType = '4700'
                                                THEN NULL
                                                ELSE @organizationType
                                           END ,
                        dateofIncorporation = CASE WHEN @customerType = '4700'
                                                   THEN NULL
                                                   ELSE @dateofIncorporation
                                              END ,
                        natureOfCompany = CASE WHEN @customerType = '4700'
                                               THEN NULL
                                               ELSE @natureOfCompany
                                          END ,
                        position = CASE WHEN @customerType = '4700' THEN NULL
                                        ELSE @position
                                   END ,
                        nameOfAuthorizedPerson = CASE WHEN @customerType = '4700'
                                                      THEN NULL
                                                      ELSE @nameOfAuthorizedPerson
                                                 END ,
                        companyName = CASE WHEN @customerType = '4700'
                                           THEN NULL
                                           ELSE @companyName
                                      END,
						monthlyIncome =@monthlyIncome
                WHERE   customerId = @customerId;
				
                SELECT  '0' ErrorCode ,
                        'Customer has been updated successfully.' Msg ,
                        @customerId id;	 
            END;
		
		IF @flag = 'customer-editeddata'
        BEGIN
		    SET @customerType='4700'

			SET @onlineUser = CASE WHEN @onlineUser='true'THEN 'Y' ELSE 'N' END

			SET @fullName = ISNULL(@firstName, '')
                                    + ISNULL(' ' + @middleName, '')
                                    + ISNULL(' ' + @lastName1, '')
									+ ISNULL(' ' + @lastName2, '')
			

			DECLARE @approvedBy VARCHAR(30),@approvedDate VARCHAR(50)

			--IF ISNULL(@street, '') IS NOT NULL
			--BEGIN
			--	SET @district = @street
			--	SELECT @custCity = CITY_NAME, @street = STREET_NAME 
			--	FROM TBL_JAPAN_ADDRESS_DETAIL(NOLOCK)
			--	WHERE ROW_ID = @district
			--END
			
			EXEC PROC_CUSTOMERMODIFYLOG 
					@flag						=	'i-new',
					@user						=	@user,
                    @customerId					=	@customerId,
					@state						=	@state,
					@street						=	@street,
					@custCity					=	@custCity,
					@cityUnicode				=	@cityUnicode,	
					@streetUnicode				=	@streetUnicode,
					@customerType				=	@customerType,
					@firstName					=	@firstName,
					@middleName					=	@middleName,
					@lastName1					=	@lastName1,
					@fullName					=	@fullName,
					@country					=	@country,
					@zipCode					=	@zipCode,
					@custGender					=	@custGender,	
					@custNativecountry			=	@custNativecountry,
					@additionalAddress			=	@custAdd1,
					@dob						=	@custDOB,
					@email						=	@custEmail,
					@custTelNo					=	@custTelNo,	
					@mobileNumber				=	@custMobile,
					@visaStatus					=	@visaStatus,	
					@employeeBusinessType		=	@employeeBusinessType,	
					@nameOfEmployeer			=	@nameOfEmployeer,
					@SSNNO						=	@SSNNO,
					@occupation					=	@occupation,
					@placeofissue				=	@placeOfIssue,
					@sourceOfFound				=	@sourceOfFound,
					@monthlyIncome				=	@monthlyIncome,
					@idType						=	@customerIdType,
					@idNumber					=	@customerIdNo,	
					@issueDate					=	@custIdissueDate,	
					@expiryDate					=	@custIdValidDate,	
					@remittanceAllowed			=	@remittanceAllowed,
					--@onlineUser					=	@onlineUser,	
					@remarks					=	@remarks,
				
					--used for customer type organisation
					@companyName				=	@companyName,	
					@registerationNo			=	@registerationNo,
					@organizationType			=	@organizationType,
					@dateofIncorporation		=	@dateofIncorporation,
					@natureOfCompany			=	@natureOfCompany,
					@nameOfAuthorizedPerson		=	@nameOfAuthorizedPerson,	
					@position					=	@position,
			
					@bank						=	@bankId,
					@accNumber					=	@accountNumber

			BEGIN
				--IF CUSTOMER IS NOT APPROVED YET DIRECT UPDATE MAIN TABLE
				
				
				UPDATE dbo.customerMaster 
					SET     firstName = @firstName ,
							middleName = CASE WHEN @customerType = '4700'
											  THEN @middleName
											  ELSE NULL
										 END ,
							lastName1 = CASE WHEN @customerType = '4700'
											 THEN @lastName1
											 ELSE NULL
										END ,
							lastName2 = CASE WHEN @customerType = '4700'
											 THEN @lastName2
											 ELSE NULL
										END ,
							country = @country ,
							[address] = @custAdd1 ,
							district = @district ,
							city = @custCity ,
							email = @custEmail ,
							mobile = @custMobile ,
							nativeCountry = @custNativecountry ,
							occupation = CASE WHEN @customerType = '4700'
											  THEN @occupation
											  ELSE NULL
										 END ,

							gender = CASE WHEN @customerType = '4700'
										  THEN @custGender
										  ELSE NULL
									 END ,
							fullName = CASE WHEN @customerType = '4700'
											   THEN ISNULL(@firstName, '') + ISNULL(' '
																  + @middleName,
																  '') + ISNULL(' '
																  + @lastName1, '')
													+ ISNULL(' ' + @lastName2, '')
											   ELSE @firstName
										  END,
							telNo = @custTelNo ,
							agentId = @agent ,
							branchId = @branch ,
							dob = CASE WHEN @custDOB IS NOT NULL THEN @custDOB
									   ELSE dob
								  END ,
							customerType = @customerType ,
							isActive = 'Y' ,
							modifiedBy = @user ,
							modifiedDate = GETDATE() ,
							idIssueDate = ISNULL(@custIdissueDate, idIssueDate) --new added by dhan
							,
							idExpiryDate = ISNULL(@custIdValidDate, idExpiryDate) ,
							idType = ISNULL(@customerIdType, idType) ,
							idNumber = ISNULL(@customerIdNo, idNumber) ,
							zipCode = @zipCode ,
				  --added New Field Value on 2018-12-28 --added by anoj
							[state] = @state ,
							sourceOfFund = @sourceOfFound,
							street = @street ,
							additionalAddress = @additionalAddress,
							streetUnicode = CASE WHEN @customerType = '4700'
												 THEN @streetUnicode
												 ELSE NULL
											END ,
							cityUnicode = CASE WHEN @customerType = '4700'
											   THEN @cityUnicode
											   ELSE NULL
										  END ,
							visaStatus = CASE WHEN @customerType = '4700'
											  THEN @visaStatus
											  ELSE NULL
										 END ,
							employeeBusinessType = CASE WHEN @customerType = '4700'
														THEN @employeeBusinessType
														ELSE NULL
												   END ,
							nameOfEmployeer = CASE WHEN @customerType = '4700'
												   THEN @nameOfEmployeer
												   ELSE NULL
											  END ,
							SSNNO = CASE WHEN @customerType = '4700' THEN @SSNNO
										 ELSE NULL
									END ,
							remittanceAllowed = CASE WHEN @customerType = '4700'
													 THEN @remittanceAllowed
													 ELSE NULL
												END ,
							remarks = CASE WHEN @customerType = '4700'
										   THEN @remarks
										   ELSE NULL
									  END ,
							registerationNo = CASE WHEN @customerType = '4700'
												   THEN NULL
												   ELSE @registerationNo
											  END ,
							organizationType = CASE WHEN @customerType = '4700'
													THEN NULL
													ELSE @organizationType
											   END ,
							dateofIncorporation = CASE WHEN @customerType = '4700'
													   THEN NULL
													   ELSE @dateofIncorporation
												  END ,
							natureOfCompany = CASE WHEN @customerType = '4700'
												   THEN NULL
												   ELSE @natureOfCompany
											  END ,
							position = CASE WHEN @customerType = '4700' THEN NULL
											ELSE @position
									   END ,
							nameOfAuthorizedPerson = CASE WHEN @customerType = '4700'
														  THEN NULL
														  ELSE @nameOfAuthorizedPerson
													 END ,
							companyName = CASE WHEN @customerType = '4700'
											   THEN NULL
											   ELSE @companyName
										  END,
							monthlyIncome =@monthlyIncome,
							documentType = @docType,
							bankName	=	@bankId,
							bankAccountNo=@accountNumber

					WHERE   customerId = @customerId;
					SELECT  '0' ErrorCode ,
							 'Customer data has been updated successfully.' Msg ,
							 @customerId id;
			END
        END

        IF @flag = 'customer-update-core'
            BEGIN
			SET @onlineUser = CASE WHEN @onlineUser='true'THEN 'Y' ELSE 'N' END
                DECLARE @userType VARCHAR(5);
                SELECT  @userType = userType
                FROM    applicationUsers (NOLOCK)
                WHERE   userName = @user;

                IF EXISTS ( SELECT  'a'
                            FROM    dbo.customerMaster (NOLOCK)
                            WHERE   customerId = @customerId
                                    AND approvedBy IS NOT NULL
                                    AND @userType <> 'HO' )
                    BEGIN
                        SELECT  '1' ErrorCode ,
                                'Customer is already approved, you can not modify this customer data.' Msg ,
                                @customerId id;	
                        RETURN;
                    END;

		--LOG FOR CUSTOMER UPDATE
                EXEC PROC_CUSTOMERMODIFYLOG @flag = 'i', @email = @custEmail,
                    @idNumber = @customerIdNo, @bank = @bankId,
                    @accNumber = @accountNumber, @customerId = @customerId,
                    @mobileNumber = @custMobile, @user = @user;	

                UPDATE  dbo.customerMaster
                SET     firstName = @firstName ,
                        middleName = middleName ,
                        lastName1 = @lastName1 ,
                        lastName2 = @lastName2 ,
                        country = @country ,
                        [address] = @custAdd1 ,
                        zipCode = ISNULL(@zipCode, @custPostal) ,
                        district = @district ,
                        city = @custCity ,
                        email = @custEmail
		--,homePhone = @customerIdNo
                        ,
                        workPhone = @workPhone ,
                        mobile = @custMobile ,
                        nativeCountry = @custNativecountry ,
                        dob = @custDOB ,
                        placeOfIssue = @placeOfIssue ,
                        occupation = @occupation ,
                        isBlackListed = @isBlackListed ,
                        lastTranId = @lastTranId ,
                        relationId = @relationId ,
                        relativeName = @relativeName ,
                        gender = @custGender ,
                        companyName = @companyName ,
                        salaryRange = @custSalary ,
                        address2 = @custAdd2 ,
                        fullName = ISNULL(@firstName, '') + ISNULL(' '
                                                              + @middleName,
                                                              '') + ISNULL(' '
                                                              + @lastName1, '')
                        + ISNULL(' ' + @lastName2, '') ,
                        --postalCode = @custPostal ,
                        idIssueDate = @custIdissueDate ,
                        idExpiryDate = @custIdValidDate ,
                        idType = @customerIdType ,
                        idNumber = @customerIdNo ,
                        telNo = @custTelNo ,
                        agentId = @agent ,
                        branchId = @branch ,
                        onlineUser = @onlineUser ,
                        customerType = @customerType ,
                        isActive = 'Y' ,
                        bankName = @bankId ,
                        modifiedBy = @user ,
                        modifiedDate = GETDATE() ,
                        bankAccountNo = @accountNumber ,
                        HasDeclare = @HasDeclare
                WHERE   customerId = @customerId;
                SELECT  '0' ErrorCode ,
                        'Customer has been updated successfully.' Msg ,
                        @customerId id;	 
            END;

        IF @flag = 'verify-customer-details'
            BEGIN
				SELECT * 
				FROM (SELECT fileName, 
								fileType, 
								documentType = detailTitle,
								ROW_NUMBER()OVER(PARTITION BY SV.detailTitle ORDER BY CD.createdDate DESC)rn
						FROM customerDocument CD(NOLOCK)
						INNER JOIN STATICDATAVALUE SV(NOLOCK) ON SV.valueId = CD.documentType
						WHERE ISNULL(isDeleted, 'N') = 'N'
						AND customerId = @customerId
						AND valueId IN (11054, 11055, 11056, 11057)
				)X WHERE rn=1

                SELECT  cm.walletAccountNo AS [walletNumber],
                        cm.customerId,
                       CONVERT(VARCHAR(10),  cm.createdDate, 121) AS createdDate,
						CM.membershipId,
                        ISNULL(email,'-') email,
                        cm.fullName ,
                        sdg.detailTitle AS [gender] ,
                        cmb.countryName AS [country] ,
                        cmn.countryName AS [nativeCountry] ,
                        ISNULL(cm.homePhone,'-') homePhone ,
                        cm.postalCode ,
                        cm.address  [address],
                       CIT.CITY_NAME AS city ,
						cm.zipcode,
                        ISNULL(COALESCE(cm.telNo,cm.homePhone),'-') telNo,
                        ISNULL(cm.mobile,'-') mobile ,
                        sdo.detailTitle AS [occupation] ,
                        sdi.detailTitle AS [idType] ,
                        cm.idType AS [idTypeCode] ,
                        cm.idNumber ,
                        cm.verifyDoc1 ,
                        cm.verifyDoc2 ,
                        cm.verifyDoc3 ,
                        CONVERT(VARCHAR(10), dob, 121) AS [dob] ,
                        CONVERT(VARCHAR(10), idIssueDate, 121) AS [idIssueDate] ,
                        CONVERT(VARCHAR(10), idExpiryDate, 121) AS [idExpiryDate] ,
                        bl.BankName ,
                        bl.bankCode ,
						PRO.PROVINCE_NAME AS district,
                        cm.bankAccountNo ,
                        cm.walletAccountNo ,
                        cm.homePhone ,
                        cm.availableBalance ,
                        verifyDoc4 = SelfieDoc ,
                        cm.obpId ,
                        cm.AuditDate ,
						customerType = TYP.detailTitle,
                        cm.customerStatus ,
                        CONVERT(VARCHAR(6), cm.dob, 12) AS [dobYMD] ,
                        CASE WHEN gender = '97' THEN '7'
                             WHEN gender = '98' THEN '8'
                        END AS [genderCode] ,
                        CASE WHEN nativeCountry = '238' THEN '1'
                             WHEN nativeCountry = '113' THEN '2'
                             WHEN nativeCountry = '45' THEN '3'
                             ELSE '4'
                        END AS [nativeCountryCode],
						doc.detailTitle AS DocumentType,
						visa.detailTitle VisaStatus,
						businessType.detailTitle  EmployeeBusinessType,
						ISNULL(cm.NameOfEmployeer,'-') NameOfEmployeer,
						ISNULL(cm.SsnNo,'-') SsnNo,
						sourceOfFund.detailTitle SourceOfFund,
						ISNULL(cm.MonthlyIncome,'-') MonthlyIncome,
						ISNULL(cm.Remarks,'-') Remarks,
						CASE WHEN cm.RemittanceAllowed = '1' THEN 'Yes' ELSE 'No' END RemittanceAllowed,
						CASE WHEN cm.OnlineUser = 'Y' THEN 'Yes' ELSE 'No' END OnlineUser
                FROM    customerMaster cm ( NOLOCK )
				LEFT JOIN staticDataValue TYP(NOLOCK) ON TYP.valueId = cm.customerType
				LEFT JOIN TBL_PROVINCE_LIST PRO(NOLOCK) ON PRO.ROW_ID=cm.district
				LEFT JOIN TBL_CITY_LIST (NOLOCK) CIT ON CIT.ROW_ID=cm.city
                LEFT JOIN staticDataValue sdg ( NOLOCK ) ON sdg.valueId = cm.gender
                LEFT JOIN dbo.countryMaster cmb ( NOLOCK ) ON cmb.countryId = cm.country
                LEFT JOIN dbo.countryMaster cmn ( NOLOCK ) ON cmn.countryId = cm.nativeCountry
                LEFT JOIN staticDataValue sdo ( NOLOCK ) ON sdo.valueId = cm.occupation
                LEFT JOIN staticDataValue sdi ( NOLOCK ) ON sdi.valueId = cm.idType
                LEFT JOIN staticDataValue doc ( NOLOCK ) ON doc.valueId = cm.documentType
                LEFT JOIN KoreanBankList bl ( NOLOCK ) ON cm.bankName = bl.rowId
				LEFT JOIN countryStateMaster CSM (NOLOCK) ON CSM.stateId = CAST(cm.state AS VARCHAR)
				LEFT JOIN StaticDataValue visa (nolock) on visa.valueId = cm.visaStatus
				LEFT JOIN StaticDataValue businessType (nolock) on businessType.valueId = cm.employeeBusinessType
				LEFT JOIN StaticDataValue sourceOfFund (nolock) on sourceOfFund.valueId = cm.sourceOfFund
				LEFT JOIN tbl_japan_address_detail detail (nolock) on detail.zip_code = cm.zipcode
                WHERE   customerId = @customerId;
            END;

        IF @flag = 'verify-customer-agent'
            BEGIN
                UPDATE  dbo.customerMaster
                SET     verifiedDate = GETDATE() ,
                        verifiedBy = @user
                WHERE   customerId = @customerId;
                SELECT  '0' ErrorCode ,
                        'Customer verified successfully.' Msg ,
                        @customerId id;
            END;

        IF @flag = 'approve-customer-admin'
            BEGIN
                UPDATE  dbo.customerMaster
                SET     approvedDate = GETDATE() ,
                        approvedBy = @user
                WHERE   customerId = @customerId;
                SELECT  '0' ErrorCode ,
                        'Customer approved successfully.' Msg ,
                        @customerId id;
            END;

        IF @flag = 'verify-pending'
            BEGIN
                UPDATE  dbo.customerMaster
                SET     verifiedDate = GETDATE() ,
                        verifiedBy = @user
                WHERE   customerId = @customerId;
                SELECT  '0' ErrorCode ,
                        'Customer verified successfully.' Msg ,
                        @customerId id;
            END;

        IF @flag = 'approve-pending'
            BEGIN
                IF NOT EXISTS ( SELECT TOP 1
                                        virtualAccNumber
                                FROM    VirtualAccountMapping WITH ( NOLOCK ) )
                    BEGIN
                        SELECT  '1' ErrorCode ,
                                'No stock Virtual account found, please upload  ! Warning ' Msg ,
                                NULL;
                        RETURN;
                    END;
                IF EXISTS ( SELECT TOP 1
                                    ''
                            FROM    customerMaster WITH ( NOLOCK )
                            WHERE   walletAccountNo IS NOT NULL )
                    BEGIN
                        SELECT  '1' ErrorCode ,
                                'Virtual account is already assigned ! Warning ' Msg ,
                                NULL;
                        RETURN;
                    END;
                SELECT TOP 1
                        @accountNumber = virtualAccNumber
                FROM    VirtualAccountMapping WITH ( NOLOCK )
                WHERE   customerId IS NULL;

                UPDATE  VirtualAccountMapping
                SET     customerId = @customerId
                WHERE   virtualAccNumber = @accountNumber; 

                UPDATE  dbo.customerMaster
                SET     approvedDate = GETDATE() ,
                        approvedBy = @user ,
                        customerStatus = 'V' ,
                        walletAccountNo = @accountNumber ,
                        CustomerBankName = @fullName
                WHERE   customerId = @customerId;

                SELECT  username = ISNULL(cm.email, '') ,
                        [password] = LOWER(dbo.FNADecryptString(cm.customerPassword)) ,
                        [channel] = LOWER(ISNULL(cm.createdBy, '')) ,
                        [account] = ISNULL(cm.membershipId, '') ,
                        walletAccountNo ,
                        bankAccountNo ,
                        fullName ,
                        CustomerBankName
                FROM    dbo.customerMaster cm ( NOLOCK )
                WHERE   cm.customerId = @customerId;
		
                SELECT  '0' ErrorCode ,
                        'Customer verified successfully.' Msg ,
                        @customerId id;
                RETURN;
            END;

	--@Max : 2018.09	
        IF @flag = 'kj-modificationList'
            BEGIN
                SELECT  k.bankCode ,
                        bankAccountNo ,
                        walletAccountNo ,
                        obpId ,
                        CustomerBankName ,
                        c.idType ,
                        c.idNumber ,
                        CONVERT(VARCHAR(6), c.dob, 12) AS [dobYMD] ,
                        CASE WHEN c.gender = '97' THEN '7'
                             WHEN c.gender = '98' THEN '8'
                        END AS [genderCode] ,
                        CASE WHEN c.nativeCountry = '238' THEN '1'
                             WHEN c.nativeCountry = '113' THEN '2'
                             WHEN c.nativeCountry = '45' THEN '3'
                             ELSE '4'
                        END AS [nativeCountryCode]
                FROM    customerMaster c ( NOLOCK )
                        INNER JOIN KoreanBankList k ( NOLOCK ) ON k.rowId = c.bankName
                WHERE   customerId = @customerId;
		
                RETURN;
            END;

        IF @flag = 'kj-modification'
            BEGIN
                UPDATE  customerMaster
                SET     CustomerBankName = @fullName
                WHERE   customerId = @customerId;
                SELECT  '0' ErrorCode ,
                        'Customer updated successfully.' Msg ,
                        @customerId id;
                RETURN;
            END;

        IF @flag = 'customerdetail'
            BEGIN
               SELECT  firstName ,
						[address]=ISNULL(cm.address,cm.ADDITIONALADDRESS),
					    mobile ,
					    fullName,
						nativeCoun.countryName nativeCountry,
						sv.detailTitle idType,
						cm.idNumber
						FROM    dbo.customerMaster cm (NOLOCK)
						LEFT JOIN dbo.countryStateMaster csm (NOLOCK) ON csm.stateId=cm.state
						LEFT JOIN dbo.countryMaster country (NOLOCK) ON country.countryId =cm.country
						LEFT JOIN dbo.countryMaster nativeCoun (NOLOCK) ON nativeCoun.countryId =cm.nativeCountry
						LEFT JOIN dbo.staticDataValue sv(NOLOCK) ON sv.valueId=cm.idType
						WHERE   customerId = @customerId;
				
            END;

        IF @flag = 'fileUpload'
            BEGIN
                UPDATE  dbo.customerMaster
                SET     verifyDoc1 = CASE WHEN @verifyDoc1 IS NOT NULL
                                          THEN @verifyDoc1
                                          ELSE verifyDoc1						-------------- passport image
                                     END ,
                        verifyDoc2 = CASE WHEN @verifyDoc2 IS NOT NULL
                                          THEN @verifyDoc2
                                          ELSE verifyDoc2						-------------- id front image
                                     END ,
                        verifyDoc3 = CASE WHEN @verifyDoc3 IS NOT NULL
                                          THEN @verifyDoc3
                                          ELSE verifyDoc3						-------------- id Back image
                    END ,
                        SelfieDoc = CASE WHEN @verifyDoc4 IS NOT NULL
                                         THEN @verifyDoc4
                                         ELSE SelfieDoc							-------------- id selfie image
                                    END
                WHERE   customerId = @customerId;
                SELECT  '0' ErrorCode ,
                        'Customer has been updated successfully.' Msg ,
                        @customerId id;	
            END;

		IF @FLAG = 'delete'
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM REMITTRAN R(NOLOCK)
						INNER JOIN TRANSENDERS S(NOLOCK) ON S.TRANID = R.ID
						WHERE S.CUSTOMERID = @rowid)
			BEGIN
				select 1 ErrorCode,'You can not delete this customer, customer has already done transaction!' Msg, @rowid id
				RETURN
			END
			IF EXISTS(SELECT * FROM CUSTOMERMASTER (NOLOCK) WHERE CUSTOMERID = @rowid AND APPROVEDDATE IS NOT NULL)
			BEGIN
				select 1 ErrorCode,'You can not delete this customer, customer has already been approved!' Msg, @rowid id
				RETURN
			END

			--select * from customermasterdeleted
			
			insert into customermasterdeleted
			select membershipId,firstName,middleName,lastName1,lastName2,country,address,state,zipCode,district,city,email,homePhone,workPhone,mobile,nativeCountry,dob,placeOfIssue
					,customerType,occupation,isBlackListed,createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate,isDeleted,lastTranId,relationId,relativeName,address2
					,fullName,postalCode,idExpiryDate,idType,idNumber,telNo,companyName,gender,salaryRange,bonusPointPending,Redeemed,bonusPoint,todaysSent,todaysNoOfTxn,agentId
					,branchId,memberIDissuedDate,memberIDissuedByUser,memberIDissuedAgentId,memberIDissuedBranchId,totalSent,idIssueDate,onlineUser,customerPassword,customerStatus
					,isActive,islocked,sessionId,lastLoginTs,howDidYouHear,ansText,ansEmail,state2,ipAddress,marketingSubscription,paidTxn,firstTxnDate,verifyDoc1,verifyDoc2,verifiedBy
					,verifiedDate,verifyDoc3,isForcedPwdChange,bankName,bankAccountNo,walletAccountNo,availableBalance,obpId,CustomerBankName,referelCode,isEmailVerified,verificationCode
					,SelfieDoc,HasDeclare,AuditDate,AuditBy,SchemeStartDate,invalidAttemptCount,sourceOfFund,street,streetUnicode,cityUnicode,visaStatus,employeeBusinessType,nameOfEmployeer
					,SSNNO,remittanceAllowed,remarks,registerationNo,organizationType,dateofIncorporation,natureOfCompany,position,nameOfAuthorizedPerson,monthlyIncome,ADDITIONALADDRESS,@user				
					,GETDATE(),customerId
			from customerMaster
			where customerId = @rowid

			delete from customerMaster where customerid = @rowid

			select 0 ErrorCode,'Customer Deleted Successfully' Msg, @rowid id
		END
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;  
        DECLARE @errorMessage VARCHAR(MAX);  
        SET @errorMessage = ERROR_MESSAGE();  
        EXEC proc_errorHandler 1, @errorMessage, @customerId;  
    END CATCH; 

GO

