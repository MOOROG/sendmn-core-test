SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

--ALTER TABLE  receiverInformation add nativeCountry VARCHAR(100) NULL 
--EXEC PROC_MOBILE_RECEIVER_INFORMATION  @flag = 'receiver-info', @customerId =32994

ALTER PROCEDURE PROC_MOBILE_RECEIVER_INFORMATION(
	 @flag				  VARCHAR(100) =  NULL
	,@customerId		  VARCHAR(100) =  NULL
	,@receiverId		  VARCHAR(100) =  NULL
	,@firstName			  VARCHAR(100) =  NULL
	,@middleName		  VARCHAR(100) =  NULL
	,@lastName1			  VARCHAR(100) =  NULL
	,@lastName2			  VARCHAR(100) =  NULL
	,@country			  VARCHAR(100) =  NULL
	,@countryId			  VARCHAR(100) =  NULL
	,@nativeCountry		  VARCHAR(100) =  NULL
	,@address			  VARCHAR(100) =  NULL
	,@state				  VARCHAR(100) =  NULL
	,@stateId			  VARCHAR(100) =  NULL
	,@zipCode			  VARCHAR(100) =  NULL
	,@city				  VARCHAR(100) =  NULL
	,@email				  VARCHAR(100) =  NULL
	,@homePhone			  VARCHAR(100) =  NULL
	,@workPhone			  VARCHAR(100) =  NULL
	,@mobile			  VARCHAR(100) =  NULL
	,@relationship		  VARCHAR(100) =  NULL
	,@relationshipId	  VARCHAR(100) =  NULL
	,@district			  VARCHAR(100) =  NULL
	,@districtId		  VARCHAR(100) =  NULL
	,@purposeOfRemit	  VARCHAR(100) =  NULL	
	,@fullName			  VARCHAR(100) =  NULL
	,@idType			  VARCHAR(100) =  NULL
	,@idNumber			  VARCHAR(100) =  NULL
	,@bank				  VARCHAR(100) =  NULL
	,@branch			  VARCHAR(100) =  NULL
	,@accountNo			  VARCHAR(100) =  NULL
	,@localFirstName	  NVARCHAR(100) =  NULL
	,@localMiddleName	  NVARCHAR(100) =  NULL
	,@localLastName1	  NVARCHAR(100) =  NULL
	,@localLastName2	  NVARCHAR(100) =  NULL
	,@paymentMethodId	  VARCHAR(100) =  NULL
)AS
BEGIN
	IF @flag = 'receiver-info'
	BEGIN

		SELECT 
			receiverId = ri.receiverId,
			fullName = CASE WHEN ri.firstName + ISNULL(' '+ ri.middleName,'') + ISNULL(' '+ ri.lastName1,'') IS NOT NULL THEN ri.firstName + ISNULL(' '+ ri.middleName,'') + ISNULL(' '+ ri.lastName1,'') ELSE  ri.localFirstName + ISNULL(' '+ ri.localMiddleName,'') + ISNULL(' '+ ri.localLastName1,'') END,
			ri.firstName,
			ri.middleName ,
			lastName1 = LTRIM(RTRIM(ISNULL(' '+ ri.lastName1,'')+ISNULL(' ' + ri.lastName2,''))),
			lastName2 ='',
			[localizedName] = ri.localFirstName + ISNULL(' '+ ri.localMiddleName,'') + ISNULL(' '+ ri.localLastName1,''),
			[paymentMethodId] = ri.paymentMode,
			[paymentMethodName] = stm.typeTitle,
			[bankId] =  ri.bank,--dbo.IsBankActive(ri.bank, ri.paymentMode),--
			[bankName] = amb.BANK_NAME, 
			[bankLocalizedName] =  amb.BANK_NAME,
			[branchId] = ri.branch,
			[branchName] = bBranch.BRANCH_NAME+' - '+bBranch.BRANCH_CODE1,
			[branchLocalizedName] = bBranch.BRANCH_NAME+' - '+bBranch.BRANCH_CODE1,
			[accountNo] = ri.receiverAccountNo,
			ri.membershipId,      
			ri.country,           
			ri.address,           
			state = ri.state,             
			stateId = ri.state,--(SELECT TOP 1 CAST(TSL.rowId AS VARCHAR) AS id FROM dbo.tblServicewiseLocation(NOLOCK) AS TSL WHERE TSL.location = ri.state),   
			district = ri.district,             
			districtId = ri.district,--(SELECT TOP 1 CAST(TSL.rowId AS VARCHAR) AS id FROM dbo.tblSubLocation(NOLOCK) AS TSL WHERE TSL.subLocation = ri.district), 
			ri.zipCode,           
			ri.city,              
			ri.email,             			      
			ri.mobile,            
			relationship =CASE WHEN ISNUMERIC(ri.relationship)=1 THEN rel.detailTitle ELSE ri.relationship END, 
			relationshipId = ri.relationship,     			        
			purposeOfRemitId = ri.purposeOfRemit,    			          
			purposeOfRemit =CASE WHEN ISNUMERIC(ri.purposeOfRemit)=1 THEN por.detailTitle ELSE ri.purposeOfRemit END,    			          
			idType = ri.idType,            
			idTypeId =  ri.idType,                  
			ri.idNumber,
			ri.localFirstName,
			ri.localMiddleName,
			ri.localLastName1,
			ri.localLastName2,
			
			countryId =  cm.countryId,
			countryCode =  cm.countryCode,
			bankCurrency= dbo.GetAllowCurrency(cm.countryId,ri.paymentMode,ri.bank),
			paymentMethodCurrency= dbo.GetAllowCurrency(cm.countryId,ri.paymentMode,ri.bank),
			payoutPartner = payOutPartner,--dbo.GetActivePayoutPartner(cm.countryId,ri.paymentMode,ri.bank),
			nativeCountry = ncm.countryName,
			nativeCountryCode = ncm.countryCode,
			nativeCountryId = ncm.countryId


		FROM dbo.receiverInformation(nolock) ri 
		INNER JOIN dbo.countryMaster(nolock) cm ON ri.country =  cm.countryName
		LEFT JOIN dbo.countryMaster(nolock) ncm ON ri.nativeCountry =  ncm.countryId
		LEFT JOIN dbo.serviceTypeMaster(nolock) stm ON stm.serviceTypeId = ri.paymentMode
		LEFT JOIN dbo.staticDataValue (NOLOCK) rel ON CAST(Rel.valueId AS VARCHAR(200))=ri.relationship
		LEFT JOIN dbo.staticDataValue (NOLOCK) por ON CAST(por.valueId AS VARCHAR(200))=ri.purposeOfRemit
		LEFT JOIN dbo.API_BANK_LIST(nolock) amb ON amb.BANK_ID = ri.bank
		LEFT JOIN dbo.API_BANK_BRANCH_LIST(NOLOCK) bBranch ON bBranch.BRANCH_ID = ri.branch				
		WHERE ri.customerId = @customerId AND ISNULL(ri.isActive,'0') = '1'
	END

	IF @flag = 'get'
	BEGIN
		  SELECT 
			receiverId = ri.receiverId,
			fullName = CASE WHEN ri.firstName + ISNULL(' '+ ri.middleName,'') + ISNULL(' '+ ri.lastName1,'') IS NOT NULL THEN ri.firstName + ISNULL(' '+ ri.middleName,'') + ISNULL(' '+ ri.lastName1,'') ELSE  ri.localFirstName + ISNULL(' '+ ri.localMiddleName,'') + ISNULL(' '+ ri.localLastName1,'') END,
			ri.firstName,
			ri.middleName ,
			lastName1 = LTRIM(RTRIM(ISNULL(' '+ ri.lastName1,'')+ISNULL(' ' + ri.lastName2,''))),
			lastName2 ='',
			[localizedName] = ri.localFirstName + ISNULL(' '+ ri.localMiddleName,'') + ISNULL(' '+ ri.localLastName1,''),
			[paymentMethodId] = ri.paymentMode,
			[paymentMethodName] = stm.typeTitle,
			[bankId] =  ri.bank,
			[bankName] =  amb.agentName,
			[bankLocalizedName] =  amb.agentName,
			[branchId] = ri.branch,
			[branchName] = abbb.agentName,
			[branchLocalizedName] = abbb.agentName,
			[accountNo] = ri.receiverAccountNo,
			ri.membershipId,      
			ri.country,           
			ri.address,           
			state = ri.state,             
			stateId = ri.state,--(SELECT TOP 1 CAST(TSL.rowId AS VARCHAR) AS id FROM dbo.tblServicewiseLocation(NOLOCK) AS TSL WHERE TSL.location = ri.state),   
			
			
			district = ri.district,             
			districtId = ri.district,--(SELECT TOP 1 CAST(TSL.rowId AS VARCHAR) AS id FROM dbo.tblSubLocation(NOLOCK) AS TSL WHERE TSL.subLocation = ri.district), 
			          
			ri.zipCode,           
			ri.city,              
			ri.email,             			      
			ri.mobile,            
			relationship = ri.relationship, 
			relationshipId = ri.relationship,     			        
			purposeOfRemitId = ri.purposeOfRemit,    			          
			purposeOfRemit = ri.purposeOfRemit,    			          
			idType = ri.idType,            
			idTypeId =  ri.idType,          
			ri.idNumber,
			ri.localFirstName,
			ri.localMiddleName,
			ri.localLastName1,
			ri.localLastName2,
			
			countryId =  cm.countryId,
			countryCode =  cm.countryCode,
			bankCurrency= dbo.GetAllowCurrency(cm.countryId,ri.paymentMode,ri.bank),
			paymentMethodCurrency= dbo.GetAllowCurrency(cm.countryId,ri.paymentMode,null),
			payoutPartner = payOutPartner,--dbo.GetActivePayoutPartner(cm.countryId,ri.paymentMode,ri.bank),
			nativeCountry = ncm.countryName,
			nativeCountryCode = ncm.countryCode,
			nativeCountryId = ncm.countryId

		FROM dbo.receiverInformation(nolock) ri 
		INNER JOIN dbo.countryMaster(nolock) cm ON ri.country =  cm.countryName
		LEFT JOIN dbo.countryMaster(nolock) ncm ON ri.nativeCountry =  ncm.countryId
		LEFT JOIN dbo.serviceTypeMaster(nolock) stm ON stm.serviceTypeId = ri.paymentMode
		LEFT JOIN dbo.agentMaster(nolock) amb ON amb.agentId = ri.bank
		LEFT JOIN dbo.agentMaster(nolock) abbb ON abbb.agentId = ri.branch		
		--LEFT JOIN (SELECT * FROM dbo.staticDataValue(nolock) WHERE typeID = 3800)  AS purpose	ON ri.purposeOfRemit = relation.detailTitle
		WHERE ri.customerId = @customerId AND ISNULL(ri.isActive,'0') = '1' AND ri.receiverId = @receiverId
	END

	IF @flag = 'add'
	BEGIN		
		DECLARE @relationId VARCHAR(200) = NULL,@porId VARCHAR(200) = NULL

		IF NOT EXISTS(SELECT 'X' FROM dbo.customerMaster(NOLOCK) WHERE customerId=@customerId)
		BEGIN
		    SELECT '1' ErrorCode, 'Customer Details Not Found' Msg, @customerId Id
			RETURN
		END

		IF EXISTS(SELECT 'x' FROM dbo.receiverInformation(NOLOCK) WHERE mobile=@mobile)
		BEGIN
		    SELECT '1' ErrorCode, 'Receiver Mobile No Already Register !' Msg, @mobile Id
			RETURN
		END 

		SELECT @countryId = countryId FROM dbo.countryMaster(NOLOCK) WHERE countryName = @nativeCountry	

		IF ISNULL(@fullName,'') =''
		BEGIN
		    SET @fullName=@firstName+ISNULL(' '+@middleName,'')+ISNULL(' '+@lastName1,'')+ISNULL(' '+@lastName2,'')
		END

		SELECT @relationId= valueid FROM dbo.staticDataValue(NOLOCK) WHERE detailTitle=@relationship

		IF ISNULL(@relationId,'')=''
		BEGIN
		    SET @relationId=@relationship
		END

		SELECT @porId=valueId FROM dbo.staticDataValue(NOLOCK) WHERE detailTitle=@purposeOfRemit
		
		IF ISNULL(@porId,'')=''
		BEGIN
		    SET @porId=@purposeOfRemit
		END

		INSERT INTO dbo.receiverInformation
		(
			customerId,firstName,middleName,lastName1,lastName2,country,address,state,zipCode,city,email,homePhone,workPhone,mobile,relationship
			,district,purposeOfRemit,isActive,fullName,idType,idNumber,bank,branch,receiverAccountNo,localFirstName,localMiddleName,localLastName1,localLastName2
			,paymentMode,nativeCountry,createdDate
		)
		SELECT 
			 @customerId,@firstName,@middleName,LTRIM(RTRIM(ISNULL(' '+ @lastName1,'')+ISNULL(' ' + @lastName2,''))),NULL,@country,@address,@state,@zipCode,@city,@email,@homePhone,@workPhone,@mobile,@relationId
			,@district,@porId,1,@fullName,@idType,@idNumber,@bank,@branch,@accountNo,@localFirstName,@localMiddleName,@localLastName1,@localLastName2
			,@paymentMethodId,@countryId,GETDATE()
			

		  SET @receiverId = @@IDENTITY

		SELECT '0' ErrorCode, 'Receiver saved successfully' Msg, ISNULL(@receiverId,'-1') Id
		RETURN		    

	END

	IF @flag = 'modify'
	BEGIN		
		SELECT @countryId = countryId FROM dbo.countryMaster(NOLOCK) WHERE countryName = @nativeCountry	

		IF NOT EXISTS(SELECT 'x' FROM receiverInformation(nolock) WHERE receiverId = @receiverId AND customerId=@customerId)
		BEGIN
			SELECT '1' ErrorCode, 'Receiver Data Not Found' Msg, NULL Id
			RETURN
		END
		DECLARE @IdTypeInt INT = NULL
		IF EXISTS(SELECT '1' FROM dbo.staticDataValue(NOLOCK) WHERE detailTitle=@idType)
		BEGIN
			SELECT @IdTypeInt = valueId FROM dbo.staticDataValue(NOLOCK) WHERE detailTitle=@idType
		END
		UPDATE dbo.receiverInformation SET 
			 firstName				=		@firstName
			,middleName				=		@middleName
			,lastName1				=		LTRIM(RTRIM(ISNULL(' '+ @lastName1,'')+ISNULL(' ' + @lastName2,'')))
			,lastName2				=		NULL
			,country				=		@country
			,address				=		@address
			,state					=		@state
			,zipCode				=		@zipCode
			,city					=		@city
			,email					=		@email
			,homePhone				=		@homePhone
			,workPhone				=		@workPhone
			,mobile					=		@mobile
			,relationship			=		@relationship
			,district				=		@district
			,purposeOfRemit			=		@purposeOfRemit		
			,fullName				=		@fullName
			,idType					=		ISNULL(@IdTypeInt,@idType)
			,idNumber				=		@idNumber
			,bank					=		@bank
			,branch					=		@branch
			,receiverAccountNo		=		@accountNo
			,localFirstName			=		@localFirstName
			,localMiddleName		=		@localMiddleName
			,localLastName1			=		@localLastName1
			,localLastName2			=		@localLastName2
			,paymentMode			=		@paymentMethodId
			,nativeCountry			=		@countryId
		WHERE receiverId			=		@receiverId     

					
		SELECT '0' ErrorCode, 'Receiver modified successfully' Msg, @receiverId Id
		RETURN		    
	END

	IF @flag = 'delete'
	BEGIN
		UPDATE dbo.receiverInformation SET isActive = '0' WHERE receiverId = @receiverId
		SELECT '0' ErrorCode, 'Receiver removed successfully' Msg, NULL Id
		RETURN
	END

END

GO

