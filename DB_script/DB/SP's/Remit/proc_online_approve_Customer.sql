
ALTER PROC [dbo].[proc_online_approve_Customer]  
 @flag						VARCHAR(50)		= NULL   
,@user						VARCHAR(30)		= NULL  
,@customerId				VARCHAR(30)		= NULL 
,@searchCriteria			VARCHAR(30)		= NULL
,@searchValue				VARCHAR(50)		= NULL
,@fromDate					DATETIME		= NULL
,@toDate					DATETIME		= NULL
,@cusType					VARCHAR(50)		= NULL
,@accountNumber				VARCHAR(100)	= NULL
,@agentId					BIGINT			= NULL

,@CustomerBankName			NVARCHAR(100)	= NULL
,@obpId						VARCHAR(50)     =NULL
--grid parameters
,@pageSize					VARCHAR(50)		= NULL
,@pageNumber				VARCHAR(50)		= NULL
,@sortBy					VARCHAR(50)		= NULL
,@sortOrder					VARCHAR(50)		= NULL
,@virtualAccountNo			VARCHAR(50)		= NULL
,@primaryAccountNo			VARCHAR(50)		= NULL
   
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
BEGIN TRY
	DECLARE  @table				VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
	DECLARE @email VARCHAR(200)
			,@username VARCHAR(50)
			,@pwd VARCHAR(50)
			,@channel VARCHAR(20)=NULL

	IF @flag='vl' --verified list/approve pending list
	BEGIN
	SET @sortBy = 'createdDate'
	SET @sortOrder = 'desc'

	SET @table ='(
		SELECT SN=ROW_NUMBER() over(ORDER BY cm.customerId asc)
				,customerId=cm.customerId
				,email=cm.email
				,fullName= REPLACE(ISNULL(cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName1, ''''), ''  '', '' '')
				,dob=CONVERT(VARCHAR,cm.dob,101)
				,address=cm.[address]
				,nativeCountry=com.countryName
				,idtype=sdv.detailTitle
				,idNumber=cm.idNumber
				,createdDate=CAST(cm.createdDate AS DATE)
				,createdBy=cm.createdBy
				,verifiedBy=cm.verifiedBy
				,branchName=''''
				,verifiedDate=CAST(cm.verifiedDate AS DATE)
				,ipAddress=cm.ipAddress
				,mobile=cm.mobile
				,bankAccountNo
				,bankName=bl.bankName
		FROM customerMaster cm(NOLOCK)
		LEFT JOIN countryMaster com(NOLOCK) ON cm.nativeCountry=com.countryId
		INNER JOIN staticDataValue sdv (NOLOCK) ON sdv.valueId=cm.idType AND sdv.typeID=1300
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE cm.approvedDate IS NULL 
		and cm.isActive = ''Y'' AND ISNULL(cm.approvedBy,'''')<> '''+@user +''' AND ISNULL(cm.createdBy,'''')<>'''+@user+''''
		
	IF ISNULL(@fromDate,'')<>'' AND ISNULL(@toDate,'')<>''
	SET @table=@table + ' AND cm.createdDate BETWEEN ''' +CAST(@fromDate AS VARCHAR)+''' AND ''' +CAST(@toDate AS VARCHAR)+''''

	SET @table = @table + ')x'
	SET @sql_filter = ''

	IF ISNULL(@searchCriteria,'')<>'' AND ISNULL(@searchValue,'')<>''
	BEGIN 
		IF @searchCriteria='idNumber'
		BEGIN
			--IF ISNUMERIC(@searchValue)<>1
			--	SET @searchValue='-1'	--to ignore string value for datatype integer/customerID
			--SET @sql_Filter=@sql_Filter + ' AND customerId = ''' +@searchValue+''''
			SET @sql_Filter=@sql_Filter + ' AND REPLACE(idNumber, ''-'', '''') = ''' +REPLACE(@searchValue, '-', '')+''''
		END
		ELSE IF @searchCriteria='emailId'
			SET @sql_Filter=@sql_Filter + ' AND email like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='customerName'
			SET @sql_Filter=@sql_Filter + ' AND fullName like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='mobile'
			SET @sql_Filter=@sql_Filter + ' AND mobile = ''' +@searchValue+''''
		ELSE IF @searchCriteria='walletAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND walletAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='bankAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND bankAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='nativeCountry'
			SET @sql_Filter=@sql_Filter + ' AND nativeCountry = ''' +@searchValue+''''
	END

	
	SET @select_field_list ='
				 SN,customerId,email,fullName,dob,address,nativeCountry,idtype,idNumber
				,createdDate,createdBy,verifiedBy,branchName,verifiedDate,bankAccountNo,bankName
				'	
	EXEC dbo.proc_paging
			@table,@sql_filter,@select_field_list,@extra_field_list
			,@sortBy,@sortOrder,@pageSize,@pageNumber

		RETURN
	END


	ELSE IF @flag='al' --approved list
	BEGIN
	IF @sortBy IS NULL
			SET @sortBy = 'customerId'
	IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
	SET @table ='(
		SELECT SN=ROW_NUMBER() over(ORDER BY cm.customerId asc)
				,customerId=cm.customerId
				,email=cm.email
				,fullName= cm.fullName
				,idtype=sdv.detailTitle
				,idNumber=cm.idNumber
				,mobile=cm.mobile
				,bankName=bl.bankName
				,cm.bankAccountNo
				,CM.walletAccountNo
				,cm.availableBalance
				,cm.dob,cm.address
				,country = ''South Korea''
				,nativeCountry = com.CountryName
				,cm.createdDate
				,approvedBy=cm.approvedBy
				,approvedDate=CAST(cm.approvedDate AS DATE)
		FROM customerMaster cm(NOLOCK)
		INNER JOIN staticDataValue sdv (NOLOCK) ON sdv.valueId=cm.idType 
		LEFT JOIN countryMaster com(NOLOCK) ON cm.nativeCountry=com.countryId
		LEFT JOIN KoreanBankList bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE cm.approvedDate is not null '
		
	
	IF ISNULL(@fromDate,'')<>'' AND ISNULL(@toDate,'')<>''
	SET @table=@table + ' AND cm.approvedDate BETWEEN ''' +CAST(CAST(@fromDate AS DATE) AS VARCHAR)+''' AND ''' +CAST(CAST(@toDate AS DATE) AS VARCHAR)+' 23:59:59'+''''

	SET @table = @table + ')x'
	SET @sql_filter = ''

	IF ISNULL(@searchCriteria,'')<>'' AND ISNULL(@searchValue,'')<>''
	BEGIN 
		IF @searchCriteria='idNumber'
		BEGIN
			--IF ISNUMERIC(@searchValue)<>1
			--	SET @searchValue='-1'	--to ignore string value for datatype integer/customerID
			--SET @sql_Filter=@sql_Filter + ' AND customerId = ''' +@searchValue+''''
			SET @sql_Filter=@sql_Filter + ' AND REPLACE(idNumber, ''-'', '''') = ''' +REPLACE(@searchValue, '-', '')+''''
		END
		ELSE IF @searchCriteria='emailId'
			SET @sql_Filter=@sql_Filter + ' AND email like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='customerName'
			SET @sql_Filter=@sql_Filter + ' AND fullName like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='mobile'
			SET @sql_Filter=@sql_Filter + ' AND mobile = ''' +@searchValue+''''
		ELSE IF @searchCriteria='walletAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND walletAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='bankAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND bankAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='nativeCountry'
			SET @sql_Filter=@sql_Filter + ' AND nativeCountry = ''' +@searchValue+''''
	END

	SET @select_field_list ='
				 SN,customerId,email,fullName,idtype,idNumber,mobile,bankName,bankAccountNo,walletAccountNo,availableBalance
				,dob,address,country,nativeCountry,createdDate,approvedDate,approvedBy'	
	EXEC dbo.proc_paging
			@table,@sql_filter,@select_field_list,@extra_field_list,@sortBy,@sortOrder,@pageSize,@pageNumber

		RETURN
	END

	ELSE IF @flag='p' --pending list
	BEGIN
	IF @sortBy IS NULL
			SET @sortBy = 'customerId'
	IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
	SET @table ='(
		SELECT SN=ROW_NUMBER() over(ORDER BY cm.customerId asc)
				,customerId=cm.customerId
				,email=cm.email
				,fullName= REPLACE(ISNULL(cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName1, ''''), ''  '', '' '')
				,dob=CONVERT(VARCHAR,cm.dob,101)
				,address=cm.[address]
				,country=c.countryName
				,ipAddress=isnull(cm.ipAddress,'''')
				,nativeCountry=com.countryName
				,idtype=sdv.detailTitle
				,idNumber=cm.idNumber
				,telNo=isnull(cm.telNo,'''')
				,mobile=cm.mobile
				,createdDate=CAST(cm.createdDate AS DATE)
				,bankName=bl.bankName
				,cm.bankAccountNo
		FROM customerMaster cm(NOLOCK)
		LEFT JOIN countryMaster com(NOLOCK) ON cm.nativeCountry=com.countryId
		LEFT JOIN countryMaster c(NOLOCK) ON cm.country=c.countryId
		INNER JOIN staticDataValue sdv (NOLOCK) ON sdv.valueId=cm.idType AND sdv.typeID=1300
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE cm.verifiedDate IS NULL'

	
	IF ISNULL(@fromDate,'')<>'' AND ISNULL(@toDate,'')<>''
	SET @table=@table + ' AND cm.createdDate BETWEEN ''' +CAST(@fromDate AS VARCHAR)+''' AND ''' +CAST(@toDate AS VARCHAR)+''''

	SET @table = @table + ')x'
	SET @sql_filter = ''

	IF ISNULL(@searchCriteria,'')<>'' AND ISNULL(@searchValue,'')<>''
	BEGIN 
		IF @searchCriteria='idNumber'
		BEGIN
			SET @sql_Filter=@sql_Filter + ' AND REPLACE(idNumber, ''-'', '''') = ''' +REPLACE(@searchValue, '-', '')+''''
		END
		ELSE IF @searchCriteria='emailId'
			SET @sql_Filter=@sql_Filter + ' AND email like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='customerName'
			SET @sql_Filter=@sql_Filter + ' AND fullName like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='mobile'
			SET @sql_Filter=@sql_Filter + ' AND mobile = ''' +@searchValue+''''
		ELSE IF @searchCriteria='bankAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND bankAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='nativeCountry'
			SET @sql_Filter=@sql_Filter + ' AND nativeCountry = ''' +@searchValue+''''
	END

	SET @select_field_list ='
				 SN
				,customerId
				,email
				,fullName
				,dob
				,address
				,country
				--,ipAddress
				,nativeCountry
				,idtype
				,idNumber
				--,telNo
				,mobile
				,createdDate
				,bankName
				,bankAccountNo
				'	
	EXEC dbo.proc_paging
			@table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber

		RETURN
	END

	ELSE IF @flag='searchCriteria'
	BEGIN
		SELECT  ''	value,			'Select' [text]		UNION ALL
		SELECT  'emailId',			'Email ID'			UNION ALL
		SELECT  'IdNumber',			'ID - Number' UNION ALL
		SELECT  'nativeCountry',	'Native Country' UNION ALL
		SELECT  'customerName',		'Customer Name'		UNION ALL
		SELECT  'walletAccountNo',	'Virtual Account No' UNION ALL
		SELECT  'bankAccountNo',	'Registered Bank Account No' UNION ALL
		SELECT  'mobile',			'Mobile No'			
		
		RETURN
	END
	ELSE IF @flag='ddlCustomerType'
	BEGIN
		SELECT  '' value,  'Select'	[text]	UNION ALL
		SELECT  'n',  'Newly Registered'	UNION ALL
		SELECT  'y',  'Existing'
		RETURN
	END

	ELSE IF @flag='verify-pending'
	BEGIN
		UPDATE dbo.customerMaster SET verifiedDate=GETDATE(),verifiedBy=@user  WHERE customerId=@customerId
		SELECT '0' ErrorCode , 'Customer verified successfully.' Msg , @customerId id
        
		RETURN
	END

	ELSE IF @flag='approve-pending'
	BEGIN
		DECLARE @custIdNumber VARCHAR(50), @WALLET_ACC_NO VARCHAR(30), @fullName VARCHAR(100)
	 
		SELECT @custIdNumber = idNumber 
			,@fullName = ISNULL(fullName, firstName)
		FROM dbo.customerMaster (NOLOCK) 
		WHERE customerId = @customerId
	 
		SELECT @cusType = userType from applicationUsers(nolock) where userName = @user

		IF EXISTS (SELECT 'X' FROM dbo.customerMaster (NOLOCK) WHERE replace(idNumber,'-','') = replace(@custIdNumber, '-', '')
						GROUP BY replace(idNumber,'-','') having count(1)>1)
		BEGIN
			SELECT '1' ErrorCode , 'Duplicate id number found for customer' Msg ,null
			RETURN
		END
	 
		IF EXISTS (SELECT 'X' FROM dbo.customerMaster (NOLOCK) WHERE replace(idNumber,'-','') = replace(@custIdNumber, '-', '') AND approvedBy IS NOT NULL)
		BEGIN
			SELECT '1' ErrorCode , 'Customer with same id number already approved.' Msg ,null
			RETURN
		END

		DECLARE @newPassword varchar(20)  =  RIGHT('0000000' + CAST(CHECKSUM(NEWID()) AS VARCHAR), 7)

		IF EXISTS(SELECT 'A' FROM customerMaster(NOLOCK) WHERE customerId = @customerId and customerPassword is not null)
			SELECT @newPassword = dbo.FNAencryptString(customerPassword) FROM customerMaster(NOLOCK) WHERE customerId = @customerId and customerPassword is not null
		ELSE
		BEGIN
			UPDATE dbo.customerMaster SET  customerPassword = dbo.FNAencryptString(@newPassword) WHERE customerId = @customerId
		END
		
		EXEC PROC_CREATE_CUSTOMER_WALLET @CUSTOMER_ID = @customerId, @USER = @USER

		UPDATE dbo.customerMaster SET approvedBy = @user, approvedDate = GETDATE(),verifiedDate=GETDATE(),verifiedBy=@user WHERE customerId = @customerId
		
		SELECT '0' ErrorCode , 'Customer verified successfully.' Msg ,@customerId id
		

		SELECT 	username = ISNULL(cm.email,''),
				[password] = dbo.FNADecryptString(cm.customerPassword),
				[channel]  = 'registration',
				[account]  = ISNULL(cm.membershipId,''),
				fullName,
				CustomerBankName,
				cm.idType,				
				REPLACE(cm.idNumber, ' ', '') AS [idNumber],
				CONVERT(VARCHAR, cm.dob, 111) AS [dob]
		FROM 	dbo.customerMaster cm(NOLOCK) 
		WHERE 	cm.customerId = @customerId
		RETURN
	END

	ELSE IF @flag='update-obpId'
	BEGIN
		BEGIN TRAN
			UPDATE dbo.customerMaster SET obpId = @obpId 
				,approvedDate=GETDATE(),approvedBy=@user ,customerStatus= 'V'
				,verifiedBy =case when verifiedBy is null then @user else verifiedBy end
				,verifiedDate =case when verifiedDate is null then GETDATE() else verifiedDate end
			WHERE customerId = @customerId

			DECLARE @Mobile VARCHAR(20)
			select @virtualAccountNo =  walletAccountNo
					,@CustomerBankName = firstName+'- Principle'
					,@Mobile	 = mobile
			from customerMaster(nolock)
			WHERE customerId = @customerId

			----#### SEND NOTIFICATION TO CUSTOMER
			DECLARE @SMSBody VARCHAR(90) = 'Dear '+LEFT(@CustomerBankName,14)+' You are successfully registered with GME.Thank you for choosing GME.'
			
			exec FastMoneyPro_Remit.dbo.proc_CallToSendSMS @FLAG = 'I',@SMSBody = @SMSBody,@MobileNo = @Mobile

			IF not EXISTS(SELECT 'A' FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE acct_num = @virtualAccountNo)
			begin
				DECLARE @GL INT = 79

				insert into FastMoneyPro_Account.dbo.ac_master 
					(acct_num, acct_name,gl_code, branch_id,acct_ownership,acct_rpt_code
					, acct_opn_date,clr_bal_amt, system_reserved_amt,lien_amt, utilised_amt, available_amt,created_date,created_by,company_id)

				select @virtualAccountNo,@CustomerBankName,@GL,@customerId,'c' ,'CP'
					,getdate(),0,0,0,0,0,getdate(),@user,1
			end
		commit tran
		SELECT '0' ErrorCode , 'Customer Partern service account registered successfully.' Msg , @customerId id
	END

	ELSE IF @flag='checkVirtualNo'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM dbo.customerMaster WHERE walletAccountNo=@virtualAccountNo)
		SELECT '1' ErrorCode , 'Invalid Virtual AccountNo' Msg , NULL id
		RETURN;
	END

	ELSE IF @flag='checkPrimaryAccountNo'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM dbo.customerMaster WHERE bankAccountNo=@primaryAccountNo)
		SELECT '1' ErrorCode , 'Invalid Primary AccountNo' Msg , NULL id
	END
	ELSE IF @flag='AuditList' --AUDITED DOC LIST
	BEGIN
	SET @sortBy = 'createdDate'
	SET @sortOrder = 'desc'

	SET @table ='(
		SELECT SN=ROW_NUMBER() over(ORDER BY cm.customerId asc)
				,customerId=cm.customerId
				,email=cm.email
				,fullName= REPLACE(ISNULL(cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName1, ''''), ''  '', '' '')
				,dob=CONVERT(VARCHAR,cm.dob,101)
				,address=cm.[address]
				,nativeCountry=com.countryName
				,idtype=sdv.detailTitle
				,idNumber=cm.idNumber
				,createdDate=CAST(cm.createdDate AS DATE)
				,verifiedBy=cm.verifiedBy
				,branchName=''''
				,verifiedDate=CAST(cm.verifiedDate AS DATE)
				,ipAddress=cm.ipAddress
				,mobile=cm.mobile
				,bankAccountNo
				,bankName=bl.bankName
				,cm.AuditBy,cm.AuditDate
		FROM customerMaster cm(NOLOCK)
		LEFT JOIN countryMaster com(NOLOCK) ON cm.nativeCountry=com.countryId
		INNER JOIN staticDataValue sdv (NOLOCK) ON sdv.valueId=cm.idType AND sdv.typeID=1300
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		WHERE cm.verifiedDate IS NOT NULL AND cm.AuditDate IS NOT NULL'
		
	IF ISNULL(@fromDate,'')<>'' AND ISNULL(@toDate,'')<>''
	SET @table=@table + ' AND cm.createdDate BETWEEN ''' +CAST(@fromDate AS VARCHAR)+''' AND ''' +CAST(@toDate AS VARCHAR)+''''

	SET @table = @table + ')x'
	SET @sql_filter = ''

	IF ISNULL(@searchCriteria,'')<>'' AND ISNULL(@searchValue,'')<>''
	BEGIN 
		IF @searchCriteria='idNumber'
		BEGIN
			--IF ISNUMERIC(@searchValue)<>1
			--	SET @searchValue='-1'	--to ignore string value for datatype integer/customerID
			--SET @sql_Filter=@sql_Filter + ' AND customerId = ''' +@searchValue+''''
			SET @sql_Filter=@sql_Filter + ' AND REPLACE(idNumber, ''-'', '''') = ''' +REPLACE(@searchValue, '-', '')+''''
		END
		ELSE IF @searchCriteria='emailId'
			SET @sql_Filter=@sql_Filter + ' AND email like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='customerName'
			SET @sql_Filter=@sql_Filter + ' AND fullName like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='mobile'
			SET @sql_Filter=@sql_Filter + ' AND mobile = ''' +@searchValue+''''
		ELSE IF @searchCriteria='walletAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND walletAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='bankAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND bankAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='nativeCountry'
			SET @sql_Filter=@sql_Filter + ' AND nativeCountry = ''' +@searchValue+''''
	END

	
	SET @select_field_list ='
				 SN,customerId,email,fullName,dob,address,nativeCountry,idtype,idNumber
				,createdDate,verifiedBy,branchName,verifiedDate,bankAccountNo,bankName,AuditBy,AuditDate
				'	
	EXEC dbo.proc_paging
			@table,@sql_filter,@select_field_list,@extra_field_list
			,@sortBy,@sortOrder,@pageSize,@pageNumber

		RETURN
	END
	ELSE IF @flag='s-customereditedata'
	BEGIN	
		IF @sortBy IS NULL
		   SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'DESC'
		 SET @table = '(
							SELECT fullName
							,customerId
							,membershipId
							,mobile
							,city
							,rowId
							,createdDate
							,hasChanged = CASE WHEN approvedBy IS NULL THEN ''Y'' ELSE ''N'' END
							,modifiedBy = CASE WHEN approvedBy IS NULL THEN createdBy ELSE createdBy END
						    from customerMasterEditedDataMod
						)x'
	
		SET @sql_filter = ''
		
		SET @select_field_list ='fullName,customerId,membershipId,mobile,city,rowId,createdDate,hasChanged,modifiedBy'
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber
			
	END
	ELSE IF @flag = 'approve' 
	BEGIN
		DECLARE 
		@firstName						VARCHAR(30)				= NULL 
		,@middleName					VARCHAR(30)				= NULL
		,@lastName1				   	    VARCHAR(100)			= NULL 
		,@onlineUser			   	    VARCHAR(50)				= NULL 
		,@customerType			     	VARCHAR(30)				= NULL 
		,@country				     	VARCHAR(30)				= NULL 
		,@zipCode				   	    VARCHAR(30)				= NULL 
		,@state					   	    VARCHAR(30)				= NULL 
		,@street		 		   	    VARCHAR(80)				= NULL 
		,@custCity				   	    VARCHAR(100)			= NULL 
		,@cityUnicode		 	   	    NVARCHAR(100)			= NULL 
		,@streetUnicode			   	    NVARCHAR(100)			= NULL 
		,@custGender			   	    VARCHAR(30)				= NULL 
		,@custNativecountry		   	    VARCHAR(30)				= NULL 
		,@custDOB						VARCHAR(30)				= NULL 
		,@custEmail						VARCHAR(50)				= NULL 
		,@custTelNo						VARCHAR(30)				= NULL 
		,@custMobile					VARCHAR(30)				= NULL 
		,@dob							DATETIME				= NULL 
		,@visaStatus					INT						= NULL 
		,@employeeBusinessType			INT						= NULL 
		,@nameOfEmployeer				VARCHAR(80)				= NULL 
		,@SSNNO							VARCHAR(20)				= NULL 
		,@occupation					VARCHAR(30)				= NULL 
		,@sourceOfFound					VARCHAR(100)			= NULL 
		,@monthlyIncome					VARCHAR(50)				= NULL 
		,@customerIdType				VARCHAR(30)				= NULL 
		,@customerIdNo					VARCHAR(50)				= NULL 
		,@custIdissueDate				VARCHAR(30)				= NULL 
		,@custIdValidDate				VARCHAR(30)				= NULL 
		,@remittanceAllowed				BIT						= NULL 
		,@remarks						VARCHAR(1000)			= NULL 
		,@companyName					VARCHAR(100)			= NULL 
		,@registerationNo				VARCHAR(30)				= NULL 
		,@organizationType				INT						= NULL 
		,@dateofIncorporation			DATETIME				= NULL 
		,@natureOfCompany				INT						= NULL 
		,@nameOfAuthorizedPerson		VARCHAR(80)				= NULL 
		,@position						INT						= NULL 

		SELECT 
		@customerId				=   customerId	
		,@customerType			=   customerType		
		,@fullName				=   fullName	
		,@firstName				=	firstName
		,@middleName			=	middleName
		,@lastName1				=	lastName1
		,@country			  	=   country
		,@zipCode				=   zipCode
		,@state					=   state
		,@street				=   street
		,@custCity				=   city
		,@cityUnicode			=   cityUnicode
		,@streetUnicode			=   streetUnicode
		,@custGender			=   gender
		,@custNativecountry		=   nativeCountry
		,@custDOB				=   CONVERT(VARCHAR,dob,111)
		,@custEmail				=   email
		,@custTelNo				=   telNo
		,@custMobile			=   mobile			
		,@visaStatus			=   visaStatus				
		,@employeeBusinessType	=   employeeBusinessType	
		,@nameOfEmployeer		=   nameOfEmployeer		
		,@SSNNO					=   SSNNO					
		,@occupation			=   occupation				
		,@sourceOfFound			=   sourceOfFund			
		,@monthlyIncome			=   monthlyIncome			
		,@customerIdType		=   idType					
		,@customerIdNo			=   idNumber				
		,@custIdissueDate		=   CONVERT(VARCHAR,idIssueDate,111)		
		,@custIdValidDate		=   CONVERT(VARCHAR,idExpiryDate,111)				
		,@remittanceAllowed		=   remittanceAllowed		
		,@onlineUser			=   onlineUser				
		,@remarks				=   remarks				
		,@companyName			=	companyName			
		,@registerationNo		=	registerationNo		
		,@organizationType		=	organizationType		
		,@dateofIncorporation	=	CONVERT(VARCHAR,dateofIncorporation,111)	
		,@natureOfCompany		=	natureOfCompany		
		,@nameOfAuthorizedPerson=	nameOfAuthorizedPerson	
		,@position				=	position				
		 FROM dbo.customerMasterEditedDataMod WHERE customerId = @customerId

		 
	--LOG FOR CUSTOMER UPDATE
				--SET @fullName=ISNULL(@firstName, '') + ISNULL(' '
    --                                                          + @firstName,
    --                                                          '') + ISNULL(' '
    --                                                          + @lastName1, '');
				SET @onlineUser = CASE WHEN @onlineUser='Y'THEN 'True' ELSE 'False' END
				
                EXEC PROC_CUSTOMERMODIFYLOG 
					@flag						=	'i-new',
					@user						=	@user,
                    @customerId					=	@customerId,
					@customerType				=	@customerType,
					@fullName					=	@fullName,
					@firstName					=	@firstName,
					@middleName					=	@middleName,
					@lastName1					=	@lastName1,
					@country					=	@country,
					@zipCode					=	@zipCode,
					@state						=	@state,
					@street						=	@street,
					@custCity					=	@custCity,
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
					@sourceOfFound				=	@sourceOfFound,
					@monthlyIncome				=	@monthlyIncome,
					@idType						=	@customerIdType,
					@idNumber					=	@customerIdNo,	
					@issueDate					=	@custIdissueDate,	
					@expiryDate					=	@custIdValidDate,	
					@remittanceAllowed			=	@remittanceAllowed,
					@onlineUser					=	@onlineUser,	
					@remarks					=	@remarks,
					--used for customer type organisation
					@companyName				=	@companyName,	
					@registerationNo			=	@registerationNo,
					@organizationType			=	@organizationType,
					@dateofIncorporation		=	@dateofIncorporation,
					@natureOfCompany			=	@natureOfCompany,
					@nameOfAuthorizedPerson		=	@nameOfAuthorizedPerson,	
					@position					=	@position

		UPDATE cm SET cm.firstName = cmm.firstName,
						cm.middleName = cmm.middleName,
						cm.lastName1 = cmm.lastName1,
						cm.country  = cmm.country,
						cm.state = cmm.state,
						cm.zipCode = cmm.zipCode,
						cm.city = cmm.city ,
						cm.street = cmm.street,
						cm.fullName = ISNULL(cmm.firstName, '') + ISNULL(' '
                                                              + cmm.middleName,
                                                              '') + ISNULL(' '
                                                              + cmm.lastName1, ''),
						cm.email= cmm.email,
						cm.cityUnicode =cmm.cityUnicode,
						cm.streetUnicode = cmm.streetUnicode,
						cm.homePhone = cmm.homePhone,
						cm.mobile = cmm.mobile,
						cm.nativeCountry = cmm.nativeCountry,
						cm.dob = cmm.dob,
						cm.nameOfEmployeer = cmm.nameOfEmployeer,
						cm.SSNNO = cmm.SSNNO,
						cm.occupation= cmm.occupation,
						cm.idExpiryDate = cmm.idExpiryDate,
						cm.idType = cmm.idType,
						cm.idNumber = cmm.idNumber,
						cm.telNo = cmm.telNo,
						cm.gender = cmm.gender,
						cm.idIssueDate = cmm.idIssueDate,
						cm.onlineUser = cmm.onlineUser,
						cm.sourceOfFund = cmm.sourceOfFund,
						cm.visaStatus = cmm.visaStatus,
						cm.employeeBusinessType = cmm.employeeBusinessType,
						cm.remittanceAllowed = cmm.remittanceAllowed,
						cm.remarks = cmm.remarks,
						cm.organizationType = cmm.organizationType,
						cm.dateofIncorporation = cmm.dateofIncorporation,
						cm.natureOfCompany = cmm.natureOfCompany,
						cm.nameOfAuthorizedPerson = cmm.nameOfAuthorizedPerson,
						cm.monthlyIncome = cmm.monthlyIncome,
						cm.registerationNo = cmm.registerationNo,
						cm.modifiedBy = @user,
						cm.modifiedDate = GETDATE()
		 FROM dbo.customerMaster cm (NOLOCK)
		INNER JOIN dbo.customerMasterEditedDataMod cmm (NOLOCK) ON cmm.customerId = cm.customerId
		WHERE cm.customerId = @customerId

		DELETE FROM dbo.customerMasterEditedDataMod WHERE customerId = @customerId
		EXEC proc_errorHandler 0, 'Customer Edited Data Approved Successfully', @customerId	
	END
	ELSE IF @flag = 'reject'
	BEGIN
		DELETE FROM dbo.customerMasterEditedDataMod WHERE customerId = @customerId
		EXEC dbo.proc_errorHandler @errorCode = '0', -- varchar(10)
		    @msg = 'Changes rejected successfully', -- varchar(max)
		    @id = @customerid -- varchar(50)
		
	END
	IF @flag='vl-forAgent' --verified list/approve pending list
	BEGIN
	--DECLARE @agentid VARCHAR(10)
	--SELECT  @agentid = agentid FROM applicationusers WHERE username = @user
	--DECLARE @branchcode VARCHAR(10)
	--SELECT  @branchcode = branchcode FROM agentmaster WHERE agentid = @agentid

	SET @sortBy = 'createdDate'
	SET @sortOrder = 'desc'

	SET @table ='(
		SELECT customerId=cm.customerId
		,CM.membershipid
				,email=cm.email
				,fullName= REPLACE(ISNULL(cm.firstName, '''') + ISNULL('' '' + cm.middleName, '''') + ISNULL('' '' + cm.lastName1, ''''), ''  '', '' '')
				,dob=CONVERT(VARCHAR,cm.dob,101)
				,address=cm.[address]
				,nativeCountry=com.countryName
				,idtype=sdv.detailTitle
				,idNumber=cm.idNumber
				,createdDate=CAST(cm.createdDate AS DATE)
				,createdBy=cm.createdBy
				,verifiedBy=cm.verifiedBy
				,branchName=''''
				,verifiedDate=CAST(cm.verifiedDate AS DATE)
				,ipAddress=cm.ipAddress
				,mobile=cm.mobile
				,bankAccountNo
				,bankName=bl.bankName
				,cm.agentId
		FROM customerMaster cm(NOLOCK)
		LEFT JOIN countryMaster com(NOLOCK) ON cm.nativeCountry=com.countryId
		INNER JOIN staticDataValue sdv (NOLOCK) ON sdv.valueId=cm.idType AND sdv.typeID=1300
		LEFT JOIN vwBankLists bl (NOLOCK) ON cm.bankName = bl.rowId
		INNER JOIN APPLICATIONUSERS AU (NOLOCK) ON AU.USERNAME = CM.CREATEDBY
		WHERE au.username <> '''+@user+''' 
		AND cm.approvedDate IS NULL
		AND CM.ISACTIVE = ''Y'''
	
	IF ISNULL(@fromDate,'')<>'' AND ISNULL(@toDate,'')<>''
	SET @table=@table + ' AND cm.createdDate BETWEEN ''' +CAST(@fromDate AS VARCHAR)+''' AND ''' +CAST(@toDate AS VARCHAR)+''''

	SET @table = @table + ')x'
	SET @sql_filter = ''
	--SET @sql_Filter=@sql_Filter + ' AND substring(membershipid,1,3) = '''+@branchcode+''''
	SET @sql_Filter=@sql_Filter + ' AND agentId  = '+cast(@agentId as varchar) +''
	
	IF ISNULL(@searchCriteria,'')<>'' AND ISNULL(@searchValue,'')<>''
	BEGIN 
		IF @searchCriteria='idNumber'
		BEGIN
			--IF ISNUMERIC(@searchValue)<>1
			--	SET @searchValue='-1'	--to ignore string value for datatype integer/customerID
			--SET @sql_Filter=@sql_Filter + ' AND customerId = ''' +@searchValue+''''
			SET @sql_Filter=@sql_Filter + ' AND REPLACE(idNumber, ''-'', '''') = ''' +REPLACE(@searchValue, '-', '')+''''
		END
		ELSE IF @searchCriteria='emailId'
			SET @sql_Filter=@sql_Filter + ' AND email like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='customerName'
			SET @sql_Filter=@sql_Filter + ' AND fullName like ''' +@searchValue+'%'''
		ELSE IF @searchCriteria='mobile'
			SET @sql_Filter=@sql_Filter + ' AND mobile = ''' +@searchValue+''''
		ELSE IF @searchCriteria='walletAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND walletAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='bankAccountNo'
			SET @sql_Filter=@sql_Filter + ' AND bankAccountNo = ''' +@searchValue+''''
		ELSE IF @searchCriteria='nativeCountry'
			SET @sql_Filter=@sql_Filter + ' AND nativeCountry = ''' +@searchValue+''''
	END

	
	SET @select_field_list ='
				 customerId,membershipid,email,fullName,dob,address,nativeCountry,idtype,idNumber
				,createdDate,createdBy,verifiedBy,branchName,verifiedDate,bankAccountNo,bankName
				'	
	EXEC dbo.proc_paging
			@table,@sql_filter,@select_field_list,@extra_field_list
			,@sortBy,@sortOrder,@pageSize,@pageNumber

		RETURN
	END
END TRY
BEGIN CATCH
	 IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE()  
     EXEC proc_errorHandler 1, @errorMessage, NULL  
END CATCH



