alter PROC PROC_RECEIVERMODIFYLOGS
	  @flag						VARCHAR(50)		= NULL,
      @user						VARCHAR(30)		= NULL,
      @receiverId				VARCHAR(50)		= NULL,
      @customerId				VARCHAR(50)		= NULL,
      @membershipId				VARCHAR(50)		= NULL,
      @firstName				VARCHAR(100)	= NULL,
      @middleName				VARCHAR(100)	= NULL,
      @lastName1				VARCHAR(100)	= NULL,
      @lastName2				VARCHAR(100)	= NULL,
	  @fullName					VARCHAR(100)	= NULL,
      @country					VARCHAR(200)	= NULL,
      @nativeCountry			VARCHAR(200)	= NULL,
      @address					VARCHAR(500)	= NULL,
      @state					VARCHAR(200)	= NULL,
      @zipCode					VARCHAR(50)		= NULL,
      @city						VARCHAR(100)	= NULL,
      @email					VARCHAR(150)	= NULL,
      @homePhone				VARCHAR(100)	= NULL,
      @workPhone				VARCHAR(100)	= NULL,
      @mobile					VARCHAR(100)	= NULL,
      @relationship				VARCHAR(100)	= NULL,
      @sortBy					VARCHAR(50)		= NULL,
      @sortOrder				VARCHAR(5)		= NULL,
      @pageSize					INT				= NULL,
      @pageNumber				INT				= NULL,
      @receiverType				INT				= NULL,
      @idType					INT				= NULL,
      @idNumber					VARCHAR(25)		= NULL,
      @placeOfIssue				VARCHAR(80)		= NULL,
      @paymentMode				INT				= NULL,
      @bankLocation				VARCHAR(100)	= NULL,
      @payOutPartner			INT				= NULL,
      @bankName					VARCHAR(150)	= NULL,
      @receiverAccountNo		VARCHAR(40)		= NULL,
      @remarks					NVARCHAR(800)	= NULL,
      @purposeOfRemit			VARCHAR(100)	= NULL,
      @fromDate					NVARCHAR(20)	= NULL,
      @toDate					NVARCHAR(20)	= NULL,
	  @otherRelationDesc		VARCHAR(20)		= NULL,
	  @tranId					BIGINT			= NULL,
	  @fieldName				VARCHAR(20)		= NULL,
	  @fieldValue				VARCHAR(MAX)	= NULL,
	  @receiverName				varchar(200)	= NULL,
	  @nameChanged				BIT				= NULL,
	  @roldNameXml				VARCHAR(MAX)	= NULL,
	  @sessionId				VARCHAR(MAX)	= NULL,
	  @isNotXmlData				BIT				= NULL			
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	DECLARE  @oldfirstName				    VARCHAR(100)	= NULL,
			 @oldmiddleName					VARCHAR(100)	= NULL,
			 @oldlastName1				    VARCHAR(100)	= NULL,
			 @oldlastName2					VARCHAR(100)	= NULL,
			 @oldfullName					VARCHAR(100)	= NULL,
			 @oldcountry					VARCHAR(200)	= NULL,
			 @oldnativeCountry				VARCHAR(200)	= NULL,
			 @oldaddress					VARCHAR(500)	= NULL,
			 @oldstate						VARCHAR(200)	= NULL,
			 @oldzipCode					VARCHAR(50)		= NULL,
			 @oldcity						VARCHAR(100)	= NULL,
			 @oldemail						VARCHAR(150)	= NULL,
			 @oldhomePhone					VARCHAR(100)	= NULL,
			 @oldworkPhone					VARCHAR(100)	= NULL,
			 @oldmobile						VARCHAR(100)	= NULL,
			 @oldrelationship				VARCHAR(100)	= NULL,
			 @oldsortBy						VARCHAR(50)		= NULL,
			 @oldsortOrder					VARCHAR(5)		= NULL,
			 @oldpageSize					INT				= NULL,
			 @oldpageNumber					INT				= NULL,
			 @oldreceiverType				INT				= NULL,
			 @oldidType						INT				= NULL,
			 @oldidNumber					VARCHAR(25)		= NULL,
			 @oldplaceOfIssue				VARCHAR(80)		= NULL,
			 @oldpaymentMode				INT				= NULL,
			 @oldbankLocation				VARCHAR(100)	= NULL,
			 @oldpayOutPartner				INT				= NULL,
			 @oldbankName					VARCHAR(150)	= NULL,
			 @oldreceiverAccountNo			VARCHAR(40)		= NULL,
			 @oldremarks					NVARCHAR(800)	= NULL,
			 @oldpurposeOfRemit				VARCHAR(100)	= NULL,
			 @oldfromDate					NVARCHAR(20)	= NULL,
			 @oldtoDate						NVARCHAR(20)	= NULL,
			 @oldotherRelationDesc			VARCHAR(20)		= NULL
			

	SELECT    @oldfirstName				= RTRIM(LTRIM(firstName))
			 ,@oldmiddleName			= RTRIM(LTRIM(middleName))		
			 ,@oldlastName1				= RTRIM(LTRIM(lastName1))	
			 ,@oldlastName2				= RTRIM(LTRIM(lastName2))	
			 ,@oldfullName				= RTRIM(LTRIM(firstName)) + ISNULL(' ' + RTRIM(LTRIM(middleName)),'') + ISNULL(' ' + RTRIM(LTRIM(lastName1)),'') + ISNULL(' ' + RTRIM(LTRIM(lastName2)) ,'')	
			 ,@oldcountry				= country			
			 ,@oldnativeCountry			= nativeCountry	
			 ,@oldaddress				= address			
			 ,@oldstate					= state			
			 ,@oldzipCode				= zipCode			
			 ,@oldcity					= city				
			 ,@oldemail					= email			
			 ,@oldhomePhone				= homePhone		
			 ,@oldworkPhone				= workPhone		
			 ,@oldmobile				= mobile			
			 ,@oldrelationship			= relationship		
			 ,@oldreceiverType			= receiverType		
			 ,@oldidType				= idType			
			 ,@oldidNumber				= idNumber			
			 ,@oldplaceOfIssue			= placeOfIssue		
			 ,@oldpaymentMode			= paymentMode		
			 ,@oldbankLocation			= bankLocation		
			 ,@oldpayOutPartner			= payOutPartner	
			 ,@oldbankName				= bankName			
			 ,@oldreceiverAccountNo		= receiverAccountNo
			 ,@oldremarks				= remarks			
			 ,@oldpurposeOfRemit		= purposeOfRemit	
			 ,@oldotherRelationDesc	    = otherRelationDesc
		FROM receiverinformation
		WHERE CUSTOMERID = @customerId
		and receiverid = @receiverId
		DECLARE @amendmentId VARCHAR(max)

IF @FLAG = 'i'
BEGIN
	SET @amendmentId = NEWID()
	IF ISNULL(@oldfirstName,'') != ISNULL(@firstName,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'firstName', @oldfirstName, @user, GETDATE(), @firstName,@tranId,@amendmentId
		END
	IF ISNULL(@oldmiddleName,'') != ISNULL(@middleName,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'middleName', @oldmiddleName, @user, GETDATE(), @middleName,@tranId,@amendmentId
		END
	IF ISNULL(@oldlastName1,'') != ISNULL(@lastName1,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'lastName1', @oldlastName1, @user, GETDATE(), @lastName1,@tranId,@amendmentId
		END
	IF ISNULL(@oldlastName2,'') != ISNULL(@lastName2,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'lastName2', @oldlastName2, @user, GETDATE(), @lastName2,@tranId,@amendmentId
		END
	IF ISNULL(@oldfullName,'') != ISNULL(@fullName,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'fullName', @oldfullName, @user, GETDATE(), @fullName,@tranId,@amendmentId
		END
	IF ISNULL(@oldcountry,'') != ISNULL(@country,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'country', @oldcountry, @user, GETDATE(), @country,@tranId,@amendmentId
		END
	IF ISNULL(@oldnativeCountry,'') != ISNULL(@nativeCountry,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'nativeCountry', @oldnativeCountry, @user, GETDATE(), @nativeCountry,@tranId,@amendmentId
		END
	IF ISNULL(@oldaddress,'') != ISNULL(@address,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'address', @oldaddress, @user, GETDATE(), @address,@tranId,@amendmentId
		END
	IF ISNULL(@oldstate,'') != ISNULL(@state,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'state', @oldstate, @user, GETDATE(), @state,@tranId,@amendmentId
		END
	IF ISNULL(@oldzipCode,'') != ISNULL(@zipCode,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'zipCode', @oldzipCode, @user, GETDATE(), @zipCode,@tranId,@amendmentId
		END
	IF ISNULL(@oldcity,'') != ISNULL(@city,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'city', @oldcity, @user, GETDATE(), @city,@tranId,@amendmentId
		END
		
	IF ISNULL(@oldemail,'') != ISNULL(@email,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'email', @oldemail, @user, GETDATE(), @email,@tranId,@amendmentId
		END
	IF ISNULL(@oldhomePhone,'') != ISNULL(@homePhone,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'homePhone', @oldhomePhone, @user, GETDATE(), @homePhone,@tranId,@amendmentId
		END
	IF ISNULL(@oldworkPhone,'') != ISNULL(@workPhone,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'workPhone', @oldworkPhone, @user, GETDATE(), @workPhone,@tranId,@amendmentId
		END
	IF ISNULL(@oldmobile,'') != ISNULL(@mobile,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'mobile', @oldmobile, @user, GETDATE(), @mobile,@tranId,@amendmentId
		END
	IF ISNULL(@oldrelationship,'') != ISNULL(@relationship,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'relationship', @oldrelationship, @user, GETDATE(), @relationship,@tranId,@amendmentId
		END
	IF ISNULL(@oldreceiverType,'') != ISNULL(@receiverType,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'receiverType', @oldreceiverType, @user, GETDATE(), @receiverType,@tranId,@amendmentId
		END
	IF ISNULL(@oldidType,'') != ISNULL(@idType,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'idType', @oldidType, @user, GETDATE(), @idType,@tranId,@amendmentId
		END
		 
	IF ISNULL(@oldidNumber,'') != ISNULL(@idNumber,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'idNumber', @oldidNumber, @user, GETDATE(), @idNumber,@tranId,@amendmentId
		END
	IF ISNULL(@oldplaceOfIssue,'') != ISNULL(@placeOfIssue,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'placeOfIssue', @oldplaceOfIssue, @user, GETDATE(), @placeOfIssue,@tranId,@amendmentId
		END
	IF ISNULL(@oldpaymentMode,'') != ISNULL(@paymentMode,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'paymentMode', @oldpaymentMode, @user, GETDATE(), @paymentMode,@tranId,@amendmentId
		END
	IF ISNULL(@oldbankLocation,'') != ISNULL(@bankLocation,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'bankLocation', @oldbankLocation, @user, GETDATE(), @bankLocation,@tranId,@amendmentId
		END
	IF ISNULL(@oldpayOutPartner,'') != ISNULL(@payOutPartner,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'payOutPartner', @oldpayOutPartner, @user, GETDATE(), @payOutPartner,@tranId,@amendmentId
		END
	IF ISNULL(@oldbankName,'') != ISNULL(@bankName,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'bankName', @oldbankName, @user, GETDATE(), @bankName,@tranId,@amendmentId
		END
	IF ISNULL(@oldreceiverAccountNo,'') != ISNULL(@receiverAccountNo,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'receiverAccountNo', @oldreceiverAccountNo, @user, GETDATE(), @receiverAccountNo,@tranId,@amendmentId
		END
	IF ISNULL(@oldremarks,'') != ISNULL(@remarks,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'remarks', @oldremarks, @user, GETDATE(), @remarks,@tranId,@amendmentId
		END
	IF ISNULL(@oldpurposeOfRemit,'') != ISNULL(@purposeOfRemit,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'purposeOfRemit', @oldpurposeOfRemit, @user, GETDATE(), @purposeOfRemit,@tranId,@amendmentId
		END
	IF ISNULL(@oldotherRelationDesc,'') != ISNULL(@otherRelationDesc,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'otherRelationDesc', @oldotherRelationDesc, @user, GETDATE(), @otherRelationDesc,@tranId,@amendmentId
		END
	 END
ELSE IF @FLAG = 'i-fromModification'
BEGIN
	SET @amendmentId = NEWID();
	IF @fieldName = 'rIdType'
	BEGIN
		IF ISNULL(@oldidType,'') != ISNULL(@fieldValue,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'idType', @oldidType, @user, GETDATE(), @fieldValue,@tranId,@amendmentId
		END
	END
	ELSE IF @fieldName = 'rAddress'
	BEGIN
		IF ISNULL(@oldaddress,'') != ISNULL(@fieldValue,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'address', @oldaddress, @user, GETDATE(), @fieldValue,@tranId,@amendmentId
		END
	END
	ELSE IF @fieldName = 'rContactNo'
	BEGIN
		IF ISNULL(@oldmobile,'') != ISNULL(@fieldValue,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'mobile', @oldmobile, @user, GETDATE(), @fieldValue,@tranId,@amendmentId
		END
	END
	ELSE IF @fieldName = 'rIdNo'
	BEGIN
		IF ISNULL(@oldidNumber,'') != ISNULL(@fieldValue,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'idNumber', @oldidNumber, @user, GETDATE(), @fieldValue,@tranId,@amendmentId
		END
	END
	ELSE IF @fieldName = 'accountNo'
	BEGIN
		IF ISNULL(@oldreceiverAccountNo,'') != ISNULL(@fieldValue,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'receiverAccountNo', @oldreceiverAccountNo, @user, GETDATE(), @fieldValue,@tranId,@amendmentId
		END
	END
	ELSE IF @fieldName = 'receiverName'
	BEGIN
		IF OBJECT_ID('tempdb..#nameTable1') IS NOT NULL 
		DROP TABLE #nameTable1
		DECLARE @XMLDATA XML = CONVERT(xml, replace(@fieldValue,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('@firstName','VARCHAR(20)') AS 'firstName'
					,p.value('@middleName','VARCHAR(100)') AS 'middleName'
					--,p.value('@BANKNAME', 'varchar(50)') AS 'BankName'
					,p.value('@firstLastName','varchar(10)') AS 'firstLastName'
					,p.value('@secondLastName','varchar(10)') AS 'secondLastName'
		INTO #nameTable1
		FROM @XMLDATA.nodes('/root/row') AS apiStates(p)
		DECLARE @fname VARCHAR(20),@mname VARCHAR(20),@lname1 VARCHAR(20),@lanme2 VARCHAR(20)
		SELECT @fname = RTRIM(LTRIM(firstName))
			  ,@mname = RTRIM(LTRIM(middleName))
			  ,@lname1 = RTRIM(LTRIM(firstLastName))
			  ,@lanme2 = RTRIM(LTRIM(secondLastName))
		FROM #nameTable1
		IF ISNULL(@oldfirstName,'') != ISNULL(@fname,'') OR ISNULL(@oldmiddleName,'') != ISNULL(@mname,'') OR ISNULL(@oldlastName1,'') != ISNULL(@lname1,'') OR ISNULL(@oldlastName2,'') != ISNULL(@lanme2,'')	
		BEGIN
			DECLARE @oldNameValue VARCHAR(300),@newNameValue VARCHAR(300)
			SET @oldNameValue = ISNULL(@oldfirstName,'') + ISNULL(' ' + @oldmiddleName,'') + ISNULL(' '+@oldlastName1,'') + ISNULL(' '+@oldlastName1,'')
			SET @newNameValue = ISNULL(@fname,'') + ISNULL(' ' + @mname,'') + ISNULL(' '+@lname1,'') + ISNULL(' '+@lanme2,'')

			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'fullname', @oldNameValue, @user, GETDATE(), @newNameValue,@tranId,@amendmentId
	
		END
		--IF ISNULL(@oldfirstName,'') != ISNULL(@fname,'')	
		--BEGIN
		--	INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		--	SELECT @receiverId, 'firstName', @oldfirstName, @user, GETDATE(), @fname,@tranId,@amendmentId
		--END
		IF ISNULL(@oldmiddleName,'') != ISNULL(@mname,'')	
			BEGIN
				INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
				SELECT @receiverId, 'middleName', @oldmiddleName, @user, GETDATE(), @mname,@tranId,@amendmentId
			END
		IF ISNULL(@oldlastName1,'') != ISNULL(@lname1,'')	
			BEGIN
				INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
				SELECT @receiverId, 'lastName1', @oldlastName1, @user, GETDATE(), @lname1,@tranId,@amendmentId
			END
		IF ISNULL(@oldlastName2,'') != ISNULL(@lanme2,'')	
			BEGIN
				INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
				SELECT @receiverId, 'lastName2', @oldlastName2, @user, GETDATE(), @lanme2,@tranId,@amendmentId
			END
	END
END	
ELSE IF @flag = 'edit-fromSendPage'
BEGIN
	SET @amendmentId = NEWID()
	IF ISNULL(@oldaddress,'') != ISNULL(@address,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'address', @oldaddress, @user, GETDATE(), @address,@tranId,@amendmentId
	END
	IF ISNULL(@oldmobile,'') != ISNULL(@mobile,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'mobile', @oldmobile, @user, GETDATE(), @mobile,@tranId,@amendmentId
	END
	IF ISNULL(@oldcountry,'') != ISNULL(@country,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'country', @oldcountry, @user, GETDATE(), @country,@tranId,@amendmentId
	END
	IF ISNULL(@oldpaymentMode,'') != ISNULL(@paymentMode,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'paymentMode', @oldpaymentMode, @user, GETDATE(), @paymentMode,@tranId,@amendmentId
	END
	IF ISNULL(@oldpayOutPartner,'') != ISNULL(@payOutPartner,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'payOutPartner', @oldpayOutPartner, @user, GETDATE(), @payOutPartner,@tranId,@amendmentId
	END
	IF ISNULL(@oldbankLocation,'') != ISNULL(@bankLocation,'')	
		BEGIN
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'bankLocation', @oldbankLocation, @user, GETDATE(), @bankLocation,@tranId,@amendmentId
		END
	IF ISNULL(@oldreceiverAccountNo,'') != ISNULL(@receiverAccountNo,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'receiverAccountNo', @oldreceiverAccountNo, @user, GETDATE(), @receiverAccountNo,@tranId,@amendmentId
	END
	IF ISNULL(@oldpurposeOfRemit,'') != ISNULL(@purposeOfRemit,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'purposeOfRemit', @oldpurposeOfRemit, @user, GETDATE(), @purposeOfRemit,@tranId,@amendmentId
	END
	IF ISNULL(@oldrelationship,'') != ISNULL(@relationship,'')	
	BEGIN
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'relationship', @oldrelationship, @user, GETDATE(), @relationship,@tranId,@amendmentId
	END
	
END
ELSE IF @FLAG = 'i-fromModificationNew'
BEGIN
	DECLARE @addressChanged						BIT = 0
			,@mobileChanged						BIT = 0 
			,@idTypeChanged						BIT = 0
			,@idNumberChanged					BIT = 0 
			,@receiverAccountNoChanged			BIT = 0
	IF ISNULL(@sessionId,'') = ''
		SET @amendmentId = NEWID();
	ELSE
		SET @amendmentId = @sessionId;
	IF ISNULL(@oldaddress,'') != ISNULL(@address,'') AND @address IS NOT NULL
		BEGIN
			SET @addressChanged =1
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'address', @oldaddress, @user, GETDATE(), @address,@tranId,@amendmentId
		END
	IF ISNULL(@oldmobile,'') != ISNULL(@mobile,'')	AND @mobile IS NOT NULL
		BEGIN
			SET @mobileChanged = 1
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'mobile', @oldmobile, @user, GETDATE(), @mobile,@tranId,@amendmentId
		END
	IF ISNULL(@oldidType,'') != ISNULL(@idType,'')	AND @idType IS NOT NULL
		BEGIN
			SET @idTypeChanged = 1
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'idType', @oldidType, @user, GETDATE(), @idType,@tranId,@amendmentId
		END
		 
	IF ISNULL(@oldidNumber,'') != ISNULL(@idNumber,'')	AND @idNumber IS NOT NULL
		BEGIN
			SET @idNumberChanged = 1
			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'idNumber', @oldidNumber, @user, GETDATE(), @idNumber,@tranId,@amendmentId
		END
	IF ISNULL(@oldreceiverAccountNo,'') != ISNULL(@receiverAccountNo,'') AND @receiverAccountNo IS NOT NULL	
	BEGIN
		SET @receiverAccountNoChanged  = 1
		INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
		SELECT @receiverId, 'receiverAccountNo', @oldreceiverAccountNo, @user, GETDATE(), @receiverAccountNo,@tranId,@amendmentId
	END
	IF @nameChanged = 1 AND @nameChanged IS NOT NULL
	BEGIN

	IF OBJECT_ID('tempdb..#nameTable1') IS NOT NULL 
		DROP TABLE #nameTable1
		DECLARE @XMLDATANEW XML = CONVERT(xml, replace(@roldNameXml,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('@firstName','VARCHAR(100)') AS 'firstName'
					,p.value('@middleName','VARCHAR(100)') AS 'middleName'
					--,p.value('@BANKNAME', 'varchar(50)') AS 'BankName'
					,p.value('@firstLastName','varchar(100)') AS 'firstLastName'
					,p.value('@secondLastName','varchar(100)') AS 'secondLastName'
		INTO #nameTableNew
		FROM @XMLDATANEW.nodes('/root/row') AS apiStates(p)
		DECLARE @fnameNew VARCHAR(100),@mnameNew VARCHAR(100),@lname1New VARCHAR(100),@lname2New VARCHAR(100)
		IF isnull(@isNotXmlData,0) = 1
		BEGIN

		SELECT @fnameNew	 = RTRIM(LTRIM(@firstName))
			  ,@mnameNew	 = RTRIM(LTRIM(@middleName))
			  ,@lname1New	 = RTRIM(LTRIM(@lastName1))
			  ,@lname2New	 = RTRIM(LTRIM(@lastName2))
		END
		ELSE
		BEGIN
		SELECT @fnameNew = RTRIM(LTRIM(firstName))
			  ,@mnameNew = RTRIM(LTRIM(middleName))
			  ,@lname1New =RTRIM(LTRIM(firstLastName))
			  ,@lname2New =RTRIM(LTRIM(secondLastName))
			FROM #nameTableNew
		END
	
		IF ISNULL(@oldfirstName,'') != ISNULL(@fnameNew,'') OR ISNULL(@oldmiddleName,'') != ISNULL(@mnameNew,'') OR ISNULL(@oldlastName1,'') != ISNULL(@lname1New,'') OR ISNULL(@oldlastName2,'') != ISNULL(@lname2New,'')	
		BEGIN
			DECLARE @oldNameValueNew VARCHAR(300),@newNameValueNew VARCHAR(300)
			SET @oldNameValueNew = ISNULL(@oldfirstName,'') + ISNULL(' ' + @oldmiddleName,'') + ISNULL(' '+@oldlastName1,'') + ISNULL(' '+@oldlastName2,'')
			SET @newNameValueNew = ISNULL(@fnameNew,'') + ISNULL(' ' + @mnameNew,'') + ISNULL(' '+@lname1New,'') + ISNULL(' '+@lname2New,'')

			INSERT INTO TBLRECEIVERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,tranId,amendmentId)
			SELECT @receiverId, 'fullname', @oldNameValueNew, @user, GETDATE(), @newNameValueNew,@tranId,@amendmentId
		END
	
		DECLARE @ridNumber VARCHAR(50),@rIdType VARCHAR(50),@rAdd1 VARCHAR(100),@rMobile NVARCHAR(50),
				@raccountNo VARCHAR(100), @rTel	VARCHAR(50),@senderId BIGINT
		SET @ridNumber = CASE WHEN @idNumberChanged = 1 THEN @idNumber ELSE @oldidNumber END
		SET @rIdType = CASE WHEN @idTypeChanged = 1 THEN @idType ELSE @oldidType END
		SET @rAdd1 = CASE WHEN @addressChanged = 1 THEN @address ELSE @oldAddress END
		SET @rMobile = CASE WHEN @mobileChanged = 1 THEN @mobile ELSE @oldmobile END
		SET @raccountNo = CASE WHEN @receiverAccountNoChanged = 1 THEN @receiverAccountNo ELSE @oldreceiverAccountNo END
		SET @senderId = @customerId
		SET @receiverId = 0
		SET @rTel = COALESCE(@oldhomePhone,@oldworkPhone)
		--Register New Receiver
		select @rIdType=detailTitle from STATICDATAVALUE where valueId = @rIdType

		declare @newFullName varchar(200),@oldReceiverFound int = 0
		set @fnameNew = case when @fnameNew = '' then null else @fnameNew end
		set @mnameNew = case when @mnameNew = '' then null else @mnameNew end
		set @lname1New = case when @lname1New = '' then null else @lname1New end

		set @newFullName = ISNULL(@fnameNew,'') + ISNULL(' ' + @mnameNew,'') + ISNULL(' '+@lname1New,'')

		IF EXISTS(select 'X' from receiverinformation where customerId = @customerId and fullname = @newFullName)
			SET @oldReceiverFound = 1
		IF @oldReceiverFound = 1
		BEGIN
			SELECT @receiverId = receiverId
				  ,@oldfirstName = firstname
				  ,@oldmiddleName = middlename
				  ,@oldlastName1 = lastname1
				  ,@oldlastName2 = lastname2
			 from receiverinformation where customerId = @customerId and fullname = @newFullName

				UPDATE dbo.tranReceivers SET customerId	 = @receiverId
											,firstName	 = @oldfirstName
											,middleName = @oldmiddleName
											,lastName1	 = @oldlastName1
											,lastName2	 = @oldlastName2 
									    WHERE tranId = @tranId
		END
		ELSE
		BEGIN
			EXEC PROC_CHECK_RECEIVER_REGISTRATION @flag = 'i'
												,@user					= @user
												,@rfName				= @fnameNew
												,@rmName				= @mnameNew
												,@rlName				= @lname1New
												,@rlName2				= @lname2New
												,@receiverIdNo			= @ridNumber
												,@receiverIdType		= @rIdType
												,@receiverCountry		= @oldcountry
												,@receiverAdd			= @rAdd1
												,@receiverCity			= @oldcity
												,@receiverMobile		= @rMobile
												,@receiverPhone			= @rTel
												,@receiverEmail			= @oldemail
												,@receiverId			= @receiverId OUT
												,@customerId			= @senderId
												,@paymentMethodId		= @oldpaymentMode
												,@rBankId				= @payOutPartner
												,@rAccountNo			= @raccountNo
												,@fromTxnAmend			= 1

			--UPDATE dbo.tranReceivers
			UPDATE dbo.tranReceivers SET customerId	 = @receiverId
										 ,firstName	 = @fnameNew
										 ,middleName = @mnameNew
										 ,lastName1	 = @lname1New
										 ,lastName2	 = @lname2New 
									 WHERE tranId = @tranId
		END
	END
END	
END TRY	
BEGIN CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		SELECT '1' ErrCode,'Error in saving receiver logs' Msg,@customerId id
	END
END CATCH